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
import { PoolConnection } from 'mysql2/promise';

export class RoomsService {
  constructor() {
    console.log('RoomsService initialized');
  }

  // ... (Giữ nguyên Helper checkRoomGenderCompatibility, getRoomForUpdate, getStudentForUpdate, calculateOccupancy)
  
  private async checkRoomGenderCompatibility(
    conn: PoolConnection,
    buildingId: string,
    roomId: string,
    studentSex: string
  ): Promise<void> {
    const [rows]: any = await conn.query(
      'SELECT sex FROM student WHERE building_id = ? AND room_id = ? LIMIT 1',
      [buildingId, roomId]
    );

    if (Array.isArray(rows) && rows.length > 0) {
      const currentRoomGender = rows[0].sex;
      const roomSexChar = currentRoomGender?.toString().trim().toUpperCase().charAt(0);
      const studentSexChar = studentSex?.toString().trim().toUpperCase().charAt(0);

      if (roomSexChar && studentSexChar && roomSexChar !== studentSexChar) {
        const genderText = roomSexChar === 'M' ? 'Nam' : 'Nữ';
        throw { 
          status: 400, 
          message: `Không thể xếp vào. Phòng này đang là phòng ${genderText}, sinh viên này khác giới tính.` 
        };
      }
    }
  }

