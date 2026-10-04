import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService instance = GamificationService._internal();
  GamificationService._internal();

  int _points = 0;
  List<Map<String, dynamic>> _earnedBadges = [];
  List<String> _completedLessons = [];
  List<String> _completedCourses = [];
  bool _isLoading = false;

  int get points => _points;
  List<Map<String, dynamic>> get earnedBadges => _earnedBadges;
  List<String> get completedLessons => _completedLessons;
  List<String> get completedCourses => _completedCourses;
  bool get isLoading => _isLoading;

  static const List<Map<String, dynamic>> allAvailableBadges = [
    {
      'id': 'first_lesson',
      'title': '🟢 بداية الرحلة',
      'description': 'إكمال أول درس تعليمي في المنصة',
      'icon': Icons.school_rounded,
      'requirement': 'إكمال درس واحد',
    },
    {
      'id': 'ten_lessons',
      'title': '📚 محب التعلم',
      'description': 'إكمال 10 دروس تعليمية',
      'icon': Icons.menu_book_rounded,
      'requirement': 'إكمال 10 دروس',
    },
    {
      'id': 'first_course',
      'title': '💻 المبرمج الصغير',
      'description': 'إكمال أول كورس برمجة كامل',
      'icon': Icons.laptop_chromebook_rounded,
      'requirement': 'إكمال كورس كامل',
    },
    {
      'id': 'algo_master',
      'title': '🧠 عقل الخوارزميات',
      'description': 'اجتياز اختبار بنسبة 90% أو أكثر',
      'icon': Icons.psychology_rounded,
      'requirement': 'الحصول على 90%+ في اختبار',
    },
    {
      'id': 'five_quizzes_90',
      'title': '🎯 دقة الامتحان',
      'description': 'اجتياز 5 اختبارات مختلفة بنسبة 90% فأعلى',
      'icon': Icons.military_tech_rounded,
      'requirement': 'اجتياز 5 اختبارات بامتياز',
    },
    {
      'id': 'streak_5',
      'title': '🔥 المثابر',
      'description': 'متابعة التعلم وإكمال الدروس عبر 5 أيام مختلفة',
      'icon': Icons.local_fire_department_rounded,
      'requirement': 'التعلم في 5 أيام متفرقة',
    },
    {
      'id': 'five_challenges',
      'title': '🏅 بطل التحديات',
      'description': 'إكمال 5 تحديات برمجية أسبوعية بنجاح',
      'icon': Icons.emoji_events_rounded,
      'requirement': 'حل 5 تحديات أسبوعية',
    },
    {
      'id': 'five_courses',
      'title': '👑 خبير التعلم',
      'description': 'إكمال 5 كورسات كاملة في المنصة',
      'icon': Icons.workspace_premium_rounded,
      'requirement': 'إكمال 5 كورسات كاملة',
    },
  ];

  /// Initialize and sync user points & badges
  Future<void> syncUserGamification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _points = 0;
      _earnedBadges = [];
      _completedLessons = [];
      _completedCourses = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Direct real-time read from Firestore user doc
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _points = (data['points'] as num?)?.toInt() ?? 0;
        _earnedBadges = List<Map<String, dynamic>>.from(data['earnedBadges'] ?? []);
        _completedLessons = List<String>.from(data['completedLessons'] ?? []);
        _completedCourses = List<String>.from(data['completedCourses'] ?? []);
      }
    } catch (e) {
      debugPrint("GamificationService sync error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Award points for completing a lesson (10 for first, 5 for others)
  Future<Map<String, dynamic>> awardLessonCompletion(String lessonId) async {
    return _sendAwardRequest({
      'type': 'complete_lesson',
      'refId': lessonId,
    });
  }

  /// Award points for completing a course (50 points)
  Future<Map<String, dynamic>> awardCourseCompletion(String courseId) async {
    return _sendAwardRequest({
      'type': 'complete_course',
      'refId': courseId,
    });
  }

  /// Award points for passing a quiz (10 pts for 70%+, 20 pts for 90%+)
  Future<Map<String, dynamic>> awardQuizPass(String quizId, double percentage) async {
    return _sendAwardRequest({
      'type': 'pass_quiz',
      'refId': quizId,
      'percentage': percentage,
    });
  }

  /// Award points for completing a challenge (25 pts)
  Future<Map<String, dynamic>> awardChallengeCompletion(String challengeId) async {
    return _sendAwardRequest({
      'type': 'complete_challenge',
      'refId': challengeId,
    });
  }

  /// Admin manual points adjustment
  Future<Map<String, dynamic>> adminManualAdjust({
    required String targetUid,
    required int points,
    String? reason,
  }) async {
    return _sendAwardRequest({
      'type': 'manual_admin',
      'targetUid': targetUid,
      'customPoints': points,
      'customReason': reason,
    });
  }

  Future<Map<String, dynamic>> _sendAwardRequest(Map<String, dynamic> payload) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User is not authenticated'};
      }

      final idToken = await user.getIdToken(true);
      final url = Uri.base.resolve('/api/gamification/award-points');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(payload),
      );

      final res = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && res['success'] == true) {
        if (res['newTotal'] != null) {
          _points = (res['newTotal'] as num).toInt();
        }
        if (res['newlyEarnedBadges'] != null) {
          final List newB = res['newlyEarnedBadges'];
          for (final b in newB) {
            _earnedBadges.add(Map<String, dynamic>.from(b));
          }
        }
        notifyListeners();
        return res;
      }
      return res;
    } catch (e) {
      debugPrint("Gamification award error: $e");
      return {'success': false, 'message': '$e'};
    }
  }
}
