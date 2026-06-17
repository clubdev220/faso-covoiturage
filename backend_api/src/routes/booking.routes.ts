import { Router, Response } from 'express';
import { AuthRequest, authenticateToken, requireRole } from '../middleware/auth';
import { BookingService } from '../services/booking.service';
import { validateBody } from '../middleware/validator';
import { z } from 'zod';
import { UserRole, BookingStatus, PaymentMethod } from '../types';

const router = Router();
const bookingService = new BookingService();

const CreateBookingSchema = z.object({
  tripId: z.string(),
  seats: z.number().min(1).max(8),
  paymentMethod: z.nativeEnum(PaymentMethod),
});

const UpdateBookingStatusSchema = z.object({
  status: z.nativeEnum(BookingStatus),
});

router.post('/', authenticateToken, validateBody(CreateBookingSchema), async (req: AuthRequest, res: Response) => {
  try {
    const { tripId, seats, paymentMethod } = req.body;
    const booking = await bookingService.createBooking(req.user!.uid, tripId, seats, paymentMethod);
    res.status(201).json({ booking });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/my', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const bookings = await bookingService.getPassengerBookings(req.user!.uid);
    res.json({ bookings });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/trip/:tripId', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const bookings = await bookingService.getTripBookings(req.params.tripId);
    res.json({ bookings });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.put('/:id/status', authenticateToken, requireRole(UserRole.DRIVER, UserRole.ADMIN), validateBody(UpdateBookingStatusSchema), async (req: AuthRequest, res: Response) => {
  try {
    const booking = await bookingService.updateBookingStatus(req.params.id, req.user!.uid, req.body.status);
    res.json({ booking });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default router;