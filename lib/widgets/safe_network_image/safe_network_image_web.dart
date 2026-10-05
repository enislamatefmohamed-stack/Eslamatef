// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'safe_network_image.dart';

final Set<String> _registeredImageViews = {};

Widget buildPlatformSafeImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadiusGeometry? borderRadius,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  final cleanUrl = sanitizeImageUrl(imageUrl);

  if (cleanUrl.isEmpty) {
    return errorWidget ?? _buildColorFallback(width: width, height: height, borderRadius: borderRadius);
  }

  // 1. Local App Assets
  if (cleanUrl.startsWith('assets/')) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => errorWidget ?? _buildColorFallback(width: width, height: height, borderRadius: borderRadius),
      ),
    );
  }

  // 2. Web Network Image:
  // Render via native HTML <img> element with referrerPolicy="no-referrer".
  // This completely bypasses CanvasKit CORS restrictions, ensuring external images
  // (Top4top, Blogger, Imgur, Google Drive, etc.) load 100% reliably in the browser.
  final viewId = 'safe_img_${cleanUrl.hashCode}_${fit.name}';

  if (!_registeredImageViews.contains(viewId)) {
    _registeredImageViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = cleanUrl
        ..referrerPolicy = 'no-referrer'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.display = 'block'
        ..style.pointerEvents = 'none';

      img.onError.listen((_) {
        img.style.display = 'none';
      });

      switch (fit) {
        case BoxFit.cover:
          img.style.objectFit = 'cover';
          break;
        case BoxFit.contain:
          img.style.objectFit = 'contain';
          break;
        case BoxFit.fill:
          img.style.objectFit = 'fill';
          break;
        case BoxFit.fitWidth:
          img.style.objectFit = 'cover';
          break;
        case BoxFit.fitHeight:
          img.style.objectFit = 'contain';
          break;
        default:
          img.style.objectFit = 'cover';
      }

      return img;
    });
  }

  Widget htmlView = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    htmlView = SizedBox(width: width, height: height, child: htmlView);
  }

  if (borderRadius != null) {
    htmlView = ClipRRect(borderRadius: borderRadius, child: htmlView);
  }

  return htmlView;
}

Widget _buildColorFallback({
  double? width,
  double? height,
  BorderRadiusGeometry? borderRadius,
  Widget? errorWidget,
}) {
  if (errorWidget != null) return errorWidget;

  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.code_rounded, color: Color(0xFF00E5FF), size: 36),
      ),
    ),
  );
}
