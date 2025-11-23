import { Request, Response } from 'express';
import { StatisticsService } from '@/Services/statistics.service';
import {
  GetDisciplinedStudentsDto,
  BuildingIdParamsDto,
  StatisticsQueryParamsDto,
  StudentsQueryDto,
  RoomsQueryDto,
  DisciplinesQueryDto,
} from '../Validations/statistics.validator';
import { QueryError } from 'mysql2';
import { StudentService } from '@/Services/students.service';
import { RoomsService } from '@/Services/rooms.service';
import pool from '@/Config/db.config';

export class StatisticsController {
  private statisticsService: StatisticsService;

  constructor() {
    this.statisticsService = new StatisticsService();
    console.log('StatisticsController initialized');
  }

  async getDisciplinedStudents(
    req: Request<{}, {}, {}, GetDisciplinedStudentsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { startDate, endDate } = req.query;
      const { totalDisciplinedStudents } =
        await this.statisticsService.getDisciplinedStudents(startDate, endDate);
      res.json({ totalDisciplinedStudents });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Error insert student: ', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getTotalStudentsByBuilding(
    req: Request<BuildingIdParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { buildingId } = req.params;
      const { totalStudents } =
        await this.statisticsService.getTotalStudentsByBuilding(buildingId);
      res.json({ totalStudents });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getValidDormitoryCards(_req: Request, res: Response): Promise<void> {
    try {
      const { validDormCards } =
        await this.statisticsService.getValidDormitoryCards();
      res.json({ validDormCards });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  // New dashboard endpoints

  async getStatisticsOverview(
    req: Request<{}, {}, {}, StatisticsQueryParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { from, to, buildingId } = req.query;
      console.log('Getting statistics overview with params:', { from, to, buildingId });
      const data = await this.statisticsService.getStatisticsOverview(
        from,
        to,
        buildingId,
      );
      console.log('Statistics overview result:', data);
      res.json(data);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || (error as Error).message || 'Unknown error';
      console.error('Error getting statistics overview: ', error);
      console.error('Error stack:', (error as Error).stack);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getFacultyDistribution(
    req: Request<{}, {}, {}, StatisticsQueryParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { from, to, buildingId } = req.query;
      const data = await this.statisticsService.getFacultyDistribution(
        from,
        to,
        buildingId,
      );
      res.json(data);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Error getting faculty distribution: ', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getOccupancyByBuilding(
    req: Request<{}, {}, {}, StatisticsQueryParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { from, to, buildingId } = req.query;
      const data = await this.statisticsService.getOccupancyByBuilding(
        from,
        to,
        buildingId,
      );
      res.json(data);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Error getting occupancy by building: ', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getDisciplineSeverity(
    req: Request<{}, {}, {}, StatisticsQueryParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { from, to, buildingId } = req.query;
      console.log('[Controller] getDisciplineSeverity - Request:', { from, to, buildingId });
      
      const data = await this.statisticsService.getDisciplineSeverity(
        from,
        to,
        buildingId,
      );
      
      console.log('[Controller] getDisciplineSeverity - Response:', JSON.stringify(data, null, 2));
      
      // Ensure we always return the correct format
      if (!data || !data.data) {
        console.warn('[Controller] getDisciplineSeverity - Invalid format, returning empty array');
        res.json({ data: [] });
        return;
      }
      
      res.json(data);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('[Controller] Error getting discipline severity:', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getViolationsTrend(
    req: Request<{}, {}, {}, StatisticsQueryParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { from, to, buildingId } = req.query;
      console.log('[Controller] getViolationsTrend - Request:', { from, to, buildingId });
      
      const data = await this.statisticsService.getViolationsTrend(
        from,
        to,
        buildingId,
      );
      
      console.log('[Controller] getViolationsTrend - Response:', JSON.stringify(data, null, 2));
      
      // Ensure we always return the correct format
      if (!data || !data.data) {
        console.warn('[Controller] getViolationsTrend - Invalid format, returning empty array');
        res.json({ data: [] });
        return;
      }
      
      res.json(data);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('[Controller] Error getting violations trend:', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  // Drill-down endpoints

  async getStudentsForDrillDown(
    req: Request<{}, {}, {}, StudentsQueryDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { faculty, from, to, buildingId, status, page, limit } =
        req.query;
      const pageNum = page ? parseInt(page as string, 10) : 1;
      const limitNum = limit ? parseInt(limit as string, 10) : 20;

      // Get all students and filter
      // KHÔNG lọc theo date - chỉ lọc theo faculty, building, status
      let students = await StudentService.getAllStudents();

      // Apply filters
      if (status) {
        students = students.filter((s) => s.study_status === status);
      } else {
        students = students.filter((s) => s.study_status === 'Active');
      }

      if (faculty) {
        students = students.filter((s) => s.faculty === faculty);
      }

      if (buildingId) {
        students = students.filter((s) => s.building_id === buildingId);
      }

      // KHÔNG lọc theo date - student không có thuộc tính ngày

      // Pagination
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const paginatedStudents = students.slice(startIndex, endIndex);

      res.json({
        data: paginatedStudents,
        pagination: {
          total: students.length,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(students.length / limitNum),
        },
      });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Error getting students for drill-down: ', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getRoomsForDrillDown(
    req: Request<{}, {}, {}, RoomsQueryDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { buildingId, page, limit } = req.query;
      const pageNum = page ? parseInt(page as string, 10) : 1;
      const limitNum = limit ? parseInt(limit as string, 10) : 20;

      let rooms;
      if (buildingId) {
        const roomsService = new RoomsService();
        rooms = await roomsService.getRoomsByBuildingId(buildingId);
      } else {
        const roomsService = new RoomsService();
        rooms = await roomsService.getAllRooms();
      }

      // Pagination
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const paginatedRooms = rooms.slice(startIndex, endIndex);

      res.json({
        data: paginatedRooms,
        pagination: {
          total: rooms.length,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(rooms.length / limitNum),
        },
      });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Error getting rooms for drill-down: ', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getDisciplinesForDrillDown(
    req: Request<{}, {}, {}, DisciplinesQueryDto>,
    res: Response,
  ): Promise<void> {
    try {
      const {
        severity,
        status,
        from,
        to,
        month,
        buildingId,
        page,
        limit,
      } = req.query;
      const pageNum = page ? parseInt(page as string, 10) : 1;
      const limitNum = limit ? parseInt(limit as string, 10) : 20;
      const offset = (pageNum - 1) * limitNum;

      // Normalize buildingId
      const normalizedBuildingId = buildingId && 
                                    buildingId.trim() !== '' && 
                                    buildingId.toUpperCase() !== 'ALL' 
                                    ? buildingId.trim().toUpperCase() 
                                    : null;

      // Build WHERE conditions
      const whereConditions: string[] = ["da.status != 'cancelled'"];
      const params: any[] = [];

      // Always join with student_discipline to ensure action has students
      let joinClause = '';
      if (normalizedBuildingId) {
        // Filter by specific building: join to student table
        joinClause = `
          INNER JOIN student_discipline sd ON da.action_id = sd.action_id
          INNER JOIN student s ON sd.sssn = s.sssn`;
        whereConditions.push('s.building_id = ?');
        params.push(normalizedBuildingId);
      } else {
        // All buildings: just ensure action has at least one student
        joinClause = `INNER JOIN student_discipline sd ON da.action_id = sd.action_id`;
      }

      // Filter by severity
      if (severity) {
        whereConditions.push('da.severity_level = ?');
        params.push(severity.toLowerCase());
      }

      // Filter by status
      if (status) {
        whereConditions.push('da.status = ?');
        params.push(status.toLowerCase());
      }

      // Filter by date range
      if (from && to && from.trim() !== '' && to.trim() !== '') {
        whereConditions.push('da.decision_date BETWEEN ? AND ?');
        params.push(from.trim(), to.trim());
      }

      // Filter by month (format: YYYY-MM)
      if (month && month.trim() !== '') {
        // Extract year and month from YYYY-MM format
        const [year, monthNum] = month.split('-');
        if (year && monthNum) {
          // Get first and last day of the month
          const firstDay = `${year}-${monthNum}-01`;
          const lastDay = new Date(parseInt(year), parseInt(monthNum), 0).toISOString().split('T')[0];
          whereConditions.push('da.decision_date BETWEEN ? AND ?');
          params.push(firstDay, lastDay);
        }
      }

      const whereClause = whereConditions.length > 0 
        ? `WHERE ${whereConditions.join(' AND ')}`
        : '';

      // Count total records for pagination
      const countQuery = `
        SELECT COUNT(DISTINCT da.action_id) as total
        FROM disciplinary_action da
        ${joinClause}
        ${whereClause}
      `;

      // Main query - get distinct disciplines with student SSN
      const query = `
        SELECT DISTINCT
          da.action_id,
          da.action_type,
          da.reason,
          da.decision_date,
          da.effective_from,
          da.effective_to,
          da.severity_level,
          da.status,
          sd.sssn
        FROM disciplinary_action da
        ${joinClause}
        ${whereClause}
        ORDER BY da.decision_date DESC
        LIMIT ? OFFSET ?
      `;

      console.log('[getDisciplinesForDrillDown] Query:', query.replace(/\s+/g, ' ').trim());
      console.log('[getDisciplinesForDrillDown] Count Query:', countQuery.replace(/\s+/g, ' ').trim());
      console.log('[getDisciplinesForDrillDown] Params:', [...params, limitNum, offset]);
      console.log('[getDisciplinesForDrillDown] Filters:', { severity, status, from, to, month, buildingId: normalizedBuildingId });

      // Execute count query
      const countResult: any = await pool.query(countQuery, params);
      const total = countResult[0]?.[0]?.total || 0;

      // Execute main query
      const result: any = await pool.query(query, [...params, limitNum, offset]);
      
      // Handle different result formats from mysql2
      let rows: any[] = [];
      if (Array.isArray(result)) {
        rows = Array.isArray(result[0]) ? result[0] : [];
      } else if (result && Array.isArray(result[0])) {
        rows = result[0];
      } else if (Array.isArray(result)) {
        rows = result;
      }

      console.log('[getDisciplinesForDrillDown] Result rows:', rows.length);
      console.log('[getDisciplinesForDrillDown] Total count:', total);

      res.json({
        data: rows,
        pagination: {
          total: total,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum),
        },
      });
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      console.error('Error getting disciplines for drill-down: ', error);
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }
}
