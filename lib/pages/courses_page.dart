import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/social_icons.dart';
import '../services/site_data_service.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _dataService = SiteDataService.instance;

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

    return Scaffold(
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
                    const SizedBox(height: 40),
                    _buildCoursesContent(context, isMobile, isDark),
                    const SizedBox(height: 60),
                    _buildPageFooter(context, isMobile, isDark),
                  ],
                ),
              ),
            ),
          ],
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
                        ArabicData.brandSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
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
                      foregroundColor: const Color(0xFF00E5FF),
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

  Widget _buildCoursesContent(BuildContext context, bool isMobile, bool isDark) {
    final courses = _dataService.courses;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 18),
                const SizedBox(width: 8),
                Text(
                  "الكورسات والمسارات التعليمية",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "المسارات البرمجية الشاملة",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            "مسارات دراسية متكاملة تأخذك من الصفر وحتى الاحتراف مع تطبيقات عملية ومشاريع حقيقية",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 14 : 16,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Courses List or Empty State
          if (courses.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (ctx, i) {
                final c = courses[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.laptop_chromebook_rounded, color: Color(0xFF00E5FF), size: 28),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c['badge'] ?? 'كورس',
                                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  c['duration'] ?? '',
                                  style: GoogleFonts.cairo(fontSize: 12, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c['title'] ?? '',
                              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if ((c['description'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                c['description'] ?? '',
                                style: GoogleFonts.cairo(fontSize: 13, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: 60),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.borderLightDark : AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF00E5FF), size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "جاري تجهيز فهرس الكورسات الشاملة",
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 20 : 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Text(
                      "يتم حالياً إعداد ورفع مسارات البرمجة، هياكل البيانات، الخوارزميات، وتطبيقات الذكاء الاصطناعي لتكون متاحة للطلاب قريباً بأعلى جودة.",
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/admin'),
                    icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                    label: Text("إضافة كورس من لوحة التحكم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070A12) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset('assets/images/logo.jpeg', width: 34, height: 34, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                Text(
                  ArabicData.brandName,
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _footerLink("الرئيسية", () => Navigator.of(context).pushReplacementNamed('/')),
                _footerLink("الدروس", () => Navigator.of(context).pushNamed('/lessons')),
                _footerLink("من نحن", () => Navigator.of(context).pushNamed('/about')),
                _footerLink("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                _footerLink("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                _footerLink("لوحة التحكم", () => Navigator.of(context).pushNamed('/admin')),
              ],
            ),
            const SizedBox(height: 16),
            const SocialIconsBar(
              facebookUrl: ArabicData.facebookUrl,
              youtubeUrl: ArabicData.youtubeUrl,
              telegramUrl: ArabicData.telegramUrl,
              linkedinUrl: ArabicData.linkedinUrl,
            ),
            const SizedBox(height: 16),
            Text(
              "جميع الحقوق محفوظة © 2026 Eslam Atef | Code & AI",
              style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
