using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using System.Xml;

public class CmfRecommendationRequest
{
    public string CpId { get; set; }
    public string Title { get; set; }
    public string Component { get; set; }
    public string CmfRequest { get; set; }
    public string Impact { get; set; }
    public string Idst { get; set; }
    public string ReproOnRvp { get; set; }
    public string Reproducibility { get; set; }
    public string CustomerDetail { get; set; }
    public string CustomerOwner { get; set; }
    public string Rules { get; set; }
}

public class CmfRecommendationRuleScore
{
    public string RuleId { get; set; }
    public string RuleName { get; set; }
    public string Score { get; set; }
    public string Evaluation { get; set; }
}

public class CmfRecommendationResponse
{
    public bool Success { get; set; }
    public string CpId { get; set; }
    public string Title { get; set; }
    public string Recommendation { get; set; }
    public string Evidence { get; set; }
    public int OverallQualityScore { get; set; }
    public int ThresholdScore { get; set; }
    public string NextSteps { get; set; }
    public List<CmfRecommendationRuleScore> RuleScores { get; set; }
    public string Message { get; set; }

    public CmfRecommendationResponse()
    {
        RuleScores = new List<CmfRecommendationRuleScore>();
    }
}

public static class CmfRecommendationService
{
    private static readonly object CacheSync = new object();
    private static readonly Dictionary<string, CmfRecommendationCacheEntry> Cache = new Dictionary<string, CmfRecommendationCacheEntry>(StringComparer.Ordinal);
        private const string RulesRelativePath = "~/App_Data/cmf-recommendation-rules.txt";
        private const string DefaultRulesText = @"rules:
    - id: R1
        name: Minimum replication / reproducibility evidence
        condition: reproducibility is meaningful OR RVP repro is yes
        weight: high
    - id: R2
        name: User or customer impact severity
        condition: impact contains High, Critical, customer blocker, data loss, hang, crash, or certification risk
        weight: high
    - id: R3
        name: Clear CMF request intent
        condition: cmf_request is cmf_ok, requested, pending, or otherwise asks for CMF review
        weight: medium
    - id: R4
        name: Enough issue context
        condition: title, component, and impact/justification are populated
        weight: medium
    - id: R5
        name: Not obviously low signal
        condition: impact is not empty and does not indicate no customer/user impact
        weight: medium
threshold_for_cmf_tag: 0.70";

    public class CmfRecommendationCacheEntry
    {
        public CmfRecommendationResponse Response { get; set; }
        public DateTime ExpiresAt { get; set; }
    }

    public static CmfRecommendationResponse GenerateCmfPendingRecommendation(CmfRecommendationRequest request)
    {
        if (request == null)
        {
            return new CmfRecommendationResponse
            {
                Success = false,
                Message = "Invalid recommendation request."
            };
        }

        string cpId = SafeText(request.CpId);
        string title = SafeText(request.Title);
        string component = SafeText(request.Component);
        string cmfRequest = SafeText(request.CmfRequest);
        string impact = SafeText(request.Impact);
        string idst = SafeText(request.Idst);
        string reproOnRvp = SafeText(request.ReproOnRvp);
        string reproducibility = SafeText(request.Reproducibility);
        string customerDetail = SafeText(request.CustomerDetail);
        string customerOwner = SafeText(request.CustomerOwner);
        string rules = SafeText(request.Rules);
        if (string.IsNullOrWhiteSpace(rules))
        {
            rules = GetActiveRulesText();
        }

        string hash = ComputeHash("cmf-recommendation-threshold-v3|" + cpId + "|" + title + "|" + component + "|" + cmfRequest + "|" + impact + "|" + idst + "|" + reproOnRvp + "|" + reproducibility + "|" + customerDetail + "|" + customerOwner + "|" + rules);
        string cacheKey = "cmf-recommendation:" + hash;

        CmfRecommendationResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached;
        }

        string modelRecommendation;
        string modelError;
        string deterministicRecommendation = BuildFallbackRecommendation(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules);
        bool hasModelRecommendation = TryGenerateWithGitHubModel(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, deterministicRecommendation, out modelRecommendation, out modelError);

        if (!hasModelRecommendation)
        {
            CmfRecommendationResponse fallbackResult = BuildFallbackRecommendationResponse(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, modelError);
            SetCached(cacheKey, fallbackResult, DateTime.UtcNow.AddMinutes(30));
            return fallbackResult;
        }

        // Parse structured response
        CmfRecommendationResponse result = ParseStructuredRecommendation(modelRecommendation);
        result.Success = true;
        result.CpId = cpId;
        result.Title = title;
        if (result.OverallQualityScore <= 0)
        {
            result.OverallQualityScore = CalculateOverallQualityScore(result.RuleScores);
        }
        int parsedThresholdScore = GetThresholdScore(rules);
        result.ThresholdScore = parsedThresholdScore;
        if (result.OverallQualityScore < parsedThresholdScore || HasFailedHighWeightRule(result.RuleScores))
        {
            result.Recommendation = "Do not tag as CMF";
        }
        else
        {
            result.Recommendation = "Tag as CMF";
        }
        if (string.IsNullOrWhiteSpace(result.Evidence))
        {
            result.Evidence = BuildReasoningFromScores(result.Recommendation, result.OverallQualityScore, parsedThresholdScore, result.RuleScores);
        }
        result.NextSteps = BuildNextSteps(result.Recommendation, result.RuleScores);
        result.Message = "AI recommendation generated.";

