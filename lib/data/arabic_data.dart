class ArabicData {
  static const String brandName = "إسلام عاطف";
  static const String brandSubtitle = "Code & AI";
  static const String phone = "01100665674";
  static const String formattedPhone = "01100665674";
  static const String whatsappUrl = "https://wa.me/201100665674";
  static const String email = "en.islam.atef.mohamed@gmail.com";

  // Social Links
  static const String facebookUrl = "https://facebook.com/EslamAtefCodeAI";
  static const String youtubeUrl = "https://www.youtube.com/@EslamAtefCodeAI";
  static const String telegramUrl = "https://t.me/EslamAtefAI";
  static const String linkedinUrl = "https://www.linkedin.com/in/eslam-atef-1a5933439";
  static const String githubUrl = "https://github.com/eslam-atef-ai";

  // The 5 Slide Items
  static final List<Map<String, dynamic>> imageSlides = [
    {
      "image": "assets/images/slide1.png",
      "buttonText": "انضم الآن",
      "buttonType": "cyan",
      "action": "join",
    },
    {
      "image": "assets/images/slide2.png",
      "buttonText": "اكتشف المحتوى",
      "buttonType": "cyan",
      "action": "explore",
    },
    {
      "image": "assets/images/slide3.png",
      "buttonText": "شاهد على YouTube",
      "buttonType": "red",
      "action": "youtube",
    },
    {
      "image": "assets/images/slide4.png",
      "buttonText": "انضم للقناة",
      "buttonType": "telegram",
      "action": "telegram",
      "hasSocial": true,
    },
    {
      "image": "assets/images/slide5.png",
      "buttonText": "استكشف المشاريع",
      "buttonType": "cyan",
      "action": "projects",
    },
  ];

  // Hero Slider
  static final List<Map<String, String>> slides = [
    {
      "badge": "علوم الحاسب والذكاء الاصطناعي",
      "title": "فكر كمهندس برمجيات.. وابنِ المستقبل مع الذكاء الاصطناعي",
      "desc": "رحلة تعليمية عملية تركز على الفهم العميق للبرمجة وهندسة النظم بدلاً من مجرد نسخ الأكواد.",
      "cta": "استكشف الكورسات",
      "target": "courses",
    },
    {
      "badge": "تأسيس برمجي صلب",
      "title": "أتقن الخوارزميات وهياكل البيانات والكود النظيف",
      "desc": "تعلم كيف تفكر في حل المشكلات، وتحليل الكفاءة، وبناء تطبيقات قوية جاهزة للعمل الحقيقي.",
      "cta": "شاهد الدروس المجانية",
      "target": "lessons",
    },
    {
      "badge": "عصر الذكاء الاصطناعي",
      "title": "وظّف الـ AI كشريك ذكي يضاعف إنتاجيتك وسرعتك",
      "desc": "افهم كيف تعمل النماذج اللغوية (LLMs) وطبق أحدث تقنيات الـ AI في مشاريعك البرمجية.",
      "cta": "تواصل معنا الآن",
      "target": "contact",
    },
  ];

  // Courses
  static final List<Map<String, dynamic>> courses = [
    {
      "title": "أساسيات علوم الحاسب وهياكل البيانات",
      "level": "من الصفر للمتقدم",
      "duration": "36 ساعة تدريبية",
      "desc": "تأسيس هندسي شامل في إدارة الذاكرة، الخوارزميات الأساسية والمتقدمة، وحل المشكلات البرمجية المعقدة.",
      "tag": "تأسيس شامل",
    },
    {
      "title": "هندسة البرمجيات والتصميم النظيف (Clean Code)",
      "level": "متوسط إلى متقدم",
      "duration": "28 ساعة تدريبية",
      "desc": "تطبيق مبادئ SOLID وأنماط التصميم المعمارية لبناء أنظمة برمجية قابلة للتوسع والصيانة بسهولة.",
      "tag": "مستوى الشركات",
    },
    {
      "title": "تعلم الآلة وتحليل البيانات التطبيقي (Machine Learning)",
      "level": "متوسط",
      "duration": "32 ساعة تدريبية",
      "desc": "بناء وتدريب ونشر نماذج تعلم الآلة على بيانات حقيقية دون الاعتماد على الصناديق السوداء.",
      "tag": "تطبيق عملي",
    },
    {
      "title": "الذكاء الاصطناعي التوليدي وأنظمة LLMs & RAG",
      "level": "متقدم",
      "duration": "40 ساعة تدريبية",
      "desc": "تصميم وبناء تطبيقات الذكاء الاصطناعي التوليدي، البحث الدلالي في قواعد البيانات، والوكلاء الذاتيون.",
      "tag": "أحدث التقنيات",
    },
  ];

  // Lessons
  static final List<Map<String, String>> lessons = [
    {
      "title": "كيف يوزع نظام التشغيل الذاكرة فعلياً تحت الغطاء؟",
      "duration": "24 دقيقة",
      "category": "علوم حاسب",
      "url": youtubeUrl,
    },
    {
      "title": "بناء نظام RAG متكامل من الصفر دون تعقيد",
      "duration": "38 دقيقة",
      "category": "ذكاء اصطناعي",
      "url": youtubeUrl,
    },
    {
      "title": "هياكل البيانات التي يجب أن تتقنها قبل تعلم الآلة",
      "duration": "20 دقيقة",
      "category": "خوارزميات",
      "url": youtubeUrl,
    },
    {
      "title": "تحويل الكود العشوائي إلى Clean Architecture احترافي",
      "duration": "31 دقيقة",
      "category": "هندسة برمجيات",
      "url": youtubeUrl,
    },
  ];

  // Privacy Policy
  static const String privacyPolicyTitle = "سياسة الخصوصية";
  static const String privacyPolicyContent = """
نحن في منصة 'Eslam Atef | Code & AI' نولي خصوصية بياناتك اهتماماً بالغاً:

1. جمع البيانات:
نجمع فقط البيانات التي تقدمها لنا طواعية (مثل الاسم ورقم الهاتف والبريد الإلكتروني عند التواصل أو الاستفسار عن الكورسات).

2. استخدام البيانات:
تُستخدم البيانات فقط للرد على استفساراتك، وتقديم الدعم الفني، وإرسال تفاصيل الكورسات والجلسات التعليمية.

3. حماية البيانات:
نلتزم بعدم مشاركة أو بيع أي من بياناتك الشخصية لأي طرف ثالث تحت أي ظرف.

4. التواصل معنا:
إذا كانت لديك أي استفسارات بخصوص الخصوصية، يمكنك التواصل معنا عبر الواتساب أو الاتصال على الرقم: 01100665674.
""";
}
