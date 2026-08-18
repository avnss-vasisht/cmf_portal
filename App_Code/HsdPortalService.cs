using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using System.Security.Principal;
using System.Web.Script.Serialization;

// Represents the fields fetched from the HSD portal for a single sighting/article.
public class HsdArticleData
{
    public string ArticleId { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public string Family { get; set; }
    public string Component { get; set; }
    public string Status { get; set; }
    public string Sysdebug { get; set; }
    public string SysdebugForum { get; set; }
    public string Priority { get; set; }
    public string Submitter { get; set; }
    public string Owner { get; set; }
    public string StepsToReproduce { get; set; }
    public string ExpectedBehavior { get; set; }
    public string ActualBehavior { get; set; }
    public List<string> Comments { get; set; }
    public bool FetchSuccess { get; set; }
    public string FetchError { get; set; }
    public string FixDescription { get; set; }
    public string ClosedReason { get; set; }
    public string FixedVersion { get; set; }
    public string CustomerImpact { get; set; }
    public string Reproducibility { get; set; }
    public string ImplementedDate { get; set; }
    public string VerifiedDate { get; set; }
    public string ClosedDate { get; set; }
    public string CmfJustification { get; set; }
    public string InvestigationHistory { get; set; }
}

public static class HsdPortalService
{
    private const string DefaultBaseUrl = "https://hsdes.intel.com/appbuilder/rest/article";
    private const string DefaultEqlServiceUrl = "https://hsdes-api.intel.com/ws/ESService";
    private const int DescriptionMaxChars = 2500;
    private const int CommentMaxChars = 600;
    private const int MaxComments = 5;

    // Fetches article fields + recent comments from the HSD portal using Windows NTLM auth.
    public static HsdArticleData FetchArticle(string articleId)
    {
        return FetchArticle(articleId, null);
    }

    public static HsdArticleData FetchArticle(string articleId, string componentGroup)
    {
        var result = new HsdArticleData
        {
            ArticleId = articleId,
            Comments = new List<string>(),
            FetchSuccess = false
        };

        string enabledStr = ConfigurationManager.AppSettings["HSD:Enabled"];
        if (string.Equals(enabledStr, "false", StringComparison.OrdinalIgnoreCase))
        {
            result.FetchError = "HSD integration disabled (HSD:Enabled=false).";
            return result;
        }

        if (string.IsNullOrWhiteSpace(articleId))
        {
            result.FetchError = "Article ID is empty.";
            return result;
        }

        string baseUrl = (ConfigurationManager.AppSettings["HSD:ArticleApiBaseUrl"] ?? DefaultBaseUrl).TrimEnd('/');
        string articleUrl = baseUrl + "/" + Uri.EscapeUriString(articleId.Trim());

        try
        {
            string json = HttpGetSspi(articleUrl);
            if (string.IsNullOrWhiteSpace(json))
            {
                result.FetchError = "Empty response from HSD API.";
                return result;
            }

            ParseArticleJson(json, result);

            if (!string.IsNullOrWhiteSpace(result.Title) ||
                !string.IsNullOrWhiteSpace(result.Description) ||
                !string.IsNullOrWhiteSpace(result.Status) ||
                !string.IsNullOrWhiteSpace(result.Sysdebug))
            {
                result.FetchSuccess = true;
            }
            else
            {
                result.FetchSuccess = false;

                if (string.IsNullOrWhiteSpace(result.FetchError))
                {
                    result.FetchError =
                        "HSD response received, but no recognizable article fields were parsed.";
                }
            }

            // Try to fetch discussion comments; ignore errors since comments are optional.
            TryFetchComments(articleUrl, result);
        }
        catch (WebException webEx)
        {
            HttpWebResponse resp = webEx.Response as HttpWebResponse;
            if (resp != null)
            {
                string authenticationScheme = resp.Headers[HttpResponseHeader.WwwAuthenticate];
                result.FetchError = "HSD API HTTP " + (int)resp.StatusCode;

                if (!string.IsNullOrWhiteSpace(authenticationScheme))
                {
                    result.FetchError += " (WWW-Authenticate: " + authenticationScheme + ")";
                }
            }
            else
            {
                result.FetchError = "HSD API unreachable: " + webEx.Message;
            }
        }
        catch (Exception ex)
        {
            result.FetchError = ex.Message;
        }

        if (!result.FetchSuccess && ShouldUseEqlFallback())
        {
            string articleApiError = result.FetchError;
            HsdArticleData eqlResult = FetchArticleByEql(articleId, componentGroup);
            if (eqlResult.FetchSuccess)
            {
                return eqlResult;
            }

            result.FetchError = "Article API: " + articleApiError + "; EQL fallback: " + eqlResult.FetchError;
        }

        return result;
    }

