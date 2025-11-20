import { Request, Response } from 'express';
import { StudentService } from '@/Services/students.service';
import { Student } from '@/Interfaces/student.interface';
import { QueryError } from 'mysql2';
import {
  StudentBody,
  StudentBodyDto,
  STUDENT_GENERAL_ERROR_MESSAGE,
  STUDENT_ID_ERROR_MESSAGE,
  STUDENT_SSN_ERROR_MESSAGE,
} from '@/App/Validations/Students.validator';
import { SsnParamDto } from '@/App/Validations/Students.validator';

type FieldError = {
  field: string;
  message: string;
};

class StudentController {
  private static logValidationError(message: string, value?: unknown) {
    const printable =
      value === undefined || value === null || value === ''
        ? 'Không có'
        : JSON.stringify(value);
    console.error(`Lỗi: ${message} Giá trị được chọn: ${printable}.`);
  }

  private static respondWithFieldErrors(
    res: Response,
    fieldErrors: FieldError[],
    source?: Record<string, unknown>,
    status = 400,
  ) {
    fieldErrors.forEach(({ field, message }) => {
      const value = source ? source[field] : undefined;
      StudentController.logValidationError(message, value);
    });
    res.status(status).json({
      error: STUDENT_GENERAL_ERROR_MESSAGE,
      fieldErrors,
    });
  }

  private static mapIssues(issues: any[]): FieldError[] {
    return issues.map((issue) => ({
      field: issue.path?.[0]?.toString() || 'form',
      message: issue.message,
    }));
  }

  private static parseStudentPayload(
    res: Response,
    rawBody: unknown,
  ): StudentBodyDto | null {
    const parsed = StudentBody.safeParse(rawBody);
    if (!parsed.success) {
      StudentController.respondWithFieldErrors(
        res,
        StudentController.mapIssues(parsed.error.issues),
        rawBody as Record<string, unknown>,
      );
      return null;
    }
    return parsed.data;
  }

  private static async ensureUniqueIdentifiers(
    res: Response,
    payload: StudentBodyDto,
    excludeSsn?: string,
  ): Promise<boolean> {
    const ssn = payload.ssn as string;
    const studentId = payload.student_id as string;

    if (!excludeSsn && (await StudentService.doesSsnExist(ssn))) {
      StudentController.respondWithFieldErrors(
        res,
        [{ field: 'ssn', message: STUDENT_SSN_ERROR_MESSAGE }],
        { ssn },
        409,
      );
      return false;
    }

    if (
      await StudentService.doesStudentIdExist(studentId, excludeSsn)
    ) {
      StudentController.respondWithFieldErrors(
        res,
        [{ field: 'student_id', message: STUDENT_ID_ERROR_MESSAGE }],
        { student_id: studentId },
        409,
      );
      return false;
    }

    return true;
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

      // Ensure we always return an array with safe values
      res.status(200).json(formatted.filter(student => student.ssn));
    } catch (error) {
      console.error('Error fetching students:', error);
      res.status(500).json({ 
        message: 'Internal Server Error',
        error: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }
  }
  static async getPaginated(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 8;

      const result = await StudentService.getPaginated(page, limit);

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
      const student: Student | undefined = students[0];

      if (!student) {
        res.status(404).json({ message: 'Student not found' });
        return;
      }

      // ✅ Giữ nguyên tất cả dữ liệu sinh viên
      const formatted = {
  ssn: student.ssn,
  cccd: student.cccd,
  first_name: student.first_name,
  last_name: student.last_name,
  birthday: student.birthday,
  sex: student.sex,
  health_state: student.health_state || 'Unknown',
  ethnic_group: student.ethnic_group || 'Unknown',

  student_id: student.student_id,
  has_health_insurance: student.has_health_insurance,
  study_status: student.study_status || 'Unknown',
  class_name: student.class_name || 'Unknown',
  faculty: student.faculty || 'Unknown',
  building_id: student.building_id,
  room_id: student.room_id,

  phone_numbers: student.phone_numbers,
  emails: student.emails,
  addresses: student.addresses,

  // ✅ Thêm đầy đủ Guardian Info
  guardian_cccd: student.guardian_cccd,
  guardian_name: student.guardian_name,
  guardian_relationship: student.guardian_relationship,
  guardian_occupation: student.guardian_occupation,
  guardian_birthday: student.guardian_birthday,
  guardian_phone_numbers: student.guardian_phone_numbers,
  guardian_addresses: student.guardian_addresses,
};

      res.status(200).json(formatted);
    } catch (error) {
      console.error('getStudentBySsn error:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  }


  static async createStudent(req: Request, res: Response) {
    try {
      const payload = StudentController.parseStudentPayload(res, req.body);
      if (!payload) return;

      const isUnique = await StudentController.ensureUniqueIdentifiers(
        res,
        payload,
      );
      if (!isUnique) return;

      await StudentService.insertStudent(payload as Student);
      res.status(201).json({ message: 'Student created successfully' });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Unexpected error when creating student:', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  static async put(
    req: Request<SsnParamDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { ssn } = req.params;
      const payload = StudentController.parseStudentPayload(res, req.body);
      if (!payload) return;

      if (payload.ssn !== ssn) {
        StudentController.respondWithFieldErrors(
          res,
          [{ field: 'ssn', message: STUDENT_SSN_ERROR_MESSAGE }],
          { ssn: payload.ssn },
        );
        return;
      }

      const isUnique = await StudentController.ensureUniqueIdentifiers(
        res,
        payload,
        ssn,
      );
      if (!isUnique) return;

      await StudentService.updateStudent(payload as Student);
      res.status(200).json({ message: 'Student updated successfully' });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Unexpected error when updating student:', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  static async delete(req: Request, res: Response): Promise<void> {
    try {
      const ssn = req.params.ssn;
      console.log('Attempting to delete student with SSN:', ssn);
      await StudentService.deleteStudent(ssn);
      console.log('Student deleted successfully');
      res.status(200).json({ message: 'Student deleted successfully' });
    } catch (error) {
      console.error('Error deleting student:', error);
      const err = error as any;
      res.status(500).json({ 
        message: 'Internal Server Error',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
      });
    }
  }
  
}

export default StudentController;
