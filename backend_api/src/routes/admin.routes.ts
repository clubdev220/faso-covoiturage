import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// TODO: Get admin statistics
// GET /stats
router.get('/stats', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: List all users
// GET /users
router.get('/users', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Update user role
// PUT /users/:userId/role
router.put('/users/:userId/role', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;