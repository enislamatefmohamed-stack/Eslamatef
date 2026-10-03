// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

void registerHtmlViewFactory(String viewId, String rawHtml, {bool isDark = false}) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.minHeight = '450px'
      ..style.backgroundColor = isDark ? '#0F172A' : '#FFFFFF'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
      ..allowFullscreen = true;

    // Convert BBCode image tags in HTML if any
    var processed = rawHtml
        .replaceAllMapped(
          RegExp(r'\[url=([^\]]+)\]\s*\[img\]([^\]]+)\[\/img\]\s*\[\/url\]', caseSensitive: false),
          (m) => '<a href="${m[1]}" target="_blank"><img src="${m[2]}" referrerpolicy="no-referrer" style="max-width:100%; border-radius:12px;" /></a>',
        )
        .replaceAllMapped(
          RegExp(r'\[img\]([^\]]+)\[\/img\]', caseSensitive: false),
          (m) => '<img src="${m[1]}" referrerpolicy="no-referrer" style="max-width:100%; border-radius:12px;" />',
        );

    // Upgrade insecure http to https for images so browser doesn't block mixed content
    processed = processed.replaceAllMapped(
      RegExp(r'<img([^>]+)src=["\x27]http://([^"\x27]+)["\x27]', caseSensitive: false),
      (m) => '<img${m[1]}src="https://${m[2]}" referrerpolicy="no-referrer"',
    );

    // Add referrerpolicy="no-referrer" to all images if missing
    processed = processed.replaceAllMapped(
      RegExp(r'<img((?![^>]*referrerpolicy)[^>]*src=["\x27][^"\x27]+["\x27][^>]*)>', caseSensitive: false),
      (m) => '<img referrerpolicy="no-referrer"${m[1]}>',
    );

    final String fullDoc;
    final commonCss = '''
    *, *::before, *::after {
      box-sizing: border-box;
    }
    html {
      scroll-behavior: smooth;
    }
    body {
      margin: 0;
      padding: 16px;
      font-family: 'Cairo', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      color: ${isDark ? '#F8FAFC' : '#0F172A'};
      background-color: ${isDark ? '#0F172A' : '#FFFFFF'};
      direction: rtl;
      line-height: 1.85;
      font-size: 16px;
      overflow-x: auto;
      word-wrap: break-word;
      user-select: text !important;
      -webkit-user-select: text !important;
    }
    img {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
    }
    iframe {
      max-width: 100%;
      border-radius: 12px;
      border: none;
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
''';

    if (processed.toLowerCase().contains('<html') || processed.toLowerCase().contains('<!doctype')) {
      // Document already contains <html>; inject no-referrer meta and responsive base CSS into <head>
      if (processed.toLowerCase().contains('<head')) {
        fullDoc = processed.replaceFirst(
          RegExp(r'<head[^>]*>', caseSensitive: false),
          '<head><meta name="referrer" content="no-referrer"><meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=5.0"><link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet"><style>$commonCss</style>',
        );
      } else {
        fullDoc = '<meta name="referrer" content="no-referrer"><style>$commonCss</style>$processed';
      }
    } else {
      fullDoc = '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=5.0, user-scalable=yes">
  <meta name="referrer" content="no-referrer">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <style>
$commonCss
  </style>
</head>
<body>
  $processed
</body>
</html>
''';
    }

    iframe.srcdoc = fullDoc;
    return iframe;
  });
}
