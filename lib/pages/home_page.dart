// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/social_icons.dart';
import '../services/site_data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dataService = SiteDataService.instance;
  int _expandedFaqIndex = -1;
  int _visibleReviewsCount = 6;
  final Set<int> _expandedReviews = {};
  final ScrollController _whatsNewScrollCtrl = ScrollController();
  Timer? _whatsNewAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startWhatsNewAutoScroll();
  }

  @override
  void dispose() {
    _whatsNewAutoScrollTimer?.cancel();
    _whatsNewScrollCtrl.dispose();
    super.dispose();
  }

  void _startWhatsNewAutoScroll() {
    _whatsNewAutoScrollTimer?.cancel();
    _whatsNewAutoScrollTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!_whatsNewScrollCtrl.hasClients) return;
      final maxExtent = _whatsNewScrollCtrl.position.maxScrollExtent;
      final current = _whatsNewScrollCtrl.offset;
      if (current >= maxExtent) {
        _whatsNewScrollCtrl.jumpTo(0);
      } else {
        _whatsNewScrollCtrl.jumpTo(current + 1);
      }
    });
  }

  // Authentic Student and Parent Reviews
  final List<Map<String, dynamic>> _reviews = [
    {
      "name": "أسامة عبد",
      "initial": "أ",
      "avatarColor": const Color(0xFFF59E0B),
      "stars": 5,
      "badge": "مشترك في باقة التأسيس • الخطة السنوية",
      "time": "مشترك منذ سبتمبر 2026",
      "text": "صراحة وددت المشاركة في التقييم على غير عادتي نظراً للاستفادة الاستثنائية التي وجدتها مع المهندس إسلام. المنهج مرتب جداً ويجمع بين الفهم العميق والتطبيق العملي. ابني عمره 11 سنة وأصبح يشرح لي كيف يعمل المعالج والذاكرة بعد أن كان يقضي وقته كله في ألعاب عشوائية!",
    },
    {
      "name": "م. أحمد النجار (ولي أمر)",
      "initial": "أ",
      "avatarColor": const Color(0xFF0284C7),
      "stars": 5,
      "badge": "مشترك في كورس بايثون والأمان السيبراني",
      "time": "مشترك منذ أغسطس 2026",
      "text": "تجربتي مع أكاديمية م. إسلام عاطف ممتازة جداً، أسلوب الشرح في كورس بايثون مبسط وسهل ومباشر لأبعد حد، والواجبات بعد كل محاضرة بتخلي الطالب يطبق بإيده وميسبش ولا معلومة تفوته. أحييك يا بشمهندس على الصبر وطاقتك الإيجابية مع الأولاد.",
    },
    {
      "name": "Jara Hussein",
      "initial": "J",
      "avatarColor": const Color(0xFF10B981),
      "stars": 5,
      "badge": "مشتركة في كورس سكراتش والخوارزميات",
      "time": "مشتركة منذ يوليو 2026",
      "text": "أنا لحد الآن أتممت كورس الأساسيات وكورس سكراتش، الصراحة الكورسات مفيدة جداً وخلتني أفهم البرمجة بطريقة منظمة بدل التشتت في قنوات اليوتيوب. دلوقتي عملت 3 ألعاب بنفسي وفخورة جداً باللي وصلتله مع مستر إسلام!",
    },
    {
      "name": "Mohamed Ahmed",
      "initial": "M",
      "avatarColor": const Color(0xFF8B5CF6),
      "stars": 5,
      "badge": "مشترك في كورس روبلوكس وLua",
      "time": "مشترك منذ أكتوبر 2026",
      "text": "جربت كورس برمجة ألعاب روبلوكس وفعلاً كانت تجربة ممتعة وفرقت كتير. عرفت إزاي أكتب كود حقيقي بلغة Lua وأعمل حركات وشخصيات داخل اللعبة بنفسي، الشرح سلس وخطوة بخطوة من غير أي ملل.",
    },
    {
      "name": "د. نادية القحطاني (ولية أمر)",
      "initial": "ن",
      "avatarColor": const Color(0xFFEC4899),
      "stars": 5,
      "badge": "مشتركة في باقة التأسيس الشاملة",
      "time": "مشتركة منذ يونيو 2026",
      "text": "كنت خايفة ابني يمل أو يلاقي المحتوى صعب، بس طريقة م. إسلام في تبسيط التفكير الحسابي والخوارزميات خلت ابني ينتظر ميعاد المحاضرة بفارغ الصبر. المتابعة المستمرة وتقارير الأداء بتطمنا دايماً على مستواه.",
    },
    {
      "name": "يوسف كريم (14 سنة)",
      "initial": "ي",
      "avatarColor": const Color(0xFF0D9488),
      "stars": 5,
      "badge": "مشترك في كورس وكلاء وأدوات الذكاء الاصطناعي",
      "time": "مشترك منذ سبتمبر 2026",
      "text": "كورس أدوات ووكلاء الذكاء الاصطناعي فتح عيني على حاجات مكنتش متخيلها. بقيت أستخدم الـ AI لمساعدتي في المذاكرة والمشاريع، وفهمت هندسة الأوامر بطريقة احترافية. أفضل استثمار في وقتي بجد!",
    },
    {
      "name": "عمر الدسوقي",
      "initial": "ع",
      "avatarColor": const Color(0xFF3B82F6),
      "stars": 5,
      "badge": "مشترك في كورس الخوارزميات وحل المشكلات",
      "time": "مشترك منذ مايو 2026",
      "text": "التفكير المنطقي وطريقة حل المسائل اللي اتعلمتها في كورس الخوارزميات فادتني مش بس في البرمجة، حتى في الرياضيات والتفكير اليومي. م. إسلام بيهتم بكل طالب في المجموعة وبيتناقش معانا في كل سطر كود.",
    },
    {
      "name": "سارة محمود",
      "initial": "س",
      "avatarColor": const Color(0xFFF97316),
      "stars": 5,
      "badge": "مشتركة في كورس بايثون للأطفال واليافعين",
      "time": "مشتركة منذ نوفمبر 2026",
      "text": "الشرح العملي المباشر والأمثلة الحية بتفرق جداً. كل حصة بنطلع ببرنامج شغال بنكتبه بنفسنا. مكنتش متخيلة إني هعرف أبرمج آلة حاسبة ولعبة تخمين أرقام كاملة بالبايثون في أسابيع قليلة!",
    },
    {
      "name": "أ. طارق عبد الرحمن (ولي أمر)",
      "initial": "ط",
      "avatarColor": const Color(0xFF6366F1),
      "stars": 5,
      "badge": "مشترك في كورس الأمان السيبراني والأجهزة",
      "time": "مشترك منذ أكتوبر 2026",
      "text": "كورس الأمان الرقمي كان ضروري جداً لأولادي لحمايتهم على الإنترنت، اتعلموا إزاي ينشئوا كلمات مرور قوية ويكتشفوا الروابط المشبوهة. شكراً جزيلاً للأكاديمية على المحتوى الهادف والمتميز.",
    },
    {
      "name": "حمزة الشناوي (12 سنة)",
      "initial": "ح",
      "avatarColor": const Color(0xFF14B8A6),
      "stars": 5,
      "badge": "مشترك في كورس سكراتش وتطوير الألعاب",
      "time": "مشترك منذ أغسطس 2026",
      "text": "سكراتش كان ممتع جداً مع مستر إسلام! كل أسبوع كنا بنبرمج لعبة جديدة، وساعدني أفهم اللوبس والشروط بطريقة لعب وسهلة جداً من غير أي تعقيد. بنصح أي حد يبدأ بيه.",
    },
    {
      "name": "مريم علي",
      "initial": "م",
      "avatarColor": const Color(0xFFE11D48),
      "stars": 5,
      "badge": "مشتركة في باقة التأسيس والبرمجة المتقدمة",
      "time": "مشتركة منذ يوليو 2026",
      "text": "أجمل ما في الأكاديمية هو روح التشجيع والدعم المستمر. حتى لما كنت بغلط في الكود، م. إسلام كان بيخليني أفكر وأكتشف الحل بنفسي. دي ثقة كبيرة اكتسبتها في نفسي.",
    },
    {
      "name": "كريم الهاشمي",
      "initial": "ك",
      "avatarColor": const Color(0xFF0284C7),
      "stars": 5,
      "badge": "مشترك في كورس وكلاء الذكاء الاصطناعي",
      "time": "مشترك منذ سبتمبر 2026",
      "text": "المحتوى حديث جداً ومش مكرر، بيواكب كل التطورات في عالم الذكاء الاصطناعي لسنة 2026 و2027. التطبيق العملي على أدوات الـ AI والـ Autonomous Agents خلانا متميزين عن أي طالب تاني في سننا.",
    },
  ];

  void _launchWhatsApp(String message) {
    final encoded = Uri.encodeComponent(message);
    final url = "https://wa.me/201100665674?text=$encoded";
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/') : null,
        floatingActionButton: _buildFloatingWhatsApp(),
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                // 1. Navigation Header
                const UnifiedAppHeader(currentRoute: '/'),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 1. Cinematic Hero Header with Classroom Image Background & Dual CTA
                        _buildCinematicHeroHeader(isMobile, screenWidth, isDark),
                        SizedBox(height: isMobile ? 24 : 40),

                        // 2. Trust Metrics Bar
                        _buildTrustBar(isMobile, screenWidth, isDark),
                        SizedBox(height: isMobile ? 40 : 70),

                        // ✨ NEW: What's New Moving Animated Slider (جديد الموقع والأكاديمية)
                        _buildWhatsNewSliderSection(isMobile, screenWidth, isDark),
                        SizedBox(height: isMobile ? 40 : 70),

                        // 3. Student & Parent Reviews Section (اراء الطلاب وأولياء الأمور)
                        _buildStudentReviewsSection(isMobile, screenWidth, isDark),
                        SizedBox(height: isMobile ? 40 : 70),

                        // 4. Parent FAQ Section
                        _buildFaqSection(isMobile, screenWidth, isDark),
                        SizedBox(height: isMobile ? 40 : 60),

                        // 5. Unified Footer (2027)
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

  // =========================================================================
  // 1. CINEMATIC HERO HEADER (Classroom Image Background + Overlay + Dual CTA)
  // =========================================================================
  Widget _buildCinematicHeroHeader(bool isMobile, double screenWidth, bool isDark) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 500 : 580),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. High-resolution Classroom Image with Mentor & Students on Laptops
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_classroom.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. Dark Cinematic Multi-layer Gradient Overlay for crisp text contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF070B14).withOpacity(0.92),
                    const Color(0xFF0F172A).withOpacity(0.80),
                    const Color(0xFF070B14).withOpacity(0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Foreground Hero Text & Dual CTA Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 36, vertical: isMobile ? 38 : 68),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Academy Tagline Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF00E5FF)),
                          const SizedBox(width: 8),
                          Text(
                            "أكاديمية Eslam Atef | Code & AI للأجيال القادمة",
                            style: GoogleFonts.cairo(
                              fontSize: isMobile ? 12 : 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 28),

                    // Large High-contrast Headline (Cyan Glow instead of yellow)
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 28 : 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        children: [
                          const TextSpan(text: "كل اللي طفلك محتاجه في التكنولوجيا،\n"),
                          TextSpan(
                            text: "في اشتراك واحد.",
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF00E5FF), // Light Cyan / Blue
                              fontWeight: FontWeight.w900,
                              shadows: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withOpacity(0.45),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 22),

                    // Inspiring Subtitle
                    Container(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Text(
                        "من أساسيات علوم الحاسب والتفكير المنطقي، إلى بايثون وروبلوكس وهندسة وكلاء الذكاء الاصطناعي. منهج تطبيقي ومتابعة فردية حية خطوة بخطوة من الصفر حتى الاحتراف مع م. إسلام عاطف.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 14 : 17.5,
                          height: 1.7,
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 28 : 38),

                    // Dual CTA Buttons (Cyan Theme with Subtle Flash Glow)
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        // Cyan Primary Button with Dark Text & Glow
                        _HoverActionButton(
                          onTap: () => _launchWhatsApp("السلام عليكم م. إسلام، أريد الاشتراك في كورسات الأكاديمية ومعرفة باقات الاشتراك المتاحة."),
                          bgColor: const Color(0xFF00E5FF),
                          hoverBgColor: const Color(0xFF38BDF8),
                          textColor: const Color(0xFF070B14),
                          borderColor: const Color(0xFF00E5FF),
                          label: "اشترك وابدأ التعلّم",
                          isPrimary: true,
                          isMobile: isMobile,
                        ),

                        // Secondary Outlined Button with Arrow & Cyan Glow
                        _HoverActionButton(
                          onTap: () => Navigator.of(context).pushNamed('/courses'),
                          bgColor: Colors.transparent,
                          hoverBgColor: const Color(0xFF00E5FF).withOpacity(0.12),
                          textColor: Colors.white,
                          borderColor: const Color(0xFF00E5FF).withOpacity(0.5),
                          label: "استكشف الكورسات الـ 8 ←",
                          isPrimary: false,
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. TRUST METRICS BAR
  // =========================================================================
  Widget _buildTrustBar(bool isMobile, double screenWidth, bool isDark) {
    final metrics = [
      {"icon": Icons.school_rounded, "number": "8", "label": "كورسات تخصصية متدرجة من الصفر"},
      {"icon": Icons.videocam_rounded, "number": "+500", "label": "ساعة تدريب تفاعلية عبر Zoom"},
      {"icon": Icons.smart_toy_rounded, "number": "+30", "label": "مشروع ولعبة برمجية عملية"},
      {"icon": Icons.verified_user_rounded, "number": "100%", "label": "متابعة وتقارير دورية مستمرة لولي الأمر"},
    ];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1220),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 24, horizontal: 16),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: metrics.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildMetricItem(m, isDark),
                  )).toList(),
                );
              }
              return Row(
                children: metrics.map((m) => Expanded(
                  child: _buildMetricItem(m, isDark),
                )).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(Map<String, dynamic> m, bool isDark) {
    return Column(
      children: [
        Icon(m["icon"] as IconData, color: const Color(0xFF00E5FF), size: 28),
        const SizedBox(height: 6),
        Text(
          m["number"] as String,
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          m["label"] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. STUDENT & PARENT REVIEWS SECTION (آراء الطلاب وأولياء الأمور)
  // =========================================================================
  // =========================================================================
  // ✨ WHAT\'S NEW MOVING SLIDER SECTION (جديد الموقع والأكاديمية)
  // =========================================================================
  Widget _buildWhatsNewSliderSection(bool isMobile, double screenWidth, bool isDark) {
    final List<Map<String, dynamic>> items = [];

    // 1. Featured Courses
    items.add({
      'type': 'course',
      'typeLabel': 'كورس أساسي 🎓',
      'typeColor': const Color(0xFF00E5FF),
      'title': 'البرمجة والذكاء الاصطناعي للأطفال | من الصفر للاحتراف',
      'subtitle': 'الكورس التأسيسي الشامل لعلوم الحاسب وبناء الخوارزميات',
      'route': '/courses?course=01_cs_fundamentals',
      'icon': Icons.school_rounded,
    });
    items.add({
      'type': 'course',
      'typeLabel': 'كورس تخصصي 💡',
      'typeColor': const Color(0xFF8B5CF6),
      'title': 'كورس الخوارزميات والتفكير المنطقي',
      'subtitle': 'تطوير العقلية المنطقية والتحضير لمسابقات البرمجة العالمية',
      'route': '/courses',
      'icon': Icons.psychology_rounded,
    });

    // 2. Published Lectures from Courses
    for (final c in _dataService.courses) {
      final lessons = List<Map<String, dynamic>>.from(c['lessons'] ?? []);
      for (final l in lessons.take(3)) {
        final title = (l['title'] ?? '').toString();
        if (title.isNotEmpty) {
          items.add({
            'type': 'lecture',
            'typeLabel': 'محاضرة جديدة 🎬',
            'typeColor': const Color(0xFFFF7A00),
            'title': title,
            'subtitle': 'ضمن مسار ' + (c['title'] ?? 'الكورس'),
            'route': '/courses?course=' + c['id'].toString(),
            'icon': Icons.play_circle_fill_rounded,
          });
        }
      }
    }

    // 3. Published Articles
    for (final a in _dataService.articles.take(5)) {
      items.add({
        'type': 'article',
        'typeLabel': 'مقال تقني 📝',
        'typeColor': const Color(0xFF10B981),
        'title': a['title'] ?? 'مقال جديد',
        'subtitle': a['category'] ?? 'مدونة علوم الحاسب',
        'route': '/blog?article=' + a['id'].toString(),
        'icon': Icons.article_rounded,
      });
    }

    final sliderItems = [...items, ...items, ...items];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1220),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 32),
        child: Column(
          children: [
            _buildSectionHeader(
              tag: '🚀 جديد الأكاديمية والموقع',
              title: 'جديد الكورسات، المحاضرات، والمقالات التعليمية',
              subtitle: 'محتوى تعليمي متجدد وتحديثات حية ومستمرة لإثراء المعرفة البرمجية لأبنائنا خطوة بخطوة.',
              isDark: isDark,
              isMobile: isMobile,
            ),
            const SizedBox(height: 20),

            // Controls Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  tooltip: 'التالي',
                  onPressed: () {
                    if (_whatsNewScrollCtrl.hasClients) {
                      _whatsNewScrollCtrl.animateTo(
                        _whatsNewScrollCtrl.offset + 320,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  tooltip: 'السابق',
                  onPressed: () {
                    if (_whatsNewScrollCtrl.hasClients) {
                      _whatsNewScrollCtrl.animateTo(
                        _whatsNewScrollCtrl.offset - 320,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // The Smooth Moving Slider
            MouseRegion(
              onEnter: (_) => _whatsNewAutoScrollTimer?.cancel(),
              onExit: (_) => _startWhatsNewAutoScroll(),
              child: SizedBox(
                height: 190,
                child: ListView.separated(
                  controller: _whatsNewScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sliderItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, idx) {
                    final it = sliderItems[idx];
                    final color = it['typeColor'] as Color;

                    return InkWell(
                      onTap: () {
                        final r = it['route'] as String;
                        Navigator.of(context).pushNamed(r);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: isMobile ? 280 : 320,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(isDark ? 0.35 : 0.25),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(isDark ? 0.12 : 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: color.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    it['typeLabel'],
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                                Icon(it['icon'] as IconData, color: color, size: 22),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              it['title'],
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.35,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              it['subtitle'],
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'استكشف الآن ➔',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentReviewsSection(bool isMobile, double screenWidth, bool isDark) {
    final displayedReviews = _reviews.take(_visibleReviewsCount).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1220),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 32),
        child: Column(
          children: [
            _buildSectionHeader(
              tag: "⭐ تجارب حقيقية وقصص نجاح",
              title: "آراء الطلاب وأولياء الأمور في الأكاديمية",
              subtitle: "شهادات حية من طلابنا في مختلف الكورسات وكيف أحدث التعلم التطبيقي فارقاً حقيقياً في شغفهم ومستواهم البرمجي.",
              isDark: isDark,
              isMobile: isMobile,
            ),
            const SizedBox(height: 36),

            // Grid of Review Cards
            LayoutBuilder(
              builder: (ctx, constraints) {
                int crossAxisCount = 3;
                if (constraints.maxWidth < 650) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 1000) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: crossAxisCount == 1 ? 1.25 : 1.12,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: displayedReviews.length,
                  itemBuilder: (ctx, idx) {
                    final review = displayedReviews[idx];
                    return _buildReviewCard(review, idx, isDark, isMobile);
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Bottom Counter Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Text(
                  "+101 طالب وولي أمر شاركوا تجربتهم الإيجابية معنا",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expand More Reviews Button (Cyan Theme with Glow)
            _HoverReviewCtaButton(
              onTap: () {
                setState(() {
                  if (_visibleReviewsCount < _reviews.length) {
                    _visibleReviewsCount = _reviews.length;
                  } else {
                    _visibleReviewsCount = 6;
                  }
                });
              },
              label: _visibleReviewsCount < _reviews.length
                  ? "😍 شوف تجارب أكثر (+101 تجربة)"
                  : "عرض أقل",
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r, int index, bool isDark, bool isMobile) {
    final bool isExpanded = _expandedReviews.contains(index);
    final String text = r["text"] as String;
    final Color avatarColor = r["avatarColor"] as Color;

    return _ReviewCardContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Big Quote Mark + 5 Gold Stars
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stylized Cyan Quote Mark
                  Text(
                    "“",
                    style: GoogleFonts.cairo(
                      fontSize: 38,
                      height: 0.8,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00E5FF).withOpacity(0.85),
                    ),
                  ),

                  // 5 Golden Stars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Review Body Text
              Text(
                text,
                maxLines: isExpanded ? 8 : 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  height: 1.65,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // "اقرأ المزيد" button if long
              if (text.length > 120) ...[
                const SizedBox(height: 4),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedReviews.remove(index);
                        } else {
                          _expandedReviews.add(index);
                        }
                      });
                    },
                    child: Text(
                      isExpanded ? "عرض أقل" : "اقرأ المزيد",
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Bottom Row: Avatar Circle + Name + Subtitle Badge
          Column(
            children: [
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF1F293D) : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: avatarColor,
                    child: Text(
                      r["initial"] as String,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r["name"] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          r["badge"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. PARENT FAQ SECTION
  // =========================================================================
  Widget _buildFaqSection(bool isMobile, double screenWidth, bool isDark) {
    final faqs = [
      {
        "q": "هل يحتاج ابني لأي معرفة مسبقة بالبرمجة أو مستوى معين في اللغة الإنجليزية؟",
        "a": "لا نهائياً! نبدأ مع الطالب من الصفر التام وبشرح عربي مبسط وممتع، مع تدريب تدريجي على المصطلحات التقنية العالمية حتى يعتاد عليها بشكل طبيعي وسلس."
      },
      {
        "q": "كيف تكون طريقة الدراسة ومواعيد المحاضرات؟",
        "a": "المحاضرات حية وتفاعلية 100% عبر برنامج Zoom في مجموعات صغيرة جداً لضمان مشاركة كل طالب بالصوت والصورة والشاشة. كما يحصل الطالب على تسجيل المحاضرة وأوراق العمل للمراجعة في أي وقت."
      },
      {
        "q": "ما هي الأجهزة أو البرامج المطلوبة للبدء؟",
        "a": "كل ما تحتاجه هو جهاز كمبيوتر أو لابتوب عادي متصل بالإنترنت ومزود بماوس وكاميرا ومايكروفون. لا نشترط أي مواصفات خارقة، وكل الأدوات البرمجية المستخدمة مجانية وآمنة للأطفال."
      },
      {
        "q": "كيف أضمن استيعاب طفلي ومتابعته بعد انتهاء الحصة؟",
        "a": "في نهاية كل محاضرة يحصل الطالب على واجب عملي تطبيقي يقوم بحله ورفعه، ويتلقى تقييماً وملاحظات فورية من المهندس، بالإضافة لتقارير أداء دورية تُرسل لولي الأمر على واتساب."
      },
    ];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 32),
        child: Column(
          children: [
            _buildSectionHeader(
              tag: "إجابات شفافة",
              title: "الأسئلة الشائعة التي تدور في ذهن أولياء الأمور",
              subtitle: "كل ما تحتاج معرفته عن طريقة تدريسنا ومتابعتنا الدقيقة لكل طالب في الأكاديمية.",
              isDark: isDark,
              isMobile: isMobile,
            ),
            const SizedBox(height: 36),

            // Accordion FAQ items
            Column(
              children: faqs.asMap().entries.map((entry) {
                final idx = entry.key;
                final faq = entry.value;
                final isExpanded = _expandedFaqIndex == idx;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131D31) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isExpanded
                          ? const Color(0xFF00E5FF)
                          : (isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0)),
                      width: isExpanded ? 1.8 : 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: Key('faq_$idx'),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (val) {
                        setState(() {
                          _expandedFaqIndex = val ? idx : -1;
                        });
                      },
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        faq["q"] as String,
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 14.5 : 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text(
                            faq["a"] as String,
                            style: GoogleFonts.cairo(
                              fontSize: isMobile ? 13.5 : 14.5,
                              height: 1.75,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
  Widget _buildSectionHeader({
    required String tag,
    required String title,
    required String subtitle,
    required bool isDark,
    required bool isMobile,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
          ),
          child: Text(
            tag,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00E5FF),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 22 : 32,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 13.5 : 15.5,
              height: 1.65,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingWhatsApp() {
    return CircularFloatingWhatsApp(
      onTap: () => _launchWhatsApp("السلام عليكم م. إسلام، أرغب في الاستفسار عن كورسات أكاديمية Eslam Atef | Code & AI."),
    );
  }
}

// ---------------------------------------------------------------------------
// Review Card Container with Subtle Cyan Hover Glow (No Gray Background)
// ---------------------------------------------------------------------------
class _ReviewCardContainer extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _ReviewCardContainer({required this.child, required this.isDark});

  @override
  State<_ReviewCardContainer> createState() => _ReviewCardContainerState();
}

class _ReviewCardContainerState extends State<_ReviewCardContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF131D31) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF00E5FF).withOpacity(0.6)
                : (widget.isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0)),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF00E5FF).withOpacity(0.18)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hover Review CTA Button ("شوف تجارب أكثر") with Light Cyan / Blue Theme
// ---------------------------------------------------------------------------
class _HoverReviewCtaButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final bool isMobile;

  const _HoverReviewCtaButton({
    required this.onTap,
    required this.label,
    required this.isMobile,
  });

  @override
  State<_HoverReviewCtaButton> createState() => _HoverReviewCtaButtonState();
}

class _HoverReviewCtaButtonState extends State<_HoverReviewCtaButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 26 : 38,
            vertical: widget.isMobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF38BDF8) : const Color(0xFF00E5FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(_isHovered ? 0.55 : 0.3),
                blurRadius: _isHovered ? 20 : 10,
                spreadRadius: _isHovered ? 1 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: widget.isMobile ? 14 : 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF070B14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hover Action Button with subtle flash glow & cursor hand (No Gray Fill)
// ---------------------------------------------------------------------------
class _HoverActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color bgColor;
  final Color hoverBgColor;
  final Color textColor;
  final Color borderColor;
  final String label;
  final bool isPrimary;
  final bool isMobile;

  const _HoverActionButton({
    required this.onTap,
    required this.bgColor,
    required this.hoverBgColor,
    required this.textColor,
    required this.borderColor,
    required this.label,
    required this.isPrimary,
    required this.isMobile,
  });

  @override
  State<_HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<_HoverActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 22 : 32,
            vertical: widget.isMobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverBgColor : widget.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? const Color(0xFF00E5FF) : widget.borderColor,
              width: 1.5,
            ),
            boxShadow: [
              if (widget.isPrimary || _isHovered)
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(_isHovered ? 0.5 : 0.25),
                  blurRadius: _isHovered ? 18 : 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cairo(
              fontSize: widget.isMobile ? 14 : 16,
              fontWeight: FontWeight.w900,
              color: _isHovered && !widget.isPrimary ? const Color(0xFF00E5FF) : widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Authentic Circular WhatsApp Floating Button
// ---------------------------------------------------------------------------
class CircularFloatingWhatsApp extends StatefulWidget {
  final VoidCallback onTap;
  const CircularFloatingWhatsApp({super.key, required this.onTap});

  @override
  State<CircularFloatingWhatsApp> createState() => _CircularFloatingWhatsAppState();
}

class _CircularFloatingWhatsAppState extends State<CircularFloatingWhatsApp> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "تواصل معنا عبر واتساب",
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withOpacity(_isHovered ? 0.55 : 0.35),
                  blurRadius: _isHovered ? 18 : 10,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: WhatsAppLogo(size: 34, whiteOnly: false),
            ),
          ),
        ),
      ),
    );
  }
}
