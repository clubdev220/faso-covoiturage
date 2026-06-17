import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { UserService } from '../services/user.service';
import { validateBody } from '../middleware/validator';
import { z } from 'zod';

const router = Router();
const userService = new UserService();

const UpdateProfileSchema = z.object({
  displayName: z.string().min(2).max(50).optional(),
  photoUrl: z.string().url().optional(),
});

const KycSchema = z.object({
  idCardNumber: z.string().min(5).max(20),
  idCardFrontUrl: z.string().url(),
  idCardBackUrl: z.string().url(),
});

router.get('/me', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const user = await userService.getUserById(req.user!.uid);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.put('/me', authenticateToken, validateBody(UpdateProfileSchema), async (req: AuthRequest, res: Response) => {
  try {
    const user = await userService.updateUser(req.user!.uid, req.body);
    res.json({ user });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/me/kyc', authenticateToken, validateBody(KycSchema), async (req: AuthRequest, res: Response) => {
  try {
    await userService.updateKycStatus(req.user!.uid, 'pending', req.body);
    res.json({ success: true, message: 'KYC submitted for review' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;