import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/site_data_service.dart';
import '../widgets/article_content_renderer.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _dataService = SiteDataService.instance;

  // 0: Hub Overview (5 Cards)
  // 1: Courses (الكورسات والمقالات)
  // 2: Lessons (الدروس والتدوينات)
  // 3: Latest Updates (شريط جديدنا)
  // 4: Weekly Challenge (تحدي الأسبوع)
  // 5: Quiz Bank (اختبر نفسك)
  int _currentSection = 0;

  // Challenge form controllers
  final _challengeWeekCtrl = TextEditingController();
  final _challengeTitleCtrl = TextEditingController();
  final _challengeDiffCtrl = TextEditingController();
  final _challengeDaysCtrl = TextEditingController();
  final _challengeScenarioCtrl = TextEditingController();
  final _challengeInputCtrl = TextEditingController();
  final _challengeOutputCtrl = TextEditingController();
  final _challengeHintCtrl = TextEditingController();
  final _challengeParticipantsCtrl = TextEditingController();
  bool _challengeActive = false;

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    _loadChallengeData();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _loadChallengeData() {
    final c = _dataService.weeklyChallenge;
    if (c != null) {
      _challengeActive = c['active'] ?? true;
      _challengeWeekCtrl.text = c['week'] ?? '';
      _challengeTitleCtrl.text = c['title'] ?? '';
      _challengeDiffCtrl.text = c['difficulty'] ?? '';
      _challengeDaysCtrl.text = c['daysLeft'] ?? '';
      _challengeScenarioCtrl.text = c['scenario'] ?? '';
      _challengeInputCtrl.text = c['input'] ?? '';
      _challengeOutputCtrl.text = c['output'] ?? '';
      _challengeHintCtrl.text = c['hint'] ?? '';
      _challengeParticipantsCtrl.text = (c['participants'] ?? 0).toString();
    } else {
      _challengeActive = false;
    }
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _challengeWeekCtrl.dispose();
    _challengeTitleCtrl.dispose();
    _challengeDiffCtrl.dispose();
    _challengeDaysCtrl.dispose();
    _challengeScenarioCtrl.dispose();
    _challengeInputCtrl.dispose();
    _challengeOutputCtrl.dispose();
    _challengeHintCtrl.dispose();
    _challengeParticipantsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
        // WordPress-Style Top Admin Bar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: _buildWordPressTopBar(isDark),
        ),
        body: Row(
          children: [
            // WordPress-Style Sidebar on Desktop
            if (isDesktop) _buildWordPressSidebar(isDark),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildActiveView(isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. WordPress Top Admin Bar
  // ==========================================
  Widget _buildWordPressTopBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Brand & WordPress Admin Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.dashboard_customize_rounded, color: Color(0xFF00E5FF), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Eslam Atef",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "لوحة الإدارة v2.0",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "نظام إدارة المحتوى والمقالات البرمجية",
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Actions (Theme, View Site)
          Row(
            children: [
              // Theme Switcher
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
                  size: 20,
                ),
                tooltip: isDark ? "الوضع النهاري" : "الوضع الليلي",
                onPressed: () => AppThemeManager.toggleTheme(),
              ),
              const SizedBox(width: 8),

              // View Live Website Button
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/'),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: Text(
                  "معاينة الموقع الرئيسي",
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. WordPress-Style Sidebar (Desktop)
  // ==========================================
  Widget _buildWordPressSidebar(bool isDark) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B101E) : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.menu_open_rounded, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  "القائمة الرئيسية",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sidebarItem(0, "لوحة التحكم الرئيسية", Icons.home_rounded, isDark),
          _sidebarItem(1, "إدارة الكورسات (مقالات)", Icons.laptop_chromebook_rounded, isDark),
          _sidebarItem(2, "إدارة الدروس (تدوينات)", Icons.menu_book_rounded, isDark),
          _sidebarItem(3, "شريط جديدنا", Icons.auto_awesome_rounded, isDark),
          _sidebarItem(4, "تحدي الأسبوع", Icons.bolt_rounded, isDark),
          _sidebarItem(5, "بنك اختبر نفسك", Icons.psychology_rounded, isDark),
          const Spacer(),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  child: const Text("EA", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Eslam Atef",
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Text(
                        "مشرف النظام (Admin)",
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, String title, IconData icon, bool isDark) {
    final isSelected = _currentSection == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _currentSection = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.16 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isSelected
                      ? const Color(0xFF00E5FF)
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF00E5FF)
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
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

  // ==========================================
  // 3. Router for Active Section
  // ==========================================
  Widget _buildActiveView(bool isDark) {
    switch (_currentSection) {
      case 0:
        return _buildHubOverview(isDark);
      case 1:
        return _buildCoursesSection(isDark);
      case 2:
        return _buildLessonsSection(isDark);
      case 3:
        return _buildLatestUpdatesSection(isDark);
      case 4:
        return _buildWeeklyChallengeSection(isDark);
      case 5:
        return _buildQuizQuestionsSection(isDark);
      default:
        return _buildHubOverview(isDark);
    }
  }

  // ==========================================
  // SECTION 0: The 5 WordPress Hub Cards
  // "عايزها ٥ كروت مش يتحرك يمين وشمال كل كارت افتحه صفحه منفصله"
  // ==========================================
  Widget _buildHubOverview(bool isDark) {
    final coursesCount = _dataService.courses.length;
    final lessonsCount = _dataService.lessons.length;
    final updatesCount = _dataService.latestUpdates.length;
    final challenge = _dataService.weeklyChallenge;
    final isChallengeActive = challenge != null && (challenge['active'] ?? false);
    final quizCount = _dataService.quizQuestions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                  : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "مرحباً بك أستاذ إسلام عاطف 👋",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "لوحة التحكم ونشر المقالات — WordPress Mode",
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "اختر أي قسم من الكروت الـ 5 أدناه لفتحه كصفحة مستقلة وإدارته بالكامل (إضافة مقالات، صور، HTML، تعديل أو حذف).",
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "أقسام الإدارة الرئيسية (5 كروت)",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              "اضغط على أي كارت للدخول لصفحته",
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid of 5 Hub Cards (Clean, Fixed, NOT moving left and right)
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 750;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                // Card 1: Courses
                SizedBox(
                  width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2,
                  child: _buildHubCard(
                    title: "إدارة الكورسات والمسارات",
                    countText: "$coursesCount كورس منشور",
                    description: "نشر مسارات تدريبية كاملة بنظام المقالات (صور، شرح تفصيلي، وسوم HTML، تصنيف ومستوى).",
                    icon: Icons.laptop_chromebook_rounded,
                    accentColor: const Color(0xFF00E5FF),
                    badge: "نظام المقالات",
                    isDark: isDark,
                    onOpen: () => setState(() => _currentSection = 1),
                    onQuickAdd: () {
                      setState(() => _currentSection = 1);
                      _showArticleDialog(isCourse: true);
                    },
                  ),
                ),

                // Card 2: Lessons
                SizedBox(
                  width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2,
                  child: _buildHubCard(
                    title: "إدارة الدروس والمقالات (المدونة)",
                    countText: "$lessonsCount مقال ودرس",
                    description: "كتابة شروحات برمجية ومقالات بلوجر تقنية مع إرفاق صور وأكواد برمجية وتنسيقات HTML.",
                    icon: Icons.menu_book_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    badge: "بلوجر / مقالات",
                    isDark: isDark,
                    onOpen: () => setState(() => _currentSection = 2),
                    onQuickAdd: () {
                      setState(() => _currentSection = 2);
                      _showArticleDialog(isCourse: false);
                    },
                  ),
                ),

                // Card 3: Latest Updates
                SizedBox(
                  width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2,
                  child: _buildHubCard(
                    title: "شريط جديدنا على المنصة",
                    countText: "$updatesCount تحديث إضافي",
                    description: "إدارة العناصر الإضافية في السلايدر الأفقي العلوي (الكورسات والدروس تظهر فيه تلقائياً).",
                    icon: Icons.auto_awesome_rounded,
                    accentColor: const Color(0xFF10B981),
                    badge: "السلايدر العلوي",
                    isDark: isDark,
                    onOpen: () => setState(() => _currentSection = 3),
                    onQuickAdd: () {
                      setState(() => _currentSection = 3);
                      _showLatestUpdateDialog();
                    },
                  ),
                ),

                // Card 4: Weekly Challenge
                SizedBox(
                  width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2,
                  child: _buildHubCard(
                    title: "تحدي الأسبوع البرمجي",
                    countText: isChallengeActive ? "نشط حالياً 🔥" : "معطل حالياً",
                    description: "كتابة سيناريو التحدي الأسبوعي، مواصفات المدخلات والمخرجات، التلميح، ورابط التسليم.",
                    icon: Icons.bolt_rounded,
                    accentColor: const Color(0xFFFFB300),
                    badge: isChallengeActive ? "نشط" : "غير نشط",
                    isDark: isDark,
                    onOpen: () => setState(() => _currentSection = 4),
                  ),
                ),

                // Card 5: Quiz Bank
                SizedBox(
                  width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2,
                  child: _buildHubCard(
                    title: "بنك أسئلة اختبر نفسك",
                    countText: "$quizCount سؤال متاح",
                    description: "إضافة وتعديل أسئلة الاختيار من متعدد مع الشروحات العلمية الفورية والتفسير المنطقي.",
                    icon: Icons.psychology_rounded,
                    accentColor: const Color(0xFFA855F7),
                    badge: "اختبارات تفاعلية",
                    isDark: isDark,
                    onOpen: () => setState(() => _currentSection = 5),
                    onQuickAdd: () {
                      setState(() => _currentSection = 5);
                      _showQuizQuestionDialog();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHubCard({
    required String title,
    required String countText,
    required String description,
    required IconData icon,
    required Color accentColor,
    required String badge,
    required bool isDark,
    required VoidCallback onOpen,
    VoidCallback? onQuickAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Count + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  countText,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            description,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text("فتح الصفحة ➔", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              if (onQuickAdd != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onQuickAdd,
                  icon: const Icon(Icons.add_rounded),
                  tooltip: "إضافة سريعة",
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    foregroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Section Navigation Header (Breadcrumb + Back)
  // ==========================================
  Widget _buildSectionHeader(String sectionTitle, String actionText, VoidCallback onAction, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back to Hub + Breadcrumb
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _currentSection = 0),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text("الرئيسية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00E5FF),
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  sectionTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),

            // Primary Action Button
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionText, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==========================================
  // SECTION 1: إدارة الكورسات (نظام المقالات)
  // ==========================================
  Widget _buildCoursesSection(bool isDark) {
    final courses = _dataService.courses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          "إدارة الكورسات (${courses.length})",
          "+ إضافة كورس / مقال جديد",
          () => _showArticleDialog(isCourse: true),
          isDark,
        ),

        if (courses.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد كورسات مضافة بعد",
            "قم بنشر أول كورس أو مسار تدريبي بكامل تفاصيله ومقالاته الآن ليظهر مباشرة في الموقع للمستخدمين.",
            isDark,
          )
        else
          ...courses.map((c) => _buildArticleItemCard(c, isCourse: true, isDark: isDark)),
      ],
    );
  }

  // ==========================================
  // SECTION 2: إدارة الدروس (المدونة التقنية)
  // ==========================================
  Widget _buildLessonsSection(bool isDark) {
    final lessons = _dataService.lessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          "إدارة الدروس والمقالات (${lessons.length})",
          "+ كتابة مقال / درس جديد",
          () => _showArticleDialog(isCourse: false),
          isDark,
        ),

        if (lessons.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد دروس أو مقالات منشورة بعد",
            "ابدأ بنشر أول مقال أو تدوينة تقنية بنظام البلوجر مع إضافة الصور والأكواد البرمجية والوسوم.",
            isDark,
          )
        else
          ...lessons.map((l) => _buildArticleItemCard(l, isCourse: false, isDark: isDark)),
      ],
    );
  }

  // ==========================================
  // Article Item Card (WordPress Post Row)
  // ==========================================
  Widget _buildArticleItemCard(Map<String, dynamic> item, {required bool isCourse, required bool isDark}) {
    final title = item['title'] ?? '';
    final category = item['category'] ?? item['subject'] ?? 'عام';
    final image = item['image'] ?? 'assets/images/slide1.png';
    final isNetwork = image.startsWith('http');
    final date = item['date'] ?? 'تاريخ غير محدد';
    final readTime = item['readTime'] ?? item['duration'] ?? '10 دقائق';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 60,
              child: isNetwork
                  ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade800))
                  : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade800)),
            ),
          ),
          const SizedBox(width: 16),

          // Title & Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "• $readTime • $date",
                      style: GoogleFonts.cairo(fontSize: 11, color: isDark ? AppColors.textMuted : AppColors.textMutedLight),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                tooltip: "معاينة المقال",
                onPressed: () => _showArticlePreviewModal(item),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                tooltip: "تعديل",
                onPressed: () => _showArticleDialog(isCourse: isCourse, existingItem: item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                tooltip: "حذف",
                onPressed: () {
                  final id = item['id'];
                  if (id != null) {
                    if (isCourse) {
                      _dataService.deleteCourse(id);
                    } else {
                      _dataService.deleteLesson(id);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: شريط جديدنا
  // ==========================================
  Widget _buildLatestUpdatesSection(bool isDark) {
    final updates = _dataService.latestUpdates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          "شريط جديدنا والتحديثات (${updates.length})",
          "+ إضافة تحديث مخصص",
          () => _showLatestUpdateDialog(),
          isDark,
        ),

        // Info Banner
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF00E5FF), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "ملاحظة ذكية: كافة الكورسات والدروس التي تنشئها في قسمي الكورسات والدروس تظهر تلقائياً في شريط «جديدنا» على الصفحة الرئيسية. يمكنك من هنا إضافة أي إعلانات أو تحديثات إضافية يدوياً.",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (updates.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد تحديثات يدوية مضافة",
            "شريط جديدنا يعتمد تلقائياً على الكورسات والدروس المضافة، ويمكنك إضافة إعلانات خاصة من الزر أعلاه.",
            isDark,
          )
        else
          ...updates.map((u) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u['title'] ?? '',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          "${u['category'] ?? ''} • ${u['badge'] ?? ''}",
                          style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF00E5FF)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    onPressed: () => _showLatestUpdateDialog(existingUpdate: u),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    onPressed: () => _dataService.deleteLatestUpdate(u['id']),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // SECTION 4: تحدي الأسبوع
  // ==========================================
  Widget _buildWeeklyChallengeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _currentSection = 0),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text("الرئيسية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00E5FF),
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "إدارة تحدي الأسبوع البرمجي",
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _saveWeeklyChallenge,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text("حفظ التحدي 💾", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("تفعيل التحدي وظهوره للطلاب على الموقع", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text("في حال التعطيل يختفي قسم التحدي تلقائياً دون أي تشويه أو نصوص وهمية", style: GoogleFonts.cairo(fontSize: 12)),
                value: _challengeActive,
                activeThumbColor: const Color(0xFFFFB300),
                onChanged: (val) => setState(() => _challengeActive = val),
              ),
              const Divider(height: 32),
              _buildField("عنوان التحدي", _challengeTitleCtrl, isDark),
              Row(
                children: [
                  Expanded(child: _buildField("المستوى (سهل / متوسط / متقدم)", _challengeDiffCtrl, isDark)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildField("رقم الأسبوع (مثال: الأسبوع 03)", _challengeWeekCtrl, isDark)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildField("الأيام المتبقية (مثال: 3 أيام متبقية)", _challengeDaysCtrl, isDark)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildField("عدد المشاركين الحالي", _challengeParticipantsCtrl, isDark)),
                ],
              ),
              _buildField("سيناريو ووصف المسألة البرمجية بالتفصيل", _challengeScenarioCtrl, isDark, maxLines: 4),
              Row(
                children: [
                  Expanded(child: _buildField("المدخل المتوقع (Input)", _challengeInputCtrl, isDark, maxLines: 2)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildField("المخرج المطلوب (Output)", _challengeOutputCtrl, isDark, maxLines: 2)),
                ],
              ),
              _buildField("تلميح الحل للطلاب", _challengeHintCtrl, isDark, maxLines: 2),
            ],
          ),
        ),
      ],
    );
  }

  void _saveWeeklyChallenge() {
    _dataService.setWeeklyChallenge({
      'active': _challengeActive,
      'week': _challengeWeekCtrl.text.trim(),
      'title': _challengeTitleCtrl.text.trim(),
      'difficulty': _challengeDiffCtrl.text.trim(),
      'daysLeft': _challengeDaysCtrl.text.trim(),
      'scenario': _challengeScenarioCtrl.text.trim(),
      'input': _challengeInputCtrl.text.trim(),
      'output': _challengeOutputCtrl.text.trim(),
      'hint': _challengeHintCtrl.text.trim(),
      'participants': int.tryParse(_challengeParticipantsCtrl.text.trim()) ?? 0,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم حفظ تحدي الأسبوع بنجاح! 🎉", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  // ==========================================
  // SECTION 5: بنك اختبر نفسك
  // ==========================================
  Widget _buildQuizQuestionsSection(bool isDark) {
    final questions = _dataService.quizQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          "بنك أسئلة اختبر نفسك (${questions.length})",
          "+ إضافة سؤال جديد",
          () => _showQuizQuestionDialog(),
          isDark,
        ),

        if (questions.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد أسئلة مضافة في البنك بعد",
            "أضف أسئلة الاختيار من متعدد مع الإجابة الصحيحة وشرح علمي مفصل يظهر للمتدرب فور إجابته.",
            isDark,
          )
        else
          ...questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            final opts = List<String>.from(q['options'] ?? []);
            final correctIdx = q['correctIndex'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "سؤال #${idx + 1} • ${q['category'] ?? 'عام'}",
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFA855F7)),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () => _showQuizQuestionDialog(existingQuestion: q),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                            onPressed: () => _dataService.deleteQuizQuestion(q['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(q['question'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opts.asMap().entries.map((optEntry) {
                      final isCorrect = optEntry.key == correctIdx;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCorrect ? const Color(0xFF10B981).withValues(alpha: 0.15) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isCorrect ? const Color(0xFF10B981) : Colors.transparent),
                        ),
                        child: Text(
                          "${isCorrect ? '✓ ' : ''}${optEntry.value}",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                            color: isCorrect ? const Color(0xFF10B981) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if ((q['explanation'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text("💡 الشرح: ${q['explanation']}", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // Article Editor Dialog (Courses / Lessons)
  // "عايز الصفحة ده تبقي زي المدونة البلوجر اقدر اعمل إضافة درس او كورس زي المقالات عن طريق إضافة صورة والكتابة او html"
  // ==========================================
  void _showArticleDialog({required bool isCourse, Map<String, dynamic>? existingItem}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingItem != null;

    final titleCtrl = TextEditingController(text: existingItem?['title'] ?? '');
    final categoryCtrl = TextEditingController(text: existingItem?['category'] ?? existingItem?['subject'] ?? 'ذكاء اصطناعي');
    final imageCtrl = TextEditingController(text: existingItem?['image'] ?? 'assets/images/slide1.png');
    final summaryCtrl = TextEditingController(text: existingItem?['summary'] ?? existingItem?['description'] ?? '');
    final contentCtrl = TextEditingController(
      text: existingItem?['content'] ??
          (isCourse
              ? "<h2>مقدمة عن الكورس</h2>\n<p>شرح شامل وتأسيسي لأهم المفاهيم في هذا المسار التعليمي.</p>\n\n<h2>ماذا ستتعلم؟</h2>\n<ul>\n  <li>فهم بنية الخوارزميات وهياكل البيانات</li>\n  <li>تطبيقات عملية بكود نظيف وفق Clean Architecture</li>\n</ul>\n\n<pre><code>// مثال كود عملي\nvoid main() {\n  print('أهلاً بك في مسار التعلم!');\n}\n</code></pre>"
              : "<h2>المقدمة والشرح النظري</h2>\n<p>في هذا الدرس سنتعرف بالتفصيل على كيفية حل هذه المسألة وأثرها البرمجي في الأداء.</p>\n\n<blockquote>تلميح مهم: احرص دائماً على تطبيق مبادئ الكود النظيف وتقليل التعقيد الزمني.</blockquote>\n\n<pre><code>// الكود البرمجي الكامل\nint calculateSum(int a, int b) {\n  return a + b;\n}\n</code></pre>"),
    );
    final readTimeCtrl = TextEditingController(text: existingItem?['readTime'] ?? existingItem?['duration'] ?? '15 دقيقة قراءة');
    final levelCtrl = TextEditingController(text: existingItem?['level'] ?? existingItem?['price'] ?? 'شامل ومجاني');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void insertTag(String prefix, String suffix) {
              final text = contentCtrl.text;
              final selection = contentCtrl.selection;
              final start = selection.start >= 0 ? selection.start : text.length;
              final end = selection.end >= 0 ? selection.end : text.length;
              final selectedText = text.substring(start, end);
              final replacement = "$prefix$selectedText$suffix";
              contentCtrl.text = text.replaceRange(start, end, replacement);
              contentCtrl.selection = TextSelection.collapsed(offset: start + replacement.length);
              setDialogState(() {});
            }

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 900,
                constraints: const BoxConstraints(maxHeight: 780),
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isCourse ? Icons.laptop_chromebook_rounded : Icons.article_rounded,
                                color: const Color(0xFF00E5FF),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEdit
                                  ? "تعديل ${isCourse ? 'الكورس' : 'المقال'}"
                                  : "نشر ${isCourse ? 'كورس جديد' : 'مقال / درس جديد'} (WordPress Editor)",
                              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Scrollable Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title & Category
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildField("عنوان ${isCourse ? 'الكورس' : 'المقال'}", titleCtrl, isDark),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildField("التصنيف (الوسم)", categoryCtrl, isDark),
                                ),
                              ],
                            ),

                            // Cover Image URL & Presets
                            _buildField("رابط صورة الغلاف أو مسارها", imageCtrl, isDark),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text("صور مقترحة بنقرة واحدة: ", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                ...[
                                  'assets/images/slide1.png',
                                  'assets/images/slide2.png',
                                  'assets/images/slide3.png',
                                  'assets/images/slide4.png',
                                  'assets/images/slide5.png',
                                ].map((preset) {
                                  return InkWell(
                                    onTap: () {
                                      imageCtrl.text = preset;
                                      setDialogState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        preset.split('/').last,
                                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF00E5FF)),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Summary / Excerpt
                            _buildField("ملخص المقال / نبذة مختصرة تظهر في الكارت", summaryCtrl, isDark, maxLines: 2),

                            // Read Time / Level
                            Row(
                              children: [
                                Expanded(child: _buildField("وقت القراءة / المدة (مثال: 12 دقيقة)", readTimeCtrl, isDark)),
                                const SizedBox(width: 14),
                                Expanded(child: _buildField("المستوى أو السعر (مثال: شامل ومجاني)", levelCtrl, isDark)),
                              ],
                            ),

                            const SizedBox(height: 10),
                            // Toolbar for Blogger / HTML
                            Text(
                              "محرر المحتوى الكامل (أدوات المقال وكتابة الـ HTML)",
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _tagBtn("H2 عنوان رئيسي", () => insertTag("<h2>", "</h2>\n")),
                                _tagBtn("H3 عنوان فرعي", () => insertTag("<h3>", "</h3>\n")),
                                _tagBtn("P فقرة", () => insertTag("<p>", "</p>\n")),
                                _tagBtn("Code كود برمجي", () => insertTag("<pre><code>", "</code></pre>\n")),
                                _tagBtn("List قائمة نقطية", () => insertTag("<ul>\n  <li>", "</li>\n</ul>\n")),
                                _tagBtn("Quote تنبيه / اقتباس", () => insertTag("<blockquote>", "</blockquote>\n")),
                                _tagBtn("Img صورة داخلية", () => insertTag('<img src="assets/images/slide1.png" alt="وصف" />\n', '')),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Code / HTML Content Area
                            TextField(
                              controller: contentCtrl,
                              maxLines: 12,
                              style: GoogleFonts.firaCode(fontSize: 13, height: 1.6),
                              decoration: InputDecoration(
                                hintText: "اكتب مقالك هنا مع إمكانية استخدام نصوص وفقرات ووسوم HTML وصور وأكواد برمجية...",
                                filled: true,
                                fillColor: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Action Buttons (Preview, Publish)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _showArticlePreviewModal({
                              'title': titleCtrl.text,
                              'category': categoryCtrl.text,
                              'image': imageCtrl.text,
                              'date': 'الآن',
                              'readTime': readTimeCtrl.text,
                              'summary': summaryCtrl.text,
                              'content': contentCtrl.text,
                            });
                          },
                          icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                          label: Text("معاينة حية للمقال 👁️", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00E5FF),
                            side: const BorderSide(color: Color(0xFF00E5FF)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) return;

                            final articleData = {
                              'title': titleCtrl.text.trim(),
                              'category': categoryCtrl.text.trim(),
                              'subject': categoryCtrl.text.trim(),
                              'image': imageCtrl.text.trim(),
                              'summary': summaryCtrl.text.trim(),
                              'description': summaryCtrl.text.trim(),
                              'content': contentCtrl.text.trim(),
                              'readTime': readTimeCtrl.text.trim(),
                              'duration': readTimeCtrl.text.trim(),
                              'level': levelCtrl.text.trim(),
                              'price': levelCtrl.text.trim(),
                              'date': existingItem?['date'] ?? _getCurrentArabicDate(),
                              'author': 'Eslam Atef',
                            };

                            if (isCourse) {
                              if (isEdit) {
                                _dataService.updateCourse(existingItem['id'], articleData..['id'] = existingItem['id']);
                              } else {
                                _dataService.addCourse(articleData);
                              }
                            } else {
                              if (isEdit) {
                                _dataService.updateLesson(existingItem['id'], articleData..['id'] = existingItem['id']);
                              } else {
                                _dataService.addLesson(articleData);
                              }
                            }

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("تم نشر المقال بنجاح في الموقع! 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          icon: const Icon(Icons.publish_rounded, size: 18),
                          label: Text(
                            isEdit ? "حفظ التعديلات 💾" : "نشر المقال الآن 🚀",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tagBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
        ),
      ),
    );
  }

  // ==========================================
  // Live Article Preview Modal
  // ==========================================
  void _showArticlePreviewModal(Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = item['image'] ?? 'assets/images/slide1.png';
    final isNetwork = image.startsWith('http');

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 850,
            constraints: const BoxConstraints(maxHeight: 750),
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("معاينة شكل المقال في المدونة", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cover
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 260,
                            child: isNetwork
                                ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900))
                                : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          item['title'] ?? '',
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),

                        // Meta
                        Text(
                          "بقلم: ${item['author'] ?? 'Eslam Atef'} • ${item['date'] ?? 'اليوم'} • ${item['category'] ?? ''}",
                          style: GoogleFonts.cairo(color: const Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Content
                        ArticleContentRenderer(content: item['content'] ?? item['summary'] ?? '', isDark: isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // Latest Update Dialog
  // ==========================================
  void _showLatestUpdateDialog({Map<String, dynamic>? existingUpdate}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingUpdate != null;

    final titleCtrl = TextEditingController(text: existingUpdate?['title'] ?? '');
    final categoryCtrl = TextEditingController(text: existingUpdate?['category'] ?? 'تحديث جديد');
    final badgeCtrl = TextEditingController(text: existingUpdate?['badge'] ?? 'جديد');
    final durationCtrl = TextEditingController(text: existingUpdate?['duration'] ?? 'الآن');
    final imageCtrl = TextEditingController(text: existingUpdate?['image'] ?? 'assets/images/slide1.png');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(isEdit ? "تعديل التحديث" : "إضافة تحديث جديد لشريط جديدنا", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField("العنوان", titleCtrl, isDark),
                _buildField("التصنيف", categoryCtrl, isDark),
                _buildField("الشارة (Badge)", badgeCtrl, isDark),
                _buildField("المدة أو الوقت", durationCtrl, isDark),
                _buildField("رابط الصورة", imageCtrl, isDark),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final data = {
                  'type': 'custom',
                  'title': titleCtrl.text.trim(),
                  'category': categoryCtrl.text.trim(),
                  'badge': badgeCtrl.text.trim(),
                  'duration': durationCtrl.text.trim(),
                  'image': imageCtrl.text.trim(),
                  'route': '/courses',
                };
                if (isEdit) {
                  _dataService.updateLatestUpdate(existingUpdate['id'], data..['id'] = existingUpdate['id']);
                } else {
                  _dataService.addLatestUpdate(data);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
              child: Text(isEdit ? "تحديث" : "إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // Quiz Question Dialog
  // ==========================================
  void _showQuizQuestionDialog({Map<String, dynamic>? existingQuestion}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingQuestion != null;

    final qCtrl = TextEditingController(text: existingQuestion?['question'] ?? '');
    final catCtrl = TextEditingController(text: existingQuestion?['category'] ?? 'ذكاء اصطناعي');
    final expCtrl = TextEditingController(text: existingQuestion?['explanation'] ?? '');
    final optCtrls = List.generate(
      4,
      (i) => TextEditingController(
        text: (existingQuestion?['options'] != null && (existingQuestion!['options'] as List).length > i)
            ? existingQuestion['options'][i]
            : '',
      ),
    );
    int correctIdx = existingQuestion?['correctIndex'] ?? 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(isEdit ? "تعديل السؤال" : "إضافة سؤال لبنك اختبر نفسك", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField("نص السؤال", qCtrl, isDark, maxLines: 2),
                    _buildField("التصنيف (مثال: خوارزميات)", catCtrl, isDark),
                    const SizedBox(height: 10),
                    Text("الخيارات الأربعة (حدد الإجابة الصحيحة):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    ...List.generate(4, (i) {
                      return Row(
                        children: [
                          // ignore: deprecated_member_use
                          Radio<int>(
                            value: i,
                            // ignore: deprecated_member_use
                            groupValue: correctIdx,
                            activeColor: const Color(0xFF10B981),
                            // ignore: deprecated_member_use
                            onChanged: (val) => setDlgState(() => correctIdx = val ?? 0),
                          ),
                          Expanded(child: _buildField("الخيار ${i + 1}", optCtrls[i], isDark)),
                        ],
                      );
                    }),
                    _buildField("الشرح العلمي الموضح للإجابة", expCtrl, isDark, maxLines: 2),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
                ElevatedButton(
                  onPressed: () {
                    if (qCtrl.text.trim().isEmpty) return;
                    final data = {
                      'question': qCtrl.text.trim(),
                      'category': catCtrl.text.trim(),
                      'explanation': expCtrl.text.trim(),
                      'options': optCtrls.map((c) => c.text.trim()).toList(),
                      'correctIndex': correctIdx,
                    };
                    if (isEdit) {
                      _dataService.updateQuizQuestion(existingQuestion['id'], data..['id'] = existingQuestion['id']);
                    } else {
                      _dataService.addQuizQuestion(data);
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7), foregroundColor: Colors.white),
                  child: Text(isEdit ? "حفظ" : "إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // Helper Widgets
  // ==========================================
  Widget _buildField(String label, TextEditingController ctrl, bool isDark, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.cairo(fontSize: 13.5),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF64748B)),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(subtitle, style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF64748B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  String _getCurrentArabicDate() {
    final now = DateTime.now();
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }
}
