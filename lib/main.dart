// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/privacy_page.dart';
import 'pages/contact_page.dart';
import 'pages/recording_page.dart';
import 'pages/courses_page.dart';
import 'pages/lessons_page.dart';
import 'pages/articles_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/challenge_page.dart';
import 'pages/quiz_page.dart';
import 'pages/student_profile_page.dart';
import 'pages/checkout_page.dart';
import 'services/site_data_service.dart';
import 'services/auth_service.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthService.instance.init();
  } catch (e) {
    debugPrint("Firebase init status: $e");
  }
  await SiteDataService.instance.init();
  runApp(const EslamAtefApp());
}

class EslamAtefApp extends StatelessWidget {
  const EslamAtefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeManager.themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: "Eslam Atef | Code & AI — تعليم علوم الحاسب والذكاء الاصطناعي",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/',
          builder: (context, child) {
            return Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) =>
                      SelectionArea(child: child ?? const SizedBox.shrink()),
                ),
              ],
            );
          },
          onGenerateRoute: (settings) {
            final rawName = settings.name ?? '';
            final uri = Uri.tryParse(rawName) ?? Uri();
            final path = uri.path;

            Widget page;
            switch (path) {
              case '/courses':
                page = const CoursesPage();
                break;
              case '/lessons':
              case '/curricula':
                page = const LessonsPage();
                break;
              case '/blog':
              case '/articles':
                page = const ArticlesPage();
                break;
              case '/challenge':
                page = const WeeklyChallengePage();
                break;
              case '/quiz':
                page = const QuizPage();
                break;
              case '/about':
                page = const AboutPage();
                break;
              case '/privacy':
                page = const PrivacyPage();
                break;
              case '/contact':
                page = const ContactPage();
                break;
              case '/recording':
                page = const RecordingStudioPage();
                break;
              case '/admin':
                page = const AdminDashboardPage();
                break;
              case '/profile':
                page = const StudentProfilePage();
                break;
              case '/checkout':
                page = const CheckoutPage();
                break;
              case '/':
              default:
                page = const HomePage();
                break;
            }

            return MaterialPageRoute(
              settings: settings,
              builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: page,
              ),
            );
          },
          routes: {
            '/': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: HomePage(),
            ),
            '/courses': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: CoursesPage(),
            ),
            '/lessons': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: LessonsPage(),
            ),
            '/challenge': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: WeeklyChallengePage(),
            ),
            '/quiz': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: QuizPage(),
            ),
            '/about': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: AboutPage(),
            ),
            '/privacy': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: PrivacyPage(),
            ),
            '/contact': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: ContactPage(),
            ),
            '/recording': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: RecordingStudioPage(),
            ),
            '/admin': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: AdminDashboardPage(),
            ),
            '/profile': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: StudentProfilePage(),
            ),
            '/checkout': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: CheckoutPage(),
            ),
            '/curricula': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: LessonsPage(),
            ),
            '/blog': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: ArticlesPage(),
            ),
            '/articles': (context) => const Directionality(
              textDirection: TextDirection.rtl,
              child: ArticlesPage(),
            ),
          },
        );
      },
    );
  }
}
