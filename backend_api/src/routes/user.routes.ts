import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// TODO: Get current user profile
// GET /me
router.get('/me', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Update current user profile
// PUT /me
router.put('/me', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Submit KYC documents
// POST /me/kyc
router.post('/me/kyc', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;