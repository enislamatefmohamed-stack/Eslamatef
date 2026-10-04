import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/fifty_challenges_data.dart';

class SiteDataService extends ChangeNotifier {
  static final SiteDataService instance = SiteDataService._internal();
  SiteDataService._internal();

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _lessonPlaylists = [];
  List<Map<String, dynamic>> _latestUpdates = [];
  Map<String, dynamic>? _weeklyChallenge;
  final List<Map<String, dynamic>> _quizQuestions = [];
  final List<Map<String, dynamic>> _recordingLessons = [];

  // Independent Categories: Course Categories vs Lesson Categories
  List<String> _courseCategories = [];
  List<String> _lessonCategories = [];

  // Modules for comprehensive Admin & Student systems
  List<Map<String, dynamic>> _interactiveQuizzes = [];
  List<Map<String, dynamic>> _quizSubmissions = [];
  List<Map<String, dynamic>> _weeklyChallenges = [];
  List<Map<String, dynamic>> _challengeSubmissions = [];
  List<Map<String, dynamic>> _members = [];

  bool _isInitialized = false;

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Map<String, dynamic>> get courses => _courses;
  List<Map<String, dynamic>> get lessons => _lessons;
  List<Map<String, dynamic>> get lessonPlaylists => _lessonPlaylists;
  List<Map<String, dynamic>> get latestUpdates => _latestUpdates;
  Map<String, dynamic>? get weeklyChallenge => _weeklyChallenge;
  List<Map<String, dynamic>> get quizQuestions => _quizQuestions;
  List<Map<String, dynamic>> get recordingLessons => _recordingLessons;
  List<String> get courseCategories => _courseCategories;
  List<String> get lessonCategories => _lessonCategories;
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

      // 1. Load Local Cache First (Instant startup with zero latency)
      final coursesStr = prefs.getString('site_courses');
      if (coursesStr != null) {
        _courses = List<Map<String, dynamic>>.from(jsonDecode(coursesStr));
      }
      for (final c in _courses) {
        final clist = (c['lessons'] as List?) ?? [];
        for (final l in clist) {
          if (l is Map<String, dynamic>) _normalizeLesson(l);
        }
      }

