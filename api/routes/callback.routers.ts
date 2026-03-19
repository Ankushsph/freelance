// callback.router.ts
import { Router, type Request, type Response } from 'express';

const router = Router();

// Temporary in-memory storage for Instagram codes
let instagramCodes: string[] = [];

router.get('/instagram', (req: Request, res: Response) => {
  const code = req.query.code as string;

  if (!code) {
    return res.status(400).json({ error: 'Missing code query parameter' });
  }

  // Save code temporarily
  instagramCodes.push(code);

  console.log('Received Instagram code:', code);
  console.log('All saved codes so far:', instagramCodes);

  return res.status(200).json({
    message: 'Code received successfully',
    code,
    totalSavedCodes: instagramCodes.length
  });
});

// Optional: endpoint to check saved codes
router.get('/instagram/codes', (_req: Request, res: Response) => {
  res.json({ savedCodes: instagramCodes });
});

let facebookCodes: string[] = [];

router.get('/facebook', (req: Request, res: Response) => {
  const code = req.query.code as string;

  if (!code) {
    return res.status(400).json({ error: 'Missing code query parameter' });
  }

  // Save code temporarily
  facebookCodes.push(code);

  console.log('Received Instagram code:', code);
  console.log('All saved codes so far:', facebookCodes);

  return res.status(200).json({
    message: 'Code received successfully',
    code,
    totalSavedCodes: facebookCodes.length
  });
});

// Optional: endpoint to check saved codes
router.get('/facebook/codes', (_req: Request, res: Response) => {
  res.json({ savedCodes: facebookCodes });
});

export default router;
