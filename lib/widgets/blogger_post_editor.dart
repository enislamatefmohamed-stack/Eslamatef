// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_content_renderer.dart';

/// Google Blogger-styled Post & Lesson Editor (محرر احترافي بنمط بلوجر الأصلي)
/// Features:
/// 1. Top bar: Title field, View Switcher dropdown (< > عرض HTML / ✏️ عرض وضع الإنشاء),
///    Preview button, Orange Publish/Save button (#F57C00).
/// 2. Ribbon toolbar: Font, size, headings, B/I/U/S, color, link, insert image (Top4Top/URL),
///    insert video (YouTube embed/URL), emojis, alignment, lists, quotes, code blocks.
/// 3. HTML Mode: Monospace editor with real-time line number gutter (1, 2, 3, 4...) on the left.
/// 4. Compose Mode: Live interactive WYSIWYG preview rendering.
/// 5. Automatically detects & extracts cover image & YouTube video from the HTML content!
class BloggerPostEditor extends StatefulWidget {
  final String initialTitle;
  final String initialHtml;
  final String initialContent;
  final String initialCategory;
  final String initialStatus;
  final bool initialHasQuiz;
  final List<String> availableCategories;
  final List<Map<String, dynamic>> availablePlaylists;
  final String? initialPlaylistId;
  final VoidCallback onCancel;
  final Function(Map<String, dynamic> result) onSave;

