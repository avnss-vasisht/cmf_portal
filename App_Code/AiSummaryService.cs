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
    public int Confidence { get; set; }
    public string Message { get; set; }
    public bool UsedFallback { get; set; }
}

public static class AiSummaryService
{
    private static readonly object CacheSync = new object();
    private static readonly Dictionary<string, AiSummaryCacheEntry> Cache = new Dictionary<string, AiSummaryCacheEntry>(StringComparer.Ordinal);
    // Store latest assistant/model summary per issueId to support follow-up Q&A (chat-like followups)
    private static readonly Dictionary<string, string> ConversationStore = new Dictionary<string, string>(StringComparer.Ordinal);

    public static AiSummaryResponse GenerateDashboardExecutiveSummary(string platformLabel, string contextDetails)
    {
        platformLabel = SafeText(platformLabel);
        contextDetails = SafeText(contextDetails);

        string hash = ComputeHash("dashboard-executive-v1|" + GetAiProviderCacheSignature() + "|" + platformLabel + "|" + contextDetails);
        string cacheKey = "dashboard-executive:" + hash;

        AiSummaryResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached;
        }

        string prompt = "Create a brief executive summary for the current CMF platform workload. " +
            "Use only the supplied metrics and tables, but write in normal business language with clear grammar and punctuation. " +
            "Do not dump raw metrics or table names; mention only the few numbers needed to explain the situation. " +
            "Keep it to 3-4 short sentences suitable for a manager demo. Do not invent customer names, dates, or counts.\n\n" +
            "Platform: " + platformLabel + "\n\n" + contextDetails;

        string modelSummary;
        string modelError;
        bool hasModelSummary = TryGenerateWithGitHubModel(
            "dashboard",
            DateTime.UtcNow.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
            "CMF Dashboard Executive Summary",
            "Dashboard",
            string.Empty,
            contextDetails,
            out modelSummary,
            out modelError,
            prompt,
            "You are an executive CMF program analyst. Be specific, evidence-grounded, concise, and business-focused. Do not invent facts.");

        AiSummaryResponse response = new AiSummaryResponse
        {
            Success = true,
            IssueId = "dashboard",
            Title = "CMF Dashboard Executive Summary",
            SubmittedDate = DateTime.UtcNow.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
            Summary = hasModelSummary ? CleanupSummarySpacing(modelSummary, 180) : BuildFallbackDashboardExecutiveSummary(platformLabel, contextDetails),
            Confidence = hasModelSummary ? 86 : 58,
            UsedFallback = !hasModelSummary,
            Message = hasModelSummary ? string.Empty : "AI provider output was unavailable; local dashboard summary was used."
        };

