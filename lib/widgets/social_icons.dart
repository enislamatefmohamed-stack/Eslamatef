import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchWebUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

// ---------------------------------------------------------------------------
// 1. Authentic YouTube Icon (Official Red Rounded Rectangle + White Play Arrow)
// ---------------------------------------------------------------------------
class YouTubeLogo extends StatelessWidget {
  final double size;
  const YouTubeLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.35,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000), // Official YouTube Red
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.45, size * 0.5),
          painter: _PlayTrianglePainter(),
        ),
      ),
    );
  }
}

class _PlayTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 2. Authentic Telegram Icon (Sky Blue Circle + White Paper Airplane)
// ---------------------------------------------------------------------------
class TelegramLogo extends StatelessWidget {
  final double size;
  const TelegramLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF229ED9), // Official Telegram Blue
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _PaperAirplanePainter(),
        ),
      ),
    );
  }
}

class _PaperAirplanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Official Telegram paper plane path
    final path = Path()
      ..moveTo(w * 0.95, h * 0.05)
      ..lineTo(w * 0.05, h * 0.45)
      ..lineTo(w * 0.38, h * 0.62)
      ..lineTo(w * 0.85, h * 0.22)
      ..lineTo(w * 0.48, h * 0.70)
      ..lineTo(w * 0.45, h * 0.95)
      ..lineTo(w * 0.65, h * 0.78)
      ..lineTo(w * 0.88, h * 0.92)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 3. Authentic WhatsApp Logo (Official Green + Speech Bubble with Phone Receiver)
// ---------------------------------------------------------------------------
class WhatsAppLogo extends StatelessWidget {
  final double size;
  final bool whiteOnly;
  const WhatsAppLogo({super.key, this.size = 24, this.whiteOnly = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _WhatsAppPainter(whiteOnly: whiteOnly),
      ),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final bool whiteOnly;
  _WhatsAppPainter({this.whiteOnly = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (!whiteOnly) {
      // Green Circle Base
      final bgPaint = Paint()
        ..color = const Color(0xFF25D366) // Official WhatsApp Green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);
    }

    // Speech bubble outline & tail
    final bubblePath = Path();
    final center = Offset(w * 0.5, h * 0.48);
    final radius = w * 0.38;

    bubblePath.addOval(Rect.fromCircle(center: center, radius: radius));
    // Tail pointing to bottom-left
    bubblePath.moveTo(w * 0.28, h * 0.72);
    bubblePath.lineTo(w * 0.16, h * 0.86);
    bubblePath.lineTo(w * 0.38, h * 0.80);
    bubblePath.close();

    if (!whiteOnly) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = w * 0.08
        ..style = PaintingStyle.stroke;
      canvas.drawPath(bubblePath, borderPaint);
    }

    // Phone Handset inside bubble
    final phonePaint = Paint()
      ..color = whiteOnly ? const Color(0xFF25D366) : Colors.white
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(w * 0.5, h * 0.48);
    canvas.rotate(-0.35); // Slight tilt

    // Draw stylized phone handset
    final phonePath = Path()
      ..moveTo(-w * 0.16, -w * 0.12)
      ..cubicTo(-w * 0.18, -w * 0.18, -w * 0.12, -w * 0.22, -w * 0.06, -w * 0.18)
      ..lineTo(-w * 0.01, -w * 0.08)
      ..cubicTo(w * 0.03, -w * 0.02, w * 0.01, w * 0.04, -w * 0.04, w * 0.08)
      ..cubicTo(w * 0.02, w * 0.14, w * 0.08, w * 0.20, w * 0.14, w * 0.24)
      ..cubicTo(w * 0.18, w * 0.19, w * 0.24, w * 0.17, w * 0.30, w * 0.21)
      ..lineTo(w * 0.38, w * 0.26)
      ..cubicTo(w * 0.42, w * 0.32, w * 0.38, w * 0.38, w * 0.32, w * 0.38)
      ..cubicTo(w * 0.18, w * 0.38, -w * 0.10, w * 0.15, -w * 0.16, -w * 0.12)
      ..close();

    canvas.drawPath(phonePath, phonePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 4. Authentic Facebook Icon (Blue Circle + White 'f')
// ---------------------------------------------------------------------------
class FacebookLogo extends StatelessWidget {
  final double size;
  const FacebookLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2), // Official Facebook Blue
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "f",
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.75,
            fontWeight: FontWeight.w900,
            fontFamily: "Arial",
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Authentic LinkedIn Icon (Blue Rounded Box + White 'in')
// ---------------------------------------------------------------------------
class LinkedInLogo extends StatelessWidget {
  final double size;
  const LinkedInLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2), // Official LinkedIn Blue
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          "in",
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.58,
            fontWeight: FontWeight.w800,
            fontFamily: "Arial",
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Social Button Wrapper with Hover
// ---------------------------------------------------------------------------
class SocialIconButton extends StatefulWidget {
  final String tooltip;
  final String url;
  final Widget iconWidget;

  const SocialIconButton({
    super.key,
    required this.tooltip,
    required this.url,
    required this.iconWidget,
  });

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => launchWebUrl(widget.url),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(7),
            transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: widget.iconWidget,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Social Icons Bar (Facebook, YouTube, Telegram, LinkedIn)
// ---------------------------------------------------------------------------
class SocialIconsBar extends StatelessWidget {
  final String facebookUrl;
  final String youtubeUrl;
  final String telegramUrl;
  final String linkedinUrl;
  final double iconSize;

  const SocialIconsBar({
    super.key,
    required this.facebookUrl,
    required this.youtubeUrl,
    required this.telegramUrl,
    required this.linkedinUrl,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Facebook
        SocialIconButton(
          tooltip: "فيسبوك",
          url: facebookUrl,
          iconWidget: FacebookLogo(size: iconSize),
        ),
        const SizedBox(width: 8),

        // 2. YouTube
        SocialIconButton(
          tooltip: "يوتيوب",
          url: youtubeUrl,
          iconWidget: YouTubeLogo(size: iconSize),
        ),
        const SizedBox(width: 8),

        // 3. Telegram
        SocialIconButton(
          tooltip: "تليجرام",
          url: telegramUrl,
          iconWidget: TelegramLogo(size: iconSize),
        ),
        const SizedBox(width: 8),

        // 4. LinkedIn
        SocialIconButton(
          tooltip: "لينكد إن",
          url: linkedinUrl,
          iconWidget: LinkedInLogo(size: iconSize),
        ),
      ],
    );
  }
}
