// api/google-verify.js
// Direct Google Search Console verification response on Vercel

module.exports = (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.status(200).send('google-site-verification: googleaddb405a7a55dda6.html');
};
