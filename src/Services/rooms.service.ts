import pool from '@/Config/db.config';
import { Room } from '@/Interfaces/rooms.interface';
import { Student } from '@/Interfaces/student.interface';
import {
  CURRENT_STUDENTS_ERROR,
  MAX_STUDENTS_ERROR,
  OCCUPANCY_RATE_ERROR,
  RENTAL_PRICE_ERROR,
  ROOM_STATUS_ERROR,
  STUDENT_NOT_FOUND_ERROR,
  STUDENT_NOT_IN_ROOM_ERROR,
} from '@/App/Validations/rooms.validator';
import { RoomUpdateBodyDto } from '@/App/Validations/rooms.validator';

export class RoomsService {
  constructor() {
    console.log('RoomsService initialized');
  }

  async getAllRooms(): Promise<Room[]> {
    const result = await pool.query('CALL list_all_rooms()');
    const rows = result[0];

    if (Array.isArray(rows) && Array.isArray(rows[0])) {
      return rows[0] as Room[];
    } else {
      throw new Error('Unexpected result format');
    }
  }

  async getRoomsByBuildingId(buildingId: string): Promise<Room[]> {
    if (buildingId.length > 5) {
      throw new Error('Building ID is exactly 5 characters long');
    }
    const result = await pool.query('CALL list_rooms_building(?)', [
      buildingId,
    ]);
    const rows = result[0];

    if (Array.isArray(rows) && Array.isArray(rows[0])) {
      return rows[0] as Room[];
    } else {
      throw new Error('Unexpected result format');
    }
  }

  async getUnderoccupiedRooms(): Promise<Room[]> {
    const result = await pool.query('CALL list_all_underoccupied_rooms()');
    const rows = result[0];

    if (Array.isArray(rows) && Array.isArray(rows[0])) {
      return rows[0] as Room[];
    } else {
      throw new Error('Unexpected result format');
    }
  }
  async getRoomDetail(buildingId: string, roomId: string): Promise<Room> {
    const result: any = await pool.query(`CALL get_room_detail(?, ?)`, [buildingId, roomId]);

    const rows = result[0];
    const room = rows[0][0];

    if (!room) {
      throw new Error('Room not found');
    }

    return room;
  }

  private calculateOccupancy(current: number, max: number) {
    if (!max || max <= 0) return 0;
    return Number(((current / max) * 100).toFixed(2));
  }

  async updateRoom(
    buildingId: string,
    roomId: string,
    data: RoomUpdateBodyDto,
  ): Promise<Room> {
    const {
      max_num_of_students,
      current_num_of_students,
      rental_price,
      room_status,
    } = data;

    if (max_num_of_students < current_num_of_students) {
      console.error('Lỗi:', MAX_STUDENTS_ERROR);
      throw { status: 400, message: MAX_STUDENTS_ERROR };
    }

    if (current_num_of_students > max_num_of_students) {
      console.error('Lỗi:', CURRENT_STUDENTS_ERROR);
      throw { status: 400, message: CURRENT_STUDENTS_ERROR };
    }

    if (rental_price < 10_000_000) {
      console.error('Lỗi:', RENTAL_PRICE_ERROR);
      throw { status: 400, message: RENTAL_PRICE_ERROR };
    }

    if (!['Available', 'Occupied', 'Under Maintenance'].includes(room_status)) {
      console.error('Lỗi:', ROOM_STATUS_ERROR);
      throw { status: 400, message: ROOM_STATUS_ERROR };
    }

    await pool.query('CALL update_room(?, ?, ?, ?, ?, ?)', [
      buildingId,
      roomId,
      max_num_of_students,
      current_num_of_students,
      rental_price,
      room_status,
    ]);

    const refreshed = await this.getRoomDetail(buildingId, roomId);
    const expectedOccupancy = this.calculateOccupancy(
      current_num_of_students,
      max_num_of_students,
    );

    if (
      typeof refreshed?.occupancy_rate === 'number' &&
      Math.abs(refreshed.occupancy_rate - expectedOccupancy) > 0.01
    ) {
      console.error('Lỗi:', OCCUPANCY_RATE_ERROR);
      throw { status: 400, message: OCCUPANCY_RATE_ERROR };
    }

    return refreshed;
  }

  private async getRoomForUpdate(
    conn: any,
    buildingId: string,
    roomId: string,
  ) {
    const [rows] = await conn.query(
      'SELECT max_num_of_students, current_num_of_students FROM living_room WHERE building_id = ? AND room_id = ? FOR UPDATE',
      [buildingId, roomId],
    );
    if (!Array.isArray(rows) || rows.length === 0) {
      throw { status: 404, message: 'Room not found' };
    }
    return rows[0];
  }

