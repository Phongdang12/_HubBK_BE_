// fileName: src/Routes/disciplineForm.routes.ts
import express from 'express';
import * as ctrl from '../App/Controllers/disciplineForm.controller';

const router = express.Router();

router.get('/', ctrl.listForms);
router.post('/', ctrl.addForm);
router.delete('/:id', ctrl.removeForm);
router.put('/:id/toggle', ctrl.toggleStatus);
export default router;