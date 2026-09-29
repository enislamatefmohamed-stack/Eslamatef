import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_theme.dart';
import 'data/arabic_data.dart';
import 'widgets/social_icons.dart';
import 'pages/about_page.dart';
import 'pages/privacy_page.dart';
import 'pages/contact_page.dart';
import 'pages/recording_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EslamAtefApp());
}

class EslamAtefApp extends StatelessWidget {
  const EslamAtefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "إسلام عاطف | Code & AI — تعليم علوم الحاسب والذكاء الاصطناعي",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: HomePage(),
            ),
        '/about': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: AboutPage(),
            ),
        '/privacy': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: PrivacyPage(),
            ),
        '/contact': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: ContactPage(),
            ),
        '/recording': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: RecordingStudioPage(),
            ),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentSlide = 0;
  Timer? _sliderTimer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      int next = (_currentSlide + 1) % ArabicData.imageSlides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _nextSlide() {
    int next = (_currentSlide + 1) % ArabicData.imageSlides.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _prevSlide() {
    int prev = (_currentSlide - 1 + ArabicData.imageSlides.length) % ArabicData.imageSlides.length;
    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleSlideAction(String action) {
    switch (action) {
      case 'join':
        launchWebUrl(
          "${ArabicData.whatsappUrl}?text=${Uri.encodeComponent('مرحباً أستاذ إسلام، أود الانضمام للكورسات والبرامج التعليمية')}",
        );
        break;
      case 'explore':
        launchWebUrl(ArabicData.youtubeUrl);
        break;
      case 'youtube':
        launchWebUrl(ArabicData.youtubeUrl);
        break;
      case 'telegram':
        launchWebUrl(ArabicData.telegramUrl);
        break;
      case 'projects':
        launchWebUrl(ArabicData.githubUrl);
        break;
      default:
        launchWebUrl(ArabicData.whatsappUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return Scaffold(
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      floatingActionButton: _buildFloatingWhatsApp(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (اللوجو، الأقسام، السوشيال)
            _buildHeader(isMobile),

            // 2. Middle Content + Sections + Footer
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 12 : 20),
                    _buildWidescreenSlider(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 36 : 60),

                    // 1. اتعلم معانا (4 Cards)
                    _buildLearnWithUsSection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 44 : 72),

                    // 2. رحلة التعلم (كيف أتعلم)
                    _buildLearningJourneySection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 36 : 60),

                    // 3. الفوتر
                    _buildFooter(isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. Header Widget
  // -------------------------------------------------------------
  Widget _buildHeader(bool isMobile) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Title
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryLight, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text("EA", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ArabicData.brandName,
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
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
                ),
              ),

              // Desktop Navigation Menu
              if (!isMobile)
                Row(
                  children: [
                    _navItem("الكورسات", () {}),
                    _navItem("الدروس", () {}),
                    _navItem("التصوير", () => Navigator.of(context).pushNamed('/recording')),
                    _navItem("من نحن", () => Navigator.of(context).pushNamed('/about')),
                    _navItem("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                    _navItem("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                  ],
                ),

              // Social Icons / Mobile Menu Button
              if (!isMobile)
                const SocialIconsBar(
                  facebookUrl: ArabicData.facebookUrl,
                  youtubeUrl: ArabicData.youtubeUrl,
                  telegramUrl: ArabicData.telegramUrl,
                  linkedinUrl: ArabicData.linkedinUrl,
                )
              else
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.primaryLight, size: 28),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Mobile Drawer
  // -------------------------------------------------------------
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.cardDark,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ArabicData.brandName,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ArabicData.brandSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined, color: AppColors.primaryLight),
              title: Text("الكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined, color: AppColors.primaryLight),
              title: Text("الدروس", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined, color: AppColors.primaryLight),
              title: Text("التصوير", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/recording');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.primaryLight),
              title: Text("من نحن", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/about');
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryLight),
              title: Text("سياسة الاستخدام والخصوصية", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/privacy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline_rounded, color: AppColors.primaryLight),
              title: Text("تواصل معنا", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/contact');
              },
            ),
            const Spacer(),
            // Phone & Social
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        ArabicData.phone,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SocialIconsBar(
                    facebookUrl: ArabicData.facebookUrl,
                    youtubeUrl: ArabicData.youtubeUrl,
                    telegramUrl: ArabicData.telegramUrl,
                    linkedinUrl: ArabicData.linkedinUrl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. The 5 Slides Carousel (السلايدر فقط في النص)
  // -------------------------------------------------------------
  Widget _buildWidescreenSlider(bool isMobile, double screenWidth) {
    // Exact aspect ratio of the 2048 x 768 panoramic slide images (~2.66667)
    const double imageAspectRatio = 2048.0 / 768.0;
    final double horizontalPadding = isMobile ? 10.0 : 24.0;
    final double maxAllowedWidth = 1200.0;

    // Calculate responsive width and proportional height to prevent any image cropping
    final double contentWidth = (screenWidth - (horizontalPadding * 2)).clamp(280.0, maxAllowedWidth);
    final double sliderHeight = contentWidth / imageAspectRatio;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            // Slide Box with navigation arrows
            Stack(
              alignment: Alignment.center,
              children: [
                // Slide Image Container
                Container(
                  width: contentWidth,
                  height: sliderHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: isMobile ? 14 : 28,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (idx) => setState(() => _currentSlide = idx),
                      itemCount: ArabicData.imageSlides.length,
                      itemBuilder: (ctx, idx) {
                        final slide = ArabicData.imageSlides[idx];
                        return _buildSlideCard(slide, isMobile);
                      },
                    ),
                  ),
                ),

                // Left Arrow (Previous)
                Positioned(
                  left: isMobile ? 4 : 16,
                  child: _buildNavArrow(Icons.arrow_back_ios_new_rounded, _prevSlide, "السابق", isMobile),
                ),

                // Right Arrow (Next)
                Positioned(
                  right: isMobile ? 4 : 16,
                  child: _buildNavArrow(Icons.arrow_forward_ios_rounded, _nextSlide, "التالي", isMobile),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),

            // Dots Navigation Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(ArabicData.imageSlides.length, (i) {
                final isActive = _currentSlide == i;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? (isMobile ? 22 : 28) : 8,
                    height: isMobile ? 6 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF00E5FF) : const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavArrow(IconData icon, VoidCallback onTap, String tooltip, bool isMobile) {
    final double btnSize = isMobile ? 26 : 40;
    final double iconSize = isMobile ? 12 : 18;

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildSlideCard(Map<String, dynamic> slide, bool isMobile) {
    final imagePath = slide["image"] as String;
    final buttonText = slide["buttonText"] as String;
    final buttonType = slide["buttonType"] as String;
    final action = slide["action"] as String;
    final hasSocial = slide["hasSocial"] == true;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. The Slide Image (2048 x 768) scaled to fit 100% with no cut-off
        Image.asset(
          imagePath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.cardDark,
            child: Center(
              child: Text(
                imagePath,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),

        // 2. Subtle Bottom Gradient for button readability
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: isMobile ? 48 : 110,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: isMobile ? 0.75 : 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // 3. The Slide Button & Social Media (Positioned cleanly at bottom)
        Positioned(
          bottom: isMobile ? 5 : 18,
          left: 8,
          right: 8,
          child: Center(
            child: hasSocial
                ? _buildSlide4ActionRow(buttonText, action, isMobile)
                : _buildSlideButton(buttonText, buttonType, action, isMobile),
          ),
        ),
      ],
    );
  }

  // Slide 4: Button + Social Media Icons Row
  Widget _buildSlide4ActionRow(String buttonText, String action, bool isMobile) {
    return Wrap(
      spacing: isMobile ? 8 : 14,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Telegram Button
        _buildSlideButton(buttonText, "telegram", action, isMobile),

        // Social Media Icons (Facebook, YouTube, Telegram, LinkedIn)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 3 : 6,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: SocialIconsBar(
            facebookUrl: ArabicData.facebookUrl,
            youtubeUrl: ArabicData.youtubeUrl,
            telegramUrl: ArabicData.telegramUrl,
            linkedinUrl: ArabicData.linkedinUrl,
            iconSize: isMobile ? 13 : 18,
          ),
        ),
      ],
    );
  }

  // Custom styled button according to user specifications
  Widget _buildSlideButton(String text, String type, String action, bool isMobile) {
    Color bg;
    Color fg;
    Widget? icon;

    final double iconSize = isMobile ? 12 : 18;

    switch (type) {
      case "cyan": // Slides 1, 2, 5
        bg = const Color(0xFF00E5FF); // Vibrant Cyan
        fg = const Color(0xFF000000);
        icon = Icon(Icons.arrow_back_rounded, color: Colors.black, size: iconSize);
        break;
      case "red": // Slide 3 (YouTube)
        bg = const Color(0xFFFF0000); // Red
        fg = Colors.white;
        icon = YouTubeLogo(size: isMobile ? 13 : 20);
        break;
      case "telegram": // Slide 4 (Telegram Blue)
        bg = const Color(0xFF229ED9); // Telegram Blue
        fg = Colors.white;
        icon = TelegramLogo(size: isMobile ? 13 : 20);
        break;
      default:
        bg = const Color(0xFF00E5FF);
        fg = Colors.black;
        icon = Icon(Icons.arrow_back_rounded, size: iconSize);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleSlideAction(action),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 28,
            vertical: isMobile ? 4 : 12,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.5),
                blurRadius: isMobile ? 8 : 18,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(width: isMobile ? 5 : 8),
              Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 11 : 16,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // -------------------------------------------------------------
  // 3. اتعلم معانا (4 Cards)
  // -------------------------------------------------------------
  Widget _buildLearnWithUsSection(bool isMobile, double screenWidth) {
    final cards = [
      _LearnCardData(
        title: "الكورسات",
        description: "كورسات تعليمية منظمة من البداية حتى التطبيق",
        linkText: "استكشف الكورسات",
        icon: Icons.laptop_chromebook_rounded,
        onTap: () {
          launchWebUrl("${ArabicData.whatsappUrl}?text=${Uri.encodeComponent('مرحباً أستاذ إسلام، أود الاستفسار عن تفاصيل الكورسات التعليمية')}");
        },
      ),
      _LearnCardData(
        title: "المحاضرات",
        description: "شرح مبسط ومباشر لمفاهيم البرمجة وعلوم الحاسب والـAI",
        linkText: "شاهد المحاضرات",
        icon: Icons.menu_book_rounded,
        onTap: () {
          launchWebUrl(ArabicData.youtubeUrl);
        },
      ),
      _LearnCardData(
        title: "الذكاء الاصطناعي",
        description: "تعلم استخدام أدوات AI في البرمجة والتعلم وبناء المشاريع",
        linkText: "استكشف محتوى AI",
        icon: Icons.smart_toy_outlined,
        onTap: () {
          launchWebUrl(ArabicData.telegramUrl);
        },
      ),
      _LearnCardData(
        title: "المشاريع",
        description: "طبّق اللي اتعلمته وابنِ مشاريع حقيقية",
        linkText: "شاهد المشاريع",
        icon: Icons.rocket_launch_rounded,
        onTap: () {
          launchWebUrl(ArabicData.githubUrl);
        },
      ),
    ];

    final isWideDesktop = screenWidth >= 1050;
    final isTablet = screenWidth >= 650 && screenWidth < 1050;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Column(
          children: [
            // Section Header
            Text(
              "اتعلم معانا",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "محتوى تعليمي عملي في البرمجة وعلوم الحاسب والذكاء الاصطناعي",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 36),

            // The 4 Cards with perfectly equal dimensions and zero overflow
            if (isWideDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards.map((c) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _LearnWithUsCard(data: c, height: 260),
                    ),
                  );
                }).toList(),
              )
            else if (isTablet)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards.map((c) {
                  return SizedBox(
                    width: (screenWidth - 48 - 16) / 2,
                    child: _LearnWithUsCard(data: c, height: 250),
                  );
                }).toList(),
              )
            else
              Column(
                children: cards.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: _LearnWithUsCard(data: c, height: null),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 4. رحلة التعلم (كيف أتعلم)
  // -------------------------------------------------------------
  Widget _buildLearningJourneySection(bool isMobile, double screenWidth) {
    final steps = [
      _JourneyStepData(
        stepNumber: "01",
        title: "فهم المشكلة والأساسيات",
        description: "استيعاب منطق علوم الحاسب، بنية الذاكرة والخوارزميات بعيداً عن الحفظ أو نسخ الكود الأعمى.",
        icon: Icons.lightbulb_outline_rounded,
      ),
      _JourneyStepData(
        stepNumber: "02",
        title: "التخطيط وهندسة الكود",
        description: "تطبيق مبادئ Clean Architecture وClean Code لتأسيس برمجيات قوية وقابلة للصيانة والتوسع.",
        icon: Icons.architecture_rounded,
      ),
      _JourneyStepData(
        stepNumber: "03",
        title: "توظيف الذكاء الاصطناعي",
        description: "استخدام نماذج وأدوات الـ AI كشريك هندسي ذكي يضاعف إنتاجيتك وسرعة إنجازك.",
        icon: Icons.psychology_outlined,
      ),
      _JourneyStepData(
        stepNumber: "04",
        title: "بناء وإطلاق المشاريع",
        description: "تحويل ما تعلمته إلى مشاريع حقيقية متكاملة تعمل على أرض الواقع وتضيف قيمة لسوق العمل.",
        icon: Icons.rocket_launch_outlined,
      ),
    ];

    final isWideDesktop = screenWidth >= 1050;
    final isTablet = screenWidth >= 650 && screenWidth < 1050;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Column(
          children: [
            // Section Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore_outlined, color: Color(0xFF00E5FF), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "كيف أتعلم؟",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section Title
            Text(
              "رحلة التعلم",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "منهجية واضحة ومدروسة تأخذك خطوة بخطوة من الفهم النظري إلى بناء أنظمة حقيقية بالذكاء الاصطناعي",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 36),

            // 4 Steps with equal dimensions and zero overflow
            if (isWideDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((s) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _JourneyStepCard(data: s, height: 220),
                    ),
                  );
                }).toList(),
              )
            else if (isTablet)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: steps.map((s) {
                  return SizedBox(
                    width: (screenWidth - 48 - 16) / 2,
                    child: _JourneyStepCard(data: s, height: 210),
                  );
                }).toList(),
              )
            else
              Column(
                children: steps.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: _JourneyStepCard(data: s, height: 185),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. Footer (الفوتر: اللوجو والاقسام والحقوق وسياسة الاستخدام)
  // -------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF070A12),
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: 28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (!isMobile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset('assets/images/logo.jpeg', width: 38, height: 38, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ArabicData.brandName,
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // Quick links
                    Row(
                      children: [
                        _footerLink("الكورسات", () {}),
                        _footerLink("الدروس", () {}),
                        _footerLink("التصوير", () => Navigator.of(context).pushNamed('/recording')),
                        _footerLink("من نحن", () => Navigator.of(context).pushNamed('/about')),
                        _footerLink("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                        _footerLink("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                      ],
                    ),

                    // Social
                    const SocialIconsBar(
                      facebookUrl: ArabicData.facebookUrl,
                      youtubeUrl: ArabicData.youtubeUrl,
                      telegramUrl: ArabicData.telegramUrl,
                      linkedinUrl: ArabicData.linkedinUrl,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset('assets/images/logo.jpeg', width: 38, height: 38, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ArabicData.brandName,
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _footerLink("الكورسات", () {}),
                        _footerLink("الدروس", () {}),
                        _footerLink("التصوير", () => Navigator.of(context).pushNamed('/recording')),
                        _footerLink("من نحن", () => Navigator.of(context).pushNamed('/about')),
                        _footerLink("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                        _footerLink("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SocialIconsBar(
                      facebookUrl: ArabicData.facebookUrl,
                      youtubeUrl: ArabicData.youtubeUrl,
                      telegramUrl: ArabicData.telegramUrl,
                      linkedinUrl: ArabicData.linkedinUrl,
                    ),
                  ],
                ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.borderDark),
              const SizedBox(height: 12),

              Text(
                "جميع الحقوق محفوظة © 2026 إسلام عاطف | Code & AI",
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // -------------------------------------------------------------
  // 4. Floating WhatsApp Button (أيقونة الواتس العائم)
  // -------------------------------------------------------------
  Widget _buildFloatingWhatsApp() {
    return Tooltip(
      message: "تواصل عبر واتساب مباشرة: 01100665674",
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => launchWebUrl(ArabicData.whatsappUrl),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: WhatsAppLogo(size: 38, whiteOnly: false),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Data Classes & Widgets for Sections
// -------------------------------------------------------------

class _LearnCardData {
  final String title;
  final String description;
  final String linkText;
  final IconData icon;
  final VoidCallback onTap;

  const _LearnCardData({
    required this.title,
    required this.description,
    required this.linkText,
    required this.icon,
    required this.onTap,
  });
}

class _LearnWithUsCard extends StatefulWidget {
  final _LearnCardData data;
  final double? height;

  const _LearnWithUsCard({
    required this.data,
    this.height,
  });

  @override
  State<_LearnWithUsCard> createState() => _LearnWithUsCardState();
}

class _LearnWithUsCardState extends State<_LearnWithUsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: widget.height,
          constraints: widget.height != null
              ? BoxConstraints.tightFor(height: widget.height)
              : const BoxConstraints(minHeight: 220),
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF131D33) : AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered ? const Color(0xFF00E5FF) : AppColors.borderLightDark,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.35),
                blurRadius: _isHovered ? 24 : 14,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cyan Glowing Icon Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: _isHovered ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: _isHovered ? 0.6 : 0.25),
                      ),
                    ),
                    child: Icon(widget.data.icon, color: const Color(0xFF00E5FF), size: 24),
                  ),
                  const SizedBox(height: 14),

                  // White Title
                  Text(
                    widget.data.title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Light Gray Description
                  Text(
                    widget.data.description,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Text Link with Arrow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.data.linkText,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(right: _isHovered ? 4.0 : 0.0),
                    child: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF00E5FF)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyStepData {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;

  const _JourneyStepData({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _JourneyStepCard extends StatefulWidget {
  final _JourneyStepData data;
  final double height;

  const _JourneyStepCard({
    required this.data,
    required this.height,
  });

  @override
  State<_JourneyStepCard> createState() => _JourneyStepCardState();
}

class _JourneyStepCardState extends State<_JourneyStepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: widget.height,
        transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF131D33) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered ? const Color(0xFF00E5FF) : AppColors.borderLightDark,
            width: _isHovered ? 1.3 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    widget.data.stepNumber,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ),
                Icon(widget.data.icon, color: const Color(0xFF00E5FF), size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.data.title,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.data.description,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
