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
import '../widgets/safe_network_image/safe_network_image.dart';
import '../widgets/auth_modal.dart';

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
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmittingComment = false;

  bool _isItemPublished(Map<String, dynamic> item) {
    if (item['status'] == 'مسودة') {
      final auth = AuthService.instance;
      final userEmail = auth.currentUser?.email?.toLowerCase() ?? '';
      return auth.isAdmin || userEmail == 'islamatef01016834012@gmail.com';
    }

    if (item['status'] == 'مجدول') {
      final schedStr = (item['scheduledPublishDate'] ?? item['scheduledDate'])?.toString();
      if (schedStr != null && schedStr.isNotEmpty) {
        try {
          final schedDate = DateTime.parse(schedStr).toLocal();
          if (schedDate.isAfter(DateTime.now())) {
            final auth = AuthService.instance;
            final userEmail = auth.currentUser?.email?.toLowerCase() ?? '';
            return auth.isAdmin || userEmail == 'islamatef01016834012@gmail.com';
          }
        } catch (_) {}
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkUrlParameters();
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

      final routeSettings = ModalRoute.of(context)?.settings;
      if (routeSettings != null) {
        if (routeSettings.arguments is Map) {
          final args = routeSettings.arguments as Map;
          if (args['id'] != null) params['id'] = args['id'].toString();
          if (args['articleId'] != null) params['id'] = args['articleId'].toString();
        }
        final routeName = routeSettings.name ?? '';
        final routeUri = Uri.tryParse(routeName);
        if (routeUri != null && routeUri.hasQuery) {
          params.addAll(routeUri.queryParameters);
        }
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
      if (_activeArticle != null) {
        final aid = _activeArticle!['id']?.toString();
        final updated = _dataService.articles.where((a) => a['id'].toString() == aid).toList();
        if (updated.isNotEmpty) {
          _activeArticle = updated.first;
        }
      } else {
        _checkUrlParameters();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _popStateSubscription?.cancel();
    _commentCtrl.dispose();
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
    final explicit = (article['imageUrl'] ?? article['image'] ?? article['thumbnail'] ?? article['cover'] ?? '').toString();
    if (explicit.isNotEmpty && !explicit.contains('placeholder')) {
      return sanitizeImageUrl(explicit);
    }

    final code = (article['htmlCode'] ?? article['content'] ?? '').toString();
    final imgMatch = RegExp(r'''<img[^>]*\bsrc\s*=\s*["']?([^"'>\s]+)["']?''', caseSensitive: false).firstMatch(code);
    if (imgMatch != null && imgMatch.group(1) != null) {
      return sanitizeImageUrl(imgMatch.group(1)!);
    }

    final mdMatch = RegExp(r'!\[.*?\]\((https?://[^\s\)]+)\)').firstMatch(code);
    if (mdMatch != null && mdMatch.group(1) != null) {
      return sanitizeImageUrl(mdMatch.group(1)!);
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
                child: SafeNetworkImage(
                  imageUrl: thumb,
                  fit: BoxFit.cover,
                  errorWidget: _buildPlaceholderImage(category, isDark),
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

            const SizedBox(height: 36),

            // Comments Section (التعليقات للمسجلين فقط)
            _buildCommentsSection(context, article, isMobile, isDark),

            const SizedBox(height: 32),

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

  // ==========================================
  // VIEW 3: Comments Section (التعليقات للمسجلين فقط)
  // ==========================================
  Widget _buildCommentsSection(BuildContext context, Map<String, dynamic> article, bool isMobile, bool isDark) {
    final articleId = (article['id'] ?? '').toString();
    final rawComments = List<Map<String, dynamic>>.from(article['comments'] ?? []);
    // Sort comments descending by createdAt
    rawComments.sort((a, b) {
      final aDate = (a['createdAt'] ?? '').toString();
      final bDate = (b['createdAt'] ?? '').toString();
      return bDate.compareTo(aDate);
    });

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF0284C7), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "التعليقات والمناقشات",
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  "${rawComments.length} تعليق",
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Add Comment Box (Logged-in Only vs Guest Prompt)
          ListenableBuilder(
            listenable: AuthService.instance,
            builder: (ctx, _) {
              final auth = AuthService.instance;
              final user = auth.currentUser;

              if (user != null) {
                // Logged-in User: Can write comment
                final userName = user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!
                    : (user.email?.split('@').first ?? 'مستخدم');
                final userPhoto = user.photoURL ?? '';

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF0284C7),
                            backgroundImage: userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
                            child: userPhoto.isEmpty
                                ? Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "عضو مسجل بالموقع",
                                style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: "شاركنا برأيك أو سؤالك حول المقال...",
                          hintStyle: GoogleFonts.cairo(fontSize: 13.5, color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmittingComment
                              ? null
                              : () async {
                                  final text = _commentCtrl.text.trim();
                                  if (text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("يرجى كتابة نص التعليق أولاً ✍️", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                        backgroundColor: const Color(0xFFEF4444),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isSubmittingComment = true);
                                  final messenger = ScaffoldMessenger.of(context);
                                  try {
                                    await _dataService.addArticleComment(
                                      articleId: articleId,
                                      text: text,
                                      userName: userName,
                                      userEmail: user.email ?? '',
                                      userPhoto: userPhoto,
                                      userId: user.uid,
                                    );

                                    _commentCtrl.clear();
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text("تم نشر تعليقك بنجاح ✅ شكراً لمشاركتك!", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                          backgroundColor: const Color(0xFF059669),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text("حدث خطأ أثناء إرسال التعليق: $e", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                          backgroundColor: const Color(0xFFEF4444),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _isSubmittingComment = false);
                                  }
                                },
                          icon: _isSubmittingComment
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded, size: 16),
                          label: Text(
                            _isSubmittingComment ? "جارٍ الإرسال..." : "إرسال التعليق",
                            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Not Logged-in: Prompt Card to Log In
                return Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFFEFF6FF), const Color(0xFFF8FAFC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded, color: Color(0xFF0284C7), size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "التعليقات متاحة فقط للأعضاء المسجلين",
                              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "سجّل دخولك الآن بضغطة واحدة للمشاركة برأيك، وطرح أسئلتك على المقال، والتفاعل مع مجتمع المنصة!",
                              style: GoogleFonts.cairo(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: () => AuthModal.show(context),
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: Text("تسجيل الدخول", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 28),

          // 3. Comments List
          if (rawComments.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D33).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 38, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "لا توجد تعليقات بعد",
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "كن أول من يشارك برأيه ويترك تعليقاً على هذا المقال! ✍️",
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rawComments.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final comment = rawComments[i];
                final cId = (comment['id'] ?? '').toString();
                final cText = (comment['text'] ?? '').toString();
                final cUser = (comment['userName'] ?? 'مستخدم').toString();
                final cEmail = (comment['userEmail'] ?? '').toString();
                final cPhoto = (comment['userPhoto'] ?? '').toString();
                final cUserId = (comment['userId'] ?? '').toString();
                final cDate = (comment['createdAt'] ?? '').toString();

                final auth = AuthService.instance;
                final curUser = auth.currentUser;
                final isOwner = curUser != null && (curUser.uid == cUserId || curUser.email == cEmail);
                final canDelete = auth.isAdmin || isOwner;
                final isAuthor = cEmail.toLowerCase() == 'islamatef01016834012@gmail.com';

                String displayDate = '';
                if (cDate.isNotEmpty) {
                  try {
                    final dt = DateTime.parse(cDate).toLocal();
                    displayDate = '${dt.year}/${dt.month}/${dt.day} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  } catch (_) {
                    displayDate = cDate;
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isAuthor
                          ? const Color(0xFF0284C7).withValues(alpha: 0.4)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      width: isAuthor ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: isAuthor ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                                backgroundImage: cPhoto.isNotEmpty ? NetworkImage(cPhoto) : null,
                                child: cPhoto.isEmpty
                                    ? Text(
                                        cUser.isNotEmpty ? cUser[0].toUpperCase() : 'U',
                                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        cUser,
                                        style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold),
                                      ),
                                      if (isAuthor) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "الكاتب ✍️",
                                            style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (displayDate.isNotEmpty)
                                    Text(
                                      displayDate,
                                      style: GoogleFonts.cairo(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (canDelete)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                              tooltip: "حذف التعليق",
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (dctx) => AlertDialog(
                                    title: Text("حذف التعليق", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                    content: Text("هل أنت متأكد من رغبتك في حذف هذا التعليق؟", style: GoogleFonts.cairo()),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dctx, false),
                                        child: Text("إلغاء", style: GoogleFonts.cairo()),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(dctx, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                        child: Text("حذف", style: GoogleFonts.cairo(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _dataService.deleteArticleComment(articleId: articleId, commentId: cId);
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text("تم حذف التعليق بنجاح", style: GoogleFonts.cairo()),
                                        backgroundColor: const Color(0xFF059669),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        cText,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
