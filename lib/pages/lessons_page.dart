import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/social_icons.dart';
import '../services/site_data_service.dart';
import '../widgets/article_content_renderer.dart';
import '../widgets/youtube_embedded_player.dart';
import '../widgets/auth_modal.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final _dataService = SiteDataService.instance;
  Map<String, dynamic>? _selectedLesson; // When non-null, plays lesson video and details

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  bool _canAccess({String? courseId, String? lessonId, required bool isPaid}) {
    if (!isPaid) return true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final cached = _dataService.members.firstWhere(
      (m) => m['uid'] == user.uid || m['email'] == user.email,
      orElse: () => <String, dynamic>{},
    );
    if (cached.isEmpty) return false;
    if (cached['role'] == 'admin') return true;

    if (courseId != null) {
      final allowedCourses = List<String>.from(cached['allowedCourses'] ?? []);
      if (allowedCourses.contains(courseId)) return true;
    }
    if (lessonId != null) {
      final allowedLessons = List<String>.from(cached['allowedLessons'] ?? []);
      if (allowedLessons.contains(lessonId)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SelectionArea(
          child: SafeArea(
          child: Column(
            children: [
              _buildPageHeader(context, isMobile, isDark),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      _selectedLesson != null
                          ? _buildLessonDetailView(context, isMobile, isDark)
                          : _buildAllLessonsCatalog(context, isMobile, isDark),
                      const SizedBox(height: 60),
                      _buildPageFooter(context, isMobile, isDark),
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

  Widget _buildPageHeader(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/logo.jpeg', width: 42, height: 42, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ArabicData.brandName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        "الدروس والفيديوهات التعليمية",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
                    ),
                    onPressed: () => AppThemeManager.toggleTheme(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text("الرئيسية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                      foregroundColor: const Color(0xFF3B82F6),
                      side: BorderSide(color: isDark ? AppColors.borderLightDark : AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // ==========================================
  // Catalog of All Lessons (collected from courses + lessons)
  // ==========================================
  Widget _buildAllLessonsCatalog(BuildContext context, bool isMobile, bool isDark) {
    // Collect all lessons: from Courses + standalone lessons
    final List<Map<String, dynamic>> allLessons = [];

    for (final course in _dataService.courses) {
      final courseTitle = course['title'] ?? 'كورس';
      final lessons = List<Map<String, dynamic>>.from(course['lessons'] ?? []);
      for (final l in lessons) {
        allLessons.add({...l, 'courseTitle': courseTitle});
      }
    }
    allLessons.addAll(_dataService.lessons);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "مكتبة الفيديوهات والشروحات التفاعلية",
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "فيديوهات برمجية مباشرة مع شرح كامل واختبار لكل درس",
                  style: GoogleFonts.cairo(fontSize: isMobile ? 22 : 32, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (allLessons.isEmpty)
            _buildEmptyState("لا توجد دروس أو فيديوهات مضافة بعد", "يمكنك إضافة الدروس والفيديوهات من لوحة التحكم.", isDark)
          else
            LayoutBuilder(
              builder: (ctx, constraints) {
                int cols = constraints.maxWidth < 650 ? 1 : (constraints.maxWidth < 980 ? 2 : 3);
                final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

                return Wrap(
                  spacing: 20,
                  runSpacing: 22,
                  children: allLessons.map((lesson) {
                    final image = (lesson['image'] ?? lesson['imageUrl'] ?? 'assets/images/slide2.png').toString();
                    final courseTitle = lesson['courseTitle'] ?? lesson['playlistTitle'] ?? lesson['category'] ?? lesson['subject'] ?? 'درس';
                    final youtubeUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString();
                    final hasYoutube = youtubeUrl.isNotEmpty;

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
                              Stack(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: image.startsWith('http')
                                        ? Image.network(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey))
                                        : Image.asset(image, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey)),
                                  ),
                                  if (hasYoutube)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                                        child: Text("▶ YouTube", style: GoogleFonts.cairo(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(courseTitle, style: GoogleFonts.cairo(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: lesson['isPaid'] == true ? const Color(0xFFDC2626).withValues(alpha: 0.15) : const Color(0xFF16A34A).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: lesson['isPaid'] == true ? const Color(0xFFDC2626) : const Color(0xFF16A34A), width: 0.8),
                                          ),
                                          child: Text(
                                            lesson['isPaid'] == true ? "🔒 مدفوع" : "🟢 مجاني",
                                            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: lesson['isPaid'] == true ? const Color(0xFFEF4444) : const Color(0xFF22C55E)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(lesson['title'] ?? '', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => setState(() => _selectedLesson = lesson),
                                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                        label: Text("مشاهدة الفيديو والشرح ➔", style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF3B82F6),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 11),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
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
    );
  }

  // ==========================================
  // Dedicated Lesson View with YouTube Player, Image & HTML Content
  // ==========================================
  Widget _buildLessonDetailView(BuildContext context, bool isMobile, bool isDark) {
    final lesson = _selectedLesson!;
    final title = lesson['title'] ?? 'درس جديد';
    final youtubeUrl = (lesson['youtubeUrl'] ?? lesson['videoUrl'] ?? '').toString().trim();
    final image = (lesson['image'] ?? lesson['imageUrl'] ?? '').toString().trim();
    final content = (lesson['content'] ?? '').toString().trim();
    final htmlCode = (lesson['htmlCode'] ?? '').toString().trim();
    final displayContent = htmlCode.isNotEmpty
        ? htmlCode
        : (content.isNotEmpty ? content : '');
    final hasQuiz = lesson['hasQuiz'] == true;
    final quizTitle = lesson['quizTitle'] ?? 'اختبار فهم الدرس';
    final isPaid = lesson['isPaid'] == true;
    final lessonId = lesson['id']?.toString();
    final courseId = lesson['courseId']?.toString() ?? lesson['playlistId']?.toString();

    // Check member permissions for paid lesson
    if (!_canAccess(courseId: courseId, lessonId: lessonId, isPaid: isPaid)) {
      return _buildLockedScreen(
        context: context,
        title: title,
        contentType: 'درس',
        isDark: isDark,
        onBack: () => setState(() => _selectedLesson = null),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _selectedLesson = null),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text("العودة لكافة الدروس", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 16),

          Text(title, style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),

          // 1. YouTube Video Player (Only if youtubeUrl is provided and valid)
          if (youtubeUrl.isNotEmpty && youtubeUrl.length > 5) ...[
            YouTubeEmbeddedPlayer(youtubeUrl: youtubeUrl, height: isMobile ? 240 : 480),
            const SizedBox(height: 24),
          ],

          // 2. Image Cover (safely renders without leftover empty box on error)
          if (image.isNotEmpty && image.startsWith('http')) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Content Box (Supports Markdown & HTML)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("شرح وتفاصيل الدرس:", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                const Divider(),
                const SizedBox(height: 8),
                if (displayContent.isNotEmpty)
                  ArticleContentRenderer(content: displayContent, isDark: isDark)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "لا يوجد محتوى نصي إضافي لهذا الدرس، يمكنك مشاهدة الفيديو بالأعلى.",
                        style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),

                // Quiz button
                if (hasQuiz) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openLessonQuizDialog(context, lesson, isDark),
                      icon: const Icon(Icons.quiz_rounded, size: 22),
                      label: Text("$quizTitle 📝", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
                  _quizOptionTile(1, lesson['quizOpt1'] ?? 'إجابة أ', selectedOption, answered, false, () {
                    if (!answered) setDlgState(() { selectedOption = 1; answered = true; });
                  }),
                  _quizOptionTile(2, lesson['quizOpt2'] ?? 'إجابة ب (صحيحة)', selectedOption, answered, true, () {
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

  Widget _buildLockedScreen({
    required BuildContext context,
    required String title,
    required String contentType,
    required bool isDark,
    required VoidCallback onBack,
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
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, size: 56, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 20),
            Text(
              "محتوى محمي وخاص بالمشتركين",
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "عذراً، $contentType \"$title\" متاح فقط للأعضاء المصرح لهم بالدخول.",
              style: GoogleFonts.cairo(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (user == null) ...[
              ElevatedButton.icon(
                onPressed: () => AuthModal.show(context),
                icon: const Icon(Icons.login_rounded),
                label: Text("تسجيل الدخول إلى حسابك", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ] else ...[
              Text(
                "أنت مسجل بحساب: ${user.email ?? ''}\nلتفعيل اشتراكك في هذا المحتوى، يرجى التواصل مباشرة مع إدارة المنصة.",
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                final wa = "https://wa.me/201201509012?text=${Uri.encodeComponent('مرحباً أستاذ إسلام، أود تفعيل الاشتراك في $contentType: $title')}";
                launchUrl(Uri.parse(wa), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.chat_bubble_rounded),
              label: Text("تواصل عبر واتساب لطلب التفعيل 💬", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
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

  Widget _buildPageFooter(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          const SizedBox(height: 16),
          const SocialIconsBar(
            facebookUrl: ArabicData.facebookUrl,
            youtubeUrl: ArabicData.youtubeUrl,
            telegramUrl: ArabicData.telegramUrl,
            linkedinUrl: ArabicData.linkedinUrl,
          ),
          const SizedBox(height: 14),
          Text(
            "جميع الحقوق محفوظة © 2026 Eslam Atef | Code & AI",
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
