import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../services/site_data_service.dart';

class WeeklyChallengePage extends StatefulWidget {
  const WeeklyChallengePage({super.key});

  @override
  State<WeeklyChallengePage> createState() => _WeeklyChallengePageState();
}

class _WeeklyChallengePageState extends State<WeeklyChallengePage> {
  final _dataService = SiteDataService.instance;
  final TextEditingController _codeController = TextEditingController();
  bool _showHint = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    AppThemeManager.themeModeNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    AppThemeManager.themeModeNotifier.removeListener(_onDataChanged);
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final challenge = _dataService.weeklyChallenge;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildPageHeader(context, isMobile, isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    if (challenge == null || challenge['active'] == false)
                      _buildNoChallengeState(isMobile, isDark)
                    else
                      _buildActiveChallengeContent(challenge, isMobile, isDark),
                    const SizedBox(height: 60),
                    _buildPageFooter(context, isMobile, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChallengeState(bool isMobile, bool isDark) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.code_off_rounded, size: 48, color: Color(0xFFFFB300)),
            ),
            const SizedBox(height: 20),
            Text(
              "لا يوجد تحدي نشط لهذا الأسبوع حالياً",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "ترقبوا إطلاق التحدي القادم قريباً! يتم طرح تحديات برمجية أسبوعية حقيقية لصقل مهارات التفكير المنطقي والخوارزميات.",
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text("العودة للرئيسية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/admin'),
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: Text("إضافة تحدي من لوحة التحكم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                    side: BorderSide(color: isDark ? AppColors.borderLightDark : AppColors.borderLightStrong),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallengeContent(Map<String, dynamic> challenge, bool isMobile, bool isDark) {
    final week = challenge['week'] ?? 'الأسبوع الحالي';
    final title = challenge['title'] ?? 'تحدي الأسبوع';
    final difficulty = challenge['difficulty'] ?? 'متوسط 🟡';
    final daysLeft = challenge['daysLeft'] ?? 'متبقي 3 أيام';
    final scenario = challenge['scenario'] ?? '';
    final input = challenge['input'] ?? '';
    final output = challenge['output'] ?? '';
    final hint = challenge['hint'] ?? '';
    final participants = challenge['participants'] ?? 0;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge & Meta Header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      week,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Badges row: Difficulty, Days Left, Participants
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildTag(Icons.speed_rounded, difficulty, const Color(0xFFFFB300), isDark),
                _buildTag(Icons.timer_outlined, daysLeft, const Color(0xFF00E5FF), isDark),
                _buildTag(Icons.people_alt_outlined, "$participants مشارك", const Color(0xFF10B981), isDark),
              ],
            ),
            const SizedBox(height: 30),

            // Scenario Card
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
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
                          color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description_rounded, color: Color(0xFFFFB300), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "وصف وسيناريو التحدي",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    scenario,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input / Output Grid
            if (input.isNotEmpty || output.isNotEmpty)
              isMobile
                  ? Column(
                      children: [
                        _buildCodeBox("المدخلات المتوقعة (Input)", input, Icons.input_rounded, isDark),
                        const SizedBox(height: 16),
                        _buildCodeBox("المخرجات المطلوبة (Output)", output, Icons.output_rounded, isDark),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCodeBox("المدخلات المتوقعة (Input)", input, Icons.input_rounded, isDark)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildCodeBox("المخرجات المطلوبة (Output)", output, Icons.output_rounded, isDark)),
                      ],
                    ),
            const SizedBox(height: 24),

            // Hint Accordion
            if (hint.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D33) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => _showHint = !_showHint),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB300), size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  "هل تحتاج إلى تلميح مساعد؟",
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _showHint ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFFFFB300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showHint) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            hint,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF78350F),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Solution Workspace Card
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
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
                        child: const Icon(Icons.terminal_rounded, color: Color(0xFF00E5FF), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "مساحة كتابة الحل البرمجي",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "اكتب الكود الخاص بك (بأي لغة تفضلها: Python / C++ / JavaScript وغيرها) واضغط على تسليم الحل للمشاركة:",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _codeController,
                      maxLines: 8,
                      style: GoogleFonts.firaCode(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: "# اكتب حلك هنا...\ndef solve():\n    pass",
                        hintStyle: GoogleFonts.firaCode(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSubmitted
                            ? null
                            : () {
                                if (_codeController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("يرجى كتابة الكود أولاً قبل التسليم")),
                                  );
                                  return;
                                }
                                setState(() => _isSubmitted = true);
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                                        const SizedBox(width: 10),
                                        Text(
                                          "تم تسليم الحل بنجاح!",
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      "رائع جداً! تم تسجيل مشاركتك في تحدي الأسبوع بنجاح. سيتم مراجعة الحل وإضافتك لقائمة المتصدرين الأسبوعية.",
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                        height: 1.6,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text("حسناً", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        icon: Icon(_isSubmitted ? Icons.check : Icons.send_rounded, size: 18),
                        label: Text(
                          _isSubmitted ? "تم التسليم بنجاح ✓" : "تسليم الحل البرمجي 🚀",
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    );
  }

  Widget _buildTag(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(String title, String content, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF00E5FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF070B14) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: SelectableText(
              content.isEmpty ? "—" : content,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header
  Widget _buildPageHeader(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset('assets/images/logo.jpeg', width: 40, height: 40, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ArabicData.brandName,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            "تحدي الأسبوع البرمجي",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFB300),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
                      size: 22,
                    ),
                    onPressed: () => AppThemeManager.toggleTheme(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                    icon: const Icon(Icons.home_outlined, size: 16),
                    label: Text("الرئيسية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  // Footer
  Widget _buildPageFooter(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070A12) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: 32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _footerLink("الرئيسية", () => Navigator.of(context).pushReplacementNamed('/'), isDark),
                  _footerLink("الكورسات", () => Navigator.of(context).pushNamed('/courses'), isDark),
                  _footerLink("الدروس", () => Navigator.of(context).pushNamed('/lessons'), isDark),
                  _footerLink("اختبر نفسك 🧠", () => Navigator.of(context).pushNamed('/quiz'), isDark),
                  _footerLink("لوحة التحكم ⚙️", () => Navigator.of(context).pushNamed('/admin'), isDark),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                "© 2026 Eslam Atef | Code & AI — جميع الحقوق محفوظة",
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap, bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
