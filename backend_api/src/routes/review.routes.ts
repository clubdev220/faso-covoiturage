import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { ReviewService } from '../services/review.service';
import { validateBody } from '../middleware/validator';
import { z } from 'zod';

const router = Router();
const reviewService = new ReviewService();

const CreateReviewSchema = z.object({
  tripId: z.string(),
  reviewedId: z.string(),
  rating: z.number().min(1).max(5),
  comment: z.string().max(500).optional(),
  type: z.enum(['passenger_to_driver', 'driver_to_passenger']),
});

router.post('/', authenticateToken, validateBody(CreateReviewSchema), async (req: AuthRequest, res: Response) => {
  try {
    const review = await reviewService.createReview({
      ...req.body,
      reviewerId: req.user!.uid,
    });
    res.status(201).json({ review });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/users/:userId', async (req: AuthRequest, res: Response) => {
  try {
    const reviews = await reviewService.getReviewsForUser(req.params.userId);
    res.json({ reviews });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/trip/:tripId', async (req: AuthRequest, res: Response) => {
  try {
    const reviews = await reviewService.getReviewsForTrip(req.params.tripId);
    res.json({ reviews });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;