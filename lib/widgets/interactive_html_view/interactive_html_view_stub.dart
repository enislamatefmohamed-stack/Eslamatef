import 'package:flutter/material.dart';

Widget buildInteractiveHtmlWidget({
  required String rawHtml,
  required String id,
  double height = 750,
}) {
  return SizedBox(
    height: height,
    width: double.infinity,
    child: const Center(
      child: Text('عرض الـ HTML التفاعلي متاح على نسخة الويب.'),
    ),
  );
}
