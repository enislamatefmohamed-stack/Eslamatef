// ignore_for_file: deprecated_member_use, unused_element
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/site_data_service.dart';
import '../services/user_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/youtube_embedded_player.dart';
import '../widgets/safe_network_image/safe_network_image.dart';
import '../widgets/blogger_post_editor.dart';
import '../widgets/recording_launcher/recording_launcher.dart';

class _SubTabItem {
  final String title;
  final IconData icon;
  final int count;

  const _SubTabItem(this.title, this.icon, {this.count = 0});

  String get label => title;
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _dataService = SiteDataService.instance;

  // 0: الرئيسية (Dashboard Home)
  // 1: جديدنا (What's New & Ticker)
  // 2: الكورسات (Courses)
  // 3: الدروس (Independent Lessons)
  // 4: اختبر نفسك (Interactive Quizzes)
  // 5: تحدي الأسبوع (Weekly Challenges)
  // 6: جلسات التصوير (Recording Studio)
  // 7: الأعضاء (Members)
  int _selectedNavIndex = 0;
  bool _isSidebarCollapsed = false;

  // Sub-tabs
  int _coursesSubTab = 0; // 0: جميع الكورسات, 1: تصنيفات الكورسات
  int _lessonsSubTab = 0; // 0: جميع الدروس, 1: تصنيفات الدروس, 2: قوائم التشغيل
  int _newsSubTab = 0;    // 0: إعلانات جديدنا المخصصة, 1: شريط المحتوى التلقائي

  // Search & Filter state
  String _coursesSearch = '';
  String _coursesFilter = 'الكل'; // الكل, منشور, مسودة
  String _selectedCourseCategoryFilter = 'الكل';

  String _lessonsSearch = '';
  String _lessonsFilter = 'الكل';
  String _selectedLessonCategoryFilter = 'الكل';

  String _newsSearch = '';

  int _quizSubNav = 0; // 0: محرر كود الاختبار (HTML فقط), 1: نتائج الطلاب
  final _quizHtmlEditorCtrl = TextEditingController();
  final _quizTitleEditorCtrl = TextEditingController(text: 'اختبار تقييم المستوى');
  Map<String, dynamic>? _editingQuiz;

  String _challengesSearch = '';
  String _challengesFilter = 'الكل'; // الكل, نشط, مجدول, منتهٍ, مسودة
  int _challengeSubNav = 0; // 0: التحديات, 1: حلول الطلاب

  String _membersSearch = '';
  int _membersCurrentPage = 0;
  final int _membersPageSize = 20;

  // Managing Course Lectures sub-state
  Map<String, dynamic>? _selectedCourseForLectures;

  // News Editor state
  final _newsTitleCtrl = TextEditingController();
  final _newsSubtitleCtrl = TextEditingController();
  final _newsBadgeCtrl = TextEditingController(text: '✨ جديدنا');
  final _newsRouteCtrl = TextEditingController(text: '/courses');
  final _newsImageCtrl = TextEditingController();

  // Full-page Lesson Workspace
  bool _isCreatingLesson = false;
  Map<String, dynamic>? _editingLesson;
  bool _isLessonHtmlMode = false;
  final _lessonTitleCtrl = TextEditingController();
  final _lessonDescCtrl = TextEditingController();
  final _lessonImgCtrl = TextEditingController();
  final _lessonVideoCtrl = TextEditingController();
  final _lessonContentCtrl = TextEditingController();
  final _lessonHtmlCtrl = TextEditingController();
  String _selectedLessonCategory = '';
  String _selectedLessonPlaylistId = '';
  String _selectedLessonStatus = 'منشور';

  // Full-page Playlist Workspace
  bool _isCreatingPlaylist = false;
  Map<String, dynamic>? _editingPlaylist;
  final _playlistTitleCtrl = TextEditingController();
  final _playlistDescCtrl = TextEditingController();
  String _selectedPlaylistStatus = 'منشور';

