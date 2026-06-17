import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// TODO: Create payment
// POST /create
router.post('/create', authenticateToken, (req: AuthRequest, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Orange Money webhook
// POST /orange/webhook
router.post('/orange/webhook', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Stripe webhook
// POST /stripe/webhook
router.post('/stripe/webhook', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;