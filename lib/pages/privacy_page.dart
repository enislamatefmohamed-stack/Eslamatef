import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/privacy') : null,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                UnifiedAppHeader(
                  currentRoute: '/privacy',
                  pageTitle: 'سياسة الاستخدام والخصوصية',
                  showBackButton: true,
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildPrivacyContent(context, isMobile, isDark),
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

  Widget _buildPrivacyContent(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Legal Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    "الوثائق القانونية والشروط الرسمية للأكاديمية",
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          Center(
            child: Text(
              "سياسة الاستخدام والخصوصية",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 24 : 34,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              "تاريخ آخر تحديث واعتماد: عام 2027 • سارية على كافة المنصات التابعة لأكاديمية إسلام عاطف",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 2. Trust Highlights Banner
          _buildTrustHighlightsBar(isDark, isMobile),
          const SizedBox(height: 36),

          // 3. Structured Policy Cards
          _buildPolicyCard(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF00E5FF),
            title: "1. مقدمة وقبول الشروط العامة",
            content: "أهلاً بك في منصة Eslam Atef | Code & AI. باستخدامك لهذا الموقع أو تسجيلك في أي من دوراتنا أو برامجنا التدريبية، فإنك تقر وتوافق على الالتزام بجميع بنود هذه الاتفاقية. نحن ملتزمون بتوفير بيئة تعليمية آمنة، احترافية، ومحفزة تضمن أعلى معايير الجودة والشفافية.",
            isDark: isDark,
          ),
          const SizedBox(height: 18),

          _buildPolicyCard(
            icon: Icons.child_care_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: "2. حماية خصوصية الأطفال وبيانات القُصّر (أولوية قصوى)",
            content: "نظراً لأن منصتنا موجهة بشكل أساسي للأطفال واليافعين، فإننا نطبق أقصى معايير حماية خصوصية الأطفال الدولية (بما يتوافق مع مبادئ COPPA). لا نقوم بجمع أي معلومات شخصية غير ضرورية، ولا نطلب صوراً شخصية إلزامية، ويكون تسجيل الطلاب تحت إشراف وعلم ولي الأمر لضمان تجربة تعليمية آمنة ومحمية بالكامل.",
            isDark: isDark,
          ),
          const SizedBox(height: 18),

          _buildPolicyCard(
            icon: Icons.copyright_rounded,
            iconColor: const Color(0xFF818CF8),
            title: "3. حقوق الملكية الفكرية والمحتوى التدريبي",
            content: "جميع المحتويات المنشورة على الموقع من مقاطع فيديو، ملازم، أوراق عمل، شروحات برمجية، اختبارات تفاعلية، وتصاميم، هي ملكية فكرية حصرية لـ م. إسلام عاطف وأكاديمية Eslam Atef | Code & AI، ومحمية بموجب قوانين حقوق المؤلف لعام 2027. يمنع منعاً باتاً نسخ أو إعادة بيع أو استغلال المحتوى تجارياً بدون إذن كتابي مسبق.",
            isDark: isDark,
          ),
          const SizedBox(height: 18),

          _buildPolicyCard(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF10B981),
            title: "4. أمان الحسابات وبيانات الدخول",
            content: "بيانات المرور والاشتراكات يتم حفظها وتشفيرها بأعلى معايير الأمان المعتمدة عالمياً عبر خوادم Firebase المشفرة. يتحمل المستخدم مسؤولية الحفاظ على سرية حسابه وعدم مشاركة بيانات الدخول مع أطراف أخرى، ونوصي دائماً باستخدام كلمة مرور قوية.",
            isDark: isDark,
          ),
          const SizedBox(height: 18),

          _buildPolicyCard(
            icon: Icons.cookie_outlined,
            iconColor: const Color(0xFF38BDF8),
            title: "5. ملفات تعريف الارتباط والتخزين المحلي",
            content: "يستخدم موقعنا تقنيات التخزين المحلي الآمنة (Local Storage) لحفظ تفضيلات المظهر (الوضع الليلي والنهاري) ومتابعة تقدم الطالب داخل الدروس والواجبات. لا نستخدم أي أدوات تتبع إعلانية ضارة أو تجسسية نهائياً.",
            isDark: isDark,
          ),
          const SizedBox(height: 18),

          _buildPolicyCard(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFFF43F5E),
            title: "6. التعديلات والتواصل والاستفسارات القانونية",
            content: "يحق لإدارة المنصة تحديث هذه الشروط بما يواكب التطورات التقنية والتنظيمية. في حال وجود أي استفسار قانوني أو طلب خاص بالبيانات أو حذف الحساب، يمكنك التواصل مباشرة مع م. إسلام عاطف أو فريق الدعم الفني.",
            isDark: isDark,
          ),
          const SizedBox(height: 36),

          // 4. Contact & Support Box
          _buildLegalContactBox(context, isDark, isMobile),
        ],
      ),
    );
  }

  Widget _buildTrustHighlightsBar(bool isDark, bool isMobile) {
    final highlights = [
      {"icon": Icons.lock_outline_rounded, "title": "تشفير كامل", "sub": "بياناتك محمية ومشفرة"},
      {"icon": Icons.family_restroom_rounded, "title": "بيئة آمنة للأطفال", "sub": "خالية من الإعلانات تماماً"},
      {"icon": Icons.no_accounts_rounded, "title": "خصوصية تامة", "sub": "لا نبيع أي بيانات لأطراف خارجية"},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: isMobile
          ? Column(
              children: highlights.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(h["icon"] as IconData, color: const Color(0xFF00E5FF), size: 24),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h["title"] as String, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(h["sub"] as String, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: highlights.map((h) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(h["icon"] as IconData, color: const Color(0xFF00E5FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h["title"] as String, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Text(h["sub"] as String, style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey)),
                    ],
                  ),
                ],
              )).toList(),
            ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.7,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalContactBox(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded, size: 36, color: Color(0xFF00E5FF)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "هل لديك أي استفسار أو تساؤل بخصوص الشروط أو الخصوصية؟",
                  style: GoogleFonts.cairo(fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "فريقنا التقني وم. إسلام عاطف مستعدون للرد على استفسارك في أي وقت.",
                  style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _launchUrl("https://wa.me/201100665674"),
            icon: const Icon(Icons.chat_rounded, size: 16),
            label: Text("تواصل معنا", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
