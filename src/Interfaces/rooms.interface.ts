export interface Room {
  building_id: string;
  room_id: string;
  max_num_of_students: number;
  current_num_of_students: number;
  occupancy_rate: number;    // <-- NÊN là number, MySQL DECIMAL → FE nhận number
  rental_price: number;      // <-- Cũng nên là number
  room_status: 'Available' | 'Occupied' | 'Under Maintenance';
  room_gender: 'Male' | 'Female' | 'Co-ed';
}
