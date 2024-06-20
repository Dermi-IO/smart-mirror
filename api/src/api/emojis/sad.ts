import express from 'express';
import MessageResponse from '../../interfaces/MessageResponse';

const sadRouter = express.Router();

sadRouter.get<{}, MessageResponse>('/', (req, res) => {
  res.json({ message: ['😢'] });
});

export default sadRouter;
