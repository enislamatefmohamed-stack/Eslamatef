// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';
import '../services/site_data_service.dart';
import '../data/kids_course_sessions_data.dart';
import '../widgets/recording_launcher/recording_launcher.dart';
import '../widgets/kids_session_code_editor_dialog.dart';

class RecordingStudioPage extends StatefulWidget {
  const RecordingStudioPage({super.key});

  @override
  State<RecordingStudioPage> createState() => _RecordingStudioPageState();
}

class _RecordingStudioPageState extends State<RecordingStudioPage> {
  int _selectedTab = 0; // 0: كورس الأطفال (49 جلسة), 1: المرحلة الثانوية والمحاضرات العامة
  String _kidsSearch = '';
  int _kidsSelectedLevel = 0; // 0: الكل, 1..7: المستويات

  Future<void> _launchDefaultPresentation(BuildContext context) async {
    final uri = Uri.parse('presentation/index.html');
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح العرض التقديمي مباشرة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/recording') : null,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                const UnifiedAppHeader(
                  currentRoute: '/recording',
                  pageTitle: 'أستوديو تسجيل الحصص والمحاضرات',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildRecordingContent(context, isMobile, screenWidth, isDark),
                        const SizedBox(height: 60),
                        const UnifiedAppFooter(),
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

  Widget _buildRecordingContent(BuildContext context, bool isMobile, double screenWidth, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_rounded, color: Color(0xFF0284C7), size: 18),
                const SizedBox(width: 8),
                Text(
                  "استوديو التصوير والعروض التقديمية التفاعلية",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            "جلسات تصوير المحاضرات وشاشات التسجيل 🎬",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 22 : 34,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "عروض تقديمية بنسبة 16:9 للشاشات الكاملة والتسجيل المباشر. يمكنك تشغيل أي جلسة، اختبارها، أو تعديل كود HTML الخاص بها فوراً.",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 13.5 : 15.5,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Main Tabs Switcher (كورس الأطفال vs المرحلة الثانوية)
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabBtn(
                  index: 0,
                  title: "كورس الأطفال (49 جلسة تصوير) 🚀",
                  icon: Icons.slideshow_rounded,
                  count: KidsCourseSessionsData.allSessions.length,
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildTabBtn(
                  index: 1,
                  title: "جلسات المرحلة الثانوية 🎥",
                  icon: Icons.videocam_rounded,
                  count: SiteDataService.instance.recordingLessons.length,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Tab Content
          if (_selectedTab == 0)
            _buildKidsSessionsTabContent(context, isMobile, screenWidth, isDark)
          else
            _buildSecondarySessionsTabContent(context, isMobile, isDark),

          const SizedBox(height: 48),

          // Shortcut Guide
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLightDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⌨️ مفاتيح التحكم السريعة أثناء تسجيل وعرض الجلسات:",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _buildKeyItem("Next / Space / Left", "الشريحة أو الخطوة التالية"),
                    _buildKeyItem("Prev / Right", "الخطوة أو الشريحة السابقة"),
                    _buildKeyItem("F / F11", "ملء الشاشة Fullscreen"),
                    _buildKeyItem("P", "تفعيل / تعطيل القلم التفاعلي"),
                    _buildKeyItem("H", "قلم التمييز Highlighter"),
                    _buildKeyItem("E", "الممحاة Eraser"),
                    _buildKeyItem("C", "مسح رسم الشريحة الحالية"),
                    _buildKeyItem("B", "إخفاء / إظهار شريط الأدوات"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBtn({
    required int index,
    required String title,
    required IconData icon,
    required int count,
    required bool isDark,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0284C7) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF0284C7))
                  : (isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? Colors.white70 : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white.withOpacity(0.2) : const Color(0xFF0284C7).withOpacity(0.12))
                    : (isDark ? Colors.white10 : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0284C7))
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 1. جلسات تصوير كورس الأطفال (KIDS SESSIONS TAB)
  // =========================================================================
  Widget _buildKidsSessionsTabContent(
      BuildContext context, bool isMobile, double screenWidth, bool isDark) {
    final allSessions = KidsCourseSessionsData.allSessions;

    final filtered = allSessions.where((s) {
      final matchesLevel = _kidsSelectedLevel == 0 || s.levelNumber == _kidsSelectedLevel;
      final q = _kidsSearch.trim().toLowerCase();
      if (q.isEmpty) return matchesLevel;

      final matchesQuery = s.title.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.formattedNumber.contains(q) ||
          s.levelName.toLowerCase().contains(q) ||
          s.topics.any((t) => t.toLowerCase().contains(q));

      return matchesLevel && matchesQuery;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and Filters Bar
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              TextField(
                onChanged: (val) => setState(() => _kidsSearch = val),
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: "ابحث في جلسات كورس الأطفال (بالرقم، العنوان، الموضوع، أو المستوى)...",
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0284C7)),
                  suffixIcon: _kidsSearch.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() => _kidsSearch = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Level filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(KidsCourseSessionsData.levels.length, (idx) {
                    final isSelected = _kidsSelectedLevel == idx;
                    final label = KidsCourseSessionsData.levels[idx];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(label),
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : const Color(0xFF475569)),
                        ),
                        selectedColor: const Color(0xFF0284C7),
                        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0284C7)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        onSelected: (_) => setState(() => _kidsSelectedLevel = idx),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Result count & Quick info
        Row(
          children: [
            Text(
              "عدد الجلسات المعروضة: ${filtered.length} من أصل 49",
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const Spacer(),
            if (_kidsSearch.isNotEmpty || _kidsSelectedLevel != 0)
              TextButton.icon(
                onPressed: () => setState(() {
                  _kidsSearch = '';
                  _kidsSelectedLevel = 0;
                }),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text("إعادة ضبط الفلاتر", style: GoogleFonts.cairo(fontSize: 12)),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Grid of Kids Sessions Cards
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text(
                  "لا توجد جلسات تطابق معايير البحث الحالية",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : (screenWidth < 1100 ? 2 : 3),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 320,
            ),
            itemBuilder: (ctx, i) => _buildKidsSessionCard(filtered[i], isDark),
          ),
      ],
    );
  }

  Widget _buildKidsSessionCard(KidsSessionItem session, bool isDark) {
    final customCode = SiteDataService.instance.getKidsSessionCustomCode(session.number);
    final hasCustomCode = customCode != null && customCode.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasCustomCode
              ? const Color(0xFF8B5CF6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: hasCustomCode ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasCustomCode
                ? const Color(0xFF8B5CF6).withOpacity(0.12)
                : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasCustomCode
                  ? (isDark ? const Color(0xFF2E1065) : const Color(0xFFFAF5FF))
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: hasCustomCode
                      ? const Color(0xFFDDD6FE)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                ),
              ),
            ),
            child: Row(
              children: [
                // Session Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasCustomCode ? const Color(0xFF7C3AED) : const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${session.formattedNumber}",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Level Tag
                Expanded(
                  child: Text(
                    "المستوى ${session.levelNumber}: ${session.levelName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                if (hasCustomCode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                    ),
                    child: Text(
                      "✨ كود مخصص",
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF7C3AED),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  // Topic Chips
                  if (session.topics.isNotEmpty)
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: session.topics.take(3).map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "#$topic",
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.filter_none_rounded, size: 13, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text(
                        "${session.slidesCount} شريحة تفاعلية",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border(
                top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              children: [
                // 1. Play Session Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      session.launchSession();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("جاري فتح جلسة العرض #${session.formattedNumber}... 🎬"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                    label: Text(
                      hasCustomCode ? "تشغيل (مخصص) 🎬" : "تشغيل الجلسة 🎬",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasCustomCode ? const Color(0xFF7C3AED) : const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 2. EDIT SESSION CODE BUTTON (تعديل كود الجلسة)
                IconButton(
                  onPressed: () => KidsSessionCodeEditorDialog.show(
                    context,
                    session,
                    onSaved: () => setState(() {}),
                  ),
                  icon: Icon(
                    hasCustomCode ? Icons.edit_note_rounded : Icons.code_rounded,
                    size: 19,
                    color: hasCustomCode ? const Color(0xFF7C3AED) : const Color(0xFF0284C7),
                  ),
                  tooltip: "تعديل كود الجلسة (HTML) 💻",
                  style: IconButton.styleFrom(
                    backgroundColor: hasCustomCode
                        ? const Color(0xFFEDE9FE)
                        : const Color(0xFFE0F2FE),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 6),

                // 3. Quiz Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => session.launchQuiz(),
                    icon: const Icon(Icons.quiz_rounded, size: 14, color: Color(0xFF0284C7)),
                    label: Text(
                      "الاختبار 🧪",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                      backgroundColor: const Color(0xFFF0F9FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. جلسات تسجيل المرحلة الثانوية (SECONDARY RECORDING LESSONS TAB)
  // =========================================================================
  Widget _buildSecondarySessionsTabContent(BuildContext context, bool isMobile, bool isDark) {
    return ListenableBuilder(
      listenable: SiteDataService.instance,
      builder: (context, _) {
        final sessions = SiteDataService.instance.recordingLessons;
        if (sessions.isEmpty) {
          return _buildDefaultSessionCard(context, isMobile, isDark);
        }
        return Column(
          children: sessions.map((rec) => _buildDynamicSessionCard(context, rec, isMobile, isDark)).toList(),
        );
      },
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLightDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicSessionCard(BuildContext context, Map<String, dynamic> rec, bool isMobile, bool isDark) {
    final title = rec['title'] ?? 'جلسة تدريسية';
    final subject = rec['subject'] ?? 'الصف الأول الثانوي — مادة البرمجة والذكاء الاصطناعي';
    final date = rec['date'] ?? '2026';
    final code = (rec['code'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF00E5FF).withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF00E5FF).withOpacity(0.12) : Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                ),
                child: Text(
                  subject,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "تاريخ: $date",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "عرض تفاعلي شامل مبني بالكامل على المحتوى والمصطلحات المعتمدة. يشمل السبورة الذكية، الأكواد البرمجية، والاختبارات التفاعلية الفورية المجهزة لتسجيل الحصص والشاشات بجودة عالية.",
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),

          // Features Badges
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildFeatureChip(Icons.aspect_ratio_rounded, "نسبة 16:9 ملء الشاشة"),
              _buildFeatureChip(Icons.edit_rounded, "قلم ووايت بورد مدمج"),
              _buildFeatureChip(Icons.touch_app_rounded, "تحكم يدوي للمدرس (No Auto-play)"),
              _buildFeatureChip(Icons.quiz_rounded, "اختبارات تفاعلية فورية"),
              _buildFeatureChip(Icons.keyboard_rounded, "دعم اختصارات لوحة المفاتيح"),
            ],
          ),
          const SizedBox(height: 34),

          // Launch Button
          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 360,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (code.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('كود الجلسة فارغ! يرجى إضافة الكود أولاً')),
                    );
                    return;
                  }
                  openRecordingPresentation(code, title: title);
                },
                icon: const Icon(Icons.play_circle_fill_rounded, size: 26),
                label: Text(
                  "بدء العرض والتسجيل الآن",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0A0F1D),
                  elevation: 10,
                  shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSessionCard(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF00E5FF).withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF00E5FF).withOpacity(0.12) : Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                ),
                child: Text(
                  "الصف الأول الثانوي — مادة البرمجة والذكاء الاصطناعي",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "جلسة نموذجية",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            "المحاضرة الأولى: البيانات والمعلومات والمعرفة",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "عرض تفاعلي شامل مبني بالكامل على المحتوى والمصطلحات المعتمدة في المنهج المدرسي. يتضمن تعاريف البيانات والمعلومات والمعرفة، الخصائص الرسمية، المقارنات البصرية، المصادر الأولية والثانوية، واختبار تفاعلي.",
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),

          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildFeatureChip(Icons.aspect_ratio_rounded, "نسبة 16:9 ملء الشاشة"),
              _buildFeatureChip(Icons.edit_rounded, "قلم ووايت بورد مدمج"),
              _buildFeatureChip(Icons.touch_app_rounded, "تحكم يدوي للمدرس"),
              _buildFeatureChip(Icons.quiz_rounded, "اختبارات تفاعلية فورية"),
              _buildFeatureChip(Icons.keyboard_rounded, "دعم اختصارات لوحة المفاتيح"),
            ],
          ),
          const SizedBox(height: 34),

          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 360,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _launchDefaultPresentation(context),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 26),
                label: Text(
                  "بدء العرض والتسجيل الآن",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF0A0F1D),
                  elevation: 10,
                  shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyItem(String key, String desc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
          ),
          child: Text(
            key,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00E5FF),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          desc,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
