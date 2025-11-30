import pool from '@/Config/db.config';
import { Student } from '@/Interfaces/student.interface';

const POINTS_MAP: Record<string, number> = { low: 2, medium: 5, high: 10, expulsion: 31 };

export class StudentService {
  // ========================================
  // GET ALL STUDENTS
  // ========================================
  static async getAllStudents(): Promise<Student[]> {
    const result: any = await pool.query('CALL get_all_students()');
    const rows = result[0][0];

    if (Array.isArray(rows)) {
      return rows.map((row: any) => ({
        ...row,
        ssn: row.sssn || row.ssn,
        cccd: row.cccd,
      })) as Student[];
    }
    throw new Error('Unexpected result format');
  }

  // ========================================
  // GET STUDENT BY SSN
  // ========================================
  static async getStudentBySsn(ssn: string): Promise<Student[]> {
    try {
      const [rows]: any = await pool.query(
        `
        SELECT 
          s.sssn,
          s.cccd,
          s.first_name,
          s.last_name,
          s.birthday,
          s.sex,
          s.health_state,
          s.ethnic_group,
          s.student_id,
          s.study_status,
          s.class_name,
          s.faculty,
          s.building_id,
          s.room_id,
          s.phone_numbers,
          s.emails,
          s.addresses,
          s.has_health_insurance,

          s.guardian_cccd,
          s.guardian_name,
          s.guardian_relationship,
          s.guardian_occupation,
          s.guardian_birthday,
          s.guardian_phone_numbers,
          s.guardian_addresses
        FROM student s
        WHERE s.sssn = ?
        LIMIT 1
        `,
        [ssn],
      );

      if (!rows || rows.length === 0) {
        throw new Error('Student not found');
      }

      const s = rows[0];

      return [
        {
          ssn: s.sssn,
          cccd: s.cccd,
          first_name: s.first_name,
          last_name: s.last_name,
          birthday: s.birthday,
          sex: s.sex,
          health_state: s.health_state,
          ethnic_group: s.ethnic_group,
          student_id: s.student_id,
          study_status: s.study_status,
          class_name: s.class_name,
          faculty: s.faculty,
          building_id: s.building_id,
          room_id: s.room_id,
          phone_numbers: s.phone_numbers,
          emails: s.emails,
          addresses: s.addresses,
          has_health_insurance: s.has_health_insurance,

          guardian_cccd: s.guardian_cccd,
          guardian_name: s.guardian_name,
          guardian_relationship: s.guardian_relationship,
          guardian_occupation: s.guardian_occupation,
          guardian_birthday: s.guardian_birthday,
          guardian_phone_numbers: s.guardian_phone_numbers,
          guardian_addresses: s.guardian_addresses,
        },
      ];
    } catch (err) {
      console.error('❌ Error in getStudentBySsn:', err);
      throw new Error('Failed to fetch student info');
    }
  }


  static async getStudentOptions() {
    // Lấy SSN, Họ tên, MSSV
    const [rows] = await pool.query(
      `SELECT sssn, first_name, last_name, student_id 
       FROM student 
       ORDER BY first_name ASC`
    );
    return rows;
  }
  static async getStudentsWithoutRoom() {
    const [rows] = await pool.query(
      `SELECT sssn, first_name, last_name, student_id 
       FROM student 
       WHERE room_id IS NULL 
       ORDER BY first_name ASC`
    );
    return rows;
  }
  // ========================================
  // MAIN FUNCTION: SORT + FILTER + PAGINATION
  // ========================================
  static async getPaginated(
  page: number,
  limit: number,
  sorts: { field: string; order: 'asc' | 'desc' }[] = [],
  filters?: {
    faculty?: string[];   
    room?: string[];
    building?: string[];
    status?: string[];
  }
) {
  const offset = (page - 1) * limit;

  const columnMap: Record<string, string> = {
      student_id: 's.student_id',
      faculty: 's.faculty',
      building_id: 's.building_id',
      room_id: 's.room_id',
      study_status: 's.study_status',
      ssn: 's.sssn',
      last_name: 's.last_name',   
      first_name: 's.first_name', 
    };

  // ---------- WHERE (IN) ----------
  const whereClauses: string[] = [];
  const params: any[] = [];

  if (filters?.faculty?.length) {
    whereClauses.push(`s.faculty IN (${filters.faculty.map(() => '?').join(',')})`);
    params.push(...filters.faculty);
  }

  if (filters?.room?.length) {
    whereClauses.push(`s.room_id IN (${filters.room.map(() => '?').join(',')})`);
    params.push(...filters.room);
  }

  if (filters?.building?.length) {
    whereClauses.push(`s.building_id IN (${filters.building.map(() => '?').join(',')})`);
    params.push(...filters.building);
  }

  if (filters?.status?.length) {
    whereClauses.push(`s.study_status IN (${filters.status.map(() => '?').join(',')})`);
    params.push(...filters.status);
  }

  const whereSQL = whereClauses.length ? `WHERE ${whereClauses.join(' AND ')}` : '';

  // ---------- ORDER BY (MULTI SORT) ----------
  let orderBy = 's.student_id ASC';

    if (Array.isArray(sorts) && sorts.length > 0) {
      const orderParts = sorts
        .filter(s => columnMap[s.field]) // Lọc các trường hợp lệ
        .map(s => {
          const direction = s.order === 'desc' ? 'DESC' : 'ASC';
          
          if (s.field === 'last_name') {
            return `s.last_name ${direction}, s.first_name ${direction}`;
          }
          return `${columnMap[s.field]} ${direction}`;
        });

      if (orderParts.length) orderBy = orderParts.join(', ');
    }

    // ---------- COUNT ----------
    const [[{ total }]]: any = await pool.query(
      `SELECT COUNT(*) AS total FROM student s ${whereSQL}`,
      params
    );

    // ---------- MAIN QUERY ----------
    let dataQuery = `
      SELECT 
        s.sssn,
        s.cccd,
        s.first_name,
        s.last_name,
        s.birthday,
        s.sex,
        s.ethnic_group,
        s.study_status,
        s.health_state,
        s.student_id,
        s.class_name,
        s.faculty,
        s.building_id,
        s.room_id,
        s.phone_numbers,
        s.emails,
        s.addresses,
        s.has_health_insurance
      FROM student s
      ${whereSQL}
      ORDER BY ${orderBy}
    `;

    if (total > limit) {
      dataQuery += ` LIMIT ? OFFSET ?`;
      params.push(limit, offset);
    }

    const [rows]: any = await pool.query(dataQuery, params);

    return {
      data: rows,
      pagination: {
        total,
        page,
        limit,
        totalPages: total > limit ? Math.ceil(total / limit) : 1,
      },
    };
  }

