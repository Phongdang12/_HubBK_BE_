import { Request, Response } from 'express';
import { StudentService } from '@/Services/students.service';
import { Student } from '@/Interfaces/student.interface';
import { QueryError } from 'mysql2';
import {
  CreateStudentBody,
  UpdateStudentBody,
  STUDENT_GENERAL_ERROR_MESSAGE,
  STUDENT_ID_ERROR_MESSAGE,
  STUDENT_SSN_ERROR_MESSAGE,
  SsnParamDto,
} from '@/App/Validations/Students.validator';

type FieldError = { field: string; message: string; };

class StudentController {
  
  // =================================================================
  // 🛠️ HELPER FUNCTIONS (XỬ LÝ LỖI & VALIDATION)
  // =================================================================

  private static logValidationError(message: string, value?: unknown) {
    const printable = value === undefined || value === null || value === '' ? 'Không có' : JSON.stringify(value);
    console.error(`Lỗi: ${message} Giá trị được chọn: ${printable}.`);
  }

  private static respondWithFieldErrors(res: Response, fieldErrors: FieldError[], source?: Record<string, unknown>, status = 400) {
    fieldErrors.forEach(({ field, message }) => {
      const value = source ? source[field] : undefined;
      StudentController.logValidationError(message, value);
    });
    res.status(status).json({ error: STUDENT_GENERAL_ERROR_MESSAGE, fieldErrors });
  }

  private static mapIssues(issues: any[]): FieldError[] {
    return issues.map((issue) => ({ field: issue.path?.[0]?.toString() || 'form', message: issue.message }));
  }

  private static parsePayload(res: Response, rawBody: unknown, schema: any) {
    const parsed = schema.safeParse(rawBody);
    if (!parsed.success) {
      StudentController.respondWithFieldErrors(res, StudentController.mapIssues(parsed.error.issues), rawBody as Record<string, unknown>);
      return null;
    }
    return parsed.data;
  }

  /**
   * ⚡ XỬ LÝ LỖI DATABASE (MYSQL)
   * Chuyển lỗi "Duplicate entry" thành lỗi hiển thị trên UI
   */
  private static handleDatabaseError(res: Response, error: any, payload: any) {
    // Mã lỗi 1062 là Duplicate Entry (Trùng lặp dữ liệu unique)
    if (error.code === 'ER_DUP_ENTRY' || error.errno === 1062) {
      const message = error.message || '';

      // 1. Kiểm tra trùng CCCD
      // MySQL trả về dạng: Duplicate entry '012345...' for key 'student.cccd'
      if (message.includes('cccd')) {
        StudentController.respondWithFieldErrors(
          res,
          [{ field: 'cccd', message: 'Số CCCD này đã tồn tại trong hệ thống.' }], 
          payload, 
          409 // Conflict Status
        );
        return;
      }

      // 2. Kiểm tra trùng MSSV
      if (message.includes('student_id')) {
        StudentController.respondWithFieldErrors(
          res,
          [{ field: 'student_id', message: 'Mã số sinh viên này đã tồn tại.' }],
          payload,
          409
        );
        return;
      }
      
      // 3. Nếu trùng SSN (thường do hệ thống sinh lỗi hoặc race condition)
      if (message.includes('PRIMARY') || message.includes('sssn')) {
         res.status(500).json({ message: 'Lỗi hệ thống: Trùng mã định danh SSN nội bộ. Vui lòng thử lại.' });
         return;
      }
    }

    // Các lỗi khác không xác định (Lỗi SQL cú pháp, mất kết nối, v.v.)
    console.error('Database Unexpected Error:', error);
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ.', detail: error.message });
  }

  // =================================================================
  // 🚀 MAIN HANDLERS
  // =================================================================

  static async getStudentsWithoutRoom(req: Request, res: Response) {
    try {
      const data = await StudentService.getStudentsWithoutRoom();
      res.json(data);
    } catch (error) {
      console.error('getStudentsWithoutRoom error:', error);
      res.status(500).json({ message: 'Failed to fetch available students' });
    }
  }