        SetCached(cacheKey, response, DateTime.UtcNow.AddMinutes(20));
        return response;
    }

    public static AiSummaryResponse GenerateDashboardPredictedBlockers(string platformLabel, string contextDetails)
    {
        platformLabel = SafeText(platformLabel);
        contextDetails = SafeText(contextDetails);

        string hash = ComputeHash("dashboard-blockers-v1|" + GetAiProviderCacheSignature() + "|" + platformLabel + "|" + contextDetails);
        string cacheKey = "dashboard-blockers:" + hash;

        AiSummaryResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached;
        }

        string prompt = "Read the supplied current CMF workload and predict the most likely blockers the program may face next. " +
            "Return exactly 1 to 3 short bullet lines. Each bullet must be one plain-English sentence under 120 characters. " +
            "Do not repeat issue titles verbatim; infer the blocker from priority, impact, milestone, status, and issue wording. " +
            "Do not invent customers, owners, dates, or counts.\n\n" +
            "Platform: " + platformLabel + "\n\n" + contextDetails;

        string modelSummary;
        string modelError;
        bool hasModelSummary = TryGenerateWithGitHubModel(
            "dashboard-blockers",
            DateTime.UtcNow.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
            "CMF Dashboard Predicted Blockers",
            "Dashboard",
            string.Empty,
            contextDetails,
            out modelSummary,
            out modelError,
            prompt,
            "You are a CMF program risk analyst. Predict concise blockers only from supplied evidence. Be brief and practical.");

        AiSummaryResponse response = new AiSummaryResponse
        {
            Success = true,
            IssueId = "dashboard-blockers",
            Title = "CMF Dashboard Predicted Blockers",
            SubmittedDate = DateTime.UtcNow.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
            Summary = hasModelSummary ? CleanupSummarySpacing(modelSummary, 80) : BuildFallbackDashboardPredictedBlockers(contextDetails),
            Confidence = hasModelSummary ? 84 : 54,
            UsedFallback = !hasModelSummary,
            Message = hasModelSummary ? string.Empty : "AI provider output was unavailable; local blocker forecast was used."
        };

        SetCached(cacheKey, response, DateTime.UtcNow.AddMinutes(20));
        return response;
    }

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

        // Enrich context with HSD sighting and promoted article details (sysdebug_forum etc.)
        try
        {
            contextDetails = EnrichContextWithHsdArticles(issueId, contextDetails);
        }
        catch
        {
            // Ignore enrichment failures - fall back to provided context only
        }

        int confidence = CalculateSummaryConfidence(status, sysdebug, contextDetails);
        string hash = ComputeHash("summary-debug-decision-live-v6|" + GetAiProviderCacheSignature() + "|" + issueId + "|" + title + "|" + submittedDate + "|" + status + "|" + sysdebug + "|" + contextDetails);
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
            int fallbackConfidence = Math.Max(40, confidence - 8);

            string fallbackSummary = CleanupSummarySpacing(
                BuildFallbackSummary(
                    issueId,
                    submittedDate,
                    title,
                    status,
                    sysdebug,
                    contextDetails,
                    fallbackConfidence),
                220);

            return new AiSummaryResponse
            {
                Success = true,
                IssueId = issueId,
                Title = title,
                SubmittedDate = submittedDate,
                Summary = fallbackSummary,
                Confidence = fallbackConfidence,
                Message = BuildFallbackMessage(modelError),
                UsedFallback = true
            };
        }

        // Post-process the model output to clean up spacing and ensure word limit
        string concise = CleanupSummarySpacing(modelSummary, 220);

        // Save the raw model output for follow-up chat interactions keyed by issueId
        try
        {
            if (!string.IsNullOrWhiteSpace(issueId))
            {
                lock (CacheSync)
                {
                    ConversationStore[issueId] = modelSummary ?? string.Empty;
                }
            }
        }
        catch
        {
            // swallow any errors in conversation caching
        }

        AiSummaryResponse result = new AiSummaryResponse
        {
            Success = true,
            IssueId = issueId,
            Title = title,
            SubmittedDate = submittedDate,
            Summary = concise,
            Confidence = confidence,
            Message = "AI summary generated.",
            UsedFallback = false
        };

        SetCached(cacheKey, result, DateTime.UtcNow.AddMinutes(30));
        return result;
    }

    // Generate an assistant-style follow-up response based on the last AI summary and ticket context.
    // Returns an AiSummaryResponse with the follow-up answer in `Summary` and confidence estimate.
    public static AiSummaryResponse GenerateFollowUpResponse(AiSummaryRequest request, string followUpQuestion)
    {
        if (request == null || string.IsNullOrWhiteSpace(followUpQuestion))
        {
            return new AiSummaryResponse { Success = false, Message = "Invalid follow-up request." };
        }

        string issueId = SafeText(request.IssueId);
        string title = SafeText(request.Title);
        string submittedDate = SafeText(request.SubmittedDate);
        string status = SafeText(request.Status);
        string sysdebug = SafeText(request.Sysdebug);
        string contextDetails = SafeText(request.ContextDetails);

        // Enrich context with HSD sighting and promoted articles
        try { contextDetails = EnrichContextWithHsdArticles(issueId, contextDetails); } catch { }

        // Retrieve last model summary if present
        string lastModelSummary = string.Empty;
        lock (CacheSync)
        {
            if (!string.IsNullOrWhiteSpace(issueId) && ConversationStore.ContainsKey(issueId))
            {
                lastModelSummary = ConversationStore[issueId] ?? string.Empty;
            }
        }

        string prompt = BuildFollowUpPrompt(issueId, submittedDate, title, status, sysdebug, contextDetails, lastModelSummary, followUpQuestion);

        string modelAnswer;
        string modelError;
        bool gotAnswer = TryGenerateWithGitHubModel(issueId + "-followup", submittedDate, title, status, sysdebug, contextDetails, out modelAnswer, out modelError, prompt, "You are a helpful CMF issue assistant. Answer succinctly and only using the supplied ticket context and previous AI summary. If the information is not available, say so.");

        if (!gotAnswer)
        {
            string fallback = BuildFallbackFollowUpAnswer(followUpQuestion, contextDetails, lastModelSummary);
            return new AiSummaryResponse
            {
                Success = true,
                IssueId = issueId,
                Title = title,
                SubmittedDate = submittedDate,
                Summary = fallback,
                Confidence = Math.Max(30, EstimateSummaryConfidence(request) - 10),
                Message = BuildFallbackMessage(modelError),
                UsedFallback = true
            };
        }

        string concise = CleanupSummarySpacing(modelAnswer, 200);

        // update conversation store with the assistant reply (so further follow-ups can reference it)
        try { lock (CacheSync) { if (!string.IsNullOrWhiteSpace(issueId)) ConversationStore[issueId] = lastModelSummary + "\n\nAssistant Reply:\n" + concise; } } catch { }

        return new AiSummaryResponse
        {
            Success = true,
            IssueId = issueId,
            Title = title,
            SubmittedDate = submittedDate,
            Summary = concise,
            Confidence = EstimateSummaryConfidence(request),
            Message = "Follow-up answer generated.",
            UsedFallback = false
        };
    }

    private static string BuildFollowUpPrompt(string issueId, string submittedDate, string title, string status, string sysdebug, string contextDetails, string previousSummary, string question)
    {
        StringBuilder b = new StringBuilder();
        b.AppendLine("You are a CMF issue assistant. Use only the supplied ticket data and previous AI summary to answer the user's question.");
        b.AppendLine("Do not invent facts or assume information not present in the data. If the answer is not determinable, say 'Insufficient information to answer'.");
        b.AppendLine();
        b.AppendLine("Ticket metadata:");
        b.AppendLine("Issue ID: " + issueId);
        b.AppendLine("Title: " + title);
        b.AppendLine("Submitted Date: " + submittedDate);
        b.AppendLine("Status: " + status);
        b.AppendLine("Sysdebug: " + sysdebug);
        if (!string.IsNullOrWhiteSpace(contextDetails))
        {
            b.AppendLine();
            b.AppendLine("Full Context:");
            b.AppendLine(contextDetails);
        }

        if (!string.IsNullOrWhiteSpace(previousSummary))
        {
            b.AppendLine();
            b.AppendLine("Previous AI Summary:");
            b.AppendLine(previousSummary);
        }

        b.AppendLine();
        b.AppendLine("User question: " + question);
        b.AppendLine();
        b.AppendLine("Answer in 1-3 short sentences, remain factual and cite the strongest evidence from the ticket context when applicable.");
        return b.ToString();
    }

    private static string BuildFallbackFollowUpAnswer(string question, string contextDetails, string previousSummary)
    {
        StringBuilder b = new StringBuilder();
        b.AppendLine("AI provider unavailable; deterministic fallback cannot fully reason like the model.");
        b.AppendLine("Question: " + question);
        if (!string.IsNullOrWhiteSpace(previousSummary))
        {
            b.AppendLine();
            b.AppendLine("Previous summary (reference):");
            b.AppendLine(previousSummary);
        }

        if (!string.IsNullOrWhiteSpace(contextDetails))
        {
            b.AppendLine();
            b.AppendLine("Ticket context (search this for details):");
            // include a short snippet of the context to help the user
            b.AppendLine(BuildContextSnippet(contextDetails));
        }

        b.AppendLine();
        b.AppendLine("Insufficient information to generate a confident follow-up answer without the AI provider.");
        return b.ToString();
    }

    public static AiSummaryResponse GenerateIssueDetails(AiSummaryRequest request)
    {
        if (request == null)
        {
            return new AiSummaryResponse
            {
                Success = false,
                Message = "Invalid issue details request."
            };
        }

        string issueId = SafeText(request.IssueId);
        string title = SafeText(request.Title);
        string submittedDate = SafeText(request.SubmittedDate);
        string status = SafeText(request.Status);
        string sysdebug = SafeText(request.Sysdebug);
        string contextDetails = SafeText(request.ContextDetails);

        // Enrich context with HSD sighting and promoted article details (sysdebug_forum etc.)
        try
        {
            contextDetails = EnrichContextWithHsdArticles(issueId, contextDetails);
        }
        catch
        {
        }
        int confidence = CalculateSummaryConfidence(status, sysdebug, contextDetails);
        string hash = ComputeHash("issue-details-context-brief-live-v6|" + GetAiProviderCacheSignature() + "|" + issueId + "|" + title + "|" + submittedDate + "|" + status + "|" + sysdebug + "|" + contextDetails);
        string cacheKey = "ai-issue-details:" + hash;

        AiSummaryResponse cached = TryGetCached(cacheKey);
        if (cached != null)
        {
            return cached;
        }

        string modelDetails;
        string modelError;
        bool hasModelDetails = TryGenerateWithGitHubModel(
            issueId,
            submittedDate,
            title,
            status,
            sysdebug,
            contextDetails,
            out modelDetails,
            out modelError,
            BuildIssueDetailsPrompt(issueId, submittedDate, title, status, sysdebug, contextDetails),
            "You write plain-language issue briefs for iDST users. Stay factual, concise, and useful for quickly understanding the issue before opening HSD.");

        string details = hasModelDetails
            ? CleanupSummarySpacing(modelDetails, 260)
            : BuildFallbackIssueDetails(issueId, submittedDate, title, status, sysdebug, contextDetails, Math.Max(40, confidence - 8));

        AiSummaryResponse result = new AiSummaryResponse
        {
            Success = true,
            IssueId = issueId,
            Title = title,
            SubmittedDate = submittedDate,
            Summary = details,
            Confidence = hasModelDetails ? confidence : Math.Max(40, confidence - 8),
            Message = hasModelDetails ? "AI issue details generated." : BuildFallbackMessage(modelError),
            UsedFallback = !hasModelDetails
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

        // Attempt to enrich context with HSD article info to improve one-line status
        try
        {
            contextDetails = EnrichContextWithHsdArticles(issueId, contextDetails);
        }
        catch
        {
        }

        string hash = ComputeHash("one-line-status-v3|" + GetAiProviderCacheSignature() + "|" + issueId + "|" + title + "|" + status + "|" + sysdebug + "|" + contextDetails);
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

    public static int EstimateSummaryConfidence(AiSummaryRequest request)
    {
        if (request == null) return 40;
        return CalculateSummaryConfidence(SafeText(request.Status), SafeText(request.Sysdebug), SafeText(request.ContextDetails));
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

        return TrimToSentenceBoundary(string.Join(" ", words, 0, maxWords));
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

    private static string BuildFallbackDashboardExecutiveSummary(string platformLabel, string contextDetails)
    {
        StringBuilder builder = new StringBuilder();
        builder.Append("For ").Append(string.IsNullOrWhiteSpace(platformLabel) ? "the selected platform" : platformLabel).Append(", the dashboard shows the current CMF workload and risk posture from live portal data. ");
        builder.Append("The issue buckets, CMF summary counts, readiness score, top risk, and pending CMF signals should be reviewed together to prioritize triage. ");
        builder.Append("Focus first on the need-attention and stale buckets, then use the CMF pending and component summaries to identify where decisions can unblock validation. ");
        builder.Append("AI provider output was unavailable, so this summary is generated from the dashboard metrics without adding unsupported assumptions.");
        return builder.ToString();
    }

    private static string BuildFallbackDashboardPredictedBlockers(string contextDetails)
    {
        if (ContainsAnyToken(contextDetails, "blocker", "showstopper"))
        {
            return "High-priority issues may block validation until owners close the main debug path.";
        }

        if (ContainsAnyToken(contextDetails, "critical", "high"))
        {
            return "High-impact issues may delay customer validation if fixes do not land quickly.";
        }

        if (ContainsAnyToken(contextDetails, "open=") && !ContainsAnyToken(contextDetails, "open=0"))
        {
            return "Open issues may slow milestone readiness unless the largest cluster is resolved first.";
        }

        return "No major blocker pattern is visible from the current workload.";
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
        string gnaiEndpoint = ResolveGnaiEndpoint();
        string gnaiModel = ResolveGnaiModel();
        bool useGnai = !string.IsNullOrWhiteSpace(gnaiToken)
            && !string.IsNullOrWhiteSpace(gnaiEndpoint)
            && !gnaiEndpoint.StartsWith("REPLACE");
        string providerName = useGnai ? "GNAI" : "GitHub Models";

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
            error = BuildModelRequestErrorMessage(webEx, providerName);
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

        string githubEndpoint = FirstNonEmpty(ConfigurationManager.AppSettings["GitHubModels:Endpoint"], "https://models.inference.ai.azure.com/chat/completions");
        string githubModel = FirstNonEmpty(ConfigurationManager.AppSettings["GitHubModels:Model"], "gpt-4o-mini");
        string githubKey = ConfigurationManager.AppSettings["GitHubModels:ApiKey"] ?? string.Empty;
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
        string displayStatus = BuildDisplayValue(FirstContextValue(contextMap, "Promoted Status", "Status", "Promoted Issue Status"));
        if (!HasPresentValue(displayStatus)) displayStatus = BuildDisplayValue(status);

        StringBuilder builder = new StringBuilder();
        builder.AppendLine("### INSTRUCTIONS ###");
        builder.AppendLine("Review all ticket information and write a summary for an iDST/CCE lead needing the current debug position and closure/escalation decision.");
        builder.AppendLine("You are an expert engineering analyst. Analyze this as an engineering investigation, not just a collection of database fields.");
        builder.AppendLine();
        builder.AppendLine("### RULES ###");
        builder.AppendLine("1. Reconstruct the issue progression. Distinguish between symptom, investigation finding, root cause, fix, and final disposition.");
        builder.AppendLine("2. Do not just repeat field values. Explain what those values mean contextually.");
        builder.AppendLine("3. Give weight to detailed investigation updates over generic metadata. When multiple updates exist, prioritize the latest information.");
        builder.AppendLine("4. DO NOT invent root cause, fix, validation result, owner action, or technical findings.");
        builder.AppendLine("5. If unresolved or unconfirmed, state it explicitly.");
        builder.AppendLine("6. Answer implicitly: Can this be closed, escalated, or kept in debug?");
        builder.AppendLine("7. Keep each section to a crisp, natural sentence under 25 words.");
        builder.AppendLine("8. Escalation Warning MUST be exactly 'None.' if no signal exists.");
        builder.AppendLine();
        builder.AppendLine("### EXPECTED OUTPUT FORMAT ###");
        builder.AppendLine("**Current/Latest Status**");
        builder.AppendLine("- [Summarize the latest status update]");
        builder.AppendLine();
        builder.AppendLine("**Debug Summary**");
        builder.AppendLine("- [Summarize the sysdebug data and logs]");
        builder.AppendLine();
        builder.AppendLine("**Next Steps**");
        builder.AppendLine("- [Action required]");
        builder.AppendLine();
        builder.AppendLine("### TICKET DATA ###");
        builder.AppendLine("Issue ID: " + issueId);
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

    private static string BuildIssueDetailsPrompt(string issueId, string submittedDate, string title, string status, string sysdebug, string contextDetails)
    {
        StringBuilder builder = new StringBuilder();
        builder.AppendLine("### INSTRUCTIONS ###");
        builder.AppendLine("Write a plain-language issue brief from the CMF database context and HSD context.");
        builder.AppendLine("Imagine an iDST user clicked the button to understand the issue quickly before opening HSD.");
        builder.AppendLine();
        builder.AppendLine("### RULES ###");
        builder.AppendLine("1. Use only supplied data. Do not invent root cause, risk, next action, or closures.");
        builder.AppendLine("2. Do not dump raw fields. Convert technical fragments into normal words.");
        builder.AppendLine("3. For 'Debug signal' and 'Latest Activity', extract the strongest signal in one crisp sentence.");
        builder.AppendLine();
        builder.AppendLine("### EXPECTED OUTPUT FORMAT ###");
        builder.AppendLine("| Field | Value |");
        builder.AppendLine("|---|---|");
        builder.AppendLine("| **ID** | " + issueId + " |");
        builder.AppendLine("| **Title** | [Issue Title] |");
        builder.AppendLine("| **Priority** | [Priority] |");
        builder.AppendLine("| **Repro Rate** | [Repro Rate/Reproducibility] |");
        builder.AppendLine("| **Customer** | [Affected Customer] |");
        builder.AppendLine();
        builder.AppendLine("### Additional Details ###");
        builder.AppendLine("[1-2 brief paragraphs describing what is happening and the hardware/OS it shows up on.]");
        builder.AppendLine();
        builder.AppendLine("### Linked HSD / CMF Data ###");
        builder.AppendLine("- **Promoted ID:** [id or N/A]");
        builder.AppendLine("- **Owner:** [owner or N/A]");
        builder.AppendLine("- **Fixed Version / Closure:** [version/closed reason or N/A]");
        builder.AppendLine("- **Latest Activity:** [one short sentence or N/A]");
        builder.AppendLine();
        builder.AppendLine("### TICKET DATA ###");
        builder.AppendLine("Issue ID: " + issueId);
        builder.AppendLine("Issue title: " + title);
        builder.AppendLine("Submitted Date: " + submittedDate);
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

    private static string BuildFallbackIssueDetails(string issueId, string submittedDate, string title, string status, string sysdebug, string contextDetails, int confidence)
    {
        Dictionary<string, string> contextMap = ParseContextDetails(contextDetails);
        List<string> activityLines = ExtractActivityLines(contextDetails);
        string component = FirstContextValue(contextMap, "Component");
        string operatingSystem = FirstContextValue(contextMap, "Operating System");
        string currentStatus = FirstNonEmpty(FirstContextValue(contextMap, "Promoted Status", "Status", "Promoted Issue Status"), status);
        string impact = FirstContextValue(contextMap, "Customer Impact", "Promoted Issue Customer Impact", "Impact", "Promoted Issue Impact");
        string reproducibility = FirstContextValue(contextMap, "Reproducibility");
        string closedReason = FirstContextValue(contextMap, "Closed Reason", "Promoted Issue Closed Reason");
        string fixedVersion = FirstContextValue(contextMap, "Fixed Version", "Promoted Issue Fixed Version");
        string hsdDescription = FirstContextValue(contextMap, "Description", "Promoted Issue Description");
        string fixDescription = FirstContextValue(contextMap, "Fix Description", "Promoted Issue Fix Description");
        string symptom = FirstNonEmpty(
            BuildCrispDetailValue(hsdDescription, 30),
            BuildCrispDetailValue(impact, 26),
            BuildCrispDetailValue(fixDescription, 26),
            BuildIssueSituationNarrative(title, component, operatingSystem, impact, string.Empty, reproducibility));
        string stateDetail = FirstNonEmpty(
            BuildCrispDetailValue(fixDescription, 24),
            BuildCrispDetailValue(closedReason, 24),
            BuildDisplayValue(currentStatus));
        string debugSignal = BuildCrispDetailValue(FirstNonEmpty(sysdebug, FirstContextValue(contextMap, "Sysdebug", "Sysdebug Forum", "Sysdebug Category")), 28);

        StringBuilder builder = new StringBuilder();
        builder.AppendLine("**Issue Details**");
        builder.AppendLine("- What is happening: " + BuildShortPhrase(symptom, 140) + ".");
        builder.AppendLine("- Where it shows up: " + BuildDisplayValue(component) + " / " + BuildDisplayValue(operatingSystem) + ".");
        builder.AppendLine("- Who is affected: " + BuildDisplayValue(impact) + ".");
        builder.AppendLine("- Current state: " + stateDetail);
        builder.AppendLine("- Debug signal: " + debugSignal);
        builder.AppendLine();
        builder.AppendLine("**Linked HSD / CMF Data**");
        builder.AppendLine("- Sighting ID: " + BuildDisplayValue(issueId));
        builder.AppendLine("- Promoted ID: " + BuildDisplayValue(FirstContextValue(contextMap, "Promoted ID", "Promoted Issue ID")));
        builder.AppendLine("- Owner: " + BuildDisplayValue(FirstContextValue(contextMap, "Owner", "Promoted Issue Owner")));
        builder.AppendLine("- Fixed Version / Closure: " + BuildDisplayValue(FirstNonEmpty(fixedVersion, closedReason)));
        builder.Append("- Latest Activity: " + BuildCrispDetailValue(activityLines.Count > 0 ? activityLines[0] : string.Empty, 28));
        return builder.ToString();
    }

    private static string BuildCrispDetailValue(string value, int maxWords)
    {
        if (!HasPresentValue(value)) return "N/A";
        string cleaned = value.Replace("\r", " ").Replace("\n", " ").Replace("_", " ").Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"\s+", " ").Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"\[[^\]]+\]\s*", string.Empty).Trim();

        int sentenceEnd = cleaned.IndexOfAny(new[] { '.', '!', '?' });
        if (sentenceEnd > 20)
        {
            cleaned = cleaned.Substring(0, sentenceEnd + 1).Trim();
        }

        string[] words = cleaned.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
        if (words.Length > maxWords)
        {
            cleaned = string.Join(" ", words, 0, maxWords).TrimEnd(',', ';', ':') + ".";
        }
        else if (!cleaned.EndsWith(".") && !cleaned.EndsWith("!") && !cleaned.EndsWith("?"))
        {
            cleaned += ".";
        }

        return cleaned;
    }

    private static string BuildOneLineStatusPrompt(string title, string status, string sysdebug, string contextDetails)
    {
        StringBuilder builder = new StringBuilder();
        builder.AppendLine("Read the HSD ticket details, promoted details, comments, investigation notes, ownership, and status updates.");
        builder.AppendLine("Write exactly one concise sentence for a table cell that tells the most recent current status of this issue.");
        builder.AppendLine("Focus on what is happening now: latest update, owner/action, investigation state, fix/closure state, or blocking information.");
        builder.AppendLine("Do not repeat or restate the issue title; use only the latest status/update meaning.");
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
            cleaned = string.Join(" ", words, 0, 22).TrimEnd('.', ',', ';', ':');
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

    private static string BuildModelRequestErrorMessage(WebException webEx, string providerName)
    {
        HttpWebResponse response = webEx.Response as HttpWebResponse;
        string body = ReadResponseBody(response);
        string providerLabel = string.IsNullOrWhiteSpace(providerName) ? "model provider" : providerName;

        if (response == null)
        {
            return providerLabel + " request failed: no response from provider. Check endpoint/proxy/network access.";
        }

        int statusCode = (int)response.StatusCode;
        string providerMessage = ExtractProviderErrorMessage(body);

        if (statusCode == 401)
        {
            return providerLabel + " request failed (401 Unauthorized): credential is invalid or expired." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 403)
        {
            return providerLabel + " request failed (403 Forbidden): configured account/token lacks access to this model or provider resource." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 404)
        {
            return providerLabel + " request failed (404 Not Found): endpoint or model may be incorrect." + AppendProviderMessage(providerMessage);
        }

        if (statusCode == 429)
        {
            return providerLabel + " request failed (429 Too Many Requests): rate limit reached." + AppendProviderMessage(providerMessage);
        }

        if (statusCode >= 500)
        {
            return providerLabel + " request failed (" + statusCode + "): provider service error." + AppendProviderMessage(providerMessage);
        }

        return providerLabel + " request failed (" + statusCode + ")." + AppendProviderMessage(providerMessage);
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

    private static string BuildFallbackSummary(string issueId, string submittedDate, string title, string status, string sysdebug, string contextDetails, int confidence)
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

        string contextSysdebug = FirstContextValue(contextMap, "Sysdebug", "Sysdebug Forum", "Sysdebug Category");
        string debugSnippet = BuildDebugSnippet(FirstNonEmpty(sysdebug, contextSysdebug));
        string interpretedDebug = BuildSysdebugInterpretation(debugSnippet, component, operatingSystem, reproducibility, impact, customerImpact);
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
        AddUniqueBullet(storyBullets, BuildShortPhrase(issueSituation, 125));

        if (!string.IsNullOrWhiteSpace(debugSnippet) && debugSnippet.IndexOf("No sysdebug details", StringComparison.OrdinalIgnoreCase) < 0)
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase(interpretedDebug, 125));
        }
        else if (activityLines.Count > 0)
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase("Latest HSD activity is the best signal: " + activityLines[0], 125));
        }
        else if (HasPresentValue(fixedVersion))
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase("The likely resolution path is tied to the recorded fix version " + fixedVersion, 125));
        }

        AddUniqueBullet(storyBullets, BuildShortPhrase("Current disposition: " + outcomeNarrative, 125));

        string evidenceNarrative = BuildEvidenceNarrative(component, operatingSystem, cmfRequest, priority, customerImpact, reproducibility, impact, promotedId, promotedIssueStatus, promotedIssueClosedReason, promotedIssueFixedVersion);
        if (!string.IsNullOrWhiteSpace(evidenceNarrative))
        {
            AddUniqueBullet(storyBullets, BuildShortPhrase(evidenceNarrative, 115));
        }

        if (storyBullets.Count == 0)
        {
            AddUniqueBullet(storyBullets, "Latest ticket context is being reviewed from the available HSD and portal fields.");
        }

        string issueSummary = BuildDecisionIssueSummary(safeStatus, closedReason, fixedVersion, issueSituation, activityLines);
        string riskAssessment = BuildDecisionRiskAssessment(highRisk, safeStatus, customerImpact, reproducibility, closedReason, fixedVersion, activityLines);
        string escalationWarning = BuildDecisionEscalationWarning(safeStatus, activityLines, customerImpact, closedReason, fixedVersion);
        string decisionImpact = BuildDecisionImpact(safeStatus, closedReason, fixedVersion, highRisk, activityLines);

        StringBuilder builder = new StringBuilder();
        builder.AppendLine("**AI summary (Confidence: " + confidence.ToString() + "%)**");
        builder.AppendLine();
        builder.AppendLine("**Issue Summary**");
        builder.AppendLine("- " + issueSummary);
        builder.AppendLine();
        builder.AppendLine("**Risk Assessment**");
        builder.AppendLine("- " + riskAssessment);
        builder.AppendLine();
        builder.AppendLine("**Next Action**");
        builder.AppendLine("- " + BuildCompactFollowUpAction(nextAction, drivers, fixedVersion, closedReason));
        builder.AppendLine();
        builder.AppendLine("**Escalation Warning**");
        builder.AppendLine("- " + escalationWarning);
        builder.AppendLine();
        builder.AppendLine("**Decision Impact**");
        builder.Append("- " + decisionImpact);
        return builder.ToString();
    }

    private static string BuildDecisionIssueSummary(string status, string closedReason, string fixedVersion, string issueSituation, List<string> activityLines)
    {
        if (HasPresentValue(fixedVersion) && HasPresentValue(closedReason))
        {
            return "Root cause/fix evidence is recorded, fix version " + fixedVersion + " is available, and closure reason is " + closedReason.Replace("_", " ") + ".";
        }

        if (HasPresentValue(fixedVersion))
        {
            return "Fix version " + BuildDisplayValue(fixedVersion) + " is recorded; the issue should stay in validation until pass evidence is confirmed.";
        }

        if (ContainsAnyToken(status, "closed", "complete", "verified", "implemented"))
        {
            return "Issue is in " + BuildDisplayValue(status) + " state with closure or validation evidence available in the ticket.";
        }

        if (activityLines != null && activityLines.Count > 0)
        {
            return BuildShortPhrase("Active debug is documented; latest signal is " + activityLines[0], 150) + ".";
        }

        return BuildShortPhrase(issueSituation, 150) + ".";
    }

    private static string BuildDecisionRiskAssessment(bool highRisk, string status, string customerImpact, string reproducibility, string closedReason, string fixedVersion, List<string> activityLines)
    {
        if (HasPresentValue(closedReason) && HasPresentValue(fixedVersion))
        {
            return "Low to medium risk because fix and closure evidence exist, but final customer validation should still be checked.";
        }

        if (HasPresentValue(fixedVersion))
        {
            return "Medium risk because a fix is identified, but validation or customer acceptance is not yet shown as complete.";
        }

        if (highRisk)
        {
            return "High risk due to " + BuildDisplayValue(FirstNonEmpty(customerImpact, "elevated customer impact")) + " and reproducibility " + BuildDisplayValue(reproducibility) + ".";
        }

        if (activityLines == null || activityLines.Count == 0)
        {
            return "Medium risk because recent HSD debug activity is not visible in the available data.";
        }

        if (ContainsAnyToken(status, "pending", "open", "debug"))
        {
            return "Medium risk because the issue remains active and needs continued debug or validation evidence.";
        }

        return "Medium risk until owner, validation, and closure criteria are confirmed from the latest HSD evidence.";
    }

    private static string BuildDecisionEscalationWarning(string status, List<string> activityLines, string customerImpact, string closedReason, string fixedVersion)
    {
        if (HasPresentValue(closedReason) && HasPresentValue(fixedVersion))
        {
            return "None; closure and fix evidence are present, pending only confirmation that customer validation is acceptable.";
        }

        if (HasPresentValue(fixedVersion))
        {
            return "None if validation is actively tracking the recorded fix; escalate only if the fix misses the needed milestone.";
        }

        if (activityLines == null || activityLines.Count == 0)
        {
            return "Escalate if no owner/debug update is available for the current review window.";
        }

        if (ContainsAnyToken(customerImpact, "high", "critical", "showstopper") && !ContainsAnyToken(status, "closed", "complete", "verified"))
        {
            return "Customer-impact signal is elevated; escalate if root cause or validation owner is not clearly assigned.";
        }

        return "None from the available data.";
    }

    private static string BuildDecisionImpact(string status, string closedReason, string fixedVersion, bool highRisk, List<string> activityLines)
    {
        if (HasPresentValue(closedReason) && HasPresentValue(fixedVersion))
        {
            return "Continue validation or close after confirming the fix version and customer acceptance evidence.";
        }

        if (HasPresentValue(fixedVersion))
        {
            return "Continue validation on fix version " + BuildDisplayValue(fixedVersion) + " and close only after pass evidence is recorded.";
        }

        if (ContainsAnyToken(status, "closed", "complete", "verified"))
        {
            return "Close or monitor unless new evidence contradicts the recorded disposition.";
        }

        if (highRisk)
        {
            return "Escalate or continue validation before closure because customer-impact risk remains material.";
        }

        if (activityLines != null && activityLines.Count > 0)
        {
            return "Continue debug/validation using the latest HSD update as the decision driver.";
        }

        return "Continue triage until current state, owner, and validation evidence are clear.";
    }

    private static int CalculateSummaryConfidence(string status, string sysdebug, string contextDetails)
    {
        Dictionary<string, string> contextMap = ParseContextDetails(contextDetails);
        int confidence = 38;

        int presentFields = CountPresentContextValues(contextMap,
            "Component", "Operating System", "CMF Request", "Must Fix For", "Customer Impact", "Impact",
            "Priority", "CMF Status", "Promoted Status", "Drivers", "Reproducibility", "RVP Platform Debug Details",
            "Promoted Issue Status", "Promoted Issue Closed Reason", "Promoted Issue Fixed Version");
        confidence += Math.Min(18, presentFields * 2);

        string debugText = FirstNonEmpty(sysdebug, FirstContextValue(contextMap, "Sysdebug", "Sysdebug Forum"));
        if (HasPresentValue(debugText))
        {
            confidence += debugText.Length > 220 ? 12 : (debugText.Length > 80 ? 9 : 5);
        }

        int activityCount = ExtractActivityLines(contextDetails).Count;
        confidence += Math.Min(14, activityCount * 3);

        if (HasPresentValue(FirstContextValue(contextMap, "Closed Reason", "Fixed Version", "Promoted Issue Fixed Version", "Promoted Issue Closed Reason"))) confidence += 8;
        if (HasPresentValue(FirstContextValue(contextMap, "Customer Impact", "Impact"))) confidence += 5;
        if (HasPresentValue(FirstContextValue(contextMap, "Reproducibility"))) confidence += 4;
        if (HasPresentValue(FirstContextValue(contextMap, "RVP Platform Debug Details"))) confidence += 4;
        if (HasPresentValue(FirstContextValue(contextMap, "Promoted Issue Status", "Promoted Status"))) confidence += 4;
        if (ContainsAnyToken(status, "rejected", "closed", "complete", "verified", "implemented")) confidence += 4;

        if (!HasPresentValue(debugText) && activityCount == 0) confidence -= 8;
        if (contextMap.Count == 0) confidence -= 10;

        if (confidence > 94) return 94;
        if (confidence < 35) return 35;
        return confidence;
    }

    private static int CountPresentContextValues(Dictionary<string, string> contextMap, params string[] keys)
    {
        if (contextMap == null || keys == null) return 0;

        int count = 0;
        foreach (string key in keys)
        {
            if (HasPresentValue(FirstContextValue(contextMap, key)))
            {
                count++;
            }
        }

        return count;
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
        string subject = "Current evidence";
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
            return "Available ticket data is limited; use the latest comments and debug notes to confirm the issue state";
        }

        return subject + " shows " + JoinReadableList(context);
    }

    private static string BuildShortPhrase(string text, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string cleaned = text.Replace("\r", " ").Replace("\n", " ").Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"\s+", " ");
        if (cleaned.Length <= maxLength) return cleaned.TrimEnd('.', ';', ':');
        string clipped = cleaned.Substring(0, Math.Max(1, maxLength)).Trim();
        int boundary = Math.Max(clipped.LastIndexOf('.'), Math.Max(clipped.LastIndexOf('!'), clipped.LastIndexOf('?')));
        if (boundary >= 40) return clipped.Substring(0, boundary + 1).Trim();
        return System.Text.RegularExpressions.Regex.Replace(clipped, @"\s+\S*$", string.Empty).TrimEnd('.', ',', ';', ':', '-', ' ') + ".";
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

    // Enrich the provided context details by fetching HSD sighting and promoted article data
    // and appending formatted HSD context (including Sysdebug Forum) when available.
    private static string EnrichContextWithHsdArticles(string issueId, string contextDetails)
    {
        string original = contextDetails ?? string.Empty;
        Dictionary<string, string> contextMap = ParseContextDetails(original);
        StringBuilder sb = new StringBuilder(original);

        try
        {
            // Fetch sighting/article HSD data for the primary issue ID
            if (!string.IsNullOrWhiteSpace(issueId))
            {
                HsdArticleData sighting = HsdPortalService.FetchArticle(issueId);
                if (sighting != null && sighting.FetchSuccess)
                {
                    string formatted = HsdPortalService.FormatForAiContext(sighting, "Sighting " + issueId);
                    if (!string.IsNullOrWhiteSpace(formatted) && original.IndexOf(formatted, StringComparison.OrdinalIgnoreCase) < 0)
                    {
                        sb.AppendLine();
                        sb.AppendLine(formatted);
                    }
                }
            }

            // Look for promoted IDs in the existing context and fetch each promoted article
            string promotedRaw = FirstContextValue(contextMap, "Promoted ID", "Promoted Issue ID", "Promoted IDs", "Promoted Issue IDs", "PromotedID");
            if (!string.IsNullOrWhiteSpace(promotedRaw))
            {
                string[] parts = promotedRaw.Split(new[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string part in parts)
                {
                    string pid = part.Trim();
                    if (string.IsNullOrWhiteSpace(pid)) continue;
                    if (!string.Equals(pid, issueId, StringComparison.OrdinalIgnoreCase))
                    {
                        try
                        {
                            HsdArticleData promoted = HsdPortalService.FetchArticle(pid);
                            if (promoted != null && promoted.FetchSuccess)
                            {
                                string formattedPromoted = HsdPortalService.FormatForAiContext(promoted, "Promoted " + pid);
                                if (!string.IsNullOrWhiteSpace(formattedPromoted) && original.IndexOf(formattedPromoted, StringComparison.OrdinalIgnoreCase) < 0)
                                {
                                    sb.AppendLine();
                                    sb.AppendLine(formattedPromoted);
                                }
                            }
                        }
                        catch
                        {
                            // ignore individual promoted fetch failures
                        }
                    }
                }
            }
        }
        catch
        {
            // best-effort enrichment — swallow any exceptions and return original context
            return original;
        }

        return sb.ToString().Trim();
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
            normalized = TrimToCleanSnippet(normalized, maxLength);
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
            normalized = TrimToCleanSnippet(normalized, maxLength);
        }

        return normalized;
    }

    private static string TrimToCleanSnippet(string text, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        string cleaned = text.Replace("\r", " ").Replace("\n", " ").Trim();
        cleaned = System.Text.RegularExpressions.Regex.Replace(cleaned, @"\s+", " ");
        if (cleaned.Length <= maxLength) return cleaned.TrimEnd('.', ';', ':');
        string clipped = cleaned.Substring(0, Math.Max(1, maxLength)).Trim();
        int boundary = Math.Max(clipped.LastIndexOf('.'), Math.Max(clipped.LastIndexOf('!'), clipped.LastIndexOf('?')));
        if (boundary >= 40) return clipped.Substring(0, boundary + 1).Trim();
        return System.Text.RegularExpressions.Regex.Replace(clipped, @"\s+\S*$", string.Empty).TrimEnd('.', ',', ';', ':', '-', ' ') + ".";
    }

    private static string BuildSysdebugInterpretation(string debugSnippet, string component, string operatingSystem, string reproducibility, string impact, string customerImpact)
    {
        if (!HasPresentValue(debugSnippet) || debugSnippet.IndexOf("No sysdebug details", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return "Sysdebug evidence is sparse, so confidence depends on HSD comments, status, and linked promoted issue context";
        }

        List<string> clues = new List<string>();
        if (HasPresentValue(component)) clues.Add("component " + component.Trim());
        if (HasPresentValue(operatingSystem)) clues.Add("OS " + operatingSystem.Trim());
        if (HasPresentValue(reproducibility)) clues.Add("repro " + reproducibility.Trim());
        if (HasPresentValue(FirstNonEmpty(customerImpact, impact))) clues.Add("impact " + BuildShortPhrase(FirstNonEmpty(customerImpact, impact), 55));

        string evidenceFrame = clues.Count > 0
            ? " against " + JoinReadableList(clues)
            : string.Empty;

        return "Sysdebug points to " + BuildShortPhrase(debugSnippet, 82) + evidenceFrame + ", which is the main technical signal for triage";
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
