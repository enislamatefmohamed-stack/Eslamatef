import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../services/site_data_service.dart';
import '../services/auth_service.dart';
import '../widgets/article_content_renderer.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _dataService = SiteDataService.instance;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;
  bool _isFinished = false;

  Map<String, dynamic>? _selectedInteractiveQuiz;
  final TextEditingController _htmlStudentScoreCtrl = TextEditingController(text: '10');
  bool _htmlQuizSubmitted = false;

  bool _isStudentRegistered = false;
  final TextEditingController _studentNameCtrl = TextEditingController();
  final TextEditingController _studentPhoneCtrl = TextEditingController();
  final TextEditingController _studentWhatsappCtrl = TextEditingController();
  String _studentCountry = 'مصر';
  DateTime? _startTime;

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
    _studentNameCtrl.dispose();
    _studentPhoneCtrl.dispose();
    _studentWhatsappCtrl.dispose();
    _htmlStudentScoreCtrl.dispose();
    super.dispose();
  }

  void _handleOptionSelect(int index, int correctIndex) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == correctIndex) {
        _score++;
      }
    });
  }

  void _handleNext(int totalQuestions) {
    if (_currentIndex + 1 < totalQuestions) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      final endTime = DateTime.now();
      _dataService.addQuizSubmission({
        'quizId': 'quiz_general',
        'quizTitle': 'اختبار قياس المستوى البرمجي',
        'studentName': _studentNameCtrl.text.trim().isNotEmpty ? _studentNameCtrl.text.trim() : 'طالب زائر',
        'phone': _studentPhoneCtrl.text.trim(),
        'whatsapp': _studentWhatsappCtrl.text.trim(),
        'country': _studentCountry,
        'score': _score,
        'totalQuestions': totalQuestions,
        'startTime': _startTime != null ? "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}" : "10:00",
        'endTime': "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
        'date': "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOption = null;
      _answered = false;
      _score = 0;
      _isFinished = false;
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interactiveQuizzes = _dataService.interactiveQuizzes;
    final questions = _dataService.quizQuestions;

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
                        const SizedBox(height: 30),
                        if (interactiveQuizzes.isNotEmpty)
                          _selectedInteractiveQuiz != null
                              ? _buildInteractiveHtmlQuizView(_selectedInteractiveQuiz!, isMobile, isDark)
                              : _buildInteractiveQuizzesCatalog(interactiveQuizzes, isMobile, isDark)
                        else if (questions.isEmpty)
                          _buildEmptyState(isMobile, isDark)
                        else if (!_isStudentRegistered)
                          _buildStudentRegistrationCard(isMobile, isDark)
                        else if (_isFinished)
                          _buildResultState(questions.length, isMobile, isDark)
                        else
                          _buildQuizContent(questions, isMobile, isDark),
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

  Widget _buildInteractiveQuizzesCatalog(List<Map<String, dynamic>> quizzes, bool isMobile, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
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
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "اختبارات تفاعلية ذكية وشاملة 🧠",
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "اختبر نفسك برمجياً مع تصحيح فوري وتسجيل نتيجتك",
                  style: GoogleFonts.cairo(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (ctx, constraints) {
              int cols = constraints.maxWidth < 650 ? 1 : 2;
              final width = (constraints.maxWidth - (cols - 1) * 20) / cols;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: quizzes.map((q) {
                  final title = q['title'] ?? 'اختبار تفاعلي HTML';

                  return SizedBox(
                    width: width,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
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
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.psychology_rounded, color: Color(0xFF8B5CF6), size: 28),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("متاح مجاناً", style: GoogleFonts.cairo(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
                          const SizedBox(height: 6),
                          Text("اختبار برمجي تفاعلي مع أسئلة وتقييم مباشر للنتيجة.", style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedInteractiveQuiz = q;
                                  _htmlQuizSubmitted = false;
                                });
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text("بدء الاختبار الآن ➔", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildInteractiveHtmlQuizView(Map<String, dynamic> quiz, bool isMobile, bool isDark) {
    final title = quiz['title'] ?? 'اختبار تفاعلي HTML';
    final htmlCode = (quiz['htmlCode'] ?? '').toString();

    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedInteractiveQuiz = null),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text("العودة للاختبارات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("اختبار تفاعلي HTML", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6))),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Text(title, style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),

          // HTML Container rendered via ArticleContentRenderer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ArticleContentRenderer(content: htmlCode, isDark: isDark),
          ),
          const SizedBox(height: 32),

          // Result submission card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                    : [const Color(0xFFF0FDF4), Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("تسجيل نتيجتك في الاختبار وحفظها في المنصة 🎓", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("سجل بياناتك مع نتيجتك ليتم توثيقها في لوحة التحكم وقاعدة بيانات المنصة.", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_htmlQuizSubmitted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "تم تسجيل نتيجتك بنجاح في قاعدة البيانات! شكراً لمشاركتك 🌟",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _studentNameCtrl,
                          decoration: InputDecoration(
                            labelText: "اسم الطالب ثلاثي *",
                            labelStyle: GoogleFonts.cairo(fontSize: 13),
                            filled: true,
                            fillColor: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _studentPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "رقم الهاتف / واتساب *",
                            labelStyle: GoogleFonts.cairo(fontSize: 13),
                            filled: true,
                            fillColor: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _htmlStudentScoreCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "الدرجة / النتيجة المحققة (مثال: 9 من 10) *",
                            labelStyle: GoogleFonts.cairo(fontSize: 13),
                            filled: true,
                            fillColor: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final name = _studentNameCtrl.text.trim();
                          final phone = _studentPhoneCtrl.text.trim();
                          if (name.isEmpty || phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("يرجى كتابة الاسم ورقم الهاتف أولاً")),
                            );
                            return;
                          }
                          final scoreVal = int.tryParse(_htmlStudentScoreCtrl.text.trim()) ?? 10;
                          await _dataService.addQuizSubmission({
                            'quizId': quiz['id'],
                            'quizTitle': title,
                            'studentName': name,
                            'phone': phone,
                            'whatsapp': phone,
                            'country': _studentCountry,
                            'score': scoreVal,
                            'totalQuestions': 10,
                            'date': "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                          });
                          setState(() {
                            _htmlQuizSubmitted = true;
                          });
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: Text("تسجيل النتيجة 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRegistrationCard(bool isMobile, bool isDark) {
    final countries = [
      'مصر', 'السعودية', 'الإمارات', 'الكويت', 'قطر', 'الأردن',
      'العراق', 'عمان', 'البحرين', 'تونس', 'الجزائر', 'المغرب',
      'فلسطين', 'سوريا', 'لبنان', 'ليبيا', 'السودان', 'اليمن', 'أخرى'
    ];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        padding: const EdgeInsets.all(32),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_pin_rounded, size: 40, color: Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "تسجيل بيانات الطالب قبل بدء الاختبار 📝",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "يرجى تسجيل بياناتك لحفظ نتيجتك وشهادتك في لوحة المتصدرين",
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildField("الاسم بالكامل *", _studentNameCtrl, isDark),
            _buildField("رقم الهاتف *", _studentPhoneCtrl, isDark),
            _buildField("رقم واتساب *", _studentWhatsappCtrl, isDark),
            const SizedBox(height: 8),
            Text("الدولة *", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _studentCountry,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.cairo()))).toList(),
                  onChanged: (val) => setState(() => _studentCountry = val ?? 'مصر'),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_studentNameCtrl.text.trim().isEmpty || _studentPhoneCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("يرجى إدخال الاسم ورقم الهاتف للمتابعة")),
                    );
                    return;
                  }
                  setState(() {
                    _isStudentRegistered = true;
                    _startTime = DateTime.now();
                  });
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text("بدء الاختبار الآن 🚀", style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            style: GoogleFonts.cairo(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile, bool isDark) {
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
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz_outlined, size: 48, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 20),
            Text(
              "لا توجد أسئلة مضافة حالياً في بنك الأسئلة",
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "تم تفريغ الأسئلة الوهمية — يمكنك إضافة أسئلة كويز تفاعلية حقيقية مع خياراتها وتفسيرها العلمي من لوحة التحكم.",
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
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                if (AuthService.instance.isAdmin)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/admin'),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text("إضافة أسئلة من لوحة التحكم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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

  Widget _buildResultState(int total, bool isMobile, bool isDark) {
    final percentage = (total > 0 ? (_score / total) * 100 : 0).round();
    final bool isExcellent = percentage >= 80;
    final bool isGood = percentage >= 50;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        padding: EdgeInsets.all(isMobile ? 26 : 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: (isExcellent ? const Color(0xFF10B981) : (isGood ? const Color(0xFFFFB300) : const Color(0xFFEF4444)))
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExcellent ? Icons.emoji_events_rounded : (isGood ? Icons.thumb_up_rounded : Icons.replay_rounded),
                size: 56,
                color: isExcellent ? const Color(0xFF10B981) : (isGood ? const Color(0xFFFFB300) : const Color(0xFFEF4444)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isExcellent ? "أداء استثنائي ومبهر! 🎉" : (isGood ? "أحسنت، نتيجة جيدة جداً! 👍" : "فرصة رائعة للمراجعة والمحاولة مجدداً! 💪"),
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "لقد أجبت على $_score إجابة صحيحة من إجمالي $total أسئلة (نسبة النجاح: $percentage%)",
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text("إعادة الاختبار", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: Text("العودة للرئيسية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                    side: BorderSide(color: isDark ? AppColors.borderLightDark : AppColors.borderLightStrong),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(List<Map<String, dynamic>> questions, bool isMobile, bool isDark) {
    final currentQ = questions[_currentIndex];
    final questionText = currentQ['question'] ?? '';
    final options = List<String>.from(currentQ['options'] ?? []);
    final correctIndex = currentQ['correctIndex'] ?? 0;
    final explanation = currentQ['explanation'] ?? '';

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 850),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar & Counter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    "السؤال ${_currentIndex + 1} من ${questions.length}",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
                Text(
                  "النقاط الحالية: $_score",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Linear Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / questions.length,
                minHeight: 8,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 28),

            // Question Box
            Container(
              padding: EdgeInsets.all(isMobile ? 22 : 32),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionText,
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4 Options
                  ...List.generate(options.length, (idx) {
                    final isSelected = _selectedOption == idx;
                    final isCorrect = idx == correctIndex;

                    Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
                    Color borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
                    Color textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

                    if (_answered) {
                      if (isCorrect) {
                        bgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
                        borderColor = const Color(0xFF10B981);
                        textColor = const Color(0xFF10B981);
                      } else if (isSelected) {
                        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
                        borderColor = const Color(0xFFEF4444);
                        textColor = const Color(0xFFEF4444);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _handleOptionSelect(idx, correctIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: (isSelected || (_answered && isCorrect)) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: borderColor.withValues(alpha: 0.15),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + idx), // A, B, C, D
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: borderColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  options[idx],
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (_answered && isCorrect)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22)
                              else if (_answered && isSelected && !isCorrect)
                                const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation Box (shows after answering)
                  if (_answered && explanation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D33) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded, color: Color(0xFF10B981), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "التفسير العلمي للإجابة:",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  explanation,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF166534),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Next Question CTA
                  if (_answered) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleNext(questions.length),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text(
                          _currentIndex + 1 < questions.length ? "السؤال التالي" : "عرض النتيجة النهائية 🏆",
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                            "اختبر نفسك 🧠",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
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
                  _footerLink("تحدي الأسبوع 🏆", () => Navigator.of(context).pushNamed('/challenge'), isDark),
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
