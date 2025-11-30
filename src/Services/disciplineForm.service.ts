// fileName: src/Services/disciplineForm.service.ts
import pool from '../Config/db.config';

// GET ALL
export async function getAllForms(onlyActive = false) {
  let sql = 'SELECT * FROM discipline_forms';
  if (onlyActive) {
    sql += ' WHERE is_active = TRUE';
  }
  sql += ' ORDER BY id ASC';
  
  const [rows] = await pool.query(sql);
  return rows;
}

// CREATE
export async function createForm(name: string, description?: string) {
  const conn = await pool.getConnection();
  try {
    const [res]: any = await conn.query(
      'INSERT INTO discipline_forms (name, description, is_active) VALUES (?, ?, TRUE)',
      [name, description || null]
    );
    return { id: res.insertId, name, description, is_active: true };
  } finally {
    conn.release();
  }
}

// DELETE (Constraint Check -> Soft Delete / Hard Delete)
export async function deleteForm(id: number) {
  const conn = await pool.getConnection();
  try {
    // 1. Lấy tên form trước
    const [forms]: any = await conn.query('SELECT name FROM discipline_forms WHERE id = ? LIMIT 1', [id]);
    if (!Array.isArray(forms) || forms.length === 0) {
        throw { status: 404, message: 'Form not found' };
    }
    const formName = forms[0].name;

    // 2. Kiểm tra xem tên form này có được dùng trong bảng disciplinary_action ko
    const [usage]: any = await conn.query(
      'SELECT 1 FROM disciplinary_action WHERE action_type = ? LIMIT 1',
      [formName]
    );

    // 3. Xử lý xóa
    if (Array.isArray(usage) && usage.length > 0) {
      // Nếu ĐÃ DÙNG -> Soft Delete (Ẩn đi)
      await conn.query('UPDATE discipline_forms SET is_active = FALSE WHERE id = ?', [id]);
      return { message: 'Form is in use. Deactivated instead of deleted.' };
    } else {
      // Nếu CHƯA DÙNG -> Hard Delete (Xóa vĩnh viễn)
      await conn.query('DELETE FROM discipline_forms WHERE id = ?', [id]);
      return { message: 'Form deleted permanently.' };
    }
  } finally {
    conn.release();
  }
}

// TOGGLE STATUS (Optional)
export async function toggleStatus(id: number, isActive: boolean) {
    const conn = await pool.getConnection();
    try {
        await conn.query('UPDATE discipline_forms SET is_active = ? WHERE id = ?', [isActive, id]);
        return true;
    } finally {
        conn.release();
    }
}
