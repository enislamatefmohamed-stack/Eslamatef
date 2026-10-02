import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/social_icons.dart';
import '../services/site_data_service.dart';
import '../widgets/article_content_renderer.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final _dataService = SiteDataService.instance;
  String _selectedCategory = "الكل";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SafeArea(
          child: Column(
            children: [
              // Top Nav Header
              _buildPageHeader(context, isMobile, isDark),

              // Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      _buildLessonsBlogContent(context, isMobile, isDark, screenWidth),
                      const SizedBox(height: 60),
                      _buildPageFooter(context, isMobile, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo & Title
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ArabicData.brandName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        "مدونة الدروس والمقالات التقنية",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Theme Toggle & Back to Home Button
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
                    ),
                    tooltip: isDark ? "الوضع النهاري" : "الوضع الليلي",
                    onPressed: () => AppThemeManager.toggleTheme(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      "الرئيسية",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                      foregroundColor: const Color(0xFF3B82F6),
                      side: BorderSide(color: isDark ? AppColors.borderLightDark : AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildLessonsBlogContent(BuildContext context, bool isMobile, bool isDark, double screenWidth) {
    final allLessons = _dataService.lessons;

    // Filter categories dynamically
    final categories = ["الكل"];
    for (final l in allLessons) {
      final cat = l['category'] ?? l['subject'] ?? 'عام';
      if (!categories.contains(cat)) categories.add(cat);
    }

    // Filtered list
    final filtered = allLessons.where((l) {
      final cat = l['category'] ?? l['subject'] ?? 'عام';
      final matchesCategory = _selectedCategory == "الكل" || cat == _selectedCategory;
      final title = (l['title'] ?? '').toString().toLowerCase();
      final summary = (l['summary'] ?? l['description'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty || title.contains(q) || summary.contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Magazine Hero Header
          Container(
            padding: EdgeInsets.all(isMobile ? 22 : 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Color(0xFF3B82F6), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "مدونة الدروس والمقالات الأكاديمية",
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "شروحات هندسية وتدوينات عميقة في البرمجة والذكاء الاصطناعي",
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 22 : 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "مقالات تفصيلية مدعومة بالأكواد الملونة والصور والشروحات النقدية لتعزيز فهمك وبناء عقليتك البرمجية.",
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 13 : 15,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.cairo(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "ابحث في الدروس والمقالات بالعنوان أو الكلمات الدلالية...",
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF3B82F6)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF070B14) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: FilterChip(
                    label: Text(cat, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3B82F6),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Lessons Grid
          if (filtered.isEmpty)
            _buildEmptyState(isDark)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 3;
                if (constraints.maxWidth < 650) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 980) {
                  crossAxisCount = 2;
                }

                final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount;

                return Wrap(
                  spacing: 20,
                  runSpacing: 22,
                  children: filtered.map((lesson) {
                    return SizedBox(
                      width: itemWidth,
                      child: _buildBloggerLessonCard(lesson, isDark),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // Blogger / Magazine Lesson Card
  // ==========================================
  Widget _buildBloggerLessonCard(Map<String, dynamic> lesson, bool isDark) {
    final title = lesson['title'] ?? 'درس جديد';
    final category = lesson['category'] ?? lesson['subject'] ?? 'درس';
    final image = lesson['image'] ?? 'assets/images/slide2.png';
    final isNetwork = image.startsWith('http');
    final summary = lesson['summary'] ?? lesson['description'] ?? 'شرح مبسط وتطبيقي لأهم المفاهيم البرمجية.';
    final date = lesson['date'] ?? '2026';
    final duration = lesson['readTime'] ?? lesson['duration'] ?? '15 دقيقة قراءة';
    final author = lesson['author'] ?? 'Eslam Atef';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: isNetwork
                      ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900))
                      : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900)),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: GoogleFonts.cairo(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Author & Read Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundImage: const AssetImage('assets/images/islam.png'),
                            backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(author, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              Text(date, style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _openLessonReader(context, lesson, isDark),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text("قراءة المقال ➔", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
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

  // ==========================================
  // Full Lesson / Article Reader View
  // ==========================================
  void _openLessonReader(BuildContext context, Map<String, dynamic> lesson, bool isDark) {
    final title = lesson['title'] ?? 'درس جديد';
    final category = lesson['category'] ?? lesson['subject'] ?? 'درس';
    final image = lesson['image'] ?? 'assets/images/slide2.png';
    final isNetwork = image.startsWith('http');
    final date = lesson['date'] ?? '2026';
    final author = lesson['author'] ?? 'Eslam Atef';
    final content = lesson['content'] ?? lesson['summary'] ?? lesson['description'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 900,
            constraints: const BoxConstraints(maxHeight: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Reader Top Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(category, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "بقلم: $author • $date",
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // Scrollable Article Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cover Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 320,
                            child: isNetwork
                                ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900))
                                : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // Rendered HTML & Rich Content
                        ArticleContentRenderer(content: content, isDark: isDark),

                        const SizedBox(height: 40),
                        const Divider(),
                        const SizedBox(height: 16),

                        // WhatsApp Registration Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "لديك استفسار أو سؤال حول هذا الدرس؟",
                              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                launchWebUrl(
                                  "${ArabicData.whatsappUrl}?text=${Uri.encodeComponent('مرحباً أستاذ إسلام عاطف، لدي سؤال بخصوص مقال/درس ($title)')}",
                                );
                              },
                              icon: const Icon(Icons.send_rounded, size: 16),
                              label: Text("اسأل إسلام عاطف 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.article_outlined, size: 52, color: Color(0xFF64748B)),
            const SizedBox(height: 14),
            Text(
              "لم يتم نشر مقالات أو دروس في هذا التصنيف بعد",
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "يمكنك كتابة ونشر مقالات تقنية جديدة بسهولة بنظام البلوجر عبر لوحة التحكم.",
              style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/admin'),
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
              label: Text("فتح لوحة التحكم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageFooter(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          const SizedBox(height: 16),
          const SocialIconsBar(
            facebookUrl: ArabicData.facebookUrl,
            youtubeUrl: ArabicData.youtubeUrl,
            telegramUrl: ArabicData.telegramUrl,
            linkedinUrl: ArabicData.linkedinUrl,
          ),
          const SizedBox(height: 14),
          Text(
            "جميع الحقوق محفوظة © 2026 Eslam Atef | Code & AI",
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
