import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/games') : null,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                UnifiedAppHeader(
                  currentRoute: '/games',
                  pageTitle: 'الألعاب — ألعاب برمجية وتفاعلية',
                  showBackButton: true,
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 40,
                            vertical: isMobile ? 60 : 100,
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 680),
                              padding: EdgeInsets.all(isMobile ? 28 : 48),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sports_esports_rounded,
                                      size: 44,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "الألعاب",
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 28 : 34,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF00E5FF).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "قريباً",
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "نعمل حالياً على تجهيز باقة مميزة وممتعة من الألعاب البرمجية والمنطقية التفاعلية لتطوير مهارات التفكير وحل المشكلات بطريقة تفاعلية وشيقة للأطفال والناشئين.",
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 15 : 16.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                      height: 1.8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacementNamed('/courses');
                                    },
                                    icon: const Icon(Icons.school_rounded, size: 20),
                                    label: Text(
                                      "استكشف الكورسات المتاحة",
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0284C7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const UnifiedAppFooter(),
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
}
