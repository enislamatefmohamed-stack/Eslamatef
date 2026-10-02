import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Renders rich article content supporting HTML-like markup and formatted text:
/// - `<h2>`, `<h3>` for section titles
/// - `<p>` for paragraphs
/// - `<pre><code>` for code snippets with copy button
/// - `<img src="..." alt="...">` for embedded images
/// - `<blockquote>` or `<tip>` for highlighted notes
/// - `<ul><li>` for bullet points
/// - Fallback clean text formatting for standard text
class ArticleContentRenderer extends StatelessWidget {
  final String content;
  final bool isDark;

  const ArticleContentRenderer({
    super.key,
    required this.content,
    required this.isDark,
  });

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

    final elements = _parseContent(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: elements.map((e) => _renderElement(context, e)).toList(),
    );
  }

  List<_ArticleBlock> _parseContent(String raw) {
    final List<_ArticleBlock> blocks = [];

    // Check if content has HTML tags
    final hasHtml = raw.contains('<') && raw.contains('>');

    if (!hasHtml) {
      // Plain text split by double newlines into paragraphs and code
      final paragraphs = raw.split(RegExp(r'\n\s*\n'));
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
      r'<(h[1-4]|p|pre|blockquote|tip|ul|img)\b([^>]*)>(.*?)(<\/\1>)?|<img\b([^>]*)\/?>',
      caseSensitive: false,
      dotAll: true,
    );

    int lastIndex = 0;
    for (final match in tagRegex.allMatches(raw)) {
      if (match.start > lastIndex) {
        final textBefore = raw.substring(lastIndex, match.start).trim();
        if (textBefore.isNotEmpty) {
          _addCleanTextBlocks(textBefore, blocks);
        }
      }

      final fullTag = match.group(0) ?? '';
      final tagName = (match.group(1) ?? 'img').toLowerCase();
      final tagAttrs = match.group(2) ?? match.group(5) ?? '';
      final innerContent = match.group(3) ?? '';

      if (tagName == 'h1' || tagName == 'h2' || tagName == 'h3' || tagName == 'h4') {
        blocks.add(_ArticleBlock(
          type: _BlockType.heading,
          text: _stripHtml(innerContent),
          level: int.tryParse(tagName.substring(1)) ?? 2,
        ));
      } else if (tagName == 'p') {
        blocks.add(_ArticleBlock(
          type: _BlockType.paragraph,
          text: _stripHtml(innerContent),
        ));
      } else if (tagName == 'pre') {
        String code = innerContent;
        code = code.replaceAll(RegExp(r'<\/?code[^>]*>', caseSensitive: false), '');
        blocks.add(_ArticleBlock(
          type: _BlockType.code,
          text: code.trim(),
        ));
      } else if (tagName == 'blockquote' || tagName == 'tip') {
        blocks.add(_ArticleBlock(
          type: _BlockType.quote,
          text: _stripHtml(innerContent),
        ));
      } else if (tagName == 'ul') {
        final liRegex = RegExp(r'<li\b[^>]*>(.*?)<\/li>', caseSensitive: false, dotAll: true);
        final items = <String>[];
        for (final li in liRegex.allMatches(innerContent)) {
          items.add(_stripHtml(li.group(1) ?? ''));
        }
        if (items.isNotEmpty) {
          blocks.add(_ArticleBlock(type: _BlockType.list, items: items));
        }
      } else if (tagName == 'img' || fullTag.startsWith('<img')) {
        final srcMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(tagAttrs);
        final altMatch = RegExp(r'alt=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(tagAttrs);
        if (srcMatch != null) {
          blocks.add(_ArticleBlock(
            type: _BlockType.image,
            src: srcMatch.group(1) ?? '',
            text: altMatch?.group(1) ?? '',
          ));
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < raw.length) {
      final textAfter = raw.substring(lastIndex).trim();
      if (textAfter.isNotEmpty) {
        _addCleanTextBlocks(textAfter, blocks);
      }
    }

    if (blocks.isEmpty) {
      blocks.add(_ArticleBlock(type: _BlockType.paragraph, text: raw.trim()));
    }

    return blocks;
  }

  void _addCleanTextBlocks(String text, List<_ArticleBlock> blocks) {
    final clean = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (clean.isNotEmpty) {
      blocks.add(_ArticleBlock(type: _BlockType.paragraph, text: clean));
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  Widget _renderElement(BuildContext context, _ArticleBlock element) {
    switch (element.type) {
      case _BlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  element.text ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: element.level == 1 ? 24 : (element.level == 2 ? 20 : 17),
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            element.text ?? '',
            style: GoogleFonts.cairo(
              fontSize: 15,
              height: 1.8,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              fontWeight: FontWeight.w400,
            ),
          ),
        );

      case _BlockType.code:
        return _CodeSnippetBlock(code: element.text ?? '', isDark: isDark);

      case _BlockType.image:
        return _ArticleImageBlock(src: element.src ?? '', caption: element.text ?? '', isDark: isDark);

      case _BlockType.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.08 : 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border(
              right: const BorderSide(color: Color(0xFF00E5FF), width: 4),
              top: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              left: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF00E5FF), size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  element.text ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.list:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (element.items ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 10),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          height: 1.7,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
    }
  }
}

enum _BlockType { heading, paragraph, code, image, quote, list }

class _ArticleBlock {
  final _BlockType type;
  final String? text;
  final String? src;
  final int level;
  final List<String>? items;

  _ArticleBlock({
    required this.type,
    this.text,
    this.src,
    this.level = 2,
    this.items,
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

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF070B14),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text(
                      "Source Code",
                      style: GoogleFonts.firaCode(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _copyCode,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 13,
                          color: _copied ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? "تم النسخ" : "نسخ الكود",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _copied ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                widget.code,
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  color: const Color(0xFF38BDF8),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleImageBlock extends StatelessWidget {
  final String src;
  final String caption;
  final bool isDark;

  const _ArticleImageBlock({required this.src, required this.caption, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isNetwork = src.startsWith('http://') || src.startsWith('https://');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 480),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: isNetwork
                  ? Image.network(
                      src,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _imageFallback(),
                    )
                  : Image.asset(
                      src,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _imageFallback(),
                    ),
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              caption,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 200,
      color: isDark ? const Color(0xFF131D33) : const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_rounded, size: 36, color: Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(
              "تعذر تحميل الصورة من المسار المحدد",
              style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
