// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../services/auth_service.dart';
import 'social_icons.dart';
import 'auth_modal.dart';

/// Unified Header used across all pages of the application.
/// Ensures identical design, branding, navigation, and smart back behavior everywhere.
class UnifiedAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;
  final VoidCallback? onBack;
  final String? pageTitle;

  const UnifiedAppHeader({
    super.key,
    this.currentRoute,
    this.onBack,
    this.pageTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHome = currentRoute == '/' || currentRoute == null;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Right: Logo + Brand + Page Subtitle
              InkWell(
                onTap: () => Navigator.of(context).pushReplacementNamed('/'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ArabicData.brandName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            pageTitle ?? ArabicData.brandSubtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Center: Desktop Navigation Links (if not mobile)
              if (!isMobile)
                Row(
                  children: [
                    _navItem(context, "الكورسات", '/courses', currentRoute == '/courses', isDark),
                    _navItem(context, "المناهج", '/curricula', currentRoute == '/lessons' || currentRoute == '/curricula', isDark),
                    _navItem(context, "تواصل معنا", '/contact', currentRoute == '/contact', isDark),
                  ],
                ),

              // 3. Left: Smart Back Button, Theme, Auth & Social
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smart Back Button on inner pages
                  if (!isHome) ...[
                    ElevatedButton.icon(
                      onPressed: () => _handleBack(context),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        "رجوع",
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF00E5FF),
                        elevation: 0,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Theme Toggle
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
                      size: 20,
                    ),
                    tooltip: isDark ? "تفعيل الوضع النهاري" : "تفعيل الوضع الليلي",
                    onPressed: () => AppThemeManager.toggleTheme(),
                  ),

                  // Auth / Profile Button
                  ListenableBuilder(
                    listenable: AuthService.instance,
                    builder: (ctx, _) {
                      final user = AuthService.instance.currentUser;
                      if (user != null) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (AuthService.instance.isAdmin && !isMobile)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).pushNamed('/admin'),
                                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 15),
                                  label: Text("لوحة التحكم", style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkWell(
                                onTap: () => Navigator.of(context).pushNamed('/profile'),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: const Color(0xFF8B5CF6),
                                        backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty)
                                            ? NetworkImage(user.photoURL!)
                                            : null,
                                        child: (user.photoURL == null || user.photoURL!.isEmpty)
                                            ? Text((user.displayName ?? 'ط')[0],
                                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold))
                                            : null,
                                      ),
                                      if (!isMobile) ...[
                                        const SizedBox(width: 5),
                                        Text(
                                          AuthService.instance.isAdmin ? "الأدمن" : "حسابي",
                                          style: GoogleFonts.cairo(
                                              fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ElevatedButton.icon(
                          onPressed: () => AuthModal.show(context),
                          icon: const Icon(Icons.person_outline_rounded, size: 15),
                          label: Text(isMobile ? "دخول" : "تسجيل الدخول",
                              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      );
                    },
                  ),

                  // Desktop Social Icons
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    const SocialIconsBar(
                      facebookUrl: ArabicData.facebookUrl,
                      youtubeUrl: ArabicData.youtubeUrl,
                      telegramUrl: ArabicData.telegramUrl,
                      linkedinUrl: ArabicData.linkedinUrl,
                    ),
                  ],

                  // Mobile Menu Drawer Button
                  if (isMobile)
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.primaryLight, size: 26),
                        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
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

  Widget _navItem(BuildContext context, String title, String route, bool isActive, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (isActive) return;
            Navigator.of(context).pushNamed(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? const Color(0xFF0284C7)
                    : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified Mobile Drawer matching the top header across all pages.
class UnifiedAppDrawer extends StatelessWidget {
  final String? currentRoute;

  const UnifiedAppDrawer({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ArabicData.brandName,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        ArabicData.brandSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(context, "الرئيسية", Icons.home_rounded, '/', currentRoute == '/'),
                  _drawerItem(context, "الكورسات والمسارات", Icons.school_rounded, '/courses', currentRoute == '/courses'),
                  _drawerItem(context, "المناهج الدراسية", Icons.menu_book_rounded, '/lessons', currentRoute == '/lessons' || currentRoute == '/curricula'),
                  _drawerItem(context, "تحدي الأسبوع", Icons.emoji_events_rounded, '/challenge', currentRoute == '/challenge'),
                  _drawerItem(context, "اختبر نفسك", Icons.quiz_rounded, '/quiz', currentRoute == '/quiz'),
                  _drawerItem(context, "من نحن", Icons.info_outline_rounded, '/about', currentRoute == '/about'),
                  _drawerItem(context, "تواصل معنا", Icons.contact_mail_rounded, '/contact', currentRoute == '/contact'),
                  if (AuthService.instance.isAdmin)
                    _drawerItem(context, "لوحة التحكم", Icons.admin_panel_settings_rounded, '/admin', currentRoute == '/admin'),
                ],
              ),
            ),

            // Social & Theme in Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SocialIconsBar(
                    facebookUrl: ArabicData.facebookUrl,
                    youtubeUrl: ArabicData.youtubeUrl,
                    telegramUrl: ArabicData.telegramUrl,
                    linkedinUrl: ArabicData.linkedinUrl,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "جميع الحقوق محفوظة © 2026",
                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, IconData icon, String route, bool isActive) {
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xFF0284C7) : Colors.grey, size: 22),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          color: isActive ? const Color(0xFF0284C7) : null,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }
}

/// Unified Footer matching all pages across the website.
class UnifiedAppFooter extends StatelessWidget {
  const UnifiedAppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              if (!isMobile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset('assets/images/logo.jpeg', width: 38, height: 38, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ArabicData.brandName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),

                    // Quick links
                    Row(
                      children: [
                        _footerLink(context, "الكورسات", '/courses'),
                        _footerLink(context, "الدروس", '/lessons'),
                        _footerLink(context, "من نحن", '/about'),
                        _footerLink(context, "سياسة الاستخدام والخصوصية", '/privacy'),
                        _footerLink(context, "تواصل معنا", '/contact'),
                      ],
                    ),

                    // Social
                    const SocialIconsBar(
                      facebookUrl: ArabicData.facebookUrl,
                      youtubeUrl: ArabicData.youtubeUrl,
                      telegramUrl: ArabicData.telegramUrl,
                      linkedinUrl: ArabicData.linkedinUrl,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset('assets/images/logo.jpeg', width: 38, height: 38, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ArabicData.brandName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _footerLink(context, "الكورسات", '/courses'),
                        _footerLink(context, "الدروس", '/lessons'),
                        _footerLink(context, "من نحن", '/about'),
                        _footerLink(context, "سياسة الاستخدام والخصوصية", '/privacy'),
                        _footerLink(context, "تواصل معنا", '/contact'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SocialIconsBar(
                      facebookUrl: ArabicData.facebookUrl,
                      youtubeUrl: ArabicData.youtubeUrl,
                      telegramUrl: ArabicData.telegramUrl,
                      linkedinUrl: ArabicData.linkedinUrl,
                    ),
                  ],
                ),

              const SizedBox(height: 18),
              Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              const SizedBox(height: 12),

              Text(
                "جميع الحقوق محفوظة © 2026 Eslam Atef | Code & AI",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(route),
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF0284C7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
