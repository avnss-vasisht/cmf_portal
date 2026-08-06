<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CMF_Web_portal.aspx.cs" Inherits="CMF_Web_portal" EnableEventValidation="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>CMF Web Portal</title>

    <!-- Stylesheets -->
    <link rel="stylesheet" href="template/vendors/feather/feather.css">
    <link rel="stylesheet" href="template/vendors/ti-icons/css/themify-icons.css">
    <link rel="stylesheet" href="template/vendors/css/vendor.bundle.base.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/all.min.css" type="text/css" />
    <link rel="stylesheet" href="template/css/style.css">
    <link rel="stylesheet" href="Content/cmf-portal.css">
    <!-- Updated CSS link -->

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>

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
            width: 0;
            flex: 0 0 0;
            min-height: 0;
            padding: 0;
            opacity: 0;
            box-shadow: none;
            border: none;
            pointer-events: none;
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
            background: rgba(255, 255, 255, 0.18);
            color: #ffffff;
            border-color: rgba(147, 197, 253, 0.62);
            box-shadow: inset 3px 0 0 #58a6ff, 0 8px 18px rgba(8, 47, 118, 0.22);
        }

        .portal-left-nav .portal-nav-link.is-active:before {
            transform: scaleY(1);
        }

        .portal-current-view {
            margin: 0 0 10px;
            padding: 10px 14px;
            border-radius: 8px;
            background: #f7fbff;
            border: 1px solid #d7e8fa;
            box-shadow: 0 1px 4px rgba(15, 94, 168, 0.08);
        }

        .portal-current-view-label {
            display: block;
            color: #64748b;
            font-size: 9px;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            margin-bottom: 3px;
        }

        .portal-current-view-title {
            display: block;
            color: #102a43;
            font-size: 18px;
            font-weight: 800;
            line-height: 1.25;
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

                .status-pill {
                    display: inline-block;
                    padding: 6px 10px;
                    border-radius: 999px;
                    font-size: 12px;
                    font-weight: 700;
                    background: #eef4fb;
                    color: #0f5ea8;
                    border: 1px solid #cfe0f1;
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
    background: #f7fafd;
    border: 1px solid #d8e3ee;
    border-radius: 10px;
    padding: 12px;
    white-space: pre-wrap;
    line-height: 1.45;
    font-size: 13px;
    color: #21384d;
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
    background: rgba(16, 31, 52, 0.35);
    display: none;
    z-index: 1060;
}

.ai-summary-drawer-bg.show {
    display: block;
}

.ai-summary-drawer {
    position: fixed;
    top: 0;
    right: 0;
    width: 520px;
    max-width: 94vw;
    height: 100%;
    background: #ffffff;
    box-shadow: -8px 0 30px rgba(0, 0, 0, 0.15);
    transform: translateX(100%);
    transition: transform 0.28s ease;
    z-index: 1061;
    overflow-y: auto;
    padding: 20px;
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
    font-size: 20px;
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
    padding: 9px 16px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    border: 1px solid #d1d9e3;
    background: #f4f6fa;
    color: #23364b;
    transition: background 0.15s, border-color 0.15s;
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
        padding-top: 2px;
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
        display: flex;
        justify-content: center;
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
        position: absolute;
        right: 10px;
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
        window.CMF_PORTAL.currentPlatform = '<%= ResolvePlatformTable(Session["selectedPlatform"] as string ?? ddlTables.SelectedValue) %>';

        window.CMF_PORTAL.defaults = {
            componentName: '',
            issueType: 'Open',
            driverName: ''
        };

        window.CMF_PORTAL.driversJson = <%= DriversJson %>;
        window.CMF_PORTAL.isInitialLoad = <%= IsPostBack ? "false" : "true" %>;

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
            var text = summary || '';
            var confidence = '';
            var confidenceMatch = text.match(/\*\*\s*AI\s+summary\s*\(\s*Confidence\s*:\s*([0-9]{1,3}%?)\s*\)\s*\*\*/i)
                || text.match(/AI\s+summary\s*\(\s*Confidence\s*:\s*([0-9]{1,3}%?)\s*\)/i);

            if (confidenceMatch && confidenceMatch[1]) {
                confidence = confidenceMatch[1];
                if (confidence.indexOf('%') < 0) confidence += '%';
            }

            text = text.replace(/^\s*\*\*\s*AI\s+summary\s*\(\s*Confidence\s*:\s*[0-9]{1,3}%?\s*\)\s*\*\*\s*$/im, '');
            text = text.replace(/^\s*AI\s+summary\s*\(\s*Confidence\s*:\s*[0-9]{1,3}%?\s*\)\s*$/im, '');
            text = text.replace(/^\s*Sighting\s+ID\s*:\s*.*?CMF\s+Ask\s+date\s*:\s*.*$/im, '');
            text = text.replace(/\n{3,}/g, '\n\n').trim();

            return { confidence: confidence, body: text || summary || '' };
        }

        function openAiSummaryModal(issueId, title, submittedDate, status, sysdebug) {
            var issueIdNode = document.getElementById('aiSummaryIssueId');
            var titleNode = document.getElementById('aiSummaryTitle');
            var titleRow = document.getElementById('aiSummaryTitleRow');
            var dateNode = document.getElementById('aiSummarySubmittedDate');
            var bodyNode = document.getElementById('aiSummaryBody');
            var actionsNode = document.getElementById('aiSummaryActions');
            var confidenceNode = document.getElementById('aiSummaryConfidence');
            var drawerBg = document.getElementById('aiSummaryDrawerBg');
            var drawer = document.getElementById('aiSummaryDrawer');

            if (!issueIdNode || !titleNode || !dateNode || !bodyNode || !drawerBg || !drawer) {
                return;
            }

            issueIdNode.textContent = issueId || 'N/A';
            if (titleNode) titleNode.textContent = '';
            if (titleRow) titleRow.style.display = 'none';
            dateNode.textContent = submittedDate || 'N/A';
            if (confidenceNode) confidenceNode.textContent = 'Confidence: --';
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
                var confidenceNode = document.getElementById('aiSummaryConfidence');
                if (confidenceNode && preparedSummary.confidence) {
                    confidenceNode.textContent = 'Confidence: ' + preparedSummary.confidence;
                }
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
            var qualityNode = document.getElementById('cmfRecQualityScore');
            var nextStepsNode = document.getElementById('cmfRecNextSteps');
            var scoresBodyNode = document.getElementById('cmfRecRuleScoresBody');
            
            if (recNode) recNode.textContent = 'Generating AI recommendation...';
            if (qualityNode) qualityNode.textContent = '-';
            if (evidenceNode) evidenceNode.textContent = '-';
            if (nextStepsNode) nextStepsNode.textContent = '-';
            if (scoresBodyNode) scoresBodyNode.innerHTML = '<div style="padding: 12px; text-align: center; color: #6b7280;">Loading...</div>';

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
                    recNode.textContent = result.Recommendation || 'No recommendation content returned.';
                }

                if (qualityNode) {
                    var thresholdScore = typeof result.ThresholdScore === 'number' ? result.ThresholdScore : 70;
                    var scoreValue = typeof result.OverallQualityScore === 'number' ? result.OverallQualityScore : null;
                    qualityNode.innerHTML = scoreValue !== null
                        ? '<div class="cmf-rec-quality-line"><span>Quality Score</span><strong>' + scoreValue + '/100</strong></div><div class="cmf-rec-quality-line"><span>Threshold Score</span><strong>' + thresholdScore + '/100</strong></div>'
                        : '-';
                }
                
                // Display AI reasoning
                if (evidenceNode) {
                    var reasoningText = result.Evidence || 'No AI reasoning provided.';
                    evidenceNode.textContent = reasoningText;
                }

                if (nextStepsNode) {
                    nextStepsNode.textContent = result.NextSteps || 'No next steps available.';
                }
                
                // Display rule scores
                if (scoresBodyNode && result.RuleScores && result.RuleScores.length > 0) {
                    var cards = '';
                    for (var i = 0; i < result.RuleScores.length; i++) {
                        var rule = result.RuleScores[i];
                        var scoreText = rule.Score || '-';
                        var evaluationText = rule.Evaluation || '-';
                        var evaluationUpper = evaluationText.toUpperCase();
                        var stateClass = 'partial';
                        var stateIcon = '!';
                        if (evaluationUpper.indexOf('PASS') === 0) {
                            stateClass = 'pass';
                            stateIcon = '&#10003;';
                        } else if (evaluationUpper.indexOf('FAIL') === 0) {
                            stateClass = 'fail';
                            stateIcon = '&times;';
                        } else if (evaluationUpper.indexOf('PARTIAL') === 0) {
                            stateClass = 'partial';
                            stateIcon = '!';
                        }
                        cards += '<div class="cmf-rec-score-item">';
                        cards += '<span class="cmf-rec-score-icon ' + stateClass + '">' + stateIcon + '</span>';
                        cards += '<div><div class="cmf-rec-score-title">' + escapeHtml((rule.RuleId || '-') + ' - ' + (rule.RuleName || '-')) + '</div>';
                        cards += '<div class="cmf-rec-score-detail">' + escapeHtml(evaluationText) + '</div></div>';
                        cards += '<div class="cmf-rec-score-value">' + escapeHtml(scoreText) + '/100</div>';
                        cards += '</div>';
                    }
                    scoresBodyNode.innerHTML = cards;
                } else if (scoresBodyNode) {
                    scoresBodyNode.innerHTML = '<div style="padding: 12px; text-align: center; color: #6b7280;">No rule scores available.</div>';
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
                    storageKey: 'cmf.collapsible.issueFilters'
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
                    label.textContent = sectionName === 'mainMenu' ? '<<' : (collapsed ? 'Show' : 'Hide');
                }
                if (sectionName === 'mainMenu') {
                    button.title = collapsed ? 'Menu collapsed' : 'Collapse menu';
                    button.setAttribute('aria-label', collapsed ? 'Menu collapsed' : 'Collapse menu');
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
                var initialCollapsed = false;
                try {
                    initialCollapsed = localStorage.getItem(cfg.storageKey) === '1';
                } catch (ignore) {
                }
                setCollapsibleSection(sectionName, initialCollapsed, false);
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

            if (!window.CMF_PORTAL.homeTrendChart) {
                window.CMF_PORTAL.homeTrendChart = echarts.init(trendHost);
            }

            if (!window.CMF_PORTAL.homeStatusChart) {
                window.CMF_PORTAL.homeStatusChart = echarts.init(statusHost);
            }

            var trend = snapshot.Trend || [];
            window.CMF_PORTAL.homeTrendChart.setOption({
                color: ['#0f5ea8', '#00a6b2', '#d97706'],
                tooltip: { trigger: 'axis' },
                legend: { bottom: 0, textStyle: { color: '#4e657b' } },
                grid: { left: 44, right: 16, top: 18, bottom: 48 },
                xAxis: {
                    type: 'category',
                    data: trend.map(function (item) { return item.WeekLabel; }),
                    axisLine: { lineStyle: { color: '#bfd0df' } },
                    axisLabel: { color: '#50687f' }
                },
                yAxis: {
                    type: 'value',
                    axisLine: { show: false },
                    splitLine: { lineStyle: { color: '#e4edf5' } },
                    axisLabel: { color: '#50687f' }
                },
                series: [
                    {
                        name: 'New Issues',
                        type: 'line',
                        smooth: true,
                        data: trend.map(function (item) { return item.NewIssues; }),
                        lineStyle: { width: 3 },
                        symbolSize: 8
                    },
                    {
                        name: 'Resolved',
                        type: 'line',
                        smooth: true,
                        data: trend.map(function (item) { return item.ResolvedIssues; }),
                        lineStyle: { width: 3 },
                        symbolSize: 8,
                        areaStyle: { color: 'rgba(0,166,178,0.10)' }
                    },
                    {
                        name: 'Needs Attention',
                        type: 'bar',
                        data: trend.map(function (item) { return item.NeedsAttention; }),
                        barMaxWidth: 24,
                        itemStyle: { borderRadius: [8, 8, 0, 0] }
                    }
                ]
            }, true);

            var statusDistribution = snapshot.StatusDistribution || [];
            window.CMF_PORTAL.homeStatusChart.setOption({
                tooltip: { trigger: 'item' },
                legend: { bottom: 0, textStyle: { color: '#4e657b', fontSize: 11 } },
                series: [{
                    type: 'pie',
                    radius: ['42%', '72%'],
                    center: ['50%', '42%'],
                    data: statusDistribution.map(function (item) {
                        return { name: item.Name, value: item.Value };
                    }),
                    label: { color: '#35516d' },
                    itemStyle: { borderColor: '#ffffff', borderWidth: 2 }
                }]
            }, true);

            listHost.innerHTML = '';
            var topComponents = snapshot.TopComponents || [];
            for (var index = 0; index < topComponents.length; index++) {
                var item = topComponents[index];
                var listItem = document.createElement('li');
                listItem.className = 'home-dashboard-list-item';

                var labelNode = document.createElement('span');
                labelNode.className = 'home-dashboard-list-label';
                labelNode.textContent = item.Name || 'Unassigned';

                var valueNode = document.createElement('span');
                valueNode.className = 'home-dashboard-list-value';
                valueNode.textContent = String(item.Value || 0);

                listItem.appendChild(labelNode);
                listItem.appendChild(valueNode);
                listHost.appendChild(listItem);
            }

            window.CMF_PORTAL.homeTrendChart.resize();
            window.CMF_PORTAL.homeStatusChart.resize();
        }

        document.addEventListener('DOMContentLoaded', function () {
            window.CMF_PORTAL.currentPlatform = getCurrentPlatformValue();
            window.CMF_PORTAL.homeDashboardSnapshot = <%= string.IsNullOrWhiteSpace(HomeDashboardSnapshotJson) ? "null" : HomeDashboardSnapshotJson %>;
            syncActivePlatformChip();
            setTimeout(function () { syncIssueHorizontalScroll(0); }, 60);
            bindReportsPromptEnterHandler();
            initReportsFormatTemplate();
            initCollapsibleSections();
            renderHomeDashboard();
        });

        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                window.CMF_PORTAL.currentPlatform = getCurrentPlatformValue();
                window.CMF_PORTAL.homeDashboardSnapshot = <%= string.IsNullOrWhiteSpace(HomeDashboardSnapshotJson) ? "null" : HomeDashboardSnapshotJson %>;
                syncActivePlatformChip();
                setTimeout(function () { syncIssueHorizontalScroll(0); }, 60);
                bindReportsPromptEnterHandler();
                initReportsFormatTemplate();
                initCollapsibleSections();
                renderHomeDashboard();
                setTimeout(initColumnHideButtons, 0);
            });
        }

        // ── Column hide buttons ──────────────────────────────────────────────
        var CMF_HIDDEN_COLS_KEY = 'cmf_hidden_cols';

        function initColumnHideButtons() {
            var grid = document.getElementById('<%= overall_request_details.ClientID %>');
            if (!grid) return;
            // Select every header cell that carries a field-* class, regardless of thead/tbody structure
            var headers = grid.querySelectorAll('th[class*="field-"]');
            if (!headers || headers.length === 0) return;
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

        if (window.Sys && Sys.Application) {
            Sys.Application.add_load(function () { initColumnHideButtons(); });
        }

        // Fallback: also hook standard DOM events for full-page postbacks
        document.addEventListener('DOMContentLoaded', function () { setTimeout(initColumnHideButtons, 100); });
        window.addEventListener('load', function () { setTimeout(initColumnHideButtons, 200); });

        // Polling guard: inject buttons whenever the grid is visible but has none yet
        setInterval(function () {
            var grid = document.getElementById('<%= overall_request_details.ClientID %>');
            if (!grid) return;
            var ths = grid.querySelectorAll('th[class*="field-"]');
            if (ths.length > 0 && grid.querySelectorAll('.col-hide-btn').length === 0) {
                initColumnHideButtons();
            }
        }, 600);
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



        <%--        <!-- Sidebar -->
        <div id="sidebar" class="sidebar">
            <button class="close-btn" onclick="closeSidebar()">X</button>
            <!-- Hardcoded 'All Drivers' link -->
    <div style="margin-left: 20px">
        <asp:LinkButton ID="lnkAllDrivers" runat="server" CommandArgument="AllDrivers" OnCommand="lnkValue_Command">
            All Drivers
        </asp:LinkButton><br />
    </div>
                       <!-- List of distinct values as checkboxes -->
    <div style="margin-left: 20px">
    <asp:Repeater ID="rptDistinctValues" runat="server">
        <ItemTemplate>
            <!-- Dynamically setting the ID and Value of the CheckBox -->
            <input type="checkbox" class="chkValue" 
                   id="chkValue_<%# Eval("drivers") %>" 
                   value='<%# Eval("drivers") %>' 
                   onclick="driverCollector()" />
            <label><%# Eval("drivers") %></label><br />
        </ItemTemplate>
    </asp:Repeater>
</div>--%>

        <!-- Sidebar -->
        <%--<div id="sidebar" class="sidebar">
            <button class="close-btn" onclick="closeSidebar()">X</button>
            <!-- Hardcoded 'All Drivers' link -->
            <div style="margin-left: 20px">
                <asp:LinkButton ID="lnkAllDrivers" runat="server" CommandArgument="AllDrivers" OnCommand="lnkValue_Command">
            All Milestones
                </asp:LinkButton><br />
            </div>

            <!-- Select All Checkbox -->
            <div id="selectallcheckbox" style="margin-left: 20px" runat="server">
                <input type="checkbox" id="chkSelectAll" onclick="driverCollector()"/>
                <label style="color: white; font-family: 'Arial', sans-serif;" for="chkSelectAll">Select All</label><br />
            </div>

            <!-- List of distinct values as checkboxes -->
            <div style="margin-left: 20px">
                <asp:Repeater ID="rptDistinctValues" runat="server">
                    <ItemTemplate>
                        <!-- Dynamically setting the ID and Value of the CheckBox -->
                        <input type="checkbox" class="chkValue"
                            id="chkValue_<%# Eval("drivers") %>"
                            value='<%# Eval("drivers") %>'
                            onclick="driverCollector()" />
                        <label style="color: white; font-family: 'Arial', sans-serif;"><%# Eval("drivers") %></label><br />
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <asp:LinkButton ID="submitdrivers" runat="server" CommandArgument="" OnCommand="lnkValue_Command">
    Submit
            </asp:LinkButton>
        </div>--%>

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
                        <div class="portal-current-view" aria-live="polite">
                            <span class="portal-current-view-label">Current View</span>
                            <asp:Label ID="lblActiveViewTitle" runat="server" CssClass="portal-current-view-title" Text="Issue List" />
                        </div>
                        <asp:Panel ID="homeWelcomePanel" runat="server" Visible="false" CssClass="welcome-home-panel">
                            <div class="home-dashboard-shell">
                                <div class="home-dashboard-hero">
                                    <div class="home-dashboard-hero-copy">
                                        <div class="home-dashboard-badge">Live Infographics</div>
                                        <h2 class="welcome-home-title" style="margin-bottom:12px;"><%: HomeDashboardPlatformLabel %></h2>
                                        <p class="welcome-home-desc">
                                            You are in <asp:Label ID="lblWelcomeMode" runat="server" /> mode. This dashboard reflects overall CMF issue signals across all platforms, including trend, status mix, and concentration by component group.
                                        </p>
                                    </div>
                                    <div class="home-dashboard-hero-actions">
                                        <asp:HyperLink ID="lnkPlatformDashboardHome" runat="server" Target="_blank" CssClass="home-dashboard-pill-link" Visible="false">Open platform dashboard</asp:HyperLink>
                                        <div class="home-dashboard-generated">Updated <asp:Label ID="lblHomeDashboardGeneratedAt" runat="server" /></div>
                                    </div>
                                </div>

                                <div class="home-dashboard-metrics">
                                    <div class="home-dashboard-metric-card">
                                        <div class="home-dashboard-metric-top"><div class="home-dashboard-metric-label">Active Issues</div><div class="home-dashboard-metric-icon"><i class="fas fa-triangle-exclamation" aria-hidden="true"></i></div></div>
                                        <div class="home-dashboard-metric-value"><asp:Label ID="lblHomeActiveIssuesValue" runat="server" /></div>
                                        <div class="home-dashboard-metric-note">Open workload across all platforms</div>
                                        <div class="home-dashboard-metric-spark" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>
                                    </div>
                                    <div class="home-dashboard-metric-card">
                                        <div class="home-dashboard-metric-top"><div class="home-dashboard-metric-label">Needs Attention</div><div class="home-dashboard-metric-icon"><i class="fas fa-bolt" aria-hidden="true"></i></div></div>
                                        <div class="home-dashboard-metric-value"><asp:Label ID="lblHomeNeedsAttentionValue" runat="server" /></div>
                                        <div class="home-dashboard-metric-note">High-priority or high-impact issues requiring fast review</div>
                                        <div class="home-dashboard-metric-spark" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>
                                    </div>
                                    <div class="home-dashboard-metric-card">
                                        <div class="home-dashboard-metric-top"><div class="home-dashboard-metric-label">Resolved This Week</div><div class="home-dashboard-metric-icon"><i class="fas fa-circle-check" aria-hidden="true"></i></div></div>
                                        <div class="home-dashboard-metric-value"><asp:Label ID="lblHomeResolvedThisWeekValue" runat="server" /></div>
                                        <div class="home-dashboard-metric-note">Issues with implemented resolution in the last 7 days</div>
                                        <div class="home-dashboard-metric-spark" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>
                                    </div>
                                    <div class="home-dashboard-metric-card">
                                        <div class="home-dashboard-metric-top"><div class="home-dashboard-metric-label">Avg. Resolution Days</div><div class="home-dashboard-metric-icon"><i class="fas fa-clock" aria-hidden="true"></i></div></div>
                                        <div class="home-dashboard-metric-value"><asp:Label ID="lblHomeResolutionDaysValue" runat="server" /></div>
                                        <div class="home-dashboard-metric-note">Average days from decision to implementation</div>
                                        <div class="home-dashboard-metric-spark" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>
                                    </div>
                                    <div class="home-dashboard-metric-card">
                                        <div class="home-dashboard-metric-top"><div class="home-dashboard-metric-label">Customers Affected</div><div class="home-dashboard-metric-icon"><i class="fas fa-users" aria-hidden="true"></i></div></div>
                                        <div class="home-dashboard-metric-value"><asp:Label ID="lblHomeCustomersAffectedValue" runat="server" /></div>
                                        <div class="home-dashboard-metric-note">Rows marked medium-to-critical customer impact</div>
                                        <div class="home-dashboard-metric-spark" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>
                                    </div>
                                </div>

                                <div class="home-ai-panels">
                                    <div class="home-ai-card">
                                        <div class="home-ai-card-head">
                                            <div>
                                                <h3 class="home-ai-card-title">AI Live Tracker</h3>
                                                <p class="home-ai-card-subtitle">Live AI triage signals across the dashboard data.</p>
                                            </div>
                                            <div class="home-ai-card-icon"><i class="fas fa-robot" aria-hidden="true"></i></div>
                                        </div>
                                        <div class="home-ai-tracker-grid">
                                            <div class="home-ai-tracker-item">
                                                <div class="home-ai-tracker-label">Watchlist</div>
                                                <div class="home-ai-tracker-value"><asp:Label ID="lblHomeAiWatchlistValue" runat="server" /></div>
                                            </div>
                                            <div class="home-ai-tracker-item">
                                                <div class="home-ai-tracker-label">New Today</div>
                                                <div class="home-ai-tracker-value"><asp:Label ID="lblHomeAiNewTodayValue" runat="server" /></div>
                                            </div>
                                            <div class="home-ai-tracker-item">
                                                <div class="home-ai-tracker-label">Closed Today</div>
                                                <div class="home-ai-tracker-value"><asp:Label ID="lblHomeAiClosedTodayValue" runat="server" /></div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="home-ai-card">
                                        <div class="home-ai-card-head">
                                            <div>
                                                <h3 class="home-ai-card-title">AI Daily Summary</h3>
                                                <p class="home-ai-card-subtitle">Summary of CMF activity detected for today.</p>
                                            </div>
                                            <div class="home-ai-card-icon"><i class="fas fa-wand-magic-sparkles" aria-hidden="true"></i></div>
                                        </div>
                                        <ul class="home-ai-summary-list">
                                            <asp:Literal ID="litHomeAiDailySummary" runat="server" />
                                        </ul>
                                    </div>
                                </div>

                                <div class="home-dashboard-grid">
                                    <div class="home-dashboard-panel">
                                        <div class="home-dashboard-panel-head">
                                            <div>
                                                <h3 class="home-dashboard-panel-title">Overall Issue Trend</h3>
                                                <p class="home-dashboard-panel-subtitle">Six-week trend for new issues, resolved issues, and high-attention items.</p>
                                            </div>
                                        </div>
                                        <div id="homeTrendChart" class="home-dashboard-chart"></div>
                                    </div>
                                    <div class="home-dashboard-side-stack">
                                        <div class="home-dashboard-panel">
                                            <div class="home-dashboard-panel-head">
                                                <div>
                                                    <h3 class="home-dashboard-panel-title">Status Mix</h3>
                                                    <p class="home-dashboard-panel-subtitle">Largest status buckets across all platforms.</p>
                                                </div>
                                            </div>
                                            <div id="homeStatusChart" class="home-dashboard-chart-compact"></div>
                                        </div>
                                        <div class="home-dashboard-panel">
                                            <div class="home-dashboard-panel-head">
                                                <div>
                                                    <h3 class="home-dashboard-panel-title">Top Component Groups</h3>
                                                    <p class="home-dashboard-panel-subtitle">Where active issue volume is currently concentrated.</p>
                                                </div>
                                            </div>
                                            <ul id="homeTopComponentsList" class="home-dashboard-list"></ul>
                                        </div>
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
<%--                    <asp:ListItem Text="PTL" Value="CMF_PTL_ALL_COMPONENTS_TABLE" />--%>
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
                    
<%--                    <asp:Button ID="btnExportToPPT" runat="server" Text="Export to PPT" OnClientClick="openExportPopup(); return false;" CssClass="modern-button" />--%>

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
                    <h2 class="ai-summary-drawer-title"><span>AI Summary</span><span id="aiSummaryConfidence" class="ai-summary-confidence-inline">Confidence: --</span></h2>
                    <div class="ai-summary-meta-row ai-summary-meta-combined"><strong>Sighting ID:</strong> <span id="aiSummaryIssueId">-</span><strong>CMF Ask Date:</strong> <span id="aiSummarySubmittedDate">-</span></div>
                    <div class="ai-summary-meta-row" id="aiSummaryTitleRow" style="display:none"><strong>Title:</strong> <span id="aiSummaryTitle">-</span></div>
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
                    <div class="ai-summary-meta-row"><strong>Pending Issue ID:</strong> <span id="cmfRecCpId">-</span></div>
                    <div class="ai-summary-meta-row"><strong>Issue Title:</strong> <span id="cmfRecTitle">-</span></div>
                    <div class="ai-summary-meta-row"><strong>Affected Component:</strong> <span id="cmfRecComponent">-</span></div>
                    
                    <div style="margin-top: 20px;">
                        <h3 style="font-size: 14px; font-weight: 700; color: #0f5ea8; margin-bottom: 8px;">Recommendation</h3>
                        <div id="cmfRecRecommendation" class="ai-summary-body" style="padding: 10px; background: #f0f7ff; border-left: 3px solid #0f5ea8; margin-bottom: 16px;">Generating...</div>
                    </div>

                    <div style="margin-top: 16px;">
                        <h3 style="font-size: 14px; font-weight: 700; color: #0f5ea8; margin-bottom: 8px;">Quality Score (/Threshold Score)</h3>
                        <div class="cmf-rec-quality-card">
                            <div>
                                <div class="cmf-rec-quality-label">Overall evaluation</div>
                                <div id="cmfRecQualityScore" class="cmf-rec-quality-value">-</div>
                            </div>
                        </div>
                    </div>
                    
                    <div style="margin-top: 16px;">
                        <h3 style="font-size: 14px; font-weight: 700; color: #0f5ea8; margin-bottom: 8px;">Reasoning</h3>
                        <div id="cmfRecEvidence" class="ai-summary-body" style="padding: 10px; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px; margin-bottom: 16px;">-</div>
                    </div>
                    
                    <div style="margin-top: 16px;">
                        <h3 style="font-size: 14px; font-weight: 700; color: #0f5ea8; margin-bottom: 8px;">Individual Scores</h3>
                        <div id="cmfRecRuleScoresBody" class="cmf-rec-score-list">
                            <div style="padding: 12px; text-align: center; color: #6b7280;">Loading...</div>
                        </div>
                    </div>

                    <div style="margin-top: 16px;">
                        <h3 style="font-size: 14px; font-weight: 700; color: #0f5ea8; margin-bottom: 8px;">Valid Next Steps</h3>
                        <div id="cmfRecNextSteps" class="ai-summary-body" style="padding: 10px; background: #fbfdff; border: 1px solid #e5e7eb; border-radius: 6px; margin-bottom: 16px;">-</div>
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

                    <asp:Panel ID="issueListHeaderPanel" runat="server" Visible="false">
                        <div class="issue-page-hd">
                            <div class="issue-page-hd-top">
                                <h1 class="issue-page-title">Overview</h1>
                            </div>
                            <p class="issue-page-desc">
                                Compact triage view with customer, owner, impact, status, milestone progress and edit controls in one workspace.
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
                                <div class="issue-kpi-sub"><i class="fas fa-arrow-up" aria-hidden="true"></i> days open over 14</div>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- TOP FILTER PANEL - FOR ISSUE LIST -->
<asp:Panel ID="fieldSelectorPanel" runat="server" Visible="false">
    <div class="field-selector-panel issue-top-filter-panel">
        <div class="issue-filter-section-header">
            <div class="issue-filter-title">Issue Filters</div>
            <button type="button" id="issueFiltersToggleBtn" class="issue-collapse-btn" aria-expanded="true" onclick="toggleCollapsibleSection('issueFilters')">
                <span class="toggle-label">Hide</span>
                <span class="toggle-chevron">▾</span>
            </button>
        </div>
        <div id="issueTopFilterBody" class="collapsible-body">
            <div class="issue-top-filter-grid">
                <div class="issue-top-filter-item"><span>Milestone</span><asp:DropDownList ID="ddlMilestoneTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>Owner</span><asp:DropDownList ID="ddlOwnerTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>RVP Repro</span><asp:DropDownList ID="ddlRvpReproTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>iDST</span><asp:DropDownList ID="ddlIdstTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>LOS</span><asp:DropDownList ID="ddlLosTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>Company</span><asp:DropDownList ID="ddlCompanyTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>Customer Detail</span><asp:DropDownList ID="ddlDetailTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>Component Group</span><asp:DropDownList ID="ddlComponentTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
                <div class="issue-top-filter-item"><span>CMF Request</span><asp:DropDownList ID="ddlCmfRequestTop" runat="server" AutoPostBack="false" CssClass="header-dropdown" /></div>
            </div>
            <div class="issue-top-filter-buttons">
                <asp:Button ID="btnApplyFilters" runat="server" CssClass="filter-btn filter-btn-primary" Text="Apply Filters" OnClick="btnApplyFilters_Click" />
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

        <asp:TemplateField HeaderText="Component Group" ItemStyle-CssClass="component-column field-component" HeaderStyle-CssClass="field-component">
            <HeaderTemplate>
                <div class="filter-header-container">
                    <div class="filter-header-text">Component Group</div>
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

       
        <%--<asp:BoundField DataField="cmf_request" HeaderText="CMF_Request" ReadOnly="True"
            ItemStyle-CssClass="field-cmf_request" HeaderStyle-CssClass="field-cmf_request" />--%>

        
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
                                <asp:LinkButton ID="btnPageGroupPrev" runat="server" CssClass="issue-pager-group-btn" OnClick="btnPageGroupPrev_Click" ToolTip="Previous 10 pages">&laquo;</asp:LinkButton>
                                <asp:Repeater ID="rptPageNumbers" runat="server" OnItemCommand="rptPageNumbers_ItemCommand">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnPageNumber" runat="server" CommandName="SelectPage" CommandArgument='<%# Eval("PageNumber") %>' CssClass='<%# "issue-pager-btn " + (Eval("IsCurrentPage").ToString() == "True" ? "issue-pager-current" : "") %>' Text='<%# Eval("PageNumber") %>' />
                                    </ItemTemplate>
                                </asp:Repeater>
                                <asp:LinkButton ID="btnPageGroupNext" runat="server" CssClass="issue-pager-group-btn" OnClick="btnPageGroupNext_Click" ToolTip="Next 10 pages">&raquo;</asp:LinkButton>
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

                    <!-- CMF PENDING LIST HEADER PANEL - INSIDE mainDataWrapper -->
                    <asp:Panel ID="cmf_pending_header_panel" runat="server" Visible="false">
                        <div class="cmf-pending-page-hd">
                            <div class="cmf-pending-page-hd-top">
                                <h1 class="cmf-pending-page-title">Overview</h1>
                            </div>
                            <p class="cmf-pending-page-desc">
                                AI reads each sighting against CMF rules, recommends tagging, detects duplicates, parses SysScope logs for root cause, and auto-completes missing fields.
                            </p>
                        </div>
                        
                        <!-- KPI ROW FOR CMF PENDING -->
                        <div class="cmf-pending-kpi-row">
                            <div class="cmf-pending-kpi">
                                <div class="cmf-pending-kpi-label">Pending Sightings</div>
                                <div class="cmf-pending-kpi-value"><asp:Label ID="lblPendingSightings" runat="server" Text="0" /></div>
                                <div class="cmf-pending-kpi-sub">Awaiting CMF decision</div>
                            </div>
                            <div class="cmf-pending-kpi">
                                <div class="cmf-pending-kpi-label" style="color:#2563eb;">Qualify for CMF</div>
                                <div class="cmf-pending-kpi-value" style="color:#059669;"><asp:Label ID="lblQualifyForCmf" runat="server" Text="0" /></div>
                                <div class="cmf-pending-kpi-sub">Admin-rule signals met</div>
                            </div>
                            <div class="cmf-pending-kpi">
                                <div class="cmf-pending-kpi-label" style="color:#2563eb;">Likely Duplicate</div>
                                <div class="cmf-pending-kpi-value" style="color:#d97706;"><asp:Label ID="lblLikelyDuplicate" runat="server" Text="0" /></div>
                                <div class="cmf-pending-kpi-sub">Duplicate language or repeated title</div>
                            </div>
                            <div class="cmf-pending-kpi">
                                <div class="cmf-pending-kpi-label" style="color:#2563eb;">Incomplete SysScope</div>
                                <div class="cmf-pending-kpi-value" style="color:#dc2626;"><asp:Label ID="lblIncompleteSysScope" runat="server" Text="0" /></div>
                                <div class="cmf-pending-kpi-sub">Missing repro, iDST, or impact</div>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- CMF PENDING LIST GRIDVIEW - INSIDE mainDataWrapper -->
                    <div class="gridview-container cmf-pending-grid-wrap" id="cmfPendingGridContainer" runat="server">
                        <asp:GridView ID="GridView_cmf_pending" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false">
                            <Columns>
                                <asp:TemplateField HeaderText="" ItemStyle-Width="34px" HeaderStyle-Width="34px">
                                    <HeaderTemplate><span class="pending-select-cell pending-select-header"><span class="pending-row-check" aria-hidden="true"></span></span></HeaderTemplate>
                                    <ItemTemplate><%# RenderPendingSelector(Eval("cmf_request")) %></ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Issue Details" ItemStyle-Width="210px" HeaderStyle-Width="210px">
                                    <ItemTemplate><%# RenderPendingIssueDetails(Eval("cp_id"), Eval("title"), Eval("cmf_request")) %></ItemTemplate>
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

                                <asp:TemplateField HeaderText="Ask / Impact" ItemStyle-Width="210px" HeaderStyle-Width="210px">
                                    <ItemTemplate><%# RenderPendingAskImpact(Eval("date_cmf_ask"), Eval("cmf_request"), Eval("impact")) %></ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Recommendation" ItemStyle-CssClass="field-recommendation" HeaderStyle-CssClass="field-recommendation" ItemStyle-Width="128px" HeaderStyle-Width="128px">
                                    <ItemTemplate>
                                        <%# RenderPendingRecommendationButton(Eval("cp_id"), Eval("title"), Eval("component"), Eval("cmf_request"), Eval("impact"), Eval("idst"), Eval("repro_on_rvp"), Eval("reproducibility"), Eval("customer_detail"), Eval("customer_owner")) %>
                                    </ItemTemplate>
                                </asp:TemplateField>

                            </Columns> 
                        </asp:GridView>
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
                                                <%--<asp:BoundField DataField="Driver_issues" HeaderText="Driver_issues" ReadOnly="True" />
                                                <asp:BoundField DataField="Implemented_Verified" HeaderText="Implemented/Verified" ReadOnly="True" />--%>
                                                <asp:CommandField ShowEditButton="True" />
                                            </Columns>
                                        </asp:GridView>
                                    </div>

                                    <asp:Panel ID="panelExtraGridViews" runat="server" Visible="false">
                                    <div class="gridview-container">
                                        <asp:GridView ID="GridView_design_summary" CssClass="table-primary" runat="server" AutoGenerateColumns="False" EmptyDataText="No Open CMFs" Visible="false" OnRowDataBound="GridView5_RowDataBound">
                                            <Columns>
                                                
                                                <asp:BoundField DataField="Design" HeaderText="Design" />
<%--                                                <asp:BoundField DataField="ME_SKU" HeaderText="ME_SKU" />--%>
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
         <%-- <asp:Button ID="btnExportDriverIssues1" runat="server"
                      Text="Export to Excel"
                      CssClass="modern-button1 export-btn"
                      OnClientClick="exportCMFIssues('component_value', '<%= HiddenDriverName.Value %>', 'issue_type_value'); return false;" />
                    --%>

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
                                                   <%-- <asp:TemplateField HeaderText="Implemented">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblImplementedCount" runat="server" Text='<%# Eval("ImplementedCount") %>'></asp:Label><br />
                                                            <asp:Label ID="lblImplementedDetails" runat="server" Text='<%# Eval("ImplementedDetails") %>'></asp:Label>
                                                        </ItemTemplate>
                                                        <ItemStyle Width="33%" />
                                                    </asp:TemplateField>--%>
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
                                            <%--<asp:GridView ID="GridView_milestone_map"
                                                          runat="server"
                                                          AutoGenerateColumns="False"
                                                          CssClass="table-primary"
                                                          EmptyDataText="No CMF data for milestones"
                                                          Visible="true">
                                                <Columns>
                                                    <asp:BoundField DataField="Driver" HeaderText="Driver" ReadOnly="True" ItemStyle-Width="50%" />
                                                    <asp:BoundField DataField="CMFCount" HeaderText="CMF Count" ReadOnly="True" ItemStyle-Width="50%" />
                                                </Columns>
                                            </asp:GridView>--%>

                                       <%-- <asp:GridView ID="GridView_milestone_map"
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
                                                       class="btn btn-link p-0">
                                                      <%# Eval("CMFCount") %>
                                                    </a>
                                                  </ItemTemplate>
                                                  <ItemStyle Width="50%" />
                                                </asp:TemplateField>
                                                
                                            </Columns>
                                        </asp:GridView>


                                        --%>  
                                            
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

