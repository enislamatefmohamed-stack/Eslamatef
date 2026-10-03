import 'package:flutter/material.dart';
import 'safe_network_image_stub.dart'
    if (dart.library.html) 'safe_network_image_web.dart' as platform_impl;

/// Universal, ultra-resilient image renderer:
/// - Automatically sanitizes BBCode `[url=...][img]...[/img][/url]` and extracts direct URLs.
/// - On Flutter Web: Renders a native HTML `<img>` element with `referrerPolicy="no-referrer"`,
///   completely bypassing CanvasKit CORS restrictions (loads Top4top, Imgur, Blogger images 100% reliably).
/// - On other platforms: Uses standard `Image.network`.
/// - Never shows an ugly broken gray box; displays an elegant tech gradient fallback.
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return platform_impl.buildPlatformSafeImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// Helper function to clean BBCode or messy URLs
String sanitizeImageUrl(String raw) {
  var trimmed = raw.trim();
  if (trimmed.isEmpty) return '';

  // 1. BBCode [url=...][img]URL[/img][/url]
  final bbMatch = RegExp(r'\[img\](https?://[^\[\]]+)\[\/img\]', caseSensitive: false).firstMatch(trimmed);
  if (bbMatch != null) {
    return bbMatch.group(1)!.trim();
  }

  // 2. BBCode [url=URL]
  final urlMatch = RegExp(r'\[url=(https?://[^\[\]]+)\]', caseSensitive: false).firstMatch(trimmed);
  if (urlMatch != null && (trimmed.startsWith('[url=') || !trimmed.startsWith('http'))) {
    return urlMatch.group(1)!.trim();
  }

  // 3. Direct image link ending with extension
  final directMatch = RegExp(r"https?://[^\s\[\]\x22\x27<>]+\.(?:png|jpg|jpeg|webp|gif|svg)(?:\?[^\s\[\]\x22\x27<>]*)?", caseSensitive: false).firstMatch(trimmed);
  if (directMatch != null) {
    return directMatch.group(0)!;
  }

  // 4. Any general http URL
  final httpMatch = RegExp(r"https?://[^\s\[\]\x22\x27<>]+", caseSensitive: false).firstMatch(trimmed);
  if (httpMatch != null) {
    return httpMatch.group(0)!;
  }

  return trimmed;
}
