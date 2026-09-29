/* ====================================================================
   Eslam Atef | Code & AI — Presentation Engine & Whiteboard Logic
   ==================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const slides = Array.from(document.querySelectorAll('.slide'));
  const totalSlides = slides.length;
  let currentSlideIndex = 0;
  let currentStepIndex = -1; // -1 means initial slide view, 0+ for step items

  // Toolbar elements
  const prevBtn = document.getElementById('prev-btn');
  const nextBtn = document.getElementById('next-btn');
  const slideCounter = document.getElementById('slide-counter');
  const fullscreenBtn = document.getElementById('fullscreen-btn');
  const penBtn = document.getElementById('pen-btn');
  const highlighterBtn = document.getElementById('highlighter-btn');
  const eraserBtn = document.getElementById('eraser-btn');
  const clearBtn = document.getElementById('clear-btn');
  const toggleToolbarBtn = document.getElementById('toggle-toolbar-btn');
  const showToolbarBtn = document.getElementById('show-toolbar-btn');
  const presenterToolbar = document.getElementById('presenter-toolbar');
  const colorDots = document.querySelectorAll('.color-dot');

  // Canvas Whiteboard
  const canvas = document.getElementById('drawing-canvas');
  const ctx = canvas.getContext('2d');
  let isDrawing = false;
  let currentTool = 'none'; // 'none', 'pen', 'highlighter', 'eraser'
  let currentColor = '#00E5FF';
  let penWidth = 4;
  let highlighterWidth = 24;
  let eraserWidth = 28;

  // Store canvas history per slide so drawings persist per slide!
  const slideDrawings = {};

  // Initialize Canvas Resolution
  function resizeCanvas() {
    const rect = canvas.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    ctx.scale(dpr, dpr);
    restoreSlideDrawing();
  }

  window.addEventListener('resize', resizeCanvas);

  // ====================================================================
  // Slide Navigation & Step-by-Step Revealing
  // ====================================================================
  function updateSlide(newIndex, resetSteps = true) {
    if (newIndex < 0 || newIndex >= totalSlides) return;

    // Save current drawing for current slide before moving
    saveSlideDrawing();

    // Remove active class from old slide
    slides[currentSlideIndex].classList.remove('active');

    currentSlideIndex = newIndex;
    slides[currentSlideIndex].classList.add('active');

    // Handle Steps in new slide
    const stepItems = slides[currentSlideIndex].querySelectorAll('.step-item');
    if (resetSteps) {
      stepItems.forEach(el => el.classList.remove('revealed'));
      currentStepIndex = -1;
    }

    // Update Counter
    const pad = (n) => String(n).padStart(2, '0');
    slideCounter.textContent = `${pad(currentSlideIndex + 1)} / ${pad(totalSlides)}`;

    // Restore any drawings made on this slide
    restoreSlideDrawing();
  }

  function handleNext() {
    const activeSlide = slides[currentSlideIndex];
    const stepItems = activeSlide.querySelectorAll('.step-item');

    if (stepItems.length > 0 && currentStepIndex < stepItems.length - 1) {
      // Reveal next step on current slide
      currentStepIndex++;
      stepItems[currentStepIndex].classList.add('revealed');
    } else {
      // Advance to next slide
      if (currentSlideIndex < totalSlides - 1) {
        updateSlide(currentSlideIndex + 1, true);
      }
    }
  }

  function handlePrev() {
    const activeSlide = slides[currentSlideIndex];
    const stepItems = activeSlide.querySelectorAll('.step-item');

    if (stepItems.length > 0 && currentStepIndex >= 0) {
      // Hide current step
      stepItems[currentStepIndex].classList.remove('revealed');
      currentStepIndex--;
    } else {
      // Go to previous slide
      if (currentSlideIndex > 0) {
        updateSlide(currentSlideIndex - 1, false);
        // Reveal all steps of previous slide
        const prevSteps = slides[currentSlideIndex].querySelectorAll('.step-item');
        prevSteps.forEach(el => el.classList.add('revealed'));
        currentStepIndex = prevSteps.length - 1;
      }
    }
  }

  // Button Listeners
  nextBtn.addEventListener('click', handleNext);
  prevBtn.addEventListener('click', handlePrev);

  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    // If typing in an input, don't trigger slide shortcuts
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

    switch (e.key) {
      case 'ArrowLeft':
      case 'ArrowDown':
      case 'PageDown':
      case ' ':
        handleNext();
        break;
      case 'ArrowRight':
      case 'ArrowUp':
      case 'PageUp':
        handlePrev();
        break;
      case 'Home':
        updateSlide(0, true);
        break;
      case 'End':
        updateSlide(totalSlides - 1, true);
        break;
      case 'f':
      case 'F':
        toggleFullscreen();
        break;
      case 'p':
      case 'P':
        setTool(currentTool === 'pen' ? 'none' : 'pen');
        break;
      case 'h':
      case 'H':
        setTool(currentTool === 'highlighter' ? 'none' : 'highlighter');
        break;
      case 'e':
      case 'E':
        setTool(currentTool === 'eraser' ? 'none' : 'eraser');
        break;
      case 'c':
      case 'C':
        clearCurrentDrawing();
        break;
      case 'b':
      case 'B':
        toggleToolbar();
        break;
    }
  });

  // ====================================================================
  // Whiteboard / Drawing Engine
  // ====================================================================
  function setTool(tool) {
    currentTool = tool;
    penBtn.classList.toggle('active', tool === 'pen');
    highlighterBtn.classList.toggle('active', tool === 'highlighter');
    eraserBtn.classList.toggle('active', tool === 'eraser');

    canvas.classList.remove('active-pen', 'active-eraser');
    if (tool === 'pen' || tool === 'highlighter') {
      canvas.classList.add('active-pen');
    } else if (tool === 'eraser') {
      canvas.classList.add('active-eraser');
    }
  }

  penBtn.addEventListener('click', () => setTool(currentTool === 'pen' ? 'none' : 'pen'));
  highlighterBtn.addEventListener('click', () => setTool(currentTool === 'highlighter' ? 'none' : 'highlighter'));
  eraserBtn.addEventListener('click', () => setTool(currentTool === 'eraser' ? 'none' : 'eraser'));

  // Color picker
  colorDots.forEach(dot => {
    dot.addEventListener('click', (e) => {
      colorDots.forEach(d => d.classList.remove('selected'));
      dot.classList.add('selected');
      currentColor = dot.dataset.color;
      if (currentTool === 'none') {
        setTool('pen');
      }
    });
  });

  // Clear drawing
  function clearCurrentDrawing() {
    const rect = canvas.getBoundingClientRect();
    ctx.clearRect(0, 0, rect.width, rect.height);
    delete slideDrawings[currentSlideIndex];
  }

  clearBtn.addEventListener('click', clearCurrentDrawing);

  function saveSlideDrawing() {
    const rect = canvas.getBoundingClientRect();
    if (rect.width > 0 && rect.height > 0) {
      slideDrawings[currentSlideIndex] = ctx.getImageData(0, 0, rect.width, rect.height);
    }
  }

  function restoreSlideDrawing() {
    const rect = canvas.getBoundingClientRect();
    ctx.clearRect(0, 0, rect.width, rect.height);
    if (slideDrawings[currentSlideIndex]) {
      ctx.putImageData(slideDrawings[currentSlideIndex], 0, 0);
    }
  }

  // Pointer Events (Mouse, Stylus, Touch)
  let lastX = 0;
  let lastY = 0;

  function getCanvasCoords(e) {
    const rect = canvas.getBoundingClientRect();
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top
    };
  }

  canvas.addEventListener('pointerdown', (e) => {
    if (currentTool === 'none') return;
    isDrawing = true;
    canvas.setPointerCapture(e.pointerId);
    const coords = getCanvasCoords(e);
    lastX = coords.x;
    lastY = coords.y;

    // Draw single dot on tap
    drawStroke(coords.x, coords.y);
  });

  canvas.addEventListener('pointermove', (e) => {
    if (!isDrawing || currentTool === 'none') return;
    const coords = getCanvasCoords(e);
    drawStroke(coords.x, coords.y);
    lastX = coords.x;
    lastY = coords.y;
  });

  function stopDrawing(e) {
    if (!isDrawing) return;
    isDrawing = false;
    try { canvas.releasePointerCapture(e.pointerId); } catch (err) {}
    saveSlideDrawing();
  }

  canvas.addEventListener('pointerup', stopDrawing);
  canvas.addEventListener('pointercancel', stopDrawing);

  function drawStroke(x, y) {
    ctx.beginPath();
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    if (currentTool === 'pen') {
      ctx.globalCompositeOperation = 'source-over';
      ctx.globalAlpha = 1.0;
      ctx.strokeStyle = currentColor;
      ctx.lineWidth = penWidth;
    } else if (currentTool === 'highlighter') {
      ctx.globalCompositeOperation = 'source-over';
      ctx.globalAlpha = 0.35;
      ctx.strokeStyle = currentColor;
      ctx.lineWidth = highlighterWidth;
    } else if (currentTool === 'eraser') {
      ctx.globalCompositeOperation = 'destination-out';
      ctx.globalAlpha = 1.0;
      ctx.lineWidth = eraserWidth;
    }

    ctx.moveTo(lastX, lastY);
    ctx.lineTo(x, y);
    ctx.stroke();
  }

  // ====================================================================
  // Fullscreen & Toolbar Toggle
  // ====================================================================
  function toggleFullscreen() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => {});
      fullscreenBtn.textContent = '⛶ إنهاء ملء الشاشة';
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
        fullscreenBtn.textContent = '⛶ ملء الشاشة';
      }
    }
  }

  fullscreenBtn.addEventListener('click', toggleFullscreen);

  function toggleToolbar() {
    const isHidden = presenterToolbar.classList.toggle('hidden');
    showToolbarBtn.classList.toggle('visible', isHidden);
  }

  toggleToolbarBtn.addEventListener('click', toggleToolbar);
  showToolbarBtn.addEventListener('click', toggleToolbar);

  // ====================================================================
  // Interactive Slide Widgets (Checks & Quiz)
  // ====================================================================
  
  // Generic single-choice checker
  document.querySelectorAll('.interactive-choice-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const container = btn.closest('.quiz-options');
      const banner = container.parentElement.querySelector('.feedback-banner');
      const isCorrect = btn.dataset.correct === 'true';

      container.querySelectorAll('.quiz-btn').forEach(b => {
        b.classList.remove('correct', 'wrong');
      });

      if (isCorrect) {
        btn.classList.add('correct');
        banner.className = 'feedback-banner show correct';
        banner.innerHTML = '✓ إجابة صحيحة وممتازة! ' + (btn.dataset.explanation || '');
      } else {
        btn.classList.add('wrong');
        banner.className = 'feedback-banner show wrong';
        banner.innerHTML = '✗ إجابة غير صحيحة، حاول مرة أخرى وفكر في خصائص ومفاهيم الدرس.';
      }
    });
  });

  // Reveal Answer Buttons (e.g. Slide 3)
  document.querySelectorAll('.reveal-answer-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.dataset.target;
      const target = document.getElementById(targetId);
      if (target) {
        target.style.display = target.style.display === 'none' ? 'block' : 'none';
        btn.textContent = target.style.display === 'none' ? 'كشف الإجابة والشرح' : 'إخفاء الإجابة';
      }
    });
  });

  // Slide 12: Primary vs Secondary Classifier
  document.querySelectorAll('.classify-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const card = btn.closest('.tech-card');
      const correctType = card.dataset.correctType;
      const chosenType = btn.dataset.type;
      const resultMsg = card.querySelector('.classify-result');

      if (correctType === chosenType) {
        card.style.borderColor = '#10B981';
        resultMsg.innerHTML = '<span style="color: #10B981; font-weight: bold;">✓ تصنيف صحيح!</span> ' + (card.dataset.note || '');
      } else {
        card.style.borderColor = '#EF4444';
        resultMsg.innerHTML = '<span style="color: #EF4444; font-weight: bold;">✗ غير دقيق!</span> فكر هل المصدر مباشر أم طرف ثالث؟';
      }
      resultMsg.style.display = 'block';
    });
  });

  // ====================================================================
  // Slide 22: Comprehensive Final Quiz Engine
  // ====================================================================
  const quizData = [
    {
      question: "1. ما هي البيانات (Data) حسب تعريف الكتاب المدرسي؟",
      options: [
        "معلومات تم تحليلها واستخلاص نتائج مفيدة منها.",
        "حقائق يتم تمثيلها باستخدام الأرقام والحروف والرموز بلا سياق.",
        "وسائل مادية تُستخدم لنقل الأخبار للمجتمع.",
        "معارف ناتجة عن حل المشكلات البرمجية."
      ],
      correctIndex: 1
    },
    {
      question: "2. أي مما يلي يُعتبر مثالاً للمعلومات (Information) وليس مجرد بيانات خام؟",
      options: [
        "الرقم: 85",
        "الاسم: محمد",
        "حصل أحمد على 85% في اختبار البرمجة والذكاء الاصطناعي.",
        "الرمز: %"
      ],
      correctIndex: 2
    },
    {
      question: "3. خاصية بقاء المعلومات محفوظة وقابلة للاسترجاع مع مرور الوقت تُسمى:",
      options: [
        "الانتشار (Propagation)",
        "الاستمرار (Persistence)",
        "إعادة الإنتاج (Reproducibility)",
        "الثقافة الإعلامية (Media Literacy)"
      ],
      correctIndex: 1
    },
    {
      question: "4. المعلومات التي يتم جمعها مباشرة من نتائج استبيان وزعته بنفسك تُصنف كـ:",
      options: [
        "معلومات ثانوية (Secondary Information)",
        "بيانات تالفة (Corrupted Data)",
        "معلومات أولية (Primary Information)",
        "وسائط نقل وبث (Transmission Media)"
      ],
      correctIndex: 2
    },
    {
      question: "5. وحدات الذاكرة Flash USB والأقراص الضوئية DVD تندرج تحت نوع:",
      options: [
        "وسائط التعبير (Expression Media)",
        "وسائط النقل والانتشار (Transmission Media)",
        "وسائط التسجيل والتخزين (Recording Media)",
        "وسائط المحادثة المباشرة"
      ],
      correctIndex: 2
    },
    {
      question: "6. مقارنة المعلومات الواردة من عدة مصادر ثانوية لتقييم الدقة والموثوقية تُسمى:",
      options: [
        "التحقق المتقاطع (Cross-checking)",
        "إعادة إنتاج الوسائط (Media Reproduction)",
        "التخزين السحابي (Cloud Storage)",
        "الترميز الرقمي (Data Encoding)"
      ],
      correctIndex: 0
    }
  ];

  let quizAnswers = new Array(quizData.length).fill(null);

  function renderFinalQuiz() {
    const container = document.getElementById('final-quiz-questions');
    if (!container) return;
    container.innerHTML = '';

    quizData.forEach((q, qIdx) => {
      const qDiv = document.createElement('div');
      qDiv.className = 'tech-card';
      qDiv.style.padding = '16px 20px';
      qDiv.style.marginBottom = '14px';

      const qTitle = document.createElement('div');
      qTitle.style.fontWeight = '800';
      qTitle.style.fontSize = '15.5px';
      qTitle.style.marginBottom = '10px';
      qTitle.textContent = q.question;
      qDiv.appendChild(qTitle);

      const optsDiv = document.createElement('div');
      optsDiv.style.display = 'grid';
      optsDiv.style.gridTemplateColumns = 'repeat(2, 1fr)';
      optsDiv.style.gap = '8px';

      q.options.forEach((opt, optIdx) => {
        const btn = document.createElement('button');
        btn.className = 'quiz-btn';
        btn.style.fontSize = '13.5px';
        btn.style.padding = '10px 14px';
        btn.textContent = opt;

        if (quizAnswers[qIdx] === optIdx) {
          if (optIdx === q.correctIndex) {
            btn.classList.add('correct');
          } else {
            btn.classList.add('wrong');
          }
        }

        btn.addEventListener('click', () => {
          quizAnswers[qIdx] = optIdx;
          renderFinalQuiz();
          evaluateQuizScore();
        });

        optsDiv.appendChild(btn);
      });

      qDiv.appendChild(optsDiv);
      container.appendChild(qDiv);
    });
  }

  function evaluateQuizScore() {
    const answeredCount = quizAnswers.filter(a => a !== null).length;
    let score = 0;
    quizAnswers.forEach((ans, idx) => {
      if (ans === quizData[idx].correctIndex) score++;
    });

    const scoreCard = document.getElementById('quiz-score-card');
    const scoreText = document.getElementById('quiz-score-text');
    const scoreBar = document.getElementById('quiz-score-bar');

    if (answeredCount === quizData.length) {
      scoreCard.style.display = 'block';
      const pct = Math.round((score / quizData.length) * 100);
      scoreText.innerHTML = `نتيجتك: <strong style="color: #00E5FF; font-size: 24px;">${score} / ${quizData.length}</strong> (${pct}%) — ${
        score === quizData.length ? 'ممتاز جداً! فهمت الدرس بنسبة 100% 🌟' : score >= 4 ? 'أداء رائع جداً! استمر 👏' : 'راجع المفاهيم وحاول مرة أخرى 👍'
      }`;
      scoreBar.style.width = pct + '%';
    }
  }

  const resetQuizBtn = document.getElementById('reset-quiz-btn');
  if (resetQuizBtn) {
    resetQuizBtn.addEventListener('click', () => {
      quizAnswers = new Array(quizData.length).fill(null);
      const scoreCard = document.getElementById('quiz-score-card');
      if (scoreCard) scoreCard.style.display = 'none';
      renderFinalQuiz();
    });
  }

  // Initial setup
  resizeCanvas();
  updateSlide(0, true);
  renderFinalQuiz();
});
