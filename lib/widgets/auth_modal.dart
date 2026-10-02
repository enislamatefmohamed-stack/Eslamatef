// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

enum AuthModalMode { login, register, forgotPassword }

class AuthModal extends StatefulWidget {
  final AuthModalMode initialMode;

  const AuthModal({
    super.key,
    this.initialMode = AuthModalMode.login,
  });

  static Future<void> show(BuildContext context, {AuthModalMode mode = AuthModalMode.login}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AuthModal(initialMode: mode),
    );
  }

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  final _authService = AuthService.instance;

  late AuthModalMode _mode;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String _selectedCountry = 'مصر';

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<String> _countries = [
    'مصر', 'السعودية', 'الإمارات', 'الكويت', 'قطر', 'الأردن',
    'العراق', 'عمان', 'البحرين', 'تونس', 'الجزائر', 'المغرب',
    'فلسطين', 'سوريا', 'لبنان', 'ليبيا', 'السودان', 'اليمن', 'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("مرحباً بك! تم تسجيل الدخول بنجاح بحساب Google 🎉", style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Handle Email Submit
  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = "يرجى كتابة البريد الإلكتروني");
      return;
    }

    if (_mode == AuthModalMode.forgotPassword) {
      setState(() => _isLoading = true);
      try {
        await _authService.sendPasswordResetEmail(email);
        setState(() {
          _successMessage = "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح.";
        });
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
      return;
    }

    final password = _passwordCtrl.text;
    if (password.length < 6) {
      setState(() => _errorMessage = "كلمة المرور يجب أن لا تقل عن 6 أحرف أو أرقام");
      return;
    }

    if (_mode == AuthModalMode.register) {
      if (_nameCtrl.text.trim().isEmpty) {
        setState(() => _errorMessage = "يرجى كتابة الاسم بالكامل");
        return;
      }
      if (password != _confirmPasswordCtrl.text) {
        setState(() => _errorMessage = "كلمتا المرور غير متطابقتين");
        return;
      }

      setState(() => _isLoading = true);
      try {
        await _authService.signUpWithEmailAndPassword(
          name: _nameCtrl.text.trim(),
          email: email,
          password: password,
          phone: _phoneCtrl.text.trim(),
          whatsapp: _whatsappCtrl.text.trim(),
          country: _selectedCountry,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم إنشاء حسابك بنجاح! تم إرسال رابط تأكيد إلى بريدك.", style: GoogleFonts.cairo()),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Login
      setState(() => _isLoading = true);
      try {
        await _authService.signInWithEmailAndPassword(email: email, password: password);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("أهلاً بك مجدداً! تم تسجيل الدخول بنجاح.", style: GoogleFonts.cairo()),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: isMobile ? double.infinity : 480,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Icon + Title + Close)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock_person_rounded, color: Color(0xFF0284C7), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mode == AuthModalMode.login
                                  ? "تسجيل الدخول"
                                  : (_mode == AuthModalMode.register ? "إنشاء حساب جديد" : "استعادة كلمة المرور"),
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              "منصة Eslam Atef | Code & AI",
                              style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Error / Success message box
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!, style: GoogleFonts.cairo(color: const Color(0xFF991B1B), fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                if (_successMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_successMessage!, style: GoogleFonts.cairo(color: const Color(0xFF166534), fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                // Google Sign In Button (For login & register)
                if (_mode != AuthModalMode.forgotPassword) ...[
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google G Icon
                        Image.network(
                          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                          width: 20,
                          height: 20,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "المتابعة باستخدام حساب Google",
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("أو عبر البريد الإلكتروني", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],

                // Form Fields
                if (_mode == AuthModalMode.register) ...[
                  _buildInputField("الاسم بالكامل *", _nameCtrl, Icons.person_outline, isDark),
                  Row(
                    children: [
                      Expanded(child: _buildInputField("رقم الهاتف", _phoneCtrl, Icons.phone_outlined, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInputField("رقم واتساب", _whatsappCtrl, Icons.chat_bubble_outline, isDark)),
                    ],
                  ),
                  _buildCountryPicker(isDark),
                ],

                _buildInputField("البريد الإلكتروني *", _emailCtrl, Icons.email_outlined, isDark, keyboardType: TextInputType.emailAddress),

                if (_mode != AuthModalMode.forgotPassword) ...[
                  _buildInputField(
                    "كلمة المرور *",
                    _passwordCtrl,
                    Icons.lock_outline,
                    isDark,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ],

                if (_mode == AuthModalMode.register) ...[
                  _buildInputField(
                    "تأكيد كلمة المرور *",
                    _confirmPasswordCtrl,
                    Icons.lock_outline,
                    isDark,
                    isPassword: true,
                    obscureText: _obscureConfirm,
                    onTogglePassword: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ],

                if (_mode == AuthModalMode.login) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _mode = AuthModalMode.forgotPassword;
                        _errorMessage = null;
                        _successMessage = null;
                      }),
                      child: Text("نسيت كلمة المرور؟", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF0284C7))),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _mode == AuthModalMode.login
                              ? "تسجيل الدخول"
                              : (_mode == AuthModalMode.register ? "إنشاء الحساب الآن" : "إرسال رابط الاستعادة"),
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 16),

                // Mode switchers
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _mode == AuthModalMode.login ? "ليس لديك حساب بعد؟" : "لديك حساب بالفعل؟",
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _mode = (_mode == AuthModalMode.login) ? AuthModalMode.register : AuthModalMode.login;
                        _errorMessage = null;
                        _successMessage = null;
                      }),
                      child: Text(
                        _mode == AuthModalMode.login ? "إنشاء حساب جديد" : "تسجيل الدخول",
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
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

  Widget _buildInputField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    bool isDark, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155))),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            obscureText: isPassword && obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.cairo(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey),
                      onPressed: onTogglePassword,
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryPicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("الدولة", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.cairo()))).toList(),
                onChanged: (val) => setState(() => _selectedCountry = val ?? 'مصر'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
