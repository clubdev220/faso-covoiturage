import { db } from '../config/firebase';
import { Payment, PaymentStatus, PaymentMethod } from '../types';
import { DocumentData } from 'firebase-admin/firestore';
import { BookingService } from './booking.service';

function paymentFromData(id: string, data: DocumentData): Payment {
  return {
    id,
    bookingId: data.bookingId,
    amount: data.amount,
    method: data.method,
    status: data.status,
    providerRef: data.providerRef,
    createdAt: data.createdAt?.toDate?.() || new Date(),
    updatedAt: data.updatedAt?.toDate?.() || new Date(),
  };
}

export class PaymentService {
  private bookingService = new BookingService();

  async createPayment(bookingId: string, amount: number, method: PaymentMethod): Promise<Payment> {
    const paymentData = {
      bookingId,
      amount,
      method,
      status: PaymentStatus.PENDING,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    const docRef = await db.collection('payments').add(paymentData);
    return paymentFromData(docRef.id, paymentData);
  }

  async getPaymentById(paymentId: string): Promise<Payment | null> {
    const doc = await db.collection('payments').doc(paymentId).get();
    if (!doc.exists) return null;
    return paymentFromData(doc.id, doc.data());
  }

  async getPaymentByBookingId(bookingId: string): Promise<Payment | null> {
    const snapshot = await db.collection('payments')
      .where('bookingId', '==', bookingId)
      .limit(1)
      .get();
    if (snapshot.empty) return null;
    return paymentFromData(snapshot.docs[0].id, snapshot.docs[0].data());
  }

  async confirmPayment(paymentId: string, providerRef: string): Promise<Payment> {
    await db.collection('payments').doc(paymentId).update({
      status: PaymentStatus.CONFIRMED,
      providerRef,
      updatedAt: new Date(),
    });

    const payment = await this.getPaymentById(paymentId);
    if (payment) {
      await this.bookingService.confirmPayment(payment.bookingId, providerRef);
    }

    return payment!;
  }

  async failPayment(paymentId: string): Promise<void> {
    await db.collection('payments').doc(paymentId).update({
      status: PaymentStatus.FAILED,
      updatedAt: new Date(),
    });
  }

  // Orange Money webhook simulation (mock - real integration needs Orange API credentials)
  async handleOrangeWebhook(payload: {
    transactionId: string;
    status: string;
    amount: number;
    bookingId: string;
  }): Promise<{ success: boolean; message: string }> {
    const payment = await this.getPaymentByBookingId(payload.bookingId);
    if (!payment) return { success: false, message: 'Payment not found' };

    if (payload.status === 'SUCCESS') {
      await this.confirmPayment(payment.id, payload.transactionId);
      return { success: true, message: 'Payment confirmed' };
    } else {
      await this.failPayment(payment.id);
      return { success: false, message: 'Payment failed' };
    }
  }

  // Stripe webhook simulation (mock - real integration needs Stripe SDK)
  async handleStripeWebhook(payload: {
    paymentIntentId: string;
    status: string;
    amount: number;
    bookingId: string;
  }): Promise<{ success: boolean; message: string }> {
    const payment = await this.getPaymentByBookingId(payload.bookingId);
    if (!payment) return { success: false, message: 'Payment not found' };

    if (payload.status === 'succeeded') {
      await this.confirmPayment(payment.id, payload.paymentIntentId);
      return { success: true, message: 'Payment confirmed' };
    } else {
      await this.failPayment(payment.id);
      return { success: false, message: 'Payment failed' };
    }
  }
}