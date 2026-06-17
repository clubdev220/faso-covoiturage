import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// TODO: Create review
// POST /
router.post('/', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Get reviews for a user
// GET /users/:userId
router.get('/users/:userId', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;