// fileName: src/Services/discipline.service.ts
import pool from '../Config/db.config';

// ✅ 1. CẤU HÌNH ĐIỂM RÈN LUYỆN
const POINTS_MAP: Record<string, number> = {
  low: 2,       // Trừ 1
  medium: 5,    // Trừ 2
  high: 10,      // Trừ 5
  expulsion: 31 // Trừ >30 (Đuổi ngay lập tức)
};
const STARTING_SCORE = 100;
const EXPULSION_THRESHOLD = 70;

export type DisciplineCreateDTO = {
  action_id: string;
  action_type: string;
  reason: string;
  decision_date: string; 
  effective_from: string;
  effective_to?: string | null;
  severity_level: 'low'|'medium'|'high'|'expulsion';
  status: 'pending'|'active'|'completed'|'cancelled';
  student_id: string; // Frontend gửi SSSN lên
};

export type DisciplineUpdateDTO = Partial<Omit<DisciplineCreateDTO, 'action_id'>> & { action_id?: string };

// Hàm sinh ID tự động (DA001, DA002...)
async function generateNextActionId(conn: any): Promise<string> {
  const [rows]: any = await conn.query(
    'SELECT action_id FROM disciplinary_action ORDER BY action_id DESC LIMIT 1'
  );
  
  if (!Array.isArray(rows) || rows.length === 0) {
    return 'DA001';
  }

  const lastId = rows[0].action_id; 
  const numberPart = parseInt(lastId.replace(/^DA/i, ''), 10); 
  const nextNumber = (isNaN(numberPart) ? 0 : numberPart) + 1;
  
  return `DA${nextNumber.toString().padStart(3, '0')}`; 
}

export async function getAllDisciplines() {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      `SELECT da.*, s.student_id, s.first_name, s.last_name, s.sssn
       FROM disciplinary_action da
       LEFT JOIN student_discipline sd ON da.action_id = sd.action_id
       LEFT JOIN student s ON sd.student_id = s.student_id
       ORDER BY da.decision_date DESC`
    );
    return rows;
  } finally {
    conn.release();
  }
}

export async function getDisciplineById(action_id: string) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      `SELECT da.*, s.student_id, s.sssn
       FROM disciplinary_action da
       LEFT JOIN student_discipline sd ON da.action_id = sd.action_id
       LEFT JOIN student s ON sd.student_id = s.student_id
       WHERE da.action_id = ? LIMIT 1`, [action_id]
    );
    // @ts-ignore
    return Array.isArray(rows) && rows.length ? rows[0] : null;
  } finally {
    conn.release();
  }
}

export async function getDisciplinesByStudentId(studentId: string) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      `SELECT da.*, s.student_id, s.first_name, s.last_name
       FROM disciplinary_action da
       JOIN student_discipline sd ON da.action_id = sd.action_id
       JOIN student s ON sd.student_id = s.student_id  
       WHERE s.student_id = ?
       ORDER BY da.decision_date DESC`,
      [studentId]
    );
    return rows;
  } finally {
    conn.release();
  }
}

