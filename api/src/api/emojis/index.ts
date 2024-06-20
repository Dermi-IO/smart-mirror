import express from 'express';
import { happyRouter } from './happy';
import sadRouter from './sad';
import MessageResponse from '../../interfaces/MessageResponse';

const router = express.Router();

router.get<{}, MessageResponse>('/', (req, res) => {
  res.send({ message: 'Emoji router' });
});

router.use('/happy', happyRouter);
router.use('/sad', sadRouter);

export { router as emojiRouter };
