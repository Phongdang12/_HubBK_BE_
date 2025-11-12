export interface Room {
  buildingId: string;
  roomId: string;
  maxNumberOfStudents: number;
  currentNumberOfStudents: number;
  occupancyRate: number;
}
