// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
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
    return _buildAssetFallback(
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      errorWidget: errorWidget,
    );
  }

  if (cleanUrl.startsWith('assets/')) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _buildAssetFallback(
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          errorWidget: errorWidget,
        ),
      ),
    );
  }

  Widget content = Image.network(
    cleanUrl,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return _buildAssetFallback(
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        errorWidget: errorWidget,
      );
    },
  );

  if (borderRadius != null) {
    content = ClipRRect(borderRadius: borderRadius, child: content);
  }

  return content;
}

Widget _buildAssetFallback({
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadiusGeometry? borderRadius,
  Widget? errorWidget,
}) {
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: Image.asset(
      'assets/images/slide1.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (c, e, s) => errorWidget ?? _buildColorFallback(width: width, height: height, borderRadius: borderRadius),
    ),
  );
}

Widget _buildColorFallback({double? width, double? height, BorderRadiusGeometry? borderRadius}) {
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
