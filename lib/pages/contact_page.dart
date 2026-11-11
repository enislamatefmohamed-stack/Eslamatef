import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedInquiryType = "استفسار عن كورس البرمجة والذكاء الاصطناعي للأطفال";
  final List<String> _inquiryTypes = [
    "استفسار عن كورس البرمجة والذكاء الاصطناعي للأطفال",
    "استفسار عن كورس الخوارزميات وحل المشكلات",
    "استفسار عن كورس سكراتش وتطوير الألعاب",
    "استفسار عن كورس بايثون لليافعين",
    "طلب تدريب خاص أو جلسة استشارية فردية",
    "دعم فني أو مشكلة في الحساب",
    "أخرى",
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();
    final type = _selectedInquiryType;

    try {
      // Save inquiry to Firestore
      await FirebaseFirestore.instance.collection('contacts').add({
        'name': name,
        'phone': phone,
        'email': email,
        'inquiryType': type,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'جديد',
      });

      if (!mounted) return;

      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _messageController.clear();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
              const SizedBox(width: 10),
              Text("تم استلام رسالتك بنجاح! 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            "شكراً لتواصلك معنا يا $name. تم تسجيل رسالتك بنجاح، وسيتواصل معك م. إسلام عاطف أو فريق العمل في أقرب وقت عبر واتساب.",
            style: GoogleFonts.cairo(fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("حسناً", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                final encoded = Uri.encodeComponent("مرحباً أستاذ إسلام، أنا $name، أرسلت استفساراً بخصوص ($type):\n$message");
                _launchUrl("https://wa.me/201100665674?text=$encoded");
              },
              icon: const Icon(Icons.chat_rounded, size: 16),
              label: Text("المتابعة على واتساب فوراً", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Fallback: direct WhatsApp
      final encoded = Uri.encodeComponent("مرحباً أستاذ إسلام، أنا $name:\n$message");
      _launchUrl("https://wa.me/201100665674?text=$encoded");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/contact') : null,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                UnifiedAppHeader(
                  currentRoute: '/contact',
                  pageTitle: 'تواصل معنا — دعم واستفسارات',
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
                        const SizedBox(height: 32),
                        _buildContactContent(context, isMobile, isDark),
                        const SizedBox(height: 60),
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

  Widget _buildContactContent(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero Header
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 8),
                  Text(
                    "قنوات التواصل والدعم الفني المباشر",
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          Center(
            child: Text(
              "يسعدنا تواصلك دائماً.. نحن هنا للإجابة على كافة تساؤلاتك",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 22 : 32,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                "سواء كنت ولي أمر ترغب في تسجيل طفلك، أو طالباً تسأل عن محتوى دورة، تواصل معنا بأسرع وسيلة تفضلها وسنكون سعداء بمساعدتك فوراً.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 13.5 : 15,
                  height: 1.7,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(height: 38),

          // 2. Two-Column Layout (Quick Channels on Right, Form on Left)
          if (!isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right Column (Direct Channels - 45% width)
                Expanded(
                  flex: 45,
                  child: _buildQuickChannels(isDark),
                ),
                const SizedBox(width: 28),

                // Left Column (Inquiry Form - 55% width)
                Expanded(
                  flex: 55,
                  child: _buildContactFormCard(isDark),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuickChannels(isDark),
                const SizedBox(height: 28),
                _buildContactFormCard(isDark),
              ],
            ),
        ],
      ),
    );
  }

  // --- Quick Direct Channels (Right Side) ---
  Widget _buildQuickChannels(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // WhatsApp Card (Most Popular)
        _buildChannelCard(
          icon: Icons.chat_rounded,
          iconColor: const Color(0xFF25D366),
          title: "محادثة واتساب سريعة ومباشرة",
          desc: "الرد المباشر مع م. إسلام عاطف وفريق الأكاديمية للاستفسارات العاجلة.",
          btnLabel: "تواصل عبر واتساب الآن 💬",
          btnColor: const Color(0xFF25D366),
          isDark: isDark,
          onTap: () => _launchUrl("https://wa.me/201100665674"),
        ),
        const SizedBox(height: 18),

        // Telegram Channel Card
        _buildChannelCard(
          icon: Icons.send_rounded,
          iconColor: const Color(0xFF0088CC),
          title: "قناة ومجتمع الأكاديمية على تيليجرام",
          desc: "انضم لمتابعة جديد الكورسات، الشروحات المجانية، وروابط المحاضرات.",
          btnLabel: "الانضمام لقناة تيليجرام 📢",
          btnColor: const Color(0xFF0088CC),
          isDark: isDark,
          onTap: () => _launchUrl("https://t.me/EslamAtefOfficial"),
        ),
        const SizedBox(height: 18),

        // Email & Response Guarantee Card
        _buildChannelCard(
          icon: Icons.mark_email_read_rounded,
          iconColor: const Color(0xFF00E5FF),
          title: "البريد الإلكتروني الرسمي",
          desc: "للمراسلات الرسمية والشراكات: islamatef01016834012@gmail.com",
          btnLabel: "إرسال بريد إلكتروني ✉️",
          btnColor: const Color(0xFF0284C7),
          isDark: isDark,
          onTap: () => _launchUrl("mailto:islamatef01016834012@gmail.com"),
        ),
        const SizedBox(height: 18),

        // Response Time Guarantee Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "نضمن الرد على جميع الاستفسارات والرسائل في أقل من ساعتين خلال أوقات العمل.",
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required String btnLabel,
    required Color btnColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.cairo(
              fontSize: 13,
              height: 1.6,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(btnLabel, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Fast Inquiry Form Card (Left Side) ---
  Widget _buildContactFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Color(0xFF00E5FF), size: 26),
                const SizedBox(width: 10),
                Text(
                  "أرسل استفسارك أو طلبك مباشرة",
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "املأ البيانات وسيقوم فريق الأكاديمية بمتابعة طلبك والرد فوراً.",
              style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 22),

            // 1. Full Name
            _buildTextField(
              controller: _nameController,
              label: "الاسم بالكامل (أو اسم ولي الأمر)",
              hint: "مثال: أحمد عبد الله",
              icon: Icons.person_outline_rounded,
              isDark: isDark,
              validator: (v) => (v == null || v.trim().isEmpty) ? "يرجى كتابة الاسم" : null,
            ),
            const SizedBox(height: 16),

            // 2. Phone / WhatsApp
            _buildTextField(
              controller: _phoneController,
              label: "رقم الهاتف / واتساب",
              hint: "مثال: 01012345678",
              icon: Icons.phone_android_rounded,
              isDark: isDark,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? "يرجى كتابة رقم الهاتف أو واتساب" : null,
            ),
            const SizedBox(height: 16),

            // 3. Email (Optional)
            _buildTextField(
              controller: _emailController,
              label: "البريد الإلكتروني (اختياري)",
              hint: "example@gmail.com",
              icon: Icons.alternate_email_rounded,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 4. Inquiry Type Dropdown
            Text(
              "نوع الاستفسار أو الدورة",
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedInquiryType,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF131D31) : Colors.white,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  items: _inquiryTypes.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: GoogleFonts.cairo(fontSize: 13), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedInquiryType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Message
            _buildTextField(
              controller: _messageController,
              label: "نص الرسالة أو الاستفسار بالتفصيل",
              hint: "اكتب رسالتك أو أسئلتك هنا...",
              icon: Icons.chat_outlined,
              isDark: isDark,
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty) ? "يرجى كتابة رسالتك" : null,
            ),
            const SizedBox(height: 24),

            // 6. Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF070B14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF070B14)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "إرسال الرسالة الآن 🚀",
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF00E5FF)),
            filled: true,
            fillColor: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
