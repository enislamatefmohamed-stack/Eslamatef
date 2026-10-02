import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Generated for project: eslam-atef-code-ai
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  // Web Firebase configuration for project: eslam-atef-code-ai
  // Replace these values with the exact credentials from your Firebase Console
  // (Project Settings -> General -> Your apps -> Web app -> SDK setup and configuration)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2cfDKEt__EQmHRDeTUD660w2Ztr2vS5U',
    appId: '1:468099037466:web:1ab696bf5ae5e0ce2814a3',
    messagingSenderId: '468099037466',
    projectId: 'eslam-atef-code-ai',
    authDomain: 'eslam-atef-code-ai.firebaseapp.com',
    storageBucket: 'eslam-atef-code-ai.firebasestorage.app',
    measurementId: 'G-XXCBZ6JMDH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSy_ANDROID_KEY',
    appId: '1:1234567890:android:abcdef',
    messagingSenderId: '1234567890',
    projectId: 'eslam-atef-code-ai',
    storageBucket: 'eslam-atef-code-ai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy_IOS_KEY',
    appId: '1:1234567890:ios:abcdef',
    messagingSenderId: '1234567890',
    projectId: 'eslam-atef-code-ai',
    storageBucket: 'eslam-atef-code-ai.firebasestorage.app',
    iosBundleId: 'com.eslamatef.codeai',
  );
}
