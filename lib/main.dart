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
import 'pages/courses_page.dart';
import 'pages/lessons_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'services/site_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SiteDataService.instance.init();
  runApp(const EslamAtefApp());
}

class EslamAtefApp extends StatelessWidget {
  const EslamAtefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeManager.themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: "Eslam Atef | Code & AI — تعليم علوم الحاسب والذكاء الاصطناعي",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const Directionality(
                  textDirection: TextDirection.rtl,
                  child: HomePage(),
                ),
            '/courses': (context) => const Directionality(
                  textDirection: TextDirection.rtl,
                  child: CoursesPage(),
                ),
            '/lessons': (context) => const Directionality(
                  textDirection: TextDirection.rtl,
                  child: LessonsPage(),
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
            '/admin': (context) => const Directionality(
                  textDirection: TextDirection.rtl,
                  child: AdminDashboardPage(),
                ),
          },
        );
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
  final ScrollController _newsScrollController = ScrollController();
  bool _showChallengeHint = false;
  int _quizCurrentIndex = 0;
  int? _quizSelectedOption;
  bool _quizAnswered = false;
  int _quizScore = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    SiteDataService.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
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
    _newsScrollController.dispose();
    SiteDataService.instance.removeListener(_onDataChanged);
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
                    // 1. الاسلايدر (Hero Slider)
                    _buildWidescreenSlider(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 36 : 60),

                    // 2. شريط الاخبار (Latest News/Updates - Square Carousel)
                    _buildLatestNewsSection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 44 : 70),

                    // 3. تحدي الاسبوع (Weekly Challenge)
                    _buildWeeklyChallengeSection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 44 : 70),

                    // 4. رحله التعلم (Learning Journey - Redesigned)
                    _buildLearningJourneySection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 44 : 70),

                    // 5. اختبر نفسك (Test Yourself / Interactive Quiz)
                    _buildTestYourselfSection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 44 : 70),

                    // 6. اتعلم معانا (Learn with Us - Redesigned Display Only)
                    _buildLearnWithUsSection(isMobile, screenWidth),
                    SizedBox(height: isMobile ? 44 : 70),

                    // 7. الفوتر
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
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                              letterSpacing: 0.5,
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
                    _navItem("الكورسات", () => Navigator.of(context).pushNamed('/courses')),
                    _navItem("الدروس", () => Navigator.of(context).pushNamed('/lessons')),
                    _navItem("من نحن", () => Navigator.of(context).pushNamed('/about')),
                    _navItem("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                    _navItem("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                  ],
                ),

              // Theme Toggle & Social Icons / Mobile Menu Button
              if (!isMobile)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF1E293B),
                        size: 22,
                      ),
                      tooltip: Theme.of(context).brightness == Brightness.dark
                          ? "تفعيل الوضع النهاري"
                          : "تفعيل الوضع الليلي",
                      onPressed: () => AppThemeManager.toggleTheme(),
                    ),
                    const SizedBox(width: 8),
                    const SocialIconsBar(
                      facebookUrl: ArabicData.facebookUrl,
                      youtubeUrl: ArabicData.youtubeUrl,
                      telegramUrl: ArabicData.telegramUrl,
                      linkedinUrl: ArabicData.linkedinUrl,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF1E293B),
                        size: 22,
                      ),
                      onPressed: () => AppThemeManager.toggleTheme(),
                    ),
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.primaryLight, size: 28),
                        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
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
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
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
                Navigator.of(context).pushNamed('/courses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined, color: AppColors.primaryLight),
              title: Text("الدروس", style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/lessons');
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
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF00E5FF)),
              title: Text("لوحة التحكم", style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: const Color(0xFF00E5FF))),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/admin');
              },
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
              ),
              onTap: () {
                AppThemeManager.toggleTheme();
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
  // 1. شريط الإضافات والأخبار (Square Carousel - Courses & Lessons)
  // -------------------------------------------------------------
  Widget _buildLatestNewsSection(bool isMobile, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final updates = SiteDataService.instance.latestUpdates;

    // If empty: Show clean placeholder with NO fake data
    if (updates.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 22 : 30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00E5FF), size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "أحدث الإضافات والتحديثات",
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        "شريط الإضافات خالي من البيانات الوهمية — يمكنك إضافة الكورسات والدروس من لوحة التحكم لتظهر هنا مباشرة.",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/admin'),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text("إضافة تحديث", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Column(
          children: [
            // Top Badge & Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E5FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "محتوى متجدد أسبوعياً",
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00E5FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "أحدث الإضافات والتحديثات",
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "استكشف أحدث الكورسات والدروس التي تم إضافتها حديثاً للمنصة",
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 13 : 15,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      _buildCarouselArrow(Icons.arrow_forward_ios_rounded, () {
                        _newsScrollController.animateTo(
                          (_newsScrollController.offset + 300).clamp(
                            0.0,
                            _newsScrollController.position.maxScrollExtent,
                          ),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      }),
                      const SizedBox(width: 10),
                      _buildCarouselArrow(Icons.arrow_back_ios_new_rounded, () {
                        _newsScrollController.animateTo(
                          (_newsScrollController.offset - 300).clamp(
                            0.0,
                            _newsScrollController.position.maxScrollExtent,
                          ),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      }),
                    ],
                  ),
              ],
            ),
            SizedBox(height: isMobile ? 18 : 26),

            // Horizontal Square Slider
            SizedBox(
              height: isMobile ? 260 : 280,
              child: ListView.separated(
                controller: _newsScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: updates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 18),
                itemBuilder: (context, index) {
                  final item = updates[index];
                  return _SquareNewsCard(item: item, isMobile: isMobile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselArrow(IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderLightDark : AppColors.borderLight),
          ),
          child: Icon(icon, size: 16, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. تحدي الأسبوع (Weekly Coding Challenge)
  // -------------------------------------------------------------
  Widget _buildWeeklyChallengeSection(bool isMobile, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final challenge = SiteDataService.instance.weeklyChallenge;

    // If no challenge active: Show clean placeholder with NO fake data
    if (challenge == null || challenge['active'] == false) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 22 : 30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.code_rounded, color: Color(0xFFFFB300), size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تحدي الأسبوع البرمجي",
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        "تم إفراغ المسائل الوهمية — سيتم إطلاق التحدي القادم قريباً! يمكنك كتابة وتفعيل التحدي الجديد من لوحة التحكم.",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/admin'),
                    icon: const Icon(Icons.settings, size: 16),
                    label: Text("إدارة التحدي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

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
                color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code_rounded, color: Color(0xFFFFB300), size: 17),
                  const SizedBox(width: 8),
                  Text(
                    "تحدي الأسبوع البرمجي",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "تحدي الأسبوع: حلل، فكّر، وطبق",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "مسألة برمجية أسبوعية حقيقية لتنمية التفكير المنطقي وهندسة الخوارزميات",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 13 : 15,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 20 : 32),

            // High-Tech IDE / Terminal Mockup Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IDE Top Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1424) : const Color(0xFFF1F5F9),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                      border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        // macOS Window Dots
                        Row(
                          children: [
                            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(width: 18),
                        Text(
                          "challenge_active.py",
                          style: GoogleFonts.firaCode(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27C93F).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(
                                "تحدي نشط",
                                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF27C93F)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // IDE Body
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meta Row
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if ((challenge['week'] ?? '').isNotEmpty)
                              _challengeChip(Icons.calendar_today_rounded, challenge['week'], const Color(0xFF00E5FF)),
                            if ((challenge['difficulty'] ?? '').isNotEmpty)
                              _challengeChip(Icons.speed_rounded, challenge['difficulty'], const Color(0xFFFFB300)),
                            if ((challenge['daysLeft'] ?? '').isNotEmpty)
                              _challengeChip(Icons.timer_outlined, challenge['daysLeft'], const Color(0xFFFF5252)),
                            if ((challenge['participants'] ?? 0) > 0)
                              _challengeChip(Icons.groups_outlined, "${challenge['participants']} مشارك", const Color(0xFF69F0AE)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Title
                        Text(
                          challenge['title'] ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Scenario
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              right: BorderSide(color: Color(0xFF00E5FF), width: 3.5),
                            ),
                          ),
                          child: Text(
                            challenge['scenario'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: isMobile ? 13.5 : 15,
                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Test Case Terminal Box
                        if ((challenge['input'] ?? '').isNotEmpty || (challenge['output'] ?? '').isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF060911),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.terminal_rounded, size: 18, color: Color(0xFF00E5FF)),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Test Case Preview",
                                      style: GoogleFonts.firaCode(fontSize: 12, color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                if ((challenge['input'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    ">>> Input:  ${challenge['input']}",
                                    style: GoogleFonts.firaCode(fontSize: 13, color: const Color(0xFFFFBD2E)),
                                  ),
                                ],
                                if ((challenge['output'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    ">>> Output: ${challenge['output']}",
                                    style: GoogleFonts.firaCode(fontSize: 13, color: const Color(0xFF27C93F)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        // Hint Container (Collapsible)
                        if (_showChallengeHint && (challenge['hint'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB300), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    challenge['hint'],
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: const Color(0xFFFFE082),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),

                        // Actions Row
                        Wrap(
                          spacing: 14,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showChallengeSubmitDialog(challenge['title'] ?? ''),
                              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                              label: Text(
                                "إرسال الحل والتقييم 🚀",
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: const Color(0xFF040812),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                            if ((challenge['hint'] ?? '').isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _showChallengeHint = !_showChallengeHint),
                                icon: Icon(
                                  _showChallengeHint ? Icons.visibility_off_outlined : Icons.lightbulb_outline_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _showChallengeHint ? "إخفاء التلميح" : "عرض تلميح الخوارزمية",
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFB300),
                                  side: const BorderSide(color: Color(0xFFFFB300)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _showChallengeSubmitDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
            ),
            title: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: Color(0xFF00E5FF)),
                const SizedBox(width: 10),
                Text(
                  "تسليم حل تحدي الأسبوع",
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            content: Text(
              "أرسل كود الحل الخاص بك مباشرة للأستاذ إسلام عاطف لمراجعته وتقييم الخوارزمية، وسيتم إعلان أسماء المتفوقين في لوحة شرف الأسبوع!",
              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("إلغاء", style: GoogleFonts.cairo(color: AppColors.textMuted)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  launchWebUrl(
                    "${ArabicData.whatsappUrl}?text=${Uri.encodeComponent('مرحباً أستاذ إسلام عاطف، أود تسليم حل تحدي الأسبوع البرمجي ($title):\n[ضع كود الحل هنا]')}",
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text("إرسال عبر واتساب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 3. رحلة التعلم (Redesigned with glowing futuristic cards)
  // -------------------------------------------------------------
  Widget _buildLearningJourneySection(bool isMobile, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = [
      _JourneyStepData(
        stepNumber: "01",
        title: "فهم المشكلة والأساسيات",
        description: "استيعاب منطق علوم الحاسب، بنية الذاكرة والخوارزميات بعيداً عن الحفظ أو نسخ الكود الأعمى.",
        icon: Icons.lightbulb_outline_rounded,
        accentColor: const Color(0xFF00E5FF),
      ),
      _JourneyStepData(
        stepNumber: "02",
        title: "التخطيط وهندسة الكود",
        description: "تطبيق مبادئ Clean Architecture وClean Code لتأسيس برمجيات قوية وقابلة للصيانة والتوسع.",
        icon: Icons.architecture_rounded,
        accentColor: const Color(0xFF3B82F6),
      ),
      _JourneyStepData(
        stepNumber: "03",
        title: "توظيف الذكاء الاصطناعي",
        description: "استخدام نماذج وأدوات الـ AI كشريك هندسي ذكي يضاعف إنتاجيتك وسرعة إنجازك.",
        icon: Icons.psychology_outlined,
        accentColor: const Color(0xFFA855F7),
      ),
      _JourneyStepData(
        stepNumber: "04",
        title: "بناء وإطلاق المشاريع",
        description: "تحويل ما تعلمته إلى مشاريع حقيقية متكاملة تعمل على أرض الواقع وتضيف قيمة لسوق العمل.",
        icon: Icons.rocket_launch_outlined,
        accentColor: const Color(0xFF10B981),
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
                    "خارطة الطريق",
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
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "منهجية واضحة ومدروسة تأخذك خطوة بخطوة من الفهم النظري إلى بناء أنظمة حقيقية بالذكاء الاصطناعي",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 14 : 16,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 36),

            // 4 Steps Cards Grid
            if (isWideDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((s) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _JourneyStepCard(data: s, height: 260),
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
                    child: _JourneyStepCard(data: s, height: 250),
                  );
                }).toList(),
              )
            else
              Column(
                children: steps.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: _JourneyStepCard(data: s, height: null),
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
  // 4. اختبر نفسك (Interactive Quiz Component)
  // -------------------------------------------------------------
  Widget _buildTestYourselfSection(bool isMobile, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = SiteDataService.instance.quizQuestions;

    // If no questions: Show clean placeholder with NO fake data
    if (questions.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 22 : 30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.quiz_rounded, color: Color(0xFF10B981), size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "اختبر نفسك",
                        style: GoogleFonts.cairo(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        "تم مسح الأسئلة الوهمية — سيتم طرح أسئلة اختبارية جديدة قريباً! يمكنك إضافة وإدارة أسئلتك الفعلية من لوحة التحكم.",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/admin'),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text("إضافة أسئلة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (_quizCompleted) {
      return _buildQuizCompletedView(isMobile, questions.length);
    }

    if (_quizCurrentIndex >= questions.length) {
      _quizCurrentIndex = 0;
    }

    final currentQ = questions[_quizCurrentIndex];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz_rounded, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "تطبيق عملي فوري",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "اختبر نفسك",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "أسئلة ذكية وسريعة لقياس فهمك لمفاهيم علوم الحاسب والبرمجة والذكاء الاصطناعي",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 13 : 15,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 20 : 30),

            // Quiz Container Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Top Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                      border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "السؤال ${_quizCurrentIndex + 1} من ${questions.length}",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "النقاط: $_quizScore",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Question Body
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Text
                        Text(
                          currentQ['question'] ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: isMobile ? 16 : 19,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options
                        ...((currentQ['options'] as List<dynamic>? ?? []).cast<String>()).asMap().entries.map((entry) {
                          final optIdx = entry.key;
                          final optText = entry.value;
                          final isSelected = _quizSelectedOption == optIdx;
                          final isCorrect = optIdx == currentQ['correctIndex'];

                          Color cardBg = isDark ? const Color(0xFF131D33) : const Color(0xFFF1F5F9);
                          Color borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
                          Color textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
                          IconData? trailingIcon;

                          if (_quizAnswered) {
                            if (isCorrect) {
                              cardBg = const Color(0xFF064E3B);
                              borderColor = const Color(0xFF10B981);
                              textColor = Colors.white;
                              trailingIcon = Icons.check_circle_rounded;
                            } else if (isSelected && !isCorrect) {
                              cardBg = const Color(0xFF7F1D1D);
                              borderColor = const Color(0xFFEF4444);
                              textColor = Colors.white;
                              trailingIcon = Icons.cancel_rounded;
                            } else {
                              cardBg = (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)).withValues(alpha: 0.5);
                              textColor = AppColors.textMuted;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MouseRegion(
                              cursor: _quizAnswered ? SystemMouseCursors.basic : SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _quizAnswered
                                    ? null
                                    : () {
                                        setState(() {
                                          _quizSelectedOption = optIdx;
                                          _quizAnswered = true;
                                          if (isCorrect) {
                                            _quizScore += 25;
                                          }
                                        });
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor, width: 1.4),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? const Color(0xFF00E5FF)
                                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${optIdx + 1}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: GoogleFonts.cairo(
                                            fontSize: isMobile ? 13.5 : 15,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: textColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      if (trailingIcon != null) ...[
                                        const SizedBox(width: 10),
                                        Icon(
                                          trailingIcon,
                                          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          size: 22,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Explanation & Next Button (when answered)
                        if (_quizAnswered) ...[
                          if ((currentQ['explanation'] ?? '').isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQ['explanation'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFFE0F2FE) : const Color(0xFF0369A1),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (_quizCurrentIndex + 1 < questions.length) {
                                    _quizCurrentIndex++;
                                    _quizSelectedOption = null;
                                    _quizAnswered = false;
                                  } else {
                                    _quizCompleted = true;
                                  }
                                });
                              },
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: Text(
                                _quizCurrentIndex + 1 < questions.length ? "السؤال التالي" : "عرض النتيجة النهائية",
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCompletedView(bool isMobile, int totalQuestions) {
    final maxScore = totalQuestions * 25;
    final percentage = maxScore > 0 ? ((_quizScore / maxScore) * 100).toInt() : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24 : 36),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF10B981), size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                "أحسنت! أتممت الاختبار بنجاح 🎉",
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 20 : 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "النتيجة: $_quizScore من $maxScore نقطة ($percentage%)",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                percentage >= 75
                    ? "مستوى استيعاب ممتاز! أنت تمتلك أساساً علمياً متيناً للانطلاق في تطبيقات الذكاء الاصطناعي وهندسة البرمجيات."
                    : "محاولة جيدة جداً! ننصحك بمراجعة محتوى المحاضرة التأسيسية لتعزيز فهم المفاهيم بشكل أعمق.",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _quizCurrentIndex = 0;
                    _quizSelectedOption = null;
                    _quizAnswered = false;
                    _quizScore = 0;
                    _quizCompleted = false;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text("إعادة الاختبار", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. اتعلم معانا (Fixed Dimensions - No Bottom Overflow Bar)
  // -------------------------------------------------------------
  Widget _buildLearnWithUsSection(bool isMobile, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cards = [
      const _LearnCardData(
        title: "الكورسات",
        description: "مسارات تعليمية مهنية متكاملة من البداية وحتى الاحتراف وسوق العمل",
        icon: Icons.laptop_chromebook_rounded,
        tag: "مسارات متكاملة",
        bullets: [
          "تأسيس منطق البرمجة وهندسة الخوارزميات",
          "تطبيقات عملية ومشاريع كود نظيف",
          "متابعة واختبارات مستمرة لتقييم المستوى",
        ],
        accentColor: Color(0xFF00E5FF),
      ),
      const _LearnCardData(
        title: "المحاضرات",
        description: "شرح تفصيلي مبسط لأعقد مفاهيم علوم الحاسب وهندسة البرمجيات",
        icon: Icons.menu_book_rounded,
        tag: "شرح أكاديمي مباشر",
        bullets: [
          "تشريح بنية الذاكرة ونظام التشغيل",
          "تحليل البيانات والمعلومات والمعرفة",
          "جودة إنتاج ومونتاج مرئي فائق الوضوح",
        ],
        accentColor: Color(0xFF3B82F6),
      ),
      const _LearnCardData(
        title: "الذكاء الاصطناعي",
        description: "توظيف نماذج LLM وأحدث أدوات AI في البرمجة وهندسة المشروعات",
        icon: Icons.smart_toy_outlined,
        tag: "أحدث التقنيات",
        bullets: [
          "تطبيقات وكلاء الذكاء الاصطناعي (AI Agents)",
          "تقنيات RAG وتكامل قواعد البيانات المتجهة",
          "مضاعفة إنتاجية المطور باستخدام الذكاء الاصطناعي",
        ],
        accentColor: Color(0xFFA855F7),
      ),
      const _LearnCardData(
        title: "المشاريع الحقيقية",
        description: "تحويل العلم إلى منتجات برمجية فعلية ترفع من قيمة ملفك المهني",
        icon: Icons.rocket_launch_rounded,
        tag: "مخرجات عملية",
        bullets: [
          "مستودعات كود مفتوحة المصدر على GitHub",
          "تطبيق معايير Clean Architecture",
          "نشر وتشغيل التطبيقات على السحابة",
        ],
        accentColor: Color(0xFF10B981),
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
            // Badge
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
                  const Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "ركائز التعلم",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section Header
            Text(
              "اتعلم معانا",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "محتوى تعليمي هندسي رصين في البرمجة وعلوم الحاسب والذكاء الاصطناعي",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 14 : 16,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 36),

            // Sizing: IntrinsicHeight ensures equal height across all 4 cards without bottom scrollbar or overflow
            if (isWideDesktop)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cards.map((c) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _LearnWithUsCard(data: c),
                      ),
                    );
                  }).toList(),
                ),
              )
            else if (isTablet)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards.map((c) {
                  return SizedBox(
                    width: (screenWidth - 48 - 16) / 2,
                    child: _LearnWithUsCard(data: c),
                  );
                }).toList(),
              )
            else
              Column(
                children: cards.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: _LearnWithUsCard(data: c),
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
  // 6. Footer (الفوتر: اللوجو والاقسام والحقوق وسياسة الاستخدام والتصوير ولوحة التحكم)
  // -------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070A12) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: 32),
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
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),

                    // Quick links
                    Row(
                      children: [
                        _footerLink("الكورسات", () => Navigator.of(context).pushNamed('/courses')),
                        _footerLink("الدروس", () => Navigator.of(context).pushNamed('/lessons')),
                        _footerLink("من نحن", () => Navigator.of(context).pushNamed('/about')),
                        _footerLink("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                        _footerLink("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                        _footerLink("استوديو التصوير 🎬", () => Navigator.of(context).pushNamed('/recording')),
                        _footerLink("لوحة التحكم ⚙️", () => Navigator.of(context).pushNamed('/admin')),
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
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _footerLink("الكورسات", () => Navigator.of(context).pushNamed('/courses')),
                        _footerLink("الدروس", () => Navigator.of(context).pushNamed('/lessons')),
                        _footerLink("من نحن", () => Navigator.of(context).pushNamed('/about')),
                        _footerLink("سياسة الاستخدام والخصوصية", () => Navigator.of(context).pushNamed('/privacy')),
                        _footerLink("تواصل معنا", () => Navigator.of(context).pushNamed('/contact')),
                        _footerLink("استوديو التصوير 🎬", () => Navigator.of(context).pushNamed('/recording')),
                        _footerLink("لوحة التحكم ⚙️", () => Navigator.of(context).pushNamed('/admin')),
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
              Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              const SizedBox(height: 12),

              Text(
                "جميع الحقوق محفوظة © 2026 Eslam Atef | Code & AI",
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 7. Floating WhatsApp Button (أيقونة الواتس العائم)
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

// Square News Card for Latest Updates
class _SquareNewsCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isMobile;

  const _SquareNewsCard({required this.item, required this.isMobile});

  @override
  State<_SquareNewsCard> createState() => _SquareNewsCardState();
}

class _SquareNewsCardState extends State<_SquareNewsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isCourse = widget.item['type'] == 'course';
    final accentColor = isCourse ? const Color(0xFF00E5FF) : const Color(0xFFFFB300);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final route = widget.item['route'] ?? (isCourse ? '/courses' : '/lessons');
          Navigator.of(context).pushNamed(route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: widget.isMobile ? 260 : 280,
          height: widget.isMobile ? 260 : 280,
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? accentColor : const Color(0xFF1E293B),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? accentColor.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.4),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    widget.item['image'] ?? 'assets/images/slide1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: const Color(0xFF0A0F1D)),
                  ),
                ),
                // Deep dark cyber gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF070B14).withValues(alpha: 0.65),
                          const Color(0xFF070B14).withValues(alpha: 0.92),
                          const Color(0xFF070B14),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Category badge & duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              widget.item['category'] ?? '',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                          if ((widget.item['duration'] ?? '').isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.item['duration'],
                                    style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Bottom Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((widget.item['badge'] ?? '').isNotEmpty) ...[
                            Text(
                              widget.item['badge'],
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            widget.item['title'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                "استكشف المحتوى",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedPadding(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.only(right: _isHovered ? 4.0 : 0.0),
                                child: Icon(Icons.arrow_back_rounded, size: 14, color: accentColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Learn With Us Card Data
class _LearnCardData {
  final String title;
  final String description;
  final IconData icon;
  final String tag;
  final List<String> bullets;
  final Color accentColor;

  const _LearnCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.tag,
    required this.bullets,
    required this.accentColor,
  });
}

// Redesigned Non-Clickable Learn Showcase Card (Fixed Dimensions - Zero Overflow)
class _LearnWithUsCard extends StatefulWidget {
  final _LearnCardData data;

  const _LearnWithUsCard({
    required this.data,
  });

  @override
  State<_LearnWithUsCard> createState() => _LearnWithUsCardState();
}

class _LearnWithUsCardState extends State<_LearnWithUsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.basic, // User explicitly requested display-only, non-clickable
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 340),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? (_isHovered
                    ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                    : [const Color(0xFF0E1626), const Color(0xFF0A0F1D)])
                : (_isHovered
                    ? [Colors.white, const Color(0xFFF1F5F9)]
                    : [Colors.white, const Color(0xFFF8FAFC)]),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? widget.data.accentColor.withValues(alpha: 0.8) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.data.accentColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: _isHovered ? 24 : 14,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: 3D Glowing Icon + Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.data.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.data.accentColor.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.accentColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(widget.data.icon, color: widget.data.accentColor, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.data.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.data.tag,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.data.accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.data.title,
              style: GoogleFonts.cairo(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              widget.data.description,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),

            // 3 Highlights/Bullets
            ...widget.data.bullets.map((bullet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: widget.data.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bullet,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 14),

            // Bottom subtle indicator (Non-interactive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.data.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "ركيزة أساسية في المنصة",
                    style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Learning Journey Step Data
class _JourneyStepData {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _JourneyStepData({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

// Redesigned Journey Step Card with Glowing Medallion
class _JourneyStepCard extends StatefulWidget {
  final _JourneyStepData data;
  final double? height;

  const _JourneyStepCard({
    required this.data,
    this.height,
  });

  @override
  State<_JourneyStepCard> createState() => _JourneyStepCardState();
}

class _JourneyStepCardState extends State<_JourneyStepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: widget.height,
        constraints: widget.height != null
            ? BoxConstraints.tightFor(height: widget.height)
            : const BoxConstraints(minHeight: 230),
        transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: isDark
              ? (_isHovered ? const Color(0xFF131D33) : const Color(0xFF0F172A))
              : (_isHovered ? Colors.white : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? widget.data.accentColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.data.accentColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: _isHovered ? 22 : 12,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Number Medallion & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Glowing Number Medallion
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.data.accentColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.data.accentColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.accentColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.data.stepNumber,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: widget.data.accentColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.data.icon, color: widget.data.accentColor, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              widget.data.title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              widget.data.description,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                height: 1.55,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

