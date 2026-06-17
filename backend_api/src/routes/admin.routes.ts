import { Router, Response } from 'express';
import { AuthRequest, authenticateToken, requireRole } from '../middleware/auth';
import { AdminService } from '../services/admin.service';
import { UserRole } from '../types';
import { validateBody } from '../middleware/validator';
import { z } from 'zod';

const router = Router();
const adminService = new AdminService();

router.get('/stats', authenticateToken, requireRole(UserRole.ADMIN), async (_req: AuthRequest, res: Response) => {
  try {
    const stats = await adminService.getStats();
    res.json(stats);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/users', authenticateToken, requireRole(UserRole.ADMIN), async (req: AuthRequest, res: Response) => {
  try {
    const role = req.query.role as UserRole | undefined;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const result = await adminService.getUsersByRole(role!, page, limit);
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

const UpdateRoleSchema = z.object({
  role: z.nativeEnum(UserRole),
});

router.put('/users/:userId/role', authenticateToken, requireRole(UserRole.ADMIN), validateBody(UpdateRoleSchema), async (req: AuthRequest, res: Response) => {
  try {
    await adminService.updateUserRole(req.params.userId, req.body.role);
    res.json({ success: true });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/reports', authenticateToken, requireRole(UserRole.ADMIN), async (req: AuthRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const result = await adminService.getAllReports(page, limit);
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

const CreateReportSchema = z.object({
  reportedUserId: z.string(),
  reason: z.string(),
  description: z.string(),
});

router.post('/reports', authenticateToken, validateBody(CreateReportSchema), async (req: AuthRequest, res: Response) => {
  try {
    const result = await adminService.createReport(req.user!.uid, req.body.reportedUserId, req.body.reason, req.body.description);
    res.status(201).json(result);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default router;