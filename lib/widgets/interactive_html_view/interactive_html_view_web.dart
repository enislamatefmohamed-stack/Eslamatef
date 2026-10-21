// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredHtmlViews = {};

Widget buildInteractiveHtmlWidget({
  required String rawHtml,
  required String id,
  double height = 750,
}) {
  final viewId = 'interactive_quiz_view_${id}_${rawHtml.hashCode}';

  if (!_registeredHtmlViews.contains(viewId)) {
    _registeredHtmlViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewIntId) {
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.minHeight = '100%'
        ..style.backgroundColor = '#FFFFFF'
        ..style.borderRadius = '16px'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
        ..allowFullscreen = true
        ..srcdoc = rawHtml;
      return iframe;
    });
  }

  return SizedBox(
    height: height,
    width: double.infinity,
    child: HtmlElementView(viewType: viewId),
  );
}
