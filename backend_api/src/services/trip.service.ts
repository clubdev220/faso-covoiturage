import { db } from '../config/firebase';
import { Trip, Location } from '../types';
import { DocumentData } from 'firebase-admin/firestore';

function tripFromData(id: string, data: DocumentData): Trip {
  return {
    id,
    driverId: data.driverId,
    driverName: data.driverName || '',
    origin: data.origin,
    destination: data.destination,
    departureTime: data.departureTime?.toDate?.() || new Date(),
    arrivalTime: data.arrivalTime?.toDate?.() || new Date(),
    availableSeats: data.availableSeats,
    totalSeats: data.totalSeats,
    pricePerSeat: data.pricePerSeat,
    vehicleInfo: data.vehicleInfo,
    status: data.status || 'scheduled',
    bookingIds: data.bookingIds || [],
    createdAt: data.createdAt?.toDate?.() || new Date(),
    updatedAt: data.updatedAt?.toDate?.() || new Date(),
  };
}

export interface TripSearchFilters {
  origin?: Location;
  destination?: Location;
  departureDate?: Date;
  availableSeats?: number;
  maxPrice?: number;
  status?: Trip['status'];
}

export class TripService {
  async createTrip(driverId: string, tripData: Omit<Trip, 'id' | 'createdAt' | 'updatedAt'>): Promise<Trip> {
    const data = {
      ...tripData,
      driverId,
      bookingIds: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    const docRef = await db.collection('trips').add(data);
    return tripFromData(docRef.id, data);
  }

  async getTripById(tripId: string): Promise<Trip | null> {
    const doc = await db.collection('trips').doc(tripId).get();
    if (!doc.exists) return null;
    return tripFromData(doc.id, doc.data());
  }

  async searchTrips(filters: TripSearchFilters, page: number, limit: number): Promise<{ trips: Trip[]; total: number }> {
    let query: FirebaseFirestore.Query = db.collection('trips');
    
    if (filters.status) {
      query = query.where('status', '==', filters.status);
    }
    if (filters.availableSeats !== undefined) {
      query = query.where('availableSeats', '>=', filters.availableSeats);
    }
    if (filters.maxPrice !== undefined) {
      query = query.where('pricePerSeat', '<=', filters.maxPrice);
    }
    
    query = query.orderBy('departureTime', 'asc');
    
    const snapshot = await query.get();
    const trips = snapshot.docs.map(doc => tripFromData(doc.id, doc.data()));
    
    return { trips, total: trips.length };
  }

  async updateTrip(tripId: string, driverId: string, updates: Partial<Trip>): Promise<Trip> {
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');
    if (trip.driverId !== driverId) throw new Error('Not authorized');

    await db.collection('trips').doc(tripId).update({
      ...updates,
      updatedAt: new Date(),
    });

    return (await this.getTripById(tripId))!;
  }

  async cancelTrip(tripId: string, driverId: string): Promise<void> {
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');
    if (trip.driverId !== driverId) throw new Error('Not authorized');

    await db.collection('trips').doc(tripId).update({
      status: 'cancelled',
      updatedAt: new Date(),
    });
  }

  async getDriverTrips(driverId: string, page: number, limit: number): Promise<{ trips: Trip[]; total: number }> {
    const snapshot = await db.collection('trips')
      .where('driverId', '==', driverId)
      .orderBy('createdAt', 'desc')
      .get();
    
    const trips = snapshot.docs.map(doc => tripFromData(doc.id, doc.data()));
    return { trips, total: trips.length };
  }

  async updateTripStatus(tripId: string, status: Trip['status']): Promise<void> {
    await db.collection('trips').doc(tripId).update({
      status,
      updatedAt: new Date(),
    });
  }

  async reserveSeats(tripId: string, seats: number): Promise<void> {
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');
    if (trip.availableSeats < seats) throw new Error('Not enough seats available');

    await db.collection('trips').doc(tripId).update({
      availableSeats: trip.availableSeats - seats,
      updatedAt: new Date(),
    });
  }

  async releaseSeats(tripId: string, seats: number): Promise<void> {
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');

    await db.collection('trips').doc(tripId).update({
      availableSeats: trip.availableSeats + seats,
      updatedAt: new Date(),
    });
  }

  async addBookingToTrip(tripId: string, bookingId: string, seats: number): Promise<void> {
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');

    await db.collection('trips').doc(tripId).update({
      bookingIds: [...trip.bookingIds, bookingId],
      availableSeats: trip.availableSeats - seats,
      updatedAt: new Date(),
    });
  }

  async removeBookingFromTrip(tripId: string, bookingId: string, seats: number): Promise<void> {
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');

    await db.collection('trips').doc(tripId).update({
      bookingIds: trip.bookingIds.filter(id => id !== bookingId),
      availableSeats: trip.availableSeats + seats,
      updatedAt: new Date(),
    });
  }

  async calculateETA(tripId: string, currentLocation: Location): Promise<{ eta: Date; distance: number }> {
    // Mock implementation - real implementation would use maps API
    const trip = await this.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');
    
    return {
      eta: trip.departureTime,
      distance: 0,
    };
  }
}

export const tripService = new TripService();