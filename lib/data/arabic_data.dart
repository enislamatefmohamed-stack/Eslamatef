class ArabicData {
  static const String brandName = "Eslam Atef";
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

  // Latest Course & Lesson Updates for the Square Carousel
  static final List<Map<String, dynamic>> latestUpdates = [
    {
      "title": "مسار هياكل البيانات والخوارزميات التأسيسي",
      "category": "كورس جديد",
      "type": "course",
      "route": "/courses",
      "image": "assets/images/slide1.png",
      "badge": "تأسيس هندسي",
      "duration": "36 ساعة",
    },
    {
      "title": "البيانات والمعلومات والمعرفة: المحاضرة التأسيسية",
      "category": "درس جديد",
      "type": "lesson",
      "route": "/lessons",
      "image": "assets/images/slide2.png",
      "badge": "ذكاء اصطناعي",
      "duration": "25 دقيقة",
    },
    {
      "title": "هندسة الكود النظيف (Clean Code Architecture)",
      "category": "كورس جديد",
      "type": "course",
      "route": "/courses",
      "image": "assets/images/slide3.png",
      "badge": "مستوى متقدم",
      "duration": "28 ساعة",
    },
    {
      "title": "كيف يوزع نظام التشغيل الذاكرة فعلياً تحت الغطاء؟",
      "category": "درس جديد",
      "type": "lesson",
      "route": "/lessons",
      "image": "assets/images/slide4.png",
      "badge": "علوم حاسب",
      "duration": "24 دقيقة",
    },
    {
      "title": "بناء وكلاء الذكاء الاصطناعي وتطبيقات LLM & RAG",
      "category": "كورس جديد",
      "type": "course",
      "route": "/courses",
      "image": "assets/images/slide5.png",
      "badge": "أحدث تقنية",
      "duration": "40 ساعة",
    },
  ];

  // Weekly Challenge
  static const Map<String, dynamic> weeklyChallenge = {
    "week": "الأسبوع 42",
    "difficulty": "مستوى: متوسط",
    "daysLeft": "ينتهي خلال 3 أيام",
    "title": "خوارزمية تصفية البيانات والتحقق المتقاطع (Cross-checking)",
    "scenario": "لديك مصفوفة من نتائج درجات الطلاب ومؤشرات التحقق من مصادر متعددة، المطلوب كتابة خوارزمية تستبعد القيم الشاذة وتحسب المتوسط الحقيقي للطلاب المؤهلين للتميز.",
    "input": "[85, 92, 45, 99, 120, 88]",
    "output": "Valid Average = 88.5 | Qualified Count = 4",
    "hint": "تذكر تطبيق شرط التحقق المتقاطع لاستبعاد القيم خارج النطاق المنطقي [0 - 100] أولاً قبل حساب المتوسط.",
    "participants": 164,
  };

  // Interactive Quiz Questions for "اختبر نفسك"
  static final List<Map<String, dynamic>> quizQuestions = [
    {
      "question": "ما هو الفرق الجوهري بين البيانات (Data) والمعلومات (Information)؟",
      "options": [
        "البيانات تنتج من تحليل وتلخيص المعلومات.",
        "المعلومات هي بيانات تم إعطاؤها معنى وسياقاً لتفيد في اتخاذ القرار.",
        "لا يوجد فرق جوهري، هما مجرد مسميات مختلفة لنفس الشيء.",
        "البيانات رقمية فقط والمعلومات نصوص فقط."
      ],
      "correctIndex": 1,
      "explanation": "المعلومات هي نتاج معالجة البيانات الخام وإكسابها سياقاً ودلالة تتيح للمستلم اتخاذ قرارات صحيحة."
    },
    {
      "question": "خاصية بقاء المعلومات مخزنة وقابلة للاسترجاع والرجوع إليها مع مرور الوقت تُسمى:",
      "options": [
        "الانتشار (Propagation)",
        "الاستمرار (Persistence)",
        "إعادة الإنتاج (Reproducibility)",
        "الثقافة الإعلامية (Media Literacy)"
      ],
      "correctIndex": 1,
      "explanation": "خاصية الاستمرار (Persistence) تعني حفظ المعلومة وبقاءها قابلة للاستدعاء عبر الزمن."
    },
    {
      "question": "المعلومات التي يتم جمعها مباشرة من خلال إجراء تجربة معملية بنفسك تُصنف كـ:",
      "options": [
        "معلومات ثانوية (Secondary Information)",
        "وسائط انتشار (Transmission Media)",
        "معلومات أولية (Primary Information)",
        "بيانات تالفة بلا سياق"
      ],
      "correctIndex": 2,
      "explanation": "المعلومات الأولية هي التي يتم الحصول عليها مباشرة من المصدر الأصلي والبحث الميداني والتجربة الشخصية."
    },
    {
      "question": "وحدات التخزين الفلاشية USB والأقراص المدمجة DVD تندرج تحت تصنيف:",
      "options": [
        "وسائط التعبير (Expression Media)",
        "وسائط النقل والبث (Transmission Media)",
        "وسائط التسجيل والتخزين (Recording Media)",
        "وسائط الاتصال الهاتفي"
      ],
      "correctIndex": 2,
      "explanation": "وسائط التسجيل (Recording Media) هي الأوعية المادية والرقمية المخصصة لتخزين وحفظ البيانات."
    }
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
