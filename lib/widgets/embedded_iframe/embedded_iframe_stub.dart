import 'package:flutter/material.dart';

Widget buildEmbeddedIframeWidget({
  required String src,
  required String id,
  double? height,
}) {
  return SizedBox(
    height: height ?? 750,
    child: const Center(
      child: Text(
        "معاينة الإطار غير متاحة على هذه المنصة",
        style: TextStyle(fontFamily: 'Cairo'),
      ),
    ),
  );
}