  const BloggerPostEditor({
    super.key,
    this.initialTitle = '',
    this.initialHtml = '',
    this.initialContent = '',
    this.initialCategory = 'عام',
    this.initialStatus = 'منشور',
    this.initialHasQuiz = false,
    this.availableCategories = const [],
    this.availablePlaylists = const [],
    this.initialPlaylistId,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<BloggerPostEditor> createState() => _BloggerPostEditorState();
}

class _BloggerPostEditorState extends State<BloggerPostEditor> {
  late TextEditingController _titleCtrl;
  late TextEditingController _codeCtrl;
  late ScrollController _scrollController;
  late ScrollController _gutterScrollController;

  // Mode: 'html' (عرض HTML) or 'compose' (عرض وضع الإنشاء)
  String _mode = 'html';
  bool _showSettings = false;

  // Settings
  late String _category;
  late String _status;
  late String? _playlistId;
  late bool _hasQuiz;

  int _lineCount = 1;

  // History for Undo/Redo
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    
    // Default template if empty
    final defaultHtml = widget.initialHtml.trim().isNotEmpty
        ? widget.initialHtml
        : (widget.initialContent.trim().isNotEmpty
            ? '<article dir="rtl">\n  <h2>${widget.initialTitle.isNotEmpty ? widget.initialTitle : "عنوان الدرس"}</h2>\n  <p>${widget.initialContent}</p>\n</article>'
            : '''<article dir="rtl" style="font-family:Tahoma,Arial,sans-serif;line-height:1.9;color:#172b4d;max-width:900px;margin:auto">

  <header style="background:linear-gradient(135deg,#071b42,#064e8a);color:white;padding:30px 20px;border-radius:16px;text-align:center">
    <div style="color:#36d5f4;font-size:14px;font-weight:bold">Eslam Atef | Code & AI</div>
    <h1 style="font-size:28px;margin:12px 0">عنوان الدرس هنا</h1>
    <p style="margin:0;color:#d9efff">مادة البرمجة والذكاء الاصطناعي</p>
  </header>

  <section style="margin:25px 0">
    <h2 style="color:#087eae;border-right:5px solid #16c5e8;padding-right:12px">🎯 أهداف ومقدمة الدرس</h2>
    <p>اكتب هنا مقدمة الدرس وشرح المفاهيم الأساسية...</p>
  </section>

</article>''');

    _codeCtrl = TextEditingController(text: defaultHtml);
    _scrollController = ScrollController();
    _gutterScrollController = ScrollController();

    _category = widget.initialCategory.isNotEmpty ? widget.initialCategory : 'عام';
    _status = widget.initialStatus;
    _playlistId = widget.initialPlaylistId;
    _hasQuiz = widget.initialHasQuiz;

    _updateLineCount();
    _codeCtrl.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    _updateLineCount();
  }

  void _updateLineCount() {
    final lines = _codeCtrl.text.split('\n').length;
    if (lines != _lineCount) {
      setState(() => _lineCount = lines > 0 ? lines : 1);
    }
  }

  void _recordHistory(String text) {
    if (_undoStack.isEmpty || _undoStack.last != text) {
      _undoStack.add(text);
      if (_undoStack.length > 50) _undoStack.removeAt(0);
      _redoStack.clear();
    }
  }

  void _undo() {
    if (_undoStack.length > 1) {
      final current = _undoStack.removeLast();
      _redoStack.add(current);
      final prev = _undoStack.last;
      _codeCtrl.text = prev;
      _updateLineCount();
      setState(() {});
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final next = _redoStack.removeLast();
      _undoStack.add(next);
      _codeCtrl.text = next;
      _updateLineCount();
      setState(() {});
    }
  }

  void _insertSnippet(String openTag, [String closeTag = '']) {
    _recordHistory(_codeCtrl.text);
    final text = _codeCtrl.text;
    final selection = _codeCtrl.selection;
    if (selection.start >= 0 && selection.end >= 0) {
      final selectedText = text.substring(selection.start, selection.end);
      final replacement = '$openTag$selectedText$closeTag';
      final newText = text.replaceRange(selection.start, selection.end, replacement);
      _codeCtrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + openTag.length + selectedText.length),
      );
    } else {
      final newText = text + openTag + closeTag;
      _codeCtrl.text = newText;
    }
    _updateLineCount();
  }

  // Dialog to Insert Image (Supports Top4Top and any direct URL)
  void _showInsertImageDialog() {
    final urlCtrl = TextEditingController();
    final captionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.image_rounded, color: Color(0xFFE65100)),
            const SizedBox(width: 8),
            Text("إدراج صورة داخل المقال", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ضع رابط الصورة المباشر (مثل رابط Top4Top المباشر أو Unsplash):",
                style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: "https://g.top4top.io/p_3928ccxzd2.png",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "وصف توضيحي أسفل الصورة (اختياري):",
                style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: captionCtrl,
                decoration: InputDecoration(
                  hintText: "مثال: مخطط بنية البيانات",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final rawUrl = urlCtrl.text.trim();
              if (rawUrl.isNotEmpty) {
                // If user pasted BBCode, extract the direct URL
                String cleanUrl = rawUrl;
                final match = RegExp(r'https?://[^\s"\[\]]+').firstMatch(rawUrl);
                if (match != null) cleanUrl = match.group(0)!;

                final caption = captionCtrl.text.trim();
                final snippet = '''\n  <figure style="margin:25px 0;text-align:center">
    <img src="$cleanUrl" alt="${caption.isNotEmpty ? caption : 'صورة توضيحية'}" referrerpolicy="no-referrer" style="width:100%;max-height:420px;object-fit:cover;border-radius:14px" />
    ${caption.isNotEmpty ? '<figcaption style="font-size:13px;color:#64748b;margin-top:8px">$caption</figcaption>' : ''}
  </figure>\n''';
                _insertSnippet(snippet);
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
            label: Text("إدراج الصورة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to Insert Video (Converts YouTube watch to embed iframe)
  void _showInsertVideoDialog() {
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.smart_display_rounded, color: Color(0xFFE65100)),
            const SizedBox(width: 8),
            Text("إدراج فيديو يوتيوب داخل الدرس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ضع رابط يوتيوب العادي أو كود المضمن (Embed):",
                style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: "https://www.youtube.com/watch?v=3XUrdkmeqmc",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(Icons.video_library_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final raw = urlCtrl.text.trim();
              if (raw.isNotEmpty) {
                String videoId = '';
                if (raw.contains('watch?v=')) {
                  videoId = raw.split('watch?v=')[1].split('&')[0];
                } else if (raw.contains('youtu.be/')) {
                  videoId = raw.split('youtu.be/')[1].split('?')[0];
                } else if (raw.contains('embed/')) {
                  videoId = raw.split('embed/')[1].split('"')[0].split('?')[0];
                } else {
                  videoId = raw;
                }

                final snippet = '''\n  <div style="position:relative;width:100%;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:14px;background:#071b42;margin:25px 0">
    <iframe src="https://www.youtube.com/embed/$videoId" title="فيديو الدرس" style="position:absolute;top:0;left:0;width:100%;height:100%;border:0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen loading="lazy"></iframe>
  </div>\n''';
                _insertSnippet(snippet);
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.video_call_rounded, size: 16),
            label: Text("إدراج الفيديو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to Insert Link
  void _showInsertLinkDialog() {
    final urlCtrl = TextEditingController();
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("إدراج رابط تشعبي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textCtrl,
                decoration: InputDecoration(
                  labelText: "نص الرابط",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: "عنوان URL",
                  hintText: "https://...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              if (urlCtrl.text.isNotEmpty) {
                final display = textCtrl.text.isNotEmpty ? textCtrl.text : urlCtrl.text;
                _insertSnippet('<a href="${urlCtrl.text.trim()}" target="_blank">$display</a>');
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            child: const Text("إدراج"),
          ),
        ],
      ),
    );
  }

  // Save handler that automatically extracts image and video
  void _handleSave() {
    final code = _codeCtrl.text;
    
    // Auto-extract first image URL from HTML code
    String detectedImage = '';
    final imgMatch = RegExp(r'<img[^>]+src=["' "'" r']([^"' "'" r']+)["' "'" r']', caseSensitive: false).firstMatch(code);
    if (imgMatch != null) {
      detectedImage = imgMatch.group(1) ?? '';
    }

    // Auto-extract first YouTube URL from HTML code
    String detectedYoutube = '';
    final ytMatch = RegExp(r'youtube\.com/(?:watch\?v=|embed/)([a-zA-Z0-9_-]+)', caseSensitive: false).firstMatch(code);
    if (ytMatch != null) {
      detectedYoutube = 'https://www.youtube.com/watch?v=${ytMatch.group(1)}';
    } else {
      final shortYt = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)', caseSensitive: false).firstMatch(code);
      if (shortYt != null) {
        detectedYoutube = 'https://www.youtube.com/watch?v=${shortYt.group(1)}';
      }
    }

    final result = {
      'title': _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'درس جديد',
      'htmlCode': code,
      'content': code,
      'editorType': _mode == 'html' ? 'html' : 'visual',
      'imageUrl': detectedImage.isNotEmpty ? detectedImage : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
      'youtubeUrl': detectedYoutube,
      'category': _category,
      'status': _status,
      'playlistId': _playlistId,
      'hasQuiz': _hasQuiz,
    };

    widget.onSave(result);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _codeCtrl.removeListener(_onCodeChanged);
    _codeCtrl.dispose();
    _scrollController.dispose();
    _gutterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Google Blogger Top Header Bar
          _buildBloggerTopHeader(),

          // 2. Google Blogger Ribbon Toolbar
          _buildBloggerRibbonToolbar(),

          // 3. Main Editor Body (HTML with Line Gutter vs Compose View)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Editor Main Canvas
                Expanded(
                  child: _mode == 'html'
                      ? _buildHtmlCodeEditorWithGutter()
                      : _buildComposeLivePreview(),
                ),

                // Collapsible Right Settings Panel (مثل "إعدادات المشاركة" في بلوجر)
                if (_showSettings) _buildBloggerSettingsPanel(),
              ],
            ),
          ),

          // 4. Status Bar (Lines, characters, mode indicator)
          _buildBloggerStatusBar(),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. Google Blogger Top Header Bar
  // =========================================================================
  Widget _buildBloggerTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF475569)),
            tooltip: "رجوع دون حفظ",
            onPressed: widget.onCancel,
          ),
          const SizedBox(width: 8),

          // Title Input Field (Clean Blogger-styled title)
          Expanded(
            child: TextField(
              controller: _titleCtrl,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: "عنوان الدرس أو المشاركة...",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),

          // Settings toggle (إعدادات المشاركة)
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _showSettings ? const Color(0xFFE65100) : const Color(0xFF64748B),
            ),
            tooltip: "إعدادات الدرس والمشاركة",
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
          const SizedBox(width: 8),

          // Eye Preview Button (معاينة)
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: 950,
                    height: 650,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("👁️ معاينة المحتوى كما سيظهر للطلاب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: ArticleContentRenderer(content: _codeCtrl.text, isDark: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: Text("معاينة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 10),

          // Orange Publish / Save Button (تعديل / نشر مثل بلوجر تماماً)
          ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.cloud_upload_rounded, size: 18),
            label: Text("حفظ ونشر 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100), // Blogger Orange
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 1,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. Google Blogger Ribbon Toolbar
  // =========================================================================
  Widget _buildBloggerRibbonToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // View Switcher Dropdown (< > عرض HTML / ✏️ عرض وضع الإنشاء)
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _mode,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                items: const [
                  DropdownMenuItem(
                    value: 'html',
                    child: Row(
                      children: [
                        Icon(Icons.code_rounded, size: 16, color: Color(0xFFE65100)),
                        SizedBox(width: 6),
                        Text("< > عرض HTML"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'compose',
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF0284C7)),
                        SizedBox(width: 6),
                        Text("✏️ عرض وضع الإنشاء"),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _mode = v);
                },
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Undo / Redo
          _toolbarIcon(Icons.undo_rounded, "تراجع", _undo),
          _toolbarIcon(Icons.redo_rounded, "إعادة", _redo),
          _toolbarDivider(),

          // Headings Dropdown
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text("التنسيق", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                items: const [
                  DropdownMenuItem(value: 'h1', child: Text("عنوان رئيسي 1")),
                  DropdownMenuItem(value: 'h2', child: Text("عنوان رئيسي 2")),
                  DropdownMenuItem(value: 'h3', child: Text("عنوان فرعي 3")),
                  DropdownMenuItem(value: 'p', child: Text("فقرة عادية")),
                ],
                onChanged: (v) {
                  if (v == 'h1') _insertSnippet('<h1>', '</h1>');
                  if (v == 'h2') _insertSnippet('<h2>', '</h2>');
                  if (v == 'h3') _insertSnippet('<h3>', '</h3>');
                  if (v == 'p') _insertSnippet('<p>', '</p>');
                },
              ),
            ),
          ),
          const SizedBox(width: 4),

          // B, I, U, S Formats
          _toolbarButton("B", "عريض", () => _insertSnippet('<strong>', '</strong>'), isBold: true),
          _toolbarButton("I", "مائل", () => _insertSnippet('<em>', '</em>'), isItalic: true),
          _toolbarButton("U", "تسطير", () => _insertSnippet('<u>', '</u>'), isUnderline: true),
          _toolbarButton("S", "يتوسطه خط", () => _insertSnippet('<s>', '</s>'), isStrike: true),
          _toolbarDivider(),

          // Colors
          _toolbarIcon(Icons.format_color_text_rounded, "لون النص", () {
            _insertSnippet('<span style="color:#0284c7">', '</span>');
          }),
          _toolbarIcon(Icons.border_color_rounded, "تمييز النص (Highlight)", () {
            _insertSnippet('<mark style="background:#fef08a;padding:2px 6px;border-radius:4px">', '</mark>');
          }),
          _toolbarDivider(),

          // Link, Image, Video
          _toolbarIcon(Icons.link_rounded, "إدراج رابط", _showInsertLinkDialog),
          _toolbarIcon(Icons.image_rounded, "إدراج صورة (Top4Top / Unsplash)", _showInsertImageDialog, color: const Color(0xFFE65100)),
          _toolbarIcon(Icons.smart_display_rounded, "إدراج فيديو يوتيوب", _showInsertVideoDialog, color: const Color(0xFFDC2626)),
          _toolbarDivider(),

          // Emojis / Special tags
          _toolbarIcon(Icons.emoji_emotions_outlined, "إدراج رموز تعبيرية", () {
            _insertSnippet(' 💡 ');
          }),

          // Alignment & Lists
          _toolbarIcon(Icons.format_align_right_rounded, "محاذاة لليمين", () => _insertSnippet('<div style="text-align:right">', '</div>')),
          _toolbarIcon(Icons.format_align_center_rounded, "محاذاة للوسط", () => _insertSnippet('<div style="text-align:center">', '</div>')),
          _toolbarIcon(Icons.format_align_left_rounded, "محاذاة لليسار", () => _insertSnippet('<div style="text-align:left">', '</div>')),
          _toolbarIcon(Icons.format_list_bulleted_rounded, "قائمة نقطية", () => _insertSnippet('<ul>\n  <li>عنصر 1</li>\n  <li>عنصر 2</li>\n</ul>')),
          _toolbarIcon(Icons.format_list_numbered_rounded, "قائمة رقمية", () => _insertSnippet('<ol>\n  <li>خطوة 1</li>\n  <li>خطوة 2</li>\n</ol>')),
          _toolbarDivider(),

          // Quote, Code, Table
          _toolbarIcon(Icons.format_quote_rounded, "اقتباس", () => _insertSnippet('<blockquote style="background:#f8fafc;border-right:4px solid #0284c7;padding:12px;margin:16px 0">', '</blockquote>')),
          _toolbarIcon(Icons.code_rounded, "كتلة كود برمجي", () => _insertSnippet('<pre><code>', '</code></pre>')),
          _toolbarIcon(Icons.table_chart_outlined, "إدراج جدول", () {
            _insertSnippet('''<table style="width:100%;border-collapse:collapse;margin:16px 0">
  <thead>
    <tr style="background:#075985;color:white">
      <th style="padding:10px;border:1px solid #cbd5e1">العنصر</th>
      <th style="padding:10px;border:1px solid #cbd5e1">الوصف</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding:10px;border:1px solid #cbd5e1">بيانات</td>
      <td style="padding:10px;border:1px solid #cbd5e1">شرح القيمة</td>
    </tr>
  </tbody>
</table>''');
          }),
        ],
      ),
    );
  }

  Widget _toolbarIcon(IconData icon, String tooltip, VoidCallback onTap, {Color? color}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 17, color: color ?? const Color(0xFF334155)),
        ),
      ),
    );
  }

  Widget _toolbarButton(String label, String tooltip, VoidCallback onTap, {bool isBold = false, bool isItalic = false, bool isUnderline = false, bool isStrike = false}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: isUnderline
                  ? TextDecoration.underline
                  : (isStrike ? TextDecoration.lineThrough : TextDecoration.none),
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarDivider() {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: const Color(0xFFCBD5E1),
    );
  }

  // =========================================================================
  // 3. HTML Code Editor with Real-time Line Number Gutter
  // =========================================================================
  Widget _buildHtmlCodeEditorWithGutter() {
    return Container(
      color: const Color(0xFF0F172A), // Modern IDE dark canvas
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Line Number Gutter (أرقام الأسطر مثل بلوجر)
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF090D16),
              border: Border(left: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: SingleChildScrollView(
              controller: _gutterScrollController,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: List.generate(_lineCount, (i) {
                  return Container(
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      "${i + 1}",
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Code Text Area
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  if (_gutterScrollController.hasClients) {
                    _gutterScrollController.jumpTo(_scrollController.offset);
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: _codeCtrl,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: GoogleFonts.firaCode(
                      fontSize: 13,
                      height: 1.5,
                      color: const Color(0xFFE2E8F0),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3B. Compose Mode: Live Preview
  // =========================================================================
  Widget _buildComposeLivePreview() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            child: ArticleContentRenderer(content: _codeCtrl.text, isDark: false),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Right Settings Panel ("إعدادات المشاركة")
  // =========================================================================
  Widget _buildBloggerSettingsPanel() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("إعدادات المشاركة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _showSettings = false),
                ),
              ],
            ),
            const Divider(),

            // Category (التصنيف)
            Text("التصنيف:", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: widget.availableCategories.contains(_category) ? _category : (widget.availableCategories.isNotEmpty ? widget.availableCategories.first : 'عام'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: (widget.availableCategories.isNotEmpty ? widget.availableCategories : ['عام', 'برمجة', 'ذكاء اصطناعي']).map((c) {
                return DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.cairo(fontSize: 12)));
              }).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'عام'),
            ),
            const SizedBox(height: 16),

            // Publishing Status (الحالة)
            Text("حالة النشر:", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'منشور', child: Text("منشور علناً")),
                DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'منشور'),
            ),
            const SizedBox(height: 16),

            // Quiz option
            CheckboxListTile(
              value: _hasQuiz,
              onChanged: (v) => setState(() => _hasQuiz = v ?? false),
              title: Text("تفعيل زر اختبار بعد الدرس 📝", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. Status Bar
  // =========================================================================
  Widget _buildBloggerStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Text(
            _mode == 'html' ? "💻 وضع كود HTML" : "✏️ وضع المعاينة والإنشاء",
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
          ),
          const SizedBox(width: 16),
          Text(
            "عدد الأسطر: $_lineCount",
            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Text(
            "عدد الحروف: ${_codeCtrl.text.length}",
            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
          ),
          const Spacer(),
          Text(
            "Blogger Engine v2.0",
            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
