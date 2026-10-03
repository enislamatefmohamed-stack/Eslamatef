import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/social_icons.dart';
import '../widgets/unified_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return Scaffold(
      endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/about') : null,
      body: SafeArea(
        child: Column(
          children: [
            const UnifiedAppHeader(
              currentRoute: '/about',
              pageTitle: 'من نحن — رسالتنا ورؤيتنا',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    _buildAboutContent(context, isMobile),
                    const SizedBox(height: 60),
                    const UnifiedAppFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAboutContent(BuildContext context, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
              child: Text(
                "من نحن | Eslam Atef",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Text(
              "التعليم البرمجي القائم على الفهم العميق وهندسة النظم",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Portrait & Bio Box
          Container(
            padding: EdgeInsets.all(isMobile ? 24 : 36),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLightDark),
            ),
            child: isMobile
                ? Column(
                    children: [
                      _buildPortraitImage(),
                      const SizedBox(height: 24),
                      _buildBioText(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildPortraitImage(),
                      const SizedBox(width: 36),
                      Expanded(child: _buildBioText()),
                    ],
                  ),
          ),
          const SizedBox(height: 36),

          // Core Principles Grid
          Text(
            "المبادئ التعليمية الأساسية",
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              int cols = w < 680 ? 1 : 2;
              final itemW = (w - ((cols - 1) * 16)) / cols;

              final principles = [
                {
                  "title": "الفهم من البداية (First Principles)",
                  "desc": "لا نكتفي بتعليمك ماذا تكتب، بل كيف يفهم المعالج تعليماتك وكيف تدار الذاكرة خلف الكواليس.",
                  "icon": Icons.memory_rounded,
                },
                {
                  "title": "الكود النظيف والمعماريات المستقرة",
                  "desc": "تعلم مبادئ SOLID وتصميم النظم لبناء برمجيات يسهل تطويرها وصيانتها في بيئات العمل الحقيقية.",
                  "icon": Icons.architecture_rounded,
                },
                {
                  "title": "الذكاء الاصطناعي كمساعد ومضاعف للإنتاجية",
                  "desc": "توظيف نماذج الـ AI كشريك ذكي تحت سيطرتك الهندسية، مع الفهم التام لكل سطر ينتجه النموذج.",
                  "icon": Icons.psychology_rounded,
                },
                {
                  "title": "مشاريع عملية بمستوى الشركات",
                  "desc": "كل مفهوم نظري يترجم إلى تطبيق واقعي يتم اختباره وبناؤه وفق معايير الجودة العالمية.",
                  "icon": Icons.rocket_launch_rounded,
                },
              ];

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: principles.map((item) {
                  return SizedBox(
                    width: itemW,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item["icon"] as IconData, color: AppColors.primaryLight, size: 28),
                          const SizedBox(height: 12),
                          Text(
                            item["title"] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item["desc"] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 40),

          // Contact Box
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF131D33), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "هل ترغب في الانضمام للكورسات أو الاستفسار؟",
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "تواصل مباشرة مع م. إسلام عاطف على: ${ArabicData.phone}",
                      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsapp,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => launchWebUrl(ArabicData.whatsappUrl),
                  icon: const WhatsAppLogo(size: 18, whiteOnly: true),
                  label: Text("محادثة واتساب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitImage() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryLight, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.25),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/islam.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.person, size: 64, color: AppColors.primaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildBioText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Eslam Atef",
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          "Computer Science & AI Educator",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "مهندس ومدرس متخصص في علوم الحاسب والذكاء الاصطناعي، يتمتع بخبرة واسعة في تدريب وتوجيه مئات المطورين نحو التفكير الهندسي السليم. تهدف رسالتي التعليمية إلى القضاء على ثقافة النسخ العشوائي للكود، وبناء مبرمج متمكن يفهم أسس النظم، وتفاصيل الخوارزميات، وكيفية توظيف الذكاء الاصطناعي التوليدي كأداة قوية ترفع من جودة وكفاءة إنتاجه البرمجي.",
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.75,
          ),
        ),
      ],
    );
  }

}

