import { db } from '../config/firebase';
import { Review } from '../types';
import { DocumentData } from 'firebase-admin/firestore';
import { UserService } from './user.service';

function reviewFromData(id: string, data: DocumentData): Review {
  return {
    id,
    tripId: data.tripId,
    reviewerId: data.reviewerId,
    reviewedId: data.reviewedId,
    rating: data.rating,
    comment: data.comment,
    type: data.type,
    createdAt: data.createdAt?.toDate?.() || new Date(),
  };
}

export class ReviewService {
  private userService = new UserService();

  async createReview(data: {
    tripId: string;
    reviewerId: string;
    reviewedId: string;
    rating: number;
    comment?: string;
    type: 'passenger_to_driver' | 'driver_to_passenger';
  }): Promise<Review> {
    // Check if review already exists for this trip from this reviewer
    const existing = await db.collection('reviews')
      .where('tripId', '==', data.tripId)
      .where('reviewerId', '==', data.reviewerId)
      .limit(1)
      .get();

    if (!existing.empty) {
      throw new Error('You have already reviewed this trip');
    }

    if (data.rating < 1 || data.rating > 5) {
      throw new Error('Rating must be between 1 and 5');
    }

    const reviewData = {
      ...data,
      createdAt: new Date(),
    };

    const docRef = await db.collection('reviews').add(reviewData);

    // Update user rating
    await this.userService.addReviewToUser(data.reviewedId, data.rating);

    return reviewFromData(docRef.id, reviewData);
  }

  async getReviewsForUser(userId: string): Promise<Review[]> {
    const snapshot = await db.collection('reviews')
      .where('reviewedId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();
    return snapshot.docs.map(doc => reviewFromData(doc.id, doc.data()));
  }

  async getReviewsForTrip(tripId: string): Promise<Review[]> {
    const snapshot = await db.collection('reviews')
      .where('tripId', '==', tripId)
      .get();
    return snapshot.docs.map(doc => reviewFromData(doc.id, doc.data()));
  }
}