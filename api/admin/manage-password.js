// api/admin/manage-password.js
// Vercel Serverless Function to securely manage student passwords using Firebase Admin SDK
// Prevents storing passwords in Firestore or SharedPreferences

const admin = require('firebase-admin');

// Super admin email with irrevocable master privilege
const SUPER_ADMIN_EMAIL = 'islamatef01016834012@gmail.com';

function initFirebaseAdmin() {
  if (admin.apps.length > 0) {
    return admin.app();
  }

  // 1. Try FIREBASE_SERVICE_ACCOUNT_KEY or FIREBASE_SERVICE_ACCOUNT (full JSON or base64)
  const rawServiceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || process.env.FIREBASE_SERVICE_ACCOUNT;
  if (rawServiceAccount) {
    let serviceAccount;
    try {
      const raw = rawServiceAccount.trim();
      if (raw.startsWith('{')) {
        serviceAccount = JSON.parse(raw);
      } else {
        const decoded = Buffer.from(raw, 'base64').toString('utf8');
        serviceAccount = JSON.parse(decoded);
      }
      return admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    } catch (e) {
      console.error('Failed to parse Firebase Service Account:', e.message);
    }
  }

  // 2. Try individual env variables
  if (process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    return admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai',
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      }),
    });
  }

  // 3. Fallback to default credentials
  try {
    return admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID || 'eslam-atef-code-ai',
    });
  } catch (e) {
    console.error('Failed default initializeApp:', e.message);
    return null;
  }
}

module.exports = async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'METHOD_NOT_ALLOWED', message: 'Only POST method is allowed' });
  }

  // Extract ID Token
  const authHeader = req.headers.authorization || '';
  if (!authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Missing or invalid Authorization header' });
  }
  const idToken = authHeader.split('Bearer ')[1].trim();

  // Initialize Firebase Admin
  let app;
  try {
    app = initFirebaseAdmin();
  } catch (e) {
    console.error('Firebase Admin init error:', e);
  }

  if (!app) {
    return res.status(503).json({
      error: 'SERVER_CREDENTIALS_MISSING',
      message: 'خدمة السيرفر تتطلب إضافة متغير بيئة FIREBASE_SERVICE_ACCOUNT في لوحة تحكم Vercel لتفعيل التغيير المباشر لكلمات المرور.',
    });
  }

  try {
    // 1. Verify caller ID Token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const callerUid = decodedToken.uid;
    const callerEmail = decodedToken.email || '';

    // 2. Verify caller is Admin
    let isCallerAdmin = (
      decodedToken.admin === true ||
      decodedToken.role === 'admin' ||
      callerEmail.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase()
    );

    if (!isCallerAdmin) {
      // Check in Firestore users collection
      const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
      if (callerDoc.exists && callerDoc.data()?.role === 'admin') {
        isCallerAdmin = true;
      }
    }

    if (!isCallerAdmin) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'عذراً، هذه العملية مخصصة لمديري النظام فقط.' });
    }

    const { action, targetUid, newPassword, targetEmail } = req.body || {};

    if (!action) {
      return res.status(400).json({ error: 'MISSING_ACTION', message: 'Action parameter is required' });
    }

    // ==============================================================
    // ACTION: sanitize_database (Clean old plaintext passwords)
    // ==============================================================
    if (action === 'sanitize_database') {
      const usersSnap = await admin.firestore().collection('users')
        .where('adminAssignedPassword', '!=', null)
        .get();

      let cleanedCount = 0;
      const batch = admin.firestore().batch();
      usersSnap.forEach((doc) => {
        batch.update(doc.ref, {
          adminAssignedPassword: admin.firestore.FieldValue.delete(),
        });
        cleanedCount++;
      });

      if (cleanedCount > 0) {
        await batch.commit();
      }

      return res.status(200).json({
        success: true,
        cleanedCount,
        message: `تم تنظيف وتطهير ${cleanedCount} كلمة مرور قديمة من قاعدة البيانات بنجاح.`,
      });
    }

    // For user-specific actions, targetUid or targetEmail is required
    if (!targetUid && !targetEmail) {
      return res.status(400).json({ error: 'MISSING_TARGET', message: 'targetUid or targetEmail is required' });
    }

    // Check target user role to prevent modifying other admins (unless super admin)
    if (targetUid) {
      const targetDoc = await admin.firestore().collection('users').doc(targetUid).get();
      if (targetDoc.exists) {
        const targetData = targetDoc.data();
        const isTargetAdmin = targetData?.role === 'admin' || (targetData?.email && targetData.email.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase());
        const isSuperAdmin = callerEmail.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase();

        if (isTargetAdmin && !isSuperAdmin) {
          return res.status(403).json({
            error: 'CANNOT_MODIFY_ADMIN',
            message: 'لا يمكنك تعديل كلمة مرور حساب إداري آخر. هذه الصلاحية محصورة بحساب الإدارة الأساسي فقط.',
          });
        }
      }
    }

    // ==============================================================
    // ACTION: set_password
    // ==============================================================
    if (action === 'set_password') {
      if (!targetUid) {
        return res.status(400).json({ error: 'MISSING_TARGET_UID', message: 'targetUid is required' });
      }
      if (!newPassword || typeof newPassword !== 'string' || newPassword.length < 6) {
        return res.status(400).json({ error: 'INVALID_PASSWORD', message: 'كلمة المرور يجب أن لا تقل عن 6 خانات' });
      }

      // Update password directly in Firebase Authentication (Hashed securely by Google)
      await admin.auth().updateUser(targetUid, {
        password: newPassword,
      });

      // Update Firestore user document WITHOUT plaintext password
      // Delete old adminAssignedPassword and mark as reset by admin
      await admin.firestore().collection('users').doc(targetUid).set({
        adminAssignedPassword: admin.firestore.FieldValue.delete(),
        passwordStatus: 'assigned_by_admin',
        passwordUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return res.status(200).json({
        success: true,
        message: 'تم تعيين كلمة المرور الجديدة في Firebase Authentication بنجاح دون تخزين أي نص في قاعدة البيانات.',
      });
    }

    // ==============================================================
    // ACTION: send_reset_link
    // ==============================================================
    if (action === 'send_reset_link') {
      const email = targetEmail || (targetUid ? (await admin.auth().getUser(targetUid)).email : null);
      if (!email) {
        return res.status(400).json({ error: 'MISSING_EMAIL', message: 'Target user does not have a valid email' });
      }

      const resetLink = await admin.auth().generatePasswordResetLink(email);

      return res.status(200).json({
        success: true,
        link: resetLink,
        message: `تم إنشاء رابط إعادة تعيين كلمة المرور الرسمي للحساب: ${email}`,
      });
    }

    return res.status(400).json({ error: 'UNKNOWN_ACTION', message: `Action '${action}' is not recognized` });
  } catch (error) {
    console.error('manage-password error:', error);
    return res.status(500).json({
      error: 'INTERNAL_ERROR',
      message: error.message || 'حدث خطأ غير متوقع أثناء معالجة الطلب',
    });
  }
};
