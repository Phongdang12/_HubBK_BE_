import pool from '@/Config/db.config';
import {
  DisciplinedStudentsResponse,
  TotalStudentsByBuildingResponse,
  ValidDormitoryCardsResponse,
  StatisticsOverviewResponse,
  FacultyDistributionResponse,
  OccupancyByBuildingResponse,
  DisciplineSeverityResponse,
  ViolationsTrendResponse,
} from '@/Interfaces/statistics.interface';

export class StatisticsService {
  constructor() {
    console.log('StatisticsService initialized');
  }

  async getDisciplinedStudents(
    startDate: string,
    endDate: string,
  ): Promise<DisciplinedStudentsResponse> {
    const result = await pool.query(
      'SELECT count_disciplined_students(?, ?) AS totalDisciplinedStudents',
      [startDate, endDate],
    );

    const totalDisciplinedStudents = result[0] as DisciplinedStudentsResponse[];
    return totalDisciplinedStudents[0];
  }

  async getTotalStudentsByBuilding(
    buildingId: string,
  ): Promise<TotalStudentsByBuildingResponse> {
    if (buildingId.length > 5) {
      throw new Error('Building ID is exactly 5 characters long');
    }

    const result = await pool.query(
      'SELECT total_students_by_building(?) AS totalStudents',
      [buildingId],
    );
    const totalStudents = result[0] as TotalStudentsByBuildingResponse[];

    return totalStudents[0];
  }

  async getValidDormitoryCards(): Promise<ValidDormitoryCardsResponse> {
    const result = await pool.query(
      'SELECT num_validity_dormitory_card() AS validDormCards;',
    );
    const validCards = result[0] as ValidDormitoryCardsResponse[];

    return validCards[0];
  }

  // New methods for dashboard statistics

  /**
   * Get statistics overview (KPI cards)
   * Logic:
   * - Occupancy Rate = current residents / total capacity (KHÔNG lọc theo date)
   * - Total Students = count of students with study_status = 'Active' and room assignment (KHÔNG lọc theo date)
   * - Available Rooms = count of rooms where current_num_of_students < max_num_of_students (KHÔNG lọc theo date)
   * - Pending Discipline = count of disciplines with status = 'pending' (CÓ lọc theo date nếu có)
   */
  async getStatisticsOverview(
    from?: string,
    to?: string,
    buildingId?: string,
  ): Promise<StatisticsOverviewResponse> {
    // Total students: KHÔNG lọc theo date, chỉ lọc theo building
    let studentsWhereClause = "WHERE s.study_status = 'Active' AND s.building_id IS NOT NULL AND s.room_id IS NOT NULL";
    const studentsParams: any[] = [];

    if (buildingId) {
      studentsWhereClause += ' AND s.building_id = ?';
      studentsParams.push(buildingId);
    }

    // Total capacity (sum of max_num_of_students from living_room)
    let capacityWhere = buildingId ? 'WHERE building_id = ?' : '';
    const capacityParams = buildingId ? [buildingId] : [];

    const capacityQuery = `SELECT COALESCE(SUM(max_num_of_students), 0) AS total_capacity
       FROM living_room
       ${capacityWhere}`;
    const capacityResult: any = await pool.query(capacityQuery, capacityParams);
    const totalCapacity = Array.isArray(capacityResult[0]) && capacityResult[0].length > 0
      ? capacityResult[0][0]?.total_capacity || 0
      : 0;

    // Current residents (sum of current_num_of_students)
    const residentsQuery = `SELECT COALESCE(SUM(current_num_of_students), 0) AS current_residents
       FROM living_room
       ${capacityWhere}`;
    const residentsResult: any = await pool.query(residentsQuery, capacityParams);
    const currentResidents = Array.isArray(residentsResult[0]) && residentsResult[0].length > 0
      ? residentsResult[0][0]?.current_residents || 0
      : 0;

    // Total students (active with room) - KHÔNG lọc theo date
    const studentsQuery = `SELECT COUNT(*) AS total_students
       FROM student s
       ${studentsWhereClause}`;
    const studentsResult: any = await pool.query(studentsQuery, studentsParams);
    const totalStudents = Array.isArray(studentsResult[0]) && studentsResult[0].length > 0
      ? Number(studentsResult[0][0]?.total_students) || 0
      : 0;

    // Available rooms
    let availableWhere = buildingId
      ? 'WHERE building_id = ? AND current_num_of_students < max_num_of_students'
      : 'WHERE current_num_of_students < max_num_of_students';
    const availableParams = buildingId ? [buildingId] : [];

    const availableQuery = `SELECT COUNT(*) AS available_rooms
       FROM living_room
       ${availableWhere}`;
    const availableResult: any = await pool.query(availableQuery, availableParams);
    const availableRooms = Array.isArray(availableResult[0]) && availableResult[0].length > 0
      ? availableResult[0][0]?.available_rooms || 0
      : 0;

    // Pending discipline - CÓ lọc theo date nếu có
    let disciplineWhere = "WHERE da.status = 'pending'";
    const disciplineParams: any[] = [];

    if (from && to) {
      disciplineWhere += ' AND da.decision_date BETWEEN ? AND ?';
      disciplineParams.push(from, to);
    } else {
      // Nếu không có date range, vẫn lấy tất cả pending (không lọc theo date)
    }

    if (buildingId) {
      disciplineWhere += ` AND EXISTS (
        SELECT 1 FROM student_discipline sd
        JOIN student s ON sd.sssn = s.sssn
        WHERE sd.action_id = da.action_id AND s.building_id = ?
      )`;
      disciplineParams.push(buildingId);
    }

    const disciplineQuery = `SELECT COUNT(*) AS pending_discipline
       FROM disciplinary_action da
       ${disciplineWhere}`;
    const disciplineResult: any = await pool.query(disciplineQuery, disciplineParams);
    const pendingDiscipline = Array.isArray(disciplineResult[0]) && disciplineResult[0].length > 0
      ? disciplineResult[0][0]?.pending_discipline || 0
      : 0;

    // Calculate occupancy rate
    const occupancyRate =
      totalCapacity > 0 ? (currentResidents / totalCapacity) * 100 : 0;

    return {
      occupancyRate: Math.round(occupancyRate * 100) / 100,
      totalStudents,
      availableRooms,
      pendingDiscipline,
      totalCapacity,
      currentResidents,
    };
  }

