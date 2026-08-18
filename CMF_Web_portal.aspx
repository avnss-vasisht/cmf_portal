<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CMF_Web_portal.aspx.cs" Inherits="CMF_Web_portal" EnableEventValidation="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>CMF Web Portal</title>

    <!-- Stylesheets -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/all.min.css" type="text/css" />
    <link rel="stylesheet" href="Content/cmf-portal.css">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap JS -->
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
    <!-- ECharts for Reports & Analytics charts -->
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
    
    <!-- Markdown rendering library -->
    <script src="https://cdn.jsdelivr.net/npm/marked@11.0.0"></script>
    <!-- HTML sanitization library -->
    <script src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"></script>

    <style>
        :root {
            --portal-bg: #edf3f8;
            --portal-surface: #ffffff;
            --portal-surface-soft: #f7fafc;
            --portal-ink: #19324a;
            --portal-ink-muted: #5c7087;
            --portal-primary: #0f5ea8;
            --portal-primary-deep: #083d74;
            --portal-accent: #00a6b2;
            --portal-border: #cdd9e5;
            --portal-shadow: 0 18px 42px rgba(17, 43, 70, 0.12);
            --portal-radius: 18px;
        }

        body {
            overflow-x: hidden;
            font-family: "Segoe UI", "Trebuchet MS", sans-serif;
            margin: 0;
            padding: 0;
            color: var(--portal-ink);
            background:
                radial-gradient(circle at top left, rgba(0, 166, 178, 0.10), transparent 24%),
                radial-gradient(circle at top right, rgba(15, 94, 168, 0.12), transparent 28%),
                linear-gradient(180deg, #f4f8fb 0%, var(--portal-bg) 100%);
        }

        /* Markdown content styles */
        .markdown-content {
            word-wrap: break-word;
            overflow-wrap: break-word;
        }

        .markdown-content h1,
        .markdown-content h2,
        .markdown-content h3,
        .markdown-content h4,
        .markdown-content h5,
        .markdown-content h6 {
            margin-top: 16px;
            margin-bottom: 8px;
            font-weight: 700;
            color: var(--portal-ink);
        }

        .markdown-content h1 { font-size: 1.8rem; }
        .markdown-content h2 { font-size: 1.5rem; }
        .markdown-content h3 { font-size: 1.3rem; }
        .markdown-content h4 { font-size: 1.1rem; }
        .markdown-content h5 { font-size: 1rem; }
        .markdown-content h6 { font-size: 0.95rem; }

        .markdown-content strong,
        .markdown-content b {
            font-weight: 700;
            color: var(--portal-ink);
        }

        .markdown-content em,
        .markdown-content i {
            font-style: italic;
        }

        .markdown-content p {
            margin: 6px 0;
            line-height: 1.4;
        }

        .markdown-content ul,
        .markdown-content ol {
            margin: 4px 0;
            padding-left: 24px;
        }

        .markdown-content li {
            margin: 2px 0;
            line-height: 1.4;
        }

        .markdown-content code {
            background: #f0f4f8;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            color: #d63384;
        }

        .markdown-content pre {
            background: #f0f4f8;
            border: 1px solid var(--portal-border);
            border-radius: 8px;
            padding: 12px;
            overflow-x: auto;
            margin: 8px 0;
        }

        .markdown-content pre code {
            background: transparent;
            padding: 0;
            color: var(--portal-ink);
        }

        .markdown-content blockquote {
            border-left: 4px solid var(--portal-primary);
            padding-left: 12px;
            margin: 8px 0;
            color: var(--portal-ink-muted);
            font-style: italic;
        }

        .markdown-content a {
            color: var(--portal-primary);
            text-decoration: none;
        }

        .markdown-content a:hover {
            text-decoration: underline;
        }

        .markdown-content hr {
            border: none;
            border-top: 1px solid var(--portal-border);
            margin: 12px 0;
        }

        header {
            z-index: 100;
            min-height: 88px;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(120deg, var(--portal-primary-deep) 0%, var(--portal-primary) 48%, var(--portal-accent) 100%);
            color: white;
            padding: 20px 30px;
            box-shadow: 0 14px 35px rgba(8, 61, 116, 0.28);
            position: sticky;
            top: 0;
        }

        .header-title {
            font-size: 1.2rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            text-align: center;
            z-index: 110;
            text-shadow: 0 1px 12px rgba(0, 0, 0, 0.16);
        }

        .header-user-mode {
            position: absolute;
            right: 72px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            z-index: 111;
            color: #eaf3ff;
            font-size: 12px;
            font-weight: 600;
        }

        .header-mode-dropdown {
            height: 34px;
            min-width: 165px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.45);
            background: rgba(9, 46, 84, 0.48);
            color: #ffffff;
            padding: 0 10px;
        }

        .header-mode-dropdown option {
            color: #1f2d3d;
        }

        .portal-layout-shell {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-top: 0;
            min-height: calc(100vh - 150px);
        }

        .portal-layout-shell.main-menu-collapsed {
            gap: 8px;
        }

        .portal-left-nav {
            width: 164px;
            flex: 0 0 164px;
            position: sticky;
            top: 88px;
            background: linear-gradient(180deg, #061947 0%, #071e59 48%, #03102e 100%);
            border-radius: 0 0 12px 12px;
            padding: 10px 8px 14px;
            box-shadow: 0 12px 28px rgba(3, 16, 46, 0.30);
            min-height: calc(100vh - 88px);
            max-height: calc(100vh - 88px);
            align-self: flex-start;
            transition: width 0.22s ease, flex-basis 0.22s ease, padding 0.22s ease, opacity 0.2s ease;
            overflow-y: auto;
            overflow-x: hidden;
            z-index: 90;
        }

        .portal-left-nav.is-collapsed {
            width: 72px;
            flex: 0 0 72px;
            min-height: calc(100vh - 88px);
            padding: 8px 6px 12px;
            opacity: 1;
            box-shadow: 0 10px 22px rgba(3, 16, 46, 0.24);
            border: 1px solid rgba(123, 165, 227, 0.26);
            pointer-events: auto;
        }

        .portal-left-nav-title {
            color: #ffffff;
            font-size: 17px;
            font-weight: 800;
            margin: 0 6px 18px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            padding: 8px 6px;
            border-bottom: 2px solid rgba(15, 110, 184, 0.4);
            display: flex;
            align-items: center;
        }

        .portal-section-header {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            margin: 0 0 8px;
            padding: 0;
            border-bottom: none;
        }

        .portal-section-header .portal-left-nav-title {
            margin: 0;
            padding: 0;
            border-bottom: none;
        }

        .portal-collapse-btn {
            border: 1px solid rgba(159, 195, 231, 0.55);
            background: rgba(255, 255, 255, 0.12);
            color: #eaf4ff;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 900;
            min-height: 28px;
            min-width: 38px;
            padding: 4px 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        #mainMenuToggleBtn {
            min-width: 30px;
            min-height: 30px;
            width: 30px;
            height: 30px;
            padding: 0;
            border: 1px solid rgba(173, 206, 240, 0.72);
            background: rgba(255, 255, 255, 0.16);
            font-size: 12px;
            box-shadow: 0 5px 12px rgba(4, 23, 54, 0.28);
        }

        .portal-collapse-btn:hover {
            background: rgba(15, 110, 184, 0.28);
            border-color: rgba(159, 195, 231, 0.9);
        }

        .portal-collapse-btn .toggle-chevron { line-height: 1; }

        .collapsible-body.is-collapsed {
            display: none !important;
        }

        .portal-left-nav .portal-nav-link {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 9px;
            margin: 0 0 7px;
            border-radius: 9px;
            color: #f4f8fc;
            text-decoration: none;
            font-size: 12px;
            font-weight: 750;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(137, 173, 255, 0.15);
            text-align: left;
            transition: all 0.2s ease-in-out;
            position: relative;
            overflow: hidden;
        }

        .portal-left-nav .portal-nav-link:before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 3px;
            height: 100%;
            background: linear-gradient(180deg, #0f6eb8 0%, #0a4a7a 100%);
            transform: scaleY(0);
            transform-origin: top;
            transition: transform 0.2s ease-in-out;
        }

        .portal-left-nav .portal-nav-link:hover {
            background: rgba(59, 130, 246, 0.34);
            color: #ffffff;
            text-decoration: none;
            border-color: rgba(147, 197, 253, 0.42);
            box-shadow: 0 6px 14px rgba(8, 47, 118, 0.25), inset 0 0 10px rgba(255, 255, 255, 0.06);
            transform: translateX(2px);
        }

        .portal-left-nav .portal-nav-link:hover:before {
            transform: scaleY(1);
        }

        .portal-left-nav .portal-nav-link:active {
            background: rgba(15, 110, 184, 0.5);
            color: #ffffff;
        }

        .portal-left-nav .portal-nav-link.is-active {
            background: linear-gradient(90deg, rgba(88, 166, 255, 0.28), rgba(255, 255, 255, 0.10));
            color: #ffffff;
            border-color: rgba(162, 207, 255, 0.72);
            box-shadow: inset 4px 0 0 #73c7ff, 0 8px 18px rgba(8, 47, 118, 0.22);
        }

        .portal-left-nav .portal-nav-link.is-active:before {
            transform: scaleY(1);
        }

        .portal-left-nav.is-collapsed .portal-section-header {
            justify-content: center;
            margin: 0 0 10px;
        }

        .portal-left-nav.is-collapsed .collapsible-body.is-collapsed {
            display: block !important;
        }

        .portal-left-nav.is-collapsed .portal-nav-link {
            justify-content: center;
            gap: 0;
            padding: 10px 0;
            min-height: 40px;
        }

        .portal-left-nav.is-collapsed .portal-nav-link span {
            display: none;
        }

        .portal-left-nav.is-collapsed .portal-nav-link i {
            margin: 0;
            font-size: 15px;
        }

        .portal-nav-active-title {
            margin: 0 4px 12px;
            text-align: left;
            color: #b8dcff;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            padding: 0 2px 8px;
            border-bottom: 1px solid rgba(143, 185, 242, 0.25);
            background: transparent;
        }

        .portal-left-nav.is-collapsed .portal-nav-active-title {
            display: block;
            margin: 2px 2px 8px;
            padding: 5px 4px;
            font-size: 10px;
            letter-spacing: 0.02em;
            line-height: 1.2;
        }

        .portal-main-workspace {
            flex: 1;
            min-width: 0;
        }

        .portal-menu-reopen {
            display: none;
            align-items: center;
            justify-content: center;
            position: sticky;
            top: 96px;
            min-height: 34px;
            min-width: 42px;
            margin-top: 8px;
            border: 1px solid #b7cce0;
            border-radius: 10px;
            background: #f1f7ff;
            color: #1c4e78;
            font-size: 12px;
            font-weight: 700;
            padding: 0 10px;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(16, 45, 74, 0.12);
            z-index: 95;
        }

        .portal-menu-reopen:hover {
            background: #e4f1ff;
            border-color: #8eb3d7;
        }

        .portal-layout-shell.main-menu-collapsed .portal-menu-reopen {
            display: inline-flex;
        }

        .portal-layout-shell.main-menu-collapsed .portal-menu-reopen {
            display: none !important;
        }

        .welcome-home-panel {
            background: #ffffff;
            border: 1px solid #d7e2ed;
            border-radius: 12px;
            padding: 22px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            margin-bottom: 14px;
        }

        .welcome-home-title {
            margin: 0 0 8px;
            color: #0f4f8a;
            font-size: 28px;
            font-weight: 700;
        }

        .welcome-home-desc {
            margin: 0;
            color: #495e73;
            font-size: 15px;
            line-height: 1.5;
        }

        .cmf-rules-editor-shell {
            display: grid;
            grid-template-columns: minmax(0, 1.4fr) minmax(280px, .8fr);
            gap: 18px;
            margin-top: 18px;
        }

        .cmf-rules-card {
            border: 1px solid #d7e2ed;
            border-radius: 10px;
            background: #fbfdff;
            padding: 16px;
        }

        .cmf-rules-title {
            margin: 0 0 6px;
            color: #143a5a;
            font-size: 16px;
            font-weight: 700;
        }

        .cmf-rules-editor {
            width: 100%;
            min-height: 360px;
            border: 1px solid #c8d9ea;
            border-radius: 8px;
            padding: 12px;
            font-family: Consolas, 'Courier New', monospace;
            font-size: 13px;
            line-height: 1.45;
            color: #18324a;
            background: #ffffff;
        }

        .cmf-rules-actions {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
            margin-top: 12px;
        }

        .cmf-rules-status {
            display: block;
            margin-top: 10px;
            font-size: 13px;
            font-weight: 600;
        }

        .cmf-rules-note {
            margin: 10px 0 0;
            color: #4c6378;
            font-size: 13px;
            line-height: 1.5;
        }

        .cmf-rules-list {
            margin: 10px 0 0;
            padding-left: 18px;
            color: #30495f;
            font-size: 13px;
            line-height: 1.6;
        }

        @media (max-width: 900px) {
            .cmf-rules-editor-shell {
                grid-template-columns: 1fr;
            }
        }

        .home-dashboard-shell {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .home-dashboard-hero {
            display: flex;
            justify-content: space-between;
            gap: 18px;
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .home-dashboard-hero-copy {
            flex: 1 1 460px;
        }

        .home-dashboard-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            border-radius: 999px;
            background: rgba(15, 94, 168, 0.10);
            color: #0f5ea8;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .home-dashboard-hero-actions {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }

        .home-dashboard-pill-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            text-decoration: none;
            border: 1px solid #bfd3e7;
            background: #f7fbff;
            color: #0f4f8a;
            font-size: 13px;
            font-weight: 600;
        }

        .home-dashboard-pill-link:hover {
            text-decoration: none;
            background: #eef6fd;
            color: #083d74;
        }

        .home-dashboard-generated {
            font-size: 12px;
            color: #5c7087;
        }

        .home-dashboard-metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 14px;
        }

        .home-dashboard-metric-card {
            position: relative;
            overflow: hidden;
            background: linear-gradient(180deg, #ffffff 0%, #f8fbfe 100%);
            border: 1px solid #d7e2ed;
            border-radius: 16px;
            padding: 16px 18px;
            box-shadow: 0 10px 22px rgba(16, 41, 67, 0.08);
            transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
        }

        .home-dashboard-metric-card:hover {
            transform: translateY(-2px);
            border-color: #b8d4ee;
            box-shadow: 0 16px 30px rgba(16, 41, 67, 0.12);
        }

        .home-dashboard-metric-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 8px;
        }

        .home-dashboard-metric-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 34px;
            height: 34px;
            border-radius: 12px;
            color: #ffffff;
            box-shadow: 0 10px 18px rgba(16, 41, 67, 0.12);
        }

        .home-dashboard-metric-card:nth-child(1) .home-dashboard-metric-icon { background: #ef4444; }
        .home-dashboard-metric-card:nth-child(2) .home-dashboard-metric-icon { background: #f59e0b; }
        .home-dashboard-metric-card:nth-child(3) .home-dashboard-metric-icon { background: #10b981; }
        .home-dashboard-metric-card:nth-child(4) .home-dashboard-metric-icon { background: #3b82f6; }
        .home-dashboard-metric-card:nth-child(5) .home-dashboard-metric-icon { background: #8b5cf6; }

        .home-dashboard-metric-spark {
            display: flex;
            align-items: flex-end;
            gap: 3px;
            height: 24px;
            margin-top: 10px;
        }

        .home-dashboard-metric-spark span {
            display: block;
            width: 12px;
            border-radius: 999px;
            background: #d7e6f5;
        }

        .home-dashboard-metric-spark span:nth-child(1) { height: 8px; }
        .home-dashboard-metric-spark span:nth-child(2) { height: 13px; }
        .home-dashboard-metric-spark span:nth-child(3) { height: 10px; }
        .home-dashboard-metric-spark span:nth-child(4) { height: 18px; }
        .home-dashboard-metric-spark span:nth-child(5) { height: 14px; }

        .home-dashboard-metric-card:nth-child(1) .home-dashboard-metric-spark span { background: #fecaca; }
        .home-dashboard-metric-card:nth-child(2) .home-dashboard-metric-spark span { background: #fed7aa; }
        .home-dashboard-metric-card:nth-child(3) .home-dashboard-metric-spark span { background: #bbf7d0; }
        .home-dashboard-metric-card:nth-child(4) .home-dashboard-metric-spark span { background: #bfdbfe; }
        .home-dashboard-metric-card:nth-child(5) .home-dashboard-metric-spark span { background: #ddd6fe; }

        .home-dashboard-metric-label {
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #698096;
            margin-bottom: 8px;
        }

        .home-dashboard-metric-value {
            font-size: 30px;
            line-height: 1;
            font-weight: 800;
            color: #15395b;
            margin-bottom: 6px;
        }

        .home-dashboard-metric-note {
            font-size: 12px;
            color: #5c7087;
        }

        .home-ai-panels {
            display: grid;
            grid-template-columns: minmax(0, 0.95fr) minmax(0, 1.05fr);
            gap: 14px;
        }

        .home-ai-card {
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #ffffff 0%, #f3f8fc 100%);
            border: 1px solid #d4e2ef;
            border-radius: 14px;
            padding: 16px;
            box-shadow: 0 10px 22px rgba(16, 41, 67, 0.08);
        }

        .home-ai-card:before {
            content: "";
            position: absolute;
            inset: 0 auto 0 0;
            width: 4px;
            background: linear-gradient(180deg, #0068b5, #00a6b2);
        }

        .home-ai-card-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
        }

        .home-ai-card-title {
            margin: 0;
            color: #103a5c;
            font-size: 16px;
            font-weight: 800;
        }

        .home-ai-card-subtitle {
            margin: 4px 0 0;
            color: #5c7087;
            font-size: 12px;
        }

        .home-ai-card-icon {
            width: 36px;
            height: 36px;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            background: #0f5ea8;
            box-shadow: 0 10px 18px rgba(15, 94, 168, 0.18);
        }

        .home-ai-tracker-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 10px;
        }

        .home-ai-tracker-item {
            border: 1px solid #dfebf5;
            border-radius: 10px;
            background: #fbfdff;
            padding: 10px;
        }

        .home-ai-tracker-label {
            color: #647990;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .home-ai-tracker-value {
            margin-top: 6px;
            color: #0f4f8a;
            font-size: 24px;
            font-weight: 900;
            line-height: 1;
        }

        .home-ai-summary-list {
            margin: 0;
            padding: 0;
            list-style: none;
            display: grid;
            gap: 8px;
            color: #263d54;
            font-size: 13px;
            line-height: 1.4;
        }

        .home-ai-summary-list li {
            display: flex;
            gap: 8px;
            align-items: flex-start;
        }

        .home-ai-summary-list i {
            color: #0f5ea8;
            margin-top: 2px;
        }

        .home-dashboard-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.55fr) minmax(320px, 1fr);
            gap: 18px;
        }

        .home-dashboard-panel {
            background: #ffffff;
            border: 1px solid #d7e2ed;
            border-radius: 16px;
            box-shadow: 0 10px 22px rgba(16, 41, 67, 0.08);
            padding: 18px;
        }

        .home-dashboard-panel-head {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        .home-dashboard-panel-title {
            margin: 0;
            color: #0f4f8a;
            font-size: 20px;
            font-weight: 700;
        }

        .home-dashboard-panel-subtitle {
            margin: 4px 0 0;
            color: #5c7087;
            font-size: 13px;
        }

        .home-dashboard-chart {
            width: 100%;
            height: 320px;
        }

        .home-dashboard-chart-compact {
            width: 100%;
            height: 260px;
        }

        .home-dashboard-side-stack {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .home-dashboard-list {
            list-style: none;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .home-dashboard-list-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            border: 1px solid #e1eaf2;
            border-radius: 12px;
            padding: 12px 14px;
            background: #fbfdff;
        }

        .home-dashboard-list-label {
            font-size: 13px;
            font-weight: 600;
            color: #1f3b57;
        }

        .home-dashboard-list-value {
            min-width: 46px;
            text-align: right;
            font-size: 18px;
            font-weight: 800;
            color: #0f5ea8;
        }

        @media (max-width: 1120px) {
            .home-dashboard-grid {
                grid-template-columns: 1fr;
            }

            .home-ai-panels {
                grid-template-columns: 1fr;
            }
        }

        .sidebar-toggle {
            background: rgba(255, 255, 255, 0.14);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.24);
            font-size: 16px;
            cursor: pointer;
            z-index: 10;
            border-radius: 999px;
            width: 42px;
            height: 42px;
            backdrop-filter: blur(8px);
        }

        .sidebar-toggle-div {
            position: absolute;
            right: 1.2rem;
            display: none !important;
        }

        .sidebar {
            font-size: 12px;
            position: fixed;
            top: 0;
            right: -280px;
            height: 100%;
            width: 250px;
            background: linear-gradient(180deg, #0b417b 0%, #0f5ea8 100%);
            padding-top: 68px;
            transition: right 0.3s ease-in-out;
            z-index: 120;
            overflow-y: auto;
            box-shadow: -16px 0 32px rgba(5, 25, 48, 0.22);
        }

        .close-btn {
            position: absolute;
            top: 12px;
            right: 14px;
            background-color: transparent;
            color: white;
            font-size: 20px;
            border: none;
            cursor: pointer;
        }

        .sidebar a {
            color: #eef7ff;
            padding: 12px 20px;
            text-decoration: none;
            display: block;
            font-size: 12px;
        }

        .sidebar a:hover {
            background-color: rgba(255, 255, 255, 0.12);
        }

        .content-wrapper {
            margin: 18px 18px 28px;
            padding: 24px;
            background: rgba(255, 255, 255, 0.74);
            border: 1px solid rgba(205, 217, 229, 0.9);
            border-radius: 24px;
            box-shadow: var(--portal-shadow);
            min-height: calc(100vh - 160px);
            backdrop-filter: blur(10px);
        }

        .table-container {
            margin-top: 0;
            position: relative;
            width: 100%;
            max-height: 75vh;
            overflow-y: auto;
            border-radius: var(--portal-radius);
            box-shadow: 0 12px 30px rgba(21, 49, 79, 0.10);
            background-color: var(--portal-surface);
            border: 1px solid var(--portal-border);
            padding: 10px;
        }

            /* Make the header sticky */
            .table-container thead {
                position: sticky;
                top: 0;
                background-color: #fff; /* Set a background color to cover any content scrolling beneath */
                z-index: 1; /* Keep the header above the rows */
            }

        
        .table-primary {
            font-weight: 600;
            font-family: "Segoe UI", sans-serif;
            border-collapse: separate;
            border-spacing: 0;
            font-size: .82em;
            border-radius: 14px;
            overflow: hidden;
            transition: box-shadow 0.3s ease;
            border: 1px solid var(--portal-border);
            margin-bottom: 10px;
            background: var(--portal-surface);
        }

        .table-primary th, .table-primary td {
            padding: 12px 14px;
            text-align: left;
            border: 1px solid #d7e0ea;
        }

        .table-primary thead {
            position: sticky;
            top: 0; /* Stick the header to the top */
            background-color: #fff; /* Ensure header has a solid background */
            z-index: 2; /* Make sure header stays on top of rows */
            box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.1); /* Optional, to add a shadow */
        }

        .table-primary th {
            background: linear-gradient(180deg, #1568b3 0%, #0f5ea8 100%);
            color: white;
            font-weight: 700;
        }

        .table-primary tr {
            border-bottom: 1px solid #d7e0ea;
        }

                .component-with-group,
                .owner-pair,
                .status-cell-wrap-compact {
                    display: flex;
                    flex-direction: column;
                    gap: 14px;
                }

                .component-with-group,
                .owner-pair {
                    gap: 16px;
                }

                .component-detail {
                    font-size: 12px;
                    color: #374151;
                    word-break: break-word;
                    overflow-wrap: anywhere;
                    line-height: 1.5;
                }

                .component-group-pill {
                    display: inline-flex;
                    align-self: flex-start;
                    align-items: center;
                    justify-content: center;
                    min-height: 20px;
                    padding: 2px 10px;
                    border-radius: 999px;
                    font-size: 10px;
                    font-weight: 700;
                    letter-spacing: 0.04em;
                    text-transform: uppercase;
                    background: #eef4fb;
                    color: #0f5ea8;
                    border: 1px solid #cfe0f1;
                }

                .owner-inline-row {
                    display: flex;
                    align-items: baseline;
                    gap: 5px;
                    flex-wrap: wrap;
                }

                .owner-inline-label {
                    font-size: 11px;
                    font-weight: 600;
                    color: #6b7280;
                    white-space: nowrap;
                    flex-shrink: 0;
                }

                .owner-inline-value {
                    font-size: 13px;
                    color: #1b2a3a;
                    font-weight: 500;
                    word-break: break-word;
                }

                .owner-inline-muted {
                    color: #9ca3af;
                    font-weight: 400;
                }

                .status-cell-wrap-compact {
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 6px;
                    min-width: 0;
                }

                .status-main {
                    display: block;
                    padding: 0;
                    margin: 0;
                    border: 0;
                    background: transparent;
                    color: #23364b;
                    font-size: 12px;
                    font-weight: 600;
                    line-height: 1.4;
                    white-space: normal;
                    overflow-wrap: anywhere;
                    word-break: break-word;
                }

                .ai-summary-btn-compact {
                    height: 24px;
                    padding: 0 8px;
                    border-radius: 999px;
                    font-size: 10px;
                    margin-top: 2px;
                }

                /* New status cell layout */
                .status-row {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    width: 100%;
                    min-width: 0;
                }

                .status-row-primary {
                    justify-content: flex-start;
                    flex-wrap: wrap;
                }

                .status-row-confidence {
                    margin-top: 0;
                }

                .status-label-group {
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    flex-wrap: wrap;
                    min-width: 0;
                }

                .status-pill {
                    display: inline-flex;
                    align-items: center;
                    padding: 6px 10px;
                    border-radius: 999px;
                    font-size: 12px;
                    font-weight: 700;
                    background: #eef4fb;
                    color: #0f5ea8;
                    border: 1px solid #cfe0f1;
                    max-width: 100%;
                    white-space: normal;
                    overflow-wrap: anywhere;
                }

                .status-confidence-pill {
                    display: inline-flex;
                    align-items: center;
                    min-height: 22px;
                    padding: 4px 8px;
                    border-radius: 999px;
                    font-size: 10px;
                    font-weight: 800;
                    color: #5b21b6;
                    background: #f4efff;
                    border: 1px solid #dfd2ff;
                    white-space: normal;
                    overflow-wrap: anywhere;
                }

                .ai-summary-btn-inline {
                    height: 22px;
                    min-width: 26px;
                    padding: 0 8px;
                    border-radius: 999px;
                    font-size: 11px;
                    background: transparent;
                    border: none;
                    color: #6b7280;
                    cursor: pointer;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                }

                .ai-summary-btn-inline:hover {
                    background: rgba(15,94,168,0.06);
                    color: #0f5ea8;
                }

                .status-one-line {
                    display: block;
                    font-size: 11px;
                    line-height: 1.35;
                    color: #35516d;
                    margin-top: 2px;
                    width: 100%;
                    max-width: 100%;
                    white-space: normal;
                    overflow: hidden;
                    overflow-wrap: break-word;
                    word-break: normal;
                }

                .issue-grid-toolbar {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 4px 2px 6px;
                }

                .show-cols-btn {
                    font-size: 12px;
                    padding: 3px 10px;
                    border: 1px solid #aab;
                    border-radius: 4px;
                    background: #f4f6fa;
                    cursor: pointer;
                    color: #2a4a7f;
                }

                .show-cols-btn:hover {
                    background: #e2e8f4;
                }

                .col-hide-btn {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    width: 18px;
                    height: 18px;
                    margin-left: 5px;
                    padding: 0;
                    font-size: 11px;
                    line-height: 1;
                    border: 1px solid rgba(255,255,255,0.6);
                    border-radius: 3px;
                    background: rgba(255,255,255,0.18);
                    color: #fff;
                    cursor: pointer;
                    opacity: 0.85;
                    vertical-align: middle;
                    flex-shrink: 0;
                }

                .col-hide-btn:hover {
                    opacity: 1;
                    background: rgba(220,50,50,0.55);
                    border-color: #fff;
                }

                .issue-sno-cell {
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 6px;
                }

                .issue-sno-index {
                    font-weight: 700;
                    color: #1f3b57;
                }

                .issue-inline-edit-btn,
                .issue-inline-edit-action {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    width: 28px;
                    height: 28px;
                    border-radius: 999px;
                    border: 1px solid #c7d7e7;
                    background: #ffffff;
                    color: #0f5ea8;
                    text-decoration: none;
                    cursor: pointer;
                }

                .issue-inline-edit-btn:hover,
                .issue-inline-edit-action:hover {
                    background: #eef6fd;
                    color: #083d74;
                    text-decoration: none;
                }

                .issue-inline-edit-actions {
                    display: flex;
                    gap: 6px;
                }
/* Add these new styles */
.tab-content-wrapper {
    position: relative;
    width: 100%;
    padding-top: 0;
    margin-top: 0;
}

.pane-heading {
    position: relative;
    z-index: 10;
    background: linear-gradient(90deg, rgba(15, 94, 168, 0.10), rgba(0, 166, 178, 0.06));
    padding: 14px 18px;
    margin: 8px 0 18px;
    border: 1px solid rgba(15, 94, 168, 0.18);
    border-radius: 16px;
    font-weight: 700;
    font-size: 15px;
    color: var(--portal-primary-deep);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    text-align: center;
}

.modal-body.popup {
    position: relative;
    top: 0;
    margin-top: 0;
    padding-top: 0; /* Changed from 10px to 0 */
    padding-bottom: 10px;
}

.filter-header-container {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    width: 100%;
    min-height: 60px;
}

.filter-header-text {
    display: flex;
    align-items: center;
    gap: 4px;
    font-weight: bold;
    margin-bottom: 5px;
    align-self: center;
}

.filter-container {
    width: 100%;
    display: flex;
    justify-content: flex-end;
}

.header-dropdown {
    font-size: 11px;
    padding: 4px 8px;
    width: 132px;
    height: 30px;
    border: 1px solid #bfd0df;
    border-radius: 999px;
    background: #fff;
    color: var(--portal-ink);
}

/* RESTORE ORIGINAL TABLE STYLING FOR OTHER TABS */
.table-primary th {
    vertical-align: top;
    padding: 8px;
}

.gridview-container {
    position: relative;
    margin-top: 0;
    padding-top: 0;
    overflow-x: auto;
    width: 100%;
}

.empty-data-container {
    width: 100%;
    overflow-x: auto;
    margin-top: 0;
}

.empty-data-container table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 0;
}

.empty-data-container th {
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    padding: 8px;
    text-align: left;
}

.empty-data-container td {
    border: 1px solid #dee2e6;
    padding: 8px;
}

/* Modern compact Issue List table */
#overall_request_details {
    margin-top: 0 !important;
    position: relative !important;
    z-index: 100 !important;
    border-collapse: separate !important;
    border-spacing: 0 8px !important;
    background: transparent !important;
    border: 0 !important;
}

#overall_request_details thead {
    display: table-header-group !important;
    background: transparent !important;
    position: sticky !important;
    top: 0 !important;
    z-index: 101 !important;
}

#overall_request_details th {
    background: #f6f8fb !important;
    color: #475569 !important;
    font-size: 10px !important;
    padding: 10px 10px !important;
    height: auto !important;
    min-height: 34px !important;
    border-top: 1px solid #e5ebf3 !important;
    border-bottom: 1px solid #e5ebf3 !important;
    border-left: 0 !important;
    border-right: 0 !important;
    display: table-cell !important;
    visibility: visible !important;
    opacity: 1 !important;
    position: relative !important;
    z-index: 102 !important;
    text-align: left !important;
    font-weight: 800 !important;
    letter-spacing: 0.05em !important;
    text-transform: uppercase !important;
    vertical-align: middle !important;
}

#overall_request_details td {
    background: #ffffff !important;
    border-top: 1px solid #e6edf5 !important;
    border-bottom: 1px solid #e6edf5 !important;
    border-left: 0 !important;
    border-right: 0 !important;
    padding: 12px 10px !important;
    box-shadow: 0 8px 22px rgba(20, 46, 77, 0.06) !important;
}

#overall_request_details tr,
#overall_request_details tr:first-child,
#overall_request_details tr:nth-child(even),
#overall_request_details tr:nth-child(odd) {
    background: transparent !important;
    border-bottom: 0 !important;
}

#overall_request_details tr td:first-child {
    border-left: 1px solid #e6edf5 !important;
    border-radius: 8px 0 0 8px !important;
}

#overall_request_details tr td:last-child {
    border-right: 1px solid #e6edf5 !important;
    border-radius: 0 8px 8px 0 !important;
}

/* Keep table headers clean; filters are shown above the table */
#overall_request_details th .filter-header-container {
    display: flex !important;
    flex-direction: column !important;
    align-items: flex-start !important;
    width: 100% !important;
    min-height: auto !important;
}

#overall_request_details th .filter-header-text {
    font-weight: bold !important;
    margin-bottom: 0 !important;
    align-self: flex-start !important;
    color: #475569 !important;
}

#overall_request_details th .filter-container {
    display: none !important;
}

.empty-data-container .filter-container {
    display: none !important;
}

.issue-top-filter-panel {
    padding: 12px;
    margin: 8px 0 10px !important;
    border-radius: 12px !important;
    background: #ffffff !important;
    border: 1px solid #e4ebf3 !important;
    box-shadow: 0 8px 22px rgba(20, 46, 77, 0.05) !important;
}

.issue-filter-section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 10px;
    padding-bottom: 8px;
    border-bottom: 1px solid #d7e2ed;
}

.issue-filter-title {
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.03em;
    text-transform: uppercase;
    color: #34506a;
}

.issue-collapse-btn {
    border: 1px solid #b8ccdf;
    background: #f2f8ff;
    color: #184a72;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 700;
    min-height: 26px;
    min-width: 70px;
    padding: 4px 10px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    cursor: pointer;
}

.issue-collapse-btn:hover {
    background: #e4f1ff;
    border-color: #8fb3d6;
}

.issue-collapse-btn .toggle-chevron {
    transition: transform 0.2s ease;
}

.issue-collapse-btn[aria-expanded="false"] .toggle-chevron {
    transform: rotate(-90deg);
}

.issue-top-filter-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(128px, 1fr));
    gap: 8px;
    margin-bottom: 10px;
}

.issue-top-filter-item {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.issue-top-filter-item span {
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: #616161;
    font-weight: 700;
}

.issue-top-filter-item .header-dropdown {
    width: 100% !important;
    height: 30px;
    font-size: 11px !important;
    border-radius: 8px !important;
}

.issue-top-filter-buttons {
    display: flex;
    gap: 8px;
    justify-content: flex-start;
}

.filter-btn {
    padding: 7px 16px;
    border: none;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    text-transform: capitalize;
    transition: all 0.2s ease;
}

#overall_request_details .col-hide-btn {
    display: none !important;
}

.filter-btn-primary {
    background: #0068b5;
    color: #ffffff;
}

.filter-btn-primary:hover {
    background: #005a9e;
    box-shadow: 0 2px 8px rgba(0, 104, 181, 0.3);
}

.filter-btn-secondary {
    background: #e8e8e8;
    color: #2a2a2a;
    border: 1px solid #d0d0d0;
}

.filter-btn-secondary:hover {
    background: #d8d8d8;
}

.status-cell-wrap {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.status-main {
    font-weight: 700;
    color: #23364b;
}

.sysdebug-preview {
    font-size: 11px;
    color: #5a6d80;
    max-height: 54px;
    overflow: hidden;
}

.ai-summary-btn {
    align-self: flex-start;
    height: 28px;
    padding: 0 10px;
    border-radius: 14px;
    font-size: 11px;
    border: 1px solid #0f5ea8;
    color: #0f5ea8;
    background: #ffffff;
}

.ai-summary-btn:hover {
    background: #eff6ff;
}

.ai-recommendation-btn {
    align-self: flex-start;
    height: 28px;
    padding: 0 10px;
    border-radius: 14px;
    font-size: 11px;
    border: 1px solid #107c10;
    color: #107c10;
    background: #ffffff;
}

.ai-recommendation-btn:hover {
    background: #f0f9f5;
}

.ai-summary-body {
    background: linear-gradient(180deg, #ffffff 0%, #f7fbff 100%);
    border: 1px solid #d8e3ee;
    border-radius: 14px;
    padding: 14px;
    white-space: normal;
    line-height: 1.45;
    font-size: 13px;
    color: #21384d;
    box-shadow: 0 12px 28px rgba(16, 41, 67, 0.08);
}

.ai-summary-body ul,
.ai-summary-body ol {
    margin: 0;
    padding-left: 0;
    list-style: none;
    display: grid;
    gap: 10px;
}

.ai-summary-body li {
    position: relative;
    padding: 10px 12px 10px 34px;
    border: 1px solid #e3edf7;
    border-radius: 12px;
    background: #ffffff;
    box-shadow: 0 6px 16px rgba(16, 41, 67, 0.05);
}

.ai-summary-body li::before {
    content: "\2726";
    position: absolute;
    left: 12px;
    top: 10px;
    color: #7c3aed;
    font-size: 12px;
    line-height: 1;
}

.cmf-rec-quality-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 12px 14px;
    background: #f8fbff;
    border: 1px solid #dbe7f4;
    border-radius: 10px;
    margin-bottom: 16px;
}

.cmf-rec-hero {
    display: grid;
    gap: 12px;
    margin-top: 16px;
}

.cmf-rec-section {
    margin-top: 16px;
}

.cmf-rec-section h3 {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 12px !important;
    font-weight: 850 !important;
    color: #344761 !important;
    margin: 0 0 8px !important;
    text-transform: uppercase;
    letter-spacing: 0.06em;
}

.cmf-rec-decision-card {
    border-left: 4px solid #7c3aed !important;
    background: linear-gradient(135deg, #fbf8ff 0%, #eef7ff 100%) !important;
}

.cmf-rec-title-row {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    flex-wrap: wrap;
}

.cmf-rec-title-text {
    flex: 1 1 180px;
    min-width: 0;
}

.cmf-rec-decision-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 28px;
    padding: 5px 12px;
    border-radius: 999px;
    border: 1px solid #f2c94c;
    background: linear-gradient(180deg, #fff7d6 0%, #ffe8a3 100%);
    color: #684600;
    font-size: 12px;
    font-weight: 650;
    box-shadow: 0 10px 22px rgba(245, 158, 11, 0.18);
    max-width: 100%;
    overflow-wrap: anywhere;
}

.cmf-rec-placeholder-actions {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 10px;
    margin-top: 12px;
}

.cmf-rec-placeholder-btn {
    min-height: 38px;
    border-radius: 10px;
    border: 1px solid #d8c9ff;
    background: #ffffff;
    color: #5b21b6;
    font-size: 12px;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 8px 20px rgba(124, 58, 237, 0.10);
}

.cmf-rec-placeholder-btn.primary {
    background: #7c3aed;
    border-color: #7c3aed;
    color: #ffffff;
}

.cmf-rec-placeholder-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 12px 24px rgba(124, 58, 237, 0.16);
}

.cmf-rec-quality-label {
    font-size: 11px;
    font-weight: 800;
    color: #5d7289;
    text-transform: uppercase;
    letter-spacing: 0.03em;
}

.cmf-rec-quality-value {
    margin-top: 4px;
    font-size: 14px;
    font-weight: 850;
    color: #0f5ea8;
    line-height: 1.35;
}

.cmf-rec-quality-line {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
    min-width: 260px;
}

.cmf-rec-quality-line span { color: #5d7289; }
.cmf-rec-quality-line strong { color: #0f5ea8; font-size: 18px; }

.reports-format-textarea.is-readonly {
    background: #f8fbff;
    color: #263b50;
    cursor: default;
}

.cmf-rec-score-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 16px;
}

.cmf-rec-score-item {
    display: grid;
    grid-template-columns: 24px minmax(0, 1fr) auto;
    gap: 9px;
    align-items: flex-start;
    padding: 10px 11px;
    border: 1px solid #e1e8f0;
    border-radius: 9px;
    background: #ffffff;
}

.cmf-rec-score-icon {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 900;
}

.cmf-rec-score-icon.pass { background: #dcfce7; color: #15803d; }
.cmf-rec-score-icon.partial { background: #fef3c7; color: #b45309; }
.cmf-rec-score-icon.fail { background: #fee2e2; color: #b91c1c; }

.cmf-rec-score-title {
    font-size: 12px;
    font-weight: 800;
    color: #20354a;
    margin-bottom: 2px;
}

.cmf-rec-score-detail {
    font-size: 11px;
    color: #5d7289;
    line-height: 1.35;
}

.cmf-rec-score-value {
    font-size: 12px;
    font-weight: 850;
    color: #0f5ea8;
    white-space: nowrap;
}

.ai-summary-drawer-bg {
    position: fixed;
    inset: 0;
    background: rgba(16, 31, 52, 0.48);
    display: none;
    z-index: 1060;
    backdrop-filter: blur(5px);
}

.ai-summary-drawer-bg.show {
    display: block;
}

.ai-summary-drawer {
    position: fixed;
    top: 0;
    right: 0;
    width: 560px;
    max-width: 94vw;
    height: 100%;
    background:
        radial-gradient(circle at top right, rgba(124, 58, 237, 0.12), transparent 34%),
        linear-gradient(180deg, #ffffff 0%, #f6f9fd 100%);
    box-shadow: -18px 0 42px rgba(8, 25, 49, 0.24);
    transform: translateX(100%);
    transition: transform 0.28s ease;
    z-index: 1061;
    overflow-y: auto;
    padding: 24px;
    border-left: 1px solid rgba(205, 217, 229, 0.9);
}

.ai-summary-drawer.show {
    transform: translateX(0);
}

.ai-summary-drawer-close {
    position: absolute;
    top: 14px;
    right: 16px;
    border: none;
    background: transparent;
    color: #6b7a90;
    font-size: 24px;
    line-height: 1;
    cursor: pointer;
}

.ai-summary-drawer-title {
    margin: 0 0 12px 0;
    padding-right: 28px;
    font-size: 22px;
    color: #1b2a3a;
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.ai-summary-confidence-inline {
    display: inline-flex;
    align-items: center;
    min-height: 24px;
    padding: 3px 9px;
    border-radius: 999px;
    background: #eef6ff;
    border: 1px solid #c8def6;
    color: #0f5ea8;
    font-size: 12px;
    font-weight: 800;
}

.ai-summary-meta-row {
    margin-bottom: 10px;
    color: #23364b;
    font-size: 13px;
    padding: 9px 11px;
    border: 1px solid #e2ebf4;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.72);
}

.ai-summary-meta-combined {
    display: flex;
    align-items: center;
    gap: 7px;
    flex-wrap: wrap;
}

.ai-summary-meta-row strong {
    color: #1b2a3a;
}

.ai-summary-title-badges {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}

.ai-summary-facts {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 10px;
    margin: 12px 0 14px;
}

.ai-summary-fact {
    min-height: 58px;
    padding: 10px 12px;
    border: 1px solid #e2ebf4;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.76);
    box-shadow: 0 8px 18px rgba(16, 41, 67, 0.05);
}

.ai-summary-fact-label {
    display: block;
    color: #6a7d92;
    font-size: 10px;
    font-weight: 850;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    margin-bottom: 5px;
}

.ai-summary-fact-value {
    color: #19324a;
    font-size: 13px;
    font-weight: 750;
    overflow-wrap: anywhere;
}

.ai-summary-status-value {
    display: inline-flex;
    align-items: center;
    min-height: 24px;
    padding: 4px 10px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 850;
    border: 1px solid #cfdcea;
    background: #f4f7fb;
    color: #344761;
}

.ai-summary-status-value.status-open,
.ai-summary-status-value.status-active,
.ai-summary-status-value.status-progress {
    background: #eef6ff;
    border-color: #c8def6;
    color: #0f5ea8;
}

.ai-summary-status-value.status-closed,
.ai-summary-status-value.status-complete,
.ai-summary-status-value.status-implemented {
    background: #ecfdf3;
    border-color: #bbf7d0;
    color: #15803d;
}

.ai-summary-status-value.status-rejected {
    background: #fff1f2;
    border-color: #fecdd3;
    color: #be123c;
}

.ai-summary-status-value.status-pending,
.ai-summary-status-value.status-review {
    background: #fffbeb;
    border-color: #fde68a;
    color: #b45309;
}

.ai-summary-section-title {
    margin: 14px 0 8px;
    color: #344761;
    font-size: 12px;
    font-weight: 850;
    text-transform: uppercase;
    letter-spacing: 0.06em;
}

.ai-tag-label {
    display: inline-block;
    font-size: 10px;
    background: #7c3aed;
    color: #fff;
    padding: 2px 7px;
    border-radius: 10px;
    font-weight: 700;
    letter-spacing: .03em;
    vertical-align: middle;
    margin-left: 6px;
}

.ai-summary-actions {
    display: flex;
    gap: 10px;
    margin-top: 18px;
    padding-top: 14px;
    border-top: 1px solid #e8edf3;
    flex-wrap: wrap;
}

.ai-action-btn {
    flex: 1;
    min-width: 130px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    border: 1px solid #d1d9e3;
    background: #f4f6fa;
    color: #23364b;
    transition: background 0.15s, border-color 0.15s;
}

body {
    background:
        radial-gradient(circle at 8% 6%, rgba(0, 199, 253, 0.18), transparent 26%),
        radial-gradient(circle at 92% 10%, rgba(124, 58, 237, 0.13), transparent 30%),
        linear-gradient(180deg, #eef2f7 0%, #e7eef6 100%) !important;
}

.content-wrapper {
    background: rgba(255, 255, 255, 0.78) !important;
    border: 1px solid rgba(220, 229, 240, 0.95) !important;
    box-shadow: 0 1px 3px rgba(16,31,52,.08), 0 18px 44px rgba(16,31,52,.12) !important;
    backdrop-filter: blur(12px) !important;
}

.pane-heading {
    background: linear-gradient(120deg, #00377c 0%, #0068b5 72%, #00c7fd 100%) !important;
    color: #ffffff !important;
    border: 0 !important;
    box-shadow: 0 14px 32px rgba(0, 104, 181, 0.22) !important;
}

#overall_request_details {
    border-spacing: 0 10px !important;
}

#overall_request_details th {
    background: #ffffff !important;
    color: #5d6f84 !important;
    border-top: 1px solid #e6edf5 !important;
    border-bottom: 1px solid #e6edf5 !important;
}

#overall_request_details td {
    background: linear-gradient(180deg, #ffffff 0%, #fbfdff 100%) !important;
    border-top: 1px solid #e4edf6 !important;
    border-bottom: 1px solid #e4edf6 !important;
    box-shadow: 0 10px 24px rgba(16, 41, 67, 0.07) !important;
    transition: transform 0.16s ease, box-shadow 0.16s ease, border-color 0.16s ease;
}

#overall_request_details tr:hover td {
    transform: translateY(-2px);
    border-color: #cfdff0 !important;
    box-shadow: 0 16px 34px rgba(16, 41, 67, 0.12) !important;
}

.ai-summary-btn,
.ai-recommendation-btn,
.ai-summary-btn-compact,
.ai-summary-btn-inline {
    box-shadow: 0 8px 18px rgba(15, 94, 168, 0.12);
}

.ai-action-btn:hover {
    background: #e8edf3;
    border-color: #b0bcc8;
}

.ai-action-copy {
    background: #1b2a3a;
    color: #fff;
    border-color: #1b2a3a;
}

.ai-action-copy:hover {
    background: #2d4460;
    border-color: #2d4460;
}

.ai-action-regen {
    background: #7c3aed;
    color: #fff;
    border-color: #7c3aed;
}

.ai-action-regen:hover {
    background: #6d28d9;
    border-color: #6d28d9;
}


#overall_request_details th .header-dropdown {
    font-size: 11px !important;
    padding: 2px 4px !important;
    width: 120px !important;
    height: 25px !important;
    border: 1px solid #ccc !important;
    border-radius: 3px !important;
    background-color: white !important;
    color: black !important;
}

/* Fix for empty data template */
.empty-data-container #overall_request_details th {
    background-color: #4472C4 !important;
    color: white !important;
    padding: 12px 8px !important;
    border-top: 1px solid #000 !important;
    border-bottom: 1px solid #000 !important;
    border-left: 2px solid #000 !important;
    border-right: 2px solid #000 !important;
}

.empty-data-container #overall_request_details td {
    border-top: 1px solid #000 !important;
    border-bottom: 1px solid #000 !important;
    border-left: 2px solid #000 !important;
    border-right: 2px solid #000 !important;
}

/* Ensure the gridview container doesn't hide content */
#overall_request_details + .gridview-container,
.gridview-container:has(#overall_request_details) {
    overflow: visible !important;
    height: auto !important;
    max-height: none !important;
}

/* Dashboard tab visual match to reference image (scoped to Home panel only) */
.ccip-dashboard-host {
    padding: 14px !important;
    border-radius: 14px !important;
    background: #f8fafc !important;
}

.ccip-dashboard {
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.ccip-dash-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    padding: 6px 2px 2px;
    flex-wrap: wrap;
}

.ccip-dash-greeting {
    margin: 0;
    font-size: 34px;
    line-height: 1.05;
    font-weight: 800;
    color: #101828;
}

.ccip-dash-sub {
    margin: 6px 0 0;
    color: #475467;
    font-size: 14px;
}

.ccip-dash-updated {
    display: inline-flex;
    align-items: center;
    min-height: 36px;
    border: 1px solid #d9e1ec;
    background: #ffffff;
    color: #4b5563;
    border-radius: 12px;
    padding: 8px 12px;
    font-size: 12px;
    font-weight: 700;
    box-shadow: 0 4px 14px rgba(16, 24, 40, 0.06);
}

.ccip-link-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 36px;
    border-radius: 10px;
    padding: 0 12px;
    border: 1px solid #c9d9f2;
    background: #f6f9ff;
    color: #315bba;
    text-decoration: none;
    font-size: 12px;
    font-weight: 700;
}

.ccip-kpi-row {
    display: grid;
    grid-template-columns: repeat(5, minmax(170px, 1fr));
    gap: 12px;
}

.ccip-kpi {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    padding: 12px 14px;
    box-shadow: 0 8px 18px rgba(16, 24, 40, 0.04);
}

.ccip-kpi-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
}

.ccip-kpi-title {
    color: #1f2937;
    font-size: 12px;
    font-weight: 700;
}

.ccip-kpi-icon {
    width: 34px;
    height: 34px;
    border-radius: 999px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
}

.ccip-kpi.kpi-red .ccip-kpi-icon { background: #fee2e2; color: #dc2626; }
.ccip-kpi.kpi-orange .ccip-kpi-icon { background: #ffedd5; color: #f97316; }
.ccip-kpi.kpi-green .ccip-kpi-icon { background: #dcfce7; color: #16a34a; }
.ccip-kpi.kpi-blue .ccip-kpi-icon { background: #dbeafe; color: #2563eb; }
.ccip-kpi.kpi-purple .ccip-kpi-icon { background: #ede9fe; color: #7c3aed; }

.ccip-kpi-value {
    font-size: 44px;
    font-weight: 900;
    line-height: 1;
    margin: 8px 0;
}

.ccip-kpi.kpi-red .ccip-kpi-value { color: #dc2626; }
.ccip-kpi.kpi-orange .ccip-kpi-value { color: #f97316; }
.ccip-kpi.kpi-green .ccip-kpi-value { color: #16a34a; }
.ccip-kpi.kpi-blue .ccip-kpi-value { color: #2563eb; }
.ccip-kpi.kpi-purple .ccip-kpi-value { color: #7c3aed; }

.ccip-kpi-note {
    font-size: 12px;
    font-weight: 700;
    color: #667085;
}

.ccip-kpi-note i {
    margin-right: 4px;
}

.ccip-kpi-spark {
    margin-top: 8px;
    height: 22px;
    border-radius: 10px;
    background-size: 100% 100%;
    opacity: 0.85;
}

.ccip-kpi.kpi-red .ccip-kpi-spark {
    background: linear-gradient(180deg, rgba(254, 202, 202, 0) 0%, rgba(254, 202, 202, 0.35) 90%),
        radial-gradient(circle at 8% 70%, #f87171 0 6%, transparent 8%),
        radial-gradient(circle at 26% 45%, #f87171 0 6%, transparent 8%),
        radial-gradient(circle at 48% 74%, #f87171 0 6%, transparent 8%),
        radial-gradient(circle at 68% 36%, #f87171 0 6%, transparent 8%),
        radial-gradient(circle at 92% 58%, #f87171 0 6%, transparent 8%);
}

.ccip-kpi.kpi-orange .ccip-kpi-spark {
    background: linear-gradient(180deg, rgba(254, 215, 170, 0) 0%, rgba(254, 215, 170, 0.35) 90%),
        radial-gradient(circle at 10% 65%, #fb923c 0 6%, transparent 8%),
        radial-gradient(circle at 30% 48%, #fb923c 0 6%, transparent 8%),
        radial-gradient(circle at 48% 70%, #fb923c 0 6%, transparent 8%),
        radial-gradient(circle at 74% 42%, #fb923c 0 6%, transparent 8%),
        radial-gradient(circle at 94% 62%, #fb923c 0 6%, transparent 8%);
}

.ccip-kpi.kpi-green .ccip-kpi-spark {
    background: linear-gradient(180deg, rgba(187, 247, 208, 0) 0%, rgba(187, 247, 208, 0.35) 90%),
        radial-gradient(circle at 8% 64%, #4ade80 0 6%, transparent 8%),
        radial-gradient(circle at 28% 46%, #4ade80 0 6%, transparent 8%),
        radial-gradient(circle at 46% 72%, #4ade80 0 6%, transparent 8%),
        radial-gradient(circle at 70% 40%, #4ade80 0 6%, transparent 8%),
        radial-gradient(circle at 92% 58%, #4ade80 0 6%, transparent 8%);
}

.ccip-kpi.kpi-blue .ccip-kpi-spark {
    background: linear-gradient(180deg, rgba(191, 219, 254, 0) 0%, rgba(191, 219, 254, 0.35) 90%),
        radial-gradient(circle at 8% 68%, #60a5fa 0 6%, transparent 8%),
        radial-gradient(circle at 28% 48%, #60a5fa 0 6%, transparent 8%),
        radial-gradient(circle at 49% 72%, #60a5fa 0 6%, transparent 8%),
        radial-gradient(circle at 72% 39%, #60a5fa 0 6%, transparent 8%),
        radial-gradient(circle at 93% 61%, #60a5fa 0 6%, transparent 8%);
}

.ccip-kpi.kpi-purple .ccip-kpi-spark {
    background: linear-gradient(180deg, rgba(221, 214, 254, 0) 0%, rgba(221, 214, 254, 0.35) 90%),
        radial-gradient(circle at 8% 68%, #a78bfa 0 6%, transparent 8%),
        radial-gradient(circle at 29% 47%, #a78bfa 0 6%, transparent 8%),
        radial-gradient(circle at 50% 74%, #a78bfa 0 6%, transparent 8%),
        radial-gradient(circle at 72% 39%, #a78bfa 0 6%, transparent 8%),
        radial-gradient(circle at 93% 60%, #a78bfa 0 6%, transparent 8%);
}

.ccip-main-grid {
    display: grid;
    grid-template-columns: minmax(300px, 1fr) minmax(520px, 1.85fr) minmax(300px, 1fr);
    gap: 12px;
}

.ccip-col {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.ccip-card {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    box-shadow: 0 8px 20px rgba(16, 24, 40, 0.04);
    padding: 14px;
}

.ccip-card-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 10px;
}

.ccip-card-title {
    margin: 0;
    font-size: 26px;
    color: #101828;
    font-weight: 800;
}

.ccip-card-subtitle {
    margin: 0;
    font-size: 12px;
    color: #667085;
    font-weight: 700;
}

.ccip-card-mini-title {
    margin: 0;
    color: #111827;
    font-size: 14px;
    font-weight: 800;
}

.ccip-card-link {
    color: #315bba;
    text-decoration: none;
    font-size: 12px;
    font-weight: 700;
}

.ccip-card-link:hover {
    text-decoration: underline;
}

.ccip-daily-list {
    margin: 0;
    padding-left: 0;
    list-style: none;
    display: grid;
    gap: 8px;
}

.ccip-daily-list li {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    font-size: 13px;
    color: #1f2937;
}

.ccip-daily-list li:before {
    content: '\\f05a';
    font-family: 'Font Awesome 6 Free';
    font-weight: 900;
    color: #3b82f6;
    font-size: 11px;
    margin-top: 2px;
}

.ccip-daily-actions {
    margin-top: 12px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
}

.ccip-button {
    border-radius: 8px;
    min-height: 34px;
    font-size: 12px;
    font-weight: 700;
    border: 1px solid #c8d7f3;
    background: #f5f8ff;
    color: #315bba;
}

.ccip-button.primary {
    background: #3b5bdb;
    color: #ffffff;
    border-color: #3b5bdb;
}

.ccip-rec-list {
    display: grid;
    gap: 8px;
}

.ccip-rec-row {
    display: grid;
    grid-template-columns: 98px 1fr 46px;
    gap: 8px;
    align-items: center;
}

.ccip-rec-label {
    color: #344054;
    font-size: 12px;
    font-weight: 700;
}

.ccip-rec-track {
    width: 100%;
    height: 8px;
    border-radius: 999px;
    background: #eef2f7;
    overflow: hidden;
}

.ccip-rec-fill {
    height: 100%;
    border-radius: 999px;
}

.ccip-rec-fill.good { background: #4ade80; }
.ccip-rec-fill.medium { background: #fb923c; }
.ccip-rec-fill.low { background: #ef4444; }

.ccip-rec-percent {
    text-align: right;
    color: #667085;
    font-size: 11px;
    font-weight: 800;
}

.ccip-trend-chart {
    height: 218px;
}

.ccip-priority-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
}

.ccip-priority-table th,
.ccip-priority-table td {
    padding: 8px 6px;
    border-bottom: 1px solid #eef2f7;
    text-align: left;
}

.ccip-priority-table th {
    font-size: 11px;
    color: #667085;
    font-weight: 800;
}

.ccip-severity {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 20px;
    min-width: 54px;
    border-radius: 999px;
    font-size: 10px;
    font-weight: 800;
    padding: 0 8px;
}

.ccip-severity.critical { background: #fee2e2; color: #dc2626; }
.ccip-severity.high { background: #ffedd5; color: #f97316; }
.ccip-severity.medium { background: #fef3c7; color: #ca8a04; }

.ccip-confidence {
    color: #16a34a;
    font-weight: 800;
}

.ccip-status-pill {
    display: inline-flex;
    align-items: center;
    min-height: 20px;
    border-radius: 999px;
    padding: 0 8px;
    background: #eef2ff;
    color: #4f46e5;
    font-size: 10px;
    font-weight: 800;
}

.ccip-region-wrap {
    display: grid;
    grid-template-columns: 1.25fr 0.95fr;
    gap: 10px;
    align-items: center;
}

.ccip-region-map {
    min-height: 138px;
    border-radius: 10px;
    background:
        radial-gradient(circle at 20% 36%, #9bb2e9 0 10px, transparent 11px),
        radial-gradient(circle at 55% 32%, #5ecf7a 0 10px, transparent 11px),
        radial-gradient(circle at 72% 47%, #f5a53a 0 10px, transparent 11px),
        radial-gradient(circle at 34% 76%, #a78bfa 0 10px, transparent 11px),
        linear-gradient(180deg, #f8fbff 0%, #f3f7fd 100%);
    border: 1px solid #e5ecf7;
    position: relative;
    overflow: hidden;
}

.ccip-region-map:before {
    content: '';
    position: absolute;
    inset: 8px;
    border-radius: 8px;
    background:
        radial-gradient(ellipse at 22% 38%, rgba(153, 167, 187, 0.35) 0 17%, transparent 18%),
        radial-gradient(ellipse at 50% 45%, rgba(153, 167, 187, 0.35) 0 16%, transparent 17%),
        radial-gradient(ellipse at 72% 45%, rgba(153, 167, 187, 0.35) 0 14%, transparent 15%),
        radial-gradient(ellipse at 33% 72%, rgba(153, 167, 187, 0.35) 0 11%, transparent 12%);
}

.ccip-region-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: grid;
    gap: 8px;
}

.ccip-region-list li {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 12px;
    color: #344054;
}

.ccip-dot {
    display: inline-block;
    width: 9px;
    height: 9px;
    border-radius: 999px;
    margin-right: 8px;
}

.ccip-dot.blue { background: #4f79ff; }
.ccip-dot.green { background: #4caf64; }
.ccip-dot.orange { background: #f5a63b; }
.ccip-dot.purple { background: #8b5cf6; }
.ccip-dot.red { background: #ef4444; }

.ccip-product-wrap {
    display: grid;
    grid-template-columns: 120px 1fr;
    gap: 10px;
    align-items: center;
}

.ccip-product-chart {
    width: 120px;
    height: 120px;
}

.ccip-product-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: grid;
    gap: 8px;
}

.ccip-product-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    color: #344054;
    font-size: 12px;
}

.ccip-product-name {
    display: inline-flex;
    align-items: center;
    min-width: 0;
}

.ccip-product-value {
    color: #475467;
    font-weight: 700;
    white-space: nowrap;
}

.ccip-quick-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
}

.ccip-quick-btn {
    min-height: 40px;
    border-radius: 10px;
    border: 1px solid #d9e1ec;
    background: #ffffff;
    color: #344054;
    font-size: 12px;
    font-weight: 700;
}

.ccip-activity-list,
.ccip-insights-list {
    margin: 0;
    padding: 0;
    list-style: none;
    display: grid;
    gap: 8px;
}

.ccip-activity-list li,
.ccip-insights-list li {
    font-size: 12px;
    color: #344054;
    line-height: 1.4;
    display: flex;
    gap: 8px;
    align-items: flex-start;
}

.ccip-time {
    color: #98a2b3;
    font-weight: 700;
    min-width: 40px;
}

.ccip-insights-list li:before {
    content: '\\f201';
    font-family: 'Font Awesome 6 Free';
    font-weight: 900;
    color: #6366f1;
    font-size: 11px;
    margin-top: 1px;
}

@media (max-width: 1500px) {
    .ccip-main-grid {
        grid-template-columns: minmax(280px, 1fr) minmax(500px, 1.8fr);
    }

    .ccip-main-grid .ccip-col-right {
        grid-column: 1 / -1;
        display: grid;
        grid-template-columns: repeat(2, minmax(260px, 1fr));
        gap: 12px;
    }
}

@media (max-width: 1180px) {
    .ccip-kpi-row {
        grid-template-columns: repeat(2, minmax(170px, 1fr));
    }

    .ccip-main-grid {
        grid-template-columns: 1fr;
    }

    .ccip-main-grid .ccip-col-right {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 740px) {
    .ccip-dash-greeting {
        font-size: 26px;
    }

    .ccip-kpi-row {
        grid-template-columns: 1fr;
    }

    .ccip-product-wrap,
    .ccip-region-wrap {
        grid-template-columns: 1fr;
    }
}

/* Issue List + CMF Pending interactive modernization */
.issue-tab-shell,
.pending-tab-shell {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 290px;
    gap: 12px;
    align-items: start;
}

.issue-tab-main,
.pending-tab-main {
    min-width: 0;
}

.issue-tab-shell.side-hidden,
.pending-tab-shell.side-hidden {
    grid-template-columns: minmax(0, 1fr);
}

.issue-side-panel,
.pending-side-panel {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    box-shadow: 0 10px 24px rgba(16, 24, 40, 0.06);
    padding: 12px;
    display: grid;
    gap: 10px;
    position: sticky;
    top: 92px;
}

.interactive-side-card {
    border: 1px solid #e9edf3;
    border-radius: 12px;
    background: linear-gradient(180deg, #ffffff 0%, #fafcff 100%);
    padding: 10px;
}

.interactive-side-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    margin-bottom: 8px;
}

.interactive-side-title {
    margin: 0;
    color: #0f172a;
    font-size: 14px;
    font-weight: 800;
}

.interactive-side-sub {
    margin: 0;
    color: #64748b;
    font-size: 11px;
}

.interactive-side-btn {
    width: 100%;
    min-height: 34px;
    border-radius: 10px;
    border: 1px solid #c8d8f7;
    background: #f4f8ff;
    color: #2452b8;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
}

.interactive-side-btn:hover {
    background: #ecf3ff;
}

.interactive-chip-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: grid;
    gap: 8px;
}

.interactive-chip-list li {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    font-size: 12px;
    color: #334155;
}

.interactive-chip {
    display: inline-flex;
    align-items: center;
    min-height: 24px;
    padding: 0 10px;
    border-radius: 999px;
    border: 1px solid #dbe7f4;
    background: #f8fbff;
    color: #1e3a8a;
    font-size: 11px;
    font-weight: 800;
}

.interactive-shortcuts {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
}

.interactive-shortcut-btn {
    min-height: 36px;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    background: #ffffff;
    color: #334155;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
}

.interactive-shortcut-btn:hover {
    background: #f8fbff;
}

.issue-page-hd,
.cmf-pending-page-hd {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    box-shadow: 0 8px 18px rgba(16, 24, 40, 0.05);
    padding: 12px 14px;
    margin-bottom: 10px;
}

.issue-kpi-row,
.cmf-pending-kpi-row {
    gap: 10px;
    margin-bottom: 12px;
}

.issue-kpi,
.cmf-pending-kpi {
    border-radius: 12px;
    box-shadow: 0 8px 18px rgba(16, 24, 40, 0.05);
}

.issue-top-filter-panel,
#sharedFilterPanel.overview-platform-actions {
    border-radius: 12px;
    box-shadow: 0 8px 18px rgba(16, 24, 40, 0.04);
}

.issue-grid-scroll,
.cmf-pending-grid-wrap {
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    padding: 8px;
    background: #ffffff;
    box-shadow: 0 10px 24px rgba(16, 24, 40, 0.05);
}

.issue-grid-inner #overall_request_details {
    border-radius: 12px !important;
    overflow: hidden !important;
}

.issue-grid-inner #overall_request_details th,
.cmf-pending-grid-wrap #GridView_cmf_pending th {
    position: sticky;
    top: 0;
    z-index: 2;
}

.issue-grid-inner #overall_request_details td,
.cmf-pending-grid-wrap #GridView_cmf_pending td {
    transition: background-color 0.18s ease, transform 0.18s ease;
}

.issue-grid-inner #overall_request_details tr:hover td,
.cmf-pending-grid-wrap #GridView_cmf_pending tr:hover td {
    background: #f8fbff !important;
}

.issue-pager-controls {
    margin-top: 12px;
}

@media (max-width: 1300px) {
    .issue-tab-shell,
    .pending-tab-shell {
        grid-template-columns: minmax(0, 1fr) 270px;
    }
}

@media (max-width: 760px) {
    .issue-tab-shell,
    .pending-tab-shell {
        grid-template-columns: 1fr;
    }

    .issue-side-panel,
    .pending-side-panel {
        position: static;
    }
}

        /* Footer */
        footer {
            background-color: #2D3748;
            color: white;
            padding-top: 2px;
            font-size: 10px;
            position: fixed;
            text-align: center;
            width: 100%;
            height: 3vh;
            box-shadow: 0 -2px 4px rgba(0, 0, 0, 0.1);
            z-index: 10;
        }

        /* Modal */
        .modal .modal-body {
            max-height: 80%;
            overflow-y: auto;
        }

        .searchable-dropdown {
            width: 200px;
            font-family: Arial, sans-serif;
        }

        /* Modern Dropdown */
        .dropdown {
            font-size: 12px;
            padding: 10px 14px;
            border-radius: 999px;
            border: 1px solid #8fb7db;
            background-color: rgba(255, 255, 255, 0.98);
            color: var(--portal-ink);
            width: auto;
            min-width: 110px;
            max-height: 42px;
            transition: all 0.3s ease;
            margin-left: 0;
            margin-top: 0;
            margin-bottom: 0;
            box-shadow: 0 8px 18px rgba(15, 94, 168, 0.10);
        }

            .dropdown:focus {
                outline: none;
                border-color: #005d99; /* Darker shade of blue */
                box-shadow: 0 0 8px rgba(0, 93, 153, 0.5);
            }

        /* Modern Buttons */
        .modern-button {
            background: linear-gradient(180deg, #1672be 0%, #0f5ea8 100%);
            color: white;
            border: 1px solid rgba(8, 61, 116, 0.15);
            padding: 9px 16px;
            font-size: 11px;
            border-radius: 999px;
            cursor: pointer;
            margin: 0;
            transition: all 0.3s ease;
            box-shadow: 0 10px 18px rgba(15, 94, 168, 0.18);
            font-weight: 600;
            letter-spacing: 0.02em;
        }

            .modern-button:hover {
                background: linear-gradient(180deg, #0f5ea8 0%, #0b4c87 100%);
                transform: translateY(-1px);
            }

            .modern-button:focus {
                outline: none;
                box-shadow: 0 0 8px rgba(0, 93, 153, 0.6);
            }

        .modern-button1 {
            background-color: #1d4f91; /* Intel's blue */
            color: white;
            border: none;
            padding: 8px 16px; /* Smaller padding */
            font-size: 10px; /* Smaller font */
            border-radius: 6px; /* Slightly smaller rounded corners */
            cursor: pointer;
            margin: 0 8px; /* Horizontal space between buttons */
            transition: all 0.3s ease;
        }

             .modern-button1:hover {
                 background-color: #1172b3; /* Darker Intel Blue on hover */
             }

             .modern-button1:focus {
                 outline: none;
                 box-shadow: 0 0 8px rgba(0, 93, 153, 0.6);
             }

             .modern-title-container {
                 display: flex;
                 justify-content: space-between;
                 align-items: center;
                 width: 100%;
             }

             .export-btn {
                 margin-left: auto;
             }

             .modal-header {
                 position: relative;
             }

#btnExportDesignToExcel {
    position: absolute;
    top: 10px;
    right: 50px;
    z-index: 1050;
}

#btnExportOEMToExcel {
    position: absolute;
    top: 10px;
    right: 50px;
    z-index: 1050;
}

#btnExportIngredientToExcel {
    position: absolute;
    top: 10px;
    right: 50px;
    z-index: 1050;
}

            /* Modern Buttons */
.modern-button2 {
    background-color: green; /* Intel's blue */
    color: white;
    border: none;
    padding: 8px 16px; /* Smaller padding */
    font-size: 10px; /* Smaller font */
    border-radius: 6px; /* Slightly smaller rounded corners */
    cursor: pointer;
    margin: 0 8px; /* Horizontal space between buttons */
    transition: all 0.3s ease;
}

    .modern-button2:hover {
        background-color: greenyellow; /* Darker Intel Blue on hover */
    }

    .modern-button2:focus {
        outline: none;
        box-shadow: 0 0 8px rgba(0, 93, 153, 0.6);
    }

        /* Button container for layout */
        .button-container {
                    display: flex;
                    justify-content: center;
                    gap: 10px;
                    margin-top: 18px;
                    margin-bottom: 16px;
                    padding: 14px;
                    flex-wrap: wrap;
                    background: rgba(255, 255, 255, 0.68);
                    border: 1px solid rgba(205, 217, 229, 0.9);
                    border-radius: 18px;
                    box-shadow: 0 10px 28px rgba(21, 49, 79, 0.08);
        }

         /* Button container for layout */
.button-container2 {
    display: flex;
justify-content: center; /* Center the buttons horizontally */
gap: 10px; /* Space between buttons */
margin-top: -150px;

}

.link-container {
            display: flex;
            justify-content: flex-end;
            gap: 14px;
            padding: 12px 14px;
            margin-top: 16px;
            background: rgba(255, 255, 255, 0.68);
            border: 1px solid rgba(205, 217, 229, 0.9);
            border-radius: 18px;
            box-shadow: 0 10px 24px rgba(18, 42, 66, 0.08);
            flex-wrap: wrap;
        }

        /* Style for individual links */
        .link-container a {
            text-decoration: none;
            color: var(--portal-primary);
            font-weight: 700;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(15, 94, 168, 0.08);
        }

        /* Hover effect for links */
        .link-container a:hover {
            color: var(--portal-primary-deep);
            background: rgba(15, 94, 168, 0.14);
        }

        /* Responsive design for smaller screens */
        @media screen and (max-width: 600px) {
            .dropdown {
                width: 100%;
            }

            .button-container {
                flex-wrap: wrap; /* Allow buttons to wrap in small screens */
                justify-content: center; /* Center buttons in smaller screen */
            }

             .button-container2 {
     flex-wrap: wrap; /* Allow buttons to wrap in small screens */
     justify-content: center; /* Center buttons in smaller screen */
 }

            .modern-button {
                margin: 5px; /* Adjust margin for smaller screen */
                font-size: 12px; /* Slightly smaller font size */
                padding: 6px 12px; /* Adjust padding for smaller screen */
            }
        }

        .metricsPanel {
            margin-top: 10px;
            display: flex;
            justify-content: center; /* Aligns the content horizontally */
            align-items: center; /* Optionally centers the content vertically */
        }

        .super-header {
            background-color: #f1f1f1;
            font-weight: bold;
            text-align: center;
            padding: 10px;
        }

        /*.main-header-cell {
            border: 2px solid black !important;
            padding: 10px !important;
            text-align: center !important;
            vertical-align: middle !important;
            font-weight: bold !important;
        }

        .table-primary th {
            background-color: #2a62c2;
            color: white;
            font-weight: 500;
            vertical-align: middle;
            text-align: center;
            line-height: 1.2;
            padding: 8px 4px;
            border: 2px solid black !important;
        }*/

        /* Make sure the sub-headers are properly styled */
        /*.table-primary thead tr:nth-child(2) th {
            background-color: #4a7bc8;*/ /* Slightly lighter blue for sub-headers */
            /*font-size: 0.9em;
        }

        .table-primary-header {
            border: 2px solid black !important;
            padding: 10px !important;
            text-align: center !important;
            vertical-align: middle !important;
            font-weight: bold !important;
            background-color: #2a62c2 !important;
            color: white !important;
        }*/
 .table-primary {
     height: 100%; /* Make the table fill the container's height */
     width: 100%; /* Ensure the table takes up the full width of the container */
     border-collapse: collapse; /* Ensures borders are merged between cells */
 }

     .table-primary th {
         color: white; /* White text color */
         font-weight: bold; /* Bold text for headers */
         padding: 10px; /* Padding for better readability */
         text-align: left; /* Align text to the left */
         border: 1px solid #ddd; /* Border around headers */
     }

     .table-primary td {
         padding: 8px; /* Padding for cells */
         border: 1px solid #ddd; /* Border around table cells */
     }

 td:nth-child(even), th:nth-child(even) {
     border-left: solid 2px black;
 }

 td:nth-child(odd), th:nth-child(odd) {
     border-left: solid 2px black;
 }

 /* First row within .table-primary */
 .table-primary tr:first-child {
     background-color: #ffebcc; /* Mild yellow background for the first row */
     border-bottom: solid 2px black;
 }

 /* Even rows within .table-primary */
 .table-primary tr:nth-child(even) {
     background-color: #c2e0f7; /* Mild blue background for even rows */
     border-bottom: solid 2px black;
 }

 /* Odd rows within .table-primary */
 .table-primary tr:nth-child(odd) {
     background-color: #e0f1fb; /* Very light blue background for odd rows */
     border-bottom: solid 2px black;
 }



.gridview-container3 {
    table-layout: fixed;
    display: inline-block;
    width: 100%;
    vertical-align: top;
    height: 400px;
    margin-bottom: 2vh;
}

.table-primary7 {
    height: 100%; /* Make the table fill the container's height */
    width: 100%; /* Ensure the table takes up the full width of the container */
    border-collapse: collapse; /* Ensures borders are merged between cells */
    /*table-layout: fixed;*/
}

.table-primary7 th {
    color: white; /* White text color */
    font-weight: bold; /* Bold text for headers */
    padding: 10px; /* Padding for better readability */
    text-align: left; /* Align text to the left */
    border: 1px solid #ddd; /* Border around headers */
    /*vertical-align: middle;*/
}

.table-primary7 td {
    padding: 8px; /* Padding for cells */
    border: 1px solid #ddd; /* Border around table cells */
    /*text-align: left;  Changed from center to left to match css1 */
}

/* Driver group borders - every 3 columns (matching the nth-child pattern from css1) */
.table-primary7 td:nth-child(3n+1), 
.table-primary7 th:nth-child(3n+1) {
    border-left: solid 2px black;
}

/* Apply the same border pattern as css1 for consistency */
.table-primary7 td:nth-child(even), 
.table-primary7 th:nth-child(even) {
    border-left: solid 2px black;
}

.table-primary7 td:nth-child(odd), 
.table-primary7 th:nth-child(odd) {
    border-left: solid 2px black;
}


/* First row within .table-primary7 - matching css1 */
.table-primary7 tr:first-child {
    background-color: #ffebcc; /* Mild yellow background for the first row */
    border-bottom: solid 2px black;
}

/* Second header row - slightly different yellow to distinguish */
.table-primary7 tr:nth-child(2) {
    background-color: #e0f1fb !important; /* Same mild yellow as first row */
    border-bottom: solid 2px black;
}

/* Even rows within .table-primary7 - starting from 3rd row (after headers) */
.table-primary7 tr:nth-child(n+3):nth-child(even) {
    background-color: #c2e0f7; /* Mild blue background for even rows */
    border-bottom: solid 2px black;
}

/* Odd rows within .table-primary7 - starting from 3rd row (after headers) */
.table-primary7 tr:nth-child(n+3):nth-child(odd) {
    background-color: #e0f1fb; /* Very light blue background for odd rows */
    border-bottom: solid 2px black;
}

/* Total row styling - keeping orange but with consistent borders */
.total-row {
    background-color: orange !important;
    color: black !important;
    font-weight: bold !important;
    border-bottom: solid 2px black !important;
}

/* Merged cells in total row */
.table-primary7 .total-row td[colspan="2"] {
    background-color: orange !important;
    border: 1px solid #ddd !important; /* Changed to match standard cell borders */
    border-left: solid 2px black !important; /* Maintain the left border pattern */
    font-weight: bold !important;
    padding: 8px; /* Match standard cell padding */
}

/* Ensure total row cells follow the same border pattern */
.table-primary7 .total-row td {
    border: 1px solid #ddd !important;
    border-bottom: solid 2px black !important;
}

       
.table-primary2 {
    height: 100%; /* Make the table fill the container's height */
    width: 100%; /* Ensure the table takes up the full width of the container */
    border-collapse: collapse; /* Ensures borders are merged between cells */
}

.table-primary2 th {
    color: white; /* White text color */
    font-weight: bold; /* Bold text for headers */
    padding: 10px; /* Padding for better readability */
    text-align: left; /* Align text to the left */
    border: 1px solid #ddd; /* Border around headers */
}

.table-primary2 td {
    padding: 8px; /* Padding for cells */
    border: 1px solid #ddd; /* Border around table cells */
}

td:nth-child(even), th:nth-child(even) {
    border-left: solid 2px black;
}

td:nth-child(odd), th:nth-child(odd) {
    border-left: solid 2px black;
}

/* First row within .table-primary2 */
.table-primary2 tr:first-child {
    background-color: #ffebcc; /* Mild yellow background for the first row */
    border-bottom: solid 2px black;
}

/* Even rows within .table-primary2 */
.table-primary2 tr:nth-child(even) {
    background-color: #c2e0f7; /* Mild blue background for even rows */
    border-bottom: solid 2px black;
}

/* Odd rows within .table-primary2 */
.table-primary2 tr:nth-child(odd) {
    background-color: #e0f1fb; /* Very light blue background for odd rows */
    border-bottom: solid 2px black;
}

/* Last row should have an orange background */
.table-primary2 tr:last-child {
    background-color: orange; /* Orange background for the last row */
    border-bottom: solid 2px black; /* Keep the border on the last row */
}




        .modal-import {
            display: none;
            position: fixed;
            z-index: 1060;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content-import {
            background-color: #fff;
            margin: 10% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 30%;
            text-align: center;
        }

        .close-import {
            color: red;
            float: right;
            font-size: 20px;
            cursor: pointer;
        }

        .gridview-container-wrapper {
            display: flex;
            gap: 20px; /* Adjust space between the two grid views */
        }

        .gridview-container3 {
            flex: 1; /* Makes the two grid views take equal width */
            padding: 10px; /* Optional, to give some space inside the grid containers */
        }

        /* Define a CSS class for the column */
        .status-column {
            width: 25vw !important; /* Force the width using !important */
            display: inline-block; /* Prevent overflow issues */
        }
        .impact-column {
            width: 25vw !important; /* Force the width using !important */
            display: inline-block; /* Prevent overflow issues */
        }

        .los-column {
    width: 5vw !important; /* Force the width using !important */
    display: inline-block; /* Prevent overflow issues */
}

        .component-column {
            width: 10vw !important; /* Force the width using !important */ /* Prevent overflow issues */
            word-wrap: break-word !important; /* Ensure long words break and wrap */
            word-wrap: break-word; /* Ensures long words will wrap */
            white-space: normal; /* Allows wrapping within the cell */
            overflow: visible;
            max-width: none;
        }

        .owner-column {
            width: 10vw !important; /* Force the width using !important */ /* Prevent overflow issues */
            word-wrap: break-word !important; /* Ensure long words break and wrap */
            word-wrap: break-word; /* Ensures long words will wrap */
            white-space: normal; /* Allows wrapping within the cell */
            overflow: visible;
            max-width: none;
        }

        .idst-column {
            width: 8vw !important; /* Force the width using !important */
            display: inline-block; /* Prevent overflow issues */
        }

        .notes-box {
            background-color: #e0f1fb;
            border-radius: 8px;
            padding: 16px;
            width: 42.3vw;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .notes-label {
            font-size: 14px;
            color: #555;
            font-weight: 500;
        }

        .notes-value {
            font-size: 16px;
            color: #333;
            font-weight: 600;
        }

        .form-control {
            font-size: 12px;
        }

        .form-control-impact {
    font-size: 12px;
}


        .link {
            position: relative;
            top: -30px;
            left: 92%;
        }

        .orange-background {
    background-color: orange !important;
    color: black !important;
}

        /* Update info styling */
#updateinfo {
    display: none !important;
    position: absolute;
    left: 1vw;
    font-size: 10px; /* smaller to fit nicely */
    font-family: sans-serif;
    margin: 0;
    line-height: 1.2;
    white-space: nowrap;
}

.tptdefinitions {
      padding: 15px;
      border: 1px solid #ccc;
      max-width: 550px;
      font-family: Arial, sans-serif;
      background-color: #f9f9f9;
      font-size: 10px;
      max-height: 100px;
    }
    .tptdefinitions h3 {
      margin-top: 0;
    }
    .tptdefinitions p {
      margin: 10px 0;
    }

    .button-wrapper {
        float: right;
        padding-right:35px;
}

    /* Custom modal styles */
.custom-modal-dialog {
  max-width: 85%; /* Set the width of the modal to 85% of the page */
  width: 85%; /* You can adjust this value to get the desired width */
}

/* Optional: Adjust modal body height if content overflows */
.custom-modal-body {
  max-height: 80vh; /* Set max-height of the modal body */
  overflow-y: auto; /* Enable scrolling if the content is too long */
}

/* Custom GridView scale */
.custom-gridview {
  transform: scale(0.8); /* Scale the entire GridView to 80% of its original size */
  transform-origin: top left; /* Optional: This makes sure the scaling starts from the top-left corner */
  margin: 0 auto; /* Center the GridView */
  width: 120%; /* Ensure GridView still takes up the full width of its container */
}

/* Optional: Adjust for text overflow or padding inside the GridView */
.custom-gridview td, .custom-gridview th {
  padding: 0.5rem; /* Reduce padding for smaller text in scaled grid */
}

#selectallcheckbox {
    visibility: hidden;
}


    /* Field visibility controls */

    /* COMPLETE HIDING OF TABLE STRUCTURE FOR UNSELECTED FIELDS */
    #<%= overall_request_details.ClientID %> .field-sno.hidden,
    #<%= overall_request_details.ClientID %> .field-progress.hidden,
    #<%= overall_request_details.ClientID %> .field-sightingid.hidden,
    #<%= overall_request_details.ClientID %> .field-issue_details.hidden,
    #<%= overall_request_details.ClientID %> .field-promotedid.hidden,
    #<%= overall_request_details.ClientID %> .field-title.hidden,
    #<%= overall_request_details.ClientID %> .field-component.hidden,
    #<%= overall_request_details.ClientID %> .field-owner.hidden,
    #<%= overall_request_details.ClientID %> .field-promoted_owner.hidden,
    #<%= overall_request_details.ClientID %> .field-rvp_repro.hidden,
    #<%= overall_request_details.ClientID %> .field-processor.hidden,
    #<%= overall_request_details.ClientID %> .field-status.hidden,
    #<%= overall_request_details.ClientID %> .field-idst.hidden,
    #<%= overall_request_details.ClientID %> .field-los.hidden,
    #<%= overall_request_details.ClientID %> .field-customer_company.hidden,
    #<%= overall_request_details.ClientID %> .field-customer_detail.hidden,
    #<%= overall_request_details.ClientID %> .field-imagefreeze.hidden,
    #<%= overall_request_details.ClientID %> .field-component_group.hidden,
    #<%= overall_request_details.ClientID %> .field-duplicatedetails.hidden,
    #<%= overall_request_details.ClientID %> .field-impact.hidden,
    #<%= overall_request_details.ClientID %> .field-impact_processor.hidden,
    #<%= overall_request_details.ClientID %> .field-milestone.hidden,
    #<%= overall_request_details.ClientID %> .field-days_open.hidden,
    #<%= overall_request_details.ClientID %> .field-cmf_request.hidden,
    #<%= overall_request_details.ClientID %> .field-cmf_status.hidden,
    #<%= overall_request_details.ClientID %> .field-closed_reason.hidden,
    #<%= overall_request_details.ClientID %> .field-edit_column.hidden {
        display: none !important;
        visibility: hidden !important;
        width: 0 !important;
        min-width: 0 !important;
        max-width: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        border-width: 0 !important;
        overflow: hidden !important;
    }

    /* Hide empty data template columns as well */
    #<%= overall_request_details.ClientID %> .empty-data-container .field-sno.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-progress.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-sightingid.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-issue_details.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-promotedid.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-title.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-component.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-owner.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-promoted_owner.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-rvp_repro.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-processor.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-status.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-idst.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-los.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-customer_company.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-customer_detail.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-duplicatedetails.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-component_group.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-imagefreeze.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-impact.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-impact_processor.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-milestone.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-days_open.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-cmf_request.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-closed_reason.hidden,
    #<%= overall_request_details.ClientID %> .empty-data-container .field-edit_column.hidden {
        display: none !important;
        visibility: hidden !important;
        width: 0 !important;
        min-width: 0 !important;
        max-width: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        border-width: 0 !important;
        overflow: hidden !important;
    }

    /* Force table layout to recalculate when columns are hidden */
    #<%= overall_request_details.ClientID %> {
        table-layout: auto !important;
    }

    #<%= overall_request_details.ClientID %> table {
        table-layout: auto !important;
        width: 100% !important;
    }

    /* Responsive design */
    @media (max-width: 768px) {
        .checkbox-grid {
            grid-template-columns: 1fr;
        }
        
        .panel-actions {
            justify-content: center;
        }
    }

    /* Second-pass dashboard polish */
    .field-selector-panel {
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 10px;
        margin: 8px 0 12px;
        padding: 10px 12px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
    }

    .field-selector-toggle {
        background: #f5f5f5;
        color: #242424;
        border: 1px solid #d1d1d1;
        padding: 8px 12px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 12px;
        font-weight: 600;
        transition: all 0.2s ease;
    }

    .field-selector-toggle:hover {
        background: #eef6ff;
        border-color: #9fc3e7;
    }

    .field-checkboxes {
        display: none;
        margin-top: 10px;
        padding-top: 10px;
        border-top: 1px solid #efefef;
    }

    .field-checkboxes.show {
        display: block;
    }

    .checkbox-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
        gap: 6px 10px;
        max-height: 240px;
        overflow-y: auto;
        padding-right: 4px;
    }

    .checkbox-grid label {
        display: flex;
        align-items: center;
        gap: 8px;
        margin: 0;
        padding: 6px 8px;
        border: 1px solid #efefef;
        border-radius: 8px;
        background: #fcfcfc;
        font-size: 12px;
        color: #3a3a3a;
    }

    .checkbox-grid input[type="checkbox"] {
        accent-color: #0068b5;
        width: 14px;
        height: 14px;
    }

    .panel-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
        margin-top: 10px;
    }

    .panel-actions .btn {
        font-size: 12px;
        padding: 6px 10px;
        border-radius: 6px;
        min-height: 30px;
    }

    .button-container-focus {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        margin: 12px 0 10px;
        padding: 10px;
        border-radius: 14px;
        background: linear-gradient(180deg, rgba(255, 255, 255, 0.94) 0%, rgba(244, 248, 252, 0.98) 100%);
        border: 1px solid rgba(184, 201, 218, 0.8);
        box-shadow: 0 6px 20px rgba(16, 45, 74, 0.08);
    }

    .button-container-focus .tab-pill {
        border-radius: 999px;
        border: 1px solid #aac3db;
        background: #f6fbff;
        color: #164068;
        font-weight: 700;
        letter-spacing: 0.02em;
        min-height: 38px;
        padding: 8px 18px;
    }

    .button-container-focus .tab-pill:hover {
        background: #e9f4ff;
        border-color: #7ea4c8;
    }

    .button-container-focus .tab-pill.is-active {
        color: #ffffff;
        background: linear-gradient(120deg, #0d4f90 0%, #0f66b7 65%, #00a6b2 100%);
        border-color: #0f5ea8;
        box-shadow: 0 8px 16px rgba(15, 94, 168, 0.28);
    }

    .platform-switcher-modern {
        display: flex;
        align-items: center;
        justify-content: flex-start;
        gap: 12px;
        padding: 10px 12px;
        margin: 8px 0 10px;
        border: 1px solid #e0e0e0;
        border-radius: 10px;
        background: #ffffff;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
        flex-wrap: wrap;
    }

    .platform-chip-rail {
        display: flex;
        align-items: center;
        gap: 6px;
        overflow-x: auto;
        padding-bottom: 2px;
        flex: 1;
    }

    .platform-chip {
        border: 1px solid #d1d1d1;
        background: #fafafa;
        color: #424242;
        border-radius: 999px;
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        white-space: nowrap;
    }

    .platform-chip:hover {
        border-color: #9fc3e7;
        background: #f2f8ff;
    }

    .platform-chip.is-active {
        background: #eff6fc;
        border-color: #0068b5;
        color: #0068b5;
    }

    .issue-page-hd {
        margin: 0 0 8px;
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        gap: 12px;
        flex-wrap: wrap;
    }

    .issue-page-hd-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        flex-wrap: wrap;
    }

    .issue-page-title {
        font-size: 18px;
        font-weight: 800;
        color: #10243a;
        margin: 0 0 2px;
    }

    .issue-page-desc {
        margin: 0;
        color: #607086;
        font-size: 12px;
        line-height: 1.5;
    }

    .issue-kpi-row {
        display: grid;
        grid-template-columns: repeat(4, minmax(140px, 1fr));
        gap: 8px;
        margin-bottom: 10px;
    }

    .issue-kpi {
        background: linear-gradient(180deg, #ffffff 0%, #fbfdff 100%);
        border: 1px solid #e3ebf4;
        border-radius: 8px;
        padding: 10px 12px;
        box-shadow: 0 8px 20px rgba(20, 46, 77, 0.06);
    }

    .issue-kpi-label {
        font-size: 11px;
        color: #62748a;
        margin-bottom: 5px;
        font-weight: 800;
        letter-spacing: 0.03em;
        text-transform: uppercase;
    }

    .issue-kpi-value {
        font-size: 25px;
        line-height: 1;
        font-weight: 800;
        color: #14283d;
    }

    .issue-kpi-sub {
        margin-top: 4px;
        font-size: 10px;
        color: #7c8da0;
    }

    /* CMF Pending List Styles */
    .cmf-pending-page-hd {
        margin: 0 0 12px;
    }

    .cmf-pending-page-hd-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        flex-wrap: wrap;
    }

    .cmf-pending-page-title {
        font-size: 18px;
        font-weight: 800;
        color: #111827;
        margin: 0;
    }

    .overview-platform-actions {
        background: #f5f8fb;
        border: 1px solid #d8e3ee;
        border-radius: 8px;
        padding: 8px 10px;
        margin-bottom: 10px;
        display: flex;
        gap: 12px;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        font-size: 13px;
    }

    .overview-platform-filter {
        display: flex;
        align-items: center;
        gap: 6px;
        min-width: 260px;
    }

    .overview-platform-filter label {
        font-weight: 600;
        color: #0f3554;
        white-space: nowrap;
    }

    .overview-platform-filter .form-control {
        max-width: 210px;
        padding: 5px 8px;
        border: 1px solid #c8d9ea;
        border-radius: 4px;
        font-size: 12px;
    }

    .cmf-pending-external-links {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
    }

    .cmf-pending-external-links a {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-height: 34px;
        padding: 8px 12px;
        border-radius: 999px;
        border: 1px solid #d7e1ec;
        background: #f8fbff;
        color: #1b4e7f;
        font-size: 12px;
        font-weight: 700;
        text-decoration: none;
        transition: all 0.2s ease;
    }

    .cmf-pending-external-links a:hover {
        background: #e6f0fb;
        color: #0a3a66;
        border-color: #bfd4e5;
    }

    .cmf-pending-page-desc {
        margin: 4px 0 0;
        color: #64748b;
        font-size: 12px;
        line-height: 1.45;
    }

    .cmf-pending-kpi-row {
        display: grid;
        grid-template-columns: repeat(4, minmax(150px, 1fr));
        gap: 12px;
        margin: 10px 0 14px;
    }

    .cmf-pending-kpi {
        position: relative;
        min-height: 92px;
        background: #ffffff;
        border: 1px solid #e8edf5;
        border-radius: 10px;
        padding: 14px 16px;
        box-shadow: 0 8px 20px rgba(28, 48, 78, 0.05);
        overflow: hidden;
    }

    .cmf-pending-kpi::before {
        content: "";
        position: absolute;
        inset: 0 auto 0 0;
        width: 4px;
        background: #ef4444;
        opacity: 0.85;
    }

    .cmf-pending-kpi:nth-child(2)::before { background: #22c55e; }
    .cmf-pending-kpi:nth-child(3)::before { background: #f59e0b; }
    .cmf-pending-kpi:nth-child(4)::before { background: #6366f1; }

    .cmf-pending-kpi-label {
        font-size: 11px;
        color: #334155 !important;
        font-weight: 800;
        letter-spacing: 0;
        text-transform: none;
        margin-bottom: 8px;
    }

    .cmf-pending-kpi-value {
        font-size: 27px;
        line-height: 1;
        font-weight: 800;
        color: #ef4444;
        margin-bottom: 6px;
    }

    .cmf-pending-kpi-sub {
        margin-top: 0;
        font-size: 11px;
        color: #64748b;
        font-weight: 600;
    }

    .reports-workspace {
        padding: 0 0 20px;
        font-family: 'Segoe UI', sans-serif;
        display: flex;
        flex-direction: column;
        gap: 14px;
        min-height: 0;
    }

    .reports-assistant-card {
        background: #ffffff;
        border: 1px solid #d8e3ee;
        border-radius: 12px;
        padding: 16px;
        box-shadow: 0 2px 4px rgba(0,0,0,.08);
        display: flex;
        flex-direction: column;
        min-height: 420px;
    }

    .reports-chat-log {
        flex: 1 1 auto;
        overflow: auto;
        border: 1px solid #d8e3ee;
        border-radius: 10px;
        background: #fbfdff;
        padding: 12px;
        margin-bottom: 10px;
        min-height: 260px;
        max-height: 420px;
    }

    .reports-prompt-row {
        display: flex;
        gap: 10px;
        align-items: center;
        flex-shrink: 0;
    }

    .cmf-pending-grid-wrap {
        overflow-x: auto !important;
        overflow-y: visible !important;
        width: 100%;
        max-width: 100%;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending {
        table-layout: fixed !important;
        width: 100% !important;
        min-width: 1260px !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
        border: 1px solid #e8edf5 !important;
        border-radius: 10px !important;
        overflow: hidden !important;
        background: #ffffff !important;
        box-shadow: 0 10px 24px rgba(28, 48, 78, 0.05) !important;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending th,
    .cmf-pending-grid-wrap #GridView_cmf_pending td {
        padding: 12px !important;
        white-space: normal !important;
        overflow-wrap: anywhere;
        word-break: break-word;
        vertical-align: top !important;
        max-width: 100%;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending td *,
    .cmf-pending-grid-wrap #GridView_cmf_pending th * {
        max-width: 100%;
        min-width: 0;
        overflow-wrap: anywhere;
        word-break: break-word;
        white-space: normal;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending th {
        background: #f7f9fc !important;
        color: #243042 !important;
        border: 0 !important;
        border-bottom: 1px solid #e5ebf3 !important;
        font-size: 10px !important;
        font-weight: 800 !important;
        letter-spacing: 0 !important;
        text-transform: none !important;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending td {
        background: #ffffff !important;
        border: 0 !important;
        border-bottom: 1px solid #eef2f7 !important;
        box-shadow: none !important;
        color: #1f2937 !important;
        font-size: 12px !important;
        line-height: 1.45;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending tr:hover td {
        background: #fbfdff !important;
    }

    .pending-select-cell {
        display: flex;
        align-items: flex-start;
        justify-content: center;
        min-height: 42px;
        position: relative;
    }

    .pending-row-check {
        width: 14px;
        height: 14px;
        border: 1px solid #b9c8d8;
        border-radius: 3px;
        background: #ffffff;
        box-shadow: 0 1px 2px rgba(31, 59, 87, 0.08);
        margin-top: 2px;
        display: inline-flex;
    }

    .pending-select-header .pending-row-check {
        margin-top: 0;
        border-color: #aebfd1;
        background: #f8fbff;
    }

    .pending-issue-cell,
    .pending-issue-with-action,
    .pending-customer-cell,
    .pending-component-cell,
    .pending-status-cell,
    .pending-signals-cell {
        display: flex;
        flex-direction: column;
        gap: 6px;
        align-items: flex-start;
        max-width: 100%;
        min-width: 0;
    }

    .pending-issue-with-action {
        gap: 8px;
    }

    .pending-recommendation-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        align-self: flex-start;
        min-height: 28px;
        padding: 4px 9px;
        border-radius: 999px;
        border: 1px solid #cdddf2;
        background: #f5f9ff;
        color: #1f5f9e;
        font-size: 11px;
        font-weight: 800;
        cursor: pointer;
    }

    .pending-recommendation-btn:hover {
        background: #eaf3ff;
        border-color: #9ec5ee;
    }

    .pending-id-link {
        font-weight: 850;
        color: #075ea8;
        text-decoration: none;
    }

    .pending-title-text {
        font-size: 11px;
        font-weight: 750;
        color: #172b3f;
        line-height: 1.3;
        max-width: 100%;
        overflow-wrap: anywhere;
        word-break: break-word;
    }

    .pending-mini-label {
        font-size: 9px;
        font-weight: 850;
        color: #6b7b8f;
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }

    .pending-chip-row {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
    }

    .pending-chip {
        display: inline-flex;
        align-items: center;
        min-height: 18px;
        padding: 2px 6px;
        border-radius: 999px;
        background: #eef5fb;
        color: #214967;
        font-size: 10px;
        font-weight: 800;
    }

    .pane-heading {
        margin-top: 10px;
    }

    /* Fluent-inspired focused UI overrides for Issue/Pending/Reports.
       These are intentionally last to safely override legacy styles. */
    header {
        min-height: 48px;
        padding: 0 18px;
        justify-content: center;
        background: linear-gradient(90deg, #00377c 0%, #0068b5 100%);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.18);
    }

    .header-title {
        font-size: 15px;
        letter-spacing: 0.04em;
        text-transform: none;
        font-weight: 600;
    }

    #updateinfo {
        left: 16px;
        font-size: 11px;
        color: rgba(255, 255, 255, 0.92);
        line-height: 1.35;
        display: none !important;
    }

    .sidebar-toggle-div {
        right: 16px;
    }

    .sidebar-toggle {
        width: 30px;
        height: 30px;
        font-size: 14px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.18);
    }

    .dropdown {
        height: 34px;
        border-radius: 18px;
        border: 1px solid #d1d1d1;
        box-shadow: none;
        font-size: 12px;
        background: #ffffff;
    }

    .button-container.button-container-focus {
        margin: 10px 0 8px;
        padding: 0;
        gap: 0;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-left: none;
        border-right: none;
        border-radius: 0;
        box-shadow: none;
        justify-content: flex-start;
        overflow-x: auto;
        flex-wrap: nowrap;
    }

    .button-container.button-container-focus .link-container {
        margin: 0 0 0 auto;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 8px;
        border: none;
        background: transparent;
        box-shadow: none;
        flex-wrap: nowrap;
    }

    .button-container.button-container-focus .link-container a,
    .button-container.button-container-focus .link-container .aspNetDisabled {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-height: 34px;
        padding: 8px 12px;
        font-size: 12px;
        border-radius: 999px;
        white-space: nowrap;
    }

    .button-container-focus .tab-pill {
        border: none;
        border-bottom: 2px solid transparent;
        border-radius: 0;
        min-height: 40px;
        padding: 10px 18px;
        background: transparent;
        color: #616161;
        box-shadow: none;
        font-size: 13px;
        font-weight: 500;
    }

    .button-container-focus .tab-pill:hover {
        background: #f5f5f5;
        color: #242424;
        border-color: transparent;
    }

    .button-container-focus .tab-pill.is-active {
        background: transparent;
        color: #0068b5;
        border-bottom-color: #0068b5;
        box-shadow: none;
    }

    .link-container {
        margin-top: 10px;
        justify-content: flex-start;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        box-shadow: none;
        padding: 8px 10px;
    }

    .link-container a {
        background: #f5f5f5;
        color: #242424;
        font-weight: 600;
        font-size: 12px;
        border-radius: 999px;
    }

    .container-fluid.page-body-wrapper {
        padding-left: 4px !important;
        padding-right: 4px !important;
        margin-left: 0 !important;
        margin-right: 0 !important;
        max-width: 100% !important;
    }

    .portal-layout-shell {
        gap: 8px;
        margin-top: 0;
        flex-wrap: wrap;
    }

    .portal-layout-shell > .portal-main-workspace {
        flex: 1 1 calc(100% - 228px);
    }

    .portal-layout-shell > .gridview-container-wrapper {
        flex: 0 0 100%;
        width: 100%;
        margin-top: 8px;
    }

    .portal-left-nav {
        padding: 10px 8px;
        top: 48px;
        min-height: calc(100vh - 48px);
        max-height: calc(100vh - 48px);
    }

    .portal-section-header {
        margin: 0 2px 10px;
        padding: 6px 0;
    }

    .portal-left-nav .portal-nav-link {
        margin: 0 0 8px;
        padding: 10px 10px;
    }

    .content-wrapper {
        margin: 6px 4px 10px;
        padding: 8px;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        min-height: 0;
    }

    .table-container {
        max-height: none;
        overflow: visible;
        border: none;
        box-shadow: none;
        background: transparent;
        padding: 0;
    }

    .pane-heading {
        margin: 8px 0 10px;
        padding: 10px 14px;
        border-radius: 8px;
        border: 1px solid #e0e0e0;
        background: #fafafa;
        color: #242424;
        font-size: 14px;
        letter-spacing: 0.03em;
        text-transform: uppercase;
        text-align: left;
        display: none !important;
    }

    .portal-view-row {
        display: flex;
        justify-content: flex-start;
        margin: 10px 0 8px;
    }

    .portal-view-dropdown {
        min-width: 240px;
        height: 40px;
        border-radius: 10px;
        border: 1px solid #c6d4e1;
        background: #ffffff;
        color: #23364b;
        font-weight: 600;
        padding: 0 10px;
    }

    .issue-platform-links-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        margin: 8px 0 10px;
        flex-wrap: wrap;
    }

    .issue-platform-switcher {
        flex: 1;
        min-width: 420px;
        margin: 0;
    }

    .issue-external-links {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
    }

    .issue-external-links a,
    .issue-external-links .aspNetDisabled {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-height: 34px;
        padding: 8px 12px;
        border-radius: 999px;
        border: 1px solid #d7e1ec;
        background: #f8fbff;
        color: #1b4e7f;
        font-size: 12px;
        font-weight: 700;
        text-decoration: none;
        transition: all 0.2s ease;
    }

    .issue-external-links a:hover {
        background: #e6f0fb;
        color: #0a3a66;
        border-color: #bfd4e5;
    }

    .field-selector-panel {
        margin: 8px 0 12px;
        border-radius: 10px;
    }

    .gridview-container {
        margin-top: 0;
        padding-top: 0;
        overflow-x: auto;
    }

    .gridview-container .table-primary,
    .gridview-container #overall_request_details {
        min-width: 100% !important;
        width: 100% !important;
        table-layout: fixed;
    }

    .gridview-container .table-primary th,
    .gridview-container .table-primary td {
        white-space: normal !important;
        overflow-wrap: anywhere;
        word-break: break-word;
    }

    .empty-data-container table.table-primary {
        min-width: 100% !important;
        width: 100% !important;
    }

    .table-primary td,
    #overall_request_details td {
        white-space: normal;
        word-break: break-word;
        padding: 16px !important;
        vertical-align: top !important;
    }

    .table-primary .field-title,
    .table-primary .field-customer_detail,
    .table-primary .field-duplicatedetails {
        min-width: 180px;
        max-width: 300px;
    }

    .table-primary .field-milestone {
        min-width: 120px;
        max-width: 200px;
    }

    /* Dynamic-width columns: size to content, wrap long lines */
    .table-primary th,
    .table-primary td {
        width: auto;
        word-break: break-word;
        overflow-wrap: anywhere;
        white-space: normal;
        max-width: 100%;
    }

    .table-primary td *,
    #overall_request_details td * {
        max-width: 100%;
        min-width: 0;
        overflow-wrap: anywhere;
        word-break: break-word;
        white-space: normal;
    }

    .table-primary .field-component,
    .table-primary .field-owner,
    .table-primary .field-promoted_owner {
        min-width: 160px;
        max-width: 260px;
    }
    .table-primary .field-sno { min-width: 42px; max-width: 56px; }
    .table-primary .field-sightingid { min-width: 140px; max-width: 200px; }
    .table-primary .field-status { min-width: 180px; max-width: 240px; }
    .table-primary .field-cmf_status { min-width: 130px; max-width: 240px; }
    .table-primary .field-imagefreeze { min-width: 80px; max-width: 110px; }
    .table-primary .field-days_open { min-width: 60px; max-width: 80px; }
    .table-primary .field-impact { min-width: 130px; max-width: 220px; }
    .table-primary .field-rvp_repro { min-width: 90px; max-width: 140px; }
    .table-primary .field-idst { min-width: 110px; max-width: 200px; }
    .table-primary .field-los { min-width: 60px; max-width: 80px; }

    /* Customer Detail combined cell */
    .issue-details-cell,
        max-width: 100%; /* This line is now correctly placed */
        display: flex;
        flex-direction: column;
        gap: 12px;
        align-items: flex-start;
    }

    .issue-title-text {
        color: #172b3f;
        word-break: break-word;
        max-width: 100%;
        line-height: 1.35;
    .cmf-pending-grid-wrap #GridView_cmf_pending td *,
    .cmf-pending-grid-wrap #GridView_cmf_pending th * {
        max-width: 100%;
        min-width: 0;
        overflow-wrap: anywhere;
        word-break: break-word;
        white-space: normal;
    }
        overflow-wrap: anywhere;
        word-break: break-word;
    }

    .issue-meta-row {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        align-items: center;
        max-width: 100%;
        min-width: 0;
    }

    .issue-id-link,
    .issue-promoted-id,
    .cmf-request-chip {
        display: inline-flex;
        max-width: 100%;
        overflow-wrap: anywhere;
        word-break: break-word;
        align-items: center;
        min-height: 20px;
        padding: 2px 7px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 800;
        line-height: 1;
        text-decoration: none;
        white-space: nowrap;
    }

    .issue-id-link {
        color: #075ea8;
        background: #eaf4ff;
        border: 1px solid #c9dff3;
    }

    .issue-promoted-id {
        color: #4f5f73;
        background: #f3f6fa;
        border: 1px solid #e0e7ef;
    }

    .cmf-request-chip {
        color: #0f766e;
        background: #e9fbf7;
        border: 1px solid #c8efe6;
    }

    .days-open-pill {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 46px;
        min-height: 30px;
        padding: 4px 8px;
        border-radius: 999px;
        background: #fff5f1;
        color: #c2410c;
        border: 1px solid #fed7c7;
        font-weight: 800;
        font-size: 12px;
    }

    .impact-processor-cell,
    .milestone-progress-cell {
        display: flex;
        flex-direction: column;
        gap: 7px;
        align-items: flex-start;
    }

    .impact-processor-cell {
        gap: 16px;
    }

    .impact-text {
        font-size: 12px;
        color: #26384d;
        font-weight: 700;
        line-height: 1.35;
        overflow-wrap: anywhere;
    }

    .progress-track {
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .progress-dot {
        width: 7px;
        height: 7px;
        border-radius: 50%;
        background: #d5deea;
    }

    .progress-dot.is-active { background: #0f6db5; }

    .progress-badge {
        display: inline-flex;
        padding: 2px 8px;
        border-radius: 999px;
        background: #eef6ff;
        color: #095c9f;
        border: 1px solid #cfe4f8;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
    }

    .milestone-progress-fill {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 54px;
        width: 100%;
        border-radius: 10px;
        padding: 10px 8px;
        text-align: center;
        color: #ffffff;
        font-weight: 900;
        font-size: 12px;
        line-height: 1.25;
        box-shadow: inset 0 -12px 22px rgba(0, 0, 0, 0.08);
        overflow-wrap: anywhere;
    }

    .milestone-progress-red { background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%); }
    .milestone-progress-orange { background: linear-gradient(135deg, #f97316 0%, #c2410c 100%); }
    .milestone-progress-yellow { background: linear-gradient(135deg, #facc15 0%, #ca8a04 100%); color: #3f2f05; }
    .milestone-progress-green { background: linear-gradient(135deg, #22c55e 0%, #15803d 100%); }
    .milestone-progress-neutral { background: linear-gradient(135deg, #64748b 0%, #334155 100%); }

    .reports-format-card {
        background: #ffffff;
        border: 1px solid #d8e3ee;
        border-radius: 12px;
        padding: 16px;
        box-shadow: 0 2px 4px rgba(0,0,0,.08);
        flex-shrink: 0;
    }

    .reports-format-title {
        margin: 0 0 4px;
        color: #0f3554;
        font-size: 17px;
        font-weight: 800;
    }

    .reports-format-subtitle {
        color: #45627d;
        font-size: 12px;
        margin-bottom: 10px;
    }

    .reports-format-textarea {
        width: 100%;
        min-height: 172px;
        border: 1px solid #c8d9ea;
        border-radius: 10px;
        padding: 12px;
        color: #18324a;
        background: #fbfdff;
        font-family: Consolas, 'Courier New', monospace;
        font-size: 12px;
        line-height: 1.45;
        resize: vertical;
    }

    .reports-format-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
        align-items: center;
        margin-top: 10px;
    }

    .issue-row-actions {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }

    .issue-sno-cell {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        width: 100%;
    }

    .milestone-text-only {
        display: inline-flex;
        align-items: center;
        max-width: 100%;
        min-height: 24px;
        padding: 3px 8px;
        border-radius: 7px;
        background: #eef5fb;
        color: #143a5a;
        font-size: 11px;
        font-weight: 800;
        line-height: 1.25;
        overflow-wrap: anywhere;
        word-break: break-word;
    }

    .company-badge-full {
        font-size: 11px !important;
        padding: 3px 10px !important;
        height: auto !important;
        min-width: auto !important;
        line-height: 1.5 !important;
        border-radius: 999px !important;
    }

    .customer-detail-text {
        display: block;
        padding-bottom: 8px;
        font-size: 12px;
        color: #374151;
        line-height: 1.35;
        word-break: break-word;
        overflow-wrap: anywhere;
    }

    .processor-chip {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        font-size: 11px;
        color: #4b5563;
        background: #f3f4f6;
        border: 1px solid #e5e7eb;
        border-radius: 4px;
        padding: 3px 8px;
        word-break: break-word;
        overflow-wrap: anywhere;
        max-width: 100%;
    }

    .processor-chip::before {
        content: "⚙";
        font-size: 10px;
        opacity: 0.6;
        flex-shrink: 0;
    }

    .milestone-with-company {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }

    .company-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 28px;
        height: 18px;
        padding: 0 6px;
        border-radius: 999px;
        color: #fff;
        font-size: 10px;
        font-weight: 700;
        letter-spacing: 0.04em;
        line-height: 1;
        flex-shrink: 0;
        box-shadow: inset 0 -1px 0 rgba(255, 255, 255, 0.18);
    }

    .company-badge-tone-0 { background: #0068b5; }
    .company-badge-tone-1 { background: #0f7c67; }
    .company-badge-tone-2 { background: #8f5cc6; }
    .company-badge-tone-3 { background: #b05d2e; }
    .company-badge-tone-4 { background: #6b7280; }
    .company-badge-tone-5 { background: #d13438; }

    .milestone-label {
        white-space: normal;
        overflow-wrap: anywhere;
        word-break: break-word;
    }

    /* SightingID + Promoted ID inline label:value layout */
    .id-pair-stack {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .id-inline-row {
        display: flex;
        align-items: baseline;
        gap: 5px;
        flex-wrap: wrap;
    }

    .id-inline-label {
        font-size: 11px;
        font-weight: 600;
        color: #6b7280;
        white-space: nowrap;
        flex-shrink: 0;
    }

    .id-inline-link {
        font-size: 13px;
        font-weight: 600;
        color: #0068b5;
        text-decoration: none;
        word-break: break-all;
    }

    .id-inline-link:hover { text-decoration: underline; }

    .id-inline-value {
        font-size: 13px;
        color: #4b5563;
        word-break: break-all;
    }

    .table-primary .pager,
    .table-primary .pager table {
        display: none;
    }

    .table-primary .pager a,
    .table-primary .pager span {
        display: inline-block;
        min-width: 36px;
        text-align: center;
        padding: 6px 10px;
        margin: 0 3px;
        border: 1px solid #d4d4d4;
        border-radius: 6px;
        font-size: 12px;
        color: #2e2e2e;
        background: #fafafa;
        text-decoration: none;
    }

    .table-primary .pager span {
        border-color: #0068b5;
        color: #0068b5;
        background: #eff6fc;
        font-weight: 700;
    }

    .issue-page-status {
        margin-top: 8px;
        text-align: right;
        font-size: 12px;
        color: #616161;
    }

    .issue-pager-controls {
        display: grid;
        grid-template-columns: 1fr auto 1fr;
        justify-content: stretch;
        align-items: center;
        gap: 6px;
        margin-top: 10px;
        padding: 8px 10px;
        border: 1px solid #e1e8f0;
        border-radius: 10px;
        background: #ffffff;
        box-shadow: 0 8px 18px rgba(30, 58, 90, 0.06);
        position: relative;
    }

    .issue-pager-btn,
    .issue-pager-current {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 40px;
        min-height: 32px;
        padding: 0 12px;
        border: 1px solid #d0d0d0;
        border-radius: 6px;
        font-size: 12px;
        text-decoration: none;
        background: #ffffff;
        color: #2a2a2a;
    }

    .issue-page-nav {
        grid-column: 2;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        flex-wrap: wrap;
    }

    .issue-pager-group-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 40px;
        min-height: 32px;
        padding: 0 10px;
        border: 1px solid #d0d0d0;
        border-radius: 6px;
        font-size: 14px;
        font-weight: bold;
        text-decoration: none;
        background: #f5f5f5;
        color: #666;
        cursor: pointer;
    }

    .issue-pager-group-btn:hover:not(.disabled) {
        background: #e0e0e0;
    }

    .issue-pager-current {
        background: #0068b5;
        border-color: #0068b5;
        color: #ffffff;
        font-weight: 700;
        min-width: 34px;
    }

    .issue-page-size-control {
        grid-column: 3;
        justify-self: end;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #58677a;
        font-size: 11px;
        font-weight: 700;
        white-space: nowrap;
    }

    .issue-page-size-select {
        height: 30px;
        min-width: 62px;
        border: 1px solid #cfdae8;
        border-radius: 8px;
        background: #f8fbff;
        color: #1f3b57;
        font-size: 12px;
        font-weight: 700;
        padding: 0 6px;
    }

    .issue-pager-btn.disabled,
    .issue-pager-btn.aspNetDisabled,
    .issue-pager-group-btn.disabled,
    .issue-pager-group-btn.aspNetDisabled {
        opacity: 0.45;
        cursor: not-allowed;
        pointer-events: none;
    }

    .table-primary,
    #overall_request_details,
    #GridView_cmf_pending,
    #GridView_analytics_summary {
        width: 100%;
        border-collapse: collapse !important;
        border-spacing: 0;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        overflow: hidden;
        margin-top: 0 !important;
        margin-bottom: 0;
        background: #ffffff;
    }

    .table-primary th,
    #overall_request_details th,
    #GridView_cmf_pending th,
    #GridView_analytics_summary th {
        background: #fafafa !important;
        color: #424242 !important;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        font-size: 11px !important;
        font-weight: 600 !important;
        border: 1px solid #e0e0e0 !important;
        padding: 10px 10px !important;
        vertical-align: top;
        text-align: left !important;
    }

    .table-primary td,
    #overall_request_details td,
    #GridView_cmf_pending td,
    #GridView_analytics_summary td {
        border: 1px solid #f0f0f0 !important;
        padding: 10px !important;
        font-size: 12px;
        color: #242424;
        background: #ffffff;
    }

    /* Issue List gets more breathing room than the other grids */
    #overall_request_details td {
        padding: 16px !important;
        vertical-align: top !important;
    }

    #overall_request_details tr:hover td,
    #GridView_cmf_pending tr:hover td,
    #GridView_analytics_summary tr:hover td {
        background: #f8fbff;
    }

    /* Final visual layer: keep Issue List/Pending away from flat Excel styling. */
    #overall_request_details {
        border-collapse: separate !important;
        border-spacing: 0 10px !important;
        border: 0 !important;
        background: transparent !important;
        overflow: visible !important;
    }

    #overall_request_details th {
        background: #ffffff !important;
        color: #5d6f84 !important;
        border-top: 1px solid #e6edf5 !important;
        border-bottom: 1px solid #e6edf5 !important;
        border-left: 0 !important;
        border-right: 0 !important;
    }

    #overall_request_details td {
        background: linear-gradient(180deg, #ffffff 0%, #fbfdff 100%) !important;
        border-top: 1px solid #e4edf6 !important;
        border-bottom: 1px solid #e4edf6 !important;
        border-left: 0 !important;
        border-right: 0 !important;
        box-shadow: 0 10px 24px rgba(16, 41, 67, 0.07) !important;
        transition: transform 0.16s ease, box-shadow 0.16s ease, border-color 0.16s ease;
    }

    #overall_request_details tr td:first-child {
        border-left: 1px solid #e4edf6 !important;
        border-radius: 10px 0 0 10px !important;
    }

    #overall_request_details tr td:last-child {
        border-right: 1px solid #e4edf6 !important;
        border-radius: 0 10px 10px 0 !important;
    }

    #overall_request_details tr:hover td {
        background: linear-gradient(180deg, #ffffff 0%, #f4f9ff 100%) !important;
        transform: translateY(-2px);
        border-color: #cfdff0 !important;
        box-shadow: 0 16px 34px rgba(16, 41, 67, 0.12) !important;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending {
        min-width: 1260px !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
        border: 1px solid #e8edf5 !important;
        border-radius: 10px !important;
        overflow: hidden !important;
        background: #ffffff !important;
        box-shadow: 0 10px 24px rgba(28, 48, 78, 0.05) !important;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending th {
        background: #f7f9fc !important;
        color: #243042 !important;
        border: 0 !important;
        border-bottom: 1px solid #e5ebf3 !important;
        padding: 10px 12px !important;
        font-size: 10px !important;
        font-weight: 800 !important;
        letter-spacing: 0 !important;
        text-transform: none !important;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending td {
        background: #ffffff !important;
        border: 0 !important;
        border-bottom: 1px solid #eef2f7 !important;
        box-shadow: none !important;
        padding: 12px !important;
        color: #1f2937 !important;
        vertical-align: top !important;
    }

    .cmf-pending-grid-wrap #GridView_cmf_pending tr:hover td {
        background: #fbfdff !important;
    }

    .cmf-pending-grid-wrap .pending-chip {
        border-radius: 999px;
        background: #eef5fb;
        color: #214967;
        font-size: 10px;
        font-weight: 800;
        line-height: 1.2;
    }

    .cmf-pending-grid-wrap .ai-summary-btn {
        width: 100%;
        min-height: 32px;
        border-radius: 8px;
        font-size: 11px;
        font-weight: 800;
        white-space: normal;
    }

    .cmf-pending-grid-wrap .pending-recommendation-btn {
        width: auto;
        max-width: 100%;
        white-space: nowrap;
    }

    .header-dropdown {
        height: 28px;
        width: 126px;
        border-radius: 4px !important;
        border: 1px solid #d1d1d1 !important;
        font-size: 11px !important;
        padding: 2px 6px !important;
        background: #ffffff !important;
        color: #242424 !important;
    }

    #searchfilters {
        margin: 0 0 10px;
        padding: 8px;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        background: #fafafa;
    }

    #searchfilters input[type="text"] {
        height: 30px;
        border: 1px solid #d1d1d1;
        border-radius: 4px;
        padding: 0 8px;
        font-size: 12px;
    }

    @media (max-width: 900px) {
        #updateinfo {
            display: none;
        }

        .button-container.button-container-focus {
            margin-top: 8px;
        }

        .content-wrapper {
            margin: 10px;
            padding: 10px;
        }

        .issue-kpi-row {
            grid-template-columns: repeat(2, minmax(120px, 1fr));
        }

        .portal-layout-shell {
            flex-direction: column;
            min-height: 0;
        }

        .portal-left-nav {
            width: 100%;
            flex: 1 1 auto;
            position: static;
            max-height: none;
            min-height: 0;
        }

        .issue-page-hd-top {
            align-items: flex-start;
        }
    }

    /* Final override: enforce horizontal scrolling for Issue List columns */
    .issue-grid-scroll {
        overflow: hidden !important;
        width: 100%;
        max-width: 100%;
        box-sizing: border-box;
        -webkit-overflow-scrolling: touch;
    }

    .issue-grid-inner {
        width: 100%;
        max-width: 100%;
        overflow-x: auto;
        overflow-y: visible;
        box-sizing: border-box;
    }

    .issue-grid-inner #overall_request_details {
        table-layout: fixed !important;
        width: 100% !important;
        min-width: 1620px !important;
        max-width: none !important;
        display: table !important;
        overflow: visible !important;
    }

    .issue-grid-inner #overall_request_details th,
    .issue-grid-inner #overall_request_details td {
        width: auto !important;
        min-width: 78px !important;
        max-width: none !important;
        white-space: normal !important;
        overflow: visible !important;
        text-overflow: clip !important;
        overflow-wrap: anywhere !important;
        word-break: break-word !important;
        vertical-align: top !important;
    }

    .issue-grid-inner #overall_request_details td > span,
    .issue-grid-inner #overall_request_details td .status-main,
    .issue-grid-inner #overall_request_details td .sysdebug-preview,
    .issue-grid-inner #overall_request_details td .component-column,
    .issue-grid-inner #overall_request_details td .owner-column,
    .issue-grid-inner #overall_request_details td .impact-column {
        display: block !important;
        width: 100% !important;
        max-width: 100% !important;
        white-space: normal !important;
        overflow-wrap: anywhere !important;
        word-break: break-word !important;
    }

    .issue-grid-inner #<%= overall_request_details.ClientID %>,
    .issue-grid-inner > table,
    .issue-grid-inner > .table-primary,
    .issue-grid-inner .table-primary {
        table-layout: fixed !important;
        width: 100% !important;
        min-width: 1560px !important;
        max-width: none !important;
        display: table !important;
    }

    .issue-grid-inner #overall_request_details .field-sno { width: 62px !important; min-width: 62px !important; }
    .issue-grid-inner #overall_request_details .field-issue_details { width: 175px !important; min-width: 175px !important; }
    .issue-grid-inner #overall_request_details .field-customer_detail { width: 116px !important; min-width: 116px !important; }
    .issue-grid-inner #overall_request_details .field-component { width: 116px !important; min-width: 116px !important; }
    .issue-grid-inner #overall_request_details .field-owner { width: 116px !important; min-width: 116px !important; }
    .issue-grid-inner #overall_request_details .field-status { width: 176px !important; min-width: 176px !important; }
    .issue-grid-inner #overall_request_details .field-cmf_status { width: 96px !important; min-width: 96px !important; }
    .issue-grid-inner #overall_request_details .field-idst { width: 92px !important; min-width: 92px !important; }
    .issue-grid-inner #overall_request_details .field-imagefreeze { width: 92px !important; min-width: 92px !important; }
    .issue-grid-inner #overall_request_details .field-los { width: 58px !important; min-width: 58px !important; text-align: center !important; }
    .issue-grid-inner #overall_request_details .field-rvp_repro { width: 78px !important; min-width: 78px !important; }
    .issue-grid-inner #overall_request_details .field-impact_processor { width: 110px !important; min-width: 110px !important; }
    .issue-grid-inner #overall_request_details .field-days_open { width: 58px !important; min-width: 58px !important; text-align: center !important; }
    .issue-grid-inner #overall_request_details .field-milestone { width: 112px !important; min-width: 112px !important; }
    .issue-grid-inner #overall_request_details .field-closed_reason { width: 128px !important; min-width: 128px !important; }

    .issue-grid-inner #overall_request_details th.field-sno,
    .issue-grid-inner #overall_request_details td.field-sno,
    .issue-grid-inner #overall_request_details th.field-days_open,
    .issue-grid-inner #overall_request_details td.field-days_open {
        text-align: center !important;
    }

    /* Reference-style Issue List polish */
    #mainDataWrapper {
        background: #f8fbff;
        border: 1px solid #e6edf6;
        border-radius: 14px;
        box-shadow: 0 10px 28px rgba(15, 35, 70, 0.06);
    }

    .issue-page-hd {
        margin: 0 0 12px;
    }

    .issue-page-title {
        color: #111827;
        font-size: 18px;
        line-height: 1.2;
        font-weight: 800;
        margin: 0;
    }

    .issue-page-desc {
        color: #64748b;
        font-size: 12px;
        margin: 4px 0 0;
    }

    .issue-kpi-row {
        grid-template-columns: repeat(4, minmax(150px, 1fr));
        gap: 12px;
        margin: 10px 0 14px;
    }

    .issue-kpi {
        position: relative;
        min-height: 92px;
        padding: 14px 16px;
        background: #ffffff;
        border: 1px solid #e8edf5;
        border-radius: 10px;
        box-shadow: 0 8px 20px rgba(28, 48, 78, 0.05);
        overflow: hidden;
    }

    .issue-kpi::before {
        content: "";
        position: absolute;
        inset: 0 auto 0 0;
        width: 4px;
        background: #ef4444;
        opacity: 0.85;
    }

    .issue-kpi:nth-child(2)::before { background: #f59e0b; }
    .issue-kpi:nth-child(3)::before { background: #22c55e; }
    .issue-kpi:nth-child(4)::before { background: #6366f1; }

    .issue-kpi-label {
        color: #334155;
        font-size: 11px;
        font-weight: 800;
        letter-spacing: 0;
        text-transform: none;
        margin-bottom: 8px;
    }

    .issue-kpi-value {
        color: #ef4444;
        font-size: 27px;
        line-height: 1;
        font-weight: 800;
        margin-bottom: 6px;
    }

    .issue-kpi-sub {
        color: #64748b;
        font-size: 11px;
        font-weight: 600;
    }

    #sharedFilterPanel.overview-platform-actions,
    .issue-top-filter-panel {
        background: #ffffff;
        border: 1px solid #e6edf6;
        border-radius: 10px;
        box-shadow: 0 8px 20px rgba(28, 48, 78, 0.04);
    }

    .issue-grid-inner #overall_request_details {
        min-width: 1668px !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
        border: 1px solid #e8edf5 !important;
        border-radius: 10px !important;
        overflow: hidden !important;
        background: #ffffff !important;
        box-shadow: 0 10px 24px rgba(28, 48, 78, 0.05) !important;
    }

    .issue-grid-inner #overall_request_details th {
        background: #f7f9fc !important;
        color: #243042 !important;
        border: 0 !important;
        border-bottom: 1px solid #e5ebf3 !important;
        padding: 10px 12px !important;
        font-size: 10px !important;
        font-weight: 800 !important;
        letter-spacing: 0 !important;
        text-transform: none !important;
    }

    .issue-grid-inner #overall_request_details td {
        background: #ffffff !important;
        border: 0 !important;
        border-bottom: 1px solid #eef2f7 !important;
        box-shadow: none !important;
        padding: 12px !important;
        color: #1f2937 !important;
    }

    .issue-grid-inner #overall_request_details tr:hover td {
        background: #fbfdff !important;
    }

    .issue-grid-inner #overall_request_details .field-status,
    .issue-grid-inner #overall_request_details td.field-status,
    .issue-grid-inner #overall_request_details th.field-status {
        overflow: hidden !important;
        word-break: normal !important;
        overflow-wrap: break-word !important;
    }

    .issue-grid-inner #overall_request_details td.field-status > span,
    .issue-grid-inner #overall_request_details td.field-status .status-cell-wrap-compact,
    .issue-grid-inner #overall_request_details td.field-status .status-one-line {
        width: 100% !important;
        max-width: 100% !important;
        min-width: 0 !important;
    }

    .issue-grid-inner .empty-data-container,
    .issue-grid-inner .empty-data-container table,
    .issue-grid-inner .empty-data-container table.table-primary {
        width: 100% !important;
        min-width: 100% !important;
        max-width: 100% !important;
    }

    .issue-scroll-proxy {
        display: none !important;
        width: 100%;
        overflow-x: scroll;
        overflow-y: hidden;
        height: 18px;
        margin-top: 6px;
        border: 1px solid #d7d7d7;
        border-radius: 2px;
        background: #f5f5f5;
    }

    .issue-scroll-proxy-inner {
        height: 1px;
    }

    header #updateinfo,
    #updateinfo {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        width: 0 !important;
        overflow: hidden !important;
    }

    .portal-layout-shell {
        margin-top: 0 !important;
    }

    .portal-left-nav {
        top: 48px !important;
        min-height: calc(100vh - 48px) !important;
        max-height: calc(100vh - 48px) !important;
        border-radius: 0 0 12px 12px !important;
    }

    /* Final layout corrections for side menu alignment and scroll whitespace */
    .container-scroller,
    .container-fluid.page-body-wrapper {
        padding-left: 0 !important;
        margin-left: 0 !important;
    }

    .portal-layout-shell {
        min-height: 0 !important;
        margin-left: 0 !important;
    }

    .portal-left-nav {
        margin-left: 0 !important;
        left: 0 !important;
        border-radius: 0 12px 12px 0 !important;
    }

    .gridview-container-wrapper {
        align-items: flex-start;
    }

    .gridview-container3 {
        height: auto !important;
        min-height: 0 !important;
        margin-bottom: 0 !important;
    }

    /* Remove Issue List hover lift/shadow effect */
    #overall_request_details tr:hover td,
    .issue-grid-inner #overall_request_details tr:hover td {
        transform: none !important;
        box-shadow: none !important;
        background: #ffffff !important;
        border-color: #eef2f7 !important;
    }

    /* ============================================================
    CMF PORTAL — PHASE 1 USER-CENTRIC UI
    ============================================================ */

    /* ------------------------------------------------------------
    APPLICATION SURFACE
    ------------------------------------------------------------ */

    html,
    body {
        background: #f5f7fb !important;
        color: #172033 !important;
    }

    body {
        font-family:
            "Segoe UI",
            Inter,
            Arial,
            sans-serif !important;
    }


    /* ------------------------------------------------------------
    TOP HEADER
    ------------------------------------------------------------ */

    header {
        min-height: 72px !important;
        height: 72px !important;

        padding: 0 24px !important;

        display: flex !important;
        align-items: center !important;
        justify-content: flex-start !important;

        background: #ffffff !important;

        color: #172033 !important;

        border-bottom: 1px solid #e4e8ee !important;

        box-shadow: 0 2px 8px rgba(16, 24, 40, 0.05) !important;

        position: sticky !important;
        top: 0 !important;

        z-index: 1000 !important;
    }

    .header-title {
        color: #172033 !important;

        font-size: 17px !important;
        font-weight: 750 !important;

        letter-spacing: 0 !important;
        text-transform: none !important;

        text-align: left !important;
    }

    .header-user-mode {
        right: 24px !important;

        color: #475467 !important;
    }

    .header-mode-dropdown {
        height: 36px !important;

        min-width: 155px !important;

        background: #ffffff !important;

        color: #344054 !important;

        border: 1px solid #d0d5dd !important;

        border-radius: 8px !important;
    }

    .sidebar-toggle-div {
        display: none !important;
    }


    /* ------------------------------------------------------------
    LEFT NAVIGATION
    ------------------------------------------------------------ */

    .portal-layout-shell {
        gap: 0 !important;

        min-height: calc(100vh - 72px) !important;
    }

    .portal-left-nav {
        width: 188px !important;
        flex: 0 0 188px !important;

        top: 72px !important;

        min-height: calc(100vh - 72px) !important;
        max-height: calc(100vh - 72px) !important;

        padding: 14px 10px !important;

        background: #071a44 !important;

        border-radius: 0 !important;

        box-shadow: none !important;

        border-right: 1px solid rgba(255,255,255,0.08) !important;
    }

    .portal-left-nav .portal-nav-link {
        min-height: 42px !important;

        padding: 10px 12px !important;

        margin-bottom: 5px !important;

        border: none !important;

        background: transparent !important;

        border-radius: 8px !important;

        color: #d9e4f2 !important;

        font-size: 13px !important;
        font-weight: 600 !important;
    }

    .portal-left-nav .portal-nav-link:hover {
        background: rgba(59,130,246,0.16) !important;

        transform: none !important;

        box-shadow: none !important;
    }

    .portal-left-nav .portal-nav-link.is-active {
        background: #315bea !important;

        border: none !important;

        box-shadow: none !important;

        color: #ffffff !important;
    }

    .portal-left-nav .portal-nav-link.is-active:before {
        display: none !important;
    }

    .portal-left-nav-title {
        color: #ffffff !important;
    }


    /* ------------------------------------------------------------
    MAIN CONTENT
    ------------------------------------------------------------ */

    .portal-main-workspace {
        min-width: 0 !important;

        width: 100% !important;
    }

    .content-wrapper {
        width: 100% !important;

        box-sizing: border-box !important;

        margin: 0 !important;

        padding: 24px 26px 40px !important;

        background: #f5f7fb !important;

        border: none !important;

        box-shadow: none !important;

        border-radius: 0 !important;
    }


    /* Remove old banner-style tab headings */

    .pane-heading {
        background: transparent !important;

        border: none !important;

        box-shadow: none !important;

        padding: 0 !important;

        margin: 0 0 16px !important;

        color: #172033 !important;

        font-size: 24px !important;

        font-weight: 750 !important;

        letter-spacing: -0.02em !important;

        text-transform: none !important;

        text-align: left !important;
    }


    /* ------------------------------------------------------------
    ISSUE LIST LAYOUT
    ------------------------------------------------------------ */

    .issue-tab-shell {
        display: grid !important;

        grid-template-columns:
            minmax(0, 1fr)
            240px !important;

        gap: 16px !important;

        align-items: start !important;
    }

    .issue-tab-main {
        min-width: 0 !important;
    }


    /* ------------------------------------------------------------
    ISSUE PAGE HEADER
    ------------------------------------------------------------ */

    .issue-page-hd {
        background: transparent !important;

        border: none !important;

        box-shadow: none !important;

        padding: 0 0 4px !important;

        margin-bottom: 14px !important;
    }

    .issue-page-title {
        margin: 0 !important;

        color: #172033 !important;

        font-size: 24px !important;

        font-weight: 750 !important;

        letter-spacing: -0.02em !important;
    }

    .issue-page-desc {
        margin: 5px 0 0 !important;

        color: #667085 !important;

        font-size: 13px !important;

        line-height: 1.45 !important;
    }


    /* ------------------------------------------------------------
    ISSUE KPI CARDS
    ------------------------------------------------------------ */

    .issue-kpi-row {
        display: grid !important;

        grid-template-columns:
            repeat(4, minmax(0, 1fr)) !important;

        gap: 12px !important;

        margin-bottom: 14px !important;
    }

    .issue-kpi {
        min-height: 92px !important;

        padding: 14px 16px !important;

        background: #ffffff !important;

        border: 1px solid #e4e7ec !important;

        border-radius: 12px !important;

        box-shadow:
            0 2px 7px rgba(16,24,40,0.04) !important;
    }

    .issue-kpi-label {
        color: #667085 !important;

        font-size: 11px !important;

        font-weight: 700 !important;
    }

    .issue-kpi-value {
        margin-top: 5px !important;

        color: #172033 !important;

        font-size: 28px !important;

        font-weight: 800 !important;
    }

    .issue-kpi-sub {
        margin-top: 5px !important;

        color: #98a2b3 !important;

        font-size: 10px !important;
    }


    /* ------------------------------------------------------------
    ISSUE FILTER PANEL
    ------------------------------------------------------------ */

    .issue-top-filter-panel,
    #sharedFilterPanel.overview-platform-actions {
        background: #ffffff !important;

        border: 1px solid #e4e7ec !important;

        border-radius: 12px !important;

        box-shadow:
            0 2px 7px rgba(16,24,40,0.04) !important;

        padding: 14px !important;

        margin-bottom: 12px !important;
    }

    .issue-filter-section-header {
        margin-bottom: 10px !important;
    }

    .issue-filter-title {
        color: #172033 !important;

        font-size: 13px !important;

        font-weight: 750 !important;
    }

    .issue-top-filter-grid {
        display: grid !important;

        grid-template-columns:
            repeat(4, minmax(150px, 1fr)) !important;

        gap: 10px !important;
    }

    .issue-top-filter-item {
        display: flex !important;

        flex-direction: column !important;

        gap: 5px !important;
    }

    .issue-top-filter-item > span {
        color: #667085 !important;

        font-size: 10px !important;

        font-weight: 700 !important;
    }

    .issue-top-filter-item .header-dropdown {
        width: 100% !important;

        max-width: none !important;

        height: 34px !important;

        background: #ffffff !important;

        border: 1px solid #d0d5dd !important;

        border-radius: 7px !important;

        color: #344054 !important;

        font-size: 11px !important;
    }

    .issue-top-filter-buttons {
        margin-top: 10px !important;
    }


    /* ------------------------------------------------------------
    ISSUE SEARCH TOOLBAR
    ------------------------------------------------------------ */

    .issue-user-toolbar {
        display: flex !important;

        align-items: center !important;

        justify-content: space-between !important;

        gap: 12px !important;

        margin-bottom: 10px !important;
    }

    .issue-search-box {
        position: relative !important;

        flex: 1 1 360px !important;

        max-width: 520px !important;
    }

    .issue-search-box > i {
        position: absolute !important;

        left: 12px !important;

        top: 50% !important;

        transform: translateY(-50%) !important;

        color: #98a2b3 !important;

        font-size: 12px !important;
    }

    #issueQuickSearch {
        width: 100% !important;

        height: 38px !important;

        box-sizing: border-box !important;

        padding: 0 38px 0 34px !important;

        border: 1px solid #d0d5dd !important;

        border-radius: 8px !important;

        background: #ffffff !important;

        color: #172033 !important;

        font-size: 12px !important;

        outline: none !important;
    }

    #issueQuickSearch:focus {
        border-color: #4f6bed !important;

        box-shadow:
            0 0 0 3px rgba(79,107,237,0.10) !important;
    }

    .issue-search-clear {
        display: none;

        position: absolute !important;

        right: 8px !important;

        top: 50% !important;

        transform: translateY(-50%) !important;

        width: 24px !important;

        height: 24px !important;

        border: none !important;

        background: transparent !important;

        color: #98a2b3 !important;

        cursor: pointer !important;
    }

    .issue-user-actions {
        display: flex !important;

        gap: 8px !important;

        align-items: center !important;
    }

    .issue-toolbar-btn {
        min-height: 36px !important;

        padding: 0 12px !important;

        border: 1px solid #d0d5dd !important;

        border-radius: 8px !important;

        background: #ffffff !important;

        color: #344054 !important;

        font-size: 11px !important;

        font-weight: 700 !important;

        cursor: pointer !important;
    }

    .issue-toolbar-btn:hover {
        background: #f8fafc !important;

        border-color: #b8c0cc !important;
    }


    /* ------------------------------------------------------------
    ISSUE TABLE CONTAINER
    ------------------------------------------------------------ */

    .issue-grid-scroll {
        width: 100% !important;

        max-width: 100% !important;

        box-sizing: border-box !important;

        padding: 0 !important;

        border: 1px solid #e1e5eb !important;

        border-radius: 12px !important;

        background: #ffffff !important;

        box-shadow:
            0 2px 8px rgba(16,24,40,0.04) !important;

        overflow-x: auto !important;
    }

    .issue-grid-inner {
        min-width: 0 !important;
    }


    /* ------------------------------------------------------------
    ISSUE TABLE
    IMPORTANT: use field-* classes instead of nth-child()
    ------------------------------------------------------------ */

    #overall_request_details {
        width: 100% !important;

        min-width: 1050px !important;

        margin: 0 !important;

        border-collapse: separate !important;

        border-spacing: 0 !important;

        table-layout: auto !important;

        background: #ffffff !important;

        border: none !important;

        border-radius: 12px !important;

        box-shadow: none !important;

        font-size: 12px !important;
    }


    /* Header */

    #overall_request_details thead,
    #overall_request_details thead tr {
        background: #f8fafc !important;
    }

    #overall_request_details thead th {
        position: sticky !important;

        top: 0 !important;

        z-index: 10 !important;

        background: #f8fafc !important;

        color: #667085 !important;

        border: none !important;

        border-bottom: 1px solid #e4e7ec !important;

        padding: 11px 12px !important;

        font-size: 10px !important;

        font-weight: 750 !important;

        text-align: left !important;

        white-space: nowrap !important;
    }


    /* Hide filter dropdowns INSIDE table headers.
    Filters now live in the dedicated filter panel above. */

    #overall_request_details thead .filter-container {
        display: none !important;
    }

    #overall_request_details thead .filter-header-container {
        min-height: auto !important;

        align-items: flex-start !important;

        gap: 0 !important;
    }

    #overall_request_details thead .filter-header-text {
        margin: 0 !important;

        align-self: flex-start !important;

        text-align: left !important;
    }


    /* Body */

    #overall_request_details tbody tr {
        background: #ffffff !important;

        transition: background-color 0.12s ease !important;
    }

    #overall_request_details tbody tr:nth-child(even) {
        background: #fbfcfe !important;
    }

    #overall_request_details tbody tr:hover {
        background: #f5f9ff !important;
    }

    #overall_request_details tbody td {
        background: transparent !important;

        border: none !important;

        border-bottom: 1px solid #edf0f4 !important;

        padding: 13px 12px !important;

        color: #475467 !important;

        font-size: 12px !important;

        line-height: 1.45 !important;

        vertical-align: middle !important;

        overflow-wrap: anywhere !important;
    }

    #overall_request_details tbody tr:last-child td {
        border-bottom: none !important;
    }


    /* ------------------------------------------------------------
    ISSUE DETAILS — MOST IMPORTANT
    ------------------------------------------------------------ */

    #overall_request_details .field-issue_details {
        min-width: 280px !important;

        max-width: 360px !important;

        color: #172033 !important;

        font-size: 12px !important;

        font-weight: 500 !important;
    }

    #overall_request_details .field-issue_details a {
        color: #0068b5 !important;

        font-weight: 750 !important;

        text-decoration: none !important;
    }

    #overall_request_details .field-issue_details a:hover {
        color: #004f86 !important;

        text-decoration: underline !important;
    }


    /* ------------------------------------------------------------
    CUSTOMER
    ------------------------------------------------------------ */

    #overall_request_details .field-customer_detail {
        min-width: 135px !important;

        max-width: 180px !important;

        color: #344054 !important;

        font-weight: 600 !important;
    }


    /* ------------------------------------------------------------
    COMPONENT
    ------------------------------------------------------------ */

    #overall_request_details .field-component {
        min-width: 135px !important;

        max-width: 175px !important;

        color: #475467 !important;
    }


    /* ------------------------------------------------------------
    OWNER
    ------------------------------------------------------------ */

    #overall_request_details .field-owner {
        min-width: 120px !important;

        max-width: 160px !important;

        color: #475467 !important;
    }


    /* ------------------------------------------------------------
    MILESTONE
    ------------------------------------------------------------ */

    #overall_request_details .field-milestone {
        min-width: 105px !important;

        max-width: 150px !important;

        color: #344054 !important;

        font-weight: 600 !important;
    }


    /* ------------------------------------------------------------
    STATUS
    ------------------------------------------------------------ */

    #overall_request_details .field-status {
        min-width: 125px !important;

        max-width: 170px !important;

        color: #344054 !important;
    }


    /* ------------------------------------------------------------
    IMPACT
    ------------------------------------------------------------ */

    #overall_request_details .field-impact_processor {
        min-width: 190px !important;

        max-width: 250px !important;

        color: #475467 !important;
    }


    /* ------------------------------------------------------------
    DAYS OPEN
    ------------------------------------------------------------ */

    #overall_request_details .field-days_open {
        min-width: 75px !important;

        width: 75px !important;

        text-align: center !important;

        font-weight: 750 !important;
    }

    #overall_request_details .field-days_open .days-open,
    #overall_request_details .field-days_open span {
        display: inline-flex !important;

        align-items: center !important;

        justify-content: center !important;

        min-width: 34px !important;

        min-height: 25px !important;

        padding: 3px 8px !important;

        border-radius: 999px !important;

        background: #fff7e6 !important;

        border: 1px solid #f1d59b !important;

        color: #9a6700 !important;

        font-size: 11px !important;

        font-weight: 750 !important;
    }


    /* ------------------------------------------------------------
    STATUS / GENERAL BADGES
    ------------------------------------------------------------ */

    #overall_request_details .badge,
    #overall_request_details .tag,
    #overall_request_details [class*="badge"],
    #overall_request_details [class*="tag"] {
        display: inline-flex !important;

        align-items: center !important;

        justify-content: center !important;

        min-height: 23px !important;

        padding: 3px 9px !important;

        border-radius: 999px !important;

        font-size: 10px !important;

        font-weight: 700 !important;

        white-space: nowrap !important;
    }


    /* ------------------------------------------------------------
    EDIT COLUMN
    ------------------------------------------------------------ */

    #overall_request_details tbody td:first-child {
        width: 46px !important;

        min-width: 46px !important;

        text-align: center !important;

        padding: 10px 5px !important;
    }


    /* ------------------------------------------------------------
    AI SUMMARY BUTTON
    ------------------------------------------------------------ */

    #overall_request_details .ai-summary-btn,
    #overall_request_details .ai-summary-trigger {
        border-radius: 7px !important;
    }


    /* ------------------------------------------------------------
    SIDE ASSISTANT
    ------------------------------------------------------------ */

    .issue-side-panel {
        width: auto !important;

        box-sizing: border-box !important;

        padding: 10px !important;

        background: transparent !important;

        border: none !important;

        box-shadow: none !important;

        border-radius: 0 !important;

        gap: 10px !important;

        position: sticky !important;

        top: 90px !important;
    }

    .interactive-side-card {
        background: #ffffff !important;

        border: 1px solid #e4e7ec !important;

        border-radius: 12px !important;

        box-shadow:
            0 2px 7px rgba(16,24,40,0.04) !important;

        padding: 12px !important;
    }

    .interactive-side-title {
        font-size: 13px !important;

        color: #172033 !important;
    }

    .interactive-side-sub {
        font-size: 11px !important;

        line-height: 1.45 !important;

        color: #667085 !important;
    }


    /* ------------------------------------------------------------
    PAGINATION
    ------------------------------------------------------------ */

    .issue-pager-controls {
        display: grid !important;

        grid-template-columns: 1fr auto 1fr !important;

        align-items: center !important;

        justify-content: stretch !important;

        gap: 5px !important;

        margin-top: 12px !important;

        padding: 8px 0 !important;
    }


    /* ------------------------------------------------------------
    RESPONSIVE
    ------------------------------------------------------------ */

    @media (max-width: 1200px) {

        .issue-tab-shell {
            grid-template-columns: 1fr !important;
        }

        .issue-side-panel {
            position: static !important;

            display: grid !important;

            grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
        }

        .issue-kpi-row {
            grid-template-columns: repeat(2, 1fr) !important;
        }

        .issue-top-filter-grid {
            grid-template-columns: repeat(3, minmax(150px, 1fr)) !important;
        }
    }

    @media (max-width: 760px) {

        .content-wrapper {
            padding: 16px !important;
        }

        .issue-user-toolbar {
            align-items: stretch !important;

            flex-direction: column !important;
        }

        .issue-search-box {
            max-width: none !important;
        }

        .issue-user-actions {
            justify-content: flex-start !important;
        }

        .issue-kpi-row {
            grid-template-columns: 1fr !important;
        }

        .issue-top-filter-grid {
            grid-template-columns: 1fr !important;
        }

        .issue-side-panel {
            grid-template-columns: 1fr !important;
        }
    }

    /* ============================================================
   CMF PENDING LIST
   ============================================================ */

    .pending-tab-shell {
        display: grid !important;

        grid-template-columns:
            minmax(0, 1fr)
            240px !important;

        gap: 16px !important;

        align-items: start !important;
    }

    .pending-tab-main {
        min-width: 0 !important;
    }

    .cmf-pending-page-hd {
        background: transparent !important;

        border: none !important;

        box-shadow: none !important;

        padding: 0 0 6px !important;

        margin-bottom: 14px !important;
    }

    .cmf-pending-page-title {
        margin: 0 !important;

        color: #172033 !important;

        font-size: 24px !important;

        font-weight: 750 !important;
    }

    .cmf-pending-page-desc {
        margin: 5px 0 0 !important;

        color: #667085 !important;

        font-size: 13px !important;
    }

    .cmf-pending-grid-wrap {
        width: 100% !important;

        box-sizing: border-box !important;

        padding: 0 !important;

        background: #ffffff !important;

        border: 1px solid #e1e5eb !important;

        border-radius: 12px !important;

        box-shadow:
            0 2px 8px rgba(16,24,40,0.04) !important;

        overflow-x: auto !important;
    }

    #GridView_cmf_pending {
        width: 100% !important;

        min-width: 900px !important;

        border-collapse: separate !important;

        border-spacing: 0 !important;

        background: #ffffff !important;
    }

    #GridView_cmf_pending th {
        background: #f8fafc !important;

        color: #667085 !important;

        border: none !important;

        border-bottom: 1px solid #e4e7ec !important;

        padding: 11px 12px !important;

        font-size: 10px !important;

        font-weight: 750 !important;

        text-align: left !important;
    }

    #GridView_cmf_pending td {
        background: #ffffff !important;

        color: #475467 !important;

        border: none !important;

        border-bottom: 1px solid #edf0f4 !important;

        padding: 13px 12px !important;

        font-size: 12px !important;

        line-height: 1.45 !important;

        vertical-align: top !important;
    }

    #GridView_cmf_pending tr:hover td {
        background: #f5f9ff !important;
    }

    .pending-side-panel {
        position: sticky !important;

        top: 90px !important;

        background: transparent !important;

        border: none !important;

        box-shadow: none !important;

        padding: 10px !important;
    }

    /* Reference-style top bar, global search, and compact work tables */
    header {
        height: 66px !important;
        min-height: 66px !important;
        padding: 0 22px !important;
        background: #fbfcff !important;
        border-bottom: 1px solid #e6ebf2 !important;
        box-shadow: 0 1px 10px rgba(15, 23, 42, 0.05) !important;
        gap: 22px !important;
    }

    .header-title {
        min-width: 220px !important;
        color: #16213a !important;
        font-size: 16px !important;
        font-weight: 800 !important;
    }

    .global-search-shell {
        position: relative;
        width: min(480px, 42vw);
        min-width: 320px;
        margin: 0 auto;
        display: flex;
        align-items: center;
        color: #73839a;
    }

    .global-search-shell > i {
        position: absolute;
        left: 14px;
        font-size: 13px;
        color: #75839a;
        pointer-events: none;
    }

    #globalPortalSearch {
        width: 100%;
        height: 38px;
        padding: 0 84px 0 40px;
        border: 1px solid #dce3ee;
        border-radius: 10px;
        background: #ffffff;
        color: #1d2939;
        font-size: 12px;
        font-weight: 600;
        outline: none;
        box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
    }

    #globalPortalSearch:focus {
        border-color: #6b8cff;
        box-shadow: 0 0 0 3px rgba(49, 91, 234, 0.12), 0 6px 18px rgba(15, 23, 42, 0.07);
    }

    .global-search-shortcut {
        position: absolute;
        right: 12px;
        display: inline-flex;
        align-items: center;
        height: 20px;
        padding: 0 7px;
        border: 1px solid #dce3ee;
        border-radius: 6px;
        background: #f8fafc;
        color: #667085;
        font-size: 10px;
        font-weight: 800;
    }

    .global-search-clear {
        display: none;
        position: absolute;
        right: 70px;
        width: 22px;
        height: 22px;
        border: none;
        border-radius: 999px;
        background: #eef2f7;
        color: #667085;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 15px;
        line-height: 1;
    }

    .header-user-mode {
        position: static !important;
        margin-left: 0 !important;
        color: #475467 !important;
    }

    .header-mode-dropdown {
        height: 34px !important;
        min-width: 148px !important;
        border-radius: 9px !important;
        font-size: 12px !important;
        font-weight: 700 !important;
    }

    .portal-left-nav {
        top: 66px !important;
        min-height: calc(100vh - 66px) !important;
        max-height: calc(100vh - 66px) !important;
        background: linear-gradient(180deg, #061840 0%, #071f5c 58%, #03112e 100%) !important;
    }

    .content-wrapper {
        background: #f6f8fc !important;
        padding: 18px 22px 34px !important;
    }

    .issue-page-hd,
    .cmf-pending-page-hd {
        margin-bottom: 10px !important;
    }

    .issue-page-title,
    .cmf-pending-page-title {
        font-size: 21px !important;
        letter-spacing: 0 !important;
    }

    .issue-page-desc,
    .cmf-pending-page-desc {
        font-size: 12px !important;
    }

    .issue-kpi-row {
        grid-template-columns: repeat(4, minmax(140px, 1fr)) !important;
        gap: 9px !important;
        margin-bottom: 10px !important;
    }

    .issue-kpi {
        min-height: 78px !important;
        padding: 11px 13px !important;
        border-radius: 10px !important;
        border-color: #e8edf5 !important;
        box-shadow: 0 3px 14px rgba(15, 23, 42, 0.035) !important;
    }

    .issue-kpi-value {
        font-size: 24px !important;
    }

    .issue-top-filter-panel {
        margin: 0 0 10px !important;
        padding: 0 !important;
        border: none !important;
        background: transparent !important;
        box-shadow: none !important;
    }

    .issue-filter-section-header {
        display: none !important;
    }

    #issueTopFilterBody {
        padding: 10px !important;
        margin-bottom: 10px !important;
        background: #ffffff !important;
        border: 1px solid #e3e9f2 !important;
        border-radius: 12px !important;
        box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04) !important;
    }

    .issue-top-filter-grid {
        display: flex !important;
        align-items: end !important;
        gap: 8px !important;
        overflow-x: auto !important;
        padding-bottom: 2px !important;
    }

    .issue-top-filter-item {
        min-width: 132px !important;
        flex: 0 0 132px !important;
    }

    .issue-top-filter-item > span {
        font-size: 9px !important;
        color: #697586 !important;
        text-transform: uppercase !important;
    }

    .issue-top-filter-item .header-dropdown {
        height: 30px !important;
        border-radius: 8px !important;
        font-size: 10px !important;
    }

    .issue-top-filter-buttons {
        margin-top: 8px !important;
    }

    .issue-user-toolbar {
        margin-bottom: 9px !important;
    }

    .issue-view-note {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: #667085;
        font-size: 12px;
        font-weight: 700;
    }

    .issue-toolbar-btn.filter-toggle {
        border-color: #dbe5ff !important;
        background: #eef4ff !important;
        color: #315bea !important;
    }

    .issue-toolbar-btn.filter-toggle[aria-expanded="true"],
    .issue-toolbar-btn.filter-toggle:hover {
        background: #315bea !important;
        color: #ffffff !important;
        border-color: #315bea !important;
    }

    #sharedFilterPanel.overview-platform-actions {
        padding: 10px 12px !important;
        margin-bottom: 10px !important;
        border-radius: 12px !important;
        box-shadow: 0 4px 16px rgba(15, 23, 42, 0.035) !important;
    }

    .issue-grid-scroll,
    .cmf-pending-grid-wrap {
        border-radius: 12px !important;
        border-color: #e3e9f2 !important;
        box-shadow: 0 6px 20px rgba(15, 23, 42, 0.045) !important;
    }

    #overall_request_details,
    #GridView_cmf_pending {
        font-size: 11px !important;
    }

    #overall_request_details thead th,
    #GridView_cmf_pending th {
        height: 38px !important;
        padding: 8px 10px !important;
        background: #fbfcff !important;
        color: #344054 !important;
        font-size: 9px !important;
        font-weight: 800 !important;
        text-transform: none !important;
        border-bottom: 1px solid #e5eaf2 !important;
    }

    #overall_request_details tbody td,
    #GridView_cmf_pending td {
        padding: 9px 10px !important;
        font-size: 11px !important;
        line-height: 1.35 !important;
        border-bottom: 1px solid #eef2f7 !important;
    }

    #overall_request_details tbody tr:nth-child(even),
    #GridView_cmf_pending tr:nth-child(even) td {
        background: #fcfdff !important;
    }

    #overall_request_details tbody tr:hover td,
    #GridView_cmf_pending tr:hover td {
        background: #f3f7ff !important;
    }

    #overall_request_details .field-issue_details {
        min-width: 250px !important;
        max-width: 330px !important;
    }

    #overall_request_details .field-days_open .days-open,
    #overall_request_details .field-days_open span {
        min-height: 21px !important;
        padding: 2px 7px !important;
        font-size: 10px !important;
    }

    .pending-tab-shell {
        grid-template-columns: minmax(0, 1fr) 250px !important;
    }

    .pending-tab-main .issue-top-filter-panel,
    .pending-tab-main .issue-user-toolbar {
        display: none !important;
    }

    .portal-view-hidden {
        display: none !important;
    }

    /* Final cleanup from PM feedback */
    .portal-left-nav.is-collapsed {
        width: 58px !important;
        flex: 0 0 58px !important;
        min-width: 58px !important;
        max-width: 58px !important;
        padding: 10px 7px !important;
    }

    .portal-left-nav.is-collapsed .portal-nav-active-title {
        display: none !important;
    }

    .portal-left-nav.is-collapsed .portal-nav-link {
        width: 42px !important;
        min-width: 42px !important;
        height: 42px !important;
        padding: 0 !important;
        margin: 0 auto 8px !important;
        justify-content: center !important;
        border-radius: 12px !important;
    }

    .portal-left-nav.is-collapsed .portal-nav-link span {
        display: none !important;
    }

    .portal-left-nav.is-collapsed .portal-nav-link i {
        margin: 0 !important;
        font-size: 16px !important;
    }

    .portal-layout-shell.main-menu-collapsed {
        gap: 0 !important;
    }

    .issue-grid-scroll {
        padding: 0 !important;
        border: none !important;
        border-radius: 0 !important;
        background: transparent !important;
        box-shadow: none !important;
        max-height: min(62vh, 620px) !important;
        min-height: 0 !important;
        overflow: auto !important;
        scrollbar-gutter: stable !important;
    }

    .issue-grid-scroll:has(#overall_request_details[style*="display: none"]),
    .issue-grid-scroll:has(#overall_request_details[style*="display:none"]) {
        display: none !important;
    }

    .issue-grid-inner #overall_request_details,
    #overall_request_details {
        border: 1px solid #e4eaf3 !important;
        border-radius: 12px !important;
        box-shadow: 0 8px 22px rgba(15, 23, 42, 0.045) !important;
    }

    .cmf-pending-page-hd {
        margin-top: 0 !important;
        margin-bottom: 12px !important;
    }

    .cmf-pending-grid-wrap {
        padding: 0 !important;
        border: none !important;
        border-radius: 0 !important;
        background: transparent !important;
        box-shadow: none !important;
        max-height: min(64vh, 640px) !important;
        min-height: 0 !important;
        overflow: auto !important;
        scrollbar-gutter: stable !important;
    }

    .cmf-pending-grid-wrap:has(#GridView_cmf_pending[style*="display: none"]),
    .cmf-pending-grid-wrap:has(#GridView_cmf_pending[style*="display:none"]) {
        display: none !important;
    }

    .issue-grid-scroll #overall_request_details thead th,
    .cmf-pending-grid-wrap #GridView_cmf_pending th {
        position: sticky !important;
        top: 0 !important;
        z-index: 20 !important;
    }

    .issue-pager-controls {
        position: static !important;
        background: rgba(246, 248, 252, 0.94) !important;
        border: 1px solid #e3eaf3 !important;
        border-radius: 12px !important;
        padding: 8px 10px !important;
        margin-top: 10px !important;
        box-shadow: 0 6px 18px rgba(15, 23, 42, 0.05) !important;
    }

    .issue-pager-controls .issue-page-size-control {
        position: static !important;
        grid-column: 3 !important;
        justify-self: end !important;
    }

    .issue-pager-controls .issue-page-nav {
        grid-column: 2 !important;
    }

    @media (max-width: 860px) {
        .issue-pager-controls {
            grid-template-columns: 1fr !important;
            justify-items: center !important;
        }

        .issue-pager-controls .issue-page-size-control {
            grid-column: 1 !important;
            justify-self: center !important;
        }

        .issue-pager-controls .issue-page-nav {
            grid-column: 1 !important;
        }
    }

    #GridView_cmf_pending {
        min-width: 1040px !important;
        border: 1px solid #e4eaf3 !important;
        border-radius: 12px !important;
        overflow: hidden !important;
        box-shadow: 0 8px 22px rgba(15, 23, 42, 0.045) !important;
        background: #ffffff !important;
    }

    #GridView_cmf_pending th {
        height: 40px !important;
        padding: 9px 12px !important;
        background: #f8fbff !important;
        color: #233044 !important;
        border-bottom: 1px solid #e3eaf3 !important;
        font-size: 10px !important;
        font-weight: 850 !important;
        letter-spacing: 0 !important;
    }

    #GridView_cmf_pending td {
        padding: 10px 12px !important;
        color: #344054 !important;
        font-size: 11px !important;
        line-height: 1.35 !important;
        vertical-align: middle !important;
        border-bottom: 1px solid #eef2f7 !important;
    }

    #GridView_cmf_pending tr:nth-child(even) td {
        background: #fcfdff !important;
    }

    #GridView_cmf_pending tr:hover td {
        background: #f2f7ff !important;
    }

    #GridView_cmf_pending a {
        color: #2456d6 !important;
        font-weight: 750 !important;
        text-decoration: none !important;
    }

    #GridView_cmf_pending a:hover {
        text-decoration: underline !important;
    }

    @media (max-width: 980px) {
        header {
            height: auto !important;
            min-height: 66px !important;
            flex-wrap: wrap !important;
            padding: 10px 14px !important;
        }

        .header-title {
            min-width: 160px !important;
        }

        .global-search-shell {
            order: 3;
            width: 100%;
            min-width: 0;
        }

        .issue-kpi-row {
            grid-template-columns: repeat(2, minmax(140px, 1fr)) !important;
        }
    }

    /* Must stay last: enforce table-only vertical scrolling after legacy overrides. */
    .issue-grid-scroll {
        max-height: min(62vh, 620px) !important;
        min-height: 0 !important;
        overflow-x: auto !important;
        overflow-y: auto !important;
        scrollbar-gutter: stable !important;
    }

    .cmf-pending-grid-wrap {
        max-height: min(64vh, 640px) !important;
        min-height: 0 !important;
        overflow-x: auto !important;
        overflow-y: auto !important;
        scrollbar-gutter: stable !important;
    }

    .issue-grid-scroll #overall_request_details thead th,
    .cmf-pending-grid-wrap #GridView_cmf_pending th {
        position: sticky !important;
        top: 0 !important;
        z-index: 20 !important;
    }

    </style>

    <script type="text/javascript">
        window.CMF_PORTAL = window.CMF_PORTAL || {};
        window.CMF_PORTAL.ids = window.CMF_PORTAL.ids || {};
        window.CMF_PORTAL.ids.hfSelectedValues = '<%= hfSelectedValues.ClientID %>';
        window.CMF_PORTAL.ids.exportBtn = '<%= exportBtn.ClientID %>';
        window.CMF_PORTAL.ids.driverCollectorhf = '<%= driverCollectorhf.ClientID %>';
        window.CMF_PORTAL.ids.hiddenComponentName = '<%= HiddenComponentName.ClientID %>';
        window.CMF_PORTAL.ids.hiddenDriverName = '<%= HiddenDriverName.ClientID %>';
        window.CMF_PORTAL.ids.hiddenIssueType = '<%= HiddenIssueType.ClientID %>';
        window.CMF_PORTAL.ids.hiddenModalDesign = '<%= HiddenModalDesign.ClientID %>';
        window.CMF_PORTAL.ids.hiddenModalDriver = '<%= HiddenModalDriver.ClientID %>';
        window.CMF_PORTAL.ids.ddlTables = '<%= ddlTables.ClientID %>';
        window.CMF_PORTAL.ids.ddlSharedPlatform = '<%= ddlSharedPlatform.ClientID %>';
        window.CMF_PORTAL.ids.hfQuickPlatform = '<%= hfQuickPlatform.ClientID %>';
        window.CMF_PORTAL.ids.btnQuickPlatformApply = '<%= btnQuickPlatformApply.UniqueID %>';
        window.CMF_PORTAL.ids.overallRequestDetails = '<%= overall_request_details.ClientID %>';
        window.CMF_PORTAL.ids.gridViewDesignSummary = '<%= GridView_design_summary.ClientID %>';
        window.CMF_PORTAL.ids.gridViewComponentSummary = '<%= GridView_component_summary.ClientID %>';
        window.CMF_PORTAL.ids.gridViewCmfSummary = '<%= GridView_cmf_summary.ClientID %>';
        window.CMF_PORTAL.ids.gridViewComp = '<%= GridView_comp.ClientID %>';
        window.CMF_PORTAL.ids.gridViewCmfPending = '<%= GridView_cmf_pending.ClientID %>';
        window.CMF_PORTAL.ids.homeWelcomePanel = '<%= homeWelcomePanel.ClientID %>';
        window.CMF_PORTAL.ids.paneIssueList = '<%= pane3.ClientID %>';
        window.CMF_PORTAL.ids.paneCmfPending = '<%= pane4.ClientID %>';
        window.CMF_PORTAL.ids.activeViewTitle = '<%= lblActiveViewTitle.ClientID %>';
        window.CMF_PORTAL.ids.issueListHeaderPanel = '<%= issueListHeaderPanel.ClientID %>';
        window.CMF_PORTAL.ids.cmfPendingHeaderPanel = '<%= cmf_pending_header_panel.ClientID %>';
        window.CMF_PORTAL.ids.lblIssueTotal = '<%= lblIssueTotal.ClientID %>';
        window.CMF_PORTAL.ids.lblIssueInProgress = '<%= lblIssueInProgress.ClientID %>';
        window.CMF_PORTAL.ids.lblIssueStale = '<%= lblIssueStale.ClientID %>';
        window.CMF_PORTAL.ids.lblPendingSightings = '<%= lblPendingSightings.ClientID %>';
        window.CMF_PORTAL.ids.lblQualifyForCmf = '<%= lblQualifyForCmf.ClientID %>';
        window.CMF_PORTAL.ids.lblLikelyDuplicate = '<%= lblLikelyDuplicate.ClientID %>';
        window.CMF_PORTAL.ids.lblIncompleteSysScope = '<%= lblIncompleteSysScope.ClientID %>';
        window.CMF_PORTAL.currentPlatform = '<%= ResolvePlatformTable(Session["selectedPlatform"] as string ?? ddlTables.SelectedValue) %>';

        window.CMF_PORTAL.defaults = {
            componentName: '',
            issueType: 'Open',
            driverName: ''
        };

        window.CMF_PORTAL.driversJson = <%= DriversJson %>;
        window.CMF_PORTAL.isInitialLoad = <%= IsPostBack ? "false" : "true" %>;
        window.CMF_PORTAL.activeFocusedTab = '<%= GetActiveFocusedTab() %>';

        window.CMF_PORTAL.platformAliasMap = {
            "PTL": "CMF_PTL_ALL_COMPONENTS_TABLE",
            "LNL": "CMF_LNL_ALL_COMPONENTS_TABLE",
            "ARL-S": "CMF_ARL_S_ALL_COMPONENTS_TABLE",
            "ARL-H": "CMF_ARL_H_ALL_COMPONENTS_TABLE",
            "ARL-U": "CMF_ARL_U_ALL_COMPONENTS_TABLE",
            "ARL-HX": "CMF_ARL_HX_ALL_COMPONENTS_TABLE",
            "ARL-REFRESH": "CMF_ARL_Refresh_ALL_COMPONENTS_TABLE",
            "GNR": "CMF_GNR_ALL_COMPONENTS_TABLE",
            "WCL": "CMF_WCL_ALL_COMPONENTS_TABLE",
            "NVL-S": "CMF_NVL_S_ALL_COMPONENTS_TABLE",
            "NVL-H": "CMF_NVL_H_ALL_COMPONENTS_TABLE"
        };

        function syncActivePlatformChip() {
            var ddl = document.getElementById(window.CMF_PORTAL.ids.ddlTables);
            if (!ddl) return;
            var current = ddl.value;
            var chips = document.querySelectorAll('.platform-chip');
            for (var i = 0; i < chips.length; i++) {
                chips[i].classList.toggle('is-active', chips[i].getAttribute('data-platform') === current);
            }
        }

        function applyQuickPlatform(platformValue) {
            if (!platformValue) return;
            var hidden = document.getElementById(window.CMF_PORTAL.ids.hfQuickPlatform);
            if (!hidden) return;
            hidden.value = platformValue;
            __doPostBack(window.CMF_PORTAL.ids.btnQuickPlatformApply, '');
        }

        function forcePortalPostBack(target) {
            var form = document.forms && document.forms.length > 0 ? document.forms[0] : null;
            if (!form || !target) {
                return false;
            }

            if (form.__EVENTTARGET) {
                form.__EVENTTARGET.value = target;
            }
            if (form.__EVENTARGUMENT) {
                form.__EVENTARGUMENT.value = '';
            }

            form.submit();
            return true;
        }

        function initPortalNavPostbackFallback() {
            var links = document.querySelectorAll('#mainMenuSidebar .portal-nav-link');
            for (var i = 0; i < links.length; i++) {
                var link = links[i];
                if (link.getAttribute('data-nav-fallback-bound') === '1') {
                    continue;
                }

                link.addEventListener('click', function (event) {
                    var target = this.name || this.id;
                    if (!target) {
                        return;
                    }
                    event.preventDefault();
                    forcePortalPostBack(target);
                });

                link.setAttribute('data-nav-fallback-bound', '1');
            }
        }

        function getCurrentPlatformValue() {
            var shared = document.getElementById(window.CMF_PORTAL.ids.ddlSharedPlatform);
            if (shared && shared.value) {
                return shared.value;
            }

            var ddl = document.getElementById(window.CMF_PORTAL.ids.ddlTables);
            if (ddl && ddl.value) {
                return ddl.value;
            }

            return window.CMF_PORTAL.currentPlatform || '';
        }

        function getIssuePendingPlatformValue() {
            var shared = document.getElementById(window.CMF_PORTAL.ids.ddlSharedPlatform);
            if (shared && shared.value) {
                return shared.value;
            }

            return getCurrentPlatformValue();
        }

        function renderMarkdown(text) {
            try {
                var htmlContent = marked.parse(text);
                var cleanHtml = DOMPurify.sanitize(htmlContent, {
                    ALLOWED_TAGS: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'br', 'strong', 'b', 'em', 'i', 
                                   'ul', 'ol', 'li', 'code', 'pre', 'blockquote', 'a', 'hr', 'span', 'div'],
                    ALLOWED_ATTR: ['href', 'target', 'class']
                });
                return cleanHtml;
            } catch (error) {
                console.error('Error rendering markdown:', error);
                return DOMPurify.sanitize(text, { ALLOWED_TAGS: [] });
            }
        }

        function prepareAiSummaryForDrawer(summary) {
            var rawText = summary || '';
            var text = normalizeAiSummaryText(rawText);
            var confidence = '';
            var confidenceMatch = rawText.match(/\*\*\s*AI\s+summary\s*\(\s*Confidence\s*:\s*([0-9]{1,3}%?)\s*\)\s*\*\*/i)
                || rawText.match(/AI\s+summary\s*\(\s*Confidence\s*:\s*([0-9]{1,3}%?)\s*\)/i);

            if (confidenceMatch && confidenceMatch[1]) {
                confidence = confidenceMatch[1];
                if (confidence.indexOf('%') < 0) confidence += '%';
            }

            var impact = extractAiSummaryLabel(text, 'Impact');
            var status = extractAiSummaryLabel(text, 'Status');
            var reproducibility = extractAiSummaryLabel(text, 'Reproducibility');
            var logs = extractAiSummaryLabel(text, 'Logs\\(sysdebug(?:/debug details)?\\)');
            var rvpDebug = extractAiSummaryLabel(text, 'RVP platform debug details');
            return {
                confidence: confidence,
                status: status,
                impact: impact,
                reproducibility: reproducibility,
                logs: logs,
                rvpDebug: rvpDebug,
                body: text,
                followUp: ''
            };
        }

        function normalizeAiSummaryText(text) {
            return String(text || '')
                .replace(/\r/g, '\n')
                .replace(/^\s*\*\*\s*(Summary|Key points|Follow up|Next action)\s*:\s*\*\*\s*$/gim, '$1:')
                .replace(/^\s*\*\*\s*AI\s+summary\s*\(\s*Confidence\s*:\s*[0-9]{1,3}%?\s*\)\s*\*\*\s*$/gim, '')
                .replace(/^\s*AI\s+summary\s*\(\s*Confidence\s*:\s*[0-9]{1,3}%?\s*\)\s*$/gim, '')
                .replace(/^\s*Sighting\s+ID\s*:\s*.*?CMF\s+Ask\s+date\s*:\s*.*$/gim, '');
        }

        function extractAiSummaryLabel(text, labelPattern) {
            var match = String(text || '').match(new RegExp('^\\s*' + labelPattern + '\\s*:\\s*(.+?)\\s*$', 'im'));
            return match && match[1] ? match[1].replace(/\*\*/g, '').trim() : 'N/A';
        }

        function extractAiSummaryBodyParts(text) {
            var source = normalizeAiSummaryText(text);
            source = source.replace(/^\s*Status\s*:\s*.*$/gim, '');
            source = source.replace(/^\s*Impact\s*:\s*.*$/gim, '');
            source = source.replace(/^\s*Reproducibility\s*:\s*.*$/gim, '');
            source = source.replace(/^\s*Logs\(sysdebug(?:\/debug details)?\)\s*:\s*.*$/gim, '');
            source = source.replace(/^\s*RVP platform debug details\s*:\s*.*$/gim, '');
            var summaryMatch = source.match(/(?:\*\*)?(?:Summary|Key points)(?:\*\*)?\s*:?([\s\S]*?)(?=(?:\*\*)?(?:Follow up|Next action)(?:\*\*)?\s*:?|$)/i);
            var followMatch = source.match(/(?:\*\*)?(?:Follow up|Next action)(?:\*\*)?\s*:?([\s\S]*)$/i);
            return {
                summary: compactAiBulletText(summaryMatch && summaryMatch[1] ? summaryMatch[1] : source, 3, 0),
                followUp: compactAiBulletText(followMatch && followMatch[1] ? followMatch[1] : '', 1, 0)
            };
        }

        function compactAiBulletText(text, maxBullets, maxLength) {
            var source = String(text || '').replace(/\r/g, '\n');
            source = source.replace(/^#{1,6}\s+.*$/gm, '');
            source = source.replace(/^\s*\*\*?(Summary|Key points|Follow up|Next action|Recommendation|Reasoning)\*\*?\s*:?\s*$/gim, '');
            var lines = source.split('\n');
            var bullets = [];
            for (var i = 0; i < lines.length && bullets.length < maxBullets; i++) {
                var line = lines[i].replace(/^\s*(?:[-*•]|\d+[\.)])\s*/, '').trim();
                line = line.replace(/\*\*/g, '').replace(/\s+/g, ' ');
                line = line.replace(/^\*+|\*+$/g, '').trim();
                if (/^(summary|key points|follow up|next action|recommendation|reasoning)\s*:?$/i.test(line)) continue;
                if (!line || /^(impact|reproducibility|logs|rvp platform debug details)\s*:/i.test(line)) continue;
                if (/^sighting id\s*:/i.test(line) || /^issue title\s*:/i.test(line)) continue;
                if (maxLength && line.length > maxLength) line = line.substring(0, maxLength).replace(/[\s,;:.]+$/g, '');
                if (bullets.indexOf(line) < 0) bullets.push(line);
            }
            if (bullets.length === 0 && source.trim()) bullets.push(maxLength ? source.trim().substring(0, maxLength) : source.trim());
            return bullets.map(function (line) { return '- ' + line; }).join('\n');
        }

        function compactRecommendationText(text) {
            return compactAiBulletText(text, 3, 0);
        }

        function openAiSummaryModal(issueId, title, submittedDate, status, sysdebug) {
            var issueIdNode = document.getElementById('aiSummaryIssueId');
            var titleNode = document.getElementById('aiSummaryTitle');
            var titleRow = document.getElementById('aiSummaryTitleRow');
            var dateNode = document.getElementById('aiSummarySubmittedDate');
            var bodyNode = document.getElementById('aiSummaryBody');
            var factsNode = document.getElementById('aiSummaryFacts');
            var actionsNode = document.getElementById('aiSummaryActions');
            var confidenceNode = document.getElementById('aiSummaryConfidence');
            var statusBadgeNode = document.getElementById('aiSummaryStatusBadge');
            var drawerTitle = document.getElementById('aiSummaryDrawerTitle');
            var dateRow = document.getElementById('aiSummaryDateRow');
            var drawerBg = document.getElementById('aiSummaryDrawerBg');
            var drawer = document.getElementById('aiSummaryDrawer');

            if (!issueIdNode || !titleNode || !dateNode || !bodyNode || !drawerBg || !drawer) {
                return;
            }

            issueIdNode.textContent = issueId || 'N/A';
            if (drawerTitle) drawerTitle.textContent = 'AI Summary';
            if (titleNode) titleNode.textContent = '';
            if (titleRow) titleRow.style.display = 'none';
            if (dateRow) dateRow.style.display = '';
            dateNode.textContent = submittedDate || 'N/A';
            if (confidenceNode) confidenceNode.textContent = 'Confidence: --';
            if (statusBadgeNode) {
                statusBadgeNode.textContent = 'Status: --';
                statusBadgeNode.className = 'ai-summary-status-value';
                statusBadgeNode.style.display = '';
            }
            if (factsNode) factsNode.style.display = '';
            updateAiSummaryFacts(factsNode, {}, true);
            bodyNode.textContent = 'Generating AI summary...';
            bodyNode.className = 'ai-summary-body markdown-content';
            if (actionsNode) actionsNode.style.display = 'none';

            drawerBg.classList.add('show');
            drawer.classList.add('show');

            var payload = {
                issueId: issueId || '',
                title: title || '',
                submittedDate: submittedDate || '',
                status: status || '',
                sysdebug: sysdebug || '',
                platform: getIssuePendingPlatformValue()
            };

            // Store for regenerate / copy
            window._aiSummaryLastPayload = payload;
            window._aiSummaryLastText = '';

            fetchAiSummary(payload, bodyNode, actionsNode);
        }
        function openAiIssueDescriptionModal(issueId, title, includeCmfReviewDetails) {
            var drawerBg = document.getElementById('aiSummaryDrawerBg');
            var drawer = document.getElementById('aiSummaryDrawer');
            var drawerTitle = document.getElementById('aiSummaryDrawerTitle');
            var issueIdNode = document.getElementById('aiSummaryIssueId');
            var titleNode = document.getElementById('aiSummaryTitle');
            var titleRow = document.getElementById('aiSummaryTitleRow');
            var dateRow = document.getElementById('aiSummaryDateRow');
            var factsNode = document.getElementById('aiSummaryFacts');
            var confidenceNode = document.getElementById('aiSummaryConfidence');
            var statusBadgeNode = document.getElementById('aiSummaryStatusBadge');
            var bodyNode = document.getElementById('aiSummaryBody');
            var actionsNode = document.getElementById('aiSummaryActions');

            if (!drawerBg || !drawer || !bodyNode) return;
            if (drawerTitle) drawerTitle.textContent = includeCmfReviewDetails ? 'AI CMF Issue Description' : 'AI Issue Description';
            if (issueIdNode) issueIdNode.textContent = issueId || 'N/A';
            if (titleNode) titleNode.textContent = title || 'N/A';
            if (titleRow) titleRow.style.display = '';
            if (dateRow) dateRow.style.display = 'none';
            if (factsNode) factsNode.style.display = 'none';
            if (confidenceNode) confidenceNode.textContent = 'Confidence: --';
            if (statusBadgeNode) statusBadgeNode.style.display = 'none';
            bodyNode.textContent = 'Generating AI issue description...';
            if (actionsNode) actionsNode.style.display = 'none';
            drawerBg.classList.add('show');
            drawer.classList.add('show');

            fetch('CMF_Web_portal.aspx/GetAiIssueDescription', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({
                    issueId: issueId || '',
                    title: title || '',
                    includeCmfReviewDetails: !!includeCmfReviewDetails,
                    platform: getIssuePendingPlatformValue()
                })
            })
            .then(function (response) { return response.json(); })
            .then(function (data) {
                var result = data && data.d ? data.d : data;
                if (!result || result.Success !== true) {
                    bodyNode.textContent = (result && result.Message) ? result.Message : 'Unable to generate issue description.';
                    return;
                }
                if (confidenceNode) confidenceNode.textContent = 'Confidence: ' + (result.Confidence || '--') + '%';
                bodyNode.innerHTML = renderMarkdown(result.Summary || 'No issue description returned.');
                if (actionsNode) actionsNode.style.display = '';
                window._aiSummaryLastText = result.Summary || '';
            })
            .catch(function () {
                bodyNode.textContent = 'Error while calling the issue description service.';
            });
        }
                    <h2 id="aiSummaryDrawerTitle" class="ai-summary-drawer-title">AI Summary</h2>
                    <div id="aiSummaryDateRow" class="ai-summary-meta-row"><strong>CMF Ask Date:</strong> <span id="aiSummarySubmittedDate">-</span></div>

        function fetchAiSummary(payload, bodyNode, actionsNode) {
            if (!bodyNode) bodyNode = document.getElementById('aiSummaryBody');
            if (!actionsNode) actionsNode = document.getElementById('aiSummaryActions');

            fetch('CMF_Web_portal.aspx/GetIssueAiSummary', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify(payload)
            })
            .then(function (response) { return response.json(); })
            .then(function (data) {
                var result = data && data.d ? data.d : data;
                if (!result || result.Success !== true) {
                    bodyNode.textContent = (result && result.Message) ? result.Message : 'Unable to generate summary at this time.';
                    bodyNode.className = 'ai-summary-body';
                    return;
                }
                var summary = result.Summary || 'No summary content returned.';
                var preparedSummary = prepareAiSummaryForDrawer(summary);
                preparedSummary.status = result.Status || preparedSummary.status;
                preparedSummary.impact = result.Impact || preparedSummary.impact;
                preparedSummary.reproducibility = result.Reproducibility || preparedSummary.reproducibility;
                preparedSummary.logs = result.LogsAvailable || preparedSummary.logs;
                preparedSummary.rvpDebug = result.RvpDebugAvailable || preparedSummary.rvpDebug;
                if (result.Confidence && !preparedSummary.confidence) {
                    preparedSummary.confidence = result.Confidence + '%';
                }
                var confidenceNode = document.getElementById('aiSummaryConfidence');
                if (confidenceNode && preparedSummary.confidence) {
                    confidenceNode.textContent = 'Confidence: ' + preparedSummary.confidence;
                }
                var statusBadgeNode = document.getElementById('aiSummaryStatusBadge');
                if (statusBadgeNode) {
                    var summaryStatus = preparedSummary.status || 'N/A';
                    statusBadgeNode.textContent = 'Status: ' + summaryStatus;
                    statusBadgeNode.className = 'ai-summary-status-value ' + getAiStatusClass(summaryStatus);
                }
                updateIssueListConfidenceBadge(payload.issueId, preparedSummary.confidence);
                updateAiSummaryFacts(document.getElementById('aiSummaryFacts'), preparedSummary, false);
                bodyNode.innerHTML = renderMarkdown(preparedSummary.body);
                bodyNode.className = 'ai-summary-body markdown-content';
                window._aiSummaryLastText = preparedSummary.body;
                if (actionsNode) actionsNode.style.display = '';
            })
            .catch(function () {
                bodyNode.textContent = 'Error while calling summary service.';
                bodyNode.className = 'ai-summary-body';
            });
        }

        function updateIssueListConfidenceBadge(issueId, confidence) {
            if (!issueId || !confidence) return;
            var selector = '.status-confidence-pill[data-ai-confidence-issue="' + cssEscapeValue(issueId) + '"]';
            var nodes = document.querySelectorAll(selector);
            for (var i = 0; i < nodes.length; i++) {
                nodes[i].textContent = 'Confidence: ' + confidence;
            }
        }

        function cssEscapeValue(value) {
            if (window.CSS && typeof window.CSS.escape === 'function') {
                return window.CSS.escape(String(value));
            }
            return String(value).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
        }

        function updateAiSummaryFacts(container, summary, isLoading) {
            if (!container) return;
            var value = function (name) {
                if (isLoading) return 'Loading...';
                return summary && summary[name] ? summary[name] : 'N/A';
            };
            container.innerHTML =
                '<div class="ai-summary-fact"><span class="ai-summary-fact-label">Impact</span><span class="ai-summary-fact-value">' + escapeHtml(value('impact')) + '</span></div>' +
                '<div class="ai-summary-fact"><span class="ai-summary-fact-label">Reproducibility</span><span class="ai-summary-fact-value">' + escapeHtml(value('reproducibility')) + '</span></div>' +
                '<div class="ai-summary-fact"><span class="ai-summary-fact-label">Logs(sysdebug)</span><span class="ai-summary-fact-value">' + escapeHtml(value('logs')) + '</span></div>' +
                '<div class="ai-summary-fact"><span class="ai-summary-fact-label">RVP platform debug details</span><span class="ai-summary-fact-value">' + escapeHtml(value('rvpDebug')) + '</span></div>';
        }

        function getAiStatusClass(statusValue) {
            var text = String(statusValue || '').toLowerCase();
            if (/reject/.test(text)) return 'status-rejected';
            if (/closed|complete|implemented|fixed|resolved/.test(text)) return 'status-closed';
            if (/pending|review|ask|triage/.test(text)) return 'status-pending';
            if (/open|active/.test(text)) return 'status-open';
            if (/progress|debug|validation/.test(text)) return 'status-progress';
            return '';
        }

        function copyAiSummaryForReport() {
            var text = window._aiSummaryLastText || '';
            if (!text) return;
            var issueId = (document.getElementById('aiSummaryIssueId') || {}).textContent || '';
            var title = (document.getElementById('aiSummaryTitle') || {}).textContent || '';
            var date = (document.getElementById('aiSummarySubmittedDate') || {}).textContent || '';
            var full = issueId + ' — ' + title + '\nCMF Ask Date: ' + date + '\n\n' + text;
            if (navigator.clipboard) {
                navigator.clipboard.writeText(full).then(function () {
                    showPortalToast('Summary copied — ready to paste into your report');
                }).catch(function () {
                    showPortalToast('Copy failed — try selecting text manually');
                });
            } else {
                showPortalToast('Clipboard not available in this browser');
            }
        }

        function regenerateAiSummary() {
            var bodyNode = document.getElementById('aiSummaryBody');
            var actionsNode = document.getElementById('aiSummaryActions');
            if (!bodyNode || !window._aiSummaryLastPayload) return;
            bodyNode.textContent = 'Regenerating AI summary...';
            bodyNode.className = 'ai-summary-body markdown-content';
            if (actionsNode) actionsNode.style.display = 'none';
            fetchAiSummary(window._aiSummaryLastPayload, bodyNode, actionsNode);
        }

        function showPortalToast(msg) {
            var t = document.getElementById('aiSummaryToast');
            if (!t) {
                t = document.createElement('div');
                t.id = 'aiSummaryToast';
                t.style.cssText = 'position:fixed;bottom:22px;left:50%;transform:translateX(-50%);background:#1b2a3a;color:#fff;padding:10px 18px;border-radius:8px;font-size:13px;z-index:2000;opacity:0;transition:opacity .25s;pointer-events:none';
                document.body.appendChild(t);
            }
            t.textContent = msg;
            t.style.opacity = '1';
            clearTimeout(t._tid);
            t._tid = setTimeout(function () { t.style.opacity = '0'; }, 2500);
        }

        function closeAiSummaryDrawer() {
            var drawerBg = document.getElementById('aiSummaryDrawerBg');
            var drawer = document.getElementById('aiSummaryDrawer');
            if (!drawerBg || !drawer) {
                return;
            }

            drawerBg.classList.remove('show');
            drawer.classList.remove('show');
        }

        document.addEventListener('keydown', function (event) {
            if (event.key !== 'Escape') {
                return;
            }

            var drawer = document.getElementById('aiSummaryDrawer');
            if (drawer && drawer.classList.contains('show')) {
                closeAiSummaryDrawer();
            }

            var recommendationDrawer = document.getElementById('cmfRecDrawer');
            if (recommendationDrawer && recommendationDrawer.classList.contains('show')) {
                closeCmfRecDrawer();
            }
        });

        function escapeHtml(value) {
            return String(value == null ? '' : value)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function openCmfPendingRecommendationModal(cpId, title, component, cmfRequest, impact, idst, reproOnRvp, reproducibility, customerDetail, customerOwner) {
            var cpIdNode = document.getElementById('cmfRecCpId');
            var titleNode = document.getElementById('cmfRecTitle');
            var componentNode = document.getElementById('cmfRecComponent');
            var bodyNode = document.getElementById('cmfRecBody');
            var drawerBg = document.getElementById('cmfRecDrawerBg');
            var drawer = document.getElementById('cmfRecDrawer');

            if (!cpIdNode || !titleNode || !componentNode || !drawerBg || !drawer) {
                console.error('CMF Recommendation modal elements not found');
                return;
            }

            cpIdNode.textContent = cpId || 'N/A';
            titleNode.textContent = title || 'N/A';
            componentNode.textContent = component || 'N/A';
            
            var recNode = document.getElementById('cmfRecRecommendation');
            var evidenceNode = document.getElementById('cmfRecEvidence');
            var scoreNode = document.getElementById('cmfRecScore');
            var checksNode = document.getElementById('cmfRecChecks');
            var nextStepsNode = document.getElementById('cmfRecNextSteps');
            
            if (recNode) recNode.textContent = 'Generating AI recommendation...';
            if (evidenceNode) evidenceNode.textContent = '-';
            if (scoreNode) scoreNode.textContent = '-';
            if (checksNode) checksNode.textContent = '-';
            if (nextStepsNode) nextStepsNode.textContent = '-';

            drawerBg.classList.add('show');
            drawer.classList.add('show');

            var payload = {
                cpId: cpId || '',
                title: title || '',
                component: component || '',
                cmfRequest: cmfRequest || '',
                impact: impact || '',
                idst: idst || '',
                reproOnRvp: reproOnRvp || '',
                reproducibility: reproducibility || '',
                customerDetail: customerDetail || '',
                customerOwner: customerOwner || '',
                platform: getIssuePendingPlatformValue()
            };

            fetch('CMF_Web_portal.aspx/GetCmfPendingRecommendation', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8'
                },
                body: JSON.stringify(payload)
            })
            .then(function (response) {
                return response.json();
            })
            .then(function (data) {
                var result = data && data.d ? data.d : data;
                if (!result || result.Success !== true) {
                    if (recNode) {
                        recNode.textContent = (result && result.Message) ? result.Message : 'Unable to generate recommendation at this time.';
                    }
                    return;
                }

                // Display recommendation
                if (recNode) {
                    recNode.textContent = result.Recommendation || 'No recommendation returned.';
                    recNode.className = 'cmf-rec-decision-badge';
                }
                
                // Display AI reasoning
                if (evidenceNode) {
                    var reasoningText = result.Evidence || 'No AI reasoning provided.';
                    evidenceNode.innerHTML = renderMarkdown(compactRecommendationText(reasoningText));
                }

                if (scoreNode) {
                    scoreNode.textContent = (result.OverallQualityScore || 0) + '/100 (threshold ' + (result.ThresholdScore || 0) + ')';
                }

                if (checksNode) {
                    var ruleScores = result.RuleScores || [];
                    var checks = [];
                    for (var index = 0; index < ruleScores.length; index++) {
                        var rule = ruleScores[index] || {};
                        checks.push('- ' + (rule.RuleId || 'Rule') + ': ' + (rule.Evaluation || 'No evaluation returned.'));
                    }
                    checksNode.innerHTML = renderMarkdown(checks.join('\n') || '- No qualification checks returned.');
                }

                if (nextStepsNode) {
                    nextStepsNode.innerHTML = renderMarkdown(result.NextSteps || 'No next action returned.');
                }

            })
            .catch(function () {
                if (recNode) {
                    recNode.textContent = 'Error while calling recommendation service.';
                }
            });
        }

        function closeCmfRecDrawer() {
            var drawerBg = document.getElementById('cmfRecDrawerBg');
            var drawer = document.getElementById('cmfRecDrawer');
            if (!drawerBg || !drawer) {
                return;
            }

            drawerBg.classList.remove('show');
            drawer.classList.remove('show');
        }

        function showCmfPlaceholderAction(actionName) {
            showPortalToast(actionName + ' is a placeholder until backend workflow is finalized.');
        }

        function appendReportsChatMessage(role, text, imageUrl, reportUrl) {
            var chatLog = document.getElementById('reportsChatLog');
            if (!chatLog) {
                return;
            }

            var messageRow = document.createElement('div');
            messageRow.style.display = 'flex';
            messageRow.style.justifyContent = role === 'user' ? 'flex-end' : 'flex-start';
            messageRow.style.marginBottom = '10px';

            var bubble = document.createElement('div');
            bubble.style.maxWidth = '80%';
            bubble.style.padding = '10px 12px';
            bubble.style.borderRadius = '10px';
            bubble.style.whiteSpace = 'pre-wrap';
            bubble.style.fontSize = '13px';
            bubble.style.lineHeight = '1.4';

            if (role === 'user') {
                bubble.style.background = '#0068b5';
                bubble.style.color = '#fff';
                bubble.textContent = text || '';
            } else {
                bubble.style.background = '#eef4fb';
                bubble.style.color = '#12344d';
                bubble.style.border = '1px solid #d6e2ef';
                bubble.style.whiteSpace = 'normal';
                var markdownHtml = renderMarkdown(text || '');
                bubble.innerHTML = markdownHtml;
                bubble.className = 'markdown-content';
            }
            messageRow.appendChild(bubble);
            chatLog.appendChild(messageRow);

            if (role !== 'user' && imageUrl) {
                var imageWrap = document.createElement('div');
                imageWrap.style.margin = '6px 0 12px 0';
                var image = document.createElement('img');
                image.src = imageUrl;
                image.alt = 'Generated analytics chart';
                image.style.maxWidth = '100%';
                image.style.border = '1px solid #d6e2ef';
                image.style.borderRadius = '8px';
                image.style.background = '#fff';
                imageWrap.appendChild(image);
                chatLog.appendChild(imageWrap);
            }

            if (role !== 'user' && reportUrl) {
                var linkWrap = document.createElement('div');
                linkWrap.style.margin = '0 0 12px 0';
                var link = document.createElement('a');
                link.href = reportUrl;
                link.target = '_blank';
                link.textContent = 'Download generated report';
                link.style.fontSize = '13px';
                linkWrap.appendChild(link);
                chatLog.appendChild(linkWrap);
            }

            chatLog.scrollTop = chatLog.scrollHeight;
        }

        function sendReportsPrompt() {
            var input = document.getElementById('reportsPromptInput');
            var sendButton = document.getElementById('reportsPromptSend');
            if (!input || !sendButton) {
                return;
            }

            var prompt = (input.value || '').trim();
            if (!prompt) {
                return;
            }

            appendReportsChatMessage('user', prompt);
            input.value = '';
            sendButton.disabled = true;
            sendButton.textContent = 'Running...';

            var payload = {
                prompt: prompt,
                platform: getCurrentPlatformValue()
            };

            fetch('CMF_Web_portal.aspx/GetReportsAssistantResponse', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8'
                },
                body: JSON.stringify(payload)
            })
            .then(function (response) {
                return response.json();
            })
            .then(function (data) {
                var result = data && data.d ? data.d : data;
                if (!result || result.Success !== true) {
                    appendReportsChatMessage('assistant', (result && result.Message) ? result.Message : 'Unable to process this analytics request right now.');
                    return;
                }

                appendReportsChatMessage('assistant', result.Message || 'Completed.', result.ImageUrl || '', result.ReportUrl || '');
            })
            .catch(function () {
                appendReportsChatMessage('assistant', 'Error while calling reports assistant service.');
            })
            .finally(function () {
                sendButton.disabled = false;
                sendButton.textContent = 'Send';
            });
        }

        function sendReportsQuickPrompt(prompt) {
            var input = document.getElementById('reportsPromptInput');
            if (!input) {
                return;
            }

            input.value = prompt;
            sendReportsPrompt();
        }

        function saveReportsFormatTemplate() {
            try {
                var textarea = document.getElementById('reportsFormatTemplate');
                if (textarea && textarea.readOnly) {
                    showPortalToast('Click Edit format before saving changes.');
                    return;
                }
                var payload = { template: textarea ? (textarea.value || '') : '', platform: getCurrentPlatformValue(), fileName: 'manual-template.md' };
                fetch('CMF_Web_portal.aspx/SaveReportsTemplate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify(payload)
                })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    var res = data && data.d ? data.d : data;
                    if (res && res.Success) {
                        setReportsTemplateEditMode(false);
                        showPortalToast('Report format saved to server.');
                    } else {
                        showPortalToast('Failed to save template: ' + (res && res.Message ? res.Message : 'unknown'));
                    }
                })
                .catch(function () { showPortalToast('Failed to save report template.'); });
            } catch (ignore) {
                showPortalToast('Failed to save report template.');
            }
        }

        function generateReportsFromTemplate() {
            // Request server to generate using the server-side saved template for current platform
            var payload = { platform: getCurrentPlatformValue() };
            var btn = document.querySelector('.reports-format-actions button[onclick*="generateReportsFromTemplate"]');
            if (btn) { btn.disabled = true; btn.textContent = 'Generating...'; }
            fetch('CMF_Web_portal.aspx/GenerateReportFromTemplate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify(payload)
            })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var res = data && data.d ? data.d : data;
                if (!res || res.Success !== true) {
                    appendReportsChatMessage('assistant', (res && res.Message) ? res.Message : 'Unable to generate report from template.');
                } else {
                    appendReportsChatMessage('assistant', res.Message || 'Report generated.', res.ImageUrl || '', res.ReportUrl || '');
                }
            })
            .catch(function () { appendReportsChatMessage('assistant', 'Error while generating report from template.'); })
            .finally(function () { if (btn) { btn.disabled = false; btn.textContent = 'Generate from format'; } });
        }

        function uploadReportsFormat(event) {
            var file = event && event.target && event.target.files && event.target.files[0];
            if (!file) return;
            var label = document.getElementById('reportsFormatName');
            var reader = new FileReader();
            reader.onload = function () {
                var content = reader.result || '';
                var payload = { template: content, platform: getCurrentPlatformValue(), fileName: file.name };
                fetch('CMF_Web_portal.aspx/SaveReportsTemplate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify(payload)
                })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    var res = data && data.d ? data.d : data;
                    if (res && res.Success) {
                        var textarea = document.getElementById('reportsFormatTemplate');
                        if (textarea) { textarea.value = content; }
                        setReportsTemplateEditMode(false);
                        if (label) { label.style.display = 'inline'; label.textContent = file.name + ' uploaded'; }
                        showPortalToast('Report template uploaded to server.');
                    } else {
                        showPortalToast('Failed to upload template: ' + (res && res.Message ? res.Message : 'unknown'));
                    }
                })
                .catch(function () { showPortalToast('Failed to upload report template.'); });
            };
            reader.readAsText(file);
        }

        function initReportsFormatTemplate() {
            try {
                var textarea = document.getElementById('reportsFormatTemplate');
                setReportsTemplateEditMode(false);
                // Try load server-saved template first
                fetch('CMF_Web_portal.aspx/GetSavedTemplate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify({ platform: getCurrentPlatformValue() })
                })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    var res = data && data.d ? data.d : data;
                    if (res && res.Success && textarea) {
                        textarea.value = res.Message || textarea.value;
                        setReportsTemplateEditMode(false);
                        return;
                    }
                    var saved = localStorage.getItem('cmf.reports.formatTemplate');
                    if (textarea && saved) { textarea.value = saved; }
                })
                .catch(function () {
                    var saved = localStorage.getItem('cmf.reports.formatTemplate');
                    if (textarea && saved) { textarea.value = saved; }
                });
            } catch (ignore) {
            }
        }

        function setReportsTemplateEditMode(isEditing) {
            var textarea = document.getElementById('reportsFormatTemplate');
            var editBtn = document.getElementById('reportsFormatEditBtn');
            var saveBtn = document.getElementById('reportsFormatSaveBtn');
            if (textarea) {
                textarea.readOnly = !isEditing;
                textarea.classList.toggle('is-readonly', !isEditing);
            }
            if (editBtn) editBtn.style.display = isEditing ? 'none' : '';
            if (saveBtn) saveBtn.disabled = !isEditing;
        }

        function bindReportsPromptEnterHandler() {
            var input = document.getElementById('reportsPromptInput');
            if (!input || input.dataset.boundEnter === '1') {
                return;
            }

            input.addEventListener('keydown', function (event) {
                if (event.key === 'Enter' && !event.shiftKey) {
                    event.preventDefault();
                    sendReportsPrompt();
                }
            });
            input.dataset.boundEnter = '1';
        }

        function getCollapsibleConfig() {
            return {
                mainMenu: {
                    bodyId: 'mainMenuSectionBody',
                    buttonId: 'mainMenuToggleBtn',
                    storageKey: 'cmf.collapsible.mainMenu',
                    containerId: 'mainMenuSidebar',
                    shellId: 'portalLayoutShell',
                    reopenButtonId: 'mainMenuReopenBtn'
                },
                issueFilters: {
                    bodyId: 'issueTopFilterBody',
                    buttonId: 'issueFiltersToggleBtn',
                    storageKey: 'cmf.collapsible.issueFilters',
                    defaultCollapsed: true
                }
            };
        }

        function setCollapsibleSection(sectionName, collapsed, persistState) {
            var config = getCollapsibleConfig()[sectionName];
            if (!config) {
                return;
            }

            var body = document.getElementById(config.bodyId);
            var button = document.getElementById(config.buttonId);
            var container = config.containerId ? document.getElementById(config.containerId) : null;
            var shell = config.shellId ? document.getElementById(config.shellId) : null;
            var reopenButton = config.reopenButtonId ? document.getElementById(config.reopenButtonId) : null;

            if (body) {
                if (collapsed) {
                    body.classList.add('is-collapsed');
                } else {
                    body.classList.remove('is-collapsed');
                }
            }

            if (button) {
                button.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
                var label = button.querySelector('.toggle-label');
                if (label) {
                    label.textContent = sectionName === 'mainMenu' ? (collapsed ? '>>' : '<<') : (collapsed ? 'Show' : 'Hide');
                }
                if (sectionName === 'mainMenu') {
                    button.title = collapsed ? 'Expand menu labels' : 'Collapse menu labels';
                    button.setAttribute('aria-label', collapsed ? 'Expand menu labels' : 'Collapse menu labels');
                }
            }

            if (container) {
                if (collapsed) {
                    container.classList.add('is-collapsed');
                } else {
                    container.classList.remove('is-collapsed');
                }
            }

            if (shell) {
                if (collapsed) {
                    shell.classList.add('main-menu-collapsed');
                } else {
                    shell.classList.remove('main-menu-collapsed');
                }
            }

            if (reopenButton) {
                reopenButton.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
            }

            if (persistState) {
                try {
                    localStorage.setItem(config.storageKey, collapsed ? '1' : '0');
                } catch (ignore) {
                }
            }
        }

        function toggleCollapsibleSection(sectionName) {
            var config = getCollapsibleConfig()[sectionName];
            if (!config) {
                return;
            }

            var body = document.getElementById(config.bodyId);
            var collapsed = body ? !body.classList.contains('is-collapsed') : false;
            setCollapsibleSection(sectionName, collapsed, true);
        }

        function initCollapsibleSections() {
            var all = getCollapsibleConfig();
            for (var sectionName in all) {
                if (!Object.prototype.hasOwnProperty.call(all, sectionName)) {
                    continue;
                }

                var cfg = all[sectionName];
                var initialCollapsed = !!cfg.defaultCollapsed;
                try {
                    var storedState = localStorage.getItem(cfg.storageKey);
                    if (storedState !== null) {
                        initialCollapsed = storedState === '1';
                    }
                } catch (ignore) {
                }
                setCollapsibleSection(sectionName, initialCollapsed, false);
            }
        }

        function initMainMenuTooltips() {
            var links = document.querySelectorAll('#mainMenuSidebar .portal-nav-link');
            for (var i = 0; i < links.length; i++) {
                var textNode = links[i].querySelector('span');
                var label = textNode ? (textNode.textContent || '').trim() : '';
                if (label) {
                    links[i].setAttribute('title', label);
                    links[i].setAttribute('aria-label', label);
                }
            }
        }

        function syncIssueHorizontalScroll(attempt) {
            var host = document.getElementById('issue-grid-inner');
            var proxy = document.getElementById('issue-scroll-proxy');
            var proxyInner = document.getElementById('issue-scroll-proxy-inner');
            var table = document.getElementById(window.CMF_PORTAL.ids.overallRequestDetails);

            if (!host || !proxy || !proxyInner || !table) {
                return;
            }

            host.style.overflowX = 'auto';
            host.style.overflowY = 'visible';

            // Enforce width at runtime in case later CSS rules collapse the table width.
            table.style.width = 'max-content';
            table.style.minWidth = '2600px';
            table.style.maxWidth = 'none';

            var targetWidth = Math.max(table.scrollWidth || 0, table.offsetWidth || 0, 2600);
            proxyInner.style.width = targetWidth + 'px';

            // If layout is not ready yet (e.g., after async update while hidden), retry a few times.
            if (host.clientWidth > 0 && targetWidth <= host.clientWidth && (attempt || 0) < 6) {
                setTimeout(function () { syncIssueHorizontalScroll((attempt || 0) + 1); }, 80);
            }

            var syncLock = false;
            host.onscroll = function () {
                if (syncLock) return;
                syncLock = true;
                proxy.scrollLeft = host.scrollLeft;
                syncLock = false;
            };

            proxy.onscroll = function () {
                if (syncLock) return;
                syncLock = true;
                host.scrollLeft = proxy.scrollLeft;
                syncLock = false;
            };

            proxy.scrollLeft = host.scrollLeft;
            proxy.style.display = 'none';
        }

        function renderHomeDashboard() {
            var homePanel = document.getElementById(window.CMF_PORTAL.ids.homeWelcomePanel);
            if (homePanel && !isElementVisible(homePanel)) {
                return;
            }

            var trendHost = document.getElementById('homeTrendChart');
            var statusHost = document.getElementById('homeStatusChart');
            var listHost = document.getElementById('homeTopComponentsList');
            if (!trendHost || !statusHost || !listHost || typeof echarts === 'undefined') {
                return;
            }

            var snapshot = window.CMF_PORTAL.homeDashboardSnapshot;
            if (!snapshot) {
                return;
            }

            var trend = snapshot.Trend || [];
            var topComponents = snapshot.TopComponents || [];
            var statusDistribution = snapshot.StatusDistribution || [];
            var snapshotKey = [
                window.CMF_PORTAL.currentPlatform || '',
                trend.length,
                topComponents.length,
                statusDistribution.length,
                getTextById(window.CMF_PORTAL.ids.lblIssueTotal),
                getTextById(window.CMF_PORTAL.ids.lblPendingSightings)
            ].join('|');

            if (window.CMF_PORTAL.lastHomeDashboardKey === snapshotKey && window.CMF_PORTAL.homeTrendChart && window.CMF_PORTAL.homeStatusChart) {
                return;
            }

            if (!window.CMF_PORTAL.homeTrendChart) {
                window.CMF_PORTAL.homeTrendChart = echarts.init(trendHost);
            }

            if (!window.CMF_PORTAL.homeStatusChart) {
                window.CMF_PORTAL.homeStatusChart = echarts.init(statusHost);
            }

            window.CMF_PORTAL.homeTrendChart.setOption({
                animation: false,
                color: ['#ef4444', '#16a34a', '#f59e0b'],
                tooltip: { trigger: 'axis' },
                legend: {
                    top: 0,
                    left: 0,
                    icon: 'circle',
                    itemWidth: 8,
                    itemHeight: 8,
                    textStyle: { color: '#475467', fontSize: 11 }
                },
                grid: { left: 36, right: 14, top: 30, bottom: 26 },
                xAxis: {
                    type: 'category',
                    data: trend.map(function (item) { return item.WeekLabel; }),
                    boundaryGap: false,
                    axisLine: { lineStyle: { color: '#e4e7ec' } },
                    axisLabel: { color: '#667085', fontSize: 11 }
                },
                yAxis: {
                    type: 'value',
                    axisLine: { show: false },
                    splitLine: { lineStyle: { color: '#eef2f7' } },
                    axisLabel: { color: '#667085', fontSize: 11 }
                },
                series: [
                    {
                        name: 'Open',
                        type: 'line',
                        smooth: true,
                        data: trend.map(function (item) { return item.NewIssues; }),
                        lineStyle: { width: 3 },
                        symbol: 'circle',
                        symbolSize: 6
                    },
                    {
                        name: 'Resolved',
                        type: 'line',
                        smooth: true,
                        data: trend.map(function (item) { return item.ResolvedIssues; }),
                        lineStyle: { width: 3 },
                        symbol: 'circle',
                        symbolSize: 6,
                        areaStyle: { color: 'rgba(22,163,74,0.12)' }
                    },
                    {
                        name: 'Need Attention',
                        type: 'line',
                        smooth: true,
                        data: trend.map(function (item) { return item.NeedsAttention; }),
                        lineStyle: { width: 3 },
                        symbol: 'circle',
                        symbolSize: 6,
                        areaStyle: { color: 'rgba(245,158,11,0.08)' }
                    }
                ]
            }, true);

            var productData = [];
            var palette = ['#4f79ff', '#4caf64', '#f5a53a', '#8b5cf6', '#94a3b8', '#ef4444'];
            var i;
            for (i = 0; i < topComponents.length; i++) {
                productData.push({
                    name: topComponents[i].Name || 'Unassigned',
                    value: topComponents[i].Value || 0,
                    itemStyle: { color: palette[i % palette.length] }
                });
            }

            if (productData.length === 0) {
                for (i = 0; i < statusDistribution.length; i++) {
                    productData.push({
                        name: statusDistribution[i].Name || 'Status',
                        value: statusDistribution[i].Value || 0,
                        itemStyle: { color: palette[i % palette.length] }
                    });
                }
            }

            window.CMF_PORTAL.homeStatusChart.setOption({
                animation: false,
                tooltip: { trigger: 'item' },
                legend: { show: false },
                series: [{
                    type: 'pie',
                    radius: ['56%', '82%'],
                    center: ['50%', '50%'],
                    data: productData,
                    label: { show: false },
                    itemStyle: { borderColor: '#ffffff', borderWidth: 2 }
                }]
            }, true);

            listHost.innerHTML = '';
            var total = 0;
            for (i = 0; i < productData.length; i++) {
                total += Number(productData[i].value || 0);
            }

            for (i = 0; i < productData.length && i < 6; i++) {
                var entry = productData[i];
                var pct = total > 0 ? Math.round((Number(entry.value || 0) * 100) / total) : 0;
                var listItem = document.createElement('li');
                listItem.className = 'ccip-product-item';
                listItem.innerHTML =
                    '<span class="ccip-product-name"><span class="ccip-dot" style="background:' + escapeHtml(entry.itemStyle.color) + '"></span>' +
                    escapeHtml(entry.name) + '</span>' +
                    '<span class="ccip-product-value">' + escapeHtml(String(entry.value)) + ' (' + escapeHtml(String(pct)) + '%)</span>';
                listHost.appendChild(listItem);
            }

            var priorityBody = document.getElementById('homePriorityRows');
            if (priorityBody) {
                priorityBody.innerHTML = '';
                var severityOrder = ['critical', 'high', 'high', 'medium', 'medium'];
                var statusOrder = ['Active', 'Waiting Info', 'In Progress', 'Investigating', 'Assigned'];
                var owners = ['John D.', 'Alice M.', 'Sam W.', 'David K.', 'Priya S.'];
                var customers = ['ABC Corp', 'XYZ Ltd', 'PQR Inc', 'LMN Corp', 'RST Ltd'];
                for (i = 0; i < productData.length && i < 5; i++) {
                    var row = document.createElement('tr');
                    row.innerHTML =
                        '<td><span class="ccip-severity ' + severityOrder[i] + '">' +
                        (severityOrder[i] === 'critical' ? 'Critical' : (severityOrder[i] === 'high' ? 'High' : 'Medium')) +
                        '</span></td>' +
                        '<td>#' + (2124 - i * 3) + '</td>' +
                        '<td>' + customers[i] + '</td>' +
                        '<td>' + escapeHtml(productData[i].name) + '</td>' +
                        '<td>' + owners[i] + '</td>' +
                        '<td><span class="ccip-confidence">' + (98 - i * 5) + '%</span></td>' +
                        '<td><span class="ccip-status-pill">' + statusOrder[i] + '</span></td>' +
                        '<td>' + (i === 0 ? '2 hrs' : (i === 1 ? '5 hrs' : (i === 2 ? '8 hrs' : (i === 3 ? '12 hrs' : '1 day')))) + '</td>';
                    priorityBody.appendChild(row);
                }
            }

            var recentList = document.getElementById('homeRecentActivity');
            if (recentList) {
                recentList.innerHTML = '';
                var times = ['10m ago', '25m ago', '1h ago', '2h ago', '3h ago'];
                for (i = 0; i < trend.length && i < 5; i++) {
                    var activity = document.createElement('li');
                    activity.innerHTML = '<span class="ccip-time">' + times[i] + '</span><span>Week ' +
                        escapeHtml(trend[Math.max(0, trend.length - 1 - i)].WeekLabel || '') +
                        ': Open ' + escapeHtml(String(trend[Math.max(0, trend.length - 1 - i)].NewIssues || 0)) +
                        ', Resolved ' + escapeHtml(String(trend[Math.max(0, trend.length - 1 - i)].ResolvedIssues || 0)) +
                        '.</span>';
                    recentList.appendChild(activity);
                }
            }

            var insightsList = document.getElementById('homeAiInsights');
            if (insightsList) {
                var topName = productData.length > 0 ? productData[0].name : 'top component';
                var topValue = productData.length > 0 ? productData[0].value : 0;
                insightsList.innerHTML =
                    '<li>Highest concentration is in ' + escapeHtml(String(topName)) + ' with ' + escapeHtml(String(topValue)) + ' active issues.</li>' +
                    '<li>Resolved trend remains stable over the latest reporting window.</li>' +
                    '<li>Need-attention items are prioritized in the center table for faster triage.</li>' +
                    '<li>Use CMF Pending and Reports tabs for recommendation and narrative export workflows.</li>';
            }

            window.CMF_PORTAL.lastHomeDashboardKey = snapshotKey;
            window.CMF_PORTAL.homeTrendChart.resize();
            window.CMF_PORTAL.homeStatusChart.resize();
        }

        function getTextById(id) {
            var node = id ? document.getElementById(id) : null;
            if (!node) return '0';
            return (node.textContent || node.innerText || '0').trim();
        }

        function renderInteractiveIssuePendingSidebars() {
            var issueTotal = getTextById(window.CMF_PORTAL.ids.lblIssueTotal);
            var issueProgress = getTextById(window.CMF_PORTAL.ids.lblIssueInProgress);
            var issueStale = getTextById(window.CMF_PORTAL.ids.lblIssueStale);
            var pendingTotal = getTextById(window.CMF_PORTAL.ids.lblPendingSightings);
            var pendingQualify = getTextById(window.CMF_PORTAL.ids.lblQualifyForCmf);
            var pendingDup = getTextById(window.CMF_PORTAL.ids.lblLikelyDuplicate);
            var pendingMissing = getTextById(window.CMF_PORTAL.ids.lblIncompleteSysScope);

            var issueTotalNode = document.getElementById('issueSideTotal');
            var issueProgressNode = document.getElementById('issueSideProgress');
            var issueStaleNode = document.getElementById('issueSideStale');
            if (issueTotalNode) issueTotalNode.textContent = issueTotal;
            if (issueProgressNode) issueProgressNode.textContent = issueProgress;
            if (issueStaleNode) issueStaleNode.textContent = issueStale;

            var pendingTotalNode = document.getElementById('pendingSideTotal');
            var pendingQualifyNode = document.getElementById('pendingSideQualify');
            var pendingDupNode = document.getElementById('pendingSideDup');
            var pendingMissNode = document.getElementById('pendingSideMissing');
            if (pendingTotalNode) pendingTotalNode.textContent = pendingTotal;
            if (pendingQualifyNode) pendingQualifyNode.textContent = pendingQualify;
            if (pendingDupNode) pendingDupNode.textContent = pendingDup;
            if (pendingMissNode) pendingMissNode.textContent = pendingMissing;
        }

        function isElementVisible(element) {
            if (!element) return false;
            var style = window.getComputedStyle ? window.getComputedStyle(element) : null;
            if (style && (style.display === 'none' || style.visibility === 'hidden')) {
                return false;
            }
            return element.offsetParent !== null || (style && style.position === 'fixed');
        }

        function normalizeIssuePendingShellDom() {
            var issueShell = document.getElementById('issueTabShell');
            var pendingShell = document.getElementById('pendingTabShell');
            if (!issueShell) return;

            var issueMain = issueShell.querySelector('.issue-tab-main');
            var issueSide = issueShell.querySelector('.issue-side-panel')
                || document.querySelector('#mainDataWrapper .issue-side-panel')
                || document.querySelector('.issue-side-panel');
            var pendingMain = pendingShell ? pendingShell.querySelector('.pending-tab-main') : null;
            var pendingSide = pendingShell
                ? (pendingShell.querySelector('.pending-side-panel')
                    || document.querySelector('#mainDataWrapper .pending-side-panel')
                    || document.querySelector('.pending-side-panel'))
                : null;

            if (issueMain && issueSide && issueSide.parentElement !== issueShell) {
                issueShell.insertBefore(issueSide, issueMain.nextSibling);
            }

            if (pendingShell && pendingMain && pendingSide && pendingSide.parentElement !== pendingShell) {
                pendingShell.insertBefore(pendingSide, pendingMain.nextSibling);
            }

            if (pendingShell && issueShell.parentElement && pendingShell.parentElement !== issueShell.parentElement) {
                issueShell.parentElement.insertBefore(pendingShell, issueShell.nextSibling);
            }
        }

        function syncIssuePendingSidePanelVisibility() {
            normalizeIssuePendingShellDom();
            var issueShell = document.getElementById('issueTabShell');
            var pendingShell = document.getElementById('pendingTabShell');
            var issueSide = issueShell ? issueShell.querySelector('.issue-side-panel') : null;
            var pendingSide = pendingShell ? pendingShell.querySelector('.pending-side-panel') : null;

            var issuePane = document.getElementById(window.CMF_PORTAL.ids.paneIssueList);
            var pendingPane = document.getElementById(window.CMF_PORTAL.ids.paneCmfPending);
            var activeViewTitle = document.getElementById(window.CMF_PORTAL.ids.activeViewTitle);
            var issueHeader = document.getElementById(window.CMF_PORTAL.ids.issueListHeaderPanel);
            var pendingHeader = document.getElementById(window.CMF_PORTAL.ids.cmfPendingHeaderPanel);
            var issueGrid = document.getElementById(window.CMF_PORTAL.ids.overallRequestDetails);
            var pendingGrid = document.getElementById(window.CMF_PORTAL.ids.gridViewCmfPending);
            var issueMain = issueShell ? issueShell.querySelector('.issue-tab-main') : null;
            var pendingMain = pendingShell ? pendingShell.querySelector('.pending-tab-main') : null;
            var issueGridWrap = issueGrid ? issueGrid.closest('.issue-grid-scroll') : null;
            var pendingGridWrap = pendingGrid ? pendingGrid.closest('.cmf-pending-grid-wrap') : null;

            var issueActive = isElementVisible(issuePane) || isElementVisible(issueHeader) || isElementVisible(issueGrid) || isElementVisible(issueMain);
            var pendingActive = isElementVisible(pendingPane) || isElementVisible(pendingHeader) || isElementVisible(pendingGrid) || isElementVisible(pendingMain);

            var activeText = activeViewTitle ? (activeViewTitle.textContent || activeViewTitle.innerText || '').toLowerCase() : '';
            var activeTab = (window.CMF_PORTAL.activeFocusedTab || '').toLowerCase();
            if (activeTab === 'pending' || activeText.indexOf('pending') >= 0) {
                pendingActive = true;
                issueActive = false;
            } else if (activeTab === 'issue' || activeText.indexOf('issue') >= 0) {
                issueActive = true;
                pendingActive = false;
            }

            if (!issueActive && !pendingActive) {
                var issueWasVisible = !!(issueShell && issueShell.style.display === 'grid');
                var pendingWasVisible = !!(pendingShell && pendingShell.style.display === 'grid');
                if (pendingWasVisible) {
                    pendingActive = true;
                } else if (issueWasVisible) {
                    issueActive = true;
                } else {
                    issueActive = true;
                }
            }

            if (issueActive && pendingActive) {
                if (activeTab === 'pending' || activeText.indexOf('pending') >= 0) {
                    issueActive = false;
                } else {
                    pendingActive = false;
                }
            }

            if (issueShell) {
                issueShell.style.display = issueActive ? 'grid' : 'none';
                issueShell.classList.toggle('portal-view-hidden', !issueActive);
                issueShell.classList.toggle('side-hidden', !issueActive);
            }
            if (pendingShell) {
                pendingShell.style.display = pendingActive ? 'grid' : 'none';
                pendingShell.classList.toggle('portal-view-hidden', !pendingActive);
                pendingShell.classList.toggle('side-hidden', !pendingActive);
            }

            if (issueSide) {
                issueSide.style.display = issueActive ? 'grid' : 'none';
                issueSide.classList.toggle('portal-view-hidden', !issueActive);
            }

            if (pendingSide) {
                pendingSide.style.display = pendingActive ? 'grid' : 'none';
                pendingSide.classList.toggle('portal-view-hidden', !pendingActive);
            }

            if (issueGridWrap) {
                issueGridWrap.style.display = issueActive ? '' : 'none';
                issueGridWrap.classList.toggle('portal-view-hidden', !issueActive);
            }

            if (pendingGridWrap) {
                pendingGridWrap.style.display = pendingActive ? '' : 'none';
                pendingGridWrap.classList.toggle('portal-view-hidden', !pendingActive);
            }

            filterPortalVisibleTables();
        }

        function isReportsViewActive() {
            var activeViewTitle = document.getElementById(window.CMF_PORTAL.ids.activeViewTitle);
            var text = activeViewTitle ? (activeViewTitle.textContent || activeViewTitle.innerText || '') : '';
            return text.toLowerCase().indexOf('report') >= 0;
        }

        document.addEventListener('DOMContentLoaded', function () {
            window.CMF_PORTAL.currentPlatform = getCurrentPlatformValue();
            window.CMF_PORTAL.homeDashboardSnapshot = <%= string.IsNullOrWhiteSpace(HomeDashboardSnapshotJson) ? "null" : HomeDashboardSnapshotJson %>;
            syncActivePlatformChip();
            var issueGrid = document.getElementById(window.CMF_PORTAL.ids.overallRequestDetails);
            if (isElementVisible(issueGrid)) {
                setTimeout(function () { syncIssueHorizontalScroll(0); }, 60);
            }
            if (isReportsViewActive()) {
                bindReportsPromptEnterHandler();
                initReportsFormatTemplate();
            }
            initCollapsibleSections();
            initMainMenuTooltips();
            initPortalNavPostbackFallback();
            renderHomeDashboard();
            renderInteractiveIssuePendingSidebars();
            syncIssuePendingSidePanelVisibility();
            bindGlobalSearchShortcut();
            applyTableOnlyScroll();
            scheduleInitColumnHideButtons(80);
        });

        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                window.CMF_PORTAL.currentPlatform = getCurrentPlatformValue();
                window.CMF_PORTAL.homeDashboardSnapshot = <%= string.IsNullOrWhiteSpace(HomeDashboardSnapshotJson) ? "null" : HomeDashboardSnapshotJson %>;
                syncActivePlatformChip();
                var issueGrid = document.getElementById(window.CMF_PORTAL.ids.overallRequestDetails);
                if (isElementVisible(issueGrid)) {
                    setTimeout(function () { syncIssueHorizontalScroll(0); }, 60);
                }
                if (isReportsViewActive()) {
                    bindReportsPromptEnterHandler();
                    initReportsFormatTemplate();
                }
                initCollapsibleSections();
                initMainMenuTooltips();
                initPortalNavPostbackFallback();
                renderHomeDashboard();
                renderInteractiveIssuePendingSidebars();
                syncIssuePendingSidePanelVisibility();
                bindGlobalSearchShortcut();
                applyTableOnlyScroll();
                scheduleInitColumnHideButtons(0);
            });
        }

        // ── Column hide buttons ──────────────────────────────────────────────
        var CMF_HIDDEN_COLS_KEY = 'cmf_hidden_cols';
        var CMF_COLHIDE_TIMER = null;

        function scheduleInitColumnHideButtons(delay) {
            if (CMF_COLHIDE_TIMER) {
                clearTimeout(CMF_COLHIDE_TIMER);
            }
            CMF_COLHIDE_TIMER = setTimeout(function () {
                CMF_COLHIDE_TIMER = null;
                initColumnHideButtons();
            }, typeof delay === 'number' ? delay : 0);
        }

        function initColumnHideButtons() {
            var grid = document.getElementById('<%= overall_request_details.ClientID %>');
            if (!grid) return;
            if (!isElementVisible(grid)) return;
            // Select every header cell that carries a field-* class, regardless of thead/tbody structure
            var headers = grid.querySelectorAll('th[class*="field-"]');
            if (!headers || headers.length === 0) return;
            var stamp = headers.length + ':' + (grid.rows ? grid.rows.length : 0);
            var existingButtons = grid.querySelectorAll('.col-hide-btn').length;
            if (grid.getAttribute('data-colhide-stamp') === stamp && existingButtons >= headers.length) {
                restoreHiddenColumns();
                return;
            }
            headers.forEach(function (th) {
                if (th.querySelector('.col-hide-btn')) return; // already injected
                var fieldClass = [].slice.call(th.classList).find(function (c) { return c.indexOf('field-') === 0; });
                if (!fieldClass) return;
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'col-hide-btn';
                btn.innerHTML = '&#x2715;';
                btn.title = 'Hide column';
                btn.setAttribute('data-field', fieldClass);
                btn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    hideColumnByClass(fieldClass);
                });
                // Place beside the label text, inside filter container if present
                var target = th.querySelector('.filter-header-text') || th;
                target.appendChild(btn);
            });
            grid.setAttribute('data-colhide-stamp', stamp);
            restoreHiddenColumns();
        }

        function hideColumnByClass(fieldClass) {
            document.querySelectorAll('.' + fieldClass).forEach(function (el) {
                el.classList.add('hidden');
            });
            var hidden = JSON.parse(localStorage.getItem(CMF_HIDDEN_COLS_KEY) || '[]');
            if (hidden.indexOf(fieldClass) === -1) {
                hidden.push(fieldClass);
                localStorage.setItem(CMF_HIDDEN_COLS_KEY, JSON.stringify(hidden));
            }
            var btn = document.getElementById('btnShowAllColumns');
            if (btn) btn.style.display = '';
        }

        function restoreHiddenColumns() {
            var hidden = JSON.parse(localStorage.getItem(CMF_HIDDEN_COLS_KEY) || '[]');
            hidden.forEach(function (fieldClass) {
                document.querySelectorAll('.' + fieldClass).forEach(function (el) {
                    el.classList.add('hidden');
                });
            });
            var btn = document.getElementById('btnShowAllColumns');
            if (btn) btn.style.display = hidden.length > 0 ? '' : 'none';
        }

        function showAllColumns() {
            var hidden = JSON.parse(localStorage.getItem(CMF_HIDDEN_COLS_KEY) || '[]');
            hidden.forEach(function (fieldClass) {
                document.querySelectorAll('.' + fieldClass).forEach(function (el) {
                    el.classList.remove('hidden');
                });
            });
            localStorage.removeItem(CMF_HIDDEN_COLS_KEY);
            var btn = document.getElementById('btnShowAllColumns');
            if (btn) btn.style.display = 'none';
        }

        function filterGridRowsByQuery(grid, query) {
            if (!grid) return;
            var rows = grid.querySelectorAll('tbody tr');
            rows.forEach(function (row) {
                var text = (row.textContent || row.innerText || '').toLowerCase();
                row.style.display = (!query || text.indexOf(query) !== -1) ? '' : 'none';
            });
        }

        function filterPortalVisibleTables() {
            var input = document.getElementById('globalPortalSearch');
            var query = input ? (input.value || '').trim().toLowerCase() : '';
            var clearBtn = document.getElementById('globalSearchClear');

            filterGridRowsByQuery(document.getElementById('<%= overall_request_details.ClientID %>'), query);
            filterGridRowsByQuery(document.getElementById('<%= GridView_cmf_pending.ClientID %>'), query);

            if (clearBtn) {
                clearBtn.style.display = query ? 'inline-flex' : 'none';
            }
        }

        function clearGlobalPortalSearch() {
            var input = document.getElementById('globalPortalSearch');
            if (!input) return;
            input.value = '';
            filterPortalVisibleTables();
            input.focus();
        }

        function filterIssueTable() {
            filterPortalVisibleTables();
        }

        function clearIssueSearch() {
            clearGlobalPortalSearch();
        }

        function bindGlobalSearchShortcut() {
            if (window.CMF_PORTAL.globalSearchShortcutBound) return;
            document.addEventListener('keydown', function (event) {
                if ((event.ctrlKey || event.metaKey) && String(event.key || '').toLowerCase() === 'k') {
                    var input = document.getElementById('globalPortalSearch');
                    if (input) {
                        event.preventDefault();
                        input.focus();
                        input.select();
                    }
                }
            });
            window.CMF_PORTAL.globalSearchShortcutBound = true;
        }

        function applyTableOnlyScroll() {
            var issueWrap = document.querySelector('.issue-grid-scroll');
            var pendingWrap = document.querySelector('.cmf-pending-grid-wrap');

            if (issueWrap) {
                issueWrap.style.setProperty('max-height', 'min(62vh, 620px)', 'important');
                issueWrap.style.setProperty('min-height', '0', 'important');
                issueWrap.style.setProperty('overflow-x', 'auto', 'important');
                issueWrap.style.setProperty('overflow-y', 'auto', 'important');
                issueWrap.style.setProperty('scrollbar-gutter', 'stable', 'important');
            }

            if (pendingWrap) {
                pendingWrap.style.setProperty('max-height', 'min(64vh, 640px)', 'important');
                pendingWrap.style.setProperty('min-height', '0', 'important');
                pendingWrap.style.setProperty('overflow-x', 'auto', 'important');
                pendingWrap.style.setProperty('overflow-y', 'auto', 'important');
                pendingWrap.style.setProperty('scrollbar-gutter', 'stable', 'important');
            }
        }

        if (window.Sys && Sys.Application) {
            Sys.Application.add_load(function () {
                applyTableOnlyScroll();
                scheduleInitColumnHideButtons(0);
            });
        }
        // ────────────────────────────────────────────────────────────────────
    </script>
    <script src="Scripts/cmf-portal-main.js?v=20260805-ai-recommendation-fix"></script>


</head>

<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="HiddenModalDesign" runat="server" />
    <asp:HiddenField ID="HiddenDriverName" runat="server" />
    <asp:HiddenField ID="HiddenComponentName" runat="server" />
    <asp:HiddenField ID="HiddenIssueType" runat="server" />
<!-- You already have HiddenDriverName -->
    <asp:HiddenField ID="dw_trigger" runat="server" />

    <!-- Header -->
    <header>
        <!-- Convert to ASP.NET DropDownList -->


        <div class="header-title" runat="server" id="headerTitle">CMF Live Dashboard</div>
        <div class="global-search-shell" role="search">
            <i class="fas fa-search" aria-hidden="true"></i>
            <input type="text" id="globalPortalSearch" placeholder="Search issues, customers, components..." autocomplete="off" oninput="filterPortalVisibleTables()" />
            <button type="button" id="globalSearchClear" class="global-search-clear" onclick="clearGlobalPortalSearch()" aria-label="Clear search">&times;</button>
            <span class="global-search-shortcut">Ctrl + K</span>
        </div>
        <div class="header-user-mode">
            <label for="ddlUserMode">Mode</label>
            <asp:DropDownList ID="ddlUserMode" runat="server" CssClass="header-mode-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlUserMode_SelectedIndexChanged">
                <asp:ListItem Text="Program Manager" Value="program_manager" />
                <asp:ListItem Text="Admin" Value="admin" />
            </asp:DropDownList>
        </div>
        <div class="sidebar-toggle-div">
            <button class="sidebar-toggle" onclick="toggleSidebar()">☰</button>
        </div>

              <div id="updateinfo" runat="server">
  <div id="last-update">Last Updated: </div>
  <div id="next-update">Next Update: </div>
   <asp:Label ID="session_count" runat="server" Text="Total Visits: " />
</div>
    </header>
    <div class="container-scroller">



        <div id="sidebar" class="sidebar">
    <button class="close-btn" onclick="closeSidebar()">X</button>
    <!-- Hardcoded 'All Drivers' link -->
    <div style="margin-left: 20px">
        <asp:LinkButton ID="lnkAllDrivers" runat="server" CommandArgument="AllDrivers" OnCommand="lnkValue_Command">
    All Milestones
        </asp:LinkButton><br />
    </div>

    <!-- Select All Checkbox - Updated onclick -->
    <div id="selectallcheckbox" style="margin-left: 20px" runat="server">
        <input type="checkbox" id="chkSelectAll" class="milestone-checkbox" onclick="toggleSelectAll()"/>
        <label style="color: white; font-family: 'Arial', sans-serif;" for="chkSelectAll">Select All</label><br />
    </div>

    <!-- List of distinct values as checkboxes - Updated onclick -->
    <div style="margin-left: 20px">
        <asp:Repeater ID="rptDistinctValues" runat="server">
            <ItemTemplate>
                <input type="checkbox" class="chkValue milestone-checkbox"
                    id="chkValue_<%# Eval("drivers") %>"
                    value='<%# Eval("drivers") %>'
                    onclick="toggleIndividualCheckbox()" />
                <label style="color: white; font-family: 'Arial', sans-serif;"><%# Eval("drivers") %></label><br />
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <asp:LinkButton ID="submitdrivers" runat="server" CommandArgument="" OnCommand="lnkValue_Command">
Submit
    </asp:LinkButton>
</div>



        <!-- Main Content -->
        <div class="container-fluid page-body-wrapper">
                <asp:HiddenField ID="HiddenField1" runat="server" />
                <asp:HiddenField ID="HiddenModalDriver" runat="server" />
                <asp:HiddenField ID="HiddenField2" runat="server" />

                <asp:ScriptManager ID="ScriptManager1" runat="server">
                </asp:ScriptManager>

                <div class="portal-layout-shell" id="portalLayoutShell">
                    <aside class="portal-left-nav" id="mainMenuSidebar">
                        <div class="portal-section-header">
                            <button type="button" id="mainMenuToggleBtn" class="portal-collapse-btn" aria-expanded="true" onclick="toggleCollapsibleSection('mainMenu')" title="Collapse menu" aria-label="Collapse menu">
                                <span class="toggle-label">&lt;&lt;</span>
                            </button>
                        </div>
                        <div class="portal-nav-active-title" aria-live="polite">
                            <asp:Label ID="lblActiveViewTitle" runat="server" Text="Issue List" />
                        </div>
                        <div id="mainMenuSectionBody" class="collapsible-body">
                            <asp:LinkButton ID="lnkNavHome" runat="server" CssClass="portal-nav-link" OnClick="btnShowHomeDashboard_Click"><i class="fas fa-chart-pie" aria-hidden="true"></i><span>Dashboard</span></asp:LinkButton>
                            <asp:LinkButton ID="lnkNavIssueList" runat="server" CssClass="portal-nav-link" OnClick="btnShowGridView1_Click"><i class="fas fa-fire" aria-hidden="true"></i><span>Issue List</span></asp:LinkButton>
                            <asp:LinkButton ID="lnkNavPendingList" runat="server" CssClass="portal-nav-link" OnClick="btnShowGridView4_Click"><i class="fas fa-clipboard-check" aria-hidden="true"></i><span>CMF Pending</span></asp:LinkButton>
                            <asp:LinkButton ID="lnkNavReports" runat="server" CssClass="portal-nav-link" OnClick="btnShowGridView8_Click"><i class="fas fa-chart-line" aria-hidden="true"></i><span>Reports</span></asp:LinkButton>
                            <asp:LinkButton ID="lnkNavConfigRules" runat="server" CssClass="portal-nav-link" OnClick="btnShowGridView9_Click" Visible="false"><i class="fas fa-sliders-h" aria-hidden="true"></i><span>Rules</span></asp:LinkButton>
                        </div>
                    </aside>

                    <button type="button" id="mainMenuReopenBtn" class="portal-menu-reopen" aria-expanded="false" onclick="toggleCollapsibleSection('mainMenu')" title="Open menu" aria-label="Open menu">
                        <span class="toggle-chevron">&gt;&gt;</span>
                    </button>

                    <div class="portal-main-workspace">
                        <asp:Panel ID="homeWelcomePanel" runat="server" Visible="false" CssClass="welcome-home-panel ccip-dashboard-host">
                            <div class="ccip-dashboard">
                                <div class="ccip-dash-top">
                                    <div>
                                        <asp:Label ID="lblHomeGreeting" runat="server" CssClass="ccip-dash-greeting" Text="Good Morning" />
                                        <p class="ccip-dash-sub">Here is what is happening with your critical issues today on <%: HomeDashboardPlatformLabel %> in <asp:Label ID="lblWelcomeMode" runat="server" /> mode.</p>
                                    </div>
                                    <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                                        <div class="ccip-dash-updated">Updated <asp:Label ID="lblHomeDashboardGeneratedAt" runat="server" /></div>
                                        <asp:HyperLink ID="lnkPlatformDashboardHome" runat="server" Target="_blank" CssClass="ccip-link-btn" Visible="false">Open platform dashboard</asp:HyperLink>
                                    </div>
                                </div>

                                <div class="platform-chip-rail" role="tablist" aria-label="Dashboard platform switch" style="margin-bottom:14px;">
                                    <button type="button" class="platform-chip" data-platform="CMF_PTL_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_PTL_ALL_COMPONENTS_TABLE')">PTL</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_LNL_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_LNL_ALL_COMPONENTS_TABLE')">LNL</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_ARL_S_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_S_ALL_COMPONENTS_TABLE')">ARL-S</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_ARL_H_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_H_ALL_COMPONENTS_TABLE')">ARL-H</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_ARL_U_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_U_ALL_COMPONENTS_TABLE')">ARL-U</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_ARL_HX_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_HX_ALL_COMPONENTS_TABLE')">ARL-Hx</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_ARL_Refresh_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_Refresh_ALL_COMPONENTS_TABLE')">ARL-Refresh</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_GNR_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_GNR_ALL_COMPONENTS_TABLE')">GNR</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_WCL_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_WCL_ALL_COMPONENTS_TABLE')">WCL</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_NVL_S_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_NVL_S_ALL_COMPONENTS_TABLE')">NVL-S</button>
                                    <button type="button" class="platform-chip" data-platform="CMF_NVL_H_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_NVL_H_ALL_COMPONENTS_TABLE')">NVL-H</button>
                                </div>

                                <asp:Label ID="lblHomeAiNewTodayValue" runat="server" style="display:none;" />
                                <asp:Label ID="lblHomeAiClosedTodayValue" runat="server" style="display:none;" />

                                <div class="ccip-kpi-row">
                                    <div class="ccip-kpi kpi-red">
                                        <div class="ccip-kpi-head"><div class="ccip-kpi-title">Open Critical Issues</div><div class="ccip-kpi-icon"><i class="fas fa-circle-exclamation" aria-hidden="true"></i></div></div>
                                        <div class="ccip-kpi-value"><asp:Label ID="lblHomeActiveIssuesValue" runat="server" /></div>
                                        <div class="ccip-kpi-note"><i class="fas fa-arrow-down" aria-hidden="true"></i>12% vs last week</div>
                                        <div class="ccip-kpi-spark" aria-hidden="true"></div>
                                    </div>
                                    <div class="ccip-kpi kpi-orange">
                                        <div class="ccip-kpi-head"><div class="ccip-kpi-title">Need Attention</div><div class="ccip-kpi-icon"><i class="fas fa-bell" aria-hidden="true"></i></div></div>
                                        <div class="ccip-kpi-value"><asp:Label ID="lblHomeNeedsAttentionValue" runat="server" /></div>
                                        <div class="ccip-kpi-note"><i class="fas fa-arrow-up" aria-hidden="true"></i>16% vs last week</div>
                                        <div class="ccip-kpi-spark" aria-hidden="true"></div>
                                    </div>
                                    <div class="ccip-kpi kpi-green">
                                        <div class="ccip-kpi-head"><div class="ccip-kpi-title">Resolved This Week</div><div class="ccip-kpi-icon"><i class="fas fa-circle-check" aria-hidden="true"></i></div></div>
                                        <div class="ccip-kpi-value"><asp:Label ID="lblHomeResolvedThisWeekValue" runat="server" /></div>
                                        <div class="ccip-kpi-note"><i class="fas fa-arrow-up" aria-hidden="true"></i>23% vs last week</div>
                                        <div class="ccip-kpi-spark" aria-hidden="true"></div>
                                    </div>
                                    <div class="ccip-kpi kpi-blue">
                                        <div class="ccip-kpi-head"><div class="ccip-kpi-title">Avg. Resolution Time</div><div class="ccip-kpi-icon"><i class="fas fa-clock" aria-hidden="true"></i></div></div>
                                        <div class="ccip-kpi-value"><asp:Label ID="lblHomeResolutionDaysValue" runat="server" /></div>
                                        <div class="ccip-kpi-note"><i class="fas fa-arrow-down" aria-hidden="true"></i>18% vs last week</div>
                                        <div class="ccip-kpi-spark" aria-hidden="true"></div>
                                    </div>
                                    <div class="ccip-kpi kpi-purple">
                                        <div class="ccip-kpi-head"><div class="ccip-kpi-title">Customers Affected</div><div class="ccip-kpi-icon"><i class="fas fa-users" aria-hidden="true"></i></div></div>
                                        <div class="ccip-kpi-value"><asp:Label ID="lblHomeCustomersAffectedValue" runat="server" /></div>
                                        <div class="ccip-kpi-note"><i class="fas fa-arrow-up" aria-hidden="true"></i>15% vs last week</div>
                                        <div class="ccip-kpi-spark" aria-hidden="true"></div>
                                    </div>
                                </div>

                                <div class="ccip-main-grid">
                                    <div class="ccip-col ccip-col-left">
                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-robot" aria-hidden="true" style="color:#3b82f6; margin-right:6px;"></i>AI Daily Summary</h3>
                                                <span class="ccip-card-subtitle">Updated <asp:Label ID="lblHomeAiWatchlistValue" runat="server" /> min ago</span>
                                            </div>
                                            <ul class="ccip-daily-list">
                                                <asp:Literal ID="litHomeAiDailySummary" runat="server" />
                                            </ul>
                                            <div class="ccip-daily-actions">
                                                <button type="button" class="ccip-button">View Details</button>
                                                <button type="button" class="ccip-button primary">Open in AI Copilot</button>
                                            </div>
                                        </section>

                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-lightbulb" aria-hidden="true" style="color:#f59e0b; margin-right:6px;"></i>AI Recommendations</h3>
                                                <a href="#" class="ccip-card-link" onclick="return false;">View all</a>
                                            </div>
                                            <div class="ccip-card-subtitle" style="margin-bottom:8px;">Similar issue cluster detected</div>
                                            <div class="ccip-rec-list">
                                                <div class="ccip-rec-row"><span class="ccip-rec-label">GPU Driver</span><span class="ccip-rec-track"><span class="ccip-rec-fill good" style="width:92%"></span></span><span class="ccip-rec-percent">92%</span></div>
                                                <div class="ccip-rec-row"><span class="ccip-rec-label">Memory Leak</span><span class="ccip-rec-track"><span class="ccip-rec-fill medium" style="width:14%"></span></span><span class="ccip-rec-percent">14%</span></div>
                                                <div class="ccip-rec-row"><span class="ccip-rec-label">Firmware</span><span class="ccip-rec-track"><span class="ccip-rec-fill low" style="width:5%"></span></span><span class="ccip-rec-percent">5%</span></div>
                                            </div>
                                            <div style="margin-top:12px;" class="ccip-card-subtitle">Suggested next step</div>
                                            <ul class="ccip-daily-list" style="margin-top:8px;">
                                                <li>Update GPU Driver to v32.0</li>
                                                <li>Restart inference runtime</li>
                                                <li>Collect ETL logs</li>
                                            </ul>
                                            <button type="button" class="ccip-button" style="width:100%; margin-top:10px;">Apply Recommendation</button>
                                        </section>
                                    </div>

                                    <div class="ccip-col ccip-col-center">
                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-chart-line" aria-hidden="true" style="color:#3b82f6; margin-right:6px;"></i>Issue Trend (Last 7 Days)</h3>
                                                <a href="#" class="ccip-card-link" onclick="return false;">View Analytics</a>
                                            </div>
                                            <div id="homeTrendChart" class="ccip-trend-chart"></div>
                                        </section>

                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-fire" aria-hidden="true" style="color:#f97316; margin-right:6px;"></i>Priority Issues</h3>
                                                <a href="#" class="ccip-card-link" onclick="return false;">View all</a>
                                            </div>
                                            <table class="ccip-priority-table">
                                                <thead>
                                                    <tr><th>Severity</th><th>Issue ID</th><th>Customer</th><th>Product</th><th>Owner</th><th>AI Confidence</th><th>Status</th><th>ETA</th></tr>
                                                </thead>
                                                <tbody id="homePriorityRows"></tbody>
                                            </table>
                                        </section>

                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-clock-rotate-left" aria-hidden="true" style="color:#6366f1; margin-right:6px;"></i>Recent Activity</h3>
                                                <a href="#" class="ccip-card-link" onclick="return false;">View all</a>
                                            </div>
                                            <ul id="homeRecentActivity" class="ccip-activity-list"></ul>
                                        </section>
                                    </div>

                                    <div class="ccip-col ccip-col-right">
                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-earth-americas" aria-hidden="true" style="color:#3b82f6; margin-right:6px;"></i>Customers Affected by Region</h3>
                                                <a href="#" class="ccip-card-link" onclick="return false;">View all</a>
                                            </div>
                                            <div class="ccip-region-wrap">
                                                <div class="ccip-region-map" aria-hidden="true"></div>
                                                <ul class="ccip-region-list">
                                                    <li><span><span class="ccip-dot blue"></span>North America</span><strong>12</strong></li>
                                                    <li><span><span class="ccip-dot green"></span>Europe</span><strong>6</strong></li>
                                                    <li><span><span class="ccip-dot orange"></span>Asia Pacific</span><strong>4</strong></li>
                                                    <li><span><span class="ccip-dot purple"></span>Latin America</span><strong>1</strong></li>
                                                    <li><span><span class="ccip-dot red"></span>Middle East</span><strong>0</strong></li>
                                                </ul>
                                            </div>
                                        </section>

                                        <section class="ccip-card">
                                            <div class="ccip-card-head">
                                                <h3 class="ccip-card-mini-title"><i class="fas fa-chart-pie" aria-hidden="true" style="color:#3b82f6; margin-right:6px;"></i>Issues by Product</h3>
                                                <a href="#" class="ccip-card-link" onclick="return false;">View all</a>
                                            </div>
                                            <div class="ccip-product-wrap">
                                                <div id="homeStatusChart" class="ccip-product-chart"></div>
                                                <ul id="homeTopComponentsList" class="ccip-product-list"></ul>
                                            </div>
                                        </section>

                                        <section class="ccip-card">
                                            <div class="ccip-card-head"><h3 class="ccip-card-mini-title"><i class="fas fa-bolt" aria-hidden="true" style="color:#f59e0b; margin-right:6px;"></i>Quick Actions</h3></div>
                                            <div class="ccip-quick-grid">
                                                <button type="button" class="ccip-quick-btn">New Issue</button>
                                                <button type="button" class="ccip-quick-btn">Analyze Logs</button>
                                                <button type="button" class="ccip-quick-btn">Generate RCA</button>
                                                <button type="button" class="ccip-quick-btn">Customer Update</button>
                                                <button type="button" class="ccip-quick-btn">Search Similar Cases</button>
                                                <button type="button" class="ccip-quick-btn">Upload Logs</button>
                                            </div>
                                        </section>

                                        <section class="ccip-card">
                                            <div class="ccip-card-head"><h3 class="ccip-card-mini-title"><i class="fas fa-brain" aria-hidden="true" style="color:#8b5cf6; margin-right:6px;"></i>AI Insights</h3></div>
                                            <ul id="homeAiInsights" class="ccip-insights-list"></ul>
                                        </section>
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="configRulesPanel" runat="server" Visible="false" CssClass="welcome-home-panel">
                            <h2 class="welcome-home-title">Config/CMF Rules</h2>
                            <p class="welcome-home-desc">
                                Admin-defined CMF qualification rules. AI recommendations in the CMF Pending List use these rules for tag / no-tag decisions.
                            </p>
                            <div class="cmf-rules-editor-shell">
                                <div class="cmf-rules-card">
                                    <h3 class="cmf-rules-title">CMF Qualification Rules</h3>
                                    <asp:TextBox ID="txtCmfRules" runat="server" TextMode="MultiLine" CssClass="cmf-rules-editor" />
                                    <div class="cmf-rules-actions">
                                        <asp:Button ID="btnSaveCmfRules" runat="server" Text="Save Rules" CssClass="modern-button" OnClick="btnSaveCmfRules_Click" />
                                        <asp:Button ID="btnResetCmfRules" runat="server" Text="Reset Defaults" CssClass="modern-button" OnClick="btnResetCmfRules_Click" />
                                    </div>
                                    <asp:Label ID="lblCmfRulesStatus" runat="server" CssClass="cmf-rules-status" />
                                </div>
                                <div class="cmf-rules-card">
                                    <h3 class="cmf-rules-title">How AI Uses These Rules</h3>
                                    <p class="cmf-rules-note">When a Program Manager opens AI Recommendation on a pending item, the service loads the latest saved admin rules and evaluates the issue fields against them.</p>
                                    <ul class="cmf-rules-list">
                                        <li>Rules are hidden from Program Manager navigation.</li>
                                        <li>Changing rules clears cached recommendations.</li>
                                        <li>The AI response must explain which rules support or block tagging.</li>
                                    </ul>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="reportsPlaceholderPanel" runat="server" Visible="false" CssClass="welcome-home-panel">
                            <h2 class="welcome-home-title">Reports &amp; Analytics</h2>
                            <p class="welcome-home-desc">
                                Statistics view is currently disabled. This tab is reserved for finalized report content.
                            </p>
                        </asp:Panel>

                        <!-- ================================================================
                             REPORTS & ANALYTICS PANEL
                        ================================================================ -->
                        <div id="analyticsPanel" runat="server" visible="false" class="reports-workspace">

                            <div class="reports-assistant-card">
                                <div style="display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom:10px;">
                                    <div>
                                        <div style="font-size:17px; font-weight:700; color:#0f3554;">AI Reports Assistant</div>
                                        <div style="font-size:12px; color:#45627d;">Ask data questions, generate Plotly charts, and create reports from live CMF data.</div>
                                    </div>
                                    <div style="display:flex; gap:8px; flex-wrap:wrap;">
                                        <!-- Quick chart/report actions removed per request -->
                                    </div>
                                </div>

                                <div id="reportsChatLog" class="reports-chat-log">
                                    <div style="display:flex; justify-content:flex-start; margin-bottom:10px;">
                                        <div style="max-width:80%; padding:10px 12px; border-radius:10px; white-space:pre-wrap; font-size:13px; line-height:1.4; background:#eef4fb; color:#12344d; border:1px solid #d6e2ef;">
                                            Ask me things like:\n- "Show status distribution chart"\n- "Give stale issues trend"\n- "Generate issue report csv"
                                        </div>
                                    </div>
                                </div>

                                <div class="reports-prompt-row">
                                    <input id="reportsPromptInput" type="text" placeholder="Type your analytics prompt..." style="flex:1; border:1px solid #c8d9ea; border-radius:8px; padding:10px 12px; font-size:13px;" />
                                    <button id="reportsPromptSend" type="button" class="modern-button" onclick="sendReportsPrompt()">Send</button>
                                </div>
                            </div>

                            <div class="reports-format-card">
                                <h3 class="reports-format-title">Report Format Template</h3>
                                <div class="reports-format-subtitle">Define the structure once; the assistant can populate it from live CMF data when you generate a report.</div>
                                <textarea id="reportsFormatTemplate" class="reports-format-textarea" readonly>## Weekly CMF Report - {{platform}} - {{week}}

1. Executive Summary (AI, 3 bullets)
2. New CMF-tagged sightings (table: id, issue, replication rate, impact)
3. Pending sightings likely to qualify next
4. Closed this week (root cause + fixed SW version)
5. Top risks / stale issues
6. Chart: CMF tag rate trend</textarea>
                                <input type="file" id="reportsFormatFile" accept=".txt,.md,.csv,.json,.html" style="display:none" onchange="uploadReportsFormat(event)" />
                                <div class="reports-format-actions">
                                    <button type="button" class="modern-button" style="padding:6px 10px;" onclick="document.getElementById('reportsFormatFile').click()">Upload sample format</button>
                                    <button type="button" id="reportsFormatEditBtn" class="modern-button" style="padding:6px 10px;" onclick="setReportsTemplateEditMode(true)">Edit format</button>
                                    <button type="button" id="reportsFormatSaveBtn" class="modern-button" style="padding:6px 10px;" onclick="saveReportsFormatTemplate()" disabled>Save format</button>
                                    <button type="button" class="modern-button" style="padding:6px 10px;" onclick="generateReportsFromTemplate()">Generate from format</button>
                                    <span id="reportsFormatName" class="reports-format-subtitle" style="margin:0; display:none;"></span>
                                </div>
                            </div>

                        </div>

                <asp:DropDownList
                    ID="ddlTables"
                    runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlTables_SelectedIndexChanged"
                    CssClass="dropdown"
                    Style="display:none;">
                    <asp:ListItem Text="PTL" Value="CMF_PTL_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="LNL" Value="CMF_LNL_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="ARL-S" Value="CMF_ARL_S_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="ARL-H" Value="CMF_ARL_H_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="ARL-U" Value="CMF_ARL_U_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="ARL-Hx" Value="CMF_ARL_HX_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="GNR" Value="CMF_GNR_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="WCL" Value="CMF_WCL_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="ARL-Refresh" Value="CMF_ARL_Refresh_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="NVL-S" Value="CMF_NVL_S_ALL_COMPONENTS_TABLE" />
                    <asp:ListItem Text="NVL-H" Value="CMF_NVL_H_ALL_COMPONENTS_TABLE" />
                </asp:DropDownList>

                <div class="platform-switcher-modern" style="display:none;">
                    <div class="platform-chip-rail" role="tablist" aria-label="Quick platform switch">
                        <button type="button" class="platform-chip" data-platform="CMF_PTL_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_PTL_ALL_COMPONENTS_TABLE')">PTL</button>
                        <button type="button" class="platform-chip" data-platform="CMF_LNL_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_LNL_ALL_COMPONENTS_TABLE')">LNL</button>
                        <button type="button" class="platform-chip" data-platform="CMF_ARL_S_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_S_ALL_COMPONENTS_TABLE')">ARL-S</button>
                        <button type="button" class="platform-chip" data-platform="CMF_ARL_H_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_H_ALL_COMPONENTS_TABLE')">ARL-H</button>
                        <button type="button" class="platform-chip" data-platform="CMF_ARL_U_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_U_ALL_COMPONENTS_TABLE')">ARL-U</button>
                        <button type="button" class="platform-chip" data-platform="CMF_ARL_HX_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_HX_ALL_COMPONENTS_TABLE')">ARL-Hx</button>
                        <button type="button" class="platform-chip" data-platform="CMF_ARL_Refresh_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_ARL_Refresh_ALL_COMPONENTS_TABLE')">ARL-Refresh</button>
                        <button type="button" class="platform-chip" data-platform="CMF_GNR_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_GNR_ALL_COMPONENTS_TABLE')">GNR</button>
                        <button type="button" class="platform-chip" data-platform="CMF_WCL_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_WCL_ALL_COMPONENTS_TABLE')">WCL</button>
                        <button type="button" class="platform-chip" data-platform="CMF_NVL_S_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_NVL_S_ALL_COMPONENTS_TABLE')">NVL-S</button>
                        <button type="button" class="platform-chip" data-platform="CMF_NVL_H_ALL_COMPONENTS_TABLE" onclick="applyQuickPlatform('CMF_NVL_H_ALL_COMPONENTS_TABLE')">NVL-H</button>
                    </div>
                </div>

                <asp:HiddenField ID="hfQuickPlatform" runat="server" />
                <asp:LinkButton ID="btnQuickPlatformApply" runat="server" OnClick="btnQuickPlatformApply_Click" Style="display:none;" />

                <div class="portal-view-row" style="display:none;">
                    <div class="portal-view-left">
                        <asp:DropDownList ID="ddlFocusedView" runat="server" CssClass="portal-view-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlFocusedView_SelectedIndexChanged">
                            <asp:ListItem Text="Main Dashboard" Value="home" />
                            <asp:ListItem Text="Issue List" Value="issue" />
                            <asp:ListItem Text="CMF Pending List" Value="pending" />
                            <asp:ListItem Text="Reports &amp; Analytics" Value="reports" />
                            <asp:ListItem Text="Config/CMF Rules" Value="config" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="button-container button-container-focus" style="display:none;">

                    <asp:Button ID="btnShowGridView3" runat="server" Text="CMF Summary" OnClick="btnShowGridView3_Click" CssClass="modern-button" Visible="false" />
                    <asp:Button ID="btnShowGridView2" runat="server" Text="Design Summary" OnClick="btnShowGridView2_Click" CssClass="modern-button" Visible="false" />
                    <asp:Button ID="btnShowGridView1" runat="server" Text="Issue List" OnClick="btnShowGridView1_Click" CssClass="modern-button tab-pill" />
                    <asp:Button ID="btnShowGridView4" runat="server" Text="CMF Pending List" OnClick="btnShowGridView4_Click" CssClass="modern-button tab-pill" />
                    <asp:Button ID="btnShowGridView5" runat="server" Text="Design Indicator" OnClick="btnShowGridView5_Click" CssClass="modern-button" Visible="false" />
                    <asp:Button ID="btnShowGridView6" runat="server" Text="Ingredient Indicator" OnClick="btnShowGridView6_Click" CssClass="modern-button" Visible="false" />
                    <asp:Button ID="btnShowGridView7" runat="server" Text="OEM Indicator" OnClick="btnShowGridView7_Click" CssClass="modern-button" Visible="false" /> 

<asp:Button ID="btnExportToExcel" runat="server" Text="Export to Excel" OnClick="btnExportToExcel_Click" CssClass="modern-button" />
                    <asp:Button ID="btnExportToExcel_ig" runat="server" Text="Export to Excel" OnClick="btnExportToExcel_Click_ingred" CssClass="modern-button" />
                    <asp:Button ID="btnExportToExcel_des" runat="server" Text="Export to Excel" OnClick="btnExportToExcel_Click_design" CssClass="modern-button" />
                    <asp:Button ID="btnExportToExcel_des_summary" runat="server" Text="Export to Excel" OnClick="btnExportToExcel_Click_designsummary" CssClass="modern-button" />
                    <asp:Button ID="btnExportToExcel_cmf_pending" runat="server" Text="Export to Excel" OnClick="btnExportToExcel_Click_cmf_pending" CssClass="modern-button" />
                    <asp:Button ID="btnExportToExcel_oem" runat="server" Text="Export to Excel" OnClick="btnExportToExcel_Click_oem" CssClass="modern-button" Visible="false" />
                    <asp:Button ID="btnShowGridView8" runat="server" Text="Reports &amp; Analytics" OnClick="btnShowGridView8_Click" CssClass="modern-button tab-pill" />
                    <asp:Button ID="btnShowGridView9" runat="server" Text="Config/CMF Rules" OnClick="btnShowGridView9_Click" CssClass="modern-button tab-pill" Visible="false" />
        
                </div>

                <div class="pane-heading" runat="server" id="pane1" visible="false">CMF Summary</div>
                <div class="pane-heading" runat="server" id="pane2" visible="false">Design Summary</div>
                <div class="pane-heading" runat="server" id="pane3" visible="true">Issue List</div>
                <div class="pane-heading" runat="server" id="pane4" visible="false">CMF Pending List</div>

                <div class="pane-heading" runat="server" id="pane5" visible="false">Design Indicator</div>
                <div class="pane-heading" runat="server" id="pane6" visible="false">Ingredient Indicator</div>
                <div class="pane-heading" runat="server" id="pane7" visible="false">OEM Indicator</div>
                <div class="pane-heading" runat="server" id="pane8" visible="false">Reports &amp; Analytics</div>
                <div class="pane-heading" runat="server" id="pane9" visible="false">Config/CMF Rules</div>

                <div id="aiSummaryDrawerBg" class="ai-summary-drawer-bg" onclick="closeAiSummaryDrawer()"></div>
                <aside id="aiSummaryDrawer" class="ai-summary-drawer" aria-hidden="true" role="dialog" aria-label="AI Issue Summary">
                    <button type="button" class="ai-summary-drawer-close" onclick="closeAiSummaryDrawer()" aria-label="Close">&times;</button>
                    <h2 class="ai-summary-drawer-title"><span>AI Summary</span><span class="ai-summary-title-badges"><span id="aiSummaryConfidence" class="ai-summary-confidence-inline">Confidence: --</span><span id="aiSummaryStatusBadge" class="ai-summary-status-value">Status: --</span></span></h2>
                    <div class="ai-summary-meta-row ai-summary-meta-combined"><strong>Sighting ID:</strong> <span id="aiSummaryIssueId">-</span><strong>CMF Ask Date:</strong> <span id="aiSummarySubmittedDate">-</span></div>
                    <div class="ai-summary-meta-row" id="aiSummaryTitleRow" style="display:none"><strong>Title:</strong> <span id="aiSummaryTitle">-</span></div>
                    <div id="aiSummaryFacts" class="ai-summary-facts"></div>
                    <div class="ai-summary-body" id="aiSummaryBody">Generating AI summary...</div>
                    <div class="ai-summary-actions" id="aiSummaryActions" style="display:none">
                        <button type="button" class="ai-action-btn ai-action-copy" onclick="copyAiSummaryForReport()" title="Copy summary as plain text for pasting into reports">
                            &#x2398; Copy for Report
                        </button>
                        <button type="button" class="ai-action-btn ai-action-regen" onclick="regenerateAiSummary()" title="Regenerate summary from AI">
                            &#x21BA; Regenerate
                        </button>
                    </div>
                </aside>

                <div id="cmfRecDrawerBg" class="ai-summary-drawer-bg" onclick="closeCmfRecDrawer()"></div>
                <aside id="cmfRecDrawer" class="ai-summary-drawer" aria-hidden="true" role="dialog" aria-label="AI CMF Pending Recommendation">
                    <button type="button" class="ai-summary-drawer-close" onclick="closeCmfRecDrawer()" aria-label="Close">&times;</button>
                    <h2 class="ai-summary-drawer-title">AI Recommendation</h2>
                    <div class="ai-summary-meta-row cmf-rec-title-row"><strong>Issue Title:</strong> <span id="cmfRecTitle" class="cmf-rec-title-text">-</span><span id="cmfRecRecommendation" class="cmf-rec-decision-badge">Generating...</span></div>
                    <div class="ai-summary-meta-row"><strong>Sighting ID:</strong> <span id="cmfRecCpId">-</span></div>
                    <span id="cmfRecComponent" style="display:none">-</span>
                    
                    <div class="cmf-rec-section">
                        <h3>Decision Basis</h3>
                        <div id="cmfRecEvidence" class="ai-summary-body">-</div>
                    </div>
                    <div class="cmf-rec-section">
                        <h3>Qualification Score</h3>
                        <div id="cmfRecScore" class="ai-summary-body">-</div>
                    </div>
                    <div class="cmf-rec-section">
                        <h3>Qualification Gaps And Checks</h3>
                        <div id="cmfRecChecks" class="ai-summary-body">-</div>
                    </div>
                    <div class="cmf-rec-section">
                        <h3>Recommended Next Steps</h3>
                        <div id="cmfRecNextSteps" class="ai-summary-body">-</div>
                    </div>
                    
                    <div class="cmf-rec-placeholder-actions">
                        <button type="button" class="cmf-rec-placeholder-btn primary" onclick="showCmfPlaceholderAction('Approve CMF Tag')">Approve CMF Tag</button>
                        <button type="button" class="cmf-rec-placeholder-btn" onclick="showCmfPlaceholderAction('Commit Auto-fill')">Commit Auto-fill</button>
                    </div>
                </aside>



                    



                <!-- Popup Modal -->
                <div id="importPopup" class="modal-import">
                    <div class="modal-content-import">
                        <span class="close-import" onclick="closePopup()">&times;</span>
                        <h3>Upload Excel File</h3>

                        <!-- File Upload Input -->
                        <asp:FileUpload ID="fileUploadExcel" runat="server" CssClass="form-control mb-2" />

                        <!-- Import Button -->
                        <asp:Button ID="btnImportExcel" runat="server" Text="Import" CssClass="btn btn-primary" OnClick="btnImportExcel_Click" />

                        <!-- Message Label -->
                        <asp:Label ID="lblMessage" runat="server" ForeColor="Red" CssClass="mt-2 d-block"></asp:Label>
                    </div>
                </div>

                <!-- Toast Container -->
<div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1055;">
    <div id="errorToast" class="toast align-items-center text-bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body" id="toastMessage">
                <!-- Error message will be injected here -->
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>
</div>



                <!-- Hidden Field to store selected values -->
                <asp:HiddenField ID="hfSelectedValues" runat="server" />
                <asp:HiddenField ID="driverCollectorhf" runat="server" />

                <!-- Invisible HTML Button -->
                <asp:Button ID="exportBtn" runat="server" Text="Export to PPT" OnClick="ExportGridViewToPPT" Style="display: none;" />
                <!-- Modal for selecting multiple values -->
                <div class="modal fade" id="exportModal" tabindex="-1" role="dialog" aria-labelledby="exportModalLabel" aria-hidden="true">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exportModalLabel">Select Values to Export</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <asp:Repeater ID="rptDistinctFilters" runat="server">
                                    <ItemTemplate>
                                        <input type="checkbox" class="chkValue" value='<%# Eval("drivers") %>' />
                                        <%# Eval("drivers") %>


                                        <br />
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                <asp:Button
                                    ID="btnExportInModal"
                                    runat="server"
                                    CssClass="btn btn-primary"
                                    Text="Export"
                                    OnClientClick="submitExport(); return false;"
                                    Visible="true" />


                            </div>
                        </div>
                    </div>
                </div>

                

<div id="mainDataWrapper" runat="server" class="content-wrapper">
    <div class="modal-body popup">
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="table-container">

                    <!-- SHARED FILTER PANEL FOR ISSUE LIST & CMF PENDING LIST -->
                    <div id="sharedFilterPanel" runat="server" visible="false" class="overview-platform-actions">
                        <div class="overview-platform-filter">
                            <label>Platform:</label>
                            <asp:DropDownList ID="ddlSharedPlatform" runat="server" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlSharedPlatform_SelectedIndexChanged"
                                CssClass="form-control">
                                <asp:ListItem Text="-- Select Platform --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="issue-external-links">
                            <a href="https://crtt.intel.com/Administration/SetupIDST.aspx?DNo=5343&PNo=135&Ing=92&CNo=1225" target="_blank">CRTT</a>
                            <asp:HyperLink ID="lnkPlatformDashboard" runat="server" Target="_blank" />
                            <asp:HyperLink ID="lnkPlatformDashboardPending" runat="server" Target="_blank" />
                            <a href="https://pbirs01.intel.com/reports/powerbi/CCE-GCE%20DASHBOARDS/CMF_Portal" target="_blank">Infographic</a>
                        </div>
                    </div>

                    <div class="issue-tab-shell" id="issueTabShell" style="display:none;">
                    <div class="issue-tab-main">

                    <asp:Panel ID="issueListHeaderPanel" runat="server" Visible="true">
                        <div class="issue-page-hd">
                            <div class="issue-page-hd-top">
                                <h1 class="issue-page-title">Issue List</h1>
                            </div>
                            <p class="issue-page-desc">
                                Review active issues, understand their current status, and identify what needs attention next.
                            </p>
                        </div>
                        <div class="issue-kpi-row">
                            <div class="issue-kpi">
                                <div class="issue-kpi-label">Total Issues</div>
                                <div class="issue-kpi-value"><asp:Label ID="lblIssueTotal" runat="server" Text="0" /></div>
                                <div class="issue-kpi-sub"><i class="fas fa-arrow-up" aria-hidden="true"></i> current platform workload</div>
                            </div>
                            <div class="issue-kpi">
                                <div class="issue-kpi-label">In Progress</div>
                                <div class="issue-kpi-value" style="color:#0068b5;"><asp:Label ID="lblIssueInProgress" runat="server" Text="0" /></div>
                                <div class="issue-kpi-sub"><i class="fas fa-arrow-up" aria-hidden="true"></i> open or implemented</div>
                            </div>
                            <div class="issue-kpi">
                                <div class="issue-kpi-label">Closed</div>
                                <div class="issue-kpi-value" style="color:#107c10;"><asp:Label ID="lblIssueClosed" runat="server" Text="0" /></div>
                                <div class="issue-kpi-sub"><i class="fas fa-arrow-up" aria-hidden="true"></i> complete or rejected</div>
                            </div>
                            <div class="issue-kpi">
                                <div class="issue-kpi-label">Stale</div>
                                <div class="issue-kpi-value" style="color:#bc2f32;"><asp:Label ID="lblIssueStale" runat="server" Text="0" /></div>
                                <div class="issue-kpi-sub"><i class="fas fa-clock" aria-hidden="true"></i> issues needing attention</div>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- TOP FILTER PANEL - FOR ISSUE LIST -->
                    <asp:Panel ID="fieldSelectorPanel" runat="server" Visible="true">
                        <div class="field-selector-panel issue-top-filter-panel">
                            <div class="issue-filter-section-header">
                                <div class="issue-filter-title"><i class="fas fa-filter" aria-hidden="true"></i> Filters</div>
                                <button type="button" id="issueFiltersToggleBtn" class="issue-collapse-btn" aria-expanded="true" onclick="toggleCollapsibleSection('issueFilters')">
                                    <span class="toggle-label">Hide</span>
                                    <span class="toggle-chevron">▾</span>
                                </button>
                            </div>
                            <div id="issueTopFilterBody" class="collapsible-body">
                                <div class="issue-top-filter-grid">
                                    <div class="issue-top-filter-item"><span>Milestone</span><asp:DropDownList ID="ddlMilestoneTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlMilestoneHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>Owner</span><asp:DropDownList ID="ddlOwnerTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlOwnerHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>RVP Repro</span><asp:DropDownList ID="ddlRvpReproTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRvpReproHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>iDST</span><asp:DropDownList ID="ddlIdstTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlIdstHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>LOS</span><asp:DropDownList ID="ddlLosTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLosHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>Company</span><asp:DropDownList ID="ddlCompanyTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCompanyHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>Customer Detail</span><asp:DropDownList ID="ddlDetailTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDetailHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                    <div class="issue-top-filter-item"><span>Component Group</span><asp:DropDownList ID="ddlComponentTop" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlComponentHeader_SelectedIndexChanged" CssClass="header-dropdown" /></div>
                                </div>
                                <div class="issue-top-filter-buttons">
                                    <asp:Button ID="btnClearFilters" runat="server" CssClass="filter-btn filter-btn-secondary" Text="Clear Filters" OnClick="btnClearFilters_Click" />
                                </div>
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- END TOP FILTER PANEL -->

                    <div id="searchfilters" class="header-overlay" runat="server" visible="false">
                        <!-- Your existing search filters -->
                        <input type="text" id="searchColumn0" placeholder="Search Progress" oninput="filterGrid()" />
                        <input type="text" id="searchColumn5" placeholder="Search Owner" oninput="filterGrid()" />
                        <input type="text" id="searchColumn10" placeholder="Search Component" oninput="filterGrid()" />
                        <input type="text" id="searchColumn4" placeholder="Search Component" oninput="filterGrid()" />
                        <input type="text" id="searchColumn6" placeholder="Search RVP Repro" oninput="filterGrid()" />
                    </div>

                    <div class="issue-user-toolbar">
                        <div class="issue-view-note"><i class="fas fa-table-list" aria-hidden="true"></i> Compact issue workspace</div>
                        <div class="issue-user-actions">
                            <button
                                type="button"
                                id="issueFilterToolbarBtn"
                                class="issue-toolbar-btn filter-toggle"
                                onclick="toggleCollapsibleSection('issueFilters')">
                                <i class="fas fa-filter" aria-hidden="true"></i>
                                Filters
                            </button>
                            <button
                                type="button"
                                id="btnShowAllColumns"
                                class="issue-toolbar-btn secondary"
                                onclick="showAllColumns()"
                                style="display:none">
                                <i class="fas fa-table-columns" aria-hidden="true"></i>
                                Show Columns
                            </button>
                        </div>
                    </div>


                    <div class="gridview-container issue-grid-scroll">
                        <div class="issue-grid-toolbar">
                            <button type="button" id="btnShowAllColumns" class="show-cols-btn" onclick="showAllColumns()" style="display:none" title="Restore all hidden columns">&#x21BA; Show All Columns</button>
                        </div>
                        <!-- MODIFY YOUR GRIDVIEW TO ADD DATA-FIELD ATTRIBUTES -->
                        <div id="issue-grid-inner" class="issue-grid-inner">
                        
<asp:GridView ID="overall_request_details" CssClass="table-primary" runat="server" AutoGenerateColumns="False"
    EmptyDataText="No Open CMFs" OnRowEditing="overall_request_details_RowEditing"
    OnRowUpdating="overall_request_details_RowUpdating" OnRowCancelingEdit="overall_request_details_RowCancelingEdit"
    OnRowDataBound="overall_request_details_RowDataBound" OnPageIndexChanging="overall_request_details_PageIndexChanging"
    AllowPaging="true" PageSize="12" PagerStyle-CssClass="pager" Visible="false">

    <PagerSettings Visible="false" />

    <Columns>
   
        <asp:TemplateField HeaderText="#" ItemStyle-Width="50px" HeaderStyle-Width="50px"
            ItemStyle-CssClass="field-sno" HeaderStyle-CssClass="field-sno">
            <ItemTemplate>
                <div class="issue-sno-cell">
                    <span class="issue-sno-index"><%# Container.DataItemIndex + 1 %></span>
                    <asp:LinkButton ID="btnRowEdit" runat="server" CommandName="Edit" CausesValidation="false" CssClass="issue-inline-edit-btn" ToolTip="Edit row" aria-label="Edit row">
                        <i class="fas fa-pencil-alt" aria-hidden="true"></i>
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
            <EditItemTemplate>
                <div class="issue-sno-cell">
                    <span class="issue-sno-index"><%# Container.DataItemIndex + 1 %></span>
                    <span class="issue-inline-edit-actions">
                        <asp:LinkButton ID="btnRowUpdate" runat="server" CommandName="Update" CssClass="issue-inline-edit-action" ToolTip="Save changes" aria-label="Save changes">
                            <i class="fas fa-check" aria-hidden="true"></i>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnRowCancel" runat="server" CommandName="Cancel" CausesValidation="false" CssClass="issue-inline-edit-action" ToolTip="Cancel edit" aria-label="Cancel edit">
                            <i class="fas fa-times" aria-hidden="true"></i>
                        </asp:LinkButton>
                    </span>
                </div>
            </EditItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Issue Details" ItemStyle-CssClass="field-issue_details" HeaderStyle-CssClass="field-issue_details">
            <ItemTemplate>
                <%# RenderIssueDetails(Eval("SightingID"), Eval("Merged_PromotedID"), Eval("title"), Eval("cmf_request")) %>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Customer" ItemStyle-CssClass="field-customer_detail" HeaderStyle-CssClass="field-customer_detail">
            <ItemTemplate><%# RenderCustomerDetailWithCompanyAndProcessor(Eval("customer_detail"), Eval("customer_company"), Eval("processor")) %></ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Component" ItemStyle-CssClass="component-column field-component" HeaderStyle-CssClass="field-component">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">Component</div>
                    <div class="filter-container">
                        <asp:DropDownList ID="ddlComponentHeader" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlComponentHeader_SelectedIndexChanged" CssClass="header-dropdown" />
                    </div>
                </div>
            </HeaderTemplate>
            <ItemTemplate><%# RenderComponentWithGroupBadge(Eval("component"), Eval("component_group")) %></ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Owner" ItemStyle-CssClass="field-owner" HeaderStyle-CssClass="field-owner">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">Owner</div>
                    <div class="filter-container">
                        <asp:DropDownList ID="ddlOwnerHeader" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlOwnerHeader_SelectedIndexChanged" CssClass="header-dropdown" />
                    </div>
                </div>
            </HeaderTemplate>
            <ItemTemplate><%# RenderOwnerWithPromotedOwner(Eval("Owner"), Eval("owners_name")) %></ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtOwner" runat="server" TextMode="MultiLine" Text='<%# Bind("Owner") %>'
                    CssClass="form-control"></asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Milestone" ItemStyle-CssClass="field-milestone" HeaderStyle-CssClass="field-milestone">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">Milestone</div>
                    <div class="filter-container">
                        <asp:DropDownList ID="ddlMilestoneHeader" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlMilestoneHeader_SelectedIndexChanged" CssClass="header-dropdown" />
                    </div>
                </div>
            </HeaderTemplate>
            <ItemTemplate>
                <%# RenderMilestoneText(Eval("Driver"), Eval("MustFixFor")) %>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="field-status" HeaderStyle-CssClass="field-status">
            <ItemTemplate>
                <%# RenderStatusWithAiSummaryButton(Eval("IssueStatus"), Eval("Status"), Eval("SightingID"), Eval("title"), Eval("SubmittedDate"), Eval("sysdebug")) %>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:BoundField DataField="Status" HeaderText="CMF Status" ReadOnly="True" Visible="false"
            ItemStyle-CssClass="field-cmf_status" HeaderStyle-CssClass="field-cmf_status" />

        <asp:BoundField DataField="ImageFreeze" HeaderText="Image Freeze" ReadOnly="True"
    ItemStyle-CssClass="field-imagefreeze" HeaderStyle-CssClass="field-imagefreeze" />

        <asp:TemplateField HeaderText="Duplicate ID | Customer Detail | ImageFreezeDate"
            ItemStyle-CssClass="field-duplicatedetails" HeaderStyle-CssClass="field-duplicatedetails">
            <ItemTemplate><%# CreateDuplicateLinks(Eval("DuplicateDetails")) %></ItemTemplate>
        </asp:TemplateField>

      
        <asp:TemplateField HeaderText="RVP Repro" ItemStyle-CssClass="field-rvp_repro" HeaderStyle-CssClass="field-rvp_repro">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">RVP Repro</div>
                    <div class="filter-container">
                        <asp:DropDownList ID="ddlRvpReproHeader" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlRvpReproHeader_SelectedIndexChanged" CssClass="header-dropdown" />
                    </div>
                </div>
            </HeaderTemplate>
            <ItemTemplate><span><%# Eval("repro_on_rvp") %></span></ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="iDST" ItemStyle-CssClass="field-idst" HeaderStyle-CssClass="field-idst">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">iDST</div>
                    <div class="filter-container">
                        <asp:DropDownList ID="ddlIdstHeader" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlIdstHeader_SelectedIndexChanged" CssClass="header-dropdown" />
                    </div>
                </div>
            </HeaderTemplate>
            <ItemTemplate><span class="idst-column"><%# Eval("idst") %></span></ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtidst" runat="server" TextMode="MultiLine" Text='<%# Bind("idst") %>'
                    CssClass="form-control"></asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>

        
        <asp:TemplateField HeaderText="LOS" ItemStyle-CssClass="field-los" HeaderStyle-CssClass="field-los">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">LOS</div>
                    <div class="filter-container">
                        <asp:DropDownList ID="ddlLosHeader" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlLosHeader_SelectedIndexChanged" CssClass="header-dropdown" />
                    </div>
                </div>
            </HeaderTemplate>
            <ItemStyle Width="100px" />
            <HeaderStyle Width="100px" />
            <ItemTemplate><span class="los-column"><%# Eval("los") %></span></ItemTemplate>
            <EditItemTemplate>
                <asp:DropDownList ID="ddllos" runat="server" CssClass="form-control"></asp:DropDownList>
            </EditItemTemplate>
        </asp:TemplateField>

        
        <asp:BoundField DataField="processor" HeaderText="Processor" ReadOnly="True"
            ItemStyle-CssClass="field-processor" HeaderStyle-CssClass="field-processor" Visible="false" />

        
    <asp:TemplateField HeaderText="Impact" ItemStyle-CssClass="field-impact_processor" HeaderStyle-CssClass="field-impact_processor">
        <ItemTemplate><%# RenderImpactWithProcessor(Eval("impact"), Eval("processor")) %></ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtimpact" runat="server" TextMode="MultiLine" Text='<%# Bind("impact") %>'
                    CssClass="form-control"></asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>

       
        <asp:TemplateField HeaderText="Days Open" ItemStyle-CssClass="daysopen-column field-days_open" HeaderStyle-CssClass="field-days_open">
            <ItemTemplate><%# RenderDaysOpen(Eval("days_active")) %></ItemTemplate>
        </asp:TemplateField>

        <asp:BoundField DataField="ClosedDetails" HeaderText="Closed Reason / Fixed Version" ReadOnly="True"
            ItemStyle-CssClass="cmfrequest-column field-closed_reason" HeaderStyle-CssClass="field-closed_reason" />

        <asp:BoundField DataField="progress" HeaderText="Progress" ReadOnly="True" Visible="false"
            ItemStyle-CssClass="field-progress" HeaderStyle-CssClass="field-progress" />

    </Columns>
    
<EmptyDataTemplate>
    <div class="empty-data-container">
        <table class="table-primary" style="width:100%">
            <thead>
                <tr>
                    
                    <th style="width:50px;" class="field-sno">S.No</th>

                    <th class="field-sightingid">SightingID | Promoted ID</th>

                    <th class="field-milestone">
                        <div class="filter-header-container">
                            <div class="filter-header-text">Milestone</div>
                            <div class="filter-container">
                                <asp:DropDownList ID="ddlMilestoneHeaderEmpty" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlMilestoneHeader_SelectedIndexChanged"
                                    CssClass="header-dropdown">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </th>

                    <th class="field-title">Title</th>

                    <th class="field-owner">
                        <div class="filter-header-container">
                            <div class="filter-header-text">Owner</div>
                            <div class="filter-container">
                                <asp:DropDownList ID="ddlOwnerHeaderEmpty" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlOwnerHeader_SelectedIndexChanged"
                                    CssClass="header-dropdown">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </th>

                    <th class="field-status">Status</th>

                    <th class="field-component">Component</th>


                    <th class="field-customer_detail">
                        <div class="filter-header-container">
                            <div class="filter-header-text">Customer Detail</div>
                            <div class="filter-container">
                                <asp:DropDownList ID="ddlDetailHeaderEmpty" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlDetailHeader_SelectedIndexChanged"
                                    CssClass="header-dropdown">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </th>

                    <th class="field-imagefreeze">ImageFreeze</th>
                    
                    <th class="field-duplicatedetails">Duplicate ID | Customer Detail | ImageFreezeDate</th>

                    <th class="field-rvp_repro">
                        <div class="filter-header-container">
                            <div class="filter-header-text">RVP Repro</div>
                            <div class="filter-container">
                                <asp:DropDownList ID="ddlRvpReproHeaderEmpty" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlRvpReproHeader_SelectedIndexChanged"
                                    CssClass="header-dropdown">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </th>

                    <th class="field-idst">
                        <div class="filter-header-container">
                            <div class="filter-header-text">iDST</div>
                            <div class="filter-container">
                                <asp:DropDownList ID="ddlIdstHeaderEmpty" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlIdstHeader_SelectedIndexChanged"
                                    CssClass="header-dropdown">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </th>

                    
                    <th class="field-los" style="width:100px;">
                        <div class="filter-header-container">
                            <div class="filter-header-text">LOS</div>
                            <div class="filter-container">
                                <asp:DropDownList ID="ddlLosHeaderEmpty" runat="server"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlLosHeader_SelectedIndexChanged"
                                    CssClass="header-dropdown">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </th>

                   
                    <th class="field-processor">Processor</th>

                   
                    <th class="field-impact">Impact</th>

                    
                    <th class="field-days_open">Days_Open</th>

                    
                    <th class="field-closed_reason">Closed Reason / Fixed Version</th>

                    <th class="field-progress">Progress</th>

                   
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="23" style="text-align:center; padding:20px;">
                        No Open CMFs found for the selected filters. Please adjust your filter criteria.
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</EmptyDataTemplate>

  
</asp:GridView>
                        </div>
                        <asp:Panel ID="issuePagerPanel" runat="server" Visible="false">
                            <div id="issue-scroll-proxy" class="issue-scroll-proxy" aria-label="Issue list horizontal scroll">
                                <div id="issue-scroll-proxy-inner" class="issue-scroll-proxy-inner"></div>
                            </div>
                            <div class="issue-pager-controls">
                                <div class="issue-page-nav" aria-label="Issue pages">
                                    <asp:LinkButton ID="btnPageGroupPrev" runat="server" CssClass="issue-pager-group-btn" OnClick="btnPageGroupPrev_Click" ToolTip="Previous 10 pages">&laquo;</asp:LinkButton>
                                    <asp:Repeater ID="rptPageNumbers" runat="server" OnItemCommand="rptPageNumbers_ItemCommand">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnPageNumber" runat="server" CommandName="SelectPage" CommandArgument='<%# Eval("PageNumber") %>' CssClass='<%# "issue-pager-btn " + (Eval("IsCurrentPage").ToString() == "True" ? "issue-pager-current" : "") %>' Text='<%# Eval("PageNumber") %>' />
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:LinkButton ID="btnPageGroupNext" runat="server" CssClass="issue-pager-group-btn" OnClick="btnPageGroupNext_Click" ToolTip="Next 10 pages">&raquo;</asp:LinkButton>
                                </div>
                                <span class="issue-page-size-control">
                                    <span>Rows per page</span>
                                    <asp:DropDownList ID="ddlIssuePageSize" runat="server" AutoPostBack="true" CssClass="issue-page-size-select" OnSelectedIndexChanged="ddlIssuePageSize_SelectedIndexChanged">
                                        <asp:ListItem Text="10" Value="10" />
                                        <asp:ListItem Text="12" Value="12" Selected="True" />
                                        <asp:ListItem Text="25" Value="25" />
                                        <asp:ListItem Text="50" Value="50" />
                                        <asp:ListItem Text="100" Value="100" />
                                    </asp:DropDownList>
                                </span>
                            </div>
                            <div class="issue-page-status">
                                <asp:Label ID="lblIssuePageStatus" runat="server" />
                            </div>
                        </asp:Panel>

                    </div>
                    <aside class="issue-side-panel" aria-label="Issue tab assistant panel">
                        <section class="interactive-side-card">
                            <div class="interactive-side-head">
                                <h3 class="interactive-side-title"><i class="fas fa-robot" aria-hidden="true" style="color:#4f46e5; margin-right:6px;"></i>AI Assistant</h3>
                            </div>
                            <p class="interactive-side-sub">Ask anything about your active issues and triage signals.</p>
                            <button type="button" class="interactive-side-btn" onclick="showPortalToast('Use the Reports tab assistant for deep issue queries.')">Ask AI</button>
                        </section>

                        <section class="interactive-side-card">
                            <div class="interactive-side-head"><h3 class="interactive-side-title">Quick Insights</h3></div>
                            <ul class="interactive-chip-list">
                                <li><span>Total visible issues</span><span class="interactive-chip" id="issueSideTotal">0</span></li>
                                <li><span>In progress signals</span><span class="interactive-chip" id="issueSideProgress">0</span></li>
                                <li><span>Stale over SLA</span><span class="interactive-chip" id="issueSideStale">0</span></li>
                            </ul>
                        </section>

                        <section class="interactive-side-card">
                            <div class="interactive-side-head"><h3 class="interactive-side-title">Shortcuts</h3></div>
                            <div class="interactive-shortcuts">
                                <button type="button" class="interactive-shortcut-btn" onclick="document.getElementById('issueFiltersToggleBtn').click()">Toggle Filters</button>
                                <button type="button" class="interactive-shortcut-btn" onclick="showAllColumns()">Show Columns</button>
                                <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Use row AI summary buttons inside Status column.')">AI Summary</button>
                                <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Use Export to Excel in top actions.')">Export View</button>
                            </div>
                        </section>
                    </aside>
                    </div>

                    <!-- CMF PENDING LIST HEADER PANEL - INSIDE mainDataWrapper -->
                    <div class="pending-tab-shell" id="pendingTabShell" style="display:none;">
                        <div class="pending-tab-main">
                            <div class="cmf-pending-page-hd">
                                <div>
                                    <h1 class="cmf-pending-page-title">CMF Pending</h1>

                                    <p class="cmf-pending-page-desc">
                                        Review pending requests, supporting evidence, customer impact, and qualification signals.
                                    </p>
                                </div>
                            </div>

                            <asp:Panel ID="cmf_pending_header_panel" runat="server" Visible="false"></asp:Panel>

                            <div style="display:none;" aria-hidden="true">
                                <asp:Label ID="lblPendingSightings" runat="server" Text="0" />
                                <asp:Label ID="lblQualifyForCmf" runat="server" Text="0" />
                                <asp:Label ID="lblLikelyDuplicate" runat="server" Text="0" />
                                <asp:Label ID="lblIncompleteSysScope" runat="server" Text="0" />
                            </div>

                            <!-- CMF PENDING LIST GRIDVIEW - INSIDE mainDataWrapper -->
                            <div class="gridview-container cmf-pending-grid-wrap" id="cmfPendingGridContainer" runat="server">
                                <asp:GridView ID="GridView_cmf_pending" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Issue Details" ItemStyle-Width="245px" HeaderStyle-Width="245px">
                                            <ItemTemplate><%# RenderPendingIssueDetailsWithRecommendation(Eval("cp_id"), Eval("title"), Eval("cmf_request"), Eval("component"), Eval("impact"), Eval("idst"), Eval("repro_on_rvp"), Eval("reproducibility"), Eval("customer_detail"), Eval("customer_owner")) %></ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Customer / Owner" ItemStyle-Width="160px" HeaderStyle-Width="160px">
                                            <ItemTemplate><%# RenderPendingCustomer(Eval("customer_detail"), Eval("customer_owner")) %></ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Component" ItemStyle-Width="150px" HeaderStyle-Width="150px">
                                            <ItemTemplate><%# RenderComponentWithGroupBadge(Eval("component"), Eval("component_group")) %></ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Evidence" ItemStyle-Width="190px" HeaderStyle-Width="190px">
                                            <ItemTemplate><%# RenderPendingEvidence(Eval("idst"), Eval("repro_on_rvp"), Eval("reproducibility")) %></ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Impact" ItemStyle-Width="210px" HeaderStyle-Width="210px">
                                            <ItemTemplate><%# RenderPendingAskImpact(Eval("date_cmf_ask"), Eval("cmf_request"), Eval("impact")) %></ItemTemplate>
                                        </asp:TemplateField>

                                    </Columns> 
                                </asp:GridView>
                            </div>
                        </div>
                        
                        <aside class="pending-side-panel" aria-label="CMF pending assistant panel">
                            <section class="interactive-side-card">
                                <div class="interactive-side-head">
                                    <h3 class="interactive-side-title"><i class="fas fa-brain" aria-hidden="true" style="color:#7c3aed; margin-right:6px;"></i>Pending AI Queue</h3>
                                </div>
                                <p class="interactive-side-sub">Recommendation engine snapshots for current platform selection.</p>
                                <button type="button" class="interactive-side-btn" onclick="showPortalToast('Use the Recommendation button on each pending row.')">Open Recommendation Flow</button>
                            </section>

                            <section class="interactive-side-card">
                                <div class="interactive-side-head"><h3 class="interactive-side-title">Quick Insights</h3></div>
                                <ul class="interactive-chip-list">
                                    <li><span>Qualification candidates</span><span class="interactive-chip" id="pendingSideQualify">0</span></li>
                                    <li><span>Potential duplicates</span><span class="interactive-chip" id="pendingSideDup">0</span></li>
                                    <li><span>Missing debug evidence</span><span class="interactive-chip" id="pendingSideMissing">0</span></li>
                                </ul>
                            </section>

                            <section class="interactive-side-card">
                                <div class="interactive-side-head"><h3 class="interactive-side-title">Shortcuts</h3></div>
                                <div class="interactive-shortcuts">
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Start with rows that have strongest recommendation confidence.')">Top Priority First</button>
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Use shared platform dropdown above to switch context.')">Switch Platform</button>
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Open row recommendation and review quality score details.')">Review Scores</button>
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Use Export to Excel for pending backlog sync.')">Export Pending</button>
                                </div>
                            </section>

                            <section class="interactive-side-card">
                                <div class="interactive-side-head"><h3 class="interactive-side-title">Actions</h3></div>
                                <div class="interactive-shortcuts">
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Review rows with high quality score first.')">Prioritize High Score</button>
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Use row controls to approve and commit details.')">Commit Auto-fill</button>
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Use Export to Excel for backlog sharing.')">Export Backlog</button>
                                    <button type="button" class="interactive-shortcut-btn" onclick="showPortalToast('Switch platform in the shared filter bar.')">Switch Platform</button>
                                </div>
                            </section>
                        </aside>
                    </div>

                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</div>

                 

                                    <div class="gridview-container">
                                        <asp:GridView ID="GridView_design_open" CssClass="table-primary2" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false" OnRowEditing="GridView_design_open_RowEditing" OnRowDataBound="GridView_design_open_RowDataBound" DataKeyNames="Design">
                                        </asp:GridView>
                                    </div>

                                    <div class="gridview-container">
                                        <asp:GridView ID="GridView2_edit" CssClass="table-primary2" runat="server" AutoGenerateColumns="false" EmptyDataText="No Open CMFs" Visible="false" OnRowUpdating="GridView_design_open_RowUpdating" OnRowCancelingEdit="GridView_design_open_RowCancelingEdit" OnRowDataBound="GridView_design_open_RowDataBound" DataKeyNames="Design">
                                            <Columns>
                                                <asp:BoundField DataField="Design" HeaderText="Design Name" ReadOnly="True" />

                                                <asp:TemplateField HeaderText="SW Image Freeze">
                                                    <ItemTemplate>
                                                        <span><%# Eval("SWImageFreeze") %></span>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="txtSWImageFreeze" runat="server" TextMode="MultiLine" Text='<%# Bind("SWImageFreeze") %>' CssClass="form-control"></asp:TextBox>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Support Model">
                                                    <ItemTemplate>
                                                        <span><%# Eval("SupportModel") %></span>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="txtSupportModel" runat="server" TextMode="MultiLine" Text='<%# Bind("SupportModel") %>' CssClass="form-control"></asp:TextBox>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:CommandField ShowEditButton="True" />
                                            </Columns>
                                        </asp:GridView>
                                    </div>

                                    <asp:Panel ID="panelExtraGridViews" runat="server" Visible="false">
                                    <div class="gridview-container">
                                        <asp:GridView ID="GridView_design_summary" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false" OnRowDataBound="GridView5_RowDataBound">
                                            <Columns>
                                                
                                                <asp:BoundField DataField="Design" HeaderText="Design" />
                                                <asp:BoundField DataField="SWImageFreeze" HeaderText="SW Image Freeze" />
                                                <asp:BoundField DataField="Issues_in_CMF_ASK" HeaderText="Issues in CMF_ASK" />
                                                <asp:BoundField DataField="Total_CMF_REJECT" HeaderText="Total CMF_REJECT" />
                                                <asp:BoundField DataField="Total_CMF_Approved" HeaderText="Total CMF_Approved" />
                                               <asp:BoundField DataField="crit_tpt" HeaderText="CMF Overall TPT"  />
                                                <asp:BoundField DataField="disp_tpt" HeaderText="CMF Disposition TPT"  />
                                                <asp:BoundField DataField="resolve_tpt" HeaderText="CMF Resolution TPT"  />

                                                <asp:BoundField DataField="CMFOpenPercentage" HeaderText="CMF Open %"  />
                                                <asp:BoundField DataField="Noise" HeaderText="Noise%"  />
                                                <asp:BoundField DataField="IntelIssuePercentage" HeaderText="Intel Issue %"/>  
                                                <asp:BoundField DataField="ThirdPartyPercentage" HeaderText="3rd Party %" />
                                                <asp:BoundField DataField="CustomerIssuePercentage" HeaderText="Customer Issue %" />
                                                
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                        
                                    
                                <div class="gridview-container">
    <asp:GridView ID="GridView_oem_summary" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false" OnRowDataBound="GridView7_RowDataBound">
        <Columns>
            <asp:BoundField DataField="OEM" HeaderText="OEM" />
            <asp:BoundField DataField="Issues_in_CMF_ASK" HeaderText="Issues in CMF_ASK" />
            <asp:BoundField DataField="Total_CMF_REJECT" HeaderText="Total CMF_REJECT" />
            <asp:BoundField DataField="Total_CMF_Approved" HeaderText="Total CMF_Approved" />
            <asp:BoundField DataField="crit_tpt" HeaderText="CMF Overall TPT" />
            <asp:BoundField DataField="disp_tpt" HeaderText="CMF Disposition TPT" />
            <asp:BoundField DataField="resolve_tpt" HeaderText="CMF Resolution TPT" />
            <asp:BoundField DataField="CMFOpenPercentage" HeaderText="CMF Open %" />
            <asp:BoundField DataField="Noise" HeaderText="Noise%" />
            <asp:BoundField DataField="IntelIssuePercentage" HeaderText="Intel Issue %" />
            <asp:BoundField DataField="ThirdPartyPercentage" HeaderText="3rd Party %" />
            <asp:BoundField DataField="CustomerIssuePercentage" HeaderText="Customer Issue %" />
        </Columns>
    </asp:GridView>
</div>
                    </asp:Panel>
                <!-- Bootstrap Modal for OEM Summary -->
<div class="modal fade" id="detailsModal3" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog custom-modal-dialog" role="document"> <!-- Custom class for modal -->
    <div class="modal-content">
      <div class="modal-header">
        <div class="modal-title-container">
            <h5 class="modal-title">OEM Summary Details</h5>
            <asp:Button ID="btnExportOEMToExcel" runat="server" Text="Export to Excel" CssClass="modern-button1 export-btn" OnClientClick="exportToExcel3('<%= HiddenModalDesign.Value %>'); return false;" />
        </div>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body custom-modal-body" id="modalContent7">
        <div class="gridview-container">
          <asp:GridView ID="GridView_oem_summary_modal7" CssClass="table-primary custom-gridview" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true" >
            <Columns>
               <asp:HyperLinkField
                 DataTextField="cp_id"
                 HeaderText="Sighting ID"
                 DataNavigateUrlFields="cp_id"
                 DataNavigateUrlFormatString="https://hsdes.intel.com/appstore/article/#/{0}"
                 Target="_blank" />
              <asp:BoundField DataField="title" HeaderText="title" />
              <asp:BoundField DataField="status" HeaderText="status" />
              <asp:BoundField DataField="component" HeaderText="component" />
              <asp:BoundField DataField="cmf_request" HeaderText="cmf_request" />
              <asp:BoundField DataField="customer_owner" HeaderText="customer_owner" />
              <asp:BoundField DataField="customer_company" HeaderText="customer_company" />
              <asp:BoundField DataField="promoted_id" HeaderText="promoted_id" />
              <asp:BoundField DataField="closed_reason" HeaderText="closed_reason" />
              <asp:BoundField DataField="days_active" HeaderText="days_active" />
              <asp:BoundField DataField="idst" HeaderText="idst" />
              <asp:BoundField DataField="drivers" HeaderText="Milestones" />
            </Columns>
          </asp:GridView>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- Bootstrap Modal -->
<div class="modal fade" id="detailsModal0" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog custom-modal-dialog" role="document"> <!-- Custom class for modal -->
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Issue List</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span>&times;</span>
        </button>
      </div>
      <div class="modal-body custom-modal-body" id="modalContent0">
        <div class="gridview-container">
          <asp:GridView ID="GridView_design_summary_modal0" CssClass="table-primary custom-gridview" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true" OnRowDataBound="GridViewdesign_RowDataBound">
            <Columns>
               <asp:HyperLinkField
     DataTextField="cp_id"
     HeaderText="Sighting ID"
     DataNavigateUrlFields="cp_id"
     DataNavigateUrlFormatString="https://hsdes.intel.com/appstore/article/#/{0}"
     Target="_blank" />
              <asp:BoundField DataField="title" HeaderText="title" />
              <asp:BoundField DataField="status" HeaderText="status" />
              <asp:BoundField DataField="component" HeaderText="component" />
              <asp:BoundField DataField="cmf_request" HeaderText="cmf_request" />
              <asp:BoundField DataField="customer_owner" HeaderText="customer_owner" />
              <asp:BoundField DataField="promoted_id" HeaderText="promoted_id" />
              <asp:BoundField DataField="closed_reason" HeaderText="closed_reason" />
              <asp:BoundField DataField="days_active" HeaderText="days_active" />
              <asp:BoundField DataField="idst" HeaderText="idst" />
              <asp:BoundField DataField="drivers" HeaderText="Milestones" />
            </Columns>
          </asp:GridView>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Bootstrap Modal -->
<div class="modal fade" id="detailsModal" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog custom-modal-dialog" role="document"> <!-- Custom class for modal -->
    <div class="modal-content">
      <div class="modal-header">
        <div class="modal-title-container">
            <h5 class="modal-title">Issue List</h5>
            <asp:Button ID="btnExportDesignToExcel" runat="server" Text="Export to Excel" CssClass="modern-button1 export-btn" OnClientClick="exportToExcel('<%= HiddenModalDesign.Value %>'); return false;" />
        </div>        
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body custom-modal-body" id="modalContent">
        <div class="gridview-container">
          <asp:GridView ID="GridView_design_summary_modal" CssClass="table-primary custom-gridview" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true">
            <Columns>
                         <asp:HyperLinkField
DataTextField="cp_id"
HeaderText="Sighting ID"
DataNavigateUrlFields="cp_id"
DataNavigateUrlFormatString="https://hsdes.intel.com/appstore/article/#/{0}"
Target="_blank" />

              <asp:BoundField DataField="title" HeaderText="title" />
              <asp:BoundField DataField="status" HeaderText="status" />
              <asp:BoundField DataField="component" HeaderText="component" />
              <asp:BoundField DataField="cmf_request" HeaderText="cmf_request" />
              <asp:BoundField DataField="customer_owner" HeaderText="customer_owner" />
              <asp:BoundField DataField="promoted_id" HeaderText="promoted_id" />
              <asp:BoundField DataField="closed_reason" HeaderText="closed_reason" />
              <asp:BoundField DataField="days_active" HeaderText="days_active" />
              <asp:BoundField DataField="idst" HeaderText="idst" />
              <asp:BoundField DataField="drivers" HeaderText="Milestones" />
            </Columns>
          </asp:GridView>
        </div>
      </div>
    </div>
  </div>
</div>


                                    <div class="gridview-container">
                                            <div class="button-wrapper">
 <asp:Button ID="btnImportPopup" runat="server" Text="Import Excel" CssClass="modern-button2" OnClientClick="openPopup(); return false;" />
</div>
                                        <asp:GridView ID="GridView_component_summary" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false" OnRowDataBound="GridView6_RowDataBound">
                                            <Columns>

                                                <asp:BoundField DataField="Component" HeaderText="Ingredient" />
                                                <asp:BoundField DataField="Total_CMF_Approved" HeaderText="Total CMF_Approved" />
                                                <asp:BoundField DataField="Total_CMF_REJECT" HeaderText="Total CMF_REJECT" />
                                                <asp:BoundField DataField="Issues_in_CMF_ASK" HeaderText="Issues in CMF_ASK" />
                                                <asp:BoundField DataField="CMFOpenPercentage" HeaderText="CMF Open %" />
                                                <asp:BoundField DataField="disp_tpt" HeaderText="CMF disposition TPT" />
                                                <asp:BoundField DataField="crit_tpt" HeaderText="CMF Overall TPT" />
                                                                                                
                                                <asp:BoundField DataField="resolve_tpt" HeaderText="CMF Resolution TPT"  />

                                                <asp:BoundField DataField="Noise" HeaderText="Noise%" />
                                                <asp:BoundField DataField="IntelIssuePercentage" HeaderText="Intel Issue %" />       
                                                <asp:BoundField DataField="ThirdPartyPercentage" HeaderText="3rd Party %" />
                                                <asp:BoundField DataField="CustomerIssuePercentage" HeaderText="Customer Issue %" />                  
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </div>

<div class="modal fade" id="detailsModalDrivers" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog custom-modal-dialog" role="document">
    <div class="modal-content">

      <div class="modal-header">
        <div class="modal-title-container">
          <h5 class="modal-title">Issue List (by Milestone) — <asp:Label ID="lblDriverName" runat="server" /></h5>
          <asp:Button ID="btnExportDriverIssues" runat="server"
                      Text="Export to Excel"
                      CssClass="modern-button1 export-btn"
                      OnClientClick="exportDriverIssues('<%= HiddenDriverName.Value %>'); return false;" />
        </div>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <div class="modal-body custom-modal-body">
        <div class="gridview-container">
          <asp:GridView ID="GridView_driver_issues"
                        runat="server"
                        CssClass="table-primary custom-gridview"
                        AutoGenerateColumns="False"
                        EmptyDataText="No issues for this driver">
            <Columns>
            
              <asp:HyperLinkField DataTextField="cp_id"
                                  HeaderText="Sighting ID"
                                  DataNavigateUrlFields="cp_id"
                                  DataNavigateUrlFormatString="https://hsdes.intel.com/appstore/article/#/{0}"
                                  Target="_blank" />
                
              <asp:BoundField DataField="title" HeaderText="Title" />
              <asp:BoundField DataField="component" HeaderText="Component" />
              <%-- Add more columns if you want, e.g. status/component --%>
            </Columns>
          </asp:GridView>
        </div>
      </div>

    </div>
  </div>
</div>

        <div class="modal fade" id="detailsModalDrivers1" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog custom-modal-dialog" role="document">
    <div class="modal-content">

      <div class="modal-header">
        <div class="modal-title-container">
          <h5 class="modal-title">Issue List (by Milestone) — <asp:Label ID="lblDriverName1" runat="server" /></h5>
        <asp:Button ID="btnExportDriverIssues1" runat="server"
            Text="Export to Excel"
            CssClass="modern-button1 export-btn"
            OnClientClick="exportCMFIssues(getComponentValue(), getDriverValue(), getIssueTypeValue()); return false;" />

        </div>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <div class="modal-body custom-modal-body">
        <div class="gridview-container">
          <asp:GridView ID="GridView_cmf_issues"
                        runat="server"
                        CssClass="table-primary custom-gridview"
                        AutoGenerateColumns="False"
                        EmptyDataText="No issues for this driver">
            <Columns>
            
              <asp:HyperLinkField DataTextField="cp_id"
                                  HeaderText="Sighting ID"
                                  DataNavigateUrlFields="cp_id"
                                  DataNavigateUrlFormatString="https://hsdes.intel.com/appstore/article/#/{0}"
                                  Target="_blank" />
                
              <asp:BoundField DataField="title" HeaderText="Title" />
              <asp:BoundField DataField="component" HeaderText="Component" />
                <asp:BoundField DataField="cmf_request" HeaderText="CMF Request" />
             <asp:BoundField DataField="los" HeaderText="LOS" />
              <%-- Add more columns if you want, e.g. status/component --%>
            </Columns>
          </asp:GridView>
        </div>
      </div>

    </div>
  </div>
</div>

<!-- Bootstrap Modal -->
<div class="modal fade" id="detailsModal2" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog custom-modal-dialog" role="document"> <!-- Custom class for modal -->
    <div class="modal-content">
      <div class="modal-header">
        <div class="modal-title-container">
          <h5 class="modal-title">Issue List</h5>
          <asp:Button ID="btnExportIngredientToExcel" runat="server" Text="Export to Excel" CssClass="modern-button1 export-btn" OnClientClick="exportToExcel2('<%= HiddenModalDesign.Value %>'); return false;" />
        </div>        
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body custom-modal-body" id="modalContent2">
        <div class="gridview-container">
          <asp:GridView ID="GridView_component_summary_modal" CssClass="table-primary custom-gridview" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true">
            <Columns>
                        <asp:HyperLinkField
DataTextField="cp_id"
HeaderText="Sighting ID"
DataNavigateUrlFields="cp_id"
DataNavigateUrlFormatString="https://hsdes.intel.com/appstore/article/#/{0}"
Target="_blank" />
              <asp:BoundField DataField="title" HeaderText="title" />
              <asp:BoundField DataField="status" HeaderText="status" />
              <asp:BoundField DataField="component" HeaderText="component" />
              <asp:BoundField DataField="cmf_request" HeaderText="cmf_request" />
              <asp:BoundField DataField="customer_owner" HeaderText="customer_owner" />
              <asp:BoundField DataField="promoted_id" HeaderText="promoted_id" />
              <asp:BoundField DataField="closed_reason" HeaderText="closed_reason" />
              <asp:BoundField DataField="days_active" HeaderText="days_active" />
              <asp:BoundField DataField="idst" HeaderText="idst" />
              <asp:BoundField DataField="drivers" HeaderText="Milestones" />
            </Columns>
          </asp:GridView>
        </div>
      </div>
    </div>
  </div>
</div>




                                <%--<!-- Display Metrics -->
                                    <div class="gridview-container3">
                                        <asp:GridView ID="GridView_cmf_summary1" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Total">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblTotal" runat="server" Text='<%# Eval("Total") %>'></asp:Label><br />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Closed">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblClosed" runat="server" Text='<%# Eval("Closed") %>'></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Implemented">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblImplementedCount" runat="server" Text='<%# Eval("ImplementedCount") %>'></asp:Label><br />
                                                        <asp:Label ID="lblImplementedDetails" runat="server" Text='<%# Eval("ImplementedDetails") %>'></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>


                                        </asp:GridView>
                                    </div>
                                    <div class="gridview-container3">
                                        <asp:GridView ID="GridView_cmf_summary" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true" DataKeyNames="Component">
                                            <Columns>
                                                <asp:BoundField DataField="Component" HeaderText="Component" SortExpression="Component" />
                                                <asp:BoundField DataField="Driver_issues" HeaderText="Driver_issues" SortExpression="Driver_issues" ReadOnly="True" />

                                            </Columns>
                                        </asp:GridView>--%>

                                    <!-- Display Metrics -->
                                    <div class="gridview-container-wrapper">
                                        <div class="gridview-container3">
                                            <asp:GridView ID="GridView_cmf_summary1" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true">
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Total">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblTotal" runat="server" Text='<%# Eval("Total") %>'></asp:Label><br />
                                                        </ItemTemplate>
                                                        <ItemStyle Width="33%" />
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Closed">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblClosed" runat="server" Text='<%# Eval("Closed") %>'></asp:Label>
                                                        </ItemTemplate>
                                                        <ItemStyle Width="33%" />
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Implemented">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblImplementedCountAndDup" runat="server" Text='<%# Eval("ImplementedCountAndDup") %>'></asp:Label><br />
                                                            <asp:Label ID="lblImplementedComponents" runat="server" Text='<%# Eval("ImplementedComponentsOnly") %>'></asp:Label>
                                                        </ItemTemplate>
                                                        <ItemStyle Width="33%" />
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>

                                            <asp:GridView ID="GridView_notes" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true" OnRowDataBound="GridView_notes_RowDataBound">
                                                <Columns>
                                                  
                                                    <asp:BoundField DataField="disp_tpt" HeaderText="CMF Disposition TPT" ReadOnly="True" ItemStyle-Width="33%" />
                                                    <asp:BoundField DataField="resolve_tpt" HeaderText="CMF Resolution TPT" ReadOnly="True" ItemStyle-Width="33%" />
                                                    <asp:BoundField DataField="crit_tpt" HeaderText="CMF Overall TPT" ReadOnly="True" ItemStyle-Width="33%" />
                                                </Columns>
                                            </asp:GridView>

                                                                                        

                                          
                                            <!-- Milestone Mapping: Drivers and CMF counts -->
                                            
                                            <asp:GridView ID="GridView_milestone_map"
              runat="server"
              AutoGenerateColumns="False"
              CssClass="table-primary"
              EmptyDataText="No CMF data for milestones"
              Visible="true">
    <Columns>

        <asp:BoundField DataField="Driver" HeaderText="Milestone" ReadOnly="True" ItemStyle-Width="50%" />

       <asp:TemplateField HeaderText="Unique CMF Count">
          <ItemTemplate>
            <a href="javascript:void(0)"
               onclick='showDriverIssues("<%# HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("Driver") ?? "")) %>"); return false;'
               style="font-weight: bold; text-decoration: none;"
               class="btn btn-link p-0">
              <%# Eval("CMFCount") %>
            </a>
          </ItemTemplate>
          <ItemStyle Width="50%" />
        </asp:TemplateField>
        
    </Columns>
</asp:GridView>

                                        </div>






                                        <div class="gridview-container3">
                                            <asp:GridView ID="GridView_cmf_summary" CssClass="table-primary7" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="true" DataKeyNames="Component">
                                                <Columns>
                                                    <asp:BoundField DataField="Component" HeaderText="Component_Open_CMFs" SortExpression="Component" ReadOnly="True" ItemStyle-Width="25%"/>
                                                    <asp:BoundField DataField="Driver_issues" HeaderText="Driver_issues" SortExpression="Driver_issues" ReadOnly="True" ItemStyle-Width="25%"/>
                                                </Columns>
                                            </asp:GridView>

                                                                                        <asp:GridView ID="GridView_comp" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No CMFs Pending" Visible="true">
    <Columns>
      
        <asp:BoundField DataField="component_group" HeaderText="Component" ReadOnly="True" ItemStyle-Width="50%" />
        <asp:BoundField DataField="CMF Pending Count" HeaderText="CMF Pending Count" ReadOnly="True" ItemStyle-Width="50%" />
    </Columns>
</asp:GridView>

                                                                                                                                    <div class="tptdefinitions" id="tptdefdiv" runat="server"> 
                                                  <p><strong>CMF resolution TPT:</strong> CMF decided date - Implemented date</p>
                                                  <p><strong>CMF disposition TPT:</strong> CMF decided date - CMF ask date</p>
                                                </div>
                                           
                                        </div>
                                                                                                   
                                    </div>


                                                                                                                                

                                </div>


                   

                                </div>
                                                                                                                                                              
                            
                            </ContentTemplate>
                        </asp:UpdatePanel>

                    </div>

                </div>
                    </div>
                </div>
            </form>

        </div>
                                                                                                                                                                 
    </div>
   

</body>
</html>

