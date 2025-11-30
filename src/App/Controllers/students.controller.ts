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
} from '@/App/Validations/Students.validator';
import { SsnParamDto } from '@/App/Validations/Students.validator';

type FieldError = { field: string; message: string; };

class StudentController {
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

  static async createStudent(req: Request, res: Response) {
    try {
      const payload = StudentController.parsePayload(res, req.body, CreateStudentBody);
      if (!payload) return;
      if (await StudentService.doesStudentIdExist(payload.student_id)) {
        StudentController.respondWithFieldErrors(res, [{ field: 'student_id', message: STUDENT_ID_ERROR_MESSAGE }], { student_id: payload.student_id }, 409);
        return;
      }
      await StudentService.insertStudent(payload as Student);
      res.status(201).json({ message: 'Student created successfully' });
    } catch (error) {
      const mysqlErrorMessage = (error as QueryError).message || 'Unknown error';
      console.error('Unexpected error when creating student:', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  static async put(req: Request<SsnParamDto>, res: Response): Promise<void> {
    try {
      const { ssn } = req.params;
      const payload = StudentController.parsePayload(res, req.body, UpdateStudentBody);
      if (!payload) return;
      if (payload.ssn !== ssn) {
        StudentController.respondWithFieldErrors(res, [{ field: 'ssn', message: STUDENT_SSN_ERROR_MESSAGE }], { ssn: payload.ssn });
        return;
      }
      if (await StudentService.doesStudentIdExist(payload.student_id, ssn)) {
        StudentController.respondWithFieldErrors(res, [{ field: 'student_id', message: STUDENT_ID_ERROR_MESSAGE }], { student_id: payload.student_id }, 409);
        return;
      }
      await StudentService.updateStudent(payload as Student);
      res.status(200).json({ message: 'Student updated successfully' });
    } catch (error: any) {
      // Bắt lỗi logic từ Service (ví dụ: điểm rèn luyện thấp)
      const message = error.message || 'Unknown error';
      console.error('Update student error:', message);
      res.status(400).json({ success: false, message });
    }
  }

  // --- SỬA HÀM DELETE ---
  static async delete(req: Request, res: Response): Promise<void> {
    try {
      const ssn = req.params.ssn;
      await StudentService.deleteStudent(ssn);
      res.status(200).json({ message: 'Student deleted successfully' });
    } catch (error: any) {
      console.error('Error deleting student:', error);
      // Lấy message lỗi cụ thể từ Service (vd: "Không thể xóa: Sinh viên đang ở phòng...")
      const message = error.message || 'Internal Server Error';
      // Trả về 400 Bad Request để Frontend nhận được message
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
}

export default StudentController;