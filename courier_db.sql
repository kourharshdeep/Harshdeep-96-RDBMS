CREATE database courier_db;

USE courier_db;
-- 1. USERS TABLE
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Address TEXT,
    Role ENUM('Customer', 'Admin') DEFAULT 'Customer',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Users
INSERT INTO Users (Name, Email, Phone, Address, Role) VALUES
('Alice Kumar', 'alice@example.com', '9876543210', '123 MG Road, Mumbai', 'Customer'),
('Bob Mehta', 'bob@example.com', '9123456780', '56 Park Street, Delhi', 'Customer'),
('Admin John', 'admin@example.com', '9999999999', 'HQ Office, Delhi', 'Admin');

SELECT *FROM Users;

-- 2. LOCATIONS TABLE
CREATE TABLE Locations (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Address TEXT,
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10)
);

-- Insert Locations
INSERT INTO Locations (Name, Address, City, State, ZipCode) VALUES
('Mumbai Central Hub', 'Plot 34, Industrial Area', 'Mumbai', 'Maharashtra', '400001'),
('Delhi Main Branch', 'Sector 21, Rohini', 'Delhi', 'Delhi', '110085');

SELECT *FROM Locations;

-- 3. EMPLOYEES TABLE
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Role ENUM('Delivery', 'Manager', 'Support'),
    LocationID INT,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

-- Insert Employees
INSERT INTO Employees (Name, Email, Phone, Role, LocationID) VALUES
('Ravi Kumar', 'ravi@courierco.com', '9988776655', 'Delivery', 1);

SELECT *FROM Employees;

-- 4. COURIERS TABLE
CREATE TABLE Couriers (
    CourierID INT PRIMARY KEY AUTO_INCREMENT,
    TrackingNumber VARCHAR(50) UNIQUE NOT NULL,
    SenderID INT,
    ReceiverID INT,
    Weight DECIMAL(6,2),
    Type ENUM('Document', 'Parcel', 'Fragile', 'Heavy', 'Other'),
    Status ENUM('Pending', 'In Transit', 'Delivered', 'Cancelled'),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SenderID) REFERENCES Users(UserID),
    FOREIGN KEY (ReceiverID) REFERENCES Users(UserID)
);

-- Insert Couriers
INSERT INTO Couriers (TrackingNumber, SenderID, ReceiverID, Weight, Type, Status) VALUES
('TRK123456789', 1, 2, 2.5, 'Parcel', 'Pending');

SELECT *FROM Couriers;

-- 5. DELIVERY ASSIGNMENTS TABLE
CREATE TABLE DeliveryAssignments (
    AssignmentID INT PRIMARY KEY AUTO_INCREMENT,
    CourierID INT,
    EmployeeID INT,
    AssignedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CourierID) REFERENCES Couriers(CourierID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert Delivery Assignment
INSERT INTO DeliveryAssignments (CourierID, EmployeeID) VALUES
(1, 1);

SELECT *FROM DeliveryAssignments;

-- 6. COURIER STATUS HISTORY TABLE
CREATE TABLE CourierStatusHistory (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    CourierID INT,
    Status ENUM('Pending', 'Dispatched', 'In Transit', 'Out for Delivery', 'Delivered', 'Delayed', 'Cancelled'),
    Location VARCHAR(255),
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CourierID) REFERENCES Couriers(CourierID)
);

-- Insert Status History
INSERT INTO CourierStatusHistory (CourierID, Status, Location) VALUES
(1, 'Pending', 'Mumbai Central Hub'),
(1, 'Dispatched', 'Mumbai Central Hub'),
(1, 'In Transit', 'On the way to Delhi');

SELECT *FROM CourierStatusHistory;

-- SAMPLE JOIN QUERY TO GET FULL TRACKING INFO
-- Retrieve latest courier status and assignment info

SELECT 
    C.TrackingNumber,
    U1.Name AS SenderName,
    U2.Name AS ReceiverName,
    CS.Status,
    CS.Location,
    CS.UpdatedAt,
    E.Name AS AssignedEmployee,
    L.Name AS EmployeeLocation
FROM Couriers C
JOIN Users U1 ON C.SenderID = U1.UserID
JOIN Users U2 ON C.ReceiverID = U2.UserID
LEFT JOIN CourierStatusHistory CS ON C.CourierID = CS.CourierID
LEFT JOIN DeliveryAssignments DA ON C.CourierID = DA.CourierID
LEFT JOIN Employees E ON DA.EmployeeID = E.EmployeeID
LEFT JOIN Locations L ON E.LocationID = L.LocationID
WHERE C.TrackingNumber = 'TRK123456789'
ORDER BY CS.UpdatedAt ASC;

SHOW TABLES;
