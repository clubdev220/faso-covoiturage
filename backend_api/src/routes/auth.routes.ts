import { Router } from 'express';

const router = Router();

// TODO: Implement phone OTP send endpoint
// POST /phone/send
router.post('/phone/send', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Implement phone OTP verify endpoint
// POST /phone/verify
router.post('/phone/verify', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Implement email register endpoint
// POST /email/register
router.post('/email/register', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Implement email login endpoint
// POST /email/login
router.post('/email/login', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

// TODO: Implement refresh token endpoint
// POST /refresh
router.post('/refresh', (req, res) => {
  res.status(501).json({ success: false, message: 'Not implemented' });
});

export default router;