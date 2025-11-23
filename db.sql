DROP DATABASE final;
CREATE DATABASE final;
USE `final`;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `building` (
  `building_id` char(5) NOT NULL,
  `building_name` char(5) NOT NULL,
  `floors` int NOT NULL,
  `rooms` int NOT NULL,
  `has_air_conditioner` TINYINT NOT NULL,
  `sponsor` varchar(100) DEFAULT NULL,
  `construction_date` date NOT NULL,
  `last_renovation` date DEFAULT NULL,
  PRIMARY KEY (`building_id`),
  CONSTRAINT `building_chk_1` CHECK ((`floors` > 0)),
  CONSTRAINT `building_chk_2` CHECK ((`rooms` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `building` WRITE;

INSERT INTO `building` VALUES ('BK001','BK001',4,16,1,'HCMUT','2015-01-01','2022-06-01'),('BK002','BK002',4,16,0,'HCMUT','2016-03-15','2023-02-10'),('BK003','BK003',4,16,1,'HCMUT','2017-05-10','2021-09-20'),('BK004','BK004',4,16,1,'HCMUT','2018-07-25',NULL);

UNLOCK TABLES;



CREATE TABLE `cccd` (
  `cccd` char(12) NOT NULL,
  `sssn` char(8) NOT NULL,
  PRIMARY KEY (`cccd`),
  KEY `fk_cccd_student` (`sssn`),
  CONSTRAINT `fk_cccd_student` FOREIGN KEY (`sssn`) REFERENCES `student` (`sssn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `cccd` WRITE;

UNLOCK TABLES;






CREATE TABLE `dormitory_card` (
  `number` char(7) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `id_card` char(8) NOT NULL,
  `validity` TINYINT DEFAULT '1',
  PRIMARY KEY (`number`),
  KEY `id_card` (`id_card`),
  CONSTRAINT `dormitory_card_ibfk_1` FOREIGN KEY (`id_card`) REFERENCES `student` (`sssn`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `dormitory_card_chk_1` CHECK ((`Start_Date` <= `End_Date`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


LOCK TABLES `dormitory_card` WRITE;

UNLOCK TABLES;



CREATE TABLE `living_room` (
  `building_id` char(5) NOT NULL,
  `room_id` char(5) NOT NULL,
  `max_num_of_students` int NOT NULL,
  `current_num_of_students` int NOT NULL DEFAULT '0',
  `rental_price` decimal(10,2) NOT NULL,
  `occupancy_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
  room_status ENUM('Available', 'Occupied', 'Under Maintenance'),
  PRIMARY KEY (`building_id`,`room_id`),
  CONSTRAINT `fk_living_room` FOREIGN KEY (`building_id`, `room_id`) REFERENCES `room` (`building_id`, `room_id`),
  CONSTRAINT `living_room_chk_1` CHECK ((`max_num_of_students` > 0)),
  CONSTRAINT `living_room_chk_2` CHECK ((`current_num_of_students` >= 0)),
  CONSTRAINT `living_room_chk_3` CHECK ((`rental_price` >= 0)),
  CONSTRAINT `living_room_chk_4` CHECK (((`occupancy_rate` >= 0) and (`occupancy_rate` <= 100))),
  CONSTRAINT `living_room_chk_5` CHECK ((`current_num_of_students` <= `max_num_of_students`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


LOCK TABLES `living_room` WRITE;

INSERT INTO `living_room` (building_id, room_id, max_num_of_students, current_num_of_students, rental_price, occupancy_rate, room_status) VALUES 
('BK001','P.101',6,2,1500000.00,33.33,'Available'),('BK001','P.104',6,3,1500000.00,50.00,'Available'),('BK001','P.201',6,3,1500000.00,50.00,'Available'),('BK001','P.202',6,0,1500000.00,0.00,'Available'),('BK001','P.203',6,0,1500000.00,0.00,'Available'),('BK001','P.204',6,4,1500000.00,66.67,'Available'),('BK001','P.301',6,0,1500000.00,0.00,'Available'),('BK001','P.302',6,0,1500000.00,0.00,'Available'),('BK001','P.303',6,0,1500000.00,0.00,'Available'),('BK001','P.304',6,4,1500000.00,66.67,'Available'),('BK001','P.401',6,0,1500000.00,0.00,'Available'),('BK001','P.402',6,0,1500000.00,0.00,'Available'),('BK001','P.403',6,0,1500000.00,0.00,'Available'),('BK001','P.404',6,0,1500000.00,0.00,'Available'),
('BK002','P.101',6,2,1500000.00,33.33,'Available'),('BK002','P.102',6,2,1500000.00,33.33,'Available'),('BK002','P.104',6,1,1500000.00,16.67,'Available'),('BK002','P.201',6,0,1500000.00,0.00,'Available'),('BK002','P.202',6,0,1500000.00,0.00,'Available'),('BK002','P.203',6,1,1500000.00,16.67,'Available'),('BK002','P.204',6,4,1500000.00,66.67,'Available'),('BK002','P.301',6,0,1500000.00,0.00,'Available'),('BK002','P.302',6,0,1500000.00,0.00,'Available'),('BK002','P.303',6,0,1500000.00,0.00,'Available'),('BK002','P.304',6,0,1500000.00,0.00,'Available'),('BK002','P.401',6,0,1500000.00,0.00,'Available'),('BK002','P.402',6,0,1500000.00,0.00,'Available'),('BK002','P.403',6,0,1500000.00,0.00,'Available'),('BK002','P.404',6,0,1500000.00,0.00,'Available'),
('BK003','P.102',6,0,1500000.00,0.00,'Available'),('BK003','P.104',6,6,1500000.00,100.00,'Occupied'),('BK003','P.201',6,0,1500000.00,0.00,'Available'),('BK003','P.202',6,0,1500000.00,0.00,'Available'),('BK003','P.203',6,0,1500000.00,0.00,'Available'),('BK003','P.204',6,5,1500000.00,83.33,'Available'),('BK003','P.301',6,0,1500000.00,0.00,'Available'),('BK003','P.302',6,0,1500000.00,0.00,'Available'),('BK003','P.303',6,0,1500000.00,0.00,'Available'),('BK003','P.304',6,4,1500000.00,66.67,'Available'),('BK003','P.401',6,0,1500000.00,0.00,'Available'),('BK003','P.402',6,0,1500000.00,0.00,'Available'),('BK003','P.403',6,0,1500000.00,0.00,'Available'),('BK003','P.404',6,0,1500000.00,0.00,'Available'),
('BK004','P.102',6,0,1500000.00,0.00,'Available'),('BK004','P.104',6,2,1500000.00,33.33,'Available'),('BK004','P.201',6,0,1500000.00,0.00,'Available'),('BK004','P.202',6,0,1500000.00,0.00,'Available'),('BK004','P.203',6,0,1500000.00,0.00,'Available'),('BK004','P.204',6,4,1500000.00,66.67,'Available'),('BK004','P.301',6,0,1500000.00,0.00,'Available'),('BK004','P.302',6,0,1500000.00,0.00,'Available'),('BK004','P.303',6,0,1500000.00,0.00,'Available'),('BK004','P.304',6,0,1500000.00,0.00,'Available'),('BK004','P.401',6,0,1500000.00,0.00,'Available'),('BK004','P.402',6,0,1500000.00,0.00,'Available'),('BK004','P.403',6,0,1500000.00,0.00,'Available'),('BK004','P.404',6,0,1500000.00,0.00,'Available');

UNLOCK TABLES;



CREATE TABLE `manager_dorm` (
  `user_name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`user_name`,`password`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


LOCK TABLES `manager_dorm` WRITE;
INSERT INTO `manager_dorm` VALUES ('sManager','$2b$10$isVtVnGDb56L/sfdPVDDbekUcgoMxq500NDJbHOyvgMBL51Vo1vyu');
UNLOCK TABLES;


CREATE TABLE `other_room` (
  `building_id` char(5) NOT NULL,
  `room_id` char(5) NOT NULL,
  `room_type` varchar(100) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `num_of_staff` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`building_id`,`room_id`),
  CONSTRAINT `fk_other_room` FOREIGN KEY (`building_id`, `room_id`) REFERENCES `room` (`building_id`, `room_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `other_room_chk_1` CHECK ((`num_of_staff` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `other_room` WRITE;
INSERT INTO `other_room` VALUES ('BK001','P.103','Meeting Room','09:00:00','17:00:00',0),('BK002','P.103','Meeting Room','09:00:00','17:00:00',0),('BK003','P.103','Meeting Room','09:00:00','17:00:00',0),('BK004','P.103','Meeting Room','09:00:00','17:00:00',0);
UNLOCK TABLES;

CREATE TABLE `room` (
  `building_id` char(5) NOT NULL,
  `room_id` char(5) NOT NULL,
  `room_status` enum('Available','Occupied','Under Maintenance') NOT NULL,
  `room_area` decimal(10,2) NOT NULL,
  PRIMARY KEY (`building_id`,`room_id`),
  CONSTRAINT `fk_room_building` FOREIGN KEY (`building_id`) REFERENCES `building` (`building_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `room_chk_1` CHECK ((`room_area` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `room` WRITE;

INSERT INTO `room` VALUES ('BK001','P.101','Available',25.00),('BK001','P.102','Available',25.00),('BK001','P.103','Available',25.00),('BK001','P.104','Available',25.00),('BK001','P.201','Occupied',25.00),('BK001','P.202','Occupied',25.00),('BK001','P.203','Occupied',25.00),('BK001','P.204','Available',25.00),('BK001','P.301','Under Maintenance',25.00),('BK001','P.302','Available',25.00),('BK001','P.303','Available',25.00),('BK001','P.304','Available',25.00),('BK001','P.401','Available',25.00),('BK001','P.402','Occupied',25.00),('BK001','P.403','Occupied',25.00),('BK001','P.404','Available',25.00),('BK002','P.101','Available',25.00),('BK002','P.102','Available',25.00),('BK002','P.103','Available',25.00),('BK002','P.104','Available',25.00),('BK002','P.201','Occupied',25.00),('BK002','P.202','Occupied',25.00),('BK002','P.203','Available',25.00),('BK002','P.204','Available',25.00),('BK002','P.301','Under Maintenance',25.00),('BK002','P.302','Available',25.00),('BK002','P.303','Available',25.00),('BK002','P.304','Available',25.00),('BK002','P.401','Available',25.00),('BK002','P.402','Occupied',25.00),('BK002','P.403','Occupied',25.00),('BK002','P.404','Available',25.00),('BK003','P.101','Available',25.00),('BK003','P.102','Available',25.00),('BK003','P.103','Available',25.00),('BK003','P.104','Available',25.00),('BK003','P.201','Occupied',25.00),('BK003','P.202','Occupied',25.00),('BK003','P.203','Occupied',25.00),('BK003','P.204','Available',25.00),('BK003','P.301','Under Maintenance',25.00),('BK003','P.302','Available',25.00),('BK003','P.303','Available',25.00),('BK003','P.304','Available',25.00),('BK003','P.401','Available',25.00),('BK003','P.402','Occupied',25.00),('BK003','P.403','Occupied',25.00),('BK003','P.404','Available',25.00),('BK004','P.101','Available',25.00),('BK004','P.102','Available',25.00),('BK004','P.103','Available',25.00),('BK004','P.104','Available',25.00),('BK004','P.201','Occupied',25.00),('BK004','P.202','Occupied',25.00),('BK004','P.203','Occupied',25.00),('BK004','P.204','Available',25.00),('BK004','P.301','Under Maintenance',25.00),('BK004','P.302','Available',25.00),('BK004','P.303','Available',25.00),('BK004','P.304','Available',25.00),('BK004','P.401','Available',25.00),('BK004','P.402','Occupied',25.00),('BK004','P.403','Occupied',25.00),('BK004','P.404','Available',25.00);
UNLOCK TABLES;


CREATE TABLE `student` (
  `sssn` char(8) NOT NULL,
  `cccd` char(12) DEFAULT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(20) NOT NULL,
  `birthday` date NOT NULL,
  `sex` char(1) DEFAULT NULL,
  `ethnic_group` varchar(30) DEFAULT NULL,
  `study_status` varchar(20) DEFAULT NULL,
  `health_state` varchar(100) DEFAULT NULL,
  `student_id` char(12) DEFAULT NULL,
  `class_name` varchar(30) DEFAULT NULL,
  `faculty` varchar(50) DEFAULT NULL,
  `building_id` char(5) DEFAULT NULL,
  `room_id` char(5) DEFAULT NULL,
  `has_health_insurance` TINYINT DEFAULT '0',
  `phone_numbers` text,
  `emails` text,
  `addresses` text,
  `guardian_cccd` char(12) DEFAULT NULL,
  `guardian_name` varchar(50) DEFAULT NULL,
  `guardian_relationship` varchar(20) DEFAULT NULL,
  `guardian_occupation` varchar(50) DEFAULT NULL,
  `guardian_birthday` date DEFAULT NULL,
  `guardian_phone_numbers` text,
  `guardian_addresses` text,
  PRIMARY KEY (`sssn`),
  UNIQUE KEY `student_id` (`student_id`),
  UNIQUE KEY `cccd` (`cccd`),
  KEY `fk_student_room` (`building_id`,`room_id`),
  CONSTRAINT `fk_student_building` FOREIGN KEY (`building_id`) REFERENCES `building` (`building_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_student_room` FOREIGN KEY (`building_id`, `room_id`) REFERENCES `living_room` (`building_id`, `room_id`),
  CONSTRAINT `student_chk_1` CHECK ((`sex` in (_utf8mb4'M',_utf8mb4'F')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `student` WRITE;

-- =====================================
-- DEMO DATA FOR STATISTICS (2025)
-- =====================================
-- Additional students, disciplinary actions, and student_discipline records
-- Date range: 2025-01-01 to 2025-11-30
-- =====================================

-- Insert additional students (100 new students)
INSERT INTO `student` (sssn, cccd, first_name, last_name, birthday, sex, ethnic_group, study_status, health_state, student_id, class_name, faculty, building_id, room_id, has_health_insurance, phone_numbers, emails, addresses, guardian_cccd, guardian_name, guardian_relationship, guardian_occupation, guardian_birthday, guardian_phone_numbers, guardian_addresses) VALUES
('05630001','012345670101','An','Tran Van','2004-01-15','M','Kinh','Active','Good','2413001','KHMT4','Computer Science','BK001','P.202',1,'0389123456','an.tranvan04@hcmut.edu.vn','Quan 1, Ho Chi Minh','075362520101','Tran Van Nam','Father','Engineer','1975-01-10','0389123457','Quan 1, Ho Chi Minh'),
('05630002','012345670102','Binh','Le Thi','2005-02-20','F','Kinh','Active','Good','2513002','CNTT4','Information Technology','BK001','P.202',1,'0389123458','binh.lethi05@hcmut.edu.vn','Quan 2, Ho Chi Minh','075362520102','Le Van Hoa','Father','Teacher','1976-02-15','0389123459','Quan 2, Ho Chi Minh'),
('05630003','012345670103','Cuong','Pham Duc','2003-03-25','M','Kinh','Active','Good','2313003','DTVT4','Electronics and Telecommunications Engineering','BK001','P.203',1,'0389123460','cuong.phamduc03@hcmut.edu.vn','Quan 3, Ho Chi Minh','075362520103','Pham Van Tuan','Father','Doctor','1974-03-20','0389123461','Quan 3, Ho Chi Minh'),
('05630004','012345670104','Dung','Nguyen Minh','2004-04-10','M','Kinh','Active','Good','2413004','CK4','Mechanical Engineering','BK001','P.203',1,'0389123462','dung.nguyenminh04@hcmut.edu.vn','Quan 4, Ho Chi Minh','075362520104','Nguyen Van Long','Father','Businessman','1975-04-05','0389123463','Quan 4, Ho Chi Minh'),
('05630005','012345670105','Em','Tran Thi','2005-05-15','F','Kinh','Active','Good','2513005','D4','Electrical Engineering','BK001','P.301',1,'0389123464','em.tranthi05@hcmut.edu.vn','Quan 5, Ho Chi Minh','075362520105','Tran Van Hung','Father','Accountant','1976-05-10','0389123465','Quan 5, Ho Chi Minh'),
('05630006','012345670106','Giang','Le Van','2003-06-20','M','Kinh','Active','Good','2313006','HTTT4','Information Security','BK001','P.301',1,'0389123466','giang.levan03@hcmut.edu.vn','Quan 6, Ho Chi Minh','075362520106','Le Van Phuc','Father','Teacher','1974-06-15','0389123467','Quan 6, Ho Chi Minh'),
('05630007','012345670107','Hoa','Pham Thi','2004-07-25','F','Kinh','Active','Good','2413007','XD4','Civil Engineering','BK001','P.302',1,'0389123468','hoa.phamthi04@hcmut.edu.vn','Quan 7, Ho Chi Minh','075362520107','Pham Van Dung','Father','Engineer','1975-07-20','0389123469','Quan 7, Ho Chi Minh'),
('05630008','012345670108','Hung','Nguyen Van','2005-08-30','M','Kinh','Active','Good','2513008','H4','Chemical Engineering','BK001','P.302',1,'0389123470','hung.nguyenvan05@hcmut.edu.vn','Quan 8, Ho Chi Minh','075362520108','Nguyen Van Khoa','Father','Doctor','1976-08-25','0389123471','Quan 8, Ho Chi Minh'),
('05630009','012345670109','Lan','Tran Thi','2003-09-05','F','Kinh','Active','Good','2313009','MT4','Environmental Engineering','BK001','P.303',1,'0389123472','lan.tranthi03@hcmut.edu.vn','Quan 9, Ho Chi Minh','075362520109','Tran Van Son','Father','Businessman','1974-09-01','0389123473','Quan 9, Ho Chi Minh'),
('05630010','012345670110','Minh','Le Duc','2004-10-10','M','Kinh','Active','Good','2413010','DK4','Control and Automation Engineering','BK001','P.303',1,'0389123474','minh.leduc04@hcmut.edu.vn','Quan 10, Ho Chi Minh','075362520110','Le Van An','Father','Teacher','1975-10-05','0389123475','Quan 10, Ho Chi Minh'),
('05630011','012345670111','Nga','Pham Thi','2005-11-15','F','Kinh','Active','Good','2513011','QL4','Industrial Management','BK001','P.401',1,'0389123476','nga.phamthi05@hcmut.edu.vn','Quan 11, Ho Chi Minh','075362520111','Pham Van Binh','Father','Accountant','1976-11-10','0389123477','Quan 11, Ho Chi Minh'),
('05630012','012345670112','Oanh','Nguyen Thi','2003-12-20','F','Kinh','Active','Good','2313012','SCM4','Logistics and Supply Chain Management','BK001','P.401',1,'0389123478','oanh.nguyenthi03@hcmut.edu.vn','Quan 12, Ho Chi Minh','075362520112','Nguyen Van Cuong','Father','Engineer','1974-12-15','0389123479','Quan 12, Ho Chi Minh'),
('05630013','012345670113','Phong','Tran Van','2004-01-25','M','Kinh','Active','Good','2413013','VL4','Materials Engineering','BK001','P.402',1,'0389123480','phong.tranvan04@hcmut.edu.vn','Binh Thanh, Ho Chi Minh','075362520113','Tran Van Dat','Father','Doctor','1975-01-20','0389123481','Binh Thanh, Ho Chi Minh'),
('05630014','012345670114','Quang','Le Van','2005-02-28','M','Kinh','Active','Good','2513014','SH4','Biotechnology','BK001','P.402',1,'0389123482','quang.levan05@hcmut.edu.vn','Tan Binh, Ho Chi Minh','075362520114','Le Van Em','Father','Businessman','1976-02-23','0389123483','Tan Binh, Ho Chi Minh'),
('05630015','012345670115','Rang','Pham Van','2003-03-05','M','Kinh','Active','Good','2313015','KT4','Computer Engineering','BK001','P.403',1,'0389123484','rang.phamvan03@hcmut.edu.vn','Tan Phu, Ho Chi Minh','075362520115','Pham Van Giang','Father','Teacher','1974-03-01','0389123485','Tan Phu, Ho Chi Minh'),
('05630016','012345670116','Son','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413016','KHMT5','Computer Science','BK001','P.403',1,'0389123486','son.nguyenvan04@hcmut.edu.vn','Phu Nhuan, Ho Chi Minh','075362520116','Nguyen Van Hoa','Father','Accountant','1975-04-05','0389123487','Phu Nhuan, Ho Chi Minh'),
('05630017','012345670117','Tam','Tran Thi','2005-05-15','F','Kinh','Active','Good','2513017','CNTT5','Information Technology','BK001','P.404',1,'0389123488','tam.tranthi05@hcmut.edu.vn','Go Vap, Ho Chi Minh','075362520117','Tran Van Hung','Father','Engineer','1976-05-10','0389123489','Go Vap, Ho Chi Minh'),
('05630018','012345670118','Uyen','Le Thi','2003-06-20','F','Kinh','Active','Good','2313018','DTVT5','Electronics and Telecommunications Engineering','BK002','P.201',1,'0389123490','uyen.lethi03@hcmut.edu.vn','Binh Tan, Ho Chi Minh','075362520118','Le Van Khoa','Father','Doctor','1974-06-15','0389123491','Binh Tan, Ho Chi Minh'),
('05630019','012345670119','Viet','Pham Van','2004-07-25','M','Kinh','Active','Good','2413019','CK5','Mechanical Engineering','BK002','P.201',1,'0389123492','viet.phamvan04@hcmut.edu.vn','Thu Duc, Ho Chi Minh','075362520119','Pham Van Lan','Father','Businessman','1975-07-20','0389123493','Thu Duc, Ho Chi Minh'),
('05630020','012345670120','Xuan','Nguyen Thi','2005-08-30','F','Kinh','Active','Good','2513020','D5','Electrical Engineering','BK002','P.202',1,'0389123494','xuan.nguyenthi05@hcmut.edu.vn','Nha Be, Ho Chi Minh','075362520120','Nguyen Van Minh','Father','Teacher','1976-08-25','0389123495','Nha Be, Ho Chi Minh'),
('05630021','012345670121','Yen','Tran Thi','2003-09-05','F','Kinh','Active','Good','2313021','HTTT5','Information Security','BK002','P.202',1,'0389123496','yen.tranthi03@hcmut.edu.vn','Can Gio, Ho Chi Minh','075362520121','Tran Van Nga','Father','Accountant','1974-09-01','0389123497','Can Gio, Ho Chi Minh'),
('05630022','012345670122','Anh','Le Van','2004-10-10','M','Kinh','Active','Good','2413022','XD5','Civil Engineering','BK002','P.203',1,'0389123498','anh.levan04@hcmut.edu.vn','Cu Chi, Ho Chi Minh','075362520122','Le Van Oanh','Father','Engineer','1975-10-05','0389123499','Cu Chi, Ho Chi Minh'),
('05630023','012345670123','Bao','Pham Van','2005-11-15','M','Kinh','Active','Good','2513023','H5','Chemical Engineering','BK002','P.203',1,'0389123500','bao.phamvan05@hcmut.edu.vn','Hoc Mon, Ho Chi Minh','075362520123','Pham Van Phong','Father','Doctor','1976-11-10','0389123501','Hoc Mon, Ho Chi Minh'),
('05630024','012345670124','Chi','Nguyen Thi','2003-12-20','F','Kinh','Active','Good','2313024','MT5','Environmental Engineering','BK002','P.301',1,'0389123502','chi.nguyenthi03@hcmut.edu.vn','Quan 1, Ho Chi Minh','075362520124','Nguyen Van Quang','Father','Businessman','1974-12-15','0389123503','Quan 1, Ho Chi Minh'),
('05630025','012345670125','Dung','Tran Van','2004-01-25','M','Kinh','Active','Good','2413025','DK5','Control and Automation Engineering','BK002','P.301',1,'0389123504','dung.tranvan04@hcmut.edu.vn','Quan 2, Ho Chi Minh','075362520125','Tran Van Rang','Father','Teacher','1975-01-20','0389123505','Quan 2, Ho Chi Minh'),
('05630026','012345670126','Em','Le Thi','2005-02-28','F','Kinh','Active','Good','2513026','QL5','Industrial Management','BK002','P.302',1,'0389123506','em.lethi05@hcmut.edu.vn','Quan 3, Ho Chi Minh','075362520126','Le Van Son','Father','Accountant','1976-02-23','0389123507','Quan 3, Ho Chi Minh'),
('05630027','012345670127','Giang','Pham Van','2003-03-05','M','Kinh','Active','Good','2313027','SCM5','Logistics and Supply Chain Management','BK002','P.302',1,'0389123508','giang.phamvan03@hcmut.edu.vn','Quan 4, Ho Chi Minh','075362520127','Pham Van Tam','Father','Engineer','1974-03-01','0389123509','Quan 4, Ho Chi Minh'),
('05630028','012345670128','Hoa','Nguyen Thi','2004-04-10','F','Kinh','Active','Good','2413028','VL5','Materials Engineering','BK002','P.303',1,'0389123510','hoa.nguyenthi04@hcmut.edu.vn','Quan 5, Ho Chi Minh','075362520128','Nguyen Van Uyen','Father','Doctor','1975-04-05','0389123511','Quan 5, Ho Chi Minh'),
('05630029','012345670129','Hung','Tran Van','2005-05-15','M','Kinh','Active','Good','2513029','SH5','Biotechnology','BK002','P.303',1,'0389123512','hung.tranvan05@hcmut.edu.vn','Quan 6, Ho Chi Minh','075362520129','Tran Van Viet','Father','Businessman','1976-05-10','0389123513','Quan 6, Ho Chi Minh'),
('05630030','012345670130','Lan','Le Thi','2003-06-20','F','Kinh','Active','Good','2313030','KT5','Computer Engineering','BK002','P.304',1,'0389123514','lan.lethi03@hcmut.edu.vn','Quan 7, Ho Chi Minh','075362520130','Le Van Xuan','Father','Teacher','1974-06-15','0389123515','Quan 7, Ho Chi Minh'),
('05630031','012345670131','Minh','Pham Van','2004-07-25','M','Kinh','Active','Good','2413031','KHMT6','Computer Science','BK002','P.401',1,'0389123516','minh.phamvan04@hcmut.edu.vn','Quan 8, Ho Chi Minh','075362520131','Pham Van Yen','Father','Accountant','1975-07-20','0389123517','Quan 8, Ho Chi Minh'),
('05630032','012345670132','Nga','Nguyen Thi','2005-08-30','F','Kinh','Active','Good','2513032','CNTT6','Information Technology','BK002','P.401',1,'0389123518','nga.nguyenthi05@hcmut.edu.vn','Quan 9, Ho Chi Minh','075362520132','Nguyen Van Anh','Father','Engineer','1976-08-25','0389123519','Quan 9, Ho Chi Minh'),
('05630033','012345670133','Oanh','Tran Thi','2003-09-05','F','Kinh','Active','Good','2313033','DTVT6','Electronics and Telecommunications Engineering','BK002','P.402',1,'0389123520','oanh.tranthi03@hcmut.edu.vn','Quan 10, Ho Chi Minh','075362520133','Tran Van Bao','Father','Doctor','1974-09-01','0389123521','Quan 10, Ho Chi Minh'),
('05630034','012345670134','Phong','Le Van','2004-10-10','M','Kinh','Active','Good','2413034','CK6','Mechanical Engineering','BK002','P.402',1,'0389123522','phong.levan04@hcmut.edu.vn','Quan 11, Ho Chi Minh','075362520134','Le Van Chi','Father','Businessman','1975-10-05','0389123523','Quan 11, Ho Chi Minh'),
('05630035','012345670135','Quang','Pham Van','2005-11-15','M','Kinh','Active','Good','2513035','D6','Electrical Engineering','BK002','P.403',1,'0389123524','quang.phamvan05@hcmut.edu.vn','Quan 12, Ho Chi Minh','075362520135','Pham Van Dung','Father','Teacher','1976-11-10','0389123525','Quan 12, Ho Chi Minh'),
('05630036','012345670136','Rang','Nguyen Van','2003-12-20','M','Kinh','Active','Good','2313036','HTTT6','Information Security','BK002','P.403',1,'0389123526','rang.nguyenvan03@hcmut.edu.vn','Binh Thanh, Ho Chi Minh','075362520136','Nguyen Van Em','Father','Accountant','1974-12-15','0389123527','Binh Thanh, Ho Chi Minh'),
('05630037','012345670137','Son','Tran Van','2004-01-25','M','Kinh','Active','Good','2413037','XD6','Civil Engineering','BK002','P.404',1,'0389123528','son.tranvan04@hcmut.edu.vn','Tan Binh, Ho Chi Minh','075362520137','Tran Van Giang','Father','Engineer','1975-01-20','0389123529','Tan Binh, Ho Chi Minh'),
('05630038','012345670138','Tam','Le Thi','2005-02-28','F','Kinh','Active','Good','2513038','H6','Chemical Engineering','BK002','P.404',1,'0389123530','tam.lethi05@hcmut.edu.vn','Tan Phu, Ho Chi Minh','075362520138','Le Van Hoa','Father','Doctor','1976-02-23','0389123531','Tan Phu, Ho Chi Minh'),
('05630039','012345670139','Uyen','Pham Thi','2003-03-05','F','Kinh','Active','Good','2313039','MT6','Environmental Engineering','BK003','P.102',1,'0389123532','uyen.phamthi03@hcmut.edu.vn','Phu Nhuan, Ho Chi Minh','075362520139','Pham Van Hung','Father','Businessman','1974-03-01','0389123533','Phu Nhuan, Ho Chi Minh'),
('05630040','012345670140','Viet','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413040','DK6','Control and Automation Engineering','BK003','P.102',1,'0389123534','viet.nguyenvan04@hcmut.edu.vn','Go Vap, Ho Chi Minh','075362520140','Nguyen Van Lan','Father','Teacher','1975-04-05','0389123535','Go Vap, Ho Chi Minh'),
('05630041','012345670141','Xuan','Tran Thi','2005-05-15','F','Kinh','Active','Good','2513041','QL6','Industrial Management','BK003','P.201',1,'0389123536','xuan.tranthi05@hcmut.edu.vn','Binh Tan, Ho Chi Minh','075362520141','Tran Van Minh','Father','Accountant','1976-05-10','0389123537','Binh Tan, Ho Chi Minh'),
('05630042','012345670142','Yen','Le Thi','2003-06-20','F','Kinh','Active','Good','2313042','SCM6','Logistics and Supply Chain Management','BK003','P.201',1,'0389123538','yen.lethi03@hcmut.edu.vn','Thu Duc, Ho Chi Minh','075362520142','Le Van Nga','Father','Engineer','1974-06-15','0389123539','Thu Duc, Ho Chi Minh'),
('05630043','012345670143','Anh','Pham Van','2004-07-25','M','Kinh','Active','Good','2413043','VL6','Materials Engineering','BK003','P.202',1,'0389123540','anh.phamvan04@hcmut.edu.vn','Nha Be, Ho Chi Minh','075362520143','Pham Van Oanh','Father','Doctor','1975-07-20','0389123541','Nha Be, Ho Chi Minh'),
('05630044','012345670144','Bao','Nguyen Van','2005-08-30','M','Kinh','Active','Good','2513044','SH6','Biotechnology','BK003','P.202',1,'0389123542','bao.nguyenvan05@hcmut.edu.vn','Can Gio, Ho Chi Minh','075362520144','Nguyen Van Phong','Father','Businessman','1976-08-25','0389123543','Can Gio, Ho Chi Minh'),
('05630045','012345670145','Chi','Tran Thi','2003-09-05','F','Kinh','Active','Good','2313045','KT6','Computer Engineering','BK003','P.203',1,'0389123544','chi.tranthi03@hcmut.edu.vn','Cu Chi, Ho Chi Minh','075362520145','Tran Van Quang','Father','Teacher','1974-09-01','0389123545','Cu Chi, Ho Chi Minh'),
('05630046','012345670146','Dung','Le Van','2004-10-10','M','Kinh','Active','Good','2413046','KHMT7','Computer Science','BK003','P.203',1,'0389123546','dung.levan04@hcmut.edu.vn','Hoc Mon, Ho Chi Minh','075362520146','Le Van Rang','Father','Accountant','1975-10-05','0389123547','Hoc Mon, Ho Chi Minh'),
('05630047','012345670147','Em','Pham Thi','2005-11-15','F','Kinh','Active','Good','2513047','CNTT7','Information Technology','BK003','P.301',1,'0389123548','em.phamthi05@hcmut.edu.vn','Quan 1, Ho Chi Minh','075362520147','Pham Van Son','Father','Engineer','1976-11-10','0389123549','Quan 1, Ho Chi Minh'),
('05630048','012345670148','Giang','Nguyen Van','2003-12-20','M','Kinh','Active','Good','2313048','DTVT7','Electronics and Telecommunications Engineering','BK003','P.301',1,'0389123550','giang.nguyenvan03@hcmut.edu.vn','Quan 2, Ho Chi Minh','075362520148','Nguyen Van Tam','Father','Doctor','1974-12-15','0389123551','Quan 2, Ho Chi Minh'),
('05630049','012345670149','Hoa','Tran Thi','2004-01-25','F','Kinh','Active','Good','2413049','CK7','Mechanical Engineering','BK003','P.302',1,'0389123552','hoa.tranthi04@hcmut.edu.vn','Quan 3, Ho Chi Minh','075362520149','Tran Van Uyen','Father','Businessman','1975-01-20','0389123553','Quan 3, Ho Chi Minh'),
('05630050','012345670150','Hung','Le Van','2005-02-28','M','Kinh','Active','Good','2513050','D7','Electrical Engineering','BK003','P.302',1,'0389123554','hung.levan05@hcmut.edu.vn','Quan 4, Ho Chi Minh','075362520150','Le Van Viet','Father','Teacher','1976-02-23','0389123555','Quan 4, Ho Chi Minh'),
('05630051','012345670151','Lan','Pham Thi','2003-03-05','F','Kinh','Active','Good','2313051','HTTT7','Information Security','BK003','P.303',1,'0389123556','lan.phamthi03@hcmut.edu.vn','Quan 5, Ho Chi Minh','075362520151','Pham Van Xuan','Father','Accountant','1974-03-01','0389123557','Quan 5, Ho Chi Minh'),
('05630052','012345670152','Minh','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413052','XD7','Civil Engineering','BK003','P.303',1,'0389123558','minh.nguyenvan04@hcmut.edu.vn','Quan 6, Ho Chi Minh','075362520152','Nguyen Van Yen','Father','Engineer','1975-04-05','0389123559','Quan 6, Ho Chi Minh'),
('05630053','012345670153','Nga','Tran Thi','2005-05-15','F','Kinh','Active','Good','2513053','H7','Chemical Engineering','BK003','P.401',1,'0389123560','nga.tranthi05@hcmut.edu.vn','Quan 7, Ho Chi Minh','075362520153','Tran Van Anh','Father','Doctor','1976-05-10','0389123561','Quan 7, Ho Chi Minh'),
('05630054','012345670154','Oanh','Le Thi','2003-06-20','F','Kinh','Active','Good','2313054','MT7','Environmental Engineering','BK003','P.401',1,'0389123562','oanh.lethi03@hcmut.edu.vn','Quan 8, Ho Chi Minh','075362520154','Le Van Bao','Father','Businessman','1974-06-15','0389123563','Quan 8, Ho Chi Minh'),
('05630055','012345670155','Phong','Pham Van','2004-07-25','M','Kinh','Active','Good','2413055','DK7','Control and Automation Engineering','BK003','P.402',1,'0389123564','phong.phamvan04@hcmut.edu.vn','Quan 9, Ho Chi Minh','075362520155','Pham Van Chi','Father','Teacher','1975-07-20','0389123565','Quan 9, Ho Chi Minh'),
('05630056','012345670156','Quang','Nguyen Van','2005-08-30','M','Kinh','Active','Good','2513056','QL7','Industrial Management','BK003','P.402',1,'0389123566','quang.nguyenvan05@hcmut.edu.vn','Quan 10, Ho Chi Minh','075362520156','Nguyen Van Dung','Father','Accountant','1976-08-25','0389123567','Quan 10, Ho Chi Minh'),
('05630057','012345670157','Rang','Tran Van','2003-09-05','M','Kinh','Active','Good','2313057','SCM7','Logistics and Supply Chain Management','BK003','P.403',1,'0389123568','rang.tranvan03@hcmut.edu.vn','Quan 11, Ho Chi Minh','075362520157','Tran Van Em','Father','Engineer','1974-09-01','0389123569','Quan 11, Ho Chi Minh'),
('05630058','012345670158','Son','Le Van','2004-10-10','M','Kinh','Active','Good','2413058','VL7','Materials Engineering','BK003','P.403',1,'0389123570','son.levan04@hcmut.edu.vn','Quan 12, Ho Chi Minh','075362520158','Le Van Giang','Father','Doctor','1975-10-05','0389123571','Quan 12, Ho Chi Minh'),
('05630059','012345670159','Tam','Pham Thi','2005-11-15','F','Kinh','Active','Good','2513059','SH7','Biotechnology','BK003','P.404',1,'0389123572','tam.phamthi05@hcmut.edu.vn','Binh Thanh, Ho Chi Minh','075362520159','Pham Van Hoa','Father','Businessman','1976-11-10','0389123573','Binh Thanh, Ho Chi Minh'),
('05630060','012345670160','Uyen','Nguyen Thi','2003-12-20','F','Kinh','Active','Good','2313060','KT7','Computer Engineering','BK003','P.404',1,'0389123574','uyen.nguyenthi03@hcmut.edu.vn','Tan Binh, Ho Chi Minh','075362520160','Nguyen Van Hung','Father','Teacher','1974-12-15','0389123575','Tan Binh, Ho Chi Minh'),
('05630061','012345670161','Viet','Tran Van','2004-01-25','M','Kinh','Active','Good','2413061','KHMT8','Computer Science','BK004','P.201',1,'0389123576','viet.tranvan04@hcmut.edu.vn','Tan Phu, Ho Chi Minh','075362520161','Tran Van Lan','Father','Accountant','1975-01-20','0389123577','Tan Phu, Ho Chi Minh'),
('05630062','012345670162','Xuan','Le Thi','2005-02-28','F','Kinh','Active','Good','2513062','CNTT8','Information Technology','BK004','P.201',1,'0389123578','xuan.lethi05@hcmut.edu.vn','Phu Nhuan, Ho Chi Minh','075362520162','Le Van Minh','Father','Engineer','1976-02-23','0389123579','Phu Nhuan, Ho Chi Minh'),
('05630063','012345670163','Yen','Pham Thi','2003-03-05','F','Kinh','Active','Good','2313063','DTVT8','Electronics and Telecommunications Engineering','BK004','P.202',1,'0389123580','yen.phamthi03@hcmut.edu.vn','Go Vap, Ho Chi Minh','075362520163','Pham Van Nga','Father','Doctor','1974-03-01','0389123581','Go Vap, Ho Chi Minh'),
('05630064','012345670164','Anh','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413064','CK8','Mechanical Engineering','BK004','P.202',1,'0389123582','anh.nguyenvan04@hcmut.edu.vn','Binh Tan, Ho Chi Minh','075362520164','Nguyen Van Oanh','Father','Businessman','1975-04-05','0389123583','Binh Tan, Ho Chi Minh'),
('05630065','012345670165','Bao','Tran Van','2005-05-15','M','Kinh','Active','Good','2513065','D8','Electrical Engineering','BK004','P.203',1,'0389123584','bao.tranvan05@hcmut.edu.vn','Thu Duc, Ho Chi Minh','075362520165','Tran Van Phong','Father','Teacher','1976-05-10','0389123585','Thu Duc, Ho Chi Minh'),
('05630066','012345670166','Chi','Le Thi','2003-06-20','F','Kinh','Active','Good','2313066','HTTT8','Information Security','BK004','P.203',1,'0389123586','chi.lethi03@hcmut.edu.vn','Nha Be, Ho Chi Minh','075362520166','Le Van Quang','Father','Accountant','1974-06-15','0389123587','Nha Be, Ho Chi Minh'),
('05630067','012345670167','Dung','Pham Van','2004-07-25','M','Kinh','Active','Good','2413067','XD8','Civil Engineering','BK004','P.301',1,'0389123588','dung.phamvan04@hcmut.edu.vn','Can Gio, Ho Chi Minh','075362520167','Pham Van Rang','Father','Engineer','1975-07-20','0389123589','Can Gio, Ho Chi Minh'),
('05630068','012345670168','Em','Nguyen Thi','2005-08-30','F','Kinh','Active','Good','2513068','H8','Chemical Engineering','BK004','P.301',1,'0389123590','em.nguyenthi05@hcmut.edu.vn','Cu Chi, Ho Chi Minh','075362520168','Nguyen Van Son','Father','Doctor','1976-08-25','0389123591','Cu Chi, Ho Chi Minh'),
('05630069','012345670169','Giang','Tran Van','2003-09-05','M','Kinh','Active','Good','2313069','MT8','Environmental Engineering','BK004','P.302',1,'0389123592','giang.tranvan03@hcmut.edu.vn','Hoc Mon, Ho Chi Minh','075362520169','Tran Van Tam','Father','Businessman','1974-09-01','0389123593','Hoc Mon, Ho Chi Minh'),
('05630070','012345670170','Hoa','Le Van','2004-10-10','M','Kinh','Active','Good','2413070','DK8','Control and Automation Engineering','BK004','P.302',1,'0389123594','hoa.levan04@hcmut.edu.vn','Quan 1, Ho Chi Minh','075362520170','Le Van Uyen','Father','Teacher','1975-10-05','0389123595','Quan 1, Ho Chi Minh'),
('05630071','012345670171','Hung','Pham Van','2005-11-15','M','Kinh','Active','Good','2513071','QL8','Industrial Management','BK004','P.303',1,'0389123596','hung.phamvan05@hcmut.edu.vn','Quan 2, Ho Chi Minh','075362520171','Pham Van Viet','Father','Accountant','1976-11-10','0389123597','Quan 2, Ho Chi Minh'),
('05630072','012345670172','Lan','Nguyen Thi','2003-12-20','F','Kinh','Active','Good','2313072','SCM8','Logistics and Supply Chain Management','BK004','P.303',1,'0389123598','lan.nguyenthi03@hcmut.edu.vn','Quan 3, Ho Chi Minh','075362520172','Nguyen Van Xuan','Father','Engineer','1974-12-15','0389123599','Quan 3, Ho Chi Minh'),
('05630073','012345670173','Minh','Tran Van','2004-01-25','M','Kinh','Active','Good','2413073','VL8','Materials Engineering','BK004','P.401',1,'0389123600','minh.tranvan04@hcmut.edu.vn','Quan 4, Ho Chi Minh','075362520173','Tran Van Yen','Father','Doctor','1975-01-20','0389123601','Quan 4, Ho Chi Minh'),
('05630074','012345670174','Nga','Le Thi','2005-02-28','F','Kinh','Active','Good','2513074','SH8','Biotechnology','BK004','P.401',1,'0389123602','nga.lethi05@hcmut.edu.vn','Quan 5, Ho Chi Minh','075362520174','Le Van Anh','Father','Businessman','1976-02-23','0389123603','Quan 5, Ho Chi Minh'),
('05630075','012345670175','Oanh','Pham Thi','2003-03-05','F','Kinh','Active','Good','2313075','KT8','Computer Engineering','BK004','P.402',1,'0389123604','oanh.phamthi03@hcmut.edu.vn','Quan 6, Ho Chi Minh','075362520175','Pham Van Bao','Father','Teacher','1974-03-01','0389123605','Quan 6, Ho Chi Minh'),
('05630076','012345670176','Phong','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413076','KHMT9','Computer Science','BK004','P.402',1,'0389123606','phong.nguyenvan04@hcmut.edu.vn','Quan 7, Ho Chi Minh','075362520176','Nguyen Van Chi','Father','Accountant','1975-04-05','0389123607','Quan 7, Ho Chi Minh'),
('05630077','012345670177','Quang','Tran Van','2005-05-15','M','Kinh','Active','Good','2513077','CNTT9','Information Technology','BK004','P.403',1,'0389123608','quang.tranvan05@hcmut.edu.vn','Quan 8, Ho Chi Minh','075362520177','Tran Van Dung','Father','Engineer','1976-05-10','0389123609','Quan 8, Ho Chi Minh'),
('05630078','012345670178','Rang','Le Van','2003-06-20','M','Kinh','Active','Good','2313078','DTVT9','Electronics and Telecommunications Engineering','BK004','P.403',1,'0389123610','rang.levan03@hcmut.edu.vn','Quan 9, Ho Chi Minh','075362520178','Le Van Em','Father','Doctor','1974-06-15','0389123611','Quan 9, Ho Chi Minh'),
('05630079','012345670179','Son','Pham Van','2004-07-25','M','Kinh','Active','Good','2413079','CK9','Mechanical Engineering','BK004','P.404',1,'0389123612','son.phamvan04@hcmut.edu.vn','Quan 10, Ho Chi Minh','075362520179','Pham Van Giang','Father','Businessman','1975-07-20','0389123613','Quan 10, Ho Chi Minh'),
('05630080','012345670180','Tam','Nguyen Thi','2005-08-30','F','Kinh','Active','Good','2513080','D9','Electrical Engineering','BK004','P.404',1,'0389123614','tam.nguyenthi05@hcmut.edu.vn','Quan 11, Ho Chi Minh','075362520180','Nguyen Van Hoa','Father','Teacher','1976-08-25','0389123615','Quan 11, Ho Chi Minh'),
('05630081','012345670181','Uyen','Tran Thi','2003-09-05','F','Kinh','Active','Good','2313081','HTTT9','Information Security','BK001','P.101',1,'0389123616','uyen.tranthi03@hcmut.edu.vn','Quan 12, Ho Chi Minh','075362520181','Tran Van Hung','Father','Accountant','1974-09-01','0389123617','Quan 12, Ho Chi Minh'),
('05630082','012345670182','Viet','Le Van','2004-10-10','M','Kinh','Active','Good','2413082','XD9','Civil Engineering','BK001','P.101',1,'0389123618','viet.levan04@hcmut.edu.vn','Binh Thanh, Ho Chi Minh','075362520182','Le Van Lan','Father','Engineer','1975-10-05','0389123619','Binh Thanh, Ho Chi Minh'),
('05630083','012345670183','Xuan','Pham Thi','2005-11-15','F','Kinh','Active','Good','2513083','H9','Chemical Engineering','BK001','P.102',1,'0389123620','xuan.phamthi05@hcmut.edu.vn','Tan Binh, Ho Chi Minh','075362520183','Pham Van Minh','Father','Doctor','1976-11-10','0389123621','Tan Binh, Ho Chi Minh'),
('05630084','012345670184','Yen','Nguyen Thi','2003-12-20','F','Kinh','Active','Good','2313084','MT9','Environmental Engineering','BK001','P.102',1,'0389123622','yen.nguyenthi03@hcmut.edu.vn','Tan Phu, Ho Chi Minh','075362520184','Nguyen Van Nga','Father','Businessman','1974-12-15','0389123623','Tan Phu, Ho Chi Minh'),
('05630085','012345670185','Anh','Tran Van','2004-01-25','M','Kinh','Active','Good','2413085','DK9','Control and Automation Engineering','BK002','P.101',1,'0389123624','anh.tranvan04@hcmut.edu.vn','Phu Nhuan, Ho Chi Minh','075362520185','Tran Van Oanh','Father','Teacher','1975-01-20','0389123625','Phu Nhuan, Ho Chi Minh'),
('05630086','012345670186','Bao','Le Van','2005-02-28','M','Kinh','Active','Good','2513086','QL9','Industrial Management','BK002','P.101',1,'0389123626','bao.levan05@hcmut.edu.vn','Go Vap, Ho Chi Minh','075362520186','Le Van Phong','Father','Engineer','1976-02-23','0389123627','Go Vap, Ho Chi Minh'),
('05630087','012345670187','Chi','Pham Thi','2003-03-05','F','Kinh','Active','Good','2313087','SCM9','Logistics and Supply Chain Management','BK002','P.102',1,'0389123628','chi.phamthi03@hcmut.edu.vn','Binh Tan, Ho Chi Minh','075362520187','Pham Van Quang','Father','Accountant','1974-03-01','0389123629','Binh Tan, Ho Chi Minh'),
('05630088','012345670188','Dung','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413088','VL9','Materials Engineering','BK002','P.102',1,'0389123630','dung.nguyenvan04@hcmut.edu.vn','Thu Duc, Ho Chi Minh','075362520188','Nguyen Van Rang','Father','Businessman','1975-04-05','0389123631','Thu Duc, Ho Chi Minh'),
('05630089','012345670189','Em','Tran Thi','2005-05-15','F','Kinh','Active','Good','2513089','SH9','Biotechnology','BK002','P.103',1,'0389123632','em.tranthi05@hcmut.edu.vn','Nha Be, Ho Chi Minh','075362520189','Tran Van Son','Father','Teacher','1976-05-10','0389123633','Nha Be, Ho Chi Minh'),
('05630090','012345670190','Giang','Le Van','2003-06-20','M','Kinh','Active','Good','2313090','KT9','Computer Engineering','BK002','P.103',1,'0389123634','giang.levan03@hcmut.edu.vn','Can Gio, Ho Chi Minh','075362520190','Le Van Tam','Father','Engineer','1974-06-15','0389123635','Can Gio, Ho Chi Minh'),
('05630091','012345670191','Hoa','Pham Thi','2004-07-25','F','Kinh','Active','Good','2413091','KHMT10','Computer Science','BK002','P.201',1,'0389123636','hoa.phamthi04@hcmut.edu.vn','Cu Chi, Ho Chi Minh','075362520191','Pham Van Uyen','Father','Doctor','1975-07-20','0389123637','Cu Chi, Ho Chi Minh'),
('05630092','012345670192','Hung','Nguyen Van','2005-08-30','M','Kinh','Active','Good','2513092','CNTT10','Information Technology','BK002','P.201',1,'0389123638','hung.nguyenvan05@hcmut.edu.vn','Hoc Mon, Ho Chi Minh','075362520192','Nguyen Van Viet','Father','Businessman','1976-08-25','0389123639','Hoc Mon, Ho Chi Minh'),
('05630093','012345670193','Lan','Tran Thi','2003-09-05','F','Kinh','Active','Good','2313093','DTVT10','Electronics and Telecommunications Engineering','BK002','P.202',1,'0389123640','lan.tranthi03@hcmut.edu.vn','Quan 1, Ho Chi Minh','075362520193','Tran Van Xuan','Father','Teacher','1974-09-01','0389123641','Quan 1, Ho Chi Minh'),
('05630094','012345670194','Minh','Le Van','2004-10-10','M','Kinh','Active','Good','2413094','CK10','Mechanical Engineering','BK002','P.202',1,'0389123642','minh.levan04@hcmut.edu.vn','Quan 2, Ho Chi Minh','075362520194','Le Van Yen','Father','Accountant','1975-10-05','0389123643','Quan 2, Ho Chi Minh'),
('05630095','012345670195','Nga','Pham Thi','2005-11-15','F','Kinh','Active','Good','2513095','D10','Electrical Engineering','BK002','P.203',1,'0389123644','nga.phamthi05@hcmut.edu.vn','Quan 3, Ho Chi Minh','075362520195','Pham Van Anh','Father','Engineer','1976-11-10','0389123645','Quan 3, Ho Chi Minh'),
('05630096','012345670196','Oanh','Nguyen Thi','2003-12-20','F','Kinh','Active','Good','2313096','HTTT10','Information Security','BK002','P.203',1,'0389123646','oanh.nguyenthi03@hcmut.edu.vn','Quan 4, Ho Chi Minh','075362520196','Nguyen Van Bao','Father','Doctor','1974-12-15','0389123647','Quan 4, Ho Chi Minh'),
('05630097','012345670197','Phong','Tran Van','2004-01-25','M','Kinh','Active','Good','2413097','XD10','Civil Engineering','BK002','P.204',1,'0389123648','phong.tranvan04@hcmut.edu.vn','Quan 5, Ho Chi Minh','075362520197','Tran Van Chi','Father','Businessman','1975-01-20','0389123649','Quan 5, Ho Chi Minh'),
('05630098','012345670198','Quang','Le Van','2005-02-28','M','Kinh','Active','Good','2513098','H10','Chemical Engineering','BK002','P.204',1,'0389123650','quang.levan05@hcmut.edu.vn','Quan 6, Ho Chi Minh','075362520198','Le Van Dung','Father','Teacher','1976-02-23','0389123651','Quan 6, Ho Chi Minh'),
('05630099','012345670199','Rang','Pham Van','2003-03-05','M','Kinh','Active','Good','2313099','MT10','Environmental Engineering','BK002','P.301',1,'0389123652','rang.phamvan03@hcmut.edu.vn','Quan 7, Ho Chi Minh','075362520199','Pham Van Em','Father','Engineer','1974-03-01','0389123653','Quan 7, Ho Chi Minh'),
('05630100','012345670200','Son','Nguyen Van','2004-04-10','M','Kinh','Active','Good','2413100','DK10','Control and Automation Engineering','BK002','P.301',1,'0389123654','son.nguyenvan04@hcmut.edu.vn','Quan 8, Ho Chi Minh','075362520200','Nguyen Van Giang','Father','Accountant','1975-04-05','0389123655','Quan 8, Ho Chi Minh');
UNLOCK TABLES;


DELIMITER ;;

DELIMITER ;
DELIMITER ;;

DELIMITER ;


CREATE TABLE disciplinary_action (

  action_id VARCHAR(20) PRIMARY KEY,

  action_type VARCHAR(50) NOT NULL,

  reason TEXT NOT NULL,

  decision_date DATE NOT NULL,

  effective_from DATE NOT NULL,

  effective_to DATE,

  severity_level ENUM('low','medium','high','expulsion') NOT NULL,

  status ENUM('pending','active','completed','cancelled') NOT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE student_discipline (

  action_id VARCHAR(20) NOT NULL,

  sssn CHAR(8) NOT NULL,

  PRIMARY KEY (action_id, sssn),

  FOREIGN KEY (action_id) REFERENCES disciplinary_action(action_id)

    ON DELETE CASCADE ON UPDATE CASCADE,

  FOREIGN KEY (sssn) REFERENCES student(sssn)

    ON DELETE CASCADE ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;





INSERT INTO disciplinary_action (

  action_id, action_type, reason, decision_date,

  effective_from, effective_to, severity_level, status

) VALUES
('DA001', 'Warning', 'Failure to comply with dorm rules',
 '2024-12-12', '2024-12-13', NULL, 'low', 'completed'),

('DA002', 'Cleaning Duty', 'Minor room cleanliness issue',
 '2024-12-20', '2024-12-21', '2025-01-05', 'low', 'completed'),

('DA003', 'Community Service', 'Disruptive behavior in common areas',
 '2025-01-02', '2025-01-03', '2025-02-03', 'medium', 'completed'),

('DA004', 'Warning', 'Unauthorized electrical appliance',
 '2025-01-15', '2025-01-16', NULL, 'medium', 'active'),

('DA005', 'Dorm Cleaning', 'Failure to attend mandatory meeting',
 '2025-01-28', '2025-01-29', '2025-02-12', 'low', 'completed'),

('DA006', 'Probation', 'Repeated noise violations',
 '2025-02-10', '2025-02-11', '2025-07-11', 'medium', 'active'),

('DA007', 'Formal Warning', 'Unauthorized room change',
 '2025-02-22', '2025-02-23', '2025-04-23', 'medium', 'completed'),

('DA008', 'Community Service', 'Misuse of dormitory facilities',
 '2025-03-03', '2025-03-04', '2025-05-04', 'medium', 'active'),

('DA009', 'Warning', 'Failing to follow hygiene rules',
 '2025-03-14', '2025-03-15', NULL, 'low', 'active'),

('DA010', 'Expulsion', 'Severe assault or endangerment',
 '2025-03-28', '2025-03-29', NULL, 'high', 'pending'),

('DA011', 'Cleaning Duty', 'Violation of quiet hours',
 '2025-01-05', '2025-01-06', '2025-01-20', 'low', 'completed'),
('DA012', 'Warning', 'Late curfew return',
 '2025-01-18', '2025-01-19', NULL, 'medium', 'completed'),
('DA013', 'Community Service', 'Unauthorized guest in dormitory',
 '2025-02-03', '2025-02-04', '2025-03-04', 'medium', 'completed'),
('DA014', 'Dorm Cleaning', 'Noise complaint from neighbors',
 '2025-02-22', '2025-02-23', '2025-03-23', 'low', 'completed'),
('DA015', 'Library Service', 'Unauthorized access to restricted areas',
 '2025-03-05', '2025-03-06', '2025-05-06', 'medium', 'active'),
('DA016', 'Hall Monitoring', 'Disregard for dormitory staff instructions',
 '2025-03-25', '2025-03-26', '2025-06-26', 'low', 'active'),
('DA017', 'Community Service', 'Smoking in non-designated areas',
 '2025-04-07', '2025-04-08', '2025-07-08', 'medium', 'active'),
('DA018', 'Formal Warning', 'Harassment or bullying',
 '2025-04-19', '2025-04-20', '2025-10-20', 'high', 'active'),
('DA019', 'Dorm Cleaning', 'Room cleanliness violation',
 '2025-05-02', '2025-05-03', '2025-05-17', 'low', 'completed'),
('DA020', 'Yard Cleaning', 'Improper trash disposal',
 '2025-05-21', '2025-05-22', '2025-06-22', 'low', 'completed'),
('DA021', 'Community Service', 'Absence without notice',
 '2025-06-04', '2025-06-05', '2025-07-05', 'medium', 'completed'),
('DA022', 'Warning', 'Repeated late curfew return',
 '2025-06-23', '2025-06-24', NULL, 'medium', 'active'),
('DA023', 'Probation', 'Repeated minor violations',
 '2025-07-06', '2025-07-07', '2025-11-07', 'medium', 'active'),
('DA024', 'Expulsion', 'Physical assault or fighting',
 '2025-07-24', '2025-07-25', NULL, 'high', 'pending'),
('DA025', 'Dorm Cleaning', 'Violation of quiet hours',
 '2025-08-09', '2025-08-10', '2025-08-24', 'low', 'completed'),
('DA026', 'Community Service', 'Unauthorized guest in dormitory',
 '2025-08-27', '2025-08-28', '2025-10-28', 'medium', 'active'),
('DA027', 'Formal Warning', 'Harassment or bullying',
 '2025-09-08', '2025-09-09', '2025-12-09', 'high', 'active'),
('DA028', 'Cleaning Duty', 'Noise complaint from neighbors',
 '2025-09-26', '2025-09-27', '2025-10-11', 'low', 'completed'),
('DA029', 'Probation', 'Repeated late curfew return',
 '2025-10-11', '2025-10-12', '2026-01-12', 'medium', 'active'),
('DA030', 'Expulsion', 'Serious property damage',
 '2025-11-05', '2025-11-06', NULL, 'high', 'pending'),

-- Additional violations for BK001 in date range 2025-03-04 to 2025-11-23
('DA031', 'Warning', 'Late curfew return',
 '2025-03-15', '2025-03-16', NULL, 'low', 'completed'),
('DA032', 'Community Service', 'Noise disturbance',
 '2025-04-10', '2025-04-11', '2025-05-11', 'medium', 'completed'),
('DA033', 'Dorm Cleaning', 'Room cleanliness violation',
 '2025-05-20', '2025-05-21', '2025-06-04', 'low', 'completed'),
('DA034', 'Formal Warning', 'Unauthorized guest',
 '2025-06-15', '2025-06-16', '2025-09-16', 'medium', 'active'),
('DA035', 'Probation', 'Repeated violations',
 '2025-07-10', '2025-07-11', '2025-12-11', 'medium', 'active'),
('DA036', 'Warning', 'Violation of quiet hours',
 '2025-08-05', '2025-08-06', NULL, 'low', 'completed'),
('DA037', 'Community Service', 'Improper trash disposal',
 '2025-09-12', '2025-09-13', '2025-10-13', 'low', 'completed'),
('DA038', 'Expulsion', 'Serious misconduct',
 '2025-10-20', '2025-10-21', NULL, 'high', 'pending');

LOCK TABLES `student_discipline` WRITE;

INSERT INTO `student_discipline` (action_id, sssn) VALUES
-- BK001: 8 violations (05630001-05630017, 05630081-05630084)
('DA001','05630001'),
('DA002','05630003'),
('DA003','05630005'),
('DA004','05630007'),
('DA005','05630010'),
('DA006','05630012'),
('DA007','05630015'),
('DA008','05630017'),

-- BK002: 7 violations (05630018-05630038, 05630085-05630100)
('DA009','05630018'),
('DA010','05630020'),
('DA011','05630022'),
('DA012','05630025'),
('DA013','05630028'),
('DA014','05630031'),
('DA015','05630034'),

-- BK003: 8 violations (05630039-05630060)
('DA016','05630039'),
('DA017','05630041'),
('DA018','05630043'),
('DA019','05630045'),
('DA020','05630047'),
('DA021','05630050'),
('DA022','05630052'),
('DA023','05630055'),

-- BK004: 7 violations (05630061-05630080)
('DA024','05630061'),
('DA025','05630063'),
('DA026','05630065'),
('DA027','05630068'),
('DA028','05630071'),
('DA029','05630074'),
('DA030','05630077'),

-- Additional violations for BK001 in date range 2025-03-04 to 2025-11-23
('DA031','05630002'),
('DA032','05630004'),
('DA033','05630006'),
('DA034','05630008'),
('DA035','05630011'),
('DA036','05630013'),
('DA037','05630014'),
('DA038','05630016');

UNLOCK TABLES;

UNLOCK TABLES;


DELIMITER ;;
CREATE  FUNCTION `check_user_exists`(p_user_name VARCHAR(50)) RETURNS TINYINT
    DETERMINISTIC
BEGIN
    DECLARE user_count INT;
    
    SELECT COUNT(*) INTO user_count
    FROM manager_dorm
    WHERE user_name = p_user_name;

    RETURN user_count > 0;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  FUNCTION `num_validity_dormitory_card`() RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE num INT;
    SELECT COUNT(*) INTO num FROM dormitory_card WHERE Validity = 1;
    RETURN num;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `check_one_room_underoccupied`(
    IN p_building_id CHAR(5),
    IN p_room_id CHAR(5)
)
BEGIN
	IF LENGTH(REPLACE(TRIM(p_building_id), ' ', '')) != 5 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Building ID must be exactly 5 characters long.';
	END IF;
    
    IF LENGTH(REPLACE(TRIM(p_room_id), ' ', '')) != 5 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room ID must be exactly 5 characters long.';
	END IF;

    SELECT 
        building_id,
        room_id,
        current_num_of_students,
        max_num_of_students,
        CONCAT(occupancy_rate, '%') AS occupancy_rate
    FROM living_room
    WHERE building_id = p_building_id
      AND room_id = p_room_id
      AND current_num_of_students < max_num_of_students;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE `create_dormitory_card`(IN p_sssn CHAR(8))
BEGIN
    DECLARE v_exists INT;

    
    SELECT COUNT(*) INTO v_exists
    FROM student
    WHERE sssn = p_sssn;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student not found.';
    ELSE
        
        INSERT INTO dormitory_card (number, start_date, end_date, id_card, validity)
        VALUES (
            CONCAT('CD', LPAD(FLOOR(RAND() * 1000000), 5, '0')), 
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 1 YEAR),
            p_sssn,    
            1          
        );
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `delete_contact_info`(
    IN p_ssn CHAR(8)
)
BEGIN
    DELETE FROM address WHERE sssn = p_ssn;
    DELETE FROM phone_number WHERE sssn = p_ssn;
    DELETE FROM email WHERE sssn = p_ssn;
END ;;
DELIMITER ;
DELIMITER ;;
CREATE  PROCEDURE `delete_student_by_sssn`(IN p_sssn CHAR(8))
BEGIN
  DECLARE v_count INT DEFAULT 0;
  DECLARE v_building CHAR(5) DEFAULT NULL;
  DECLARE v_room CHAR(5) DEFAULT NULL;
  DECLARE v_max INT DEFAULT NULL;
  DECLARE v_curr INT DEFAULT NULL;

  
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1
      @err_no = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
    SELECT CONCAT('? SQL Error ', @err_no, ': ', @msg) AS debug_message;
    ROLLBACK;
  END;

  START TRANSACTION;

  
  SELECT COUNT(*) INTO v_count
  FROM student
  WHERE sssn = p_sssn;

  SELECT CONCAT('? Step 1: Found ', v_count, ' student(s)') AS info;
  IF v_count = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Student with this SSSN does not exist.';
  END IF;

  
  SELECT building_id, room_id
  INTO v_building, v_room
  FROM student
  WHERE sssn = p_sssn;

  SELECT CONCAT('? Step 2: building_id=', COALESCE(v_building, 'NULL'),
                ', room_id=', COALESCE(v_room, 'NULL')) AS info;

  
  IF v_building IS NOT NULL AND v_room IS NOT NULL THEN
    SELECT max_num_of_students, current_num_of_students
    INTO v_max, v_curr
    FROM living_room
    WHERE building_id = v_building AND room_id = v_room;

    SELECT CONCAT('? Step 3: Found room data -> max=', COALESCE(v_max, -1),
                  ', curr=', COALESCE(v_curr, -1)) AS info;

    UPDATE living_room
    SET current_num_of_students = GREATEST(current_num_of_students - 1, 0),
        occupancy_rate = CASE
          WHEN max_num_of_students > 0 THEN ROUND((GREATEST(current_num_of_students - 1, 0) / max_num_of_students) * 100, 2)
          ELSE 0
        END
    WHERE building_id = v_building AND room_id = v_room;
  ELSE
    SELECT '? Step 3 skipped: No room data' AS info;
  END IF;

  
  UPDATE dormitory_card
  SET validity = FALSE
  WHERE id_card = p_sssn;
  SELECT '? Step 4: dormitory_card updated' AS info;

  
  BEGIN
    DECLARE table_exists INT DEFAULT 0;
    SELECT COUNT(*)
    INTO table_exists
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = 'relative';

    IF table_exists > 0 THEN
      DELETE FROM relative WHERE sssn = p_sssn;
      SELECT '? Step 5: relative deleted' AS info;
    ELSE
      SELECT '? Step 5 skipped: table relative not found' AS info;
    END IF;
  END;

  
  DELETE FROM student WHERE sssn = p_sssn;
  SELECT '? Step 6: student deleted' AS info;

  COMMIT;
  SELECT '? Delete success!' AS done;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  PROCEDURE `get_all_students`()
BEGIN
    SELECT 
        sssn,
        first_name,
        last_name,
        birthday,
        sex,
        ethnic_group,
        study_status,
        health_state,
        student_id,
        class_name,
        faculty,
        building_id,
        room_id
    FROM student;
END ;;
DELIMITER ;
DELIMITER ;;
CREATE  PROCEDURE `get_manager_dorm_by_username`(IN p_user_name VARCHAR(255))
BEGIN
    SELECT * FROM manager_dorm WHERE user_name = p_user_name;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  PROCEDURE `get_paginated_students`(
  IN p_page INT,
  IN p_limit INT
)
BEGIN
  DECLARE v_offset INT;
  SET v_offset = (p_page - 1) * p_limit;

  SELECT 
    sssn, cccd, first_name, last_name, birthday, sex,
    ethnic_group, study_status, health_state,
    student_id, class_name, faculty, building_id, room_id,
    phone_numbers, emails, addresses, has_health_insurance,
    guardian_cccd, guardian_name, guardian_relationship,
    guardian_occupation, guardian_birthday,
    guardian_phone_numbers, guardian_addresses
  FROM student
  ORDER BY sssn
  LIMIT p_limit OFFSET v_offset;

  SELECT COUNT(*) AS total FROM student;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `get_student`()
BEGIN
  SELECT 
    s.sssn AS cccd,
    s.student_id,
    s.first_name,
    s.last_name,
    s.birthday,
    s.sex,
    s.health_state,
    s.ethnic_group,
    s.study_status,
    s.class_name,
    s.faculty,
    s.building_id,
    s.room_id,

    GROUP_CONCAT(DISTINCT ph.phone_number SEPARATOR '; ') AS phone_numbers,
    GROUP_CONCAT(DISTINCT CONCAT_WS(', ', a.commune, a.province) SEPARATOR '; ') AS addresses,
    GROUP_CONCAT(DISTINCT e.email SEPARATOR '; ') AS emails

  FROM student s
  JOIN dormitory_card dc 
       ON dc.id_card = s.sssn 
      AND dc.validity = TRUE
  LEFT JOIN phone_number ph 
       ON s.sssn = ph.sssn
  LEFT JOIN address a 
       ON s.sssn = a.sssn
  LEFT JOIN email e 
       ON s.sssn = e.sssn

  GROUP BY 
    s.sssn, s.student_id, s.first_name, s.last_name,
    s.birthday, s.sex, s.health_state, s.ethnic_group,
    s.study_status, s.class_name, s.faculty, s.building_id, s.room_id;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  PROCEDURE `get_student_by_sssn`(IN p_sssn CHAR(8))
BEGIN
    
    IF LENGTH(REPLACE(TRIM(p_sssn), ' ', '')) != 8 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SSSN must be exactly 8 characters long.';
    END IF;

    
    SELECT 
        s.sssn,
        s.cccd,
        s.first_name,
        s.last_name,
        s.birthday,
        s.sex,
        s.health_state,
        s.ethnic_group,
        s.student_id,
        s.study_status,
        s.class_name,
        s.faculty,
        s.building_id,
        s.room_id,
        GROUP_CONCAT(DISTINCT ph.phone_number SEPARATOR ';') AS phone_numbers,
        GROUP_CONCAT(DISTINCT CONCAT_WS(', ', a.commune, a.province) SEPARATOR ';') AS addresses,
        GROUP_CONCAT(DISTINCT e.email SEPARATOR ';') AS emails
    FROM student s
    LEFT JOIN phone_number ph ON s.sssn = ph.sssn
    LEFT JOIN address a ON s.sssn = a.sssn
    LEFT JOIN email e ON s.sssn = e.sssn
    WHERE s.sssn = p_sssn
    GROUP BY 
        s.sssn, s.first_name, s.last_name, s.birthday, s.sex, 
        s.health_state, s.ethnic_group, s.student_id, s.study_status, 
        s.class_name, s.faculty, s.building_id, s.room_id;

    
    SELECT 
        r.guardian_cccd AS guardian_cccd,
        r.fname AS guardian_first_name,
        r.lname AS guardian_last_name,
        CONCAT(r.fname, ' ', r.lname) AS guardian_name,
        r.relationship AS guardian_relationship,
        r.birthday AS guardian_birthday,
        r.phone_number AS guardian_phone_numbers,
        r.address AS guardian_addresses,
        r.job AS guardian_occupation
    FROM relative r
    WHERE r.sssn = p_sssn;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  PROCEDURE `get_violation_statistics_by_type`(IN min_count INT)
BEGIN
    SELECT reason, COUNT(*) AS violation_count
    FROM student_discipline sd
    JOIN disciplinary_action da ON sd.action_id = da.action_id
    GROUP BY reason
    HAVING COUNT(*) >= min_count
    ORDER BY violation_count DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `insert_addresses`(
	IN p_ssn CHAR(8),
	IN p_addresses TEXT
)
BEGIN
	DECLARE addr_index INT DEFAULT 1;
    DECLARE addr_item VARCHAR(255);
    DECLARE commune VARCHAR(30);
    DECLARE province VARCHAR(30);
    DECLARE num INT DEFAULT 0;
    DECLARE comma_count INT;

	IF p_addresses IS NOT NULL AND p_addresses != '' THEN
        SET num = LENGTH(p_addresses) - LENGTH(REPLACE(p_addresses, ';', '')) + 1;

        WHILE addr_index <= num DO
            SET addr_item = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_addresses, ';', addr_index), ';', -1));

            IF addr_item != '' THEN
                SET comma_count = LENGTH(addr_item) - LENGTH(REPLACE(addr_item, ',', ''));
                IF comma_count < 0 OR comma_count > 2 THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid address format';
                END IF;

                IF comma_count = 2 THEN
                    SET commune = TRIM(SUBSTRING_INDEX(addr_item, ',', 1));
                    SET province = TRIM(SUBSTRING_INDEX(addr_item, ',', -1));
                ELSEIF comma_count = 1 THEN
                    SET commune = TRIM(SUBSTRING_INDEX(addr_item, ',', 1));
                    SET province = '';
                ELSE
                    SET commune = TRIM(addr_item);
                    SET province = '';
                END IF;

                IF EXISTS (
                    SELECT 1 FROM address A
					WHERE A.sssn = p_ssn
					  AND TRIM(LOWER(A.commune)) = TRIM(LOWER(commune))
					  AND TRIM(LOWER(A.province)) = TRIM(LOWER(province))
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This address already exists';
                ELSE
                    INSERT INTO address (sssn, commune, province)
                    VALUES (p_ssn, commune, province);
                END IF;
            END IF;

            SET addr_index = addr_index + 1;
        END WHILE;
    END IF;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  PROCEDURE `insert_emails`(
	IN p_ssn CHAR(8),
	IN p_emails TEXT
)
BEGIN
	DECLARE email_index INT DEFAULT 1;
    DECLARE email_item VARCHAR(50);
    DECLARE num INT DEFAULT 0;

	IF p_emails IS NOT NULL AND p_emails != '' THEN
        SET num = LENGTH(p_emails) - LENGTH(REPLACE(p_emails, ';', '')) + 1;
        WHILE email_index <= num DO
            SET email_item = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_emails, ';', email_index), ';', -1));
            IF email_item != '' THEN
                IF NOT (email_item REGEXP '^[^@]+@[^@]+\\.[^@]+$') THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email';
                END IF;
                IF EXISTS (
                    SELECT 1 FROM email
                    WHERE sssn = p_ssn AND email = email_item
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email already exists';
                ELSE
                    INSERT INTO email (sssn, email)
                    VALUES (p_ssn, email_item);
                END IF;
            END IF;
            SET email_index = email_index + 1;
        END WHILE;
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `insert_manager_dorm`(
    IN p_user_name VARCHAR(50),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE user_exists INT;
    
    SELECT COUNT(*) INTO user_exists
    FROM manager_dorm
    WHERE user_name = p_user_name;
    IF user_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User already exists';
    ELSE
        INSERT INTO manager_dorm (user_name, password)
        VALUES (p_user_name, p_password);
    END IF;
    
END ;;
DELIMITER ;

DELIMITER ;;
CREATE  PROCEDURE `insert_phone_numbers`(
	IN p_ssn CHAR(8),
	IN p_phone_numbers TEXT
)
BEGIN
	DECLARE phone_index INT DEFAULT 1;
    DECLARE phone_item CHAR(10);
    DECLARE num INT DEFAULT 0;

	IF p_phone_numbers IS NOT NULL AND p_phone_numbers != '' THEN
        SET num = LENGTH(p_phone_numbers) - LENGTH(REPLACE(p_phone_numbers, ';', '')) + 1;

        WHILE phone_index <= num DO
            SET phone_item = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_phone_numbers, ';', phone_index), ';', -1));

            IF phone_item != '' THEN
                IF LENGTH(phone_item) != 10 OR phone_item REGEXP '[^0-9]' THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid phone number';
                END IF;

                IF EXISTS (
                    SELECT 1 FROM phone_number
                    WHERE sssn = p_ssn AND phone_number = phone_item
                ) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This phone number already exists';
                ELSE
                    INSERT INTO phone_number (sssn, phone_number)
                    VALUES (p_ssn, phone_item);
                END IF;
            END IF;

            SET phone_index = phone_index + 1;
        END WHILE;
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `insert_student`(
    IN p_sssn CHAR(8),
    IN p_cccd CHAR(12),
    IN p_first_name VARCHAR(20),
    IN p_last_name VARCHAR(20),
    IN p_birthday DATE,
    IN p_sex CHAR(1),
    IN p_ethnic_group VARCHAR(30),
    IN p_health_state VARCHAR(100),
    IN p_student_id CHAR(12),
    IN p_study_status VARCHAR(20),
    IN p_class_name VARCHAR(30),
    IN p_faculty VARCHAR(50),
    IN p_building_id CHAR(5),
    IN p_room_id CHAR(5),
    IN p_phone_numbers TEXT,
    IN p_emails TEXT,
    IN p_addresses TEXT,
    IN p_guardian_cccd CHAR(12),
    IN p_guardian_name VARCHAR(50),
    IN p_guardian_relationship VARCHAR(20),
    IN p_guardian_occupation VARCHAR(50),
    IN p_guardian_birthday DATE,
    IN p_guardian_phone_numbers TEXT,
    IN p_guardian_addresses TEXT
)
BEGIN
    INSERT INTO student (
        sssn, cccd, first_name, last_name, birthday, sex, ethnic_group,
        health_state, student_id, study_status, class_name, faculty,
        building_id, room_id, phone_numbers, emails, addresses,
        guardian_cccd, guardian_name, guardian_relationship,
        guardian_occupation, guardian_birthday, guardian_phone_numbers, guardian_addresses
    )
    VALUES (
        p_sssn, p_cccd, p_first_name, p_last_name, p_birthday, p_sex, p_ethnic_group,
        p_health_state, p_student_id, p_study_status, p_class_name, p_faculty,
        p_building_id, p_room_id, p_phone_numbers, p_emails, p_addresses,
        p_guardian_cccd, p_guardian_name, p_guardian_relationship,
        p_guardian_occupation, p_guardian_birthday, p_guardian_phone_numbers, p_guardian_addresses
    );
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `update_guardian_info`(
    IN p_sssn CHAR(8),
    IN p_guardian_cccd CHAR(12),
    IN p_guardian_name VARCHAR(100),
    IN p_guardian_relationship VARCHAR(50),
    IN p_guardian_occupation VARCHAR(50),
    IN p_guardian_birthday DATE,
    IN p_guardian_phone_numbers VARCHAR(200),
    IN p_guardian_addresses VARCHAR(500)
)
BEGIN
    UPDATE student
    SET
        guardian_cccd = p_guardian_cccd,
        guardian_name = p_guardian_name,
        guardian_relationship = p_guardian_relationship,
        guardian_occupation = p_guardian_occupation,
        guardian_birthday = p_guardian_birthday,
        guardian_phone_numbers = p_guardian_phone_numbers,
        guardian_addresses = p_guardian_addresses
    WHERE sssn = p_sssn;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `update_relative_by_sssn`(
    IN p_sssn CHAR(8),
    IN p_guardian_cccd CHAR(12),
    IN p_fname VARCHAR(20),
    IN p_lname VARCHAR(20),
    IN p_birthday DATE,
    IN p_relationship VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_phone_number VARCHAR(100),
    IN p_job VARCHAR(50)
)
BEGIN
    IF EXISTS (SELECT 1 FROM relative WHERE sssn = p_sssn) THEN
        UPDATE relative
        SET guardian_cccd = p_guardian_cccd,
            fname = p_fname,
            lname = p_lname,
            birthday = p_birthday,
            relationship = p_relationship,
            address = p_address,
            phone_number = p_phone_number,
            job = p_job
        WHERE sssn = p_sssn;
    ELSE
        INSERT INTO relative (
            sssn, guardian_cccd, fname, lname, birthday, relationship, address, phone_number, job
        ) VALUES (
            p_sssn, p_guardian_cccd, p_fname, p_lname, p_birthday, p_relationship, p_address, p_phone_number, p_job
        );
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `update_student`(
    IN p_new_ssn CHAR(8),
    IN p_ssn CHAR(8),
    IN p_last_name VARCHAR(20),
    IN p_first_name VARCHAR(20),
    IN p_birthday DATE,
    IN p_sex CHAR(1),
    IN p_health_state VARCHAR(100),
    IN p_ethnic_group VARCHAR(30),
    IN p_student_id CHAR(7),
    IN p_has_health_insurance BOOLEAN,
    IN p_study_status VARCHAR(20),
    IN p_class_name VARCHAR(20),
    IN p_faculty VARCHAR(50),
    IN p_building_id CHAR(5),
    IN p_room_id CHAR(5),
    IN p_addresses TEXT,
    IN p_phone_numbers TEXT,
    IN p_emails TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p_message = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @p_message;
    END;
    
    START TRANSACTION;
    
    
    IF LENGTH(REPLACE(TRIM(p_ssn), ' ', '')) != 8 OR LENGTH(REPLACE(TRIM(p_new_ssn), ' ', '')) != 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN must be exactly 8 characters long.';
    END IF;
    
    IF LENGTH(TRIM(p_first_name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required';
    END IF;
    
    IF LENGTH(TRIM(p_last_name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Last name is required';
    END IF;
    
    IF LENGTH(REPLACE(TRIM(p_student_id), ' ', '')) != 7 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student ID must be exactly 7 characters long.';
    END IF;
    
    IF p_ssn = p_new_ssn THEN
        
        CALL update_student_info(p_ssn, p_first_name, p_last_name, p_birthday, p_sex, p_ethnic_group, p_health_state, p_student_id, p_study_status, p_class_name, p_faculty, p_building_id, p_room_id);
        CALL delete_contact_info(p_ssn);
        CALL insert_addresses(p_ssn, p_addresses);
        CALL insert_phone_numbers(p_ssn, p_phone_numbers);
        CALL insert_emails(p_ssn, p_emails);
    ELSE
        
        CALL insert_student(p_new_ssn, p_first_name, p_last_name, p_birthday, p_sex, p_ethnic_group, p_health_state, p_student_id, p_study_status, p_class_name, p_faculty, p_building_id, p_room_id);
        CALL insert_addresses(p_new_ssn, p_addresses);
        CALL insert_phone_numbers(p_new_ssn, p_phone_numbers);
        CALL insert_emails(p_new_ssn, p_emails);
        
        CALL delete_student_by_sssn(p_ssn);
    END IF;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE  PROCEDURE `update_student_info`(
    IN p_sssn CHAR(8),
    IN p_cccd CHAR(12),
    IN p_first_name VARCHAR(20),
    IN p_last_name VARCHAR(20),
    IN p_birthday DATE,
    IN p_sex CHAR(1),
    IN p_ethnic_group VARCHAR(30),
    IN p_health_state VARCHAR(100),
    IN p_student_id CHAR(12),
    IN p_study_status VARCHAR(20),
    IN p_class_name VARCHAR(30),
    IN p_faculty VARCHAR(50),
    IN p_building_id CHAR(5),
    IN p_room_id CHAR(5),
    IN p_phone_numbers TEXT,
    IN p_emails TEXT,
    IN p_addresses TEXT,
    IN p_has_health_insurance BOOLEAN
)
BEGIN
    IF p_cccd IS NULL OR p_cccd = '' THEN
        SET p_cccd = (SELECT cccd FROM student WHERE sssn = p_sssn);
    END IF;

    IF p_building_id = '' THEN SET p_building_id = NULL; END IF;
    IF p_room_id = '' THEN SET p_room_id = NULL; END IF;

    UPDATE student
    SET
        cccd = p_cccd,
        first_name = p_first_name,
        last_name = p_last_name,
        birthday = p_birthday,
        sex = p_sex,
        ethnic_group = p_ethnic_group,
        health_state = p_health_state,
        student_id = p_student_id,
        has_health_insurance = p_has_health_insurance,
        study_status = p_study_status,
        class_name = p_class_name,
        faculty = p_faculty,
        building_id = p_building_id,
        room_id = p_room_id,
        phone_numbers = p_phone_numbers,
        emails = p_emails,
        addresses = p_addresses
    WHERE student.sssn = p_sssn;
END ;;
DELIMITER ;
SET FOREIGN_KEY_CHECKS = 1;


-- =====================================
-- ROOM MANAGEMENT PROCEDURES
-- =====================================

DELIMITER $$

-- Procedure to list all rooms in a specific building
CREATE PROCEDURE list_rooms_building(
    IN p_building_id CHAR(5)
)
BEGIN
    -- Validate building ID length
    IF LENGTH(REPLACE(TRIM(p_building_id), ' ', '')) != 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Building ID must be exactly 5 characters long.';
    END IF;

    -- Select rooms from the specified building
    SELECT 
        building_id,
        room_id,
        current_num_of_students,
        max_num_of_students,
        occupancy_rate,
        room_status,
        CONCAT(occupancy_rate, '%') AS formatted_occupancy_rate
    FROM living_room
    WHERE building_id = p_building_id
    ORDER BY room_id;
END$$

-- Procedure to list all rooms
CREATE PROCEDURE list_all_rooms()
BEGIN
    SELECT 
        building_id,
        room_id,
        current_num_of_students,
        max_num_of_students,
        occupancy_rate,
        room_status,
        CONCAT(occupancy_rate, '%') AS formatted_occupancy_rate
    FROM living_room
    ORDER BY building_id, room_id;
END$$

-- Procedure to list all underoccupied rooms
CREATE PROCEDURE list_all_underoccupied_rooms()
BEGIN
    SELECT 
        building_id,
        room_id,
        current_num_of_students,
        max_num_of_students,
        occupancy_rate,
        CONCAT(occupancy_rate, '%') AS formatted_occupancy_rate
    FROM living_room
    WHERE current_num_of_students < max_num_of_students
    ORDER BY building_id, room_id;
END$$
DELIMITER $$

CREATE PROCEDURE get_students_in_room(
    IN p_building_id VARCHAR(10),
    IN p_room_id VARCHAR(10)
)
BEGIN
    SELECT 
        s.sssn as ssn,
        s.cccd,
        s.first_name,
        s.last_name,
        s.phone_numbers
    FROM student s
    INNER JOIN living_room r
        ON s.room_id = r.room_id AND s.building_id = r.building_id
    WHERE r.building_id = p_building_id AND r.room_id = p_room_id;
END $$

DELIMITER $$
DELIMITER $$

CREATE PROCEDURE get_room_detail(
    IN p_building_id VARCHAR(10),
    IN p_room_id VARCHAR(10)
)
BEGIN
    -- Trả về thông tin phòng
    SELECT 
        building_id,
        room_id,
        max_num_of_students,
        current_num_of_students,
        occupancy_rate,
        rental_price,
        room_status
    FROM living_room
    WHERE building_id = p_building_id AND room_id = p_room_id;
END $$

DELIMITER $$
DELIMITER $$

CREATE PROCEDURE update_room(
    IN p_building_id CHAR(5),
    IN p_room_id CHAR(5),
    IN p_max_num_of_students INT,
    IN p_current_num_of_students INT,
    IN p_rental_price DECIMAL(10,2),
    IN p_room_status ENUM('Available','Occupied','Under Maintenance')
)
BEGIN
    DECLARE v_occupancy_rate DECIMAL(5,2);

    -- Tính occupancy_rate
    IF p_max_num_of_students > 0 THEN
        SET v_occupancy_rate = (p_current_num_of_students / p_max_num_of_students) * 100;
    ELSE
        SET v_occupancy_rate = 0;
    END IF;

    -- Cập nhật thông tin phòng
    UPDATE living_room
    SET 
        max_num_of_students = p_max_num_of_students,
        current_num_of_students = p_current_num_of_students,
        rental_price = p_rental_price,
        room_status = p_room_status,
        occupancy_rate = v_occupancy_rate
    WHERE building_id = p_building_id
      AND room_id = p_room_id;
END $$

DELIMITER $$


-- Procedure to list underoccupied rooms by building
CREATE PROCEDURE list_underoccupied_by_building(
    IN p_building_id CHAR(5)
)
BEGIN
    -- Validate building ID length
    IF LENGTH(REPLACE(TRIM(p_building_id), ' ', '')) != 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Building ID must be exactly 5 characters long.';
    END IF;

    -- Select underoccupied rooms from the specified building
    SELECT 
        building_id,
        room_id,
        current_num_of_students,
        max_num_of_students,
        occupancy_rate,
        room_status,
        CONCAT(occupancy_rate, '%') AS formatted_occupancy_rate
    FROM living_room
    WHERE building_id = p_building_id 
      AND current_num_of_students < max_num_of_students
    ORDER BY room_id;
END$$

DELIMITER ;

