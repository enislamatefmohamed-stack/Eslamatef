// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

void registerIframeViewFactory(String viewId, String videoId) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final wrapper = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.overflow = 'hidden'
      ..style.borderRadius = '16px'
      ..style.backgroundColor = '#000000'
      ..style.position = 'relative'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..dir = 'ltr';

    final iframe = html.IFrameElement()
      ..src = 'https://www.youtube.com/embed/$videoId?rel=0&autoplay=0'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.borderRadius = '16px'
      ..style.display = 'block'
      ..dir = 'ltr'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
      ..allowFullscreen = true;

    wrapper.children.add(iframe);
    return wrapper;
  });
}
