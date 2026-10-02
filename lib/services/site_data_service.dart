import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SiteDataService extends ChangeNotifier {
  static final SiteDataService instance = SiteDataService._internal();
  SiteDataService._internal();

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _latestUpdates = [];
  Map<String, dynamic>? _weeklyChallenge;
  List<Map<String, dynamic>> _quizQuestions = [];
  List<Map<String, dynamic>> _recordingLessons = [];

  // New modules for comprehensive Admin & Student systems
  List<Map<String, dynamic>> _interactiveQuizzes = [];
  List<Map<String, dynamic>> _quizSubmissions = [];
  List<Map<String, dynamic>> _weeklyChallenges = [];
  List<Map<String, dynamic>> _challengeSubmissions = [];
  List<Map<String, dynamic>> _members = [];

  bool _isInitialized = false;

  List<Map<String, dynamic>> get courses => _courses;
  List<Map<String, dynamic>> get lessons => _lessons;
  List<Map<String, dynamic>> get latestUpdates => _latestUpdates;
  Map<String, dynamic>? get weeklyChallenge => _weeklyChallenge;
  List<Map<String, dynamic>> get quizQuestions => _quizQuestions;
  List<Map<String, dynamic>> get recordingLessons => _recordingLessons;
  List<Map<String, dynamic>> get interactiveQuizzes => _interactiveQuizzes;
  List<Map<String, dynamic>> get quizSubmissions => _quizSubmissions;
  List<Map<String, dynamic>> get weeklyChallenges => _weeklyChallenges;
  List<Map<String, dynamic>> get challengeSubmissions => _challengeSubmissions;
  List<Map<String, dynamic>> get members => _members;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      final coursesStr = prefs.getString('site_courses');
      if (coursesStr != null) {
        _courses = List<Map<String, dynamic>>.from(jsonDecode(coursesStr));
      } else {
        _courses = [];
      }

      final lessonsStr = prefs.getString('site_lessons');
      if (lessonsStr != null) {
        _lessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsStr));
      } else {
        _lessons = [];
      }

      final updatesStr = prefs.getString('site_latest_updates');
      if (updatesStr != null) {
        _latestUpdates = List<Map<String, dynamic>>.from(jsonDecode(updatesStr));
      } else {
        _latestUpdates = [];
      }

      final challengeStr = prefs.getString('site_weekly_challenge');
      if (challengeStr != null) {
        _weeklyChallenge = Map<String, dynamic>.from(jsonDecode(challengeStr));
      } else {
        _weeklyChallenge = null;
      }

      final quizStr = prefs.getString('site_quiz_questions');
      if (quizStr != null) {
        _quizQuestions = List<Map<String, dynamic>>.from(jsonDecode(quizStr));
      } else {
        _quizQuestions = [];
      }

      final recordingStr = prefs.getString('site_recording_lessons');
      if (recordingStr != null) {
        _recordingLessons = List<Map<String, dynamic>>.from(jsonDecode(recordingStr));
      } else {
        _recordingLessons = [
          {
            'id': 'rec_default_1',
            'title': 'المحاضرة الأولى: البيانات والمعلومات والمعرفة',
            'subject': 'الصف الأول الثانوي — مادة البرمجة والذكاء الاصطناعي',
            'date': '2026',
            'status': 'منشور',
            'url': 'presentation/index.html',
            'code': '''<!-- قالب الشريحة التقنية -->
<section class="slide">
  <header class="slide-header">
    <div class="brand">⚡ KMT AI — Eslam Atef</div>
    <div class="slide-meta">الدرس 01: مقدمة البرمجة</div>
  </header>
  <div class="slide-title-area">
    <div class="slide-tag">المفاهيم الأساسية</div>
    <h2 class="slide-main-title">البيانات والمعلومات والمعرفة</h2>
    <p class="slide-subtitle">تحويل الحقائق الأولية إلى قرارات ذكية برمجياً</p>
  </div>
  <div class="slide-body">
    <div class="card-grid grid-cols-3">
      <div class="tech-card">
        <div class="card-icon">📦</div>
        <div class="card-title">البيانات (Data)</div>
        <div class="card-desc">حقائق خام مجردة بدون سياق واضح.</div>
      </div>
      <div class="tech-card">
        <div class="card-icon">⚡</div>
        <div class="card-title">المعلومات (Information)</div>
        <div class="card-desc">بيانات تمت معالجتها وتنظيمها لتعطي معنى.</div>
      </div>
      <div class="tech-card">
        <div class="card-icon">🧠</div>
        <div class="card-title">المعرفة (Knowledge)</div>
        <div class="card-desc">تطبيق الفهم والمعلومات لحل المشكلات المعقدة.</div>
      </div>
    </div>
  </div>
</section>''',
          }
        ];
      }

      // 1. Interactive Quizzes
      final iQuizStr = prefs.getString('site_interactive_quizzes');
      if (iQuizStr != null) {
        _interactiveQuizzes = List<Map<String, dynamic>>.from(jsonDecode(iQuizStr));
      } else {
        _interactiveQuizzes = [
          {
            'id': 'quiz_ai_bac',
            'title': 'اختبار البكالوريا والبرمجة والذكاء الاصطناعي',
            'description': 'اختبار قياس فهم مفاهيم البرمجة الكينونية OOP وخوارزميات الذكاء الاصطناعي وتعلم الآلة.',
            'category': 'ثانوي وعام',
            'questionsCount': 10,
            'status': 'منشور',
            'date': '2026-10-01',
            'editorType': 'html',
            'htmlCode': '''<div class="quiz-container">
  <h3>اختبار مفاهيم البرمجة والذكاء الاصطناعي</h3>
  <p>أجب عن الأسئلة بدقة لتحديد مستواك البرمجي.</p>
</div>''',
          },
          {
            'id': 'quiz_kids',
            'title': 'اختبار البرمجة والذكاء الاصطناعي للأطفال',
            'description': 'اختبار ممتع وتفاعلي لتقييم أساسيات التفكير المنطقي والبرمجة الصورية للأطفال والناشئين.',
            'category': 'الأطفال والناشئين',
            'questionsCount': 8,
            'status': 'منشور',
            'date': '2026-10-01',
            'editorType': 'html',
            'htmlCode': '''<div class="quiz-container">
  <h3>رحلة الأبطال الصغار في عالم الكود</h3>
  <p>اختبار ممتع لاكتشاف المبرمج الصغير بداخلك!</p>
</div>''',
          },
        ];
      }

      // 2. Quiz Submissions (Student Results)
      final qSubStr = prefs.getString('site_quiz_submissions');
      if (qSubStr != null) {
        _quizSubmissions = List<Map<String, dynamic>>.from(jsonDecode(qSubStr));
      } else {
        _quizSubmissions = [
          {
            'id': 'sub_1',
            'quizId': 'quiz_ai_bac',
            'quizTitle': 'اختبار البكالوريا والبرمجة والذكاء الاصطناعي',
            'studentName': 'أحمد محمد السيد',
            'phone': '01012345678',
            'whatsapp': '01012345678',
            'country': 'مصر',
            'score': 9,
            'totalQuestions': 10,
            'startTime': '2026-10-02 10:15',
            'endTime': '2026-10-02 10:28',
            'date': '2026-10-02',
          },
          {
            'id': 'sub_2',
            'quizId': 'quiz_kids',
            'quizTitle': 'اختبار البرمجة والذكاء الاصطناعي للأطفال',
            'studentName': 'سارة عمر خالد',
            'phone': '0559876543',
            'whatsapp': '0559876543',
            'country': 'السعودية',
            'score': 8,
            'totalQuestions': 8,
            'startTime': '2026-10-01 16:30',
            'endTime': '2026-10-01 16:42',
            'date': '2026-10-01',
          },
        ];
      }

      // 3. Weekly Challenges (50 Challenges Scheduler)
      final wChallStr = prefs.getString('site_weekly_challenges');
      if (wChallStr != null) {
        _weeklyChallenges = List<Map<String, dynamic>>.from(jsonDecode(wChallStr));
      } else {
        _weeklyChallenges = [
          {
            'id': 'chall_w01',
            'weekNumber': 1,
            'title': 'تحدي الأسبوع 01: خوارزمية البحث الثنائي Binary Search',
            'imageUrl': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600',
            'difficulty': 'متوسط',
            'startDate': '2026-10-03',
            'endDate': '2026-10-08',
            'status': 'نشط',
            'editorType': 'visual',
            'problemDesc': 'قم ببناء دالة تأخذ مصفوفة أرقام مرتبة وقيمة بحث، وترجع مؤشر العنصر بتعقيد زمني O(log n).',
            'requirements': '- لا تستخدم دوال البحث الجاهزة.\n- تعامل مع حالة عدم وجود العنصر بإرجاع -1.\n- كتابة حالات اختبار دقيقة.',
            'htmlCode': '',
          },
          {
            'id': 'chall_w02',
            'weekNumber': 2,
            'title': 'تحدي الأسبوع 02: معالجة النصوص وبناء محلل المشاعر NLP',
            'imageUrl': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600',
            'difficulty': 'متقدم',
            'startDate': '2026-10-10',
            'endDate': '2026-10-15',
            'status': 'مجدول',
            'editorType': 'visual',
            'problemDesc': 'بناء نموذج خفيف يقوم بتصنيف المراجعات إلى إيجابية أو سلبية بناءً على الكلمات المفتاحية.',
            'requirements': '- استخراج الكلمات المفتاحية.\n- تنظيف النص من علامات الترقيم.\n- حساب نسبة الثقة.',
            'htmlCode': '',
          },
        ];
      }

      // 4. Challenge Submissions (Student Solutions)
      final cSubStr = prefs.getString('site_challenge_submissions');
      if (cSubStr != null) {
        _challengeSubmissions = List<Map<String, dynamic>>.from(jsonDecode(cSubStr));
      } else {
        _challengeSubmissions = [
          {
            'id': 'sol_1',
            'challengeId': 'chall_w01',
            'challengeTitle': 'تحدي الأسبوع 01: خوارزمية البحث الثنائي Binary Search',
            'studentName': 'محمود حسن',
            'email': 'mahmoud@gmail.com',
            'whatsapp': '01123456789',
            'projectUrl': 'https://github.com/mahmoud/binary-search-challenge',
            'notes': 'تم تطبيق الحل بلغة Python مع اختبارات الـ Unit Tests الكاملة.',
            'date': '2026-10-02',
            'status': 'جديد',
          },
        ];
      }

      // 5. Members System
      final membersStr = prefs.getString('site_members');
      if (membersStr != null) {
        _members = List<Map<String, dynamic>>.from(jsonDecode(membersStr));
      } else {
        _members = [
          {
            'id': 'mem_1',
            'name': 'أحمد محمد السيد',
            'email': 'ahmed.m@example.com',
            'phone': '01012345678',
            'country': 'مصر',
            'registeredDate': '2026-09-20',
            'status': 'نشط',
            'quizzesCount': 2,
            'challengesCount': 1,
            'lastActive': 'منذ 3 ساعات',
            'role': 'student',
          },
          {
            'id': 'mem_2',
            'name': 'سارة عمر خالد',
            'email': 'sara.khalid@example.com',
            'phone': '0559876543',
            'country': 'السعودية',
            'registeredDate': '2026-09-24',
            'status': 'نشط',
            'quizzesCount': 1,
            'challengesCount': 0,
            'lastActive': 'أمس',
            'role': 'student',
          },
          {
            'id': 'mem_3',
            'name': 'محمود حسن علي',
            'email': 'mahmoud.ali@example.com',
            'phone': '01123456789',
            'country': 'مصر',
            'registeredDate': '2026-09-28',
            'status': 'نشط',
            'quizzesCount': 3,
            'challengesCount': 1,
            'lastActive': 'اليوم',
            'role': 'student',
          },
        ];
      }
    } catch (e) {
      debugPrint("Error initializing SiteDataService: $e");
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // --- Courses CRUD (Course Folder) ---
  Future<void> addCourse(Map<String, dynamic> course) async {
    course['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    if (course['lessons'] == null) {
      course['lessons'] = <Map<String, dynamic>>[];
    }
    _courses.add(course);
    await _saveCourses();
    notifyListeners();
  }

  Future<void> updateCourse(String id, Map<String, dynamic> updated) async {
    final idx = _courses.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      if (updated['lessons'] == null && _courses[idx]['lessons'] != null) {
        updated['lessons'] = _courses[idx]['lessons'];
      }
      _courses[idx] = updated;
      await _saveCourses();
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((c) => c['id'] == id);
    await _saveCourses();
    notifyListeners();
  }

  // Nested Lessons inside Course Folder
  Future<void> addLessonToCourse(String courseId, Map<String, dynamic> lesson) async {
    final idx = _courses.indexWhere((c) => c['id'] == courseId);
    if (idx != -1) {
      lesson['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      final lessonsList = List<Map<String, dynamic>>.from(_courses[idx]['lessons'] ?? []);
      lessonsList.add(lesson);
      _courses[idx]['lessons'] = lessonsList;
      await _saveCourses();
      notifyListeners();
    }
  }

  Future<void> updateLessonInCourse(String courseId, String lessonId, Map<String, dynamic> updated) async {
    final cIdx = _courses.indexWhere((c) => c['id'] == courseId);
    if (cIdx != -1) {
      final lessonsList = List<Map<String, dynamic>>.from(_courses[cIdx]['lessons'] ?? []);
      final lIdx = lessonsList.indexWhere((l) => l['id'] == lessonId);
      if (lIdx != -1) {
        lessonsList[lIdx] = updated;
        _courses[cIdx]['lessons'] = lessonsList;
        await _saveCourses();
        notifyListeners();
      }
    }
  }

  Future<void> deleteLessonFromCourse(String courseId, String lessonId) async {
    final cIdx = _courses.indexWhere((c) => c['id'] == courseId);
    if (cIdx != -1) {
      final lessonsList = List<Map<String, dynamic>>.from(_courses[cIdx]['lessons'] ?? []);
      lessonsList.removeWhere((l) => l['id'] == lessonId);
      _courses[cIdx]['lessons'] = lessonsList;
      await _saveCourses();
      notifyListeners();
    }
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_courses', jsonEncode(_courses));
  }

  // --- Independent Lessons CRUD ---
  Future<void> addLesson(Map<String, dynamic> lesson) async {
    lesson['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _lessons.add(lesson);
    await _saveLessons();
    notifyListeners();
  }

  Future<void> updateLesson(String id, Map<String, dynamic> updated) async {
    final idx = _lessons.indexWhere((l) => l['id'] == id);
    if (idx != -1) {
      _lessons[idx] = updated;
      await _saveLessons();
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String id) async {
    _lessons.removeWhere((l) => l['id'] == id);
    await _saveLessons();
    notifyListeners();
  }

  Future<void> _saveLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_lessons', jsonEncode(_lessons));
  }

  // --- Latest Updates CRUD ---
  Future<void> addLatestUpdate(Map<String, dynamic> update) async {
    update['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _latestUpdates.add(update);
    await _saveLatestUpdates();
    notifyListeners();
  }

  Future<void> updateLatestUpdate(String id, Map<String, dynamic> updated) async {
    final idx = _latestUpdates.indexWhere((u) => u['id'] == id);
    if (idx != -1) {
      _latestUpdates[idx] = updated;
      await _saveLatestUpdates();
      notifyListeners();
    }
  }

  Future<void> deleteLatestUpdate(String id) async {
    _latestUpdates.removeWhere((u) => u['id'] == id);
    await _saveLatestUpdates();
    notifyListeners();
  }

  Future<void> _saveLatestUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_latest_updates', jsonEncode(_latestUpdates));
  }

  // --- Interactive Quizzes CRUD ---
  Future<void> addInteractiveQuiz(Map<String, dynamic> quiz) async {
    quiz['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _interactiveQuizzes.add(quiz);
    await _saveInteractiveQuizzes();
    notifyListeners();
  }

  Future<void> updateInteractiveQuiz(String id, Map<String, dynamic> updated) async {
    final idx = _interactiveQuizzes.indexWhere((q) => q['id'] == id);
    if (idx != -1) {
      _interactiveQuizzes[idx] = updated;
      await _saveInteractiveQuizzes();
      notifyListeners();
    }
  }

  Future<void> deleteInteractiveQuiz(String id) async {
    _interactiveQuizzes.removeWhere((q) => q['id'] == id);
    await _saveInteractiveQuizzes();
    notifyListeners();
  }

  Future<void> _saveInteractiveQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_interactive_quizzes', jsonEncode(_interactiveQuizzes));
  }

  // --- Quiz Submissions (Student Results) ---
  Future<void> addQuizSubmission(Map<String, dynamic> submission) async {
    submission['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _quizSubmissions.insert(0, submission);
    await _saveQuizSubmissions();

    final phone = submission['phone']?.toString();
    final name = submission['studentName']?.toString();
    if (phone != null && phone.isNotEmpty) {
      final mIdx = _members.indexWhere((m) => m['phone'] == phone);
      if (mIdx != -1) {
        _members[mIdx]['quizzesCount'] = (_members[mIdx]['quizzesCount'] ?? 0) + 1;
        _members[mIdx]['lastActive'] = 'الآن';
        await _saveMembers();
      } else if (name != null && name.isNotEmpty) {
        _members.add({
          'id': 'mem_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': '$phone@student.kmt',
          'phone': phone,
          'country': submission['country'] ?? 'مصر',
          'registeredDate': submission['date'] ?? '2026-10-02',
          'status': 'نشط',
          'quizzesCount': 1,
          'challengesCount': 0,
          'lastActive': 'الآن',
          'role': 'student',
        });
        await _saveMembers();
      }
    }
    notifyListeners();
  }

  Future<void> deleteQuizSubmission(String id) async {
    _quizSubmissions.removeWhere((s) => s['id'] == id);
    await _saveQuizSubmissions();
    notifyListeners();
  }

  Future<void> _saveQuizSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_quiz_submissions', jsonEncode(_quizSubmissions));
  }

  // --- Weekly Challenges Scheduler & List CRUD ---
  Future<void> addWeeklyChallenge(Map<String, dynamic> challenge) async {
    challenge['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _weeklyChallenges.add(challenge);
    await _saveWeeklyChallenges();
    notifyListeners();
  }

  Future<void> updateWeeklyChallenge(String id, Map<String, dynamic> updated) async {
    final idx = _weeklyChallenges.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      _weeklyChallenges[idx] = updated;
      await _saveWeeklyChallenges();
      notifyListeners();
    }
  }

  Future<void> deleteWeeklyChallenge(String id) async {
    _weeklyChallenges.removeWhere((c) => c['id'] == id);
    await _saveWeeklyChallenges();
    notifyListeners();
  }

  Future<void> _saveWeeklyChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_weekly_challenges', jsonEncode(_weeklyChallenges));
  }

  Map<String, dynamic>? getActiveChallenge() {
    final explicitActive = _weeklyChallenges.where((c) => c['status'] == 'نشط').toList();
    if (explicitActive.isNotEmpty) return explicitActive.first;
    if (_weeklyChallenge != null) return _weeklyChallenge;
    if (_weeklyChallenges.isNotEmpty) return _weeklyChallenges.first;
    return null;
  }

  // --- Challenge Submissions (Student Solutions) ---
  Future<void> addChallengeSubmission(Map<String, dynamic> submission) async {
    submission['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    submission['status'] = submission['status'] ?? 'جديد';
    _challengeSubmissions.insert(0, submission);
    await _saveChallengeSubmissions();

    final email = submission['email']?.toString();
    if (email != null && email.isNotEmpty) {
      final mIdx = _members.indexWhere((m) => m['email'] == email);
      if (mIdx != -1) {
        _members[mIdx]['challengesCount'] = (_members[mIdx]['challengesCount'] ?? 0) + 1;
        _members[mIdx]['lastActive'] = 'الآن';
        await _saveMembers();
      }
    }
    notifyListeners();
  }

  Future<void> updateChallengeSubmissionStatus(String id, String status) async {
    final idx = _challengeSubmissions.indexWhere((s) => s['id'] == id);
    if (idx != -1) {
      _challengeSubmissions[idx]['status'] = status;
      await _saveChallengeSubmissions();
      notifyListeners();
    }
  }

  Future<void> deleteChallengeSubmission(String id) async {
    _challengeSubmissions.removeWhere((s) => s['id'] == id);
    await _saveChallengeSubmissions();
    notifyListeners();
  }

  Future<void> _saveChallengeSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_challenge_submissions', jsonEncode(_challengeSubmissions));
  }

  // --- Members CRUD ---
  Future<void> addMember(Map<String, dynamic> member) async {
    member['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _members.add(member);
    await _saveMembers();
    notifyListeners();
  }

  Future<void> updateMember(String id, Map<String, dynamic> updated) async {
    final idx = _members.indexWhere((m) => m['id'] == id);
    if (idx != -1) {
      _members[idx] = updated;
      await _saveMembers();
      notifyListeners();
    }
  }

  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m['id'] == id);
    await _saveMembers();
    notifyListeners();
  }

  Future<void> _saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_members', jsonEncode(_members));
  }

  Future<void> setWeeklyChallenge(Map<String, dynamic>? challenge) async {
    _weeklyChallenge = challenge;
    final prefs = await SharedPreferences.getInstance();
    if (challenge == null) {
      await prefs.remove('site_weekly_challenge');
    } else {
      await prefs.setString('site_weekly_challenge', jsonEncode(challenge));
    }
    notifyListeners();
  }

  // --- Quiz Questions CRUD ---
  Future<void> addQuizQuestion(Map<String, dynamic> question) async {
    question['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _quizQuestions.add(question);
    await _saveQuizQuestions();
    notifyListeners();
  }

  Future<void> updateQuizQuestion(String id, Map<String, dynamic> updated) async {
    final idx = _quizQuestions.indexWhere((q) => q['id'] == id);
    if (idx != -1) {
      _quizQuestions[idx] = updated;
      await _saveQuizQuestions();
      notifyListeners();
    }
  }

  Future<void> deleteQuizQuestion(String id) async {
    _quizQuestions.removeWhere((q) => q['id'] == id);
    await _saveQuizQuestions();
    notifyListeners();
  }

  Future<void> _saveQuizQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_quiz_questions', jsonEncode(_quizQuestions));
  }

  // --- Recording Lessons CRUD (استوديو التصوير) ---
  Future<void> addRecordingLesson(Map<String, dynamic> lesson) async {
    lesson['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _recordingLessons.add(lesson);
    await _saveRecordingLessons();
    notifyListeners();
  }

  Future<void> updateRecordingLesson(String id, Map<String, dynamic> updated) async {
    final idx = _recordingLessons.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      _recordingLessons[idx] = updated;
      await _saveRecordingLessons();
      notifyListeners();
    }
  }

  Future<void> deleteRecordingLesson(String id) async {
    _recordingLessons.removeWhere((r) => r['id'] == id);
    await _saveRecordingLessons();
    notifyListeners();
  }

  Future<void> _saveRecordingLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_recording_lessons', jsonEncode(_recordingLessons));
  }
}
