-- Create Database
CREATE DATABASE SportsEventDB;
USE SportsEventDB;

-- Table: Venue
CREATE TABLE Venue (
    VenueID INT PRIMARY KEY AUTO_INCREMENT,
    VenueName VARCHAR(100),
    Location VARCHAR(100),
    Capacity INT
);

-- Table: Sport
CREATE TABLE Sport (
    SportID INT PRIMARY KEY AUTO_INCREMENT,
    SportName VARCHAR(100),
    Category VARCHAR(50) -- Indoor / Outdoor
);

-- Table: Team
CREATE TABLE Team (
    TeamID INT PRIMARY KEY AUTO_INCREMENT,
    TeamName VARCHAR(100),
    CoachName VARCHAR(100),
    SportID INT,
    FOREIGN KEY (SportID) REFERENCES Sport(SportID)
);

-- Table: Player
CREATE TABLE Player (
    PlayerID INT PRIMARY KEY AUTO_INCREMENT,
    PlayerName VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    TeamID INT,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

-- Table: Event
CREATE TABLE Event (
    EventID INT PRIMARY KEY AUTO_INCREMENT,
    EventName VARCHAR(100),
    SportID INT,
    VenueID INT,
    EventDate DATE,
    FOREIGN KEY (SportID) REFERENCES Sport(SportID),
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID)
);

-- Table: Result
CREATE TABLE Result (
    ResultID INT PRIMARY KEY AUTO_INCREMENT,
    EventID INT,
    WinnerTeamID INT,
    RunnerUpTeamID INT,
    FOREIGN KEY (EventID) REFERENCES Event(EventID),
    FOREIGN KEY (WinnerTeamID) REFERENCES Team(TeamID),
    FOREIGN KEY (RunnerUpTeamID) REFERENCES Team(TeamID)
);

-- Insert Data into Venue
INSERT INTO Venue (VenueName, Location, Capacity) VALUES
('National Stadium', 'City A', 20000),
('Indoor Sports Complex', 'City B', 5000);
SELECT * FROM Venue;

-- Insert Data into Sport
INSERT INTO Sport (SportName, Category) VALUES
('Football', 'Outdoor'),
('Badminton', 'Indoor');
SELECT * FROM Sport;

-- Insert Data into Team
INSERT INTO Team (TeamName, CoachName, SportID) VALUES
('City A Tigers', 'Rahul Mehra', 1),
('City B Warriors', 'Anita Sharma', 1),
('Shuttle Stars', 'Vikram Joshi', 2),
('Smash Masters', 'Priya Nair', 2);
SELECT * FROM Team;

-- Insert Data into Player
INSERT INTO Player (PlayerName, Age, Gender, TeamID) VALUES
('Amit Singh', 24, 'Male', 1),
('Rohit Verma', 22, 'Male', 1),
('Sneha Roy', 21, 'Female', 3),
('Pooja Gupta', 23, 'Female', 3),
('Karan Patel', 25, 'Male', 2),
('Nisha Rathi', 20, 'Female', 4);
SELECT * FROM Player;

-- Insert Data into Event
INSERT INTO Event (EventName, SportID, VenueID, EventDate) VALUES
('Intercity Football Final', 1, 1, '2025-06-10'),
('State Badminton Championship', 2, 2, '2025-06-15');
SELECT * FROM Event;

-- Insert Data into Result
INSERT INTO Result (EventID, WinnerTeamID, RunnerUpTeamID) VALUES
(1, 1, 2),
(2, 3, 4);
SELECT * FROM Result;

-- JOIN Query: Join Event and Result tables to get event results and teams
SELECT 
    e.EventID, 
    e.EventName, 
    t.TeamName AS "Winner Team",
    r.WinnerTeamID
FROM 
    Event e
JOIN 
    Result r ON e.EventID = r.EventID
JOIN 
    Team t ON r.WinnerTeamID = t.TeamID;