// ==========================================================
// ✅ HÀM CREATE: TỰ ĐỘNG TÍNH ĐIỂM & UPDATE TRẠNG THÁI
// ==========================================================
export async function createDiscipline(payload: DisciplineCreateDTO) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // 1. Sinh Action ID mới
    const newActionId = await generateNextActionId(conn);

    // 2. Tìm Student ID (Chấp nhận cả SSSN hoặc MSSV)
    // Logic: Tìm thằng nào có sssn = input HOẶC student_id = input
    const [students]: any = await conn.query(
      'SELECT student_id FROM student WHERE sssn = ? OR student_id = ? LIMIT 1', 
      [payload.student_id, payload.student_id]
    );
    
    if (!students.length) {
      throw { status: 404, message: `Student not found with ID/SSN: ${payload.student_id}` };
    }
    
    const finalStudentId = students[0].student_id;

    // 3. Insert vào bảng disciplinary_action
    await conn.query(
      `INSERT INTO disciplinary_action
        (action_id, action_type, reason, decision_date, effective_from, effective_to, severity_level, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        newActionId,
        payload.action_type,
        payload.reason,
        payload.decision_date,
        payload.effective_from,
        payload.effective_to || null,
        payload.severity_level,
        payload.status
      ]
    );

    // 4. Insert vào bảng liên kết
    await conn.query(
      `INSERT INTO student_discipline (action_id, student_id) VALUES (?, ?)`,
      [newActionId, finalStudentId]
    );

    // =====================================================
    // 🆕 LOGIC TỰ ĐỘNG ĐUỔI HỌC (Dưới 70 điểm -> Non_Active)
    // =====================================================
    
    // A. Lấy danh sách kỷ luật 'active' để tính điểm
    const [disciplineHistory]: any = await conn.query(
      `SELECT da.severity_level 
       FROM disciplinary_action da
       JOIN student_discipline sd ON da.action_id = sd.action_id
       WHERE sd.student_id = ? 
       AND da.status = 'active'`, 
      [finalStudentId]
    );

    // B. Tính tổng điểm trừ
    let totalDeduction = 0;
    if (Array.isArray(disciplineHistory)) {
      totalDeduction = disciplineHistory.reduce((sum: number, record: any) => {
        const points = POINTS_MAP[record.severity_level?.toLowerCase()] || 0;
        return sum + points;
      }, 0);
    }

    const currentScore = STARTING_SCORE - totalDeduction;
    let isExpelled = false;

    // C. Kiểm tra ngưỡng < 70
    if (currentScore < EXPULSION_THRESHOLD) {
      console.log(`⚠️ AUTO-EXPULSION: Student ${finalStudentId} dropped to ${currentScore} points.`);
      
      // 🔥 Cập nhật trạng thái sinh viên ngay lập tức
      await conn.query(
        `UPDATE student SET study_status = 'Non_Active' WHERE student_id = ?`,
        [finalStudentId]
      );
      isExpelled = true;
    }
    // =====================================================

    await conn.commit();
    const created = await getDisciplineById(newActionId);
    // Trả về thêm thông tin điểm để UI (nếu cần) biết ngay
    return { ...created, currentScore, isExpelled };

  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

// Update kỷ luật (Giữ nguyên logic cơ bản)
export async function updateDiscipline(action_idParam: string, payload: DisciplineUpdateDTO) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const existing = await getDisciplineById(action_idParam);
    if (!existing) throw { status: 404, message: 'Discipline not found' };

    const fields: string[] = [];
    const values: any[] = [];
    const updatable = ['action_type','reason','decision_date','effective_from','effective_to','severity_level','status'];
    
    for (const f of updatable) {
      // @ts-ignore
      if (payload[f] !== undefined) {
        fields.push(`${f} = ?`);
        // @ts-ignore
        values.push(payload[f]);
      }
    }

    if (fields.length) {
      values.push(action_idParam);
      await conn.query(`UPDATE disciplinary_action SET ${fields.join(', ')} WHERE action_id = ?`, values);
    }
    
    // Logic update student_id nếu cần (ít khi dùng)
    if ((payload as DisciplineCreateDTO).student_id !== undefined) {
      // ... (giữ nguyên phần tìm và update student_id nếu bạn muốn)
    }
    
    // 💡 Nếu muốn Update cũng kích hoạt tính điểm lại, bạn có thể copy đoạn logic tính điểm từ createDiscipline vào đây.
    // Hiện tại chỉ cần Create hoạt động là đủ cho kịch bản "Thêm lỗi -> Bị đuổi".

    await conn.commit();
    return await getDisciplineById(action_idParam);
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

export async function deleteDiscipline(action_id: string) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // BƯỚC 1: Tìm sinh viên liên quan trước khi xoá (để lát nữa tính lại điểm)
    const [links]: any = await conn.query(
      `SELECT student_id FROM student_discipline WHERE action_id = ? LIMIT 1`, 
      [action_id]
    );
    
    if (!links.length) {
       throw { status: 404, message: 'Discipline record not found' };
    }
    const targetStudentId = links[0].student_id;

    // BƯỚC 2: Xoá kỷ luật (Cascade sẽ tự xoá trong bảng student_discipline)
    const [res]: any = await conn.query('DELETE FROM disciplinary_action WHERE action_id = ?', [action_id]);

    // =====================================================
    // 🆕 LOGIC TỰ ĐỘNG PHỤC HỒI (Nếu điểm >= 70 -> Active)
    // =====================================================
    
    // A. Tính lại tổng điểm trừ của các lỗi CÒN LẠI (active)
    const [disciplineHistory]: any = await conn.query(
      `SELECT da.severity_level 
       FROM disciplinary_action da
       JOIN student_discipline sd ON da.action_id = sd.action_id
       WHERE sd.student_id = ? 
       AND da.status = 'active'`, 
      [targetStudentId]
    );

    let totalDeduction = 0;
    if (Array.isArray(disciplineHistory)) {
      totalDeduction = disciplineHistory.reduce((sum: number, record: any) => {
        const points = POINTS_MAP[record.severity_level?.toLowerCase()] || 0;
        return sum + points;
      }, 0);
    }

    const currentScore = STARTING_SCORE - totalDeduction;

    // B. Kiểm tra: Nếu điểm đã an toàn (>= 70) mà đang bị Non_Active -> Mở lại Active
    if (currentScore >= EXPULSION_THRESHOLD) {
      // Kiểm tra trạng thái hiện tại
      const [studentRows]: any = await conn.query(
        `SELECT study_status FROM student WHERE student_id = ?`, 
        [targetStudentId]
      );
      
      if (studentRows.length > 0 && studentRows[0].study_status === 'Non_Active') {
         console.log(`♻️ AUTO-RESTORE: Student ${targetStudentId} recovered to ${currentScore} points. Status set to Active.`);
         
         await conn.query(
           `UPDATE student SET study_status = 'Active' WHERE student_id = ?`,
           [targetStudentId]
         );
      }
    }
    // =====================================================

    await conn.commit();
    return { affectedRows: res.affectedRows || 0, currentScore };

  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

export async function doesStudentExist(idOrSsn: string) {
  const conn = await pool.getConnection();
  try {
    // ✅ SỬA: Tìm trong cả 2 cột sssn HOẶC student_id
    const [rows] = await conn.query(
      'SELECT 1 FROM student WHERE sssn = ? OR student_id = ? LIMIT 1', 
      [idOrSsn, idOrSsn]
    );
    // @ts-ignore
    return Array.isArray(rows) && rows.length > 0;
  } finally {
    conn.release();
  }
}