  static async getStudent(req: Request, res: Response) {
    try {
      const students: Student[] = await StudentService.getAllStudents();
      const formatted = students.map((student: Student) => ({
        cccd: student.cccd || '',
        ssn: student.ssn || '',
        first_name: student.first_name || '',
        last_name: student.last_name || '',
        birthday: student.birthday || null,
        sex: student.sex || '',
        health_state: student.health_state || 'Unknown',
        ethnic_group: student.ethnic_group || 'Unknown',
        student_id: student.student_id || '',
        has_health_insurance: student.has_health_insurance || false,
        study_status: student.study_status || 'Unknown',
        class_name: student.class_name || 'Unknown',
        faculty: student.faculty || 'Unknown',
        building_id: student.building_id || null,
        room_id: student.room_id || null,
        phone_numbers: student.phone_numbers || '',
        emails: student.emails || '',
        addresses: student.addresses || '',
      }));
      res.status(200).json(formatted.filter((s) => s.ssn));
    } catch (error) {
      console.error('Error fetching students:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  }

  static async getPaginated(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 8;
      const sorts = req.query.sorts ? JSON.parse(req.query.sorts as string) : [];
      const split = (v?: string) => v ? v.split(',').map(x => x.trim()).filter(Boolean) : undefined;
      const filters = {
        faculty: split(req.query.faculty as string | undefined),
        room: split(req.query.room as string | undefined),
        building: split(req.query.building as string | undefined),
        status: split(req.query.status as string | undefined),
      };
      const result = await StudentService.getPaginated(page, limit, sorts, filters);
      res.status(200).json(result);
    } catch (error) {
      console.error('getPaginated error:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  }

  static async getStudentBySsn(req: Request, res: Response): Promise<void> {
    try {
      const ssn = req.params.ssn;
      const students: Student[] = await StudentService.getStudentBySsn(ssn);
      const student = students[0];
      if (!student) {
        res.status(404).json({ message: 'Student not found' });
        return;
      }
      res.status(200).json(student);
    } catch (error) {
      console.error('getStudentBySsn error:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  }

  // --- CREATE STUDENT (Đã sửa để bắt lỗi DB) ---
  static async createStudent(req: Request, res: Response) {
    let payload;
    try {
      payload = StudentController.parsePayload(res, req.body, CreateStudentBody);
      if (!payload) return;

      // Check trùng student_id thủ công (Optional - DB cũng sẽ check lại)
      if (await StudentService.doesStudentIdExist(payload.student_id)) {
        StudentController.respondWithFieldErrors(res, [{ field: 'student_id', message: STUDENT_ID_ERROR_MESSAGE }], { student_id: payload.student_id }, 409);
        return;
      }

      await StudentService.insertStudent(payload as Student);
      res.status(201).json({ message: 'Student created successfully' });
    } catch (error) {
      // Gọi hàm xử lý lỗi DB tập trung
      StudentController.handleDatabaseError(res, error, payload);
    }
  }

  // --- UPDATE STUDENT (Đã sửa để bắt lỗi DB) ---
  static async put(req: Request<SsnParamDto>, res: Response): Promise<void> {
    let payload;
    try {
      const { ssn } = req.params;
      payload = StudentController.parsePayload(res, req.body, UpdateStudentBody);
      if (!payload) return;

      if (payload.ssn !== ssn) {
        StudentController.respondWithFieldErrors(res, [{ field: 'ssn', message: STUDENT_SSN_ERROR_MESSAGE }], { ssn: payload.ssn });
        return;
      }

      // Check logic nghiệp vụ (ví dụ: điểm rèn luyện thấp, v.v...)
      // Các logic này ném ra Error thông thường, không phải QueryError
      await StudentService.updateStudent(payload as Student);
      
      res.status(200).json({ message: 'Student updated successfully' });
    } catch (error: any) {
      // Phân biệt lỗi logic (400) và lỗi DB (Duplicate/SQL Error)
      if (error.message && !error.code && !error.errno) {
         // Lỗi logic từ Service (ví dụ: Không đủ điểm rèn luyện, còn phòng...)
         res.status(400).json({ success: false, message: error.message });
         return;
      }

      // Gọi hàm xử lý lỗi DB
      StudentController.handleDatabaseError(res, error, payload);
    }
  }

  static async delete(req: Request, res: Response): Promise<void> {
    try {
      const ssn = req.params.ssn;
      await StudentService.deleteStudent(ssn);
      res.status(200).json({ message: 'Student deleted successfully' });
    } catch (error: any) {
      console.error('Error deleting student:', error);
      const message = error.message || 'Internal Server Error';
      res.status(400).json({ message });
    }
  }

  static async getStudentOptions(req: Request, res: Response) {
    try {
      const data = await StudentService.getStudentOptions();
      res.json(data);
    } catch (error) {
      res.status(500).json({ message: 'Failed to fetch student options' });
    }
  }
  static async checkExistence(req: Request, res: Response) {
  try {
    const { field, value } = req.query;

    if (!value || typeof value !== 'string') {
      res.status(400).json({ message: 'Value is required' });
      return;
    }

    let exists = false;

    if (field === 'student_id') {
      exists = await StudentService.doesStudentIdExist(value);
    } 
    // Cho phép check cả cccd (sinh viên) và guardian_cccd (người thân)
    // Nếu guardian_cccd trùng với bất kỳ sinh viên nào trong hệ thống -> Báo exists
    else if (field === 'cccd' || field === 'guardian_cccd') {
      exists = await StudentService.doesCccdExist(value);
    } else {
      res.status(400).json({ message: 'Invalid field check' });
      return;
    }

    res.status(200).json({ exists });
  } catch (error) {
    console.error('Check existence error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
}
}

export default StudentController;