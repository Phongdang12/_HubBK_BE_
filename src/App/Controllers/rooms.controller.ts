import { Request, Response } from 'express';
import { ZodError, ZodIssue } from 'zod';
import {
  BuildingIdParamsDto,
  RoomCheckParamsDto,
  RoomStudentMutationBody,
  RoomStudentMutationBodyDto,
  RoomUpdateBody,
  RoomUpdateBodyDto,
  GENERAL_ROOM_ERROR,
  STUDENT_NOT_FOUND_ERROR,
} from '../Validations/rooms.validator';
import { RoomsService } from '@/Services/rooms.service';
import { QueryError } from 'mysql2';

export class RoomsController {
  private roomsService: RoomsService;

  constructor() {
    this.roomsService = new RoomsService();
    console.log('RoomsController initialized');
  }

  private static logRoomError(message: string, value?: unknown) {
    const printable =
      value === undefined || value === null || value === ''
        ? 'Không có'
        : JSON.stringify(value);
    console.error(`Lỗi: ${message} Giá trị được chọn: ${printable}.`);
  }

  private static respondWithFieldErrors(
    res: Response,
    fieldErrors: { field: string; message: string }[],
    source?: Record<string, unknown>,
    status = 400,
  ) {
    fieldErrors.forEach(({ field, message }) => {
      const value = source ? source[field] : undefined;
      RoomsController.logRoomError(message, value);
    });

    res.status(status).json({
      error: GENERAL_ROOM_ERROR,
      fieldErrors,
    });
  }

  private static mapIssues(issues: ZodIssue[]) {
    return issues.map((issue) => ({
      field: issue.path?.[0]?.toString() || 'form',
      message: issue.message,
    }));
  }

  private parseRoomUpdatePayload(
    res: Response,
    rawBody: unknown,
  ): RoomUpdateBodyDto | null {
    const parsed = RoomUpdateBody.safeParse(rawBody);
    if (!parsed.success) {
      RoomsController.respondWithFieldErrors(
        res,
        RoomsController.mapIssues(parsed.error.issues),
        rawBody as Record<string, unknown>,
      );
      return null;
    }
    return parsed.data;
  }

  private parseStudentMutationBody(
    res: Response,
    rawBody: unknown,
  ): RoomStudentMutationBodyDto | null {
    const parsed = RoomStudentMutationBody.safeParse(rawBody);
    if (!parsed.success) {
      RoomsController.respondWithFieldErrors(
        res,
        RoomsController.mapIssues(parsed.error.issues),
        rawBody as Record<string, unknown>,
      );
      return null;
    }
    return parsed.data;
  }

  private handleServiceError(res: Response, error: any) {
    if (error instanceof ZodError) {
      RoomsController.respondWithFieldErrors(
        res,
        RoomsController.mapIssues(error.issues),
      );
      return;
    }

    if (error && typeof error === 'object' && error.status) {
      console.error('Lỗi:', error.message);
      res.status(error.status).json({ error: error.message });
      return;
    }

    const mysqlErrorMessage =
      (error as QueryError).message || 'Unknown error';
    console.error('Unexpected room error:', mysqlErrorMessage);
    res.status(500).json({ error: mysqlErrorMessage });
  }

