import { Router, Response } from 'express';
import { AuthRequest, authenticateToken, requireRole } from '../middleware/auth';
import { TripService } from '../services/trip.service';
import { validateBody } from '../middleware/validator';
import { z } from 'zod';
import { UserRole } from '../types';

const router = Router();
const tripService = new TripService();

const CreateTripSchema = z.object({
  origin: z.object({ latitude: z.number(), longitude: z.number() }),
  originAddress: z.string().min(5),
  originCity: z.string().min(2),
  destination: z.object({ latitude: z.number(), longitude: z.number() }),
  destinationAddress: z.string().min(5),
  destinationCity: z.string().min(2),
  departureDate: z.string().datetime(),
  departureTime: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  arrivalTime: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  totalSeats: z.number().min(1).max(8),
  pricePerSeat: z.number().positive(),
  vehicleInfo: z.object({
    brand: z.string(),
    model: z.string(),
    color: z.string(),
    plateNumber: z.string(),
  }),
  notes: z.string().optional(),
});

const UpdateTripSchema = CreateTripSchema.partial();

const SearchTripSchema = z.object({
  originCity: z.string().optional(),
  destinationCity: z.string().optional(),
  date: z.string().optional(),
  minSeats: z.coerce.number().optional(),
  maxPrice: z.coerce.number().optional(),
  page: z.coerce.number().default(1),
  limit: z.coerce.number().default(20),
});

router.get('/', validateBody(SearchTripSchema), async (req: AuthRequest, res: Response) => {
  try {
    const result = await tripService.searchTrips(req.body);
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/my', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const trips = await tripService.getDriverTrips(req.user!.uid);
    res.json({ trips });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const trip = await tripService.getTripById(req.params.id);
    if (!trip) return res.status(404).json({ error: 'Trip not found' });
    res.json({ trip });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/', authenticateToken, requireRole(UserRole.DRIVER, UserRole.ADMIN), validateBody(CreateTripSchema), async (req: AuthRequest, res: Response) => {
  try {
    const trip = await tripService.createTrip(req.user!.uid, req.body);
    res.status(201).json({ trip });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

router.put('/:id', authenticateToken, validateBody(UpdateTripSchema), async (req: AuthRequest, res: Response) => {
  try {
    const trip = await tripService.updateTrip(req.params.id, req.user!.uid, req.body);
    res.json({ trip });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

router.delete('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    await tripService.cancelTrip(req.params.id, req.user!.uid);
    res.json({ success: true });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default router;