import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/social_icons.dart';

class RecordingStudioPage extends StatelessWidget {
  const RecordingStudioPage({super.key});

  Future<void> _launchPresentation(BuildContext context) async {
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            _buildPageHeader(context, isMobile),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    _buildRecordingContent(context, isMobile, screenWidth),
                    const SizedBox(height: 60),
                    _buildPageFooter(context, isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isMobile) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Title
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
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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

              // Back to Home Button
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  "الرئيسية",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardDark,
                  foregroundColor: AppColors.primaryLight,
                  side: const BorderSide(color: AppColors.borderLightDark),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingContent(BuildContext context, bool isMobile, double screenWidth) {
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

          // Main Lesson Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 22 : 36),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
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
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "22 شريحة تفاعلية",
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "عرض تفاعلي شامل مبني بالكامل على المحتوى والمصطلحات المعتمدة في المنهج المدرسي. يتضمن تعاريف البيانات والمعلومات والمعرفة، الخصائص الرسمية (الاستمرار، إعادة الإنتاج، الانتشار)، المقارنات البصرية، المصادر الأولية والثانوية، التحقق المتقاطع (Cross-checking)، أنواع الوسائط (تعبير، نقل، تسجيل)، الثقافة الإعلامية، واختبار نهائي تفاعلي.",
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
                      onPressed: () => _launchPresentation(context),
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

  Widget _buildPageFooter(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                "جميع الحقوق محفوظة © 2026 إسلام عاطف | Code & AI",
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              const SocialIconsBar(
                facebookUrl: ArabicData.facebookUrl,
                youtubeUrl: ArabicData.youtubeUrl,
                telegramUrl: ArabicData.telegramUrl,
                linkedinUrl: ArabicData.linkedinUrl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
