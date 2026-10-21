import 'package:flutter/material.dart';
import 'interactive_html_view_stub.dart'
    if (dart.library.js_interop) 'interactive_html_view_web.dart'
    if (dart.library.html) 'interactive_html_view_web.dart';

class InteractiveHtmlView extends StatelessWidget {
  final String rawHtml;
  final String id;
  final double height;

  const InteractiveHtmlView({
    super.key,
    required this.rawHtml,
    required this.id,
    this.height = 750,
  });

  @override
  Widget build(BuildContext context) {
    return buildInteractiveHtmlWidget(
      rawHtml: rawHtml,
      id: id,
      height: height,
    );
  }
}