  // ========================================
  // DELETE STUDENT (SỬA LOGIC CHẶN NẾU CÒN PHÒNG)
  // ========================================
  static async deleteStudent(ssn: string): Promise<void> {
    // 1. Kiểm tra xem sinh viên có đang ở trong phòng nào không
    const [rows]: any = await pool.query(
        `SELECT room_id, first_name, last_name FROM student WHERE sssn = ?`, 
        [ssn]
    );

    if (!rows || rows.length === 0) {
        throw new Error('Sinh viên không tồn tại.');
    }

    const student = rows[0];

    // 2. Nếu room_id khác null/empty -> Chặn xóa
    if (student.room_id) {
        throw new Error(
            `Không thể xóa: Sinh viên ${student.first_name} ${student.last_name} đang ở phòng ${student.room_id}. Vui lòng rời phòng trước khi xóa.`
        );
    }

    // 3. Nếu không có phòng, tiến hành xóa
    await pool.query('CALL delete_student_by_sssn(?)', [ssn]);
  }

  // ========================================
  // GENERATE SSN AUTOMATICALLY (YYxxxxxx)
  // ========================================
  static async generateNextSsn(): Promise<string> {
    const currentYearShort = new Date().getFullYear().toString().slice(-2); // VD: "25" cho 2025
    const prefix = `${currentYearShort}`; 
    
    // Tìm SSN lớn nhất bắt đầu bằng 2 số cuối của năm hiện tại
    const [rows]: any = await pool.query(
      `SELECT sssn FROM student WHERE sssn LIKE ? ORDER BY sssn DESC LIMIT 1`,
      [`${prefix}%`]
    );

    if (!rows || rows.length === 0) {
      // Chưa có sinh viên nào trong năm nay => Bắt đầu từ YY000001
      return `${prefix}000001`;
    }

    const maxSsn = rows[0].sssn; // VD: 25000005
    // Lấy 6 số cuối và tăng lên 1
    const currentSequence = parseInt(maxSsn.slice(2), 10); 
    const nextSequence = currentSequence + 1;

    // Pad số 0 vào trước để đủ 6 chữ số
    return `${prefix}${nextSequence.toString().padStart(6, '0')}`;
  }

