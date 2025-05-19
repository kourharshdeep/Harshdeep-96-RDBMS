-- Create the database
CREATE DATABASE FoodChainPortal;
USE FoodChainPortal;

-- Table: Restaurants
CREATE TABLE Restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    contact_number VARCHAR(15)
);

-- Table: Menus
CREATE TABLE Menus (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    item_name VARCHAR(100),
    price DECIMAL(10, 2),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
);

-- Table: Customers
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

-- Table: Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
);

-- Step 3: Insert sample data
INSERT INTO Restaurants (name, location, contact_number) VALUES 
('Pizza Palace', 'Downtown', '123-456-7890'),
('Burger Hub', 'Uptown', '987-654-3210');
SELECT *FROM Restaurants;

INSERT INTO Menus (restaurant_id, item_name, price) VALUES 
(1, 'Pepperoni Pizza', 12.99),
(1, 'Veggie Pizza', 10.99),
(2, 'Cheeseburger', 8.50),
(2, 'Chicken Burger', 9.00);
SELECT *FROM Menus;

INSERT INTO Customers (name, email, phone) VALUES 
('John Doe', 'john@example.com', '111-222-3333'),
('Jane Smith', 'jane@example.com', '444-555-6666');
SELECT *FROM Customers;

INSERT INTO Orders (customer_id, restaurant_id, total_amount) VALUES 
(1, 1, 12.99),
(2, 2, 8.50);
SELECT *FROM Orders;

-- Step 4: Triggers
DELIMITER //
CREATE TRIGGER update_total_amount
AFTER INSERT ON Menus
FOR EACH ROW
BEGIN
    UPDATE Orders 
    SET total_amount = (SELECT SUM(price) FROM Menus WHERE restaurant_id = NEW.restaurant_id)
    WHERE order_id = (SELECT MAX(order_id) FROM Orders WHERE restaurant_id = NEW.restaurant_id);
END //
DELIMITER ;

-- Step 5: Join queries
-- Join to get order details with customer and restaurant names
SELECT o.order_id, c.name AS customer_name, r.name AS restaurant_name, o.total_amount
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id;
