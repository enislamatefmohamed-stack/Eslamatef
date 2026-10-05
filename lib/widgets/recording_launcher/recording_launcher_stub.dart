import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

Future<void> openRecordingPresentation(String htmlContent, {String? title}) async {
  if (htmlContent.trim().isEmpty) return;
  final uri = Uri.dataFromString(
    htmlContent,
    mimeType: 'text/html',
    encoding: utf8,
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
