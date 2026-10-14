// api/sitemap.js
// Vercel Serverless Function: Dynamic XML Sitemap Generator from Firestore

let admin = null;
try {
  admin = require('firebase-admin');
} catch (e) {
  // Graceful fallback if firebase-admin is not installed locally
}

function initFirebaseAdmin() {
  if (!admin) return null;
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
  const host = req.headers['x-forwarded-host'] || req.headers.host || 'eslamatef-sepia.vercel.app';
  const protocol = req.headers['x-forwarded-proto'] || (host.includes('localhost') ? 'http' : 'https');
  const baseUrl = `${protocol}://${host}`;

  // Default core URLs
  const nowIso = new Date().toISOString();
  const urlEntries = [
    { loc: `${baseUrl}/`, lastmod: nowIso, changefreq: 'daily', priority: '1.0' },
    { loc: `${baseUrl}/courses`, lastmod: nowIso, changefreq: 'daily', priority: '0.9' },
    { loc: `${baseUrl}/blog`, lastmod: nowIso, changefreq: 'daily', priority: '0.8' },
    { loc: `${baseUrl}/about`, lastmod: nowIso, changefreq: 'monthly', priority: '0.7' },
  ];

  try {
    const app = initFirebaseAdmin();
    if (app) {
      const db = admin.firestore();
      
      // Fetch published courses
      const coursesSnap = await db.collection('courses').get().catch(() => ({ docs: [] }));
      for (const courseDoc of coursesSnap.docs) {
        const cData = courseDoc.data();
        if (cData.isPublished === false) continue;

        const cUpdated = cData.updatedAt
          ? (cData.updatedAt.toDate ? cData.updatedAt.toDate().toISOString() : nowIso)
          : nowIso;

        urlEntries.push({
          loc: `${baseUrl}/courses/${courseDoc.id}`,
          lastmod: cUpdated,
          changefreq: 'weekly',
          priority: '0.85',
        });

        // Subcollection: lessons
        try {
          const lessonsSnap = await courseDoc.ref.collection('lessons').get();
          for (const lessonDoc of lessonsSnap.docs) {
            const lData = lessonDoc.data();
            if (lData.isPublished === false) continue;

            const lUpdated = lData.updatedAt
              ? (lData.updatedAt.toDate ? lData.updatedAt.toDate().toISOString() : cUpdated)
              : cUpdated;

            urlEntries.push({
              loc: `${baseUrl}/courses/${courseDoc.id}/lessons/${lessonDoc.id}`,
              lastmod: lUpdated,
              changefreq: 'weekly',
              priority: '0.8',
            });
          }
        } catch (subErr) {
          console.warn(`Could not fetch lessons for course ${courseDoc.id}:`, subErr.message);
        }
      }

      // Fetch published articles (if any)
      try {
        const articlesSnap = await db.collection('articles').get();
        for (const aDoc of articlesSnap.docs) {
          const aData = aDoc.data();
          if (aData.isPublished === false) continue;
          const aUpdated = aData.updatedAt
            ? (aData.updatedAt.toDate ? aData.updatedAt.toDate().toISOString() : nowIso)
            : nowIso;
          urlEntries.push({
            loc: `${baseUrl}/blog/${aDoc.id}`,
            lastmod: aUpdated,
            changefreq: 'weekly',
            priority: '0.75',
          });
        }
      } catch (artErr) {
        // articles collection might not exist yet
      }
    }
  } catch (err) {
    console.error('Error querying Firestore for sitemap:', err.message);
  }

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urlEntries
  .map(
    (entry) => `  <url>
    <loc>${entry.loc}</loc>
    <lastmod>${entry.lastmod}</lastmod>
    <changefreq>${entry.changefreq}</changefreq>
    <priority>${entry.priority}</priority>
  </url>`
  )
  .join('\n')}
</urlset>`;

  res.setHeader('Content-Type', 'application/xml; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
  res.status(200).send(xml);
};