  /**
   * Get student distribution by faculty
   * Groups students by faculty name
   * KHÔNG lọc theo date, chỉ lọc theo building
   */
  async getFacultyDistribution(
    from?: string,
    to?: string,
    buildingId?: string,
  ): Promise<FacultyDistributionResponse> {
    let whereClause = "WHERE s.study_status = 'Active' AND s.faculty IS NOT NULL";
    const params: any[] = [];

    // KHÔNG lọc theo date - chỉ lọc theo building
    if (buildingId) {
      whereClause += ' AND s.building_id = ?';
      params.push(buildingId);
    }

    const query = `SELECT 
        s.faculty AS faculty,
        COUNT(*) AS count
       FROM student s
       ${whereClause}
       GROUP BY s.faculty
       ORDER BY count DESC`;
    const result: any = await pool.query(query, params);
    const rows = Array.isArray(result[0]) ? result[0] : [];

    return {
      data: rows.map((row: any) => ({
        faculty: row.faculty || 'Unknown',
        count: row.count,
      })),
    };
  }

  /**
   * Get occupancy by building
   * For each building: total capacity, current residents, available spots
   * KHÔNG lọc theo date, chỉ lọc theo building
   */
  async getOccupancyByBuilding(
    from?: string,
    to?: string,
    buildingId?: string,
  ): Promise<OccupancyByBuildingResponse> {
    // KHÔNG lọc theo date - chỉ lọc theo building
    let whereClause = buildingId ? 'WHERE lr.building_id = ?' : '';
    const params: any[] = [];

    if (buildingId) {
      params.push(buildingId);
    }

    const query = `SELECT 
        lr.building_id AS building,
        COALESCE(SUM(lr.max_num_of_students), 0) AS total_capacity,
        COALESCE(SUM(lr.current_num_of_students), 0) AS current_residents
       FROM living_room lr
       ${whereClause}
       GROUP BY lr.building_id
       ORDER BY lr.building_id`;
    const result: any = await pool.query(query, params);
    const rows = Array.isArray(result[0]) ? result[0] : [];

    return {
      data: rows.map((row: any) => ({
        building: row.building,
        totalCapacity: row.total_capacity,
        currentResidents: row.current_residents,
        available: Math.max(0, row.total_capacity - row.current_residents),
      })),
    };
  }

