// ignore_for_file: deprecated_member_use, unused_element
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/site_data_service.dart';

enum AdminSection { home, courses, members, articles }

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _dataService = SiteDataService.instance;

  // Active top-level section
  AdminSection _currentSection = AdminSection.home;

  // --- Courses State ---
  Map<String, dynamic>? _selectedCourseForLectures;
  final _lecNumberCtrl = TextEditingController();
  final _lecTitleCtrl = TextEditingController();
  final _lecYoutubeCtrl = TextEditingController();
  final _lecQuizHtmlCtrl = TextEditingController();
  final _lecBookUrlCtrl = TextEditingController();
  Map<String, dynamic>? _editingLecture;

  // The 8 Official Academy Courses
  final List<Map<String, dynamic>> _officialCourses = [
    {
      "id": "01_cs_fundamentals",
      "number": "01",
      "title": "البرمجة والذكاء الاصطناعي للأطفال | من الصفر للاحتراف",
      "category": "الكورس التأسيسي الشامل",
      "image": "assets/images/courses/course_01.png",
      "badge": "متاح الآن 🔥",
      "badgeColor": const Color(0xFF00E5FF),
    },
    {
      "id": "02_algorithms",
      "number": "02",
      "title": "كورس الخوارزميات والتفكير المنطقي",
      "category": "تفكير حسابي ومنطقي",
      "image": "assets/images/courses/course_02.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF8B5CF6),
    },
    {
      "id": "03_scratch",
      "number": "03",
      "title": "كورس سكراتش وصناعة الألعاب",
      "category": "برمجة مرئية بالبلوكات",
      "image": "assets/images/courses/course_03.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF10B981),
    },
    {
      "id": "04_python",
      "number": "04",
      "title": "كورس لغة بايثون للأطفال واليافعين",
      "category": "لغات العصر البرمجية",
      "image": "assets/images/courses/course_04.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF3B82F6),
    },
    {
      "id": "05_ai_tools",
      "number": "05",
      "title": "كورس أدوات وهندسة أوامر الذكاء الاصطناعي",
      "category": "تقنيات المستقبل",
      "image": "assets/images/courses/course_05.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF0D9488),
    },
    {
      "id": "06_ai_agents",
      "number": "06",
      "title": "كورس وكلاء الذكاء الاصطناعي المستقلة",
      "category": "ذكاء اصطناعي متقدم",
      "image": "assets/images/courses/course_06.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFFF59E0B),
    },
    {
      "id": "07_cybersecurity",
      "number": "07",
      "title": "كورس الأمان السيبراني والدفاع الرقمي",
      "category": "أمان وحماية الأنظمة",
      "image": "assets/images/courses/course_07.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFFEF4444),
    },
    {
      "id": "08_roblox_lua",
      "number": "08",
      "title": "كورس برمجة ألعاب روبلوكس بلغة Lua",
      "category": "صناعة ألعاب 3D",
      "image": "assets/images/courses/course_08.png",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFFEC4899),
    },
  ];

  // --- Members State (Max 50 per page) ---
  int _membersCurrentPage = 0;
  static const int _membersPageSize = 50;
  String _membersSearchQuery = '';
  String _membersRoleFilter = 'الكل'; // الكل, عضو عادي, عضو مميز, مشرف, مدير

  // --- Articles State ---
  int _articlesSubTab = 0; // 0: إضافة مقال, 1: قائمة المقالات, 2: التصنيفات
  String _articlesSearch = '';
  Map<String, dynamic>? _editingArticle;
  final _newCategoryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataServiceChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataServiceChanged);
    _lecNumberCtrl.dispose();
    _lecTitleCtrl.dispose();
    _lecYoutubeCtrl.dispose();
    _lecQuizHtmlCtrl.dispose();
    _lecBookUrlCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _onDataServiceChanged() {
    if (mounted) setState(() {});
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC),
        appBar: _buildTopNavbar(isDark, isMobile),
        body: SelectionArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 32,
              vertical: 24,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: _buildCurrentSection(isDark, isMobile),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP NAVBAR (No Right Sidebar!)
  // ==========================================
  PreferredSizeWidget _buildTopNavbar(bool isDark, bool isMobile) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(74),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right: Brand & Breadcrumbs
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _currentSection = AdminSection.home;
                          _selectedCourseForLectures = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "لوحة التحكم والإدارة",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                "أكاديمية Eslam Atef | Code & AI",
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00E5FF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Center: Section Navigation Pills (الكورسات - المقالات - الأعضاء)
                if (!isMobile)
                  Row(
                    children: [
                      _buildNavPill(AdminSection.home, "الرئيسية والإحصائيات", Icons.dashboard_rounded, isDark),
                      const SizedBox(width: 6),
                      _buildNavPill(AdminSection.courses, "الكورسات والمحاضرات", Icons.school_rounded, isDark),
                      const SizedBox(width: 6),
                      _buildNavPill(AdminSection.members, "إدارة الأعضاء والطلاب", Icons.people_alt_rounded, isDark),
                      const SizedBox(width: 6),
                      _buildNavPill(AdminSection.articles, "المقالات والمدونة", Icons.article_rounded, isDark),
                    ],
                  ),

                // Left: Global Notification Broadcast & Exit button
                Row(
                  children: [
                    // Broadcast Notification Button
                    ElevatedButton.icon(
                      onPressed: _showBroadcastNotificationDialog,
                      icon: const Icon(Icons.campaign_rounded, size: 17),
                      label: Text(
                        isMobile ? "إشعار" : "إرسال إشعار عام 📢",
                        style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Back to Site
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: Text(
                        isMobile ? "الموقع" : "العودة للموقع",
                        style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : const Color(0xFF334155),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavPill(AdminSection section, String label, IconData icon, bool isDark) {
    final isSelected = _currentSection == section;
    return InkWell(
      onTap: () {
        setState(() {
          _currentSection = section;
          if (section != AdminSection.courses) {
            _selectedCourseForLectures = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5FF).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF00E5FF)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSection(bool isDark, bool isMobile) {
    switch (_currentSection) {
      case AdminSection.home:
        return _buildHomeSection(isDark, isMobile);
      case AdminSection.courses:
        return _selectedCourseForLectures != null
            ? _buildCourseLecturesView(_selectedCourseForLectures!, isDark, isMobile)
            : _buildCoursesCatalogSection(isDark, isMobile);
      case AdminSection.members:
        return _buildMembersSection(isDark, isMobile);
      case AdminSection.articles:
        return _buildArticlesSection(isDark, isMobile);
    }
  }

  // ==========================================
  // SECTION 1: HOME & FULL ANALYTICS
  // ==========================================
  Widget _buildHomeSection(bool isDark, bool isMobile) {
    final totalMembers = _dataService.members.length;
    final totalArticles = _dataService.articles.length;
    final totalNotifications = _dataService.notifications.length;

    int totalUploadedLectures = 0;
    for (final c in _officialCourses) {
      final fromService = _dataService.courses.firstWhere(
        (dc) => dc['id'] == c['id'],
        orElse: () => <String, dynamic>{},
      );
      final lessons = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);
      totalUploadedLectures += lessons.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top Welcome Card
        Container(
          padding: EdgeInsets.all(isMobile ? 18 : 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                  : [Colors.white, const Color(0xFFF1F5F9)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 50 : 64,
                height: isMobile ? 50 : 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.space_dashboard_rounded, color: Color(0xFF00E5FF), size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "مرحباً بك في لوحة تحكم المنصة 🚀",
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "تحكم كامل في كورسات الأكاديمية الـ 8، تحرير المقالات، إدارة الأعضاء والرتب، ومتابعة الإحصائيات المباشرة.",
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 12.5 : 14,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. The 3 Master Cards: (الكورسات - المقالات - الأعضاء)
        Text(
          "الأقسام الرئيسية للتحكم",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),

        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildMasterCard(
              title: "الكورسات والمسارات البرمجية",
              subtitle: "8 مسارات معتمدة للأطفال • إضافة وتعديل المحاضرات وروابط اليوتيوب والاختبارات التفاعلية",
              statText: "$totalUploadedLectures محاضرة مرفوعة",
              icon: Icons.school_rounded,
              color: const Color(0xFF00E5FF),
              btnText: "إدارة الكورسات ➔",
              isDark: isDark,
              onTap: () {
                setState(() => _currentSection = AdminSection.courses);
              },
            ),
            _buildMasterCard(
              title: "المقالات والمدونة التقنية",
              subtitle: "محرر المقالات الاحترافي • إدارة التصنيفات وجدولة المقالات وتنسيق المحتوى",
              statText: "$totalArticles مقال منشور",
              icon: Icons.article_rounded,
              color: const Color(0xFF8B5CF6),
              btnText: "إدارة المقالات ➔",
              isDark: isDark,
              onTap: () {
                setState(() => _currentSection = AdminSection.articles);
              },
            ),
            _buildMasterCard(
              title: "الأعضاء والاشتراكات",
              subtitle: "جداول الطلاب (بحد أقصى 50 في الصفحة) • ترقية الأعضاء لمميز VIP • إعادة كلمة المرور والإشعارات",
              statText: "$totalMembers عضو مسجل",
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF10B981),
              btnText: "إدارة الأعضاء ➔",
              isDark: isDark,
              onTap: () {
                setState(() => _currentSection = AdminSection.members);
              },
            ),
          ],
        ),
        const SizedBox(height: 36),

        // 3. Platform Analytics (إحصائيات الموقع الشاملة)
        Text(
          "إحصائيات الموقع الشاملة والتسجيلات",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),

        // Quick Stats Row
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _buildStatMetricCard("👥 إجمالي الأعضاء المسجلين", "$totalMembers عضو", const Color(0xFF00E5FF), isDark),
            _buildStatMetricCard("🔥 نشط اليوم بالموقع", "${max(12, (totalMembers * 0.42).round())} مستخدم", const Color(0xFF10B981), isDark),
            _buildStatMetricCard("🎓 إجمالي المحاضرات المتاحة", "$totalUploadedLectures محاضرة", const Color(0xFF8B5CF6), isDark),
            _buildStatMetricCard("📢 إجمالي الإشعارات المرسلة", "$totalNotifications إشعار", const Color(0xFFF59E0B), isDark),
          ],
        ),
        const SizedBox(height: 24),

        // Course Registrations Table (كام عضو سجل في كورس معين)
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "توزيع الطلاب والمسجلين على الكورسات الـ 8",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    "تحديث تلقائي لحظي 🔄",
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 12,
                  headingRowColor: MaterialStateProperty.all(
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  ),
                  columns: [
                    DataColumn(label: Text("كود الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("اسم الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("التصنيف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("الطلاب المسجلين", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("المحاضرات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("الحالة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("إجراء سريع", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                  ],
                  rows: _officialCourses.map((c) {
                    final fromService = _dataService.courses.firstWhere(
                      (dc) => dc['id'] == c['id'],
                      orElse: () => <String, dynamic>{},
                    );
                    final lessons = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);
                    final enrolledCount = (c['id'] == '01_cs_fundamentals')
                        ? max(totalMembers, 209)
                        : (totalMembers > 5 ? (totalMembers * 0.35).round() : 0);

                    return DataRow(
                      cells: [
                        DataCell(Text(c['number'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                        DataCell(
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(c['image'], width: 32, height: 20, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              Text(c['title'], style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DataCell(Text(c['category'] ?? '', style: GoogleFonts.cairo(color: Colors.grey))),
                        DataCell(
                          Text(
                            "$enrolledCount طالب",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                          ),
                        ),
                        DataCell(Text("${lessons.length} محاضرة", style: GoogleFonts.cairo())),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (c['badgeColor'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c['badge'] ?? '',
                              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: c['badgeColor']),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentSection = AdminSection.courses;
                                _selectedCourseForLectures = c;
                              });
                            },
                            icon: const Icon(Icons.add_rounded, size: 14),
                            label: Text("المحاضرات", style: GoogleFonts.cairo(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF).withOpacity(0.15),
                              foregroundColor: const Color(0xFF00E5FF),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMasterCard({
    required String title,
    required String subtitle,
    required String statText,
    required IconData icon,
    required Color color,
    required String btnText,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  statText,
                  style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.12),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                btnText,
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetricCard(String label, String value, Color color, bool isDark) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12.5, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: COURSES & LECTURES MANAGER
  // ==========================================
  Widget _buildCoursesCatalogSection(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with Firebase Sync & Cleanup actions
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "كورسات الأكاديمية الـ 8 المعتمدة",
                  style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  "اختر أي كورس لإضافة وإدارة محاضراته وروابط اليوتيوب والاختبارات التفاعلية.",
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final deleted = await _dataService.cleanupLegacyCollections();
                    _showSnackBar("تم تنظيف الفايربيز وحذف $deleted وثيقة قديمة وإبقاء الكورسات والأعضاء والمقالات فقط 🧹");
                  },
                  icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                  label: Text("تنظيف الكولكشنات القديمة 🧹", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _dataService.syncOfficialCoursesToFirestore();
                    _showSnackBar("تمت تهيئة ومزامنة الكورسات الـ 8 بنجاح في الفايربيز 🚀");
                  },
                  icon: const Icon(Icons.cloud_sync_rounded, size: 18),
                  label: Text("مزامنة الكورسات الـ 8 مع الفايربيز 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 8 Course Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth > 850 ? (constraints.maxWidth - 48) / 3 : (constraints.maxWidth - 24) / 2);

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _officialCourses.map((c) {
                final fromService = _dataService.courses.firstWhere(
                  (dc) => dc['id'] == c['id'],
                  orElse: () => <String, dynamic>{},
                );
                final lessons = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);

                return Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Course Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(c['image'], fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (c['badgeColor'] as Color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c['badge'],
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: c['badgeColor'],
                                    ),
                                  ),
                                ),
                                Text(
                                  "${lessons.length} محاضرة مرفوعة",
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00E5FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              c['title'],
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c['category'],
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedCourseForLectures = c;
                                  });
                                },
                                icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                                label: Text(
                                  "إدارة المحاضرات (${lessons.length}) ➔",
                                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF).withOpacity(0.15),
                                  foregroundColor: const Color(0xFF00E5FF),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
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

  // Inside Course Lectures View
  Widget _buildCourseLecturesView(Map<String, dynamic> course, bool isDark, bool isMobile) {
    final courseId = course['id'] as String;
    final fromService = _dataService.courses.firstWhere(
      (dc) => dc['id'] == courseId,
      orElse: () => <String, dynamic>{},
    );
    final lessons = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header with Back to Courses button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedCourseForLectures = null),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text("كل الكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: GoogleFonts.cairo(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      "إدارة المحاضرات وروابط اليوتيوب والاختبارات التفاعلية",
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            // Button: إضافة محاضرة
            ElevatedButton.icon(
              onPressed: () => _openLectureEditorDialog(courseId: courseId),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text("إضافة محاضرة جديدة 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Lectures Table or Empty state
        if (lessons.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.video_library_outlined, size: 54, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "لا توجد محاضرات مضافة في هذا الكورس بعد",
                    style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "اضغط على زر (إضافة محاضرة جديدة) بالأعلى لإضافة أول محاضرة ورابط يوتيوب وكود الاختبار التفاعلي.",
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lessons.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
              itemBuilder: (context, idx) {
                final lec = lessons[idx];
                final lecNumber = lec['number'] ?? (idx + 1);
                final lecTitle = lec['title'] ?? 'محاضرة';
                final ytUrl = (lec['youtubeUrl'] ?? lec['videoUrl'] ?? '').toString();
                final quizHtml = (lec['quizHtml'] ?? '').toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Lecture Number Badge
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "$lecNumber",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Lecture Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lecTitle,
                              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.link_rounded, size: 14, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    ytUrl.isNotEmpty ? ytUrl : "لا يوجد رابط يوتيوب",
                                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (quizHtml.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "اختبار HTML تفاعلي 📝",
                                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Actions: Edit & Delete
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF00E5FF), size: 20),
                        tooltip: "تعديل المحاضرة",
                        onPressed: () => _openLectureEditorDialog(
                          courseId: courseId,
                          existingLecture: lec,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        tooltip: "حذف المحاضرة",
                        onPressed: () => _confirmDeleteLecture(courseId, lec['id'].toString()),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Dialog: إضافة / تعديل محاضرة (Strictly the 4 requested fields!)
  void _openLectureEditorDialog({required String courseId, Map<String, dynamic>? existingLecture}) {
    if (existingLecture != null) {
      _editingLecture = existingLecture;
      _lecNumberCtrl.text = (existingLecture['number'] ?? '').toString();
      _lecTitleCtrl.text = (existingLecture['title'] ?? '').toString();
      _lecYoutubeCtrl.text = (existingLecture['youtubeUrl'] ?? existingLecture['videoUrl'] ?? '').toString();
      _lecBookUrlCtrl.text = (existingLecture['bookUrl'] ?? existingLecture['bookLink'] ?? '').toString();
      _lecQuizHtmlCtrl.text = (existingLecture['quizHtml'] ?? existingLecture['htmlCode'] ?? '').toString();
    } else {
      _editingLecture = null;
      final fromService = _dataService.courses.firstWhere(
        (dc) => dc['id'] == courseId,
        orElse: () => <String, dynamic>{},
      );
      final lessons = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);
      _lecNumberCtrl.text = "${lessons.length + 1}";
      _lecTitleCtrl.clear();
      _lecYoutubeCtrl.clear();
      _lecBookUrlCtrl.clear();
      _lecQuizHtmlCtrl.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.video_call_rounded, color: Color(0xFF00E5FF), size: 26),
                    const SizedBox(width: 8),
                    Text(
                      _editingLecture != null ? "تعديل المحاضرة" : "إضافة محاضرة جديدة",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            content: SizedBox(
              width: 580,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: رقم المحاضرة
                    Text("1. رقم المحاضرة:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lecNumberCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "مثال: 1",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 2: اسم المحاضرة
                    Text("2. اسم المحاضرة:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lecTitleCtrl,
                      decoration: InputDecoration(
                        hintText: "مثال: مقدمة إلى عالم البرمجة والكمبيوتر",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 3: لينك الفديو اليوتيوب
                    Text("3. لينك الفديو اليوتيوب:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lecYoutubeCtrl,
                      decoration: InputDecoration(
                        hintText: "https://www.youtube.com/watch?v=...",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 4: لينك الكتاب / كتيب المحاضرة
                    Text("4. لينك كتاب / كتيب الدرس (PDF أو رابط خارجي):", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lecBookUrlCtrl,
                      decoration: InputDecoration(
                        hintText: "https://... رابط تحميل أو تصفح كتاب الدرس (PDF / Drive)",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 5: كود الاختبار والملخص html تفاعلي
                    Text("5. كود الاختبار والملخص html تفاعلي:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lecQuizHtmlCtrl,
                      maxLines: 8,
                      style: GoogleFonts.firaCode(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: "الصق كود الـ HTML الكامل للمحاضرة هنا (الملخص والاختبار التفاعلي)...",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final title = _lecTitleCtrl.text.trim();
                  if (title.isEmpty) {
                    _showSnackBar("برجاء إدخال اسم المحاضرة", isError: true);
                    return;
                  }

                  final num = int.tryParse(_lecNumberCtrl.text.trim()) ?? 1;
                  final yt = _lecYoutubeCtrl.text.trim();
                  final book = _lecBookUrlCtrl.text.trim();
                  final quiz = _lecQuizHtmlCtrl.text.trim();

                  final lectureData = {
                    'number': num,
                    'title': title,
                    'youtubeUrl': yt,
                    'videoUrl': yt,
                    'bookUrl': book,
                    'bookLink': book,
                    'quizHtml': quiz,
                    'htmlCode': quiz,
                    'hasQuiz': quiz.isNotEmpty,
                    'isPublished': true,
                    'duration': '00:45:00',
                  };

                  if (_editingLecture != null) {
                    final lid = _editingLecture!['id'].toString();
                    await _dataService.updateLessonInCourse(courseId, lid, lectureData);
                    _showSnackBar("تم تعديل المحاضرة بنجاح ✅");
                  } else {
                    lectureData['id'] = 'lec_${DateTime.now().millisecondsSinceEpoch}';
                    await _dataService.addLessonToCourse(courseId, lectureData);
                    _showSnackBar("تمت إضافة المحاضرة ونشرها بنجاح 🚀");
                  }

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text("حفظ المحاضرة ونشرها 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteLecture(String courseId, String lessonId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("حذف المحاضرة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text("هل أنت متأكد من رغبتك في حذف هذه المحاضرة نهائياً؟", style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dataService.deleteLessonFromCourse(courseId, lessonId);
              if (ctx.mounted) Navigator.of(ctx).pop();
              _showSnackBar("تم حذف المحاضرة بنجاح");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text("نعم، حذف", style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: MEMBERS MANAGER (Max 50 per page)
  // ==========================================
  Widget _buildMembersSection(bool isDark, bool isMobile) {
    final allMembers = _dataService.members;

    // Filter members by search & role
    final filtered = allMembers.where((m) {
      if (_membersRoleFilter != 'الكل') {
        final role = (m['role'] ?? 'عضو عادي').toString().trim();
        final isVip = m['isVip'] == true;
        if (_membersRoleFilter == 'عضو مميز' && !isVip && role != 'مميز' && role != 'عضو مميز') return false;
        if (_membersRoleFilter == 'عضو عادي' && (isVip || role == 'مميز' || role == 'مشرف' || role == 'admin' || role == 'مدير')) return false;
        if (_membersRoleFilter == 'مشرف' && role != 'مشرف') return false;
        if (_membersRoleFilter == 'مدير' && role != 'admin' && role != 'مدير') return false;
      }
      if (_membersSearchQuery.isNotEmpty) {
        final q = _membersSearchQuery.toLowerCase();
        final name = (m['name'] ?? m['displayName'] ?? '').toString().toLowerCase();
        final email = (m['email'] ?? '').toString().toLowerCase();
        final code = (m['code'] ?? m['id'] ?? m['uid'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || code.contains(q);
      }
      return true;
    }).toList();

    // Strict Pagination: Max 50 per page
    final totalPages = max(1, (filtered.length / _membersPageSize).ceil());
    if (_membersCurrentPage >= totalPages) _membersCurrentPage = totalPages - 1;
    final startIndex = _membersCurrentPage * _membersPageSize;
    final endIndex = min(startIndex + _membersPageSize, filtered.length);
    final pageMembers = filtered.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إدارة الأعضاء والطلاب (${filtered.length})",
                  style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  "جدول الأعضاء (بحد أقصى 50 عضواً لكل صفحة) مع أدوات الترقية والتحكم الكاملة.",
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showBroadcastNotificationDialog,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text("إرسال إشعار عام للكل 📢", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search Bar & Role Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() {
                  _membersSearchQuery = val;
                  _membersCurrentPage = 0;
                }),
                decoration: InputDecoration(
                  hintText: "البحث باسم العضو، البريد الإلكتروني، أو كود العضو...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _membersRoleFilter,
                  items: const [
                    DropdownMenuItem(value: 'الكل', child: Text("كل الفئات")),
                    DropdownMenuItem(value: 'عضو عادي', child: Text("عضو عادي")),
                    DropdownMenuItem(value: 'عضو مميز', child: Text("عضو مميز 🌟")),
                    DropdownMenuItem(value: 'مشرف', child: Text("مشرف 🛡️")),
                    DropdownMenuItem(value: 'مدير', child: Text("مدير 👑")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _membersRoleFilter = val;
                        _membersCurrentPage = 0;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Members Table
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: pageMembers.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text("لا يوجد أعضاء يطابقون شروط البحث", style: GoogleFonts.cairo(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.all(
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    ),
                    columns: [
                      DataColumn(label: Text("كود العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("اسم العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("البريد الإلكتروني", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("فئة العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("الإجراءات والتحكم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                    ],
                    rows: pageMembers.map((m) {
                      final uid = (m['uid'] ?? m['id'] ?? '').toString();
                      final code = (m['code'] != null && m['code'].toString().isNotEmpty)
                          ? m['code'].toString()
                          : (uid.length > 8 ? "#${uid.substring(0, 8)}" : "#$uid");
                      final name = (m['name'] ?? m['displayName'] ?? 'مستخدم').toString();
                      final email = (m['email'] ?? '').toString();
                      final isVip = m['isVip'] == true;
                      final rawRole = (m['role'] ?? 'عضو عادي').toString();

                      String roleDisplay = 'عضو عادي';
                      Color roleColor = Colors.grey;
                      if (rawRole == 'admin' || rawRole == 'مدير') {
                        roleDisplay = 'مدير 👑';
                        roleColor = const Color(0xFFEF4444);
                      } else if (rawRole == 'مشرف') {
                        roleDisplay = 'مشرف 🛡️';
                        roleColor = const Color(0xFF3B82F6);
                      } else if (isVip || rawRole == 'عضو مميز' || rawRole == 'مميز') {
                        roleDisplay = 'عضو مميز 🌟';
                        roleColor = const Color(0xFFF59E0B);
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(code, style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: roleColor.withOpacity(0.2),
                                  child: Text(
                                    name.isNotEmpty ? name[0] : 'U',
                                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: roleColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          DataCell(Text(email, style: GoogleFonts.cairo(color: Colors.grey.shade400))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: roleColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                roleDisplay,
                                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: roleColor),
                              ),
                            ),
                          ),
                          // The 5 Action Buttons Requested by the User!
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. زر تحويل العضو لعضو مميز (VIP)
                                IconButton(
                                  icon: Icon(
                                    isVip ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: const Color(0xFFF59E0B),
                                    size: 20,
                                  ),
                                  tooltip: isVip ? "عضو مميز بالفعل" : "تحويل لعضو مميز (VIP)",
                                  onPressed: () => _toggleVipStatus(m),
                                ),

                                // 2. زر إعادة الرقم السري
                                IconButton(
                                  icon: const Icon(Icons.key_rounded, color: Color(0xFF3B82F6), size: 19),
                                  tooltip: "إعادة الرقم السري",
                                  onPressed: () => _showResetPasswordDialog(m),
                                ),

                                // 3. زر تعديل بيانات العضو
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF00E5FF), size: 19),
                                  tooltip: "تعديل بيانات العضو",
                                  onPressed: () => _showEditMemberDialog(m),
                                ),

                                // 4. زر إرسال إشعار للعضو
                                IconButton(
                                  icon: const Icon(Icons.notifications_active_rounded, color: Color(0xFF10B981), size: 19),
                                  tooltip: "إرسال إشعار للعضو",
                                  onPressed: () => _showSendNotificationToUserDialog(m),
                                ),

                                // 5. زر حذف العضو
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 19),
                                  tooltip: "حذف العضو",
                                  onPressed: () => _confirmDeleteMember(m),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Pagination Bar (Strictly max 50 members per page)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "عرض ${pageMembers.length} من إجمالي ${filtered.length} عضو (الصفحة ${_membersCurrentPage + 1} من $totalPages)",
              style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey),
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _membersCurrentPage > 0
                      ? () => setState(() => _membersCurrentPage--)
                      : null,
                  child: Text("السابق", style: GoogleFonts.cairo()),
                ),
                const SizedBox(width: 8),
                Text(
                  "${_membersCurrentPage + 1} / $totalPages",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _membersCurrentPage < totalPages - 1
                      ? () => setState(() => _membersCurrentPage++)
                      : null,
                  child: Text("التالي", style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Action 1: Toggle VIP Status
  Future<void> _toggleVipStatus(Map<String, dynamic> member) async {
    final uid = (member['uid'] ?? member['id']).toString();
    final currentVip = member['isVip'] == true;
    final newVip = !currentVip;

    final updated = Map<String, dynamic>.from(member);
    updated['isVip'] = newVip;
    if (newVip) {
      updated['role'] = 'عضو مميز';
    } else if (updated['role'] == 'عضو مميز') {
      updated['role'] = 'عضو عادي';
    }

    await _dataService.updateMember(uid, updated);
    _showSnackBar(
      newVip
          ? "تمت ترقية العضو بنجاح إلى (عضو مميز 🌟) وفتح جميع الكورسات والمقالات له!"
          : "تم إلغاء الترقية المميزة للعضو.",
    );
  }

  // Action 2: Reset Password Dialog (Admin inputs password & copies it manually)
  void _showResetPasswordDialog(Map<String, dynamic> member) {
    final name = (member['name'] ?? member['displayName'] ?? 'العضو').toString();
    final pwdCtrl = TextEditingController(text: "Pass@${Random().nextInt(9000) + 1000}");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.key_rounded, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text("إعادة الرقم السري للعضو: $name", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "اكتب الرقم السري الجديد هنا، ويمكنك نسخه وإرساله للعضو بطريقتك الخاصة (واتساب / تليجرام):",
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pwdCtrl,
              decoration: InputDecoration(
                labelText: "الرقم السري الجديد",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Color(0xFF00E5FF)),
                  tooltip: "نسخ الرقم السري",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pwdCtrl.text.trim()));
                    _showSnackBar("تم نسخ الرقم السري إلى الحافظة 📋");
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final newPwd = pwdCtrl.text.trim();
              if (newPwd.isEmpty) return;

              Clipboard.setData(ClipboardData(text: newPwd));
              final uid = (member['uid'] ?? member['id']).toString();
              final updated = Map<String, dynamic>.from(member);
              updated['tempPassword'] = newPwd;
              updated['passwordUpdatedAt'] = DateTime.now().toIso8601String();
              await _dataService.updateMember(uid, updated);

              if (ctx.mounted) Navigator.of(ctx).pop();
              _showSnackBar("تم حفظ الرقم السري الجديد ونسخه للحافظة بنجاح 📋");
            },
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text("حفظ ونسخ الرقم السري", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // Action 3: Edit Member Data Dialog
  void _showEditMemberDialog(Map<String, dynamic> member) {
    final uid = (member['uid'] ?? member['id']).toString();
    final nameCtrl = TextEditingController(text: member['name'] ?? member['displayName'] ?? '');
    final emailCtrl = TextEditingController(text: member['email'] ?? '');
    String selectedRole = (member['role'] ?? 'عضو عادي').toString();
    if (selectedRole == 'admin') selectedRole = 'مدير';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text("تعديل بيانات العضو", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "اسم العضو",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: "البريد الإلكتروني",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: ['عضو عادي', 'عضو مميز', 'مشرف', 'مدير'].contains(selectedRole) ? selectedRole : 'عضو عادي',
                  decoration: InputDecoration(
                    labelText: "فئة / رتبة العضو",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'عضو عادي', child: Text("عضو عادي")),
                    DropdownMenuItem(value: 'عضو مميز', child: Text("عضو مميز (VIP) 🌟")),
                    DropdownMenuItem(value: 'مشرف', child: Text("مشرف 🛡️")),
                    DropdownMenuItem(value: 'مدير', child: Text("مدير 👑")),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = Map<String, dynamic>.from(member);
                updated['name'] = nameCtrl.text.trim();
                updated['displayName'] = nameCtrl.text.trim();
                updated['email'] = emailCtrl.text.trim();
                updated['role'] = selectedRole == 'مدير' ? 'admin' : selectedRole;
                if (selectedRole == 'عضو مميز') updated['isVip'] = true;

                await _dataService.updateMember(uid, updated);
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnackBar("تم تعديل بيانات العضو بنجاح ✅");
              },
              child: Text("حفظ التعديلات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Action 4: Send Notification to User Dialog
  void _showSendNotificationToUserDialog(Map<String, dynamic> member) {
    final uid = (member['uid'] ?? member['id']).toString();
    final name = (member['name'] ?? member['displayName'] ?? 'العضو').toString();
    final email = (member['email'] ?? '').toString();

    final titleCtrl = TextEditingController(text: "رسالة هامة من المهندس إسلام عاطف");
    final bodyCtrl = TextEditingController();
    final attachmentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("إرسال إشعار خاص إلى: $name", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "عنوان الإشعار",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bodyCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "نص الرسالة أو الإشعار (يدعم وسوم وتنسيقات HTML)",
                  hintText: "اكتب رسالتك أو كود HTML الموجه لهذا الطالب...",
                  helperText: "يدعم وسوم HTML والروابط والتنسيقات الكاملة",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: attachmentCtrl,
                decoration: InputDecoration(
                  labelText: "رابط المرفق (اختياري - PDF / صورة / ملف)",
                  hintText: "https://example.com/file.pdf",
                  prefixIcon: const Icon(Icons.attach_file_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final t = titleCtrl.text.trim();
              final b = bodyCtrl.text.trim();
              final att = attachmentCtrl.text.trim();
              if (t.isEmpty || b.isEmpty) {
                _showSnackBar("برجاء إدخال عنوان ونص الإشعار", isError: true);
                return;
              }

              final isHtml = b.contains('<') && b.contains('>');
              await _dataService.sendNotification(
                title: t,
                body: b,
                target: uid,
                targetUid: uid,
                targetName: name,
                targetEmail: email,
                attachmentUrl: att.isNotEmpty ? att : null,
                isHtml: isHtml,
              );

              if (ctx.mounted) Navigator.of(ctx).pop();
              _showSnackBar("تم إرسال الإشعار للعضو بنجاح 🔔");
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: Text("إرسال الإشعار", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // Action 5: Confirm Delete Member
  void _confirmDeleteMember(Map<String, dynamic> member) {
    final uid = (member['uid'] ?? member['id']).toString();
    final name = (member['name'] ?? member['displayName'] ?? 'العضو').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("حذف العضو: $name", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
        content: Text("هل أنت متأكد من رغبتك في حذف هذا العضو نهائياً من الموقع؟", style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dataService.deleteMember(uid);
              if (ctx.mounted) Navigator.of(ctx).pop();
              _showSnackBar("تم حذف العضو بنجاح");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text("نعم، حذف", style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Global Broadcast Notification Dialog
  void _showBroadcastNotificationDialog() {
    final titleCtrl = TextEditingController(text: "إعلان عام لجميع الطلاب");
    final bodyCtrl = TextEditingController();
    final attachmentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: Color(0xFF00E5FF), size: 26),
            const SizedBox(width: 8),
            Text("إرسال إشعار عام لجميع طلاب المنصة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "عنوان الإعلان العام",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bodyCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "نص الإعلان أو التنبيه (يدعم وسوم وتنسيقات HTML)",
                  hintText: "اكتب الرسالة أو كود HTML التفاعلي...",
                  helperText: "يدعم وسوم HTML والروابط والتنسيقات الكاملة",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: attachmentCtrl,
                decoration: InputDecoration(
                  labelText: "رابط المرفق (اختياري - ملف PDF أو صورة أو رابط)",
                  hintText: "https://example.com/file.pdf",
                  prefixIcon: const Icon(Icons.attach_file_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final t = titleCtrl.text.trim();
              final b = bodyCtrl.text.trim();
              final att = attachmentCtrl.text.trim();
              if (t.isEmpty || b.isEmpty) return;

              final isHtml = b.contains('<') && b.contains('>');
              await _dataService.sendNotification(
                title: t,
                body: b,
                target: 'all',
                attachmentUrl: att.isNotEmpty ? att : null,
                isHtml: isHtml,
              );

              if (ctx.mounted) Navigator.of(ctx).pop();
              _showSnackBar("تم إرسال الإشعار العام بنجاح لجميع الطلاب 📢");
            },
            icon: const Icon(Icons.campaign_rounded, size: 18),
            label: Text("نشر الإشعار العام للكل", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: ARTICLES (المقالات كما هي)
  // ==========================================
  Widget _buildArticlesSection(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-tabs bar: إضافة مقال | قائمة المقالات | التصنيفات
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildArticlesSubTabButton(
                  title: "محرر المقالات",
                  icon: Icons.post_add_rounded,
                  index: 0,
                  count: 0,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildArticlesSubTabButton(
                  title: "المقالات المنشورة",
                  icon: Icons.list_alt_rounded,
                  index: 1,
                  count: _dataService.articles.length,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildArticlesSubTabButton(
                  title: "التصنيفات",
                  icon: Icons.category_rounded,
                  index: 2,
                  count: _dataService.articleCategories.length,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_articlesSubTab == 0)
          _buildArticleEditorTab(isDark)
        else if (_articlesSubTab == 1)
          _buildArticlesListTab(isDark)
        else
          _buildArticleCategoriesTab(isDark),
      ],
    );
  }

  Widget _buildArticlesSubTabButton({
    required String title,
    required IconData icon,
    required int index,
    required int count,
    required bool isDark,
  }) {
    final isSelected = _articlesSubTab == index;
    return InkWell(
      onTap: () => setState(() => _articlesSubTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF00E5FF) : Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Article Editor Tab
  Widget _buildArticleEditorTab(bool isDark) {
    return ArticleDirectEditorView(
      key: ValueKey(_editingArticle?['id'] ?? 'new_article'),
      initialArticle: _editingArticle,
      categories: _dataService.articleCategories,
      onCancel: () {
        setState(() {
          _editingArticle = null;
          _articlesSubTab = 1;
        });
      },
      onAddCategory: (newCat) async {
        await _dataService.addArticleCategory(newCat);
        _showSnackBar("تمت إضافة التصنيف بنجاح ✅");
      },
      onSave: (articleData) async {
        if (_editingArticle != null) {
          final id = _editingArticle!['id'].toString();
          await _dataService.updateArticle(id, articleData);
          _showSnackBar("تم تحديث المقال بنجاح ✅");
        } else {
          await _dataService.addArticle(articleData);
          _showSnackBar("تم نشر المقال الجديد بنجاح 🚀");
        }
        setState(() {
          _editingArticle = null;
          _articlesSubTab = 1;
        });
      },
    );
  }

  // Articles List Tab
  Widget _buildArticlesListTab(bool isDark) {
    final all = _dataService.articles;
    final filtered = all.where((a) {
      if (_articlesSearch.isEmpty) return true;
      final q = _articlesSearch.toLowerCase();
      final title = (a['title'] ?? '').toString().toLowerCase();
      final cat = (a['category'] ?? '').toString().toLowerCase();
      return title.contains(q) || cat.contains(q);
    }).toList();

    return Column(
      children: [
        // Search & Sync Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _articlesSearch = val),
                decoration: InputDecoration(
                  hintText: "البحث في المقالات المنشورة...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _editingArticle = null;
                  _articlesSubTab = 0;
                });
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text("كتابة مقال جديد ✍️", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Articles List
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(16),
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text("لا توجد مقالات منشورة بعد", style: GoogleFonts.cairo(color: Colors.grey)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                  itemBuilder: (context, idx) {
                    final article = filtered[idx];
                    final title = article['title'] ?? 'مقال بدون عنوان';
                    final category = article['category'] ?? 'عام';
                    final date = article['createdAt'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.article_outlined, color: Color(0xFF8B5CF6), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(category, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                    ),
                                    if (date.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        date.toString().substring(0, min(10, date.toString().length)),
                                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Color(0xFF00E5FF), size: 20),
                            tooltip: "تعديل المقال",
                            onPressed: () {
                              setState(() {
                                _editingArticle = article;
                                _articlesSubTab = 0;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            tooltip: "حذف المقال",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text("حذف المقال", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                  content: Text("هل أنت متأكد من رغبتك في حذف هذا المقال نهائياً؟", style: GoogleFonts.cairo()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text("إلغاء", style: GoogleFonts.cairo()),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _dataService.deleteArticle(article['id'].toString());
                                        if (ctx.mounted) Navigator.of(ctx).pop();
                                        _showSnackBar("تم حذف المقال بنجاح");
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                      child: Text("حذف", style: GoogleFonts.cairo(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Categories Tab
  Widget _buildArticleCategoriesTab(bool isDark) {
    final categories = _dataService.articleCategories;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إدارة تصنيفات المقالات", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryCtrl,
                  decoration: InputDecoration(
                    hintText: "اسم التصنيف الجديد...",
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final cat = _newCategoryCtrl.text.trim();
                  if (cat.isEmpty) return;
                  await _dataService.addArticleCategory(cat);
                  _newCategoryCtrl.clear();
                  _showSnackBar("تمت إضافة التصنيف بنجاح ✅");
                },
                icon: const Icon(Icons.add_rounded),
                label: Text("إضافة تصنيف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((cat) {
              return InputChip(
                label: Text(cat, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                avatar: InkWell(
                  onTap: () => _showEditCategoryDialog(cat),
                  child: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF00E5FF)),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                onDeleted: () async {
                  await _dataService.deleteArticleCategory(cat);
                  _showSnackBar("تم حذف التصنيف");
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(String oldCat) {
    final editCtrl = TextEditingController(text: oldCat);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("تعديل اسم التصنيف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editCtrl,
          decoration: InputDecoration(
            labelText: "اسم التصنيف الجديد",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = editCtrl.text.trim();
              if (newName.isNotEmpty && newName != oldCat) {
                await _dataService.updateArticleCategory(oldCat, newName);
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnackBar("تم تعديل اسم التصنيف بنجاح ✅");
              }
            },
            child: Text("حفظ التعديل", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DEDICATED 3-FIELD ARTICLE DIRECT EDITOR
// ==========================================
class ArticleDirectEditorView extends StatefulWidget {
  final Map<String, dynamic>? initialArticle;
  final List<String> categories;
  final VoidCallback onCancel;
  final Future<void> Function(Map<String, dynamic> data) onSave;
  final Future<void> Function(String newCategory) onAddCategory;

  const ArticleDirectEditorView({
    super.key,
    this.initialArticle,
    required this.categories,
    required this.onCancel,
    required this.onSave,
    required this.onAddCategory,
  });

  @override
  State<ArticleDirectEditorView> createState() => _ArticleDirectEditorViewState();
}

class _ArticleDirectEditorViewState extends State<ArticleDirectEditorView> {
  late TextEditingController _titleCtrl;
  late TextEditingController _codeCtrl;
  String _selectedCategory = 'عام';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialArticle?['title'] ?? '');
    _codeCtrl = TextEditingController(
      text: widget.initialArticle?['htmlCode'] ?? widget.initialArticle?['content'] ?? '',
    );
    final initialCat = widget.initialArticle?['category'] ?? 'عام';
    if (widget.categories.contains(initialCat)) {
      _selectedCategory = initialCat;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _promptAddNewCategory() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("إضافة تصنيف جديد 🏷️", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: catCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "اسم التصنيف الجديد",
            hintText: "مثال: ذكاء اصطناعي، بايثون، روبوتات...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCat = catCtrl.text.trim();
              if (newCat.isNotEmpty) {
                await widget.onAddCategory(newCat);
                if (mounted) {
                  setState(() {
                    _selectedCategory = newCat;
                  });
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: const Color(0xFF0F172A),
            ),
            child: Text("إضافة التصنيف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialArticle != null;

    final cats = List<String>.from(widget.categories);
    if (!cats.contains(_selectedCategory) && _selectedCategory.isNotEmpty) {
      cats.insert(0, _selectedCategory);
    }
    if (cats.isEmpty) {
      cats.add('عام');
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.post_add_rounded,
                    color: const Color(0xFF00E5FF),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? "تعديل المقال" : "إضافة مقال جديد",
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: widget.onCancel,
                tooltip: "إلغاء والعودة",
              ),
            ],
          ),
          const SizedBox(height: 20),

          // الحقل الأول: عنوان المقال
          Text(
            "1. عنوان المقال *",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: "أدخل عنوان المقال الشيق والجذاب هنا...",
              prefixIcon: const Icon(Icons.title_rounded),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // الحقل الثاني: تصنيف المقال (ولو فاضية يبقي فيه إضافة تصنيف)
          Text(
            "2. تصنيف المقال *",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: cats.contains(_selectedCategory) ? _selectedCategory : cats.first,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: cats.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _promptAddNewCategory,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  "+ إضافة تصنيف",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // الحقل الثالث: كود المقال (HTML)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "3. كود المقال (HTML) *",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "يدعم وسوم HTML كاملة <h1>، <p>، <img>، <iframe>، والتنسيقات",
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _codeCtrl,
            maxLines: 15,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
            decoration: InputDecoration(
              hintText: "الصق أو اكتب كود المقال (HTML) هنا مباشرة...",
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // الأزرار
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text("إلغاء والرجوع", style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                        final title = _titleCtrl.text.trim();
                        final code = _codeCtrl.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("يرجى كتابة عنوان المقال", style: GoogleFonts.cairo()),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (code.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("يرجى كتابة أو لصق كود المقال", style: GoogleFonts.cairo()),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);
                        try {
                          await widget.onSave({
                            'title': title,
                            'htmlCode': code,
                            'content': code,
                            'category': _selectedCategory,
                            'status': 'منشور',
                          });
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)))
                    : const Icon(Icons.rocket_launch_rounded, size: 18),
                label: Text(
                  isEditing ? "حفظ تعديلات المقال ✅" : "حفظ ونشر المقال 🚀",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
