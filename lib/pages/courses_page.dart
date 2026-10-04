import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/site_data_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/youtube_embedded_player.dart';
import '../widgets/auth_modal.dart';
import '../widgets/safe_network_image/safe_network_image.dart';
import '../widgets/unified_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    _checkEnrollment();
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
      _checkEnrollment();
      setState(() {});
    }
  }

  @override
  void dispose() {
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

  String _resolveLessonThumbnail(Map<String, dynamic> lesson, [Map<String, dynamic>? course]) {
    final courseImg = (course?['image'] ?? course?['imageUrl'] ?? '').toString().trim();

    // 1. Try to extract first image from the lesson article content (HTML or Markdown)
    final htmlCode = (lesson['htmlCode'] ?? '').toString();
    final content = (lesson['content'] ?? '').toString();
    final desc = (lesson['description'] ?? '').toString();
    final combined = '$htmlCode $content $desc';

    if (combined.isNotEmpty) {
      // Check HTML <img>
      final htmlMatch = RegExp(r'<img[^>]+src=["\x27](https?:\/\/[^"\x27\s]+)["\x27]', caseSensitive: false).firstMatch(combined);
      if (htmlMatch != null) {
        final src = htmlMatch.group(1)!.trim();
        if (src.isNotEmpty && src != courseImg) return src;
      }

      // Check Markdown ![...](...)
      final mdMatch = RegExp(r'!\[.*?\]\((https?:\/\/[^\s\)]+)\)').firstMatch(combined);
      if (mdMatch != null) {
        final src = mdMatch.group(1)!.trim();
        if (src.isNotEmpty && src != courseImg) return src;
      }

      // Check direct image URL ending with extension
      final extMatch = RegExp(r'(https?:\/\/[^\s"<>]+\.(?:jpg|jpeg|png|webp|gif|svg))', caseSensitive: false).firstMatch(combined);
      if (extMatch != null) {
        final src = extMatch.group(1)!.trim();
        if (src.isNotEmpty && src != courseImg) return src;
      }
    }

    // 2. Check lesson explicit image if distinct from course cover
    final rawLessonImg = (lesson['image'] ?? lesson['imageUrl'] ?? '').toString().trim();
    if (rawLessonImg.isNotEmpty && rawLessonImg != courseImg && rawLessonImg != 'assets/images/slide1.png') {
      return rawLessonImg;
    }

    // 3. Fallback: if YouTube video exists, extract its thumbnail
    final ytUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString().trim();
    if (ytUrl.isNotEmpty) {
      final ytMatch = RegExp(r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|shorts\/|live\/))([a-zA-Z0-9_-]{11})').firstMatch(ytUrl);
      if (ytMatch != null) {
        return 'https://img.youtube.com/vi/${ytMatch.group(1)}/hqdefault.jpg';
      }
    }

    // 4. Fallback to lesson image or course cover
    if (rawLessonImg.isNotEmpty) return rawLessonImg;
    if (courseImg.isNotEmpty) return courseImg;
    return 'assets/images/slide1.png';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
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
                  onBack: _activeLesson != null
                      ? () => setState(() => _activeLesson = null)
                      : (_activeCourse != null
                          ? () => setState(() => _activeCourse = null)
                          : null),
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
    );
  }


  // ==========================================
  // VIEW 1: Course Folders Catalog
  // ==========================================
  Widget _buildCourseFoldersCatalog(BuildContext context, bool isMobile, bool isDark) {
    final courses = _dataService.courses;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
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
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "مسارات برمجية كاملة مقسمة إلى دروس وفيديوهات",
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "اختر المسار وافتح ملف الكورس لمشاهدة الدروس والاختبارات",
                  style: GoogleFonts.cairo(fontSize: isMobile ? 22 : 32, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (courses.isEmpty)
            _buildEmptyState("لا توجد كورسات مضافة بعد", "يمكنك إنشاء ملفات الكورسات وإضافة الفيديوهات والشروحات من لوحة التحكم.", isDark)
          else
            LayoutBuilder(
              builder: (ctx, constraints) {
                int cols = constraints.maxWidth < 650 ? 1 : (constraints.maxWidth < 980 ? 2 : 3);
                final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

                return Wrap(
                  spacing: 20,
                  runSpacing: 22,
                  children: courses.map((course) {
                    final lessons = (course['lessons'] as List?) ?? [];
                    final rawCourseImg = (course['image'] ?? course['imageUrl'] ?? '').toString().trim();
                    final image = rawCourseImg.isNotEmpty ? rawCourseImg : 'assets/images/slide1.png';

                    return SizedBox(
                      width: width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 180,
                                child: SafeNetworkImage(
                                  imageUrl: image,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(course['category'] ?? 'كورس', style: GoogleFonts.cairo(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: course['isPaid'] == true ? const Color(0xFFDC2626).withValues(alpha: 0.15) : const Color(0xFF16A34A).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: course['isPaid'] == true ? const Color(0xFFDC2626) : const Color(0xFF16A34A), width: 0.8),
                                          ),
                                          child: Text(
                                            course['isPaid'] == true ? "🔒 مدفوع" : "🟢 مجاني",
                                            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: course['isPaid'] == true ? const Color(0xFFEF4444) : const Color(0xFF22C55E)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(course['title'] ?? '', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900), maxLines: 2),
                                    const SizedBox(height: 6),
                                    Text(course['description'] ?? 'مسار تدريبي شامل وتطبيقي.', style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey), maxLines: 2),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                                          child: Text("📂 ${lessons.length} درس وفيديو", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => setState(() => _activeCourse = course),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
                                          child: Text("فتح الكورس ➔", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
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

  // ==========================================
  // VIEW 2: Inside Course Folder (Playlist of lessons/videos)
  // ==========================================
  Widget _buildCourseInsideView(BuildContext context, bool isMobile, bool isDark) {
    final course = _activeCourse!;
    final courseId = course['id']?.toString() ?? '';
    final lessons = List<Map<String, dynamic>>.from(course['lessons'] ?? []);
    final isPaid = course['isPaid'] == true;
    final price = course['price'] ?? 250;
    final user = FirebaseAuth.instance.currentUser;
    final isEnrolled = _isUserEnrolled(courseId: courseId, isPaid: isPaid);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMobile) ...[
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _activeCourse = null),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text("العودة لكافة الكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                course['title'] ?? '',
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ] else ...[
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _activeCourse = null),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text("العودة لكافة الكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(course['title'] ?? '', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

          // Enrollment / Progress Banner
          if (!isEnrolled) ...[
            Container(
              padding: const EdgeInsets.all(22),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F2D6B), const Color(0xFF0F172A)]
                      : [const Color(0xFFE0F2FE), Colors.white],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "سجّل الآن في هذا الكورس لتفعيل الدروس وحفظ تقدمك 🎓",
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              isPaid
                                  ? "هذا الكورس يتطلب اشتراكاً مدفوعاً ($price ج.م) للحصول على الوصول الكامل والمحاضرات والاختبارات."
                                  : "الالتحاق مجاني بالكامل! سجّل لتتمكن من متابعة الدروس واحتساب نسبة إنجازك في ملفك الشخصي.",
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      if (user == null)
                        ElevatedButton.icon(
                          onPressed: () => showDialog(context: context, builder: (c) => const AuthModal()),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: Text("تسجيل الدخول للالتحاق بالكورس 🔐", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      else if (!isPaid)
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
                                content: Text("تم تسجيلك في الكورس بنجاح! تم فتح جميع المحاضرات لك 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: Text("الالتحاق بالكورس مجاناً (تسجيل فوري) 🎓", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/checkout', arguments: course),
                          icon: const Icon(Icons.credit_card_rounded, size: 18),
                          label: Text("شراء الكورس والاشتراك الآن 💳 ($price ج.م)", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Enrolled Concise Badge (علامة خضراء أنيقة ومختصرة)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "مسجّل في هذا الكورس",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_watchedLessonIds.length}/${lessons.length} مكتمل",
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (lessons.isEmpty)
            _buildEmptyState("لا توجد دروس أو فيديوهات داخل هذا الكورس بعد", "يمكنك إضافة دروس جديدة لهذا الكورس عبر لوحة التحكم.", isDark)
          else
            ...lessons.asMap().entries.map((entry) {
              final idx = entry.key;
              final lesson = entry.value;
              final lessonId = (lesson['id'] ?? '').toString();
              final isWatched = _watchedLessonIds.contains(lessonId);
              final image = _resolveLessonThumbnail(lesson, _activeCourse);
              final youtubeUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString();
              final hasYoutube = youtubeUrl.isNotEmpty;
              final hasQuiz = lesson['hasQuiz'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isWatched
                        ? const Color(0xFF10B981).withValues(alpha: 0.5)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isWatched ? const Color(0xFF10B981) : const Color(0xFF00E5FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isWatched
                                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                                      : Text("${idx + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 70,
                                  height: 50,
                                  child: SafeNetworkImage(
                                    imageUrl: image,
                                    width: 70,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson['title'] ?? '',
                                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        if (hasYoutube)
                                          Text("▶ يوتيوب", style: GoogleFonts.cairo(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                        if (hasQuiz)
                                          Text("📝 اختبار", style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                        if (isWatched)
                                          Text("✓ مكتمل", style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (user == null) {
                                showDialog(context: context, builder: (c) => const AuthModal());
                                return;
                              }
                              if (!isEnrolled) {
                                if (!isPaid) {
                                  await _dataService.enrollInCourse(
                                    courseId: courseId,
                                    userId: user.uid,
                                    userEmail: user.email,
                                    userName: user.displayName,
                                  );
                                  setState(() => _enrolledCourseIds.add(courseId));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("هذا الكورس يتطلب اشتراكاً مدفوعاً لمشاهدة الدروس 🔒", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                  );
                                  return;
                                }
                              }
                              setState(() => _activeLesson = lesson);
                              if (lessonId.isNotEmpty) {
                                _dataService.markLessonWatched(courseId: courseId, lessonId: lessonId, userId: user.uid);
                                setState(() => _watchedLessonIds.add(lessonId));
                              }
                            },
                            icon: Icon(isEnrolled ? Icons.play_arrow_rounded : Icons.lock_outline_rounded, size: 18),
                            label: Text(
                              isEnrolled
                                  ? (isWatched ? "مشاهدة الدرس (مكتمل ✓)" : "مشاهدة الدرس ➔")
                                  : "يتطلب التسجيل 🔒",
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnrolled ? const Color(0xFF00E5FF) : Colors.grey.shade700,
                              foregroundColor: isEnrolled ? Colors.black : Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isWatched ? const Color(0xFF10B981) : const Color(0xFF00E5FF),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isWatched
                                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                                  : Text("${idx + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 90,
                              height: 65,
                              child: SafeNetworkImage(
                                imageUrl: image,
                                width: 90,
                                height: 65,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesson['title'] ?? '', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    if (hasYoutube)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                        child: Text("▶ فيديو يوتيوب مدمج", style: GoogleFonts.cairo(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    if (hasQuiz) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                        child: Text("📝 اختبار متاح", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    if (isWatched) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                        child: Text("تمت المشاهدة ✓", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (user == null) {
                                showDialog(context: context, builder: (c) => const AuthModal());
                                return;
                              }
                              if (!isEnrolled) {
                                if (!isPaid) {
                                  await _dataService.enrollInCourse(
                                    courseId: courseId,
                                    userId: user.uid,
                                    userEmail: user.email,
                                    userName: user.displayName,
                                  );
                                  setState(() => _enrolledCourseIds.add(courseId));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("هذا الكورس يتطلب اشتراكاً مدفوعاً لمشاهدة الدروس 🔒", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                  );
                                  return;
                                }
                              }
                              setState(() => _activeLesson = lesson);
                              if (lessonId.isNotEmpty) {
                                _dataService.markLessonWatched(courseId: courseId, lessonId: lessonId, userId: user.uid);
                                setState(() => _watchedLessonIds.add(lessonId));
                              }
                            },
                            icon: Icon(isEnrolled ? Icons.play_arrow_rounded : Icons.lock_outline_rounded, size: 20),
                            label: Text(
                              isEnrolled
                                  ? (isWatched ? "مشاهدة الدرس (مكتمل ✓)" : "مشاهدة الدرس ➔")
                                  : "يتطلب التسجيل 🔒",
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnrolled ? const Color(0xFF00E5FF) : Colors.grey.shade700,
                              foregroundColor: isEnrolled ? Colors.black : Colors.white70,
                            ),
                          ),
                        ],
                      ),
              );
            }),
        ],
      ),
    ),
  );
}

  // ==========================================
  // VIEW 3: Dedicated Lesson & YouTube Video Player View
  // ==========================================
  Widget _buildLessonVideoPlayerView(BuildContext context, bool isMobile, bool isDark) {
    final lesson = _activeLesson!;
    final title = lesson['title'] ?? 'درس جديد';
    final desc = (lesson['description'] ?? lesson['desc'] ?? '').toString().trim();
    final youtubeUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString().trim();
    final content = (lesson['content'] ?? '').toString().trim();
    final htmlCode = (lesson['htmlCode'] ?? '').toString().trim();
    final displayContent = htmlCode.isNotEmpty
        ? htmlCode
        : (content.isNotEmpty ? content : '');
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
        onBack: () => setState(() => _activeLesson = null),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _activeLesson = null),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text("العودة لقائمة دروس الكورس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
              ),
            ),
            const SizedBox(height: 16),

            // 1. العنوان الأول (Lesson Title)
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // 2. الوصف (Lesson Description)
            if (desc.isNotEmpty) ...[
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

            // 3. الفيديو (Video / YouTube Player) - يعرض فقط إذا لم يكن المقال يحتوي بالفعل على فيديو لتجنب التكرار
            if (!displayContent.contains('youtube') && !displayContent.contains('youtu.be') && !displayContent.contains('<iframe') && youtubeUrl.isNotEmpty && youtubeUrl.length > 5) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: YouTubeEmbeddedPlayer(youtubeUrl: youtubeUrl, height: isMobile ? 240 : 480),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

          // 5. شرح وتفاصيل الدرس (Lesson Explanation)
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Color(0xFF00E5FF), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      "شرح وتفاصيل الدرس",
                      style: GoogleFonts.cairo(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 14),
                if (displayContent.isNotEmpty)
                  ArticleContentRenderer(content: displayContent, isDark: isDark)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        "لا يوجد محتوى نصي إضافي لهذا الدرس، يمكنك متابعة الشرح بالفيديو أعلاه.",
                        style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 6. الاختبار إن وُجد (Quiz if present)
          if (hasQuiz) ...[
            const SizedBox(height: 28),
            Container(
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

  void _openLessonQuizDialog(BuildContext context, Map<String, dynamic> lesson, bool isDark) {
    final quizHtml = (lesson['quizHtml'] ?? '').toString().trim();

    if (quizHtml.isNotEmpty) {
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
              child: SingleChildScrollView(
                child: ArticleContentRenderer(content: quizHtml, isDark: isDark),
              ),
            ),
          );
        },
      );
      return;
    }

    int? selectedOption;
    bool answered = false;

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
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text("💡 ${lesson['quizExplanation'] ?? 'إجابة ممتازة!'}", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق")),
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

  Widget _buildEmptyState(String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.video_library_outlined, size: 52, color: Color(0xFF64748B)),
            const SizedBox(height: 14),
            Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF64748B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

}
