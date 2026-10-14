// api/preview.js
// Vercel Serverless Function: Social Media Crawler Dynamic Previews (OG & Twitter Cards)

let admin = null;
try {
  admin = require('firebase-admin');
} catch (e) {
  // Graceful fallback
}

const BOT_PATTERNS = [
  'facebookexternalhit',
  'Facebot',
  'Twitterbot',
  'TelegramBot',
  'WhatsApp',
  'LinkedInBot',
  'Slackbot',
  'Discordbot',
  'Googlebot',
  'bingbot',
  'Applebot',
];

function isBot(userAgent = '') {
  const ua = userAgent.toLowerCase();
  return BOT_PATTERNS.some((bot) => ua.includes(bot.toLowerCase()));
}

function initFirebaseAdmin() {
  if (!admin) return null;
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
      console.error('Service Account parse error in preview:', e.message);
    }
  }
  try {
    return admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai' });
  } catch (e) {
    return null;
  }
}

module.exports = async function handler(req, res) {
  const userAgent = req.headers['user-agent'] || '';
  const host = req.headers['x-forwarded-host'] || req.headers.host || 'eslamatef-sepia.vercel.app';
  const protocol = req.headers['x-forwarded-proto'] || (host.includes('localhost') ? 'http' : 'https');
  const baseUrl = `${protocol}://${host}`;

  const { courseId, lessonId, articleId } = req.query;

  // If a real user visits, redirect them to the Flutter Single Page Application route
  if (!isBot(userAgent)) {
    if (courseId && lessonId) {
      return res.redirect(302, `${baseUrl}/#/courses/${courseId}/lessons/${lessonId}`);
    } else if (courseId) {
      return res.redirect(302, `${baseUrl}/#/courses/${courseId}`);
    } else if (articleId) {
      return res.redirect(302, `${baseUrl}/#/blog/${articleId}`);
    }
    return res.redirect(302, `${baseUrl}/`);
  }

  // Fallback defaults
  let title = 'منصة إسلام عاطف | تعليم علوم الحاسب والذكاء الاصطناعي';
  let description = 'Think. Code. Build with AI. مسارات عملية وتفاعلية لتعلم البرمجة وهندسة الذكاء الاصطناعي مع مستر إسلام عاطف.';
  let image = `${baseUrl}/assets/assets/images/logo.jpeg`;
  let pageUrl = baseUrl;

  try {
    const app = initFirebaseAdmin();
    if (app && admin) {
      const db = admin.firestore();

      if (courseId && lessonId) {
      pageUrl = `${baseUrl}/courses/${courseId}/lessons/${lessonId}`;
      const lSnap = await db.collection('courses').doc(courseId).collection('lessons').doc(lessonId).get();
      if (lSnap.exists) {
        const lData = lSnap.data();
        title = `${lData.title || 'درس تفاعلي'} | مستر إسلام عاطف`;
        description = lData.description || lData.summary || description;
        if (lData.thumbnailUrl) image = lData.thumbnailUrl;
      }
    } else if (courseId) {
      pageUrl = `${baseUrl}/courses/${courseId}`;
      const cSnap = await db.collection('courses').doc(courseId).get();
      if (cSnap.exists) {
        const cData = cSnap.data();
        title = `${cData.title || 'كورس تعليمي'} | منصة إسلام عاطف`;
        description = cData.description || cData.shortDescription || description;
        if (cData.imageUrl) image = cData.imageUrl;
      }
    } else if (articleId) {
      pageUrl = `${baseUrl}/blog/${articleId}`;
      const aSnap = await db.collection('articles').doc(articleId).get();
      if (aSnap.exists) {
        const aData = aSnap.data();
        title = `${aData.title || 'مقال تقني'} | إسلام عاطف`;
        description = aData.summary || aData.description || description;
        if (aData.coverImage) image = aData.coverImage;
      }
    }
    }
  } catch (err) {
    console.error('Error fetching preview data:', err.message);
  }

  const safeTitle = String(title).replace(/"/g, '&quot;');
  const safeDesc = String(description).replace(/"/g, '&quot;');

  const html = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <title>${safeTitle}</title>
  <meta name="description" content="${safeDesc}">
  <link rel="canonical" href="${pageUrl}">

  <!-- OpenGraph -->
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="Eslam Atef | Code & AI">
  <meta property="og:url" content="${pageUrl}">
  <meta property="og:title" content="${safeTitle}">
  <meta property="og:description" content="${safeDesc}">
  <meta property="og:image" content="${image}">
  <meta property="og:locale" content="ar_EG">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:url" content="${pageUrl}">
  <meta name="twitter:title" content="${safeTitle}">
  <meta name="twitter:description" content="${safeDesc}">
  <meta name="twitter:image" content="${image}">
</head>
<body style="font-family: sans-serif; background: #070b14; color: #fff; padding: 20px;">
  <h1>${safeTitle}</h1>
  <p>${safeDesc}</p>
</body>
</html>`;

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
  res.status(200).send(html);
};
