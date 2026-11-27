using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Hosting;
using System.Web.Script.Serialization;
using OfficeOpenXml;

public sealed class CmfAssistantUnifiedConfig
{
    public string Version { get; set; }
    public string GnaiEndpoint { get; set; }
    public string GnaiAnthropicEndpoint { get; set; }
    public string GnaiOpenAiEndpoint { get; set; }
    public string GnaiApiKey { get; set; }
    public string PrimaryModel { get; set; }
    public string FastSummaryModel { get; set; }
    public List<string> FallbackModels { get; set; }
    public string GnaiProxy { get; set; }
    public int RequestTimeoutSeconds { get; set; }

    public bool HsdEnabled { get; set; }
    public List<string> HsdProviderOrder { get; set; }
    public string HsdArticleApiBaseUrl { get; set; }
    public int HsdTimeoutSeconds { get; set; }
    public int HsdCacheRefreshSeconds { get; set; }
    public bool SkipCommentEndpointsWhenHistoryPresent { get; set; }

    public string DatabaseConnectionName { get; set; }
    public string DatabaseConnectionString { get; set; }
    public string DatabaseProviderName { get; set; }
    public bool DatabaseFallbackToWebConfig { get; set; }

    public bool FeedbackMemoryEnabled { get; set; }
    public string FeedbackStoragePath { get; set; }
    public int MaxFewShotExamples { get; set; }

    public string PythonExecutable { get; set; }
    public string SyncfusionLicenseKey { get; set; }

    public int ScaleMax { get; set; }
    public string Formula { get; set; }
    public double CmfOkMinScore { get; set; }
    public double CmfReviewMinScore { get; set; }
    public int ThresholdScore { get; set; }
    public int ReviewThresholdScore { get; set; }
    public int CustomerExperienceOverrideScore { get; set; }
    public bool RequireComponentInDescription { get; set; }
    public bool RequireRvpReproInDescription { get; set; }
    public bool RequirePromotedIdInHeader { get; set; }
    public bool RequireRvpReproInReasoning { get; set; }
    public string RvpReproPolicy { get; set; }
    public Dictionary<string, int> DimensionWeights { get; set; }
    public string CompiledRulesText { get; set; }
    public Dictionary<string, string> PermutationLookup { get; set; }

    public Dictionary<string, List<string>> PlatformFamilyJargons { get; set; }
    public Dictionary<string, List<string>> PlatformSkuJargons { get; set; }
    public Dictionary<string, List<string>> ComponentSynonymJargons { get; set; }
}

public static class CmfAssistantConfigService
{
    private static readonly object SyncRoot = new object();
    private static CmfAssistantUnifiedConfig CachedConfig;
    private static DateTime CachedLastWriteUtc = DateTime.MinValue;
    private static string CachedConfigPath;

    public static CmfAssistantUnifiedConfig GetConfig()
    {
        lock (SyncRoot)
        {
            string path = ResolveConfigFilePath();
            DateTime lastWriteUtc = (!string.IsNullOrWhiteSpace(path) && File.Exists(path))
                ? File.GetLastWriteTimeUtc(path)
                : DateTime.MinValue;

            if (CachedConfig != null && string.Equals(CachedConfigPath, path, StringComparison.OrdinalIgnoreCase) && lastWriteUtc == CachedLastWriteUtc)
            {
                return CachedConfig;
            }

            CachedConfig = LoadConfigFromFile(path);
            CachedConfigPath = path;
            CachedLastWriteUtc = lastWriteUtc;
            return CachedConfig;
        }
    }