  private async getStudentForUpdate(conn: any, sssn: string) {
    const [rows] = await conn.query(
      'SELECT sssn, building_id, room_id FROM student WHERE sssn = ? FOR UPDATE',
      [sssn],
    );
    if (!Array.isArray(rows) || rows.length === 0) {
      console.error('Lỗi:', STUDENT_NOT_FOUND_ERROR);
      throw { status: 404, message: STUDENT_NOT_FOUND_ERROR };
    }
    return rows[0];
  }

  async addStudentToRoom(
    buildingId: string,
    roomId: string,
    sssn: string,
  ): Promise<Room> {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const room = await this.getRoomForUpdate(conn, buildingId, roomId);
      if (room.current_num_of_students >= room.max_num_of_students) {
        console.error('Lỗi:', CURRENT_STUDENTS_ERROR);
        throw { status: 400, message: CURRENT_STUDENTS_ERROR };
      }

      const student = await this.getStudentForUpdate(conn, sssn);
      if (student.building_id && student.room_id) {
        console.error(
          'Lỗi: Sinh viên đang được gán cho phòng khác.',
          student.building_id,
          student.room_id,
        );
        throw {
          status: 400,
          message: 'Sinh viên đang thuộc phòng khác. Vui lòng chuyển sinh viên ra trước.',
        };
      }

      await conn.query(
        'UPDATE student SET building_id = ?, room_id = ? WHERE sssn = ?',
        [buildingId, roomId, sssn],
      );

      const newCurrent = room.current_num_of_students + 1;
      const occupancy = this.calculateOccupancy(newCurrent, room.max_num_of_students);
      await conn.query(
        'UPDATE living_room SET current_num_of_students = ?, occupancy_rate = ? WHERE building_id = ? AND room_id = ?',
        [newCurrent, occupancy, buildingId, roomId],
      );

      await conn.commit();
      return this.getRoomDetail(buildingId, roomId);
    } catch (error) {
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  async removeStudentFromRoom(
    buildingId: string,
    roomId: string,
    sssn: string,
  ): Promise<Room> {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const room = await this.getRoomForUpdate(conn, buildingId, roomId);
      const student = await this.getStudentForUpdate(conn, sssn);

      if (student.building_id !== buildingId || student.room_id !== roomId) {
        console.error('Lỗi:', STUDENT_NOT_IN_ROOM_ERROR);
        throw { status: 400, message: STUDENT_NOT_IN_ROOM_ERROR };
      }

      await conn.query(
        'UPDATE student SET building_id = NULL, room_id = NULL WHERE sssn = ?',
        [sssn],
      );

      const newCurrent = Math.max(room.current_num_of_students - 1, 0);
      const occupancy = this.calculateOccupancy(
        newCurrent,
        room.max_num_of_students,
      );
      await conn.query(
        'UPDATE living_room SET current_num_of_students = ?, occupancy_rate = ? WHERE building_id = ? AND room_id = ?',
        [newCurrent, occupancy, buildingId, roomId],
      );

      await conn.commit();
      return this.getRoomDetail(buildingId, roomId);
    } catch (error) {
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  async getStudentsInRoom(buildingId: string, roomId: string): Promise<Student[]> {
    const result: any = await pool.query('CALL get_students_in_room(?, ?)', [buildingId, roomId]);
    const rows = result[0];
    if (!rows || !Array.isArray(rows[0])) return [];
    return rows[0];
  }

  async getUnderoccupiedRoomsByBuildingId(buildingId: string): Promise<Room[]> {
    if (buildingId.length > 5) {
      throw new Error('Building ID is exactly 5 characters long');
    }
    const result = await pool.query('CALL list_underoccupied_by_building(?)', [
      buildingId,
    ]);
    const rows = result[0];

    if (Array.isArray(rows) && Array.isArray(rows[0])) {
      return rows[0] as Room[];
    } else {
      throw new Error('Unexpected result format');
    }
  }

  async checkUnderoccupiedRoom(
    buildingId: string,
    roomId: string,
  ): Promise<Room[]> {
    if (buildingId.length > 5) {
      throw new Error('Building ID is exactly 5 characters long');
    }

    if (roomId.length > 5) {
      throw new Error('Room ID is exactly 5 characters long');
    }
    const result = await pool.query('CALL check_one_room_underoccupied(?, ?)', [
      buildingId,
      roomId,
    ]);
    const rows = result[0];

    if (Array.isArray(rows) && Array.isArray(rows[0])) {
      return rows[0] as Room[];
    } else {
      throw new Error('Unexpected result format');
    }
  }
}