  async getAllRooms(_req: Request, res: Response): Promise<void> {
    try {
      console.log('getAllRooms called');
      const result = await this.roomsService.getAllRooms();
      res.json(result);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }
  async getRoomDetail(req: Request<RoomCheckParamsDto>, res: Response): Promise<void> {
    try {
      const { buildingId, roomId } = req.params;

      // Trực tiếp lấy object Room từ service
      const room = await this.roomsService.getRoomDetail(buildingId, roomId);
      console.log('Params received:', buildingId, roomId);
      if (!room) {
        res.status(404).json({ message: 'Room not found' });
        return;
      }
      console.log('Room from DB:', room);
      const formatted = {
        building_id: room.building_id,
        room_id: room.room_id,
        max_num_of_students: room.max_num_of_students,
        current_num_of_students: room.current_num_of_students,
        occupancy_rate: room.occupancy_rate,
        rental_price: room.rental_price,
        room_status: room.room_status,
      };

      res.status(200).json(formatted);
    } catch (error) {
      console.error('getRoomDetail error:', error);
      const msg = (error as QueryError).message || 'Unknown error';
      res.status(500).json({ message: msg });
    }
  }
  async getStudentsInRoom(req: Request<RoomCheckParamsDto>, res: Response): Promise<void> {
    try {
      const { buildingId, roomId } = req.params;
      const students = await this.roomsService.getStudentsInRoom(buildingId, roomId);
      res.status(200).json(students);
    } catch (error) {
      const msg = (error as QueryError).message || 'Unknown error';
      res.status(500).json({ message: msg });
    }
  }
  async updateRoom(
    req: Request<RoomCheckParamsDto>,
    res: Response,
  ): Promise<void> {
    const { buildingId, roomId } = req.params;
    const parsedBody = this.parseRoomUpdatePayload(res, req.body);
    if (!parsedBody) return;

    try {
      const updated = await this.roomsService.updateRoom(
        buildingId,
        roomId,
        parsedBody,
      );
      res.status(200).json(updated);
    } catch (error) {
      this.handleServiceError(res, error);
    }
  }

  async addStudentToRoom(
    req: Request<RoomCheckParamsDto>,
    res: Response,
  ): Promise<void> {
    const { buildingId, roomId } = req.params;
    const parsedBody = this.parseStudentMutationBody(res, req.body);
    if (!parsedBody) return;

    try {
      const updatedRoom = await this.roomsService.addStudentToRoom(
        buildingId,
        roomId,
        parsedBody.sssn,
      );
      res.status(200).json(updatedRoom);
    } catch (error) {
      this.handleServiceError(res, error);
    }
  }

  async removeStudentFromRoom(
    req: Request<{ buildingId: string; roomId: string; sssn: string }>,
    res: Response,
  ): Promise<void> {
    const { buildingId, roomId, sssn } = req.params;

    if (!/^\d{8}$/.test(sssn)) {
      RoomsController.logRoomError(STUDENT_NOT_FOUND_ERROR, sssn);
      res.status(400).json({ error: STUDENT_NOT_FOUND_ERROR });
      return;
    }

    try {
      const updatedRoom = await this.roomsService.removeStudentFromRoom(
        buildingId,
        roomId,
        sssn,
      );
      res.status(200).json(updatedRoom);
    } catch (error) {
      this.handleServiceError(res, error);
    }
  }

  async getRoomsByBuildingId(
    req: Request<BuildingIdParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      console.log('getRoomsByBuildingId called');
      const { buildingId } = req.params;
      const result = await this.roomsService.getRoomsByBuildingId(buildingId);
      res.json(result);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getUnderoccupiedRooms(_req: Request, res: Response): Promise<void> {
    try {
      console.log('getUnderoccupiedRooms called');
      const result = await this.roomsService.getUnderoccupiedRooms();
      res.json(result);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async getUnderoccupiedRoomsByBuildingId(
    req: Request<BuildingIdParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      console.log('getUnderoccupiedRoomsByBuildingId called');
      const { buildingId } = req.params;
      const result =
        await this.roomsService.getUnderoccupiedRoomsByBuildingId(buildingId);
      res.json(result);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }

  async checkUnderoccupiedRoom(
    req: Request<RoomCheckParamsDto>,
    res: Response,
  ): Promise<void> {
    try {
      const { buildingId, roomId } = req.params;
      const result = await this.roomsService.checkUnderoccupiedRoom(
        buildingId,
        roomId,
      );
      res.json(result);
    } catch (error) {
      const mysqlErrorMessage =
        (error as QueryError).message || 'Unknown error';
      res.status(500).json({ success: false, message: mysqlErrorMessage });
    }
  }
}
