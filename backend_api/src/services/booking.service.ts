import { db } from '../config/firebase';
import { Booking, BookingStatus, PaymentStatus, PaymentMethod } from '../types';
import { DocumentData } from 'firebase-admin/firestore';
import { TripService } from './trip.service';
import { PaymentService } from './payment.service';

function bookingFromData(id: string, data: DocumentData): Booking {
  return {
    id,
    tripId: data.tripId,
    passengerId: data.passengerId,
    seats: data.seats,
    totalAmount: data.totalAmount,
    status: data.status,
    paymentStatus: data.paymentStatus,
    paymentMethod: data.paymentMethod,
    createdAt: data.createdAt?.toDate?.() || new Date(),
    updatedAt: data.updatedAt?.toDate?.() || new Date(),
  };
}

export class BookingService {
  private tripService = new TripService();
  private paymentService = new PaymentService();

  async createBooking(passengerId: string, tripId: string, seats: number, paymentMethod: PaymentMethod): Promise<Booking> {
    const trip = await this.tripService.getTripById(tripId);
    if (!trip) throw new Error('Trip not found');
    if (trip.status !== 'active') throw new Error('Trip is not active');
    if (trip.availableSeats < seats) throw new Error('Not enough seats available');
    if (trip.driverId === passengerId) throw new Error('Cannot book your own trip');

    const totalAmount = trip.pricePerSeat * seats;

    const bookingData = {
      tripId,
      passengerId,
      seats,
      totalAmount,
      status: BookingStatus.PENDING,
      paymentStatus: PaymentStatus.PENDING,
      paymentMethod,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const docRef = await db.collection('bookings').add(bookingData);
    
    // Reserve seats immediately
    await this.tripService.reserveSeats(tripId, seats);

    return bookingFromData(docRef.id, bookingData);
  }

  async getBookingById(bookingId: string): Promise<Booking | null> {
    const doc = await db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    return bookingFromData(doc.id, doc.data());
  }

  async updateBookingStatus(bookingId: string, driverId: string, status: BookingStatus): Promise<Booking> {
    const booking = await this.getBookingById(bookingId);
    if (!booking) throw new Error('Booking not found');

    const trip = await this.tripService.getTripById(booking.tripId);
    if (!trip) throw new Error('Trip not found');
    if (trip.driverId !== driverId) throw new Error('Not authorized');

    if (status === BookingStatus.REJECTED || status === BookingStatus.CANCELLED) {
      // Release seats
      await this.tripService.releaseSeats(booking.tripId, booking.seats);
    }

    await db.collection('bookings').doc(bookingId).update({
      status,
      updatedAt: new Date(),
    });

    return (await this.getBookingById(bookingId))!;
  }

  async confirmPayment(bookingId: string, providerRef: string): Promise<void> {
    const booking = await this.getBookingById(bookingId);
    if (!booking) throw new Error('Booking not found');

    await db.collection('bookings').doc(bookingId).update({
      paymentStatus: PaymentStatus.CONFIRMED,
      status: BookingStatus.ACCEPTED,
      updatedAt: new Date(),
    });
  }

  async getPassengerBookings(passengerId: string): Promise<Booking[]> {
    const snapshot = await db.collection('bookings')
      .where('passengerId', '==', passengerId)
      .orderBy('createdAt', 'desc')
      .get();
    return snapshot.docs.map(doc => bookingFromData(doc.id, doc.data()));
  }

  async getTripBookings(tripId: string): Promise<Booking[]> {
    const snapshot = await db.collection('bookings')
      .where('tripId', '==', tripId)
      .orderBy('createdAt', 'desc')
      .get();
    return snapshot.docs.map(doc => bookingFromData(doc.id, doc.data()));
  }
}