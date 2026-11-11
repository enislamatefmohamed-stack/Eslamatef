// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../services/auth_service.dart';
import '../services/site_data_service.dart';
import 'social_icons.dart';
import 'auth_modal.dart';
import 'achievements_dialog.dart';

/// Unified Header used across all pages of the application.
/// Ensures identical design, branding, navigation, and smart back behavior everywhere.
class UnifiedAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;
  final VoidCallback? onBack;
  final String? pageTitle;
  final bool showBackButton;

  const UnifiedAppHeader({
    super.key,
    this.currentRoute,
    this.onBack,
    this.pageTitle,
    this.showBackButton = false,
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

  void _showNotificationsDialog(BuildContext context, List<Map<String, dynamic>> notifs, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF00E5FF), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "مركز الإشعارات والتنبيهات",
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                Expanded(
                  child: notifs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                "لا توجد إشعارات جديدة حالياً",
                                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ستصلك التحديثات والإعلانات فور نشرها",
                                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: notifs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (c, idx) {
                            final n = notifs[idx];
                            final title = (n['title'] ?? 'إشعار').toString();
                            final body = (n['body'] ?? '').toString();
                            final sender = (n['sender'] ?? 'إدارة الأكاديمية').toString();
                            final isPublic = (n['target'] ?? 'all') == 'all';
                            final time = (n['createdAt'] ?? '').toString();
                            String timeStr = '';
                            if (time.isNotEmpty) {
                              try {
                                final dt = DateTime.parse(time);
                                timeStr = "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                              } catch (_) {}
                            }

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isPublic
                                      ? const Color(0xFF00E5FF).withOpacity(0.3)
                                      : const Color(0xFFF59E0B).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isPublic ? Icons.campaign_rounded : Icons.mark_email_unread_rounded,
                                            size: 16,
                                            color: isPublic ? const Color(0xFF00E5FF) : const Color(0xFFF59E0B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isPublic ? "إعلان عام" : "إشعار خاص بك",
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isPublic ? const Color(0xFF00E5FF) : const Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (timeStr.isNotEmpty)
                                        Text(
                                          timeStr,
                                          style: GoogleFonts.cairo(fontSize: 10.5, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (body.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      body,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        height: 1.5,
                                        color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "من: $sender",
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SelectionContainer.disabled(
      child: Container(
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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
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
                ),

                // 2. Center: Desktop Navigation Links (الكورسات - المقالات فقط)
                if (!isMobile)
                  Row(
                    children: [
                      InteractiveNavButton(
                        title: "الكورسات",
                        route: '/courses',
                        isActive: currentRoute == '/courses',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      InteractiveNavButton(
                        title: "المقالات",
                        route: '/blog',
                        isActive: currentRoute == '/blog' || currentRoute == '/articles',
                        isDark: isDark,
                      ),
                    ],
                  ),

                // 3. Left: Smart Back Button, Theme, Auth & Social
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smart Back Button (only when explicitly requested)
                    if (showBackButton) ...[
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton.icon(
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
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Notification Bell Icon with Badge
                    ListenableBuilder(
                      listenable: SiteDataService.instance,
                      builder: (ctx, _) {
                        final user = AuthService.instance.currentUser;
                        final notifs = SiteDataService.instance.notifications.where((n) {
                          final target = (n['target'] ?? 'all').toString();
                          if (target == 'all') return true;
                          if (user != null && (target == user.uid || (n['targetUid'] ?? '') == user.uid || (n['targetEmail'] ?? '') == user.email)) return true;
                          return false;
                        }).toList();

                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                                  size: 22,
                                ),
                                tooltip: "الإشعارات والتنبيهات",
                                onPressed: () => _showNotificationsDialog(context, notifs, isDark),
                              ),
                              if (notifs.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Center(
                                      child: Text(
                                        notifs.length > 9 ? '+9' : '${notifs.length}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),

                    // Theme Toggle
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark ? const Color(0xFFFFB300) : const Color(0xFF1E293B),
                          size: 20,
                        ),
                        tooltip: isDark ? "تفعيل الوضع النهاري" : "تفعيل الوضع الليلي",
                        onPressed: () => AppThemeManager.toggleTheme(),
                      ),
                    ),

                    // Auth / Profile Button
                    ListenableBuilder(
                      listenable: AuthService.instance,
                      builder: (ctx, _) {
                        final user = AuthService.instance.currentUser;
                        if (user != null) {
                          final String displayName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
                              ? user.displayName!.trim()
                              : (user.email?.split('@').first ?? "حسابي");

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (AuthService.instance.isAdmin && !isMobile) ...[
                                _HoverBadgeButton(
                                  onTap: () => Navigator.of(context).pushNamed('/admin'),
                                  icon: Icons.admin_panel_settings_rounded,
                                  label: "لوحة التحكم",
                                  color: const Color(0xFF0284C7),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (!isMobile) ...[
                                _HoverBadgeButton(
                                  onTap: () => AchievementsDialog.show(context),
                                  icon: Icons.emoji_events_rounded,
                                  label: "إنجازاتي",
                                  color: const Color(0xFF0284C7),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                              ],
                              _HoverUserButton(
                                onTap: () => Navigator.of(context).pushNamed('/profile'),
                                user: user,
                                displayName: displayName,
                                isDark: isDark,
                                isMobile: isMobile,
                              ),
                            ],
                          );
                        }

                        // When NOT logged in: strictly says "الاشتراك"
                        return _HoverAuthButton(
                          label: "الاشتراك",
                          onTap: () => AuthModal.show(context),
                          isDark: isDark,
                          isMobile: isMobile,
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
                      ),
                    ],

                    // Mobile Menu Drawer Button
                    if (isMobile)
                      Builder(
                        builder: (ctx) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon: const Icon(Icons.menu_rounded, color: AppColors.primaryLight, size: 26),
                            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Interactive Nav Button with smooth hover animation & pointer cursor
// ---------------------------------------------------------------------------
class InteractiveNavButton extends StatefulWidget {
  final String title;
  final String route;
  final bool isActive;
  final bool isDark;

  const InteractiveNavButton({
    super.key,
    required this.title,
    required this.route,
    required this.isActive,
    required this.isDark,
  });

  @override
  State<InteractiveNavButton> createState() => _InteractiveNavButtonState();
}

class _InteractiveNavButtonState extends State<InteractiveNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0284C7);
    final isDark = widget.isDark;

    Color textColor;
    if (widget.isActive) {
      textColor = activeColor;
    } else if (_isHovered) {
      textColor = const Color(0xFF00E5FF);
    } else {
      textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    }

    Color bgColor;
    if (widget.isActive) {
      bgColor = isDark ? const Color(0xFF0284C7).withOpacity(0.2) : const Color(0xFFE0F2FE);
    } else if (_isHovered) {
      bgColor = const Color(0xFF00E5FF).withOpacity(0.08); // Subtle cyan glow without gray
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.isActive) return;
          Navigator.of(context).pushNamed(widget.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (widget.isActive || _isHovered)
                  ? const Color(0xFF00E5FF).withOpacity(0.5)
                  : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: [
              if (_isHovered || widget.isActive)
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
            ],
          ),
          child: Text(
            widget.title,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: (widget.isActive || _isHovered) ? FontWeight.w800 : FontWeight.w600,
              color: (widget.isActive || _isHovered) ? const Color(0xFF00E5FF) : textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Hover Auth Button ("الاشتراك")
// ---------------------------------------------------------------------------
class _HoverAuthButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isMobile;

  const _HoverAuthButton({
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_HoverAuthButton> createState() => _HoverAuthButtonState();
}

class _HoverAuthButtonState extends State<_HoverAuthButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 12 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF0369A1) : const Color(0xFF0284C7),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: const Color(0xFF0284C7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Hover User Button (Shows user's real name when logged in)
// ---------------------------------------------------------------------------
class _HoverUserButton extends StatefulWidget {
  final VoidCallback onTap;
  final dynamic user;
  final String displayName;
  final bool isDark;
  final bool isMobile;

  const _HoverUserButton({
    required this.onTap,
    required this.user,
    required this.displayName,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_HoverUserButton> createState() => _HoverUserButtonState();
}

class _HoverUserButtonState extends State<_HoverUserButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isDark
                ? (_isHovered ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
                : (_isHovered ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? const Color(0xFF00E5FF) : const Color(0xFF0284C7).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF0284C7),
                backgroundImage: (widget.user.photoURL != null && widget.user.photoURL!.isNotEmpty)
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
                child: (widget.user.photoURL == null || widget.user.photoURL!.isEmpty)
                    ? Text(
                        widget.displayName.isNotEmpty ? widget.displayName[0] : 'ط',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              if (!widget.isMobile) ...[
                const SizedBox(width: 6),
                Text(
                  widget.displayName,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Hover Badge Button (Admin / Achievements)
// ---------------------------------------------------------------------------
class _HoverBadgeButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _HoverBadgeButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  State<_HoverBadgeButton> createState() => _HoverBadgeButtonState();
}

class _HoverBadgeButtonState extends State<_HoverBadgeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_isHovered ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.color.withOpacity(_isHovered ? 0.7 : 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ],
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
                  _drawerItem(context, "الكورسات", Icons.school_rounded, '/courses', currentRoute == '/courses'),
                  _drawerItem(context, "المقالات", Icons.article_rounded, '/blog', currentRoute == '/blog' || currentRoute == '/articles'),
                  _drawerItem(context, "من نحن", Icons.info_outline_rounded, '/about', currentRoute == '/about'),
                  _drawerItem(context, "سياسة الاستخدام", Icons.verified_user_rounded, '/privacy', currentRoute == '/privacy'),
                  _drawerItem(context, "تواصل معنا", Icons.support_agent_rounded, '/contact', currentRoute == '/contact'),
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF0284C7), size: 22),
                    title: Text(
                      AuthService.instance.currentUser != null
                          ? (AuthService.instance.currentUser?.displayName?.isNotEmpty == true
                              ? AuthService.instance.currentUser!.displayName!
                              : "الملف الشخصي")
                          : "الاشتراك",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0284C7),
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (AuthService.instance.currentUser != null) {
                        Navigator.of(context).pushNamed('/profile');
                      } else {
                        AuthModal.show(context);
                      }
                    },
                  ),
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
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "جميع الحقوق محفوظة © 2027 Eslam Atef | Code & AI",
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
/// Links: الكورسات - المقالات - من نحن - سياسه الاستخدام - تواصل معنا
/// Logo + Brand Name + Copyright © 2027 Eslam Atef | Code & AI
class UnifiedAppFooter extends StatelessWidget {
  const UnifiedAppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SelectionContainer.disabled(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF070A12) : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        ),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: 36),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                if (!isMobile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand with Logo & cursor
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed('/'),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Row(
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
                          ),
                        ),
                      ),

                      // Quick links with animated hover & cursor
                      Row(
                        children: [
                          AnimatedHoverFooterLink(title: "الكورسات", route: '/courses', isDark: isDark),
                          AnimatedHoverFooterLink(title: "المقالات", route: '/blog', isDark: isDark),
                          AnimatedHoverFooterLink(title: "من نحن", route: '/about', isDark: isDark),
                          AnimatedHoverFooterLink(title: "سياسة الاستخدام", route: '/privacy', isDark: isDark),
                          AnimatedHoverFooterLink(title: "تواصل معنا", route: '/contact', isDark: isDark),
                        ],
                      ),

                      // Social
                      const SocialIconsBar(
                        facebookUrl: ArabicData.facebookUrl,
                        youtubeUrl: ArabicData.youtubeUrl,
                        telegramUrl: ArabicData.telegramUrl,
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed('/'),
                          borderRadius: BorderRadius.circular(10),
                          child: Row(
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          AnimatedHoverFooterLink(title: "الكورسات", route: '/courses', isDark: isDark),
                          AnimatedHoverFooterLink(title: "المقالات", route: '/blog', isDark: isDark),
                          AnimatedHoverFooterLink(title: "من نحن", route: '/about', isDark: isDark),
                          AnimatedHoverFooterLink(title: "سياسة الاستخدام", route: '/privacy', isDark: isDark),
                          AnimatedHoverFooterLink(title: "تواصل معنا", route: '/contact', isDark: isDark),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SocialIconsBar(
                        facebookUrl: ArabicData.facebookUrl,
                        youtubeUrl: ArabicData.youtubeUrl,
                        telegramUrl: ArabicData.telegramUrl,
                      ),
                    ],
                  ),

                const SizedBox(height: 22),
                Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 14),

                Text(
                  "جميع الحقوق محفوظة © 2027 Eslam Atef | Code & AI",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Hover Footer Link with pointer cursor & smooth scale
// ---------------------------------------------------------------------------
class AnimatedHoverFooterLink extends StatefulWidget {
  final String title;
  final String route;
  final bool isDark;

  const AnimatedHoverFooterLink({
    super.key,
    required this.title,
    required this.route,
    required this.isDark,
  });

  @override
  State<AnimatedHoverFooterLink> createState() => _AnimatedHoverFooterLinkState();
}

class _AnimatedHoverFooterLinkState extends State<AnimatedHoverFooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.title,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
              color: _isHovered
                  ? const Color(0xFF00E5FF)
                  : (widget.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
            ),
          ),
        ),
      ),
    );
  }
}
