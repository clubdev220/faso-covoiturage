import admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID || 'faso-covoiturage-dev',
  });
}

export const db = admin.firestore();
export const auth = admin.auth();
export default admin;