    private static bool ShouldUseEqlFallback()
    {
        string setting = ConfigurationManager.AppSettings["HSD:UseEqlFallback"];
        return string.IsNullOrWhiteSpace(setting) || !string.Equals(setting, "false", StringComparison.OrdinalIgnoreCase);
    }

    private static HsdArticleData FetchArticleByEql(string articleId, string componentGroup)
    {
        HsdArticleData result = new HsdArticleData
        {
            ArticleId = articleId,
            Comments = new List<string>(),
            FetchSuccess = false
        };

        try
        {
            string entity = ResolveEqlEntity(componentGroup);
            string escapedId = articleId.Trim().Replace("'", "''");
            string eql = "select " + entity + ".id as 'id', " + entity + ".title as 'title', " +
                entity + ".status as 'status', " + entity + ".owner as 'owner', " +
                entity + ".priority as 'priority', " + entity + ".sysdebug as 'sysdebug', " +
                entity + ".sysdebug_forum as 'sysdebug_forum', " + entity + ".reproducibility as 'reproducibility', " +
                entity + ".closed_reason as 'closed_reason', " + entity + ".fixed_in_version as 'fixed_version' " +
                "where " + entity + ".id = '" + escapedId + "'";

            string responseJson = HttpPostSspi(GetEqlServiceUrl(), BuildEqlRequest(eql));
            string error;
            IDictionary fields = GetFirstEqlResult(responseJson, out error);
            if (fields == null)
            {
                result.FetchError = error;
                return result;
            }

            MapArticleFields(fields, result);
            result.FetchSuccess = !string.IsNullOrWhiteSpace(result.Title)
                || !string.IsNullOrWhiteSpace(result.Status)
                || !string.IsNullOrWhiteSpace(result.Owner);
            result.FetchError = result.FetchSuccess ? null : "EQL returned no recognizable article fields.";
        }
        catch (WebException webEx)
        {
            HttpWebResponse response = webEx.Response as HttpWebResponse;
            result.FetchError = response == null
                ? webEx.Message
                : "HSD EQL HTTP " + (int)response.StatusCode;
        }
        catch (Exception ex)
        {
            result.FetchError = ex.Message;
        }

        return result;
    }

    private static string ResolveEqlEntity(string componentGroup)
    {
        switch ((componentGroup ?? string.Empty).Trim().ToUpperInvariant())
        {
            case "HW":
            case "MEMORY": return "sighting_central.sighting";
            case "AUDIO": return "sfip.sighting";
            case "GFX":
            case "IGFX":
            case "IPF": return "ip_sw_graphics.bug";
            case "SENSOR": return "ip_fw_sw_sensing.bug";
            case "BIOS": return "central_firmware.bug";
            case "OS": return "platf_win_os.bug";
            case "TBT":
            case "TCSS (EXCL TBT)": return "client_conn_ip.bug";
            case "LAN": return "client_conn_ip.sighting";
            default: return "client_platf.bug";
        }
    }

    private static string GetEqlServiceUrl()
    {
        return ConfigurationManager.AppSettings["HSD:EqlServiceUrl"] ?? DefaultEqlServiceUrl;
    }

    private static string BuildEqlRequest(string eql)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        return serializer.Serialize(new
        {
            requests = new[]
            {
                new
                {
                    tran_id = Guid.NewGuid().ToString(),
                    command = "get_records_by_eql",
                    command_args = new { eql = eql, count = "1" },
                    var_args = new string[0]
                }
            }
        });
    }

    private static IDictionary GetFirstEqlResult(string responseJson, out string error)
    {
        error = "Empty EQL response.";
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;
        IDictionary root = serializer.DeserializeObject(responseJson) as IDictionary;
        IList responses = root == null ? null : root["responses"] as IList;
        IDictionary response = responses != null && responses.Count > 0 ? responses[0] as IDictionary : null;
        IList results = response == null ? null : response["result_table"] as IList;
        IDictionary fields = results != null && results.Count > 0 ? results[0] as IDictionary : null;

        if (fields != null)
        {
            error = null;
            return fields;
        }

        string status = response == null || response["status"] == null ? "unknown status" : response["status"].ToString();
        string detail = FirstNonEmptyResponseValue(response, "message", "error", "error_message", "details");
        error = "EQL returned no article data (" + status + ")" +
            (string.IsNullOrWhiteSpace(detail) ? "." : ": " + Truncate(detail, 500));
        return null;
    }

