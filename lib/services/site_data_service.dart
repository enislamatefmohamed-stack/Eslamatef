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

  bool _isInitialized = false;

  List<Map<String, dynamic>> get courses => _courses;
  List<Map<String, dynamic>> get lessons => _lessons;
  List<Map<String, dynamic>> get latestUpdates => _latestUpdates;
  Map<String, dynamic>? get weeklyChallenge => _weeklyChallenge;
  List<Map<String, dynamic>> get quizQuestions => _quizQuestions;
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
        // Empty by default as requested (no dummy data)
        _latestUpdates = [];
      }

      final challengeStr = prefs.getString('site_weekly_challenge');
      if (challengeStr != null) {
        _weeklyChallenge = Map<String, dynamic>.from(jsonDecode(challengeStr));
      } else {
        // No dummy challenge by default
        _weeklyChallenge = null;
      }

      final quizStr = prefs.getString('site_quiz_questions');
      if (quizStr != null) {
        _quizQuestions = List<Map<String, dynamic>>.from(jsonDecode(quizStr));
      } else {
        // No dummy quiz questions by default
        _quizQuestions = [];
      }
    } catch (e) {
      debugPrint("Error initializing SiteDataService: $e");
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // --- Courses CRUD ---
  Future<void> addCourse(Map<String, dynamic> course) async {
    course['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _courses.add(course);
    await _saveCourses();
    notifyListeners();
  }

  Future<void> updateCourse(String id, Map<String, dynamic> updated) async {
    final idx = _courses.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
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

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_courses', jsonEncode(_courses));
  }

  // --- Lessons CRUD ---
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

  // --- Weekly Challenge CRUD ---
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
}
