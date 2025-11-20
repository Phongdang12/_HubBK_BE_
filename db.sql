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
('BK001','P.104',6,3,1500000.00,50.00,'Available'),('BK001','P.201',6,3,1500000.00,50.00,'Available'),('BK001','P.202',6,0,1500000.00,0.00,'Available'),('BK001','P.203',6,0,1500000.00,0.00,'Available'),('BK001','P.204',6,4,1500000.00,66.67,'Available'),('BK001','P.301',6,0,1500000.00,0.00,'Available'),('BK001','P.302',6,0,1500000.00,0.00,'Available'),('BK001','P.303',6,0,1500000.00,0.00,'Available'),('BK001','P.304',6,4,1500000.00,66.67,'Available'),('BK001','P.401',6,0,1500000.00,0.00,'Available'),('BK001','P.402',6,0,1500000.00,0.00,'Available'),('BK001','P.403',6,0,1500000.00,0.00,'Available'),('BK001','P.404',6,0,1500000.00,0.00,'Available'),
('BK002','P.102',6,2,1500000.00,33.33,'Available'),('BK002','P.104',6,1,1500000.00,16.67,'Available'),('BK002','P.201',6,0,1500000.00,0.00,'Available'),('BK002','P.202',6,0,1500000.00,0.00,'Available'),('BK002','P.203',6,1,1500000.00,16.67,'Available'),('BK002','P.204',6,4,1500000.00,66.67,'Available'),('BK002','P.301',6,0,1500000.00,0.00,'Available'),('BK002','P.302',6,0,1500000.00,0.00,'Available'),('BK002','P.303',6,0,1500000.00,0.00,'Available'),('BK002','P.304',6,0,1500000.00,0.00,'Available'),('BK002','P.401',6,0,1500000.00,0.00,'Available'),('BK002','P.402',6,0,1500000.00,0.00,'Available'),('BK002','P.403',6,0,1500000.00,0.00,'Available'),('BK002','P.404',6,0,1500000.00,0.00,'Available'),
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
INSERT INTO `student` VALUES ('05620513','012345670013','Khoi Nguyen','Minh','2003-06-02','M','Kinh','Active','Good','2312613','KHMT1','Computer Science','BK001','P.104',1,'0389162347, 0328190284','khoi.nguyenminh03@hcmut.edu.vn; khoinguyen13@gmail.com','Tam Dan, Quang Nam','075362513699','Nguyen Van An','Father','Teacher','1975-05-14','0389162345','Tam Dan, Quang Nam'),('05620514','012345670014','Mai','Nguyen Phuong','2006-03-09','F','Kinh','Active','Good','2212345','KHMT2','Computer Science','BK001','P.104',1,'0328190284','mai.nguyenphuong06@hcmut.edu.vn','Son Tra, Da Nang','075362513702','Tran Thi Linh','Mother','Accountant','1980-11-25','0328190286','Son Tra, Da Nang'),('05620515','012345670015','Ngoc','Nguyen Minh','2003-12-01','F','Kinh','Active','Good','2012346','CNTT1','Information Technology','BK003','P.204',1,'0323824785','ngoc.nguyenminh03@hcmut.edu.vn','Cam Le, Da Nang','075362513703','Le Van Hung','Father','Doctor','1973-07-18','0323824786','Cam Le, Da Nang'),('05620516','012345670016','Nam','Nguyen Hao','2006-03-02','M','Kinh','Active','Good','2112347','CNTT2','Information Technology','BK001','P.104',1,'0309238478, 0302455638','nam.nguyenhao06@hcmut.edu.vn, namhao987@gmail.com','Thanh Khe, Da Nang','075362513705','Nguyen Anh Tuan','Father','Businessman','1972-12-05','0309238479','Thanh Khe, Da Nang'),('05620517','012345670017','Ngan','Pham Kim','2003-10-20','F','Kinh','Active','Good','2312348','DTVT1','Electronics and Telecommunications Engineering','BK002','P.102',1,'0320245757','ngan.phamkim03@hcmut.edu.vn','Hoa Vang, Da Nang','075362513708','Nguyen Thi Lan','Mother','Nurse','1974-10-10','0320245759','Hoa Vang, Da Nang'),('05620518','012345670018','Phuong','Tran Ngoc','2005-03-26','F','Kinh','Active','Good','2412349','DTVT2','Electronics and Telecommunications Engineering','BK002','P.104',1,'0329287547, 0329309458','phuong.tranngoc05@hcmut.edu.vn','Hoa An, Da Nang, Thanh Khe, Da Nang','075362513710','Le Thi Huong','Mother','Teacher','1975-05-25','0329287549','Hoa An, Da Nang'),('05620519','012345670019','Phu','Nguyen Quoc','2005-07-23','M','Kinh','Active','Good','2212350','CK1','Mechanical Engineering','BK002','P.203',1,'0320918267','phu.nguyenquoc05@hcmut.edu.vn','Cau Moi, Quang Ninh','075362513711','Nguyen Van Hai','Father','Fisherman','1969-08-12','0320918268','Cau Moi, Quang Ninh'),('05620520','012345670020','Phung','Nguyen Minh','2004-05-01','F','Kinh','Non_Active','Good','2012351','CK2','Mechanical Engineering','BK002','P.102',1,'0387326653','phung.nguyenminh04@hcmut.edu.vn','Bai Chay, Quang Ninh','075362513714','Tran Thi Nga','Mother','Receptionist','1978-07-19','0387326655','Bai Chay, Quang Ninh'),('05620521','012345670021','Quan','Vo Anh','2005-09-06','M','Kinh','Active','Good','2112352','D1','Electrical Engineering','BK003','P.104',1,'0320975643, 0329235432','quan.voanh05@hcmut.edu.vn, quanvo05@gmail.com','Quang Trung, Quang Ninh','075362513715','Vo Van Long','Father','Construction Worker','1972-09-03','0320975644','Quang Trung, Quang Ninh'),('05620522','012345670022','Phuoc Nguyen','Thien','2005-10-17','M','Kinh','Active','Good','2312353','D2','Electrical Engineering','BK003','P.104',1,'0399706545','phuoc.nguyenthien05@hcmut.edu.vn;phuoc@gmail.com','Yen Thanh, Quang Ninh, Nam Dong, Thua Thien Hue','075362513718','Nguyen Thi Nhung','Mother','Teacher','1974-10-21','0399706547','Yen Thanh, Quang Ninh'),('05620523','012345670023','Quynh','Nguyen Ngoc Diem','2006-02-01','F','Kinh','Active','Good','2412354','HTTT1','Information Security','BK003','P.104',1,'0328100038','quynh.nguyenngocdiem06@hcmut.edu.vn','Mong Duong, Quang Ninh','075362513719','Nguyen Hoang Nam','Father','Driver','1973-01-30','0328100039','Mong Duong, Quang Ninh'),('05620524','012345670024','Quynh','Nguyen Thi Diem','2004-05-01','F','Kinh','Active','Good','2212355','HTTT2','Information Security','BK003','P.104',1,'0391203470','quynh.nguyenthidiem04@hcmut.edu.vn','Uong Bi, Quang Ninh','075362513721','Nguyen Van Phuc','Father','Electrician','1971-03-25','0391203471','Uong Bi, Quang Ninh'),('05620525','012345670025','Phat','Vo Tan','2004-05-01','M','Kinh','Active','Good','2012356','XD1','Civil Engineering','BK003','P.104',1,'0328906742, 0392348324','phat.vo10@hcmut.edu.vn, phatvo@gmail.com','Dong Tien, Hoa Binh','075362513724','Nguyen Thi Suong','Mother','Housewife','1972-12-18','0328906744','Dong Tien, Hoa Binh'),('05620526','012345670026','Son Bui','Ngoc','2003-12-11','M','Kinh','Active','Good','2112359','XD2','Civil Engineering','BK003','P.104',1,'0328109200','son.buingoc03@hcmut.edu.vn','Mai Chau, Hoa Binh','075362513725','Bui Van Thang','Father','Tour Guide','1974-05-19','0328109201','Mai Chau, Hoa Binh'),('05620527','012345670027','Tai','Nguyen Duc','2003-09-30','M','Thai','Active','Good','2312358','H1','Chemical Engineering','BK004','P.104',1,'0328102980, 0328239804','tai.nguyenduc03@hcmut.edu.vn','Dinh Hoa, Thai Nguyen','075362513727','Nguyen Duc Tung','Father','Tea Farmer','1970-11-15','0328102981','Dinh Hoa, Thai Nguyen'),('05620528','012345670028','Tan Nguyen','Nhat','2004-01-29','M','Kinh','Active','Good','2412359','H2','Chemical Engineering','BK004','P.104',1,'0322134783','tan.nguyennhat04@hcmut.edu.vn;tannhat@gmail.com','Son Cam, Thai Nguyen','075362513730','Nguyen Van Dong','Father','Teacher','1977-07-13','0336958963','Son Cam, Thai Nguyen'),('05620529','012345670029','Tien','Phan Ngoc','2005-09-17','M','Kinh','Non_Active','Good','2212360','MT1','Environmental Engineering','BK001','P.204',1,'0320975423','tien.phanngoc05@hcmut.edu.vn, tienphan@gmail.com','Hoa Binh, Hoa Binh','075362513731','Phan Van Yen','Father','Construction Worker','1971-08-10','0320975424','Hoa Binh, Hoa Binh'),('05620530','012345670030','Tu','Nguyen Anh','2003-02-12','M','Kinh','Active','Good','2012361','MT2','Environmental Engineering','BK001','P.204',1,'0328100347','tu.nguyenanh03@hcmut.edu.vn','Lang Son, Lang Son','075362513734','Tran Thi Bich','Mother','Housewife','1978-11-30','0328100349','Lang Son, Lang Son'),('05620531','012345670031','Tuong','Nguyen Ngoc','2005-03-14','M','Kinh','Active','Good','2112362','DK1','Control and Automation Engineering','BK001','P.204',1,'0326784592, 0322349823','tuong.nguyenngoc05@hcmut.edu.vn','Phu Tan, Dong Nai','075362513735','Vo Van Chien','Father','Factory Worker','1972-03-15','0326784593','Phu Tan, Dong Nai'),('05620532','012345670032','Thao','Nguyen Ngoc Thanh','2006-02-04','F','Kinh','Active','Good','2312363','DK2','Control and Automation Engineering','BK001','P.204',1,'0326735204','thao.nguyenngocthanh06@hcmut.edu.vn','Bac Giang, Bac Giang','075362513737','Nguyen Van Giang','Father','Farmer','1970-05-10','0326735205','Bac Giang, Bac Giang'),('05620533','012345670033','Thu','Nguyen Ngoc Minh','2005-03-31','F','Kinh','Active','Good','2412364','QL1','Industrial Management','BK002','P.204',1,'0327843792','thu.nguyenngocminh05@hcmut.edu.vn, thuminhnguyen123@gmail.com','Tuy An, Phu Yen, Tan Xuan, Phu Yen','075362513740','Nguyen Thi Lien','Mother','Seamstress','1977-06-25','0327843794','Tuy An, Phu Yen'),('05620534','012345670034','Thuy','Nguyen Thi Thanh','2003-02-15','F','Kinh','Active','Good','2212365','QL2','Industrial Management','BK002','P.204',1,'0328129343, 0339852345','thuy.nguyenthithanh03@hcmut.edu.vn','Phu Ly, Ha Nam','075362513742','Tran Thi Nga','Mother','Shopkeeper','1975-09-20','0328129345','Phu Ly, Ha Nam'),('05620535','012345670035','Uyen','Nguyen Ngoc','2005-02-18','M','Kinh','Active','Good','2012366','SCM1','Logistics and Supply Chain Management','BK002','P.204',1,'0393280450','uyen.nguyenngoc05@hcmut.edu.vn','Duc Tho, Ha Tinh','075362513743','Nguyen Van Phu','Other','Teacher','1974-07-25','0393280451','Duc Tho, Ha Tinh'),('05620536','012345670036','Vy','Nguyen Tuong','2004-06-13','M','Kinh','Active','Good','2112367','SCM2','Logistics and Supply Chain Management','BK002','P.204',1,'0924723455, 0959873235','vy.nguyenthuong04@hcmut.edu.vn','Quynh Luu, Nghe An','075362513745','Nguyen Van Son','Father','Farmer','1972-02-10','0924723456','Quynh Luu, Nghe An'),('05620537','012345670037','Vu','Tran Van','2003-02-12','M','Kinh','Active','Good','2312368','VL1','Materials Engineering','BK003','P.204',1,'0739012012','vu.tranvan03@hcmut.edu.vn','Vinh, Nghe An, Dong Tien, Hoa Binh','075362513748','Nguyen Thi Uyen','Mother','Teacher','1974-10-25','0739012014','Vinh, Nghe An'),('05620538','012345670038','Duc','Nguyen Minh','2003-03-15','M','Tay','Active','Good','2412369','VL2','Materials Engineering','BK003','P.204',1,'0928761451','duc.nguyenminh03@hcmut.edu.vn','Nam Dan, Nghe An','075362513749','Nguyen Van Viet','Father','Teacher','1973-08-15','0928761452','Nam Dan, Nghe An'),('05620539','012345670039','Toan Bui','Duc','2006-01-15','M','Kinh','Active','Good','2212370','SH1','Biotechnology','BK001','P.201',1,'0322934734','toan.buiduc06@hcmut.edu.vn;toanducr@gmail.com','Thanh Chuong, Nghe An','075362513751','Bui Van Yen','Father','Farmer','1971-04-06','0322934735','Thanh Chuong, Nghe An'),('05620540','012345670040','Tram','Nguyen Thuy','2004-08-01','F','Kinh','Non_Active','Good','2012371','SH2','Biotechnology','BK003','P.204',1,'0329235483, 0325359783','tram.nguyenthuy04@hcmut.edu.vn','Cua Lo, Nghe An','075362513752','Nguyen Van Anh','Other','Fisherman','1974-12-20','0329235484','Cua Lo, Nghe An'),('05620541','012345670041','Truc','Pham Ngoc','2006-01-24','M','Kinh','Active','Good','2412374','KT1','Computer Engineering','BK004','P.204',1,'0328198534','truc.phamngoc06@hcmut.edu.vn','Hung Nguyen, Nghe An','075362513754','Tran Van Cuong','Father','Teacher','1972-03-15','0391287452','Dien Chau, Nghe An'),('05620542','012345670042','Hau','Nguyen Phuc','2005-06-01','F','Kinh','Active','Good','2212375','KT2','Computer Engineering','BK004','P.204',1,'0327684529','hau.nguyenphuc05@hcmut.edu.vn','Kien Thuy, Hai Phong','075362513755','Le Van Duc','Father','Fisherman','1970-09-10','0320394755','Ngo Quyen, Hai Phong'),('05620543','012345670043','Thuan','Luong Minh','2003-12-05','M','Kinh','Active','Good','2112382','XD3','Civil Engineering','BK004','P.204',1,'0320394754','thuan.luongminh03@hcmut.edu.vn','Ngo Quyen, Hai Phong','075362513758','Tran Thi Hanh','Mother','Housewife','1977-11-25','0309237434','An Lao, Hai Phong'),('05620544','012345670044','Nhi','Nguyen Ngoc Thuy','2006-03-20','F','Kinh','Active','Good','2312383','H3','Chemical Engineering',NULL,NULL,1,'0309237432, 0329483452','nhi.nguyenngocthuy06@hcmut.edu.vn','An Lao, Hai Phong','075362513760','Nguyen Thi Linh','Other','Teacher','1975-06-15','0322934525','Van Lam, Hung Yen'),('05620545','012345670045','Dai','Nguyen Van','2005-02-17','M','Kinh','Active','Good','2012376','KHMT3','Computer Science','BK001','P.304',1,'0320293745','dai.nguyenvan05@hcmut.edu.vn, daivan@gmail.com','Van Lam, Hung Yen, Yen Thanh, Quang Ninh','075362513761','Pham Van Minh','Father','Businessman','1973-04-20','0302348524','Cua Lo, Nghe An'),('05620546','012345670046','Khiem','Pham Gia','2003-09-23','M','Kinh','Active','Good','2112377','CNTT3','Information Technology','BK001','P.304',1,'0302348523, 0339854982','khiem.phamgia03@hcmut.edu.vn','Cua Lo, Nghe An, Phan Thiet, Binh Thuan','075362513763','Le Thi Nga','Mother','Shopkeeper','1976-08-30','0920975344','Tan Nghia, Binh Thuan'),('05620547','012345670047','Tran','Nguyen Ngoc Thao','2005-05-29','F','Kinh','Active','Good','2312378','DTVT3','Electronics and Telecommunications Engineering','BK001','P.304',1,'0920975343','tran.nguyenngocthao05@hcmut.edu.vn','Tan Nghia, Binh Thuan, Hung Nguyen, Nghe An','075362513765','Nguyen Van Phat','Father','Soldier','1974-05-15','0328102400','Dong Ha, Quang Tri'),('05620548','012345670048','Tien','Nguyen Thuy','2004-03-19','F','Kinh','Active','Good','2412379','CK3','Mechanical Engineering','BK001','P.304',1,'0322934523, 0339845723','tien.nguyenthuy04@hcmut.edu.vn','Dong Ha, Quang Tri','075362513766','Le Van Quang','Father','Teacher','1972-10-10','0328724235','Huong Thuy, Thua Thien Hue'),('05620549','012345670049','Tuan','Nguyen Quoc','2005-09-12','M','Kinh','Active','Good','2212380','D3','Electrical Engineering','BK003','P.304',1,'0328102409','tuan.nguyenquoc05@hcmut.edu.vn, tuannguyen@gmail.com','Huong Thuy, Thua Thien Hue','075362513769','Tran Thi Trang','Mother','Nurse','1975-12-05','0329235799','Phu Bai, Thua Thien Hue'),('05620550','012345670050','Chi','Bui Ngoc Kim','2003-09-15','F','Hoa','Active','Good','2012381','HTTT3','Information Security','BK003','P.304',1,'0328724234, 0339785329','chi.buingockim03@hcmut.edu.vn','Phu Bai, Thua Thien Hue','075362513770','Nguyen Van Van','Father','Farmer','1973-03-20','0329459839','Nam Dong, Thua Thien Hue'),('05620551','012345670051','Chi','Pham Minh','2006-04-01','M','Kinh','Active','Good','2112372','PM1','Software Engineering','BK003','P.304',1,'0329235798','chi.phamminh06@hcmut.edu.vn, chipham00@gmail.com','Nam Dong, Thua Thien Hue','075362513772','Le Thi Xuan','Mother','Shopkeeper','1976-07-15','0328102982','Huong Tra, Thua Thien Hue'),('05620552','012345670052','Chien','Tran Duc','2002-01-26','M','Kinh','Active','Good','2312373','PM2','Software Engineering','BK003','P.304',1,'0329459838','chien.tranduc02@hcmut.edu.vn','Huong Tra, Thua Thien Hue','075362513773','Tran Van Binh','Father','Teacher','1972-09-22','0389199282','Dong Ha, Quang Tri');
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

