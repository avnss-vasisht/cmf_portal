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
    public string HsdContext { get; set; }
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

        string hsdContext = SafeText(request.HsdContext);
        string hash = ComputeHash("cmf-recommendation-live-context-v9|" + GetAiProviderCacheSignature() + "|" + cpId + "|" + title + "|" + component + "|" + cmfRequest + "|" + impact + "|" + idst + "|" + reproOnRvp + "|" + reproducibility + "|" + customerDetail + "|" + customerOwner + "|" + rules + "|" + hsdContext);
        string cacheKey = "cmf-recommendation:" + hash;

        CmfRecommendationResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached;
        }

        string modelRecommendation;
        string modelError;
        string deterministicRecommendation = BuildFallbackRecommendation(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules);
        bool hasModelRecommendation = TryGenerateWithGitHubModel(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, deterministicRecommendation, out modelRecommendation, out modelError, BuildCmfRecommendationPrompt(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, deterministicRecommendation, hsdContext));

        if (!hasModelRecommendation)
        {
            CmfRecommendationResponse fallbackResult = BuildFallbackRecommendationResponse(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, hsdContext, modelError);
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
        result.Recommendation = ResolveCmfDisposition(result.Recommendation, result.OverallQualityScore, parsedThresholdScore, result.RuleScores);
        if (string.IsNullOrWhiteSpace(result.Evidence))
        {
            result.Evidence = BuildReasoningFromScores(result.Recommendation, result.OverallQualityScore, parsedThresholdScore, result.RuleScores);
        }
        result.NextSteps = BuildNextSteps(result.Recommendation, result.RuleScores);
        result.Message = "AI recommendation generated.";

        SetCached(cacheKey, result, DateTime.UtcNow.AddMinutes(30));
        return result;
    }

    public static CmfRecommendationResponse GenerateCmfPendingDecisionDetails(CmfRecommendationRequest request)
    {
        if (request == null)
        {
            return new CmfRecommendationResponse { Success = false, Message = "Invalid CMF details request." };
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
        string hsdContext = SafeText(request.HsdContext);
        string rules = string.IsNullOrWhiteSpace(request.Rules) ? GetActiveRulesText() : SafeText(request.Rules);
        string cacheKey = "cmf-decision-details:" + ComputeHash("cmf-decision-details-live-context-v4|" + GetAiProviderCacheSignature() + "|" + cpId + "|" + title + "|" + component + "|" + cmfRequest + "|" + impact + "|" + idst + "|" + reproOnRvp + "|" + reproducibility + "|" + customerDetail + "|" + customerOwner + "|" + hsdContext);

        CmfRecommendationResponse cached = TryGetCached(cacheKey);
        if (cached != null) return cached;

        string details;
        string modelError;
        bool hasModelDetails = TryGenerateWithGitHubModel(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, string.Empty, out details, out modelError, BuildCmfDecisionDetailsPrompt(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, hsdContext), "You explain CMF pending issue details for reviewers. Be concise, grammatical, evidence-grounded, and decision-focused.");

        CmfRecommendationResponse response = new CmfRecommendationResponse
        {
            Success = true,
            CpId = cpId,
            Title = title,
            Recommendation = "CMF Decision Details",
            Evidence = hasModelDetails ? details.Trim() : BuildFallbackCmfDecisionDetails(title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, hsdContext),
            Message = hasModelDetails ? "AI CMF decision details generated." : BuildFallbackMessage(modelError)
        };

        SetCached(cacheKey, response, DateTime.UtcNow.AddMinutes(30));
        return response;
    }

    public static CmfRecommendationResponse GenerateCmfPendingImpactDetails(CmfRecommendationRequest request)
    {
        if (request == null)
        {
            return new CmfRecommendationResponse { Success = false, Message = "Invalid CMF impact request." };
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
        string hsdContext = SafeText(request.HsdContext);
        string rules = string.IsNullOrWhiteSpace(request.Rules) ? GetActiveRulesText() : SafeText(request.Rules);
        string cacheKey = "cmf-impact-details:" + ComputeHash("cmf-impact-details-live-context-v1|" + GetAiProviderCacheSignature() + "|" + cpId + "|" + title + "|" + component + "|" + cmfRequest + "|" + impact + "|" + idst + "|" + reproOnRvp + "|" + reproducibility + "|" + customerDetail + "|" + customerOwner + "|" + hsdContext);

        CmfRecommendationResponse cached = TryGetCached(cacheKey);
        if (cached != null) return cached;

        string details;
        string modelError;
        bool hasModelDetails = TryGenerateWithGitHubModel(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, string.Empty, out details, out modelError, BuildCmfImpactDetailsPrompt(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, hsdContext), "You explain the practical impact of CMF pending issues. Be concise, evidence-grounded, and business-readable.");

        CmfRecommendationResponse response = new CmfRecommendationResponse
        {
            Success = true,
            CpId = cpId,
            Title = title,
            Recommendation = "AI Impact Details",
            Evidence = hasModelDetails ? details.Trim() : BuildFallbackCmfImpactDetails(title, component, impact, reproOnRvp, reproducibility, customerDetail, hsdContext),
            Message = hasModelDetails ? "AI impact details generated." : BuildFallbackMessage(modelError)
        };

        SetCached(cacheKey, response, DateTime.UtcNow.AddMinutes(30));
        return response;
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
        out string recommendation, out string error, string promptOverride = null, string systemOverride = null)
    {
        recommendation = string.Empty;
        error = string.Empty;

        string gnaiToken = ResolveGnaiToken();
        string gnaiEndpoint = ResolveGnaiEndpoint();
        string gnaiModel = ResolveGnaiModel();
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

        string prompt = string.IsNullOrWhiteSpace(promptOverride) ? BuildCmfRecommendationPrompt(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner, rules, deterministicRecommendation, string.Empty) : promptOverride;

        try
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = int.MaxValue;

            var payload = new
            {
                model = model,
                messages = new object[]
                {
                    new { role = "system", content = string.IsNullOrWhiteSpace(systemOverride) ? "You are an AI assistant specialized in CMF pending decisions. Use the admin-defined CMF rules as policy. Recommend CMF_OK, CMF_REJECT, or CMF_INCOMPLETE with concise reasoning and missing-information guidance." : systemOverride },
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
            int timeoutMilliseconds = ResolveAiRequestTimeoutMilliseconds();
            request.Timeout = timeoutMilliseconds;
            request.ReadWriteTimeout = timeoutMilliseconds;
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
        builder.AppendLine("## " + decision);
        builder.AppendLine();
        builder.AppendLine("- Decision: " + ruleSummary);
        builder.AppendLine("- Evidence: request \"" + safeRequest + "\"; RVP \"" + SafeDisplay(reproOnRvp) + "\"; reproducibility \"" + SafeDisplay(reproducibility) + "\"; impact " + safeImpact + ".");
        if (decision == "Tag as CMF")
        {
            builder.Append("- Next: approve the tag after owner ETA is confirmed.");
        }
        else
        {
            builder.Append("- Next: collect missing rule evidence before approving the tag.");
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

    private static CmfRecommendationResponse BuildFallbackRecommendationResponse(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string rules, string hsdContext, string modelError)
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
        string evidence = BuildContextGroundedReasoning(decision, overallQualityScore, thresholdScore, ruleScores, title, component, impact, reproducibility, reproOnRvp, hsdContext);

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

    private static bool IsGatingRule(string ruleId)
    {
        return IsHighWeightRule(ruleId)
            || string.Equals(ruleId, "R3", StringComparison.OrdinalIgnoreCase);
    }

    private static bool HasBlockingRuleFailure(List<CmfRecommendationRuleScore> ruleScores)
    {
        if (ruleScores == null) return false;

        foreach (CmfRecommendationRuleScore rule in ruleScores)
        {
            if (rule == null) continue;

            string ruleId = SafeText(rule.RuleId);
            string evaluation = SafeText(rule.Evaluation);
            bool failed = evaluation.StartsWith("FAIL", StringComparison.OrdinalIgnoreCase);
            bool partial = evaluation.StartsWith("PARTIAL", StringComparison.OrdinalIgnoreCase);

            int score;
            bool hasScore = int.TryParse((rule.Score ?? string.Empty).Replace("%", string.Empty).Trim(), out score);
            if (hasScore && score <= 0)
            {
                failed = true;
            }

            if (failed)
            {
                return true;
            }

            if (partial && IsGatingRule(ruleId))
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
        if (ruleScores != null)
        {
            foreach (CmfRecommendationRuleScore rule in ruleScores)
            {
                string evaluation = rule == null ? string.Empty : SafeText(rule.Evaluation);
                string ruleId = rule == null ? string.Empty : SafeText(rule.RuleId);
                if (evaluation.StartsWith("FAIL", StringComparison.OrdinalIgnoreCase) || evaluation.StartsWith("PARTIAL", StringComparison.OrdinalIgnoreCase))
                {
                    blockers.Add(BuildRecommendationReasonClause(ruleId, evaluation, false));
                }
                else if (evaluation.StartsWith("PASS", StringComparison.OrdinalIgnoreCase))
                {
                    strengths.Add(BuildRecommendationReasonClause(ruleId, evaluation, true));
                }
            }
        }

        bool shouldTag = string.Equals(recommendation, "Tag as CMF", StringComparison.OrdinalIgnoreCase);
        StringBuilder reasoning = new StringBuilder();
        if (shouldTag)
        {
            reasoning.Append("The issue meets the CMF tagging bar because the strongest signals support both severity and actionability. ");
            reasoning.Append("The score is ").Append(overallQualityScore).Append("/100 against a ").Append(thresholdScore).Append("/100 threshold, and ");
            reasoning.Append(strengths.Count > 0 ? JoinReadableList(TakeFirstReasons(strengths, 2)) : "the active rule checks do not show a blocking gap").Append(". ");
            reasoning.Append("Based on those signals, tagging is justified while the owner continues normal validation tracking.");
        }
        else
        {
            reasoning.Append("The issue should not be tagged yet because the evidence does not clear the CMF decision gates. ");
            reasoning.Append("The score is ").Append(overallQualityScore).Append("/100 against a ").Append(thresholdScore).Append("/100 threshold, and ");
            reasoning.Append(blockers.Count > 0 ? JoinReadableList(TakeFirstReasons(blockers, 2)) : "one or more required signals are still unclear").Append(". ");
            reasoning.Append("Until those gaps are resolved, approving the CMF tag would be premature.");
        }
        return reasoning.ToString();
    }

    private static List<string> TakeFirstReasons(List<string> reasons, int maxCount)
    {
        List<string> selected = new List<string>();
        if (reasons == null) return selected;
        for (int index = 0; index < reasons.Count && selected.Count < maxCount; index++)
        {
            if (!string.IsNullOrWhiteSpace(reasons[index])) selected.Add(reasons[index]);
        }
        return selected;
    }

    private static string BuildRecommendationReasonClause(string ruleId, string evaluation, bool isPass)
    {
        string detail = ExtractRuleDetail(evaluation);
        if (string.Equals(ruleId, "R1", StringComparison.OrdinalIgnoreCase))
        {
            return isPass ? "reproduction or RVP evidence makes the issue credible" : "reproduction or RVP evidence is not strong enough yet";
        }
        if (string.Equals(ruleId, "R2", StringComparison.OrdinalIgnoreCase))
        {
            return isPass ? "the customer or user impact is severe enough for CMF attention" : "the impact does not clearly show a CMF-level customer or user consequence";
        }
        if (string.Equals(ruleId, "R3", StringComparison.OrdinalIgnoreCase))
        {
            return isPass ? "the request state shows clear CMF intent" : "the CMF request intent still needs confirmation";
        }
        if (string.Equals(ruleId, "R4", StringComparison.OrdinalIgnoreCase))
        {
            return isPass ? "the issue has enough component and impact context for review" : "the issue context is incomplete for a confident decision";
        }
        if (string.Equals(ruleId, "R5", StringComparison.OrdinalIgnoreCase))
        {
            return isPass ? "there is no obvious low-signal wording blocking the tag" : "the wording suggests the issue may be low signal or low impact";
        }
        return isPass ? "the available evidence supports the active rules" : (string.IsNullOrWhiteSpace(detail) ? "a required rule signal is incomplete" : detail.Trim(' ', '(', ')'));
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
        bool shouldTag = string.Equals(recommendation, "CMF_OK", StringComparison.OrdinalIgnoreCase)
            || string.Equals(recommendation, "Tag as CMF", StringComparison.OrdinalIgnoreCase);
        List<string> steps = new List<string>();

        if (shouldTag)
        {
            steps.Add("Approve CMF only after the rule evidence and HSD details stay consistent with the current data.");
            steps.Add("Capture the customer/launch impact and validation proof in the CMF notes.");
            steps.Add("Link similar sightings if the same component or failure mode is repeated.");
        }
        else
        {
            steps.Add("Hold CMF approval until the missing rule evidence is updated.");
            steps.Add("Add clear repro proof, customer/launch impact, or recovery status before re-running the assessment.");
            steps.Add("Reject only when the issue remains low-impact or unsupported after review.");
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
            normalized = TrimToCleanSentence(normalized, maxLength);
        }

        return normalized;
    }

    private static string TrimToCleanSentence(string text, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string cleaned = text.Replace("\r", " ").Replace("\n", " ").Trim();
        while (cleaned.IndexOf("  ", StringComparison.Ordinal) >= 0)
        {
            cleaned = cleaned.Replace("  ", " ");
        }

        if (cleaned.Length <= maxLength) return cleaned.TrimEnd('.', ';', ':');
        string clipped = cleaned.Substring(0, Math.Max(1, maxLength)).Trim();
        int boundary = Math.Max(clipped.LastIndexOf('.'), Math.Max(clipped.LastIndexOf('!'), clipped.LastIndexOf('?')));
        if (boundary >= 50) return clipped.Substring(0, boundary + 1).Trim();
        return System.Text.RegularExpressions.Regex.Replace(clipped, @"\s+\S*$", string.Empty).TrimEnd(',', ';', ':', '-', ' ') + ".";
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
            response.Recommendation = rawResponse.Length > 200 ? TrimToCleanSentence(rawResponse, 200) : rawResponse;
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

    private static string BuildCmfRecommendationPrompt(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string rules, string deterministicRecommendation, string hsdContext)
    {
        StringBuilder prompt = new StringBuilder();
        prompt.AppendLine("Analyze this CMF pending issue from a Customer Must Fix reviewer point of view.");
        prompt.AppendLine("Goal: provide a strong, meaningful, user-understandable recommendation using BOTH the admin-defined backend rules and your understanding of the issue context collected so far.");
        prompt.AppendLine("The admin rules are policy gates, not decoration. Apply them first, then use AI judgment to interpret the HSD/row details, contradictions, missing evidence, duplicate/similar issue risk, recovery status, replication strength, and customer or launch-gating consequence.");
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
        prompt.AppendLine("Debug/Evidence Reference: " + (string.IsNullOrWhiteSpace(idst) ? "N/A" : idst));
        prompt.AppendLine("RVP Repro: " + (string.IsNullOrWhiteSpace(reproOnRvp) ? "N/A" : reproOnRvp));
        prompt.AppendLine("Reproducibility: " + (string.IsNullOrWhiteSpace(reproducibility) ? "N/A" : reproducibility));
        prompt.AppendLine("Customer Detail: " + (string.IsNullOrWhiteSpace(customerDetail) ? "N/A" : customerDetail));
        prompt.AppendLine("Customer Owner: " + (string.IsNullOrWhiteSpace(customerOwner) ? "N/A" : customerOwner));
        if (!string.IsNullOrWhiteSpace(hsdContext))
        {
            prompt.AppendLine();
            prompt.AppendLine("HSD context:");
            prompt.AppendLine(hsdContext);
        }
        prompt.AppendLine();
        prompt.AppendLine("Provide your response in this exact format:");
        prompt.AppendLine("Use threshold_for_cmf_tag from the rules as the minimum overall quality score for tagging. Treat high-weight rules as blocking gates: if a high-weight rule fails, recommend Do not tag as CMF even when the rollup score is near the threshold. The overall quality score should be weighted by rule weight, not a plain average.");
        prompt.AppendLine();
        prompt.AppendLine("RECOMMENDATION: [One line only: exactly \"CMF_OK\", \"CMF_REJECT\", or \"CMF_INCOMPLETE\"]");
        prompt.AppendLine();
        prompt.AppendLine("OVERALL QUALITY SCORE: [0-100 integer rollup based on the rule scores]");
        prompt.AppendLine();
        prompt.AppendLine("AI REASONING:");
        prompt.AppendLine("[4-5 crisp, polished, issue-specific sentences. Start with the actual situation, then explain how the admin rules and HSD/row evidence support or block the recommendation. Mention the strongest evidence, the most important missing/incomplete detail, and the practical review risk. Avoid generic wording such as 'evidence is insufficient' unless you name what evidence is missing and why it matters.]");
        prompt.AppendLine();
        prompt.AppendLine("RULE SCORES:");
        prompt.AppendLine("For each rule defined above, provide:");
        prompt.AppendLine("Rule ID | Rule Name | Score | Evaluation");
        prompt.AppendLine("[Example: R1 | Minimum replication evidence | 100 | PASS - Reproducibility is documented]");
        prompt.AppendLine("[Example: R2 | User impact severity | 0 | FAIL - Impact level is not critical]");
        prompt.AppendLine();
        prompt.AppendLine("Use numeric scores only in the Score column: 100 for PASS, 50-70 for PARTIAL, and 0 for FAIL. Put PASS, FAIL, or PARTIAL at the start of the Evaluation text. If evidence is missing but the issue may be CMF-worthy, use CMF_INCOMPLETE rather than CMF_REJECT. Keep reasoning understandable for a reviewer who already knows the portal fields; do not explain field names.");

        return prompt.ToString();
    }

    private static string BuildCmfDecisionDetailsPrompt(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string hsdContext)
    {
        StringBuilder prompt = new StringBuilder();
        prompt.AppendLine("Provide CMF decision details for a reviewer. This is not a final recommendation; it is the issue brief used before the CMF decision.");
        prompt.AppendLine("Write brief, crisp, user-facing content. Do not mention owner names, owner fields, iDST labels, or portal-internal field names. Highlight HSD information quality, missing fields, recovery/workaround signal, replication strength, duplicate/similar-issue clues, qualification gaps, and customer/launch-gating relevance when supported by data.");
        prompt.AppendLine("Use exactly these sections. Keep each section to one short paragraph or two short bullets:");
        prompt.AppendLine("## Context");
        prompt.AppendLine("## HSD Information Quality");
        prompt.AppendLine("Quality Score: [0-100 integer]");
        prompt.AppendLine("Missing/Incomplete Details: [short phrase list, or None found]");
        prompt.AppendLine("Key Strengths: [short phrase list, or Limited strengths]");
        prompt.AppendLine("## Evidence Signals");
        prompt.AppendLine("## Reviewer Attention");
        prompt.AppendLine();
        prompt.AppendLine("Row data:");
        prompt.AppendLine("CP ID: " + SafeDisplay(cpId));
        prompt.AppendLine("Title: " + SafeDisplay(title));
        prompt.AppendLine("Component: " + SafeDisplay(component));
        prompt.AppendLine("CMF Request: " + SafeDisplay(cmfRequest));
        prompt.AppendLine("Impact: " + SafeDisplay(impact));
        prompt.AppendLine("Debug/Evidence Reference: " + SafeDisplay(idst));
        prompt.AppendLine("RVP Repro: " + SafeDisplay(reproOnRvp));
        prompt.AppendLine("Reproducibility: " + SafeDisplay(reproducibility));
        prompt.AppendLine("Customer Detail: " + SafeDisplay(customerDetail));
        if (!string.IsNullOrWhiteSpace(hsdContext))
        {
            prompt.AppendLine();
            prompt.AppendLine("HSD context:");
            prompt.AppendLine(hsdContext);
        }
        return prompt.ToString();
    }

    private static string BuildCmfImpactDetailsPrompt(string cpId, string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string hsdContext)
    {
        StringBuilder prompt = new StringBuilder();
        prompt.AppendLine("Give an AI perspective on the impact of this CMF pending issue. Focus only on what the impact means for validation, customer readiness, schedule, or release risk.");
        prompt.AppendLine("Return 3-4 short bullet sentences. Do not make a CMF tag/no-tag recommendation. Do not invent facts. If impact data is weak, say what is missing.");
        prompt.AppendLine();
        prompt.AppendLine("Row data:");
        prompt.AppendLine("CP ID: " + SafeDisplay(cpId));
        prompt.AppendLine("Title: " + SafeDisplay(title));
        prompt.AppendLine("Component: " + SafeDisplay(component));
        prompt.AppendLine("CMF Request: " + SafeDisplay(cmfRequest));
        prompt.AppendLine("Impact: " + SafeDisplay(impact));
        prompt.AppendLine("Debug/Evidence Reference: " + SafeDisplay(idst));
        prompt.AppendLine("RVP Repro: " + SafeDisplay(reproOnRvp));
        prompt.AppendLine("Reproducibility: " + SafeDisplay(reproducibility));
        prompt.AppendLine("Customer Detail: " + SafeDisplay(customerDetail));
        if (!string.IsNullOrWhiteSpace(hsdContext))
        {
            prompt.AppendLine();
            prompt.AppendLine("HSD context:");
            prompt.AppendLine(hsdContext);
        }
        return prompt.ToString();
    }

    private static string BuildFallbackCmfDecisionDetails(string title, string component, string cmfRequest, string impact, string idst, string reproOnRvp, string reproducibility, string customerDetail, string customerOwner, string hsdContext)
    {
        string contextSignal = ExtractContextSignal(hsdContext, "Description", "Impact", "Customer Impact", "Sysdebug Forum", "Fix Description", "Closed Reason");
        string activitySignal = ExtractLatestInvestigationSignal(hsdContext);
        StringBuilder builder = new StringBuilder();
        builder.AppendLine("## Context");
        builder.AppendLine("- " + SafeDisplay(title) + " is pending CMF review for " + SafeDisplay(component) + ".");
        builder.AppendLine("- " + (string.IsNullOrWhiteSpace(contextSignal) ? "Customer signal: " + SafeDisplay(customerDetail) : contextSignal) + ".");
        builder.AppendLine();
        builder.AppendLine("## HSD Information Quality");
        builder.AppendLine("Quality Score: " + EstimateHsdQualityScore(title, component, impact, reproOnRvp, reproducibility, customerDetail).ToString(System.Globalization.CultureInfo.InvariantCulture));
        builder.AppendLine("Missing/Incomplete Details: " + BuildMissingCmfDetails(impact, idst, reproOnRvp, reproducibility, hsdContext) + ".");
        builder.AppendLine("Key Strengths: " + BuildFallbackQualityStrengths(impact, reproOnRvp, reproducibility, customerDetail) + ".");
        builder.AppendLine();
        builder.AppendLine("## Evidence Signals");
        builder.AppendLine("- Repro signal: " + SafeDisplay(reproOnRvp) + "; replication detail: " + SafeDisplay(reproducibility) + ".");
        if (!string.IsNullOrWhiteSpace(activitySignal)) builder.AppendLine("- Latest HSD signal: " + activitySignal + ".");
        builder.AppendLine();
        builder.AppendLine("## Reviewer Attention");
        builder.Append("- Confirm customer blocking status, similar CMFs, and whether the supplied evidence justifies " + SafeDisplay(cmfRequest) + ".");
        return builder.ToString();
    }

    private static string BuildFallbackCmfImpactDetails(string title, string component, string impact, string reproOnRvp, string reproducibility, string customerDetail, string hsdContext)
    {
        string contextSignal = ExtractContextSignal(hsdContext, "Customer Impact", "Impact", "Description", "Sysdebug Forum", "Fix Description");
        StringBuilder builder = new StringBuilder();
        builder.AppendLine("- " + SafeDisplay(title) + " can affect " + SafeDisplay(component) + " readiness because the stated impact is: " + SafeDisplay(impact) + ".");
        builder.AppendLine("- Customer scope is " + SafeDisplay(customerDetail) + ", so validate whether this blocks customer usage, launch criteria, or qualification sign-off.");
        builder.AppendLine("- Repro signal is " + SafeDisplay(reproducibility) + " and RVP repro is " + SafeDisplay(reproOnRvp) + ", which determines how confidently the impact can be acted on.");
        builder.Append("- " + (string.IsNullOrWhiteSpace(contextSignal) ? "Impact details are limited; add customer-visible symptom, affected flow, and workaround/recovery status." : "HSD signal: " + contextSignal + "."));
        return builder.ToString();
    }

    private static string BuildContextGroundedReasoning(string recommendation, int overallQualityScore, int thresholdScore, List<CmfRecommendationRuleScore> ruleScores, string title, string component, string impact, string reproducibility, string reproOnRvp, string hsdContext)
    {
        string baseReasoning = BuildReasoningFromScores(recommendation, overallQualityScore, thresholdScore, ruleScores);
        string contextSignal = ExtractContextSignal(hsdContext, "Fix Description", "Closed Reason", "Customer Impact", "Impact", "Description", "Sysdebug Forum");
        string activitySignal = ExtractLatestInvestigationSignal(hsdContext);
        StringBuilder builder = new StringBuilder();
        builder.Append(SafeDisplay(title)).Append(" is under CMF review for ").Append(SafeDisplay(component)).Append(" with impact signal: ").Append(SafeDisplay(impact)).Append(". ");
        if (!string.IsNullOrWhiteSpace(contextSignal)) builder.Append(contextSignal).Append(". ");
        if (!string.IsNullOrWhiteSpace(activitySignal)) builder.Append("Latest HSD signal: ").Append(activitySignal).Append(". ");
        builder.Append("Repro signal is ").Append(SafeDisplay(reproducibility)).Append(" and RVP repro is ").Append(SafeDisplay(reproOnRvp)).Append(". ");
        builder.Append(baseReasoning);
        return builder.ToString();
    }

    private static string ExtractContextSignal(string context, params string[] labels)
    {
        if (string.IsNullOrWhiteSpace(context) || labels == null) return string.Empty;
        string[] lines = context.Replace("\r", string.Empty).Split('\n');
        foreach (string label in labels)
        {
            foreach (string rawLine in lines)
            {
                string line = rawLine == null ? string.Empty : rawLine.Trim();
                if (line.StartsWith(label + ":", StringComparison.OrdinalIgnoreCase))
                {
                    string value = line.Substring(label.Length + 1).Trim();
                    if (!string.IsNullOrWhiteSpace(value) && !value.Equals("N/A", StringComparison.OrdinalIgnoreCase))
                    {
                        return BuildImpactSnippet(value).TrimEnd('.');
                    }
                }
            }
        }
        return string.Empty;
    }

    private static string ExtractLatestInvestigationSignal(string context)
    {
        if (string.IsNullOrWhiteSpace(context)) return string.Empty;
        string[] lines = context.Replace("\r", string.Empty).Split('\n');
        for (int index = lines.Length - 1; index >= 0; index--)
        {
            string line = lines[index] == null ? string.Empty : lines[index].Trim();
            if (line.Length < 24 || line.StartsWith("++++", StringComparison.Ordinal)) continue;
            if (line.IndexOf("update", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("fix", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("validate", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("repro", StringComparison.OrdinalIgnoreCase) >= 0
                || line.IndexOf("root cause", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return BuildImpactSnippet(line).TrimEnd('.');
            }
        }
        return string.Empty;
    }

    private static string BuildMissingCmfDetails(string impact, string idst, string reproOnRvp, string reproducibility, string hsdContext)
    {
        List<string> missing = new List<string>();
        if (string.IsNullOrWhiteSpace(impact)) missing.Add("customer impact");
        if (string.IsNullOrWhiteSpace(idst)) missing.Add("iDST/debug reference");
        if (string.IsNullOrWhiteSpace(reproOnRvp) && string.IsNullOrWhiteSpace(reproducibility)) missing.Add("repro evidence");
        if (string.IsNullOrWhiteSpace(ExtractContextSignal(hsdContext, "Fix Description", "Closed Reason"))) missing.Add("recovery or closure evidence");
        return missing.Count == 0 ? "None found from the available context" : JoinReadableList(missing);
    }

    private static int EstimateHsdQualityScore(string title, string component, string impact, string reproOnRvp, string reproducibility, string customerDetail)
    {
        int score = 25;
        if (!string.IsNullOrWhiteSpace(title)) score += 10;
        if (!string.IsNullOrWhiteSpace(component)) score += 10;
        if (!string.IsNullOrWhiteSpace(impact)) score += 20;
        if (!string.IsNullOrWhiteSpace(reproOnRvp)) score += 15;
        if (!string.IsNullOrWhiteSpace(reproducibility)) score += 10;
        if (!string.IsNullOrWhiteSpace(customerDetail)) score += 10;
        return Math.Min(100, score);
    }

    private static string BuildFallbackQualityStrengths(string impact, string reproOnRvp, string reproducibility, string customerDetail)
    {
        List<string> strengths = new List<string>();
        if (!string.IsNullOrWhiteSpace(impact)) strengths.Add("impact is described");
        if (!string.IsNullOrWhiteSpace(reproOnRvp) || !string.IsNullOrWhiteSpace(reproducibility)) strengths.Add("repro signal is present");
        if (!string.IsNullOrWhiteSpace(customerDetail)) strengths.Add("customer context is present");
        return strengths.Count == 0 ? "limited strengths" : JoinReadableList(strengths);
    }

    private static string ResolveCmfDisposition(string modelRecommendation, int overallQualityScore, int thresholdScore, List<CmfRecommendationRuleScore> ruleScores)
    {
        string normalized = SafeText(modelRecommendation).ToUpperInvariant();
        if (overallQualityScore >= thresholdScore && !HasBlockingRuleFailure(ruleScores)) return "CMF_OK";
        if (normalized.Contains("CMF_REJECT") && !HasAnyPartialRule(ruleScores) && overallQualityScore <= 0) return "CMF_REJECT";
        if (normalized.Contains("CMF_INCOMPLETE") || HasAnyPartialRule(ruleScores) || overallQualityScore > 0) return "CMF_INCOMPLETE";
        if (normalized.Contains("CMF_OK")) return "CMF_INCOMPLETE";
        return "CMF_REJECT";
    }

    private static string ResolveCmfDisposition(int overallQualityScore, int thresholdScore, List<CmfRecommendationRuleScore> ruleScores)
    {
        if (overallQualityScore >= thresholdScore && !HasBlockingRuleFailure(ruleScores)) return "CMF_OK";
        if (HasAnyPartialRule(ruleScores) || overallQualityScore > 0) return "CMF_INCOMPLETE";
        return "CMF_REJECT";
    }

    private static bool HasAnyPartialRule(List<CmfRecommendationRuleScore> ruleScores)
    {
        if (ruleScores == null) return false;
        foreach (CmfRecommendationRuleScore rule in ruleScores)
        {
            if (rule != null && SafeText(rule.Evaluation).StartsWith("PARTIAL", StringComparison.OrdinalIgnoreCase)) return true;
        }
        return false;
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
        string gnaiEndpoint = ResolveGnaiEndpoint();
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
        string token = GetAppSetting("GNAI:ApiKey");
        if (!string.IsNullOrWhiteSpace(token))
        {
            return token;
        }

        return FirstNonEmpty(System.Environment.GetEnvironmentVariable("GNAI_TOKEN"), System.Environment.GetEnvironmentVariable("GNAI_API_KEY"));
    }

    private static string ResolveGnaiEndpoint()
    {
        return FirstNonEmpty(GetAppSetting("GNAI:Endpoint"), System.Environment.GetEnvironmentVariable("GNAI_ENDPOINT"));
    }

    private static string ResolveGnaiModel()
    {
        return FirstNonEmpty(GetAppSetting("GNAI:Model"), System.Environment.GetEnvironmentVariable("GNAI_MODEL"));
    }

    private static int ResolveAiRequestTimeoutMilliseconds()
    {
        string configured = FirstNonEmpty(GetAppSetting("AI:RequestTimeoutSeconds"), System.Environment.GetEnvironmentVariable("AI_REQUEST_TIMEOUT_SECONDS"));
        int seconds;
        if (int.TryParse(configured, out seconds))
        {
            return Math.Max(15, Math.Min(120, seconds)) * 1000;
        }

        return 60000;
    }

    private static string GetAiProviderCacheSignature()
    {
        string gnaiToken = ResolveGnaiToken();
        string gnaiEndpoint = ResolveGnaiEndpoint();
        string gnaiModel = ResolveGnaiModel();
        bool useGnai = !string.IsNullOrWhiteSpace(gnaiToken)
            && !string.IsNullOrWhiteSpace(gnaiEndpoint)
            && !gnaiEndpoint.StartsWith("REPLACE");

        if (useGnai)
        {
            return "GNAI|" + gnaiEndpoint + "|" + FirstNonEmpty(gnaiModel, "gpt-5-mini") + "|" + ComputeHash(gnaiToken).Substring(0, 12);
        }

        string githubEndpoint = FirstNonEmpty(GetAppSetting("GitHubModels:Endpoint"), "https://models.inference.ai.azure.com/chat/completions");
        string githubModel = FirstNonEmpty(GetAppSetting("GitHubModels:Model"), "gpt-4o-mini");
        string githubKey = GetAppSetting("GitHubModels:ApiKey");
        return "GitHubModels|" + githubEndpoint + "|" + githubModel + "|" + ComputeHash(githubKey).Substring(0, 12);
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
