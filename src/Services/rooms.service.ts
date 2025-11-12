import pool from '@/Config/db.config';
import { Room } from '@/Interfaces/rooms.interface';

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
