// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/site_data_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/youtube_embedded_player.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _dataService = SiteDataService.instance;

  // 0: Dashboard (الرئيسية - نمط ووردبريس الكلاسيكي)
  // 1: Courses & Folders (ملفات الكورسات والمسارات)
  // 2: Inside Course Folder (إدارة الدروس والفيديوهات داخل كورس محدد)
  // 3: Recording Studio (استوديو التصوير)
  // 4: Latest News (شريط جديدنا)
  // 5: Weekly Challenge (تحدي الأسبوع)
  // 6: Quiz Bank (بنك الأسئلة)
  int _currentSection = 0;
  String? _selectedCourseIdForFolder;

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

  // Quick Draft Controller
  final _draftTitleCtrl = TextEditingController();
  final _draftContentCtrl = TextEditingController();

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
    _draftTitleCtrl.dispose();
    _draftContentCtrl.dispose();
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
        backgroundColor: isDark ? const Color(0xFF101520) : const Color(0xFFF0F0F1),
        // Classic WordPress Top Admin Bar (#1D2327)
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildClassicWpTopBar(isDark),
        ),
        body: Row(
          children: [
            // Classic WordPress Left/Right Admin Sidebar (#1D2327)
            if (isDesktop) _buildClassicWpSidebar(isDark),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1250),
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
  // 1. Classic WordPress Top Admin Bar (#1D2327)
  // ==========================================
  Widget _buildClassicWpTopBar(bool isDark) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF1D2327),
        border: Border(bottom: BorderSide(color: Color(0xFF2C3338), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: WordPress Logo + Site Title + + New
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF2271B1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("W", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => setState(() => _currentSection = 0),
                child: Row(
                  children: [
                    const Icon(Icons.home_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Eslam Atef | Code & AI",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              PopupMenuButton<String>(
                color: const Color(0xFF2C3338),
                offset: const Offset(0, 36),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text("أضف جديد", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                onSelected: (val) {
                  if (val == 'course') {
                    _showCourseFolderDialog();
                  } else if (val == 'recording') {
                    setState(() => _currentSection = 3);
                    _showRecordingLessonDialog();
                  } else if (val == 'update') {
                    setState(() => _currentSection = 4);
                    _showLatestUpdateDialog();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'course',
                    child: Text("📁 ملف كورس / مسار جديد", style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                  ),
                  PopupMenuItem(
                    value: 'recording',
                    child: Text("🎬 جلسة تصوير جديدة", style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                  ),
                  PopupMenuItem(
                    value: 'update',
                    child: Text("✨ تحديث لشريط جديدنا", style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),

          // Right: Theme + View Site + User Profile
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: const Color(0xFFFFB300),
                  size: 18,
                ),
                tooltip: "تبديل المظهر",
                onPressed: () => AppThemeManager.toggleTheme(),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2271B1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      Text("زيارة الموقع ↗", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Row(
                children: [
                  Text("مرحباً، إسلام عاطف (المدير)", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.white70)),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage('assets/images/islam.png'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. Classic WordPress Admin Sidebar (#1D2327)
  // ==========================================
  Widget _buildClassicWpSidebar(bool isDark) {
    return Container(
      width: 230,
      color: const Color(0xFF1D2327),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _wpSidebarItem(0, "الرئيسية (Dashboard)", Icons.dashboard_outlined),
          _wpSidebarItem(1, "الكورسات والمسارات", Icons.folder_open_rounded),
          _wpSidebarItem(3, "استوديو التصوير 🎬", Icons.videocam_rounded),
          _wpSidebarItem(4, "شريط جديدنا", Icons.auto_awesome_rounded),
          _wpSidebarItem(5, "تحدي الأسبوع", Icons.bolt_rounded),
          _wpSidebarItem(6, "بنك الأسئلة (اختبر نفسك)", Icons.quiz_outlined),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF2C3338))),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF2271B1), size: 18),
                const SizedBox(width: 8),
                Text("WordPress 6.4 Style", style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wpSidebarItem(int sectionIndex, String title, IconData icon) {
    final isSelected = _currentSection == sectionIndex || (_currentSection == 2 && sectionIndex == 1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentSection = sectionIndex;
            if (sectionIndex != 2) _selectedCourseIdForFolder = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2271B1) : Colors.transparent,
            border: isSelected
                ? const Border(right: BorderSide(color: Color(0xFF72AEE6), width: 4))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFFA7AAAD)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFFA7AAAD),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Router for Active View
  // ==========================================
  Widget _buildActiveView(bool isDark) {
    switch (_currentSection) {
      case 0:
        return _buildWordPressDashboardHome(isDark);
      case 1:
        return _buildCourseFoldersView(isDark);
      case 2:
        return _buildInsideCourseFolderView(isDark);
      case 3:
        return _buildRecordingStudioSection(isDark);
      case 4:
        return _buildLatestUpdatesSection(isDark);
      case 5:
        return _buildWeeklyChallengeSection(isDark);
      case 6:
        return _buildQuizQuestionsSection(isDark);
      default:
        return _buildWordPressDashboardHome(isDark);
    }
  }

  // ==========================================
  // SECTION 0: WordPress Dashboard Home (Matching Screenshot 2)
  // ==========================================
  Widget _buildWordPressDashboardHome(bool isDark) {
    final courses = _dataService.courses;
    int totalLessons = 0;
    for (final c in courses) {
      totalLessons += ((c['lessons'] as List?) ?? []).length;
    }
    final recordings = _dataService.recordingLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Heading
        Text(
          "لوحة التحكم (Dashboard)",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1D2327)),
        ),
        const SizedBox(height: 14),

        // 1. Welcome to WordPress Box (Exact match with user Screenshot 2)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2234) : Colors.white,
            border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أهلاً بك في لوحة تحكم WordPress لـ Eslam Atef!",
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "لقد قمنا بتجهيز روابط سريعة للبدء في إدارة الكورسات والدروس واستوديو التصوير:",
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ابدأ الآن", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => setState(() => _currentSection = 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2271B1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text("إدارة ملفات الكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("الخطوات التالية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      _wpQuickActionLink("+ إنشاء ملف كورس جديد", () => _showCourseFolderDialog()),
                      _wpQuickActionLink("+ إضافة جلسة تصوير جديدة", () {
                        setState(() => _currentSection = 3);
                        _showRecordingLessonDialog();
                      }),
                      _wpQuickActionLink("زيارة واستعراض الموقع", () => Navigator.of(context).pushNamed('/')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("إجراءات إضافية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      _wpQuickActionLink("تعديل سيناريو تحدي الأسبوع", () => setState(() => _currentSection = 5)),
                      _wpQuickActionLink("إدارة بنك أسئلة اختبر نفسك", () => setState(() => _currentSection = 6)),
                      _wpQuickActionLink("التحكم في شريط جديدنا", () => setState(() => _currentSection = 4)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. WordPress 2-Column Widget Grid (Exact match with user Screenshot 2)
        LayoutBuilder(
          builder: (ctx, constraints) {
            final isNarrow = constraints.maxWidth < 800;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1
                Expanded(
                  flex: isNarrow ? 1 : 1,
                  child: Column(
                    children: [
                      // Widget: At a Glance (في لمحة)
                      _buildWpCard(
                        title: "في لمحة (At a Glance)",
                        isDark: isDark,
                        child: Column(
                          children: [
                            _wpStatRow(Icons.folder_rounded, "$courses كورس وملف مسار", const Color(0xFF2271B1)),
                            const Divider(height: 16),
                            _wpStatRow(Icons.video_library_rounded, "$totalLessons درس وفيديو مضاف", const Color(0xFF00E5FF)),
                            const Divider(height: 16),
                            _wpStatRow(Icons.videocam_rounded, "${recordings.length} محاضرة في استوديو التصوير", const Color(0xFFFFB300)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Widget: Site Health
                      _buildWpCard(
                        title: "حالة النظام (Site Health Status)",
                        isDark: isDark,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("حالة الموقع ممتازة وجاهزة للنشر", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text("تخزين البيانات المحلي يعمل بسلاسة ويدعم التحديث الفوري.", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isNarrow) const SizedBox(width: 18),

                // Column 2
                Expanded(
                  flex: isNarrow ? 1 : 1,
                  child: Column(
                    children: [
                      // Widget: Quick Draft (مسودة سريعة)
                      _buildWpCard(
                        title: "مسودة سريعة (Quick Draft)",
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _draftTitleCtrl,
                              decoration: InputDecoration(
                                hintText: "عنوان الفكرة أو الدرس...",
                                isDense: true,
                                filled: true,
                                fillColor: isDark ? const Color(0xFF101520) : const Color(0xFFF6F7F7),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _draftContentCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "ما الذي يدور في ذهنك؟ اكتب ملاحظة أو فكرة كورس...",
                                filled: true,
                                fillColor: isDark ? const Color(0xFF101520) : const Color(0xFFF6F7F7),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("تم حفظ المسودة بنجاح")),
                                  );
                                  _draftTitleCtrl.clear();
                                  _draftContentCtrl.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2271B1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: Text("حفظ المسودة", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Widget: Activity (النشاط الأخير)
                      _buildWpCard(
                        title: "النشاط الأخير (Activity)",
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("أحدث الإضافات:", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            if (courses.isEmpty)
                              Text("لا توجد كورسات مضافة بعد.", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey))
                            else
                              ...courses.take(3).map((c) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_left_rounded, size: 18, color: Color(0xFF2271B1)),
                                      Expanded(
                                        child: Text(c['title'] ?? '', style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
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

  Widget _wpQuickActionLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF2271B1), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _wpStatRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWpCard({required String title, required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2234) : Colors.white,
        border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4))),
            ),
            child: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 1: Course Folders (ملفات الكورسات والمسارات)
  // "لازم الاول احدد ملف للكورس او الدرس جواه هيبقي الدروس او الفديوهات"
  // ==========================================
  Widget _buildCourseFoldersView(bool isDark) {
    final courses = _dataService.courses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("إدارة ملفات الكورسات والمسارات (${courses.length})", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("أنشئ ملف الكورس أولاً، ثم اضغط عليه لإضافة الدروس والفيديوهات وشروحات الـ HTML داخله.", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCourseFolderDialog(),
              icon: const Icon(Icons.create_new_folder_rounded, size: 18),
              label: Text("+ إنشاء ملف كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2271B1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (courses.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد ملفات كورسات منشأة بعد",
            "اضغط على زر (+ إنشاء ملف كورس جديد) لإنشاء أول مسار، ثم ابدأ بإضافة الدروس والفيديوهات داخله.",
            isDark,
          )
        else
          ...courses.map((course) {
            final lessons = (course['lessons'] as List?) ?? [];
            final image = course['image'] ?? 'assets/images/slide1.png';
            final isNetwork = image.startsWith('http');

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2234) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 60,
                    height: 50,
                    child: isNetwork
                        ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey))
                        : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey)),
                  ),
                ),
                title: Text(course['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(
                  "التصنيف: ${course['category'] ?? 'عام'} • يحتوي على: (${lessons.length}) درس وفيديو",
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF2271B1), fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCourseIdForFolder = course['id'];
                          _currentSection = 2; // Open inside course
                        });
                      },
                      icon: const Icon(Icons.folder_open_rounded, size: 16),
                      label: Text("فتح محتوى الكورس (${lessons.length})", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: "تعديل الكورس",
                      onPressed: () => _showCourseFolderDialog(existingCourse: course),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      tooltip: "حذف الكورس",
                      onPressed: () => _dataService.deleteCourse(course['id']),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // SECTION 2: Inside Course Folder (الدروس والفيديوهات داخل الكورس)
  // "جواه هيبقي الدروس او الفديوهات كل فديو هيبقي فيه صوره و الفديو لينك من اليوتيوب وفيه كلام شرح وفيه اختبار"
  // ==========================================
  Widget _buildInsideCourseFolderView(bool isDark) {
    final course = _dataService.courses.firstWhere(
      (c) => c['id'] == _selectedCourseIdForFolder,
      orElse: () => {},
    );

    if (course.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () => setState(() => _currentSection = 1),
          child: const Text("العودة لملفات الكورسات"),
        ),
      );
    }

    final lessons = List<Map<String, dynamic>>.from(course['lessons'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation Breadcrumb
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _currentSection = 1),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text("العودة لملفات الكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2271B1),
                side: const BorderSide(color: Color(0xFF2271B1)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "ملف الكورس: ${course['title']} (${lessons.length} دروس)",
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Action Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("الدروس والفيديوهات المضافة داخل هذا الكورس:", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showLessonEditorDialog(courseId: course['id']),
              icon: const Icon(Icons.video_call_rounded, size: 18),
              label: Text("+ إضافة درس / فيديو جديد في هذا الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2271B1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (lessons.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد دروس أو فيديوهات داخل هذا الكورس بعد",
            "اضغط على زر (+ إضافة درس / فيديو جديد) لإرفاق فيديو يوتيوب وصورة وشرح الدرس واختباره.",
            isDark,
          )
        else
          ...lessons.asMap().entries.map((entry) {
            final idx = entry.key;
            final lesson = entry.value;
            final image = lesson['image'] ?? 'assets/images/slide1.png';
            final hasYoutube = (lesson['youtubeUrl'] ?? '').toString().isNotEmpty;
            final hasQuiz = lesson['hasQuiz'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2234) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2271B1).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text("${idx + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF2271B1))),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 70,
                      height: 50,
                      child: image.startsWith('http')
                          ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey))
                          : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                        Row(
                          children: [
                            if (hasYoutube)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                child: Text("▶ يوتيوب مدمج", style: GoogleFonts.cairo(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            if (hasQuiz)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                child: Text("📝 اختبار مفعّل", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: "تعديل الدرس",
                        onPressed: () => _showLessonEditorDialog(courseId: course['id'], existingLesson: lesson),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        tooltip: "حذف الدرس",
                        onPressed: () => _dataService.deleteLessonFromCourse(course['id'], lesson['id']),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // Lesson Editor Dialog (Matching Screenshot 1: Joomla / CMS Editor)
  // Two Editing Modes: Visual Text vs HTML Code
  // YouTube link + Image + Explanation + Quiz button
  // ==========================================
  void _showLessonEditorDialog({required String courseId, Map<String, dynamic>? existingLesson}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingLesson != null;

    final titleCtrl = TextEditingController(text: existingLesson?['title'] ?? '');
    final youtubeCtrl = TextEditingController(text: existingLesson?['youtubeUrl'] ?? '');
    final imageCtrl = TextEditingController(text: existingLesson?['image'] ?? 'assets/images/slide1.png');
    final contentCtrl = TextEditingController(
      text: existingLesson?['content'] ??
          "<h2>شرح الدرس بالتفصيل</h2>\n<p>في هذا الفيديو نقوم بشرح الخطوات العملية لتطبيق المفاهيم البرمجية بدقة.</p>\n\n<pre><code>// الكود البرمجي الخاص بالدرس\nvoid main() {\n  print('أهلاً بكم في هذا الدرس');\n}\n</code></pre>",
    );
    bool hasQuiz = existingLesson?['hasQuiz'] ?? false;
    final quizTitleCtrl = TextEditingController(text: existingLesson?['quizTitle'] ?? 'اختبار فهم هذا الدرس');
    final quizQuestionCtrl = TextEditingController(text: existingLesson?['quizQuestion'] ?? 'ما هي النتيجة الصحيحة لتنفيذ الكود المشروح في هذا الدرس؟');
    final quizOpt1Ctrl = TextEditingController(text: existingLesson?['quizOpt1'] ?? 'إجابة أ');
    final quizOpt2Ctrl = TextEditingController(text: existingLesson?['quizOpt2'] ?? 'إجابة ب (صحيحة)');
    final quizExplanationCtrl = TextEditingController(text: existingLesson?['quizExplanation'] ?? 'الشرح العلمي لنتيجة الكود.');

    // Editor tab: 0 = Content (Text / HTML), 1 = Video & Media, 2 = Quiz Options
    int editorTab = 0;
    // Inside Content tab: 0 = Visual Editor (Blogger Visual), 1 = HTML Source Code Editor (Blogger HTML)
    int contentMode = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            void insertTag(String prefix, String suffix) {
              final text = contentCtrl.text;
              final selection = contentCtrl.selection;
              final start = selection.start >= 0 ? selection.start : text.length;
              final end = selection.end >= 0 ? selection.end : text.length;
              final selectedText = text.substring(start, end);
              final replacement = "$prefix$selectedText$suffix";
              contentCtrl.text = text.replaceRange(start, end, replacement);
              contentCtrl.selection = TextSelection.collapsed(offset: start + replacement.length);
              setDlgState(() {});
            }

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                width: 950,
                constraints: const BoxConstraints(maxHeight: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Joomla / CMS Style Top Action Bar (Matching Screenshot 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D2327),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text("Articles: Edit Lesson", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (titleCtrl.text.trim().isEmpty) return;
                                  final data = {
                                    'title': titleCtrl.text.trim(),
                                    'youtubeUrl': youtubeCtrl.text.trim(),
                                    'image': imageCtrl.text.trim(),
                                    'content': contentCtrl.text.trim(),
                                    'hasQuiz': hasQuiz,
                                    'quizTitle': quizTitleCtrl.text.trim(),
                                    'quizQuestion': quizQuestionCtrl.text.trim(),
                                    'quizOpt1': quizOpt1Ctrl.text.trim(),
                                    'quizOpt2': quizOpt2Ctrl.text.trim(),
                                    'quizExplanation': quizExplanationCtrl.text.trim(),
                                  };
                                  if (isEdit) {
                                    _dataService.updateLessonInCourse(courseId, existingLesson['id'], data..['id'] = existingLesson['id']);
                                  } else {
                                    _dataService.addLessonToCourse(courseId, data);
                                  }
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("تم حفظ الدرس بنجاح! 🎉"), backgroundColor: Color(0xFF10B981)),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 14),
                                label: Text("حفظ وإغلاق (Save & Close)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // Title Input Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Title * (عنوان الدرس والفيديو)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: titleCtrl,
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: "مثال: الدرس 1: إعداد بيئة العمل وتشغيل أول برنامج",
                              filled: true,
                              fillColor: isDark ? const Color(0xFF101520) : const Color(0xFFF6F7F7),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Joomla Style Tabs Bar (Content, Media & Links, Quiz Options)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4))),
                      ),
                      child: Row(
                        children: [
                          _cmsTabHeader(0, "المحتوى والشرح (Content)", editorTab, (idx) => setDlgState(() => editorTab = idx)),
                          _cmsTabHeader(1, "فيديو يوتيوب وصورة الغلاف (Video & Media)", editorTab, (idx) => setDlgState(() => editorTab = idx)),
                          _cmsTabHeader(2, "زر الاختبار (Lesson Quiz)", editorTab, (idx) => setDlgState(() => editorTab = idx)),
                        ],
                      ),
                    ),

                    // Tab Body
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: editorTab == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Blogger Style Dual Mode Toggle (Visual vs HTML)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text("وضع التحرير: ", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            ChoiceChip(
                                              label: Text("📝 محرر مرئي / نصوص (Visual)", style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                              selected: contentMode == 0,
                                              selectedColor: const Color(0xFF2271B1),
                                              labelStyle: TextStyle(color: contentMode == 0 ? Colors.white : null),
                                              onSelected: (val) => setDlgState(() => contentMode = 0),
                                            ),
                                            const SizedBox(width: 8),
                                            ChoiceChip(
                                              label: Text("💻 كود HTML حر (HTML Source)", style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                              selected: contentMode == 1,
                                              selectedColor: const Color(0xFF2271B1),
                                              labelStyle: TextStyle(color: contentMode == 1 ? Colors.white : null),
                                              onSelected: (val) => setDlgState(() => contentMode = 1),
                                            ),
                                          ],
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            _showLessonPreviewModal(titleCtrl.text, youtubeCtrl.text, imageCtrl.text, contentCtrl.text);
                                          },
                                          icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                                          label: Text("معاينة شكل الدرس 👁️", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // CMS Formatting Toolbar (Matching Screenshot 1)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF101520) : const Color(0xFFF0F0F1),
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                        border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
                                      ),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          _toolBtn("H2 عنوان رئيسي", () => insertTag("<h2>", "</h2>\n")),
                                          _toolBtn("H3 عنوان فرعي", () => insertTag("<h3>", "</h3>\n")),
                                          _toolBtn("P فقرة", () => insertTag("<p>", "</p>\n")),
                                          _toolBtn("B عريض", () => insertTag("<b>", "</b>")),
                                          _toolBtn("I مائل", () => insertTag("<i>", "</i>")),
                                          _toolBtn("Code كود برمجي", () => insertTag("<pre><code>// اكتب الكود هنا\n", "\n</code></pre>\n")),
                                          _toolBtn("Quote تنبيه", () => insertTag("<blockquote>", "</blockquote>\n")),
                                          _toolBtn("List قائمة", () => insertTag("<ul>\n  <li>نقطة 1</li>\n  <li>نقطة 2</li>\n</ul>\n", "")),
                                        ],
                                      ),
                                    ),

                                    // Editor Area
                                    TextField(
                                      controller: contentCtrl,
                                      maxLines: 12,
                                      style: contentMode == 1 ? GoogleFonts.firaCode(fontSize: 13, height: 1.6) : GoogleFonts.cairo(fontSize: 14, height: 1.7),
                                      decoration: InputDecoration(
                                        hintText: contentMode == 1
                                            ? "<div class='lesson-content'>\n  <h2>عنوان الدرس</h2>\n  <p>شرح بالـ HTML...</p>\n</div>"
                                            : "اكتب شرح وتفاصيل الدرس هنا...",
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF0B101E) : Colors.white,
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4))),
                                      ),
                                    ),
                                  ],
                                )
                              : editorTab == 1
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // YouTube URL Input
                                        Text("رابط فيديو اليوتيوب (YouTube Video URL) *", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: youtubeCtrl,
                                          style: GoogleFonts.inter(fontSize: 14),
                                          decoration: InputDecoration(
                                            hintText: "مثال: https://www.youtube.com/watch?v=dQw4w9WgXcQ أو https://youtu.be/...",
                                            prefixIcon: const Icon(Icons.video_library_rounded, color: Colors.red),
                                            filled: true,
                                            fillColor: isDark ? const Color(0xFF101520) : const Color(0xFFF6F7F7),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                            isDense: true,
                                          ),
                                          onChanged: (_) => setDlgState(() {}),
                                        ),
                                        const SizedBox(height: 14),

                                        // Live Embedded Player Test
                                        if (youtubeCtrl.text.trim().isNotEmpty) ...[
                                          Text("معاينة مشغل اليوتيوب المباشر داخل الموقع:", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                          const SizedBox(height: 8),
                                          YouTubeEmbeddedPlayer(youtubeUrl: youtubeCtrl.text.trim(), height: 240),
                                          const SizedBox(height: 18),
                                        ],

                                        // Thumbnail Image
                                        Text("صورة الغلاف / مصغرة الدرس (Thumbnail URL)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: imageCtrl,
                                          decoration: InputDecoration(
                                            hintText: "رابط صورة أو مسار داخلي مثل assets/images/slide1.png",
                                            prefixIcon: const Icon(Icons.image_outlined),
                                            filled: true,
                                            fillColor: isDark ? const Color(0xFF101520) : const Color(0xFFF6F7F7),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                            isDense: true,
                                          ),
                                          onChanged: (_) => setDlgState(() {}),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Quiz Option
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text("تفعيل زر اختبار لهذا الدرس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                          subtitle: Text("عند تفعيله، يظهر زر في نهاية الدرس للطلاب لخوض اختبار فهم سريع.", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                                          value: hasQuiz,
                                          activeColor: const Color(0xFF10B981),
                                          onChanged: (val) => setDlgState(() => hasQuiz = val),
                                        ),
                                        const Divider(),
                                        if (hasQuiz) ...[
                                          _buildField("نص الزر / عنوان الاختبار", quizTitleCtrl, isDark),
                                          _buildField("سؤال الاختبار الأول", quizQuestionCtrl, isDark),
                                          Row(
                                            children: [
                                              Expanded(child: _buildField("الخيار 1", quizOpt1Ctrl, isDark)),
                                              const SizedBox(width: 12),
                                              Expanded(child: _buildField("الخيار 2 (الصحيح)", quizOpt2Ctrl, isDark)),
                                            ],
                                          ),
                                          _buildField("الشرح العلمي لنتيجة الإجابة", quizExplanationCtrl, isDark),
                                        ],
                                      ],
                                    ),
                        ),
                      ),
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

  Widget _cmsTabHeader(int tabIndex, String label, int currentTab, Function(int) onSelect) {
    final isSelected = currentTab == tabIndex;
    return InkWell(
      onTap: () => onSelect(tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: Color(0xFF2271B1), width: 3))
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF2271B1) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _toolBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showLessonPreviewModal(String title, String youtubeUrl, String image, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 800,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("معاينة شكل الدرس للطلاب", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(title, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (youtubeUrl.isNotEmpty) YouTubeEmbeddedPlayer(youtubeUrl: youtubeUrl, height: 280),
                        const SizedBox(height: 16),
                        ArticleContentRenderer(content: content, isDark: isDark),
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
  // SECTION 3: استوديو التصوير (Recording Studio)
  // "+ فين لينك التصوير زي ما قولتلك حط التصوير في لوحه التحكم ميبقاش في الموقع ولما ادوس علي التصوير يبقي في زر اضافه تصوير جديد اسم الدرس وتحت احط الكود بتاع الدرس لما افتح التصوير يبقي في الدروس الي عملتها للتصوير وفيه زر اضافه درس جديد وقولي الكود html بتاع التصوير عايزه ازاي عشان يطلع زي الي موجود دلوقتي"
  // ==========================================
  Widget _buildRecordingStudioSection(bool isDark) {
    final recordings = _dataService.recordingLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🎬 استوديو تصوير المحاضرات (${recordings.length})", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("خاص بمدير النظام فقط لتسجيل المحاضرات وشرح الشرائح مع السبورة البيضاء.", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showRecordingLessonDialog(),
              icon: const Icon(Icons.add_to_photos_rounded, size: 18),
              label: Text("+ إضافة درس تصوير جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Interactive HTML Presentation Template Explainer
        ExpansionTile(
          collapsedBackgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
          backgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: const Icon(Icons.code_rounded, color: Color(0xFF00E5FF)),
          title: Text("📋 قالب كود HTML لشرائح التصوير (اضغط لعرض القالب وكيفية كتابته)", style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold)),
          subtitle: Text("انسخ هذا الكود وضعه في أي درس تصوير جديد ليخرج بنفس تصميم الاستوديو المباشر.", style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "هيكل كل شريحة في استوديو التصوير يتكون من وسم <section class='slide'> ويحتوي على الكروت والعناوين:",
                    style: GoogleFonts.cairo(fontSize: 12.5),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B101E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2C3338)),
                    ),
                    child: SelectableText(
                      '''<!-- نموذج شريحة في استوديو التصوير -->
<section class="slide">
  <!-- رأس الشريحة -->
  <header class="slide-header">
    <div class="brand-badge">
      <div class="brand-logo-icon">E</div>
      <div class="brand-text">
        <span class="brand-title">Eslam Atef | Code & AI</span>
        <span class="brand-tagline">Think. Code. Build with AI.</span>
      </div>
    </div>
    <div class="lesson-badge">مفهوم أساسي</div>
    <div class="slide-number-indicator">01 / 10</div>
  </header>

  <!-- عنوان الشريحة -->
  <div class="slide-title-area">
    <h2 class="slide-title"><span class="slide-title-icon">⚡</span> عنوان الشريحة هنا</h2>
    <p class="slide-subtitle">نبذة توضيحية لما يتم شرحه في هذه الشريحة</p>
  </div>

  <!-- جسم الشريحة وكروت الشرح -->
  <div class="slide-body">
    <div class="card-grid grid-cols-3">
      <div class="tech-card">
        <div class="card-badge">01</div>
        <h3 class="card-title">العنصر الأول</h3>
        <p class="card-desc">اكتب الشرح النظري والتطبيقي هنا بدقة وبساطة.</p>
      </div>
      <div class="tech-card">
        <div class="card-badge">02</div>
        <h3 class="card-title">العنصر الثاني</h3>
        <p class="card-desc">يمكنك إضافة مقارنات ونقاط محددة للطالب.</p>
      </div>
    </div>
  </div>
</section>''',
                      style: GoogleFonts.firaCode(fontSize: 12, color: const Color(0xFF00E5FF), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // List of Recording Lessons
        if (recordings.isEmpty)
          _buildEmptyPlaceholder(
            "لا توجد جلسات تصوير مضافة بعد",
            "اضغط على زر (+ إضافة درس تصوير جديد) لإضافة اسم المحاضرة وكود الشرائح الخاص بها.",
            isDark,
          )
        else
          ...recordings.map((rec) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2234) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Color(0xFFFFB300), size: 24),
                ),
                title: Text(rec['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text("المادة: ${rec['subject'] ?? 'عام'} • ${rec['date'] ?? '2026'}", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open presentation studio
                        final uri = Uri.parse(rec['url'] ?? 'presentation/index.html');
                        launchUrl(uri, mode: LaunchMode.platformDefault);
                      },
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                      label: Text("فتح الاستوديو والعرض 🎬", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.code_rounded, size: 18),
                      tooltip: "تعديل الكود",
                      onPressed: () => _showRecordingLessonDialog(existingRecording: rec),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      tooltip: "حذف",
                      onPressed: () => _dataService.deleteRecordingLesson(rec['id']),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // Recording Lesson Dialog (Add / Edit Code)
  // ==========================================
  void _showRecordingLessonDialog({Map<String, dynamic>? existingRecording}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingRecording != null;

    final titleCtrl = TextEditingController(text: existingRecording?['title'] ?? '');
    final subjectCtrl = TextEditingController(text: existingRecording?['subject'] ?? 'الصف الأول الثانوي — برمجة وذكاء اصطناعي');
    final codeCtrl = TextEditingController(
      text: existingRecording?['code'] ??
          '''<section class="slide">
  <div class="tech-card">
    <div class="card-badge">01</div>
    <h3 class="card-title">عنوان النقطة</h3>
    <p class="card-desc">اكتب تفاصيل المحتوى هنا...</p>
  </div>
</section>''',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 800,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? "تعديل كود جلسة التصوير" : "إضافة درس تصوير جديد",
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildField("اسم الدرس / عنوان المحاضرة للتصوير *", titleCtrl, isDark),
                        _buildField("المادة أو الصف الدراسي", subjectCtrl, isDark),
                        const SizedBox(height: 10),
                        Text("كود HTML لشرائح هذا الدرس:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: codeCtrl,
                          maxLines: 14,
                          style: GoogleFonts.firaCode(fontSize: 12.5, height: 1.5),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0B101E) : const Color(0xFFF6F7F7),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        final data = {
                          'title': titleCtrl.text.trim(),
                          'subject': subjectCtrl.text.trim(),
                          'code': codeCtrl.text.trim(),
                          'url': 'presentation/index.html',
                          'date': '2026',
                        };
                        if (isEdit) {
                          _dataService.updateRecordingLesson(existingRecording['id'], data..['id'] = existingRecording['id']);
                        } else {
                          _dataService.addRecordingLesson(data);
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم حفظ جلسة التصوير بنجاح! 🎬"), backgroundColor: Color(0xFF10B981)),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300), foregroundColor: Colors.black),
                      child: Text(isEdit ? "حفظ التعديل" : "إضافة للاستوديو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // Course Folder Dialog (Create / Edit Course Folder)
  // ==========================================
  void _showCourseFolderDialog({Map<String, dynamic>? existingCourse}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingCourse != null;

    final titleCtrl = TextEditingController(text: existingCourse?['title'] ?? '');
    final categoryCtrl = TextEditingController(text: existingCourse?['category'] ?? 'ذكاء اصطناعي');
    final imageCtrl = TextEditingController(text: existingCourse?['image'] ?? 'assets/images/slide1.png');
    final descCtrl = TextEditingController(text: existingCourse?['description'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(isEdit ? "تعديل ملف الكورس" : "إنشاء ملف كورس / مسار جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField("اسم الكورس / المسار *", titleCtrl, isDark),
                _buildField("التصنيف (مثال: Flutter، ذكاء اصطناعي، خوارزميات)", categoryCtrl, isDark),
                _buildField("رابط صورة الغلاف أو مسارها", imageCtrl, isDark),
                _buildField("وصف مختصر للكورس", descCtrl, isDark, maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final data = {
                  'title': titleCtrl.text.trim(),
                  'category': categoryCtrl.text.trim(),
                  'image': imageCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                };
                if (isEdit) {
                  _dataService.updateCourse(existingCourse['id'], data..['id'] = existingCourse['id']);
                } else {
                  _dataService.addCourse(data);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2271B1), foregroundColor: Colors.white),
              child: Text(isEdit ? "حفظ التعديل" : "إنشاء الملف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // SECTION 4: شريط جديدنا
  // ==========================================
  Widget _buildLatestUpdatesSection(bool isDark) {
    final updates = _dataService.latestUpdates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("شريط جديدنا والتحديثات (${updates.length})", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showLatestUpdateDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: Text("+ إضافة تحديث", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2271B1), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (updates.isEmpty)
          _buildEmptyPlaceholder("لا توجد تحديثات مخصصة", "الكورسات والدروس تظهر تلقائياً في شريط جديدنا.", isDark)
        else
          ...updates.map((u) {
            return Card(
              color: isDark ? const Color(0xFF1A2234) : Colors.white,
              child: ListTile(
                title: Text(u['title'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text("${u['category'] ?? ''} • ${u['badge'] ?? ''}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showLatestUpdateDialog(existingUpdate: u)),
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18), onPressed: () => _dataService.deleteLatestUpdate(u['id'])),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

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
          backgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
          title: Text(isEdit ? "تعديل التحديث" : "إضافة تحديث لشريط جديدنا", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField("العنوان", titleCtrl, isDark),
                _buildField("التصنيف", categoryCtrl, isDark),
                _buildField("الشارة", badgeCtrl, isDark),
                _buildField("المدة أو الوقت", durationCtrl, isDark),
                _buildField("رابط الصورة", imageCtrl, isDark),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2271B1), foregroundColor: Colors.white),
              child: Text(isEdit ? "حفظ" : "إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // SECTION 5: تحدي الأسبوع
  // ==========================================
  Widget _buildWeeklyChallengeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("إدارة تحدي الأسبوع البرمجي", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _saveWeeklyChallenge,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text("حفظ التحدي 💾", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300), foregroundColor: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2234) : Colors.white,
            border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("تفعيل التحدي وظهوره على الموقع", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                value: _challengeActive,
                activeThumbColor: const Color(0xFFFFB300),
                onChanged: (val) => setState(() => _challengeActive = val),
              ),
              const Divider(),
              _buildField("عنوان التحدي", _challengeTitleCtrl, isDark),
              Row(
                children: [
                  Expanded(child: _buildField("المستوى", _challengeDiffCtrl, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField("الأسبوع", _challengeWeekCtrl, isDark)),
                ],
              ),
              _buildField("سيناريو المسألة البرمجية", _challengeScenarioCtrl, isDark, maxLines: 3),
              Row(
                children: [
                  Expanded(child: _buildField("المدخل (Input)", _challengeInputCtrl, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField("المخرج (Output)", _challengeOutputCtrl, isDark)),
                ],
              ),
              _buildField("التلميح", _challengeHintCtrl, isDark),
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
      const SnackBar(content: Text("تم حفظ التحدي بنجاح! 🎉"), backgroundColor: Color(0xFF10B981)),
    );
  }

  // ==========================================
  // SECTION 6: بنك الأسئلة
  // ==========================================
  Widget _buildQuizQuestionsSection(bool isDark) {
    final questions = _dataService.quizQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("بنك أسئلة اختبر نفسك (${questions.length})", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showQuizQuestionDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: Text("+ إضافة سؤال", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2271B1), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (questions.isEmpty)
          _buildEmptyPlaceholder("لا توجد أسئلة مضافة", "أضف أسئلة الاختيار من متعدد مع الشرح العلمي.", isDark)
        else
          ...questions.map((q) {
            return Card(
              color: isDark ? const Color(0xFF1A2234) : Colors.white,
              child: ListTile(
                title: Text(q['question'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text("التصنيف: ${q['category'] ?? 'عام'} • الشرح: ${q['explanation'] ?? ''}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showQuizQuestionDialog(existingQuestion: q)),
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18), onPressed: () => _dataService.deleteQuizQuestion(q['id'])),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

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
              backgroundColor: isDark ? const Color(0xFF1A2234) : Colors.white,
              title: Text(isEdit ? "تعديل السؤال" : "إضافة سؤال لبنك الأسئلة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField("نص السؤال", qCtrl, isDark, maxLines: 2),
                    _buildField("التصنيف", catCtrl, isDark),
                    ...List.generate(4, (i) {
                      return Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: correctIdx,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (val) => setDlgState(() => correctIdx = val ?? 0),
                          ),
                          Expanded(child: _buildField("الخيار ${i + 1}", optCtrls[i], isDark)),
                        ],
                      );
                    }),
                    _buildField("الشرح العلمي", expCtrl, isDark, maxLines: 2),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2271B1), foregroundColor: Colors.white),
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
  // Helper Form Fields
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
              fillColor: isDark ? const Color(0xFF101520) : const Color(0xFFF6F7F7),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2234) : Colors.white,
        border: Border.all(color: isDark ? const Color(0xFF2C3338) : const Color(0xFFCCD0D4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(subtitle, style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