  // ========================================
  // INSERT STUDENT (Tự động sinh SSN)
  // ========================================
  static async insertStudent(student: Partial<Student>): Promise<void> {
    // Tự động sinh SSN, không dùng SSN từ input
    const generatedSsn = await StudentService.generateNextSsn();

    const params = [
      generatedSsn,
      student.cccd,
      student.first_name,
      student.last_name,
      student.birthday,
      student.sex,
      student.ethnic_group,
      student.health_state,
      student.student_id,
      student.study_status,
      student.class_name || null,
      student.faculty || null,
      student.building_id || null, 
      student.room_id || null,     
      student.phone_numbers || null,
      student.emails || null,
      student.addresses || null,
      student.guardian_cccd || null,
      student.guardian_name || null,
      student.guardian_relationship || null,
      student.guardian_occupation || null,
      student.guardian_birthday || null,
      student.guardian_phone_numbers || null,
      student.guardian_addresses || null,
    ];

    await pool.query(
      `CALL insert_student(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      params,
    );

    // Tạo thẻ ký túc xá với SSN mới
    await pool.query('CALL create_dormitory_card(?)', [generatedSsn]);
  }

  // ========================================
  // UPDATE STUDENT
  // ========================================
  static async updateStudent(student: Student): Promise<void> {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // 1. KIỂM TRA ĐIỂM RÈN LUYỆN (Logic cũ - Giữ nguyên)
      if (student.study_status === 'Active') {
        const [sRows]: any = await conn.query('SELECT student_id FROM student WHERE sssn = ?', [student.ssn]);
        if (sRows.length > 0) {
            const mssv = sRows[0].student_id;
            const [dRows]: any = await conn.query(
                `SELECT severity_level FROM disciplinary_action da 
                 JOIN student_discipline sd ON da.action_id = sd.action_id 
                 WHERE sd.student_id = ? AND da.status = 'active'`,
                [mssv]
            );
            let totalDeduction = 0;
            if (Array.isArray(dRows)) {
                totalDeduction = dRows.reduce((sum: number, row: any) => sum + (POINTS_MAP[row.severity_level?.toLowerCase()] || 0), 0);
            }
            const currentScore = 100 - totalDeduction;
            if (currentScore < 70) {
                throw new Error(`Không thể kích hoạt. Điểm rèn luyện ${currentScore}/100 (Dưới 70).`);
            }
        }
      }

      // =================================================================
      // 🔥 LOGIC MỚI: TỰ ĐỘNG RỜI PHÒNG NẾU NON_ACTIVE
      // =================================================================
      if (student.study_status === 'Non_Active') {
        // Lấy thông tin phòng hiện tại của sinh viên
        const [rows]: any = await conn.query(
          'SELECT building_id, room_id FROM student WHERE sssn = ? FOR UPDATE', 
          [student.ssn]
        );
        
        const currentInfo = rows[0];

        // Nếu sinh viên đang ở trong phòng
        if (currentInfo && currentInfo.building_id && currentInfo.room_id) {
           // 1. Giảm sĩ số phòng cũ
           await conn.query(`
             UPDATE living_room 
             SET current_num_of_students = GREATEST(current_num_of_students - 1, 0),
                 occupancy_rate = (GREATEST(current_num_of_students - 1, 0) / max_num_of_students) * 100
             WHERE building_id = ? AND room_id = ?
           `, [currentInfo.building_id, currentInfo.room_id]);


        }
      }
      // =================================================================

      const studentParams = [
        student.ssn,
        student.cccd,
        student.first_name,
        student.last_name,
        student.birthday ? student.birthday.slice(0, 10) : null,
        student.sex,
        student.ethnic_group,
        student.health_state,
        student.student_id,
        student.study_status,
        student.class_name || null,
        student.faculty || null,
        student.building_id || null, // Nếu Non_Active thì cái này đã thành null ở trên
        student.room_id || null,     // Nếu Non_Active thì cái này đã thành null ở trên
        student.phone_numbers,
        student.emails,
        student.addresses,
        student.has_health_insurance,
      ];

      // Gọi Procedure update thông tin (Sử dụng conn để cùng transaction)
      await conn.query(
        'CALL update_student_info(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        studentParams,
      );

      // Update Guardian (Giữ nguyên)
      const hasGuardian = student.guardian_name || student.guardian_cccd;
      if (hasGuardian) {
        await conn.query('CALL update_guardian_info(?, ?, ?, ?, ?, ?, ?, ?)', [
          student.ssn,
          student.guardian_cccd || null,
          student.guardian_name || null,
          student.guardian_relationship || null,
          student.guardian_occupation || null,
          student.guardian_birthday ? student.guardian_birthday.slice(0, 10) : null,
          student.guardian_phone_numbers || null,
          student.guardian_addresses || null,
        ]);
      }

      await conn.commit();
    } catch (error) {
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  // ========================================
  // CHECK UNIQUE
  // ========================================
  static async doesSsnExist(ssn: string, excludeSsn?: string): Promise<boolean> {
    const params: any[] = [ssn];
    let sql = 'SELECT 1 FROM student WHERE sssn = ?';
    if (excludeSsn) {
      sql += ' AND sssn <> ?';
      params.push(excludeSsn);
    }
    const [rows]: any = await pool.query(sql + ' LIMIT 1', params);
    return Array.isArray(rows) && rows.length > 0;
  }

  static async doesStudentIdExist(
    studentId: string,
    excludeSsn?: string,
  ): Promise<boolean> {
    const params: any[] = [studentId];
    let sql = 'SELECT 1 FROM student WHERE student_id = ?';
    if (excludeSsn) {
      sql += ' AND sssn <> ?';
      params.push(excludeSsn);
    }
    const [rows]: any = await pool.query(sql + ' LIMIT 1', params);
    return Array.isArray(rows) && rows.length > 0;
  }
}