    public static string ResolveGnaiEndpoint()
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        if (!string.IsNullOrWhiteSpace(cfg.GnaiEndpoint))
        {
            return cfg.GnaiEndpoint.Trim();
        }
        return "https://gnai.intel.com/api/providers/anthropic/v1/messages";
    }

    public static string ResolveGnaiEndpointForModel(string baseEndpoint, string model)
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        if (!string.IsNullOrWhiteSpace(cfg.GnaiAnthropicEndpoint))
        {
            return cfg.GnaiAnthropicEndpoint.Trim();
        }
        if (!string.IsNullOrWhiteSpace(baseEndpoint))
        {
            return baseEndpoint.Trim();
        }
        return ResolveGnaiEndpoint();
    }

    public static bool IsAnthropicMessagesEndpoint(string endpoint, string model)
    {
        if (!string.IsNullOrWhiteSpace(endpoint) && endpoint.IndexOf("/providers/anthropic/", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return true;
        }
        return !string.IsNullOrWhiteSpace(model) && model.Trim().StartsWith("claude-", StringComparison.OrdinalIgnoreCase);
    }

    public static string ResolveGnaiToken()
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        if (!string.IsNullOrWhiteSpace(cfg.GnaiApiKey)
            && !string.Equals(cfg.GnaiApiKey, "FROM_ENV_OR_WEB_CONFIG", StringComparison.OrdinalIgnoreCase)
            && !cfg.GnaiApiKey.StartsWith("REPLACE", StringComparison.OrdinalIgnoreCase))
        {
            return cfg.GnaiApiKey.Trim();
        }
        return string.Empty;
    }

    public static string ResolveDatabaseConnectionString()
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        if (cfg != null
            && !string.IsNullOrWhiteSpace(cfg.DatabaseConnectionString)
            && !string.Equals(cfg.DatabaseConnectionString, "FROM_WEB_CONFIG", StringComparison.OrdinalIgnoreCase)
            && !cfg.DatabaseConnectionString.StartsWith("REPLACE", StringComparison.OrdinalIgnoreCase))
        {
            return cfg.DatabaseConnectionString.Trim();
        }
        return string.Empty;
    }

    public static string ResolvePrimaryModel()
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        if (!string.IsNullOrWhiteSpace(cfg.PrimaryModel)) return cfg.PrimaryModel.Trim();
        return "claude-sonnet-5-5";
    }

    public static string ResolveFastSummaryModel()
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        if (!string.IsNullOrWhiteSpace(cfg.FastSummaryModel)) return cfg.FastSummaryModel.Trim();
        return ResolvePrimaryModel();
    }

    public static List<string> ResolveModelChain(string preferredPrimaryModel)
    {
        CmfAssistantUnifiedConfig cfg = GetConfig();
        List<string> chain = new List<string>();
        string primary = string.IsNullOrWhiteSpace(preferredPrimaryModel) ? ResolvePrimaryModel() : preferredPrimaryModel.Trim();
        chain.Add(primary);

        if (cfg.FallbackModels != null)
        {
            foreach (string candidate in cfg.FallbackModels)
            {
                if (!string.IsNullOrWhiteSpace(candidate)
                    && candidate.Trim().StartsWith("claude-", StringComparison.OrdinalIgnoreCase)
                    && !chain.Exists(m => string.Equals(m, candidate.Trim(), StringComparison.OrdinalIgnoreCase)))
                {
                    chain.Add(candidate.Trim());
                }
            }
        }

        return chain;
    }

    private static string ResolveConfigFilePath()
    {
        try
        {
            string mapped = HostingEnvironment.MapPath("~/App_Data/cmf-assistant-config.json");
            if (!string.IsNullOrWhiteSpace(mapped) && File.Exists(mapped)) return mapped;
        }
        catch { }

        string[] candidates = new[]
        {
            Path.Combine(AppDomain.CurrentDomain.BaseDirectory ?? string.Empty, "App_Data", "cmf-assistant-config.json"),
            Path.Combine(Environment.CurrentDirectory ?? string.Empty, "App_Data", "cmf-assistant-config.json"),
            Path.Combine(Environment.CurrentDirectory ?? string.Empty, "cmf_portal", "App_Data", "cmf-assistant-config.json")
        };

        foreach (string candidate in candidates)
        {
            if (!string.IsNullOrWhiteSpace(candidate) && File.Exists(candidate)) return candidate;
        }
        return candidates[0];
    }

    private static CmfAssistantUnifiedConfig LoadConfigFromFile(string path)
    {
        CmfAssistantUnifiedConfig config = CreateDefaultConfig();
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path)) return config;

        try
        {
            string json = File.ReadAllText(path, Encoding.UTF8);
            JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
            IDictionary root = serializer.DeserializeObject(json) as IDictionary;
            if (root == null) return config;

            config.Version = ReadString(root, "version", config.Version);

            IDictionary gnai = root["gnai"] as IDictionary;
            if (gnai != null)
            {
                config.GnaiEndpoint = ReadString(gnai, "endpoint", config.GnaiEndpoint);
                config.GnaiAnthropicEndpoint = ReadString(gnai, "anthropicEndpoint", config.GnaiAnthropicEndpoint);
                config.PrimaryModel = ReadString(gnai, "primaryModel", config.PrimaryModel);
                config.FastSummaryModel = ReadString(gnai, "fastSummaryModel", config.FastSummaryModel);
                List<string> fallbackModels = ReadStringList(gnai, "fallbackModels");
                if (fallbackModels.Count > 0) config.FallbackModels = fallbackModels;
            }

            IDictionary hsd = root["hsd"] as IDictionary;
            if (hsd != null)
            {
                config.HsdEnabled = ReadBool(hsd, "enabled", config.HsdEnabled);
                config.HsdArticleApiBaseUrl = ReadString(hsd, "articleApiBaseUrl", config.HsdArticleApiBaseUrl);
                config.HsdTimeoutSeconds = ReadInt(hsd, "timeoutSeconds", config.HsdTimeoutSeconds);
                config.HsdCacheRefreshSeconds = ReadInt(hsd, "cacheRefreshSeconds", config.HsdCacheRefreshSeconds);
                config.SkipCommentEndpointsWhenHistoryPresent = ReadBool(hsd, "skipCommentEndpointsWhenHistoryPresent", config.SkipCommentEndpointsWhenHistoryPresent);
                List<string> providers = ReadStringList(hsd, "providerOrder");
                if (providers.Count > 0) config.HsdProviderOrder = providers;
            }

            IDictionary reports = root["reports"] as IDictionary;
            if (reports != null)
            {
                config.PythonExecutable = ReadString(reports, "pythonExecutable", config.PythonExecutable);
            }

            IDictionary ui = root["ui"] as IDictionary;
            if (ui != null)
            {
                config.SyncfusionLicenseKey = ReadString(ui, "syncfusionLicenseKey", config.SyncfusionLicenseKey);
            }

            IDictionary plugins = root["plugins"] as IDictionary;
            if (plugins != null)
            {
                IDictionary feedback = plugins["feedbackMemory"] as IDictionary;
                if (feedback != null)
                {
                    config.FeedbackMemoryEnabled = ReadBool(feedback, "enabled", config.FeedbackMemoryEnabled);
                    config.FeedbackStoragePath = ReadString(feedback, "storagePath", config.FeedbackStoragePath);
                    config.MaxFewShotExamples = ReadInt(feedback, "maxFewShotExamples", config.MaxFewShotExamples);
                }
            }

            IDictionary scoring = root["scoringRules"] as IDictionary;
            if (scoring != null)
            {
                config.ScaleMax = ReadInt(scoring, "scaleMax", config.ScaleMax);
                config.Formula = ReadString(scoring, "formula", config.Formula);
                config.CmfOkMinScore = ReadDouble(scoring, "cmfOkMinScore", config.CmfOkMinScore);
                config.CmfReviewMinScore = ReadDouble(scoring, "cmfReviewMinScore", config.CmfReviewMinScore);
                config.ThresholdScore = ReadInt(scoring, "thresholdScore", config.ThresholdScore);
                config.ReviewThresholdScore = ReadInt(scoring, "reviewThresholdScore", config.ReviewThresholdScore);
                config.CustomerExperienceOverrideScore = ReadInt(scoring, "customerExperienceOverrideScore", 0);

                IDictionary mandatory = scoring["mandatoryRequirements"] as IDictionary;
                if (mandatory != null)
                {
                    config.RequireComponentInDescription = ReadBool(mandatory, "requireComponentInDescription", config.RequireComponentInDescription);
                    config.RequireRvpReproInDescription = ReadBool(mandatory, "requireRvpReproInDescription", config.RequireRvpReproInDescription);
                    config.RequirePromotedIdInHeader = ReadBool(mandatory, "requirePromotedIdInHeader", config.RequirePromotedIdInHeader);
                    config.RequireRvpReproInReasoning = ReadBool(mandatory, "requireRvpReproInReasoning", config.RequireRvpReproInReasoning);
                    config.RvpReproPolicy = ReadString(mandatory, "rvpReproPolicy", config.RvpReproPolicy);
                }

                IList dimensions = scoring["dimensions"] as IList;
                if (dimensions != null && dimensions.Count > 0)
                {
                    StringBuilder rulesBuilder = new StringBuilder();
                    rulesBuilder.AppendLine("scale_max: " + config.ScaleMax);
                    rulesBuilder.AppendLine("formula: " + config.Formula);
                    rulesBuilder.AppendLine("cmf_ok_min_score: " + config.CmfOkMinScore.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture));
                    rulesBuilder.AppendLine("cmf_review_min_score: " + config.CmfReviewMinScore.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture));
                    rulesBuilder.AppendLine("threshold_for_cmf_tag: " + config.ThresholdScore);
                    rulesBuilder.AppendLine("review_threshold: " + config.ReviewThresholdScore);
                    if (config.CustomerExperienceOverrideScore > 0 && config.DimensionWeights != null && config.DimensionWeights.ContainsKey("CX"))
                    {
                        rulesBuilder.AppendLine("customer_experience_override: " + config.CustomerExperienceOverrideScore);
                    }
                    if (!string.IsNullOrWhiteSpace(config.RvpReproPolicy))
                    {
                        rulesBuilder.AppendLine("rvp_repro_policy: " + config.RvpReproPolicy);
                    }
                    rulesBuilder.AppendLine("scoring_dimensions (1 to " + config.ScaleMax + " scale):");
                    foreach (object item in dimensions)
                    {
                        IDictionary dim = item as IDictionary;
                        if (dim == null) continue;
                        string id = ReadString(dim, "id", string.Empty);
                        string name = ReadString(dim, "name", string.Empty);
                        int weight = ReadInt(dim, "weight", 15);
                        string rubric = ReadString(dim, "rubric", string.Empty);
                        if (!string.IsNullOrWhiteSpace(id))
                        {
                            config.DimensionWeights[id.ToUpperInvariant()] = weight;
                            rulesBuilder.AppendLine("  " + id + " | " + name + " | Weight " + weight + " | " + rubric);
                        }
                    }

                    IList dispositions = scoring["dispositionTable"] as IList;
                    if (dispositions != null && dispositions.Count > 0)
                    {
                        rulesBuilder.AppendLine("cmf_disposition_table:");
                        foreach (object item in dispositions)
                        {
                            IDictionary disp = item as IDictionary;
                            if (disp == null) continue;
                            rulesBuilder.AppendFormat(
                                "  {0} ({1}): Score {2} | Min Conditions: {3} | Meaning: {4} | Action: {5}\n",
                                ReadString(disp, "disposition", string.Empty),
                                ReadString(disp, "output", string.Empty),
                                ReadString(disp, "scoreBand", string.Empty),
                                ReadString(disp, "minimumConditions", string.Empty),
                                ReadString(disp, "meaning", string.Empty),
                                ReadString(disp, "requiredAction", string.Empty));
                        }
                    }

                    IList guardrails = scoring["gatingGuardrails"] as IList;
                    if (guardrails != null && guardrails.Count > 0)
                    {
                        rulesBuilder.AppendLine("gating_guardrails:");
                        foreach (object item in guardrails)
                        {
                            IDictionary gr = item as IDictionary;
                            if (gr == null) continue;
                            rulesBuilder.AppendFormat(
                                "  - {0}: {1} ({2})\n",
                                ReadString(gr, "name", string.Empty),
                                ReadString(gr, "rule", string.Empty),
                                ReadString(gr, "rationale", string.Empty));
                        }
                    }

                    IList perms = scoring["permutationAnalysis"] as IList;
                    if (perms != null && perms.Count > 0)
                    {
                        var lookup = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                        foreach (object item in perms)
                        {
                            IDictionary p = item as IDictionary;
                            if (p == null) continue;
                            int s = ReadInt(p, "s", 0);
                            int o = ReadInt(p, "o", 0);
                            int d = ReadInt(p, "d", 0);
                            int b = ReadInt(p, "b", 0);
                            int rvp = ReadInt(p, "rvpScore", 0);
                            string rec = ReadString(p, "recommendation", string.Empty);
                            if (s > 0 && o > 0 && d > 0 && b > 0 && rvp > 0 && !string.IsNullOrWhiteSpace(rec))
                            {
                                lookup[string.Format(CultureInfo.InvariantCulture, "{0}_{1}_{2}_{3}_{4}", s, o, d, b, rvp)] = rec;
                            }
                        }
                        if (lookup.Count > 0) config.PermutationLookup = lookup;
                    }

                    config.CompiledRulesText = rulesBuilder.ToString().Trim();
                }
            }

            IDictionary jargons = root["jargonMappings"] as IDictionary;
            if (jargons != null)
            {
                Dictionary<string, List<string>> famMap = ReadDictionaryOfStringLists(jargons["platformFamilies"] as IDictionary);
                if (famMap.Count > 0) config.PlatformFamilyJargons = famMap;

                Dictionary<string, List<string>> skuMap = ReadDictionaryOfStringLists(jargons["platformSkus"] as IDictionary);
                if (skuMap.Count > 0) config.PlatformSkuJargons = skuMap;

                Dictionary<string, List<string>> compMap = ReadDictionaryOfStringLists(jargons["componentSynonyms"] as IDictionary);
                if (compMap.Count > 0) config.ComponentSynonymJargons = compMap;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.TraceWarning("CmfAssistantConfigService load error: {0}", ex.Message);
        }

        return config;
    }

    private static CmfAssistantUnifiedConfig CreateDefaultConfig()
    {
        var config = new CmfAssistantUnifiedConfig
        {
            Version = "1.0",
            GnaiEndpoint = "https://gnai.intel.com/api/providers/anthropic/v1/messages",
            GnaiAnthropicEndpoint = "https://gnai.intel.com/api/providers/anthropic/v1/messages",
            GnaiOpenAiEndpoint = string.Empty,
            GnaiApiKey = "REPLACE_WITH_GNAI_TOKEN",
            PrimaryModel = "claude-4-5-sonnet",
            FastSummaryModel = "claude-4-5-haiku",
            FallbackModels = new List<string> { "claude-4-5-haiku" },
            GnaiProxy = string.Empty,
            RequestTimeoutSeconds = 30,
            HsdEnabled = true,
            HsdProviderOrder = new List<string> { "rest", "gnai" },
            HsdArticleApiBaseUrl = "https://hsdes-api.intel.com/rest/article",
            HsdTimeoutSeconds = 12,
            HsdCacheRefreshSeconds = 120,
            SkipCommentEndpointsWhenHistoryPresent = true,
            DatabaseConnectionName = "gfxitt",
            DatabaseConnectionString = "REPLACE_WITH_SQL_CONNECTION_STRING",
            DatabaseProviderName = "System.Data.SqlClient",
            DatabaseFallbackToWebConfig = false,
            FeedbackMemoryEnabled = true,
            FeedbackStoragePath = "~/App_Data/cmf-feedback-memory.json",
            MaxFewShotExamples = 4,
            PythonExecutable = "python",
            SyncfusionLicenseKey = string.Empty,
            ScaleMax = 4,
            Formula = "Overall Score = (S * 0.30) + (O * 0.15) + (D * 0.10) + (B * 0.30) + (RVP * 0.15)",
            CmfOkMinScore = 3.50,
            CmfReviewMinScore = 2.75,
            ThresholdScore = 88,
            ReviewThresholdScore = 69,
            CustomerExperienceOverrideScore = 0,
            RequireComponentInDescription = true,
            RequireRvpReproInDescription = true,
            RequirePromotedIdInHeader = true,
            RequireRvpReproInReasoning = true,
            RvpReproPolicy = "1) When RVP_repro is Yes: the issue reproduces on the Intel Reference Validation Platform (RVP), meaning there is a high likelihood the defect appears across most OEM customer units designed on that RVP platform (critical platform-wide impact) -- RVP is scored 4/4 (contributing 0.60 to the weighted score) and satisfies Priority 1 qualification [S>=3 AND (B>=3 OR RVP=Yes)]; explicitly highlight 'also reproduced on RVP' in the CMF reasoning and recommendation justification. 2) When RVP_repro is Unknown, Blank, NA, or Pending: score RVP as 2/4 (neutral score contributing 0.30); RVP exposure is not established. 3) When RVP_repro is No: score RVP as 1/4 (contributing 0.15 to the weighted score), reflecting that the defect did not reproduce on RVP and is isolated to customer units; state in the reasoning that RVP repro is No (isolated to customer unit / not reproduced on RVP).",
            DimensionWeights = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
            {
                { "S", 30 }, { "O", 15 }, { "D", 10 }, { "B", 30 }, { "RVP", 15 }
            },
            CompiledRulesText = string.Empty,
            PermutationLookup = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase),
            PlatformFamilyJargons = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase)
            {
                { "NVL", new List<string> { "novalake", "nova lake", "nvl" } },
                { "PTL", new List<string> { "pantherlake", "panther lake", "ptl" } },
                { "LNL", new List<string> { "lunarlake", "lunar lake", "lnl" } },
                { "ARL", new List<string> { "arrowlake", "arrow lake", "arl" } },
                { "WCL", new List<string> { "wildcatlake", "wildcat lake", "wcl" } },
                { "GNR", new List<string> { "graniterapids", "granite rapids", "gnr" } }
            },
            PlatformSkuJargons = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase)
            {
                { "NVL-H", new List<string> { "novalake-h", "novalake h", "nova lake-h", "nova lake h", "nvl-h", "nvl h", "nvl_h" } },
                { "NVL-S", new List<string> { "novalake-s", "novalake s", "nova lake-s", "nova lake s", "nvl-s", "nvl s", "nvl_s" } },
                { "NVL-Hx", new List<string> { "novalake-hx", "novalake hx", "nova lake-hx", "nova lake hx", "nvl-hx", "nvl hx", "nvl_hx" } },
                { "NVL-U", new List<string> { "novalake-u", "novalake u", "nova lake-u", "nova lake u", "nvl-u", "nvl u", "nvl_u" } }
            },
            ComponentSynonymJargons = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase)
            {
                { "iGFX (Graphics)", new List<string> { "graphics", "igfx", "display", "gfx", "igpu", "media" } },
                { "Audio", new List<string> { "audio", "sound", "speaker", "microphone", "mic", "voice" } },
                { "TBT", new List<string> { "thunderbolt", "tbt", "usb4", "type-c", "usb-c", "usbc" } },
                { "BIOS", new List<string> { "bios", "ifwi", "firmware", "uefi" } },
                { "CSME", new List<string> { "csme", "cse", "manageability" } },
                { "PnP", new List<string> { "pnp", "power", "battery", "modern standby", "s0ix" } },
                { "DTT", new List<string> { "dtt", "thermal", "temperature" } }
            }
        };

        var settings = new Hashtable(StringComparer.OrdinalIgnoreCase);
        foreach (string key in ConfigurationManager.AppSettings.AllKeys)
        {
            settings[key] = ConfigurationManager.AppSettings[key];
        }
        ApplyPortalInfrastructureSettings(config, settings, ConfigurationManager.ConnectionStrings);
        return config;
    }

    private static void ApplyPortalInfrastructureSettings(CmfAssistantUnifiedConfig config, IDictionary settings, ConnectionStringSettingsCollection connections)
    {
        config.GnaiApiKey = ReadString(settings, "GNAI:ApiKey", config.GnaiApiKey);
        config.GnaiOpenAiEndpoint = ReadString(settings, "GNAI:OpenAiEndpoint", config.GnaiOpenAiEndpoint);
        config.GnaiProxy = ReadString(settings, "GNAI:Proxy", config.GnaiProxy);
        config.RequestTimeoutSeconds = ReadInt(settings, "GNAI:RequestTimeoutSeconds", config.RequestTimeoutSeconds);

        config.DatabaseConnectionName = ReadString(settings, "Database:ConnectionName", config.DatabaseConnectionName);
        ConnectionStringSettings connection = connections[config.DatabaseConnectionName];
        if (connection != null)
        {
            config.DatabaseConnectionString = connection.ConnectionString;
            if (!string.IsNullOrWhiteSpace(connection.ProviderName)) config.DatabaseProviderName = connection.ProviderName;
        }
    }

    private static Dictionary<string, List<string>> ReadDictionaryOfStringLists(IDictionary dict)
    {
        Dictionary<string, List<string>> result = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
        if (dict == null) return result;
        foreach (DictionaryEntry entry in dict)
        {
            if (entry.Key == null) continue;
            string key = entry.Key.ToString().Trim();
            if (string.IsNullOrWhiteSpace(key)) continue;
            IList rawList = entry.Value as IList;
            if (rawList == null) continue;
            List<string> values = new List<string>();
            foreach (object item in rawList)
            {
                if (item != null && !string.IsNullOrWhiteSpace(item.ToString()))
                {
                    values.Add(item.ToString().Trim());
                }
            }
            if (values.Count > 0) result[key] = values;
        }
        return result;
    }

    private static string ReadString(IDictionary dict, string key, string fallback)
    {
        if (dict == null || !dict.Contains(key) || dict[key] == null) return fallback;
        string val = dict[key].ToString().Trim();
        return string.IsNullOrWhiteSpace(val) ? fallback : val;
    }

    private static int ReadInt(IDictionary dict, string key, int fallback)
    {
        if (dict == null || !dict.Contains(key) || dict[key] == null) return fallback;
        int parsed;
        return int.TryParse(dict[key].ToString().Trim(), out parsed) ? parsed : fallback;
    }

    private static double ReadDouble(IDictionary dict, string key, double fallback)
    {
        if (dict == null || !dict.Contains(key) || dict[key] == null) return fallback;
        double parsed;
        return double.TryParse(dict[key].ToString().Trim(), System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out parsed) ? parsed : fallback;
    }

    private static bool ReadBool(IDictionary dict, string key, bool fallback)
    {
        if (dict == null || !dict.Contains(key) || dict[key] == null) return fallback;
        bool parsed;
        return bool.TryParse(dict[key].ToString().Trim(), out parsed) ? parsed : fallback;
    }

    private static List<string> ReadStringList(IDictionary dict, string key)
    {
        List<string> list = new List<string>();
        if (dict == null || !dict.Contains(key)) return list;
        IList raw = dict[key] as IList;
        if (raw == null) return list;
        foreach (object item in raw)
        {
            if (item != null && !string.IsNullOrWhiteSpace(item.ToString()))
            {
                list.Add(item.ToString().Trim());
            }
        }
        return list;
    }

    public static bool TryAutoLearnJargonFromText(string text, out string category, out string targetCode, out string aliasTerm)
    {
        category = string.Empty;
        targetCode = string.Empty;
        aliasTerm = string.Empty;
        if (string.IsNullOrWhiteSpace(text)) return false;

        // Patterns such as: "map soundwire to Audio", "MTL means Meteor Lake", "treat display engine as iGFX (Graphics)"
        Match m = Regex.Match(
            text.Trim(),
            @"(?:map|treat|alias|jargon|synonym)?\s*[""']?(?<left>[A-Za-z0-9 _/-]{2,32})[""']?\s+(?:means|stands\s+for|maps\s+to|is\s+alias\s+for|->|=|\bis\b|\bto\b|\bas\b)\s+[""']?(?<right>[A-Za-z0-9 ()_/-]{2,32})[""']?",
            RegexOptions.IgnoreCase);
        if (!m.Success) return false;

        string left = m.Groups["left"].Value.Trim();
        string right = m.Groups["right"].Value.Trim();
        if (string.IsNullOrWhiteSpace(left) || string.IsNullOrWhiteSpace(right) || string.Equals(left, right, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        CmfAssistantUnifiedConfig cfg = GetConfig();
        string candidateTarget = right;
        string candidateAlias = left;

        // If left is a short code (2-6 chars like MTL, RPL, NVL-P) and right is a longer name ("Meteor Lake"), left is the target code
        if (left.Length <= 6 && right.Length > left.Length && !IsKnownComponentTarget(right, cfg))
        {
            candidateTarget = left.ToUpperInvariant();
            candidateAlias = right.ToLowerInvariant();
        }
        else if (IsKnownComponentTarget(right, cfg))
        {
            candidateTarget = ResolveCanonicalComponentTarget(right, cfg);
            candidateAlias = left.ToLowerInvariant();
            category = "componentSynonyms";
        }
        else if (IsKnownComponentTarget(left, cfg))
        {
            candidateTarget = ResolveCanonicalComponentTarget(left, cfg);
            candidateAlias = right.ToLowerInvariant();
            category = "componentSynonyms";
        }

        if (string.IsNullOrWhiteSpace(category))
        {
            category = candidateTarget.Contains("-") ? "platformSkus" : "platformFamilies";
        }

        targetCode = candidateTarget;
        aliasTerm = candidateAlias;
        string statusMsg;
        return RegisterLearnedJargonSynonym(category, targetCode, aliasTerm, out statusMsg);
    }

    private static bool IsKnownComponentTarget(string val, CmfAssistantUnifiedConfig cfg)
    {
        if (string.IsNullOrWhiteSpace(val)) return false;
        string v = val.Trim();
        if (Regex.IsMatch(v, @"^(?:iGFX|Graphics|Audio|TBT|BIOS|CSME|PnP|DTT)$", RegexOptions.IgnoreCase)) return true;
        if (cfg != null && cfg.ComponentSynonymJargons != null && cfg.ComponentSynonymJargons.ContainsKey(v)) return true;
        return false;
    }

    private static string ResolveCanonicalComponentTarget(string val, CmfAssistantUnifiedConfig cfg)
    {
        string v = (val ?? string.Empty).Trim();
        if (Regex.IsMatch(v, @"^(?:igfx|graphics)$", RegexOptions.IgnoreCase)) return "iGFX (Graphics)";
        if (cfg != null && cfg.ComponentSynonymJargons != null)
        {
            foreach (string key in cfg.ComponentSynonymJargons.Keys)
            {
                if (string.Equals(key, v, StringComparison.OrdinalIgnoreCase)) return key;
            }
        }
        return v;
    }

    public static bool RegisterLearnedJargonSynonym(string category, string canonicalTarget, string synonym, out string message)
    {
        message = string.Empty;
        string cleanCat = string.IsNullOrWhiteSpace(category) ? "platformFamilies" : category.Trim();
        string cleanTarget = (canonicalTarget ?? string.Empty).Trim();
        string cleanSynonym = (synonym ?? string.Empty).Trim().ToLowerInvariant();

        if (string.IsNullOrWhiteSpace(cleanTarget) || string.IsNullOrWhiteSpace(cleanSynonym))
        {
            message = "Both target code/component and synonym are required.";
            return false;
        }

        if (!string.Equals(cleanCat, "platformFamilies", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(cleanCat, "platformSkus", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(cleanCat, "componentSynonyms", StringComparison.OrdinalIgnoreCase))
        {
            cleanCat = cleanTarget.Contains("-") ? "platformSkus" : "platformFamilies";
        }

        lock (SyncRoot)
        {
            try
            {
                string path = ResolveConfigFilePath();
                if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
                {
                    message = "Config file not found.";
                    return false;
                }

                JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                IDictionary root = serializer.DeserializeObject(File.ReadAllText(path, Encoding.UTF8)) as IDictionary;
                if (root == null)
                {
                    message = "Unable to parse config JSON.";
                    return false;
                }

                IDictionary jargons = root["jargonMappings"] as IDictionary;
                if (jargons == null)
                {
                    jargons = new Dictionary<string, object>();
                    root["jargonMappings"] = jargons;
                }

                IDictionary subMap = jargons[cleanCat] as IDictionary;
                if (subMap == null)
                {
                    subMap = new Dictionary<string, object>();
                    jargons[cleanCat] = subMap;
                }

                List<string> list = ReadStringList(subMap, cleanTarget);
                bool exists = false;
                foreach (string s in list)
                {
                    if (string.Equals(s, cleanSynonym, StringComparison.OrdinalIgnoreCase)) { exists = true; break; }
                }
                if (!exists)
                {
                    list.Add(cleanSynonym);
                }
                subMap[cleanTarget] = list.ToArray();

                File.WriteAllText(path, FormatPrettyJson(serializer.Serialize(root)), Encoding.UTF8);
                CachedConfig = null;
                CachedLastWriteUtc = DateTime.MinValue;
                message = "Saved jargon mapping: '" + cleanSynonym + "' -> '" + cleanTarget + "' (" + cleanCat + ").";
                return true;
            }
            catch (Exception ex)
            {
                message = "Failed to save jargon mapping: " + ex.Message;
                return false;
            }
        }
    }

    public static bool ImportScoringGuidelinesFromExcel(Stream excelStream, out string statusMessage)
    {
        statusMessage = string.Empty;
        if (excelStream == null)
        {
            statusMessage = "No Excel file stream provided.";
            return false;
        }

        lock (SyncRoot)
        {
            try
            {
                using (ExcelPackage pkg = new ExcelPackage(excelStream))
                {
                    if (pkg.Workbook == null || pkg.Workbook.Worksheets == null || pkg.Workbook.Worksheets.Count == 0)
                    {
                        statusMessage = "The uploaded Excel workbook contains no worksheets.";
                        return false;
                    }

                    // Content-based sheet discovery (works with ANY worksheet tab names)
                    ExcelWorksheet rubricSheet = FindRubricWorksheet(pkg.Workbook);
                    ExcelWorksheet standalonePermSheet = FindPermutationWorksheet(pkg.Workbook, rubricSheet);
                    if (rubricSheet == null && standalonePermSheet != null)
                    {
                        List<Dictionary<string, object>> standalonePermList = ParsePermutationSheet(standalonePermSheet);
                        if (standalonePermList.Count > 0)
                        {
                            string permConfigPath = ResolveConfigFilePath();
                            JavaScriptSerializer permSerializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                            IDictionary permRoot = (File.Exists(permConfigPath) ? permSerializer.DeserializeObject(File.ReadAllText(permConfigPath, Encoding.UTF8)) as IDictionary : null)
                                ?? new Dictionary<string, object>();
                            IDictionary permScoringNode = permRoot["scoringRules"] as IDictionary ?? new Dictionary<string, object>();
                            permScoringNode["permutationAnalysis"] = standalonePermList.ToArray();
                            permRoot["scoringRules"] = permScoringNode;

                            File.WriteAllText(permConfigPath, FormatPrettyJson(permSerializer.Serialize(permRoot)), Encoding.UTF8);
                            CachedConfig = null;
                            CachedLastWriteUtc = DateTime.MinValue;
                            CmfRecommendationService.ClearRecommendationCache();

                            statusMessage = string.Format(
                                "Successfully imported {0} permutation analysis combinations into cmf-assistant-config.json.",
                                standalonePermList.Count);
                            return true;
                        }
                    }

                    // 1. Locate rubric sheet dynamically by content (fallback to first worksheet if needed)
                    if (rubricSheet == null) rubricSheet = pkg.Workbook.Worksheets[1];

                    // 2. Discover header row and dimensions dynamically
                    int headerRow = -1;
                    int endRow = rubricSheet.Dimension != null ? rubricSheet.Dimension.End.Row : 0;
                    int endCol = rubricSheet.Dimension != null ? rubricSheet.Dimension.End.Column : 0;

                    for (int r = 1; r <= Math.Min(endRow, 10); r++)
                    {
                        for (int c = 1; c <= endCol; c++)
                        {
                            string txt = (rubricSheet.Cells[r, c].Text ?? string.Empty).Trim();
                            if (txt.IndexOf("Severity", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                headerRow = r;
                                break;
                            }
                        }
                        if (headerRow > 0) break;
                    }
                    if (headerRow <= 0) headerRow = 2;

                    var discoveredDims = new List<ExcelDimensionDef>();
                    for (int c = 2; c <= endCol; c++)
                    {
                        string hText = (rubricSheet.Cells[headerRow, c].Text ?? string.Empty).Trim();
                        if (string.IsNullOrWhiteSpace(hText)) continue;

                        string id = string.Empty;
                        Match m = Regex.Match(hText, @"\(([A-Za-z0-9_-]+)\)");
                        if (m.Success)
                        {
                            id = m.Groups[1].Value.ToUpperInvariant();
                        }
                        else
                        {
                            if (hText.IndexOf("Severity", StringComparison.OrdinalIgnoreCase) >= 0) id = "S";
                            else if (hText.IndexOf("Occurrence", StringComparison.OrdinalIgnoreCase) >= 0) id = "O";
                            else if (hText.IndexOf("Detection", StringComparison.OrdinalIgnoreCase) >= 0 || hText.IndexOf("Trigger", StringComparison.OrdinalIgnoreCase) >= 0) id = "D";
                            else if (hText.IndexOf("Recovery", StringComparison.OrdinalIgnoreCase) >= 0 || hText.IndexOf("Workaround", StringComparison.OrdinalIgnoreCase) >= 0) id = "R";
                            else if (hText.IndexOf("Business", StringComparison.OrdinalIgnoreCase) >= 0) id = "B";
                            else if (hText.IndexOf("Customer", StringComparison.OrdinalIgnoreCase) >= 0) id = "CX";
                            else if (hText.IndexOf("RVP", StringComparison.OrdinalIgnoreCase) >= 0) id = "RVP";
                            else id = Regex.Replace(hText, @"[^A-Za-z0-9]", string.Empty).ToUpperInvariant();
                        }

                        if (string.IsNullOrWhiteSpace(id)) continue;

                        string name = Regex.Replace(hText, @"\s*\([^)]*\)", string.Empty).Trim();
                        if (string.IsNullOrWhiteSpace(name))
                        {
                            if (id == "S") name = "Severity";
                            else if (id == "O") name = "Occurrence";
                            else if (id == "D") name = "Detection";
                            else if (id == "R") name = "Recovery";
                            else if (id == "B") name = "Business Impact";
                            else if (id == "CX") name = "Customer Experience";
                            else if (id == "RVP") name = "RVP Repro Status";
                            else name = id;
                        }

                        discoveredDims.Add(new ExcelDimensionDef
                        {
                            Id = id,
                            Name = name,
                            Column = c,
                            Weight = 15
                        });
                    }

                    // Fallback to standard 6 dimensions if discovery found nothing
                    if (discoveredDims.Count == 0)
                    {
                        string[] dimIds = new[] { "S", "O", "D", "R", "B", "CX" };
                        string[] dimNames = new[] { "Severity", "Occurrence", "Detection", "Recovery", "Business Impact", "Customer Experience" };
                        int[] dimCols = new[] { 2, 3, 4, 5, 6, 7 };
                        int[] defWeights = new[] { 20, 15, 15, 10, 20, 20 };
                        for (int i = 0; i < dimIds.Length; i++)
                        {
                            discoveredDims.Add(new ExcelDimensionDef
                            {
                                Id = dimIds[i],
                                Name = dimNames[i],
                                Column = dimCols[i],
                                Weight = defWeights[i]
                            });
                        }
                    }

                    // 3. Bounded rubric parsing & weight/formula detection
                    int maxScoreFound = 4;
                    string currentScoreLabel = string.Empty;
                    string formulaStr = string.Empty;
                    int rubricStopRow = endRow + 1;

                    for (int r = headerRow + 1; r <= endRow; r++)
                    {
                        string c1 = (rubricSheet.Cells[r, 1].Text ?? string.Empty).Trim();

                        if (c1.StartsWith("Weight", StringComparison.OrdinalIgnoreCase))
                        {
                            currentScoreLabel = string.Empty;
                            rubricStopRow = Math.Min(rubricStopRow, r);
                            foreach (var dim in discoveredDims)
                            {
                                string wText = (rubricSheet.Cells[r, dim.Column].Text ?? string.Empty).Replace("%", string.Empty).Trim();
                                double dVal;
                                if (double.TryParse(wText, NumberStyles.Float, CultureInfo.InvariantCulture, out dVal) && dVal > 0)
                                {
                                    dim.Weight = dVal <= 1.0 ? (int)Math.Round(dVal * 100.0) : (int)Math.Round(dVal);
                                }
                            }
                            continue;
                        }

                        if (c1.StartsWith("Calculation", StringComparison.OrdinalIgnoreCase) || c1.IndexOf("Overall Score", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            currentScoreLabel = string.Empty;
                            rubricStopRow = Math.Min(rubricStopRow, r);
                            for (int c = 1; c <= endCol; c++)
                            {
                                string cellTxt = (rubricSheet.Cells[r, c].Text ?? string.Empty).Trim();
                                if (cellTxt.IndexOf("Overall Score", StringComparison.OrdinalIgnoreCase) >= 0)
                                {
                                    formulaStr = cellTxt;
                                    break;
                                }
                            }
                            continue;
                        }

                        if (c1.IndexOf("Decision", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            c1.IndexOf("Priority", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            c1.IndexOf("Guardrail", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            c1.IndexOf("Disposition", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            rubricStopRow = Math.Min(rubricStopRow, r);
                            break;
                        }

                        if (Regex.IsMatch(c1, @"^[1-5]$"))
                        {
                            currentScoreLabel = c1;
                            int parsedS;
                            if (int.TryParse(c1, out parsedS) && parsedS > maxScoreFound) maxScoreFound = parsedS;

                            foreach (var dim in discoveredDims)
                            {
                                string cellText = (rubricSheet.Cells[r, dim.Column].Text ?? string.Empty).Replace("\r", " ").Replace("\n", " ").Trim();
                                if (!string.IsNullOrWhiteSpace(cellText))
                                {
                                    string prefix = currentScoreLabel + "=";
                                    int existingIdx = -1;
                                    for (int k = 0; k < dim.Rubrics.Count; k++)
                                    {
                                        if (dim.Rubrics[k].StartsWith(prefix, StringComparison.Ordinal)) { existingIdx = k; break; }
                                    }
                                    if (existingIdx >= 0)
                                    {
                                        dim.Rubrics[existingIdx] = dim.Rubrics[existingIdx].TrimEnd('.', ';', ' ') + " OR " + cellText;
                                    }
                                    else
                                    {
                                        dim.Rubrics.Add(prefix + cellText);
                                    }
                                }
                            }
                        }
                        else
                        {
                            currentScoreLabel = string.Empty;
                        }
                    }

                    // 4. Locate disposition & guardrails dynamically across any worksheet name (separate sheet or in-sheet priority table)
                    ExcelWorksheet mechSheet = FindDispositionWorksheet(pkg.Workbook, rubricSheet);
                    double cmfOkMin = 3.50;
                    double cmfReviewMin = 2.75;
                    List<Dictionary<string, object>> dispRows = new List<Dictionary<string, object>>();
                    List<Dictionary<string, object>> guardrailRows = new List<Dictionary<string, object>>();

                    if (mechSheet != null && mechSheet.Dimension != null)
                    {
                        bool inDisposition = false;
                        bool inGuardrails = false;
                        for (int r = 1; r <= mechSheet.Dimension.End.Row; r++)
                        {
                            string col1 = (mechSheet.Cells[r, 1].Text ?? string.Empty).Trim();
                            string col2 = (mechSheet.Cells[r, 2].Text ?? string.Empty).Trim();
                            if (col1.IndexOf("CMF Disposition", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                inDisposition = true;
                                inGuardrails = false;
                                continue;
                            }
                            if (col1.IndexOf("Gating Guardrails", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                inDisposition = false;
                                inGuardrails = true;
                                continue;
                            }

                            if (inDisposition && col1.StartsWith("CMF_", StringComparison.OrdinalIgnoreCase))
                            {
                                string col3 = (mechSheet.Cells[r, 3].Text ?? string.Empty).Trim();
                                string col4 = (mechSheet.Cells[r, 4].Text ?? string.Empty).Trim();
                                string col5 = (mechSheet.Cells[r, 5].Text ?? string.Empty).Trim();
                                string col8 = (mechSheet.Cells[r, 8].Text ?? string.Empty).Trim();
                                dispRows.Add(new Dictionary<string, object>
                                {
                                    { "disposition", col1.ToUpperInvariant() },
                                    { "scoreBand", col2 },
                                    { "minimumConditions", col3 },
                                    { "meaning", col4 },
                                    { "requiredAction", col5 },
                                    { "output", string.IsNullOrWhiteSpace(col8) ? col1 : col8 }
                                });

                                Match numMatch = Regex.Match(col2, @"(\d+\.\d+)");
                                if (numMatch.Success)
                                {
                                    double parsedNum;
                                    if (double.TryParse(numMatch.Groups[1].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out parsedNum))
                                    {
                                        if (string.Equals(col1, "CMF_OK", StringComparison.OrdinalIgnoreCase)) cmfOkMin = parsedNum;
                                        else if (string.Equals(col1, "CMF_REVIEW", StringComparison.OrdinalIgnoreCase)) cmfReviewMin = parsedNum;
                                    }
                                }
                            }
                            else if (inGuardrails && !string.IsNullOrWhiteSpace(col1) && !string.IsNullOrWhiteSpace(col2))
                            {
                                string col6 = (mechSheet.Cells[r, 6].Text ?? string.Empty).Trim();
                                guardrailRows.Add(new Dictionary<string, object>
                                {
                                    { "id", Regex.Replace(col1.ToLowerInvariant(), @"[^a-z0-9]+", "_").Trim('_') },
                                    { "name", col1 },
                                    { "rule", col2 },
                                    { "rationale", col6 }
                                });
                            }
                        }
                    }
                    else
                    {
                        // Check for in-sheet "Decision Logic and Rule Priority"
                        for (int r = Math.Max(1, rubricStopRow); r <= endRow; r++)
                        {
                            string col1 = (rubricSheet.Cells[r, 1].Text ?? string.Empty).Trim();
                            string col2 = (rubricSheet.Cells[r, 2].Text ?? string.Empty).Trim();
                            string col3 = (rubricSheet.Cells[r, 3].Text ?? string.Empty).Trim();
                            string col4 = (rubricSheet.Cells[r, 4].Text ?? string.Empty).Trim();

                            if (col1.StartsWith("Priority", StringComparison.OrdinalIgnoreCase) ||
                                col1.IndexOf("Decision", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                continue;
                            }

                            int priorityNum;
                            if (int.TryParse(col1, out priorityNum) && !string.IsNullOrWhiteSpace(col2))
                            {
                                string cond = col2;
                                string rec = col3;
                                string interp = col4;

                                guardrailRows.Add(new Dictionary<string, object>
                                {
                                    { "id", "priority_" + priorityNum },
                                    { "name", "Priority " + priorityNum + (string.IsNullOrWhiteSpace(interp) ? string.Empty : ": " + interp) },
                                    { "rule", cond + (string.IsNullOrWhiteSpace(rec) ? string.Empty : " -> " + rec) },
                                    { "rationale", interp }
                                });

                                Match numMatch = Regex.Match(cond, @"Score\s*>=\s*(\d+\.\d+)");
                                if (numMatch.Success)
                                {
                                    double parsedNum;
                                    if (double.TryParse(numMatch.Groups[1].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out parsedNum))
                                    {
                                        if (string.Equals(rec, "CMF_OK", StringComparison.OrdinalIgnoreCase)) cmfOkMin = parsedNum;
                                        else if (string.Equals(rec, "CMF_REVIEW", StringComparison.OrdinalIgnoreCase)) cmfReviewMin = parsedNum;
                                    }
                                }
                            }
                        }

                        if (guardrailRows.Count > 0)
                        {
                            dispRows.Add(new Dictionary<string, object>
                            {
                                { "disposition", "CMF_OK" },
                                { "scoreBand", ">= " + cmfOkMin.ToString("0.00", CultureInfo.InvariantCulture) + " (or S>=3 with B>=3/RVP=Yes)" },
                                { "minimumConditions", "S>=3 AND (B>=3 OR RVP=Yes) [Priority 1] OR Score>=" + cmfOkMin.ToString("0.00", CultureInfo.InvariantCulture) + " [Priority 2]" },
                                { "meaning", "Meets primary severity/business/RVP criteria or secondary weighted score with confirmed gate." },
                                { "requiredAction", "Approve CMF request and tag as CMF_OK." },
                                { "output", "Approve" }
                            });
                            dispRows.Add(new Dictionary<string, object>
                            {
                                { "disposition", "CMF_REVIEW" },
                                { "scoreBand", ">= " + cmfReviewMin.ToString("0.00", CultureInfo.InvariantCulture) + " to < " + cmfOkMin.ToString("0.00", CultureInfo.InvariantCulture) + " (or S>=3 or B>=3 safeguard)" },
                                { "minimumConditions", "S>=3 [Priority 3], B>=3 [Priority 4], or Score>=" + cmfReviewMin.ToString("0.00", CultureInfo.InvariantCulture) + " [Priority 5]" },
                                { "meaning", "Severity or confirmed gate safeguard met, or score in review band. Requires committee review." },
                                { "requiredAction", "Route to CMF review meeting for manual disposition." },
                                { "output", "Review" }
                            });
                            dispRows.Add(new Dictionary<string, object>
                            {
                                { "disposition", "CMF_REJECT" },
                                { "scoreBand", "< " + cmfReviewMin.ToString("0.00", CultureInfo.InvariantCulture) },
                                { "minimumConditions", "Otherwise [Priority 6] (RVP Yes alone does not qualify)" },
                                { "meaning", "Does not meet severity, confirmed gate, or weighted score threshold for CMF." },
                                { "requiredAction", "Reject CMF request." },
                                { "output", "Reject" }
                            });
                        }
                    }

                    // Ensure 5-Tag Model condition entries (CMF_INCOMPLETE & CMF_DUPLICATE) remain in dispositionTable
                    bool hasIncompleteDisp = false;
                    bool hasDuplicateDisp = false;
                    foreach (Dictionary<string, object> dr in dispRows)
                    {
                        string dName = Convert.ToString(dr["disposition"]);
                        if (string.Equals(dName, "CMF_INCOMPLETE", StringComparison.OrdinalIgnoreCase)) hasIncompleteDisp = true;
                        if (string.Equals(dName, "CMF_DUPLICATE", StringComparison.OrdinalIgnoreCase)) hasDuplicateDisp = true;
                    }
                    if (!hasIncompleteDisp)
                    {
                        dispRows.Add(new Dictionary<string, object>
                        {
                            { "disposition", "CMF_INCOMPLETE" },
                            { "scoreBand", "Condition-based (Any Score)" },
                            { "minimumConditions", "Core metric evidence missing (Guardrail #3)" },
                            { "meaning", "One or more core categories cannot be scored from the available ticket evidence." },
                            { "requiredAction", "Request missing reproduction, recovery, or impact details from the submitter before disposition." },
                            { "output", "Incomplete" }
                        });
                    }
                    if (!hasDuplicateDisp)
                    {
                        dispRows.Add(new Dictionary<string, object>
                        {
                            { "disposition", "CMF_DUPLICATE" },
                            { "scoreBand", "Condition-based (Any Score)" },
                            { "minimumConditions", "Duplicate sighting or merge ID identified in ticket/comments" },
                            { "meaning", "Issue reports the same underlying failure already tracked under a primary sighting." },
                            { "requiredAction", "Mark as cmf_duplicate and link to the primary sighting." },
                            { "output", "Duplicate" }
                        });
                    }

                    // Default formula if not found on sheet
                    if (string.IsNullOrWhiteSpace(formulaStr))
                    {
                        List<string> parts = new List<string>();
                        foreach (var dim in discoveredDims)
                        {
                            parts.Add("(" + dim.Id + " * " + (dim.Weight / 100.0).ToString("0.00", CultureInfo.InvariantCulture) + ")");
                        }
                        formulaStr = "Overall Score = " + string.Join(" + ", parts.ToArray());
                    }

                    // 5. Persist updated scoringRules into cmf-assistant-config.json
                    string configPath = ResolveConfigFilePath();
                    JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                    IDictionary root = (File.Exists(configPath) ? serializer.DeserializeObject(File.ReadAllText(configPath, Encoding.UTF8)) as IDictionary : null)
                        ?? new Dictionary<string, object>();

                    IDictionary existingScoring = root["scoringRules"] as IDictionary;
                    IDictionary existingMandatory = existingScoring != null ? existingScoring["mandatoryRequirements"] as IDictionary : null;

                    // Erase previous scoring rules completely and construct fresh scoringNode
                    var scoringNode = new Dictionary<string, object>();
                    scoringNode["scaleMax"] = maxScoreFound;
                    scoringNode["formula"] = formulaStr;
                    scoringNode["cmfOkMinScore"] = cmfOkMin;
                    scoringNode["cmfReviewMinScore"] = cmfReviewMin;
                    scoringNode["thresholdScore"] = (int)Math.Round((cmfOkMin / maxScoreFound) * 100.0);
                    scoringNode["reviewThresholdScore"] = (int)Math.Round((cmfReviewMin / maxScoreFound) * 100.0);

                    if (existingMandatory != null)
                    {
                        var mandatoryCopy = new Dictionary<string, object>();
                        int importedRvpWeight = 0;
                        foreach (var dim in discoveredDims)
                        {
                            if (string.Equals(dim.Id, "RVP", StringComparison.OrdinalIgnoreCase))
                            {
                                importedRvpWeight = dim.Weight;
                                break;
                            }
                        }
                        foreach (DictionaryEntry de in existingMandatory)
                        {
                            string key = Convert.ToString(de.Key);
                            string val = Convert.ToString(de.Value);
                            if (key == "rvpReproPolicy" && importedRvpWeight > 0)
                            {
                                double w = importedRvpWeight / 100.0;
                                val = string.Format(
                                    CultureInfo.InvariantCulture,
                                    "1) When RVP_repro is Yes: the issue reproduces on the Intel Reference Validation Platform (RVP), indicating platform-wide risk across OEM customer units -- RVP is scored {0}/{0} (contributing {1:0.00} to the weighted score); explicitly highlight RVP reproduction in the CMF reasoning. 2) When RVP_repro is Unknown, Blank, NA, or Pending: score RVP as 2/{0} (neutral score contributing {2:0.00}); RVP exposure is not established. 3) When RVP_repro is No: score RVP as 1/{0} (contributing {3:0.00} to the weighted score), reflecting that the defect did not reproduce on RVP and is isolated to customer units.",
                                    maxScoreFound,
                                    maxScoreFound * w,
                                    2 * w,
                                    1 * w);
                            }
                            else if (key == "rvpReproPolicy")
                            {
                                val = val.Replace("6-category", "mathematical");
                            }
                            mandatoryCopy[key] = de.Value is bool ? de.Value : (object)val;
                        }
                        scoringNode["mandatoryRequirements"] = mandatoryCopy;
                    }

                    List<Dictionary<string, object>> updatedDims = new List<Dictionary<string, object>>();
                    foreach (var dim in discoveredDims)
                    {
                        string rubricStr = dim.Rubrics.Count > 0 ? string.Join(" ", dim.Rubrics.ToArray()) : string.Empty;
                        updatedDims.Add(new Dictionary<string, object>
                        {
                            { "id", dim.Id },
                            { "name", dim.Name },
                            { "weight", dim.Weight },
                            { "rubric", rubricStr }
                        });
                    }
                    scoringNode["dimensions"] = updatedDims.ToArray();
                    if (dispRows.Count > 0) scoringNode["dispositionTable"] = dispRows.ToArray();
                    if (guardrailRows.Count > 0) scoringNode["gatingGuardrails"] = guardrailRows.ToArray();

                    // Parse Permutation Analysis sheet if present (any tab name, detected by header columns).
                    // Do NOT carry over old permutationAnalysis from previous guidelines when importing a new rubric workbook without a Permutation sheet.
                    ExcelWorksheet permSheet = FindPermutationWorksheet(pkg.Workbook, rubricSheet);
                    if (permSheet != null && permSheet.Dimension != null && permSheet.Dimension.End.Row >= 5)
                    {
                        List<Dictionary<string, object>> permList = ParsePermutationSheet(permSheet);
                        if (permList.Count > 0)
                        {
                            scoringNode["permutationAnalysis"] = permList.ToArray();
                        }
                    }

                    root["scoringRules"] = scoringNode;

                    File.WriteAllText(configPath, FormatPrettyJson(serializer.Serialize(root)), Encoding.UTF8);
                    CachedConfig = null;
                    CachedLastWriteUtc = DateTime.MinValue;

                    // Clear cached recommendations so new cmf-assistant-config.json rules take effect immediately
                    CmfRecommendationService.ClearRecommendationCache();

                    statusMessage = string.Format(
                        "Successfully imported {0}-point scoring guidelines ({1} dimensions, {2} disposition bands, {3} gating guardrails) into cmf-assistant-config.json.",
                        maxScoreFound, updatedDims.Count, dispRows.Count, guardrailRows.Count);
                    return true;
                }
            }
            catch (Exception ex)
            {
                statusMessage = "Excel scoring import failed: " + ex.Message;
                return false;
            }
        }
    }

    private static ExcelWorksheet FindRubricWorksheet(ExcelWorkbook workbook)
    {
        if (workbook == null || workbook.Worksheets == null) return null;
        foreach (ExcelWorksheet ws in workbook.Worksheets)
        {
            if (ws == null || ws.Dimension == null) continue;
            bool hasSeverity = false;
            bool hasSecondDimOrWeight = false;
            int maxR = Math.Min(ws.Dimension.End.Row, 15);
            int maxC = Math.Min(ws.Dimension.End.Column, 12);
            for (int r = 1; r <= maxR; r++)
            {
                for (int c = 1; c <= maxC; c++)
                {
                    string txt = (ws.Cells[r, c].Text ?? string.Empty).Trim();
                    if (string.IsNullOrWhiteSpace(txt)) continue;
                    if (txt.IndexOf("Severity", StringComparison.OrdinalIgnoreCase) >= 0) hasSeverity = true;
                    if (txt.IndexOf("Occurrence", StringComparison.OrdinalIgnoreCase) >= 0
                        || txt.IndexOf("Business Impact", StringComparison.OrdinalIgnoreCase) >= 0
                        || txt.StartsWith("Weight", StringComparison.OrdinalIgnoreCase))
                    {
                        hasSecondDimOrWeight = true;
                    }
                }
            }
            if (hasSeverity && hasSecondDimOrWeight) return ws;
        }
        return null;
    }

    private static ExcelWorksheet FindDispositionWorksheet(ExcelWorkbook workbook, ExcelWorksheet rubricSheet)
    {
        if (workbook == null || workbook.Worksheets == null) return null;
        foreach (ExcelWorksheet ws in workbook.Worksheets)
        {
            if (ws == null || ws.Dimension == null || ws == rubricSheet) continue;
            int maxR = Math.Min(ws.Dimension.End.Row, 60);
            int maxC = Math.Min(ws.Dimension.End.Column, 6);
            bool hasDispositionMarker = false;
            for (int r = 1; r <= maxR; r++)
            {
                for (int c = 1; c <= maxC; c++)
                {
                    string txt = (ws.Cells[r, c].Text ?? string.Empty).Trim();
                    if (txt.IndexOf("CMF Disposition", StringComparison.OrdinalIgnoreCase) >= 0
                        || txt.IndexOf("Gating Guardrails", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        hasDispositionMarker = true;
                        break;
                    }
                }
                if (hasDispositionMarker) break;
            }
            if (hasDispositionMarker) return ws;
        }
        return null;
    }

    private static ExcelWorksheet FindPermutationWorksheet(ExcelWorkbook workbook, ExcelWorksheet rubricSheet)
    {
        if (workbook == null || workbook.Worksheets == null) return null;
        foreach (ExcelWorksheet ws in workbook.Worksheets)
        {
            if (ws == null || ws.Dimension == null || ws == rubricSheet || ws.Dimension.End.Row < 5 || ws.Dimension.End.Column < 8) continue;
            int maxR = Math.Min(ws.Dimension.End.Row, 10);
            int maxC = Math.Min(ws.Dimension.End.Column, 14);
            for (int r = 1; r <= maxR; r++)
            {
                string col1 = (ws.Cells[r, 1].Text ?? string.Empty).Trim();
                if (!string.Equals(col1, "ID", StringComparison.OrdinalIgnoreCase)) continue;
                bool hasS = false, hasO = false, hasRec = false;
                for (int c = 2; c <= maxC; c++)
                {
                    string h = (ws.Cells[r, c].Text ?? string.Empty).Trim();
                    if (string.Equals(h, "S", StringComparison.OrdinalIgnoreCase) || h.IndexOf("Severity", StringComparison.OrdinalIgnoreCase) >= 0) hasS = true;
                    if (string.Equals(h, "O", StringComparison.OrdinalIgnoreCase) || h.IndexOf("Occurrence", StringComparison.OrdinalIgnoreCase) >= 0) hasO = true;
                    if (h.IndexOf("Recommendation", StringComparison.OrdinalIgnoreCase) >= 0 || h.IndexOf("Disposition", StringComparison.OrdinalIgnoreCase) >= 0) hasRec = true;
                }
                if (hasS && hasO && hasRec) return ws;
            }
        }
        return null;
    }

    private static List<Dictionary<string, object>> ParsePermutationSheet(ExcelWorksheet permSheet)
    {
        List<Dictionary<string, object>> permList = new List<Dictionary<string, object>>();
        if (permSheet == null || permSheet.Dimension == null || permSheet.Dimension.End.Row < 5) return permList;

        int permHeader = 4;
        for (int pr = 1; pr <= Math.Min(permSheet.Dimension.End.Row, 10); pr++)
        {
            string c1 = (permSheet.Cells[pr, 1].Text ?? string.Empty).Trim();
            if (string.Equals(c1, "ID", StringComparison.OrdinalIgnoreCase)) { permHeader = pr; break; }
        }
        for (int pr = permHeader + 1; pr <= permSheet.Dimension.End.Row; pr++)
        {
            string idTxt = (permSheet.Cells[pr, 1].Text ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(idTxt)) continue;
            int idVal;
            if (!int.TryParse(idTxt, out idVal)) continue;

            int sVal = 0, oVal = 0, dVal = 0, bVal = 0, rvpScoreVal = 0;
            int.TryParse((permSheet.Cells[pr, 2].Text ?? string.Empty).Trim(), out sVal);
            int.TryParse((permSheet.Cells[pr, 3].Text ?? string.Empty).Trim(), out oVal);
            int.TryParse((permSheet.Cells[pr, 4].Text ?? string.Empty).Trim(), out dVal);
            int.TryParse((permSheet.Cells[pr, 5].Text ?? string.Empty).Trim(), out bVal);
            string rvpStatus = (permSheet.Cells[pr, 6].Text ?? string.Empty).Trim();
            int.TryParse((permSheet.Cells[pr, 7].Text ?? string.Empty).Trim(), out rvpScoreVal);
            double wScore = 0.0;
            double.TryParse((permSheet.Cells[pr, 8].Text ?? string.Empty).Trim(), NumberStyles.Float, CultureInfo.InvariantCulture, out wScore);
            string sBand = (permSheet.Cells[pr, 9].Text ?? string.Empty).Trim();
            string rTrig = (permSheet.Cells[pr, 10].Text ?? string.Empty).Trim();
            string recVal = (permSheet.Cells[pr, 11].Text ?? string.Empty).Trim();
            string ratVal = (permSheet.Cells[pr, 12].Text ?? string.Empty).Trim();

            permList.Add(new Dictionary<string, object>
            {
                { "id", idVal },
                { "s", sVal },
                { "o", oVal },
                { "d", dVal },
                { "b", bVal },
                { "rvpStatus", rvpStatus },
                { "rvpScore", rvpScoreVal },
                { "weightedScore", Math.Round(wScore, 2) },
                { "scoreBand", sBand },
                { "ruleTriggered", rTrig },
                { "recommendation", recVal },
                { "rationale", ratVal }
            });
        }
        return permList;
    }

    private class ExcelDimensionDef
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public int Column { get; set; }
        public int Weight { get; set; }
        public List<string> Rubrics { get; set; }
        public ExcelDimensionDef() { Rubrics = new List<string>(); }
    }

    private sealed class RubricLevelEntry
    {
        public int Score { get; set; }
        public string LeadText { get; set; }
        public List<string> Items { get; set; }
        public RubricLevelEntry() { Items = new List<string>(); }
    }

    private static List<RubricLevelEntry> ParseRubricIntoLevels(string rubric, int scaleMax)
    {
        var result = new List<RubricLevelEntry>();
        string text = rubric ?? string.Empty;
        MatchCollection matches = Regex.Matches(text, @"(?:^|\s)([1-9])=");

        var found = new Dictionary<int, string>();
        for (int i = 0; i < matches.Count; i++)
        {
            int score;
            if (!int.TryParse(matches[i].Groups[1].Value, out score)) continue;
            int contentStart = matches[i].Index + matches[i].Length;
            int contentEnd = (i + 1 < matches.Count) ? matches[i + 1].Index : text.Length;
            string body = contentEnd > contentStart ? text.Substring(contentStart, contentEnd - contentStart).Trim() : string.Empty;
            if (!found.ContainsKey(score)) found[score] = body;
        }

        int maxS = scaleMax > 0 ? scaleMax : 4;
        for (int s = maxS; s >= 1; s--)
        {
            string body = found.ContainsKey(s) ? found[s] : string.Empty;
            var entry = new RubricLevelEntry { Score = s, LeadText = string.Empty };
            if (!string.IsNullOrWhiteSpace(body))
            {
                string[] parts = Regex.Split(body, @"\s+-\s+");
                entry.LeadText = (parts[0] ?? string.Empty).Trim();
                for (int p = 1; p < parts.Length; p++)
                {
                    string item = (parts[p] ?? string.Empty).Trim();
                    if (!string.IsNullOrWhiteSpace(item)) entry.Items.Add(item);
                }
            }
            result.Add(entry);
        }

        return result;
    }

    private static string SerializeLevelsToRubric(List<RubricLevelEntry> levels)
    {
        if (levels == null || levels.Count == 0) return string.Empty;
        var chunks = new List<string>();
        foreach (RubricLevelEntry lvl in levels)
        {
            if (lvl == null || lvl.Score <= 0) continue;
            var sb = new StringBuilder();
            sb.Append(lvl.Score).Append("=");
            string lead = (lvl.LeadText ?? string.Empty).Trim();
            if (!string.IsNullOrWhiteSpace(lead)) sb.Append(lead);
            if (lvl.Items != null)
            {
                foreach (string rawItem in lvl.Items)
                {
                    string item = (rawItem ?? string.Empty).Trim();
                    if (string.IsNullOrWhiteSpace(item)) continue;
                    if (sb.Length > 2) sb.Append(" - ");
                    else sb.Append("- ");
                    sb.Append(item);
                }
            }
            string built = sb.ToString().Trim();
            if (built.Length > 2) chunks.Add(built);
        }
        return string.Join(" ", chunks.ToArray());
    }

    public static Dictionary<string, object> GetScoringRulesStructured()
    {
        lock (SyncRoot)
        {
            var output = new Dictionary<string, object>();
            string configPath = ResolveConfigFilePath();
            if (string.IsNullOrWhiteSpace(configPath) || !File.Exists(configPath))
            {
                output["success"] = false;
                output["message"] = "Configuration file cmf-assistant-config.json not found.";
                return output;
            }

            try
            {
                JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                IDictionary root = serializer.DeserializeObject(File.ReadAllText(configPath, Encoding.UTF8)) as IDictionary;
                IDictionary scoring = root != null ? root["scoringRules"] as IDictionary : null;
                if (scoring == null)
                {
                    output["success"] = false;
                    output["message"] = "scoringRules section not found in cmf-assistant-config.json.";
                    return output;
                }

                int scaleMax = ReadInt(scoring, "scaleMax", 4);
                output["success"] = true;
                output["scaleMax"] = scaleMax;
                output["formula"] = ReadString(scoring, "formula", string.Empty);
                output["cmfOkMinScore"] = ReadDouble(scoring, "cmfOkMinScore", 3.5);
                output["cmfReviewMinScore"] = ReadDouble(scoring, "cmfReviewMinScore", 2.75);

                IDictionary mandatory = scoring["mandatoryRequirements"] as IDictionary;
                var mandatoryOut = new Dictionary<string, object>
                {
                    { "requireComponentInDescription", mandatory != null && ReadBool(mandatory, "requireComponentInDescription", true) },
                    { "requireRvpReproInDescription", mandatory != null && ReadBool(mandatory, "requireRvpReproInDescription", true) },
                    { "requirePromotedIdInHeader", mandatory != null && ReadBool(mandatory, "requirePromotedIdInHeader", true) },
                    { "requireRvpReproInReasoning", mandatory != null && ReadBool(mandatory, "requireRvpReproInReasoning", true) }
                };
                output["mandatoryRequirements"] = mandatoryOut;

                var dimsOut = new List<Dictionary<string, object>>();
                IList dims = scoring["dimensions"] as IList;
                if (dims != null)
                {
                    foreach (object item in dims)
                    {
                        IDictionary d = item as IDictionary;
                        if (d == null) continue;
                        string id = ReadString(d, "id", string.Empty);
                        string name = ReadString(d, "name", string.Empty);
                        int weight = ReadInt(d, "weight", 0);
                        string rubric = ReadString(d, "rubric", string.Empty);
                        List<RubricLevelEntry> levels = ParseRubricIntoLevels(rubric, scaleMax);
                        var levelsOut = new List<Dictionary<string, object>>();
                        foreach (RubricLevelEntry lvl in levels)
                        {
                            levelsOut.Add(new Dictionary<string, object>
                            {
                                { "score", lvl.Score },
                                { "leadText", lvl.LeadText },
                                { "items", lvl.Items.ToArray() }
                            });
                        }
                        dimsOut.Add(new Dictionary<string, object>
                        {
                            { "id", id },
                            { "name", name },
                            { "weight", weight },
                            { "rubric", rubric },
                            { "levels", levelsOut.ToArray() }
                        });
                    }
                }
                output["dimensions"] = dimsOut.ToArray();

                var guardrailsOut = new List<Dictionary<string, object>>();
                IList guardrails = scoring["gatingGuardrails"] as IList;
                if (guardrails != null)
                {
                    foreach (object item in guardrails)
                    {
                        IDictionary g = item as IDictionary;
                        if (g == null) continue;
                        guardrailsOut.Add(new Dictionary<string, object>
                        {
                            { "id", ReadString(g, "id", string.Empty) },
                            { "name", ReadString(g, "name", string.Empty) },
                            { "rule", ReadString(g, "rule", string.Empty) },
                            { "rationale", ReadString(g, "rationale", string.Empty) }
                        });
                    }
                }
                output["gatingGuardrails"] = guardrailsOut.ToArray();
                return output;
            }
            catch (Exception ex)
            {
                output["success"] = false;
                output["message"] = "Failed to load scoring rules: " + ex.Message;
                return output;
            }
        }
    }

    public static bool UpdateScoringRubricLevel(string dimensionId, int scoreLevel, string leadText, List<string> items, out string statusMessage)
    {
        statusMessage = string.Empty;
        if (string.IsNullOrWhiteSpace(dimensionId) || scoreLevel < 1 || scoreLevel > 4)
        {
            statusMessage = "Valid dimension ID and score level (1-4) are required.";
            return false;
        }

        lock (SyncRoot)
        {
            try
            {
                string configPath = ResolveConfigFilePath();
                if (string.IsNullOrWhiteSpace(configPath) || !File.Exists(configPath))
                {
                    statusMessage = "Configuration file cmf-assistant-config.json not found.";
                    return false;
                }

                JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                IDictionary root = serializer.DeserializeObject(File.ReadAllText(configPath, Encoding.UTF8)) as IDictionary;
                IDictionary scoring = root != null ? root["scoringRules"] as IDictionary : null;
                IList dims = scoring != null ? scoring["dimensions"] as IList : null;
                if (dims == null)
                {
                    statusMessage = "scoringRules.dimensions not found in cmf-assistant-config.json.";
                    return false;
                }

                int scaleMax = ReadInt(scoring, "scaleMax", 4);
                bool updated = false;
                string dimDisplayName = dimensionId;
                foreach (object item in dims)
                {
                    IDictionary d = item as IDictionary;
                    if (d == null) continue;
                    string id = ReadString(d, "id", string.Empty);
                    if (!string.Equals(id, dimensionId.Trim(), StringComparison.OrdinalIgnoreCase)) continue;

                    dimDisplayName = ReadString(d, "name", id);
                    string rubric = ReadString(d, "rubric", string.Empty);
                    List<RubricLevelEntry> levels = ParseRubricIntoLevels(rubric, scaleMax);
                    RubricLevelEntry target = levels.Find(l => l.Score == scoreLevel);
                    if (target == null)
                    {
                        target = new RubricLevelEntry { Score = scoreLevel };
                        levels.Add(target);
                        levels.Sort((a, b) => b.Score.CompareTo(a.Score));
                    }

                    target.LeadText = (leadText ?? string.Empty).Trim();
                    target.Items = new List<string>();
                    if (items != null)
                    {
                        foreach (string raw in items)
                        {
                            string clean = Regex.Replace((raw ?? string.Empty).Trim(), @"^[-*\u2022]\s+", string.Empty).Trim();
                            if (!string.IsNullOrWhiteSpace(clean)) target.Items.Add(clean);
                        }
                    }

                    d["rubric"] = SerializeLevelsToRubric(levels);
                    updated = true;
                    break;
                }

                if (!updated)
                {
                    statusMessage = "Dimension '" + dimensionId + "' not found.";
                    return false;
                }

                File.WriteAllText(configPath, FormatPrettyJson(serializer.Serialize(root)), Encoding.UTF8);
                CachedConfig = null;
                CachedLastWriteUtc = DateTime.MinValue;
                CmfRecommendationService.ClearRecommendationCache();

                statusMessage = string.Format("Updated {0} (Score {1}) in cmf-assistant-config.json.", dimDisplayName, scoreLevel);
                return true;
            }
            catch (Exception ex)
            {
                statusMessage = "Failed to save rubric level: " + ex.Message;
                return false;
            }
        }
    }

    public static bool AddScoringRubricSymptom(string dimensionId, int scoreLevel, string symptomText, out string statusMessage)
    {
        statusMessage = string.Empty;
        string cleanSymptom = Regex.Replace((symptomText ?? string.Empty).Trim(), @"^[-*\u2022]\s+", string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(dimensionId) || scoreLevel < 1 || scoreLevel > 4 || string.IsNullOrWhiteSpace(cleanSymptom))
        {
            statusMessage = "Dimension, score level (1-4), and symptom/condition text are required.";
            return false;
        }

        lock (SyncRoot)
        {
            try
            {
                string configPath = ResolveConfigFilePath();
                if (string.IsNullOrWhiteSpace(configPath) || !File.Exists(configPath))
                {
                    statusMessage = "Configuration file cmf-assistant-config.json not found.";
                    return false;
                }

                JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                IDictionary root = serializer.DeserializeObject(File.ReadAllText(configPath, Encoding.UTF8)) as IDictionary;
                IDictionary scoring = root != null ? root["scoringRules"] as IDictionary : null;
                IList dims = scoring != null ? scoring["dimensions"] as IList : null;
                if (dims == null)
                {
                    statusMessage = "scoringRules.dimensions not found in cmf-assistant-config.json.";
                    return false;
                }

                int scaleMax = ReadInt(scoring, "scaleMax", 4);
                foreach (object item in dims)
                {
                    IDictionary d = item as IDictionary;
                    if (d == null) continue;
                    string id = ReadString(d, "id", string.Empty);
                    if (!string.Equals(id, dimensionId.Trim(), StringComparison.OrdinalIgnoreCase)) continue;

                    string rubric = ReadString(d, "rubric", string.Empty);
                    List<RubricLevelEntry> levels = ParseRubricIntoLevels(rubric, scaleMax);
                    RubricLevelEntry target = levels.Find(l => l.Score == scoreLevel);
                    if (target == null)
                    {
                        target = new RubricLevelEntry { Score = scoreLevel };
                        levels.Add(target);
                        levels.Sort((a, b) => b.Score.CompareTo(a.Score));
                    }

                    bool exists = target.Items.Exists(x => string.Equals(x, cleanSymptom, StringComparison.OrdinalIgnoreCase));
                    if (!exists) target.Items.Add(cleanSymptom);

                    d["rubric"] = SerializeLevelsToRubric(levels);
                    File.WriteAllText(configPath, FormatPrettyJson(serializer.Serialize(root)), Encoding.UTF8);
                    CachedConfig = null;
                    CachedLastWriteUtc = DateTime.MinValue;
                    CmfRecommendationService.ClearRecommendationCache();

                    statusMessage = string.Format("Added symptom to {0} (Score {1}) in cmf-assistant-config.json.", ReadString(d, "name", id), scoreLevel);
                    return true;
                }

                statusMessage = "Dimension '" + dimensionId + "' not found.";
                return false;
            }
            catch (Exception ex)
            {
                statusMessage = "Failed to add symptom: " + ex.Message;
                return false;
            }
        }
    }

    public static bool SaveGuardrailsAndThresholds(double cmfOkMinScore, double cmfReviewMinScore, List<Dictionary<string, string>> guardrails, Dictionary<string, bool> mandatoryReqs, out string statusMessage)
    {
        statusMessage = string.Empty;
        if (cmfOkMinScore <= 0 || cmfReviewMinScore <= 0 || cmfOkMinScore < cmfReviewMinScore)
        {
            statusMessage = "CMF_OK min score must be greater than or equal to CMF_REVIEW min score.";
            return false;
        }

        lock (SyncRoot)
        {
            try
            {
                string configPath = ResolveConfigFilePath();
                if (string.IsNullOrWhiteSpace(configPath) || !File.Exists(configPath))
                {
                    statusMessage = "Configuration file cmf-assistant-config.json not found.";
                    return false;
                }

                JavaScriptSerializer serializer = new JavaScriptSerializer { MaxJsonLength = 4194304 };
                IDictionary root = serializer.DeserializeObject(File.ReadAllText(configPath, Encoding.UTF8)) as IDictionary;
                IDictionary scoring = root != null ? root["scoringRules"] as IDictionary : null;
                if (scoring == null)
                {
                    statusMessage = "scoringRules section not found in cmf-assistant-config.json.";
                    return false;
                }

                int scaleMax = ReadInt(scoring, "scaleMax", 4);
                scoring["cmfOkMinScore"] = Math.Round(cmfOkMinScore, 2);
                scoring["cmfReviewMinScore"] = Math.Round(cmfReviewMinScore, 2);
                scoring["thresholdScore"] = (int)Math.Round((cmfOkMinScore / Math.Max(1, scaleMax)) * 100.0);
                scoring["reviewThresholdScore"] = (int)Math.Round((cmfReviewMinScore / Math.Max(1, scaleMax)) * 100.0);

                if (mandatoryReqs != null)
                {
                    IDictionary mandatory = scoring["mandatoryRequirements"] as IDictionary ?? new Dictionary<string, object>();
                    foreach (KeyValuePair<string, bool> kv in mandatoryReqs)
                    {
                        if (!string.IsNullOrWhiteSpace(kv.Key)) mandatory[kv.Key] = kv.Value;
                    }
                    scoring["mandatoryRequirements"] = mandatory;
                }

                if (guardrails != null)
                {
                    var cleanedGuardrails = new List<Dictionary<string, object>>();
                    int idx = 1;
                    foreach (Dictionary<string, string> g in guardrails)
                    {
                        if (g == null) continue;
                        string name = g.ContainsKey("name") ? (g["name"] ?? string.Empty).Trim() : string.Empty;
                        string rule = g.ContainsKey("rule") ? (g["rule"] ?? string.Empty).Trim() : string.Empty;
                        string rationale = g.ContainsKey("rationale") ? (g["rationale"] ?? string.Empty).Trim() : string.Empty;
                        string id = g.ContainsKey("id") && !string.IsNullOrWhiteSpace(g["id"]) ? g["id"].Trim() : ("priority_" + idx);
                        if (string.IsNullOrWhiteSpace(name) && string.IsNullOrWhiteSpace(rule)) continue;
                        cleanedGuardrails.Add(new Dictionary<string, object>
                        {
                            { "id", id },
                            { "name", name },
                            { "rule", rule },
                            { "rationale", rationale }
                        });
                        idx++;
                    }
                    scoring["gatingGuardrails"] = cleanedGuardrails.ToArray();
                }

                File.WriteAllText(configPath, FormatPrettyJson(serializer.Serialize(root)), Encoding.UTF8);
                CachedConfig = null;
                CachedLastWriteUtc = DateTime.MinValue;
                CmfRecommendationService.ClearRecommendationCache();

                statusMessage = "Guardrails and thresholds saved to cmf-assistant-config.json.";
                return true;
            }
            catch (Exception ex)
            {
                statusMessage = "Failed to save guardrails: " + ex.Message;
                return false;
            }
        }
    }

    private static string FormatPrettyJson(string rawJson)
    {
        if (string.IsNullOrWhiteSpace(rawJson)) return "{}";
        StringBuilder sb = new StringBuilder();
        int indent = 0;
        bool inQuotes = false;
        bool escaped = false;

        foreach (char ch in rawJson)
        {
            if (escaped)
            {
                sb.Append(ch);
                escaped = false;
                continue;
            }
            if (ch == '\\' && inQuotes)
            {
                sb.Append(ch);
                escaped = true;
                continue;
            }
            if (ch == '"')
            {
                inQuotes = !inQuotes;
                sb.Append(ch);
                continue;
            }
            if (!inQuotes)
            {
                if (ch == '{' || ch == '[')
                {
                    sb.Append(ch);
                    sb.AppendLine();
                    indent++;
                    sb.Append(new string(' ', indent * 2));
                }
                else if (ch == '}' || ch == ']')
                {
                    sb.AppendLine();
                    indent = Math.Max(0, indent - 1);
                    sb.Append(new string(' ', indent * 2));
                    sb.Append(ch);
                }
                else if (ch == ',')
                {
                    sb.Append(ch);
                    sb.AppendLine();
                    sb.Append(new string(' ', indent * 2));
                }
                else if (ch == ':')
                {
                    sb.Append(": ");
                }
                else if (!char.IsWhiteSpace(ch))
                {
                    sb.Append(ch);
                }
            }
            else
            {
                sb.Append(ch);
            }
        }
        return sb.ToString();
    }
}
