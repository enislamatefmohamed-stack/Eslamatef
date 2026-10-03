// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'safe_network_image.dart';

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
    return errorWidget ?? _buildFallback(width: width, height: height, borderRadius: borderRadius);
  }

  if (cleanUrl.startsWith('assets/')) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => errorWidget ?? _buildFallback(width: width, height: height, borderRadius: borderRadius),
      ),
    );
  }

  // Register unique view factory for the HTML <img> element
  final viewId = 'safe_img_${cleanUrl.hashCode.abs()}';
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = cleanUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain ? 'contain' : 'cover'
      ..style.border = 'none'
      ..style.display = 'block'
      ..referrerPolicy = 'no-referrer';
    return img;
  });

  Widget content = SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );

  if (borderRadius != null) {
    content = ClipRRect(borderRadius: borderRadius, child: content);
  }

  return content;
}

Widget _buildFallback({double? width, double? height, BorderRadiusGeometry? borderRadius}) {
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
