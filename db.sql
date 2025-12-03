DROP DATABASE IF EXISTS final;
CREATE DATABASE final;
USE `final`;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================
-- 1. TẠO CẤU TRÚC BẢNG
-- =========================================================

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `building` VALUES 
('BK001','BK001',4,16,1,'HCMUT','2015-01-01','2022-06-01'),
('BK002','BK002',4,16,0,'HCMUT','2016-03-15','2023-02-10'),
('BK003','BK003',4,16,1,'HCMUT','2017-05-10','2021-09-20'),
('BK004','BK004',4,16,1,'HCMUT','2018-07-25',NULL);

CREATE TABLE discipline_forms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO discipline_forms (name, description) VALUES 
('Cafeteria Duty', 'Phục vụ tại nhà ăn'), ('Cleaning Duty', 'Vệ sinh phòng ở'), 
('Community Service', 'Lao động công ích'), ('Dorm Cleaning', 'Vệ sinh hành lang'), 
('Library Service', 'Hỗ trợ thư viện'), ('Yard Cleaning', 'Quét sân'), 
('Classroom Setup', 'Sắp xếp bàn ghế'), ('Hall Monitoring', 'Trực hành lang'), ('Expulsion', 'Buộc thôi học');

CREATE TABLE `cccd` (
  `cccd` char(12) NOT NULL,
  `sssn` char(8) NOT NULL,
  PRIMARY KEY (`cccd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `room` (
  `building_id` char(5) NOT NULL,
  `room_id` char(5) NOT NULL,
  `room_status` enum('Available','Occupied','Under Maintenance') NOT NULL,
  `room_area` decimal(10,2) NOT NULL,
  PRIMARY KEY (`building_id`,`room_id`),
  CONSTRAINT `fk_room_building` FOREIGN KEY (`building_id`) REFERENCES `building` (`building_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  CONSTRAINT `living_room_chk_4` CHECK (((`occupancy_rate` >= 0) and (`occupancy_rate` <= 100)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  CONSTRAINT `student_chk_1` CHECK ((`sex` in ('M','F')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `dormitory_card` (
  `number` VARCHAR(20) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `id_card` char(8) NOT NULL,
  `validity` TINYINT DEFAULT '1',
  PRIMARY KEY (`number`),
  KEY `id_card` (`id_card`),
  CONSTRAINT `dormitory_card_ibfk_1` FOREIGN KEY (`id_card`) REFERENCES `student` (`sssn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `manager_dorm` (
  `user_name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`user_name`,`password`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `manager_dorm` VALUES ('sManager','$2b$10$isVtVnGDb56L/sfdPVDDbekUcgoMxq500NDJbHOyvgMBL51Vo1vyu');

CREATE TABLE `other_room` (
  `building_id` char(5) NOT NULL,
  `room_id` char(5) NOT NULL,
  `room_type` varchar(100) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `num_of_staff` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`building_id`,`room_id`),
  CONSTRAINT `fk_other_room` FOREIGN KEY (`building_id`, `room_id`) REFERENCES `room` (`building_id`, `room_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  student_id CHAR(7) NOT NULL,
  PRIMARY KEY (action_id, student_id),
  FOREIGN KEY (action_id) REFERENCES disciplinary_action(action_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- 2. INSERT DỮ LIỆU PHÒNG
-- =========================================================

-- Insert Room Base
INSERT INTO `room` (building_id, room_id, room_status, room_area) VALUES
-- BK001
('BK001','P.101','Occupied',25),('BK001','P.102','Available',25),('BK001','P.103','Available',25),('BK001','P.104','Available',25),
('BK001','P.201','Available',25),('BK001','P.202','Available',25),('BK001','P.203','Available',25),('BK001','P.204','Available',25),
('BK001','P.301','Available',25),('BK001','P.302','Available',25),('BK001','P.303','Available',25),('BK001','P.304','Available',25),
('BK001','P.401','Available',25),('BK001','P.402','Available',25),('BK001','P.403','Available',25),('BK001','P.404','Available',25),
-- BK002
('BK002','P.101','Available',25),('BK002','P.102','Available',25),('BK002','P.103','Available',25),('BK002','P.104','Available',25),
('BK002','P.201','Available',25),('BK002','P.202','Available',25),('BK002','P.203','Available',25),('BK002','P.204','Available',25),
('BK002','P.301','Available',25),('BK002','P.302','Available',25),('BK002','P.303','Available',25),('BK002','P.304','Available',25),
('BK002','P.401','Available',25),('BK002','P.402','Available',25),('BK002','P.403','Available',25),('BK002','P.404','Available',25),
-- BK003
('BK003','P.101','Available',25),('BK003','P.102','Available',25),('BK003','P.103','Available',25),('BK003','P.104','Available',25),
('BK003','P.201','Available',25),('BK003','P.202','Available',25),('BK003','P.203','Available',25),('BK003','P.204','Available',25),
('BK003','P.301','Available',25),('BK003','P.302','Available',25),('BK003','P.303','Available',25),('BK003','P.304','Available',25),
('BK003','P.401','Available',25),('BK003','P.402','Available',25),('BK003','P.403','Available',25),('BK003','P.404','Available',25),
-- BK004
('BK004','P.101','Occupied',25),('BK004','P.102','Available',25),('BK004','P.103','Available',25),('BK004','P.104','Available',25),
('BK004','P.201','Available',25),('BK004','P.202','Available',25),('BK004','P.203','Available',25),('BK004','P.204','Available',25),
('BK004','P.301','Available',25),('BK004','P.302','Available',25),('BK004','P.303','Available',25),('BK004','P.304','Available',25),
('BK004','P.401','Available',25),('BK004','P.402','Available',25),('BK004','P.403','Available',25),('BK004','P.404','Available',25);

INSERT INTO `other_room` VALUES 
('BK001','P.103','Meeting Room','09:00:00','17:00:00',0),('BK002','P.103','Meeting Room','09:00:00','17:00:00',0),
('BK003','P.103','Meeting Room','09:00:00','17:00:00',0),('BK004','P.103','Meeting Room','09:00:00','17:00:00',0);

-- Insert Living Room (CẤU HÌNH TỶ LỆ)
-- BK001 (NAM)
INSERT INTO `living_room` (building_id, room_id, max_num_of_students, current_num_of_students, rental_price, occupancy_rate, room_status) VALUES
('BK001','P.101',6,6,1500000,100.00,'Occupied'), -- 6/6
('BK001','P.102',6,5,1500000,83.33,'Available'), -- 5/6
('BK001','P.103',6,3,1500000,50.00,'Available'), -- 3/6
('BK001','P.104',6,1,1500000,16.67,'Available'), -- 1/6
('BK001','P.201',4,2,1800000,50.00,'Available'), -- 2/4
('BK001','P.202',6,0,1500000,0.00,'Available'), ('BK001','P.203',6,0,1500000,0.00,'Available'), ('BK001','P.204',6,0,1500000,0.00,'Available'),
('BK001','P.301',6,0,1500000,0.00,'Available'), ('BK001','P.302',6,0,1500000,0.00,'Available'), ('BK001','P.303',6,0,1500000,0.00,'Available'), ('BK001','P.304',6,0,1500000,0.00,'Available'),
('BK001','P.401',6,0,1500000,0.00,'Available'), ('BK001','P.402',6,0,1500000,0.00,'Available'), ('BK001','P.403',6,0,1500000,0.00,'Available'), ('BK001','P.404',6,0,1500000,0.00,'Available');

-- BK002 (NAM)
INSERT INTO `living_room` (building_id, room_id, max_num_of_students, current_num_of_students, rental_price, occupancy_rate, room_status) VALUES
('BK002','P.101',6,2,1500000,33.33,'Available'), -- 2/6
('BK002','P.102',6,0,1500000,0.00,'Available'), ('BK002','P.103',6,0,1500000,0.00,'Available'), ('BK002','P.104',6,0,1500000,0.00,'Available'),
('BK002','P.201',6,0,1500000,0.00,'Available'), ('BK002','P.202',6,0,1500000,0.00,'Available'), ('BK002','P.203',6,0,1500000,0.00,'Available'), ('BK002','P.204',6,0,1500000,0.00,'Available'),
('BK002','P.301',6,0,1500000,0.00,'Available'), ('BK002','P.302',6,0,1500000,0.00,'Available'), ('BK002','P.303',6,0,1500000,0.00,'Available'), ('BK002','P.304',6,0,1500000,0.00,'Available'),
('BK002','P.401',6,0,1500000,0.00,'Available'), ('BK002','P.402',6,0,1500000,0.00,'Available'), ('BK002','P.403',6,0,1500000,0.00,'Available'), ('BK002','P.404',6,0,1500000,0.00,'Available');

-- BK003 (NỮ)
INSERT INTO `living_room` (building_id, room_id, max_num_of_students, current_num_of_students, rental_price, occupancy_rate, room_status) VALUES
('BK003','P.101',4,3,1800000,75.00,'Available'), -- 3/4
('BK003','P.102',4,2,1800000,50.00,'Available'), -- 2/4
('BK003','P.201',6,5,1500000,83.33,'Available'), -- 5/6
('BK003','P.103',6,0,1500000,0.00,'Available'), ('BK003','P.104',6,0,1500000,0.00,'Available'),
('BK003','P.202',6,0,1500000,0.00,'Available'), ('BK003','P.203',6,0,1500000,0.00,'Available'), ('BK003','P.204',6,0,1500000,0.00,'Available'),
('BK003','P.301',6,0,1500000,0.00,'Available'), ('BK003','P.302',6,0,1500000,0.00,'Available'), ('BK003','P.303',6,0,1500000,0.00,'Available'), ('BK003','P.304',6,0,1500000,0.00,'Available'),
('BK003','P.401',6,0,1500000,0.00,'Available'), ('BK003','P.402',6,0,1500000,0.00,'Available'), ('BK003','P.403',6,0,1500000,0.00,'Available'), ('BK003','P.404',6,0,1500000,0.00,'Available');

-- BK004 (NỮ)
INSERT INTO `living_room` (building_id, room_id, max_num_of_students, current_num_of_students, rental_price, occupancy_rate, room_status) VALUES
('BK004','P.101',6,6,1500000,100.00,'Occupied'), -- 6/6
('BK004','P.102',6,3,1500000,50.00,'Available'), -- 3/6
('BK004','P.103',6,0,1500000,0.00,'Available'), ('BK004','P.104',6,0,1500000,0.00,'Available'),
('BK004','P.201',6,0,1500000,0.00,'Available'), ('BK004','P.202',6,0,1500000,0.00,'Available'), ('BK004','P.203',6,0,1500000,0.00,'Available'), ('BK004','P.204',6,0,1500000,0.00,'Available'),
('BK004','P.301',6,0,1500000,0.00,'Available'), ('BK004','P.302',6,0,1500000,0.00,'Available'), ('BK004','P.303',6,0,1500000,0.00,'Available'), ('BK004','P.304',6,0,1500000,0.00,'Available'),
('BK004','P.401',6,0,1500000,0.00,'Available'), ('BK004','P.402',6,0,1500000,0.00,'Available'), ('BK004','P.403',6,0,1500000,0.00,'Available'), ('BK004','P.404',6,0,1500000,0.00,'Available');

-- =========================================================
-- 3. INSERT SINH VIÊN (Bổ sung cột Guardian để sửa lỗi)
-- =========================================================

INSERT INTO `student` (sssn, cccd, first_name, last_name, birthday, sex, ethnic_group, study_status, health_state, student_id, class_name, faculty, building_id, room_id, has_health_insurance, phone_numbers, emails, addresses, guardian_cccd, guardian_name, guardian_relationship, guardian_occupation, guardian_birthday, guardian_phone_numbers, guardian_addresses) VALUES 
-- === PHÂN KHU NAM (BK001, BK002) ===
-- [BK001-P.101] (6/6)
('23126131','012345670001','Khoi Nguyen','Minh','2005-01-01','M','Kinh','Active','Good','2312613','KHMT1','Computer Science','BK001','P.101',1,'0389162347','khoi.nguyen@hcmut.edu.vn','Quang Nam, Tam Dan', '001090000001', 'Nguyen Van A', 'Father', 'Farmer', '1975-01-01', '0901234567', 'Quang Nam'),
('21123472','012345670002','Nam','Nguyen Hao','2003-01-01','M','Kinh','Active','Good','2112347','CNTT2','Information Technology','BK001','P.101',1,'0309238478','nam.nguyen@hcmut.edu.vn','Da Nang, Thanh Khe', '001090000002', 'Nguyen Van B', 'Father', 'Worker', '1976-01-01', '0901234568', 'Da Nang'),
('22123503','012345670003','Phu','Nguyen Quoc','2004-01-01','M','Kinh','Active','Good','2212350','CK1','Mechanical Engineering','BK001','P.101',1,'0320918267','phu.nguyen@hcmut.edu.vn','Quang Ninh, Cau Moi', '001090000003', 'Nguyen Van C', 'Father', 'Teacher', '1977-01-01', '0901234569', 'Quang Ninh'),
('21123524','012345670004','Quan','Vo Anh','2003-01-01','M','Kinh','Active','Good','2112352','D1','Electrical Engineering','BK001','P.101',1,'0320975643','quan.vo@hcmut.edu.vn','Quang Ninh, Quang Trung', '001090000004', 'Vo Van D', 'Father', 'Doctor', '1978-01-01', '0901234570', 'Quang Ninh'),
('23123535','012345670005','Phuoc','Nguyen Thien','2005-01-01','M','Kinh','Active','Good','2312353','D2','Electrical Engineering','BK001','P.101',1,'0399706545','phuoc.nguyen@hcmut.edu.vn','Quang Ninh, Yen Thanh', '001090000005', 'Nguyen Van E', 'Father', 'Engineer', '1979-01-01', '0901234571', 'Quang Ninh'),
('20123566','012345670006','Phat','Vo Tan','2002-01-01','M','Kinh','Active','Good','2012356','XD1','Civil Engineering','BK001','P.101',1,'0328906742','phat.vo@hcmut.edu.vn','Hoa Binh, Dong Tien', '001090000006', 'Vo Van F', 'Father', 'Driver', '1980-01-01', '0901234572', 'Hoa Binh'),

-- [BK001-P.102] (5/6)
('21123597','012345670007','Son','Bui Ngoc','2003-01-01','M','Kinh','Active','Good','2112359','XD2','Civil Engineering','BK001','P.102',1,'0328109200','son.bui@hcmut.edu.vn','Hoa Binh, Mai Chau', '001090000007', 'Bui Van G', 'Father', 'Farmer', '1975-02-01', '0901234573', 'Hoa Binh'),
('23123588','012345670008','Tai','Nguyen Duc','2005-01-01','M','Kinh','Active','Good','2312358','H1','Chemical Engineering','BK001','P.102',1,'0328102980','tai.nguyen@hcmut.edu.vn','Thai Nguyen, Dinh Hoa', '001090000008', 'Nguyen Van H', 'Father', 'Worker', '1976-02-01', '0901234574', 'Thai Nguyen'),
('24123599','012345670009','Tan','Nguyen Nhat','2006-01-01','M','Kinh','Active','Good','2412359','H2','Chemical Engineering','BK001','P.102',1,'0322134783','tan.nguyen@hcmut.edu.vn','Thai Nguyen, Son Cam', '001090000009', 'Nguyen Van I', 'Father', 'Teacher', '1977-02-01', '0901234575', 'Thai Nguyen'),
('22123600','012345670010','Tien','Phan Ngoc','2004-01-01','M','Kinh','Active','Good','2212360','MT1','Environmental Engineering','BK001','P.102',1,'0320975423','tien.phan@hcmut.edu.vn','Hoa Binh, Hoa Binh', '001090000010', 'Phan Van J', 'Father', 'Doctor', '1978-02-01', '0901234576', 'Hoa Binh'),
('20123611','012345670011','Tu','Nguyen Anh','2002-01-01','M','Kinh','Active','Good','2012361','MT2','Environmental Engineering','BK001','P.102',1,'0328100347','tu.nguyen@hcmut.edu.vn','Lang Son, Lang Son', '001090000011', 'Nguyen Van K', 'Father', 'Engineer', '1979-02-01', '0901234577', 'Lang Son'),

-- [BK001-P.103] (3/6)
('21123622','012345670012','Tuong','Nguyen Ngoc','2003-01-01','M','Kinh','Active','Good','2112362','DK1','Control and Automation','BK001','P.103',1,'0326784592','tuong.nguyen@hcmut.edu.vn','Dong Nai, Phu Tan', '001090000012', 'Nguyen Van L', 'Father', 'Driver', '1980-02-01', '0901234578', 'Dong Nai'),
('23123683','012345670013','Vu','Tran Van','2005-01-01','M','Kinh','Active','Good','2312368','VL1','Materials Engineering','BK001','P.103',1,'0739012012','vu.tran@hcmut.edu.vn','Nghe An, Vinh', '001090000013', 'Tran Van M', 'Father', 'Farmer', '1975-03-01', '0901234579', 'Nghe An'),
('24123694','012345670014','Duc','Nguyen Minh','2006-01-01','M','Tay','Active','Good','2412369','VL2','Materials Engineering','BK001','P.103',1,'0928761451','duc.nguyen@hcmut.edu.vn','Nghe An, Nam Dan', '001090000014', 'Nguyen Van N', 'Father', 'Worker', '1976-03-01', '0901234580', 'Nghe An'),

-- [BK001-P.104] (1/6)
('22123705','012345670015','Toan','Bui Duc','2004-01-01','M','Kinh','Active','Good','2212370','SH1','Biotechnology','BK001','P.104',1,'0322934734','toan.bui@hcmut.edu.vn','Nghe An, Thanh Chuong', '001090000015', 'Bui Van O', 'Father', 'Teacher', '1977-03-01', '0901234581', 'Nghe An'),

-- [BK001-P.201] (2/4)
('24123746','012345670016','Truc','Pham Ngoc','2006-01-01','M','Kinh','Active','Good','2412374','KT1','Computer Engineering','BK001','P.201',1,'0328198534','truc.pham@hcmut.edu.vn','Nghe An, Hung Nguyen', '001090000016', 'Pham Van P', 'Father', 'Doctor', '1978-03-01', '0901234582', 'Nghe An'),
('21123827','012345670017','Thuan','Luong Minh','2003-01-01','M','Kinh','Active','Good','2112382','XD3','Civil Engineering','BK001','P.201',1,'0320394754','thuan.luong@hcmut.edu.vn','Hai Phong, Ngo Quyen', '001090000017', 'Luong Van Q', 'Father', 'Engineer', '1979-03-01', '0901234583', 'Hai Phong'),

-- [BK002-P.101] (2/6)
('20123768','012345670018','Dai','Nguyen Van','2002-01-01','M','Kinh','Active','Good','2012376','KHMT3','Computer Science','BK002','P.101',1,'0320293745','dai.nguyen@hcmut.edu.vn','Hung Yen, Van Lam', '001090000018', 'Nguyen Van R', 'Father', 'Driver', '1980-03-01', '0901234584', 'Hung Yen'),
('21123779','012345670019','Khiem','Pham Gia','2003-01-01','M','Kinh','Active','Good','2112377','CNTT3','Information Technology','BK002','P.101',1,'0302348523','khiem.pham@hcmut.edu.vn','Binh Thuan, Phan Thiet', '001090000019', 'Pham Van S', 'Father', 'Farmer', '1975-04-01', '0901234585', 'Binh Thuan'),

-- Các nam còn lại (Xếp vào phòng trống BK002)
('22123800','012345670020','Tuan','Nguyen Quoc','2004-01-01','M','Kinh','Active','Good','2212380','D3','Electrical Engineering','BK002','P.102',1,'0328102409','tuan.nguyen@hcmut.edu.vn','Thua Thien Hue, Huong Thuy', '001090000020', 'Nguyen Van T', 'Father', 'Worker', '1976-04-01', '0901234586', 'Hue'),
('21123721','012345670021','Chi','Pham Minh','2003-01-01','M','Kinh','Active','Good','2112372','PM1','Software Engineering','BK002','P.102',1,'0329235798','chi.pham@hcmut.edu.vn','Thua Thien Hue, Nam Dong', '001090000021', 'Pham Van U', 'Father', 'Teacher', '1977-04-01', '0901234587', 'Hue'),
('23123732','012345670022','Chien','Tran Duc','2005-01-01','M','Kinh','Active','Good','2312373','PM2','Software Engineering','BK002','P.102',1,'0329459838','chien.tran@hcmut.edu.vn','Thua Thien Hue, Huong Tra', '001090000022', 'Tran Van V', 'Father', 'Doctor', '1978-04-01', '0901234588', 'Hue'),
('24124013','012345670023','Hung','Le Van','2006-01-01','M','Kinh','Active','Good','2412401','CK4','Mechanical Engineering','BK002','P.102',1,'0901234561','hung.le@hcmut.edu.vn','TP.HCM, Quan 1', '001090000023', 'Le Van W', 'Father', 'Engineer', '1979-04-01', '0901234589', 'TP.HCM'),
('24124024','012345670024','Dung','Tran Tuan','2006-01-01','M','Kinh','Active','Good','2412402','CK5','Mechanical Engineering','BK002','P.103',1,'0901234562','dung.tran@hcmut.edu.vn','TP.HCM, Quan 3', '001090000024', 'Tran Van X', 'Father', 'Driver', '1980-04-01', '0901234590', 'TP.HCM'),
('24124035','012345670025','Hai','Nguyen Thanh','2006-01-01','M','Kinh','Active','Good','2412403','D4','Electrical Engineering','BK002','P.103',1,'0901234563','hai.nguyen@hcmut.edu.vn','TP.HCM, Thu Duc', '001090000025', 'Nguyen Van Y', 'Father', 'Farmer', '1975-05-01', '0901234591', 'TP.HCM'),
('24124046','012345670026','Binh','Pham Thai','2006-01-01','M','Kinh','Active','Good','2412404','D5','Electrical Engineering','BK002','P.103',1,'0901234564','binh.pham@hcmut.edu.vn','Dong Nai, Bien Hoa', '001090000026', 'Pham Van Z', 'Father', 'Worker', '1976-05-01', '0901234592', 'Dong Nai'),
('24124057','012345670027','Cuong','Do Manh','2006-01-01','M','Kinh','Active','Good','2412405','KT3','Computer Engineering','BK002','P.103',1,'0901234565','cuong.do@hcmut.edu.vn','Binh Duong, Di An', '001090000027', 'Do Van A1', 'Father', 'Teacher', '1977-05-01', '0901234593', 'Binh Duong'),
('24124068','012345670028','Thinh','Bui Gia','2006-01-01','M','Kinh','Active','Good','2412406','KT4','Computer Engineering','BK002','P.104',1,'0901234566','thinh.bui@hcmut.edu.vn','Vung Tau, Chau Duc', '001090000028', 'Bui Van B1', 'Father', 'Doctor', '1978-05-01', '0901234594', 'Vung Tau'),
('24124079','012345670029','Kien','Vu Trung','2006-01-01','M','Kinh','Active','Good','2412407','KHMT4','Computer Science','BK002','P.104',1,'0901234567','kien.vu@hcmut.edu.vn','Khanh Hoa, Nha Trang', '001090000029', 'Vu Van C1', 'Father', 'Engineer', '1979-05-01', '0901234595', 'Khanh Hoa'),
('24124080','012345670030','Dat','Ngo Thanh','2006-01-01','M','Kinh','Active','Good','2412408','KHMT5','Computer Science','BK002','P.104',1,'0901234568','dat.ngo@hcmut.edu.vn','Lam Dong, Da Lat', '001090000030', 'Ngo Van D1', 'Father', 'Driver', '1980-05-01', '0901234596', 'Lam Dong'),
('24124091','012345670031','Hieu','Hoang Minh','2006-01-01','M','Kinh','Active','Good','2412409','CNTT4','Information Technology','BK002','P.104',1,'0901234569','hieu.hoang@hcmut.edu.vn','Dak Lak, Buon Ma Thuot', '001090000031', 'Hoang Van E1', 'Father', 'Farmer', '1975-06-01', '0901234597', 'Dak Lak'),
('24124102','012345670032','Nghia','Dang Trong','2006-01-01','M','Kinh','Active','Good','2412410','CNTT5','Information Technology','BK002','P.201',1,'0901234570','nghia.dang@hcmut.edu.vn','Gia Lai, Pleiku', '001090000032', 'Dang Van F1', 'Father', 'Worker', '1976-06-01', '0901234598', 'Gia Lai'),
('24124113','012345670033','Loi','Phan Tan','2006-01-01','M','Kinh','Active','Good','2412411','XD4','Civil Engineering','BK002','P.201',1,'0901234571','loi.phan@hcmut.edu.vn','Long An, Tan An', '001090000033', 'Phan Van G1', 'Father', 'Teacher', '1977-06-01', '0901234599', 'Long An'),
('24124124','012345670034','Loc','Duong Tan','2006-01-01','M','Kinh','Active','Good','2412412','XD5','Civil Engineering','BK002','P.201',1,'0901234572','loc.duong@hcmut.edu.vn','Tien Giang, My Tho', '001090000034', 'Duong Van H1', 'Father', 'Doctor', '1978-06-01', '0901234600', 'Tien Giang'),
('24124135','012345670035','Phuc','Ta Dinh','2006-01-01','M','Kinh','Active','Good','2412413','MT3','Environmental Engineering','BK002','P.201',1,'0901234573','phuc.ta@hcmut.edu.vn','Ben Tre, Ben Tre', '001090000035', 'Ta Van I1', 'Father', 'Engineer', '1979-06-01', '0901234601', 'Ben Tre'),
('24124146','012345670036','Thang','Cao Quy','2006-01-01','M','Kinh','Active','Good','2412414','MT4','Environmental Engineering','BK002','P.202',1,'0901234574','thang.cao@hcmut.edu.vn','Tra Vinh, Tra Vinh', '001090000036', 'Cao Van J1', 'Father', 'Driver', '1980-06-01', '0901234602', 'Tra Vinh'),
('24124157','012345670037','Vinh','Ly Quoc','2006-01-01','M','Kinh','Active','Good','2412415','H4','Chemical Engineering','BK002','P.202',1,'0901234575','vinh.ly@hcmut.edu.vn','Vinh Long, Vinh Long', '001090000037', 'Ly Van K1', 'Father', 'Farmer', '1975-07-01', '0901234603', 'Vinh Long'),
('24124168','012345670038','Quang','Dinh Nhat','2006-01-01','M','Kinh','Active','Good','2412416','H5','Chemical Engineering','BK002','P.202',1,'0901234576','quang.dinh@hcmut.edu.vn','Dong Thap, Cao Lanh', '001090000038', 'Dinh Van L1', 'Father', 'Worker', '1976-07-01', '0901234604', 'Dong Thap'),
('24124179','012345670039','Truong','Khuong Van','2006-01-01','M','Kinh','Active','Good','2412417','QL3','Industrial Management','BK002','P.202',1,'0901234577','truong.khuong@hcmut.edu.vn','An Giang, Long Xuyen', '001090000039', 'Khuong Van M1', 'Father', 'Teacher', '1977-07-01', '0901234605', 'An Giang'),
('24124180','012345670040','Viet','Quach Hoang','2006-01-01','M','Kinh','Active','Good','2412418','QL4','Industrial Management','BK002','P.203',1,'0901234578','viet.quach@hcmut.edu.vn','Kien Giang, Rach Gia', '001090000040', 'Quach Van N1', 'Father', 'Doctor', '1978-07-01', '0901234606', 'Kien Giang'),
('24124191','012345670041','Tung','Mai Son','2006-01-01','M','Kinh','Active','Good','2412419','VL3','Materials Engineering','BK002','P.203',1,'0901234579','tung.mai@hcmut.edu.vn','Can Tho, Ninh Kieu', '001090000041', 'Mai Van O1', 'Father', 'Engineer', '1979-07-01', '0901234607', 'Can Tho'),
('24124202','012345670042','Khanh','Trinh Duy','2006-01-01','M','Kinh','Active','Good','2412420','VL4','Materials Engineering','BK002','P.203',1,'0901234580','khanh.trinh@hcmut.edu.vn','Soc Trang, Soc Trang', '001090000042', 'Trinh Van P1', 'Father', 'Driver', '1980-07-01', '0901234608', 'Soc Trang'),
('24124213','012345670043','Bao','Lam Quoc','2006-01-01','M','Kinh','Active','Good','2412421','SH3','Biotechnology','BK002','P.203',1,'0901234581','bao.lam@hcmut.edu.vn','Bac Lieu, Bac Lieu', '001090000043', 'Lam Van Q1', 'Father', 'Farmer', '1975-08-01', '0901234609', 'Bac Lieu'),
('24124224','012345670044','An','Ha Thai','2006-01-01','M','Kinh','Active','Good','2412422','SH4','Biotechnology','BK002','P.204',1,'0901234582','an.ha@hcmut.edu.vn','Ca Mau, Ca Mau', '001090000044', 'Ha Van R1', 'Father', 'Worker', '1976-08-01', '0901234610', 'Ca Mau'),
('24124235','012345670045','Thien','Phi Vu','2006-01-01','M','Kinh','Active','Good','2412423','DTVT4','Electronics','BK002','P.204',1,'0901234583','thien.phi@hcmut.edu.vn','Hau Giang, Vi Thanh', '001090000045', 'Phi Van S1', 'Father', 'Teacher', '1977-08-01', '0901234611', 'Hau Giang'),
('24124246','012345670046','Luan','Diep Thanh','2006-01-01','M','Kinh','Active','Good','2412424','DTVT5','Electronics','BK002','P.204',1,'0901234584','luan.diep@hcmut.edu.vn','Tay Ninh, Tay Ninh', '001090000046', 'Diep Van T1', 'Father', 'Doctor', '1978-08-01', '0901234612', 'Tay Ninh'),
('24124257','012345670047','Tam','Tang Minh','2006-01-01','M','Kinh','Active','Good','2412425','HTTT4','Information Security','BK002','P.204',1,'0901234585','tam.tang@hcmut.edu.vn','Binh Phuoc, Dong Xoai', '001090000047', 'Tang Van U1', 'Father', 'Engineer', '1979-08-01', '0901234613', 'Binh Phuoc'),
('24124268','012345670048','Nhan','Kieu Trong','2006-01-01','M','Kinh','Active','Good','2412426','HTTT5','Information Security','BK002','P.301',1,'0901234586','nhan.kieu@hcmut.edu.vn','Ninh Thuan, Phan Rang', '001090000048', 'Kieu Van V1', 'Father', 'Driver', '1980-08-01', '0901234614', 'Ninh Thuan'),
('24124279','012345670049','Tri','La Minh','2006-01-01','M','Kinh','Active','Good','2412427','PM3','Software Engineering','BK002','P.301',1,'0901234587','tri.la@hcmut.edu.vn','Phu Yen, Tuy Hoa', '001090000049', 'La Van W1', 'Father', 'Farmer', '1975-09-01', '0901234615', 'Phu Yen'),
('24124280','012345670050','Triet','Giang Minh','2006-01-01','M','Kinh','Active','Good','2412428','PM4','Software Engineering','BK002','P.301',1,'0901234588','triet.giang@hcmut.edu.vn','Binh Dinh, Quy Nhon', '001090000050', 'Giang Van X1', 'Father', 'Worker', '1976-09-01', '0901234616', 'Binh Dinh'),
('24124291','012345670051','Huy','Ton That','2006-01-01','M','Kinh','Active','Good','2412429','CK6','Mechanical Engineering','BK002','P.301',1,'0901234589','huy.ton@hcmut.edu.vn','Quang Ngai, Quang Ngai', '001090000051', 'Ton Van Y1', 'Father', 'Teacher', '1977-09-01', '0901234617', 'Quang Ngai'),
('24124302','012345670052','Hoang','Ong Cao','2006-01-01','M','Kinh','Active','Good','2412430','D6','Electrical Engineering','BK002','P.301',1,'0901234590','hoang.ong@hcmut.edu.vn','Quang Nam, Hoi An', '001090000052', 'Ong Van Z1', 'Father', 'Doctor', '1978-09-01', '0901234618', 'Quang Nam'),

-- === PHÂN KHU NỮ (BK003, BK004) ===
-- [BK003-P.101] (3/4 - Max 4)
('22123453','012345670053','Mai','Nguyen Phuong','2004-01-01','F','Kinh','Active','Good','2212345','KHMT2','Computer Science','BK003','P.101',1,'0328190284','mai.nguyen@hcmut.edu.vn','Da Nang, Son Tra', '001090000053', 'Nguyen Thi A2', 'Mother', 'Farmer', '1975-10-01', '0901234619', 'Da Nang'),
('20123464','012345670054','Ngoc','Nguyen Minh','2002-01-01','F','Kinh','Active','Good','2012346','CNTT1','Information Technology','BK003','P.101',1,'0323824785','ngoc.nguyen@hcmut.edu.vn','Da Nang, Cam Le', '001090000054', 'Nguyen Thi B2', 'Mother', 'Worker', '1976-10-01', '0901234620', 'Da Nang'),
('23123485','012345670055','Ngan','Pham Kim','2005-01-01','F','Kinh','Active','Good','2312348','DTVT1','Electronics','BK003','P.101',1,'0320245757','ngan.pham@hcmut.edu.vn','Da Nang, Hoa Vang', '001090000055', 'Pham Thi C2', 'Mother', 'Teacher', '1977-10-01', '0901234621', 'Da Nang'),

-- [BK003-P.102] (2/4 - Max 4)
('24123496','012345670056','Phuong','Tran Ngoc','2006-01-01','F','Kinh','Active','Good','2412349','DTVT2','Electronics','BK003','P.102',1,'0329287547','phuong.tran@hcmut.edu.vn','Da Nang, Hoa An', '001090000056', 'Tran Thi D2', 'Mother', 'Doctor', '1978-10-01', '0901234622', 'Da Nang'),
('20123517','012345670057','Phung','Nguyen Minh','2002-01-01','F','Kinh','Active','Good','2012351','CK2','Mechanical Engineering','BK003','P.102',1,'0387326653','phung.nguyen@hcmut.edu.vn','Quang Ninh, Bai Chay', '001090000057', 'Nguyen Thi E2', 'Mother', 'Engineer', '1979-10-01', '0901234623', 'Quang Ninh'),

-- [BK003-P.201] (5/6)
('24123548','012345670058','Quynh','Nguyen Ngoc Diem','2006-01-01','F','Kinh','Active','Good','2412354','HTTT1','Information Security','BK003','P.201',1,'0328100038','quynh.nguyen@hcmut.edu.vn','Quang Ninh, Mong Duong', '001090000058', 'Nguyen Thi F2', 'Mother', 'Driver', '1980-10-01', '0901234624', 'Quang Ninh'),
('22123559','012345670059','Quynh','Nguyen Thi Diem','2004-01-01','F','Kinh','Active','Good','2212355','HTTT2','Information Security','BK003','P.201',1,'0391203470','diem.nguyen@hcmut.edu.vn','Quang Ninh, Uong Bi', '001090000059', 'Nguyen Thi G2', 'Mother', 'Farmer', '1975-11-01', '0901234625', 'Quang Ninh'),
('23123630','012345670060','Thao','Nguyen Ngoc Thanh','2005-01-01','F','Kinh','Active','Good','2312363','DK2','Control and Automation','BK003','P.201',1,'0326735204','thao.nguyen@hcmut.edu.vn','Bac Giang, Bac Giang', '001090000060', 'Nguyen Thi H2', 'Mother', 'Worker', '1976-11-01', '0901234626', 'Bac Giang'),
('24123641','012345670061','Thu','Nguyen Ngoc Minh','2006-01-01','F','Kinh','Active','Good','2412364','QL1','Industrial Management','BK003','P.201',1,'0327843792','thu.nguyen@hcmut.edu.vn','Phu Yen, Tuy An', '001090000061', 'Nguyen Thi I2', 'Mother', 'Teacher', '1977-11-01', '0901234627', 'Phu Yen'),
('22123652','012345670062','Thuy','Nguyen Thi Thanh','2004-01-01','F','Kinh','Active','Good','2212365','QL2','Industrial Management','BK003','P.201',1,'0328129343','thuy.nguyen@hcmut.edu.vn','Ha Nam, Phu Ly', '001090000062', 'Nguyen Thi J2', 'Mother', 'Doctor', '1978-11-01', '0901234628', 'Ha Nam'),

-- [BK004-P.101] (6/6 Full)
('20123663','012345670063','Uyen','Nguyen Ngoc','2002-01-01','F','Kinh','Active','Good','2012366','SCM1','Logistics','BK004','P.101',1,'0393280450','uyen.nguyen@hcmut.edu.vn','Ha Tinh, Duc Tho', '001090000063', 'Nguyen Thi K2', 'Mother', 'Engineer', '1979-11-01', '0901234629', 'Ha Tinh'),
('21123674','012345670064','Vy','Nguyen Tuong','2003-01-01','F','Kinh','Active','Good','2112367','SCM2','Logistics','BK004','P.101',1,'0924723455','vy.nguyen@hcmut.edu.vn','Nghe An, Quynh Luu', '001090000064', 'Nguyen Thi L2', 'Mother', 'Driver', '1980-11-01', '0901234630', 'Nghe An'),
('20123715','012345670065','Tram','Nguyen Thuy','2002-01-01','F','Kinh','Active','Good','2012371','SH2','Biotechnology','BK004','P.101',1,'0329235483','tram.nguyen@hcmut.edu.vn','Nghe An, Cua Lo', '001090000065', 'Nguyen Thi M2', 'Mother', 'Farmer', '1975-12-01', '0901234631', 'Nghe An'),
('22123756','012345670066','Hau','Nguyen Phuc','2004-01-01','F','Kinh','Active','Good','2212375','KT2','Computer Engineering','BK004','P.101',1,'0327684529','hau.nguyen@hcmut.edu.vn','Hai Phong, Kien Thuy', '001090000066', 'Nguyen Thi N2', 'Mother', 'Worker', '1976-12-01', '0901234632', 'Hai Phong'),
('23123837','012345670067','Nhi','Nguyen Ngoc Thuy','2005-01-01','F','Kinh','Active','Good','2312383','H3','Chemical Engineering','BK004','P.101',1,'0309237432','nhi.nguyen@hcmut.edu.vn','Hai Phong, An Lao', '001090000067', 'Nguyen Thi O2', 'Mother', 'Teacher', '1977-12-01', '0901234633', 'Hai Phong'),
('23123788','012345670068','Tran','Nguyen Ngoc Thao','2005-01-01','F','Kinh','Active','Good','2312378','DTVT3','Electronics','BK004','P.101',1,'0920975343','tran.nguyen@hcmut.edu.vn','Binh Thuan, Tan Nghia', '001090000068', 'Nguyen Thi P2', 'Mother', 'Doctor', '1978-12-01', '0901234634', 'Binh Thuan'),

-- [BK004-P.102] (3/6)
('24123799','012345670069','Tien','Nguyen Thuy','2006-01-01','F','Kinh','Active','Good','2412379','CK3','Mechanical Engineering','BK004','P.102',1,'0322934523','tien.nguyen@hcmut.edu.vn','Quang Tri, Dong Ha', '001090000069', 'Nguyen Thi Q2', 'Mother', 'Engineer', '1979-12-01', '0901234635', 'Quang Tri'),
('20123810','012345670070','Chi','Bui Ngoc Kim','2002-01-01','F','Hoa','Active','Good','2012381','HTTT3','Information Security','BK004','P.102',1,'0328724234','chi.bui@hcmut.edu.vn','Thua Thien Hue, Phu Bai', '001090000070', 'Bui Thi R2', 'Mother', 'Driver', '1980-12-01', '0901234636', 'Hue'),
('24124311','012345670071','Lan','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412431','KT6','Computer Engineering','BK004','P.102',1,'0901234591','lan.nguyen@hcmut.edu.vn','Thua Thien Hue, Hue', '001090000071', 'Nguyen Thi S2', 'Mother', 'Farmer', '1975-01-01', '0901234637', 'Hue'),

-- Các nữ còn lại (Xếp vào phòng trống BK004)
('24124322','012345670072','Mai','Le Thi','2006-01-01','F','Kinh','Active','Good','2412432','KT7','Computer Engineering','BK004','P.103',1,'0901234592','mai.le@hcmut.edu.vn','Da Nang, Hai Chau', '001090000072', 'Le Thi T2', 'Mother', 'Worker', '1976-01-01', '0901234638', 'Da Nang'),
('24124333','012345670073','Cuc','Pham Thi','2006-01-01','F','Kinh','Active','Good','2412433','KT8','Computer Engineering','BK004','P.103',1,'0901234593','cuc.pham@hcmut.edu.vn','Quang Nam, Hoi An', '001090000073', 'Pham Thi U2', 'Mother', 'Teacher', '1977-01-01', '0901234639', 'Quang Nam'),
('24124344','012345670074','Dao','Tran Thi','2006-01-01','F','Kinh','Active','Good','2412434','KT9','Computer Engineering','BK004','P.103',1,'0901234594','dao.tran@hcmut.edu.vn','Quang Ngai, Son Tinh', '001090000074', 'Tran Thi V2', 'Mother', 'Doctor', '1978-01-01', '0901234640', 'Quang Ngai'),
('24124355','012345670075','Hong','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412435','KT10','Computer Engineering','BK004','P.103',1,'0901234595','hong.nguyen@hcmut.edu.vn','Binh Dinh, Quy Nhon', '001090000075', 'Nguyen Thi W2', 'Mother', 'Engineer', '1979-01-01', '0901234641', 'Binh Dinh'),
('24124366','012345670076','Hue','Le Thi','2006-01-01','F','Kinh','Active','Good','2412436','KT11','Computer Engineering','BK004','P.104',1,'0901234596','hue.le@hcmut.edu.vn','Phu Yen, Tuy Hoa', '001090000076', 'Le Thi X2', 'Mother', 'Driver', '1980-01-01', '0901234642', 'Phu Yen'),
('24124377','012345670077','Thuy','Pham Thi','2006-01-01','F','Kinh','Active','Good','2412437','SH5','Biotechnology','BK004','P.104',1,'0901234597','thuy.pham@hcmut.edu.vn','Khanh Hoa, Nha Trang', '001090000077', 'Pham Thi Y2', 'Mother', 'Farmer', '1975-02-01', '0901234643', 'Khanh Hoa'),
('24124388','012345670078','Trang','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412438','SH6','Biotechnology','BK004','P.104',1,'0901234598','trang.nguyen@hcmut.edu.vn','Ninh Thuan, Phan Rang', '001090000078', 'Nguyen Thi Z2', 'Mother', 'Worker', '1976-02-01', '0901234644', 'Ninh Thuan'),
('24124399','012345670079','Nhung','Le Thi','2006-01-01','F','Kinh','Active','Good','2412439','SH7','Biotechnology','BK004','P.104',1,'0901234599','nhung.le@hcmut.edu.vn','Binh Thuan, Phan Thiet', '001090000079', 'Le Thi A3', 'Mother', 'Teacher', '1977-02-01', '0901234645', 'Binh Thuan'),
('24124400','012345670080','Tuyet','Tran Thi','2006-01-01','F','Kinh','Active','Good','2412440','SH8','Biotechnology','BK004','P.201',1,'0901234600','tuyet.tran@hcmut.edu.vn','Kon Tum, Kon Tum', '001090000080', 'Tran Thi B3', 'Mother', 'Doctor', '1978-02-01', '0901234646', 'Kon Tum'),
('24124411','012345670081','Hoa','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412441','SH9','Biotechnology','BK004','P.201',1,'0901234601','hoa.nguyen@hcmut.edu.vn','Gia Lai, Pleiku', '001090000081', 'Nguyen Thi C3', 'Mother', 'Engineer', '1979-02-01', '0901234647', 'Gia Lai'),
('24124422','012345670082','Lien','Le Thi','2006-01-01','F','Kinh','Active','Good','2412442','SH10','Biotechnology','BK004','P.201',1,'0901234602','lien.le@hcmut.edu.vn','Dak Lak, Buon Ma Thuot', '001090000082', 'Le Thi D3', 'Mother', 'Driver', '1980-02-01', '0901234648', 'Dak Lak'),
('24124433','012345670083','Huong','Pham Thi','2006-01-01','F','Kinh','Active','Good','2412443','MT5','Environmental','BK004','P.201',1,'0901234603','huong.pham@hcmut.edu.vn','Dak Nong, Gia Nghia', '001090000083', 'Pham Thi E3', 'Mother', 'Farmer', '1975-03-01', '0901234649', 'Dak Nong'),
('24124444','012345670084','Thanh','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412444','MT6','Environmental','BK004','P.202',1,'0901234604','thanh.nguyen@hcmut.edu.vn','Lam Dong, Da Lat', '001090000084', 'Nguyen Thi F3', 'Mother', 'Worker', '1976-03-01', '0901234650', 'Lam Dong'),
('24124455','012345670085','Hanh','Le Thi','2006-01-01','F','Kinh','Active','Good','2412445','MT7','Environmental','BK004','P.202',1,'0901234605','hanh.le@hcmut.edu.vn','Binh Phuoc, Dong Xoai', '001090000085', 'Le Thi G3', 'Mother', 'Teacher', '1977-03-01', '0901234651', 'Binh Phuoc'),
('24124466','012345670086','Thao','Tran Thi','2006-01-01','F','Kinh','Active','Good','2412446','MT8','Environmental','BK004','P.202',1,'0901234606','thao.tran@hcmut.edu.vn','Tay Ninh, Tay Ninh', '001090000086', 'Tran Thi H3', 'Mother', 'Doctor', '1978-03-01', '0901234652', 'Tay Ninh'),
('24124477','012345670087','Hien','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412447','MT9','Environmental','BK004','P.202',1,'0901234607','hien.nguyen@hcmut.edu.vn','Binh Duong, Thu Dau Mot', '001090000087', 'Nguyen Thi I3', 'Mother', 'Engineer', '1979-03-01', '0901234653', 'Binh Duong'),
('24124488','012345670088','Thu','Le Thi','2006-01-01','F','Kinh','Active','Good','2412448','MT10','Environmental','BK004','P.203',1,'0901234608','thu.le@hcmut.edu.vn','Dong Nai, Long Khanh', '001090000088', 'Le Thi J3', 'Mother', 'Driver', '1980-03-01', '0901234654', 'Dong Nai'),
('24124499','012345670089','Dung','Pham Thi','2006-01-01','F','Kinh','Active','Good','2412449','H6','Chemical','BK004','P.203',1,'0901234609','dung.pham@hcmut.edu.vn','Ba Ria - Vung Tau, Vung Tau', '001090000089', 'Pham Thi K3', 'Mother', 'Farmer', '1975-04-01', '0901234655', 'Ba Ria'),
('24124500','012345670090','Yen','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412450','H7','Chemical','BK004','P.203',1,'0901234610','yen.nguyen@hcmut.edu.vn','TP.HCM, Quan 5', '001090000090', 'Nguyen Thi L3', 'Mother', 'Worker', '1976-04-01', '0901234656', 'TP.HCM'),
('24124511','012345670091','Loan','Le Thi','2006-01-01','F','Kinh','Active','Good','2412451','H8','Chemical','BK004','P.203',1,'0901234611','loan.le@hcmut.edu.vn','Long An, Ben Luc', '001090000091', 'Le Thi M3', 'Mother', 'Teacher', '1977-04-01', '0901234657', 'Long An'),
('24124522','012345670092','Diep','Tran Thi','2006-01-01','F','Kinh','Active','Good','2412452','H9','Chemical','BK004','P.204',1,'0901234612','diep.tran@hcmut.edu.vn','Tien Giang, Cai Be', '001090000092', 'Tran Thi N3', 'Mother', 'Doctor', '1978-04-01', '0901234658', 'Tien Giang'),
('24124533','012345670093','Nga','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412453','H10','Chemical','BK004','P.204',1,'0901234613','nga.nguyen@hcmut.edu.vn','Ben Tre, Mo Cay', '001090000093', 'Nguyen Thi O3', 'Mother', 'Engineer', '1979-04-01', '0901234659', 'Ben Tre'),
('24124544','012345670094','Phuong','Le Thi','2006-01-01','F','Kinh','Active','Good','2412454','H11','Chemical','BK004','P.204',1,'0901234614','phuong.le@hcmut.edu.vn','Tra Vinh, Tra Vinh', '001090000094', 'Le Thi P3', 'Mother', 'Driver', '1980-04-01', '0901234660', 'Tra Vinh'),
('24124555','012345670095','Anh','Pham Thi','2006-01-01','F','Kinh','Active','Good','2412455','QL5','Management','BK004','P.204',1,'0901234615','anh.pham@hcmut.edu.vn','Vinh Long, Vung Liem', '001090000095', 'Pham Thi Q3', 'Mother', 'Farmer', '1975-05-01', '0901234661', 'Vinh Long'),
('24124566','012345670096','Kim','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412456','QL6','Management','BK004','P.301',1,'0901234616','kim.nguyen@hcmut.edu.vn','Dong Thap, Sa Dec', '001090000096', 'Nguyen Thi R3', 'Mother', 'Worker', '1976-05-01', '0901234662', 'Dong Thap'),
('24124577','012345670097','Chau','Le Thi','2006-01-01','F','Kinh','Active','Good','2412457','QL7','Management','BK004','P.301',1,'0901234617','chau.le@hcmut.edu.vn','An Giang, Chau Doc', '001090000097', 'Le Thi S3', 'Mother', 'Teacher', '1977-05-01', '0901234663', 'An Giang'),
('24124588','012345670098','Nguyet','Tran Thi','2006-01-01','F','Kinh','Active','Good','2412458','QL8','Management','BK004','P.301',1,'0901234618','nguyet.tran@hcmut.edu.vn','Kien Giang, Ha Tien', '001090000098', 'Tran Thi T3', 'Mother', 'Doctor', '1978-05-01', '0901234664', 'Kien Giang'),
('24124599','012345670099','Tuyen','Nguyen Thi','2006-01-01','F','Kinh','Active','Good','2412459','QL9','Management','BK004','P.301',1,'0901234619','tuyen.nguyen@hcmut.edu.vn','Can Tho, Cai Rang', '001090000099', 'Nguyen Thi U3', 'Mother', 'Engineer', '1979-05-01', '0901234665', 'Can Tho'),
('24124600','012345670100','Thoa','Le Thi','2006-01-01','F','Kinh','Active','Good','2412460','QL10','Management','BK004','P.301',1,'0901234620','thoa.le@hcmut.edu.vn','Hau Giang, Nga Bay', '001090000100', 'Le Thi V3', 'Mother', 'Driver', '1980-05-01', '0901234666', 'Hau Giang');

-- =========================================================
-- 4. INSERT THẺ & KỶ LUẬT
-- =========================================================

-- Insert Dormitory Card (Cần có sau khi có Student)
INSERT INTO `dormitory_card` (number, start_date, end_date, id_card, validity)
SELECT CONCAT('CD', sssn), CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), sssn, 1 FROM student;

INSERT INTO `disciplinary_action` (action_id, action_type, reason, decision_date, effective_from, effective_to, severity_level, status) VALUES
('DA001', 'Cleaning Duty', 'Violation of quiet hours', '2025-01-10', '2025-01-11', '2025-01-18', 'low', 'completed'),
('DA002', 'Warning', 'Late return after curfew', '2025-01-15', '2025-01-15', NULL, 'low', 'active'),
('DA003', 'Cleaning Duty', 'Littering in public area', '2025-01-20', '2025-01-21', '2025-01-28', 'low', 'completed'),
('DA004', 'Warning', 'Improper parking', '2025-02-05', '2025-02-05', NULL, 'low', 'active'),
('DA005', 'Cleaning Duty', 'Room cleanliness check fail', '2025-02-12', '2025-02-13', '2025-02-20', 'low', 'completed'),
('DA006', 'Warning', 'Noise violation', '2025-02-25', '2025-02-25', NULL, 'low', 'active'),
('DA007', 'Cleaning Duty', 'Unauthorized furniture moving', '2025-03-01', '2025-03-02', '2025-03-09', 'low', 'active'),
('DA008', 'Warning', 'Late payment of utility fees', '2025-03-10', '2025-03-10', NULL, 'low', 'active'),
('DA009', 'Cleaning Duty', 'Pet policy violation (small pet)', '2025-03-15', '2025-03-16', '2025-03-23', 'low', 'completed'),
('DA010', 'Warning', 'Forgot ID card multiple times', '2025-03-20', '2025-03-20', NULL, 'low', 'active'),
('DA011', 'Community Service', 'Unauthorized guest overnight', '2025-04-05', '2025-04-06', '2025-05-06', 'medium', 'active'),
('DA012', 'Community Service', 'Cooking in non-designated area', '2025-04-12', '2025-04-13', '2025-05-13', 'medium', 'pending'),
('DA013', 'Community Service', 'Disrespectful behavior to staff', '2025-04-20', '2025-04-21', '2025-05-21', 'medium', 'active'),
('DA014', 'Community Service', 'Damaging public property (minor)', '2025-05-01', '2025-05-02', '2025-06-02', 'medium', 'active'),
('DA015', 'Community Service', 'Using prohibited electrical appliances', '2025-05-15', '2025-05-16', '2025-06-16', 'medium', 'pending'),
('DA016', 'Community Service', 'Alcohol possession', '2025-06-01', '2025-06-02', '2025-07-02', 'medium', 'active'),
('DA017', 'Community Service', 'Smoking in corridor', '2025-06-10', '2025-06-11', '2025-07-11', 'medium', 'active'),
('DA018', 'Community Service', 'Gambling (minor)', '2025-06-25', '2025-06-26', '2025-07-26', 'medium', 'active'),
('DA019', 'Community Service', 'Climbing over fence', '2025-07-05', '2025-07-06', '2025-08-06', 'medium', 'active'),
('DA020', 'Community Service', 'Tampering with fire equipment', '2025-07-20', '2025-07-21', '2025-08-21', 'medium', 'active'),
('DA021', 'Suspension', 'Physical altercation (Fighting)', '2025-08-01', '2025-08-02', '2025-09-02', 'high', 'active'),
('DA022', 'Suspension', 'Theft', '2025-08-15', '2025-08-16', '2025-09-16', 'high', 'pending'),
('DA023', 'Community Service', 'Vandalism', '2025-09-01', '2025-09-02', '2025-10-02', 'high', 'active'),
('DA024', 'Warning', 'Curfew violation (repeated)', '2025-09-10', '2025-09-10', NULL, 'medium', 'active'),
('DA025', 'Cleaning Duty', 'Hygiene violation', '2025-09-20', '2025-09-21', '2025-09-28', 'low', 'completed'),
('DA026', 'Community Service', 'Hosting party late night', '2025-10-05', '2025-10-06', '2025-11-06', 'medium', 'active'),
('DA027', 'Warning', 'Verbal abuse', '2025-10-15', '2025-10-15', NULL, 'medium', 'active'),
('DA028', 'Suspension', 'Substance abuse', '2025-11-01', '2025-11-02', '2025-12-02', 'high', 'active'),
('DA029', 'Cleaning Duty', 'Littering', '2025-11-10', '2025-11-11', '2025-11-18', 'low', 'completed'),
('DA030', 'Warning', 'Noise violation', '2025-12-01', '2025-12-01', NULL, 'low', 'active');

-- Gán Kỷ luật (Sử dụng đúng StudentID trong dữ liệu gốc)
INSERT INTO `student_discipline` (action_id, student_id) VALUES
('DA001', '2312613'), ('DA002', '2112347'), ('DA003', '2212350'), ('DA004', '2112352'), ('DA005', '2312353'),
('DA006', '2012356'), ('DA007', '2112359'), ('DA008', '2312358'), ('DA009', '2412359'), ('DA010', '2212360'),
('DA011', '2012361'), ('DA012', '2112362'), ('DA013', '2312368'), ('DA014', '2412369'), ('DA015', '2212370'),
('DA016', '2412374'), ('DA017', '2112382'), ('DA018', '2012376'), ('DA019', '2112377'), ('DA020', '2212380'),
('DA021', '2112372'), ('DA022', '2312373'), ('DA023', '2412401'), ('DA024', '2412402'), ('DA025', '2412403'),
('DA026', '2412404'), ('DA027', '2412405'), ('DA028', '2412406'), ('DA029', '2412407'), ('DA030', '2412408');

-- =========================================================
-- 5. STORED PROCEDURES (GIỮ NGUYÊN)
-- =========================================================

DELIMITER ;;
CREATE  FUNCTION `check_user_exists`(p_user_name VARCHAR(50)) RETURNS TINYINT
    DETERMINISTIC
BEGIN
    DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count FROM manager_dorm WHERE user_name = p_user_name;
    RETURN user_count > 0;
END ;;

CREATE  FUNCTION `num_validity_dormitory_card`() RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE num INT;
    SELECT COUNT(*) INTO num FROM dormitory_card WHERE Validity = 1;
    RETURN num;
END ;;

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

CREATE PROCEDURE `create_dormitory_card`(IN p_sssn CHAR(8))
BEGIN
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists FROM student WHERE sssn = p_sssn;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student not found.';
    ELSE
        INSERT INTO dormitory_card (number, start_date, end_date, id_card, validity)
        VALUES (
            CONCAT('CD', LPAD(FLOOR(RAND() * 1000000), 5, '0')), 
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 1 YEAR),
            p_sssn, 1          
        );
    END IF;
END ;;

CREATE  PROCEDURE `delete_contact_info`(IN p_ssn CHAR(8))
BEGIN
    DELETE FROM address WHERE sssn = p_ssn;
    DELETE FROM phone_number WHERE sssn = p_ssn;
    DELETE FROM email WHERE sssn = p_ssn;
END ;;

CREATE  PROCEDURE `delete_student_by_sssn`(IN p_sssn CHAR(8))
BEGIN
  DECLARE v_count INT DEFAULT 0;
  DECLARE v_building CHAR(5) DEFAULT NULL;
  DECLARE v_room CHAR(5) DEFAULT NULL;
  DECLARE v_max INT DEFAULT NULL;
  DECLARE v_curr INT DEFAULT NULL;

  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 @err_no = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
    ROLLBACK;
  END;

  START TRANSACTION;
  SELECT COUNT(*) INTO v_count FROM student WHERE sssn = p_sssn;
  IF v_count = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student with this SSSN does not exist.';
  END IF;

  SELECT building_id, room_id INTO v_building, v_room FROM student WHERE sssn = p_sssn;

  IF v_building IS NOT NULL AND v_room IS NOT NULL THEN
    SELECT max_num_of_students, current_num_of_students INTO v_max, v_curr
    FROM living_room WHERE building_id = v_building AND room_id = v_room;

    UPDATE living_room
    SET current_num_of_students = GREATEST(current_num_of_students - 1, 0),
        occupancy_rate = CASE WHEN max_num_of_students > 0 THEN ROUND((GREATEST(current_num_of_students - 1, 0) / max_num_of_students) * 100, 2) ELSE 0 END
    WHERE building_id = v_building AND room_id = v_room;
  END IF;

  UPDATE dormitory_card SET validity = FALSE WHERE id_card = p_sssn;
  
  BEGIN
    DECLARE table_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO table_exists FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'relative';
    IF table_exists > 0 THEN DELETE FROM relative WHERE sssn = p_sssn; END IF;
  END;

  DELETE FROM student WHERE sssn = p_sssn;
  COMMIT;
END ;;

CREATE  PROCEDURE `get_all_students`()
BEGIN
    SELECT sssn, first_name, last_name, birthday, sex, ethnic_group, study_status, health_state, student_id, class_name, faculty, building_id, room_id FROM student;
END ;;

CREATE  PROCEDURE `get_manager_dorm_by_username`(IN p_user_name VARCHAR(255))
BEGIN
    SELECT * FROM manager_dorm WHERE user_name = p_user_name;
END ;;

CREATE  PROCEDURE `get_paginated_students`(IN p_page INT, IN p_limit INT)
BEGIN
  DECLARE v_offset INT;
  SET v_offset = (p_page - 1) * p_limit;
  SELECT * FROM student ORDER BY sssn LIMIT p_limit OFFSET v_offset;
  SELECT COUNT(*) AS total FROM student;
END ;;

CREATE  PROCEDURE `get_student`()
BEGIN
  SELECT s.sssn AS cccd, s.student_id, s.first_name, s.last_name, s.birthday, s.sex, s.health_state, s.ethnic_group, s.study_status, s.class_name, s.faculty, s.building_id, s.room_id,
    GROUP_CONCAT(DISTINCT ph.phone_number SEPARATOR '; ') AS phone_numbers,
    GROUP_CONCAT(DISTINCT CONCAT_WS(', ', a.commune, a.province) SEPARATOR '; ') AS addresses,
    GROUP_CONCAT(DISTINCT e.email SEPARATOR '; ') AS emails
  FROM student s
  JOIN dormitory_card dc ON dc.id_card = s.sssn AND dc.validity = TRUE
  LEFT JOIN phone_number ph ON s.sssn = ph.sssn
  LEFT JOIN address a ON s.sssn = a.sssn
  LEFT JOIN email e ON s.sssn = e.sssn
  GROUP BY s.sssn, s.student_id, s.first_name, s.last_name, s.birthday, s.sex, s.health_state, s.ethnic_group, s.study_status, s.class_name, s.faculty, s.building_id, s.room_id;
END ;;

CREATE  PROCEDURE `get_student_by_sssn`(IN p_sssn CHAR(8))
BEGIN
    IF LENGTH(REPLACE(TRIM(p_sssn), ' ', '')) != 8 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSSN must be exactly 8 characters long.'; END IF;
    SELECT s.*, GROUP_CONCAT(DISTINCT ph.phone_number SEPARATOR ';') AS phone_numbers, GROUP_CONCAT(DISTINCT CONCAT_WS(', ', a.commune, a.province) SEPARATOR ';') AS addresses, GROUP_CONCAT(DISTINCT e.email SEPARATOR ';') AS emails
    FROM student s LEFT JOIN phone_number ph ON s.sssn = ph.sssn LEFT JOIN address a ON s.sssn = a.sssn LEFT JOIN email e ON s.sssn = e.sssn WHERE s.sssn = p_sssn GROUP BY s.sssn;
    SELECT r.guardian_cccd AS guardian_cccd, r.fname AS guardian_first_name, r.lname AS guardian_last_name, CONCAT(r.fname, ' ', r.lname) AS guardian_name, r.relationship AS guardian_relationship, r.birthday AS guardian_birthday, r.phone_number AS guardian_phone_numbers, r.address AS guardian_addresses, r.job AS guardian_occupation FROM relative r WHERE r.sssn = p_sssn;
END ;;

CREATE  PROCEDURE `get_violation_statistics_by_type`(IN min_count INT)
BEGIN
    SELECT reason, COUNT(*) AS violation_count FROM student_discipline sd JOIN disciplinary_action da ON sd.action_id = da.action_id GROUP BY reason HAVING COUNT(*) >= min_count ORDER BY violation_count DESC;
END ;;

CREATE  PROCEDURE `insert_addresses`(IN p_ssn CHAR(8), IN p_addresses TEXT)
BEGIN
    -- (Giữ nguyên logic của bạn, rút gọn để hiển thị)
    DECLARE addr_index INT DEFAULT 1; DECLARE addr_item VARCHAR(255); DECLARE commune VARCHAR(30); DECLARE province VARCHAR(30); DECLARE num INT DEFAULT 0; DECLARE comma_count INT;
	IF p_addresses IS NOT NULL AND p_addresses != '' THEN
        SET num = LENGTH(p_addresses) - LENGTH(REPLACE(p_addresses, ';', '')) + 1;
        WHILE addr_index <= num DO
            SET addr_item = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_addresses, ';', addr_index), ';', -1));
            IF addr_item != '' THEN
                SET comma_count = LENGTH(addr_item) - LENGTH(REPLACE(addr_item, ',', ''));
                IF comma_count = 2 THEN SET commune = TRIM(SUBSTRING_INDEX(addr_item, ',', 1)); SET province = TRIM(SUBSTRING_INDEX(addr_item, ',', -1));
                ELSEIF comma_count = 1 THEN SET commune = TRIM(SUBSTRING_INDEX(addr_item, ',', 1)); SET province = '';
                ELSE SET commune = TRIM(addr_item); SET province = ''; END IF;
                IF NOT EXISTS (SELECT 1 FROM address A WHERE A.sssn = p_ssn AND TRIM(LOWER(A.commune)) = TRIM(LOWER(commune)) AND TRIM(LOWER(A.province)) = TRIM(LOWER(province))) THEN
                    INSERT INTO address (sssn, commune, province) VALUES (p_ssn, commune, province);
                END IF;
            END IF;
            SET addr_index = addr_index + 1;
        END WHILE;
    END IF;
END ;;

CREATE  PROCEDURE `insert_emails`(IN p_ssn CHAR(8), IN p_emails TEXT)
BEGIN
    DECLARE email_index INT DEFAULT 1; DECLARE email_item VARCHAR(50); DECLARE num INT DEFAULT 0;
	IF p_emails IS NOT NULL AND p_emails != '' THEN
        SET num = LENGTH(p_emails) - LENGTH(REPLACE(p_emails, ';', '')) + 1;
        WHILE email_index <= num DO
            SET email_item = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_emails, ';', email_index), ';', -1));
            IF email_item != '' AND NOT EXISTS (SELECT 1 FROM email WHERE sssn = p_ssn AND email = email_item) THEN
                INSERT INTO email (sssn, email) VALUES (p_ssn, email_item);
            END IF;
            SET email_index = email_index + 1;
        END WHILE;
    END IF;
END ;;

CREATE  PROCEDURE `insert_manager_dorm`(IN p_user_name VARCHAR(50), IN p_password VARCHAR(255))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM manager_dorm WHERE user_name = p_user_name) THEN INSERT INTO manager_dorm (user_name, password) VALUES (p_user_name, p_password); END IF;
END ;;

CREATE  PROCEDURE `insert_phone_numbers`(IN p_ssn CHAR(8), IN p_phone_numbers TEXT)
BEGIN
    DECLARE phone_index INT DEFAULT 1; DECLARE phone_item CHAR(10); DECLARE num INT DEFAULT 0;
	IF p_phone_numbers IS NOT NULL AND p_phone_numbers != '' THEN
        SET num = LENGTH(p_phone_numbers) - LENGTH(REPLACE(p_phone_numbers, ';', '')) + 1;
        WHILE phone_index <= num DO
            SET phone_item = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_phone_numbers, ';', phone_index), ';', -1));
            IF phone_item != '' AND NOT EXISTS (SELECT 1 FROM phone_number WHERE sssn = p_ssn AND phone_number = phone_item) THEN
                INSERT INTO phone_number (sssn, phone_number) VALUES (p_ssn, phone_item);
            END IF;
            SET phone_index = phone_index + 1;
        END WHILE;
    END IF;
END ;;

CREATE  PROCEDURE `insert_student`(IN p_sssn CHAR(8), IN p_cccd CHAR(12), IN p_first_name VARCHAR(20), IN p_last_name VARCHAR(20), IN p_birthday DATE, IN p_sex CHAR(1), IN p_ethnic_group VARCHAR(30), IN p_health_state VARCHAR(100), IN p_student_id CHAR(12), IN p_study_status VARCHAR(20), IN p_class_name VARCHAR(30), IN p_faculty VARCHAR(50), IN p_building_id CHAR(5), IN p_room_id CHAR(5), IN p_phone_numbers TEXT, IN p_emails TEXT, IN p_addresses TEXT, IN p_guardian_cccd CHAR(12), IN p_guardian_name VARCHAR(50), IN p_guardian_relationship VARCHAR(20), IN p_guardian_occupation VARCHAR(50), IN p_guardian_birthday DATE, IN p_guardian_phone_numbers TEXT, IN p_guardian_addresses TEXT)
BEGIN
    INSERT INTO student (sssn, cccd, first_name, last_name, birthday, sex, ethnic_group, health_state, student_id, study_status, class_name, faculty, building_id, room_id, phone_numbers, emails, addresses, guardian_cccd, guardian_name, guardian_relationship, guardian_occupation, guardian_birthday, guardian_phone_numbers, guardian_addresses)
    VALUES (p_sssn, p_cccd, p_first_name, p_last_name, p_birthday, p_sex, p_ethnic_group, p_health_state, p_student_id, p_study_status, p_class_name, p_faculty, p_building_id, p_room_id, p_phone_numbers, p_emails, p_addresses, p_guardian_cccd, p_guardian_name, p_guardian_relationship, p_guardian_occupation, p_guardian_birthday, p_guardian_phone_numbers, p_guardian_addresses);
END ;;

CREATE  PROCEDURE `update_guardian_info`(IN p_sssn CHAR(8), IN p_guardian_cccd CHAR(12), IN p_guardian_name VARCHAR(100), IN p_guardian_relationship VARCHAR(50), IN p_guardian_occupation VARCHAR(50), IN p_guardian_birthday DATE, IN p_guardian_phone_numbers VARCHAR(200), IN p_guardian_addresses VARCHAR(500))
BEGIN
    UPDATE student SET guardian_cccd = p_guardian_cccd, guardian_name = p_guardian_name, guardian_relationship = p_guardian_relationship, guardian_occupation = p_guardian_occupation, guardian_birthday = p_guardian_birthday, guardian_phone_numbers = p_guardian_phone_numbers, guardian_addresses = p_guardian_addresses WHERE sssn = p_sssn;
END ;;

CREATE  PROCEDURE `update_relative_by_sssn`(IN p_sssn CHAR(8), IN p_guardian_cccd CHAR(12), IN p_fname VARCHAR(20), IN p_lname VARCHAR(20), IN p_birthday DATE, IN p_relationship VARCHAR(50), IN p_address VARCHAR(255), IN p_phone_number VARCHAR(100), IN p_job VARCHAR(50))
BEGIN
    IF EXISTS (SELECT 1 FROM relative WHERE sssn = p_sssn) THEN
        UPDATE relative SET guardian_cccd = p_guardian_cccd, fname = p_fname, lname = p_lname, birthday = p_birthday, relationship = p_relationship, address = p_address, phone_number = p_phone_number, job = p_job WHERE sssn = p_sssn;
    ELSE
        INSERT INTO relative (sssn, guardian_cccd, fname, lname, birthday, relationship, address, phone_number, job) VALUES (p_sssn, p_guardian_cccd, p_fname, p_lname, p_birthday, p_relationship, p_address, p_phone_number, p_job);
    END IF;
END ;;

CREATE  PROCEDURE `update_student`(IN p_new_ssn CHAR(8), IN p_ssn CHAR(8), IN p_last_name VARCHAR(20), IN p_first_name VARCHAR(20), IN p_birthday DATE, IN p_sex CHAR(1), IN p_health_state VARCHAR(100), IN p_ethnic_group VARCHAR(30), IN p_student_id CHAR(7), IN p_has_health_insurance BOOLEAN, IN p_study_status VARCHAR(20), IN p_class_name VARCHAR(20), IN p_faculty VARCHAR(50), IN p_building_id CHAR(5), IN p_room_id CHAR(5), IN p_addresses TEXT, IN p_phone_numbers TEXT, IN p_emails TEXT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 @p_message = MESSAGE_TEXT; ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @p_message; END;
    START TRANSACTION;
    IF p_ssn = p_new_ssn THEN
        CALL update_student_info(p_ssn, p_first_name, p_last_name, p_birthday, p_sex, p_ethnic_group, p_health_state, p_student_id, p_study_status, p_class_name, p_faculty, p_building_id, p_room_id, p_phone_numbers, p_emails, p_addresses, p_has_health_insurance);
    ELSE
        CALL insert_student(p_new_ssn, NULL, p_first_name, p_last_name, p_birthday, p_sex, p_ethnic_group, p_health_state, p_student_id, p_study_status, p_class_name, p_faculty, p_building_id, p_room_id, p_phone_numbers, p_emails, p_addresses, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        CALL delete_student_by_sssn(p_ssn);
    END IF;
    COMMIT;
END ;;

DELIMITER $$


CREATE PROCEDURE `update_student_info`(
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
    DECLARE v_old_building CHAR(5);
    DECLARE v_old_room CHAR(5);

    -- 1. Lấy thông tin phòng CŨ mà sinh viên đang ở (trước khi update)
    SELECT building_id, room_id INTO v_old_building, v_old_room
    FROM student WHERE sssn = p_sssn;

    -- 2. Xử lý các giá trị đầu vào
    IF p_cccd IS NULL OR p_cccd = '' THEN 
        SET p_cccd = (SELECT cccd FROM student WHERE sssn = p_sssn); 
    END IF;

    IF p_building_id = '' THEN SET p_building_id = NULL; END IF;
    IF p_room_id = '' THEN SET p_room_id = NULL; END IF;

    -- Nếu trạng thái là Non_Active -> Ép buộc Set NULL phòng mới
    IF p_study_status = 'Non_Active' THEN 
        SET p_building_id = NULL; 
        SET p_room_id = NULL; 
    END IF;

    -- 3. LOGIC QUAN TRONG: CAP NHAT SI SO PHONG CU
    -- Điều kiện: Sinh viên ĐANG ở một phòng (v_old_room không null)
    -- VÀ (Sinh viên bị chuyển thành Non_Active HOẶC Sinh viên chuyển sang phòng khác)
    IF (v_old_building IS NOT NULL AND v_old_room IS NOT NULL) THEN
        IF (p_study_status = 'Non_Active' OR v_old_room <> IFNULL(p_room_id, '')) THEN
            
            -- Trừ đi 1 người ở phòng cũ và tính lại occupancy_rate
            UPDATE living_room 
            SET current_num_of_students = GREATEST(current_num_of_students - 1, 0),
                occupancy_rate = CASE 
                    WHEN max_num_of_students > 0 THEN (GREATEST(current_num_of_students - 1, 0) / max_num_of_students) * 100 
                    ELSE 0 
                END
            WHERE building_id = v_old_building AND room_id = v_old_room;
            
        END IF;
    END IF;

    -- 4. Cập nhật thông tin sinh viên (Gán building/room mới hoặc NULL)
    UPDATE student 
    SET cccd = p_cccd, 
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
    WHERE sssn = p_sssn;
END$$

DELIMITER ;
DELIMITER $$

DROP PROCEDURE IF EXISTS `list_rooms_building`$$
CREATE PROCEDURE `list_rooms_building`(IN p_building_id CHAR(5))
BEGIN
    IF LENGTH(REPLACE(TRIM(p_building_id), ' ', '')) != 5 THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Building ID must be exactly 5 characters long.';
    END IF;

    SELECT 
        r.building_id,
        r.room_id,
        r.current_num_of_students,
        r.max_num_of_students,
        r.occupancy_rate,
        r.rental_price,
        r.room_status,
        CONCAT(r.occupancy_rate, '%') AS formatted_occupancy_rate,
        (SELECT s.sex 
           FROM student s 
          WHERE s.building_id = r.building_id 
            AND s.room_id = r.room_id 
          LIMIT 1) AS room_gender
    FROM living_room r
    WHERE r.building_id = p_building_id
    ORDER BY r.room_id;
END$$

DROP PROCEDURE IF EXISTS `list_all_rooms`$$

CREATE PROCEDURE `list_all_rooms`()
BEGIN
    SELECT 
        r.building_id,
        r.room_id,
        r.current_num_of_students,
        r.max_num_of_students,
        r.occupancy_rate,
        r.rental_price,
        r.room_status,
        
        -- Lấy giới tính của phòng (dựa trên sinh viên đầu tiên tìm thấy)
        (SELECT s.sex 
         FROM student s 
         WHERE s.building_id = r.building_id AND s.room_id = r.room_id 
         LIMIT 1) AS room_gender

    FROM living_room r
    ORDER BY r.building_id, r.room_id;
END$$

DELIMITER ;;

CREATE PROCEDURE list_all_underoccupied_rooms()
BEGIN
    SELECT r.building_id, r.room_id, r.current_num_of_students, r.max_num_of_students, r.occupancy_rate, r.rental_price, r.room_status, CONCAT(r.occupancy_rate, '%') AS formatted_occupancy_rate, (SELECT s.sex FROM student s WHERE s.building_id = r.building_id AND s.room_id = r.room_id LIMIT 1) AS room_gender FROM living_room r WHERE r.current_num_of_students < r.max_num_of_students ORDER BY r.building_id, r.room_id;
END ;;

CREATE PROCEDURE get_students_in_room(IN p_building_id VARCHAR(10), IN p_room_id VARCHAR(10))
BEGIN
    SELECT s.sssn as ssn, s.student_id, s.cccd, s.first_name, s.last_name, s.phone_numbers, s.sex, s.emails FROM student s INNER JOIN living_room r ON s.room_id = r.room_id AND s.building_id = r.building_id WHERE r.building_id = p_building_id AND r.room_id = p_room_id;
END ;;

CREATE PROCEDURE get_room_detail(IN p_building_id VARCHAR(10), IN p_room_id VARCHAR(10))
BEGIN
    SELECT r.building_id AS building_id, r.room_id AS room_id, r.max_num_of_students, r.current_num_of_students, r.occupancy_rate, r.rental_price, r.room_status, (SELECT s.sex FROM student s WHERE s.building_id = r.building_id AND s.room_id = r.room_id LIMIT 1) AS room_gender FROM living_room r WHERE r.building_id = p_building_id AND r.room_id = p_room_id;
END ;;

CREATE PROCEDURE update_room(IN p_building_id CHAR(5), IN p_room_id CHAR(5), IN p_max_num_of_students INT, IN p_current_num_of_students INT, IN p_rental_price DECIMAL(10,2), IN p_room_status ENUM('Available','Occupied','Under Maintenance'))
BEGIN
    UPDATE living_room SET max_num_of_students = p_max_num_of_students, current_num_of_students = p_current_num_of_students, rental_price = p_rental_price, room_status = p_room_status, occupancy_rate = CASE WHEN p_max_num_of_students > 0 THEN (p_current_num_of_students / p_max_num_of_students) * 100 ELSE 0 END WHERE building_id = p_building_id AND room_id = p_room_id;
END ;;

CREATE PROCEDURE list_underoccupied_by_building(IN p_building_id CHAR(5))
BEGIN
    IF LENGTH(REPLACE(TRIM(p_building_id), ' ', '')) != 5 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Building ID must be exactly 5 characters long.'; END IF;
    SELECT building_id, room_id, current_num_of_students, max_num_of_students, occupancy_rate, room_status, CONCAT(occupancy_rate, '%') AS formatted_occupancy_rate FROM living_room WHERE building_id = p_building_id AND current_num_of_students < max_num_of_students ORDER BY room_id;
END ;;

DELIMITER ;
SET FOREIGN_KEY_CHECKS = 1;