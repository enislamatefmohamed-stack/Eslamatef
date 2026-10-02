import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../services/site_data_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

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
    final challenge = _dataService.getActiveChallenge();

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
                    if (challenge == null || challenge['status'] == 'مسودة')
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

  void _openSubmitChallengeDialog(Map<String, dynamic> challenge, bool isDark) {
    final user = AuthService.instance.currentUser;
    final nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final gradeCtrl = TextEditingController();
    final weekRaw = challenge['week']?.toString() ?? '1';
    final weekNum = RegExp(r'\d+').firstMatch(weekRaw)?.group(0) ?? '1';
    final challengeNumCtrl = TextEditingController(text: weekNum);
    final projectUrlCtrl = TextEditingController();
    final fileUrlCtrl = TextEditingController();
    final messageCtrl = TextEditingController(text: _codeController.text.isNotEmpty ? "كود الحل المكتوب:\n${_codeController.text}" : "");
    String? pickedFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, color: Color(0xFF8B5CF6), size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                "📩 أرسل التحدي للمدرس",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      "تحدي: ${challenge['title'] ?? ''}",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  _buildFormField("الاسم بالكامل *", nameCtrl, isDark),
                  _buildFormField("البريد الإلكتروني *", emailCtrl, isDark),
                  _buildFormField("الصف الدراسي (مثال: الصف الثاني الثانوي) *", gradeCtrl, isDark),
                  _buildFormField("رقم التحدي *", challengeNumCtrl, isDark),
                  _buildFormField("رابط المشروع GitHub / Drive *", projectUrlCtrl, isDark),
                  
                  // File upload optional
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("رفع ملف الحل — اختياري", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.pickFiles(type: FileType.any);
                                if (result.isNotEmpty) {
                                  final name = result.first.name;
                                  setDialogState(() {
                                    pickedFileName = name;
                                    fileUrlCtrl.text = "ملف مرفق: $name";
                                  });
                                }
                              },
                              icon: const Icon(Icons.attach_file_rounded, size: 16),
                              label: Text(pickedFileName != null ? "تغيير الملف" : "اختر ملف الحل", style: GoogleFonts.cairo(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8B5CF6),
                                side: const BorderSide(color: Color(0xFF8B5CF6)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pickedFileName ?? "أو الصق رابط الملف أدناه",
                                style: GoogleFonts.cairo(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: fileUrlCtrl,
                          style: GoogleFonts.cairo(fontSize: 12, color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "رابط ملف إضافي (Google Drive أو غيره)",
                            filled: true,
                            fillColor: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildFormField("رسالة للمدرس (ملاحظاتك، استفسارك، أو كود الحل)", messageCtrl, isDark, maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final studentName = nameCtrl.text.trim();
                final studentEmail = emailCtrl.text.trim();
                final studentGrade = gradeCtrl.text.trim();
                final challengeNum = challengeNumCtrl.text.trim();
                final projectUrl = projectUrlCtrl.text.trim();
                final fileUrl = fileUrlCtrl.text.trim();
                final teacherMessage = messageCtrl.text.trim();

                if (studentName.isEmpty || studentEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("يرجى إدخال الاسم والبريد الإلكتروني")),
                  );
                  return;
                }

                Navigator.pop(ctx);

                // 1. Record submission in local / Firebase
                final submissionData = {
                  'challengeId': challenge['id'] ?? 'chall_w$challengeNum',
                  'challengeTitle': challenge['title'] ?? 'تحدي الأسبوع $challengeNum',
                  'challengeNum': challengeNum,
                  'studentName': studentName,
                  'email': studentEmail,
                  'grade': studentGrade,
                  'projectUrl': projectUrl,
                  'fileUrl': fileUrl,
                  'message': teacherMessage,
                  'date': "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                  'status': 'جديد',
                };

                await _dataService.addChallengeSubmission(submissionData);
                if (user != null) {
                  await UserService.instance.recordChallengeSubmission(user.uid, submissionData);
                }

                // 2. Open email client with full submission details
                const teacherEmail = "en.islam.atef.mohamed@gmail.com";
                final subject = Uri.encodeComponent("حل تحدي الأسبوع $challengeNum - $studentName");
                final body = Uri.encodeComponent("""
السلام عليكم ورحمة الله،
أستاذ إسلام عاطف، تم إرسال حل تحدي الأسبوع عبر المنصة:

• اسم الطالب: $studentName
• البريد الإلكتروني: $studentEmail
• الصف الدراسي: $studentGrade
• رقم التحدي: $challengeNum
• عنوان التحدي: ${challenge['title'] ?? ''}

• رابط المشروع (GitHub / Drive):
$projectUrl

• ملف الحل:
$fileUrl

• رسالة الطالب للمدرس:
$teacherMessage
""");

                final mailtoUri = Uri.parse("mailto:$teacherEmail?subject=$subject&body=$body");
                try {
                  if (await canLaunchUrl(mailtoUri)) {
                    await launchUrl(mailtoUri);
                  }
                } catch (e) {
                  debugPrint("Error opening mail client: $e");
                }

                if (!mounted) return;
                setState(() => _isSubmitted = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🎉 تم تسجيل وإرسال حلك بنجاح! سيتم مراجعته والتواصل معك."),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("[ إرسال الحل 🚀 ]", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController ctrl, bool isDark, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.cairo(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
            ),
          ),
        ],
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
                if (AuthService.instance.isAdmin)
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
    final requirements = challenge['requirements'] ?? '';
    final conditions = challenge['conditions'] ?? '';
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
            // Friday transition banner if today is Friday
            if (_dataService.isFridayTransitionDay()) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      const Color(0xFF0284C7).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: Color(0xFF8B5CF6), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "⏳ اليوم الجمعة: فترة انتقالية وتحضيرية — التحدي الجديد القادم ينطلق تلقائياً صباح غد السبت بإذن الله!",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                        "وصف المشكلة والسيناريو",
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

            // Requirements Card if present
            if (requirements.isNotEmpty) ...[
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
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.task_alt_rounded, color: Color(0xFF0284C7), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          "المطلوب",
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
                      requirements,
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
            ],

            // Conditions Card if present
            if (conditions.isNotEmpty) ...[
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
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.rule_folder_rounded, color: Color(0xFF8B5CF6), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          "شروط التحدي",
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
                      conditions,
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
            ],

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
                            : () => _openSubmitChallengeDialog(challenge, isDark),
                        icon: Icon(_isSubmitted ? Icons.check : Icons.send_rounded, size: 18),
                        label: Text(
                          _isSubmitted ? "تم الإرسال بنجاح ✓" : "📩 أرسل التحدي",
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
