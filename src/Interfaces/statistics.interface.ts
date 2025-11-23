export interface DisciplinedStudentsResponse {
  totalDisciplinedStudents: number;
}

export interface TotalStudentsByBuildingResponse {
  totalStudents: number;
}

export interface ValidDormitoryCardsResponse {
  validDormCards: number;
}

// New interfaces for dashboard statistics
export interface StatisticsOverviewResponse {
  occupancyRate: number;
  totalStudents: number;
  availableRooms: number;
  pendingDiscipline: number;
  totalCapacity: number;
  currentResidents: number;
}

export interface FacultyDistributionItem {
  faculty: string;
  count: number;
}

export interface FacultyDistributionResponse {
  data: FacultyDistributionItem[];
}

export interface OccupancyByBuildingItem {
  building: string;
  totalCapacity: number;
  currentResidents: number;
  available: number;
}

export interface OccupancyByBuildingResponse {
  data: OccupancyByBuildingItem[];
}

export interface DisciplineSeverityItem {
  severity: string;
  count: number;
}

export interface DisciplineSeverityResponse {
  data: DisciplineSeverityItem[];
}

export interface ViolationsTrendItem {
  month: string;
  count: number;
}

export interface ViolationsTrendResponse {
  data: ViolationsTrendItem[];
}