      final lessonsStr = prefs.getString('site_lessons');
      if (lessonsStr != null) {
        _lessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsStr));
      }
      for (final l in _lessons) {
        _normalizeLesson(l);
      }

      final plStr = prefs.getString('site_lesson_playlists');
      if (plStr != null) {
        _lessonPlaylists = List<Map<String, dynamic>>.from(jsonDecode(plStr));
      } else {
        _lessonPlaylists = [];
      }

      final cCatStr = prefs.getString('site_course_categories');
      if (cCatStr != null) {
        _courseCategories = List<String>.from(jsonDecode(cCatStr));
      } else {
        _courseCategories = ['برمجة الويب Full Stack', 'تطبيقات الهاتف Flutter', 'الذكاء الاصطناعي وتعلم الآلة', 'أساسيات علوم الحاسب CS'];
      }

      final lCatStr = prefs.getString('site_lesson_categories');
      if (lCatStr != null) {
        _lessonCategories = List<String>.from(jsonDecode(lCatStr));
      } else {
        _lessonCategories = ['شروحات منهجية', 'تطبيقات عملية ومشاريع', 'خوارزميات وحل مشكلات', 'نصائح ومفاهيم برمجية'];
      }

      final updatesStr = prefs.getString('site_latest_updates');
      if (updatesStr != null) {
        _latestUpdates = List<Map<String, dynamic>>.from(jsonDecode(updatesStr));
      }

      final iQuizzesStr = prefs.getString('site_interactive_quizzes');
      if (iQuizzesStr != null) {
        _interactiveQuizzes = List<Map<String, dynamic>>.from(jsonDecode(iQuizzesStr));
      }

      final qSubStr = prefs.getString('site_quiz_submissions');
      if (qSubStr != null) {
        _quizSubmissions = List<Map<String, dynamic>>.from(jsonDecode(qSubStr));
      }

      final wChallStr = prefs.getString('site_weekly_challenges');
      if (wChallStr != null) {
        _weeklyChallenges = List<Map<String, dynamic>>.from(jsonDecode(wChallStr));
      }
      if (_weeklyChallenges.length < 50) {
        _weeklyChallenges = FiftyChallengesData.getAllChallenges();
      }

      final cSubStr = prefs.getString('site_challenge_submissions');
      if (cSubStr != null) {
        _challengeSubmissions = List<Map<String, dynamic>>.from(jsonDecode(cSubStr));
      }

      final membersStr = prefs.getString('site_members');
      if (membersStr != null) {
        _members = List<Map<String, dynamic>>.from(jsonDecode(membersStr));
      }

      _isInitialized = true;
      notifyListeners();

      // 2. Connect directly to Firebase Cloud Firestore for Live Sync
      _bindFirestoreListeners();
    } catch (e) {
      debugPrint("SiteDataService init warning: $e");
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _bindFirestoreListeners() {
    if (!isFirebaseReady) return;
    try {
      // Courses Collection
      _firestore.collection('courses').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _courses = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            final clist = (data['lessons'] as List?) ?? [];
            for (final l in clist) {
              if (l is Map<String, dynamic>) _normalizeLesson(l);
            }
            return data;
          }).toList();
          _saveCourses();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore courses listener error: $e"));

      // Lessons Collection
      _firestore.collection('lessons').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _lessons = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            _normalizeLesson(data);
            return data;
          }).toList();
          _saveLessons();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore lessons listener error: $e"));

      // Course Categories Collection
      _firestore.collection('course_categories').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _courseCategories = snapshot.docs.map((doc) => (doc.data()['name'] ?? doc.id).toString()).toList();
          _saveCourseCategories();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore course_categories error: $e"));

      // Lesson Categories Collection
      _firestore.collection('lesson_categories').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _lessonCategories = snapshot.docs.map((doc) => (doc.data()['name'] ?? doc.id).toString()).toList();
          _saveLessonCategories();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore lesson_categories error: $e"));

      // Lesson Playlists Collection (Curricula / مناهج)
      _firestore.collection('lesson_playlists').snapshots().listen((snapshot) {
        _lessonPlaylists = snapshot.docs.map((doc) {
          final d = doc.data();
          d['id'] = doc.id;
          return d;
        }).toList();
        _saveLessonPlaylists();
        notifyListeners();
      }, onError: (e) => debugPrint("Firestore lesson_playlists error: $e"));

      // Interactive Quizzes Collection
      _firestore.collection('interactive_quizzes').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _interactiveQuizzes = snapshot.docs.map((doc) {
            final d = doc.data();
            d['id'] = doc.id;
            return d;
          }).toList();
          _saveInteractiveQuizzes();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore quizzes error: $e"));

      // Quiz Submissions Collection
      _firestore.collection('quiz_submissions').orderBy('date', descending: true).snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _quizSubmissions = snapshot.docs.map((doc) {
            final d = doc.data();
            d['id'] = doc.id;
            return d;
          }).toList();
          _saveQuizSubmissions();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore quiz_submissions error: $e"));

      // Users / Members Collection
      _firestore.collection('users').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _members = snapshot.docs.map((doc) {
            final d = doc.data();
            d['id'] = doc.id;
            d['uid'] = doc.id;
            return d;
          }).toList();
          _saveMembers();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore users error: $e"));

      // Latest Updates Collection
      _firestore.collection('latest_updates').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _latestUpdates = snapshot.docs.map((doc) {
            final d = doc.data();
            d['id'] = doc.id;
            return d;
          }).toList();
          _saveLatestUpdates();
          notifyListeners();
        }
      }, onError: (e) => debugPrint("Firestore updates error: $e"));

    } catch (e) {
      debugPrint("Error binding Firestore listeners: $e");
    }
  }

  void _normalizeLesson(Map<String, dynamic> lesson) {
    if (lesson['imageUrl'] != null && (lesson['image'] == null || lesson['image'].toString().isEmpty)) {
      lesson['image'] = lesson['imageUrl'];
    }
    if (lesson['image'] != null && (lesson['imageUrl'] == null || lesson['imageUrl'].toString().isEmpty)) {
      lesson['imageUrl'] = lesson['image'];
    }
    if (lesson['videoUrl'] != null && (lesson['youtubeUrl'] == null || lesson['youtubeUrl'].toString().isEmpty)) {
      lesson['youtubeUrl'] = lesson['videoUrl'];
    }
    if (lesson['youtubeUrl'] != null && (lesson['videoUrl'] == null || lesson['videoUrl'].toString().isEmpty)) {
      lesson['videoUrl'] = lesson['youtubeUrl'];
    }
    if (lesson['category'] != null && (lesson['subject'] == null || lesson['subject'].toString().isEmpty)) {
      lesson['subject'] = lesson['category'];
    }
    if (lesson['subject'] != null && (lesson['category'] == null || lesson['category'].toString().isEmpty)) {
      lesson['category'] = lesson['subject'];
    }

    // Bidirectional HTML content normalization
    final htmlCode = (lesson['htmlCode'] ?? '').toString().trim();
    final content = (lesson['content'] ?? '').toString().trim();
    if (htmlCode.isNotEmpty && content.isEmpty) {
      lesson['content'] = htmlCode;
    } else if (content.isNotEmpty && htmlCode.isEmpty) {
      lesson['htmlCode'] = content;
    }

    // Detect if content is HTML
    final activeText = htmlCode.isNotEmpty ? htmlCode : content;
    if (activeText.contains('<style') ||
        activeText.contains('<div') ||
        activeText.contains('<iframe') ||
        activeText.contains('<p') ||
        activeText.startsWith('<')) {
      lesson['editorType'] = 'html';
    }
  }

  // =========================================================================
  // COURSES CRUD (Synced with Firestore 'courses')
  // =========================================================================
  Future<void> createCourse(Map<String, dynamic> course) => addCourse(course);
  Future<void> addCourse(Map<String, dynamic> course) async {
    final id = course['id']?.toString() ?? 'course_${DateTime.now().millisecondsSinceEpoch}';
    course['id'] = id;
    course['isPaid'] = course['isPaid'] == true;
    _courses.add(course);
    await _saveCourses();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('courses').doc(id).set(course, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addCourse error: $e");
      }
    }
  }

  Future<void> updateCourse(String id, Map<String, dynamic> updated) async {
    final idx = _courses.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      updated['id'] = id;
      updated['isPaid'] = updated['isPaid'] == true;
      _courses[idx] = updated;
      await _saveCourses();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('courses').doc(id).set(updated, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Firestore updateCourse error: $e");
        }
      }
    }
  }

  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((c) => c['id'] == id);
    await _saveCourses();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('courses').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteCourse error: $e");
      }
    }
  }

  Future<void> addLessonToCourse(String courseId, Map<String, dynamic> lesson) async {
    final idx = _courses.indexWhere((c) => c['id'] == courseId);
    if (idx != -1) {
      lesson['id'] = 'lec_${DateTime.now().millisecondsSinceEpoch}';
      _normalizeLesson(lesson);
      final list = List<Map<String, dynamic>>.from(_courses[idx]['lessons'] ?? []);
      list.add(lesson);
      _courses[idx]['lessons'] = list;
      await _saveCourses();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('courses').doc(courseId).update({'lessons': list});
        } catch (e) {
          debugPrint("Firestore addLessonToCourse error: $e");
        }
      }
    }
  }

  Future<void> updateLessonInCourse(String courseId, String lessonId, Map<String, dynamic> updatedLesson) async {
    final idx = _courses.indexWhere((c) => c['id'] == courseId);
    if (idx != -1) {
      final list = List<Map<String, dynamic>>.from(_courses[idx]['lessons'] ?? []);
      final lIdx = list.indexWhere((l) => l['id'] == lessonId);
      if (lIdx != -1) {
        updatedLesson['id'] = lessonId;
        _normalizeLesson(updatedLesson);
        list[lIdx] = updatedLesson;
        _courses[idx]['lessons'] = list;
        await _saveCourses();
        notifyListeners();

        if (isFirebaseReady) {
          try {
            await _firestore.collection('courses').doc(courseId).update({'lessons': list});
          } catch (e) {
            debugPrint("Firestore updateLessonInCourse error: $e");
          }
        }
      }
    }
  }

  Future<void> deleteLessonFromCourse(String courseId, String lessonId) async {
    final idx = _courses.indexWhere((c) => c['id'] == courseId);
    if (idx != -1) {
      final list = List<Map<String, dynamic>>.from(_courses[idx]['lessons'] ?? []);
      list.removeWhere((l) => l['id'] == lessonId);
      _courses[idx]['lessons'] = list;
      await _saveCourses();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('courses').doc(courseId).update({'lessons': list});
        } catch (e) {
          debugPrint("Firestore deleteLessonFromCourse error: $e");
        }
      }
    }
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_courses', jsonEncode(_courses));
  }

  // =========================================================================
  // COURSE CATEGORIES CRUD (Synced with Firestore 'course_categories')
  // =========================================================================
  Future<void> addCourseCategory(String category) async {
    final cat = category.trim();
    if (cat.isNotEmpty && !_courseCategories.contains(cat)) {
      _courseCategories.add(cat);
      await _saveCourseCategories();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          final id = 'ccat_${cat.hashCode.abs()}';
          await _firestore.collection('course_categories').doc(id).set({'name': cat, 'createdAt': FieldValue.serverTimestamp()});
        } catch (e) {
          debugPrint("Firestore addCourseCategory error: $e");
        }
      }
    }
  }

  Future<void> updateCourseCategory(String oldCat, String newCat) async {
    final idx = _courseCategories.indexOf(oldCat);
    if (idx != -1 && newCat.trim().isNotEmpty) {
      _courseCategories[idx] = newCat.trim();
      for (final c in _courses) {
        if (c['category'] == oldCat) {
          c['category'] = newCat.trim();
        }
      }
      await _saveCourses();
      await _saveCourseCategories();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          final oldId = 'ccat_${oldCat.hashCode.abs()}';
          final newId = 'ccat_${newCat.trim().hashCode.abs()}';
          await _firestore.collection('course_categories').doc(oldId).delete();
          await _firestore.collection('course_categories').doc(newId).set({'name': newCat.trim()});
        } catch (e) {
          debugPrint("Firestore updateCourseCategory error: $e");
        }
      }
    }
  }

  Future<void> deleteCourseCategory(String category) async {
    _courseCategories.remove(category);
    await _saveCourseCategories();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        final id = 'ccat_${category.hashCode.abs()}';
        await _firestore.collection('course_categories').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteCourseCategory error: $e");
      }
    }
  }

  Future<void> _saveCourseCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_course_categories', jsonEncode(_courseCategories));
  }

  // =========================================================================
  // LESSON CATEGORIES CRUD (Synced with Firestore 'lesson_categories')
  // =========================================================================
  Future<void> addLessonCategory(String category) async {
    final cat = category.trim();
    if (cat.isNotEmpty && !_lessonCategories.contains(cat)) {
      _lessonCategories.add(cat);
      await _saveLessonCategories();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          final id = 'lcat_${cat.hashCode.abs()}';
          await _firestore.collection('lesson_categories').doc(id).set({'name': cat, 'createdAt': FieldValue.serverTimestamp()});
        } catch (e) {
          debugPrint("Firestore addLessonCategory error: $e");
        }
      }
    }
  }

  Future<void> updateLessonCategory(String oldCat, String newCat) async {
    final idx = _lessonCategories.indexOf(oldCat);
    if (idx != -1 && newCat.trim().isNotEmpty) {
      _lessonCategories[idx] = newCat.trim();
      for (final l in _lessons) {
        if (l['category'] == oldCat || l['subject'] == oldCat) {
          l['category'] = newCat.trim();
          l['subject'] = newCat.trim();
        }
      }
      await _saveLessons();
      await _saveLessonCategories();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          final oldId = 'lcat_${oldCat.hashCode.abs()}';
          final newId = 'lcat_${newCat.trim().hashCode.abs()}';
          await _firestore.collection('lesson_categories').doc(oldId).delete();
          await _firestore.collection('lesson_categories').doc(newId).set({'name': newCat.trim()});
        } catch (e) {
          debugPrint("Firestore updateLessonCategory error: $e");
        }
      }
    }
  }

  Future<void> deleteLessonCategory(String category) async {
    _lessonCategories.remove(category);
    await _saveLessonCategories();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        final id = 'lcat_${category.hashCode.abs()}';
        await _firestore.collection('lesson_categories').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteLessonCategory error: $e");
      }
    }
  }

  Future<void> _saveLessonCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_lesson_categories', jsonEncode(_lessonCategories));
  }

  // =========================================================================
  // LESSONS CRUD (Synced with Firestore 'lessons')
  // =========================================================================
  Future<void> addLesson(Map<String, dynamic> lesson) async {
    final id = lesson['id']?.toString() ?? 'lesson_${DateTime.now().millisecondsSinceEpoch}';
    lesson['id'] = id;
    lesson['isPaid'] = lesson['isPaid'] == true;
    _normalizeLesson(lesson);
    _lessons.add(lesson);
    await _saveLessons();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('lessons').doc(id).set(lesson, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addLesson error: $e");
      }
    }
  }

  Future<void> updateLesson(String id, Map<String, dynamic> updated) async {
    final idx = _lessons.indexWhere((l) => l['id'] == id);
    if (idx != -1) {
      updated['id'] = id;
      updated['isPaid'] = updated['isPaid'] == true;
      _normalizeLesson(updated);
      _lessons[idx] = updated;
      await _saveLessons();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('lessons').doc(id).set(updated, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Firestore updateLesson error: $e");
        }
      }
    }
  }

  Future<void> deleteLesson(String id) async {
    _lessons.removeWhere((l) => l['id'] == id);
    await _saveLessons();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('lessons').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteLesson error: $e");
      }
    }
  }

  Future<void> _saveLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_lessons', jsonEncode(_lessons));
  }

  // =========================================================================
  // LESSON PLAYLISTS CRUD (Curricula / مناهج)
  // =========================================================================
  Future<void> createLessonPlaylist(Map<String, dynamic> playlist) => addLessonPlaylist(playlist);
  Future<void> addLessonPlaylist(Map<String, dynamic> playlist) async {
    final id = playlist['id']?.toString() ?? 'pl_${DateTime.now().millisecondsSinceEpoch}';
    playlist['id'] = id;
    _lessonPlaylists.add(playlist);
    await _saveLessonPlaylists();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('lesson_playlists').doc(id).set(playlist, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addLessonPlaylist error: $e");
      }
    }
  }

  Future<void> updateLessonPlaylist(String id, Map<String, dynamic> updated) async {
    final idx = _lessonPlaylists.indexWhere((p) => p['id'] == id);
    if (idx != -1) {
      updated['id'] = id;
      _lessonPlaylists[idx] = updated;
      await _saveLessonPlaylists();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('lesson_playlists').doc(id).set(updated, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Firestore updateLessonPlaylist error: $e");
        }
      }
    }
  }

  Future<void> deleteLessonPlaylist(String id) async {
    _lessonPlaylists.removeWhere((p) => p['id'] == id);
    await _saveLessonPlaylists();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('lesson_playlists').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteLessonPlaylist error: $e");
      }
    }
  }

  Future<void> clearAllLessonPlaylists() async {
    _lessonPlaylists.clear();
    await _saveLessonPlaylists();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        final snap = await _firestore.collection('lesson_playlists').get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Firestore clearAllLessonPlaylists error: $e");
      }
    }
  }

  Future<void> _saveLessonPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_lesson_playlists', jsonEncode(_lessonPlaylists));
  }

  // =========================================================================
  // INTERACTIVE QUIZZES CRUD (اختبر نفسك HTML)
  // =========================================================================
  Future<void> addInteractiveQuiz(Map<String, dynamic> quiz) async {
    final id = quiz['id']?.toString() ?? 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    quiz['id'] = id;
    quiz['createdAt'] = DateTime.now().toIso8601String();
    _interactiveQuizzes.add(quiz);
    await _saveInteractiveQuizzes();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('interactive_quizzes').doc(id).set(quiz, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addInteractiveQuiz error: $e");
      }
    }
  }

  Future<void> updateInteractiveQuiz(String id, Map<String, dynamic> updated) async {
    final idx = _interactiveQuizzes.indexWhere((q) => q['id'] == id);
    if (idx != -1) {
      updated['id'] = id;
      _interactiveQuizzes[idx] = updated;
      await _saveInteractiveQuizzes();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('interactive_quizzes').doc(id).set(updated, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Firestore updateInteractiveQuiz error: $e");
        }
      }
    }
  }

  Future<void> deleteInteractiveQuiz(String id) async {
    _interactiveQuizzes.removeWhere((q) => q['id'] == id);
    await _saveInteractiveQuizzes();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('interactive_quizzes').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteInteractiveQuiz error: $e");
      }
    }
  }

  Future<void> _saveInteractiveQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_interactive_quizzes', jsonEncode(_interactiveQuizzes));
  }

  // =========================================================================
  // QUIZ SUBMISSIONS (Student Results)
  // =========================================================================
  Future<void> addQuizSubmission(Map<String, dynamic> submission) async {
    final id = submission['id']?.toString() ?? 'sub_${DateTime.now().millisecondsSinceEpoch}';
    submission['id'] = id;
    submission['date'] = submission['date'] ?? "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    _quizSubmissions.insert(0, submission);
    await _saveQuizSubmissions();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('quiz_submissions').doc(id).set(submission, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addQuizSubmission error: $e");
      }
    }
  }

  Future<void> deleteQuizSubmission(String id) async {
    _quizSubmissions.removeWhere((s) => s['id'] == id);
    await _saveQuizSubmissions();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('quiz_submissions').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteQuizSubmission error: $e");
      }
    }
  }

  Future<void> _saveQuizSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_quiz_submissions', jsonEncode(_quizSubmissions));
  }

  // =========================================================================
  // MEMBERS CRUD (Synced with Firestore 'users')
  // =========================================================================
  Future<void> addMember(Map<String, dynamic> member) async {
    final id = member['id']?.toString() ?? 'mem_${DateTime.now().millisecondsSinceEpoch}';
    member['id'] = id;
    member['uid'] = id;
    member['allowedCourses'] = member['allowedCourses'] ?? [];
    member['allowedLessons'] = member['allowedLessons'] ?? [];
    _members.add(member);
    await _saveMembers();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('users').doc(id).set(member, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addMember error: $e");
      }
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> updated) async {
    final idx = _members.indexWhere((m) => m['id'] == id || m['uid'] == id);
    if (idx != -1) {
      updated['id'] = id;
      updated['uid'] = id;
      _members[idx] = updated;
      await _saveMembers();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('users').doc(id).set(updated, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Firestore updateMember error: $e");
        }
      }
    }
  }

  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m['id'] == id || m['uid'] == id);
    await _saveMembers();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('users').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteMember error: $e");
      }
    }
  }

  Future<void> _saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_members', jsonEncode(_members));
  }

  // =========================================================================
  // LATEST UPDATES (For Live Text Ticker)
  // =========================================================================
  Future<void> addLatestUpdate(Map<String, dynamic> update) async {
    final id = update['id']?.toString() ?? 'up_${DateTime.now().millisecondsSinceEpoch}';
    update['id'] = id;
    _latestUpdates.add(update);
    await _saveLatestUpdates();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('latest_updates').doc(id).set(update, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore addLatestUpdate error: $e");
      }
    }
  }

  Future<void> updateLatestUpdate(String id, Map<String, dynamic> updated) async {
    final idx = _latestUpdates.indexWhere((u) => u['id'] == id);
    if (idx != -1) {
      updated['id'] = id;
      _latestUpdates[idx] = updated;
      await _saveLatestUpdates();
      notifyListeners();

      if (isFirebaseReady) {
        try {
          await _firestore.collection('latest_updates').doc(id).set(updated, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Firestore updateLatestUpdate error: $e");
        }
      }
    }
  }

  Future<void> deleteLatestUpdate(String id) async {
    _latestUpdates.removeWhere((u) => u['id'] == id);
    await _saveLatestUpdates();
    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore.collection('latest_updates').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteLatestUpdate error: $e");
      }
    }
  }

  Future<void> _saveLatestUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_latest_updates', jsonEncode(_latestUpdates));
  }

  // =========================================================================
  // WEEKLY CHALLENGES
  // =========================================================================
  Future<void> addWeeklyChallenge(Map<String, dynamic> challenge) async {
    final id = challenge['id']?.toString() ?? 'chall_${DateTime.now().millisecondsSinceEpoch}';
    challenge['id'] = id;
    _weeklyChallenges.add(challenge);
    await _saveWeeklyChallenges();
    notifyListeners();
  }

  Future<void> updateWeeklyChallenge(String id, Map<String, dynamic> updated) async {
    final idx = _weeklyChallenges.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      updated['id'] = id;
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

  bool isFridayTransitionDay() {
    return DateTime.now().weekday == DateTime.friday;
  }

  Map<String, dynamic>? getActiveChallenge() {
    final explicitActive = _weeklyChallenges.where((c) => c['status'] == 'نشط').toList();
    if (explicitActive.isNotEmpty) return explicitActive.first;

    final now = DateTime.now();
    final anchor = DateTime(2026, 10, 3);
    int diffWeeks = 0;
    if (now.isAfter(anchor)) {
      diffWeeks = now.difference(anchor).inDays ~/ 7;
    }
    final currentWeekNum = (diffWeeks % 50) + 1;
    final match = _weeklyChallenges.firstWhere(
      (c) => c['weekNumber'] == currentWeekNum,
      orElse: () => _weeklyChallenges.isNotEmpty ? _weeklyChallenges.first : {},
    );
    if (match.isNotEmpty) return match;
    if (_weeklyChallenge != null) return _weeklyChallenge;
    return null;
  }

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

  // =========================================================================
  // ENROLLMENT & LESSON PROGRESS TRACKING
  // =========================================================================
  Future<void> enrollInCourse({
    required String courseId,
    required String userId,
    String? userEmail,
    String? userName,
    bool isCurriculum = false,
  }) async {
    final enrollmentData = {
      'courseId': courseId,
      'userId': userId,
      'userEmail': userEmail ?? '',
      'userName': userName ?? '',
      'isCurriculum': isCurriculum,
      'enrolledAt': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final key = 'enrollment_${userId}_$courseId';
    await prefs.setString(key, jsonEncode(enrollmentData));

    final listKey = 'user_enrolled_courses_$userId';
    final currentList = prefs.getStringList(listKey) ?? [];
    if (!currentList.contains(courseId)) {
      currentList.add(courseId);
      await prefs.setStringList(listKey, currentList);
    }

    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('enrollments')
            .doc(courseId)
            .set(enrollmentData, SetOptions(merge: true));

        await _firestore
            .collection('enrollments')
            .doc('${userId}_$courseId')
            .set(enrollmentData, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore enrollInCourse error: $e");
      }
    }
  }

  Future<bool> isEnrolled({required String courseId, required String userId}) async {
    if (userId.isEmpty || courseId.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final key = 'enrollment_${userId}_$courseId';
    if (prefs.containsKey(key)) return true;

    if (isFirebaseReady) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('enrollments')
            .doc(courseId)
            .get();
        if (doc.exists) {
          await prefs.setString(key, jsonEncode(doc.data()));
          return true;
        }
      } catch (e) {
        debugPrint("Firestore isEnrolled check error: $e");
      }
    }
    return false;
  }

  Future<void> markLessonWatched({
    required String courseId,
    required String lessonId,
    required String userId,
  }) async {
    if (userId.isEmpty || courseId.isEmpty || lessonId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'watched_${userId}_${courseId}_$lessonId';
    await prefs.setBool(key, true);

    final watchedListKey = 'watched_lessons_${userId}_$courseId';
    final currentList = prefs.getStringList(watchedListKey) ?? [];
    if (!currentList.contains(lessonId)) {
      currentList.add(lessonId);
      await prefs.setStringList(watchedListKey, currentList);
    }

    notifyListeners();

    if (isFirebaseReady) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('enrollments')
            .doc(courseId)
            .set({
          'watchedLessons': FieldValue.arrayUnion([lessonId]),
          'lastWatchedAt': DateTime.now().toIso8601String(),
          'lastLessonId': lessonId,
        }, SetOptions(merge: true));

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('watched_lessons')
            .doc('${courseId}_$lessonId')
            .set({
          'courseId': courseId,
          'lessonId': lessonId,
          'watchedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore markLessonWatched error: $e");
      }
    }
  }

  Future<List<String>> getWatchedLessons({required String courseId, required String userId}) async {
    if (userId.isEmpty || courseId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final watchedListKey = 'watched_lessons_${userId}_$courseId';
    return prefs.getStringList(watchedListKey) ?? [];
  }

  // =========================================================================
  // COURSE PURCHASE REQUESTS
  // =========================================================================
  Future<void> submitPurchaseRequest({
    required String courseId,
    required String courseTitle,
    required dynamic price,
    required String paymentMethod,
    required String senderPhone,
    required String userId,
    required String userEmail,
    String notes = '',
  }) async {
    final req = {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'price': price,
      'paymentMethod': paymentMethod,
      'senderPhone': senderPhone,
      'userId': userId,
      'userEmail': userEmail,
      'notes': notes,
      'status': 'قيد المراجعة',
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (isFirebaseReady) {
      try {
        await _firestore.collection('purchase_requests').add(req);
      } catch (e) {
        debugPrint("Firestore submitPurchaseRequest error: $e");
      }
    }
  }
}
