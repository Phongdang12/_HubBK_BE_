import { Router } from 'express';
import StudentController from '../App/Controllers/students.controller';
import { validateAll } from '@/App/Middlewares/validate';
import { SsnParam } from '@/App/Validations/Students.validator';
import { verifyToken } from '@/App/Middlewares/auth';

const router = Router();

// ==================================================================
// ⚠️ CÁC ROUTE CỤ THỂ PHẢI ĐẶT TRƯỚC ROUTE DYNAMIC (/:ssn)
// ==================================================================

// 1. Lấy danh sách options (dropdown)
router.get('/options', StudentController.getStudentOptions);

// 2. Lấy danh sách sinh viên chưa có phòng (Route mới thêm - Đặt ở đây để tránh lỗi 400)
router.get('/without-room', verifyToken, StudentController.getStudentsWithoutRoom);

// 3. Lấy danh sách phân trang
router.get('/paginated', StudentController.getPaginated);

// 4. Lấy danh sách tất cả (Root)
router.get('/', verifyToken, StudentController.getStudent);

// 5. Tạo mới sinh viên
router.post('/', StudentController.createStudent);


// ==================================================================
// ROUTE DYNAMIC (/:ssn) PHẢI ĐẶT CUỐI CÙNG
// ==================================================================

// Lấy chi tiết theo SSN
router.get(
  '/:ssn',
  verifyToken,
  validateAll({ params: SsnParam }),
  StudentController.getStudentBySsn,
);

// Cập nhật thông tin
router.put(
  '/:ssn',
  validateAll({ params: SsnParam }),
  StudentController.put,
);

// Xóa sinh viên
router.delete(
  '/:ssn',
  verifyToken,
  validateAll({ params: SsnParam }),
  StudentController.delete,
);

export default router;