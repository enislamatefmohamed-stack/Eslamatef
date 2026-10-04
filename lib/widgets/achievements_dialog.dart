import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gamification_service.dart';

class AchievementsDialog extends StatelessWidget {
  const AchievementsDialog({super.key});

  static void show(BuildContext context) {
    GamificationService.instance.syncUserGamification();
    showDialog(
      context: context,
      builder: (ctx) => const Directionality(
        textDirection: TextDirection.rtl,
        child: AchievementsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService.instance;

    return AnimatedBuilder(
      animation: gamification,
      builder: (context, _) {
        final points = gamification.points;
        final earned = gamification.earnedBadges;
        final earnedIds = earned.map((b) => b['id']).toSet();
        final completedLessons = gamification.completedLessons.length;
        final completedCourses = gamification.completedCourses.length;

        // Level calculation
        String levelName = 'مبتدئ شغوف 🌱';
        double levelProgress = (points % 100) / 100.0;
        int nextLevelPoints = ((points ~/ 100) + 1) * 100;
        if (points >= 500) {
          levelName = 'خبير برمجيات 👑';
          levelProgress = 1.0;
        } else if (points >= 300) {
          levelName = 'مبرمج محترف 💻';
        } else if (points >= 150) {
          levelName = 'مطور متميز 🚀';
        } else if (points >= 50) {
          levelName = 'متعلم مجتهد 📚';
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 650,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("لوحة إنجازاتي وأوسمتي 🏆", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("رصيدك التعليمي والأوسمة المستحقة في المنصة", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Points & Level Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("نقاط التميز الإجمالية", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF94A3B8))),
                              Row(
                                children: [
                                  Text("$points", style: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFFF59E0B))),
                                  const SizedBox(width: 6),
                                  Text("نقطة", style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFFFDE68A))),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                            ),
                            child: Text(
                              levelName,
                              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFE0F2FE)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: levelProgress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("التقدم نحو المستوى التالي", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF94A3B8))),
                          Text("المستوى القادم عند: $nextLevelPoints نقطة", style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFFCBD5E1))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quick stats chips
                Row(
                  children: [
                    _buildStatChip("الدروس المنجزة", "$completedLessons", Icons.play_lesson_rounded, const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    _buildStatChip("الكورسات المكتملة", "$completedCourses", Icons.school_rounded, const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _buildStatChip("الأوسمة المحققة", "${earned.length}", Icons.military_tech_rounded, const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 18),

                // Badges title
                Text("الأوسمة والشارات التقديرية", style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Badges Grid
                Expanded(
                  child: GridView.builder(
                    itemCount: GamificationService.allAvailableBadges.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isMobile ? 3.2 : 2.5,
                    ),
                    itemBuilder: (context, idx) {
                      final badge = GamificationService.allAvailableBadges[idx];
                      final isUnlocked = earnedIds.contains(badge['id']);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUnlocked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                            width: isUnlocked ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUnlocked ? const Color(0xFF22C55E).withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isUnlocked ? (badge['icon'] as IconData) : Icons.lock_outline_rounded,
                                color: isUnlocked ? const Color(0xFF16A34A) : Colors.grey,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          badge['title'] as String,
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: isUnlocked ? const Color(0xFF14532D) : Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isUnlocked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(6)),
                                          child: Text("تم الفتح ✨", style: GoogleFonts.cairo(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    badge['description'] as String,
                                    style: GoogleFonts.cairo(fontSize: 11, color: isUnlocked ? const Color(0xFF166534) : Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
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
        );
      },
    );
  }

  Widget _buildStatChip(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(count, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            Text(title, style: GoogleFonts.cairo(fontSize: 10.5, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
