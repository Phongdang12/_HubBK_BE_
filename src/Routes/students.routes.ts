import { Router } from 'express';
import StudentController from '../App/Controllers/students.controller';
import { validateAll } from '@/App/Middlewares/validate';
import { SsnParam } from '@/App/Validations/Students.validator';
import { verifyToken } from '@/App/Middlewares/auth';

const router = Router();

router.get('/paginated', StudentController.getPaginated);
router.get('/', verifyToken, StudentController.getStudent);
router.post('/', StudentController.createStudent);
router.get(
  '/:ssn',
  verifyToken,
  validateAll({ params: SsnParam }),
  StudentController.getStudentBySsn,
);
router.put(
  '/:ssn',
  validateAll({ params: SsnParam }),
  StudentController.put,
);
router.delete(
  '/:ssn',
  verifyToken,
  validateAll({ params: SsnParam }),
  StudentController.delete,
);

export default router;
