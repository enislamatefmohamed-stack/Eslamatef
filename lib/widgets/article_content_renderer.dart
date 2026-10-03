// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'html_view_platform/html_view_platform.dart' as html_platform;
import 'youtube_embedded_player.dart';

/// Renders rich article content:
/// - On Web: Supports full Blogger HTML, embedded `<style>`, `<div>`, `<iframe src="...">`,
///   and custom designs natively without stripping CSS or showing raw code.
/// - On other platforms: Clean parsed markdown and structured HTML blocks.
class ArticleContentRenderer extends StatelessWidget {
  final String content;
  final bool isDark;

  const ArticleContentRenderer({
    super.key,
    required this.content,
    required this.isDark,
  });

  bool _isHtmlContent(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    // Check for HTML signatures
    if (trimmed.startsWith('<') && trimmed.contains('>')) return true;
    final htmlTags = [
      '<div', '<p', '<style', '<iframe', '<section', '<article',
      '<table', '<span', '<h1', '<h2', '<h3', '<h4', '<ul', '<ol', '<img'
    ];
    for (final tag in htmlTags) {
      if (trimmed.toLowerCase().contains(tag)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return Text(
        "لا يوجد محتوى مضاف لهذا المقال بعد.",
        style: GoogleFonts.cairo(
          fontSize: 15,
          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (kIsWeb && _isHtmlContent(content)) {
      return WebHtmlViewWidget(
        rawHtml: content,
        isDark: isDark,
      );
    }

    final elements = _parseContent(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: elements.map((e) => _renderElement(context, e)).toList(),
    );
  }

  List<_ArticleBlock> _parseContent(String raw) {
    final List<_ArticleBlock> blocks = [];

    // 1. Strip <style> and <script> tags completely so raw CSS/JS is NEVER printed as plain text
    var sanitized = raw
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?<\/style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?<\/script>', caseSensitive: false), '');

    // Check if content has HTML tags
    final hasHtml = sanitized.contains('<') && sanitized.contains('>');

    if (!hasHtml) {
      final paragraphs = sanitized.split(RegExp(r'\n\s*\n'));
      for (final p in paragraphs) {
        final trimmed = p.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('```') && trimmed.endsWith('```')) {
          final code = trimmed.substring(3, trimmed.length - 3).trim();
          blocks.add(_ArticleBlock(type: _BlockType.code, text: code));
        } else if (trimmed.startsWith('# ') || trimmed.startsWith('## ')) {
          final title = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
          blocks.add(_ArticleBlock(type: _BlockType.heading, text: title));
        } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
          final items = trimmed.split('\n').map((l) => l.replaceFirst(RegExp(r'^[-*]\s*'), '')).toList();
          blocks.add(_ArticleBlock(type: _BlockType.list, items: items));
        } else {
          blocks.add(_ArticleBlock(type: _BlockType.paragraph, text: trimmed));
        }
      }
      return blocks;
    }

    // HTML-like tokenization
    final tagRegex = RegExp(
      r'<(h[1-4]|p|pre|blockquote|tip|ul|img|iframe)\b([^>]*)>(.*?)(<\/\1>)?|<img\b([^>]*)\/?>|<iframe\b([^>]*)\/?>',
      caseSensitive: false,
      dotAll: true,
    );

    int lastIndex = 0;
    for (final match in tagRegex.allMatches(sanitized)) {
      if (match.start > lastIndex) {
        final textBefore = sanitized.substring(lastIndex, match.start).trim();
        if (textBefore.isNotEmpty) {
          _addCleanTextBlocks(textBefore, blocks);
        }
      }

      final tagName = (match.group(1) ?? (match.group(0)?.contains('iframe') == true ? 'iframe' : 'img')).toLowerCase();
      final tagAttrs = match.group(2) ?? match.group(5) ?? match.group(6) ?? '';
      final innerContent = match.group(3) ?? '';

      if (tagName == 'h1' || tagName == 'h2' || tagName == 'h3' || tagName == 'h4') {
        blocks.add(_ArticleBlock(
          type: _BlockType.heading,
          text: _stripHtml(innerContent),
          level: int.tryParse(tagName.substring(1)) ?? 2,
        ));
      } else if (tagName == 'pre') {
        final codeText = innerContent.replaceAll(RegExp(r'<\/?code[^>]*>'), '');
        blocks.add(_ArticleBlock(type: _BlockType.code, text: _decodeHtml(codeText.trim())));
      } else if (tagName == 'blockquote' || tagName == 'tip') {
        blocks.add(_ArticleBlock(type: _BlockType.tip, text: _stripHtml(innerContent)));
      } else if (tagName == 'ul') {
        final liRegex = RegExp(r'<li\b[^>]*>(.*?)<\/li>', caseSensitive: false, dotAll: true);
        final items = liRegex.allMatches(innerContent).map((m) => _stripHtml(m.group(1) ?? '')).toList();
        if (items.isNotEmpty) {
          blocks.add(_ArticleBlock(type: _BlockType.list, items: items));
        }
      } else if (tagName == 'img') {
        final srcMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]').firstMatch(tagAttrs);
        final altMatch = RegExp(r'alt=["\x27]([^"\x27]+)["\x27]').firstMatch(tagAttrs);
        if (srcMatch != null) {
          blocks.add(_ArticleBlock(
            type: _BlockType.image,
            imageUrl: srcMatch.group(1),
            caption: altMatch?.group(1),
          ));
        }
      } else if (tagName == 'iframe') {
        final srcMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]').firstMatch(tagAttrs);
        if (srcMatch != null) {
          blocks.add(_ArticleBlock(
            type: _BlockType.video,
            imageUrl: srcMatch.group(1),
          ));
        }
      } else if (tagName == 'p') {
        final cleanP = _stripHtml(innerContent).trim();
        if (cleanP.isNotEmpty) {
          blocks.add(_ArticleBlock(type: _BlockType.paragraph, text: cleanP));
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < sanitized.length) {
      final remaining = sanitized.substring(lastIndex).trim();
      if (remaining.isNotEmpty) {
        _addCleanTextBlocks(remaining, blocks);
      }
    }

    return blocks;
  }

  void _addCleanTextBlocks(String text, List<_ArticleBlock> blocks) {
    final clean = _stripHtml(text).trim();
    if (clean.isEmpty) return;
    final parts = clean.split(RegExp(r'\n\s*\n'));
    for (final p in parts) {
      final t = p.trim();
      if (t.isNotEmpty) {
        blocks.add(_ArticleBlock(type: _BlockType.paragraph, text: t));
      }
    }
  }

  String _stripHtml(String html) {
    return _decodeHtml(html.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  String _decodeHtml(String html) {
    return html
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  Widget _renderElement(BuildContext context, _ArticleBlock block) {
    switch (block.type) {
      case _BlockType.heading:
        final fontSize = block.level == 1 ? 26.0 : (block.level == 2 ? 22.0 : 18.0);
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            block.text ?? '',
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              height: 1.4,
            ),
          ),
        );

      case _BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            block.text ?? '',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.85,
            ),
          ),
        );

      case _BlockType.code:
        return _CodeSnippetBlock(code: block.text ?? '', isDark: isDark);

      case _BlockType.tip:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: isDark ? AppColors.primaryLight : const Color(0xFF3B82F6),
                width: 4,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: isDark ? AppColors.primaryLight : const Color(0xFF3B82F6),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  block.text ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E3A8A),
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.list:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (block.items ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 10),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primary : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.cairo(
                          fontSize: 15.5,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case _BlockType.image:
        if (block.imageUrl == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              block.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
            ),
          ),
        );

      case _BlockType.video:
        if (block.imageUrl == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: YouTubeEmbeddedPlayer(youtubeUrl: block.imageUrl!, height: 320),
        );
    }
  }
}

