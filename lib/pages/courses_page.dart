// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/site_data_service.dart';
import '../services/auth_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/interactive_html_view/interactive_html_view.dart';
import '../widgets/youtube_embedded_player.dart';
import '../widgets/auth_modal.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/pdf_viewer/pdf_viewer_modal.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _dataService = SiteDataService.instance;
  Map<String, dynamic>? _activeCourse; // null = Folders list, non-null = Course details & lessons
  Map<String, dynamic>? _activeLesson; // Currently playing lesson/video
  final Set<String> _enrolledCourseIds = {};
  final Set<String> _watchedLessonIds = {};
  StreamSubscription? _popStateSubscription;

  // The 8 Official Courses of Eslam Atef | Code & AI
  final List<Map<String, dynamic>> _officialCourses = [
    {
      "id": "01_cs_fundamentals",
      "number": "01",
      "title": "البرمجة والذكاء الاصطناعي للأطفال | من الصفر للاحتراف",
      "titleEn": "Programming & AI for Kids | Zero to Hero",
      "category": "الكورس التأسيسي الشامل",
      "badge": "متاح الآن بالكامل 🔥",
      "badgeColor": const Color(0xFF00E5FF),
      "duration": "14 محاضرة تفاعلية كاملة",
      "desc": "المدخل الشامل لفهم ما بداخل الكمبيوتر، كيفية عمل الإنترنت والشبكات، الأمان الرقمي، ومدخل الخوارزميات والبرمجة مع 14 محاضرة وواجبات تفاعلية.",
      "image": "assets/images/courses/course_01.png",
      "icon": Icons.laptop_chromebook_rounded,
      "color": const Color(0xFF00E5FF),
      "isPrimary": true,
      "route": "/courses?course=01_cs_fundamentals",
    },
    {
      "id": "02_algorithms",
      "number": "02",
      "title": "كورس الخوارزميات والتفكير المنطقي",
      "titleEn": "Algorithms & Computational Thinking",
      "category": "تفكير حسابي ومنطقي",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "12 محاضرة تطبيقية",
      "desc": "تطوير العقلية المنطقية والتفكير الحسابي، تفكيك المسائل المعقدة، خوارزميات البحث والترتيب، والتحضير لمسابقات البرمجة العالمية.",
      "image": "assets/images/courses/course_02.png",
      "icon": Icons.psychology_rounded,
      "color": const Color(0xFF8B5CF6),
      "isPrimary": false,
      "route": "/courses",
    },
    {
      "id": "03_scratch",
      "number": "03",
      "title": "كورس سكراتش وصناعة الألعاب",
      "titleEn": "Scratch Programming & Game Design",
      "category": "برمجة مرئية بالبلوكات",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "12 محاضرة إبداعية",
      "desc": "مدخل البرمجة المرئية بالبلوكات، صناعة الرسوم المتحركة، القصص التفاعلية، وبرمجة ألعاب 2D ممتعة تبني التفكير المنطقي بلا تعقيد.",
      "image": "assets/images/courses/course_03.png",
      "icon": Icons.sports_esports_rounded,
      "color": const Color(0xFF10B981),
      "isPrimary": false,
      "route": "/courses",
    },
    {
      "id": "04_python",
      "number": "04",
      "title": "كورس لغة بايثون للأطفال واليافعين",
      "titleEn": "Python Programming",
      "category": "لغات العصر البرمجية",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "16 محاضرة تطبيقية",
      "desc": "الانتقال لكتابة الكود النصي الحقيقي، المتغيرات، الشروط، الحلقات، وبناء برامج وألعاب تفاعلية بمكتبات بايثون الشهيرة خطوة بخطوة.",
      "image": "assets/images/courses/course_04.png",
      "icon": Icons.code_rounded,
      "color": const Color(0xFF3B82F6),
      "isPrimary": false,
      "route": "/courses",
    },
    {
      "id": "05_ai_tools",
      "number": "05",
      "title": "كورس أدوات وهندسة أوامر الذكاء الاصطناعي",
      "titleEn": "AI Tools & Prompt Engineering",
      "category": "تقنيات المستقبل",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "10 محاضرات عملية",
      "desc": "احتراف استخدام نماذج الذكاء الاصطناعي التوليدي، كتابة الأوامر الفائقة (Prompt Engineering)، وتوظيف الـ AI في الدراسة والتصميم والابتكار.",
      "image": "assets/images/courses/course_05.png",
      "icon": Icons.smart_toy_rounded,
      "color": const Color(0xFF0D9488),
      "isPrimary": false,
      "route": "/courses",
    },
    {
      "id": "06_ai_agents",
      "number": "06",
      "title": "كورس وكلاء الذكاء الاصطناعي المستقلة",
      "titleEn": "AI Autonomous Agents",
      "category": "ذكاء اصطناعي متقدم",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "12 محاضرة متقدمة",
      "desc": "فهم وبناء الأنظمة الذكية المستقلة التي تخطط وتنفذ المشاريع المعقدة بنفسها وكيفية توجيه الوكلاء الأذكياء لحل المشكلات.",
      "image": "assets/images/courses/course_06.png",
      "icon": Icons.precision_manufacturing_rounded,
      "color": const Color(0xFFF59E0B),
      "isPrimary": false,
      "route": "/courses",
    },
    {
      "id": "07_cybersecurity",
      "number": "07",
      "title": "كورس الأمان السيبراني والدفاع الرقمي",
      "titleEn": "Cybersecurity & Digital Defense",
      "category": "أمان وحماية الأنظمة",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "10 محاضرات حية",
      "desc": "أسرار حماية البيانات، تشفير المعلومات، كشف محاولات الاختراق والتصيد الاحتيالي، وبناء درع أمني رقمي للجيل القادم.",
      "image": "assets/images/courses/course_07.png",
      "icon": Icons.security_rounded,
      "color": const Color(0xFFEF4444),
      "isPrimary": false,
      "route": "/courses",
    },
    {
      "id": "08_roblox_lua",
      "number": "08",
      "title": "كورس برمجة ألعاب روبلوكس بلغة Lua",
      "titleEn": "Roblox Coding with Lua",
      "category": "صناعة ألعاب 3D",
      "badge": "قريباً ⏳",
      "badgeColor": const Color(0xFF64748B),
      "duration": "14 محاضرة ممتعة",
      "desc": "تعلم لغة البرمجة الحقيقية Lua داخل محرك Roblox Studio، بناء عوالم ثلاثية الأبعاد تفاعلية، برمجة آليات اللعب ونشر الألعاب عالمياً.",
      "image": "assets/images/courses/course_08.png",
      "icon": Icons.videogame_asset_rounded,
      "color": const Color(0xFFEC4899),
      "isPrimary": false,
      "route": "/courses",
    },
  ];

  String _extractYouTubeUrl(String content, [String? explicitUrl]) {
    if (explicitUrl != null && explicitUrl.trim().length > 5) {
      return explicitUrl.trim();
    }
    if (content.isEmpty) return '';

    final embedMatch = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)', caseSensitive: false).firstMatch(content);
    if (embedMatch != null) {
      return 'https://www.youtube.com/watch?v=${embedMatch.group(1)}';
    }

    final shortMatch = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)', caseSensitive: false).firstMatch(content);
    if (shortMatch != null) {
      return 'https://www.youtube.com/watch?v=${shortMatch.group(1)}';
    }

    final watchMatch = RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)', caseSensitive: false).firstMatch(content);
    if (watchMatch != null) {
      return 'https://www.youtube.com/watch?v=${watchMatch.group(1)}';
    }

    return '';
  }

  bool _isItemPublished(Map<String, dynamic> item) {
    if (item['status'] == 'مسودة') {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email?.toLowerCase() ?? '';
      return userEmail == 'islamatef01016834012@gmail.com' || AuthService.instance.isAdmin;
    }

    if (item['status'] == 'مجدول') {
      final schedStr = (item['scheduledPublishDate'] ?? item['scheduledDate'])?.toString();
      if (schedStr != null && schedStr.isNotEmpty) {
        try {
          final schedDate = DateTime.parse(schedStr).toLocal();
          if (schedDate.isAfter(DateTime.now())) {
            final user = FirebaseAuth.instance.currentUser;
            final userEmail = user?.email?.toLowerCase() ?? '';
            return userEmail == 'islamatef01016834012@gmail.com' || AuthService.instance.isAdmin;
          }
        } catch (_) {}
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkUrlParameters();
    _dataService.addListener(_onDataChanged);
    _checkEnrollment();

    try {
      _popStateSubscription = html.window.onPopState.listen((event) {
        if (!mounted) return;
        setState(() {
          _checkUrlParameters();
        });
      });

      html.window.onMessage.listen((event) {
        try {
          final data = event.data;
          if (data is Map && data['type'] == 'QUIZ_SUBMITTED') {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && _activeLesson != null) {
              final cid = (_activeCourse?['id'] ?? '').toString();
              final lid = (_activeLesson?['id'] ?? '').toString();
              final score = int.tryParse(data['score'].toString()) ?? 10;
              final total = int.tryParse(data['total'].toString()) ?? 10;
              _dataService.submitQuizResult(
                quizId: lid,
                quizTitle: (_activeLesson?['title'] ?? 'اختبار المحاضرة').toString(),
                courseId: cid,
                userId: user.uid,
                userName: user.displayName ?? user.email?.split('@').first ?? 'طالب الأكاديمية',
                score: score,
                totalQuestions: total,
              );
            }
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  void _checkUrlParameters() {
    try {
      final uri = Uri.base;
      final Map<String, String> params = Map.from(uri.queryParameters);
      if (uri.hasFragment && uri.fragment.contains('?')) {
        try {
          final queryPart = uri.fragment.substring(uri.fragment.indexOf('?') + 1);
          params.addAll(Uri.splitQueryString(queryPart));
        } catch (_) {}
      }

      final courseId = params['course'] ?? params['courseId'] ?? params['id'] ?? params['c'];
      final lessonId = params['lesson'] ?? params['lessonId'] ?? params['l'];

      if (courseId != null && courseId.isNotEmpty) {
        Map<String, dynamic>? targetCourse;
        final off = _officialCourses.where((c) => c['id'].toString() == courseId).toList();
        if (off.isNotEmpty) {
          targetCourse = off.first;
        } else {
          final cloud = _dataService.courses.where((c) => c['id'].toString() == courseId && _isItemPublished(c)).toList();
          if (cloud.isNotEmpty) targetCourse = cloud.first;
        }

        if (targetCourse != null) {
          if (_activeCourse == null || _activeCourse!['id'] != targetCourse['id']) {
            _openCourseContent(targetCourse);
          }
          if (lessonId != null && lessonId.isNotEmpty) {
            final lessons = List<Map<String, dynamic>>.from(_activeCourse!['lessons'] ?? []).where(_isItemPublished).toList();
            final matched = lessons.where((l) => (l['id'] ?? '').toString() == lessonId).toList();
            _activeLesson = matched.isNotEmpty ? matched.first : null;
          } else {
            _activeLesson = null;
          }
        } else {
          _activeCourse = null;
          _activeLesson = null;
        }
      } else {
        _activeCourse = null;
        _activeLesson = null;
      }
    } catch (_) {}
  }

  void _syncUrl({bool replace = false}) {
    try {
      String newUrl;
      if (_activeCourse != null) {
        final cid = (_activeCourse!['id'] ?? '').toString();
        if (_activeLesson != null) {
          final lid = (_activeLesson!['id'] ?? '').toString();
          newUrl = '/courses?course=$cid&lesson=$lid';
        } else {
          newUrl = '/courses?course=$cid';
        }
      } else {
        newUrl = '/courses';
      }

      final currentUri = Uri.base;
      final currentPathAndQuery = '${currentUri.path}${currentUri.hasQuery ? '?${currentUri.query}' : ''}';
      if (currentPathAndQuery == newUrl) return;

      if (replace) {
        html.window.history.replaceState(null, '', newUrl);
      } else {
        html.window.history.pushState(null, '', newUrl);
      }
    } catch (_) {}
  }

  void _handleBack() {
    if (_activeLesson != null) {
      setState(() => _activeLesson = null);
      _syncUrl(replace: true);
    } else if (_activeCourse != null) {
      setState(() => _activeCourse = null);
      _syncUrl(replace: true);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  void _copyLink(String url, String message) {
    Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _checkEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _activeCourse != null) {
      final cid = _activeCourse!['id']?.toString() ?? '';
      final enrolled = await _dataService.isEnrolled(courseId: cid, userId: user.uid);
      if (enrolled) {
        _enrolledCourseIds.add(cid);
      }
      final watched = await _dataService.getWatchedLessons(courseId: cid, userId: user.uid);
      _watchedLessonIds.addAll(watched);
      if (mounted) setState(() {});
    }
  }

  void _onDataChanged() {
    if (mounted) {
      if (_activeCourse == null) {
        _checkUrlParameters();
      } else {
        final cid = _activeCourse!['id']?.toString() ?? '';
        final fromService = _dataService.courses.firstWhere(
          (dc) => dc['id'] == cid,
          orElse: () => <String, dynamic>{},
        );
        if (fromService.isNotEmpty) {
          _activeCourse!['lessons'] = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);
        }
      }
      _checkEnrollment();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _popStateSubscription?.cancel();
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  bool _isAdmin(User? user) {
    if (user == null) return false;
    if (user.email == 'islamatef01016834012@gmail.com') return true;
    final cached = _dataService.members.firstWhere(
      (m) => m['uid'] == user.uid || m['email'] == user.email,
      orElse: () => <String, dynamic>{},
    );
    return cached['role'] == 'admin';
  }

  bool _isUserEnrolled({required String courseId, required bool isPaid}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    if (_isAdmin(user)) return true;
    if (_enrolledCourseIds.contains(courseId)) return true;
    if (isPaid) {
      final cached = _dataService.members.firstWhere((m) => m['uid'] == user.uid, orElse: () => <String, dynamic>{});
      final allowedCourses = List<String>.from(cached['allowedCourses'] ?? []);
      return allowedCourses.contains(courseId);
    }
    return false;
  }

  bool _canAccessLesson({required String courseId, required String lessonId, required bool isPaid}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    if (_isAdmin(user)) return true;
    if (!_isUserEnrolled(courseId: courseId, isPaid: isPaid)) return false;
    if (!isPaid) return true;
    final cached = _dataService.members.firstWhere((m) => m['uid'] == user.uid, orElse: () => <String, dynamic>{});
    final allowedCourses = List<String>.from(cached['allowedCourses'] ?? []);
    if (allowedCourses.contains(courseId)) return true;
    final allowedLessons = List<String>.from(cached['allowedLessons'] ?? []);
    return allowedLessons.contains(lessonId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _activeLesson == null && _activeCourse == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/courses') : null,
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SelectionArea(
            child: SafeArea(
              child: Column(
                children: [
                  UnifiedAppHeader(
                    currentRoute: '/courses',
                    pageTitle: 'الكورسات والمسارات البرمجية',
                    showBackButton: _activeLesson != null || _activeCourse != null,
                    onBack: (_activeLesson != null || _activeCourse != null)
                        ? _handleBack
                        : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 28),
                            _activeLesson != null
                                ? _buildLessonVideoPlayerView(context, isMobile, isDark)
                                : _activeCourse != null
                                    ? _buildCourseInsideView(context, isMobile, isDark)
                                    : _buildCourseFoldersCatalog(context, isMobile, isDark),
                            const SizedBox(height: 60),
                            const UnifiedAppFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // ==========================================
  // VIEW 1: Course Folders Catalog (8 Official Courses)
  // ==========================================
  Widget _buildCourseFoldersCatalog(BuildContext context, bool isMobile, bool isDark) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1220),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section Header Banner
            Container(
              padding: EdgeInsets.all(isMobile ? 22 : 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                      : [Colors.white, const Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "المسارات البرمجية المعتمدة (8 كورسات تخصصية متدرجة)",
                      style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "كورسات أكاديمية Eslam Atef | Code & AI",
                    style: GoogleFonts.cairo(fontSize: isMobile ? 22 : 32, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 750),
                    child: Text(
                      "منهج عملي تطبيقي متدرج ينقل طفلك من فهم أساسيات التكنولوجيا حتى احتراف لغات البرمجة والذكاء الاصطناعي وصناعة الألعاب خطوة بخطوة.",
                      style: GoogleFonts.cairo(fontSize: isMobile ? 13 : 15, color: Colors.grey, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Responsive Grid for 8 Course Cards
            LayoutBuilder(
              builder: (ctx, constraints) {
                int cols = constraints.maxWidth < 650 ? 1 : (constraints.maxWidth < 980 ? 2 : 3);
                final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

                return Wrap(
                  spacing: 20,
                  runSpacing: 22,
                  children: _officialCourses.map((course) {
                    return SizedBox(
                      width: width,
                      child: _buildOfficialCourseCard(context, course, isDark, isMobile),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCourseContent(Map<String, dynamic> c) {
    final courseData = Map<String, dynamic>.from(c);
    final fromService = _dataService.courses.firstWhere(
      (dc) => dc['id'] == c['id'],
      orElse: () => <String, dynamic>{},
    );
    final serviceLessons = List<Map<String, dynamic>>.from(fromService['lessons'] ?? []);
    courseData['lessons'] = serviceLessons;
    courseData['isPaid'] = fromService['isPaid'] ?? c['isPaid'] ?? false;

    setState(() {
      _activeCourse = courseData;
      _activeLesson = null;
    });
    _syncUrl();
  }

  Widget _buildOfficialCourseCard(BuildContext context, Map<String, dynamic> c, bool isDark, bool isMobile) {
    final bool isPrimary = c["isPrimary"] == true;
    final String imagePath = c["image"] as String;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF00E5FF)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color(0xFF00E5FF).withOpacity(0.2)
                : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: isPrimary ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Course Thumbnail Image Container (STRICT 16:9 Aspect Ratio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF131D31),
                      child: const Center(
                        child: Icon(Icons.code_rounded, size: 48, color: Color(0xFF00E5FF)),
                      ),
                    ),
                  ),

                  // Status Badge (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPrimary ? const Color(0xFF0284C7) : const Color(0xFF334155).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPrimary ? "متاح الآن بالكامل 🔥" : "قريباً ⏳",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Card Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    c["title"] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // If NOT Primary (Courses 2..8): strictly show "قريباً" badge and NOTHING ELSE!
                  if (!isPrimary) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_empty_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            "قريباً",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // For Course 01: Direct Action Button (Requires User Login)
                    const SizedBox(height: 14),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              showDialog(context: context, builder: (c) => const AuthModal());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "يرجى تسجيل الدخول أولاً للوصول إلى محتوى الكورس 🔐",
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: const Color(0xFF0284C7),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            _openCourseContent(c);
                          },
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                          label: Text(
                            "اضغط هنا لبدا الكورس",
                            style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: const Color(0xFF070B14),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
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
    );
  }

  // ==========================================
  // VIEW 2: Inside Course Folder (For9a-Style Two-Column Layout)
  // ==========================================
  Widget _buildCourseInsideView(BuildContext context, bool isMobile, bool isDark) {
    final course = _activeCourse!;
    final courseId = course['id']?.toString() ?? '';
    // STRICT RULE: Only show lessons that have a real, published video link!
    final lessons = List<Map<String, dynamic>>.from(course['lessons'] ?? [])
        .where(_isItemPublished)
        .where((l) {
          final yt = (l['youtubeUrl'] ?? l['videoUrl'] ?? '').toString().trim();
          return yt.isNotEmpty;
        })
        .toList();

    final isPaid = course['isPaid'] == true;
    final user = FirebaseAuth.instance.currentUser;
    final isEnrolled = _isUserEnrolled(courseId: courseId, isPaid: isPaid);

    final totalDurationStr = _calculateTotalDuration(lessons);
    final hoursBadgeStr = _calculateHoursBadge(lessons);
    final totalCount = lessons.length;
    final lecturesCountStr = "$totalCount ${totalCount <= 10 ? 'محاضرات' : 'محاضرة'}";

    // Split lessons into Level 1, Level 2, and any extra
    final level1Lessons = lessons.where((l) {
      final lvl = l['levelNumber'];
      final num = l['number'] ?? 0;
      return lvl == 1 || (num >= 1 && num <= 5);
    }).toList();

    final level2Lessons = lessons.where((l) {
      final lvl = l['levelNumber'];
      final num = l['number'] ?? 0;
      return lvl == 2 || (num >= 6 && num <= 14);
    }).toList();

    final extraLessons = lessons.where((l) => !level1Lessons.contains(l) && !level2Lessons.contains(l)).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Breadcrumbs Navigation Row
            _buildBreadcrumbsRow(course, isMobile, isDark),
            const SizedBox(height: 20),

            // 2. Top Hero Card (Title, Badges, Instructor, 16:9 Thumbnail)
            _buildCourseHeroCard(
              course: course,
              lessons: lessons,
              hoursBadgeStr: hoursBadgeStr,
              lecturesCountStr: lecturesCountStr,
              isDark: isDark,
              isMobile: isMobile,
            ),
            const SizedBox(height: 32),

            // 3. Two-Column Layout (Main Content on right, Sidebar card on left)
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Content Column (محتوى الدورة)
                  Expanded(
                    flex: 66,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCourseModulesContent(
                          context,
                          course,
                          level1Lessons,
                          level2Lessons,
                          extraLessons,
                          lecturesCountStr,
                          isEnrolled,
                          isDark,
                        ),
                        const SizedBox(height: 24),
                        _buildCoursePdfCard(course, isDark, isMobile),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Sidebar Column (معلومات سريعة عن الدورة + زر البدء)
                  Expanded(
                    flex: 34,
                    child: _buildCourseSidebarCard(
                      context,
                      course,
                      lessons,
                      totalDurationStr,
                      lecturesCountStr,
                      isEnrolled,
                      user,
                      isDark,
                      isMobile,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCourseSidebarCard(
                    context,
                    course,
                    lessons,
                    totalDurationStr,
                    lecturesCountStr,
                    isEnrolled,
                    user,
                    isDark,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildCourseModulesContent(
                    context,
                    course,
                    level1Lessons,
                    level2Lessons,
                    extraLessons,
                    lecturesCountStr,
                    isEnrolled,
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildCoursePdfCard(course, isDark, isMobile),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- Dynamic Duration & Count Helpers ---
  String _calculateTotalDuration(List<Map<String, dynamic>> lessons) {
    int totalSeconds = 0;
    for (final l in lessons) {
      final durStr = (l['duration'] ?? '').toString().trim();
      final parts = durStr.split(':');
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        totalSeconds += (h * 3600) + (m * 60) + s;
      } else if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        totalSeconds += (m * 60) + s;
      }
    }
    if (totalSeconds == 0) return '02:10:45';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$hStr:$mStr:$sStr';
  }

  String _calculateHoursBadge(List<Map<String, dynamic>> lessons) {
    int totalSeconds = 0;
    for (final l in lessons) {
      final durStr = (l['duration'] ?? '').toString().trim();
      final parts = durStr.split(':');
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        totalSeconds += (h * 3600) + (m * 60) + s;
      } else if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        totalSeconds += (m * 60) + s;
      }
    }
    final hours = (totalSeconds / 3600).ceil();
    if (hours <= 0) return '+2 ساعة تدريبية';
    return '+$hours ساعات تدريبية';
  }

  String _getCourseShareUrl(String courseId) {
    try {
      final origin = html.window.location.origin;
      if (origin.isNotEmpty && origin != 'null') {
        return '$origin/courses?course=$courseId';
      }
    } catch (_) {}
    return '/courses?course=$courseId';
  }

  // --- 1. Breadcrumbs Navigation ---
  Widget _buildBreadcrumbsRow(Map<String, dynamic> course, bool isMobile, bool isDark) {
    return Row(
      children: [
        InkWell(
          onTap: _handleBack,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF00E5FF)),
                const SizedBox(width: 4),
                Text(
                  "الكورسات",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          " › ",
          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
        ),
        Text(
          "مسار علوم الحاسب والذكاء الاصطناعي للأطفال",
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 11.5 : 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (!isMobile) ...[
          Text(
            " › ",
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              course['title'] ?? '',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  // --- 2. Top Hero Card ---
  Widget _buildCourseHeroCard({
    required Map<String, dynamic> course,
    required List<Map<String, dynamic>> lessons,
    required String hoursBadgeStr,
    required String lecturesCountStr,
    required bool isDark,
    required bool isMobile,
  }) {
    final title = course['title'] ?? 'كورس البرمجة والذكاء الاصطناعي للأطفال | من الصفر للاحتراف';
    final desc = course['description'] ??
        'رحلة تأسيسية تفاعلية شيقة تمكّن الأطفال واليافعين من فهم الكمبيوتر والإنترنت، والتفكير البرمجي وبناء مشاريع ذكاء اصطناعي حقيقية خطوة بخطوة من الصفر للاحتراف.';

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track Category
        Text(
          "دورات علوم الحاسب والبرمجة للأطفال واليافعين",
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00E5FF),
          ),
        ),
        const SizedBox(height: 8),

        // Main Title
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w900,
            height: 1.3,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle / Description
        Text(
          desc,
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 13 : 14.5,
            height: 1.6,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 16),

        // Badges Strip (strictly reflects active videos count and certified badge)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBadgePill(Icons.language_rounded, "عربي", isDark),
            _buildBadgePill(Icons.ondemand_video_rounded, lecturesCountStr, isDark),
            _buildBadgePill(Icons.workspace_premium_rounded, "بشهادة إتمام معتمدة", isDark),
          ],
        ),
        const SizedBox(height: 20),

        // Teacher & Stats Row
        Wrap(
          spacing: 24,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Instructor
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                    child: Image.asset(
                      'assets/images/courses/course_01.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFF00E5FF)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اسم المدرب",
                      style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      "م. إسلام عاطف",
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تقييم الدورة",
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      "4.9 (101+ تقييماً)",
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Students Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "عدد المسجلين بالدورة",
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  "👥 209+ طالب",
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    // 16:9 Thumbnail Image
    final thumbnailImage = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/courses/course_01.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                "دورة مجانية بالكامل ✨",
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          thumbnailImage,
          const SizedBox(height: 18),
          textColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: textColumn),
        const SizedBox(width: 28),
        SizedBox(width: 360, child: thumbnailImage),
      ],
    );
  }

  Widget _buildBadgePill(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Modules & Lessons Content (Right Main Column) ---
  Widget _buildCourseModulesContent(
    BuildContext context,
    Map<String, dynamic> course,
    List<Map<String, dynamic>> level1Lessons,
    List<Map<String, dynamic>> level2Lessons,
    List<Map<String, dynamic>> extraLessons,
    String lecturesCountStr,
    bool isEnrolled,
    bool isDark,
  ) {
    return Container(
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
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "محتوى الدورة",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                "$lecturesCountStr متاحة للمشاهدة الآن",
                style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Module 1: المستوى 1 (Only rendered if it has active video lessons)
          if (level1Lessons.isNotEmpty)
            _buildModuleCard(
              context: context,
              title: "المستوى 1: عالم الكمبيوتر والإنترنت",
              badgeText: "${level1Lessons.length} دروس",
              lessons: level1Lessons,
              isEnrolled: isEnrolled,
              isDark: isDark,
              course: course,
            ),

          // Module 2: المستوى 2 (Only rendered if it has active video lessons)
          if (level2Lessons.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildModuleCard(
              context: context,
              title: "المستوى 2: التفكير البرمجي والخوارزميات",
              badgeText: "${level2Lessons.length} دروس",
              lessons: level2Lessons,
              isEnrolled: isEnrolled,
              isDark: isDark,
              course: course,
            ),
          ],

          // Extra Module (Cloud / Admin Updates - Only rendered if it has active video lessons)
          if (extraLessons.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildModuleCard(
              context: context,
              title: "المحاضرات الإضافية وتحديثات الأكاديمية",
              badgeText: "${extraLessons.length} دروس",
              lessons: extraLessons,
              isEnrolled: isEnrolled,
              isDark: isDark,
              course: course,
            ),
          ],

          // Clean Empty State when course has no published lectures
          if (level1Lessons.isEmpty && level2Lessons.isEmpty && extraLessons.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.video_collection_outlined, size: 32, color: Color(0xFF00E5FF)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "لا توجد محاضرات منشورة حالياً في هذا الكورس",
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "سيتم إضافة ورفع المحاضرات قريباً من لوحة التحكم 🚀",
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String badgeText,
    required List<Map<String, dynamic>> lessons,
    required bool isEnrolled,
    required bool isDark,
    required Map<String, dynamic> course,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Module Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lessons Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
            itemBuilder: (context, idx) {
              final lesson = lessons[idx];
              return _buildLessonItemRow(context, lesson, course, isEnrolled, isDark);
            },
          ),
        ],
      ),
    );
  }

    void _trackLessonWatched(Map<String, dynamic> lesson) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _activeCourse != null) {
      final cid = (_activeCourse!['id'] ?? '').toString();
      final lid = (lesson['id'] ?? '').toString();
      if (cid.isNotEmpty && lid.isNotEmpty) {
        _dataService.markLessonWatched(
          courseId: cid,
          lessonId: lid,
          userId: user.uid,
          lessonTitle: (lesson['title'] ?? '').toString(),
          courseTitle: (_activeCourse!['title'] ?? '').toString(),
        );
        if (!_watchedLessonIds.contains(lid)) {
          setState(() => _watchedLessonIds.add(lid));
        }
      }
    }
  }

  Widget _buildLessonItemRow(
    BuildContext context,
    Map<String, dynamic> lesson,
    Map<String, dynamic> course,
    bool isEnrolled,
    bool isDark,
  ) {
    final title = lesson['title'] ?? 'محاضرة تعليمية';
    final ytUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString().trim();
    final hasActiveVideo = ytUrl.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          setState(() {
            _activeLesson = lesson;
          });
          _trackLessonWatched(lesson);
          _syncUrl();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Icon (Lock or Play matching the screenshot style)
              Icon(
                hasActiveVideo ? Icons.play_circle_fill_rounded : Icons.lock_outline_rounded,
                size: 20,
                color: hasActiveVideo ? const Color(0xFF00E5FF) : Colors.grey.shade400,
              ),
              const SizedBox(width: 12),

              // Lecture Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 4. Sidebar Card (Left Column) ---
  Widget _buildCourseSidebarCard(
    BuildContext context,
    Map<String, dynamic> course,
    List<Map<String, dynamic>> lessons,
    String totalDurationStr,
    String lecturesCountStr,
    bool isEnrolled,
    User? user,
    bool isDark,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Start Course CTA Button (سجّل بالدورة / ابدأ المشاهدة)
          ElevatedButton(
            onPressed: lessons.isEmpty
                ? null
                : () async {
                    if (user == null) {
                      showDialog(context: context, builder: (c) => const AuthModal());
                      return;
                    }
                    if (!isEnrolled) {
                      await _dataService.enrollInCourse(
                        courseId: course['id']?.toString() ?? '',
                        userId: user.uid,
                        userEmail: user.email ?? '',
                        userName: user.displayName ?? '',
                      );
                      _checkEnrollment();
                    }
                    setState(() {
                      _activeLesson = lessons.first;
                    });
                    _trackLessonWatched(lessons.first);
                    _syncUrl();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              foregroundColor: Colors.white,
              disabledForegroundColor: isDark ? Colors.white54 : Colors.black45,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: lessons.isEmpty ? 0 : 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  lessons.isEmpty
                      ? Icons.hourglass_empty_rounded
                      : (isEnrolled ? Icons.play_arrow_rounded : Icons.how_to_reg_rounded),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  lessons.isEmpty
                      ? "قريباً - لا توجد محاضرات حالياً ⏳"
                      : (isEnrolled ? "ابدأ مشاهدة الدورة الآن 🎬" : "سجّل بالدورة"),
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sidebar Title
          Text(
            "معلومات سريعة عن الدورة",
            style: GoogleFonts.cairo(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // Facts List (Strictly reflecting actual published videos)
          _buildSidebarFactRow(
            Icons.ondemand_video_rounded,
            "عدد المحاضرات:",
            lecturesCountStr,
            const Color(0xFF818CF8),
            isDark,
          ),
          _buildSidebarFactRow(
            Icons.check_circle_outline_rounded,
            "إمكانية الوصول للمحاضرات بأي وقت",
            "",
            const Color(0xFF10B981),
            isDark,
          ),
          _buildSidebarFactRow(
            Icons.language_rounded,
            "لغة الدورة:",
            "عربي",
            const Color(0xFF38BDF8),
            isDark,
          ),
          _buildSidebarFactRow(
            Icons.workspace_premium_rounded,
            "شهادة مشاركة:",
            "نعم",
            const Color(0xFFF59E0B),
            isDark,
          ),
          _buildSidebarFactRow(
            Icons.card_giftcard_rounded,
            "رسوم الدورة:",
            "مجاناً",
            const Color(0xFF10B981),
            isDark,
          ),

          const SizedBox(height: 20),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Share with friends (Matching the screenshot)
          Text(
            "شارك الأصدقاء",
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialShareCircle(
                Icons.chat_rounded,
                const Color(0xFF25D366),
                "واتساب",
                () => _shareToWhatsApp(course),
              ),
              _buildSocialShareCircle(
                Icons.send_rounded,
                const Color(0xFF0088CC),
                "تيليجرام",
                () => _shareToTelegram(course),
              ),
              _buildSocialShareCircle(
                Icons.facebook_rounded,
                const Color(0xFF1877F2),
                "فيسبوك",
                () => _shareToFacebook(course),
              ),
              _buildSocialShareCircle(
                Icons.link_rounded,
                const Color(0xFF00E5FF),
                "نسخ الرابط",
                () => _copyLink(
                  _getCourseShareUrl(course['id']?.toString() ?? ''),
                  'تم نسخ رابط الكورس بنجاح 📋',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFactRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
    bool isDark,
  ) {
    Widget valueWidget;
    if (value == "نعم") {
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "نعم",
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
          ),
        ),
      );
    } else if (value == "مجاناً" || value == "مجاناً بالكامل") {
      valueWidget = Text(
        "مجاناً",
        style: GoogleFonts.cairo(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF10B981),
        ),
      );
    } else if (value.isEmpty) {
      valueWidget = const SizedBox.shrink();
    } else {
      valueWidget = Text(
        value,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildSocialShareCircle(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _shareToWhatsApp(Map<String, dynamic> course) {
    final title = course['title'] ?? 'كورس البرمجة والذكاء الاصطناعي';
    final url = _getCourseShareUrl(course['id']?.toString() ?? '');
    final msg = 'شاهد $title مجاناً على منصة م. إسلام عاطف: $url';
    html.window.open('https://wa.me/?text=${Uri.encodeComponent(msg)}', '_blank');
  }

  void _shareToTelegram(Map<String, dynamic> course) {
    final title = course['title'] ?? 'كورس البرمجة والذكاء الاصطناعي';
    final url = _getCourseShareUrl(course['id']?.toString() ?? '');
    html.window.open('https://t.me/share/url?url=${Uri.encodeComponent(url)}&text=${Uri.encodeComponent(title)}', '_blank');
  }

  void _shareToFacebook(Map<String, dynamic> course) {
    final url = _getCourseShareUrl(course['id']?.toString() ?? '');
    html.window.open('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}', '_blank');
  }

  Widget _buildCoursePdfCard(Map<String, dynamic> course, bool isDark, bool isMobile) {
    final pdfUrl = (course['pdfUrl'] ?? course['pdfLink'] ?? '').toString().trim();
    if (pdfUrl.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.45 : 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ملزمة ومرفقات الكورس (PDF)",
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "تصفح وقراءة الملزمة كاملة مباشرة داخل الموقع.",
                            style: GoogleFonts.cairo(fontSize: 11.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => PdfViewerModal.show(
                    context,
                    pdfUrl: pdfUrl,
                    title: "ملزمة ${course['title'] ?? 'الكورس'}",
                    isDark: isDark,
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text("تصفح وقراءة الملزمة داخل الموقع 📖", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ملزمة ومرفقات الكورس (PDF)",
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "مذكرة وملخصات هذا الكورس متوفرة للقراءة المباشرة داخل الموقع أو التحميل.",
                        style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => PdfViewerModal.show(
                    context,
                    pdfUrl: pdfUrl,
                    title: "ملزمة ${course['title'] ?? 'الكورس'}",
                    isDark: isDark,
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text("تصفح وقراءة الملزمة داخل الموقع 📖", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================
  // VIEW 3: Dedicated Lesson & YouTube Video Player View
  // ==========================================
  Widget _buildLessonVideoPlayerView(BuildContext context, bool isMobile, bool isDark) {
    final lesson = _activeLesson!;
    var title = (lesson['title'] ?? '').toString().trim();
    if (title.isEmpty || title == 'درس جديد') {
      final code = (lesson['htmlCode'] ?? lesson['content'] ?? '').toString();
      final h1Match = RegExp(r'<h1[^>]*>([^<]+)</h1>', caseSensitive: false).firstMatch(code);
      if (h1Match != null && h1Match.group(1)!.trim().isNotEmpty) {
        title = h1Match.group(1)!.trim();
      } else {
        title = 'درس تعليمي';
      }
    }
    final desc = (lesson['description'] ?? lesson['desc'] ?? '').toString().trim();
    final youtubeUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString().trim();
    final content = (lesson['content'] ?? '').toString().trim();
    final htmlCode = (lesson['htmlCode'] ?? '').toString().trim();
    final rawContent = htmlCode.isNotEmpty
        ? htmlCode
        : (content.isNotEmpty ? content : '');
    final displayContent = _sanitizeArticleHtml(rawContent);
    final hasQuiz = lesson['hasQuiz'] == true;
    final quizTitle = lesson['quizTitle'] ?? 'اختبار فهم الدرس';
    final isPaid = lesson['isPaid'] == true || _activeCourse?['isPaid'] == true;

    // Check permissions for lesson
    final courseId = _activeCourse?['id']?.toString() ?? '';
    final lessonId = lesson['id']?.toString() ?? '';
    if (!_canAccessLesson(courseId: courseId, lessonId: lessonId, isPaid: isPaid)) {
      return _buildLockedScreen(
        context: context,
        title: title,
        contentType: 'درس',
        isDark: isDark,
        isPaid: isPaid,
        courseId: courseId,
        onBack: _handleBack,
      );
    }

    final isFullHtml = displayContent.contains('<!DOCTYPE') ||
        displayContent.contains('<html') ||
        displayContent.contains('class="article-header') ||
        displayContent.contains('badge-course') ||
        displayContent.contains('<header');

    final String resolvedVideoUrl = _extractYouTubeUrl(rawContent, youtubeUrl);
    final String bookUrl = (lesson['bookUrl'] ?? lesson['bookLink'] ?? '').toString().trim();
    final String quizHtml = (lesson['quizHtml'] ?? '').toString().trim();
    final String finalHtmlToDisplay = quizHtml.isNotEmpty
        ? quizHtml
        : (rawContent.isNotEmpty ? rawContent : '');

    final bool showCustomTitle = !isFullHtml && title.trim() != 'درس جديد';
    final bool showCustomDesc = !isFullHtml &&
        desc.isNotEmpty &&
        desc.trim() != 'درس جديد' &&
        desc.trim() != title.trim();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 0. Top Back to Course Navigation Button
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _handleBack,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  "العودة إلى محتوى الكورس",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00E5FF),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. عنوان الدرس (فقط للدروس العادية التي لا تحتوي على مقال HTML مستقل متكامل وليست "درس جديد")
            if (showCustomTitle) ...[
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 2. وصف الدرس (فقط إذا لم يكن مكرراً أو "درس جديد")
            if (showCustomDesc) ...[
              Text(
                desc,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3. الفيديو (Video / YouTube Player) أو مشغل المحاضرة المهيأ
            if (resolvedVideoUrl.isNotEmpty) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: YouTubeEmbeddedPlayer(
                      youtubeUrl: resolvedVideoUrl,
                      height: isMobile ? 240 : 480,
                      showWatermark: isPaid && FirebaseAuth.instance.currentUser != null,
                      watermarkText: FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'طالب منصة إسلام عاطف',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF070B14)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.15,
                              child: Image.asset(
                                'assets/images/courses/course_01.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF).withOpacity(0.35),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.play_arrow_rounded, color: Color(0xFF00E5FF), size: 40),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "مشغل فيديو المحاضرة مهيأ وجاهز",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: isMobile ? 16 : 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "سيتم ربط وإضافة مقطع الفيديو والشرح لهذه المحاضرة لاحقاً بجودة عالية.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: isMobile ? 12 : 14,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    if ((lesson['webUrl'] ?? '').toString().isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          final webUrl = lesson['webUrl'].toString();
                                          html.window.open(webUrl, '_blank');
                                        },
                                        icon: const Icon(Icons.laptop_chromebook_rounded, size: 16),
                                        label: Text(
                                          "تشغيل العرض التقديمي للحصة 🖥️",
                                          style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00E5FF),
                                          foregroundColor: const Color(0xFF070B14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    if ((lesson['quizUrl'] ?? '').toString().isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final quizUrl = lesson['quizUrl'].toString();
                                          html.window.open(quizUrl, '_blank');
                                        },
                                        icon: const Icon(Icons.quiz_rounded, size: 16),
                                        label: Text(
                                          "خوض الاختبار التفاعلي 🧠",
                                          style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF10B981),
                                          side: const BorderSide(color: Color(0xFF10B981)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. كتاب / كتيب المحاضرة إن وُجد (Book / Worksheet Link)
            if (bookUrl.isNotEmpty) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        html.window.open(bookUrl, '_blank');
                      },
                      icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                      label: Text(
                        "تحميل وتصفح كتيب الدرس (PDF) 📚",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // 5. الملخص والاختبار التفاعلي المباشر تحت الفيديو مباشرة دون الحاجة لأزرار إضافية
            if (finalHtmlToDisplay.isNotEmpty) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: InteractiveHtmlView(
                    id: 'course_lesson_content_${lessonId.isNotEmpty ? lessonId : 'view'}',
                    rawHtml: finalHtmlToDisplay,
                    height: (finalHtmlToDisplay.length * 0.12).clamp(750.0, 5000.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ] else if (content.isNotEmpty) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
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
                    child: ArticleContentRenderer(content: displayContent, isDark: isDark),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],

            // 6. في حالة وجود اختبار مخصص منفصل (أسئلة متعددة) ولا يوجد كود HTML تفاعلي
            if (hasQuiz && quizHtml.isEmpty) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF064E3B).withValues(alpha: 0.4), const Color(0xFF0F172A)]
                            : [const Color(0xFFECFDF5), Colors.white],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "اختبار فهم الدرس 📝",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "اختبر معلوماتك وفهمك لما تعلمته في هذا الدرس عبر خوض هذا الاختبار.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _openLessonQuizDialog(context, lesson, isDark),
                          icon: const Icon(Icons.quiz_rounded, size: 22),
                          label: Text("ابدأ $quizTitle", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          const SizedBox(height: 36),
        ],
      ),
    ),
  );
}

  Widget _buildLockedScreen({
    required BuildContext context,
    required String title,
    required String contentType,
    required bool isDark,
    required VoidCallback onBack,
    bool isPaid = true,
    String courseId = '',
  }) {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, size: 48, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 20),
            Text(
              isPaid ? "🔒 محتوى مدفوع خاص بالمشتركين" : "🔒 يتطلب التسجيل في الكورس",
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isPaid
                  ? "هذا الـ$contentType ($title) مخصص للطلاب المشتركين فقط. لا يمكنك الوصول إلى محتواه ومشاهدة الدروس والاختبارات إلا بعد الحصول على تصريح من الإدارة."
                  : (user == null
                      ? "لمشاهدة هذا الدرس ومتابعة المحتوى، يجب تسجيل الدخول والالتحاق بالكورس أولاً."
                      : "أنت مسجل كعضو، لكن لم تنضم لهذا الكورس بعد. اضغط على زر الالتحاق بالأسفل لتفعيل الدروس فوراً وحفظ تقدمك."),
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (user == null) ...[
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (c) => const AuthModal()),
                icon: const Icon(Icons.login_rounded),
                label: Text("تسجيل الدخول / إنشاء حساب جديد 🔐", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
            ] else if (!isPaid && courseId.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await _dataService.enrollInCourse(
                    courseId: courseId,
                    userId: user.uid,
                    userEmail: user.email,
                    userName: user.displayName,
                  );
                  setState(() => _enrolledCourseIds.add(courseId));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("تم تسجيلك في الكورس بنجاح! تم فتح الدرس لك 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text("الالتحاق بالكورس وتفعيل الدرس مجاناً 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (isPaid) ...[
              ElevatedButton.icon(
                onPressed: () {
                  final email = user?.email ?? 'زائر';
                  final msg = Uri.encodeComponent("مرحباً أستاذ إسلام عاطف، أرغب في تفعيل الاشتراك في $contentType: $title\nالبريد الإلكتروني: $email");
                  launchUrl(Uri.parse("https://wa.me/201016834012?text=$msg"), mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.chat_rounded, color: Colors.white),
                label: Text("تواصل عبر واتساب للتفعيل الفوري 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: onBack,
              child: Text("العودة إلى القائمة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  void _openLessonQuizDialog(BuildContext context, Map<String, dynamic> lesson, bool isDark) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("تسجيل الدخول مطلوب 🔐", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            "يرجى تسجيل الدخول أولاً لتتمكن من خوض الاختبار وتوثيق نتيجتك رسمياً في صفحة (إنجازاتي) بالفايربيز.",
            style: GoogleFonts.cairo(height: 1.5),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                showDialog(context: context, builder: (_) => const AuthModal());
              },
              child: const Text("تسجيل الدخول الآن"),
            ),
          ],
        ),
      );
      return;
    }

    final cid = (_activeCourse?['id'] ?? 'course').toString();
    final lid = (lesson['id'] ?? 'item').toString();
    final quizId = 'quiz_${cid}_$lid';

    // STRICT RULE: A member can only take the quiz ONCE
    final hasSubmitted = await _dataService.hasUserSubmittedQuiz(quizId: quizId, userId: user.uid);
    if (hasSubmitted) {
      final prevResult = await _dataService.getUserQuizResult(quizId: quizId, userId: user.uid);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 26),
                const SizedBox(width: 8),
                Text("تم أداء هذا الاختبار مسبقاً 🏆", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "لقد قمت بإجراء هذا الاختبار بالفعل! وفقاً للائحة الأكاديمية لا يمكن إعادة الاختبار مرة أخرى لضمان المصداقية وتوثيق الإنجازات الرسمية.",
                  style: GoogleFonts.cairo(height: 1.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("النتيجة المعتمدة:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      Text(
                        "${prevResult?['score'] ?? 10} من ${prevResult?['totalQuestions'] ?? 10} (${(prevResult?['percentage'] ?? 100).toInt()}%)",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF10B981), fontSize: 16),
                      ),
                    ],
                  ),
                ),
                if (prevResult?['date'] != null) ...[
                  const SizedBox(height: 8),
                  Text("تاريخ الإجراء: ${prevResult!['date']}", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق")),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/profile');
                },
                icon: const Icon(Icons.person_rounded, size: 18),
                label: const Text("عرض الملف الشخصي 👤"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: const Color(0xFF0F172A)),
              ),
            ],
          ),
        );
      }
      return;
    }

    final quizHtml = (lesson['quizHtml'] ?? '').toString().trim();

    if (quizHtml.isNotEmpty) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lesson['quizTitle'] ?? 'اختبار فهم الدرس', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            content: SizedBox(
              width: 750,
              height: 600,
              child: Column(
                children: [
                  Expanded(
                    child: InteractiveHtmlView(
                      id: 'lesson_quiz_dialog_${lesson['id'] ?? 'item'}',
                      rawHtml: quizHtml,
                      height: 520,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _dataService.submitQuizResult(
                        quizId: quizId,
                        quizTitle: (lesson['title'] ?? 'اختبار المحاضرة').toString(),
                        courseId: cid,
                        userId: user.uid,
                        userName: user.displayName ?? user.email ?? 'طالب',
                        score: 10,
                        totalQuestions: 10,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("تهانينا! تم تسجيل نتيجتك (10/10) بنجاح 🎯", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text("تسجيل النتيجة 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    int? selectedOption;
    bool answered = false;

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(lesson['quizTitle'] ?? 'اختبار الدرس', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(lesson['quizQuestion'] ?? 'سؤال الاختبار', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  _quizOptionTile(1, lesson['quizOpt1'] ?? 'إجابة 1', selectedOption, answered, false, () {
                    if (!answered) setDlgState(() { selectedOption = 1; answered = true; });
                  }),
                  _quizOptionTile(2, lesson['quizOpt2'] ?? 'إجابة 2 (صحيحة)', selectedOption, answered, true, () {
                    if (!answered) setDlgState(() { selectedOption = 2; answered = true; });
                  }),
                  if (answered) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text("💡 ${lesson['quizExplanation'] ?? 'إجابة ممتازة!'}", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق")),
                if (answered)
                  ElevatedButton(
                    onPressed: () async {
                      final score = selectedOption == 2 ? 10 : 5;
                      await _dataService.submitQuizResult(
                        quizId: quizId,
                        quizTitle: (lesson['title'] ?? 'اختبار المحاضرة').toString(),
                        courseId: cid,
                        userId: user.uid,
                        userName: user.displayName ?? user.email ?? 'طالب',
                        score: score,
                        totalQuestions: 10,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("تم حفظ وتوثيق نتيجتك ($score/10) بنجاح 🎯", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                    child: const Text("حفظ النتيجة 🎯"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _quizOptionTile(int index, String text, int? selected, bool answered, bool isCorrect, VoidCallback onTap) {
    Color border = Colors.grey.shade700;
    Color bg = Colors.transparent;

    if (answered) {
      if (isCorrect) {
        border = const Color(0xFF10B981);
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
      } else if (selected == index) {
        border = Colors.redAccent;
        bg = Colors.redAccent.withValues(alpha: 0.15);
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  static String _sanitizeArticleHtml(String html) {
    if (html.isEmpty) return html;
    var cleaned = html;
    // 1. Remove quick links box
    cleaned = cleaned.replaceAll(RegExp(r'(?:<!--\s*Quick Links[^\n]*-->\s*)?<div[^>]*class="[^"]*quick-links-box[^"]*"[^>]*>[\s\S]*?</div>\s*</div>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'(?:<!--\s*Quick Links[^\n]*-->\s*)?<div[^>]*class="[^"]*quick-links-box[^"]*"[^>]*>[\s\S]*?</div>', caseSensitive: false), '');
    // 2. Remove official links text blocks
    cleaned = cleaned.replaceAll(RegExp(r'📌\s*روابط المحاضرة[^<]*<\/span>[\s\S]*?📢\s*التليجرام والواجبات<\/a>\s*<\/div>', caseSensitive: false), '');
    // 3. Remove SEO tags box
    cleaned = cleaned.replaceAll(RegExp(r'(?:<!--\s*SEO Tags[^\n]*-->\s*)?<footer[^>]*class="[^"]*seo-tags-box[^"]*"[^>]*>[\s\S]*?</footer>', caseSensitive: false), '');
    // 4. Remove SEO metadata header
    cleaned = cleaned.replaceAll(RegExp(r'<h2>📌\s*بيانات تحسين محركات البحث[^\n<]*<\/h2>\s*(?:<li>[\s\S]*?<\/li>\s*)+(?:<p>---<\/p>\s*)?', caseSensitive: false), '');
    // 5. Remove any raw SEO keywords box
    cleaned = cleaned.replaceAll(RegExp(r'🔑\s*الكلمات المفتاحية لمسؤولي محركات البحث[\s\S]*?<\/p>', caseSensitive: false), '');
    return cleaned;
  }
}
