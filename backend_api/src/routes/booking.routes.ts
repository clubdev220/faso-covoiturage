import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// TODO: Create new booking
// POST /
router.post('/', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Get current user's bookings
// GET /my
router.get('/my', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Update booking status
// PUT /:id/status
router.put('/:id/status', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;