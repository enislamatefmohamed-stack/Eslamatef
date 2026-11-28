// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/embedded_iframe/embedded_iframe.dart';

class ToolItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final String file;

  const ToolItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.file,
  });
}

const List<ToolItem> _allTools = [
  // PDF
  ToolItem(
    id: 'pdf-merge',
    title: 'دمج وتقسيم PDF',
    description: 'اجمع عدة ملفات PDF في ملف واحد منظم، أو قسّم ملف واستخرج الصفحات التي تحتاجها بسهولة وسرعة.',
    category: 'أدوات PDF',
    icon: Icons.picture_as_pdf_rounded,
    color: Color(0xFFEF4444),
    file: 'codeai-pdf.html',
  ),
  ToolItem(
    id: 'img-to-pdf',
    title: 'تحويل الصور لـ PDF',
    description: 'رتّب صورك وحولها إلى ملف PDF عالي الجودة بصفحة مستقلة لكل صورة وبدون فقدان الوضوح.',
    category: 'أدوات PDF',
    icon: Icons.collections_rounded,
    color: Color(0xFFF97316),
    file: 'codeai-img2pdf.html',
  ),
  ToolItem(
    id: 'pdf-compress',
    title: 'ضغط ملفات PDF',
    description: 'قلل حجم ملفات PDF الكبيرة لتسهيل إرسالها ومشاركتها مع الحفاظ على جودة المستند.',
    category: 'أدوات PDF',
    icon: Icons.compress_rounded,
    color: Color(0xFFE11D48),
    file: 'codeai-pdfcomp.html',
  ),
  ToolItem(
    id: 'pdf-images',
    title: 'استخراج الصور من PDF',
    description: 'اسحب جميع الصور الموجودة داخل ملف PDF ونزّلها بصيغة PNG وبدقتها الأصلية دفعة واحدة.',
    category: 'أدوات PDF',
    icon: Icons.photo_library_rounded,
    color: Color(0xFFEA580C),
    file: 'codeai-pdfimg.html',
  ),
  ToolItem(
    id: 'pdf-text',
    title: 'استخراج النص من PDF',
    description: 'استخرج النصوص العربية والإنجليزية من ملفات PDF صفحة بصفحة لنسخها أو حفظها كملف نصي.',
    category: 'أدوات PDF',
    icon: Icons.text_snippet_rounded,
    color: Color(0xFFDC2626),
    file: 'codeai-pdftext.html',
  ),

  // Media & Audio
  ToolItem(
    id: 'image-compress',
    title: 'ضغط وتصغير الصور',
    description: 'صغّر حجم صورك وقلل أبعادها بنسبة تصل إلى 80% في ثوانٍ معدودة دون رفعها لأي سيرفر.',
    category: 'الميديا والصوت',
    icon: Icons.photo_size_select_large_rounded,
    color: Color(0xFF0284C7),
    file: 'codeai-compress.html',
  ),
  ToolItem(
    id: 'file-converter',
    title: 'محوّل الملفات الشامل',
    description: 'حوّل بين صيغ الصور والصوت والملفات النصية المختلفة بسهولة وأمان تام داخل المتصفح.',
    category: 'الميديا والصوت',
    icon: Icons.transform_rounded,
    color: Color(0xFF06B6D4),
    file: 'codeai-converter.html',
  ),
  ToolItem(
    id: 'audio-fixer',
    title: 'تحسين ومعالجة الصوت',
    description: 'ارفع مستوى الصوت المنخفض، قلل الضجيج والتشويش، واحفظ ملفك بجودة WAV أو MP3.',
    category: 'الميديا والصوت',
    icon: Icons.graphic_eq_rounded,
    color: Color(0xFF0D9488),
    file: 'codeai-audfix.html',
  ),
  ToolItem(
    id: 'voice-recorder',
    title: 'مسجّل الصوت الاحترافي',
    description: 'سجّل صوتك من الميكروفون مع عدّاد دقيق ومؤشر للموجات الصوتية ونزّل التسجيل MP3 أو WAV.',
    category: 'الميديا والصوت',
    icon: Icons.mic_rounded,
    color: Color(0xFF10B981),
    file: 'codeai-recorder.html',
  ),

  // Developers & Code
  ToolItem(
    id: 'html-editor',
    title: 'محرر HTML وCSS المباشر',
    description: 'محرر كود فوري مع معاينة حية سريعة لتصميم صفحات الويب وتجربة الأكواد التفاعلية.',
    category: 'أدوات المطورين',
    icon: Icons.code_rounded,
    color: Color(0xFF8B5CF6),
    file: 'codeai-htmled.html',
  ),
  ToolItem(
    id: 'python-explainer',
    title: 'شرح كود بايثون سطر بسطر',
    description: 'الصق كود بايثون واحصل على تحليل وشرح تعليمي مبسط باللغة العربية لكل سطر برمجي.',
    category: 'أدوات المطورين',
    icon: Icons.integration_instructions_rounded,
    color: Color(0xFF6366F1),
    file: 'codeai-pyexp.html',
  ),
  ToolItem(
    id: 'base64-tool',
    title: 'تشفير وفك Base64',
    description: 'حوّل النصوص والملفات والصور إلى صيغة Base64 والعكس بسرعة مع أزرار نسخ فورية.',
    category: 'أدوات المطورين',
    icon: Icons.enhanced_encryption_rounded,
    color: Color(0xFFA855F7),
    file: 'codeai-b64.html',
  ),
  ToolItem(
    id: 'seo-sitemap',
    title: 'مولّد ملفات الـ SEO',
    description: 'أنشئ ملفات sitemap.xml وrobots.txt الاحترافية لموقعك بضغطة زر واحدة لتحسين أرشفة محركات البحث.',
    category: 'أدوات المطورين',
    icon: Icons.travel_explore_rounded,
    color: Color(0xFF3B82F6),
    file: 'codeai-sitemap.html',
  ),
  ToolItem(
    id: 'qr-generator',
    title: 'مولّد QR Code الذكي',
    description: 'أنشئ رموز QR مخصصة للروابط، أرقام الواتساب، والواي فاي، ونزلها بدقة عالية PNG أو SVG.',
    category: 'أدوات المطورين',
    icon: Icons.qr_code_2_rounded,
    color: Color(0xFF14B8A6),
    file: 'codeai-qr.html',
  ),

  // Text & Productivity
  ToolItem(
    id: 'pomodoro',
    title: 'مؤقت بومودورو للإنتاجية',
    description: 'نظام إدارة الوقت المثالي (25 دقيقة تركيز + 5 دقائق راحة) مع تنبيهات صوتية وإحصائيات جلسات.',
    category: 'النصوص والإنتاجية',
    icon: Icons.timer_rounded,
    color: Color(0xFFF59E0B),
    file: 'codeai-pomo.html',
  ),
  ToolItem(
    id: 'word-repeater',
    title: 'فاحص تكرار الكلمات',
    description: 'حلل مقالك ومحتواك واكتشف الكلمات الأكثر تكراراً لضبط الصياغة وتحسين جودة الكتابة.',
    category: 'النصوص والإنتاجية',
    icon: Icons.find_in_page_rounded,
    color: Color(0xFFD97706),
    file: 'codeai-repeat.html',
  ),
  ToolItem(
    id: 'text-cleaner',
    title: 'منظّف ومنسق النصوص',
    description: 'أزل المسافات الزائدة، والأسطر الفارغة، ووحّد علامات الترقيم ونسّق النص العربي بنقرة واحدة.',
    category: 'النصوص والإنتاجية',
    icon: Icons.cleaning_services_rounded,
    color: Color(0xFF10B981),
    file: 'codeai-tclean.html',
  ),
  ToolItem(
    id: 'cycle-calculator',
    title: 'حاسبة الصحة والخصوبة',
    description: 'حساب مواعيد الدورة الشهرية وفترات الخصوبة والتبويض بدقة مع تقويم توضيحي مريح.',
    category: 'النصوص والإنتاجية',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFFEC4899),
    file: 'codeai-cycle.html',
  ),
];

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'الكل',
    'أدوات PDF',
    'الميديا والصوت',
    'أدوات المطورين',
    'النصوص والإنتاجية',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ToolItem> get _filteredTools {
    return _allTools.where((tool) {
      final matchesCategory = _selectedCategory == 'الكل' || tool.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          tool.title.toLowerCase().contains(query) ||
          tool.description.toLowerCase().contains(query) ||
          tool.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openToolInModal(BuildContext context, ToolItem tool) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(ctx).size.width;
        final isMobile = screenWidth < 850;

        return Dialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 32,
            vertical: isMobile ? 16 : 24,
          ),
          child: Container(
            width: isMobile ? double.infinity : 1000,
            height: isMobile ? MediaQuery.of(ctx).size.height * 0.92 : 820,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Modal Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tool.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tool.icon, color: tool.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tool.title,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              tool.category,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // External Link Button
                      IconButton(
                        tooltip: "فتح في نافذة كاملة",
                        icon: const Icon(Icons.open_in_new_rounded, size: 20),
                        onPressed: () {
                          _launchToolUrl(tool.file);
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: "إغلاق",
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                // Tool Frame
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    child: EmbeddedIframe(
                      src: '/tools/${tool.file}',
                      id: tool.id,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchToolUrl(String file) {
    if (kIsWeb) {
      html.window.open('/tools/$file', '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isTablet = screenWidth >= 850 && screenWidth < 1200;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        endDrawer: isMobile ? const UnifiedAppDrawer(currentRoute: '/tools') : null,
        body: SelectionArea(
          child: SafeArea(
            child: Column(
              children: [
                UnifiedAppHeader(
                  currentRoute: '/tools',
                  pageTitle: 'الأدوات — أدوات برمجية ومكتبية مجانية',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 48,
                            vertical: isMobile ? 32 : 48,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: isDark
                                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                                  : [const Color(0xFFF0FDF4), const Color(0xFFE0F2FE)],
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF00E5FF).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF0284C7)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "خصوصية تامة · معالجة 100% داخل جهازك دون رفع أي بيانات",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "الأدوات الذكية والبرمجية",
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 26 : 38,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "مجموعة أدوات مجانية متكاملة لملفات الـ PDF، الميديا، الأكواد البرمجية، وتحسين الإنتاجية",
                                    style: GoogleFonts.cairo(
                                      fontSize: isMobile ? 14 : 16,
                                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 28),

                                  // Search Bar
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 620),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.cardDark : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _searchCtrl,
                                      onChanged: (val) {
                                        setState(() {
                                          _searchQuery = val;
                                        });
                                      },
                                      style: GoogleFonts.cairo(
                                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "ابحث في الأدوات (مثال: PDF, صور, QR, بايثون)...",
                                        hintStyle: GoogleFonts.cairo(
                                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                                        ),
                                        suffixIcon: _searchQuery.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear_rounded, size: 18),
                                                onPressed: () {
                                                  _searchCtrl.clear();
                                                  setState(() {
                                                    _searchQuery = '';
                                                  });
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Category Chips
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: _categories.map((cat) {
                                      final isSelected = _selectedCategory == cat;
                                      return ChoiceChip(
                                        label: Text(cat),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedCategory = cat;
                                            });
                                          }
                                        },
                                        labelStyle: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                                        ),
                                        selectedColor: const Color(0xFF0284C7),
                                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isSelected
                                                ? const Color(0xFF0284C7)
                                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                          ),
                                        ),
                                        showCheckmark: false,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Tools Grid Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 48,
                            vertical: 36,
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "جميع الأدوات المتاحة",
                                        style: GoogleFonts.cairo(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${_filteredTools.length}",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  if (_filteredTools.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(48),
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 60,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "لم يتم العثور على أي أدوات مطابقة",
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "جرّب البحث بكلمة أخرى أو تغيير التصنيف",
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        mainAxisExtent: 240,
                                      ),
                                      itemCount: _filteredTools.length,
                                      itemBuilder: (ctx, index) {
                                        final tool = _filteredTools[index];
                                        return _ToolCard(
                                          tool: tool,
                                          isDark: isDark,
                                          onOpen: () => _openToolInModal(context, tool),
                                          onOpenNewTab: () => _launchToolUrl(tool.file),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Unified Footer
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
}

class _ToolCard extends StatefulWidget {
  final ToolItem tool;
  final bool isDark;
  final VoidCallback onOpen;
  final VoidCallback onOpenNewTab;

  const _ToolCard({
    required this.tool,
    required this.isDark,
    required this.onOpen,
    required this.onOpenNewTab,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -4, 0)) : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? tool.color.withOpacity(0.5)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? tool.color.withOpacity(0.12)
                  : Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tool.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tool.icon, color: tool.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        tool.category,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tool.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                tool.description,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _isHovered
                              ? tool.color.withOpacity(0.4)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                    ),
                    icon: Icon(Icons.play_arrow_rounded, size: 18, color: tool.color),
                    label: Text(
                      "تشغيل الأداة",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: "فتح في نافذة كاملة",
                  icon: Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  onPressed: widget.onOpenNewTab,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
