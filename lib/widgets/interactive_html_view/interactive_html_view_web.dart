// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredHtmlViews = {};

Widget buildInteractiveHtmlWidget({
  required String rawHtml,
  required String id,
  double height = 750,
}) {
  return AutoResizingHtmlWidget(
    rawHtml: rawHtml,
    id: id,
    defaultHeight: height,
  );
}

class AutoResizingHtmlWidget extends StatefulWidget {
  final String rawHtml;
  final String id;
  final double defaultHeight;

  const AutoResizingHtmlWidget({
    super.key,
    required this.rawHtml,
    required this.id,
    required this.defaultHeight,
  });

  @override
  State<AutoResizingHtmlWidget> createState() => _AutoResizingHtmlWidgetState();
}

class _AutoResizingHtmlWidgetState extends State<AutoResizingHtmlWidget> {
  late double _currentHeight;
  StreamSubscription? _msgSub;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    // Smart initial height estimation based on text length to prevent jumping
    if (widget.rawHtml.length > 15000) {
      _currentHeight = (widget.rawHtml.length * 0.12).clamp(widget.defaultHeight, 6000.0);
    } else {
      _currentHeight = widget.defaultHeight;
    }

    _viewId = 'interactive_quiz_view_${widget.id}_${widget.rawHtml.hashCode}';

    if (!_registeredHtmlViews.contains(_viewId)) {
      _registeredHtmlViews.add(_viewId);

      final resizeScript = '''
<script>
(function() {
  function sendHeight() {
    try {
      var body = document.body;
      var htmlElem = document.documentElement;
      var h = Math.max(
        body ? body.scrollHeight : 0,
        body ? body.offsetHeight : 0,
        htmlElem ? htmlElem.clientHeight : 0,
        htmlElem ? htmlElem.scrollHeight : 0,
        htmlElem ? htmlElem.offsetHeight : 0
      );
      if (h > 50) {
        window.parent.postMessage({ type: 'flutter_html_resize', id: '${widget.id}', height: h }, '*');
      }
    } catch(e) {}
  }
  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    sendHeight();
  } else {
    window.addEventListener('DOMContentLoaded', sendHeight);
  }
  window.addEventListener('load', sendHeight);
  if (window.ResizeObserver && document.body) {
    try {
      new ResizeObserver(sendHeight).observe(document.body);
    } catch(e) {}
  }
  setTimeout(sendHeight, 300);
  setTimeout(sendHeight, 800);
  setTimeout(sendHeight, 1800);
  setTimeout(sendHeight, 3500);
})();
</script>
''';

      var processedHtml = widget.rawHtml;
      if (processedHtml.contains('</body>')) {
        processedHtml = processedHtml.replaceFirst('</body>', '$resizeScript</body>');
      } else {
        processedHtml += resizeScript;
      }

      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewIntId) {
        final iframe = html.IFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.minHeight = '100%'
          ..style.backgroundColor = 'transparent'
          ..style.overflow = 'hidden'
          ..setAttribute('scrolling', 'no')
          ..allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
          ..allowFullscreen = true
          ..srcdoc = processedHtml;
        return iframe;
      });
    }

    _msgSub = html.window.onMessage.listen((event) {
      try {
        final data = event.data;
        if (data is Map && data['type'] == 'flutter_html_resize' && data['id'] == widget.id) {
          final h = (data['height'] as num?)?.toDouble();
          if (h != null && h > 50 && (h - _currentHeight).abs() > 10) {
            if (mounted) {
              setState(() {
                _currentHeight = h + 25; // padding
              });
            }
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _currentHeight,
      width: double.infinity,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
