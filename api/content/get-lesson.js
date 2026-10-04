// api/content/get-lesson.js
// Vercel Serverless Function: Secure Server-Side Paid Lesson Content Protection

const admin = require('firebase-admin');

const SUPER_ADMIN_EMAIL = 'islamatef01016834012@gmail.com';

function initFirebaseAdmin() {
  if (admin.apps.length > 0) {
    return admin.app();
  }

  const rawServiceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || process.env.FIREBASE_SERVICE_ACCOUNT;
  if (rawServiceAccount) {
    try {
      const raw = rawServiceAccount.trim();
      const serviceAccount = raw.startsWith('{')
        ? JSON.parse(raw)
        : JSON.parse(Buffer.from(raw, 'base64').toString('utf8'));
      return admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
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
    return admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai',
    });
  } catch (e) {
    console.error('Default initApp error:', e.message);
    return null;
  }
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const courseId = req.query.courseId || req.body?.courseId;
  const lessonId = req.query.lessonId || req.body?.lessonId;

  if (!courseId || !lessonId) {
    return res.status(400).json({ error: 'MISSING_PARAMS', message: 'courseId and lessonId are required' });
  }

  const app = initFirebaseAdmin();
  if (!app) {
    return res.status(503).json({ error: 'SERVER_UNAVAILABLE', message: 'Firebase service is not initialized' });
  }

  const db = admin.firestore();

  try {
    // 1. Fetch lesson from subcollection or fallback to course doc
    let lessonData = null;
    const lessonSubRef = db.collection('courses').doc(courseId).collection('lessons').doc(lessonId);
    const lessonSnap = await lessonSubRef.get();

    if (lessonSnap.exists) {
      lessonData = { id: lessonSnap.id, ...lessonSnap.data() };
    } else {
      // Fallback: check course doc 'lessons' array
      const courseSnap = await db.collection('courses').doc(courseId).get();
      if (courseSnap.exists) {
        const courseData = courseSnap.data();
        const lessons = courseData.lessons || [];
        lessonData = lessons.find((l) => l.id === lessonId || l.title === lessonId);
      }
    }

    if (!lessonData) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'الدرس غير موجود' });
    }

    const isPaid = lessonData.isPaid === true || lessonData.isFree === false;

    // 2. If lesson is free, return immediately
    if (!isPaid) {
      return res.status(200).json({
        success: true,
        unlocked: true,
        lesson: lessonData,
      });
    }

    // 3. Lesson is paid: verify Authorization
    const authHeader = req.headers.authorization || '';
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(200).json({
        success: true,
        unlocked: false,
        lockedReason: 'AUTH_REQUIRED',
        message: 'هذا الدرس مخصص للمشتركين. يرجى تسجيل الدخول أولاً.',
        preview: {
          id: lessonData.id,
          title: lessonData.title,
          description: lessonData.description,
          image: lessonData.image || lessonData.imageUrl,
          duration: lessonData.duration,
          isPaid: true,
        },
      });
    }

    const idToken = authHeader.split('Bearer ')[1].trim();
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (e) {
      return res.status(401).json({ error: 'INVALID_TOKEN', message: 'جلسة تسجيل الدخول منتهية أو غير صالحة' });
    }

    const uid = decodedToken.uid;
    const email = (decodedToken.email || '').toLowerCase();

    // Check Admin rights
    const isAdmin = (
      decodedToken.admin === true ||
      decodedToken.role === 'admin' ||
      email === SUPER_ADMIN_EMAIL.toLowerCase()
    );

    if (isAdmin) {
      return res.status(200).json({
        success: true,
        unlocked: true,
        lesson: lessonData,
      });
    }

    // Check student subscription in Firestore
    const userSnap = await db.collection('users').doc(uid).get();
    if (!userSnap.exists) {
      return res.status(403).json({
        success: true,
        unlocked: false,
        lockedReason: 'NOT_SUBSCRIBED',
        message: 'أنت غير مشترك في هذا الكورس بعد.',
        preview: {
          id: lessonData.id,
          title: lessonData.title,
          description: lessonData.description,
          image: lessonData.image || lessonData.imageUrl,
          duration: lessonData.duration,
          isPaid: true,
        },
      });
    }

    const userData = userSnap.data();
    if (userData.role === 'admin') {
      return res.status(200).json({
        success: true,
        unlocked: true,
        lesson: lessonData,
      });
    }

    const allowedCourses = userData.allowedCourses || [];
    const allowedLessons = userData.allowedLessons || [];

    const hasAccess = allowedCourses.includes(courseId) || allowedLessons.includes(lessonId);

    if (hasAccess) {
      return res.status(200).json({
        success: true,
        unlocked: true,
        lesson: lessonData,
      });
    }

    // Not subscribed
    return res.status(200).json({
      success: true,
      unlocked: false,
      lockedReason: 'NOT_SUBSCRIBED',
      message: 'هذا المحتوى مخصص للمشتركين في هذا الكورس.',
      preview: {
        id: lessonData.id,
        title: lessonData.title,
        description: lessonData.description,
        image: lessonData.image || lessonData.imageUrl,
        duration: lessonData.duration,
        isPaid: true,
      },
    });
  } catch (error) {
    console.error('get-lesson error:', error);
    return res.status(500).json({ error: 'INTERNAL_ERROR', message: error.message });
  }
};