        SetCached(cacheKey, result, DateTime.UtcNow.AddMinutes(30));
        return result;
    }

    public static string GetDefaultRulesText()
    {
        return DefaultRulesText;
    }

    public static string GetActiveRulesText()
    {
        string path = ResolveRulesPath();
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
        {
            return DefaultRulesText;
        }

        string savedRules = File.ReadAllText(path);
        return string.IsNullOrWhiteSpace(savedRules) ? DefaultRulesText : savedRules.Trim();
    }

    public static void SaveActiveRulesText(string rulesText)
    {
        string cleanRules = SafeText(rulesText);
        if (string.IsNullOrWhiteSpace(cleanRules))
        {
            cleanRules = DefaultRulesText;
        }

        string path = ResolveRulesPath();
        string directory = Path.GetDirectoryName(path);
        if (!Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }

        File.WriteAllText(path, cleanRules, Encoding.UTF8);
        ClearRecommendationCache();
    }

    public static void ResetActiveRulesText()
    {
        SaveActiveRulesText(DefaultRulesText);
    }

    public static void ClearRecommendationCache()
    {
        lock (CacheSync)
        {
            Cache.Clear();
        }
    }

    private static string ResolveRulesPath()
    {
        if (System.Web.HttpContext.Current != null)
        {
            return System.Web.HttpContext.Current.Server.MapPath(RulesRelativePath);
        }

        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "cmf-recommendation-rules.txt");
    }

    private static CmfRecommendationResponse TryGetCached(string cacheKey)
    {
        lock (CacheSync)
        {
            CmfRecommendationCacheEntry entry;
            if (!Cache.TryGetValue(cacheKey, out entry))
            {
                return null;
            }

            if (DateTime.UtcNow > entry.ExpiresAt)
            {
                Cache.Remove(cacheKey);
                return null;
            }

            return entry.Response;
        }
    }

    private static void SetCached(string cacheKey, CmfRecommendationResponse response, DateTime expiresAt)
    {
        lock (CacheSync)
        {
            Cache[cacheKey] = new CmfRecommendationCacheEntry
            {
                Response = response,
                ExpiresAt = expiresAt
            };
        }
    }

    private static bool TryGenerateWithGitHubModel(
        string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string rules, string deterministicRecommendation,
        out string recommendation, out string error)
    {
        recommendation = string.Empty;
        error = string.Empty;

        string gnaiToken = ResolveGnaiToken();
        string gnaiEndpoint = FirstNonEmpty(System.Environment.GetEnvironmentVariable("GNAI_ENDPOINT"), GetAppSetting("GNAI:Endpoint"));
        string gnaiModel = FirstNonEmpty(System.Environment.GetEnvironmentVariable("GNAI_MODEL"), GetAppSetting("GNAI:Model"));
        bool useGnai = !string.IsNullOrWhiteSpace(gnaiToken)
            && !string.IsNullOrWhiteSpace(gnaiEndpoint)
            && !gnaiEndpoint.StartsWith("REPLACE");

        string apiKey, endpoint, model;
        if (useGnai)
        {
            apiKey = gnaiToken;
            endpoint = gnaiEndpoint;
            model = string.IsNullOrWhiteSpace(gnaiModel) ? "gpt-5-mini" : gnaiModel;
        }
        else
        {
            apiKey = ConfigurationManager.AppSettings["GitHubModels:ApiKey"] ?? string.Empty;
            endpoint = ConfigurationManager.AppSettings["GitHubModels:Endpoint"] ?? string.Empty;
            model = ConfigurationManager.AppSettings["GitHubModels:Model"] ?? string.Empty;
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                error = "No AI credentials. Set GNAI_TOKEN env var (or GNAI:ApiKey in Web.config) + GNAI:Endpoint, or set GitHubModels:ApiKey.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(endpoint))
                endpoint = "https://models.inference.ai.azure.com/chat/completions";
            if (string.IsNullOrWhiteSpace(model))
                model = "gpt-4o-mini";
        }

        string prompt = BuildCmfRecommendationPrompt(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, deterministicRecommendation);

        try
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = int.MaxValue;

            var payload = new
            {
                model = model,
                messages = new object[]
                {
                    new { role = "system", content = "You are an AI assistant specialized in CMF (Component Management Framework) pending issues. Use the admin-defined CMF rules as the decision policy. The recommendation must be binary: either Tag as CMF or Do not tag as CMF. If evidence is missing, partial, or contradictory, recommend Do not tag as CMF and cite the blocking rule IDs." },
                    new { role = "user", content = prompt }
                }
            };

            string payloadJson = serializer.Serialize(payload);

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(endpoint);
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            request.Method = "POST";
            request.ContentType = "application/json";
            request.Accept = "application/json";
            request.Headers["Authorization"] = "Bearer " + apiKey;
            request.UserAgent = "CMF-Portal-AI-Recommendation/1.0";
            request.Timeout = 30000;
            ConfigureProxy(request);

            using (StreamWriter writer = new StreamWriter(request.GetRequestStream()))
            {
                writer.Write(payloadJson);
            }

            string responseBody;
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (StreamReader reader = new StreamReader(response.GetResponseStream()))
            {
                responseBody = reader.ReadToEnd();
            }

            object raw = serializer.DeserializeObject(responseBody);

            if (raw is Dictionary<string, object>)
            {
                Dictionary<string, object> responseDict = raw as Dictionary<string, object>;
                if (responseDict.ContainsKey("choices"))
                {
                    object choicesObj = responseDict["choices"];
                    if (choicesObj is object[])
                    {
                        object[] choices = choicesObj as object[];
                        if (choices.Length > 0 && choices[0] is Dictionary<string, object>)
                        {
                            Dictionary<string, object> firstChoice = choices[0] as Dictionary<string, object>;
                            if (firstChoice.ContainsKey("message"))
                            {
                                object messageObj = firstChoice["message"];
                                if (messageObj is Dictionary<string, object>)
                                {
                                    Dictionary<string, object> message = messageObj as Dictionary<string, object>;
                                    if (message.ContainsKey("content"))
                                    {
                                        recommendation = message["content"] as string;
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            error = "Invalid response format from AI model.";
            return false;
        }
        catch (WebException webEx)
        {
            error = BuildModelRequestErrorMessage(webEx);
            return false;
        }
        catch (Exception ex)
        {
            error = ex.Message;
            return false;
        }
    }

    private static string BuildModelRequestErrorMessage(WebException webEx)
    {
        HttpWebResponse response = webEx.Response as HttpWebResponse;
        string body = ReadResponseBody(response);

        if (response == null)
        {
            return "Model request failed: no response from provider. Check access to the configured GNAI/GitHub endpoint.";
        }

        int statusCode = (int)response.StatusCode;
        string providerMessage = ExtractProviderErrorMessage(body);

        if (statusCode == 401)
        {
            return "Model request failed (401 Unauthorized): AI token is invalid or expired." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 403)
        {
            return "Model request failed (403 Forbidden): AI token does not have access to this model resource." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 404)
        {
            return "Model request failed (404 Not Found): endpoint or model may be incorrect." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 429)
        {
            return "Model request failed (429 Too Many Requests): rate limit reached." + AppendProviderMessage(providerMessage);
        }

        if (statusCode >= 500)
        {
            return "Model request failed (" + statusCode + "): provider service error." + AppendProviderMessage(providerMessage);
        }

        return "Model request failed (" + statusCode + ")." + AppendProviderMessage(providerMessage);
    }

    private static string ReadResponseBody(HttpWebResponse response)
    {
        if (response == null)
        {
            return string.Empty;
        }

        try
        {
            using (Stream stream = response.GetResponseStream())
            {
                if (stream == null)
                {
                    return string.Empty;
                }

                using (StreamReader reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
        }
        catch
        {
            return string.Empty;
        }
    }

    private static string ExtractProviderErrorMessage(string responseBody)
    {
        if (string.IsNullOrWhiteSpace(responseBody))
        {
            return string.Empty;
        }

        try
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            object raw = serializer.DeserializeObject(responseBody);
            IDictionary root = raw as IDictionary;
            if (root == null)
            {
                return responseBody.Trim();
            }

            IDictionary errorObj = root["error"] as IDictionary;
            if (errorObj != null && errorObj["message"] != null)
            {
                return errorObj["message"].ToString();
            }

            if (root["message"] != null)
            {
                return root["message"].ToString();
            }
        }
        catch
        {
        }

        return responseBody.Trim();
    }

    private static string AppendProviderMessage(string providerMessage)
    {
        if (string.IsNullOrWhiteSpace(providerMessage))
        {
            return string.Empty;
        }

        string sanitizedMessage = providerMessage.Trim();
        if (sanitizedMessage.IndexOf("You do not belong to any of the group", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            sanitizedMessage = "access denied because the account is not in an allowed access group for this model resource";
        }

        const int maxLength = 220;
        if (sanitizedMessage.Length > maxLength)
        {
            sanitizedMessage = sanitizedMessage.Substring(0, maxLength) + "...";
        }

        return " Provider says: " + sanitizedMessage;
    }

    private static string BuildFallbackMessage(string modelError)
    {
        if (string.IsNullOrWhiteSpace(modelError))
        {
            return "AI model unavailable. Showing deterministic fallback recommendation.";
        }

        return "AI model unavailable. Showing deterministic fallback recommendation. " + modelError;
    }

    private static string BuildFallbackRecommendation(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string rules)
    {
        string safeCpId = string.IsNullOrWhiteSpace(cpId) ? "N/A" : cpId.Trim();
        string safeTitle = string.IsNullOrWhiteSpace(title) ? "Untitled issue" : title.Trim();
        string safeComponent = string.IsNullOrWhiteSpace(component) ? "Unknown" : component.Trim();
        string safeRequest = string.IsNullOrWhiteSpace(cmfRequest) ? "Unknown" : cmfRequest.Trim();
        string safeImpact = BuildImpactSnippet(impact);
        bool hasContext = !string.IsNullOrWhiteSpace(title) && !string.IsNullOrWhiteSpace(component) && !string.IsNullOrWhiteSpace(impact);
        bool hasRequestIntent = ContainsAny(cmfRequest, new string[] { "cmf_ok", "cmf ask", "cmf_ask", "request", "pending", "review" });
        bool strongRequestIntent = ContainsAny(cmfRequest, new string[] { "cmf_ok", "approved", "requested" });
        bool negativeRepro = ContainsAny(reproducibility, new string[] { "not reproduced", "not reproduce", "no repro", "cannot reproduce", "unable to reproduce", "not able to reproduce" })
            || ContainsAny(reproOnRvp, new string[] { "no", "false", "n/a", "not reproduced", "not reproduce" });
        bool meaningfulRepro = !negativeRepro && (ContainsAny(reproducibility, new string[] { "yes", "reproduces", "reproduced", "always", "consistent", "100", "high" })
            || ContainsAny(reproOnRvp, new string[] { "yes", "y", "true", "reproduces", "reproduced" }));
        bool highImpact = ContainsAny(impact, new string[] { "critical", "high", "blocker", "showstopper", "hang", "crash", "data loss", "certification", "sla" });
        bool lowImpact = ContainsAny(impact, new string[] { "no impact", "low", "minor", "cosmetic", "informational", "unable to reproduce" });
        bool hasSysScopeEvidence = !string.IsNullOrWhiteSpace(idst) || !string.IsNullOrWhiteSpace(reproducibility) || !string.IsNullOrWhiteSpace(reproOnRvp);
        string decision;
        string ruleSummary;

        if (hasContext && hasRequestIntent && meaningfulRepro && highImpact && hasSysScopeEvidence && !lowImpact)
        {
            decision = "Tag as CMF";
            ruleSummary = "R1-R5 are satisfied: reproducibility/SysScope evidence exists, the issue has high impact, CMF request intent is clear, context is complete, and no low-signal language is present.";
        }
        else if (!hasContext || lowImpact || !hasRequestIntent)
        {
            decision = "Do not tag as CMF";
            ruleSummary = "One or more mandatory rules are not satisfied. The available data does not support an automatic CMF tag.";
        }
        else
        {
            decision = "Do not tag as CMF";
            ruleSummary = "Some signals are present, but the available evidence is not strong enough to recommend a CMF tag.";
        }

        StringBuilder builder = new StringBuilder();
        builder.AppendLine("## Recommendation: " + decision);
        builder.AppendLine();
        builder.AppendLine("- Why: " + ruleSummary);
        builder.AppendLine("- Decision driver: " + BuildRecommendationDecisionDriver(decision, hasContext, hasRequestIntent, meaningfulRepro, highImpact, hasSysScopeEvidence, lowImpact) + ".");
        builder.AppendLine("- Evidence used: request state is \"" + safeRequest + "\"; RVP repro is \"" + SafeDisplay(reproOnRvp) + "\"; reproducibility is \"" + SafeDisplay(reproducibility) + "\"; iDST is \"" + SafeDisplay(idst) + "\"; impact is " + safeImpact + ".");
        builder.AppendLine("- Admin rules used: " + BuildRulesSnippet(rules));
        if (decision == "Tag as CMF")
        {
            builder.Append("Recommended next step: tag as CMF and record the owner ETA, because the rule evidence is complete enough for the tag.");
        }
        else
        {
            builder.Append("Recommended next step: do not tag as CMF unless the missing rule evidence is added and re-evaluated.");
        }
        return builder.ToString();
    }

    private static string BuildRecommendationDecisionDriver(string decision, bool hasContext, bool hasRequestIntent, bool meaningfulRepro, bool highImpact, bool hasSysScopeEvidence, bool lowImpact)
    {
        if (decision == "Tag as CMF")
        {
            return "the issue meets the CMF intent, reproducibility, SysScope/context, and high-impact gates, so the rules support tagging";
        }

        List<string> missing = new List<string>();
        if (!hasContext) missing.Add("complete issue context");
        if (!hasRequestIntent) missing.Add("clear CMF request intent");
        if (!meaningfulRepro) missing.Add("direct reproducibility evidence");
        if (!highImpact) missing.Add("high customer or user impact");
        if (!hasSysScopeEvidence) missing.Add("SysScope/iDST evidence");
        if (lowImpact) missing.Add("absence of low-impact language");

        if (missing.Count == 0)
        {
            return "the available signals are mixed and do not clear the active CMF tagging threshold";
        }

        return "the recommendation is blocked by missing or weak " + JoinReadableList(missing);
    }

    private static string JoinReadableList(List<string> values)
    {
        if (values == null || values.Count == 0) return string.Empty;
        if (values.Count == 1) return values[0];
        if (values.Count == 2) return values[0] + " and " + values[1];

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < values.Count; i++)
        {
            if (i > 0)
            {
                builder.Append(i == values.Count - 1 ? ", and " : ", ");
            }
            builder.Append(values[i]);
        }
        return builder.ToString();
    }

    private static CmfRecommendationResponse BuildFallbackRecommendationResponse(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string rules, string modelError)
    {
        bool hasContext = !string.IsNullOrWhiteSpace(title) && !string.IsNullOrWhiteSpace(component) && !string.IsNullOrWhiteSpace(impact);
        bool hasRequestIntent = ContainsAny(cmfRequest, new string[] { "cmf_ok", "cmf ask", "cmf_ask", "request", "pending", "review" });
        bool strongRequestIntent = ContainsAny(cmfRequest, new string[] { "cmf_ok", "approved", "requested" });
        bool negativeRepro = ContainsAny(reproducibility, new string[] { "not reproduced", "not reproduce", "no repro", "cannot reproduce", "unable to reproduce", "not able to reproduce" })
            || ContainsAny(reproOnRvp, new string[] { "no", "false", "n/a", "not reproduced", "not reproduce" });
        bool meaningfulRepro = !negativeRepro && (ContainsAny(reproducibility, new string[] { "yes", "reproduces", "reproduced", "always", "consistent", "100", "high" })
            || ContainsAny(reproOnRvp, new string[] { "yes", "y", "true", "reproduces", "reproduced" }));
        bool highImpact = ContainsAny(impact, new string[] { "critical", "high", "blocker", "showstopper", "hang", "crash", "data loss", "certification", "sla" });
        bool lowImpact = ContainsAny(impact, new string[] { "no impact", "low", "minor", "cosmetic", "informational", "unable to reproduce" });
        bool hasSysScopeEvidence = !string.IsNullOrWhiteSpace(idst) || !string.IsNullOrWhiteSpace(reproducibility) || !string.IsNullOrWhiteSpace(reproOnRvp);

        var ruleScores = new List<CmfRecommendationRuleScore>
        {
            new CmfRecommendationRuleScore { RuleId = "R1", RuleName = "Minimum replication / reproducibility evidence", Score = meaningfulRepro ? "100" : (hasSysScopeEvidence ? "55" : "0"), Evaluation = meaningfulRepro ? "PASS - Reproducibility/RVP repro evidence is present." : (hasSysScopeEvidence ? "PARTIAL - SysScope/iDST context exists, but direct reproducibility evidence is incomplete." : "FAIL - Reproducibility and RVP repro evidence are missing.") },
            new CmfRecommendationRuleScore { RuleId = "R2", RuleName = "User or customer impact severity", Score = highImpact ? "100" : (lowImpact ? "0" : "50"), Evaluation = highImpact ? "PASS - Impact text indicates high customer/user severity: " + SafeDisplay(impact) : (lowImpact ? "FAIL - Impact appears low or explicitly non-blocking: " + SafeDisplay(impact) : "PARTIAL - Impact exists but does not clearly show high severity: " + SafeDisplay(impact)) },
            new CmfRecommendationRuleScore { RuleId = "R3", RuleName = "Clear CMF request intent", Score = strongRequestIntent ? "100" : (hasRequestIntent ? "60" : "0"), Evaluation = strongRequestIntent ? "PASS - CMF request intent is clear from request status: " + SafeDisplay(cmfRequest) : (hasRequestIntent ? "PARTIAL - CMF request is present but needs PM confirmation: " + SafeDisplay(cmfRequest) : "FAIL - CMF request intent is missing or unclear.") },
            new CmfRecommendationRuleScore { RuleId = "R4", RuleName = "Enough issue context", Score = hasContext ? "100" : "20", Evaluation = hasContext ? "PASS - Title, component, and impact context are available for " + SafeDisplay(component) + "." : "FAIL - Required issue context is incomplete." },
            new CmfRecommendationRuleScore { RuleId = "R5", RuleName = "Not obviously low signal", Score = lowImpact ? "0" : "100", Evaluation = lowImpact ? "FAIL - Low/no-impact language was detected." : "PASS - No obvious low-signal language was detected." }
        };

        int overallQualityScore = CalculateOverallQualityScore(ruleScores);
        int thresholdScore = GetThresholdScore(rules);
        bool hasHighWeightFailure = !meaningfulRepro || !highImpact;
        string decision = overallQualityScore >= thresholdScore && !hasHighWeightFailure && hasContext && hasRequestIntent && !lowImpact
            ? "Tag as CMF"
            : "Do not tag as CMF";
        string evidence = BuildReasoningFromScores(decision, overallQualityScore, thresholdScore, ruleScores);

        return new CmfRecommendationResponse
        {
            Success = true,
            CpId = cpId,
            Title = title,
            Recommendation = decision,
            Evidence = evidence,
            OverallQualityScore = overallQualityScore,
            ThresholdScore = thresholdScore,
            NextSteps = BuildNextSteps(decision, ruleScores),
            RuleScores = ruleScores,
            Message = BuildFallbackMessage(modelError)
        };
    }

    private static int CalculateOverallQualityScore(List<CmfRecommendationRuleScore> ruleScores)
    {
        if (ruleScores == null || ruleScores.Count == 0)
        {
            return 0;
        }

        int weightedTotal = 0;
        int weightTotal = 0;
        foreach (CmfRecommendationRuleScore rule in ruleScores)
        {
            int score;
            if (rule != null && int.TryParse((rule.Score ?? string.Empty).Replace("%", string.Empty).Trim(), out score))
            {
                int weight = IsHighWeightRule(rule.RuleId) ? 2 : 1;
                weightedTotal += Math.Max(0, Math.Min(100, score)) * weight;
                weightTotal += weight;
            }
        }

        return weightTotal == 0 ? 0 : (int)Math.Round(weightedTotal / (double)weightTotal);
    }

    private static bool IsHighWeightRule(string ruleId)
    {
        return string.Equals(ruleId, "R1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(ruleId, "R2", StringComparison.OrdinalIgnoreCase);
    }

    private static bool HasFailedHighWeightRule(List<CmfRecommendationRuleScore> ruleScores)
    {
        if (ruleScores == null) return false;
        foreach (CmfRecommendationRuleScore rule in ruleScores)
        {
            if (rule == null || !IsHighWeightRule(rule.RuleId)) continue;
            int score;
            if (int.TryParse((rule.Score ?? string.Empty).Replace("%", string.Empty).Trim(), out score) && score <= 0)
            {
                return true;
            }
            if ((rule.Evaluation ?? string.Empty).Trim().StartsWith("FAIL", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    private static int GetThresholdScore(string rules)
    {
        if (string.IsNullOrWhiteSpace(rules)) return 70;
        string marker = "threshold_for_cmf_tag:";
        int index = rules.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (index < 0) return 70;

        string tail = rules.Substring(index + marker.Length).Trim();
        string[] parts = tail.Split(new[] { '\r', '\n', ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0) return 70;

        double threshold;
        if (double.TryParse(parts[0], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out threshold))
        {
            if (threshold <= 1) return (int)Math.Round(threshold * 100);
            return (int)Math.Round(threshold);
        }

        return 70;
    }

    private static string BuildReasoningFromScores(string recommendation, int overallQualityScore, int thresholdScore, List<CmfRecommendationRuleScore> ruleScores)
    {
        List<string> blockers = new List<string>();
        List<string> strengths = new List<string>();
        bool hasReproStrength = false;
        bool hasImpactStrength = false;
        bool hasIntentStrength = false;
        bool hasContextStrength = false;
        bool hasLowSignalStrength = false;
        if (ruleScores != null)
        {
            foreach (CmfRecommendationRuleScore rule in ruleScores)
            {
                string evaluation = rule == null ? string.Empty : SafeText(rule.Evaluation);
                string ruleId = rule == null ? string.Empty : SafeText(rule.RuleId);
                if (evaluation.StartsWith("FAIL", StringComparison.OrdinalIgnoreCase) || evaluation.StartsWith("PARTIAL", StringComparison.OrdinalIgnoreCase))
                {
                    blockers.Add((rule.RuleId ?? "Rule") + ": " + evaluation);
                }
                else if (evaluation.StartsWith("PASS", StringComparison.OrdinalIgnoreCase))
                {
                    strengths.Add((rule.RuleId ?? "Rule") + ": " + evaluation);
                    if (string.Equals(ruleId, "R1", StringComparison.OrdinalIgnoreCase)) hasReproStrength = true;
                    if (string.Equals(ruleId, "R2", StringComparison.OrdinalIgnoreCase)) hasImpactStrength = true;
                    if (string.Equals(ruleId, "R3", StringComparison.OrdinalIgnoreCase)) hasIntentStrength = true;
                    if (string.Equals(ruleId, "R4", StringComparison.OrdinalIgnoreCase)) hasContextStrength = true;
                    if (string.Equals(ruleId, "R5", StringComparison.OrdinalIgnoreCase)) hasLowSignalStrength = true;
                }
            }
        }

        string primary = blockers.Count > 0 ? BuildPlainReasonFromRuleText(blockers[0]) : (strengths.Count > 0 ? BuildPlainReasonFromRuleText(strengths[0]) : "the available fields were checked against the active CMF policy");
        string secondary = blockers.Count > 1 ? BuildPlainReasonFromRuleText(blockers[1]) : (strengths.Count > 1 ? BuildPlainReasonFromRuleText(strengths[1]) : string.Empty);
        StringBuilder reasoning = new StringBuilder();
        reasoning.Append("The recommendation is based on whether the issue has enough CMF-worthy evidence, not just whether details are present. ");
        reasoning.Append("It scored ").Append(overallQualityScore).Append("/100 against a ").Append(thresholdScore).Append("/100 threshold. ");
        reasoning.Append(string.IsNullOrWhiteSpace(recommendation) ? "Do not tag as CMF" : recommendation).Append(" was selected because ");
        if (blockers.Count == 0)
        {
            reasoning.Append(BuildPositiveRecommendationBasis(hasReproStrength, hasImpactStrength, hasIntentStrength, hasContextStrength, hasLowSignalStrength));
            reasoning.Append(" Supporting signals include ").Append(TrimTrailingSentencePunctuation(primary));
            if (!string.IsNullOrWhiteSpace(secondary))
            {
                reasoning.Append(" and ").Append(TrimTrailingSentencePunctuation(secondary));
            }
            reasoning.Append(".");
        }
        else
        {
            reasoning.Append("one or more gating signals are weak or missing. ");
            reasoning.Append("The main blocker is ").Append(primary);
            if (!string.IsNullOrWhiteSpace(secondary))
            {
                reasoning.Append(". A second concern is ").Append(secondary);
            }
            reasoning.Append(". Because these are gating signals, the item should not move forward until the missing evidence is clarified.");
        }
        return reasoning.ToString();
    }

    private static string BuildPlainReasonFromRuleText(string ruleText)
    {
        string text = SafeText(ruleText);
        string upper = text.ToUpperInvariant();
        string detail = ExtractRuleDetail(text);

        if (text.IndexOf("R1", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            if (upper.Contains("FAIL")) return "there is no clear reproduction or RVP validation evidence yet";
            if (upper.Contains("PARTIAL")) return "there is some debug or iDST context, but not enough direct reproduction proof";
            return "the issue has reproduction or RVP evidence that makes the failure credible";
        }

        if (text.IndexOf("R2", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            if (upper.Contains("FAIL")) return "the described impact looks low or non-blocking" + detail;
            if (upper.Contains("PARTIAL")) return "impact is present, but it does not clearly show a severe customer or user consequence" + detail;
            return "the impact description is severe enough to justify CMF attention" + detail;
        }

        if (text.IndexOf("R3", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            if (upper.Contains("FAIL")) return "the record does not show a clear CMF request or acceptance intent";
            if (upper.Contains("PARTIAL")) return "the CMF request is present but still needs PM confirmation" + detail;
            return "the request state already shows clear CMF intent" + detail;
        }

        if (text.IndexOf("R4", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            if (upper.Contains("FAIL")) return "basic issue context such as title, component, or impact is incomplete";
            return "the issue has enough component and impact context for a decision" + detail;
        }

        if (text.IndexOf("R5", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            if (upper.Contains("FAIL")) return "the wording suggests this may be low signal or low impact";
            return "there is no obvious low-signal wording blocking the recommendation";
        }

        return string.IsNullOrWhiteSpace(detail) ? "the available evidence was checked against the active rules" : detail.TrimStart(' ', '-', ':');
    }

    private static string ExtractRuleDetail(string ruleText)
    {
        if (string.IsNullOrWhiteSpace(ruleText)) return string.Empty;
        int separator = ruleText.LastIndexOf(':');
        if (separator < 0 || separator >= ruleText.Length - 1) return string.Empty;

        string detail = ruleText.Substring(separator + 1).Trim().TrimEnd('.');
        if (string.IsNullOrWhiteSpace(detail) || detail.Equals("missing", StringComparison.OrdinalIgnoreCase)) return string.Empty;
        return " (" + detail + ")";
    }

    private static string BuildPositiveRecommendationBasis(bool hasReproStrength, bool hasImpactStrength, bool hasIntentStrength, bool hasContextStrength, bool hasLowSignalStrength)
    {
        List<string> basis = new List<string>();
        if (hasReproStrength) basis.Add("the issue has direct reproduction or RVP validation evidence");
        if (hasImpactStrength) basis.Add("the customer/user impact is severe enough to justify CMF attention");
        if (hasIntentStrength) basis.Add("the request state shows clear CMF intent");
        if (hasContextStrength) basis.Add("the issue has enough title, component, and impact context for action");
        if (hasLowSignalStrength) basis.Add("there is no obvious low-impact or low-signal wording blocking the tag");

        if (basis.Count == 0)
        {
            return "the available evidence clears the active CMF decision policy.";
        }

        return JoinReadableList(basis) + ".";
    }

    private static string TrimTrailingSentencePunctuation(string text)
    {
        return string.IsNullOrWhiteSpace(text) ? string.Empty : text.Trim().TrimEnd('.', ';', ':');
    }

    private static string BuildNextSteps(string recommendation, List<CmfRecommendationRuleScore> ruleScores)
    {
        bool shouldTag = string.Equals(recommendation, "Tag as CMF", StringComparison.OrdinalIgnoreCase);
        List<string> steps = new List<string>();

        if (shouldTag)
        {
            steps.Add("Tag the issue as CMF and capture the owner, ETA, and validation evidence in the tracking notes.");
            steps.Add("Notify the affected customer or program contact with the reason for CMF acceptance and expected follow-up path.");
            steps.Add("Monitor for duplicate sightings so related issues can be merged or linked cleanly.");
        }
        else
        {
            steps.Add("Keep the item out of CMF tagging until the blocking evidence is resolved.");
            steps.Add("Ask the owner to add the missing reproducibility, SysScope/iDST, or impact justification called out by the rule evaluation.");
            steps.Add("Re-run the recommendation after the missing data is updated, especially if customer impact or repro evidence changes.");
        }

        return string.Join("\n", steps.ToArray());
    }

    private static string FormatReasonClause(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string trimmed = text.Trim();
        int separatorIndex = trimmed.IndexOf(':');
        if (separatorIndex > 0 && separatorIndex < trimmed.Length - 1)
        {
            string tail = trimmed.Substring(separatorIndex + 1).TrimStart();
            if (tail.Length == 0) return trimmed.Substring(0, separatorIndex + 1);
            return trimmed.Substring(0, separatorIndex + 1) + " " + tail;
        }

        return trimmed;
    }

    private static string SafeDisplay(string value)
    {
        return string.IsNullOrWhiteSpace(value) ? "missing" : BuildImpactSnippet(value);
    }

    private static bool ContainsAny(string source, string[] tokens)
    {
        if (string.IsNullOrWhiteSpace(source) || tokens == null)
        {
            return false;
        }

        foreach (string token in tokens)
        {
            if (!string.IsNullOrWhiteSpace(token) && source.IndexOf(token, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return true;
            }
        }

        return false;
    }

    private static string BuildRulesSnippet(string rules)
    {
        string normalized = BuildImpactSnippet(rules);
        return string.IsNullOrWhiteSpace(normalized) ? "default CMF rules" : normalized;
    }

    private static string BuildImpactSnippet(string impact)
    {
        if (string.IsNullOrWhiteSpace(impact))
        {
            return "No impact details were provided";
        }

        string normalized = impact.Replace("\r", " ").Replace("\n", " ").Trim();
        while (normalized.IndexOf("  ", StringComparison.Ordinal) >= 0)
        {
            normalized = normalized.Replace("  ", " ");
        }

        const int maxLength = 140;
        if (normalized.Length > maxLength)
        {
            normalized = normalized.Substring(0, maxLength) + "...";
        }

        return normalized;
    }

    private static CmfRecommendationResponse ParseStructuredRecommendation(string rawResponse)
    {
        var response = new CmfRecommendationResponse
        {
            Recommendation = string.Empty,
            Evidence = string.Empty,
            RuleScores = new List<CmfRecommendationRuleScore>()
        };

        if (string.IsNullOrWhiteSpace(rawResponse))
        {
            response.Recommendation = "Unable to parse recommendation.";
            return response;
        }

        string[] lines = rawResponse.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        string currentSection = string.Empty;
        StringBuilder evidenceBuilder = new StringBuilder();

        foreach (string line in lines)
        {
            string trimmed = line.Trim();
            
            if (trimmed.StartsWith("RECOMMENDATION:", StringComparison.OrdinalIgnoreCase))
            {
                currentSection = "RECOMMENDATION";
                response.Recommendation = trimmed.Substring("RECOMMENDATION:".Length).Trim();
                continue;
            }
            
            if (trimmed.StartsWith("EVIDENCE:", StringComparison.OrdinalIgnoreCase) ||
                trimmed.StartsWith("AI REASONING:", StringComparison.OrdinalIgnoreCase))
            {
                currentSection = "EVIDENCE";
                continue;
            }

            if (trimmed.StartsWith("OVERALL QUALITY SCORE:", StringComparison.OrdinalIgnoreCase))
            {
                int score;
                string scoreText = trimmed.Substring("OVERALL QUALITY SCORE:".Length).Replace("/100", string.Empty).Replace("%", string.Empty).Trim();
                if (int.TryParse(scoreText, out score))
                {
                    response.OverallQualityScore = Math.Max(0, Math.Min(100, score));
                }
                continue;
            }
            
            if (trimmed.StartsWith("RULE SCORES:", StringComparison.OrdinalIgnoreCase) || 
                trimmed.StartsWith("Rule ID", StringComparison.OrdinalIgnoreCase))
            {
                currentSection = "RULES";
                continue;
            }

            // Process content based on current section
            if (currentSection == "EVIDENCE" && !string.IsNullOrWhiteSpace(trimmed))
            {
                if (!trimmed.StartsWith("RULE", StringComparison.OrdinalIgnoreCase))
                {
                    if (evidenceBuilder.Length > 0) evidenceBuilder.Append(" ");
                    evidenceBuilder.Append(trimmed);
                }
            }
            else if (currentSection == "RULES" && trimmed.Contains("|"))
            {
                string[] parts = trimmed.Split('|');
                if (parts.Length >= 4)
                {
                    CmfRecommendationRuleScore ruleScore = new CmfRecommendationRuleScore
                    {
                        RuleId = parts[0].Trim(),
                        RuleName = parts[1].Trim(),
                        Score = NormalizeNumericScore(parts[2].Trim()),
                        Evaluation = parts[3].Trim()
                    };
                    response.RuleScores.Add(ruleScore);
                }
            }
        }

        response.Evidence = evidenceBuilder.ToString().Trim();
        if (response.OverallQualityScore <= 0)
        {
            response.OverallQualityScore = CalculateOverallQualityScore(response.RuleScores);
        }
        
        // Fallback if parsing failed
        if (string.IsNullOrWhiteSpace(response.Recommendation))
        {
            response.Recommendation = rawResponse.Length > 200 ? rawResponse.Substring(0, 200) + "..." : rawResponse;
        }

        return response;
    }

    private static string NormalizeNumericScore(string scoreText)
    {
        if (string.IsNullOrWhiteSpace(scoreText)) return "0";
        string normalized = scoreText.Replace("/100", string.Empty).Replace("%", string.Empty).Trim();
        int score;
        if (int.TryParse(normalized, out score))
        {
            return Math.Max(0, Math.Min(100, score)).ToString();
        }

        if (scoreText.Equals("PASS", StringComparison.OrdinalIgnoreCase)) return "100";
        if (scoreText.Equals("PARTIAL", StringComparison.OrdinalIgnoreCase)) return "50";
        if (scoreText.Equals("FAIL", StringComparison.OrdinalIgnoreCase)) return "0";
        return "0";
    }

    private static string BuildCmfRecommendationPrompt(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string rules, string deterministicRecommendation)
    {
        StringBuilder prompt = new StringBuilder();
        prompt.AppendLine("Analyze the following CMF (Component Management Framework) pending issue against the admin-defined CMF rules.");
        prompt.AppendLine();
        prompt.AppendLine("Admin-defined CMF rules:");
        prompt.AppendLine(string.IsNullOrWhiteSpace(rules) ? DefaultRulesText : rules);
        prompt.AppendLine();
        prompt.AppendLine("Issue details:");
        prompt.AppendLine("CP ID: " + (string.IsNullOrWhiteSpace(cpId) ? "N/A" : cpId));
        prompt.AppendLine("Title: " + (string.IsNullOrWhiteSpace(title) ? "N/A" : title));
        prompt.AppendLine("Component: " + (string.IsNullOrWhiteSpace(component) ? "N/A" : component));
        prompt.AppendLine("CMF Request Status: " + (string.IsNullOrWhiteSpace(cmfRequest) ? "N/A" : cmfRequest));
        prompt.AppendLine("Impact/Justification: " + (string.IsNullOrWhiteSpace(impact) ? "N/A" : impact));
        prompt.AppendLine("iDST/SysScope Evidence: " + (string.IsNullOrWhiteSpace(idst) ? "N/A" : idst));
        prompt.AppendLine("RVP Repro: " + (string.IsNullOrWhiteSpace(reproOnRvp) ? "N/A" : reproOnRvp));
        prompt.AppendLine("Reproducibility: " + (string.IsNullOrWhiteSpace(reproducibility) ? "N/A" : reproducibility));
        prompt.AppendLine("Customer Detail: " + (string.IsNullOrWhiteSpace(customerDetail) ? "N/A" : customerDetail));
        prompt.AppendLine("Customer Owner: " + (string.IsNullOrWhiteSpace(customerOwner) ? "N/A" : customerOwner));
        prompt.AppendLine();
        prompt.AppendLine("Provide your response in this exact format:");
        prompt.AppendLine("Use threshold_for_cmf_tag from the rules as the minimum overall quality score for tagging. Treat high-weight rules as blocking gates: if a high-weight rule fails, recommend Do not tag as CMF even when the rollup score is near the threshold. The overall quality score should be weighted by rule weight, not a plain average.");
        prompt.AppendLine();
        prompt.AppendLine("RECOMMENDATION: [One line only: exactly \"Tag as CMF\" or exactly \"Do not tag as CMF\"]");
        prompt.AppendLine();
        prompt.AppendLine("OVERALL QUALITY SCORE: [0-100 integer rollup based on the rule scores]");
        prompt.AppendLine();
        prompt.AppendLine("AI REASONING:");
        prompt.AppendLine("[2-3 issue-specific sentences that answer why this recommendation was made. Connect the decision to the strongest supporting or blocking rule IDs, explain the causal decision driver, and avoid simply restating issue fields.] ");
        prompt.AppendLine();
        prompt.AppendLine("RULE SCORES:");
        prompt.AppendLine("For each rule defined above, provide:");
        prompt.AppendLine("Rule ID | Rule Name | Score | Evaluation");
        prompt.AppendLine("[Example: R1 | Minimum replication evidence | 100 | PASS - Reproducibility is documented]");
        prompt.AppendLine("[Example: R2 | User impact severity | 0 | FAIL - Impact level is not critical]");
        prompt.AppendLine();
        prompt.AppendLine("Use numeric scores only in the Score column: 100 for PASS, 50-70 for PARTIAL, and 0 for FAIL. Put PASS, FAIL, or PARTIAL at the start of the Evaluation text. Be specific and concise. If any important rule is FAIL or PARTIAL, the recommendation should be Do not tag as CMF.");

        return prompt.ToString();
    }

    private static string SafeText(string input)
    {
        return string.IsNullOrWhiteSpace(input) ? string.Empty : input.Trim();
    }

    private static void ConfigureProxy(HttpWebRequest request)
    {
        // GNAI is internal, so NO proxy needed for it
        // Only GitHub Models (external) requires the DMZ proxy
        string gnaiToken = ResolveGnaiToken();
        string gnaiEndpoint = FirstNonEmpty(System.Environment.GetEnvironmentVariable("GNAI_ENDPOINT"), GetAppSetting("GNAI:Endpoint"));
        bool usingGnai = !string.IsNullOrWhiteSpace(gnaiToken)
            && !string.IsNullOrWhiteSpace(gnaiEndpoint)
            && !gnaiEndpoint.StartsWith("REPLACE");
        
        if (usingGnai)
        {
            string gnaiProxy = FirstNonEmpty(System.Environment.GetEnvironmentVariable("GNAI_PROXY"), GetAppSetting("GNAI:Proxy"));
            if (!string.IsNullOrWhiteSpace(gnaiProxy))
            {
                WebProxy explicitGnaiProxy = new WebProxy(gnaiProxy.Trim(), true);
                explicitGnaiProxy.Credentials = CredentialCache.DefaultNetworkCredentials;
                request.Proxy = explicitGnaiProxy;
                return;
            }

            request.Proxy = null;
            return;
        }
        
        // GitHub Models is external - needs proxy
        string proxyAddress = ConfigurationManager.AppSettings["GitHubModels:Proxy"];
        if (!string.IsNullOrWhiteSpace(proxyAddress))
        {
            WebProxy explicitProxy = new WebProxy(proxyAddress.Trim(), true);
            explicitProxy.Credentials = CredentialCache.DefaultNetworkCredentials;
            request.Proxy = explicitProxy;
            return;
        }

        IWebProxy systemProxy = WebRequest.GetSystemWebProxy();
        if (systemProxy != null)
        {
            systemProxy.Credentials = CredentialCache.DefaultCredentials;
            request.Proxy = systemProxy;
        }
    }

    private static string ResolveGnaiToken()
    {
        string token = FirstNonEmpty(System.Environment.GetEnvironmentVariable("GNAI_TOKEN"), System.Environment.GetEnvironmentVariable("GNAI_API_KEY"));
        if (!string.IsNullOrWhiteSpace(token))
        {
            return token;
        }

        return GetAppSetting("GNAI:ApiKey");
    }

    private static string FirstNonEmpty(params string[] values)
    {
        if (values == null) return string.Empty;
        for (int index = 0; index < values.Length; index++)
        {
            if (!string.IsNullOrWhiteSpace(values[index]))
            {
                return values[index];
            }
        }

        return string.Empty;
    }

    private static string GetAppSetting(string key)
    {
        string value = ConfigurationManager.AppSettings[key] ?? string.Empty;
        if (!string.IsNullOrWhiteSpace(value)) return value;

        try
        {
            List<string> configPaths = new List<string>();
            configPaths.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Web.config"));
            try
            {
                string mappedPath = System.Web.Hosting.HostingEnvironment.MapPath("~/Web.config");
                if (!string.IsNullOrWhiteSpace(mappedPath)) configPaths.Add(mappedPath);
            }
            catch { }

            try
            {
                if (System.Web.HttpContext.Current != null && System.Web.HttpContext.Current.Server != null)
                {
                    string serverPath = System.Web.HttpContext.Current.Server.MapPath("~/Web.config");
                    if (!string.IsNullOrWhiteSpace(serverPath)) configPaths.Add(serverPath);
                }
            }
            catch { }

            for (int index = 0; index < configPaths.Count; index++)
            {
                string configPath = configPaths[index];
                if (string.IsNullOrWhiteSpace(configPath) || !File.Exists(configPath)) continue;

                XmlDocument document = new XmlDocument();
                document.Load(configPath);
                XmlNode node = document.SelectSingleNode("/configuration/appSettings/add[@key='" + key.Replace("'", "&apos;") + "']");
                if (node != null && node.Attributes != null && node.Attributes["value"] != null)
                {
                    return node.Attributes["value"].Value ?? string.Empty;
                }
            }
        }
        catch { }

        return string.Empty;
    }

    private static string ComputeHash(string input)
    {
        if (string.IsNullOrEmpty(input))
            return string.Empty;

        using (SHA256 sha256 = SHA256.Create())
        {
            byte[] hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
            return BitConverter.ToString(hashedBytes).Replace("-", "").ToLowerInvariant();
        }
    }
}