  /**
   * Get discipline severity distribution
   * Groups disciplines by severity_level
   * Counts distinct action_ids to avoid duplicates when multiple students have same action
   */
  async getDisciplineSeverity(
    from?: string,
    to?: string,
    buildingId?: string,
  ): Promise<DisciplineSeverityResponse> {
    try {
      // Normalize buildingId: empty string, 'ALL', null, undefined = all buildings
      const normalizedBuildingId = buildingId && 
                                    buildingId.trim() !== '' && 
                                    buildingId.toUpperCase() !== 'ALL' 
                                    ? buildingId.trim().toUpperCase() 
                                    : null;

      // Normalize date filters: only apply if both are provided and valid
      // IMPORTANT: If date filter is invalid, return ALL data (not filtered by date)
      const hasValidDateFilter = from && 
                                 to && 
                                 from.trim() !== '' && 
                                 to.trim() !== '' &&
                                 !isNaN(Date.parse(from.trim())) &&
                                 !isNaN(Date.parse(to.trim()));

      // Build WHERE conditions
      const whereConditions: string[] = ["da.status != 'cancelled'"];
      const params: any[] = [];

      // Build JOIN clause - always need to join with student_discipline to ensure action has students
      let joinClause = '';
      if (normalizedBuildingId) {
        // Filter by specific building: need to join to student table
        joinClause = `
          INNER JOIN student_discipline sd ON da.action_id = sd.action_id
          INNER JOIN student s ON sd.sssn = s.sssn`;
        whereConditions.push('s.building_id = ?');
        params.push(normalizedBuildingId);
      } else {
        // All buildings: just ensure action has at least one student
        joinClause = `INNER JOIN student_discipline sd ON da.action_id = sd.action_id`;
      }

      // Add date filter only if both dates are provided and valid
      if (hasValidDateFilter) {
        whereConditions.push('da.decision_date BETWEEN ? AND ?');
        params.push(from.trim(), to.trim());
      }

      const whereClause = whereConditions.length > 0 
        ? `WHERE ${whereConditions.join(' AND ')}`
        : '';

      // Build final query with DISTINCT to avoid duplicates from JOIN
      const query = `
        SELECT 
          da.severity_level AS severity,
          COUNT(DISTINCT da.action_id) AS count
        FROM disciplinary_action da
        ${joinClause}
        ${whereClause}
        GROUP BY da.severity_level
        ORDER BY 
          CASE da.severity_level
            WHEN 'low' THEN 1
            WHEN 'medium' THEN 2
            WHEN 'high' THEN 3
            WHEN 'expulsion' THEN 4
            ELSE 5
          END`;

      console.log('[getDisciplineSeverity] Query:', query.replace(/\s+/g, ' ').trim());
      console.log('[getDisciplineSeverity] Params:', params);
      console.log('[getDisciplineSeverity] BuildingId:', buildingId, '->', normalizedBuildingId);
      console.log('[getDisciplineSeverity] Date filter:', { from, to, hasValidDateFilter });
      
      // Debug: Check if there are any disciplines in the date range first
      if (hasValidDateFilter) {
        const debugQuery = `
          SELECT COUNT(*) as total
          FROM disciplinary_action da
          WHERE da.status != 'cancelled'
            AND da.decision_date BETWEEN ? AND ?
        `;
        const debugResult: any = await pool.query(debugQuery, [from.trim(), to.trim()]);
        console.log('[getDisciplineSeverity] Debug - Total disciplines in date range:', debugResult[0]?.[0]?.total || 0);
        
        // Debug: Check if student_discipline has records for these actions
        const debugQuery2 = `
          SELECT COUNT(DISTINCT da.action_id) as total
          FROM disciplinary_action da
          INNER JOIN student_discipline sd ON da.action_id = sd.action_id
          WHERE da.status != 'cancelled'
            AND da.decision_date BETWEEN ? AND ?
        `;
        const debugResult2: any = await pool.query(debugQuery2, [from.trim(), to.trim()]);
        console.log('[getDisciplineSeverity] Debug - Disciplines with students:', debugResult2[0]?.[0]?.total || 0);
      }
      
      const result: any = await pool.query(query, params);
      
      // Handle different result formats from mysql2
      let rows: any[] = [];
      if (Array.isArray(result)) {
        // mysql2 returns [rows, fields]
        rows = Array.isArray(result[0]) ? result[0] : [];
      } else if (result && Array.isArray(result[0])) {
        rows = result[0];
      } else if (Array.isArray(result)) {
        rows = result;
      }

      console.log('[getDisciplineSeverity] Result type:', typeof result);
      console.log('[getDisciplineSeverity] Result is array:', Array.isArray(result));
      console.log('[getDisciplineSeverity] Result rows:', rows.length);
      console.log('[getDisciplineSeverity] Result data:', JSON.stringify(rows, null, 2));

      // Always return array format
      return {
        data: rows.map((row: any) => ({
          severity: row.severity || '',
          count: Number(row.count) || 0,
        })),
      };
    } catch (error) {
      console.error('[getDisciplineSeverity] Error:', error);
      throw error;
    }
  }

