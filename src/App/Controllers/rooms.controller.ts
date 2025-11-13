import { Request, Response } from 'express';
import {
  BuildingIdParamsDto,
  RoomCheckParamsDto,
} from '../Validations/rooms.validator';
import { RoomsService } from '@/Services/rooms.service';
import { QueryError } from 'mysql2';

export class RoomsController {
  private roomsService: RoomsService;

  constructor() {
    this.roomsService = new RoomsService();
    console.log('RoomsController initialized');
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
