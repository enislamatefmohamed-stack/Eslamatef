// api/gamification/award-points.js
// Vercel Serverless Function: Secure Server-Side Points & Badges Management

const admin = require('firebase-admin');

const SUPER_ADMIN_EMAIL = 'islamatef01016834012@gmail.com';

function initFirebaseAdmin() {
  if (admin.apps.length > 0) return admin.app();

  const rawServiceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || process.env.FIREBASE_SERVICE_ACCOUNT;
  if (rawServiceAccount) {
    try {
      const raw = rawServiceAccount.trim();
      const serviceAccount = raw.startsWith('{')
        ? JSON.parse(raw)
        : JSON.parse(Buffer.from(raw, 'base64').toString('utf8'));
      return admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    } catch (e) {
      console.error('Failed to parse Firebase Service Account:', e.message);
    }
  }

  if (process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    return admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai',
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      }),
    });
  }

  try {
    return admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai' });
  } catch (e) {
    return null;
  }
}

// Badges catalogue definitions
const BADGES = {
  first_lesson: {
    id: 'first_lesson',
    title: '🟢 بداية الرحلة',
    description: 'إكمال أول درس تعليمي في المنصة',
    icon: 'school',
  },
  ten_lessons: {
    id: 'ten_lessons',
    title: '📚 محب التعلم',
    description: 'إكمال 10 دروس تعليمية',
    icon: 'auto_stories',
  },
  first_course: {
    id: 'first_course',
    title: '💻 المبرمج الصغير',
    description: 'إكمال أول كورس برمجة كامل',
    icon: 'laptop_chromebook',
  },
  algo_master: {
    id: 'algo_master',
    title: '🧠 عقل الخوارزميات',
    description: 'اجتياز اختبار بنسبة 90% أو أكثر',
    icon: 'psychology',
  },
  five_quizzes_90: {
    id: 'five_quizzes_90',
    title: '🎯 دقة الامتحان',
    description: 'اجتياز 5 اختبارات مختلفة بنسبة 90% فأعلى',
    icon: 'military_tech',
  },
  streak_5: {
    id: 'streak_5',
    title: '🔥 المثابر',
    description: 'متابعة التعلم وإكمال الدروس عبر 5 أيام مختلفة',
    icon: 'local_fire_department',
  },
  five_challenges: {
    id: 'five_challenges',
    title: '🏅 بطل التحديات',
    description: 'إكمال 5 تحديات برمجية أسبوعية بنجاح',
    icon: 'emoji_events',
  },
  five_courses: {
    id: 'five_courses',
    title: '👑 خبير التعلم',
    description: 'إكمال 5 كورسات كاملة في المنصة',
    icon: 'workspace_premium',
  },
};

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const authHeader = req.headers.authorization || '';
  if (!authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Authorization header is required' });
  }

  const idToken = authHeader.split('Bearer ')[1].trim();
  const app = initFirebaseAdmin();
  if (!app) {
    return res.status(503).json({ error: 'SERVER_UNAVAILABLE', message: 'Firebase admin is not initialized' });
  }

  let decodedToken;
  try {
    decodedToken = await admin.auth().verifyIdToken(idToken);
  } catch (e) {
    return res.status(401).json({ error: 'INVALID_TOKEN', message: 'Invalid or expired authentication token' });
  }

  const callerUid = decodedToken.uid;
  const callerEmail = (decodedToken.email || '').toLowerCase();
  const isCallerAdmin = (
    decodedToken.admin === true ||
    decodedToken.role === 'admin' ||
    callerEmail === SUPER_ADMIN_EMAIL.toLowerCase()
  );

  const db = admin.firestore();

  // GET: Return gamification profile (Points, badges, history)
  if (req.method === 'GET') {
    const targetUid = (req.query.uid && isCallerAdmin) ? req.query.uid : callerUid;
    const userDoc = await db.collection('users').doc(targetUid).get();
    const data = userDoc.exists ? userDoc.data() : {};

    return res.status(200).json({
      success: true,
      points: data.points || 0,
      earnedBadges: data.earnedBadges || [],
      completedLessons: data.completedLessons || [],
      completedCourses: data.completedCourses || [],
      allBadges: BADGES,
    });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'METHOD_NOT_ALLOWED' });
  }

  const { type, refId, courseId, percentage, customPoints, customReason, targetUid } = req.body || {};

  // Action by admin: manual award
  if (type === 'manual_admin') {
    if (!isCallerAdmin) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'Only admins can manually adjust points' });
    }
    if (!targetUid || !customPoints || typeof customPoints !== 'number') {
      return res.status(400).json({ error: 'INVALID_DATA', message: 'targetUid and customPoints are required' });
    }

    const userRef = db.collection('users').doc(targetUid);
    await db.runTransaction(async (t) => {
      const snap = await t.get(userRef);
      const current = snap.exists ? (snap.data().points || 0) : 0;
      const newPoints = Math.max(0, current + customPoints);
      t.set(userRef, { points: newPoints, lastPointsUpdate: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

      const txRef = userRef.collection('points_history').doc();
      t.set(txRef, {
        points: customPoints,
        type: 'manual_admin',
        reason: customReason || 'مكافأة إدارية تشجيعية',
        adminEmail: callerEmail,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return res.status(200).json({ success: true, message: 'تم تحديث رصيد النقاط بنجاح.' });
  }

  // Student actions: Complete lesson, complete course, pass quiz, complete challenge
  const userRef = db.collection('users').doc(callerUid);

  try {
    const result = await db.runTransaction(async (t) => {
      const userSnap = await t.get(userRef);
      if (!userSnap.exists) throw new Error('User profile does not exist');

      const userData = userSnap.data();
      const currentPoints = userData.points || 0;
      const completedLessons = userData.completedLessons || [];
      const completedCourses = userData.completedCourses || [];
      const passedQuizzes = userData.passedQuizzes || {}; // { quizId: percentage }
      const completedChallenges = userData.completedChallenges || [];
      const earnedBadges = userData.earnedBadges || [];
      const earnedBadgeIds = earnedBadges.map((b) => b.id);

      let pointsToAdd = 0;
      let reason = '';
      const newlyEarnedBadges = [];

      // 1. LESSON COMPLETION
      if (type === 'complete_lesson') {
        if (!refId) throw new Error('Missing lesson refId');
        if (completedLessons.includes(refId)) {
          return { alreadyRewarded: true, points: currentPoints, message: 'الدرس مكتمل مسبقاً' };
        }

        completedLessons.push(refId);
        const isFirst = completedLessons.length === 1;
        pointsToAdd = isFirst ? 10 : 5;
        reason = isFirst ? 'إكمال أول درس في المنصة (10 نقاط)' : `إكمال الدرس: ${refId} (5 نقاط)`;

        // Check Badges
        if (isFirst && !earnedBadgeIds.includes('first_lesson')) {
          newlyEarnedBadges.push({ ...BADGES.first_lesson, earnedAt: new Date().toISOString() });
        }
        if (completedLessons.length >= 10 && !earnedBadgeIds.includes('ten_lessons')) {
          newlyEarnedBadges.push({ ...BADGES.ten_lessons, earnedAt: new Date().toISOString() });
        }
      }

      // 2. COURSE COMPLETION
      else if (type === 'complete_course') {
        if (!refId) throw new Error('Missing course refId');
        if (completedCourses.includes(refId)) {
          return { alreadyRewarded: true, points: currentPoints, message: 'الكورس مكتمل مسبقاً' };
        }

        completedCourses.push(refId);
        pointsToAdd = 50;
        reason = `إكمال جميع دروس الكورس: ${refId} (50 نقطة إضافية)`;

        if (completedCourses.length === 1 && !earnedBadgeIds.includes('first_course')) {
          newlyEarnedBadges.push({ ...BADGES.first_course, earnedAt: new Date().toISOString() });
        }
        if (completedCourses.length >= 5 && !earnedBadgeIds.includes('five_courses')) {
          newlyEarnedBadges.push({ ...BADGES.five_courses, earnedAt: new Date().toISOString() });
        }
      }

      // 3. QUIZ PASSING
      else if (type === 'pass_quiz') {
        if (!refId) throw new Error('Missing quiz refId');
        const scorePct = Number(percentage) || 0;
        if (scorePct < 70) {
          return { alreadyRewarded: false, points: currentPoints, message: 'نسبة النجاح أقل من 70%' };
        }

        const prevScore = passedQuizzes[refId] || 0;
        if (prevScore >= 90) {
          return { alreadyRewarded: true, points: currentPoints, message: 'تم احتساب الدرجة القصوى مسبقاً' };
        }

        if (scorePct >= 90) {
          if (prevScore >= 70) {
            pointsToAdd = 10; // Upgrade from 10 to 20
            reason = `ترقية نتيجة الاختبار ${refId} إلى 90%+ (+10 نقاط)`;
          } else {
            pointsToAdd = 20;
            reason = `اجتياز الاختبار ${refId} بامتياز 90%+ (20 نقطة)`;
          }
          passedQuizzes[refId] = scorePct;

          if (!earnedBadgeIds.includes('algo_master')) {
            newlyEarnedBadges.push({ ...BADGES.algo_master, earnedAt: new Date().toISOString() });
          }
        } else {
          // 70% to 89%
          if (prevScore >= 70) {
            return { alreadyRewarded: true, points: currentPoints, message: 'الاختبار مجتاز مسبقاً' };
          }
          pointsToAdd = 10;
          reason = `اجتياز الاختبار ${refId} بنسبة ${scorePct}% (10 نقاط)`;
          passedQuizzes[refId] = scorePct;
        }

        // Check five_quizzes_90 badge
        const count90 = Object.values(passedQuizzes).filter((p) => p >= 90).length;
        if (count90 >= 5 && !earnedBadgeIds.includes('five_quizzes_90')) {
          newlyEarnedBadges.push({ ...BADGES.five_quizzes_90, earnedAt: new Date().toISOString() });
        }
      }

      // 4. WEEKLY CHALLENGE
      else if (type === 'complete_challenge') {
        if (!refId) throw new Error('Missing challenge refId');
        if (completedChallenges.includes(refId)) {
          return { alreadyRewarded: true, points: currentPoints, message: 'التحدي مكتمل مسبقاً' };
        }

        completedChallenges.push(refId);
        pointsToAdd = 25;
        reason = `إكمال التحدي الأسبوعي: ${refId} (25 نقطة)`;

        if (completedChallenges.length >= 5 && !earnedBadgeIds.includes('five_challenges')) {
          newlyEarnedBadges.push({ ...BADGES.five_challenges, earnedAt: new Date().toISOString() });
        }
      } else {
        throw new Error('Unknown points type');
      }

      const updatedPoints = currentPoints + pointsToAdd;
      const allEarnedBadges = [...earnedBadges, ...newlyEarnedBadges];

      // Update Firestore document atomically
      t.update(userRef, {
        points: updatedPoints,
        completedLessons,
        completedCourses,
        passedQuizzes,
        completedChallenges,
        earnedBadges: allEarnedBadges,
        lastPointsUpdate: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Record transaction
      if (pointsToAdd > 0) {
        const txRef = userRef.collection('points_history').doc();
        t.set(txRef, {
          points: pointsToAdd,
          type,
          refId,
          reason,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {
        alreadyRewarded: false,
        pointsAwarded: pointsToAdd,
        newTotal: updatedPoints,
        newlyEarnedBadges,
        reason,
      };
    });

    return res.status(200).json({ success: true, ...result });
  } catch (err) {
    console.error('Error awarding points:', err);
    return res.status(500).json({ error: 'TRANSACTION_ERROR', message: err.message });
  }
};