  // Full-page Course Workspace
  bool _isCreatingCourse = false;
  Map<String, dynamic>? _editingCourse;
  bool _isCourseHtmlMode = false;
  bool _isCoursePaid = false;
  final _coursePriceCtrl = TextEditingController();
  final _courseTitleCtrl = TextEditingController();
  final _courseDescCtrl = TextEditingController();
  final _courseImgCtrl = TextEditingController();
  final _coursePdfCtrl = TextEditingController();
  final _courseCatCtrl = TextEditingController();
  final _courseHtmlCtrl = TextEditingController();
  String _selectedCourseCategory = '';
  String _selectedCourseLevel = 'جميع المستويات';
  String _selectedCourseStatus = 'منشور';

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    _dataService.init();
    _initQuizTemplateIfEmpty();
  }

  void _initQuizTemplateIfEmpty() {
    if (_quizHtmlEditorCtrl.text.isEmpty) {
      _quizHtmlEditorCtrl.text = '''<!-- قالب اختبار تفاعلي HTML -->
<div class="interactive-quiz" style="background:#ffffff; border-radius:16px; padding:24px; border:1px solid #e2e8f0; font-family:'Cairo', sans-serif;">
  <h2 style="color:#0f172a; font-size:22px; margin-bottom:12px; font-weight:bold;">اختبار تجريبي في أساسيات الذكاء الاصطناعي 🧠</h2>
  <p style="color:#64748b; font-size:14px; margin-bottom:20px;">أجب عن الأسئلة بدقة لتحديد مستواك العلمي وفهمك للبرمجة.</p>

  <div style="background:#f8fafc; border-radius:12px; padding:16px; margin-bottom:16px; border:1px solid #e2e8f0;">
    <h3 style="font-size:16px; color:#1e293b; margin-bottom:10px;">السؤال 1: ما هو المفهوم الأساسي للتعلم الآلي (Machine Learning)؟</h3>
    <label style="display:block; margin:8px 0; color:#334155; cursor:pointer;"><input type="radio" name="q1"> تدريب الحاسوب على التعلم من البيانات دون برمجة صريحة لكل خطوة</label>
    <label style="display:block; margin:8px 0; color:#334155; cursor:pointer;"><input type="radio" name="q1"> كتابة كود حسابي بسيط فقط</label>
    <label style="display:block; margin:8px 0; color:#334155; cursor:pointer;"><input type="radio" name="q1"> رسم واجهات المستخدم</label>
  </div>
</div>''';
    }
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _newsTitleCtrl.dispose();
    _newsSubtitleCtrl.dispose();
    _newsBadgeCtrl.dispose();
    _newsRouteCtrl.dispose();
    _newsImageCtrl.dispose();
    _lessonTitleCtrl.dispose();
    _lessonDescCtrl.dispose();
    _lessonImgCtrl.dispose();
    _lessonVideoCtrl.dispose();
    _lessonContentCtrl.dispose();
    _lessonHtmlCtrl.dispose();
    _playlistTitleCtrl.dispose();
    _playlistDescCtrl.dispose();
    _courseTitleCtrl.dispose();
    _courseDescCtrl.dispose();
    _coursePriceCtrl.dispose();
    _courseImgCtrl.dispose();
    _coursePdfCtrl.dispose();
    _courseCatCtrl.dispose();
    _courseHtmlCtrl.dispose();
    _quizHtmlEditorCtrl.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openWebsiteExternal() async {
    final uri = Uri.parse("https://eslamatef-sepia.vercel.app/");
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
    } catch (e) {
      _showSnackBar("تعذر فتح الموقع في علامة تبويب جديدة", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF), // Pure white main background as required
        drawer: isMobile ? _buildSidebar(isDrawer: true) : null,
        body: Row(
          children: [
            // Right Sidebar (Fixed RTL)
            if (!isMobile) _buildSidebar(isDrawer: false),

            // Left Workspace (Main Content - Pure White "#FFFFFF")
            Expanded(
              child: Container(
                color: const Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    _buildTopHeader(isMobile),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                        child: _buildCurrentSection(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SIDEBAR (القائمة الجانبية اليمنى)
  // ==========================================
  Widget _buildSidebar({required bool isDrawer}) {
    final width = isDrawer
        ? 280.0
        : (_isSidebarCollapsed ? 80.0 : 260.0);

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.code_rounded, color: Colors.white, size: 24),
                  ),
                ),
                if (!_isSidebarCollapsed || isDrawer) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Eslam Atef",
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Code & AI — لوحة الإدارة",
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Nav Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildNavItem(0, "الرئيسية", Icons.home_rounded, isDrawer),
                _buildNavItem(1, "الكورسات", Icons.menu_book_rounded, isDrawer, count: _dataService.courses.length),
                _buildNavItem(2, "الدروس", Icons.school_rounded, isDrawer, count: _dataService.lessons.length),
                _buildNavItem(3, "اختبر نفسك", Icons.psychology_rounded, isDrawer, count: _dataService.interactiveQuizzes.length),
                _buildNavItem(4, "تحدي الأسبوع", Icons.emoji_events_rounded, isDrawer, count: _dataService.weeklyChallenges.length),
                _buildNavItem(5, "جلسات التصوير", Icons.videocam_rounded, isDrawer, count: _dataService.recordingLessons.length),
                _buildNavItem(6, "الأعضاء", Icons.group_rounded, isDrawer, count: _dataService.members.length),
                const Divider(color: Color(0xFFE2E8F0), height: 24),
                _buildWebsiteLinkItem(isDrawer),
              ],
            ),
          ),

          // Collapse / Expand Button (for desktop)
          if (!isDrawer)
            InkWell(
              onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Icon(
                      _isSidebarCollapsed ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFF64748B),
                      size: 16,
                    ),
                    if (!_isSidebarCollapsed) ...[
                      const SizedBox(width: 12),
                      Text(
                        "تصغير القائمة",
                        style: GoogleFonts.cairo(color: const Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, bool isDrawer, {int? count}) {
    final isSelected = _selectedNavIndex == index && _selectedCourseForLectures == null;
    final isCollapsed = _isSidebarCollapsed && !isDrawer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
            _selectedCourseForLectures = null;
          });
          if (isDrawer) Navigator.pop(context);
        },
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          size: 20,
        ),
        title: isCollapsed
            ? null
            : Text(
                title,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
        trailing: (isCollapsed || count == null || count == 0)
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: GoogleFonts.cairo(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        contentPadding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16, vertical: 2),
        minLeadingWidth: 24,
      ),
    );
  }

  Widget _buildWebsiteLinkItem(bool isDrawer) {
    final isCollapsed = _isSidebarCollapsed && !isDrawer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.25)),
      ),
      child: ListTile(
        onTap: _openWebsiteExternal,
        dense: true,
        leading: const Icon(Icons.open_in_new_rounded, color: Color(0xFF8B5CF6), size: 18),
        title: isCollapsed
            ? null
            : Text(
                "زيارة الموقع 🌐",
                style: GoogleFonts.cairo(
                  color: const Color(0xFF8B5CF6),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
        contentPadding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16, vertical: 2),
        minLeadingWidth: 24,
      ),
    );
  }

  // ==========================================
  // TOP HEADER (شريط العنوان والإجراءات)
  // ==========================================
  Widget _buildTopHeader(bool isMobile) {
    final titles = [
      "لوحة التحكم الرئيسية",
      "إدارة الكورسات والمسارات",
      "إدارة الدروس المستقلة",
      "إدارة اختبارات اختبر نفسك",
      "إدارة تحدي الأسبوع والحلول",
      "إدارة جلسات التصوير",
      "إدارة الأعضاء والطلاب",
    ];

    final currentTitle = _selectedCourseForLectures != null
        ? "محاضرات: ${_selectedCourseForLectures!['title'] ?? 'الكورس'}"
        : titles[_selectedNavIndex];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 28,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (_selectedCourseForLectures != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0284C7)),
              tooltip: "العودة للكورسات",
              onPressed: () => setState(() => _selectedCourseForLectures = null),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  isMobile ? "لوحة تحكم Eslam Atef" : "لوحة تحكم Eslam Atef | Code & AI — بيئة إدارة المحتوى المباشرة",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMobile)
            IconButton(
              onPressed: _openWebsiteExternal,
              tooltip: "الموقع الخارجي",
              icon: const Icon(Icons.language_rounded, color: Color(0xFF0284C7), size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF0F9FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _openWebsiteExternal,
              icon: const Icon(Icons.language_rounded, size: 16, color: Color(0xFF0284C7)),
              label: Text("الموقع الخارجي", style: GoogleFonts.cairo(fontSize: 13, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBAE6FD)),
                backgroundColor: const Color(0xFFF0F9FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION SWITCHER
  // ==========================================
  Widget _buildCurrentSection() {
    if (_isCreatingLesson || _editingLesson != null) {
      return _buildLessonFullPageEditor();
    }
    if (_isCreatingPlaylist || _editingPlaylist != null) {
      return _buildPlaylistFullPageEditor();
    }
    if (_isCreatingCourse || _editingCourse != null) {
      return _buildCourseFullPageEditor();
    }
    if (_selectedCourseForLectures != null) {
      return _buildCourseLecturesView(_selectedCourseForLectures!);
    }

    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeSection();
      case 1:
        return _buildCoursesSection();
      case 2:
        return _buildLessonsSection();
      case 3:
        return _buildQuizzesSection();
      case 4:
        return _buildChallengesSection();
      case 5:
        return _buildRecordingStudioSection();
      case 6:
        return _buildMembersSection();
      default:
        return _buildHomeSection();
    }
  }

  // =========================================================================
  // 1. الرئيسية (DASHBOARD HOME - إحصائيات فقط بدون أي أزرار ومعلومات حقيقية)
  // =========================================================================
  Widget _buildHomeSection() {
    final coursesCount = _dataService.courses.length;
    int totalLectures = 0;
    for (var c in _dataService.courses) {
      totalLectures += (c['lessons'] as List?)?.length ?? 0;
    }
    final lessonsCount = _dataService.lessons.length + totalLectures;
    final questionsCount = _dataService.quizQuestions.length +
        _dataService.interactiveQuizzes.fold(0, (acc, q) => acc + ((q['questionsCount'] as int?) ?? 10));
    final quizzesCount = _dataService.interactiveQuizzes.length;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: UserService.instance.streamAllStudents(),
      builder: (context, snapshot) {
        final realDocs = snapshot.data?.docs ?? [];
        final realMembersCount = realDocs.isNotEmpty ? realDocs.length : _dataService.members.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real Summary Cards (5 Stat Cards: أعضاء، كورسات، دروس، أسئلة، اختبارات) — ZERO BUTTONS
            LayoutBuilder(
              builder: (ctx, constraints) {
                final cardWidth = constraints.maxWidth > 1100
                    ? (constraints.maxWidth - 64) / 5
                    : (constraints.maxWidth > 700 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth);

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard("عدد الأعضاء", "$realMembersCount", Icons.people_alt_rounded, const Color(0xFF0284C7), cardWidth),
                    _buildStatCard("عدد الكورسات", "$coursesCount", Icons.menu_book_rounded, const Color(0xFF8B5CF6), cardWidth),
                    _buildStatCard("عدد الدروس", "$lessonsCount", Icons.school_rounded, const Color(0xFF0284C7), cardWidth),
                    _buildStatCard("عدد الأسئلة", "$questionsCount", Icons.help_outline_rounded, const Color(0xFF8B5CF6), cardWidth),
                    _buildStatCard("عدد الاختبارات", "$quizzesCount", Icons.psychology_rounded, const Color(0xFF0284C7), cardWidth),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Two Columns: Recent Members & Recent Content (Informational View - ZERO buttons)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Registered Members
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.people_alt_rounded, color: Color(0xFF0284C7), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "أحدث الأعضاء والطلاب المسجلين",
                              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        if (realDocs.isEmpty && _dataService.members.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text("لا يوجد أعضاء مسجلون حتى الآن", style: GoogleFonts.cairo(color: Colors.grey)),
                            ),
                          )
                        else if (realDocs.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: realDocs.take(4).length,
                            separatorBuilder: (ctx, i) => const Divider(color: Color(0xFFF8FAFC), height: 1),
                            itemBuilder: (ctx, i) {
                              final data = realDocs[i].data();
                              final name = data['name'] ?? data['displayName'] ?? 'طالب مسجل';
                              final email = data['email'] ?? '—';
                              final role = data['role'] == 'admin' ? 'أدمن 🛡️' : 'طالب 👨‍🎓';

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0284C7).withOpacity(0.1),
                                  child: Text(
                                    name.isNotEmpty ? name[0] : 'ع',
                                    style: GoogleFonts.cairo(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text("$email • $role", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                trailing: Text("نشط", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              );
                            },
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _dataService.members.take(4).length,
                            separatorBuilder: (ctx, i) => const Divider(color: Color(0xFFF8FAFC), height: 1),
                            itemBuilder: (ctx, i) {
                              final mem = _dataService.members[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0284C7).withOpacity(0.1),
                                  child: Text(
                                    (mem['name'] ?? 'م')[0],
                                    style: GoogleFonts.cairo(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(mem['name'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text("${mem['email'] ?? ''} • ${mem['country'] ?? 'مصر'}", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                trailing: Text(mem['registeredDate'] ?? '', style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8))),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(width: 24),

            // Recent Added Content
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "أحدث المحتويات التعليمية المضافة",
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 24),
                    if (_dataService.courses.isEmpty && _dataService.lessons.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text("لم يتم نشر محتويات بعد", style: GoogleFonts.cairo(color: Colors.grey)),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ..._dataService.courses.take(2).map((c) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.folder_open_rounded, color: Color(0xFF0284C7), size: 20),
                                ),
                                title: Text(c['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text("كورس • ${(c['lessons'] as List?)?.length ?? 0} محاضرات", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (c['status'] == 'مسودة') ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c['status'] ?? 'منشور',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: (c['status'] == 'مسودة') ? const Color(0xFF64748B) : const Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              )),
                          ..._dataService.lessons.take(2).map((l) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.play_circle_outline_rounded, color: Color(0xFF8B5CF6), size: 20),
                                ),
                                title: Text(l['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text("درس • ${l['playlistTitle'] ?? l['category'] ?? 'عام'}", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                  child: Text("منشور", style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A))),
                                ),
                              )),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
      },
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0284C7))),
    );
  }

  Widget _buildEditorField(String label, TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.cairo(fontSize: 13),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  // =========================================================================
  // SUB-TAB NAVIGATION HELPER
  // =========================================================================
  Widget _buildSubTabHeader({
    required List<_SubTabItem> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    Widget? trailing,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isMobile ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(tabs.length, (idx) {
                      final tab = tabs[idx];
                      final isSelected = selectedIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: () => onTabSelected(idx),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(tab.icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(
                                  tab.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                                if (tab.count > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withOpacity(0.25) : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${tab.count}",
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 10),
                  trailing,
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (idx) {
                        final tab = tabs[idx];
                        final isSelected = selectedIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: InkWell(
                            onTap: () => onTabSelected(idx),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(tab.icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Text(
                                    tab.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF475569),
                                    ),
                                  ),
                                  if (tab.count > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withOpacity(0.25) : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${tab.count}",
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
    );
  }

  // =========================================================================
  // 1. جديدنا وشريط الأخبار التفاعلي ✨
  // =========================================================================
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubTabHeader(
          tabs: [
            _SubTabItem("إعلانات جديدنا المخصصة", Icons.campaign_rounded, count: _dataService.latestUpdates.length),
            _SubTabItem("شريط المحتوى التلقائي (Live Ticker)", Icons.stream_rounded),
          ],
          selectedIndex: _newsSubTab,
          onTabSelected: (idx) => setState(() => _newsSubTab = idx),
          trailing: _newsSubTab == 0
              ? ElevatedButton.icon(
                  onPressed: () => _showNewsDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text("+ إضافة إعلان جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 20),
        if (_newsSubTab == 0) _buildCustomNewsListTab() else _buildLiveTickerStreamTab(),
      ],
    );
  }

  Widget _buildCustomNewsListTab() {
    final updates = _dataService.latestUpdates.where((u) {
      final q = _newsSearch.toLowerCase();
      final title = (u['title'] ?? '').toString().toLowerCase();
      final subtitle = (u['subtitle'] ?? '').toString().toLowerCase();
      return title.contains(q) || subtitle.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (val) => setState(() => _newsSearch = val),
          decoration: InputDecoration(
            hintText: "بحث في إعلانات جديدنا...",
            hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 20),
        if (updates.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.campaign_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text("لا توجد إعلانات مخصصة في جدول جديدنا", style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showNewsDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text("إضافة أول إعلان الآن", style: GoogleFonts.cairo()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
              final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: updates.map((item) {
                  final img = (item['image'] ?? item['imageUrl'] ?? '').toString();
                  return Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (img.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Image.network(
                              img,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                height: 130,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['badge'] ?? '✨ جديدنا',
                                      style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item['route'] ?? '/courses',
                                    style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['title'] ?? 'بدون عنوان',
                                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'] ?? item['description'] ?? '',
                                style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 20, color: Color(0xFFF1F5F9)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                                    tooltip: "تعديل",
                                    onPressed: () => _showNewsDialog(existing: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                    tooltip: "حذف",
                                    onPressed: () => _confirmDelete("إعلان: ${item['title']}", () async {
                                      await _dataService.deleteLatestUpdate(item['id']);
                                      _showSnackBar("تم حذف الإعلان بنجاح");
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLiveTickerStreamTab() {
    final courses = _dataService.courses;
    int lecturesCount = 0;
    for (final c in courses) {
      lecturesCount += (c['lessons'] as List?)?.length ?? 0;
    }
    final lessons = _dataService.lessons;
    final updates = _dataService.latestUpdates;
    final totalTickerItems = courses.length + lecturesCount + lessons.length + updates.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Explanation Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF16A34A), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("شريط جديدنا التلقائي (Live Feed)", style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF15803D))),
                    Text(
                      "يقوم شريط 'جديدنا على المنصة' في أعلى الصفحة الرئيسية بتجميع كافة الكورسات والدروس المضافة فوراً وبشكل تلقائي، بالإضافة لأي إعلان مخصص تضيفه هنا.",
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Live Feed Statistics
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard("إجمالي عناصر الشريط", "$totalTickerItems", Icons.view_carousel_rounded, const Color(0xFF0284C7), 200),
            _buildStatCard("الكورسات النشطة", "${courses.length}", Icons.menu_book_rounded, const Color(0xFF8B5CF6), 200),
            _buildStatCard("المحاضرات بالكورسات", "$lecturesCount", Icons.video_library_rounded, const Color(0xFF0284C7), 200),
            _buildStatCard("الدروس المستقلة", "${lessons.length}", Icons.school_rounded, const Color(0xFF10B981), 200),
            _buildStatCard("إعلانات مخصصة", "${updates.length}", Icons.campaign_rounded, const Color(0xFFF59E0B), 200),
          ],
        ),

        const SizedBox(height: 28),
        Text("معاينة حية للعناصر المتدفقة في شريط 'جديدنا' بالصفحة الرئيسية:", style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...updates.map((u) => _buildTickerPreviewTile(
                title: u['title'] ?? '',
                subtitle: u['subtitle'] ?? 'إعلان مخصص',
                badge: u['badge'] ?? '✨ جديدنا',
                badgeColor: const Color(0xFF0284C7),
                route: u['route'] ?? '/courses',
                icon: Icons.campaign_rounded,
              )),
              ...courses.map((c) => _buildTickerPreviewTile(
                title: c['title'] ?? '',
                subtitle: c['category'] ?? 'كورس جديد',
                badge: c['level'] ?? 'كورس متميز',
                badgeColor: const Color(0xFF8B5CF6),
                route: '/courses',
                icon: Icons.menu_book_rounded,
              )),
              ...lessons.map((l) => _buildTickerPreviewTile(
                title: l['title'] ?? '',
                subtitle: (l['category'] ?? l['subject'] ?? 'درس مستقل').toString(),
                badge: 'درس جديد',
                badgeColor: const Color(0xFF10B981),
                route: '/lessons',
                icon: Icons.school_rounded,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTickerPreviewTile({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required String route,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: badgeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Text(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor)),
          ),
          const SizedBox(width: 12),
          Text(route, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  void _showNewsDialog({Map<String, dynamic>? existing}) {
    _newsTitleCtrl.text = existing?['title'] ?? '';
    _newsSubtitleCtrl.text = existing?['subtitle'] ?? '';
    _newsBadgeCtrl.text = existing?['badge'] ?? '✨ جديدنا';
    _newsRouteCtrl.text = existing?['route'] ?? '/courses';
    _newsImageCtrl.text = existing?['image'] ?? existing?['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? "إضافة إعلان جديد في جديدنا" : "تعديل إعلان جديدنا", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditorField("عنوان الإعلان / المحتوى *", _newsTitleCtrl, "مثال: كورس Flutter الجديد متاح الآن"),
                const SizedBox(height: 14),
                _buildEditorField("الوصف المختصر *", _newsSubtitleCtrl, "مثال: تعلم بناء تطبيقات عصرية من الصفر حتى الاحتراف", maxLines: 2),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildEditorField("شارة التمييز (Badge)", _newsBadgeCtrl, "✨ جديدنا")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildEditorField("المسار المستهدف", _newsRouteCtrl, "/courses أو /lessons")),
                  ],
                ),
                const SizedBox(height: 14),
                _buildEditorField("رابط صورة الغلاف (URL)", _newsImageCtrl, "https://..."),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء", style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newsTitleCtrl.text.trim().isEmpty) {
                _showSnackBar("يرجى إدخال عنوان الإعلان", isError: true);
                return;
              }
              final data = {
                'title': _newsTitleCtrl.text.trim(),
                'subtitle': _newsSubtitleCtrl.text.trim(),
                'badge': _newsBadgeCtrl.text.trim().isNotEmpty ? _newsBadgeCtrl.text.trim() : '✨ جديدنا',
                'route': _newsRouteCtrl.text.trim().isNotEmpty ? _newsRouteCtrl.text.trim() : '/courses',
                'image': _newsImageCtrl.text.trim(),
                'imageUrl': _newsImageCtrl.text.trim(),
              };
              if (existing == null) {
                await _dataService.addLatestUpdate(data);
              } else {
                await _dataService.updateLatestUpdate(existing['id'], data);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnackBar("تم حفظ الإعلان بنجاح");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            child: Text("حفظ الإعلان", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // COURSE CATEGORIES MANAGEMENT (تصنيفات الكورسات المستقلة)
  // =========================================================================
  void _showAddCourseCategoryDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("إضافة تصنيف كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: _inputDecoration("اسم تصنيف الكورس، مثال: الذكاء الاصطناعي"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isEmpty) return;
              await _dataService.addCourseCategory(val);
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnackBar("تمت إضافة تصنيف الكورس بنجاح");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            child: Text("إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditCourseCategoryDialog(String oldCategory) {
    final ctrl = TextEditingController(text: oldCategory);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("تعديل تصنيف الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: _inputDecoration("اسم التصنيف الجديد"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isEmpty || val == oldCategory) return;
              await _dataService.updateCourseCategory(oldCategory, val);
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnackBar("تم تعديل تصنيف الكورس وتحديث الكورسات المرتبطة");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            child: Text("حفظ التعديل", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCategoriesTab() {
    final cats = _dataService.courseCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("إدارة تصنيفات الكورسات (${cats.length})", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ElevatedButton.icon(
              onPressed: _showAddCourseCategoryDialog,
              icon: const Icon(Icons.add, size: 16),
              label: Text("+ إضافة تصنيف كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (cats.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Center(child: Text("لا توجد تصنيفات كورسات", style: GoogleFonts.cairo(color: Colors.grey))),
          )
        else
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cats.map((cat) {
                  final count = _dataService.courses.where((c) => (c['category'] ?? '') == cat).length;
                  return Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.menu_book_rounded, color: Color(0xFF0284C7), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text("$count كورس مرتبط", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                          tooltip: "تعديل",
                          onPressed: () => _showEditCourseCategoryDialog(cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          tooltip: "حذف",
                          onPressed: () => _confirmDelete("تصنيف الكورس: $cat", () async {
                            await _dataService.deleteCourseCategory(cat);
                            _showSnackBar("تم حذف تصنيف الكورس");
                          }),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  // =========================================================================
  // LESSON CATEGORIES MANAGEMENT (تصنيفات الدروس المستقلة تماماً)
  // =========================================================================
  void _showAddLessonCategoryDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("إضافة تصنيف درس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: _inputDecoration("اسم تصنيف الدرس، مثال: قواعد البيانات"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isEmpty) return;
              await _dataService.addLessonCategory(val);
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnackBar("تمت إضافة تصنيف الدرس بنجاح");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            child: Text("إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditLessonCategoryDialog(String oldCategory) {
    final ctrl = TextEditingController(text: oldCategory);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("تعديل تصنيف الدرس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: _inputDecoration("اسم التصنيف الجديد"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isEmpty || val == oldCategory) return;
              await _dataService.updateLessonCategory(oldCategory, val);
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnackBar("تم تعديل تصنيف الدرس وتحديث الدروس المرتبطة");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            child: Text("حفظ التعديل", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCategoriesTab() {
    final cats = _dataService.lessonCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("إدارة تصنيفات الدروس المستقلة (${cats.length})", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ElevatedButton.icon(
              onPressed: _showAddLessonCategoryDialog,
              icon: const Icon(Icons.add, size: 16),
              label: Text("+ إضافة تصنيف درس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (cats.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Center(child: Text("لا توجد تصنيفات دروس", style: GoogleFonts.cairo(color: Colors.grey))),
          )
        else
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cats.map((cat) {
                  final count = _dataService.lessons.where((l) => (l['category'] ?? '') == cat || (l['subject'] ?? '') == cat).length;
                  return Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text("$count درس مرتبط", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                          tooltip: "تعديل",
                          onPressed: () => _showEditLessonCategoryDialog(cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          tooltip: "حذف",
                          onPressed: () => _confirmDelete("تصنيف الدرس: $cat", () async {
                            await _dataService.deleteLessonCategory(cat);
                            _showSnackBar("تم حذف تصنيف الدرس");
                          }),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  // --- Course Workspace Methods ---
  void _openCreateCourseView({Map<String, dynamic>? existing}) {
    _editingCourse = existing;
    _isCreatingCourse = true;
    _isCourseHtmlMode = (existing?['editorType'] ?? 'visual') == 'html';
    _isCoursePaid = existing?['isPaid'] == true;
    _coursePriceCtrl.text = (existing != null && existing['price'] != null && existing['price'].toString() != '0') ? existing['price'].toString() : '';
    _courseTitleCtrl.text = existing?['title'] ?? '';
    _courseDescCtrl.text = existing?['description'] ?? '';
    _courseImgCtrl.text = existing?['image'] ?? existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600';
    _coursePdfCtrl.text = existing?['pdfUrl'] ?? existing?['pdfLink'] ?? '';
    final cats = _dataService.courseCategories;
    _selectedCourseCategory = existing?['category'] ?? (cats.isNotEmpty ? cats.first : 'مسارات البرمجة');
    _courseCatCtrl.text = _selectedCourseCategory;
    _courseHtmlCtrl.text = existing?['htmlCode'] ?? '';
    _selectedCourseLevel = existing?['level'] ?? 'جميع المستويات';
    _selectedCourseStatus = existing?['status'] ?? 'منشور';
    setState(() {});
  }

  Widget _buildCourseFullPageEditor() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0284C7)),
                  tooltip: "العودة إلى قائمة الكورسات",
                  onPressed: () => setState(() {
                    _isCreatingCourse = false;
                    _editingCourse = null;
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _editingCourse == null ? "إنشاء كورس تعليمي جديد" : "تعديل الكورس",
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _isCourseHtmlMode = false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: !_isCourseHtmlMode ? const Color(0xFF0284C7) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            "📝 عادي",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: !_isCourseHtmlMode ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _isCourseHtmlMode = true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isCourseHtmlMode ? const Color(0xFF8B5CF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            "💻 HTML",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isCourseHtmlMode ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveCourseFromEditor,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text("حفظ الكورس 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0284C7)),
                  tooltip: "العودة إلى قائمة الكورسات",
                  onPressed: () => setState(() {
                    _isCreatingCourse = false;
                    _editingCourse = null;
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingCourse == null ? "إنشاء كورس تعليمي جديد" : "تعديل الكورس",
                        style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      Text(
                        _isCourseHtmlMode ? "وضع محرر HTML التفاعلي المباشر للكورس" : "وضع الإدخال العادي للكورس",
                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                // Mode switcher
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _isCourseHtmlMode = false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isCourseHtmlMode ? const Color(0xFF0284C7) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            "📝 إدخال عادي",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !_isCourseHtmlMode ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _isCourseHtmlMode = true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isCourseHtmlMode ? const Color(0xFF8B5CF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            "💻 محرر HTML",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isCourseHtmlMode ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: _saveCourseFromEditor,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text("حفظ الكورس 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 36, color: Color(0xFFE2E8F0)),

          // Standard Details - Always preserved
          _buildEditorField("عنوان الكورس *", _courseTitleCtrl, "مثال: مسار الذكاء الاصطناعي وبايثون المتقدم"),
          const SizedBox(height: 16),
          _buildEditorField("وصف الكورس *", _courseDescCtrl, "اكتب وصفاً مفصلاً ومحفزاً للطلاب...", maxLines: 3),
          const SizedBox(height: 16),
          if (isMobile) ...[
            _buildEditorField("رابط صورة الغلاف (URL) *", _courseImgCtrl, "https://..."),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("تصنيف الكورس * (مستقل)", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _showAddCourseCategoryDialog,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      child: Text("+ تصنيف جديد", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _dataService.courseCategories.contains(_selectedCourseCategory)
                      ? _selectedCourseCategory
                      : (_dataService.courseCategories.isNotEmpty ? _dataService.courseCategories.first : null),
                  decoration: _inputDecoration("اختر تصنيف الكورس"),
                  items: _dataService.courseCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: GoogleFonts.cairo(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() {
                    _selectedCourseCategory = v ?? '';
                    _courseCatCtrl.text = _selectedCourseCategory;
                  }),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildEditorField("رابط صورة الغلاف (URL) *", _courseImgCtrl, "https://...")),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("تصنيف الكورس * (مستقل)", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: _showAddCourseCategoryDialog,
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                            child: Text("+ تصنيف جديد", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _dataService.courseCategories.contains(_selectedCourseCategory)
                            ? _selectedCourseCategory
                            : (_dataService.courseCategories.isNotEmpty ? _dataService.courseCategories.first : null),
                        decoration: _inputDecoration("اختر تصنيف الكورس"),
                        items: _dataService.courseCategories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat, style: GoogleFonts.cairo(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedCourseCategory = v ?? '';
                          _courseCatCtrl.text = _selectedCourseCategory;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("مستوى الكورس", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCourseLevel,
                  decoration: _inputDecoration("اختر المستوى"),
                  items: const [
                    DropdownMenuItem(value: 'جميع المستويات', child: Text("جميع المستويات")),
                    DropdownMenuItem(value: 'مبتدئ', child: Text("مبتدئ")),
                    DropdownMenuItem(value: 'متوسط', child: Text("متوسط")),
                    DropdownMenuItem(value: 'متقدم', child: Text("متقدم")),
                  ],
                  onChanged: (v) => setState(() => _selectedCourseLevel = v ?? 'جميع المستويات'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("حالة النشر", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCourseStatus,
                  decoration: _inputDecoration("اختر الحالة"),
                  items: const [
                    DropdownMenuItem(value: 'منشور', child: Text("منشور (متاح للجميع)")),
                    DropdownMenuItem(value: 'مسودة', child: Text("مسودة (غير ظاهر)")),
                  ],
                  onChanged: (v) => setState(() => _selectedCourseStatus = v ?? 'منشور'),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("مستوى الكورس", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCourseLevel,
                        decoration: _inputDecoration("اختر المستوى"),
                        items: const [
                          DropdownMenuItem(value: 'جميع المستويات', child: Text("جميع المستويات")),
                          DropdownMenuItem(value: 'مبتدئ', child: Text("مبتدئ")),
                          DropdownMenuItem(value: 'متوسط', child: Text("متوسط")),
                          DropdownMenuItem(value: 'متقدم', child: Text("متقدم")),
                        ],
                        onChanged: (v) => setState(() => _selectedCourseLevel = v ?? 'جميع المستويات'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("حالة النشر", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCourseStatus,
                        decoration: _inputDecoration("اختر الحالة"),
                        items: const [
                          DropdownMenuItem(value: 'منشور', child: Text("منشور (متاح للجميع)")),
                          DropdownMenuItem(value: 'مسودة', child: Text("مسودة (غير ظاهر)")),
                        ],
                        onChanged: (v) => setState(() => _selectedCourseStatus = v ?? 'منشور'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Course Pricing & Access
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isCoursePaid ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isCoursePaid ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isCoursePaid ? "🔒 كورس مدفوع (يتطلب شراء واشتراك)" : "🟢 كورس مجاني (متاح للجميع بالتسجيل)",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _isCoursePaid ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: _isCoursePaid,
                      activeColor: const Color(0xFFDC2626),
                      onChanged: (v) => setState(() => _isCoursePaid = v),
                    ),
                  ],
                ),
                if (_isCoursePaid)
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: _coursePriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("سعر الكورس (ج.م EGP) * مثال: 300"),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Course PDF Booklet / Material (ملزمة أو ملف الكورس PDF)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "ملزمة أو ملف الكورس PDF (اختياري)",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF991B1B)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text("غير إجباري", style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "ضع رابط ملف الملزمة (مثل رابط Google Drive أو رابط مباشر لملف PDF). سيتمكن الطلاب من تصفحه وقراءته مباشرة داخل الموقع.",
                  style: GoogleFonts.cairo(fontSize: 11.5, color: const Color(0xFFB91C1C)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _coursePdfCtrl,
                  decoration: _inputDecoration(
                    "مثال: https://drive.google.com/file/d/1KVh0bxk0ozZSuC4QCggyDsHkSK3WHmNt/view",
                  ).copyWith(
                    prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFFEF4444), size: 20),
                  ),
                ),
              ],
            ),
          ),

          if (_isCourseHtmlMode) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, color: Color(0xFF8B5CF6), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("محرر HTML المباشر لمحتوى الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                        Text("يمكنك هنا كتابة صفحات ويب وأقسام تفاعلية كاملة مع الحفاظ على بطاقة الكورس وعنوانه وصورته سليمة.", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF7C3AED))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("كود HTML للكورس *", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _courseHtmlCtrl,
                maxLines: 15,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF38BDF8)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "<div class=\"course-container\">...</div>",
                  hintStyle: TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("معاينة كود HTML:", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _courseHtmlCtrl.text.trim().isEmpty
                  ? Center(child: Text("أدخل كود HTML لمشاهدة المعاينة الفورية", style: GoogleFonts.cairo(color: Colors.grey)))
                  : ArticleContentRenderer(content: _courseHtmlCtrl.text, isDark: false),
            ),
          ],
        ],
      ),
    );
  }

  void _saveCourseFromEditor() async {
    final title = _courseTitleCtrl.text.trim();
    if (title.isEmpty) {
      _showSnackBar("يرجى إدخال عنوان الكورس", isError: true);
      return;
    }
    final cats = _dataService.courseCategories;
    final cat = _selectedCourseCategory.isNotEmpty
        ? _selectedCourseCategory
        : (cats.isNotEmpty ? cats.first : 'مسارات البرمجة');

    final img = _courseImgCtrl.text.trim().isNotEmpty
        ? _courseImgCtrl.text.trim()
        : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600';

    final courseData = {
      'title': title,
      'description': _courseDescCtrl.text.trim(),
      'imageUrl': img,
      'image': img,
      'category': cat,
      'level': _selectedCourseLevel,
      'status': _selectedCourseStatus,
      'isPaid': _isCoursePaid,
      'price': _isCoursePaid ? (double.tryParse(_coursePriceCtrl.text.trim()) ?? _coursePriceCtrl.text.trim()) : 0,
      'editorType': _isCourseHtmlMode ? 'html' : 'visual',
      'htmlCode': _courseHtmlCtrl.text.trim(),
      'content': _isCourseHtmlMode ? _courseHtmlCtrl.text.trim() : _courseDescCtrl.text.trim(),
      'pdfUrl': _coursePdfCtrl.text.trim(),
      'pdfLink': _coursePdfCtrl.text.trim(),
      'lessons': _editingCourse?['lessons'] ?? <Map<String, dynamic>>[],
    };

    if (_editingCourse == null) {
      await _dataService.addCourse(courseData);
    } else {
      await _dataService.updateCourse(_editingCourse!['id'], courseData);
    }
    setState(() {
      _isCreatingCourse = false;
      _editingCourse = null;
    });
    _showSnackBar("تم حفظ الكورس بنجاح");
  }

  // --- Playlist Workspace Methods ---
  void _openCreatePlaylistView({Map<String, dynamic>? existing}) {
    _editingPlaylist = existing;
    _isCreatingPlaylist = true;
    _playlistTitleCtrl.text = existing?['title'] ?? '';
    _playlistDescCtrl.text = existing?['description'] ?? '';
    _selectedPlaylistStatus = existing?['status'] ?? 'منشور';
    setState(() {});
  }

  Widget _buildPlaylistFullPageEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0284C7)),
                tooltip: "العودة إلى قائمة الدروس",
                onPressed: () => setState(() {
                  _isCreatingPlaylist = false;
                  _editingPlaylist = null;
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingPlaylist == null ? "إنشاء قائمة دروس جديدة" : "تعديل القائمة",
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      "تتيح القوائم تجميع الدروس والمحاضرات في سلاسل تعليمية مرتبة",
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _savePlaylistFromEditor,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text("حفظ القائمة 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const Divider(height: 36, color: Color(0xFFE2E8F0)),
          _buildEditorField("عنوان القائمة / السلسلة *", _playlistTitleCtrl, "مثال: سلسلة البرمجة للمبتدئين"),
          const SizedBox(height: 16),
          _buildEditorField("وصف القائمة *", _playlistDescCtrl, "اكتب نبذة عن الدروس المتضمنة داخل هذه القائمة...", maxLines: 3),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("حالة القائمة", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedPlaylistStatus,
                decoration: _inputDecoration("اختر الحالة"),
                items: const [
                  DropdownMenuItem(value: 'منشور', child: Text("منشور (نشط)")),
                  DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                ],
                onChanged: (v) => setState(() => _selectedPlaylistStatus = v ?? 'منشور'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _savePlaylistFromEditor() async {
    if (_playlistTitleCtrl.text.trim().isEmpty) {
      _showSnackBar("يرجى إدخال عنوان القائمة", isError: true);
      return;
    }
    final playlistData = {
      'title': _playlistTitleCtrl.text.trim(),
      'description': _playlistDescCtrl.text.trim(),
      'status': _selectedPlaylistStatus,
    };
    if (_editingPlaylist == null) {
      await _dataService.addLessonPlaylist(playlistData);
    } else {
      await _dataService.updateLessonPlaylist(_editingPlaylist!['id'], playlistData);
    }
    setState(() {
      _isCreatingPlaylist = false;
      _editingPlaylist = null;
    });
    _showSnackBar("تم حفظ القائمة بنجاح");
  }

  // --- Lesson Workspace Methods ---
  void _openCreateLessonView({Map<String, dynamic>? existing}) {
    _editingLesson = existing;
    _isCreatingLesson = true;
    _isLessonHtmlMode = (existing?['editorType'] ?? 'visual') == 'html';
    _lessonTitleCtrl.text = existing?['title'] ?? '';
    _lessonDescCtrl.text = existing?['description'] ?? '';
    _lessonImgCtrl.text = existing?['image'] ?? existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600';
    _lessonVideoCtrl.text = existing?['youtubeUrl'] ?? existing?['videoUrl'] ?? '';
    _lessonContentCtrl.text = existing?['content'] ?? '';
    _lessonHtmlCtrl.text = existing?['htmlCode'] ?? existing?['content'] ?? '';
    final cats = _dataService.lessonCategories;
    _selectedLessonCategory = existing?['category'] ?? existing?['subject'] ?? (cats.isNotEmpty ? cats.first : 'أساسيات البرمجة');
    final playlists = _dataService.lessonPlaylists;
    _selectedLessonPlaylistId = existing?['playlistId'] ?? (playlists.isNotEmpty ? (playlists.first['id'] ?? '') : '');
    _selectedLessonStatus = existing?['status'] ?? 'منشور';
    setState(() {});
  }

  void _insertHtmlSnippet(String snippet) {
    final text = _lessonHtmlCtrl.text;
    final selection = _lessonHtmlCtrl.selection;
    if (selection.isValid && selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, snippet);
      _lessonHtmlCtrl.text = newText;
      _lessonHtmlCtrl.selection = TextSelection.collapsed(offset: selection.start + snippet.length);
    } else {
      _lessonHtmlCtrl.text = text + (text.isEmpty ? '' : '\n\n') + snippet;
      _lessonHtmlCtrl.selection = TextSelection.collapsed(offset: _lessonHtmlCtrl.text.length);
    }
    setState(() {});
  }

  Widget _buildLessonFullPageEditor() {
    return SizedBox(
      height: 820,
      child: BloggerPostEditor(
        initialTitle: _editingLesson?['title'] ?? _lessonTitleCtrl.text,
        initialHtml: _editingLesson?['htmlCode'] ?? _lessonHtmlCtrl.text,
        initialContent: _editingLesson?['content'] ?? _lessonContentCtrl.text,
        initialCategory: _selectedLessonCategory.isNotEmpty
            ? _selectedLessonCategory
            : (_editingLesson?['category'] ?? 'عام'),
        initialStatus: _selectedLessonStatus,
        initialHasQuiz: _editingLesson?['hasQuiz'] == true,
        availableCategories: _dataService.lessonCategories,
        availablePlaylists: _dataService.lessonPlaylists,
        initialPlaylistId: _selectedLessonPlaylistId,
        onCancel: () => setState(() {
          _isCreatingLesson = false;
          _editingLesson = null;
        }),
        onSave: (result) async {
          final lessonData = {
            ...result,
            'playlistId': result['playlistId'] ?? _selectedLessonPlaylistId,
            'description': result['title'],
          };
          if (_editingLesson == null) {
            await _dataService.addLesson(lessonData);
            _showSnackBar("تم نشر الدرس بنجاح عبر محرر بلوجر 🚀");
          } else {
            await _dataService.updateLesson(_editingLesson!['id'], lessonData);
            _showSnackBar("تم تحديث الدرس بنجاح عبر محرر بلوجر 🚀");
          }
          setState(() {
            _isCreatingLesson = false;
            _editingLesson = null;
          });
        },
      ),
    );
  }

  Widget _buildLegacyLessonFullPageEditor() {
    final playlists = _dataService.lessonPlaylists;
    final lessonCats = _dataService.lessonCategories;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0284C7)),
                tooltip: "العودة إلى قائمة الدروس",
                onPressed: () => setState(() {
                  _isCreatingLesson = false;
                  _editingLesson = null;
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingLesson == null ? "إنشاء درس تعليمي جديد" : "تعديل الدرس",
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      _isLessonHtmlMode ? "وضع محرر HTML التفاعلي المباشر" : "وضع الإدخال العادي (كتابة الشرح ومحرر مرئي)",
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Mode switcher: عادي vs HTML
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isLessonHtmlMode = false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isLessonHtmlMode ? const Color(0xFF0284C7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          "📝 شرح نصي",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: !_isLessonHtmlMode ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isLessonHtmlMode = true),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isLessonHtmlMode ? const Color(0xFF8B5CF6) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          "💻 محرر HTML",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isLessonHtmlMode ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: _saveLessonFromEditor,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text("حفظ الدرس 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const Divider(height: 36, color: Color(0xFFE2E8F0)),

          // 1. Basic Metadata: Title and Status
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildEditorField("عنوان الدرس *", _lessonTitleCtrl, "مثال: الدرس 01: مقدمة في بنية البيانات والمصفوفات"),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("حالة النشر", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedLessonStatus,
                      decoration: _inputDecoration("اختر الحالة"),
                      items: const [
                        DropdownMenuItem(value: 'منشور', child: Text("منشور (متاح)")),
                        DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                      ],
                      onChanged: (v) => setState(() => _selectedLessonStatus = v ?? 'منشور'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Independent Lesson Category & Playlist
          Row(
            children: [
              // Independent Lesson Category Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("تصنيف الدرس * (مستقل عن الكورسات)", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6))),
                        TextButton(
                          onPressed: _showAddLessonCategoryDialog,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          child: Text("+ تصنيف جديد", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: lessonCats.contains(_selectedLessonCategory)
                          ? _selectedLessonCategory
                          : (lessonCats.isNotEmpty ? lessonCats.first : null),
                      decoration: _inputDecoration("اختر تصنيف الدرس"),
                      items: lessonCats.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat, style: GoogleFonts.cairo(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedLessonCategory = v ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Lesson Playlist Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("قائمة التشغيل التابع لها الدرس *", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7))),
                        TextButton(
                          onPressed: () => _openCreatePlaylistView(),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          child: Text("+ قائمة جديدة", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (playlists.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                        child: Text("لا توجد قوائم تشغيل. يرجى إنشاء قائمة أولاً.", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFB91C1C))),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedLessonPlaylistId.isNotEmpty && playlists.any((p) => p['id'] == _selectedLessonPlaylistId)
                            ? _selectedLessonPlaylistId
                            : playlists.first['id'],
                        decoration: _inputDecoration("اختر القائمة"),
                        items: playlists.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['id'].toString(),
                            child: Text("${p['title']} 📁", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedLessonPlaylistId = v ?? ''),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Cover Image and YouTube Video Link (ALWAYS PRESERVED!)
          Row(
            children: [
              Expanded(child: _buildEditorField("رابط صورة غلاف الدرس (URL) *", _lessonImgCtrl, "https://images.unsplash.com/...")),
              const SizedBox(width: 16),
              Expanded(child: _buildEditorField("رابط فيديو يوتيوب (Video URL / Embed)", _lessonVideoCtrl, "https://www.youtube.com/watch?v=... أو رابط مباشر")),
            ],
          ),
          const SizedBox(height: 16),
          _buildEditorField("وصف الدرس المختصر *", _lessonDescCtrl, "اكتب نبذة مختصرة عن أهداف الدرس ومحتواه...", maxLines: 2),
          const SizedBox(height: 20),

          // 4. Content Workspace: Text vs HTML
          if (!_isLessonHtmlMode) ...[
            _buildEditorField("المحتوى كتابة (نص الدرس والشرح وملاحظات الكود) *", _lessonContentCtrl, "اكتب محتوى الدرس بالتفصيل، يدعم النص العادي والـ Markdown...", maxLines: 10),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code_rounded, color: Color(0xFF8B5CF6), size: 24),
                      const SizedBox(width: 10),
                      Text("محرر HTML المتقدم للدرس التفاعلي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("استخدم الأزرار السريعة التالية لإدراج عناصر HTML أنيقة مباشرة داخل الدرس:", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF7C3AED))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _insertHtmlSnippet(
                          '<div style="background: linear-gradient(135deg, #1e293b, #0f172a); border-radius: 16px; padding: 24px; color: #fff; margin: 20px 0;">\n  <h3 style="color: #38bdf8; margin-top: 0;">✨ فكرة برمجية متميزة</h3>\n  <p style="color: #cbd5e1; line-height: 1.7;">اكتب الشرح والملاحظة هنا بأسلوب أنيق...</p>\n</div>',
                        ),
                        icon: const Icon(Icons.card_membership_rounded, size: 14),
                        label: Text("+ كرت أنيق", style: GoogleFonts.cairo(fontSize: 11)),
                        style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _insertHtmlSnippet(
                          '<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; border-radius: 12px; margin: 20px 0;">\n  <iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" style="position: absolute; top:0; left: 0; width: 100%; height: 100%; border:0;" allowfullscreen></iframe>\n</div>',
                        ),
                        icon: const Icon(Icons.video_library_rounded, size: 14),
                        label: Text("+ تضمين يوتيوب", style: GoogleFonts.cairo(fontSize: 11)),
                        style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _insertHtmlSnippet(
                          '<pre style="background: #0f172a; color: #38bdf8; padding: 16px; border-radius: 10px; font-family: monospace; direction: ltr; text-align: left; overflow-x: auto;">\n<code>// اكتب الكود البرمجي هنا\nvoid main() {\n    print("مرحباً بك في أكاديمية إسلام عاطف");\n}\n</code></pre>',
                        ),
                        icon: const Icon(Icons.terminal_rounded, size: 14),
                        label: Text("+ كود ملون", style: GoogleFonts.cairo(fontSize: 11)),
                        style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _insertHtmlSnippet(
                          '<div style="background: #f0fdf4; border-right: 4px solid #22c55e; padding: 14px 18px; border-radius: 8px; color: #15803d; margin: 16px 0;">\n  <strong>💡 معلومة ذكية:</strong> ركز على فهم المفاهيم بدلاً من حفظ الأكواد.\n</div>',
                        ),
                        icon: const Icon(Icons.lightbulb_outline_rounded, size: 14),
                        label: Text("+ صندوق معلومة", style: GoogleFonts.cairo(fontSize: 11)),
                        style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text("كود HTML للدرس *", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _lessonHtmlCtrl,
                maxLines: 15,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF38BDF8)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "<div class=\"lesson-box\">...</div>",
                  hintStyle: TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),
            const SizedBox(height: 20),
            Text("معاينة كود HTML الفورية:", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _lessonHtmlCtrl.text.trim().isEmpty
                  ? Center(child: Text("أدخل كود HTML لمشاهدة المعاينة المباشرة هنا", style: GoogleFonts.cairo(color: Colors.grey)))
                  : ArticleContentRenderer(content: _lessonHtmlCtrl.text, isDark: false),
            ),
          ],
        ],
      ),
    );
  }

  void _saveLessonFromEditor() async {
    final title = _lessonTitleCtrl.text.trim();
    if (title.isEmpty) {
      _showSnackBar("يرجى إدخال عنوان الدرس", isError: true);
      return;
    }

    final playlists = _dataService.lessonPlaylists;
    if (_selectedLessonPlaylistId.isEmpty && playlists.isNotEmpty) {
      _selectedLessonPlaylistId = playlists.first['id'];
    }
    final selectedPl = playlists.firstWhere(
      (p) => p['id'] == _selectedLessonPlaylistId,
      orElse: () => {'title': 'عام'},
    );
    final playlistTitle = selectedPl['title'] ?? 'عام';

    final cats = _dataService.lessonCategories;
    final cat = _selectedLessonCategory.isNotEmpty
        ? _selectedLessonCategory
        : (cats.isNotEmpty ? cats.first : 'أساسيات البرمجة');

    final img = _lessonImgCtrl.text.trim().isNotEmpty
        ? _lessonImgCtrl.text.trim()
        : 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600';
    final video = _lessonVideoCtrl.text.trim();

    final lessonData = {
      'title': title,
      'description': _lessonDescCtrl.text.trim(),
      'imageUrl': img,
      'image': img,
      'videoUrl': video,
      'youtubeUrl': video,
      'category': cat,
      'subject': cat,
      'playlistId': _selectedLessonPlaylistId,
      'playlistTitle': playlistTitle,
      'status': _selectedLessonStatus,
      'editorType': _isLessonHtmlMode ? 'html' : 'visual',
      'htmlCode': _lessonHtmlCtrl.text.trim(),
      'content': _isLessonHtmlMode
          ? (_lessonHtmlCtrl.text.trim().isNotEmpty ? _lessonHtmlCtrl.text.trim() : _lessonContentCtrl.text.trim())
          : _lessonContentCtrl.text.trim(),
    };

    if (_editingLesson == null) {
      await _dataService.addLesson(lessonData);
    } else {
      await _dataService.updateLesson(_editingLesson!['id'], lessonData);
    }

    setState(() {
      _isCreatingLesson = false;
      _editingLesson = null;
    });
    _showSnackBar("تم حفظ الدرس بنجاح");
  }

  // =========================================================================
  // THE 4-CARD SYSTEM (الأربع كروت المركزية لإدارة الكورسات والدروس)
  // =========================================================================

  Widget _buildFourActionCards({required bool isCourse}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          int cols = w < 650 ? 1 : (w < 1100 ? 2 : 4);
          final itemWidth = (w - (cols - 1) * 16) / cols;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // Card 1: إنشاء صنف
              _buildActionCard(
                width: itemWidth,
                num: "1",
                title: "إنشاء صنف",
                subtitle: isCourse
                    ? "إدارة تصنيفات الكورسات وإضافة صنف بمربع كتابة مباشر"
                    : "إدارة تصنيفات الدروس وإضافة صنف بمربع كتابة مباشر",
                badge: "الأصناف",
                icon: Icons.category_rounded,
                color: const Color(0xFF0284C7),
                btnText: "إدارة الأصناف 🏷️",
                onTap: () => _openCategoryManagerModal(isCourse: isCourse),
              ),
              // Card 2: قوائم التشغيل
              _buildActionCard(
                width: itemWidth,
                num: "2",
                title: "قوائم التشغيل",
                subtitle: isCourse
                    ? "إنشاء كورس / مسار كامل (اسم، صورة، وصف، مجاني/مدفوع)"
                    : "إنشاء منهج / قائمة تشغيل (اسم، صورة، وصف، مجاني/مدفوع)",
                badge: isCourse ? "الكورسات" : "المناهج",
                icon: Icons.playlist_play_rounded,
                color: const Color(0xFF8B5CF6),
                btnText: isCourse ? "إنشاء كورس 📂" : "إنشاء قائمة 📑",
                onTap: () => _openPlaylistManagerModal(isCourse: isCourse),
              ),
              // Card 3: إضافة فيديو / إضافة درس
              _buildActionCard(
                width: itemWidth,
                num: "3",
                title: isCourse ? "إضافة فيديو للكورس" : "إضافة درس",
                subtitle: "تحديد القائمة + العنوان + محرر عادي مثل بلوجر ومحرر HTML",
                badge: "محرر مزدوج",
                icon: isCourse ? Icons.video_call_rounded : Icons.post_add_rounded,
                color: const Color(0xFF10B981),
                btnText: isCourse ? "+ إضافة فيديو 🎬" : "+ إضافة درس 📝",
                onTap: () => _openAddLectureOrLessonModal(isCourse: isCourse),
              ),
              // Card 4: اختبار
              _buildActionCard(
                width: itemWidth,
                num: "4",
                title: "اختبار (Quiz)",
                subtitle: "تحديد القائمة والدرس + محرر كود HTML فقط للاختبار",
                badge: "HTML فقط",
                icon: Icons.quiz_rounded,
                color: const Color(0xFFF59E0B),
                btnText: "+ إضافة اختبار 🧠",
                onTap: () => _openAddQuizToLectureOrLessonModal(isCourse: isCourse),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required double width,
    required String num,
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color color,
    required String btnText,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "كارت $num | $badge",
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  btnText,
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Card 1: إنشاء صنف (Category Manager Modal)
  // ----------------------------------------------------
  void _openCategoryManagerModal({required bool isCourse}) {
    final newCatCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            final cats = isCourse ? _dataService.courseCategories : _dataService.lessonCategories;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.category_rounded, color: Color(0xFF0284C7), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCourse ? "إدارة أصناف الكورسات 🏷️" : "إدارة أصناف الدروس 🏷️",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اكتب اسم الصنف فقط بمربع الكتابة واضغط إضافة ليتم حفظه فوراً في Firebase:",
                      style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newCatCtrl,
                            decoration: InputDecoration(
                              hintText: "اكتب اسم الصنف هنا (مربع كتابة الصنف)...",
                              hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            onSubmitted: (val) async {
                              final cat = val.trim();
                              if (cat.isEmpty) return;
                              if (isCourse) {
                                await _dataService.addCourseCategory(cat);
                              } else {
                                await _dataService.addLessonCategory(cat);
                              }
                              newCatCtrl.clear();
                              setDlgState(() {});
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final cat = newCatCtrl.text.trim();
                            if (cat.isEmpty) {
                              _showSnackBar("يرجى كتابة اسم الصنف أولاً", isError: true);
                              return;
                            }
                            if (isCourse) {
                              await _dataService.addCourseCategory(cat);
                            } else {
                              await _dataService.addLessonCategory(cat);
                            }
                            newCatCtrl.clear();
                            setDlgState(() {});
                            setState(() {});
                            _showSnackBar("تمت إضافة الصنف وحفظه بنجاح في Firebase");
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text("إضافة الصنف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "الأصناف المتاحة حالياً (${cats.length}):",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: cats.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text("لا توجد أصناف مضافة حتى الآن", style: GoogleFonts.cairo(color: Colors.grey)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: cats.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 8),
                              itemBuilder: (c, i) {
                                final cat = cats[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.label_important_outline_rounded, size: 18, color: Color(0xFF0284C7)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(cat, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                        tooltip: "حذف الصنف",
                                        onPressed: () async {
                                          if (isCourse) {
                                            await _dataService.deleteCourseCategory(cat);
                                          } else {
                                            await _dataService.deleteLessonCategory(cat);
                                          }
                                          setDlgState(() {});
                                          setState(() {});
                                          _showSnackBar("تم حذف الصنف من Firebase");
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("إغلاق", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Card 2: قوائم التشغيل (Playlist Manager Modal)
  // ----------------------------------------------------
  void _openPlaylistManagerModal({required bool isCourse}) {
    final titleCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final cats = isCourse ? _dataService.courseCategories : _dataService.lessonCategories;
    String selectedCat = cats.isNotEmpty ? cats.first : 'عام';
    bool isPaid = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            final playlists = isCourse ? _dataService.courses : _dataService.lessonPlaylists;
            final screenWidth = MediaQuery.of(context).size.width;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.playlist_play_rounded, color: Color(0xFF8B5CF6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCourse ? "قوائم التشغيل (إنشاء وإدارة الكورسات) 📚" : "قوائم التشغيل (إنشاء وإدارة المناهج) 📑",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: screenWidth > 650 ? 600 : screenWidth * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCourse ? "+ إنشاء كورس / مسار جديد:" : "+ إنشاء منهج / قائمة جديدة:",
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: titleCtrl,
                              decoration: _inputDecoration(isCourse ? "اسم الكورس / القائمة *" : "اسم المنهج / القائمة *"),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: imgCtrl,
                              decoration: _inputDecoration("رابط صورة غلاف القائمة (URL)"),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: descCtrl,
                              maxLines: 2,
                              decoration: _inputDecoration("وصف مختصر للقائمة *"),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: DropdownButtonFormField<String>(
                                    value: (cats.contains(selectedCat)) ? selectedCat : (cats.isNotEmpty ? cats.first : null),
                                    decoration: _inputDecoration("التصنيف"),
                                    items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.cairo(fontSize: 13)))).toList(),
                                    onChanged: (v) => setDlgState(() => selectedCat = v ?? selectedCat),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isPaid ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isPaid ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isPaid ? "🔒 مدفوع" : "🟢 مجاني",
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isPaid ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: isPaid,
                                        activeColor: const Color(0xFFDC2626),
                                        onChanged: (v) => setDlgState(() => isPaid = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isPaid) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration("سعر الاشتراك (بالجنيه المصري EGP) * مثال: 250"),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final title = titleCtrl.text.trim();
                                  if (title.isEmpty) {
                                    _showSnackBar("يرجى كتابة اسم القائمة", isError: true);
                                    return;
                                  }
                                  final rawImg = imgCtrl.text.trim();
                                  final img = rawImg.isNotEmpty
                                      ? sanitizeImageUrl(rawImg)
                                      : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600';
                                  final desc = descCtrl.text.trim();
                                  final priceVal = isPaid
                                      ? (double.tryParse(priceCtrl.text.trim()) ?? priceCtrl.text.trim())
                                      : 0;

                                  if (isCourse) {
                                    await _dataService.createCourse({
                                      'title': title,
                                      'imageUrl': img,
                                      'image': img,
                                      'description': desc,
                                      'category': selectedCat,
                                      'isPaid': isPaid,
                                      'price': priceVal,
                                      'status': 'منشور',
                                      'lessons': [],
                                    });
                                  } else {
                                    await _dataService.createLessonPlaylist({
                                      'title': title,
                                      'imageUrl': img,
                                      'image': img,
                                      'description': desc,
                                      'category': selectedCat,
                                      'isPaid': isPaid,
                                      'price': priceVal,
                                      'status': 'منشور',
                                    });
                                  }
                                  titleCtrl.clear();
                                  imgCtrl.clear();
                                  descCtrl.clear();
                                  priceCtrl.clear();
                                  setDlgState(() {});
                                  setState(() {});
                                  _showSnackBar("تم حفظ القائمة بنجاح في Firebase 🚀");
                                },
                                icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                                label: Text("حفظ القائمة في Firebase", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("القوائم الحالية (${playlists.length}):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (!isCourse && playlists.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: dialogCtx,
                                  builder: (c) => AlertDialog(
                                    title: Text("تأكيد مسح كافة المناهج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                    content: Text("هل أنت متأكد من مسح جميع المناهج الحالية من Firebase والتطبيق لتتمكن من إنشاء منهج جديد نظيف؟", style: GoogleFonts.cairo()),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("إلغاء")),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                        child: const Text("نعم، امسح الكل"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _dataService.clearAllLessonPlaylists();
                                  setDlgState(() {});
                                  setState(() {});
                                  _showSnackBar("تم مسح وتنظيف كافة المناهج من Firebase بنجاح 🗑️");
                                }
                              },
                              icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Color(0xFFEF4444)),
                              label: Text("مسح وتنظيف كافة المناهج", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: playlists.isEmpty
                            ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("لا توجد قوائم منشأة بعد", style: GoogleFonts.cairo(color: Colors.grey))))
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: playlists.length,
                                separatorBuilder: (c, i) => const SizedBox(height: 8),
                                itemBuilder: (c, i) {
                                  final item = playlists[i];
                                  final paid = item['isPaid'] == true;
                                  final priceText = item['price'] != null && item['price'].toString().isNotEmpty && item['price'].toString() != '0'
                                      ? " (${item['price']} ج.م)"
                                      : "";
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 50,
                                            height: 40,
                                            child: Image.network(
                                              item['imageUrl'] ?? item['image'] ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 18, color: Colors.grey)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                              Text(item['category'] ?? '', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: paid ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            paid ? "🔒 مدفوع$priceText" : "🟢 مجاني",
                                            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: paid ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                          tooltip: "حذف القائمة",
                                          onPressed: () async {
                                            if (isCourse) {
                                              await _dataService.deleteCourse(item['id']);
                                            } else {
                                              await _dataService.deleteLessonPlaylist(item['id']);
                                            }
                                            setDlgState(() {});
                                            setState(() {});
                                            _showSnackBar("تم حذف القائمة من Firebase");
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("إغلاق", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Card 3: إضافة فيديو / درس (Dual Editor Workspace)
  // ----------------------------------------------------
  void _openAddLectureOrLessonModal({required bool isCourse}) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final htmlCtrl = TextEditingController();
    bool isPaid = false;
    int editorTab = 0; // 0: محرر بلوجر العادي, 1: محرر كود HTML

    final playlists = isCourse ? _dataService.courses : _dataService.lessonPlaylists;
    String selectedPlaylistId = playlists.isNotEmpty ? playlists.first['id'].toString() : '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isCourse ? Icons.video_call_rounded : Icons.post_add_rounded, color: const Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCourse ? "إضافة فيديو جديد للكورس 🎬" : "إضافة درس جديد 📝",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width > 820 ? 780 : MediaQuery.of(context).size.width * 0.92,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Playlist selector & Free/Paid toggle
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: playlists.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      isCourse ? "لا توجد كورسات مضافة. يرجى إنشاء كورس أولاً من كارت 2." : "لا توجد قوائم تشغيل. يرجى إنشاء قائمة أولاً من كارت 2.",
                                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFDC2626)),
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    value: playlists.any((p) => p['id'].toString() == selectedPlaylistId)
                                        ? selectedPlaylistId
                                        : playlists.first['id'].toString(),
                                    decoration: _inputDecoration(isCourse ? "اختر الكورس التابع له *" : "اختر قائمة التشغيل / المنهج *"),
                                    items: playlists.map((p) => DropdownMenuItem(value: p['id'].toString(), child: Text(p['title'] ?? '', style: GoogleFonts.cairo(fontSize: 13)))).toList(),
                                    onChanged: (v) => setDlgState(() => selectedPlaylistId = v ?? ''),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPaid ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isPaid ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isPaid ? "🔒 مدفوع" : "🟢 مجاني",
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isPaid ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: isPaid,
                                  activeColor: const Color(0xFFDC2626),
                                  onChanged: (v) => setDlgState(() => isPaid = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 2. Title
                      TextField(
                        controller: titleCtrl,
                        decoration: _inputDecoration(isCourse ? "عنوان الفيديو / المحاضرة *" : "عنوان الدرس *"),
                      ),
                      const SizedBox(height: 16),

                      // 3. Dual Editor Tabs Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setDlgState(() => editorTab = 0),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: editorTab == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: editorTab == 0 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "✍️ المحرر العادي (زي مدونة بلوجر)",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: editorTab == 0 ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setDlgState(() => editorTab = 1),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: editorTab == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: editorTab == 1 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "💻 محرر كود HTML (كامل)",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: editorTab == 1 ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Editor 1: Blogger Visual Editor
                      if (editorTab == 0) ...[
                        _buildBloggerRibbonToolbar(contentCtrl, () => setDlgState(() {})),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentCtrl,
                          maxLines: 9,
                          decoration: InputDecoration(
                            hintText: "اكتب محتوى الدرس وشرحه هنا... يمكنك استخدام شريط الأدوات بالأعلى لتنسيق الخطوط وإضافة الصور والفيديوهات والكود والملاحظات مثل بلوجر تماماً.",
                            hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                        ),
                      ] else ...[
                        // Editor 2: Full HTML Code Editor
                        Container(
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: htmlCtrl,
                            maxLines: 10,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF38BDF8)),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "<div class=\"lesson-content\">\n  <!-- أدخل كود HTML بالكامل هنا مع التنسيقات والأكواد التفاعلية -->\n</div>",
                              hintStyle: TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) {
                      _showSnackBar("يرجى كتابة عنوان المحتوى", isError: true);
                      return;
                    }
                    if (playlists.isEmpty || selectedPlaylistId.isEmpty) {
                      _showSnackBar("يرجى اختيار قائمة التشغيل", isError: true);
                      return;
                    }

                    final content = contentCtrl.text.trim();
                    final htmlCode = htmlCtrl.text.trim();
                    final sourceBody = editorTab == 0 ? content : htmlCode;

                    // Automatically extract image cover and video if inserted inside the editor
                    String img = '';
                    String video = '';

                    final imgMatch = RegExp(r'<img[^>]+src=["\x27]([^"\x27]+)["\x27]|\[img\]([^\[\]]+)\[\/img\]|!\[[^\]]*\]\(([^)]+)\)').firstMatch(sourceBody);
                    if (imgMatch != null) {
                      img = sanitizeImageUrl((imgMatch.group(1) ?? imgMatch.group(2) ?? imgMatch.group(3) ?? '').trim());
                    }

                    final vidMatch = RegExp(r'(https?://(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)[a-zA-Z0-9_\-]+)|<iframe[^>]+src=["\x27]([^"\x27]+)["\x27]').firstMatch(sourceBody);
                    if (vidMatch != null) {
                      video = (vidMatch.group(1) ?? vidMatch.group(2) ?? '').trim();
                    }

                    if (isCourse) {
                      // Append to course's lessons list
                      final courseIdx = _dataService.courses.indexWhere((c) => c['id'].toString() == selectedPlaylistId);
                      if (courseIdx >= 0) {
                        final course = _dataService.courses[courseIdx];
                        final lessonsList = List<Map<String, dynamic>>.from(course['lessons'] ?? []);
                        lessonsList.add({
                          'id': 'lec_${DateTime.now().millisecondsSinceEpoch}',
                          'title': title,
                          'imageUrl': img,
                          'image': img,
                          'videoUrl': video,
                          'youtubeUrl': video,
                          'isPaid': isPaid,
                          'editorType': editorTab == 0 ? 'visual' : 'html',
                          'content': content,
                          'htmlCode': htmlCode,
                        });
                        await _dataService.updateCourse(course['id'], {'lessons': lessonsList});
                      }
                    } else {
                      // Add standalone lesson
                      final targetPlaylist = _dataService.lessonPlaylists.firstWhere(
                        (p) => p['id'].toString() == selectedPlaylistId,
                        orElse: () => <String, dynamic>{},
                      );

                      await _dataService.addLesson({
                        'title': title,
                        'playlistId': selectedPlaylistId,
                        'playlistTitle': targetPlaylist['title'] ?? 'قائمة الدروس',
                        'category': targetPlaylist['category'] ?? 'عام',
                        'imageUrl': img,
                        'image': img,
                        'videoUrl': video,
                        'youtubeUrl': video,
                        'isPaid': isPaid,
                        'editorType': editorTab == 0 ? 'visual' : 'html',
                        'content': content,
                        'htmlCode': htmlCode,
                        'status': 'منشور',
                      });
                    }

                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    setState(() {});
                    _showSnackBar("تم حفظ ونشر المحتوى بنجاح في Firebase 🚀");
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text("حفظ ونشر في Firebase", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Card 4: اختبار (Quiz Modal - HTML Editor Only)
  // ----------------------------------------------------
  void _openAddQuizToLectureOrLessonModal({required bool isCourse}) {
    final quizTitleCtrl = TextEditingController(text: "اختبار قياس الفهم");
    final quizHtmlCtrl = TextEditingController();
    final playlists = isCourse ? _dataService.courses : _dataService.lessonPlaylists;
    String selectedPlaylistId = playlists.isNotEmpty ? playlists.first['id'].toString() : '';
    String selectedLessonId = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            // Available lessons/lectures depending on the selected playlist
            List<Map<String, dynamic>> targetLessons = [];
            if (isCourse) {
              final course = _dataService.courses.firstWhere(
                (c) => c['id'].toString() == selectedPlaylistId,
                orElse: () => <String, dynamic>{},
              );
              targetLessons = List<Map<String, dynamic>>.from(course['lessons'] ?? []);
            } else {
              targetLessons = _dataService.lessons.where((l) => l['playlistId'].toString() == selectedPlaylistId).toList();
            }

            if (selectedLessonId.isEmpty && targetLessons.isNotEmpty) {
              selectedLessonId = targetLessons.first['id'].toString();
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.quiz_rounded, color: Color(0xFFF59E0B), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text("إضافة اختبار للدرس أو الفيديو 🧠", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width > 750 ? 720 : MediaQuery.of(context).size.width * 0.92,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Select Playlist
                      DropdownButtonFormField<String>(
                        value: playlists.any((p) => p['id'].toString() == selectedPlaylistId)
                            ? selectedPlaylistId
                            : (playlists.isNotEmpty ? playlists.first['id'].toString() : null),
                        decoration: _inputDecoration(isCourse ? "اختر الكورس *" : "اختر قائمة التشغيل *"),
                        items: playlists.map((p) => DropdownMenuItem(value: p['id'].toString(), child: Text(p['title'] ?? '', style: GoogleFonts.cairo(fontSize: 13)))).toList(),
                        onChanged: (v) {
                          setDlgState(() {
                            selectedPlaylistId = v ?? '';
                            selectedLessonId = '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // 2. Select Lesson / Lecture
                      if (targetLessons.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                          child: Text("لا توجد دروس أو فيديوهات مضافة بعد داخل هذه القائمة.", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFDC2626))),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: targetLessons.any((l) => l['id'].toString() == selectedLessonId)
                              ? selectedLessonId
                              : targetLessons.first['id'].toString(),
                          decoration: _inputDecoration("اختر الدرس أو الفيديو المستهدف *"),
                          items: targetLessons.map((l) => DropdownMenuItem(value: l['id'].toString(), child: Text(l['title'] ?? '', style: GoogleFonts.cairo(fontSize: 13)))).toList(),
                          onChanged: (v) => setDlgState(() => selectedLessonId = v ?? ''),
                        ),
                      const SizedBox(height: 12),

                      // 3. Quiz Title
                      TextField(
                        controller: quizTitleCtrl,
                        decoration: _inputDecoration("عنوان الاختبار *"),
                      ),
                      const SizedBox(height: 16),

                      // 4. HTML Editor Only
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("محرر كود HTML فقط للاختبار *", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                          TextButton.icon(
                            onPressed: () {
                              quizHtmlCtrl.text = '''
<div style="font-family: 'Cairo', sans-serif; direction: rtl; padding: 20px; background: #f8fafc; border-radius: 16px; border: 1px solid #e2e8f0;">
  <h3 style="color: #0284c7; margin-top: 0;">📝 اختبار قياس الفهم والاستيعاب</h3>
  <p style="color: #64748b;">اختر الإجابة الصحيحة لكل سؤال واضغط على زر التحقق لمعرفة نتيجتك فوراً:</p>

  <div style="background: #ffffff; padding: 18px; border-radius: 12px; margin-bottom: 16px; border: 1px solid #cbd5e1;">
    <h4 style="margin: 0 0 12px; color: #1e293b;">السؤال الأول: ما هي لغة البرمجة الأساسية لبناء تطبيقات Flutter؟</h4>
    <label style="display: block; margin-bottom: 8px; cursor: pointer;"><input type="radio" name="q1" value="wrong"> JavaScript</label>
    <label style="display: block; margin-bottom: 8px; cursor: pointer;"><input type="radio" name="q1" value="correct"> Dart</label>
    <label style="display: block; margin-bottom: 8px; cursor: pointer;"><input type="radio" name="q1" value="wrong"> Python</label>
  </div>

  <button onclick="checkScore()" style="background: #0284c7; color: #ffffff; border: none; padding: 12px 24px; border-radius: 8px; font-weight: bold; cursor: pointer;">تحقق من النتيجة ✅</button>
  <div id="quiz-result" style="margin-top: 14px; font-weight: bold; color: #16a34a;"></div>
</div>

<script>
function checkScore() {
  var q1 = document.querySelector('input[name="q1"]:checked');
  var res = document.getElementById('quiz-result');
  if(!q1) { res.innerText = "يرجى اختيار إجابة أولاً!"; res.style.color="#dc2626"; return; }
  if(q1.value === "correct") {
    res.innerText = "🎉 إجابة ممتازة وصحيحة! نتيجتك 100%";
    res.style.color="#16a34a";
  } else {
    res.innerText = "❌ إجابة غير صحيحة، حاول مجدداً!";
    res.style.color="#dc2626";
  }
}
</script>
''';
                              setDlgState(() {});
                            },
                            icon: const Icon(Icons.auto_fix_high_rounded, size: 16, color: Color(0xFFF59E0B)),
                            label: Text("إدراج قالب اختبار تفاعلي جاهز 🪄", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFD97706), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: quizHtmlCtrl,
                          maxLines: 10,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF38BDF8)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "<div class=\"quiz-box\">\n  <!-- أدخل كود HTML للاختبار فقط هنا -->\n</div>",
                            hintStyle: TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final qTitle = quizTitleCtrl.text.trim();
                    final qHtml = quizHtmlCtrl.text.trim();

                    if (selectedLessonId.isEmpty) {
                      _showSnackBar("يرجى اختيار الدرس أو الفيديو المستهدف", isError: true);
                      return;
                    }
                    if (qHtml.isEmpty) {
                      _showSnackBar("يرجى إدخال كود HTML للاختبار", isError: true);
                      return;
                    }

                    if (isCourse) {
                      final courseIdx = _dataService.courses.indexWhere((c) => c['id'].toString() == selectedPlaylistId);
                      if (courseIdx >= 0) {
                        final course = _dataService.courses[courseIdx];
                        final lessonsList = List<Map<String, dynamic>>.from(course['lessons'] ?? []);
                        final lecIdx = lessonsList.indexWhere((l) => l['id'].toString() == selectedLessonId);
                        if (lecIdx >= 0) {
                          lessonsList[lecIdx]['hasQuiz'] = true;
                          lessonsList[lecIdx]['quizTitle'] = qTitle;
                          lessonsList[lecIdx]['quizHtml'] = qHtml;
                          await _dataService.updateCourse(course['id'], {'lessons': lessonsList});
                        }
                      }
                    } else {
                      await _dataService.updateLesson(selectedLessonId, {
                        'hasQuiz': true,
                        'quizTitle': qTitle,
                        'quizHtml': qHtml,
                      });
                    }

                    // Also save to interactiveQuizzes collection
                    await _dataService.addInteractiveQuiz({
                      'title': qTitle,
                      'htmlContent': qHtml,
                      'htmlCode': qHtml,
                    });

                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    setState(() {});
                    _showSnackBar("تم ربط الاختبار بالدرس وحفظه بنجاح في Firebase 🧠");
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text("حفظ الاختبار في Firebase", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Blogger Ribbon Toolbar Helper
  // ----------------------------------------------------
  Widget _buildBloggerRibbonToolbar(TextEditingController ctrl, VoidCallback onUpdate) {
    void wrapSelection(String open, String close) {
      final text = ctrl.text;
      final sel = ctrl.selection;
      if (sel.isValid && sel.start >= 0 && sel.end >= 0 && sel.start != sel.end) {
        final before = text.substring(0, sel.start);
        final selected = text.substring(sel.start, sel.end);
        final after = text.substring(sel.end);
        ctrl.text = '$before$open$selected$close$after';
        ctrl.selection = TextSelection(baseOffset: sel.start + open.length, extentOffset: sel.start + open.length + selected.length);
      } else {
        final pos = sel.isValid && sel.baseOffset >= 0 ? sel.baseOffset : text.length;
        final before = text.substring(0, pos);
        final after = text.substring(pos);
        ctrl.text = '$before$open$close$after';
        ctrl.selection = TextSelection.collapsed(offset: pos + open.length);
      }
      onUpdate();
    }

    void insertSnippet(String snippet) {
      final text = ctrl.text;
      final sel = ctrl.selection;
      final pos = sel.isValid && sel.baseOffset >= 0 ? sel.baseOffset : text.length;
      final before = text.substring(0, pos);
      final after = text.substring(pos);
      ctrl.text = '$before\n$snippet\n$after';
      ctrl.selection = TextSelection.collapsed(offset: pos + snippet.length + 2);
      onUpdate();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _toolbarBtn("B", "عريض", () => wrapSelection("<b>", "</b>"), isBold: true),
          _toolbarBtn("I", "مائل", () => wrapSelection("<i>", "</i>"), isItalic: true),
          _toolbarBtn("U", "مسطر", () => wrapSelection("<u>", "</u>"), isUnderline: true),
          const SizedBox(height: 18, child: VerticalDivider(color: Color(0xFF94A3B8))),
          _toolbarBtn("H1", "عنوان رئيسي", () => wrapSelection("<h1 style=\"color:#0284c7; border-bottom: 2px solid #e2e8f0; padding-bottom: 8px;\">", "</h1>")),
          _toolbarBtn("H2", "عنوان فرعي", () => wrapSelection("<h2 style=\"color:#334155; margin-top: 18px;\">", "</h2>")),
          _toolbarBtn("H3", "عنوان قسم", () => wrapSelection("<h3 style=\"color:#64748b;\">", "</h3>")),
          const SizedBox(height: 18, child: VerticalDivider(color: Color(0xFF94A3B8))),
          _toolbarIconBtn(Icons.image_rounded, "إضافة صورة", () {
            _promptForUrlAndInsert(
              title: "إضافة صورة في المقال",
              hint: "رابط الصورة (URL أو رابط مباشر)",
              onConfirm: (url) {
                final cleanUrl = sanitizeImageUrl(url);
                insertSnippet('<div style="text-align: center; margin: 20px 0;">\n  <img src="$cleanUrl" style="max-width: 100%; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.1);" alt="صورة المقال"/>\n</div>');
              },
            );
          }),
          _toolbarIconBtn(Icons.video_library_rounded, "إضافة فيديو يوتيوب", () {
            _promptForUrlAndInsert(
              title: "إضافة فيديو يوتيوب",
              hint: "رابط فيديو يوتيوب (https://www.youtube.com/watch?v=...)",
              onConfirm: (url) {
                final id = _extractYoutubeId(url);
                insertSnippet('<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; border-radius: 12px; margin: 20px 0;">\n  <iframe src="https://www.youtube.com/embed/$id" style="position: absolute; top:0; left: 0; width: 100%; height: 100%; border:0;" allowfullscreen></iframe>\n</div>');
              },
            );
          }),
          _toolbarIconBtn(Icons.terminal_rounded, "إضافة كود برمجي", () {
            insertSnippet('<pre style="background: #0f172a; color: #38bdf8; padding: 16px; border-radius: 10px; font-family: monospace; direction: ltr; text-align: left; overflow-x: auto;">\n<code>// اكتب الكود البرمجي هنا\nvoid main() {\n  print("Hello World!");\n}\n</code></pre>');
          }),
          _toolbarIconBtn(Icons.lightbulb_outline_rounded, "صندوق ملاحظة / تنبيه", () {
            insertSnippet('<div style="background: #f0fdf4; border-right: 4px solid #22c55e; padding: 14px 18px; border-radius: 8px; color: #15803d; margin: 16px 0;">\n  <strong>💡 معلومة هامة:</strong> اكتب الملاحظة أو التنبيه هنا...\n</div>');
          }),
          _toolbarIconBtn(Icons.link_rounded, "إضافة رابط", () {
            _promptForUrlAndInsert(
              title: "إضافة رابط خارجي",
              hint: "الرابط (URL)",
              onConfirm: (url) {
                wrapSelection('<a href="$url" target="_blank" style="color: #0284c7; text-decoration: underline; font-weight: bold;">', '</a>');
              },
            );
          }),
          _toolbarIconBtn(Icons.format_list_bulleted_rounded, "قائمة نقطية", () {
            insertSnippet('<ul style="line-height: 2; margin: 14px 0;">\n  <li>العنصر الأول</li>\n  <li>العنصر الثاني</li>\n  <li>العنصر الثالث</li>\n</ul>');
          }),
        ],
      ),
    );
  }

  Widget _toolbarBtn(String label, String tooltip, VoidCallback onTap, {bool isBold = false, bool isItalic = false, bool isUnderline = false}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
              fontSize: 12,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarIconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
          child: Icon(icon, size: 16, color: const Color(0xFF475569)),
        ),
      ),
    );
  }

  void _promptForUrlAndInsert({required String title, required String hint, required Function(String) onConfirm}) {
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: urlCtrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              final val = urlCtrl.text.trim();
              if (val.isNotEmpty) {
                onConfirm(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text("تأكيد وإدراج"),
          ),
        ],
      ),
    );
  }

  String _extractYoutubeId(String url) {
    final regExp = RegExp(r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([\w-]{11})');
    final match = regExp.firstMatch(url);
    return match != null ? match.group(1)! : url;
  }

  // ----------------------------------------------------
  // Members Permissions Manager Dialog
  // ----------------------------------------------------
  void _openMemberPermissionsDialog(Map<String, dynamic> member) {
    final uid = member['uid'] ?? '';
    final name = member['name'] ?? member['displayName'] ?? 'عضو';
    final email = member['email'] ?? '';
    final List<String> allowedCourses = List<String>.from(member['allowedCourses'] ?? []);
    final List<String> allowedLessons = List<String>.from(member['allowedLessons'] ?? []);

    final paidCourses = _dataService.courses.where((c) => c['isPaid'] == true).toList();
    final paidLessons = _dataService.lessons.where((l) => l['isPaid'] == true).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.vpn_key_rounded, color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("إدارة صلاحيات المحتوى المدفوع 🔑", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("للعضو: $name ($email)", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "حدد الكورسات والدروس المدفوعة المصرح لهذا العضو بالدخول إليها ومتابعتها:",
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 1: Paid Courses
                      Text("الكورسات المدفوعة 📚 (${paidCourses.length}):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      if (paidCourses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("لا توجد كورسات محددة كـ 'مدفوعة' حتى الآن.", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                        )
                      else
                        ...paidCourses.map((c) {
                          final cId = c['id'].toString();
                          final isAllowed = allowedCourses.contains(cId);
                          return CheckboxListTile(
                            dense: true,
                            title: Text(c['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("التصنيف: ${c['category'] ?? 'عام'}", style: GoogleFonts.cairo(fontSize: 11)),
                            value: isAllowed,
                            activeColor: const Color(0xFF0284C7),
                            onChanged: (val) {
                              setDlgState(() {
                                if (val == true) {
                                  allowedCourses.add(cId);
                                } else {
                                  allowedCourses.remove(cId);
                                }
                              });
                            },
                          );
                        }),

                      const Divider(height: 28),

                      // Section 2: Paid Lessons
                      Text("الدروس المستقلة المدفوعة 📝 (${paidLessons.length}):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      if (paidLessons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("لا توجد دروس محددة كـ 'مدفوعة' حتى الآن.", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                        )
                      else
                        ...paidLessons.map((l) {
                          final lId = l['id'].toString();
                          final isAllowed = allowedLessons.contains(lId);
                          return CheckboxListTile(
                            dense: true,
                            title: Text(l['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("القائمة: ${l['playlistTitle'] ?? l['category'] ?? 'عام'}", style: GoogleFonts.cairo(fontSize: 11)),
                            value: isAllowed,
                            activeColor: const Color(0xFF8B5CF6),
                            onChanged: (val) {
                              setDlgState(() {
                                if (val == true) {
                                  allowedLessons.add(lId);
                                } else {
                                  allowedLessons.remove(lId);
                                }
                              });
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await UserService.instance.updateMemberPermissions(
                      uid,
                      allowedCourses: allowedCourses,
                      allowedLessons: allowedLessons,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _showSnackBar("تم حفظ وتحديث صلاحيات العضو في Firebase بنجاح 🔑");
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text("حفظ الصلاحيات في Firebase", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 2. الكورسات (COURSES 📚)
  // =========================================================================
  Widget _buildCoursesSection() {
    final cats = _dataService.courseCategories;
    final filteredCourses = _dataService.courses.where((c) {
      final matchesSearch = (c['title'] ?? '').toString().toLowerCase().contains(_coursesSearch.toLowerCase()) ||
          (c['description'] ?? '').toString().toLowerCase().contains(_coursesSearch.toLowerCase());
      final matchesFilter = _coursesFilter == 'الكل' || (c['status'] ?? 'منشور') == _coursesFilter;
      final matchesCat = _selectedCourseCategoryFilter == 'الكل' || (c['category'] ?? '') == _selectedCourseCategoryFilter;
      return matchesSearch && matchesFilter && matchesCat;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Action Cards for Courses
        _buildFourActionCards(isCourse: true),
        _buildSubTabHeader(
          tabs: [
            _SubTabItem("الكورسات التعليمية", Icons.menu_book_rounded, count: _dataService.courses.length),
            _SubTabItem("تصنيفات الكورسات (مستقلة)", Icons.category_rounded, count: _dataService.courseCategories.length),
          ],
          selectedIndex: _coursesSubTab,
          onTabSelected: (idx) => setState(() => _coursesSubTab = idx),
          trailing: _coursesSubTab == 0 && !isMobile
              ? ElevatedButton.icon(
                  onPressed: () => _openCreateCourseView(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text("+ إنشاء كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 20),
        if (_coursesSubTab == 1)
          _buildCourseCategoriesTab()
        else ...[
          // Top Toolbar: Search + Category Filter + Status Filter + Add Button
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _coursesSearch = val),
                  decoration: InputDecoration(
                    hintText: "بحث في الكورسات...",
                    hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: (cats.contains(_selectedCourseCategoryFilter) || _selectedCourseCategoryFilter == 'الكل')
                                ? _selectedCourseCategoryFilter
                                : 'الكل',
                            items: [
                              const DropdownMenuItem(value: 'الكل', child: Text("جميع التصنيفات", overflow: TextOverflow.ellipsis)),
                              ...cats.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (v) => setState(() => _selectedCourseCategoryFilter = v ?? 'الكل'),
                            style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _coursesFilter,
                            items: const [
                              DropdownMenuItem(value: 'الكل', child: Text("جميع الحالات")),
                              DropdownMenuItem(value: 'منشور', child: Text("منشور")),
                              DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                            ],
                            onChanged: (v) => setState(() => _coursesFilter = v ?? 'الكل'),
                            style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCreateCourseView(),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text("+ إنشاء كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    onChanged: (val) => setState(() => _coursesSearch = val),
                    decoration: InputDecoration(
                      hintText: "بحث في الكورسات...",
                      hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (cats.contains(_selectedCourseCategoryFilter) || _selectedCourseCategoryFilter == 'الكل')
                          ? _selectedCourseCategoryFilter
                          : 'الكل',
                      items: [
                        const DropdownMenuItem(value: 'الكل', child: Text("جميع التصنيفات 📁")),
                        ...cats.map((cat) => DropdownMenuItem(value: cat, child: Text("تصنيف: $cat"))),
                      ],
                      onChanged: (v) => setState(() => _selectedCourseCategoryFilter = v ?? 'الكل'),
                      style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _coursesFilter,
                      items: const [
                        DropdownMenuItem(value: 'الكل', child: Text("جميع الحالات")),
                        DropdownMenuItem(value: 'منشور', child: Text("منشور فقط")),
                        DropdownMenuItem(value: 'مسودة', child: Text("مسودة فقط")),
                      ],
                      onChanged: (v) => setState(() => _coursesFilter = v ?? 'الكل'),
                      style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: () => _openCreateCourseView(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text("+ إنشاء كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Courses Cards Grid
          if (filteredCourses.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text("لا توجد كورسات مطابقة لبحثك أو التصنيف المحدد", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _openCreateCourseView(),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                      child: Text("إنشاء أول كورس الآن", style: GoogleFonts.cairo(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
                final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 20)) / crossAxisCount;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: filteredCourses.map((c) => _buildCourseCard(c, cardWidth)).toList(),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, double width) {
    final lectures = (course['lessons'] as List?) ?? [];
    final isDraft = (course['status'] ?? 'منشور') == 'مسودة';

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image & Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  color: const Color(0xFF060D1F),
                  child: SafeNetworkImage(
                    imageUrl: (course['image'] ?? course['imageUrl'] ?? '').toString(),
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDraft ? const Color(0xFF64748B) : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDraft ? "مسودة" : "منشور",
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course['level'] ?? 'جميع المستويات',
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'] ?? 'بدون عنوان',
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  course['description'] ?? '',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B), height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.video_collection_outlined, size: 16, color: Color(0xFF0284C7)),
                    const SizedBox(width: 6),
                    Text("${lectures.length} محاضرات", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(course['category'] ?? 'عام', style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _selectedCourseForLectures = course),
                        icon: const Icon(Icons.playlist_add_check_rounded, size: 16),
                        label: Text("إدارة المحاضرات", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                      tooltip: "تعديل الكورس",
                      onPressed: () => _openCreateCourseView(existing: course),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      tooltip: "حذف الكورس",
                      onPressed: () => _confirmDelete("كورس: ${course['title']}", () async {
                        await _dataService.deleteCourse(course['id']);
                        _showSnackBar("تم حذف الكورس بنجاح");
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // COURSE LECTURES VIEW (إدارة محاضرات الكورس)
  // =========================================================================
  Widget _buildCourseLecturesView(Map<String, dynamic> course) {
    final lectures = List<Map<String, dynamic>>.from(course['lessons'] ?? []);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner of the Course
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SafeNetworkImage(
                            imageUrl: (course['image'] ?? course['imageUrl'] ?? '').toString(),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title'] ?? '',
                                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                "${lectures.length} محاضرات حتى الآن",
                                style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF0369A1), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((course['description'] ?? '').toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        course['description'] ?? '',
                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF475569), height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openLectureEditorDialog(courseId: course['id']),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text("+ إضافة محاضرة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SafeNetworkImage(
                        imageUrl: (course['image'] ?? course['imageUrl'] ?? '').toString(),
                        width: 90,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['title'] ?? '',
                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            "${course['description'] ?? ''} • ${lectures.length} محاضرات حتى الآن",
                            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF0369A1)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openLectureEditorDialog(courseId: course['id']),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text("+ إضافة محاضرة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 24),

        Text("قائمة المحاضرات والدروس التابعة للكورس:", style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 12),

        if (lectures.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.video_library_outlined, size: 40, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text("لا توجد محاضرات في هذا الكورس بعد.", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _openLectureEditorDialog(courseId: course['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                    child: Text("إضافة المحاضرة الأولى", style: GoogleFonts.cairo(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lectures.length,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = lectures.removeAt(oldIndex);
              lectures.insert(newIndex, item);
              course['lessons'] = lectures;
              await _dataService.updateCourse(course['id'], course);
              setState(() {});
            },
            itemBuilder: (ctx, idx) {
              final lecture = lectures[idx];
              final isHtml = (lecture['editorType'] ?? 'visual') == 'html';

              return Container(
                key: ValueKey(lecture['id'] ?? '$idx'),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator_rounded, color: Colors.grey),
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text("${idx + 1}", style: GoogleFonts.cairo(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(lecture['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isHtml ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isHtml ? "محرر HTML 💻" : "محرر مرئي 📝",
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isHtml ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                                  ),
                                ),
                              ),
                              if (lecture['hasQuiz'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                  child: Text("اختبار مفعل 🧠", style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF15803D), fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          Text(
                            lecture['description'] ?? 'بدون وصف مختصر',
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                      padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
                      icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0284C7), size: 20),
                      tooltip: "معاينة المحاضرة",
                      onPressed: () => _previewLectureDialog(lecture),
                    ),
                    IconButton(
                      constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                      padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 20),
                      tooltip: "تعديل المحاضرة",
                      onPressed: () => _openLectureEditorDialog(courseId: course['id'], existing: lecture),
                    ),
                    IconButton(
                      constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                      padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      tooltip: "حذف المحاضرة",
                      onPressed: () => _confirmDelete("محاضرة: ${lecture['title']}", () async {
                        await _dataService.deleteLessonFromCourse(course['id'], lecture['id']);
                        setState(() {
                          final updatedCourse = _dataService.courses.firstWhere((c) => c['id'] == course['id'], orElse: () => course);
                          _selectedCourseForLectures = updatedCourse;
                        });
                        _showSnackBar("تم حذف المحاضرة بنجاح");
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // =========================================================================
  // 3. الدروس المستقلة (INDEPENDENT LESSONS 🎓)
  // =========================================================================
  String _selectedLessonsPlaylistFilter = 'الكل';

  Widget _buildPlaylistsTab() {
    final playlists = _dataService.lessonPlaylists;
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "إدارة قوائم وسلاسل المناهج والدروس (${playlists.length})",
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (playlists.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text("تأكيد مسح كافة المناهج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            content: Text("هل أنت متأكد من مسح جميع المناهج الحالية من Firebase والتطبيق لتتمكن من إنشاء منهج جديد نظيف؟", style: GoogleFonts.cairo()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("إلغاء")),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text("نعم، امسح الكل"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _dataService.clearAllLessonPlaylists();
                          setState(() {});
                          _showSnackBar("تم مسح وتنظيف كافة المناهج من Firebase بنجاح 🗑️");
                        }
                      },
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Color(0xFFEF4444)),
                      label: Text("مسح وتنظيف كافة المناهج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444), fontSize: 12)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444))),
                    ),
                  ElevatedButton.icon(
                    onPressed: () => _openCreatePlaylistView(),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text("+ إنشاء منهج جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("إدارة قوائم وسلاسل المناهج والدروس (${playlists.length})", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (playlists.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text("تأكيد مسح كافة المناهج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            content: Text("هل أنت متأكد من مسح جميع المناهج الحالية من Firebase والتطبيق لتتمكن من إنشاء منهج جديد نظيف؟", style: GoogleFonts.cairo()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("إلغاء")),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text("نعم، امسح الكل"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _dataService.clearAllLessonPlaylists();
                          setState(() {});
                          _showSnackBar("تم مسح وتنظيف كافة المناهج من Firebase بنجاح 🗑️");
                        }
                      },
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Color(0xFFEF4444)),
                      label: Text("مسح وتنظيف كافة المناهج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444), fontSize: 12)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444))),
                    ),
                  ElevatedButton.icon(
                    onPressed: () => _openCreatePlaylistView(),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text("+ إنشاء منهج جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (playlists.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Center(child: Text("لا توجد قوائم تشغيل منشأة بعد", style: GoogleFonts.cairo(color: Colors.grey))),
          )
        else
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: playlists.map((pl) {
                  final count = _dataService.lessons.where((l) => l['playlistId'] == pl['id']).length;
                  return Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.playlist_play_rounded, color: Color(0xFF0284C7), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pl['title'] ?? '', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                                  Text("$count درس بالقائمة", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if ((pl['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(pl['description'] ?? '', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                              tooltip: "تعديل",
                              onPressed: () => _openCreatePlaylistView(existing: pl),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                              tooltip: "حذف",
                              onPressed: () => _confirmDelete("قائمة: ${pl['title']}", () async {
                                await _dataService.deleteLessonPlaylist(pl['id']);
                                _showSnackBar("تم حذف قائمة التشغيل");
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLessonsSection() {
    final playlists = _dataService.lessonPlaylists;
    final lessonCats = _dataService.lessonCategories;

    final filteredLessons = _dataService.lessons.where((l) {
      final matchesSearch = (l['title'] ?? '').toString().toLowerCase().contains(_lessonsSearch.toLowerCase()) ||
          (l['description'] ?? '').toString().toLowerCase().contains(_lessonsSearch.toLowerCase());
      final matchesFilter = _lessonsFilter == 'الكل' || (l['status'] ?? 'منشور') == _lessonsFilter;
      final matchesPlaylist = _selectedLessonsPlaylistFilter == 'الكل' ||
          (l['playlistId'] ?? '') == _selectedLessonsPlaylistFilter ||
          (l['category'] ?? '') == _selectedLessonsPlaylistFilter;
      final matchesCat = _selectedLessonCategoryFilter == 'الكل' ||
          (l['category'] ?? '') == _selectedLessonCategoryFilter ||
          (l['subject'] ?? '') == _selectedLessonCategoryFilter;
      return matchesSearch && matchesFilter && matchesPlaylist && matchesCat;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Action Cards for Lessons
        _buildFourActionCards(isCourse: false),
        _buildSubTabHeader(
          tabs: [
            _SubTabItem("جميع الدروس", Icons.school_rounded, count: _dataService.lessons.length),
            _SubTabItem("تصنيفات الدروس (مستقلة)", Icons.label_important_rounded, count: _dataService.lessonCategories.length),
            _SubTabItem("قوائم التشغيل", Icons.playlist_play_rounded, count: _dataService.lessonPlaylists.length),
          ],
          selectedIndex: _lessonsSubTab,
          onTabSelected: (idx) => setState(() => _lessonsSubTab = idx),
          trailing: _lessonsSubTab == 0 && !isMobile
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openCreatePlaylistView(),
                      icon: const Icon(Icons.playlist_add_rounded, size: 16, color: Color(0xFF0284C7)),
                      label: Text("إنشاء قائمة", style: GoogleFonts.cairo(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                        backgroundColor: const Color(0xFFF0F9FF),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openCreateLessonView(),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text("+ إنشاء درس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 20),

        if (_lessonsSubTab == 1)
          _buildLessonCategoriesTab()
        else if (_lessonsSubTab == 2)
          _buildPlaylistsTab()
        else ...[
          // Search & Filters
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _lessonsSearch = val),
                  decoration: InputDecoration(
                    hintText: "بحث في الدروس...",
                    hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: (lessonCats.contains(_selectedLessonCategoryFilter) || _selectedLessonCategoryFilter == 'الكل')
                                ? _selectedLessonCategoryFilter
                                : 'الكل',
                            items: [
                              const DropdownMenuItem(value: 'الكل', child: Text("جميع التصنيفات", overflow: TextOverflow.ellipsis)),
                              ...lessonCats.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (v) => setState(() => _selectedLessonCategoryFilter = v ?? 'الكل'),
                            style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: (playlists.any((p) => p['id'] == _selectedLessonsPlaylistFilter) || _selectedLessonsPlaylistFilter == 'الكل')
                                ? _selectedLessonsPlaylistFilter
                                : 'الكل',
                            items: [
                              const DropdownMenuItem(value: 'الكل', child: Text("جميع القوائم", overflow: TextOverflow.ellipsis)),
                              ...playlists.map((p) => DropdownMenuItem(value: p['id'].toString(), child: Text(p['title'] ?? '', overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (v) => setState(() => _selectedLessonsPlaylistFilter = v ?? 'الكل'),
                            style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _lessonsFilter,
                            items: const [
                              DropdownMenuItem(value: 'الكل', child: Text("جميع الحالات", overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'منشور', child: Text("منشور", overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'مسودة', child: Text("مسودة", overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (v) => setState(() => _lessonsFilter = v ?? 'الكل'),
                            style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openCreatePlaylistView(),
                        icon: const Icon(Icons.playlist_add_rounded, size: 16, color: Color(0xFF0284C7)),
                        label: Text("إنشاء قائمة", style: GoogleFonts.cairo(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          backgroundColor: const Color(0xFFF0F9FF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openCreateLessonView(),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text("+ إنشاء درس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (val) => setState(() => _lessonsSearch = val),
                    decoration: InputDecoration(
                      hintText: "بحث في الدروس...",
                      hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Category Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (lessonCats.contains(_selectedLessonCategoryFilter) || _selectedLessonCategoryFilter == 'الكل')
                          ? _selectedLessonCategoryFilter
                          : 'الكل',
                      items: [
                        const DropdownMenuItem(value: 'الكل', child: Text("جميع تصنيفات الدروس 🏷️")),
                        ...lessonCats.map((cat) => DropdownMenuItem(value: cat, child: Text("تصنيف: $cat"))),
                      ],
                      onChanged: (v) => setState(() => _selectedLessonCategoryFilter = v ?? 'الكل'),
                      style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Playlist Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (playlists.any((p) => p['id'] == _selectedLessonsPlaylistFilter) || _selectedLessonsPlaylistFilter == 'الكل')
                          ? _selectedLessonsPlaylistFilter
                          : 'الكل',
                      items: [
                        const DropdownMenuItem(value: 'الكل', child: Text("جميع القوائم 📁")),
                        ...playlists.map((p) => DropdownMenuItem(value: p['id'].toString(), child: Text("قائمة: ${p['title']}"))),
                      ],
                      onChanged: (v) => setState(() => _selectedLessonsPlaylistFilter = v ?? 'الكل'),
                      style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _lessonsFilter,
                      items: const [
                        DropdownMenuItem(value: 'الكل', child: Text("جميع الحالات")),
                        DropdownMenuItem(value: 'منشور', child: Text("منشور فقط")),
                        DropdownMenuItem(value: 'مسودة', child: Text("مسودة فقط")),
                      ],
                      onChanged: (v) => setState(() => _lessonsFilter = v ?? 'الكل'),
                      style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          if (filteredLessons.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text("لا توجد دروس مطابقة للبحث أو التصنيف المحدد", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openCreatePlaylistView(),
                          icon: const Icon(Icons.playlist_add_rounded, size: 16),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                          label: Text("إنشاء قائمة جديدة", style: GoogleFonts.cairo()),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openCreateLessonView(),
                          icon: const Icon(Icons.post_add_rounded, size: 16),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                          label: Text("إنشاء درس جديد", style: GoogleFonts.cairo()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
                final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 20)) / crossAxisCount;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: filteredLessons.map((l) => _buildLessonCard(l, cardWidth)).toList(),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, double width) {
    final isHtml = (lesson['editorType'] ?? 'visual') == 'html';
    final isDraft = (lesson['status'] ?? 'منشور') == 'مسودة';
    final img = (lesson['image'] ?? lesson['imageUrl'] ?? '').toString();
    final cat = (lesson['category'] ?? lesson['subject'] ?? 'عام').toString();

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  img.isNotEmpty ? img : 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 150,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.school_rounded, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDraft ? const Color(0xFF64748B) : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDraft ? "مسودة" : "منشور",
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHtml ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isHtml ? "HTML 💻" : "Visual 📝",
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isHtml ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'] ?? 'بدون عنوان',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  lesson['description'] ?? '',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(cat, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF475569), fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Text(lesson['date'] ?? '2026', style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _previewLectureDialog(lesson),
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                      label: Text("معاينة", style: GoogleFonts.cairo(fontSize: 12)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                          tooltip: "تعديل الدرس",
                          onPressed: () => _openCreateLessonView(existing: lesson),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          tooltip: "حذف الدرس",
                          onPressed: () => _confirmDelete("درس: ${lesson['title']}", () async {
                            await _dataService.deleteLesson(lesson['id']);
                            _showSnackBar("تم حذف الدرس بنجاح");
                          }),
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
    );
  }

  // =========================================================================
  // 4. اختبر نفسك (INTERACTIVE QUIZZES 🧠)
  // =========================================================================
  Widget _buildQuizzesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-tabs: 1. إنشاء اختبار (HTML فقط) | 2. الأعضاء الذين أتموا الاختبار ونتيجتهم
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => _quizSubNav = 0),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _quizSubNav == 0 ? const Color(0xFF0284C7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.code_rounded, size: 18, color: _quizSubNav == 0 ? Colors.white : const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        "💻 إنشاء اختبار (HTML فقط)",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _quizSubNav == 0 ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _quizSubNav = 1),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _quizSubNav == 1 ? const Color(0xFF8B5CF6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assessment_rounded, size: 18, color: _quizSubNav == 1 ? Colors.white : const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        "📊 الأعضاء الذين أتموا الاختبار ونتيجتهم (${_dataService.quizSubmissions.length})",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _quizSubNav == 1 ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        if (_quizSubNav == 0) ...[
          // Part 1: HTML-Only Quiz Creation/Editing ("ويكون html فقط بدون عنوان ولا غيره")
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.code_rounded, color: Color(0xFF0284C7), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingQuiz == null ? "إنشاء اختبار تفاعلي جديد (HTML فقط)" : "تعديل كود اختبار HTML",
                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            "يتم إدخال كود HTML الكامل للاختبار فقط بدون أي حقول أخرى (لا عنوان ولا وصف ولا غيره). ويظهر مباشرة في قسم 'اختبر نفسك'.",
                            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveHtmlQuiz,
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: Text("حفظ ونشر الاختبار 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),

                Text("عنوان الاختبار *", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _quizTitleEditorCtrl,
                  decoration: _inputDecoration("اكتب عنوان الاختبار التفاعلي..."),
                ),
                const SizedBox(height: 18),

                Text("كود HTML للاختبار *", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _quizHtmlEditorCtrl,
                    maxLines: 14,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF38BDF8)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "<div class=\"quiz-container\">...</div>",
                      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text("المعاينة الفورية المباشرة لكود HTML:", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: _quizHtmlEditorCtrl.text.trim().isEmpty
                      ? Center(child: Text("أدخل كود HTML لمشاهدة المعاينة الحية للاختبار هنا", style: GoogleFonts.cairo(color: Colors.grey)))
                      : ArticleContentRenderer(content: _quizHtmlEditorCtrl.text, isDark: false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // List of current interactive quizzes
          Text("قائمة الاختبارات المنشورة (${_dataService.interactiveQuizzes.length}):", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dataService.interactiveQuizzes.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final q = _dataService.interactiveQuizzes[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.psychology_rounded, color: Color(0xFF8B5CF6), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q['title'] ?? 'اختبار تفاعلي HTML', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("كود HTML متكامل • تم النشر للطلاب", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _editingQuiz = q;
                          _quizTitleEditorCtrl.text = q['title'] ?? 'اختبار تفاعلي';
                          _quizHtmlEditorCtrl.text = q['htmlCode'] ?? '';
                        });
                        _showSnackBar("تم تحميل كود الاختبار في المحرر للتعديل");
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text("تعديل الكود", style: GoogleFonts.cairo(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      tooltip: "حذف الاختبار",
                      onPressed: () => _confirmDelete("اختبار: ${q['title'] ?? 'HTML'}", () async {
                        await _dataService.deleteInteractiveQuiz(q['id']);
                        _showSnackBar("تم حذف الاختبار");
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ] else ...[
          // Part 2: Table of Members who completed the test and their scores
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: _dataService.quizSubmissions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text("لا توجد نتائج مسجلة حتى الآن من الطلاب.", style: GoogleFonts.cairo(color: Colors.grey)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: [
                        DataColumn(label: Text("اسم الطالب ثلاثي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("رقم الهاتف مع كود الدولة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("الدولة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("اسم الاختبار", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("النتيجة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("الوقت والتاريخ", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("حذف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                      ],
                      rows: _dataService.quizSubmissions.map((sub) {
                        final score = sub['score'] ?? 0;
                        final total = sub['totalQuestions'] ?? 10;
                        final isPassed = score >= (total / 2);

                        return DataRow(cells: [
                          DataCell(Text(sub['studentName'] ?? 'طالب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                          DataCell(Text(sub['phone'] ?? sub['whatsapp'] ?? '—', textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontWeight: FontWeight.w600))),
                          DataCell(Text(sub['country'] ?? 'مصر', style: GoogleFonts.cairo())),
                          DataCell(Text(sub['quizTitle'] ?? 'اختبار تفاعلي HTML', style: GoogleFonts.cairo(fontSize: 12))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPassed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "$score / $total",
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  color: isPassed ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text("${sub['date'] ?? ''} ${sub['startTime'] ?? ''}", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                              onPressed: () async {
                                await _dataService.deleteQuizSubmission(sub['id']);
                                _showSnackBar("تم حذف النتيجة بنجاح");
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  void _saveHtmlQuiz() async {
    final code = _quizHtmlEditorCtrl.text.trim();
    if (code.isEmpty) {
      _showSnackBar("يرجى إدخال كود HTML للاختبار", isError: true);
      return;
    }
    final title = _quizTitleEditorCtrl.text.trim().isNotEmpty
        ? _quizTitleEditorCtrl.text.trim()
        : 'اختبار تفاعلي HTML';

    final quizData = {
      'id': _editingQuiz?['id'] ?? 'quiz_html_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'description': 'اختبار تفاعلي مباشر مبني بكود HTML',
      'category': 'عام',
      'questionsCount': 10,
      'editorType': 'html',
      'htmlCode': code,
      'status': 'منشور',
      'date': "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
    };
    if (_editingQuiz == null) {
      await _dataService.addInteractiveQuiz(quizData);
    } else {
      await _dataService.updateInteractiveQuiz(_editingQuiz!['id'], quizData);
    }
    setState(() {
      _editingQuiz = null;
    });
    _showSnackBar("تم حفظ ونشر الاختبار بنجاح 🚀");
  }

  // =========================================================================
  // 5. تحدي الأسبوع (WEEKLY CHALLENGES 🏆)
  // =========================================================================
  Widget _buildChallengesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub Navigation Tabs: Challenges vs Submissions
        Row(
          children: [
            ChoiceChip(
              label: Text("🏆 التحديات المجدولة (${_dataService.weeklyChallenges.length})", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              selected: _challengeSubNav == 0,
              onSelected: (val) => setState(() => _challengeSubNav = 0),
              selectedColor: const Color(0xFF0284C7),
              labelStyle: TextStyle(color: _challengeSubNav == 0 ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: Text("📩 حلول الطلاب المستلمة (${_dataService.challengeSubmissions.length})", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              selected: _challengeSubNav == 1,
              onSelected: (val) => setState(() => _challengeSubNav = 1),
              selectedColor: const Color(0xFF0284C7),
              labelStyle: TextStyle(color: _challengeSubNav == 1 ? Colors.white : const Color(0xFF0F172A)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (_challengeSubNav == 0) ...[
          // Scheduler Banner (Egyptian Time Info)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Color(0xFFD97706), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "نظام التحدي الأسبوعي التلقائي (توقيت مصر GMT+3)",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF92400E)),
                      ),
                      Text(
                        "يبدأ كل سبت تلقائياً، وينتهي كل خميس 11:59 م. الجمعة فترة انتقالية. يمكنك إضافة حتى 50 تحدياً وجدولتها مسبقاً!",
                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFB45309)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openCreateChallengeDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text("+ إضافة تحدٍ جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search & Filter Toolbar for Challenges
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  onChanged: (val) => setState(() => _challengesSearch = val),
                  decoration: InputDecoration(
                    hintText: "بحث في التحديات الأسبوعية...",
                    hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _challengesFilter,
                    items: const [
                      DropdownMenuItem(value: 'الكل', child: Text("جميع الحالات")),
                      DropdownMenuItem(value: 'نشط', child: Text("نشط فقط")),
                      DropdownMenuItem(value: 'مجدول', child: Text("مجدول فقط")),
                      DropdownMenuItem(value: 'منتهٍ', child: Text("منتهٍ")),
                      DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                    ],
                    onChanged: (v) => setState(() => _challengesFilter = v ?? 'الكل'),
                    style: GoogleFonts.cairo(color: const Color(0xFF0F172A), fontSize: 13),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Challenges List
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
              final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 20)) / crossAxisCount;

              final filteredChallenges = _dataService.weeklyChallenges.where((ch) {
                final matchesSearch = (ch['title'] ?? '').toString().toLowerCase().contains(_challengesSearch.toLowerCase());
                final matchesFilter = _challengesFilter == 'الكل' || (ch['status'] ?? 'نشط') == _challengesFilter;
                return matchesSearch && matchesFilter;
              }).toList();

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: filteredChallenges.map((ch) => _buildChallengeCard(ch, cardWidth)).toList(),
              );
            },
          ),
        ] else ...[
          // Submissions Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: _dataService.challengeSubmissions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text("لا توجد حلول مرسلة من الطلاب حتى الآن.", style: GoogleFonts.cairo(color: Colors.grey)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: [
                        DataColumn(label: Text("اسم الطالب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("التحدي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("البريد / واتساب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("رابط الحل / المشروع", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("ملاحظات الطالب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("الحالة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("إجراءات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                      ],
                      rows: _dataService.challengeSubmissions.map((sol) {
                        final status = sol['status'] ?? 'جديد';
                        return DataRow(cells: [
                          DataCell(Text(sol['studentName'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                          DataCell(Text(sol['challengeTitle'] ?? '', style: GoogleFonts.cairo(fontSize: 12))),
                          DataCell(Text("${sol['email'] ?? ''}\n${sol['whatsapp'] ?? ''}", textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 11))),
                          DataCell(
                            InkWell(
                              onTap: () {
                                final url = sol['projectUrl']?.toString();
                                if (url != null && url.isNotEmpty) {
                                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.link, size: 16, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 4),
                                  Text("فتح الرابط", style: GoogleFonts.cairo(color: const Color(0xFF0284C7), decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(sol['notes'] ?? '', style: GoogleFonts.cairo(fontSize: 11), maxLines: 1)),
                          DataCell(
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: ['جديد', 'قيد المراجعة', 'تمت المراجعة'].contains(status) ? status : 'جديد',
                                items: const [
                                  DropdownMenuItem(value: 'جديد', child: Text("جديد 🆕")),
                                  DropdownMenuItem(value: 'قيد المراجعة', child: Text("قيد المراجعة ⏳")),
                                  DropdownMenuItem(value: 'تمت المراجعة', child: Text("تمت المراجعة ✅")),
                                ],
                                onChanged: (newStatus) async {
                                  if (newStatus != null) {
                                    await _dataService.updateChallengeSubmissionStatus(sol['id'], newStatus);
                                    _showSnackBar("تم تحديث حالة الحل إلى $newStatus");
                                  }
                                },
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                              onPressed: () async {
                                await _dataService.deleteChallengeSubmission(sol['id']);
                                _showSnackBar("تم حذف الحل");
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, double width) {
    final status = challenge['status'] ?? 'نشط';
    final isActive = status == 'نشط';

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0), width: isActive ? 2 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  challenge['imageUrl'] ?? 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(height: 140, color: const Color(0xFFF1F5F9)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "الأسبوع ${challenge['weekNumber'] ?? 1} • $status",
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    challenge['difficulty'] ?? 'متوسط',
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge['title'] ?? '', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text(
                  challenge['problemDesc'] ?? challenge['requirements'] ?? '',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text("${challenge['startDate'] ?? ''} ➔ ${challenge['endDate'] ?? ''}", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                Row(
                  children: [
                    if (!isActive)
                      OutlinedButton(
                        onPressed: () async {
                          challenge['status'] = 'نشط';
                          await _dataService.updateWeeklyChallenge(challenge['id'], challenge);
                          _showSnackBar("تم تعيين التحدي ليكون التحدي النشط الآن على الموقع");
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("تنشيط التحدي", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFFD97706), fontWeight: FontWeight.bold)),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                      onPressed: () => _openCreateChallengeDialog(existing: challenge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      onPressed: () => _confirmDelete("تحدي: ${challenge['title']}", () async {
                        await _dataService.deleteWeeklyChallenge(challenge['id']);
                        _showSnackBar("تم حذف التحدي");
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 6. جلسات التصوير (RECORDING STUDIO 🎥)
  // =========================================================================
  Widget _buildRecordingStudioSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Studio Notice Banner (Fully Responsive for Mobile)
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.videocam_rounded, color: Color(0xFF16A34A), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "استوديو التصوير التفاعلي 🔒",
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF166534)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "تم سحب الاستوديو من الواجهة العامة وحمايته داخل لوحة الإدارة. يمكنك كتابة أكواد الشرائح وفتح السبورة التفاعلية للشرح.",
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF15803D), height: 1.6),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _openCreateRecordingSessionPrompt(),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text("+ إضافة جلسة تصوير جديدة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.videocam_rounded, color: Color(0xFF16A34A), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "استوديو التصوير التفاعلي (خاص بالأدمن فقط 🔒)",
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF166534)),
                          ),
                          Text(
                            "تم سحب الاستوديو من الواجهة العامة للموقع وحمايته داخل لوحة الإدارة. يمكنك كتابة أكواد الشرائح HTML وفتح السبورة التفاعلية للشرح.",
                            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF15803D)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openCreateRecordingSessionPrompt(),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text("+ إضافة جلسة تصوير جديدة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 28),

        Text("جلسات التصوير المحفوظة:", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 16),

        if (_dataService.recordingLessons.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text("لا توجد جلسات تصوير مسجلة بعد", style: GoogleFonts.cairo(color: Colors.grey)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dataService.recordingLessons.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final rec = _dataService.recordingLessons[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Center(child: Icon(Icons.slideshow_rounded, color: Color(0xFF16A34A), size: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(rec['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text("${rec['subject'] ?? 'جلسة تدريسية'} • تاريخ: ${rec['date'] ?? '2026'}", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final code = (rec['code'] ?? '').toString();
                                    if (code.trim().isEmpty) {
                                      _showSnackBar("كود الجلسة فارغ! يرجى النقر على أيقونة التعديل وإضافة كود الـ HTML أولاً");
                                      return;
                                    }
                                    openRecordingPresentation(code, title: rec['title']);
                                  },
                                  icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                                  label: Text("تشغيل الاستوديو 🎬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.code_rounded, color: Color(0xFF0284C7)),
                                tooltip: "تعديل كود الـ HTML للشرائح",
                                onPressed: () => _openRecordingHtmlEditor(rec),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                                tooltip: "حذف الجلسة",
                                onPressed: () => _confirmDelete("جلسة: ${rec['title']}", () async {
                                  await _dataService.deleteRecordingLesson(rec['id']);
                                  _showSnackBar("تم حذف جلسة التصوير");
                                }),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Center(child: Icon(Icons.slideshow_rounded, color: Color(0xFF16A34A), size: 24)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rec['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text("${rec['subject'] ?? 'جلسة تدريسية'} • تاريخ: ${rec['date'] ?? '2026'}", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              final code = (rec['code'] ?? '').toString();
                              if (code.trim().isEmpty) {
                                _showSnackBar("كود الجلسة فارغ! يرجى النقر على أيقونة التعديل وإضافة كود الـ HTML أولاً");
                                return;
                              }
                              openRecordingPresentation(code, title: rec['title']);
                            },
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                            label: Text("تشغيل الاستوديو 🎬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.code_rounded, color: Color(0xFF0284C7)),
                            tooltip: "تعديل كود الـ HTML للشرائح",
                            onPressed: () => _openRecordingHtmlEditor(rec),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                            tooltip: "حذف الجلسة",
                            onPressed: () => _confirmDelete("جلسة: ${rec['title']}", () async {
                              await _dataService.deleteRecordingLesson(rec['id']);
                              _showSnackBar("تم حذف جلسة التصوير");
                            }),
                          ),
                        ],
                      ),
              );
            },
          ),
      ],
    );
  }

  // =========================================================================
  // 7. الأعضاء (MEMBERS & STUDENTS 👥 — الفايربيز المباشر الحقيقي)
  // =========================================================================
  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary & Search Toolbar
        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                onChanged: (val) => setState(() => _membersSearch = val),
                decoration: InputDecoration(
                  hintText: "بحث بالاسم، البريد الإلكتروني، أو الهاتف...",
                  hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () async {
                _showSnackBar("جارٍ فحص وتنظيف كلمات المرور القديمة من قاعدة البيانات...");
                final count = await UserService.instance.sanitizeAllOldPlaintextPasswords();
                _showSnackBar("اكتمل التنظيف الأمني: تم تطهير $count مستند من أي نصوص كلمات مرور 🛡️");
              },
              icon: const Icon(Icons.cleaning_services_rounded, size: 16, color: Color(0xFF0284C7)),
              label: Text("تطهير كلمات المرور القديمة 🛡️", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done_rounded, color: Color(0xFF16A34A), size: 18),
                  const SizedBox(width: 8),
                  Text("متصل مباشرة بقاعدة بيانات Firebase", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF15803D))),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Live Firebase Firestore Stream of Members
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: UserService.instance.streamAllStudents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text("خطأ في جلب بيانات الأعضاء من Firebase: ${snapshot.error}", style: GoogleFonts.cairo(color: const Color(0xFF991B1B))),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final q = _membersSearch.trim().toLowerCase();

            final filteredDocs = docs.where((doc) {
              final data = doc.data();
              final name = (data['name'] ?? data['displayName'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();
              final phone = (data['phone'] ?? '').toString().toLowerCase();
              return q.isEmpty || name.contains(q) || email.contains(q) || phone.contains(q);
            }).toList();

            if (filteredDocs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text("لا توجد سجلات أعضاء مطابقة للبحث في Firebase", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            final totalMembers = filteredDocs.length;
            final totalPages = (totalMembers / _membersPageSize).ceil().clamp(1, 999999);
            if (_membersCurrentPage >= totalPages) {
              _membersCurrentPage = totalPages - 1;
            }
            if (_membersCurrentPage < 0) {
              _membersCurrentPage = 0;
            }
            final startIndex = _membersCurrentPage * _membersPageSize;
            final endIndex = (startIndex + _membersPageSize).clamp(0, totalMembers);
            final pageDocs = filteredDocs.sublist(startIndex, endIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 768;
                    if (isMobile) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pageDocs.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = pageDocs[index];
                          final data = doc.data();
                          final uid = doc.id;
                          final memberData = {...data, 'uid': uid};
                          final name = data['name'] ?? data['displayName'] ?? 'طالب بدون اسم';
                          final email = data['email'] ?? '—';
                          final phone = data['phone'] ?? '—';
                          final whatsapp = data['whatsapp'] ?? data['phone'] ?? '';
                          final country = data['country'] ?? 'مصر';
                          final role = (data['role'] ?? 'student').toString().toLowerCase();
                          final isAdmin = role == 'admin';
                          final allowedCourses = (data['allowedCourses'] as List?)?.length ?? 0;
                          final allowedLessons = (data['allowedLessons'] as List?)?.length ?? 0;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: (isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF0284C7)).withValues(alpha: 0.12),
                                      child: Text(
                                        name.isNotEmpty ? name[0] : 'ع',
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(email, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]), textDirection: TextDirection.ltr),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isAdmin ? "أدمن 🛡️" : "طالب 👨‍🎓",
                                        style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isAdmin ? const Color(0xFF7E22CE) : const Color(0xFF0369A1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(phone, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(country, style: GoogleFonts.cairo(fontSize: 12)),
                                      ],
                                    ),
                                    if (whatsapp.isNotEmpty)
                                      InkWell(
                                        onTap: () {
                                          final cleanNum = whatsapp.replaceAll(RegExp(r'\D'), '');
                                          launchUrl(Uri.parse('https://wa.me/$cleanNum'), mode: LaunchMode.externalApplication);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.chat_bubble_rounded, size: 13, color: Color(0xFF16A34A)),
                                            const SizedBox(width: 4),
                                            Text(whatsapp, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF15803D), fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _openMemberPermissionsDialog(memberData),
                                      icon: const Icon(Icons.vpn_key_rounded, size: 14),
                                      label: Text("صلاحيات ($allowedCourses كورس | $allowedLessons درس)", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF59E0B),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final newRole = isAdmin ? 'student' : 'admin';
                                        await UserService.instance.updateUserRole(uid, newRole);
                                        _showSnackBar(isAdmin ? "تم تحويل $name إلى رتبة طالب" : "تمت ترقية $name إلى رتبة أدمن 🛡️");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAdmin ? const Color(0xFF0284C7) : const Color(0xFF8B5CF6),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      child: Text(
                                        isAdmin ? "تحويل لطالب" : "ترقية لأدمن",
                                        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _openAdminManagePasswordDialog(
                                        uid,
                                        name,
                                        email,
                                        whatsapp.isNotEmpty ? whatsapp : phone,
                                        isAdmin,
                                      ),
                                      icon: const Icon(Icons.lock_person_rounded, size: 13),
                                      label: Text("كلمة المرور 🔐", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0284C7),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                      tooltip: "إزالة العضو",
                                      onPressed: () => _confirmDelete("عضو: $name", () async {
                                        await UserService.instance.deleteUser(uid);
                                        _showSnackBar("تمت إزالة العضو بنجاح من قاعدة البيانات");
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                          columns: [
                            DataColumn(label: Text("اسم العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("البريد الإلكتروني", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("الهاتف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("واتساب 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("الدولة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("الرتبة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("إدارة الصلاحيات 🔑", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFD97706)))),
                            DataColumn(label: Text("تغيير الرتبة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("إدارة كلمة المرور 🔐", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("إزالة العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                          ],
                          rows: pageDocs.map((doc) {
                            final data = doc.data();
                            final uid = doc.id;
                            final memberData = {...data, 'uid': uid};
                            final name = data['name'] ?? data['displayName'] ?? 'طالب بدون اسم';
                            final email = data['email'] ?? '—';
                            final phone = data['phone'] ?? '—';
                            final whatsapp = data['whatsapp'] ?? data['phone'] ?? '';
                            final country = data['country'] ?? 'مصر';
                            final role = (data['role'] ?? 'student').toString().toLowerCase();
                            final isAdmin = role == 'admin';
                            final allowedCourses = (data['allowedCourses'] as List?)?.length ?? 0;
                            final allowedLessons = (data['allowedLessons'] as List?)?.length ?? 0;

                            return DataRow(cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: (isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF0284C7)).withValues(alpha: 0.12),
                                      child: Text(
                                        name.isNotEmpty ? name[0] : 'ع',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              DataCell(Text(email, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 12))),
                              DataCell(Text(phone, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 12))),
                              DataCell(
                                whatsapp.isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          final cleanNum = whatsapp.replaceAll(RegExp(r'\D'), '');
                                          launchUrl(Uri.parse('https://wa.me/$cleanNum'), mode: LaunchMode.externalApplication);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.chat_bubble_rounded, size: 12, color: Color(0xFF16A34A)),
                                              const SizedBox(width: 4),
                                              Text(whatsapp, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF15803D), fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const Text("—"),
                              ),
                              DataCell(Text(country, style: GoogleFonts.cairo())),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isAdmin ? "أدمن 🛡️" : "طالب 👨‍🎓",
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isAdmin ? const Color(0xFF7E22CE) : const Color(0xFF0369A1),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _openMemberPermissionsDialog(memberData),
                                  icon: const Icon(Icons.vpn_key_rounded, size: 14),
                                  label: Text("صلاحيات ($allowedCourses كورس | $allowedLessons درس)", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF59E0B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () async {
                                    final newRole = isAdmin ? 'student' : 'admin';
                                    await UserService.instance.updateUserRole(uid, newRole);
                                    _showSnackBar(isAdmin ? "تم تحويل $name إلى رتبة طالب" : "تمت ترقية $name إلى رتبة أدمن 🛡️");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAdmin ? const Color(0xFF0284C7) : const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: Text(
                                    isAdmin ? "تحويل لطالب" : "ترقية لأدمن",
                                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _openAdminManagePasswordDialog(
                                    uid,
                                    name,
                                    email,
                                    whatsapp.isNotEmpty ? whatsapp : phone,
                                    isAdmin,
                                  ),
                                  icon: const Icon(Icons.lock_person_rounded, size: 13),
                                  label: Text("إدارة كلمة المرور 🔐", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                  tooltip: "إزالة العضو نهائياً من Firebase",
                                  onPressed: () => _confirmDelete("عضو: $name", () async {
                                    await UserService.instance.deleteUser(uid);
                                    _showSnackBar("تمت إزالة العضو بنجاح من قاعدة البيانات");
                                  }),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "عرض ${startIndex + 1} - $endIndex من إجمالي $totalMembers عضو",
                        style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            tooltip: "الصفحة السابقة",
                            onPressed: _membersCurrentPage > 0
                                ? () {
                                    setState(() {
                                      _membersCurrentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${_membersCurrentPage + 1} / $totalPages",
                              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            tooltip: "الصفحة التالية",
                            onPressed: _membersCurrentPage < totalPages - 1
                                ? () {
                                    setState(() {
                                      _membersCurrentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // =========================================================================
  // ADMIN PASSWORD MANAGEMENT (المرحلة الأولى: إدارة وتأمين كلمات المرور)
  // =========================================================================
  void _openAdminManagePasswordDialog(
    String uid,
    String name,
    String email,
    String phone,
    bool isTargetAdmin,
  ) {
    final currentAdminEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
    final isSuperAdmin = currentAdminEmail == 'islamatef01016834012@gmail.com';

    // حماية حسابات الإدارة: منع تغيير كلمة مرور أدمن آخر إلا للسوبر أدمن
    if (isTargetAdmin && !isSuperAdmin) {
      _showSnackBar(
        "⛔ تنبيه أمني: لا يمكن تعديل كلمة مرور حساب إداري آخر. هذه الصلاحية محصورة بحساب الإدارة الأساسي.",
        isError: true,
      );
      return;
    }

    final passwordCtrl = TextEditingController();
    bool isSaving = false;
    bool obscureText = false;
    int selectedTab = 0; // 0: Official Email Reset Link, 1: Direct Server Temporary Password

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.security_rounded, color: Color(0xFF0284C7)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("إدارة كلمة المرور وحساب الطالب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(name, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة تلخيص بيانات الطالب
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF0284C7).withOpacity(0.12),
                          child: Text(
                            name.isNotEmpty ? name[0] : 'ط',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("البريد: $email", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey)),
                              if (phone.isNotEmpty && phone != '—')
                                Text("الهاتف / واتساب: $phone", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // تبويبات الاختيار بين الرابط الرسمي والتعيين المباشر
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setDlgState(() => selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "✉️ رابط بريد رسمي (موصى به)",
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: selectedTab == 0 ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => setDlgState(() => selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "🔑 تعيين كلمة مرور مؤقتة",
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: selectedTab == 1 ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (selectedTab == 0) ...[
                    // Tab 0: Send Email Reset Link
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              Text("الطريقة الرسمية الأكثر أماناً", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.5, color: const Color(0xFF15803D))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "سيتم إرسال رابط رسمي مشفر من Google Firebase مباشرة إلى بريد الطالب ($email). يضغط عليه الطالب ليقوم بتعيين كلمة مروره الخاصة بنفسه وبأمان تام دون اطلاع أي شخص عليها.",
                            style: GoogleFonts.cairo(fontSize: 11.5, color: const Color(0xFF166534), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Tab 1: Direct Server Temporary Password
                    Row(
                      children: [
                        Text("كلمة المرور المؤقتة:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            final randomNum = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
                            passwordCtrl.text = "Eslam#$randomNum";
                            setDlgState(() {});
                          },
                          icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                          label: Text("توليد عشوائي قسري", style: GoogleFonts.cairo(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "أدخل كلمة مرور (6 خانات على الأقل)",
                        hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                        prefixIcon: const Icon(Icons.password_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setDlgState(() => obscureText = !obscureText),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        "🛡️ التزام بالأمان: يتم إرسال كلمة المرور إلى Firebase Authentication على السيرفر، ولن تُخزّن كنص صريح في Firestore مطلقاً. سيتم حذف أي كلمة مرور قديمة مسجلة للطالب.",
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF1E40AF), height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              if (selectedTab == 0)
                ElevatedButton.icon(
                  onPressed: isSaving || email.isEmpty || email == '—'
                      ? null
                      : () async {
                          setDlgState(() => isSaving = true);
                          try {
                            await UserService.instance.sendPasswordReset(email);
                            await UserService.instance.removeAdminAssignedPassword(uid);
                            if (!context.mounted) return;
                            Navigator.of(ctx).pop();
                            _showSnackBar("تم إرسال رابط تعيين كلمة المرور بنجاح إلى: $email ✉️");
                          } catch (e) {
                            setDlgState(() => isSaving = false);
                            _showSnackBar("فشل إرسال رابط إعادة التعيين: $e", isError: true);
                          }
                        },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(isSaving ? "جارٍ الإرسال..." : "إرسال الرابط للطالب ✉️", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newPass = passwordCtrl.text.trim();
                          if (newPass.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("كلمة المرور يجب أن لا تقل عن 6 خانات", style: GoogleFonts.cairo()),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDlgState(() => isSaving = true);
                          try {
                            final res = await UserService.instance.setStudentPasswordSecurely(
                              targetUid: uid,
                              newPassword: newPass,
                              targetEmail: email,
                            );

                            if (res['success'] == true) {
                              if (!context.mounted) return;
                              Navigator.of(ctx).pop();
                              _showSnackBar("تم تحديث كلمة المرور في Firebase Authentication بنجاح ✅");
                              _showPasswordCredentialsDialog(name, email, phone, newPass);
                            } else {
                              // If server credentials missing on Vercel, fallback gracefully to email reset
                              if (res['error'] == 'SERVER_CREDENTIALS_MISSING') {
                                if (email.isNotEmpty && email != '—') {
                                  await UserService.instance.sendPasswordReset(email);
                                  await UserService.instance.removeAdminAssignedPassword(uid);
                                  if (!context.mounted) return;
                                  Navigator.of(ctx).pop();
                                  _showSnackBar(
                                    "مفتاح السيرفر غير مهيأ بعد على Vercel. تم إرسال رابط استعادة رسمي فوراً إلى بريد الطالب: $email ✉️",
                                  );
                                  return;
                                }
                              }

                              setDlgState(() => isSaving = false);
                              _showSnackBar(res['message'] ?? "فشلت العملية", isError: true);
                            }
                          } catch (e) {
                            setDlgState(() => isSaving = false);
                            _showSnackBar("خطأ: $e", isError: true);
                          }
                        },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: Text(isSaving ? "جارٍ الحفظ والتعيين..." : "حفظ وتعيين في Firebase 🔑", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordCredentialsDialog(String name, String email, String phone, String password) {
    final credentialsText = "مرحباً $name،\nتم تعيين كلمة مرور مؤقتة لحسابك في منصة Eslam Atef | Code & AI:\nالبريد: $email\nكلمة المرور المؤقتة: $password\n\nيرجى تسجيل الدخول وتغيير كلمة المرور فوراً عبر:\nhttps://tef-sepia.vercel.app";

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("بيانات الدخول المؤقتة للطالب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "⚠️ لن يتم حفظ كلمة المرور في قاعدة البيانات بعد إغلاق هذه النافذة حرصاً على الأمان. يرجى نسخها الآن وتزويد الطالب بها.",
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: SelectableText(
                  credentialsText,
                  style: GoogleFonts.cairo(fontSize: 13, height: 1.6),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: credentialsText));
                _showSnackBar("تم نسخ بيانات الدخول إلى الحافظة بنجاح 📋");
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text("نسخ البيانات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
            if (phone.isNotEmpty && phone != '—')
              ElevatedButton.icon(
                onPressed: () {
                  final cleanNum = phone.replaceAll(RegExp(r'\D'), '');
                  final waUrl = Uri.parse("https://wa.me/$cleanNum?text=${Uri.encodeComponent(credentialsText)}");
                  launchUrl(waUrl, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                label: Text("إرسال عبر واتساب 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("إغلاق", style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // DIALOGS & EDITORS (المحرر المرئي ومحرر HTML)
  // =========================================================================

  // 1. Create/Edit Course Dialog
  void _openCreateCourseDialog({Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final imgCtrl = TextEditingController(text: existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600');
    final catCtrl = TextEditingController(text: existing?['category'] ?? 'مسارات البرمجة والذكاء الاصطناعي');
    String level = existing?['level'] ?? 'جميع المستويات';
    String status = existing?['status'] ?? 'منشور';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existing == null ? "إنشاء كورس / ملف جديد" : "تعديل الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogField("اسم الكورس", titleCtrl),
                  _buildDialogField("وصف الكورس المختصر", descCtrl, maxLines: 3),
                  _buildDialogField("رابط صورة الغلاف (URL)", imgCtrl),
                  _buildDialogField("التصنيف", catCtrl),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("المستوى", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: level,
                              items: const [
                                DropdownMenuItem(value: 'جميع المستويات', child: Text("جميع المستويات")),
                                DropdownMenuItem(value: 'مبتدئ', child: Text("مبتدئ")),
                                DropdownMenuItem(value: 'متوسط', child: Text("متوسط")),
                                DropdownMenuItem(value: 'متقدم', child: Text("متقدم")),
                              ],
                              onChanged: (v) => setDlgState(() => level = v ?? 'جميع المستويات'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("حالة النشر", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: status,
                              items: const [
                                DropdownMenuItem(value: 'منشور', child: Text("منشور علناً")),
                                DropdownMenuItem(value: 'مسودة', child: Text("مسودة (مخفي)")),
                              ],
                              onChanged: (v) => setDlgState(() => status = v ?? 'منشور'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final courseData = {
                  if (existing != null) 'id': existing['id'],
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'imageUrl': imgCtrl.text.trim(),
                  'category': catCtrl.text.trim(),
                  'level': level,
                  'status': status,
                  'lessons': existing?['lessons'] ?? <Map<String, dynamic>>[],
                };

                Navigator.pop(ctx);
                if (existing != null) {
                  await _dataService.updateCourse(existing['id'], courseData);
                  _showSnackBar("تم تحديث الكورس بنجاح");
                } else {
                  await _dataService.addCourse(courseData);
                  _showSnackBar("تم إنشاء الكورس بنجاح");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              child: Text("حفظ الكورس", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Lecture / Lesson Editor (Visual Editor vs HTML Editor + YouTube + Quiz)
  void _openLectureEditorDialog({required String courseId, Map<String, dynamic>? existing}) {
    _openGenericLessonEditor(
      titleText: existing == null ? "إضافة محاضرة جديدة للكورس" : "تعديل المحاضرة",
      existing: existing,
      onSave: (lessonData) async {
        if (existing != null) {
          await _dataService.updateLessonInCourse(courseId, existing['id'], lessonData);
          _showSnackBar("تم تحديث المحاضرة بنجاح");
        } else {
          await _dataService.addLessonToCourse(courseId, lessonData);
          _showSnackBar("تمت إضافة المحاضرة إلى الكورس بنجاح");
        }
        setState(() {
          _selectedCourseForLectures = _dataService.courses.firstWhere((c) => c['id'] == courseId, orElse: () => _selectedCourseForLectures!);
        });
      },
    );
  }

  void _openCreateLessonDialog({Map<String, dynamic>? existing}) {
    _openGenericLessonEditor(
      titleText: existing == null ? "إضافة درس مستقل جديد" : "تعديل الدرس المستقل",
      existing: existing,
      onSave: (lessonData) async {
        if (existing != null) {
          await _dataService.updateLesson(existing['id'], lessonData);
          _showSnackBar("تم تحديث الدرس بنجاح");
        } else {
          await _dataService.addLesson(lessonData);
          _showSnackBar("تم نشر الدرس بنجاح");
        }
      },
    );
  }

  void _openGenericLessonEditor({
    required String titleText,
    Map<String, dynamic>? existing,
    required Function(Map<String, dynamic>) onSave,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 1100,
          height: 750,
          constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 850),
          child: BloggerPostEditor(
            initialTitle: existing?['title'] ?? '',
            initialHtml: existing?['htmlCode'] ?? '',
            initialContent: existing?['content'] ?? '',
            initialCategory: existing?['category'] ?? 'عام',
            initialStatus: existing?['status'] ?? 'منشور',
            initialHasQuiz: existing?['hasQuiz'] == true,
            availableCategories: _dataService.lessonCategories,
            availablePlaylists: _dataService.lessonPlaylists,
            onCancel: () => Navigator.pop(ctx),
            onSave: (result) {
              Navigator.pop(ctx);
              final lessonData = {
                if (existing != null) 'id': existing['id'],
                ...result,
                'description': result['title'],
                'date': existing?['date'] ?? '2026-10-03',
              };
              onSave(lessonData);
            },
          ),
        ),
      ),
    );
  }

  // 3. Create / Edit Challenge Dialog
  void _openCreateChallengeDialog({Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final weekCtrl = TextEditingController(text: existing?['weekNumber']?.toString() ?? '1');
    final imgCtrl = TextEditingController(text: existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600');
    final probCtrl = TextEditingController(text: existing?['problemDesc'] ?? '');
    final reqCtrl = TextEditingController(text: existing?['requirements'] ?? '');
    final htmlCtrl = TextEditingController(text: existing?['htmlCode'] ?? '');
    String difficulty = existing?['difficulty'] ?? 'متوسط';
    String status = existing?['status'] ?? 'نشط';
    String editorType = existing?['editorType'] ?? 'visual';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existing == null ? "إضافة تحدٍ أسبوعي جديد" : "تعديل التحدي الأسبوعي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildDialogField("عنوان التحدي", titleCtrl)),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: _buildDialogField("رقم الأسبوع", weekCtrl)),
                    ],
                  ),
                  _buildDialogField("رابط صورة التحدي", imgCtrl),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("مستوى الصعوبة", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                            DropdownButtonFormField<String>(
                              value: difficulty,
                              items: const [
                                DropdownMenuItem(value: 'سهل', child: Text("سهل")),
                                DropdownMenuItem(value: 'متوسط', child: Text("متوسط")),
                                DropdownMenuItem(value: 'متقدم', child: Text("متقدم")),
                              ],
                              onChanged: (v) => setDlgState(() => difficulty = v ?? 'متوسط'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("الحالة", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                            DropdownButtonFormField<String>(
                              value: status,
                              items: const [
                                DropdownMenuItem(value: 'نشط', child: Text("نشط الآن")),
                                DropdownMenuItem(value: 'مجدول', child: Text("مجدول للأسبوع القادم")),
                                DropdownMenuItem(value: 'منتهٍ', child: Text("منتهٍ")),
                                DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                              ],
                              onChanged: (v) => setDlgState(() => status = v ?? 'نشط'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text("نوع المحرر: ", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                      Radio<String>(value: 'visual', groupValue: editorType, onChanged: (v) => setDlgState(() => editorType = v!)),
                      Text("محرر عادي", style: GoogleFonts.cairo(fontSize: 13)),
                      const SizedBox(width: 12),
                      Radio<String>(value: 'html', groupValue: editorType, onChanged: (v) => setDlgState(() => editorType = v!)),
                      Text("محرر HTML", style: GoogleFonts.cairo(fontSize: 13)),
                    ],
                  ),
                  if (editorType == 'visual') ...[
                    _buildDialogField("وصف المشكلة البرمجية", probCtrl, maxLines: 3),
                    _buildDialogField("المطلوب والشروط", reqCtrl, maxLines: 3),
                  ] else ...[
                    _buildDialogField("كود HTML الكامل للتحدي", htmlCtrl, maxLines: 6),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final challengeData = {
                  if (existing != null) 'id': existing['id'],
                  'title': titleCtrl.text.trim(),
                  'weekNumber': int.tryParse(weekCtrl.text) ?? 1,
                  'imageUrl': imgCtrl.text.trim(),
                  'difficulty': difficulty,
                  'status': status,
                  'editorType': editorType,
                  'problemDesc': probCtrl.text.trim(),
                  'requirements': reqCtrl.text.trim(),
                  'htmlCode': htmlCtrl.text.trim(),
                  'startDate': existing?['startDate'] ?? '2026-10-03',
                  'endDate': existing?['endDate'] ?? '2026-10-08',
                };

                Navigator.pop(ctx);
                if (existing != null) {
                  await _dataService.updateWeeklyChallenge(existing['id'], challengeData);
                  _showSnackBar("تم تحديث التحدي بنجاح");
                } else {
                  await _dataService.addWeeklyChallenge(challengeData);
                  _showSnackBar("تمت إضافة التحدي إلى الجدول بنجاح");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
              child: Text("حفظ التحدي", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Recording Studio: Prompt for Name FIRST, then open HTML Editor
  void _openCreateRecordingSessionPrompt() {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: "الصف الأول الثانوي | البرمجة والذكاء الاصطناعي");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("إضافة جلسة تصوير جديدة 🎥", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("أدخل بيانات الجلسة ثم تابع لكتابة أو لصق كود الـ HTML والسبورة التفاعلية:", style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              _buildDialogField("اسم الجلسة / المحاضرة", nameCtrl, hint: "مثال: المحاضرة 01: البيانات والمعلومات والمعرفة"),
              const SizedBox(height: 10),
              _buildDialogField("المادة / المسار الدراسي", subjectCtrl, hint: "مثال: الصف الأول الثانوي | البرمجة والذكاء الاصطناعي"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              _openRecordingHtmlEditor({
                'title': name,
                'subject': subjectCtrl.text.trim().isEmpty ? 'جلسة تدريسية' : subjectCtrl.text.trim(),
                'code': '',
              }, isNew: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            child: Text("متابعة لمحرر الأكواد ➔", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openRecordingHtmlEditor(Map<String, dynamic> rec, {bool isNew = false}) {
    final titleCtrl = TextEditingController(text: rec['title'] ?? '');
    final subjectCtrl = TextEditingController(text: rec['subject'] ?? 'الصف الأول الثانوي | البرمجة والذكاء الاصطناعي');
    final codeCtrl = TextEditingController(text: rec['code'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.code_rounded, color: Color(0xFF0284C7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isNew ? "إنشاء وتجهيز كود جلسة التصوير" : "تعديل كود جلسة: ${rec['title'] ?? ''}",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 850,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogField("عنوان الجلسة", titleCtrl),
                const SizedBox(height: 8),
                _buildDialogField("المادة / المسار", subjectCtrl),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("كود HTML / CSS / JS للشرائح والسبورة الذكية:", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    TextButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data != null && data.text != null && data.text!.isNotEmpty) {
                          codeCtrl.text = data.text!;
                          _showSnackBar("تم لصق الكود من الحافظة 📋");
                        }
                      },
                      icon: const Icon(Icons.paste_rounded, size: 16),
                      label: Text("لصق الكود من الحافظة", style: GoogleFonts.cairo(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: codeCtrl,
                  maxLines: 18,
                  style: GoogleFonts.firaCode(fontSize: 12, color: const Color(0xFF38BDF8)),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    hintText: "الصق كود الـ HTML التفاعلي الكامل هنا...",
                    hintStyle: GoogleFonts.firaCode(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          OutlinedButton.icon(
            onPressed: () {
              final code = codeCtrl.text;
              if (code.trim().isEmpty) {
                _showSnackBar("الكود فارغ! يرجى إدخال أو لصق كود الجلسة للمعاينة");
                return;
              }
              openRecordingPresentation(code, title: titleCtrl.text);
            },
            icon: const Icon(Icons.play_circle_outline_rounded, size: 18, color: Color(0xFF0284C7)),
            label: Text("تشغيل ومعاينة مباشرة 🎬", style: GoogleFonts.cairo(color: const Color(0xFF0284C7), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) {
                _showSnackBar("يرجى كتابة عنوان الجلسة أولاً");
                return;
              }
              Navigator.pop(ctx);
              rec['title'] = title;
              rec['subject'] = subjectCtrl.text.trim().isEmpty ? 'جلسة تدريسية' : subjectCtrl.text.trim();
              rec['code'] = codeCtrl.text;
              if (isNew) {
                await _dataService.addRecordingLesson(rec);
                _showSnackBar("تمت إضافة جلسة التصوير وحفظها في الفايربيز بنجاح ☁️");
              } else {
                await _dataService.updateRecordingLesson(rec['id'], rec);
                _showSnackBar("تم تحديث جلسة التصوير في الفايربيز بنجاح ☁️");
              }
            },
            icon: const Icon(Icons.cloud_upload_rounded, size: 18, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            label: Text("حفظ في الفايربيز 💾", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. Interactive Quiz Editor Dialog
  void _openQuizEditorDialog({Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final catCtrl = TextEditingController(text: existing?['category'] ?? 'ثانوي وعام');
    final qCountCtrl = TextEditingController(text: existing?['questionsCount']?.toString() ?? '10');
    final htmlCtrl = TextEditingController(text: existing?['htmlCode'] ?? '<div class="quiz-box">...</div>');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existing == null ? "إنشاء اختبار تفاعلي جديد" : "تعديل الاختبار", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogField("اسم الاختبار", titleCtrl),
                _buildDialogField("الوصف المختصر", descCtrl),
                Row(
                  children: [
                    Expanded(child: _buildDialogField("الفئة المستهدفة", catCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDialogField("عدد الأسئلة", qCountCtrl)),
                  ],
                ),
                _buildDialogField("كود HTML التفاعلي للاختبار (اختياري)", htmlCtrl, maxLines: 6),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final quizData = {
                if (existing != null) 'id': existing['id'],
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'category': catCtrl.text.trim(),
                'questionsCount': int.tryParse(qCountCtrl.text) ?? 10,
                'htmlCode': htmlCtrl.text.trim(),
                'status': 'منشور',
                'date': existing?['date'] ?? '2026-10-02',
              };

              Navigator.pop(ctx);
              if (existing != null) {
                await _dataService.updateInteractiveQuiz(existing['id'], quizData);
                _showSnackBar("تم تحديث الاختبار");
              } else {
                await _dataService.addInteractiveQuiz(quizData);
                _showSnackBar("تم إنشاء الاختبار بنجاح");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: Text("حفظ الاختبار", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 6. View Quiz Results Dialog
  void _viewQuizResultsDialog(Map<String, dynamic> quiz) {
    final submissions = _dataService.quizSubmissions.where((s) => s['quizId'] == quiz['id']).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("نتائج: ${quiz['title']}", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 700,
          height: 400,
          child: submissions.isEmpty
              ? Center(child: Text("لا توجد مشاركات مسجلة لهذا الاختبار بعد.", style: GoogleFonts.cairo(color: Colors.grey)))
              : ListView.separated(
                  itemCount: submissions.length,
                  separatorBuilder: (ctx, i) => const Divider(color: Color(0xFFF1F5F9)),
                  itemBuilder: (ctx, i) {
                    final sub = submissions[i];
                    return ListTile(
                      title: Text(sub['studentName'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      subtitle: Text("الهاتف: ${sub['phone']} • الدولة: ${sub['country']} • الوقت: ${sub['startTime']}", style: GoogleFonts.cairo(fontSize: 11)),
                      trailing: Text(
                        "النتيجة: ${sub['score']} / ${sub['totalQuestions']}",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF16A34A), fontSize: 14),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق")),
        ],
      ),
    );
  }

  // 7. Member Details Dialog
  void _viewMemberDetailsDialog(Map<String, dynamic> member) {
    final memberSubmissions = _dataService.quizSubmissions.where((s) => s['phone'] == member['phone']).toList();
    final memberChallenges = _dataService.challengeSubmissions.where((c) => c['email'] == member['email']).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("ملف العضو: ${member['name']}", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("البريد الإلكتروني:", member['email'] ?? ''),
                _buildInfoRow("رقم الهاتف:", member['phone'] ?? ''),
                _buildInfoRow("الدولة:", member['country'] ?? 'مصر'),
                _buildInfoRow("تاريخ التسجيل:", member['registeredDate'] ?? ''),
                _buildInfoRow("حالة الحساب:", member['status'] ?? 'نشط'),
                const Divider(height: 24),
                Text("الاختبارات التي خاضها (${memberSubmissions.length}):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                if (memberSubmissions.isEmpty)
                  Text("لم يقم بإجراء اختبارات بعد", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11))
                else
                  ...memberSubmissions.map((s) => Text("• ${s['quizTitle']}: النتيجة ${s['score']}/${s['totalQuestions']} (${s['date']})", style: GoogleFonts.cairo(fontSize: 12))),
                const Divider(height: 24),
                Text("التحديات البرمجية المرسلة (${memberChallenges.length}):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                if (memberChallenges.isEmpty)
                  Text("لم يرسل حلول تحديات بعد", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11))
                else
                  ...memberChallenges.map((c) => Text("• ${c['challengeTitle']} - الحالة: ${c['status']}", style: GoogleFonts.cairo(fontSize: 12))),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق")),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // 8. Add Member Dialog
  void _openAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: 'مصر');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("إضافة عضو / طالب جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField("الاسم بالكامل", nameCtrl),
              _buildDialogField("البريد الإلكتروني", emailCtrl),
              _buildDialogField("رقم الهاتف", phoneCtrl),
              _buildDialogField("الدولة", countryCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _dataService.addMember({
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'country': countryCtrl.text.trim(),
                'registeredDate': '2026-10-02',
                'status': 'نشط',
                'quizzesCount': 0,
                'challengesCount': 0,
                'lastActive': 'الآن',
                'role': 'student',
              });
              _showSnackBar("تمت إضافة العضو بنجاح");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            child: Text("إضافة", style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 9. Preview Lecture Dialog
  void _previewLectureDialog(Map<String, dynamic> lecture) {
    final youtubeUrl = (lecture['youtubeUrl'] ?? lecture['videoUrl'] ?? '').toString().trim();
    final html = (lecture['htmlCode'] ?? '').toString().trim();
    final text = (lecture['content'] ?? '').toString().trim();
    final activeContent = html.isNotEmpty ? html : text;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("معاينة: ${lecture['title']}", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 850,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (youtubeUrl.isNotEmpty && youtubeUrl.length > 5) ...[
                  YouTubeEmbeddedPlayer(youtubeUrl: youtubeUrl, height: 280),
                  const SizedBox(height: 16),
                ],
                ArticleContentRenderer(content: activeContent, isDark: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق")),
        ],
      ),
    );
  }

  // Helper: Confirmation Dialog
  void _confirmDelete(String itemDescription, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("تأكيد الحذف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
        content: Text("هل أنت متأكد من رغبتك في حذف $itemDescription نهائياً؟ لا يمكن التراجع عن هذا الإجراء.", style: GoogleFonts.cairo(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: Text("نعم، احذف", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Helper: Dialog Field
  Widget _buildDialogField(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }
}
