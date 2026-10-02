import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'youtube_platform/youtube_platform.dart' as yt_platform;

class YouTubeEmbeddedPlayer extends StatefulWidget {
  final String youtubeUrl;
  final double height;

  const YouTubeEmbeddedPlayer({
    super.key,
    required this.youtubeUrl,
    this.height = 360,
  });

  @override
  State<YouTubeEmbeddedPlayer> createState() => _YouTubeEmbeddedPlayerState();
}

class _YouTubeEmbeddedPlayerState extends State<YouTubeEmbeddedPlayer> {
  late String _viewId;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.youtubeUrl);
    _viewId = 'yt_player_${DateTime.now().millisecondsSinceEpoch}_${_videoId ?? 'video'}';

    if (kIsWeb && _videoId != null) {
      yt_platform.registerIframeViewFactory(_viewId, _videoId!);
    }
  }

  String? _extractVideoId(String url) {
    if (url.trim().isEmpty) return null;
    final trimmed = url.trim();

    // Direct ID (11 chars)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }

    // youtu.be/<id>
    final shortMatch = RegExp(r'youtu\.be\/([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (shortMatch != null) return shortMatch.group(1);

    // youtube.com/watch?v=<id>
    final watchMatch = RegExp(r'v=([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (watchMatch != null) return watchMatch.group(1);

    // youtube.com/embed/<id>
    final embedMatch = RegExp(r'embed\/([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
    if (embedMatch != null) return embedMatch.group(1);

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
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
        child: kIsWeb
            ? HtmlElementView(viewType: _viewId)
            : Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://img.youtube.com/vi/$_videoId/hqdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(color: Colors.black),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.black.withValues(alpha: 0.4)),
                  ),
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
                ],
              ),
      ),
    );
  }
}
