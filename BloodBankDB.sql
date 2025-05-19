-- Create Database
CREATE DATABASE BloodBankDB;
USE BloodBankDB;

-- Table: Donor
CREATE TABLE Donor (
    DonorID INT PRIMARY KEY AUTO_INCREMENT,
    DonorName VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    BloodGroup VARCHAR(5),
    ContactNumber VARCHAR(15),
    Address VARCHAR(150),
    LastDonationDate DATE
);

-- Table: Recipient
CREATE TABLE Recipient (
    RecipientID INT PRIMARY KEY AUTO_INCREMENT,
    RecipientName VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    BloodGroup VARCHAR(5),
    ContactNumber VARCHAR(15),
    Address VARCHAR(150),
    RequiredDate DATE
);

-- Table: BloodBank
CREATE TABLE BloodBank (
    BankID INT PRIMARY KEY AUTO_INCREMENT,
    BankName VARCHAR(100),
    Location VARCHAR(100),
    ContactNumber VARCHAR(15)
);

-- Table: BloodStock
CREATE TABLE BloodStock (
    StockID INT PRIMARY KEY AUTO_INCREMENT,
    BankID INT,
    BloodGroup VARCHAR(5),
    Quantity INT, -- in units
    LastUpdated DATE,
    FOREIGN KEY (BankID) REFERENCES BloodBank(BankID)
);

-- Table: Donation
CREATE TABLE Donation (
    DonationID INT PRIMARY KEY AUTO_INCREMENT,
    DonorID INT,
    BankID INT,
    DonationDate DATE,
    Quantity INT, -- in units
    FOREIGN KEY (DonorID) REFERENCES Donor(DonorID),
    FOREIGN KEY (BankID) REFERENCES BloodBank(BankID)
);

-- Table: BloodRequest
CREATE TABLE BloodRequest (
    RequestID INT PRIMARY KEY AUTO_INCREMENT,
    RecipientID INT,
    BankID INT,
    RequestDate DATE,
    BloodGroup VARCHAR(5),
    Quantity INT, -- in units
    Status VARCHAR(20), -- Pending, Approved, Rejected
    FOREIGN KEY (RecipientID) REFERENCES Recipient(RecipientID),
    FOREIGN KEY (BankID) REFERENCES BloodBank(BankID)
);

-- Insert Sample Data into BloodBank
INSERT INTO BloodBank (BankName, Location, ContactNumber) VALUES
('City Central Blood Bank', 'City A', '9876543210'),
('LifeCare Blood Bank', 'City B', '9123456789');
SELECT *FROM BloodBank;

-- Insert Sample Data into Donor
INSERT INTO Donor (DonorName, Age, Gender, BloodGroup, ContactNumber, Address, LastDonationDate) VALUES
('Ramesh Kumar', 30, 'Male', 'A+', '9998887776', 'City A', '2025-05-01'),
('Seema Rani', 28, 'Female', 'B+', '9887766554', 'City B', '2025-04-20');
SELECT *FROM Donor;

-- Insert Sample Data into Recipient
INSERT INTO Recipient (RecipientName, Age, Gender, BloodGroup, ContactNumber, Address, RequiredDate) VALUES
('Amit Singh', 45, 'Male', 'A+', '9876543210', 'City A', '2025-05-20'),
('Pooja Sharma', 50, 'Female', 'O-', '9123456789', 'City B', '2025-05-18');
SELECT *FROM Recipient;

-- Insert Sample Data into BloodStock
INSERT INTO BloodStock (BankID, BloodGroup, Quantity, LastUpdated) VALUES
(1, 'A+', 20, '2025-05-10'),
(1, 'B+', 15, '2025-05-10'),
(2, 'O-', 10, '2025-05-08');
SELECT *FROM BloodStock;

-- Insert Sample Data into Donation
INSERT INTO Donation (DonorID, BankID, DonationDate, Quantity) VALUES
(1, 1, '2025-05-01', 2),
(2, 2, '2025-04-20', 1);
SELECT *FROM Donation;

-- Insert Sample Data into BloodRequest
INSERT INTO BloodRequest (RecipientID, BankID, RequestDate, BloodGroup, Quantity, Status) VALUES
(1, 1, '2025-05-15', 'A+', 2, 'Pending'),
(2, 2, '2025-05-12', 'O-', 1, 'Approved');
SELECT *FROM BloodRequest;

-- JOIN Query: Join BloodRequest and BloodStock to check available blood for requests
SELECT 
    r.RequestID, 
    rec.RecipientName, 
    r.BloodGroup, 
    b.BloodGroup AS "Available Blood", 
    b.Quantity
FROM 
    BloodRequest r
JOIN 
    BloodStock b ON r.BloodGroup = b.BloodGroup AND r.BankID = b.BankID
JOIN 
    Recipient rec ON r.RecipientID = rec.RecipientID
WHERE 
    b.Quantity >= r.Quantity AND r.Status = 'Pending';

    
-- Trigger: Automatically approve/reject BloodRequest based on available stock
DELIMITER //

CREATE TRIGGER after_blood_request_insert
AFTER INSERT ON BloodRequest
FOR EACH ROW
BEGIN
    DECLARE available_quantity INT;
    
    SELECT Quantity INTO available_quantity
    FROM BloodStock
    WHERE BloodGroup = NEW.BloodGroup;

    IF available_quantity >= NEW.Quantity THEN
        UPDATE BloodRequest
        SET Status = 'Approved'
        WHERE RequestID = NEW.RequestID;
    ELSE
        UPDATE BloodRequest
        SET Status = 'Rejected'
        WHERE RequestID = NEW.RequestID;
    END IF;
END //

DELIMITER ;