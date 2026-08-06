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

public class AiSummaryRequest
{
    public string IssueId { get; set; }
    public string Title { get; set; }
    public string SubmittedDate { get; set; }
    public string Status { get; set; }
    public string Sysdebug { get; set; }
    public string ContextDetails { get; set; }
}

public class AiSummaryResponse
{
    public bool Success { get; set; }
    public string IssueId { get; set; }
    public string Title { get; set; }
    public string SubmittedDate { get; set; }
    public string Summary { get; set; }
    public string Message { get; set; }
    public bool UsedFallback { get; set; }
}

public static class AiSummaryService
{
    private static readonly object CacheSync = new object();
    private static readonly Dictionary<string, AiSummaryCacheEntry> Cache = new Dictionary<string, AiSummaryCacheEntry>(StringComparer.Ordinal);

    public static AiSummaryResponse GenerateIssueSummary(AiSummaryRequest request)
    {
        if (request == null)
        {
            return new AiSummaryResponse
            {
                Success = false,
                Message = "Invalid summary request."
            };
        }

        string issueId = SafeText(request.IssueId);
        string title = SafeText(request.Title);
        string submittedDate = SafeText(request.SubmittedDate);
        string status = SafeText(request.Status);
        string sysdebug = SafeText(request.Sysdebug);
        string contextDetails = SafeText(request.ContextDetails);

        string hash = ComputeHash("summary-compact-template-v1|" + issueId + "|" + title + "|" + submittedDate + "|" + status + "|" + sysdebug + "|" + contextDetails);
        string cacheKey = "ai-summary:" + hash;

        AiSummaryResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached;
        }

        string modelSummary;
        string modelError;
        bool hasModelSummary = TryGenerateWithGitHubModel(issueId, submittedDate, title, status, sysdebug, contextDetails, out modelSummary, out modelError);

        if (!hasModelSummary)
        {
            string fallbackSummary = CleanupSummarySpacing(BuildFallbackSummary(issueId, submittedDate, title, status, sysdebug, contextDetails), 140);
            return new AiSummaryResponse
            {
                Success = true,
                IssueId = issueId,
                Title = title,
                SubmittedDate = submittedDate,
                Summary = fallbackSummary,
                Message = BuildFallbackMessage(modelError),
                UsedFallback = true
            };
        }

        // Post-process the model output to clean up spacing and ensure word limit
        string concise = CleanupSummarySpacing(modelSummary, 140);

        AiSummaryResponse result = new AiSummaryResponse
        {
            Success = true,
            IssueId = issueId,
            Title = title,
            SubmittedDate = submittedDate,
            Summary = concise,
            Message = "AI summary generated.",
            UsedFallback = false
        };

