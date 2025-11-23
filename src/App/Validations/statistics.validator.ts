import { z } from 'zod';

export const GetDisciplinedStudents = z.object({
  startDate: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Invalid startDate format',
  }),
  endDate: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Invalid endDate format',
  }),
});

export const BuildingIdParams = z.object({
  buildingId: z
    .string()
    .min(1, {
      message: 'Building ID is required',
    })
    .max(5, {
      message: 'Building ID must be at most 5 characters long',
    }),
});

// New validators for dashboard statistics
export const StatisticsQueryParams = z.object({
  from: z.string().optional(),
  to: z.string().optional(),
  buildingId: z.string().optional(),
});

export const FacultyDistributionQuery = StatisticsQueryParams;
export const OccupancyByBuildingQuery = StatisticsQueryParams;
export const DisciplineSeverityQuery = StatisticsQueryParams;
export const ViolationsTrendQuery = StatisticsQueryParams;

// Drill-down query params (keep as strings, parse in controller)
export const StudentsQuery = z.object({
  faculty: z.string().optional(),
  from: z.string().optional(),
  to: z.string().optional(),
  buildingId: z.string().optional(),
  status: z.string().optional(),
  page: z.string().optional(),
  limit: z.string().optional(),
});

export const RoomsQuery = z.object({
  buildingId: z.string().optional(),
  from: z.string().optional(),
  to: z.string().optional(),
  page: z.string().optional(),
  limit: z.string().optional(),
});

export const DisciplinesQuery = z.object({
  severity: z.string().optional(),
  status: z.string().optional(),
  from: z.string().optional(),
  to: z.string().optional(),
  month: z.string().optional(), // Format: YYYY-MM
  buildingId: z.string().optional(),
  page: z.string().optional(),
  limit: z.string().optional(),
});

export type GetDisciplinedStudentsDto = z.infer<typeof GetDisciplinedStudents>;
export type BuildingIdParamsDto = z.infer<typeof BuildingIdParams>;
export type StatisticsQueryParamsDto = z.infer<typeof StatisticsQueryParams>;
export type StudentsQueryDto = z.infer<typeof StudentsQuery>;
export type RoomsQueryDto = z.infer<typeof RoomsQuery>;
export type DisciplinesQueryDto = z.infer<typeof DisciplinesQuery>;
