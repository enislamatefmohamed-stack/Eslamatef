// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredIframeViews = {};

Widget buildEmbeddedIframeWidget({
  required String src,
  required String id,
  double? height,
}) {
  // Use a sanitized unique viewId
  final sanitizedId = id.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
  final viewId = 'iframe_view_$sanitizedId';

  if (!_registeredIframeViews.contains(viewId)) {
    _registeredIframeViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewIdInt) {
      final iframe = html.IFrameElement()
        ..src = src
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block'
        ..style.backgroundColor = 'transparent'
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
        ..allowFullscreen = true;
      return iframe;
    });
  }

  return SizedBox(
    height: height ?? 750,
    width: double.infinity,
    child: HtmlElementView(viewType: viewId),
  );
}
