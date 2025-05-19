-- Create Database
CREATE DATABASE CrimeRecordDB;
USE CrimeRecordDB;

-- Table: PoliceStation
CREATE TABLE PoliceStation (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(100),
    Location VARCHAR(100),
    ContactNumber VARCHAR(15)
);

-- Table: Officer
CREATE TABLE Officer (
    OfficerID INT PRIMARY KEY AUTO_INCREMENT,
    OfficerName VARCHAR(100),
    Position VARCHAR(50),
    StationID INT,
    FOREIGN KEY (StationID) REFERENCES PoliceStation(StationID)
);

-- Table: Criminal
CREATE TABLE Criminal (
    CriminalID INT PRIMARY KEY AUTO_INCREMENT,
    CriminalName VARCHAR(100),
    CriminalAge INT,
    Gender VARCHAR(10),
    Address VARCHAR(150),
    CrimeCommitted VARCHAR(100),
    ArrestDate DATE
);

-- Table: Victim
CREATE TABLE Victim (
    VictimID INT PRIMARY KEY AUTO_INCREMENT,
    VictimName VARCHAR(100),
    VictimAge INT,
    Gender VARCHAR(10),
    Address VARCHAR(150),
    CrimeInvolved VARCHAR(100)
);

-- Table: CrimeRecord
CREATE TABLE CrimeRecord (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    CrimeType VARCHAR(100),
    CrimeDate DATE,
    Location VARCHAR(100),
    CriminalID INT,
    VictimID INT,
    OfficerID INT,
    FOREIGN KEY (CriminalID) REFERENCES Criminal(CriminalID),
    FOREIGN KEY (VictimID) REFERENCES Victim(VictimID),
    FOREIGN KEY (OfficerID) REFERENCES Officer(OfficerID)
);

-- Insert Data into PoliceStation
INSERT INTO PoliceStation (StationName, Location, ContactNumber) VALUES
('Central Police Station', 'Downtown', '1234567890'),
('West Side Station', 'West Avenue', '0987654321');
SELECT *FROM PoliceStation;

-- Insert Data into Officer
INSERT INTO Officer (OfficerName, Position, StationID) VALUES
('Rajesh Kumar', 'Inspector', 1),
('Suman Gupta', 'Sub-Inspector', 2);
SELECT *FROM Officer;

-- Insert Data into Criminal
INSERT INTO Criminal (CriminalName, CriminalAge, Gender, Address, CrimeCommitted, ArrestDate) VALUES
('Rohit Sharma', 32, 'Male', 'Sector 21, City A', 'Robbery', '2025-05-01'),
('Anjali Verma', 28, 'Female', 'Area B, City B', 'Fraud', '2025-04-20');
SELECT *FROM Criminal;

-- Insert Data into Victim
INSERT INTO Victim (VictimName, VictimAge, Gender, Address, CrimeInvolved) VALUES
('Vikas Malhotra', 40, 'Male', 'Sector 11, City A', 'Robbery'),
('Meena Joshi', 35, 'Female', 'West Street, City B', 'Fraud');
SELECT *FROM Victim;

-- Insert Data into CrimeRecord
INSERT INTO CrimeRecord (CrimeType, CrimeDate, Location, CriminalID, VictimID, OfficerID) VALUES
('Robbery', '2025-05-01', 'Sector 21, City A', 1, 1, 1),
('Fraud', '2025-04-20', 'Area B, City B', 2, 2, 2);
SELECT *FROM CrimeRecord;

-- JOIN Query: Join CrimeRecord with Criminal, Victim, and Officer to get crime details
SELECT 
    c.RecordID, 
    c.CrimeType, 
    c.CrimeDate, 
    p.OfficerName, 
    cr.CriminalName, 
    v.VictimName 
FROM 
    CrimeRecord c
JOIN 
    Officer p ON c.OfficerID = p.OfficerID
JOIN 
    Criminal cr ON c.CriminalID = cr.CriminalID
JOIN 
    Victim v ON c.VictimID = v.VictimID;
-- Trigger: Automatically insert a record into CrimeRecord after a criminal is added
DELIMITER //

CREATE TRIGGER after_criminal_insert 
AFTER INSERT ON Criminal
FOR EACH ROW
BEGIN
    INSERT INTO CrimeRecord (CrimeType, CrimeDate, CriminalID, VictimID, OfficerID)
    VALUES ('Unknown Crime', NOW(), NEW.CriminalID, NULL, NULL);
END //

DELIMITER ;