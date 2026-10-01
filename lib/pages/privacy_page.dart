import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/social_icons.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildPageHeader(context, isMobile),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    _buildContent(context, isMobile),
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
              Row(
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/logo.jpeg', width: 42, height: 42, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ArabicData.brandName,
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        ArabicData.brandSubtitle,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardDark,
                  foregroundColor: AppColors.primaryLight,
                  side: const BorderSide(color: AppColors.borderLightDark),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  "الرئيسية",
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
              child: Text(
                "الوثائق القانونية والشروط",
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "سياسة الاستخدام والخصوصية",
              style: GoogleFonts.cairo(fontSize: isMobile ? 26 : 34, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "تاريخ آخر تحديث: 2026",
              style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 36),

          _buildSectionCard(
            "1. مقدمة وقبول الشروط",
            "أهلاً بك في المنصة الرسمية لـ Eslam Atef | Code & AI. باستخدامك لهذا الموقع أو تسجيلك في أي من برامجنا أو دوراتنا التعليمية، فإنك تقر وتوافق صراحة على الالتزام بجميع بنود سياسة الاستخدام والخصوصية الموضحة أدناه.",
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "2. حقوق الملكية الفكرية",
            "جميع المواد التعليمية، والمحاضرات المرئية، والمقالات، والأكواد البرمجية والتصميمات المنشورة على هذا الموقع مملوكة بالكامل لـ Eslam Atef ومحمية بموجب قوانين الملكية الفكرية الدولية. يُمنع منعاً باتاً إعادة بيع أو نشر أو توزيع المحتوى أو تسجيل المحاضرات الخاصة بالدورات دون إذن كتابي مسبق.",
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "3. جمع وحماية البيانات الشخصية (الخصوصية)",
            "نحن نلتزم بأعلى معايير حماية الخصوصية والأمان الرقمي:\n• نجمع البيانات التي تزودنا بها بمحض إرادتك مثل: الاسم، ورقم الهاتف، والبريد الإلكتروني عند التواصل أو الاشتراك.\n• نستخدم بياناتك حصراً لأغراض الرد على استفساراتك، وتقديم الدعم الأكاديمي، وتنظيم مواعيد الكورسات.\n• نتعهد بعدم بيع، أو تأجير، أو مشاركة أي بيانات شخصية مع أي جهات خارجية أو أطراف دعائية تحت أي ظرف.",
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "4. شروط التسجيل في الكورسات",
            "• يلتزم الطالب بحضور الجلسات في مواعيدها ومتابعة التطبيقات العملية والمشاريع المحددة في المسار.\n• يحق للمتدرب الاستفسار والمناقشة المباشرة والحصول على المراجعات البرمجية والتوجيه الفني الكامل خلال فترة الكورس.\n• أي انتهاك لشروط الاستخدام أو الإضرار ببيئة التعلم قد يؤدي إلى إيقاف الوصول دون استرداد الرسوم.",
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "5. التواصل والاستفسارات الرسمية",
            "إذا كانت لديك أي استفسارات أو ملاحظات بخصوص شروط الاستخدام أو سياسة الخصوصية، يمكنك التواصل معنا مباشرة:\n• الهاتف الرسمي: 01100665674\n• الواتساب: عبر الرابط المباشر في الموقع\n• البريد الإلكتروني: contact@eslamatef.dev",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              height: 1.75,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(BuildContext context, bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF070A12),
        border: Border(top: BorderSide(color: AppColors.borderDark)),
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
                _footerLink("الكورسات", () {}),
                _footerLink("الدروس", () {}),
                _footerLink("من نحن", () => Navigator.of(context).pushNamed('/about')),
                _footerLink("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
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
