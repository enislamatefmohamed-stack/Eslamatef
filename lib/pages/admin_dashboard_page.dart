// ignore_for_file: deprecated_member_use, unused_element
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/site_data_service.dart';
import '../services/user_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/youtube_embedded_player.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _dataService = SiteDataService.instance;

  // 0: الرئيسية (Dashboard Home)
  // 1: الكورسات (Courses)
  // 2: الدروس (Independent Lessons)
  // 3: اختبر نفسك (Interactive Quizzes)
  // 4: تحدي الأسبوع (Weekly Challenges)
  // 5: جلسات التصوير (Recording Studio)
  // 6: الأعضاء (Members)
  int _selectedNavIndex = 0;
  bool _isSidebarCollapsed = false;

  // Search & Filter state
  String _coursesSearch = '';
  String _coursesFilter = 'الكل'; // الكل, منشور, مسودة

  String _lessonsSearch = '';
  String _lessonsFilter = 'الكل';

  int _quizSubNav = 0; // 0: محرر كود الاختبار (HTML فقط), 1: نتائج الطلاب
  final _quizHtmlEditorCtrl = TextEditingController();
  Map<String, dynamic>? _editingQuiz;

  String _challengesSearch = '';
  String _challengesFilter = 'الكل'; // الكل, نشط, مجدول, منتهٍ, مسودة
  int _challengeSubNav = 0; // 0: التحديات, 1: حلول الطلاب

  String _membersSearch = '';

  // Managing Course Lectures sub-state
  Map<String, dynamic>? _selectedCourseForLectures;

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
  final _courseTitleCtrl = TextEditingController();
  final _courseDescCtrl = TextEditingController();
  final _courseImgCtrl = TextEditingController();
  final _courseCatCtrl = TextEditingController();
  final _courseHtmlCtrl = TextEditingController();
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
    _courseImgCtrl.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  "لوحة تحكم Eslam Atef | Code & AI — بيئة إدارة المحتوى المباشرة",
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
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

  // --- Course Workspace Methods ---
  void _openCreateCourseView({Map<String, dynamic>? existing}) {
    _editingCourse = existing;
    _isCreatingCourse = true;
    _isCourseHtmlMode = (existing?['editorType'] ?? 'visual') == 'html';
    _courseTitleCtrl.text = existing?['title'] ?? '';
    _courseDescCtrl.text = existing?['description'] ?? '';
    _courseImgCtrl.text = existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600';
    _courseCatCtrl.text = existing?['category'] ?? 'مسارات البرمجة والذكاء الاصطناعي';
    _courseHtmlCtrl.text = existing?['htmlCode'] ?? '';
    _selectedCourseLevel = existing?['level'] ?? 'جميع المستويات';
    _selectedCourseStatus = existing?['status'] ?? 'منشور';
    setState(() {});
  }

  Widget _buildCourseFullPageEditor() {
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
          const Divider(height: 36, color: Color(0xFFE2E8F0)),

          if (!_isCourseHtmlMode) ...[
            _buildEditorField("عنوان الكورس *", _courseTitleCtrl, "مثال: مسار الذكاء الاصطناعي وبايثون المتقدم"),
            const SizedBox(height: 16),
            _buildEditorField("وصف الكورس *", _courseDescCtrl, "اكتب وصفاً مفصلاً ومحفزاً للطلاب...", maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildEditorField("رابط صورة الغلاف (URL) *", _courseImgCtrl, "https://...")),
                const SizedBox(width: 16),
                Expanded(child: _buildEditorField("التصنيف أو المسار *", _courseCatCtrl, "مسارات البرمجة")),
              ],
            ),
            const SizedBox(height: 16),
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
          ] else ...[
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
                        Text("محرر HTML المباشر للكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                        Text("في وضع HTML تم إخفاء العنوان والوصف والصورة، ويتم عرض المحتوى كصفحة ويب متكاملة مباشرة.", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF7C3AED))),
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
    if (_isCourseHtmlMode) {
      if (_courseHtmlCtrl.text.trim().isEmpty) {
        _showSnackBar("يرجى كتابة كود HTML للكورس", isError: true);
        return;
      }
      final courseData = {
        'title': _editingCourse?['title'] ?? 'كورس تفاعلي HTML',
        'description': 'كورس مبني بكود HTML متكامل',
        'imageUrl': _editingCourse?['imageUrl'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
        'category': 'مسارات البرمجة',
        'level': 'جميع المستويات',
        'status': _selectedCourseStatus,
        'editorType': 'html',
        'htmlCode': _courseHtmlCtrl.text.trim(),
        'lessons': _editingCourse?['lessons'] ?? <Map<String, dynamic>>[],
      };
      if (_editingCourse == null) {
        await _dataService.addCourse(courseData);
      } else {
        await _dataService.updateCourse(_editingCourse!['id'], courseData);
      }
    } else {
      if (_courseTitleCtrl.text.trim().isEmpty) {
        _showSnackBar("يرجى إدخال عنوان الكورس", isError: true);
        return;
      }
      final courseData = {
        'title': _courseTitleCtrl.text.trim(),
        'description': _courseDescCtrl.text.trim(),
        'imageUrl': _courseImgCtrl.text.trim(),
        'category': _courseCatCtrl.text.trim(),
        'level': _selectedCourseLevel,
        'status': _selectedCourseStatus,
        'editorType': 'visual',
        'htmlCode': '',
        'lessons': _editingCourse?['lessons'] ?? <Map<String, dynamic>>[],
      };
      if (_editingCourse == null) {
        await _dataService.addCourse(courseData);
      } else {
        await _dataService.updateCourse(_editingCourse!['id'], courseData);
      }
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
    _lessonImgCtrl.text = existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600';
    _lessonVideoCtrl.text = existing?['videoUrl'] ?? '';
    _lessonContentCtrl.text = existing?['content'] ?? '';
    _lessonHtmlCtrl.text = existing?['htmlCode'] ?? '';
    final playlists = _dataService.lessonPlaylists;
    _selectedLessonPlaylistId = existing?['playlistId'] ?? (playlists.isNotEmpty ? (playlists.first['id'] ?? '') : '');
    _selectedLessonStatus = existing?['status'] ?? 'منشور';
    setState(() {});
  }

  Widget _buildLessonFullPageEditor() {
    final playlists = _dataService.lessonPlaylists;

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
                      _editingLesson == null ? "إنشاء درس جديد" : "تعديل الدرس",
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      _isLessonHtmlMode ? "وضع محرر HTML التفاعلي المباشر" : "وضع الإدخال العادي (عنوان، وصف، صورة، فيديو، نص)",
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
                          "📝 إدخال عادي",
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

          // Mandatory Playlist Selector: "القائمه داخلها مجموعه دروس الدرس لازم احدد ليه قائمه"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("اختر القائمة التابع لها هذا الدرس * (إلزامي)", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7))),
              const SizedBox(height: 6),
              if (playlists.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Text("لا توجد قوائم منشأة بعد. يرجى الضغط على زر 'إنشاء قائمة' أولاً.", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFB91C1C))),
                    ],
                  ),
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
          const SizedBox(height: 20),

          if (!_isLessonHtmlMode) ...[
            // Normal Inputs: العنوان، الوصف، الصوره، لينك الفديو، المحتوي كتابه
            _buildEditorField("عنوان الدرس *", _lessonTitleCtrl, "مثال: الدرس 01: مقدمة في بنية البيانات والمصفوفات"),
            const SizedBox(height: 16),
            _buildEditorField("وصف الدرس *", _lessonDescCtrl, "اكتب نبذة مختصرة عن أهداف الدرس...", maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildEditorField("رابط صورة الدرس (URL) *", _lessonImgCtrl, "https://...")),
                const SizedBox(width: 16),
                Expanded(child: _buildEditorField("رابط فيديو يوتيوب (Video URL)", _lessonVideoCtrl, "https://www.youtube.com/watch?v=...")),
              ],
            ),
            const SizedBox(height: 16),
            _buildEditorField("المحتوى كتابة (نص الدرس والشرح) *", _lessonContentCtrl, "اكتب محتوى الدرس بالتفصيل...", maxLines: 8),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("حالة الدرس", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedLessonStatus,
                  decoration: _inputDecoration("اختر الحالة"),
                  items: const [
                    DropdownMenuItem(value: 'منشور', child: Text("منشور (متاح للطلاب)")),
                    DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                  ],
                  onChanged: (v) => setState(() => _selectedLessonStatus = v ?? 'منشور'),
                ),
              ],
            ),
          ] else ...[
            // HTML Mode: As requested: "لو اخترت html يبقي مفيش كل ده لا وصف ولا عنوان ولا رابط فديو ولا صوره تمام"
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
                        Text("محرر HTML المباشر للدرس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                        Text("في وضع HTML تم إخفاء العنوان والوصف والصورة والفيديو، وسيتم عرض صفحة الويب المباشرة داخل الدرس.", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF7C3AED))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("كود HTML الكامل للدرس *", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
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
    final playlists = _dataService.lessonPlaylists;
    if (_selectedLessonPlaylistId.isEmpty && playlists.isNotEmpty) {
      _selectedLessonPlaylistId = playlists.first['id'];
    }
    if (_selectedLessonPlaylistId.isEmpty) {
      _showSnackBar("يرجى اختيار قائمة تابعة للدرس أولاً، أو إنشاء قائمة جديدة", isError: true);
      return;
    }
    final selectedPl = playlists.firstWhere(
      (p) => p['id'] == _selectedLessonPlaylistId,
      orElse: () => {'title': 'عام'},
    );
    final playlistTitle = selectedPl['title'] ?? 'عام';

    if (_isLessonHtmlMode) {
      if (_lessonHtmlCtrl.text.trim().isEmpty) {
        _showSnackBar("يرجى إدخال كود HTML للدرس", isError: true);
        return;
      }
      final lessonData = {
        'title': _editingLesson?['title'] ?? 'درس تفاعلي HTML ($playlistTitle)',
        'description': 'درس تفاعلي مباشر بكود HTML',
        'imageUrl': _editingLesson?['imageUrl'] ?? 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600',
        'videoUrl': '',
        'content': '',
        'category': playlistTitle,
        'playlistId': _selectedLessonPlaylistId,
        'playlistTitle': playlistTitle,
        'status': _selectedLessonStatus,
        'editorType': 'html',
        'htmlCode': _lessonHtmlCtrl.text.trim(),
      };
      if (_editingLesson == null) {
        await _dataService.addLesson(lessonData);
      } else {
        await _dataService.updateLesson(_editingLesson!['id'], lessonData);
      }
    } else {
      if (_lessonTitleCtrl.text.trim().isEmpty) {
        _showSnackBar("يرجى إدخال عنوان الدرس", isError: true);
        return;
      }
      final lessonData = {
        'title': _lessonTitleCtrl.text.trim(),
        'description': _lessonDescCtrl.text.trim(),
        'imageUrl': _lessonImgCtrl.text.trim(),
        'videoUrl': _lessonVideoCtrl.text.trim(),
        'content': _lessonContentCtrl.text.trim(),
        'category': playlistTitle,
        'playlistId': _selectedLessonPlaylistId,
        'playlistTitle': playlistTitle,
        'status': _selectedLessonStatus,
        'editorType': 'visual',
        'htmlCode': '',
      };
      if (_editingLesson == null) {
        await _dataService.addLesson(lessonData);
      } else {
        await _dataService.updateLesson(_editingLesson!['id'], lessonData);
      }
    }
    setState(() {
      _isCreatingLesson = false;
      _editingLesson = null;
    });
    _showSnackBar("تم حفظ الدرس بنجاح");
  }

  // =========================================================================
  // 2. الكورسات (COURSES 📚)
  // =========================================================================
  Widget _buildCoursesSection() {
    final filteredCourses = _dataService.courses.where((c) {
      final matchesSearch = (c['title'] ?? '').toString().toLowerCase().contains(_coursesSearch.toLowerCase()) ||
          (c['description'] ?? '').toString().toLowerCase().contains(_coursesSearch.toLowerCase());
      final matchesFilter = _coursesFilter == 'الكل' || (c['status'] ?? 'منشور') == _coursesFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Toolbar: Search + Filter + Add Button
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
            const SizedBox(width: 16),
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
                  Text("لا توجد كورسات مطابقة لبحثك", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
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
                child: Image.network(
                  course['imageUrl'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 160,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.school_rounded, color: Colors.grey, size: 48),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner of the Course
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course['imageUrl'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
                  width: 90,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(width: 90, height: 70, color: Colors.grey),
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
                          Row(
                            children: [
                              Text(lecture['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
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
                              if (lecture['hasQuiz'] == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                  child: Text("اختبار مفعل 🧠", style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF15803D), fontWeight: FontWeight.bold)),
                                ),
                              ],
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
                      icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0284C7)),
                      tooltip: "معاينة المحاضرة",
                      onPressed: () => _previewLectureDialog(lecture),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                      tooltip: "تعديل المحاضرة",
                      onPressed: () => _openLectureEditorDialog(courseId: course['id'], existing: lecture),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
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

  Widget _buildLessonsSection() {
    final playlists = _dataService.lessonPlaylists;
    final filteredLessons = _dataService.lessons.where((l) {
      final matchesSearch = (l['title'] ?? '').toString().toLowerCase().contains(_lessonsSearch.toLowerCase()) ||
          (l['description'] ?? '').toString().toLowerCase().contains(_lessonsSearch.toLowerCase());
      final matchesFilter = _lessonsFilter == 'الكل' || (l['status'] ?? 'منشور') == _lessonsFilter;
      final matchesPlaylist = _selectedLessonsPlaylistFilter == 'الكل' ||
          (l['playlistId'] ?? '') == _selectedLessonsPlaylistFilter ||
          (l['category'] ?? '') == _selectedLessonsPlaylistFilter;
      return matchesSearch && matchesFilter && matchesPlaylist;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                onChanged: (val) => setState(() => _lessonsSearch = val),
                decoration: InputDecoration(
                  hintText: "بحث في الدروس والقوائم...",
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
            const SizedBox(width: 14),
            // Button 1: إنشاء قائمة
            ElevatedButton.icon(
              onPressed: () => _openCreatePlaylistView(),
              icon: const Icon(Icons.playlist_add_rounded, size: 18),
              label: Text("إنشاء قائمة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 10),
            // Button 2: إنشاء درس
            ElevatedButton.icon(
              onPressed: () => _openCreateLessonView(),
              icon: const Icon(Icons.post_add_rounded, size: 18),
              label: Text("إنشاء درس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  Text("لا توجد دروس مطابقة للبحث أو القائمة المختارة", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
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
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, double width) {
    final isHtml = (lesson['editorType'] ?? 'visual') == 'html';
    final isDraft = (lesson['status'] ?? 'منشور') == 'مسودة';

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
                  lesson['imageUrl'] ?? 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600',
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
                    Text(lesson['category'] ?? 'عام', style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8))),
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
    final quizData = {
      'id': _editingQuiz?['id'] ?? 'quiz_html_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'اختبار تفاعلي HTML',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Studio Notice Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
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
                child: Row(
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
                        // Launch live interactive presentation studio in presentation/index.html
                        final studioUrl = Uri.parse("presentation/index.html");
                        launchUrl(studioUrl, mode: LaunchMode.platformDefault);
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

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                    DataColumn(label: Text("الرتبة / الصلاحية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("الدولة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("تغيير الرتبة (أدمن / طالب)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("تغيير الرقم السري", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("إزالة العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredDocs.map((doc) {
                    final data = doc.data();
                    final uid = doc.id;
                    final name = data['name'] ?? data['displayName'] ?? 'طالب بدون اسم';
                    final email = data['email'] ?? '—';
                    final phone = data['phone'] ?? '—';
                    final country = data['country'] ?? 'مصر';
                    final role = (data['role'] ?? 'student').toString().toLowerCase();
                    final isAdmin = role == 'admin';

                    return DataRow(cells: [
                      // Name + Avatar
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: (isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF0284C7)).withOpacity(0.12),
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
                      // Email
                      DataCell(Text(email, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 12))),
                      // Phone
                      DataCell(Text(phone, textDirection: TextDirection.ltr, style: GoogleFonts.cairo(fontSize: 12))),
                      // Role Badge
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
                      // Country
                      DataCell(Text(country, style: GoogleFonts.cairo())),
                      // Action 1: Role Toggle (من طالب إلى أدمن أو العكس)
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
                      // Action 2: Password Reset Link
                      DataCell(
                        OutlinedButton.icon(
                          onPressed: email.isEmpty || email == '—'
                              ? null
                              : () async {
                                  try {
                                    await UserService.instance.sendPasswordReset(email);
                                    _showSnackBar("تم إرسال رابط تعيين كلمة المرور بنجاح إلى: $email");
                                  } catch (e) {
                                    _showSnackBar("فشل إرسال رابط كلمة المرور: $e", isError: true);
                                  }
                                },
                          icon: const Icon(Icons.lock_reset_rounded, size: 14, color: Color(0xFF0284C7)),
                          label: Text("إرسال رابط", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF0284C7))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBAE6FD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      // Action 3: Delete Member from Firebase
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
      ],
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
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final ytCtrl = TextEditingController(text: existing?['youtubeUrl'] ?? '');
    final imgCtrl = TextEditingController(text: existing?['imageUrl'] ?? 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600');
    final catCtrl = TextEditingController(text: existing?['category'] ?? 'عام');

    // Visual Content vs HTML
    String editorType = existing?['editorType'] ?? 'visual'; // visual, html
    final visualContentCtrl = TextEditingController(text: existing?['content'] ?? '');
    final htmlCodeCtrl = TextEditingController(
      text: existing?['htmlCode'] ??
          '''<article class="lecture-content">
  <h2>مقدمة في الدرس</h2>
  <p>اكتب هنا شرح المحاضرة بالتفصيل مع إمكانية إضافة وسوم HTML كاملة.</p>
  <pre><code>print("Hello Eslam Atef Code & AI")</code></pre>
</article>''',
    );

    // Quiz button options
    bool hasQuiz = existing?['hasQuiz'] ?? false;
    final quizTitleCtrl = TextEditingController(text: existing?['quizTitle'] ?? 'ابدأ اختبار فهم الدرس 🧠');
    final quizQCtrl = TextEditingController(text: existing?['quizQuestion'] ?? 'ما هي المخرجات الأساسية للكود المعروض؟');
    final quizOpt1Ctrl = TextEditingController(text: existing?['quizOpt1'] ?? 'خطأ في التنفيذ');
    final quizOpt2Ctrl = TextEditingController(text: existing?['quizOpt2'] ?? 'طباعة النص بنجاح');
    String status = existing?['status'] ?? 'منشور';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(titleText, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              // Choice Tabs: Visual Editor vs HTML Editor
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'visual', label: Text("📝 محرر مرئي"), icon: Icon(Icons.edit_note_rounded)),
                  ButtonSegment(value: 'html', label: Text("💻 كود HTML"), icon: Icon(Icons.code_rounded)),
                ],
                selected: {editorType},
                onSelectionChanged: (set) => setDlgState(() => editorType = set.first),
              ),
            ],
          ),
          content: SizedBox(
            width: 780,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogField("عنوان الدرس / المحاضرة", titleCtrl),
                  _buildDialogField("وصف مختصر", descCtrl),
                  _buildDialogField("رابط فيديو يوتيوب (يشتغل مباشرة داخل الموقع)", ytCtrl, hint: "https://www.youtube.com/watch?v=... أو معرف الفيديو"),
                  _buildDialogField("رابط صورة الغلاف المصغرة (Thumbnail)", imgCtrl),

                  const SizedBox(height: 8),

                  // Editor Area
                  if (editorType == 'visual') ...[
                    Text("محتوى الدرس (شرح، مقالات، وتوضيحات برمجية):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: visualContentCtrl,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "اكتب تفاصيل وشرح الدرس هنا بأسلوب سهل ومنظم...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("محرر أكواد HTML الكامل (يدعم جميع وسوم وتنسيقات HTML):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: ctx,
                              builder: (c) => AlertDialog(
                                title: Text("معاينة كود HTML", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                content: SizedBox(
                                  width: 600,
                                  height: 400,
                                  child: SingleChildScrollView(
                                    child: ArticleContentRenderer(content: htmlCodeCtrl.text, isDark: false),
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c), child: const Text("إغلاق")),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.preview_rounded, size: 16),
                          label: Text("معاينة الكود", style: GoogleFonts.cairo(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: htmlCodeCtrl,
                      maxLines: 10,
                      style: GoogleFonts.firaCode(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "<div class='content'>...</div>",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Quiz Button Options
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("تفعيل زر اختبار تفاعلي في نهاية الدرس 🧠", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text("يسمح للطلاب باختبار فهمهم للدرس والحصول على تغذية راجعة فورية.", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                    value: hasQuiz,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setDlgState(() => hasQuiz = val),
                  ),

                  if (hasQuiz) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
                      child: Column(
                        children: [
                          _buildDialogField("نص زر الاختبار", quizTitleCtrl),
                          _buildDialogField("السؤال", quizQCtrl),
                          Row(
                            children: [
                              Expanded(child: _buildDialogField("الخيار 1", quizOpt1Ctrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildDialogField("الخيار 2 (الإجابة الصحيحة)", quizOpt2Ctrl)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text("حالة النشر: ", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: status,
                        items: const [
                          DropdownMenuItem(value: 'منشور', child: Text("منشور")),
                          DropdownMenuItem(value: 'مسودة', child: Text("مسودة")),
                        ],
                        onChanged: (v) => setDlgState(() => status = v ?? 'منشور'),
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
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final lessonData = {
                  if (existing != null) 'id': existing['id'],
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'youtubeUrl': ytCtrl.text.trim(),
                  'imageUrl': imgCtrl.text.trim(),
                  'category': catCtrl.text.trim(),
                  'editorType': editorType,
                  'content': visualContentCtrl.text.trim(),
                  'htmlCode': htmlCodeCtrl.text.trim(),
                  'hasQuiz': hasQuiz,
                  'quizTitle': quizTitleCtrl.text.trim(),
                  'quizQuestion': quizQCtrl.text.trim(),
                  'quizOpt1': quizOpt1Ctrl.text.trim(),
                  'quizOpt2': quizOpt2Ctrl.text.trim(),
                  'status': status,
                  'date': existing?['date'] ?? '2026-10-02',
                };
                onSave(lessonData);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              child: Text("حفظ الدرس", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("اسم جلسة التصوير الجديدة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("يرجى إدخال اسم الدرس / الجلسة أولاً للمتابعة:", style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildDialogField("اسم الجلسة", nameCtrl, hint: "مثال: الدرس 02: الجمل الشرطية والحلقات التكرارية"),
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
                'code': '''<!-- قالب شرائح التصوير التفاعلية لـ Eslam Atef -->
<section class="slide">
  <header class="slide-header">
    <div class="brand">⚡ KMT AI — Eslam Atef</div>
    <div class="slide-meta">$name</div>
  </header>
  <div class="slide-title-area">
    <div class="slide-tag">المفاهيم الأساسية</div>
    <h2 class="slide-main-title">$name</h2>
    <p class="slide-subtitle">شرح تطبيقي وعملي مع كتابة الأكواد على السبورة الذكية</p>
  </div>
  <div class="slide-body">
    <div class="card-grid grid-cols-2">
      <div class="tech-card">
        <div class="card-title">المفهوم الأول</div>
        <div class="card-desc">اكتب تفاصيل النقطة الأولى هنا للشرح</div>
      </div>
      <div class="tech-card">
        <div class="card-title">المفهوم الثاني</div>
        <div class="card-desc">اكتب تفاصيل النقطة الثانية هنا للشرح</div>
      </div>
    </div>
  </div>
</section>''',
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
    final codeCtrl = TextEditingController(text: rec['code'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("محرر شرائح HTML: ${rec['title']}", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("الصق أو اكتب كود HTML لشرائح العرض التقديمي. يدعم فئات .slide و .tech-card و .brand:", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  maxLines: 15,
                  style: GoogleFonts.firaCode(fontSize: 13),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              rec['code'] = codeCtrl.text;
              if (isNew) {
                await _dataService.addRecordingLesson(rec);
                _showSnackBar("تمت إضافة جلسة التصوير بنجاح");
              } else {
                await _dataService.updateRecordingLesson(rec['id'], rec);
                _showSnackBar("تم حفظ كود الجلسة بنجاح");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: Text("حفظ الجلسة", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("معاينة: ${lecture['title']}", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 700,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((lecture['youtubeUrl'] ?? '').toString().isNotEmpty) ...[
                  YouTubeEmbeddedPlayer(youtubeUrl: lecture['youtubeUrl'], height: 260),
                  const SizedBox(height: 16),
                ],
                ArticleContentRenderer(content: (lecture['editorType'] == 'html') ? (lecture['htmlCode'] ?? '') : (lecture['content'] ?? ''), isDark: false),
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
