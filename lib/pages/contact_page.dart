import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../data/arabic_data.dart';
import '../widgets/unified_app_bar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedInquiryType = "استفسار عن الكورسات والتدريب";
  final List<String> _inquiryTypes = [
    "استفسار عن الكورسات والتدريب",
    "استشارة برمجية أو ذكاء اصطناعي",
    "سؤال تقني حول أحد الدروس",
    "طلب تدريب خاص أو كودنج كوتشينج",
    "اقتراح أو تعاون تقني",
    "أخرى",
  ];

  final List<PlatformFile> _attachedFiles = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isNotEmpty) {
        setState(() {
          _attachedFiles.addAll(files);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'حدث خطأ أثناء تحديد الملفات: $e',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? extension) {
    final ext = (extension ?? '').toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'svg'].contains(ext)) {
      return Icons.image_rounded;
    } else if (['pdf'].contains(ext)) {
      return Icons.picture_as_pdf_rounded;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return Icons.folder_zip_rounded;
    } else if (['dart', 'py', 'js', 'ts', 'html', 'css', 'cpp', 'java'].contains(ext)) {
      return Icons.code_rounded;
    } else if (['doc', 'docx', 'txt'].contains(ext)) {
      return Icons.description_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    final fileNames = _attachedFiles.map((f) => "${f.name} (${_formatFileSize(f.lengthSync() ?? 0)})").join(", ");

    try {
      // 1. Submit via FormSubmit AJAX directly to en.islam.atef.mohamed@gmail.com
      final url = Uri.parse("https://formsubmit.co/ajax/en.islam.atef.mohamed@gmail.com");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'الاسم': name,
          'البريد_الإلكتروني': email,
          'رقم_الهاتف_الواتساب': phone.isNotEmpty ? phone : "غير محدد",
          'نوع_الاستفسار': _selectedInquiryType,
          'الرسالة': message,
          'الملفات_المرفقة': _attachedFiles.isNotEmpty ? fileNames : "لا توجد مرفقات",
          '_subject': "رسالة تواصل جديدة من الموقع: $name - $_selectedInquiryType",
          '_template': "table",
        }),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSuccessDialog();
      } else {
        // Fallback to mailto if API error
        _launchMailtoFallback(name, email, phone, message, fileNames);
      }
    } catch (_) {
      if (!mounted) return;
      // Network or CORS issue: fallback directly to mailto
      _launchMailtoFallback(name, email, phone, message, fileNames);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _launchMailtoFallback(String name, String email, String phone, String message, String fileNames) async {
    final subject = Uri.encodeComponent("رسالة تواصل من: $name - $_selectedInquiryType");
    final body = Uri.encodeComponent(
      "الاسم: $name\n"
      "البريد الإلكتروني: $email\n"
      "الهاتف: $phone\n"
      "نوع الاستفسار: $_selectedInquiryType\n\n"
      "الرسالة:\n$message\n\n"
      "المرفقات المختارة: ${fileNames.isNotEmpty ? fileNames : 'لا توجد'}",
    );

    final mailtoUri = Uri.parse("mailto:en.islam.atef.mohamed@gmail.com?subject=$subject&body=$body");

    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri);
    }

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    // Reset Form
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();
    setState(() {
      _attachedFiles.clear();
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
          contentPadding: const EdgeInsets.all(28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF), size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                "تم إرسال رسالتك بنجاح!",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "شكراً لتواصلك معنا. تم إرسال رسالتك مباشرة إلى البريد الإلكتروني:\nen.islam.atef.mohamed@gmail.com\nوسيقوم Eslam Atef بالرد عليك في أقرب وقت.",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  "حسناً، شكراً لك",
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/contact') : null,
        body: SafeArea(
          child: Column(
            children: [
              const UnifiedAppHeader(
                currentRoute: '/contact',
                pageTitle: 'تواصل معنا — يسعدنا استقبال رسائلك',
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      _buildContactHero(isMobile, isDark),
                      const SizedBox(height: 32),
                      _buildContentContainer(isMobile, screenWidth, isDark),
                      const SizedBox(height: 48),
                      const UnifiedAppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // -------------------------------------------------------------
  // Hero Banner
  // -------------------------------------------------------------
  Widget _buildContactHero(bool isMobile, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mail_rounded, color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 8),
                Text(
                  "قنوات التواصل الرسمية",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "تواصل معنا الآن",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "يسعدنا استقبال استفساراتك حول الكورسات البرمجية، التدريب الخاص، أو أي استشارة تقنية في هندسة البرمجيات والذكاء الاصطناعي. املأ النموذج أدناه وستصل رسالتك مباشرة إلى Eslam Atef.",
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 14 : 16,
              color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Main Content: Form + Quick Info Cards
  // -------------------------------------------------------------
  Widget _buildContentContainer(bool isMobile, double screenWidth, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          // Quick Contact Info Row
          _buildQuickInfoCards(isMobile, isDark),
          const SizedBox(height: 36),

          // The Contact Form Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppColors.borderLightDark : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 36),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send_rounded, color: Color(0xFF00E5FF), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "نموذج المراسلة المباشر",
                              style: GoogleFonts.cairo(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              "تصل الرسالة فوراً إلى: en.islam.atef.mohamed@gmail.com",
                              style: GoogleFonts.cairo(
                                fontSize: isMobile ? 12 : 13,
                                color: const Color(0xFF00E5FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Fields: Name & Email
                  if (!isMobile)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildNameField(isDark)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEmailField(isDark)),
                      ],
                    )
                  else ...[
                    _buildNameField(isDark),
                    const SizedBox(height: 18),
                    _buildEmailField(isDark),
                  ],

                  const SizedBox(height: 18),

                  // Fields: Phone & Inquiry Type
                  if (!isMobile)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPhoneField(isDark)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildInquiryTypeField(isDark)),
                      ],
                    )
                  else ...[
                    _buildPhoneField(isDark),
                    const SizedBox(height: 18),
                    _buildInquiryTypeField(isDark),
                  ],

                  const SizedBox(height: 18),

                  // Message Field
                  _buildMessageField(isDark),

                  const SizedBox(height: 24),

                  // File & Image Attachments Section
                  _buildAttachmentsSection(isMobile, isDark),

                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Quick Contact Info Cards
  // -------------------------------------------------------------
  Widget _buildQuickInfoCards(bool isMobile, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = constraints.maxWidth > 700;

        final cards = [
          _infoCard(
            icon: Icons.alternate_email_rounded,
            title: "البريد الإلكتروني المباشر",
            value: "en.islam.atef.mohamed@gmail.com",
            actionText: "مراسلة عبر الإيميل",
            iconColor: const Color(0xFF00E5FF),
            isDark: isDark,
            onTap: () => launchUrl(Uri.parse("mailto:en.islam.atef.mohamed@gmail.com")),
          ),
          _infoCard(
            icon: Icons.chat_rounded,
            title: "واتساب وهاتف التواصل",
            value: "01100665674",
            actionText: "محادثة فورية",
            iconColor: const Color(0xFF25D366),
            isDark: isDark,
            onTap: () => launchUrl(Uri.parse(ArabicData.whatsappUrl)),
          ),
          _infoCard(
            icon: Icons.send_rounded,
            title: "قناة التليجرام",
            value: "@EslamAtefAI",
            actionText: "انضم للقناة",
            iconColor: const Color(0xFF229ED9),
            isDark: isDark,
            onTap: () => launchUrl(Uri.parse(ArabicData.telegramUrl)),
          ),
        ];

        if (useGrid) {
          return Row(
            children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList(),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 14), child: c)).toList(),
          );
        }
      },
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required String actionText,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderLightDark : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_back_rounded, size: 14, color: iconColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Form Field Widgets
  // -------------------------------------------------------------
  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("الاسم بالكامل", isDark: isDark, isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A), fontSize: 14),
          decoration: _inputDecoration(
            hint: "مثال: أحمد محمود",
            prefixIcon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "يرجى كتابة الاسم";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("البريد الإلكتروني", isDark: isDark, isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A), fontSize: 14),
          decoration: _inputDecoration(
            hint: "example@gmail.com",
            prefixIcon: Icons.alternate_email_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "يرجى كتابة البريد الإلكتروني";
            }
            if (!val.contains('@') || !val.contains('.')) {
              return "يرجى إدخال بريد إلكتروني صحيح";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("رقم الهاتف أو الواتساب", isDark: isDark, isRequired: false),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A), fontSize: 14),
          decoration: _inputDecoration(
            hint: "010xxxxxxxx أو مع كود الدولة",
            prefixIcon: Icons.phone_outlined,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInquiryTypeField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("موضوع الاستفسار", isDark: isDark, isRequired: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderLightDark : const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedInquiryType,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryLight),
              style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A), fontSize: 14),
              items: _inquiryTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedInquiryType = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("تفاصيل الرسالة أو الاستفسار", isDark: isDark, isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 5,
          style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A), fontSize: 14),
          decoration: _inputDecoration(
            hint: "اكتب جميع تفاصيل استفسارك أو هدفك التعليمي أو المشروع البرمجي هنا...",
            prefixIcon: Icons.message_outlined,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "يرجى كتابة نص الرسالة";
            }
            if (val.trim().length < 10) {
              return "يرجى كتابة تفاصيل كافية (10 أحرف على الأقل)";
            }
            return null;
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // File and Image Attachments Section
  // -------------------------------------------------------------
  Widget _buildAttachmentsSection(bool isMobile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _attachedFiles.isNotEmpty
              ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
          style: BorderStyle.solid,
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
                  const Icon(Icons.attach_file_rounded, color: Color(0xFF00E5FF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "إرفاق ملفات أو صور (اختياري)",
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFF00E5FF),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _pickFiles,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                label: Text(
                  "اختيار ملفات",
                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "يمكنك إرفاق سكرين شوت، أكواد برمجية، ملفات PDF، أو أي مستندات تدعم استفسارك.",
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
            ),
          ),

          if (_attachedFiles.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_attachedFiles.length, (index) {
                final file = _attachedFiles[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF00E5FF).withValues(alpha: 0.3) : const Color(0xFFBAE6FD),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getFileIcon(file.extension), size: 18, color: const Color(0xFF00E5FF)),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          file.name,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(${_formatFileSize(file.lengthSync() ?? 0)})",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _removeFile(index),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Submit Button
  // -------------------------------------------------------------
  Widget _buildSubmitButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 8,
          shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
        ),
        onPressed: _isSubmitting ? null : _submitForm,
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "جاري إرسال الرسالة إلى Eslam Atef...",
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    "إرسال الرسالة الآن",
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _fieldLabel(String label, {required bool isDark, required bool isRequired}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData prefixIcon, required bool isDark}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: AppColors.primaryLight, size: 20),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderLightDark : const Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderLightDark : const Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

}

