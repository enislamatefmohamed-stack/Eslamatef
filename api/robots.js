// api/robots.js
// Vercel Serverless Function: Dynamic Robots.txt for Search Engines

module.exports = (req, res) => {
  const host = req.headers['x-forwarded-host'] || req.headers.host || 'eslamatef-sepia.vercel.app';
  const protocol = req.headers['x-forwarded-proto'] || (host.includes('localhost') ? 'http' : 'https');

  const robotsContent = `# Robots.txt for Eslam Atef | Code & AI Platform
User-agent: *
Allow: /
Allow: /courses
Allow: /courses?*
Allow: /curricula
Allow: /challenge
Allow: /quiz
Allow: /about
Allow: /contact
Allow: /privacy

# Block admin panel, internal sessions, and API endpoints
Disallow: /admin
Disallow: /admin/*
Disallow: /api/*
Disallow: /presentation/*
Disallow: /session/*
Disallow: /auth/
Disallow: /*?*fbclid=*
Disallow: /*?*utm_*

# Dynamic Sitemap
Sitemap: ${protocol}://${host}/sitemap.xml
`;

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Cache-Control', 'public, s-maxage=86400, stale-while-revalidate=86400');
  res.status(200).send(robotsContent);
};