    private static string FirstNonEmptyResponseValue(IDictionary response, params string[] keys)
    {
        if (response == null || keys == null) return null;
        foreach (string key in keys)
        {
            object value = response[key];
            if (value != null && !string.IsNullOrWhiteSpace(value.ToString())) return value.ToString();
        }
        return null;
    }

    // Formats HsdArticleData into a context block for the AI prompt.
    public static string FormatForAiContext(HsdArticleData data, string sectionLabel)
    {
        if (data == null || !data.FetchSuccess) return string.Empty;

        var sb = new StringBuilder();
        sb.AppendLine("--- " + sectionLabel + " (HSD Portal) ---");
        AppendIfSet(sb, "Description", Truncate(data.Description, DescriptionMaxChars));
        AppendIfSet(sb, "Family", data.Family);
        AppendIfSet(sb, "Component", data.Component);
        AppendIfSet(sb, "Status", data.Status);
        AppendIfSet(sb, "Priority", data.Priority);
        AppendIfSet(sb, "Sysdebug Category", data.Sysdebug);
        AppendIfSet(sb, "Sysdebug Forum", Truncate(data.SysdebugForum, 1000));
        AppendIfSet(sb, "Submitter", data.Submitter);
        AppendIfSet(sb, "Owner", data.Owner);
        AppendIfSet(sb, "Steps to Reproduce", Truncate(data.StepsToReproduce, 800));
        AppendIfSet(sb, "Expected Behavior", Truncate(data.ExpectedBehavior, 500));
        AppendIfSet(sb, "Actual Behavior", Truncate(data.ActualBehavior, 500));

        if (data.Comments != null && data.Comments.Count > 0)
        {
            sb.AppendLine("Discussion Comments (" + data.Comments.Count + " shown):");
            for (int i = 0; i < data.Comments.Count; i++)
                sb.AppendLine("  [" + (i + 1) + "] " + data.Comments[i]);
        }

        if (!string.IsNullOrWhiteSpace(data.InvestigationHistory))
        {
            sb.AppendLine();
            sb.AppendLine("=== HSD INVESTIGATION HISTORY ===");
            sb.AppendLine(data.InvestigationHistory);
        }

        return sb.ToString().Trim();
    }

    private static void TryFetchComments(string articleUrl, HsdArticleData result)
    {
        string[] commentEndpoints = new[]
        {
            articleUrl + "/children?type=discussion&count=" + MaxComments,
            articleUrl + "/comments?count=" + MaxComments
        };

        foreach (string endpoint in commentEndpoints)
        {
            try
            {
                string json = HttpGetSspi(endpoint);
                if (string.IsNullOrWhiteSpace(json)) continue;

                ParseCommentsJson(json, result);
                if (result.Comments.Count > 0) break; // stop once we got comments
            }
            catch { }
        }
    }

    private static string HttpGetSspi(string url)
    {
        int timeoutMs = 10000;

        string timeoutStr = ConfigurationManager.AppSettings["HSD:TimeoutSeconds"];
        int secs;

        if (!string.IsNullOrWhiteSpace(timeoutStr) &&
            int.TryParse(timeoutStr, out secs) &&
            secs > 0)
        {
            timeoutMs = secs * 1000;
        }

        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);

        request.Method = "GET";
        request.Accept = "application/json";
        request.ContentType = "application/json";
        request.Timeout = timeoutMs;
        request.ReadWriteTimeout = timeoutMs;
        request.AllowAutoRedirect = true;
        request.KeepAlive = true;

        // Use the user / process identity that is already logged into the Intel domain so
        // the challenge is negotiated as Kerberos/NTLM (SSPI) rather than using a hardcoded
        // network account that usually doesn't have HSD access.
        bool useDefaultCredentials = true;
        string useDefaultCredentialsSetting = ConfigurationManager.AppSettings["HSD:UseDefaultCredentials"];
        if (!string.IsNullOrWhiteSpace(useDefaultCredentialsSetting) &&
            !bool.TryParse(useDefaultCredentialsSetting, out useDefaultCredentials))
        {
            useDefaultCredentials = true;
        }

        ConfigureHsdAuthentication(request, useDefaultCredentials);

        // HSD is usually accessible from the corporate network. If a proxy is required,
        // preserve the same Windows identity so the proxy and the upstream HSD endpoint
        // can negotiate authentication correctly.
        request.Proxy = BuildHsdProxy();

        WindowsIdentity identity = WindowsIdentity.GetCurrent();
        System.Diagnostics.Debug.WriteLine(
            "HSD SSPI Windows Identity: " +
            (identity != null ? identity.Name : "NULL")
        );