        SetCached(cacheKey, result, DateTime.UtcNow.AddMinutes(30));
        return result;
    }

    public static string GenerateOneLineStatus(AiSummaryRequest request)
    {
        if (request == null)
        {
            return string.Empty;
        }

        string issueId = SafeText(request.IssueId);
        string title = SafeText(request.Title);
        string status = SafeText(request.Status);
        string sysdebug = SafeText(request.Sysdebug);
        string contextDetails = SafeText(request.ContextDetails);

        string hash = ComputeHash("one-line-status-v1|" + issueId + "|" + title + "|" + status + "|" + sysdebug + "|" + contextDetails);
        string cacheKey = "ai-one-line-status:" + hash;

        AiSummaryResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached.Summary;
        }

        string modelStatus;
        string modelError;
        bool hasModelStatus = TryGenerateWithGitHubModel(
            issueId,
            string.Empty,
            title,
            status,
            sysdebug,
            contextDetails,
            out modelStatus,
            out modelError,
            BuildOneLineStatusPrompt(title, status, sysdebug, contextDetails),
            "You write one-sentence status updates for issue-list table cells. Use the latest HSD ticket details and comments. Output one professional sentence only, no markdown, no bullets, no labels.");

        string result = hasModelStatus
            ? CleanupOneLineStatus(modelStatus)
            : BuildDeterministicOneLineStatus(status, sysdebug, contextDetails);

        SetCached(cacheKey, new AiSummaryResponse { Success = true, Summary = result }, DateTime.UtcNow.AddMinutes(30));
        return result;
    }

    private static string CleanupSummarySpacing(string text, int maxWords)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;

        // Remove excessive blank lines and normalize spacing
        text = System.Text.RegularExpressions.Regex.Replace(text, @"\n\s*\n\s*\n+", "\n\n");
        text = System.Text.RegularExpressions.Regex.Replace(text, @"[ \t]+", " ");
        text = text.Trim();

        string[] lines = text.Replace("\r", string.Empty).Split('\n');
        StringBuilder limited = new StringBuilder();
        int wordCount = 0;

        HashSet<string> seenMeaningfulLines = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (string rawLine in lines)
        {
            string line = rawLine == null ? string.Empty : rawLine.Trim();
            if (line.Length == 0)
            {
                if (limited.Length > 0) limited.AppendLine();
                continue;
            }

            string[] words = line.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) continue;

            bool isHeader = line.StartsWith("**", StringComparison.Ordinal) && line.EndsWith("**", StringComparison.Ordinal);
            string dedupeKey = NormalizeSummaryLineForDedupe(line);
            if (!isHeader && dedupeKey.Length > 0)
            {
                if (seenMeaningfulLines.Contains(dedupeKey)) continue;
                seenMeaningfulLines.Add(dedupeKey);
            }

            int remaining = maxWords - wordCount;
            if (!isHeader && remaining <= 0) break;

            if (!isHeader && words.Length > remaining)
            {
                line = TrimToSentenceBoundary(string.Join(" ", words, 0, Math.Max(1, remaining)));
                wordCount = maxWords;
            }
            else if (!isHeader)
            {
                wordCount += words.Length;
            }

            limited.AppendLine(line);
        }

        return limited.ToString().Trim();
    }

    private static string NormalizeSummaryLineForDedupe(string line)
    {
        if (string.IsNullOrWhiteSpace(line)) return string.Empty;
        string normalized = System.Text.RegularExpressions.Regex.Replace(line, @"^[\-\*\d\.\)\s]+", string.Empty).Trim();
        normalized = System.Text.RegularExpressions.Regex.Replace(normalized, @"\s+", " ");
        return normalized.Trim('.', ',', ';', ':').ToLowerInvariant();
    }

    private static string TrimToSentenceBoundary(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string trimmed = text.Trim();
        int boundary = Math.Max(trimmed.LastIndexOf('.'), Math.Max(trimmed.LastIndexOf('!'), trimmed.LastIndexOf('?')));
        if (boundary >= 40)
        {
            return trimmed.Substring(0, boundary + 1);
        }

        return trimmed.TrimEnd('.', ',', ';', ':');
    }

    private static string MakeConciseBusinessSummary(string text, int maxWords)
    {
        // Deprecated - kept for fallback compatibility
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;

        // Split into sentences by punctuation.
        var sentences = System.Text.RegularExpressions.Regex.Split(text.Trim(), "(?<=[.!?])\\s+");
        var selected = new List<string>();
        int wordCount = 0;

        foreach (var s in sentences)
        {
            var trimmed = s.Trim();
            if (string.IsNullOrWhiteSpace(trimmed)) continue;
            selected.Add(trimmed);
            wordCount += trimmed.Split(new[] { ' ', '\t', '\n' }, StringSplitOptions.RemoveEmptyEntries).Length;
            if (selected.Count >= 4 || wordCount >= maxWords) break;
        }

        string paragraph = string.Join(" ", selected).Replace("\r", " ").Replace("\n", " ").Trim();
        // Ensure <= maxWords by truncating words if necessary
        var words = paragraph.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
        if (words.Length <= maxWords) return paragraph;

        return string.Join(" ", words, 0, maxWords) + "...";
    }

    private static AiSummaryResponse TryGetCached(string cacheKey)
    {
        lock (CacheSync)
        {
            AiSummaryCacheEntry entry;
            if (!Cache.TryGetValue(cacheKey, out entry))
            {
                return null;
            }

            if (entry.ExpiresAtUtc <= DateTime.UtcNow)
            {
                Cache.Remove(cacheKey);
                return null;
            }

            return entry.Value;
        }
    }

    private static void SetCached(string cacheKey, AiSummaryResponse value, DateTime expiresAtUtc)
    {
        lock (CacheSync)
        {
            Cache[cacheKey] = new AiSummaryCacheEntry
            {
                ExpiresAtUtc = expiresAtUtc,
                Value = value
            };
        }
    }

    private static bool TryGenerateWithGitHubModel(
        string issueId,
        string submittedDate,
        string title,
        string status,
        string sysdebug,
        string contextDetails,
        out string summary,
        out string error,
        string promptOverride = null,
        string systemOverride = null)
    {
        summary = string.Empty;
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

        string prompt = string.IsNullOrWhiteSpace(promptOverride) ? BuildPrompt(issueId, submittedDate, title, status, sysdebug, contextDetails) : promptOverride;

        try
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = int.MaxValue;

            var payload = new
            {
                model = model,
                messages = new object[]
                {
                    new { role = "system", content = string.IsNullOrWhiteSpace(systemOverride) ? "You are a senior CMF issue summarizer for Program Managers and engineering users. Be brief, evidence-grounded, and template-faithful. Do not invent anything not present in the data." : systemOverride },
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
            request.UserAgent = "CMF-Portal-AI-Summary/1.0";
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
            summary = ExtractContentFromResponse(raw);
            if (string.IsNullOrWhiteSpace(summary))
            {
                error = "Model response was empty.";
                return false;
            }

            summary = summary.Trim();
            return true;
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
        if (!string.IsNullOrWhiteSpace(value))
        {
            return value;
        }

        try
        {
            List<string> configPaths = new List<string>();
            configPaths.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Web.config"));

            try
            {
                string mappedPath = System.Web.Hosting.HostingEnvironment.MapPath("~/Web.config");
                if (!string.IsNullOrWhiteSpace(mappedPath))
                {
                    configPaths.Add(mappedPath);
                }
            }
            catch
            {
            }

            try
            {
                if (System.Web.HttpContext.Current != null && System.Web.HttpContext.Current.Server != null)
                {
                    string serverPath = System.Web.HttpContext.Current.Server.MapPath("~/Web.config");
                    if (!string.IsNullOrWhiteSpace(serverPath))
                    {
                        configPaths.Add(serverPath);
                    }
                }
            }
            catch
            {
            }

            for (int index = 0; index < configPaths.Count; index++)
            {
                string configPath = configPaths[index];
                if (string.IsNullOrWhiteSpace(configPath) || !File.Exists(configPath))
                {
                    continue;
                }

                XmlDocument document = new XmlDocument();
                document.Load(configPath);
                XmlNode node = document.SelectSingleNode("/configuration/appSettings/add[@key='" + key.Replace("'", "&apos;") + "']");
                if (node != null && node.Attributes != null && node.Attributes["value"] != null)
                {
                    return node.Attributes["value"].Value ?? string.Empty;
                }
            }

            return string.Empty;
        }
        catch
        {
            return string.Empty;
        }
    }

    private static string BuildPrompt(string issueId, string submittedDate, string title, string status, string sysdebug, string contextDetails)
    {
        Dictionary<string, string> contextMap = ParseContextDetails(contextDetails);
        int confidence = CalculateSummaryConfidence(status, sysdebug, contextDetails);
        string impact = BuildDisplayValue(FirstContextValue(contextMap, "Customer Impact", "Promoted Issue Customer Impact", "Impact", "Promoted Issue Impact"));
        string reproducibility = BuildDisplayValue(FirstContextValue(contextMap, "Reproducibility"));
        string logsAvailable = HasPresentValue(sysdebug) || HasPresentValue(FirstContextValue(contextMap, "Sysdebug", "Sysdebug Forum")) ? "Yes" : "No";
        string rvpDebugAvailable = BuildYesNoValue(FirstContextValue(contextMap, "RVP Platform Debug Details", "RVP Debug", "Repro On RVP"));

        StringBuilder builder = new StringBuilder();
        builder.AppendLine("Review all ticket information and write for a busy engineering/program user who will scan this in seconds.");
        builder.AppendLine();
        builder.AppendLine("CRITICAL REQUIREMENTS:");
        builder.AppendLine("- Use EXACTLY the output template below and keep labels unchanged.");
        builder.AppendLine("- Summary must contain exactly 3 numbered points: 1), 2), 3).");
        builder.AppendLine("- Each numbered point must be one short line, ideally 10-16 words.");
        builder.AppendLine("- Follow up must be exactly one bullet and one short line.");
        builder.AppendLine("- Keep the full answer under 110 words, excluding fixed labels.");
        builder.AppendLine("- Prefer latest HSD comments, owner/debug updates, closure/fix evidence, impact, reproducibility, and CMF status.");
        builder.AppendLine("- Do not repeat the title; compress it into the actual issue meaning.");
        builder.AppendLine("- Do not mention vendor investigation, escalation, reopening, or log collection unless explicitly present in the issue data.");
        builder.AppendLine("Do not invent details not present in the data below.");
        builder.AppendLine();
        builder.AppendLine("Output template:");
        builder.AppendLine("**AI summary (Confidence: " + confidence.ToString() + "%)**");
        builder.AppendLine();
        builder.AppendLine("Sighting ID: " + BuildDisplayValue(issueId) + "  CMF Ask date: " + BuildDisplayValue(submittedDate));
        builder.AppendLine();
        builder.AppendLine("Impact: " + impact);
        builder.AppendLine("Reproducibility: " + reproducibility);
        builder.AppendLine("Logs(sysdebug/debug details): " + logsAvailable);
        builder.AppendLine("RVP platform debug details: " + rvpDebugAvailable);
        builder.AppendLine();
        builder.AppendLine("**Summary:**");
        builder.AppendLine("1) [main issue in one concise line]");
        builder.AppendLine("2) [latest investigation/action/status in one concise line]");
        builder.AppendLine("3) [current outcome or risk in one concise line]");
        builder.AppendLine();
        builder.AppendLine("**Follow up**");
        builder.AppendLine("- [one brief next action, or no further action if resolved]");
        builder.AppendLine();
        builder.AppendLine("Ticket data:");
        builder.AppendLine("Status: " + status);
        builder.AppendLine("Sysdebug: " + sysdebug);
        if (!string.IsNullOrWhiteSpace(contextDetails))
        {
            builder.AppendLine();
            builder.AppendLine("Full Context:");
            builder.AppendLine(contextDetails);
        }
        return builder.ToString();
    }

    private static string BuildOneLineStatusPrompt(string title, string status, string sysdebug, string contextDetails)
    {
        StringBuilder builder = new StringBuilder();
        builder.AppendLine("Read the HSD ticket details, promoted details, comments, investigation notes, ownership, and status updates.");
        builder.AppendLine("Write exactly one concise sentence for a table cell that tells the most recent current status of this issue.");
        builder.AppendLine("Focus on what is happening now: latest update, owner/action, investigation state, fix/closure state, or blocking information.");
        builder.AppendLine("Do not use markdown, bullets, labels, quotes, or mention commenter names unless critical.");
        builder.AppendLine("Keep it under 22 words so it fits inside a narrow status column.");
        builder.AppendLine();
        builder.AppendLine("Issue title: " + title);
        builder.AppendLine("Status: " + status);
        builder.AppendLine("Sysdebug: " + sysdebug);
        if (!string.IsNullOrWhiteSpace(contextDetails))
        {
            builder.AppendLine();
            builder.AppendLine("Full Context:");
            builder.AppendLine(contextDetails);
        }
        return builder.ToString();
    }

    private static string CleanupOneLineStatus(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string cleaned = text.Replace("\r", " ").Replace("\n", " ").Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"^[-*•\s]+", string.Empty).Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"\s+", " ").Trim();

        int firstSentenceEnd = cleaned.IndexOfAny(new[] { '.', '!', '?' });
        if (firstSentenceEnd >= 0 && firstSentenceEnd < cleaned.Length - 1)
        {
            cleaned = cleaned.Substring(0, firstSentenceEnd + 1).Trim();
        }

        string[] words = cleaned.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
        if (words.Length > 22)
        {
            cleaned = string.Join(" ", words, 0, 22).TrimEnd('.', ',', ';', ':') + "...";
        }

        return cleaned;
    }

    private static string BuildDeterministicOneLineStatus(string status, string sysdebug, string contextDetails)
    {
        Dictionary<string, string> contextMap = ParseContextDetails(contextDetails);
        string owner = FirstContextValue(contextMap, "Owner", "Promoted Issue Owner");
        string promotedStatus = FirstContextValue(contextMap, "Promoted Status", "Promoted Issue Status", "Status");
        string fixedVersion = FirstContextValue(contextMap, "Promoted Issue Fixed Version", "Fixed Version");
        string closedReason = FirstContextValue(contextMap, "Closed Reason", "Promoted Issue Closed Reason");

        if (!string.IsNullOrWhiteSpace(fixedVersion) && !string.Equals(fixedVersion, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            return CleanupOneLineStatus("Fix is recorded in " + fixedVersion + ", with validation or closure follow-up pending.");
        }

        if (!string.IsNullOrWhiteSpace(closedReason) && !string.Equals(closedReason, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            return CleanupOneLineStatus("Issue is closed or rejected with reason " + closedReason + ".");
        }

        string effectiveStatus = string.IsNullOrWhiteSpace(promotedStatus) || string.Equals(promotedStatus, "N/A", StringComparison.OrdinalIgnoreCase) ? status : promotedStatus;
        if (!string.IsNullOrWhiteSpace(owner) && !string.Equals(owner, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            return CleanupOneLineStatus("Issue is " + effectiveStatus + " and currently owned by " + owner + " for follow-up.");
        }

        if (!string.IsNullOrWhiteSpace(sysdebug))
        {
            return CleanupOneLineStatus(sysdebug);
        }

        return CleanupOneLineStatus("Issue is " + effectiveStatus + " with latest HSD details under review.");
    }

    private static string BuildModelRequestErrorMessage(WebException webEx)
    {
        HttpWebResponse response = webEx.Response as HttpWebResponse;
        string body = ReadResponseBody(response);

        if (response == null)
        {
            return "Model request failed: no response from provider. Check internet/proxy access to models.inference.ai.azure.com.";
        }

        int statusCode = (int)response.StatusCode;
        string providerMessage = ExtractProviderErrorMessage(body);

        if (statusCode == 401)
        {
            return "Model request failed (401 Unauthorized): GitHub PAT is invalid or expired." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 403)
        {
            return "Model request failed (403 Forbidden): PAT lacks GitHub Models access for this account/org." + AppendProviderMessage(providerMessage);
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
            return "AI model unavailable. Showing deterministic fallback summary.";
        }

        return "AI model unavailable. Showing deterministic fallback summary. " + modelError;
    }

    private static string BuildFallbackSummary(string issueId, string submittedDate, string title, string status, string sysdebug, string contextDetails)
    {
        Dictionary<string, string> contextMap = ParseContextDetails(contextDetails);
        bool hasIssueContext = contextMap.Count > 0;

        string safeStatus = string.IsNullOrWhiteSpace(status) ? "Unknown" : status.Trim();
        string contextStatus = FirstContextValue(contextMap, "Promoted Status", "Status", "Promoted Issue Status");
        if (!string.IsNullOrWhiteSpace(contextStatus) && !string.Equals(contextStatus, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            safeStatus = contextStatus;
        }

        string component = FirstContextValue(contextMap, "Component");
        string operatingSystem = FirstContextValue(contextMap, "Operating System");
        string cmfRequest = FirstContextValue(contextMap, "CMF Request", "Promoted Issue CMF Request");
        string priority = FirstContextValue(contextMap, "Priority", "Promoted Issue Priority");
        string customerImpact = FirstContextValue(contextMap, "Customer Impact", "Promoted Issue Customer Impact");
        string reproducibility = FirstContextValue(contextMap, "Reproducibility");
        string impact = FirstContextValue(contextMap, "Impact", "Promoted Issue Impact");
        string promotedId = FirstContextValue(contextMap, "Promoted ID", "Promoted Issue ID");
        string promotedIssueStatus = FirstContextValue(contextMap, "Promoted Issue Status");
        string promotedIssueClosedReason = FirstContextValue(contextMap, "Promoted Issue Closed Reason");
        string promotedIssueFixedVersion = FirstContextValue(contextMap, "Promoted Issue Fixed Version");
        string closedReason = FirstContextValue(contextMap, "Closed Reason", "Promoted Issue Closed Reason");
        string fixedVersion = FirstContextValue(contextMap, "Fixed Version", "Promoted Issue Fixed Version");
        string drivers = FirstContextValue(contextMap, "Drivers", "Must Fix For");
        string rvpDebug = FirstContextValue(contextMap, "RVP Platform Debug Details", "RVP Debug", "Repro On RVP");
        List<string> activityLines = ExtractActivityLines(contextDetails);

        string debugSnippet = BuildDebugSnippet(sysdebug);
        string issueSituation = BuildIssueSituationNarrative(title, component, operatingSystem, impact, customerImpact, reproducibility);
        bool highRisk = ContainsAnyToken(priority, "p0", "p1", "showstopper") || ContainsAnyToken(customerImpact, "critical", "2-high", "high");

        string riskNarrative = highRisk
            ? "The signals indicate elevated risk because priority/impact are high"
            : "The current signals look moderate and need normal triage follow-up";

        if (!string.IsNullOrWhiteSpace(reproducibility) && !string.Equals(reproducibility, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            riskNarrative += " and reproducibility is reported as " + reproducibility;
        }

        string outcomeNarrative = BuildOutcomeNarrative(safeStatus, closedReason, fixedVersion, riskNarrative);

        string nextAction;
        if (ContainsAnyToken(safeStatus, "rejected", "closed", "complete")
            && !string.IsNullOrWhiteSpace(closedReason)
            && !string.Equals(closedReason, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            nextAction = "No active debug action is needed unless new evidence contradicts the closure reason: " + closedReason.Replace("_", " ") + ".";
        }
        else if (highRisk && ContainsAnyToken(cmfRequest, "cmf_ask", "cmf_incomplete"))
        {
            nextAction = "run an owner-led triage now, attach fresh repro/debug evidence, and make a CMF go/no-go call with ETA.";
        }
        else if (ContainsAnyToken(cmfRequest, "cmf_reject") && highRisk)
        {
            nextAction = "recheck the reject decision against customer impact and linked-issue evidence before closing triage.";
        }
        else if (!string.IsNullOrWhiteSpace(promotedIssueFixedVersion) && !string.Equals(promotedIssueFixedVersion, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            nextAction = "validate whether the recorded fix version resolves this issue and update status with verification evidence.";
        }
        else
        {
            nextAction = "confirm owner, reproduce with latest logs, and record the next unblock step with target date.";
        }

        List<string> storyBullets = new List<string>();
        AddUniqueBullet(storyBullets, BuildShortPhrase(issueSituation, 115));
        for (int index = 0; index < activityLines.Count && storyBullets.Count < 2; index++)
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase(activityLines[index], 115));
        }

        if (storyBullets.Count <= 1 && !string.IsNullOrWhiteSpace(debugSnippet) && debugSnippet.IndexOf("No sysdebug details", StringComparison.OrdinalIgnoreCase) < 0)
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase("Latest debug signal: " + debugSnippet, 115));
        }

        AddUniqueBullet(storyBullets, BuildShortPhrase(outcomeNarrative, 115));

        string evidenceNarrative = BuildEvidenceNarrative(component, operatingSystem, cmfRequest, priority, customerImpact, reproducibility, impact, promotedId, promotedIssueStatus, promotedIssueClosedReason, promotedIssueFixedVersion);
        if (!string.IsNullOrWhiteSpace(evidenceNarrative))
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase(evidenceNarrative, 115));
        }

        if (storyBullets.Count == 0)
        {
            AddUniqueBullet(storyBullets, "Latest ticket context is being reviewed from the available HSD and portal fields.");
        }

        StringBuilder builder = new StringBuilder();
        builder.AppendLine("**AI summary (Confidence: " + CalculateSummaryConfidence(status, sysdebug, contextDetails).ToString() + "%)**");
        builder.AppendLine();
        builder.AppendLine("Sighting ID: " + BuildDisplayValue(issueId) + "  CMF Ask date: " + BuildDisplayValue(submittedDate));
        builder.AppendLine();
        builder.AppendLine("Impact: " + BuildDisplayValue(FirstNonEmpty(customerImpact, impact)));
        builder.AppendLine("Reproducibility: " + BuildDisplayValue(reproducibility));
        builder.AppendLine("Logs(sysdebug/debug details): " + (HasPresentValue(sysdebug) || HasPresentValue(FirstContextValue(contextMap, "Sysdebug", "Sysdebug Forum")) ? "Yes" : "No"));
        builder.AppendLine("RVP platform debug details: " + BuildYesNoValue(rvpDebug));
        builder.AppendLine();
        builder.AppendLine("**Summary:**");
        for (int index = 0; index < 3; index++)
        {
            string bullet = index < storyBullets.Count ? storyBullets[index] : "Latest available HSD fields do not add more issue activity.";
            builder.AppendLine((index + 1).ToString() + ") " + bullet.TrimEnd('.'));
        }

        builder.AppendLine();
        builder.AppendLine("**Follow up**");
        builder.Append("- " + BuildCompactFollowUpAction(nextAction, drivers, fixedVersion, closedReason));
        return builder.ToString();
    }

    private static int CalculateSummaryConfidence(string status, string sysdebug, string contextDetails)
    {
        Dictionary<string, string> contextMap = ParseContextDetails(contextDetails);
        int confidence = 50;

        if (contextMap.Count > 0) confidence += 10;
        if (HasPresentValue(sysdebug) || HasPresentValue(FirstContextValue(contextMap, "Sysdebug", "Sysdebug Forum"))) confidence += 10;
        if (ExtractActivityLines(contextDetails).Count > 0) confidence += 10;
        if (HasPresentValue(FirstContextValue(contextMap, "Closed Reason", "Fixed Version", "Promoted Issue Fixed Version", "Promoted Issue Closed Reason"))) confidence += 10;
        if (HasPresentValue(FirstContextValue(contextMap, "Customer Impact", "Impact"))) confidence += 5;
        if (HasPresentValue(FirstContextValue(contextMap, "Reproducibility", "RVP Platform Debug Details"))) confidence += 5;
        if (ContainsAnyToken(status, "rejected", "closed", "complete", "verified", "implemented")) confidence += 5;

        if (confidence > 92) return 92;
        if (confidence < 40) return 40;
        return confidence;
    }

    private static string BuildDisplayValue(string value)
    {
        if (!HasPresentValue(value)) return "N/A";
        return BuildShortPhrase(value.Trim().Replace("_", " "), 80);
    }

    private static string BuildYesNoValue(string value)
    {
        if (!HasPresentValue(value)) return "No";
        if (ContainsAnyToken(value, "no", "false", "not available", "n/a", "none")) return "No";
        return "Yes";
    }

    private static bool HasPresentValue(string value)
    {
        if (string.IsNullOrWhiteSpace(value)) return false;
        string cleaned = value.Trim();
        return !string.Equals(cleaned, "N/A", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(cleaned, "NA", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(cleaned, "null", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(cleaned, "-", StringComparison.OrdinalIgnoreCase);
    }

    private static string BuildCompactFollowUpAction(string defaultAction, string drivers, string fixedVersion, string closedReason)
    {
        if (HasPresentValue(drivers) && ContainsAnyToken(drivers, "hot fix", "hotfix", "hf", "fix"))
        {
            return "Apply " + BuildShortPhrase(drivers.Replace("_", " "), 70) + " and rerun validation.";
        }

        if (HasPresentValue(fixedVersion))
        {
            return "Validate fix in " + BuildShortPhrase(fixedVersion, 60) + " and update status.";
        }

        if (HasPresentValue(closedReason))
        {
            return "No further action unless new evidence changes closure.";
        }

        return BuildShortPhrase(defaultAction, 95).TrimEnd('.') + ".";
    }

    private static string BuildIssueSituationNarrative(string title, string component, string operatingSystem, string impact, string customerImpact, string reproducibility)
    {
        string subject = string.IsNullOrWhiteSpace(title) ? "This issue" : "This issue concerns " + BuildShortPhrase(title, 120);
        List<string> context = new List<string>();

        if (!string.IsNullOrWhiteSpace(component) && !string.Equals(component, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            context.Add("component " + component.Trim());
        }

        if (!string.IsNullOrWhiteSpace(operatingSystem) && !string.Equals(operatingSystem, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            context.Add("OS " + operatingSystem.Trim());
        }

        string impactText = !string.IsNullOrWhiteSpace(customerImpact) && !string.Equals(customerImpact, "N/A", StringComparison.OrdinalIgnoreCase)
            ? customerImpact
            : impact;
        if (!string.IsNullOrWhiteSpace(impactText) && !string.Equals(impactText, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            context.Add("reported impact " + BuildShortPhrase(impactText, 90));
        }

        if (!string.IsNullOrWhiteSpace(reproducibility) && !string.Equals(reproducibility, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            context.Add("reproducibility " + BuildShortPhrase(reproducibility, 60));
        }

        if (context.Count == 0)
        {
            return subject;
        }

        return subject + ", with " + JoinReadableList(context);
    }

    private static string BuildShortPhrase(string text, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string cleaned = text.Replace("\r", " ").Replace("\n", " ").Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"\s+", " ");
        if (cleaned.Length <= maxLength) return cleaned.TrimEnd('.', ';', ':');
        return cleaned.Substring(0, Math.Max(1, maxLength - 3)).TrimEnd('.', ',', ';', ':', ' ') + "...";
    }

    private static string JoinReadableList(List<string> values)
    {
        if (values == null || values.Count == 0) return string.Empty;
        if (values.Count == 1) return values[0];
        if (values.Count == 2) return values[0] + " and " + values[1];

        StringBuilder builder = new StringBuilder();
        for (int index = 0; index < values.Count; index++)
        {
            if (index > 0)
            {
                builder.Append(index == values.Count - 1 ? ", and " : ", ");
            }

            builder.Append(values[index]);
        }

        return builder.ToString();
    }

    private static void AddUniqueBullet(List<string> bullets, string bullet)
    {
        if (bullets == null || string.IsNullOrWhiteSpace(bullet))
        {
            return;
        }

        string cleaned = bullet.Trim().TrimStart('-', ' ').Trim();
        if (string.IsNullOrWhiteSpace(cleaned))
        {
            return;
        }

        string key = NormalizeSummaryLineForDedupe(cleaned);
        for (int index = 0; index < bullets.Count; index++)
        {
            if (string.Equals(NormalizeSummaryLineForDedupe(bullets[index]), key, StringComparison.OrdinalIgnoreCase))
            {
                return;
            }
        }

        bullets.Add(cleaned);
    }

    private static string BuildEvidenceNarrative(string component, string operatingSystem, string cmfRequest, string priority, string customerImpact, string reproducibility, string impact, string promotedId, string promotedIssueStatus, string promotedIssueClosedReason, string promotedIssueFixedVersion)
    {
        List<string> evidence = new List<string>();
        AddEvidence(evidence, "component", component);
        AddEvidence(evidence, "OS", operatingSystem);
        AddEvidence(evidence, "priority", priority);
        AddEvidence(evidence, "customer impact", customerImpact);
        AddEvidence(evidence, "reproducibility", reproducibility);
        AddEvidence(evidence, "impact", impact);
        AddEvidence(evidence, "CMF request", cmfRequest);

        if (!string.IsNullOrWhiteSpace(promotedIssueFixedVersion) && !string.Equals(promotedIssueFixedVersion, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            AddEvidence(evidence, "promoted fix", promotedIssueFixedVersion);
        }
        else if (!string.IsNullOrWhiteSpace(promotedIssueClosedReason) && !string.Equals(promotedIssueClosedReason, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            AddEvidence(evidence, "promoted closure", promotedIssueClosedReason);
        }
        else if (!string.IsNullOrWhiteSpace(promotedIssueStatus) && !string.Equals(promotedIssueStatus, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            AddEvidence(evidence, "promoted status", promotedIssueStatus);
        }
        else if (!string.IsNullOrWhiteSpace(promotedId) && !string.Equals(promotedId, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            AddEvidence(evidence, "promoted ID", promotedId);
        }

        if (evidence.Count == 0)
        {
            return string.Empty;
        }

        return "Supporting evidence includes " + string.Join(", ", evidence.ToArray());
    }

    private static void AddEvidence(List<string> evidence, string label, string value)
    {
        if (evidence == null || evidence.Count >= 4 || string.IsNullOrWhiteSpace(value) || string.Equals(value.Trim(), "N/A", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        evidence.Add(label + " " + value.Trim().Replace("_", " "));
    }

    private static string BuildOutcomeNarrative(string status, string closedReason, string fixedVersion, string riskNarrative)
    {
        string safeStatus = string.IsNullOrWhiteSpace(status) ? "unknown" : status.Trim();
        string readableStatus = safeStatus.Replace("_", " ");
        string readableClosedReason = string.IsNullOrWhiteSpace(closedReason) ? string.Empty : closedReason.Trim().Replace("_", " ");
        string readableFixedVersion = string.IsNullOrWhiteSpace(fixedVersion) ? string.Empty : fixedVersion.Trim();
        bool isRejectedOrClosed = ContainsAnyToken(safeStatus, "rejected", "closed", "complete");

        if (isRejectedOrClosed && !string.IsNullOrWhiteSpace(readableClosedReason) && !string.Equals(readableClosedReason, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            if (!string.IsNullOrWhiteSpace(readableFixedVersion) && !string.Equals(readableFixedVersion, "N/A", StringComparison.OrdinalIgnoreCase))
            {
                return "Current status is " + readableStatus + " because it was closed as " + readableClosedReason + ", with fix/version evidence recorded as " + readableFixedVersion;
            }

            return "The issue is " + readableStatus + "; closure reason " + readableClosedReason + " is the strongest available outcome signal";
        }

        if (isRejectedOrClosed && !string.IsNullOrWhiteSpace(readableFixedVersion) && !string.Equals(readableFixedVersion, "N/A", StringComparison.OrdinalIgnoreCase))
        {
            return "Current status is " + readableStatus + " with fix/version evidence recorded as " + readableFixedVersion;
        }

        return "Current status is " + readableStatus + "; " + riskNarrative;
    }

    private static List<string> ExtractActivityLines(string contextDetails)
    {
        List<string> activity = new List<string>();
        if (string.IsNullOrWhiteSpace(contextDetails))
        {
            return activity;
        }

        string[] lines = contextDetails.Replace("\r", string.Empty).Split('\n');
        for (int index = 0; index < lines.Length; index++)
        {
            string line = lines[index] == null ? string.Empty : lines[index].Trim();
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            bool looksLikeActivity = line.StartsWith("[", StringComparison.Ordinal)
                || line.StartsWith("Discussion Comments", StringComparison.OrdinalIgnoreCase)
                || line.StartsWith("Owner:", StringComparison.OrdinalIgnoreCase)
                || line.StartsWith("Submitter:", StringComparison.OrdinalIgnoreCase)
                || line.StartsWith("Promoted Issue Fixed Version:", StringComparison.OrdinalIgnoreCase)
                || line.StartsWith("Sysdebug Forum:", StringComparison.OrdinalIgnoreCase);

            if (!looksLikeActivity)
            {
                continue;
            }

            string cleaned = line.TrimStart('-', ' ');
            cleaned = BuildDebugSnippet(cleaned);
            if (!string.IsNullOrWhiteSpace(cleaned) && !activity.Contains(cleaned))
            {
                activity.Add(cleaned);
            }

            if (activity.Count >= 4)
            {
                break;
            }
        }

        return activity;
    }

    private static Dictionary<string, string> ParseContextDetails(string contextDetails)
    {
        Dictionary<string, string> parsed = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (string.IsNullOrWhiteSpace(contextDetails))
        {
            return parsed;
        }

        string[] lines = contextDetails.Replace("\r", string.Empty).Split('\n');
        for (int index = 0; index < lines.Length; index++)
        {
            string line = lines[index];
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            int separator = line.IndexOf(':');
            if (separator <= 0)
            {
                continue;
            }

            string key = line.Substring(0, separator).Trim();
            string value = line.Substring(separator + 1).Trim();
            if (key.Length == 0)
            {
                continue;
            }

            if (!parsed.ContainsKey(key))
            {
                parsed[key] = value;
            }
        }

        return parsed;
    }

    private static string FirstContextValue(Dictionary<string, string> contextMap, params string[] keys)
    {
        if (contextMap == null || keys == null)
        {
            return string.Empty;
        }

        for (int index = 0; index < keys.Length; index++)
        {
            string key = keys[index];
            if (string.IsNullOrWhiteSpace(key))
            {
                continue;
            }

            string value;
            if (!contextMap.TryGetValue(key, out value))
            {
                continue;
            }

            if (!string.IsNullOrWhiteSpace(value))
            {
                return value.Trim();
            }
        }

        return string.Empty;
    }

    private static bool ContainsAnyToken(string text, params string[] tokens)
    {
        if (string.IsNullOrWhiteSpace(text) || tokens == null)
        {
            return false;
        }

        for (int index = 0; index < tokens.Length; index++)
        {
            string token = tokens[index];
            if (string.IsNullOrWhiteSpace(token))
            {
                continue;
            }

            if (text.IndexOf(token, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return true;
            }
        }

        return false;
    }

    private static string BuildContextSnippet(string contextDetails)
    {
        if (string.IsNullOrWhiteSpace(contextDetails))
        {
            return string.Empty;
        }

        string normalized = contextDetails.Replace("\r", " ").Replace("\n", " ").Trim();
        while (normalized.IndexOf("  ", StringComparison.Ordinal) >= 0)
        {
            normalized = normalized.Replace("  ", " ");
        }

        const int maxLength = 180;
        if (normalized.Length > maxLength)
        {
            normalized = normalized.Substring(0, maxLength) + "...";
        }

        return normalized;
    }

    private static string BuildDebugSnippet(string sysdebug)
    {
        if (string.IsNullOrWhiteSpace(sysdebug))
        {
            return "No sysdebug details were provided";
        }

        string normalized = sysdebug.Replace("\r", " ").Replace("\n", " ").Trim();
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

    private static string ExtractContentFromResponse(object raw)
    {
        IDictionary root = raw as IDictionary;
        if (root == null)
        {
            return string.Empty;
        }

        object choicesObj = root["choices"];
        IList choices = choicesObj as IList;
        if (choices == null || choices.Count == 0)
        {
            return string.Empty;
        }

        IDictionary firstChoice = choices[0] as IDictionary;
        if (firstChoice == null)
        {
            return string.Empty;
        }

        IDictionary message = firstChoice["message"] as IDictionary;
        if (message == null)
        {
            return string.Empty;
        }

        object contentObj = message["content"];
        if (contentObj == null)
        {
            return string.Empty;
        }

        return contentObj.ToString();
    }

    private static string SafeText(object value)
    {
        if (value == null)
        {
            return string.Empty;
        }

        string text = value.ToString();
        return string.IsNullOrWhiteSpace(text) ? string.Empty : text.Trim();
    }

    private static string ComputeHash(string input)
    {
        using (SHA256 sha = SHA256.Create())
        {
            byte[] bytes = Encoding.UTF8.GetBytes(input ?? string.Empty);
            byte[] hash = sha.ComputeHash(bytes);
            StringBuilder builder = new StringBuilder(hash.Length * 2);
            for (int index = 0; index < hash.Length; index++)
            {
                builder.Append(hash[index].ToString("x2"));
            }

            return builder.ToString();
        }
    }
}

public class AiSummaryCacheEntry
{
    public DateTime ExpiresAtUtc { get; set; }
    public AiSummaryResponse Value { get; set; }
}
