// src/routes/discipline.routes.ts
import express from 'express';
import * as ctrl from '../App/Controllers/discipline.controller';
const router = express.Router();

router.get('/', ctrl.listDisciplines);
router.get('/:action_id', ctrl.getDiscipline);
router.post('/', ctrl.createDiscipline);
router.put('/:action_id', ctrl.updateDiscipline);
router.delete('/:action_id', ctrl.deleteDiscipline);

export default router;
