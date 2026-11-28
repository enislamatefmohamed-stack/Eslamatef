import 'package:flutter/material.dart';
import 'embedded_iframe_stub.dart'
    if (dart.library.js_interop) 'embedded_iframe_web.dart'
    if (dart.library.html) 'embedded_iframe_web.dart';

class EmbeddedIframe extends StatelessWidget {
  final String src;
  final String id;
  final double? height;

  const EmbeddedIframe({
    super.key,
    required this.src,
    required this.id,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return buildEmbeddedIframeWidget(
      src: src,
      id: id,
      height: height,
    );
  }
}
