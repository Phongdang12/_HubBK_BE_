import express from 'express';
import { StatisticsController } from '@/App/Controllers/statistics.controller';
import { validateAll } from '@/App/Middlewares/validate';
import {
  GetDisciplinedStudents,
  BuildingIdParams,
  StatisticsQueryParams,
  StudentsQuery,
  RoomsQuery,
  DisciplinesQuery,
} from '@/App/Validations/statistics.validator';
import { verifyToken } from '@/App/Middlewares/auth';

const statisticsRouter = express.Router();
const statisticsController = new StatisticsController();

// Legacy endpoints
statisticsRouter
  .get(
    '/disciplined-students',
    verifyToken,
    validateAll({ query: GetDisciplinedStudents }),
    statisticsController.getDisciplinedStudents.bind(statisticsController),
  )
  .get(
    '/total-students/:buildingId',
    verifyToken,
    validateAll({ params: BuildingIdParams }),
    statisticsController.getTotalStudentsByBuilding.bind(statisticsController),
  )
  .get(
    '/valid-dormitory-cards',
    verifyToken,
    statisticsController.getValidDormitoryCards.bind(statisticsController),
  );

// New dashboard endpoints
statisticsRouter
  .get(
    '/overview',
    verifyToken,
    validateAll({ query: StatisticsQueryParams }),
    statisticsController.getStatisticsOverview.bind(statisticsController),
  )
  .get(
    '/faculty-distribution',
    verifyToken,
    validateAll({ query: StatisticsQueryParams }),
    statisticsController.getFacultyDistribution.bind(statisticsController),
  )
  .get(
    '/occupancy-by-building',
    verifyToken,
    validateAll({ query: StatisticsQueryParams }),
    statisticsController.getOccupancyByBuilding.bind(statisticsController),
  )
  .get(
    '/discipline-severity',
    verifyToken,
    validateAll({ query: StatisticsQueryParams }),
    statisticsController.getDisciplineSeverity.bind(statisticsController),
  )
  .get(
    '/violations-trend',
    verifyToken,
    validateAll({ query: StatisticsQueryParams }),
    statisticsController.getViolationsTrend.bind(statisticsController),
  );

// Drill-down endpoints
statisticsRouter
  .get(
    '/drill-down/students',
    verifyToken,
    validateAll({ query: StudentsQuery }),
    statisticsController.getStudentsForDrillDown.bind(statisticsController),
  )
  .get(
    '/drill-down/rooms',
    verifyToken,
    validateAll({ query: RoomsQuery }),
    statisticsController.getRoomsForDrillDown.bind(statisticsController),
  )
  .get(
    '/drill-down/disciplines',
    verifyToken,
    validateAll({ query: DisciplinesQuery }),
    statisticsController.getDisciplinesForDrillDown.bind(statisticsController),
  );

export default statisticsRouter;