        System.Diagnostics.Debug.WriteLine(
            "HSD SSPI Authentication Type: " +
            (identity != null ? identity.AuthenticationType : "NULL")
        );

        using (HttpWebResponse response =
            (HttpWebResponse)request.GetResponse())
        using (StreamReader reader =
            new StreamReader(response.GetResponseStream(), Encoding.UTF8))
        {
            return reader.ReadToEnd();
        }
    }

    private static string HttpPostSspi(string url, string requestBody)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        request.Method = "POST";
        request.Accept = "application/json";
        request.ContentType = "application/json";
        request.Timeout = GetTimeoutMilliseconds();
        request.ReadWriteTimeout = GetTimeoutMilliseconds();
        ConfigureHsdAuthentication(request, true);
        request.Proxy = BuildHsdProxy();

        using (StreamWriter writer = new StreamWriter(request.GetRequestStream()))
        {
            writer.Write(requestBody);
        }

        using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
        using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
        {
            return reader.ReadToEnd();
        }
    }

    private static int GetTimeoutMilliseconds()
    {
        int timeoutSeconds;
        return int.TryParse(ConfigurationManager.AppSettings["HSD:TimeoutSeconds"], out timeoutSeconds) && timeoutSeconds > 0
            ? timeoutSeconds * 1000
            : 10000;
    }

    private static void ConfigureHsdAuthentication(HttpWebRequest request, bool useDefaultCredentials)
    {
        string authenticationMode = ConfigurationManager.AppSettings["HSD:AuthenticationMode"] ?? "Negotiate";
        if (string.Equals(authenticationMode, "Basic", StringComparison.OrdinalIgnoreCase))
        {
            string username = Environment.GetEnvironmentVariable("HSD_BASIC_USERNAME");
            string password = Environment.GetEnvironmentVariable("HSD_BASIC_PASSWORD");
            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                throw new InvalidOperationException("HSD Basic authentication is enabled, but HSD_BASIC_USERNAME or HSD_BASIC_PASSWORD is not set for the IIS Express process.");
            }

            string token = Convert.ToBase64String(Encoding.UTF8.GetBytes(username + ":" + password));
            request.Headers[HttpRequestHeader.Authorization] = "Basic " + token;
            request.UseDefaultCredentials = false;
            request.PreAuthenticate = true;
            return;
        }

        request.UseDefaultCredentials = useDefaultCredentials;
        request.Credentials = useDefaultCredentials
            ? CredentialCache.DefaultCredentials
            : CredentialCache.DefaultNetworkCredentials;
        request.PreAuthenticate = true;
    }

    private static IWebProxy BuildHsdProxy()
    {
        string explicitProxy = ConfigurationManager.AppSettings["HSD:Proxy"];
        if (!string.IsNullOrWhiteSpace(explicitProxy))
        {
            WebProxy proxy = new WebProxy(explicitProxy.Trim(), true);
            proxy.Credentials = CredentialCache.DefaultCredentials;
            return proxy;
        }

        IWebProxy systemProxy = WebRequest.GetSystemWebProxy();
        if (systemProxy != null)
        {
            systemProxy.Credentials = CredentialCache.DefaultCredentials;
            return systemProxy;
        }

        return null;
    }

    private static void ParseArticleJson(string json, HsdArticleData result)
    {
        JavaScriptSerializer ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;

        object raw = ser.DeserializeObject(json);

        IDictionary root = raw as IDictionary;

        if (root == null)
        {
            result.FetchError = "HSD response root is not a JSON object.";
            return;
        }

        // TEMPORARY DIAGNOSTIC
        string debugPath = null;

        try
        {
            debugPath = Path.Combine(
                AppDomain.CurrentDomain.BaseDirectory,
                "App_Data",
                "hsd-raw-response-" + result.ArticleId + ".json"
            );

            File.WriteAllText(debugPath, json);
        }
        catch
        {
            // Do not allow debugging output to affect HSD processing.
        }

        IList dataArray = root["data"] as IList;

        IDictionary fields = null;

        if (dataArray != null && dataArray.Count > 0)
        {
            fields = dataArray[0] as IDictionary;
        }
        else
        {
            fields = root;
        }

        if (fields == null)
        {
            result.FetchError = "Unable to locate HSD article fields.";
            return;
        }

        MapArticleFields(fields, result);
    }

    private static void MapArticleFields(IDictionary fields, HsdArticleData result)
    {
        result.Title = Pick(fields, "title", "subject", "name");
        result.Description = Pick(fields, "description", "sighting.description", "body", "text");
        result.Family = Pick(fields, "family", "product_family", "sighting.family", "cpu_family");
        result.Component = Pick(fields, "component", "sighting.component", "component_name");
        result.Status = Pick(fields, "status", "sighting.status", "state");
        result.Sysdebug = Pick(fields, "sysdebug", "sighting.sysdebug", "debug_category", "sysdebug_category");
        result.SysdebugForum = Pick(fields, "sysdebug_forum", "sighting.sysdebug_forum", "debug_forum");
        result.Priority = Pick(fields, "priority", "sighting.priority", "severity");
        result.Submitter = Pick(fields, "submitter", "reporter", "created_by", "author");
        result.Owner = Pick(fields, "owner", "assigned_to", "assignee");
        result.StepsToReproduce = Pick(fields, "steps_to_reproduce", "repro_steps", "sighting.steps_to_reproduce", "repro");
        result.ExpectedBehavior = Pick(fields, "expected_behavior", "expected", "sighting.expected_behavior");
        result.ActualBehavior = Pick(fields, "actual_behavior", "actual", "sighting.actual_behavior");
        result.FixDescription = Pick(
            fields,
            "bugfixdescription",
            "fixdescription",
            "fix_description");

        result.ClosedReason = Pick(
            fields,
            "bugclosedreason",
            "closedreason",
            "closed_reason");

        result.FixedVersion = Pick(
            fields,
            "clientplatfbugfixedinversion",
            "fixedinversion",
            "fixed_version");

        result.CustomerImpact = Pick(
            fields,
            "clientplatfbugimpact",
            "bugcustomerimpact",
            "customerimpact");

        result.Reproducibility = Pick(
            fields,
            "bugreproducibility",
            "reproducibility");

        result.ImplementedDate = Pick(
            fields,
            "bugimplementeddate",
            "dateimplemented");

        result.VerifiedDate = Pick(
            fields,
            "bugverifieddate",
            "dateverified");

        result.ClosedDate = Pick(
            fields,
            "closeddate",
            "dateclosed");

        result.CmfJustification = Pick(
            fields,
            "clientplatfbugwhycmfchange",
            "whycmfchange");

        string commentsHistory = Pick(
            fields,
            "comments",
            "discussion_comments",
            "discussioncomments");

        if (!string.IsNullOrWhiteSpace(commentsHistory))
        {
            result.InvestigationHistory = commentsHistory;
        }

        string customerBlogHistory = Pick(
            fields,
            "clientplatfbugextcustbloghist",
            "custbloghist",
            "customerbloghistory");

        if (!string.IsNullOrWhiteSpace(customerBlogHistory))
        {
            if (!string.IsNullOrWhiteSpace(result.InvestigationHistory))
            {
                result.InvestigationHistory += "\n\n=== CUSTOMER / EXTERNAL HISTORY ===\n"
                    + customerBlogHistory;
            }
            else
            {
                result.InvestigationHistory = customerBlogHistory;
            }
        }
    }

    private static void ParseCommentsJson(string json, HsdArticleData result)
    {
        JavaScriptSerializer ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;

        object raw = ser.DeserializeObject(json);
        IDictionary root = raw as IDictionary;
        if (root == null) return;

        IList items = root["data"] as IList ?? root["comments"] as IList ?? root["children"] as IList;
        if (items == null) return;

        foreach (object item in items)
        {
            IDictionary c = item as IDictionary;
            if (c == null) continue;

            string text = Pick(c, "description", "body", "text", "content", "comment");
            if (string.IsNullOrWhiteSpace(text)) continue;

            string author = Pick(c, "submitter", "author", "created_by");
            string entry = string.IsNullOrWhiteSpace(author)
                ? text
                : "[" + author + "]: " + text;

            result.Comments.Add(Truncate(entry, CommentMaxChars));
            if (result.Comments.Count >= MaxComments) break;
        }
    }

    // Returns the first non-empty value matching any of the given keys.
    private static string Pick(IDictionary dict, params string[] keys)
    {
        if (dict == null) return null;
        foreach (string key in keys)
        {
            if (!dict.Contains(key)) continue;
            object val = dict[key];
            if (val == null) continue;
            string s = val.ToString().Trim();
            if (!string.IsNullOrEmpty(s) && !string.Equals(s, "null", StringComparison.OrdinalIgnoreCase))
                return s;
        }
        return null;
    }

    private static string Truncate(string value, int maxLen)
    {
        if (string.IsNullOrEmpty(value) || value.Length <= maxLen) return value;
        return value.Substring(0, maxLen) + "... [truncated]";
    }

    private static void AppendIfSet(StringBuilder sb, string label, string value)
    {
        if (!string.IsNullOrWhiteSpace(value))
            sb.AppendLine(label + ": " + value);
    }
}
