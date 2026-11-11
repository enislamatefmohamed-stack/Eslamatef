import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/about') : null,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                UnifiedAppHeader(
                  currentRoute: '/about',
                  pageTitle: 'من نحن — رسالتنا ورؤيتنا',
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
                        _buildAboutContent(context, isMobile, isDark),
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

  Widget _buildAboutContent(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Category Pill & Hero Title
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 8),
                  Text(
                    "أكاديمية ومنصة Eslam Atef | Code & AI",
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          Center(
            child: Text(
              "نبني عقول الغد البرمجية.. ونصنع رواد الذكاء الاصطناعي",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 24 : 34,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Text(
                "رسالتنا في أكاديمية إسلام عاطف هي تحويل شغف الأطفال والشباب من مجرد مستهلكين للتقنية إلى مبرمجين ومبتكرين قادرين على فهم الكمبيوتر وبناء أنظمة ذكاء اصطناعي حقيقية خطوة بخطوة من الصفر حتى الاحتراف.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 13.5 : 15.5,
                  height: 1.7,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // 2. Instructor Profile Card
          _buildInstructorHeroCard(context, isDark, isMobile),
          const SizedBox(height: 48),

          // 3. Trust Statistics Numbers Bar
          _buildStatsRow(isDark, isMobile),
          const SizedBox(height: 56),

          // 4. Core Pillars of the Academy
          _buildPillarsSection(isDark, isMobile),
          const SizedBox(height: 56),

          // 5. Educational Journey (4 Steps)
          _buildJourneySection(isDark, isMobile),
          const SizedBox(height: 48),

          // 6. Direct CTA Action Box
          _buildCtaBox(context, isDark, isMobile),
        ],
      ),
    );
  }

  // --- Instructor Profile Card ---
  Widget _buildInstructorHeroCard(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: 20),
                _buildInstructorBio(isDark),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(width: 32),
                Expanded(child: _buildInstructorBio(isDark)),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0284C7)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.5),
      child: ClipOval(
        child: Image.asset(
          'assets/images/islam.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF070B14),
            child: const Icon(Icons.person_rounded, size: 68, color: Color(0xFF00E5FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructorBio(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "م. إسلام عاطف",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Text(
                "مؤسس الأكاديمية",
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "مهندس برمجيات • محاضر علوم حاسب وذكاء اصطناعي للأجيال القادمة",
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00E5FF),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "أؤمن بأن البرمجة ليست مجرد كتابة سطور كود، بل هي مهارة التفكير المنطقي وحل المشكلات وصناعة المستقبل. هدفي في هذه الأكاديمية أن ينشأ أطفالنا وشبابنا على الفهم العميق لأسس التكنولوجيا وكيف تفكر الحواسيب، وبناء مشاريع حقيقية تواكب ثورة الذكاء الاصطناعي لسنة 2027 وما بعدها، بكل شغف واحترافية.",
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            height: 1.75,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  // --- Trust Statistics Row ---
  Widget _buildStatsRow(bool isDark, bool isMobile) {
    final stats = [
      {"number": "+209,000", "label": "طالب ومتعلم مستفيد", "icon": Icons.people_alt_rounded},
      {"number": "+10 سنوات", "label": "خبرة برمجية وهندسية", "icon": Icons.timeline_rounded},
      {"number": "8 مسارات", "label": "مناهج متخصصة للأطفال", "icon": Icons.menu_book_rounded},
      {"number": "4.9 / 5.0", "label": "تقييم أولياء الأمور والطلاب", "icon": Icons.star_rounded},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: isMobile
          ? Column(
              children: stats.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildStatItem(s["number"] as String, s["label"] as String, s["icon"] as IconData, isDark),
              )).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.map((s) => _buildStatItem(s["number"] as String, s["label"] as String, s["icon"] as IconData, isDark)).toList(),
            ),
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: const Color(0xFF00E5FF)),
        const SizedBox(height: 6),
        Text(
          number,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // --- Core Pillars Section ---
  Widget _buildPillarsSection(bool isDark, bool isMobile) {
    final pillars = [
      {
        "title": "الفهم من البداية (First Principles)",
        "desc": "لا نكتفي بتعليم ماذا يكتب الطفل، بل كيف يفكر المعالج وكيف تتحول الكهرباء إلى أفكار وحسابات منطقية.",
        "icon": Icons.psychology_rounded,
        "color": const Color(0xFF00E5FF),
      },
      {
        "title": "التفكير الخوارزمي وحل المسائل",
        "desc": "تنمية المنطق التحليلي وتفكيك المشكلات الكبيرة إلى خطوات برمجية صغيرة ومرتبة بدقة.",
        "icon": Icons.account_tree_rounded,
        "color": const Color(0xFF818CF8),
      },
      {
        "title": "مواكبة ثورة الذكاء الاصطناعي 2027",
        "desc": "تدريب عملي على وكلاء الذكاء الاصطناعي (AI Agents)، تعلم الآلة، وبناء تطبيقات تتفاعل بذكاء.",
        "icon": Icons.auto_awesome_rounded,
        "color": const Color(0xFFF59E0B),
      },
      {
        "title": "مشاريع حقيقية وبناء محفظة أعمال",
        "desc": "كل طالب يخرج من كل مرحلة بألعاب وتطبيقات وبرامج كاملة صممها ونفذها بنفسه ويفخر بها.",
        "icon": Icons.rocket_launch_rounded,
        "color": const Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ركائز ومبادئ الأكاديمية",
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 20 : 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "المعايير الهندسية والتربوية التي نبني عليها كل حصة وتطبيق عملي.",
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: pillars.map((p) {
            final cardWidth = isMobile ? double.infinity : 520.0;
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (p["color"] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(p["icon"] as IconData, color: p["color"] as Color, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p["title"] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p["desc"] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              height: 1.6,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Educational Journey ---
  Widget _buildJourneySection(bool isDark, bool isMobile) {
    final steps = [
      {"step": "01", "title": "عالم الكمبيوتر", "desc": "فهم كيف تعمل الحواسيب والإنترنت والعتاد البرمجي."},
      {"step": "02", "title": "التفكير المنطقي", "desc": "تعلم الخوارزميات وحل المسائل وبناء ألعاب سكراتش."},
      {"step": "03", "title": "لغات البرمجة الحقيقية", "desc": "كتابة كود بايثون وهياكل البيانات وبناء البرامج."},
      {"step": "04", "title": "مشاريع الذكاء الاصطناعي", "desc": "توظيف نماذج الـ AI وبناء حلول ذكية تواكب المستقبل."},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "رحلة الطالب معنا خطوة بخطوة",
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 20 : 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "مسار مدروس بعناية ينتقل بالطفل تدريجياً دون تعقيد أو ملل.",
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: steps.map((s) {
            final w = isMobile ? double.infinity : 252.0;
            return SizedBox(
              width: w,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s["step"] as String,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s["title"] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s["desc"] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        height: 1.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Direct CTA Action Box ---
  Widget _buildCtaBox(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F2D6B), const Color(0xFF0F172A)]
              : [const Color(0xFFE0F2FE), Colors.white],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "جاهز تبدأ رحلة البرمجة والذكاء الاصطناعي؟",
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  "تصفح الكورسات المتاحة الآن أو تواصل مباشرة معنا عبر واتساب.",
                  style: GoogleFonts.cairo(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/courses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF070B14),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("تصفح الكورسات 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => _launchUrl("https://wa.me/201100665674"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("محادثة واتساب مباشرة 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "جاهز تبدأ رحلة البرمجة والذكاء الاصطناعي؟",
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "تصفح الكورسات المتاحة أو تواصل مع م. إسلام عاطف وفريق الأكاديمية مباشرة.",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () => _launchUrl("https://wa.me/201100665674"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                        side: const BorderSide(color: Color(0xFF25D366)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("محادثة واتساب 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/courses'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: const Color(0xFF070B14),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("تصفح الكورسات 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
