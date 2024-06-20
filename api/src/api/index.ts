import express from 'express';

import MessageResponse from '../interfaces/MessageResponse';
import { emojiRouter } from './emojis';

const router = express.Router();

router.get<{}, MessageResponse>('/', (req, res) => {
  res.json({
    message: 'Hello World, API is working!',
  });
});

router.use('/emojis', emojiRouter);

export default router;