/// Web-native HTML viewer that executes full Blogger HTML/CSS/iframe
class WebHtmlViewWidget extends StatefulWidget {
  final String rawHtml;
  final bool isDark;

  const WebHtmlViewWidget({
    super.key,
    required this.rawHtml,
    required this.isDark,
  });

  @override
  State<WebHtmlViewWidget> createState() => _WebHtmlViewWidgetState();
}

class _WebHtmlViewWidgetState extends State<WebHtmlViewWidget> {
  late String _viewId;
  double _containerHeight = 650;

  @override
  void initState() {
    super.initState();
    _containerHeight = _estimateHeight(widget.rawHtml);
    _registerView();
  }

  double _estimateHeight(String html) {
    final len = html.length;
    if (len < 600) return 450;
    if (len < 2000) return 700;
    if (len < 4000) return 950;
    return 1300;
  }

  void _registerView() {
    _viewId = 'html_view_${DateTime.now().microsecondsSinceEpoch}_${widget.rawHtml.hashCode.abs()}';
    html_platform.registerHtmlViewFactory(_viewId, widget.rawHtml, isDark: widget.isDark);
  }

  @override
  void didUpdateWidget(WebHtmlViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawHtml != widget.rawHtml || oldWidget.isDark != widget.isDark) {
      _containerHeight = _estimateHeight(widget.rawHtml);
      _registerView();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar with Zoom & Expand controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(
                  color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Text(
                  "محتوى تفاعلي (HTML / Blogger)",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const Spacer(),
                Text(
                  "الارتفاع: ${_containerHeight.toInt()}px",
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.zoom_in_rounded, size: 18),
                  tooltip: "تكبير الارتفاع (+200px)",
                  onPressed: () => setState(() => _containerHeight += 200),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.zoom_out_rounded, size: 18),
                  tooltip: "تصغير الارتفاع (-200px)",
                  onPressed: _containerHeight > 350
                      ? () => setState(() => _containerHeight -= 200)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // HTML iframe sandbox
          SizedBox(
            height: _containerHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              child: HtmlElementView(viewType: _viewId),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BlockType { heading, paragraph, code, tip, list, image, video }

class _ArticleBlock {
  final _BlockType type;
  final String? text;
  final int level;
  final List<String>? items;
  final String? imageUrl;
  final String? caption;

  _ArticleBlock({
    required this.type,
    this.text,
    this.level = 2,
    this.items,
    this.imageUrl,
    this.caption,
  });
}

class _CodeSnippetBlock extends StatefulWidget {
  final String code;
  final bool isDark;

  const _CodeSnippetBlock({required this.code, required this.isDark});

  @override
  State<_CodeSnippetBlock> createState() => _CodeSnippetBlockState();
}

class _CodeSnippetBlockState extends State<_CodeSnippetBlock> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, size: 16, color: Color(0xFF58A6FF)),
                const SizedBox(width: 8),
                Text(
                  "كود برمجي",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF8B949E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _copy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 14,
                          color: _copied ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _copied ? "تم النسخ!" : "نسخ الكود",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: _copied ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Color(0xFFE6EDF3),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
