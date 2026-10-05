import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';
import '../services/site_data_service.dart';
import '../widgets/recording_launcher/recording_launcher.dart';

class RecordingStudioPage extends StatelessWidget {
  const RecordingStudioPage({super.key});

  Future<void> _launchDefaultPresentation(BuildContext context) async {
    final uri = Uri.parse('presentation/index.html');
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح العرض التقديمي مباشرة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/recording') : null,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                const UnifiedAppHeader(
                  currentRoute: '/recording',
                  pageTitle: 'أستوديو تسجيل الحصص والمحاضرات',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        _buildRecordingContent(context, isMobile, screenWidth, isDark),
                        const SizedBox(height: 60),
                        const UnifiedAppFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingContent(BuildContext context, bool isMobile, double screenWidth, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Badge
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
                const Icon(Icons.videocam_rounded, color: Color(0xFF00E5FF), size: 18),
                const SizedBox(width: 8),
                Text(
                  "استوديو التصوير والعروض التقديمية",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            "جاهز لتسجيل دروس اليوتيوب والشاشات",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 24 : 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "عروض تقديمية تفاعلية مصممة بنسبة 16:9 للشاشات الكاملة والتسجيل المباشر بدون شريط تمرير",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Dynamic Lesson Cards from SiteDataService (Firebase)
          ListenableBuilder(
            listenable: SiteDataService.instance,
            builder: (context, _) {
              final sessions = SiteDataService.instance.recordingLessons;
              if (sessions.isEmpty) {
                return _buildDefaultSessionCard(context, isMobile, isDark);
              }
              return Column(
                children: sessions.map((rec) => _buildDynamicSessionCard(context, rec, isMobile, isDark)).toList(),
              );
            },
          ),
          const SizedBox(height: 40),

          // Shortcut Guide
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLightDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⌨️ مفاتيح التحكم السريعة أثناء تسجيل الدرس:",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _buildKeyItem("Next / Space / Left", "الشريحة أو الخطوة التالية"),
                    _buildKeyItem("Prev / Right", "الخطوة أو الشريحة السابقة"),
                    _buildKeyItem("F / F11", "ملء الشاشة Fullscreen"),
                    _buildKeyItem("P", "تفعيل / تعطيل القلم"),
                    _buildKeyItem("H", "قلم التمييز Highlighter"),
                    _buildKeyItem("E", "الممحاة Eraser"),
                    _buildKeyItem("C", "مسح رسم الشريحة الحالية"),
                    _buildKeyItem("B", "إخفاء / إظهار شريط الأدوات"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLightDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicSessionCard(BuildContext context, Map<String, dynamic> rec, bool isMobile, bool isDark) {
    final title = rec['title'] ?? 'جلسة تدريسية';
    final subject = rec['subject'] ?? 'الصف الأول الثانوي — مادة البرمجة والذكاء الاصطناعي';
    final date = rec['date'] ?? '2026';
    final code = (rec['code'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 22 : 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF00E5FF).withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF00E5FF).withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: Text(
                  subject,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "تاريخ: $date",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "عرض تفاعلي شامل مبني بالكامل على المحتوى والمصطلحات المعتمدة. يشمل السبورة الذكية، الأكواد البرمجية، والاختبارات التفاعلية الفورية المجهزة لتسجيل الحصص والشاشات بجودة عالية.",
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),

          // Features Badges
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildFeatureChip(Icons.aspect_ratio_rounded, "نسبة 16:9 ملء الشاشة"),
              _buildFeatureChip(Icons.edit_rounded, "قلم ووايت بورد مدمج"),
              _buildFeatureChip(Icons.touch_app_rounded, "تحكم يدوي للمدرس (No Auto-play)"),
              _buildFeatureChip(Icons.quiz_rounded, "اختبارات تفاعلية فورية"),
              _buildFeatureChip(Icons.keyboard_rounded, "دعم اختصارات لوحة المفاتيح"),
            ],
          ),
          const SizedBox(height: 34),

          // Launch Button
          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 360,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (code.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('كود الجلسة فارغ! يرجى إضافة الكود من لوحة الإدارة')),
                    );
                    return;
                  }
                  openRecordingPresentation(code, title: title);
                },
                icon: const Icon(Icons.play_circle_fill_rounded, size: 26),
                label: Text(
                  "بدء العرض والتسجيل الآن",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0A0F1D),
                  elevation: 10,
                  shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSessionCard(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF00E5FF).withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF00E5FF).withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: Text(
                  "الصف الأول الثانوي — مادة البرمجة والذكاء الاصطناعي",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "جلسة نموذجية",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            "المحاضرة الأولى: البيانات والمعلومات والمعرفة",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "عرض تفاعلي شامل مبني بالكامل على المحتوى والمصطلحات المعتمدة في المنهج المدرسي. يتضمن تعاريف البيانات والمعلومات والمعرفة، الخصائص الرسمية، المقارنات البصرية، المصادر الأولية والثانوية، واختبار تفاعلي.",
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),

          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildFeatureChip(Icons.aspect_ratio_rounded, "نسبة 16:9 ملء الشاشة"),
              _buildFeatureChip(Icons.edit_rounded, "قلم ووايت بورد مدمج"),
              _buildFeatureChip(Icons.touch_app_rounded, "تحكم يدوي للمدرس"),
              _buildFeatureChip(Icons.quiz_rounded, "اختبارات تفاعلية فورية"),
              _buildFeatureChip(Icons.keyboard_rounded, "دعم اختصارات لوحة المفاتيح"),
            ],
          ),
          const SizedBox(height: 34),

          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 360,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _launchDefaultPresentation(context),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 26),
                label: Text(
                  "بدء العرض والتسجيل الآن",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0A0F1D),
                  elevation: 10,
                  shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyItem(String key, String desc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          ),
          child: Text(
            key,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00E5FF),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          desc,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

