import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  bool _initialized = false;
  User? _currentUser;
  bool _isAdmin = false;

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  bool get isAdmin => _isAdmin;

  Future<void> checkAdminStatus(User? user) async {
    if (user == null) {
      _isAdmin = false;
      notifyListeners();
      return;
    }
    try {
      final tokenResult = await user.getIdTokenResult();
      _isAdmin = tokenResult.claims?['admin'] == true || tokenResult.claims?['role'] == 'admin';
    } catch (_) {
      _isAdmin = false;
    }
    notifyListeners();
  }

  void init() {
    if (_initialized || !isFirebaseReady) return;
    try {
      _auth.authStateChanges().listen((User? user) {
        _currentUser = user;
        if (user != null) {
          UserService.instance.syncUserProfile(user);
        }
        checkAdminStatus(user);
      });
      _initialized = true;
      if (_auth.currentUser != null) {
        checkAdminStatus(_auth.currentUser);
      }
    } catch (e) {
      debugPrint("AuthService listener warning: $e");
    }
  }

  User? get currentUser {
    if (!isFirebaseReady) return null;
    return _currentUser ?? _auth.currentUser;
  }

  bool get isAuthenticated => currentUser != null;

  Stream<User?> get authStateChanges {
    if (!isFirebaseReady) return const Stream.empty();
    return _auth.authStateChanges();
  }

  /// Sign in with Google (using popup on Web, redirect fallback)
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        credential = await _auth.signInWithProvider(googleProvider);
      }

      if (credential.user != null) {
        await UserService.instance.syncUserProfile(credential.user!);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getArabicAuthErrorMessage(e);
    } catch (e) {
      throw "حدث خطأ أثناء تسجيل الدخول بحساب Google: $e";
    }
  }

  /// Register with Email and Password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? whatsapp,
    String? country,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        // Send email verification
        try {
          await user.sendEmailVerification();
        } catch (_) {}

        // Save complete profile in Firestore
        await UserService.instance.syncUserProfile(
          user,
          additionalData: {
            'name': name.trim(),
            'phone': phone?.trim() ?? '',
            'whatsapp': whatsapp?.trim() ?? '',
            'country': country?.trim() ?? 'مصر',
          },
        );
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getArabicAuthErrorMessage(e);
    } catch (e) {
      throw "حدث خطأ أثناء إنشاء الحساب: $e";
    }
  }

  /// Sign in with Email and Password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await UserService.instance.syncUserProfile(credential.user!);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getArabicAuthErrorMessage(e);
    } catch (e) {
      throw "حدث خطأ أثناء تسجيل الدخول: $e";
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getArabicAuthErrorMessage(e);
    } catch (e) {
      throw "تعذر إرسال رابط استعادة كلمة المرور: $e";
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  /// Map Firebase Auth codes to clear Arabic errors
  String _getArabicAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'كلمة المرور غير صحيحة، يرجى المحاولة مرة أخرى.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل بحساب آخر.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً، يرجى كتابة 6 خانات على الأقل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صالحة.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب من قبل الإدارة.';
      case 'too-many-requests':
        return 'محاولات دخول كثيرة خاطئة، تم حظر المحاولة مؤقتاً لحمايتك. حاول لاحقاً.';
      case 'popup-closed-by-user':
        return 'تم إغلاق نافذة تسجيل الدخول قبل إتمام العملية.';
      case 'cancelled':
        return 'تم إلغاء عملية تسجيل الدخول.';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت، يرجى التحقق من اتصالك.';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول هذه غير مفعلة حالياً في إعدادات المشروع.';
      default:
        return e.message ?? 'حدث خطأ غير متوقع أثناء المصادقة.';
    }
  }
}
