import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService extends ChangeNotifier {
  static final UserService instance = UserService._internal();
  UserService._internal();

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  /// Create or update student profile document in Firestore
  Future<void> syncUserProfile(
    User user, {
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isFirebaseReady) return;
    try {
      final userDoc = _usersCol.doc(user.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        // First-time registration
        await userDoc.set({
          'uid': user.uid,
          'name': additionalData?['name'] ?? user.displayName ?? 'طالب جديد',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'phone': additionalData?['phone'] ?? user.phoneNumber ?? '',
          'whatsapp': additionalData?['whatsapp'] ?? user.phoneNumber ?? '',
          'country': additionalData?['country'] ?? 'مصر',
          'role': 'student', // 'student' or 'admin'
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'quizzesCount': 0,
          'challengesCount': 0,
        });
      } else {
        // Existing user update
        final updatePayload = <String, dynamic>{
          'lastLogin': FieldValue.serverTimestamp(),
        };
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          updatePayload['photoUrl'] = user.photoURL;
        }
        if (additionalData != null) {
          updatePayload.addAll(additionalData);
        }
        await userDoc.update(updatePayload);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error syncing user profile to Firestore: $e");
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
    return null;
  }

  /// Stream user profile for reactive UI
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(String uid) {
    return _usersCol.doc(uid).snapshots();
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(uid).update(data);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating user profile: $e");
      rethrow;
    }
  }

  /// Check if user has admin role (checks Firebase Custom Claims first)
  Future<bool> isUserAdmin(String uid) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        final idTokenResult = await currentUser.getIdTokenResult();
        if (idTokenResult.claims?['admin'] == true || idTokenResult.claims?['role'] == 'admin') {
          return true;
        }
      }
      final profile = await getUserProfile(uid);
      return profile?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Fetch all registered students for Admin Dashboard
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final query = await _usersCol.orderBy('createdAt', descending: true).get();
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("Error getting all students: $e");
      return [];
    }
  }

  /// Stream all students for reactive Admin Dashboard
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllStudents() {
    return _usersCol.orderBy('createdAt', descending: true).snapshots();
  }

  /// Update user role (admin <-> student)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _usersCol.doc(uid).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating user role: $e");
      rethrow;
    }
  }

  /// Delete user from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCol.doc(uid).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting user: $e");
      rethrow;
    }
  }

  /// Send password reset email to member
  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint("Error sending password reset email: $e");
      rethrow;
    }
  }

  /// Record a quiz attempt for the student
  Future<void> recordQuizSubmission(String uid, Map<String, dynamic> submission) async {
    try {
      final batch = _firestore.batch();

      // 1. Add to student's subcollection
      final studentQuizRef = _usersCol.doc(uid).collection('quizzes').doc();
      batch.set(studentQuizRef, {
        ...submission,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Add to global quiz_submissions collection
      final globalSubRef = _firestore.collection('quiz_submissions').doc(studentQuizRef.id);
      batch.set(globalSubRef, {
        ...submission,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update student's last active timestamp
      batch.update(_usersCol.doc(uid), {
        'lastActive': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("Error recording quiz submission: $e");
    }
  }

  /// Record a weekly challenge submission for the student
  Future<void> recordChallengeSubmission(String uid, Map<String, dynamic> submission) async {
    try {
      final batch = _firestore.batch();

      // 1. Add to student's subcollection
      final studentChallRef = _usersCol.doc(uid).collection('challenges').doc();
      batch.set(studentChallRef, {
        ...submission,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Add to global challenge_submissions collection
      final globalChallRef = _firestore.collection('challenge_submissions').doc(studentChallRef.id);
      batch.set(globalChallRef, {
        ...submission,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update student's last active timestamp
      batch.update(_usersCol.doc(uid), {
        'lastActive': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint("Error recording challenge submission: $e");
    }
  }
}
