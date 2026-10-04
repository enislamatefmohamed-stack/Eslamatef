import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/site_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/safe_network_image/safe_network_image.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic>? itemData;

  const CheckoutPage({super.key, this.itemData});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _senderPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedMethod = 'InstaPay';
  bool _isSubmitting = false;

  final String instaPayNumber = '01100665674';
  final String vodafoneCashNumber = '01025173298';
  final String whatsappSupportNumber = '201025173298';

  @override
  void dispose() {
    _senderPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم نسخ رقم $label بنجاح ($text) 📋", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openWhatsAppConfirmation(String title, dynamic price) async {
    final user = AuthService.instance.currentUser;
    final email = user?.email ?? 'غير مسجل';
    final name = user?.displayName ?? 'طالب جديد';
    final priceStr = (price != null && price.toString().isNotEmpty && price.toString() != '0')
        ? '$price ج.م'
        : 'الاشتراك المطلوب';

    final message = "مرحباً يا بشمهندس إسلام 👋\n"
        "أرغب في تفعيل الاشتراك في: *$title*\n"
        "المبلغ المحول: *$priceStr*\n"
        "طريقة الدفع: *$_selectedMethod*\n"
        "اسم الطالب: *$name*\n"
        "البريد المسجل: *$email*\n"
        "مرفق إشعار / لقطة شاشة التحويل لتفعيل الكورس بحسابي فوراً.";

    final encoded = Uri.encodeComponent(message);
    final url = "https://wa.me/$whatsappSupportNumber?text=$encoded";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _submitInAppRequest(String courseId, String title, dynamic price) async {
    final phone = _senderPhoneCtrl.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يرجى إدخال رقم الهاتف المحول منه لتأكيد العملية", style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يرجى تسجيل الدخول أولاً لإرسال طلب الاشتراك", style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await SiteDataService.instance.submitPurchaseRequest(
        courseId: courseId,
        courseTitle: title,
        price: price,
        paymentMethod: _selectedMethod,
        senderPhone: phone,
        userId: user.uid,
        userEmail: user.email ?? '',
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
              const SizedBox(width: 8),
              Text("تم إرسال الطلب بنجاح! 🚀", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "تم استلام بيانات تحويلك بنجاح وسيقوم فريق العمل بمراجعة العملية وتفعيل الكورس في حسابك خلال دقائق.\nيمكنك أيضاً مراسلتنا مباشرة على واتساب للسرعة القصوى.",
            style: GoogleFonts.cairo(height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushReplacementNamed('/courses');
              },
              child: Text("العودة للكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _openWhatsAppConfirmation(title, price);
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text("تأكيد عبر واتساب الآن", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء إرسال الطلب: $e", style: GoogleFonts.cairo()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final item = widget.itemData ?? routeArgs ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    final title = item['title'] ?? 'كورس البرمجة والذكاء الاصطناعي';
    final desc = item['description'] ?? 'احصل على وصول كامل وشامل لكافة المحاضرات والتطبيقات والاختبارات التفاعلية.';
    final image = item['imageUrl'] ?? item['image'] ?? 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600';
    final price = item['price'] != null && item['price'].toString().isNotEmpty && item['price'].toString() != '0'
        ? item['price']
        : 250;
    final courseId = item['id']?.toString() ?? 'course_main';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      drawer: const UnifiedAppDrawer(currentRoute: '/courses'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const UnifiedAppHeader(
                currentRoute: '/courses',
                pageTitle: "شراء واشتراك في الكورس",
              ),
              const SizedBox(height: 24),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : Navigator.of(context).pushReplacementNamed('/courses'),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text("العودة للكورسات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card 1: Course Summary & Price
                      Container(
                        padding: EdgeInsets.all(isMobile ? 18 : 24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: isMobile ? 90 : 160,
                                height: isMobile ? 90 : 120,
                                child: SafeNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      "🔒 اشتراك مدفوع كامل",
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 17 : 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    desc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        "السعر المطلوب:",
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF0284C7), Color(0xFF00E5FF)],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "$price ج.م (EGP)",
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card 2: Payment Methods (InstaPay & Vodafone Cash)
                      Text(
                        "اختر طريقة الدفع المناسبة لك وحوّل المبلغ:",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Method 1: InstaPay Card
                      _buildPaymentMethodCard(
                        isDark: isDark,
                        isSelected: _selectedMethod == 'InstaPay',
                        onSelect: () => setState(() => _selectedMethod = 'InstaPay'),
                        brandName: "إنستا باي (InstaPay)",
                        badge: "تحويل لحظي مباشر",
                        badgeColor: const Color(0xFF8B5CF6),
                        icon: Icons.flash_on_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        number: instaPayNumber,
                        instructions: "افتح تطبيق إنستا باي أو تطبيق بنكك، واختر تحويل إلى رقم الهاتف المسجل.",
                      ),
                      const SizedBox(height: 14),

                      // Method 2: Vodafone Cash Card
                      _buildPaymentMethodCard(
                        isDark: isDark,
                        isSelected: _selectedMethod == 'VodafoneCash',
                        onSelect: () => setState(() => _selectedMethod = 'VodafoneCash'),
                        brandName: "فودافون كاش (Vodafone Cash)",
                        badge: "محفظة إلكترونية",
                        badgeColor: const Color(0xFFDC2626),
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: const Color(0xFFDC2626),
                        number: vodafoneCashNumber,
                        instructions: "حول من محفظتك بكود #9* أو عبر تطبيق أنا فودافون أو من أي فرع فودافون.",
                      ),
                      const SizedBox(height: 28),

                      // Fast Track WhatsApp Button
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                                : [const Color(0xFFECFDF5), Colors.white],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  "التفعيل الأسرع عبر واتساب ⚡",
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "بعد تحويل المبلغ، اضغط على الزر أدناه لإرسال لقطة شاشة التحويل وسيتم تفعيل حسابك فوراً:",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openWhatsAppConfirmation(title, price),
                              icon: const Icon(Icons.chat_rounded, size: 20),
                              label: Text(
                                "إرسال إشعار الدفع عبر واتساب (تفعيل فوري) 💬",
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // In-app Confirmation Form
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "أو قم بتأكيد بيانات التحويل هنا داخل الموقع:",
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _senderPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "رقم الهاتف المحول منه المبلغ *",
                                hintText: "مثال: 010xxxxxxxx",
                                prefixIcon: const Icon(Icons.phone_android_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesCtrl,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: "ملاحظات إضافية أو اسم صاحب الحساب (اختياري)",
                                hintText: "اكتب اسمك أو أي تفاصيل تخص التحويل...",
                                prefixIcon: const Icon(Icons.notes_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : () => _submitInAppRequest(courseId, title, price),
                                icon: _isSubmitting
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.send_rounded, size: 18),
                                label: Text(
                                  _isSubmitting ? "جاري الإرسال..." : "إرسال طلب التفعيل إلى الإدارة",
                                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

              const UnifiedAppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required bool isDark,
    required bool isSelected,
    required VoidCallback onSelect,
    required String brandName,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
    required String number,
    required String instructions,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brandName,
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        instructions,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accentColor : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // Number Box with Copy Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "رقم التحويل المباشر:",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        number,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(number, brandName),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text("نسخ الرقم", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
