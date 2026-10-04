import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/privacy') : null,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                const UnifiedAppHeader(
                  currentRoute: '/privacy',
                  pageTitle: 'سياسة الاستخدام والخصوصية',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        _buildContent(context, isMobile, isDark),
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

  Widget _buildContent(BuildContext context, bool isMobile, bool isDark) {
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
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "تاريخ آخر تحديث: 2026",
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 36),

          _buildSectionCard(
            "1. مقدمة وقبول الشروط",
            "أهلاً بك في المنصة الرسمية لـ Eslam Atef | Code & AI. باستخدامك لهذا الموقع أو تسجيلك في أي من برامجنا أو دوراتنا التعليمية، فإنك تقر وتوافق صراحة على الالتزام بجميع بنود سياسة الاستخدام والخصوصية الموضحة أدناه.",
            isDark,
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "2. حقوق الملكية الفكرية",
            "جميع المواد التعليمية، والمحاضرات المرئية، والمقالات، والأكواد البرمجية والتصميمات المنشورة على هذا الموقع مملوكة بالكامل لـ Eslam Atef ومحمية بموجب قوانين الملكية الفكرية الدولية. يُمنع منعاً باتاً إعادة بيع أو نشر أو توزيع المحتوى أو تسجيل المحاضرات الخاصة بالدورات دون إذن كتابي مسبق.",
            isDark,
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "3. جمع وحماية البيانات الشخصية (الخصوصية)",
            "نحن نلتزم بأعلى معايير حماية الخصوصية والأمان الرقمي:\n• نجمع البيانات التي تزودنا بها بمحض إرادتك مثل: الاسم، ورقم الهاتف، والبريد الإلكتروني عند التواصل أو الاشتراك.\n• نستخدم بياناتك حصراً لأغراض الرد على استفساراتك، وتقديم الدعم الأكاديمي، وتنظيم مواعيد الكورسات.\n• نتعهد بعدم بيع، أو تأجير، أو مشاركة أي بيانات شخصية مع أي جهات خارجية أو أطراف دعائية تحت أي ظرف.",
            isDark,
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "4. شروط التسجيل في الكورسات",
            "• يلتزم الطالب بحضور الجلسات في مواعيدها ومتابعة التطبيقات العملية والمشاريع المحددة في المسار.\n• يحق للمتدرب الاستفسار والمناقشة المباشرة والحصول على المراجعات البرمجية والتوجيه الفني الكامل خلال فترة الكورس.\n• أي انتهاك لشروط الاستخدام أو الإضرار ببيئة التعلم قد يؤدي إلى إيقاف الوصول دون استرداد الرسوم.",
            isDark,
          ),
          const SizedBox(height: 20),

          _buildSectionCard(
            "5. التواصل والاستفسارات الرسمية",
            "إذا كانت لديك أي استفسارات أو ملاحظات بخصوص شروط الاستخدام أو سياسة الخصوصية، يمكنك التواصل معنا مباشرة:\n• الهاتف الرسمي: 01100665674\n• الواتساب: عبر الرابط المباشر في الموقع\n• البريد الإلكتروني: contact@eslamatef.dev",
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String body, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              height: 1.75,
              color: isDark ? AppColors.textSecondary : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

