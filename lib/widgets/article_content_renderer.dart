// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'youtube_embedded_player.dart';
import 'safe_network_image/safe_network_image.dart';

/// Renders rich article and lesson content natively with Flutter widgets.
/// Eliminates all CanvasKit web iframe 50% split / cut-off bugs, eliminates unwanted toolbars,
/// and delivers responsive, pixel-perfect Arabic typography and layout.
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
        "لا يوجد محتوى نصي مضاف لهذا الدرس بعد.",
        style: GoogleFonts.cairo(
          fontSize: 15,
          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final elements = _parseContent(content);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: elements.map((e) => _renderElement(context, e)).toList(),
      ),
    );
  }

  List<_ArticleBlock> _parseContent(String raw) {
    final List<_ArticleBlock> blocks = [];

    // Pre-sanitize: repair broken Unsplash URLs & clean scripts/styles/outer container wrappers
    var sanitized = raw
        .replaceAll(
          RegExp(r'https?://images\.unsplash\.com/photo-151632131[^\s"\x27<>]*', caseSensitive: false),
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=85',
        )
        .replaceAll(RegExp(r'onerror=["\x27][^"\x27]*["\x27]', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?<\/style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?<\/script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<\/?(?:article|html|body|main)[^>]*>', caseSensitive: false), '');

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
          blocks.add(_ArticleBlock(type: _BlockType.heading, text: title, level: 2));
        } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
          final items = trimmed.split('\n').map((l) => l.replaceFirst(RegExp(r'^[-*]\s*'), '')).toList();
          blocks.add(_ArticleBlock(type: _BlockType.list, items: items));
        } else {
          blocks.add(_ArticleBlock(type: _BlockType.paragraph, text: trimmed));
        }
      }
      return blocks;
    }

    // Comprehensive HTML tokenization (matches header, figure, section, table, details, footer, headings, etc.)
    final tagRegex = RegExp(
      r'<(header|footer|figure|details|table|section|div|h[1-6]|p|pre|blockquote|ul|ol|iframe|img)\b([^>]*)>([\s\S]*?)<\/\1>|<img\b([^>]*)\/?>|<iframe\b([^>]*)\/?>',
      caseSensitive: false,
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
      final tagAttrs = match.group(2) ?? match.group(4) ?? match.group(5) ?? '';
      final innerContent = match.group(3) ?? '';

      if (tagName == 'header') {
        // Parse lesson header banner (Title, subtitle, brand, badge)
        final brandMatch = RegExp(r'<div[^>]*>([\s\S]*?)<\/div>', caseSensitive: false).firstMatch(innerContent);
        final titleMatch = RegExp(r'<h1[^>]*>([\s\S]*?)<\/h1>', caseSensitive: false).firstMatch(innerContent);
        final subMatch = RegExp(r'<p[^>]*>([\s\S]*?)<\/p>', caseSensitive: false).firstMatch(innerContent);
        final badgeMatches = RegExp(r'<div[^>]*>([\s\S]*?)<\/div>', caseSensitive: false).allMatches(innerContent).toList();

        final brand = brandMatch != null ? _stripHtml(brandMatch.group(1)!) : 'Eslam Atef | Code & AI';
        final title = titleMatch != null ? _stripHtml(titleMatch.group(1)!) : '';
        final subtitle = subMatch != null ? _stripHtml(subMatch.group(1)!) : '';
        final badge = badgeMatches.length > 1 ? _stripHtml(badgeMatches.last.group(1)!) : '';

        blocks.add(_ArticleBlock(
          type: _BlockType.headerBanner,
          text: title,
          subtitle: subtitle,
          brand: brand,
          badge: badge,
        ));
      } else if (tagName == 'figure') {
        // Parse figure (image + figcaption)
        final imgMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(innerContent);
        final capMatch = RegExp(r'<figcaption[^>]*>([\s\S]*?)<\/figcaption>', caseSensitive: false).firstMatch(innerContent);
        if (imgMatch != null) {
          blocks.add(_ArticleBlock(
            type: _BlockType.image,
            imageUrl: imgMatch.group(1),
            caption: capMatch != null ? _stripHtml(capMatch.group(1)!) : null,
          ));
        }
      } else if (tagName.startsWith('h') && tagName.length == 2) {
        blocks.add(_ArticleBlock(
          type: _BlockType.heading,
          text: _stripHtml(innerContent),
          level: int.tryParse(tagName.substring(1)) ?? 2,
        ));
      } else if (tagName == 'table') {
        // Parse Table
        final rows = _parseHtmlTable(innerContent);
        if (rows.isNotEmpty) {
          blocks.add(_ArticleBlock(
            type: _BlockType.table,
            tableRows: rows,
          ));
        }
      } else if (tagName == 'details') {
        // Parse Accordion / Quiz answers
        final sumMatch = RegExp(r'<summary[^>]*>([\s\S]*?)<\/summary>', caseSensitive: false).firstMatch(innerContent);
        final bodyText = _stripHtml(innerContent.replaceAll(RegExp(r'<summary[\s\S]*?<\/summary>', caseSensitive: false), ''));
        blocks.add(_ArticleBlock(
          type: _BlockType.accordion,
          text: sumMatch != null ? _stripHtml(sumMatch.group(1)!) : "اضغط لعرض التفاصيل",
          subtitle: bodyText.trim(),
        ));
      } else if (tagName == 'footer') {
        // Parse lesson summary footer
        final titleMatch = RegExp(r'<h2[^>]*>([\s\S]*?)<\/h2>', caseSensitive: false).firstMatch(innerContent);
        final pMatches = RegExp(r'<p[^>]*>([\s\S]*?)<\/p>', caseSensitive: false).allMatches(innerContent).map((m) => _stripHtml(m.group(1)!)).toList();
        blocks.add(_ArticleBlock(
          type: _BlockType.footerCard,
          text: titleMatch != null ? _stripHtml(titleMatch.group(1)!) : "خلاصة الدرس",
          items: pMatches,
        ));
      } else if (tagName == 'pre') {
        final codeText = innerContent.replaceAll(RegExp(r'<\/?code[^>]*>'), '');
        blocks.add(_ArticleBlock(type: _BlockType.code, text: _decodeHtml(codeText.trim())));
      } else if (tagName == 'blockquote') {
        blocks.add(_ArticleBlock(type: _BlockType.tip, text: _stripHtml(innerContent)));
      } else if (tagName == 'ul' || tagName == 'ol') {
        final liRegex = RegExp(r'<li\b[^>]*>([\s\S]*?)<\/li>', caseSensitive: false);
        final items = liRegex.allMatches(innerContent).map((m) => _stripHtml(m.group(1) ?? '')).toList();
        if (items.isNotEmpty) {
          blocks.add(_ArticleBlock(type: _BlockType.list, items: items));
        }
      } else if (tagName == 'iframe') {
        final srcMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(tagAttrs.isNotEmpty ? tagAttrs : innerContent);
        if (srcMatch != null) {
          blocks.add(_ArticleBlock(
            type: _BlockType.video,
            imageUrl: srcMatch.group(1),
          ));
        }
      } else if (tagName == 'img') {
        final srcMatch = RegExp(r'src=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(tagAttrs);
        final altMatch = RegExp(r'alt=["\x27]([^"\x27]+)["\x27]', caseSensitive: false).firstMatch(tagAttrs);
        if (srcMatch != null) {
          blocks.add(_ArticleBlock(
            type: _BlockType.image,
            imageUrl: srcMatch.group(1),
            caption: altMatch?.group(1),
          ));
        }
      } else if (tagName == 'section' || tagName == 'div') {
        // Check if it's a flow diagram (Data -> Info -> Knowledge)
        if (innerContent.contains('⬇') || (innerContent.contains('البيانات') && innerContent.contains('المعلومات') && innerContent.contains('المعرفة') && innerContent.contains('text-align:center'))) {
          blocks.add(_ArticleBlock(type: _BlockType.diagram, text: _stripHtml(innerContent)));
        } else {
          // Recursively parse inner content of section
          final subBlocks = _parseContent(innerContent);
          // If section has a colored background in style
          final bgMatch = RegExp(r'background:\s*(#[a-fA-F0-9]{3,6}|rgba?\([^)]+\))', caseSensitive: false).firstMatch(tagAttrs);
          if (bgMatch != null && subBlocks.isNotEmpty) {
            blocks.add(_ArticleBlock(
              type: _BlockType.callout,
              subBlocks: subBlocks,
              bgColorHex: bgMatch.group(1),
            ));
          } else {
            blocks.addAll(subBlocks);
          }
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

  List<List<String>> _parseHtmlTable(String tableHtml) {
    final List<List<String>> rows = [];
    final trRegex = RegExp(r'<tr\b[^>]*>([\s\S]*?)<\/tr>', caseSensitive: false);
    for (final trMatch in trRegex.allMatches(tableHtml)) {
      final rowContent = trMatch.group(1) ?? '';
      final cellRegex = RegExp(r'<(?:td|th)\b[^>]*>([\s\S]*?)<\/(?:td|th)>', caseSensitive: false);
      final cells = cellRegex.allMatches(rowContent).map((c) => _stripHtml(c.group(1) ?? '').trim()).toList();
      if (cells.isNotEmpty) {
        rows.add(cells);
      }
    }
    return rows;
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
    return _decodeHtml(html.replaceAll(RegExp(r'<[^>]*>'), ' ')).replaceAll(RegExp(r'\s+'), ' ').trim();
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
      case _BlockType.headerBanner:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF071B42), Color(0xFF064E8A)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E8A).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              if ((block.brand ?? '').isNotEmpty)
                Text(
                  block.brand!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF36D5F4),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                block.text ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              if ((block.subtitle ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  block.subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD9EFFF),
                  ),
                ),
              ],
              if ((block.badge ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7EB4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    block.badge!,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );

      case _BlockType.heading:
        final fontSize = block.level == 1 ? 24.0 : (block.level == 2 ? 20.0 : 17.0);
        return Container(
          margin: const EdgeInsets.only(top: 28, bottom: 14),
          padding: const EdgeInsets.only(right: 14),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Color(0xFF16C5E8), width: 5),
            ),
          ),
          child: Text(
            block.text ?? '',
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF087EAE),
              height: 1.35,
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
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              height: 1.9,
              fontWeight: FontWeight.w500,
            ),
          ),
        );

      case _BlockType.list:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (block.items ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 9, left: 10),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.cairo(
                          fontSize: 15.5,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          height: 1.75,
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SafeNetworkImage(
                  imageUrl: block.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 320,
                ),
              ),
              if ((block.caption ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  block.caption!,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );

      case _BlockType.video:
        if (block.imageUrl == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: YouTubeEmbeddedPlayer(youtubeUrl: block.imageUrl!, height: 340),
          ),
        );

      case _BlockType.table:
        final rows = block.tableRows ?? [];
        if (rows.isEmpty) return const SizedBox.shrink();
        final headerRow = rows.first;
        final dataRows = rows.length > 1 ? rows.sublist(1) : <List<String>>[];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFF075985)),
                    children: headerRow.map((cell) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          cell,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ...dataRows.asMap().entries.map((entry) {
                    final isEven = entry.key.isEven;
                    return TableRow(
                      decoration: BoxDecoration(
                        color: isDark
                            ? (isEven ? const Color(0xFF0F172A) : const Color(0xFF1E293B))
                            : (isEven ? Colors.white : const Color(0xFFF8FAFC)),
                      ),
                      children: entry.value.map((cell) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          child: Text(
                            cell,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        );

      case _BlockType.accordion:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE9F8FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              block.text ?? '',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF075985),
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  block.subtitle ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.diagram:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 22),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF071B42),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDiagramStep("📥 البيانات (Data)", "حقائق وأرقام أولية"),
              const SizedBox(height: 10),
              const Icon(Icons.arrow_downward_rounded, color: Color(0xFF35D4F5), size: 28),
              const SizedBox(height: 10),
              _buildDiagramStep("📊 المعلومات (Information)", "بيانات تمت معالجتها وتنظيمها"),
              const SizedBox(height: 10),
              const Icon(Icons.arrow_downward_rounded, color: Color(0xFF35D4F5), size: 28),
              const SizedBox(height: 10),
              _buildDiagramStep("🧠 المعرفة (Knowledge)", "فهم واستنتاج لاتخاذ القرار"),
            ],
          ),
        );

      case _BlockType.callout:
        final isGreen = (block.bgColorHex ?? '').contains('f0fdf4') || (block.bgColorHex ?? '').contains('green');
        final borderColor = isGreen ? const Color(0xFF86EFAC) : const Color(0xFFBAE6FD);
        final bgColor = isDark
            ? (isGreen ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFF0C4A6E).withValues(alpha: 0.3))
            : (isGreen ? const Color(0xFFF0FDF4) : const Color(0xFFEDF9FF));

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 18),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: (block.subBlocks ?? []).map((sub) => _renderElement(context, sub)).toList(),
          ),
        );

      case _BlockType.footerCard:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 26),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF071B42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E3A8A)),
          ),
          child: Column(
            children: [
              Text(
                block.text ?? '🚀 خلاصة الدرس',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF36D5F4),
                ),
              ),
              const SizedBox(height: 14),
              ...(block.items ?? []).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 15.5,
                      color: const Color(0xFFE2E8F0),
                      height: 1.8,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              const Divider(color: Color(0xFF315276)),
              const SizedBox(height: 12),
              Text(
                "Eslam Atef | Code & AI",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Think. Code. Build with AI.",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF36D5F4),
                ),
              ),
            ],
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
            border: const Border(
              right: BorderSide(color: Color(0xFF00E5FF), width: 4),
            ),
          ),
          child: Text(
            block.text ?? '',
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E3A8A),
              height: 1.75,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  Widget _buildDiagramStep(String title, String desc) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2D6B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            desc,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF38BDF8),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BlockType {
  headerBanner,
  heading,
  paragraph,
  code,
  tip,
  list,
  image,
  video,
  table,
  accordion,
  footerCard,
  callout,
  diagram,
}

class _ArticleBlock {
  final _BlockType type;
  final String? text;
  final String? subtitle;
  final String? brand;
  final String? badge;
  final int level;
  final List<String>? items;
  final String? imageUrl;
  final String? caption;
  final List<List<String>>? tableRows;
  final List<_ArticleBlock>? subBlocks;
  final String? bgColorHex;

  _ArticleBlock({
    required this.type,
    this.text,
    this.subtitle,
    this.brand,
    this.badge,
    this.level = 2,
    this.items,
    this.imageUrl,
    this.caption,
    this.tableRows,
    this.subBlocks,
    this.bgColorHex,
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
                  style: GoogleFonts.firaCode(
                    fontSize: 13.5,
                    color: const Color(0xFFE6EDF3),
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
