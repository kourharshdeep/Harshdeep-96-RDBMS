-- Database
CREATE DATABASE smart_home_iot;
USE smart_home_iot;

-- Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

-- Devices Table
CREATE TABLE Devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    device_name VARCHAR(100),
    device_type VARCHAR(50),
    room VARCHAR(50),
    status ENUM('ON', 'OFF') DEFAULT 'OFF',
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Sensors Table
CREATE TABLE Sensors (
    sensor_id INT AUTO_INCREMENT PRIMARY KEY,
    sensor_type VARCHAR(50),
    value FLOAT,
    unit VARCHAR(20),
    device_id INT,
    FOREIGN KEY (device_id) REFERENCES Devices(device_id)
);

-- Logs Table (Device Usage Logs)
CREATE TABLE Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT,
    action VARCHAR(100),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES Devices(device_id)
);

-- Users
INSERT INTO Users (name, email, phone) VALUES
('Alice', 'alice@example.com', '1234567890'),
('Bob', 'bob@example.com', '0987654321');
SELECT *FROM Users;

-- Devices
INSERT INTO Devices (device_name, device_type, room, status, user_id) VALUES
('Smart Light', 'Light', 'Living Room', 'OFF', 1),
('Smart Thermostat', 'Thermostat', 'Bedroom', 'OFF', 1),
('Smart Door Lock', 'Lock', 'Main Door', 'OFF', 2);
SELECT *FROM Devices;

-- Sensors
INSERT INTO Sensors (sensor_type, value, unit, device_id) VALUES
('Temperature', 22.5, 'Celsius', 2),
('Motion', 0, 'Boolean', 3);
SELECT *FROM Sensors;

-- Logs
INSERT INTO Logs (device_id, action) VALUES
(1, 'Turned ON'),
(2, 'Temperature Set to 22.5 C'),
(3, 'Door Locked');
SELECT *FROM Logs;

SELECT d.device_id, d.device_name, d.device_type, d.room, d.status, u.name AS owner_name
FROM Devices d
JOIN Users u ON d.user_id = u.user_id;

SELECT s.sensor_id, s.sensor_type, s.value, s.unit, d.device_name, d.room
FROM Sensors s
JOIN Devices d ON s.device_id = d.device_id;

SELECT l.log_id, l.action, l.log_time, d.device_name, u.name AS user_name
FROM Logs l
JOIN Devices d ON l.device_id = d.device_id
JOIN Users u ON d.user_id = u.user_id
ORDER BY l.log_time DESC;

DELIMITER //
CREATE TRIGGER after_device_update
AFTER UPDATE ON Devices
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO Logs (device_id, action)
        VALUES (NEW.device_id, CONCAT('Device ', NEW.device_name, ' turned ', NEW.status));
    END IF;
END//
DELIMITER ;

-- Change status of a device to trigger log entry
UPDATE Devices SET status = 'ON' WHERE device_id = 1;

-- Check Logs Table
SELECT * FROM Logs;
