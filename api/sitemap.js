// api/sitemap.js
// Vercel Serverless Function: Dynamic & Automated XML Sitemap Generator for Google Search Console
// Automatically syncs with Cloud Firestore so any newly added course, lesson, or article is indexed immediately.

const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai';
const FIREBASE_API_KEY = process.env.FIREBASE_API_KEY || 'AIzaSyC2cfDKEt__EQmHRDeTUD660w2Ztr2vS5U';

function escapeXml(unsafe) {
  return (unsafe || '')
    .toString()
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

async function fetchFirestoreCollection(collectionName) {
  const url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/${collectionName}?key=${FIREBASE_API_KEY}`;
  try {
    const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
    if (!res.ok) {
      console.warn(`Firestore REST ${collectionName} returned status ${res.status}`);
      return [];
    }
    const data = await res.json();
    return data.documents || [];
  } catch (err) {
    console.error(`Error fetching ${collectionName} from Firestore REST:`, err.message);
    return [];
  }
}

module.exports = async function handler(req, res) {
  const host = req.headers['x-forwarded-host'] || req.headers.host || 'eslamatef-sepia.vercel.app';
  const protocol = req.headers['x-forwarded-proto'] || (host.includes('localhost') ? 'http' : 'https');
  const baseUrl = `${protocol}://${host}`;

  const nowIso = new Date().toISOString();

  // 1. Core Platform Pages
  const urlEntries = [
    { loc: `${baseUrl}/`, lastmod: nowIso, changefreq: 'daily', priority: '1.0' },
    { loc: `${baseUrl}/courses`, lastmod: nowIso, changefreq: 'daily', priority: '0.95' },
    { loc: `${baseUrl}/curricula`, lastmod: nowIso, changefreq: 'daily', priority: '0.90' },
    { loc: `${baseUrl}/blog`, lastmod: nowIso, changefreq: 'daily', priority: '0.90' },
    { loc: `${baseUrl}/challenge`, lastmod: nowIso, changefreq: 'weekly', priority: '0.85' },
    { loc: `${baseUrl}/quiz`, lastmod: nowIso, changefreq: 'weekly', priority: '0.85' },
    { loc: `${baseUrl}/about`, lastmod: nowIso, changefreq: 'monthly', priority: '0.80' },
    { loc: `${baseUrl}/contact`, lastmod: nowIso, changefreq: 'monthly', priority: '0.80' },
    { loc: `${baseUrl}/privacy`, lastmod: nowIso, changefreq: 'monthly', priority: '0.50' },
  ];

  // 2. Fetch Live Courses & Lessons directly from Firestore (Live & Automated)
  try {
    const coursesDocs = await fetchFirestoreCollection('courses');

    for (const doc of coursesDocs) {
      const courseId = doc.name ? doc.name.split('/').pop() : null;
      if (!courseId) continue;

      const fields = doc.fields || {};
      const isPublished = fields.isPublished ? fields.isPublished.booleanValue !== false : true;
      if (!isPublished) continue;

      const updatedTime = doc.updateTime || nowIso;

      // Add Course URL
      urlEntries.push({
        loc: `${baseUrl}/courses?course=${encodeURIComponent(courseId)}`,
        lastmod: updatedTime,
        changefreq: 'weekly',
        priority: '0.90',
      });

      // Add Each Lesson URL inside the course
      const lessonsList = fields.lessons && fields.lessons.arrayValue && fields.lessons.arrayValue.values
        ? fields.lessons.arrayValue.values
        : [];

      for (const lessonVal of lessonsList) {
        const lFields = lessonVal.mapValue ? lessonVal.mapValue.fields : null;
        if (!lFields) continue;

        const lessonId = lFields.id && lFields.id.stringValue ? lFields.id.stringValue : null;
        if (!lessonId) continue;

        const isLessonPublished = lFields.isPublished ? lFields.isPublished.booleanValue !== false : true;
        if (!isLessonPublished) continue;

        urlEntries.push({
          loc: `${baseUrl}/courses?course=${encodeURIComponent(courseId)}&lesson=${encodeURIComponent(lessonId)}`,
          lastmod: updatedTime,
          changefreq: 'weekly',
          priority: '0.85',
        });
      }
    }
  } catch (e) {
    console.error('Error generating dynamic courses in sitemap:', e.message);
  }

  // 3. Fetch Live Articles (المقالات) directly from Firestore
  try {
    const articlesDocs = await fetchFirestoreCollection('articles');

    for (const doc of articlesDocs) {
      const articleId = doc.name ? doc.name.split('/').pop() : null;
      if (!articleId) continue;

      const fields = doc.fields || {};
      const isPublished = fields.isPublished ? fields.isPublished.booleanValue !== false : true;
      if (!isPublished) continue;

      const updatedTime = doc.updateTime || nowIso;

      urlEntries.push({
        loc: `${baseUrl}/blog?id=${encodeURIComponent(articleId)}`,
        lastmod: updatedTime,
        changefreq: 'weekly',
        priority: '0.85',
      });
    }
  } catch (e) {
    console.error('Error generating dynamic articles in sitemap:', e.message);
  }

  // 4. Build XML Sitemap
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urlEntries
  .map(
    (entry) => `  <url>
    <loc>${escapeXml(entry.loc)}</loc>
    <lastmod>${entry.lastmod}</lastmod>
    <changefreq>${entry.changefreq}</changefreq>
    <priority>${entry.priority}</priority>
  </url>`
  )
  .join('\n')}
</urlset>`;

  res.setHeader('Content-Type', 'application/xml; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=300, stale-while-revalidate=600');
  res.status(200).send(xml);
};
