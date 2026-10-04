// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _authService = AuthService.instance;
  final _userService = UserService.instance;

  bool _isEditing = false;
  bool _isSaving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  String _country = 'مصر';

  final List<String> _countries = [
    'مصر', 'السعودية', 'الإمارات', 'الكويت', 'قطر', 'الأردن',
    'العراق', 'عمان', 'البحرين', 'تونس', 'الجزائر', 'المغرب',
    'فلسطين', 'سوريا', 'لبنان', 'ليبيا', 'السودان', 'اليمن', 'أخرى'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  void _initFields(Map<String, dynamic> data) {
    if (!_isEditing) {
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _whatsappCtrl.text = data['whatsapp'] ?? '';
      _country = data['country'] ?? 'مصر';
    }
  }

  Future<void> _saveProfile(String uid) async {
    setState(() => _isSaving = true);
    try {
      await _userService.updateUserProfile(uid, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'whatsapp': _whatsappCtrl.text.trim(),
        'country': _country,
      });
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم حفظ وتحديث بياناتك بنجاح ✅", style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء الحفظ: $e", style: GoogleFonts.cairo()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 750;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("الملف الشخصي", style: GoogleFonts.cairo())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text("يرجى تسجيل الدخول أولاً للوصول إلى حسابك", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF070B14) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          elevation: 0,
          title: Text("لوحة حساب العضو والطالب", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              tooltip: "تسجيل الخروج",
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _userService.streamUserProfile(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
            }

            final data = snapshot.data?.data() ?? {
              'name': user.displayName ?? 'طالب',
              'email': user.email ?? '',
              'photoUrl': user.photoURL ?? '',
              'country': 'مصر',
              'quizzesCount': 0,
              'challengesCount': 0,
            };

            _initFields(data);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Header Card (Responsive for mobile)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 18 : 24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        ),
                        child: isMobile
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: const Color(0xFF0284C7).withOpacity(0.15),
                                        backgroundImage: (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty)
                                            ? NetworkImage(data['photoUrl'])
                                            : null,
                                        child: (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty)
                                            ? Text((data['name'] ?? 'ط')[0], style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)))
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['name'] ?? '',
                                              style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                            ),
                                            Text(
                                              data['email'] ?? '',
                                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                                              child: Text(
                                                "عضو مسجل • ${data['country'] ?? 'مصر'}",
                                                style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => setState(() => _isEditing = !_isEditing),
                                      icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, size: 16),
                                      label: Text(_isEditing ? "إلغاء التعديل" : "تعديل البيانات", style: GoogleFonts.cairo(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isEditing ? Colors.grey : const Color(0xFF0284C7),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: const Color(0xFF0284C7).withOpacity(0.15),
                                    backgroundImage: (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty)
                                        ? NetworkImage(data['photoUrl'])
                                        : null,
                                    child: (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty)
                                        ? Text((data['name'] ?? 'ط')[0], style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)))
                                        : null,
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? '',
                                          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                        ),
                                        Text(
                                          data['email'] ?? '',
                                          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                                          child: Text(
                                            "عضو مسجل • ${data['country'] ?? 'مصر'}",
                                            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => setState(() => _isEditing = !_isEditing),
                                    icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, size: 16),
                                    label: Text(_isEditing ? "إلغاء التعديل" : "تعديل البيانات", style: GoogleFonts.cairo(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isEditing ? Colors.grey : const Color(0xFF0284C7),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 20),

                      // Edit Profile Form (if active)
                      if (_isEditing)
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF0284C7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("تعديل بيانات الملف الشخصي:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 16),
                              _buildField("الاسم بالكامل", _nameCtrl, isDark),
                              if (isMobile) ...[
                                _buildField("رقم الهاتف", _phoneCtrl, isDark),
                                _buildField("رقم واتساب", _whatsappCtrl, isDark),
                              ] else ...[
                                Row(
                                  children: [
                                    Expanded(child: _buildField("رقم الهاتف", _phoneCtrl, isDark)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _buildField("رقم واتساب", _whatsappCtrl, isDark)),
                                  ],
                                ),
                              ],
                              _buildCountryPicker(isDark),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isSaving ? null : () => _saveProfile(user.uid),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text("حفظ التغييرات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                      // Activity Summary Counters (Live Streamed)
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('enrollments').snapshots(),
                        builder: (ctx, eSnap) {
                          final enrolledCount = eSnap.data?.docs.length ?? 0;
                          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('watched_lessons').snapshots(),
                            builder: (ctx2, wSnap) {
                              final watchedCount = wSnap.data?.docs.length ?? 0;

                              return isMobile
                                  ? Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatTile(
                                                "الكورسات المسجلة",
                                                "$enrolledCount",
                                                Icons.school_rounded,
                                                const Color(0xFF00E5FF),
                                                isDark,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatTile(
                                                "الدروس المكتملة",
                                                "$watchedCount",
                                                Icons.play_circle_filled_rounded,
                                                const Color(0xFF10B981),
                                                isDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildStatTile(
                                          "الاختبارات المنجزة",
                                          "${data['quizzesCount'] ?? 0}",
                                          Icons.psychology_rounded,
                                          const Color(0xFF8B5CF6),
                                          isDark,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatTile(
                                            "الكورسات المسجلة",
                                            "$enrolledCount",
                                            Icons.school_rounded,
                                            const Color(0xFF00E5FF),
                                            isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildStatTile(
                                            "الدروس المكتملة",
                                            "$watchedCount",
                                            Icons.play_circle_filled_rounded,
                                            const Color(0xFF10B981),
                                            isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildStatTile(
                                            "الاختبارات المنجزة",
                                            "${data['quizzesCount'] ?? 0}",
                                            Icons.psychology_rounded,
                                            const Color(0xFF8B5CF6),
                                            isDark,
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Section: Enrolled Courses & Curricula
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "📚 الكورسات والمناهج المسجّل بها:",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/courses'),
                            icon: const Icon(Icons.explore_outlined, size: 16),
                            label: Text("تصفح الكورسات", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('enrollments')
                            .snapshots(),
                        builder: (ctx, eSnap) {
                          if (eSnap.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                          }
                          final docs = eSnap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                                    const SizedBox(height: 10),
                                    Text("لم تقم بالتسجيل في أي كورس بعد.", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "يمكنك التسجيل المجاني أو الاشتراك في أي كورس للوصول لكافة المحاضرات والاختبارات.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pushNamed('/courses'),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
                                      child: Text("تصفح الكورسات المتاحة ➔", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 10),
                            itemBuilder: (c, i) {
                              final enroll = docs[i].data();
                              final cid = enroll['courseId'] ?? '';
                              final date = enroll['enrolledAt'] != null
                                  ? (enroll['enrolledAt'] as Timestamp).toDate().toString().split(' ')[0]
                                  : 'تاريخ حديث';

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                                ),
                                child: isMobile
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                                child: const Icon(Icons.school_rounded, color: Color(0xFF10B981), size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("كورس مسجل: $cid", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                                    Text("تاريخ التسجيل: $date", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pushNamed('/courses'),
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                                            child: Text("متابعة ودخول الكورس ➔", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                            child: const Icon(Icons.school_rounded, color: Color(0xFF10B981), size: 22),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("كورس مسجل: $cid", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                                Text("تاريخ التسجيل: $date • الحالة: مفعّل بالكامل ✅", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pushNamed('/courses'),
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                                            child: Text("متابعة الكورس ➔", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Section: Watched Lessons & Progress
                      Text(
                        "🎬 سجل الدروس والفيديوهات المشاهدة:",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('watched_lessons')
                            .snapshots(),
                        builder: (ctx, wSnap) {
                          if (wSnap.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator()));
                          }
                          final docs = wSnap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              ),
                              child: Center(
                                child: Text("لم تقم بمشاهدة أي دروس بعد. ابدأ بمشاهدة الدروس ليتم تسجيل إنجازك هنا.", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 8),
                            itemBuilder: (c, i) {
                              final watched = docs[i].data();
                              final lid = watched['lessonId'] ?? docs[i].id;
                              final cid = watched['courseId'] ?? '';
                              final date = watched['watchedAt'] != null
                                  ? (watched['watchedAt'] as Timestamp).toDate().toString().split(' ')[0]
                                  : '';

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "درس مكتمل ($cid): $lid",
                                        style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (date.isNotEmpty)
                                      Text(date, style: GoogleFonts.cairo(fontSize: 10.5, color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Quizzes Submissions List
                      Text("📊 نتائج اختباراتك المسجلة:", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('quizzes')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (ctx, qSnap) {
                          if (qSnap.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                          }
                          final docs = qSnap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              ),
                              child: Center(
                                child: Text("لم تقم بإجراء أي اختبارات تفاعلية بعد.", style: GoogleFonts.cairo(color: Colors.grey)),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 10),
                            itemBuilder: (c, i) {
                              final q = docs[i].data();
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.verified_outlined, color: Color(0xFF8B5CF6), size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(q['quizTitle'] ?? 'اختبار', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text("تاريخ الإجراء: ${q['date'] ?? ''}", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        "الدرجة: ${q['score'] ?? 0} / ${q['totalQuestions'] ?? 10}",
                                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF15803D), fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                Text(count, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            style: GoogleFonts.cairo(fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryPicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("الدولة", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _country,
              isExpanded: true,
              items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.cairo()))).toList(),
              onChanged: (val) => setState(() => _country = val ?? 'مصر'),
            ),
          ),
        ),
      ],
    );
  }
}
