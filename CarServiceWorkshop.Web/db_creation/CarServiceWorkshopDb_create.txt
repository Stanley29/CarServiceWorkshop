CREATE DATABASE CarServiceWorkshopDb;
GO

USE CarServiceWorkshopDb;
GO

CREATE TABLE Clients (
    Id INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    Email NVARCHAR(200) NOT NULL
);

CREATE TABLE Cars (
    Id INT IDENTITY PRIMARY KEY,
    PlateNumber NVARCHAR(50) NOT NULL,
    Brand NVARCHAR(100) NOT NULL,
    Model NVARCHAR(100) NOT NULL,
    Year INT NOT NULL,
    ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id)
);

CREATE TABLE Orders (
    Id INT IDENTITY PRIMARY KEY,
    CarId INT NOT NULL FOREIGN KEY REFERENCES Cars(Id),
    CreatedAt DATETIME2 NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    EstimatedCost DECIMAL(10,2) NOT NULL,
    Status INT NOT NULL
);
GO

INSERT INTO Clients (FullName, Phone, Email) VALUES
('John Doe','+4911111111','john@example.com'),
('Jane Smith','+4911111112','jane@example.com'),
('Michael Brown','+4911111113','michael@example.com'),
('Emily Davis','+4911111114','emily@example.com'),
('Robert Johnson','+4911111115','robert@example.com'),
('Olivia Wilson','+4911111116','olivia@example.com'),
('Liam Miller','+4911111117','liam@example.com'),
('Sophia Taylor','+4911111118','sophia@example.com'),
('Noah Anderson','+4911111119','noah@example.com'),
('Ava Thomas','+4911111120','ava@example.com'),
('Ethan Jackson','+4911111121','ethan@example.com'),
('Isabella White','+4911111122','isabella@example.com'),
('Mason Harris','+4911111123','mason@example.com'),
('Mia Martin','+4911111124','mia@example.com'),
('Logan Thompson','+4911111125','logan@example.com'),
('Charlotte Garcia','+4911111126','charlotte@example.com'),
('Lucas Martinez','+4911111127','lucas@example.com'),
('Amelia Robinson','+4911111128','amelia@example.com'),
('Henry Clark','+4911111129','henry@example.com'),
('Harper Rodriguez','+4911111130','harper@example.com');
GO

INSERT INTO Cars (PlateNumber, Brand, Model, Year, ClientId) VALUES
('SB-CSW-001','BMW','3 Series',2018,1),
('SB-CSW-002','Audi','A4',2019,1),
('SB-CSW-003','Mercedes','C-Class',2020,2),
('SB-CSW-004','Volkswagen','Golf',2017,3),
('SB-CSW-005','Toyota','Corolla',2016,4),
('SB-CSW-006','Honda','Civic',2018,5),
('SB-CSW-007','Ford','Focus',2015,6),
('SB-CSW-008','Opel','Astra',2014,7),
('SB-CSW-009','Skoda','Octavia',2019,8),
('SB-CSW-010','Tesla','Model 3',2021,9),
('SB-CSW-011','BMW','5 Series',2017,10),
('SB-CSW-012','Audi','Q5',2018,11),
('SB-CSW-013','Mercedes','E-Class',2019,12),
('SB-CSW-014','Volkswagen','Passat',2016,13),
('SB-CSW-015','Toyota','Camry',2015,14),
('SB-CSW-016','Honda','Accord',2017,15),
('SB-CSW-017','Ford','Mondeo',2014,16),
('SB-CSW-018','Opel','Insignia',2016,17),
('SB-CSW-019','Skoda','Superb',2018,18),
('SB-CSW-020','Tesla','Model S',2020,19),
('SB-CSW-021','BMW','X3',2019,20),
('SB-CSW-022','Audi','A3',2016,2),
('SB-CSW-023','Mercedes','GLA',2018,3),
('SB-CSW-024','Volkswagen','Tiguan',2019,4),
('SB-CSW-025','Toyota','RAV4',2020,5),
('SB-CSW-026','Honda','CR-V',2019,6),
('SB-CSW-027','Ford','Kuga',2018,7),
('SB-CSW-028','Opel','Mokka',2017,8),
('SB-CSW-029','Skoda','Karoq',2020,9),
('SB-CSW-030','Tesla','Model Y',2022,10);
GO

INSERT INTO Orders (CarId, CreatedAt, Description, EstimatedCost, Status) VALUES
(1,  GETUTCDATE(), 'Oil change and filter replacement', 120.00, 3),
(2,  GETUTCDATE(), 'Brake pads replacement', 250.00, 2),
(3,  GETUTCDATE(), 'Engine diagnostics', 90.00, 1),
(4,  GETUTCDATE(), 'Tire replacement', 400.00, 3),
(5,  GETUTCDATE(), 'Battery check', 60.00, 0),
(6,  GETUTCDATE(), 'Air conditioning repair', 300.00, 2),
(7,  GETUTCDATE(), 'Suspension inspection', 150.00, 1),
(8,  GETUTCDATE(), 'Transmission service', 500.00, 2),
(9,  GETUTCDATE(), 'Wheel alignment', 100.00, 3),
(10, GETUTCDATE(), 'Software update', 80.00, 3),
(11, GETUTCDATE(), 'Full inspection', 200.00, 1),
(12, GETUTCDATE(), 'Oil leak repair', 350.00, 2),
(13, GETUTCDATE(), 'Exhaust system repair', 220.00, 1),
(14, GETUTCDATE(), 'Headlight replacement', 130.00, 3),
(15, GETUTCDATE(), 'Clutch replacement', 700.00, 2),
(16, GETUTCDATE(), 'Cooling system flush', 180.00, 1),
(17, GETUTCDATE(), 'Timing belt replacement', 650.00, 2),
(18, GETUTCDATE(), 'Fuel system cleaning', 160.00, 3),
(19, GETUTCDATE(), 'Detailing and polishing', 250.00, 3),
(20, GETUTCDATE(), 'High voltage system check', 400.00, 1),
(21, GETUTCDATE(), 'Diagnostics after accident', 500.00, 2),
(22, GETUTCDATE(), 'Minor body repair', 300.00, 1),
(23, GETUTCDATE(), 'Interior cleaning', 120.00, 3),
(24, GETUTCDATE(), 'Winter tires installation', 200.00, 3),
(25, GETUTCDATE(), 'Summer tires installation', 200.00, 0),
(26, GETUTCDATE(), 'ABS system diagnostics', 180.00, 1),
(27, GETUTCDATE(), 'Parking sensors installation', 350.00, 2),
(28, GETUTCDATE(), 'Navigation system update', 150.00, 3),
(29, GETUTCDATE(), 'Paint correction', 600.00, 2),
(30, GETUTCDATE(), 'Battery replacement', 220.00, 3);
GO
