// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/site_data_service.dart';
import '../services/auth_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/interactive_html_view/interactive_html_view.dart';
import '../widgets/unified_app_bar.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final _dataService = SiteDataService.instance;
  Map<String, dynamic>? _activeArticle;
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  StreamSubscription? _popStateSubscription;

  bool _isItemPublished(Map<String, dynamic> item) {
    final auth = AuthService.instance;
    final userEmail = auth.currentUser?.email?.toLowerCase() ?? '';
    final isAdmin = auth.isAdmin || userEmail == 'islamatef01016834012@gmail.com';
    if (isAdmin) return true;

    if (item['isPublished'] == false || item['status'] == 'مسودة') {
      return false;
    }

    final schedStr = (item['scheduledPublishDate'] ?? item['scheduledDate'])?.toString();
    if (schedStr != null && schedStr.isNotEmpty) {
      try {
        final schedDate = DateTime.parse(schedStr);
        if (schedDate.isAfter(DateTime.now())) {
          return false;
        }
      } catch (_) {}
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkUrlParameters();
    _dataService.addListener(_onDataChanged);

    try {
      _popStateSubscription = html.window.onPopState.listen((event) {
        if (!mounted) return;
        setState(() {
          _checkUrlParameters();
        });
      });
    } catch (_) {}
  }

  void _checkUrlParameters() {
    try {
      final uri = Uri.base;
      final Map<String, String> params = Map.from(uri.queryParameters);
      if (uri.hasFragment && uri.fragment.contains('?')) {
        try {
          final queryPart = uri.fragment.substring(uri.fragment.indexOf('?') + 1);
          params.addAll(Uri.splitQueryString(queryPart));
        } catch (_) {}
      }

      final articleId = params['id'] ?? params['article'] ?? params['articleId'];
      if (articleId != null && articleId.isNotEmpty) {
        final matched = _dataService.articles.where((a) => a['id'].toString() == articleId).toList();
        if (matched.isNotEmpty && _isItemPublished(matched.first)) {
          _activeArticle = matched.first;
        } else {
          _activeArticle = null;
        }
      } else {
        _activeArticle = null;
      }
    } catch (_) {}
  }

  void _syncUrl({bool replace = false}) {
    try {
      String newUrl;
      if (_activeArticle != null) {
        final aid = (_activeArticle!['id'] ?? '').toString();
        newUrl = '/blog?id=$aid';
      } else {
        newUrl = '/blog';
      }

      final currentUri = Uri.base;
      final currentPathAndQuery = '${currentUri.path}${currentUri.hasQuery ? '?${currentUri.query}' : ''}';
      if (currentPathAndQuery == newUrl) return;

      if (replace) {
        html.window.history.replaceState(null, '', newUrl);
      } else {
        html.window.history.pushState(null, '', newUrl);
      }
    } catch (_) {}
  }

  void _onDataChanged() {
    if (mounted) {
      if (_activeArticle == null) {
        _checkUrlParameters();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _popStateSubscription?.cancel();
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _handleBack() {
    if (_activeArticle != null) {
      setState(() => _activeArticle = null);
      _syncUrl(replace: true);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  void _copyLink(String url, String message) {
    Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _extractThumbnail(Map<String, dynamic> article) {
    final explicit = (article['image'] ?? article['imageUrl'] ?? '').toString();
    if (explicit.isNotEmpty && !explicit.contains('placeholder')) return explicit;

    final code = (article['htmlCode'] ?? article['content'] ?? '').toString();
    final imgMatch = RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false).firstMatch(code) ??
        RegExp(r"<img[^>]+src='([^'>]+)'", caseSensitive: false).firstMatch(code);
    if (imgMatch != null && imgMatch.group(1) != null) {
      return imgMatch.group(1)!;
    }

    return '';
  }

  String _extractSnippet(Map<String, dynamic> article) {
    final code = (article['htmlCode'] ?? article['content'] ?? '').toString();
    final clean = code
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (clean.length > 150) {
      return '${clean.substring(0, 150)}...';
    }
    return clean.isNotEmpty ? clean : 'اضغط لقراءة تفاصيل المقال كاملاً...';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _activeArticle == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/blog') : null,
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SelectionArea(
            child: SafeArea(
              child: Column(
                children: [
                  UnifiedAppHeader(
                    currentRoute: '/blog',
                    pageTitle: 'المقالات والتدوينات التقنية',
                    showBackButton: _activeArticle != null,
                    onBack: _activeArticle != null ? _handleBack : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 28),
                            _activeArticle != null
                                ? _buildArticleDetailView(context, isMobile, isDark)
                                : _buildArticlesCatalog(context, isMobile, isDark),
                            const SizedBox(height: 60),
                            const UnifiedAppFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: Articles Catalog
  // ==========================================
  Widget _buildArticlesCatalog(BuildContext context, bool isMobile, bool isDark) {
    final allArticles = _dataService.articles.where(_isItemPublished).toList();
    final categories = ['الكل', ..._dataService.articleCategories];

    final filtered = allArticles.where((a) {
      final title = (a['title'] ?? '').toString().toLowerCase();
      final content = (a['htmlCode'] ?? a['content'] ?? '').toString().toLowerCase();
      final cat = (a['category'] ?? '').toString();

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery.toLowerCase()) ||
          content.contains(_searchQuery.toLowerCase());

      final matchesCat = _selectedCategory == 'الكل' || cat == _selectedCategory;

      return matchesSearch && matchesCat;
    }).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Header
            Container(
              padding: EdgeInsets.all(isMobile ? 24 : 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                      : [Colors.white, const Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "📚 المقالات والتدوينات البرمجية",
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF0284C7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "مدونة التقنية والبرمجة والذكاء الاصطناعي",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 22 : 30,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      "شروحات مقالية متخصصة، أدلة إرشادية ممتعة، وأحدث أسرار علوم الحاسب والذكاء الاصطناعي مع م. إسلام عاطف.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 14 : 16,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: "ابحث في المقالات والمواضيع...",
                        hintStyle: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0284C7)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Categories Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final count = cat == 'الكل'
                      ? allArticles.length
                      : allArticles.where((a) => (a['category'] ?? '') == cat).length;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0284C7)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cat,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "$count",
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Articles Grid / Empty State
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.article_outlined, size: 54, color: Colors.grey),
                    const SizedBox(height: 14),
                    Text(
                      _searchQuery.isNotEmpty
                          ? "لم يتم العثور على مقالات تطابق بحثك"
                          : "لا توجد مقالات منشورة في هذا التصنيف حالياً",
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "سيتم إضافة مقالات وتدوينات ممتعة قريباً جداً، ترقبوا كل جديد!",
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);
                  final itemWidth = (width - ((crossAxisCount - 1) * 20)) / crossAxisCount;

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: filtered.map((article) {
                      return SizedBox(
                        width: itemWidth,
                        child: _buildArticleCard(context, article, isDark),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article, bool isDark) {
    final title = (article['title'] ?? 'مقال جديد').toString();
    final category = (article['category'] ?? 'عام').toString();
    final snippet = _extractSnippet(article);
    final thumb = _extractThumbnail(article);

    return InkWell(
      onTap: () {
        setState(() => _activeArticle = article);
        _syncUrl();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image / Thumbnail
            if (thumb.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => _buildPlaceholderImage(category, isDark),
                ),
              )
            else
              _buildPlaceholderImage(category, isDark),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF0284C7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Snippet
                  Text(
                    snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "اقرأ المقال كاملاً",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF0284C7)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String category, bool isDark) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 36, color: Color(0xFF0284C7)),
            const SizedBox(height: 6),
            Text(
              category,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 2: Single Article Details View
  // ==========================================
  Widget _buildArticleDetailView(BuildContext context, bool isMobile, bool isDark) {
    final article = _activeArticle!;
    final title = (article['title'] ?? 'مقال').toString();
    final category = (article['category'] ?? 'عام').toString();
    final htmlCode = (article['htmlCode'] ?? article['content'] ?? '').toString();
    final articleId = (article['id'] ?? '').toString();

    final isFullHtml = htmlCode.contains('<!DOCTYPE') ||
        htmlCode.contains('<html') ||
        htmlCode.contains('class="article-header') ||
        htmlCode.contains('<header');

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top action buttons bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _handleBack,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text("العودة لكافة المقالات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    side: const BorderSide(color: Color(0xFF0284C7)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copyLink(
                    'https://eslamatef-sepia.vercel.app/blog?id=$articleId',
                    "تم نسخ رابط المقال المباشر 📋",
                  ),
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: Text("مشاركة المقال", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // If not a full stand-alone HTML page with its own header, show the title & meta card
            if (!isFullHtml) ...[
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF0284C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 22 : 30,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Content Viewer
            if (isFullHtml)
              InteractiveHtmlView(
                id: 'article_content_${articleId.isNotEmpty ? articleId : 'view'}',
                rawHtml: htmlCode,
                height: (htmlCode.length * 0.12).clamp(800.0, 5000.0),
              )
            else
              Container(
                padding: EdgeInsets.all(isMobile ? 18 : 32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: (htmlCode.contains('<div') || htmlCode.contains('<p') || htmlCode.contains('<table'))
                    ? InteractiveHtmlView(
                        id: 'article_content_${articleId.isNotEmpty ? articleId : 'view'}',
                        rawHtml: htmlCode,
                        height: (htmlCode.length * 0.12).clamp(600.0, 4000.0),
                      )
                    : ArticleContentRenderer(content: htmlCode, isDark: isDark),
              ),

            const SizedBox(height: 28),

            // Bottom Return Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _handleBack,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text("العودة لكافة المقالات", style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
