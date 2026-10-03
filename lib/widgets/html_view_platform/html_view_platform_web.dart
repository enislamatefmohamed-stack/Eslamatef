// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

void registerHtmlViewFactory(String viewId, String rawHtml, {bool isDark = false}) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.minHeight = '400px'
      ..style.backgroundColor = isDark ? '#0F172A' : '#FFFFFF'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
      ..allowFullscreen = true;

    final fullDoc = '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=5.0, user-scalable=yes">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after {
      box-sizing: border-box;
    }
    html {
      scroll-behavior: smooth;
    }
    body {
      margin: 0;
      padding: 18px;
      font-family: 'Cairo', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      color: ${isDark ? '#F8FAFC' : '#0F172A'};
      background-color: ${isDark ? '#0F172A' : '#FFFFFF'};
      direction: rtl;
      text-align: right;
      line-height: 1.85;
      font-size: 16px;
      overflow-x: hidden;
      word-wrap: break-word;
      user-select: text !important;
      -webkit-user-select: text !important;
    }
    img {
      max-width: 100% !important;
      height: auto !important;
      border-radius: 12px;
      display: block;
      margin: 16px auto;
      box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }
    iframe {
      max-width: 100% !important;
      border-radius: 12px;
      border: none;
      display: block;
      margin: 16px auto;
      box-shadow: 0 4px 16px rgba(0,0,0,0.12);
    }
    pre, code {
      font-family: Consolas, 'Courier New', monospace;
      direction: ltr;
      text-align: left;
      border-radius: 8px;
    }
    pre {
      background: ${isDark ? '#1E293B' : '#F1F5F9'};
      padding: 16px;
      overflow-x: auto;
      border: 1px solid ${isDark ? '#334155' : '#E2E8F0'};
    }
    a {
      color: #0284C7;
      text-decoration: none;
      font-weight: 600;
    }
    a:hover {
      text-decoration: underline;
    }
    /* Blogger card & layout styling fixes */
    .lesson-card, .article-card, .post-body, .container {
      max-width: 100% !important;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 16px 0;
    }
    th, td {
      border: 1px solid ${isDark ? '#334155' : '#E2E8F0'};
      padding: 10px 14px;
    }
    th {
      background: ${isDark ? '#1E293B' : '#F8FAFC'};
    }
  </style>
</head>
<body>
  $rawHtml
</body>
</html>
''';

    iframe.srcdoc = fullDoc;
    return iframe;
  });
}