  private async getRoomForUpdate(conn: any, buildingId: string, roomId: string) {
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
      'SELECT sssn, building_id, room_id, sex FROM student WHERE sssn = ? FOR UPDATE',
      [sssn],
    );
    if (!Array.isArray(rows) || rows.length === 0) {
      console.error('Lỗi:', STUDENT_NOT_FOUND_ERROR);
      throw { status: 404, message: STUDENT_NOT_FOUND_ERROR };
    }
    return rows[0];
  }

  private calculateOccupancy(current: number, max: number) {
    if (!max || max <= 0) return 0;
    return Number(((current / max) * 100).toFixed(2));
  }

  // =================================================================
  // CÁC HÀM GET DỮ LIỆU (Query)
  // =================================================================

  async getAllRooms(): Promise<Room[]> {
    const result = await pool.query('CALL list_all_rooms()');
    const rows = result[0];
    if (Array.isArray(rows) && Array.isArray(rows[0])) {
      return rows[0] as Room[];
    }
    throw new Error('Unexpected result format');
  }

  async getRoomsByBuildingId(buildingId: string): Promise<Room[]> {
    if (buildingId.length > 5) throw new Error('Building ID is exactly 5 characters long');
    const result = await pool.query('CALL list_rooms_building(?)', [buildingId]);
    const rows = result[0];
    if (Array.isArray(rows) && Array.isArray(rows[0])) return rows[0] as Room[];
    throw new Error('Unexpected result format');
  }

  async getUnderoccupiedRooms(): Promise<Room[]> {
    const result = await pool.query('CALL list_all_underoccupied_rooms()');
    const rows = result[0];
    if (Array.isArray(rows) && Array.isArray(rows[0])) return rows[0] as Room[];
    throw new Error('Unexpected result format');
  }

  // ✅ ĐÃ SỬA LỖI Ở ĐÂY: Trả về rows[0][0] (Object) thay vì rows[0] (Array)
  async getRoomDetail(buildingId: string, roomId: string): Promise<Room> {
    const result: any = await pool.query(`CALL get_room_detail(?, ?)`, [buildingId, roomId]);
    const rows = result[0]; // Mảng các result set
    
    // rows[0] là result set đầu tiên (danh sách các dòng)
    // rows[0][0] là dòng đầu tiên (object phòng)
    if (!rows || !rows[0] || !rows[0][0]) {
        throw new Error('Room not found');
    }
    return rows[0][0]; 
  }

  async getStudentsInRoom(buildingId: string, roomId: string): Promise<Student[]> {
    const result: any = await pool.query('CALL get_students_in_room(?, ?)', [buildingId, roomId]);
    const rows = result[0];
    if (!rows || !Array.isArray(rows[0])) return [];
    return rows[0];
  }

  async getUnderoccupiedRoomsByBuildingId(buildingId: string): Promise<Room[]> {
    if (buildingId.length > 5) throw new Error('Building ID is exactly 5 characters long');
    const result = await pool.query('CALL list_underoccupied_by_building(?)', [buildingId]);
    const rows = result[0];
    if (Array.isArray(rows) && Array.isArray(rows[0])) return rows[0] as Room[];
    throw new Error('Unexpected result format');
  }

  async checkUnderoccupiedRoom(buildingId: string, roomId: string): Promise<Room[]> {
    if (buildingId.length > 5) throw new Error('Building ID is exactly 5 characters long');
    if (roomId.length > 5) throw new Error('Room ID is exactly 5 characters long');
    const result = await pool.query('CALL check_one_room_underoccupied(?, ?)', [buildingId, roomId]);
    const rows = result[0];
    if (Array.isArray(rows) && Array.isArray(rows[0])) return rows[0] as Room[];
    throw new Error('Unexpected result format');
  }

  // ... (Giữ nguyên phần updateRoom, addStudentToRoom, transferStudent, removeStudentFromRoom như file trước)
  // Vì lỗi chỉ nằm ở hàm getRoomDetail nên các hàm dưới không cần sửa đổi gì thêm so với phiên bản trước.
  
  async updateRoom(buildingId: string, roomId: string, data: RoomUpdateBodyDto): Promise<Room> {
    const { max_num_of_students, current_num_of_students, rental_price, room_status } = data;
    if (max_num_of_students < current_num_of_students) throw { status: 400, message: MAX_STUDENTS_ERROR };
    if (current_num_of_students > max_num_of_students) throw { status: 400, message: CURRENT_STUDENTS_ERROR };
    if (rental_price < 10_000_000) throw { status: 400, message: RENTAL_PRICE_ERROR };
    if (!['Available', 'Occupied', 'Under Maintenance'].includes(room_status)) throw { status: 400, message: ROOM_STATUS_ERROR };

    await pool.query('CALL update_room(?, ?, ?, ?, ?, ?)', [buildingId, roomId, max_num_of_students, current_num_of_students, rental_price, room_status]);
    return this.getRoomDetail(buildingId, roomId);
  }

  async addStudentToRoom(buildingId: string, roomId: string, sssn: string): Promise<Room> {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Lock dữ liệu phòng và sinh viên
      const room = await this.getRoomForUpdate(conn, buildingId, roomId);
      if (room.current_num_of_students >= room.max_num_of_students) {
        throw { status: 400, message: 'Phòng đã đầy.' };
      }

      const student = await this.getStudentForUpdate(conn, sssn);
      if (student.building_id && student.room_id) {
        throw { status: 400, message: 'Sinh viên đang ở phòng khác.' };
      }

      // Kiểm tra giới tính
      await this.checkRoomGenderCompatibility(conn, buildingId, roomId, student.sex);

      // Cập nhật sinh viên
      await conn.query('UPDATE student SET building_id = ?, room_id = ? WHERE sssn = ?', [buildingId, roomId, sssn]);

      // Tính toán chỉ số mới cho phòng
      const newCurrent = room.current_num_of_students + 1;
      const occupancy = this.calculateOccupancy(newCurrent, room.max_num_of_students);
      
      // LOGIC MỚI: Nếu đầy thì chuyển thành 'Occupied', ngược lại là 'Available'
      const newStatus = newCurrent >= room.max_num_of_students ? 'Occupied' : 'Available';

      // Cập nhật phòng (bao gồm cả room_status)
      await conn.query(
        'UPDATE living_room SET current_num_of_students = ?, occupancy_rate = ?, room_status = ? WHERE building_id = ? AND room_id = ?', 
        [newCurrent, occupancy, newStatus, buildingId, roomId]
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
  
  async transferStudent(sssn: string, targetBuildingId: string, targetRoomId: string): Promise<void> {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // 1. Lấy thông tin cần thiết và khóa dòng (Locking)
      const student = await this.getStudentForUpdate(conn, sssn);
      const oldBuildingId = student.building_id;
      const oldRoomId = student.room_id;

      if (!oldBuildingId || !oldRoomId) throw { status: 400, message: 'Sinh viên chưa có phòng.' };
      if (oldBuildingId === targetBuildingId && oldRoomId === targetRoomId) throw { status: 400, message: 'Sinh viên đang ở phòng này rồi.' };

      const targetRoom = await this.getRoomForUpdate(conn, targetBuildingId, targetRoomId);
      if (targetRoom.current_num_of_students >= targetRoom.max_num_of_students) throw { status: 400, message: `Phòng đích ${targetRoomId} đã đầy.` };
      
      await this.checkRoomGenderCompatibility(conn, targetBuildingId, targetRoomId, student.sex);
      const oldRoom = await this.getRoomForUpdate(conn, oldBuildingId, oldRoomId);

      // 2. Cập nhật bảng STUDENT
      await conn.query('UPDATE student SET building_id = ?, room_id = ? WHERE sssn = ?', [targetBuildingId, targetRoomId, sssn]);

      // 3. Cập nhật PHÒNG CŨ (Nơi sinh viên rời đi)
      const oldCurrent = Math.max(oldRoom.current_num_of_students - 1, 0);
      const oldOccupancy = this.calculateOccupancy(oldCurrent, oldRoom.max_num_of_students);
      // Logic: Nếu sinh viên rời đi, phòng chắc chắn sẽ "Available" (trừ khi max=0)
      const oldStatus = oldCurrent < oldRoom.max_num_of_students ? 'Available' : 'Occupied';

      await conn.query(
        'UPDATE living_room SET current_num_of_students = ?, occupancy_rate = ?, room_status = ? WHERE building_id = ? AND room_id = ?', 
        [oldCurrent, oldOccupancy, oldStatus, oldBuildingId, oldRoomId]
      );

      // 4. Cập nhật PHÒNG MỚI (Nơi sinh viên đến)
      const newCurrent = targetRoom.current_num_of_students + 1;
      const newOccupancy = this.calculateOccupancy(newCurrent, targetRoom.max_num_of_students);
      // Logic: Nếu đầy thì set thành 'Occupied', chưa đầy thì 'Available'
      const newStatus = newCurrent >= targetRoom.max_num_of_students ? 'Occupied' : 'Available';

      await conn.query(
        'UPDATE living_room SET current_num_of_students = ?, occupancy_rate = ?, room_status = ? WHERE building_id = ? AND room_id = ?', 
        [newCurrent, newOccupancy, newStatus, targetBuildingId, targetRoomId]
      );

      await conn.commit();
    } catch (error) {
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  async removeStudentFromRoom(buildingId: string, roomId: string, sssn: string): Promise<Room> {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const room = await this.getRoomForUpdate(conn, buildingId, roomId);
      const student = await this.getStudentForUpdate(conn, sssn);

      if (student.building_id !== buildingId || student.room_id !== roomId) {
        throw { status: 400, message: STUDENT_NOT_IN_ROOM_ERROR };
      }

      // Xóa thông tin phòng khỏi sinh viên
      await conn.query('UPDATE student SET building_id = NULL, room_id = NULL WHERE sssn = ?', [sssn]);

      // Tính toán chỉ số mới cho phòng
      const newCurrent = Math.max(room.current_num_of_students - 1, 0);
      const occupancy = this.calculateOccupancy(newCurrent, room.max_num_of_students);

      // LOGIC MỚI: Khi xóa bớt người, phòng thường sẽ có chỗ trống -> 'Available'
      // Kiểm tra kỹ: Nếu vẫn đầy (trường hợp max=0 lạ lùng nào đó) thì giữ Occupied, còn lại là Available
      const newStatus = newCurrent < room.max_num_of_students ? 'Available' : 'Occupied';

      // Cập nhật phòng (bao gồm cả room_status)
      await conn.query(
        'UPDATE living_room SET current_num_of_students = ?, occupancy_rate = ?, room_status = ? WHERE building_id = ? AND room_id = ?', 
        [newCurrent, occupancy, newStatus, buildingId, roomId]
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
}