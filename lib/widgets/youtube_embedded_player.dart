import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'youtube_platform/youtube_platform.dart' as yt_platform;

class YouTubeEmbeddedPlayer extends StatefulWidget {
  final String youtubeUrl;
  final double height;
  final bool showWatermark;
  final String? watermarkText;

  const YouTubeEmbeddedPlayer({
    super.key,
    required this.youtubeUrl,
    this.height = 360,
    this.showWatermark = false,
    this.watermarkText,
  });

  @override
  State<YouTubeEmbeddedPlayer> createState() => _YouTubeEmbeddedPlayerState();
}

class _YouTubeEmbeddedPlayerState extends State<YouTubeEmbeddedPlayer> {
  late String _viewId;
  String? _videoId;
  int _watermarkPosition = 0; // 0: top-right, 1: bottom-left, 2: top-left, 3: bottom-right
  Timer? _watermarkTimer;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.youtubeUrl);
    _viewId = 'yt_player_${DateTime.now().millisecondsSinceEpoch}_${_videoId ?? 'video'}';

    if (kIsWeb && _videoId != null) {
      yt_platform.registerIframeViewFactory(_viewId, _videoId!);
    }

    _initWatermarkTimer();
  }

  void _initWatermarkTimer() {
    _watermarkTimer?.cancel();
    if (widget.showWatermark && (widget.watermarkText?.isNotEmpty ?? false)) {
      _watermarkTimer = Timer.periodic(const Duration(seconds: 25), (t) {
        if (mounted) {
          setState(() {
            _watermarkPosition = (_watermarkPosition + 1) % 4;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(YouTubeEmbeddedPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showWatermark != widget.showWatermark || oldWidget.watermarkText != widget.watermarkText) {
      _initWatermarkTimer();
    }
    if (oldWidget.youtubeUrl != widget.youtubeUrl) {
      _videoId = _extractVideoId(widget.youtubeUrl);
      _viewId = 'yt_player_${DateTime.now().millisecondsSinceEpoch}_${_videoId ?? 'video'}';
      if (kIsWeb && _videoId != null) {
        yt_platform.registerIframeViewFactory(_viewId, _videoId!);
      }
      setState(() {});
    }
  }

  String? _extractVideoId(String url) {
    if (url.trim().isEmpty) return null;
    final trimmed = url.trim();

    // 1. If iframe tag pasted: extract src
    final iframeSrcMatch = RegExp('src=["\']([^"\']+)["\']').firstMatch(trimmed);
    final targetUrl = iframeSrcMatch != null ? iframeSrcMatch.group(1)! : trimmed;

    // Direct ID (11 chars)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(targetUrl)) {
      return targetUrl;
    }

    // youtu.be/<id>
    final shortMatch = RegExp(r'youtu\.be\/([a-zA-Z0-9_-]{11})').firstMatch(targetUrl);
    if (shortMatch != null) return shortMatch.group(1);

    // youtube.com/watch?v=<id> or &v=<id>
    final watchMatch = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(targetUrl);
    if (watchMatch != null) return watchMatch.group(1);

    // youtube.com/embed/<id>
    final embedMatch = RegExp(r'embed\/([a-zA-Z0-9_-]{11})').firstMatch(targetUrl);
    if (embedMatch != null) return embedMatch.group(1);

    // youtube.com/shorts/<id>
    final shortsMatch = RegExp(r'shorts\/([a-zA-Z0-9_-]{11})').firstMatch(targetUrl);
    if (shortsMatch != null) return shortsMatch.group(1);

    // youtube.com/live/<id>
    final liveMatch = RegExp(r'live\/([a-zA-Z0-9_-]{11})').firstMatch(targetUrl);
    if (liveMatch != null) return liveMatch.group(1);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_library_outlined, color: Colors.grey, size: 24),
              const SizedBox(width: 10),
              Text(
                "لم يتم إرفاق رابط يوتيوب لهذا الدرس بعد",
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : (screenWidth - 32);
        final effectiveHeight = isMobile
            ? (availableWidth * (9 / 16)).clamp(180.0, 520.0)
            : widget.height;

        return SizedBox(
          width: availableWidth,
          height: effectiveHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: kIsWeb
                        ? HtmlElementView(viewType: _viewId)
                        : Image.network(
                            'https://img.youtube.com/vi/$_videoId/hqdefault.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(color: Colors.black),
                          ),
                  ),
                  if (!kIsWeb)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(widget.youtubeUrl), mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
                        label: Text("مشاهدة الفيديو على يوتيوب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  if (widget.showWatermark && (widget.watermarkText?.isNotEmpty ?? false))
                    _buildWatermarkOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatermarkOverlay() {
    Alignment align;
    switch (_watermarkPosition) {
      case 0:
        align = Alignment.topRight;
        break;
      case 1:
        align = Alignment.bottomLeft;
        break;
      case 2:
        align = Alignment.topLeft;
        break;
      case 3:
      default:
        align = Alignment.bottomRight;
        break;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedAlign(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          alignment: align,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 12, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 5),
                  Text(
                    widget.watermarkText!,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
