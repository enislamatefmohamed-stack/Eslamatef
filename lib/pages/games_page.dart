// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/embedded_iframe/embedded_iframe.dart';

class GameCategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const GameCategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

const List<GameCategoryItem> _gameCategories = [
  GameCategoryItem(
    id: 'all',
    name: 'الكل',
    icon: Icons.apps_rounded,
    color: Color(0xFF0284C7),
    description: 'جميع الألعاب التعليمية وثلاثية الأبعاد',
  ),
  GameCategoryItem(
    id: 'memory',
    name: 'الذاكرة',
    icon: Icons.psychology_rounded,
    color: Color(0xFF8B5CF6),
    description: 'ألعاب تقوية وتنشيط الذاكرة البصرية والتسلسلية',
  ),
  GameCategoryItem(
    id: 'logic',
    name: 'المنطق',
    icon: Icons.extension_rounded,
    color: Color(0xFF06B6D4),
    description: 'ألغاز برمجية وتحديات التفكير الاستنتاجي',
  ),
  GameCategoryItem(
    id: 'math',
    name: 'الرياضيات',
    icon: Icons.calculate_rounded,
    color: Color(0xFF10B981),
    description: 'حسابات رياضية سريعة وممتعة بطريقة تفاعلية',
  ),
  GameCategoryItem(
    id: 'shape',
    name: 'الأشكال',
    icon: Icons.category_rounded,
    color: Color(0xFFF59E0B),
    description: 'تميز الأشكال الهندسية والأنماط ثلاثية الأبعاد',
  ),
  GameCategoryItem(
    id: 'focus',
    name: 'التركيز',
    icon: Icons.center_focus_strong_rounded,
    color: Color(0xFFEC4899),
    description: 'ألعاب سرعة البديهة والتركيز البصري العالي',
  ),
  GameCategoryItem(
    id: 'word',
    name: 'الكلمات',
    icon: Icons.spellcheck_rounded,
    color: Color(0xFF6366F1),
    description: 'تكوين الكلمات اللغوية وحل الألغاز النصية',
  ),
  GameCategoryItem(
    id: 'create',
    name: 'الإبداع',
    icon: Icons.palette_rounded,
    color: Color(0xFFF97316),
    description: 'ألعاب التفكير الابتكاري والتشكيل الإبداعي',
  ),
  GameCategoryItem(
    id: 'brain',
    name: 'الذكاء',
    icon: Icons.smart_toy_rounded,
    color: Color(0xFF14B8A6),
    description: 'تحديات ذكاء متقدمة تجمع بين كل المهارات',
  ),
];

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String _selectedCategory = 'all';
  String _gameUrl = '/games/index.html';

  void _onCategorySelected(String catId) {
    setState(() {
      _selectedCategory = catId;
      if (catId == 'all') {
        _gameUrl = '/games/index.html';
      } else {
        _gameUrl = '/games/index.html?cat=$catId';
      }
    });
  }

  void _openFullscreen() {
    if (kIsWeb) {
      html.window.open(_gameUrl, '_blank');
    }
  }

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
                  pageTitle: 'الألعاب — ألعاب برمجية وذكاء تفاعلية',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 48,
                            vertical: isMobile ? 32 : 44,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: isDark
                                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                                  : [const Color(0xFFEFF6FF), const Color(0xFFE0F2FE)],
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF00E5FF).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.sports_esports_rounded, size: 16, color: Color(0xFF0284C7)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "ألعاب ذكاء 3D · من عمر 5 حتى 12 سنة وما فوق",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "مكتبة الألعاب التفاعلية ثلاثية الأبعاد",
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 26 : 38,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "العب مباشرة داخل متصفحك مجاناً! ألعاب صُممت بعناية لتنمية الذكاء، المنطق البرمجي، والتفكير السريع",
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 14 : 16,
                                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),

                                  // Category chips
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: _gameCategories.map((cat) {
                                      final isSelected = _selectedCategory == cat.id;
                                      return ChoiceChip(
                                        avatar: Icon(
                                          cat.icon,
                                          size: 16,
                                          color: isSelected ? Colors.white : cat.color,
                                        ),
                                        label: Text(cat.name),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _onCategorySelected(cat.id);
                                          }
                                        },
                                        labelStyle: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                                        ),
                                        selectedColor: const Color(0xFF0284C7),
                                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isSelected
                                                ? const Color(0xFF0284C7)
                                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                          ),
                                        ),
                                        showCheckmark: false,
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 20),

                                  // Action Bar: Fullscreen
                                  ElevatedButton.icon(
                                    onPressed: _openFullscreen,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0284C7),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.fullscreen_rounded, size: 20),
                                    label: Text(
                                      "تشغيل اللعبة بملء الشاشة",
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Embedded Game Player Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 36,
                            vertical: isMobile ? 20 : 36,
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1100),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Game Player Toolbar
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "منصة الألعاب المباشرة",
                                              style: GoogleFonts.cairo(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          tooltip: "إعادة تحميل",
                                          icon: const Icon(Icons.refresh_rounded, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              _gameUrl = '/games/index.html?t=${DateTime.now().millisecondsSinceEpoch}';
                                            });
                                          },
                                        ),
                                        IconButton(
                                          tooltip: "تكبير الشاشة في نافذة جديدة",
                                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                                          onPressed: _openFullscreen,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Embedded Frame
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                                    child: EmbeddedIframe(
                                      key: ValueKey(_gameUrl),
                                      src: _gameUrl,
                                      id: 'game_library',
                                      height: isMobile ? 620 : 760,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Unified Footer
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
