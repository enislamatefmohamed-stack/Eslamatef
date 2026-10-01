import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/site_data_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dataService = SiteDataService.instance;

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
    _tabController = TabController(length: 5, vsync: this);
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
    _tabController.dispose();
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 1,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00E5FF), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                "لوحة التحكم — Eslam Atef",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          actions: [
            // Theme toggle
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
              ),
              tooltip: isDark ? "تفعيل الوضع النهاري" : "تفعيل الوضع الليلي",
              onPressed: () => AppThemeManager.toggleTheme(),
            ),
            const SizedBox(width: 8),
            // Back to site button
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text("الموقع الرئيسي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(width: 16),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF00E5FF),
            unselectedLabelColor: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            indicatorColor: const Color(0xFF00E5FF),
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(icon: Icon(Icons.laptop_chromebook_rounded), text: "الكورسات"),
              Tab(icon: Icon(Icons.menu_book_rounded), text: "الدروس"),
              Tab(icon: Icon(Icons.view_carousel_rounded), text: "أحدث الإضافات"),
              Tab(icon: Icon(Icons.code_rounded), text: "تحدي الأسبوع"),
              Tab(icon: Icon(Icons.quiz_rounded), text: "اختبر نفسك"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCoursesTab(isDark),
            _buildLessonsTab(isDark),
            _buildLatestUpdatesTab(isDark),
            _buildWeeklyChallengeTab(isDark),
            _buildQuizQuestionsTab(isDark),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: الكورسات
  // ==========================================
  Widget _buildCoursesTab(bool isDark) {
    final courses = _dataService.courses;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إدارة الكورسات (${courses.length})",
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCourseDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: Text("إضافة كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: courses.isEmpty
                ? _buildEmptyState("لا توجد كورسات مضافة حالياً. اضغط على 'إضافة كورس جديد' للبدء.")
                : ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (ctx, i) {
                      final c = courses[i];
                      return _buildItemCard(
                        isDark: isDark,
                        title: c['title'] ?? '',
                        subtitle: "${c['category'] ?? ''} • ${c['duration'] ?? ''}",
                        tag: c['badge'] ?? 'كورس',
                        onEdit: () => _showCourseDialog(course: c),
                        onDelete: () => _dataService.deleteCourse(c['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCourseDialog({Map<String, dynamic>? course}) {
    final isEdit = course != null;
    final titleCtrl = TextEditingController(text: course?['title'] ?? '');
    final catCtrl = TextEditingController(text: course?['category'] ?? 'كورس تأسيسي');
    final durCtrl = TextEditingController(text: course?['duration'] ?? '30 ساعة');
    final badgeCtrl = TextEditingController(text: course?['badge'] ?? 'Clean Code');
    final descCtrl = TextEditingController(text: course?['description'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEdit ? "تعديل الكورس" : "إضافة كورس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "عنوان الكورس")),
                  const SizedBox(height: 12),
                  TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "التصنيف / المجال")),
                  const SizedBox(height: 12),
                  TextField(controller: durCtrl, decoration: const InputDecoration(labelText: "المدة الزمنية (مثال: 36 ساعة)")),
                  const SizedBox(height: 12),
                  TextField(controller: badgeCtrl, decoration: const InputDecoration(labelText: "الشارة (Badge)")),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "وصف الكورس")),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final data = {
                  if (isEdit) 'id': course['id'],
                  'title': titleCtrl.text.trim(),
                  'category': catCtrl.text.trim(),
                  'duration': durCtrl.text.trim(),
                  'badge': badgeCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'image': course?['image'] ?? 'assets/images/slide1.png',
                };
                if (isEdit) {
                  _dataService.updateCourse(course['id'], data);
                } else {
                  _dataService.addCourse(data);
                }
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? "حفظ التعديلات" : "إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: الدروس
  // ==========================================
  Widget _buildLessonsTab(bool isDark) {
    final lessons = _dataService.lessons;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إدارة الدروس (${lessons.length})",
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showLessonDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: Text("إضافة درس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: lessons.isEmpty
                ? _buildEmptyState("لا توجد دروس مضافة حالياً. اضغط على 'إضافة درس جديد' للبدء.")
                : ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (ctx, i) {
                      final l = lessons[i];
                      return _buildItemCard(
                        isDark: isDark,
                        title: l['title'] ?? '',
                        subtitle: "${l['category'] ?? ''} • ${l['duration'] ?? ''}",
                        tag: l['badge'] ?? 'درس',
                        onEdit: () => _showLessonDialog(lesson: l),
                        onDelete: () => _dataService.deleteLesson(l['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showLessonDialog({Map<String, dynamic>? lesson}) {
    final isEdit = lesson != null;
    final titleCtrl = TextEditingController(text: lesson?['title'] ?? '');
    final catCtrl = TextEditingController(text: lesson?['category'] ?? 'ذكاء اصطناعي');
    final durCtrl = TextEditingController(text: lesson?['duration'] ?? '25 دقيقة');
    final badgeCtrl = TextEditingController(text: lesson?['badge'] ?? 'جديد');
    final descCtrl = TextEditingController(text: lesson?['description'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEdit ? "تعديل الدرس" : "إضافة درس جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "عنوان الدرس")),
                  const SizedBox(height: 12),
                  TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "التصنيف / المادة")),
                  const SizedBox(height: 12),
                  TextField(controller: durCtrl, decoration: const InputDecoration(labelText: "المدة الزمنية (مثال: 25 دقيقة)")),
                  const SizedBox(height: 12),
                  TextField(controller: badgeCtrl, decoration: const InputDecoration(labelText: "الشارة (Badge)")),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "وصف الدرس")),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final data = {
                  if (isEdit) 'id': lesson['id'],
                  'title': titleCtrl.text.trim(),
                  'category': catCtrl.text.trim(),
                  'duration': durCtrl.text.trim(),
                  'badge': badgeCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'image': lesson?['image'] ?? 'assets/images/slide2.png',
                };
                if (isEdit) {
                  _dataService.updateLesson(lesson['id'], data);
                } else {
                  _dataService.addLesson(data);
                }
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? "حفظ التعديلات" : "إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: أحدث الإضافات (شريط السلايدر المربع)
  // ==========================================
  Widget _buildLatestUpdatesTab(bool isDark) {
    final updates = _dataService.latestUpdates;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "شريط أحدث الإضافات (${updates.length})",
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "يتم عرض هذه الكورسات والدروس في السلايدر المربع في الصفحة الرئيسية",
                    style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showUpdateDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: Text("إضافة تحديث جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: updates.isEmpty
                ? _buildEmptyState("شريط التحديثات فارغ حالياً (لا توجد بيانات وهمية). يمكنك إضافة محتواك الفعلي الآن.")
                : ListView.builder(
                    itemCount: updates.length,
                    itemBuilder: (ctx, i) {
                      final u = updates[i];
                      return _buildItemCard(
                        isDark: isDark,
                        title: u['title'] ?? '',
                        subtitle: "${u['category'] ?? ''} • ${u['duration'] ?? ''}",
                        tag: u['badge'] ?? 'جديد',
                        onEdit: () => _showUpdateDialog(update: u),
                        onDelete: () => _dataService.deleteLatestUpdate(u['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog({Map<String, dynamic>? update}) {
    final isEdit = update != null;
    final titleCtrl = TextEditingController(text: update?['title'] ?? '');
    final catCtrl = TextEditingController(text: update?['category'] ?? 'كورس جديد');
    final durCtrl = TextEditingController(text: update?['duration'] ?? '30 ساعة');
    final badgeCtrl = TextEditingController(text: update?['badge'] ?? 'أحدث تقنية');
    String type = update?['type'] ?? 'course';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(isEdit ? "تعديل التحديث" : "إضافة تحديث للسلايدر", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(labelText: "نوع الإضافة"),
                      items: const [
                        DropdownMenuItem(value: 'course', child: Text("كورس (يربط بصفحة الكورسات)")),
                        DropdownMenuItem(value: 'lesson', child: Text("درس (يربط بصفحة الدروس)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDlgState(() => type = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "عنوان الإضافة")),
                    const SizedBox(height: 12),
                    TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "التصنيف (مثال: كورس جديد / درس جديد)")),
                    const SizedBox(height: 12),
                    TextField(controller: durCtrl, decoration: const InputDecoration(labelText: "المدة الزمنية")),
                    const SizedBox(height: 12),
                    TextField(controller: badgeCtrl, decoration: const InputDecoration(labelText: "الشارة (Badge)")),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final data = {
                    if (isEdit) 'id': update['id'],
                    'title': titleCtrl.text.trim(),
                    'category': catCtrl.text.trim(),
                    'type': type,
                    'route': type == 'course' ? '/courses' : '/lessons',
                    'duration': durCtrl.text.trim(),
                    'badge': badgeCtrl.text.trim(),
                    'image': update?['image'] ?? (type == 'course' ? 'assets/images/slide1.png' : 'assets/images/slide2.png'),
                  };
                  if (isEdit) {
                    _dataService.updateLatestUpdate(update['id'], data);
                  } else {
                    _dataService.addLatestUpdate(data);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(isEdit ? "حفظ التعديل" : "إضافة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 4: تحدي الأسبوع
  // ==========================================
  Widget _buildWeeklyChallengeTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "إدارة تحدي الأسبوع البرمجي",
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "عند تعطيل التحدي أو حذفه، لن يظهر أي نص وهمي في الصفحة الرئيسية",
                    style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Switch(
                value: _challengeActive,
                activeThumbColor: const Color(0xFF00E5FF),
                onChanged: (val) {
                  setState(() => _challengeActive = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _challengeWeekCtrl,
                        decoration: const InputDecoration(labelText: "رقم الأسبوع (مثال: الأسبوع 42)"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _challengeDiffCtrl,
                        decoration: const InputDecoration(labelText: "المستوى (مثال: مستوى: متوسط)"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _challengeDaysCtrl,
                        decoration: const InputDecoration(labelText: "الوقت المتبقي (مثال: ينتهي خلال 3 أيام)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _challengeTitleCtrl,
                  decoration: const InputDecoration(labelText: "عنوان التحدي"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _challengeScenarioCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "سيناريو وشرح المسألة البرمجية"),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _challengeInputCtrl,
                        decoration: const InputDecoration(labelText: "نموذج المدخلات (Input)"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _challengeOutputCtrl,
                        decoration: const InputDecoration(labelText: "الناتج المتوقع (Output)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _challengeHintCtrl,
                  decoration: const InputDecoration(labelText: "تلميح الخوارزمية (اختياري)"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _challengeParticipantsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "عدد المشاركين الحاليين"),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (!_challengeActive) {
                          await _dataService.setWeeklyChallenge(null);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("تم تعطيل تحدي الأسبوع وإخفاؤه")),
                          );
                          return;
                        }
                        final map = {
                          'active': true,
                          'week': _challengeWeekCtrl.text.trim(),
                          'title': _challengeTitleCtrl.text.trim(),
                          'difficulty': _challengeDiffCtrl.text.trim(),
                          'daysLeft': _challengeDaysCtrl.text.trim(),
                          'scenario': _challengeScenarioCtrl.text.trim(),
                          'input': _challengeInputCtrl.text.trim(),
                          'output': _challengeOutputCtrl.text.trim(),
                          'hint': _challengeHintCtrl.text.trim(),
                          'participants': int.tryParse(_challengeParticipantsCtrl.text.trim()) ?? 0,
                        };
                        await _dataService.setWeeklyChallenge(map);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم حفظ وتحديث تحدي الأسبوع بنجاح!")),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text("حفظ تحدي الأسبوع", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _challengeActive = false;
                          _challengeWeekCtrl.clear();
                          _challengeTitleCtrl.clear();
                          _challengeScenarioCtrl.clear();
                          _challengeInputCtrl.clear();
                          _challengeOutputCtrl.clear();
                          _challengeHintCtrl.clear();
                        });
                        await _dataService.setWeeklyChallenge(null);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم مسح تحدي الأسبوع")),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      label: Text("مسح وحذف التحدي", style: GoogleFonts.cairo(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
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

  // ==========================================
  // TAB 5: اختبر نفسك
  // ==========================================
  Widget _buildQuizQuestionsTab(bool isDark) {
    final questions = _dataService.quizQuestions;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "إدارة أسئلة «اختبر نفسك» (${questions.length})",
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "تم مسح الأسئلة الوهمية السابقة؛ أضف أسئلتك المنهجية الفعلية هنا",
                    style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showQuizDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: Text("إضافة سؤال جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: questions.isEmpty
                ? _buildEmptyState("لا توجد أسئلة حالياً (تم إفراغ الأسئلة الوهمية). اضغط على 'إضافة سؤال جديد' لإضافة أسئلة حقيقية.")
                : ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (ctx, i) {
                      final q = questions[i];
                      final opts = (q['options'] as List<dynamic>? ?? []).join(" | ");
                      return _buildItemCard(
                        isDark: isDark,
                        title: q['question'] ?? '',
                        subtitle: "الخيارات: $opts",
                        tag: "إجابة #${(q['correctIndex'] ?? 0) + 1}",
                        onEdit: () => _showQuizDialog(question: q),
                        onDelete: () => _dataService.deleteQuizQuestion(q['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showQuizDialog({Map<String, dynamic>? question}) {
    final isEdit = question != null;
    final qCtrl = TextEditingController(text: question?['question'] ?? '');
    final opt0Ctrl = TextEditingController(text: (question?['options'] as List<dynamic>?)?.elementAtOrNull(0) ?? '');
    final opt1Ctrl = TextEditingController(text: (question?['options'] as List<dynamic>?)?.elementAtOrNull(1) ?? '');
    final opt2Ctrl = TextEditingController(text: (question?['options'] as List<dynamic>?)?.elementAtOrNull(2) ?? '');
    final opt3Ctrl = TextEditingController(text: (question?['options'] as List<dynamic>?)?.elementAtOrNull(3) ?? '');
    final expCtrl = TextEditingController(text: question?['explanation'] ?? '');
    int correctIndex = question?['correctIndex'] ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(isEdit ? "تعديل السؤال" : "إضافة سؤال جديد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: qCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "نص السؤال")),
                    const SizedBox(height: 14),
                    _buildOptionInput("الخيار الأول", opt0Ctrl, 0, correctIndex, (v) => setDlgState(() => correctIndex = v)),
                    _buildOptionInput("الخيار الثاني", opt1Ctrl, 1, correctIndex, (v) => setDlgState(() => correctIndex = v)),
                    _buildOptionInput("الخيار الثالث", opt2Ctrl, 2, correctIndex, (v) => setDlgState(() => correctIndex = v)),
                    _buildOptionInput("الخيار الرابع", opt3Ctrl, 3, correctIndex, (v) => setDlgState(() => correctIndex = v)),
                    const SizedBox(height: 12),
                    TextField(controller: expCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "تفسير وشرح الإجابة الصحيحة")),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: GoogleFonts.cairo())),
              ElevatedButton(
                onPressed: () {
                  if (qCtrl.text.trim().isEmpty) return;
                  final opts = [
                    opt0Ctrl.text.trim(),
                    opt1Ctrl.text.trim(),
                    opt2Ctrl.text.trim(),
                    opt3Ctrl.text.trim(),
                  ];
                  final data = {
                    if (isEdit) 'id': question['id'],
                    'question': qCtrl.text.trim(),
                    'options': opts,
                    'correctIndex': correctIndex,
                    'explanation': expCtrl.text.trim(),
                  };
                  if (isEdit) {
                    _dataService.updateQuizQuestion(question['id'], data);
                  } else {
                    _dataService.addQuizQuestion(data);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(isEdit ? "حفظ السؤال" : "إضافة السؤال", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionInput(String label, TextEditingController ctrl, int idx, int selected, ValueChanged<int> onSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              idx == selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: idx == selected ? const Color(0xFF10B981) : AppColors.textSecondary,
            ),
            tooltip: "تعيين كإجابة صحيحة",
            onPressed: () => onSelected(idx),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: "$label ${idx == selected ? ' (الإجابة الصحيحة)' : ''}",
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Shared Item Card ---
  Widget _buildItemCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String tag,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF00E5FF)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF00E5FF)),
            tooltip: "تعديل",
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
            tooltip: "حذف",
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
