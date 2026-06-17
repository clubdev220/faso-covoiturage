import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { PaymentService } from '../services/payment.service';
import { BookingService } from '../services/booking.service';
import { validateBody } from '../middleware/validator';
import { z } from 'zod';
import { PaymentMethod } from '../types';

const router = Router();
const paymentService = new PaymentService();
const bookingService = new BookingService();

const CreatePaymentSchema = z.object({
  bookingId: z.string(),
  method: z.nativeEnum(PaymentMethod),
});

const OrangeWebhookSchema = z.object({
  transactionId: z.string(),
  status: z.string(),
  amount: z.number(),
  bookingId: z.string(),
});

const StripeWebhookSchema = z.object({
  paymentIntentId: z.string(),
  status: z.string(),
  amount: z.number(),
  bookingId: z.string(),
});

router.post('/create', authenticateToken, validateBody(CreatePaymentSchema), async (req: AuthRequest, res: Response) => {
  try {
    const booking = await bookingService.getBookingById(req.body.bookingId);
    if (!booking) return res.status(404).json({ error: 'Booking not found' });
    if (booking.passengerId !== req.user!.uid) return res.status(403).json({ error: 'Not authorized' });

    const payment = await paymentService.createPayment(req.body.bookingId, booking.totalAmount, req.body.method);
    res.status(201).json({ payment });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

router.post('/orange/webhook', validateBody(OrangeWebhookSchema), async (_req: AuthRequest, res: Response) => {
  try {
    const result = await paymentService.handleOrangeWebhook(_req.body);
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/stripe/webhook', validateBody(StripeWebhookSchema), async (_req: AuthRequest, res: Response) => {
  try {
    const result = await paymentService.handleStripeWebhook(_req.body);
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;