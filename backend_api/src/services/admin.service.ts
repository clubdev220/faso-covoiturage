import { db } from '../config/firebase';
import { UserRole } from '../types';
import { DocumentData } from 'firebase-admin/firestore';

export class AdminService {
  async getStats(): Promise<{
    totalUsers: number;
    totalDrivers: number;
    totalTrips: number;
    activeTrips: number;
    totalBookings: number;
    totalRevenue: number;
  }> {
    const [usersSnap, driversSnap, tripsSnap, bookingsSnap] = await Promise.all([
      db.collection('users').count().get(),
      db.collection('users').where('role', '==', UserRole.DRIVER).count().get(),
      db.collection('trips').count().get(),
      db.collection('bookings').count().get(),
    ]);

    const activeTripsSnap = await db.collection('trips').where('status', '==', 'active').count().get();
    const bookings = await db.collection('bookings').where('paymentStatus', '==', 'confirmed').get();
    let totalRevenue = 0;
    bookings.docs.forEach(doc => {
      totalRevenue += doc.data().totalAmount || 0;
    });

    return {
      totalUsers: usersSnap.data().count,
      totalDrivers: driversSnap.data().count,
      totalTrips: tripsSnap.data().count,
      activeTrips: activeTripsSnap.data().count,
      totalBookings: bookingsSnap.data().count,
      totalRevenue,
    };
  }

  async getUsersByRole(role: UserRole, page: number = 1, limit: number = 20) {
    const snapshot = await db.collection('users')
      .where('role', '==', role)
      .limit(limit)
      .offset((page - 1) * limit)
      .get();

    const users = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        email: data.email,
        phone: data.phone,
        displayName: data.displayName,
        role: data.role,
        rating: data.rating || 0,
        kycStatus: data.kycStatus,
        createdAt: data.createdAt?.toDate?.() || new Date(),
      };
    });

    return { users, page, limit };
  }

  async updateUserRole(userId: string, role: UserRole): Promise<void> {
    await db.collection('users').doc(userId).update({ role, updatedAt: new Date() });
  }

  async getAllReports(page: number = 1, limit: number = 20) {
    const snapshot = await db.collection('reports')
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .offset((page - 1) * limit)
      .get();

    const reports = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate?.() || new Date(),
    }));

    return { reports, page, limit };
  }

  async createReport(reporterId: string, reportedUserId: string, reason: string, description: string) {
    const reportData = {
      reporterId,
      reportedUserId,
      reason,
      description,
      status: 'pending',
      createdAt: new Date(),
    };
    await db.collection('reports').add(reportData);
    return { success: true };
  }
}