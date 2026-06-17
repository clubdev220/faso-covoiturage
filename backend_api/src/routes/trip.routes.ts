import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// TODO: List/search trips
// GET /
router.get('/', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Create new trip
// POST /
router.post('/', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Get trip by ID
// GET /:id
router.get('/:id', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Update trip
// PUT /:id
router.put('/:id', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Delete trip
// DELETE /:id
router.delete('/:id', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;