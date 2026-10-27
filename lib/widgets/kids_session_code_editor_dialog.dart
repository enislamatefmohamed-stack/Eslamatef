// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../data/kids_course_sessions_data.dart';
import '../services/site_data_service.dart';
import 'recording_launcher/recording_launcher.dart';

class KidsSessionCodeEditorDialog extends StatefulWidget {
  final KidsSessionItem session;
  final VoidCallback? onSaved;

  const KidsSessionCodeEditorDialog({
    super.key,
    required this.session,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context,
    KidsSessionItem session, {
    VoidCallback? onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => KidsSessionCodeEditorDialog(
        session: session,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<KidsSessionCodeEditorDialog> createState() =>
      _KidsSessionCodeEditorDialogState();
}

class _KidsSessionCodeEditorDialogState
    extends State<KidsSessionCodeEditorDialog> {
  late TextEditingController _codeController;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasCustomCode = false;
  String _statusMessage = "جاري تحميل كود الجلسة الحالي...";

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _loadSessionCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionCode() async {
    final customCode = SiteDataService.instance
        .getKidsSessionCustomCode(widget.session.number);
    if (customCode != null && customCode.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          _codeController.text = customCode;
          _hasCustomCode = true;
          _isLoading = false;
          _statusMessage = "تم تحميل الكود المخصص المحفوظ في الفايربيز ☁️";
        });
      }
      return;
    }

    // If no custom code, fetch the original HTML file from webUrl
    final targetUrl = widget.session.webUrl ??
        'kids_sessions/lecture_${widget.session.formattedNumber}/index.html';

    try {
      final res = await http.get(Uri.parse(targetUrl));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        if (mounted) {
          setState(() {
            _codeController.text = res.body;
            _hasCustomCode = false;
            _isLoading = false;
            _statusMessage = "تم تحميل الكود الأصلي للجلسة بنجاح 📄";
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("Error fetching default session html: $e");
    }

    if (mounted) {
      setState(() {
        _hasCustomCode = false;
        _isLoading = false;
        _statusMessage = "جاهز للصق أو كتابة كود HTML للجلسة 💻";
      });
    }
  }

  Future<void> _saveCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnack("يرجى إدخال أو لصق كود HTML أولاً!");
      return;
    }

    setState(() => _isSaving = true);
    try {
      await SiteDataService.instance
          .saveKidsSessionCustomCode(widget.session.number, code);
      if (!mounted) return;
      widget.onSaved?.call();
      Navigator.of(context).pop();
      _showSnack("تم حفظ وتطبيق كود الجلسة #${widget.session.formattedNumber} بنجاح! 🚀");
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack("حدث خطأ أثناء الحفظ: $e");
    }
  }

  Future<void> _restoreOriginal() async {
    setState(() => _isSaving = true);
    try {
      await SiteDataService.instance
          .deleteKidsSessionCustomCode(widget.session.number);
      if (!mounted) return;
      widget.onSaved?.call();
      Navigator.of(context).pop();
      _showSnack(
          "تمت استعادة الكود الأصلي للجلسة #${widget.session.formattedNumber} بنجاح! 🔄");
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack("حدث خطأ أثناء استعادة الكود: $e");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 700;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 24,
        ),
        child: Container(
          width: 1100,
          height: isMobile ? screenHeight * 0.92 : 820,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.code_rounded,
                        color: Color(0xFF0284C7), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "تعديل كود جلسة العرض #${widget.session.formattedNumber}",
                              style: GoogleFonts.cairo(
                                fontSize: isMobile ? 15 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_hasCustomCode)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8B5CF6).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "✨ كود مخصص نشط",
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          "${widget.session.title} • يمكنك تعديل الكود أو لصق كود HTML جديد بالكامل وسيتم تطبيقه فوراً",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Quick Actions Toolbar
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null && data!.text!.isNotEmpty) {
                        setState(() {
                          _codeController.text = data.text!;
                        });
                        _showSnack("تم لصق الكود من الحافظة بنجاح! 📋");
                      }
                    },
                    icon: const Icon(Icons.paste_rounded, size: 15),
                    label: Text("لصق من الحافظة 📋",
                        style: GoogleFonts.cairo(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (_codeController.text.isNotEmpty) {
                        Clipboard.setData(
                            ClipboardData(text: _codeController.text));
                        _showSnack("تم نسخ الكود بالكامل إلى الحافظة! 📄");
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: Text("نسخ الكود الحالي 📄",
                        style: GoogleFonts.cairo(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final code = _codeController.text.trim();
                      if (code.isEmpty) {
                        _showSnack("الكود فارغ حالياً! اكتب أو الصق الكود أولاً.");
                        return;
                      }
                      openRecordingPresentation(code,
                          title: widget.session.title);
                      _showSnack("جاري فتح المعاينة المباشرة للجلسة... 🎬");
                    },
                    icon: const Icon(Icons.play_arrow_rounded,
                        size: 16, color: Color(0xFF10B981)),
                    label: Text("معاينة حية مباشرة 👁️",
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                      backgroundColor: const Color(0xFFF0FDF4),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _codeController.clear()),
                    icon: const Icon(Icons.clear_all_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    label: Text("مسح المحرر",
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: const Color(0xFFEF4444))),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Status message bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    if (_isLoading) ...[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    if (!_isLoading && _codeController.text.isNotEmpty)
                      Text(
                        "${_codeController.text.length} حرف • ${_codeController.text.split('\n').length} سطر",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Code Editor Box
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF38BDF8),
                          ),
                        )
                      : TextField(
                          controller: _codeController,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFFE2E8F0),
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                "<!DOCTYPE html>\n<html lang=\"ar\" dir=\"rtl\">...\nالصق أو عدل كود HTML للجلسة هنا",
                            hintStyle: TextStyle(
                              color: Color(0xFF64748B),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer Bar
              Row(
                children: [
                  if (_hasCustomCode)
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _restoreOriginal,
                      icon: const Icon(Icons.restore_rounded,
                          size: 16, color: Color(0xFFEF4444)),
                      label: Text("استعادة الكود الأصلي 🔄",
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: const Color(0xFFFEF2F2),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("إلغاء",
                        style: GoogleFonts.cairo(
                            fontSize: 13, color: const Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveCode,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 17),
                    label: Text(
                      _isSaving ? "جاري الحفظ..." : "حفظ الكود وتطبيقه 💾",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
