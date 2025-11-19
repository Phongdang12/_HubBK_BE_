// src/services/discipline.service.ts
import pool from '../Config/db.config';

export type DisciplineCreateDTO = {
  action_id: string;
  action_type: string;
  reason: string;
  decision_date: string; // ISO date
  effective_from: string;
  effective_to?: string | null;
  severity_level: 'low'|'medium'|'high'|'expulsion';
  status: 'pending'|'active'|'completed'|'cancelled';
  sssn: string; // student sssn (8 chars)
};

export type DisciplineUpdateDTO = Partial<Omit<DisciplineCreateDTO, 'action_id'>> & { action_id?: string };

export async function getAllDisciplines() {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      `SELECT da.*, sd.sssn
       FROM disciplinary_action da
       LEFT JOIN student_discipline sd ON da.action_id = sd.action_id
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
      `SELECT da.*, sd.sssn
       FROM disciplinary_action da
       LEFT JOIN student_discipline sd ON da.action_id = sd.action_id
       WHERE da.action_id = ? LIMIT 1`, [action_id]
    );
    // @ts-ignore
    return Array.isArray(rows) && rows.length ? rows[0] : null;
  } finally {
    conn.release();
  }
}

export async function createDiscipline(payload: DisciplineCreateDTO) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // ensure action_id not exists
    const [existing] = await conn.query('SELECT 1 FROM disciplinary_action WHERE action_id = ? LIMIT 1', [payload.action_id]);
    // @ts-ignore
    if (Array.isArray(existing) && existing.length > 0) {
      throw { status: 409, message: 'action_id already exists' };
    }

    // insert disciplinary_action
    await conn.query(
      `INSERT INTO disciplinary_action
        (action_id, action_type, reason, decision_date, effective_from, effective_to, severity_level, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        payload.action_id,
        payload.action_type,
        payload.reason,
        payload.decision_date,
        payload.effective_from,
        payload.effective_to || null,
        payload.severity_level,
        payload.status
      ]
    );

    // insert student_discipline (associate sssn)
    await conn.query(
      `INSERT INTO student_discipline (action_id, sssn) VALUES (?, ?)`,
      [payload.action_id, payload.sssn]
    );

    await conn.commit();

    // return created row (join to include sssn)
    const created = await getDisciplineById(payload.action_id);
    return created;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

export async function updateDiscipline(action_idParam: string, payload: DisciplineUpdateDTO) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // check existence
    const existing = await getDisciplineById(action_idParam);
    if (!existing) {
      throw { status: 404, message: 'Discipline not found' };
    }

    // do not allow changing action_id
    if (payload.action_id && payload.action_id !== action_idParam) {
      throw { status: 400, message: 'action_id cannot be changed' };
    }

    // update disciplinary_action fields if provided
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
      const sql = `UPDATE disciplinary_action SET ${fields.join(', ')} WHERE action_id = ?`;
      values.push(action_idParam);
      await conn.query(sql, values);
    }

    // update student_discipline.sssn if provided
    if ((payload as DisciplineCreateDTO).sssn !== undefined) {
      // upsert style: if row exists update sssn else insert
      const [sdRows] = await conn.query('SELECT 1 FROM student_discipline WHERE action_id = ? LIMIT 1', [action_idParam]);
      // @ts-ignore
      if (Array.isArray(sdRows) && sdRows.length > 0) {
        await conn.query('UPDATE student_discipline SET sssn = ? WHERE action_id = ?', [(payload as any).sssn, action_idParam]);
      } else {
        await conn.query('INSERT INTO student_discipline (action_id, sssn) VALUES (?, ?)', [action_idParam, (payload as any).sssn]);
      }
    }

    await conn.commit();
    const updated = await getDisciplineById(action_idParam);
    return updated;
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
    // deleting disciplinary_action should cascade student_discipline if FK set with ON DELETE CASCADE
    const [res] = await conn.query('DELETE FROM disciplinary_action WHERE action_id = ?', [action_id]);
    await conn.commit();
    // @ts-ignore
    return { affectedRows: res.affectedRows || 0 };
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}