('DA001', 'Cleaning Duty', 'Violation of quiet hours', '2023-03-15', '2023-03-16', '2023-06-16', 'low', 'cancelled'),

('DA002', 'Community Service', 'Violation of quiet hours', '2023-04-20', '2023-04-21', NULL, 'expulsion', 'active'),

('DA003', 'Expulsion', 'Smoking in non-designated areas', '2023-02-10', '2023-02-11', '2023-04-11', 'high', 'active'),

('DA004', 'Expulsion', 'Physical assault or fighting', '2023-01-05', '2023-01-06', NULL, 'expulsion', 'active'),

('DA005', 'Yard Cleaning', 'Unauthorized guests', '2023-05-12', '2023-05-13', '2023-08-13', 'low', 'completed'),

('DA006', 'Classroom Setup', 'Physical assault or fighting', '2023-08-01', '2023-08-02', '2023-11-03', 'high', 'completed'),

('DA007', 'Dorm Cleaning', 'Physical assault or fighting', '2023-09-01', '2023-09-02', '2023-10-02', 'high', 'completed'),

('DA008', 'Cafeteria Duty', 'Harassment or bullying', '2025-02-20', '2025-02-21', '2025-05-21', 'medium', 'active'),

('DA009', 'Library Service', 'Unauthorized access to restricted areas', '2025-03-10', '2025-03-11', '2025-06-11', 'medium', 'active'),

('DA010', 'Hall Monitoring', 'Disregard for dormitory staff instructions', '2025-03-15', '2025-03-16', '2025-07-16', 'low', 'active');

INSERT INTO student_discipline (action_id, sssn) VALUES

('DA001', '05620513'),

('DA002', '05620514'),

('DA003', '05620515'),

('DA004', '05620516'),

('DA005', '05620517'),

('DA006', '05620518'),

('DA007', '05620519'),

('DA008', '05620520'),

('DA009', '05620521'),

('DA010', '05620522');




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

