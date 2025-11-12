import express from 'express';
import { RoomsController } from '@/App/Controllers/rooms.controller';
import { validateAll } from '@/App/Middlewares/validate';
import {
  BuildingIdParams,
  RoomCheckParams,
} from '@/App/Validations/rooms.validator';
import { verifyToken } from '@/App/Middlewares/auth';

const roomsRouter = express.Router();
const roomsController = new RoomsController();

roomsRouter
  .get('/', verifyToken, roomsController.getAllRooms.bind(roomsController))
  .get(
    '/underoccupied',
    verifyToken,
    roomsController.getUnderoccupiedRooms.bind(roomsController),
  )
  .get(
    '/:buildingId',
    verifyToken,
    validateAll({ params: BuildingIdParams }),
    roomsController.getRoomsByBuildingId.bind(roomsController),
  )
  .get(
    '/underoccupied/:buildingId',
    verifyToken,
    validateAll({ params: BuildingIdParams }),
    roomsController.getUnderoccupiedRoomsByBuildingId.bind(roomsController),
  )
  .get(
    '/underoccupied/:buildingId/:roomId',
    verifyToken,
    validateAll({ params: RoomCheckParams }),
    roomsController.checkUnderoccupiedRoom.bind(roomsController),
  );

export default roomsRouter;