  /**
   * Get violations trend by month
   * Groups disciplines by month of decision_date
   * Counts distinct action_ids to avoid duplicates when multiple students have same action
   */
  async getViolationsTrend(
    from?: string,
    to?: string,
    buildingId?: string,
  ): Promise<ViolationsTrendResponse> {
    try {
      // Normalize buildingId: empty string, 'ALL', null, undefined = all buildings
      const normalizedBuildingId = buildingId && 
                                    buildingId.trim() !== '' && 
                                    buildingId.toUpperCase() !== 'ALL' 
                                    ? buildingId.trim().toUpperCase() 
                                    : null;

      // Normalize date filters: only apply if both are provided and valid
      // IMPORTANT: If date filter is invalid, return ALL data (not filtered by date)
      const hasValidDateFilter = from && 
                                 to && 
                                 from.trim() !== '' && 
                                 to.trim() !== '' &&
                                 !isNaN(Date.parse(from.trim())) &&
                                 !isNaN(Date.parse(to.trim()));

      // Build WHERE conditions
      const whereConditions: string[] = ["da.status != 'cancelled'"];
      const params: any[] = [];

      // Build JOIN clause - always need to join with student_discipline to ensure action has students
      let joinClause = '';
      if (normalizedBuildingId) {
        // Filter by specific building: need to join to student table
        joinClause = `
          INNER JOIN student_discipline sd ON da.action_id = sd.action_id
          INNER JOIN student s ON sd.sssn = s.sssn`;
        whereConditions.push('s.building_id = ?');
        params.push(normalizedBuildingId);
      } else {
        // All buildings: just ensure action has at least one student
        joinClause = `INNER JOIN student_discipline sd ON da.action_id = sd.action_id`;
      }

      // Add date filter only if both dates are provided and valid
      if (hasValidDateFilter) {
        whereConditions.push('da.decision_date BETWEEN ? AND ?');
        params.push(from.trim(), to.trim());
      }

      const whereClause = whereConditions.length > 0 
        ? `WHERE ${whereConditions.join(' AND ')}`
        : '';

      // Build final query with DISTINCT to avoid duplicates from JOIN
      const query = `
        SELECT 
          DATE_FORMAT(da.decision_date, '%b %Y') AS month,
          COUNT(DISTINCT da.action_id) AS count
        FROM disciplinary_action da
        ${joinClause}
        ${whereClause}
        GROUP BY DATE_FORMAT(da.decision_date, '%Y-%m'), DATE_FORMAT(da.decision_date, '%b %Y')
        ORDER BY DATE_FORMAT(da.decision_date, '%Y-%m')`;

      console.log('[getViolationsTrend] Query:', query.replace(/\s+/g, ' ').trim());
      console.log('[getViolationsTrend] Params:', params);
      console.log('[getViolationsTrend] BuildingId:', buildingId, '->', normalizedBuildingId);
      console.log('[getViolationsTrend] Date filter:', { from, to, hasValidDateFilter });
      console.log('[getViolationsTrend] Raw from/to:', { from, to });
      
      // Debug: Check if there are any disciplines in the date range first
      const debugQuery = `
        SELECT COUNT(*) as total
        FROM disciplinary_action da
        WHERE da.status != 'cancelled'
          AND da.decision_date BETWEEN ? AND ?
      `;
      const debugResult: any = await pool.query(debugQuery, [from?.trim() || '', to?.trim() || '']);
      console.log('[getViolationsTrend] Debug - Total disciplines in date range:', debugResult[0]?.[0]?.total || 0);
      
      // Debug: Check if student_discipline has records
      const debugQuery2 = `
        SELECT COUNT(*) as total
        FROM student_discipline
      `;
      const debugResult2: any = await pool.query(debugQuery2);
      console.log('[getViolationsTrend] Debug - Total student_discipline records:', debugResult2[0]?.[0]?.total || 0);
      
      const result: any = await pool.query(query, params);
      
      // Handle different result formats from mysql2
      let rows: any[] = [];
      if (Array.isArray(result)) {
        // mysql2 returns [rows, fields]
        rows = Array.isArray(result[0]) ? result[0] : [];
      } else if (result && Array.isArray(result[0])) {
        rows = result[0];
      } else if (Array.isArray(result)) {
        rows = result;
      }

      console.log('[getViolationsTrend] Result type:', typeof result);
      console.log('[getViolationsTrend] Result is array:', Array.isArray(result));
      console.log('[getViolationsTrend] Result rows:', rows.length);
      console.log('[getViolationsTrend] Result data:', JSON.stringify(rows, null, 2));
      console.log('[getViolationsTrend] Full result:', JSON.stringify(result, null, 2));

      // Always return array format
      return {
        data: rows.map((row: any) => ({
          month: row.month || '',
          count: Number(row.count) || 0,
        })),
      };
    } catch (error) {
      console.error('[getViolationsTrend] Error:', error);
      throw error;
    }
  }
}
