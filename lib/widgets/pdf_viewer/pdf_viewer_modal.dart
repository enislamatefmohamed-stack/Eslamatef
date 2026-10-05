import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pdf_platform.dart' as pdf_platform;

/// Normalizes any PDF URL (especially Google Drive links) into an embeddable preview URL.
String normalizePdfPreviewUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return '';

  // 1. Google Drive /file/d/<ID>/...
  final driveFileMatch = RegExp(r'drive\.google\.com\/file\/d\/([a-zA-Z0-9_-]+)').firstMatch(trimmed);
  if (driveFileMatch != null) {
    final fileId = driveFileMatch.group(1)!;
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  // 2. Google Drive ?id=<ID>
  final driveIdMatch = RegExp(r'drive\.google\.com\/(?:open|uc)\?(?:[^&]*&)*id=([a-zA-Z0-9_-]+)').firstMatch(trimmed);
  if (driveIdMatch != null) {
    final fileId = driveIdMatch.group(1)!;
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  // 3. Direct PDF or other docs: Use Google Docs Viewer for seamless in-page embedding
  if (trimmed.toLowerCase().endsWith('.pdf') || trimmed.contains('.pdf?')) {
    return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(trimmed)}&embedded=true';
  }

  // 4. Default return if already formatted
  return trimmed;
}

/// A modal dialog that opens and embeds PDF documents (Google Drive & Direct PDFs)
/// seamlessly inside the website without redirecting away.
class PdfViewerModal extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool isDark;

  const PdfViewerModal({
    super.key,
    required this.pdfUrl,
    this.title = 'ملزمة الكورس (PDF)',
    this.isDark = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String pdfUrl,
    String? title,
    bool isDark = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PdfViewerModal(
        pdfUrl: pdfUrl,
        title: title ?? 'ملزمة ومحتوى الكورس (PDF)',
        isDark: isDark,
      ),
    );
  }

  @override
  State<PdfViewerModal> createState() => _PdfViewerModalState();
}

class _PdfViewerModalState extends State<PdfViewerModal> {
  late String _viewId;
  late String _embedUrl;

  @override
  void initState() {
    super.initState();
    _embedUrl = normalizePdfPreviewUrl(widget.pdfUrl);
    _viewId = 'pdf_viewer_${DateTime.now().millisecondsSinceEpoch}_${_embedUrl.hashCode}';

    if (kIsWeb && _embedUrl.isNotEmpty) {
      pdf_platform.registerPdfIframeViewFactory(_viewId, _embedUrl);
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.pdfUrl.trim());
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 32,
          vertical: isMobile ? 12 : 24,
        ),
        child: Container(
          width: 1100,
          height: size.height * 0.90,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.6 : 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "قراءة وتصفح الملف مباشرة داخل الموقع",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openExternal,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: Text(
                        isMobile ? "فتح" : "فتح في تبويب خارجي",
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0284C7),
                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: "إغلاق",
                      onPressed: () => Navigator.of(context).pop(),
                      color: widget.isDark ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
              ),

              // Viewer Body
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Container(
                    color: widget.isDark ? const Color(0xFF060D1F) : const Color(0xFFF1F5F9),
                    child: kIsWeb && _embedUrl.isNotEmpty
                        ? HtmlElementView(viewType: _viewId)
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    size: 64,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "يمكنك فتح الملف مباشرة لقراءته أو تحميله:",
                                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _openExternal,
                                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                    label: Text(
                                      "فتح وقراءة الملف 📖",
                                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0284C7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
