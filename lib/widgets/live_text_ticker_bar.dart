import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveTextTickerBar extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final bool isDark;

  const LiveTextTickerBar({
    super.key,
    required this.items,
    required this.isDark,
  });

  @override
  State<LiveTextTickerBar> createState() => _LiveTextTickerBarState();
}

class _LiveTextTickerBarState extends State<LiveTextTickerBar> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_isPaused || !_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= maxExtent) {
        _scrollController.jumpTo(0.0);
      } else {
        _scrollController.jumpTo(current + 1.2);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Row(
            children: [
              // 1. Fixed "جديدنا" Badge on the right (RTL start)
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "جديدنا ✨",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Animated Moving Text Stream
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isPaused = true),
                  onExit: (_) => setState(() => _isPaused = false),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (widget.items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            "مرحباً بكم في منصة Eslam Atef | Code & AI — استكشف أحدث الكورسات والدروس والمسابقات التفاعلية المتاحة الآن!",
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                            ),
                          ),
                        );
                      }

                      final item = widget.items[index % widget.items.length];
                      final title = item['title'] ?? '';
                      final badge = item['badge'] ?? 'جديد';
                      final route = item['route'] ?? '/courses';

                      return InkWell(
                        onTap: () => Navigator.pushNamed(context, route),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  badge,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                title,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Text(
                                "•",
                                style: TextStyle(
                                  color: isDark ? Colors.white24 : Colors.black26,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
