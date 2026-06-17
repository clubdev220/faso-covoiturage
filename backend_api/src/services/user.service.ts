import { db } from '../config/firebase';
import { User, UserRole } from '../types';
import { DocumentData, QuerySnapshot } from 'firebase-admin/firestore';

function userFromData(id: string, data: DocumentData): User {
  return {
    id,
    email: data.email,
    phone: data.phone,
    displayName: data.displayName,
    photoUrl: data.photoUrl,
    role: data.role || UserRole.PASSENGER,
    kycStatus: data.kycStatus || 'none',
    rating: data.rating || 0,
    reviewCount: data.reviewCount || 0,
    createdAt: data.createdAt?.toDate?.() || new Date(),
    updatedAt: data.updatedAt?.toDate?.() || new Date(),
  };
}

export class UserService {
  async getUserById(uid: string): Promise<User | null> {
    const doc = await db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return userFromData(doc.id, doc.data()!);
  }

  async getUserByPhone(phone: string): Promise<User | null> {
    const snapshot = await db.collection('users').where('phone', '==', phone).limit(1).get();
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return userFromData(doc.id, doc.data());
  }

  async createUser(uid: string, data: Partial<User>): Promise<User> {
    const userData = {
      ...data,
      rating: 0,
      reviewCount: 0,
      kycStatus: 'none',
      role: data.role || UserRole.PASSENGER,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    await db.collection('users').doc(uid).set(userData);
    return userFromData(uid, userData);
  }

  async updateUser(uid: string, data: Partial<User>): Promise<User> {
    const updates = { ...data, updatedAt: new Date() };
    await db.collection('users').doc(uid).update(updates);
    return (await this.getUserById(uid))!;
  }

  async updateKycStatus(uid: string, status: 'pending' | 'verified' | 'rejected', kycData?: object): Promise<void> {
    await db.collection('users').doc(uid).update({
      kycStatus: status,
      ...(kycData && { kycData }),
      updatedAt: new Date(),
    });
  }

  async listUsers(page: number = 1, limit: number = 20, role?: UserRole): Promise<{ users: User[]; total: number }> {
    let query: any = db.collection('users');
    if (role) query = query.where('role', '==', role);
    const snapshot = await query.limit(limit).offset((page - 1) * limit).get();
    const users = snapshot.docs.map(doc => userFromData(doc.id, doc.data()));
    const totalSnap = await db.collection('users').count().get();
    return { users, total: totalSnap.data().count };
  }

  async addReviewToUser(uid: string, newRating: number): Promise<void> {
    const user = await this.getUserById(uid);
    if (!user) return;
    const totalRating = user.rating * user.reviewCount + newRating;
    const newCount = user.reviewCount + 1;
    await db.collection('users').doc(uid).update({
      rating: totalRating / newCount,
      reviewCount: newCount,
    });
  }
}