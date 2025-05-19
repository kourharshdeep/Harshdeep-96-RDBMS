-- Create Database
CREATE DATABASE SupplyChainManagement;
USE SupplyChainManagement;

-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(100),
    ContactName VARCHAR(100),
    ContactEmail VARCHAR(100),
    ContactPhone VARCHAR(15),
    Location VARCHAR(150)
);

-- Product Table
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2),
    QuantityInStock INT
);

-- PurchaseOrder Table
CREATE TABLE PurchaseOrder (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierID INT,
    OrderDate DATE,
    Status VARCHAR(50), -- Pending, Delivered, Canceled
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

-- PurchaseOrderDetails Table (Many-to-many relation between PurchaseOrders and Products)
CREATE TABLE PurchaseOrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES PurchaseOrder(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Inventory Table
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    Quantity INT,
    LastUpdated DATE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- SalesOrder Table
CREATE TABLE SalesOrder (
    SalesOrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100),
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    Status VARCHAR(50), -- Pending, Completed, Canceled
    ShippingAddress VARCHAR(150)
);

-- SalesOrderDetails Table (Many-to-many relation between SalesOrders and Products)
CREATE TABLE SalesOrderDetails (
    SalesOrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    SalesOrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Shipment Table
CREATE TABLE Shipment (
    ShipmentID INT PRIMARY KEY AUTO_INCREMENT,
    SalesOrderID INT,
    ShipmentDate DATE,
    ShippingMethod VARCHAR(50),
    TrackingNumber VARCHAR(100),
    Status VARCHAR(50), -- In Transit, Delivered
    FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID)
);

-- Insert Data into Supplier Table
INSERT INTO Supplier (SupplierName, ContactName, ContactEmail, ContactPhone, Location)
VALUES 
('Global Supplies Inc.', 'Alice Johnson', 'alice@globalsupplies.com', '1234567890', 'New York'),
('Prime Traders', 'Bob Smith', 'bob@primetraders.com', '9876543210', 'Los Angeles');
SELECT *FROM Supplier;

-- Insert Data into Product Table
INSERT INTO Product (ProductName, Category, Price, QuantityInStock)
VALUES 
('LED Monitor', 'Electronics', 150.00, 50),
('Wireless Mouse', 'Accessories', 25.00, 200),
('Mechanical Keyboard', 'Accessories', 75.00, 120);
SELECT *FROM Product;

-- Insert Data into PurchaseOreder Table
INSERT INTO PurchaseOrder (SupplierID, OrderDate, Status, TotalAmount)
VALUES 
(1, '2025-05-10', 'Delivered', 3000.00),
(2, '2025-05-12', 'Pending', 1875.00);
SELECT *FROM PurchaseOrder;

-- Insert Data into PurchaseOrderDetails Table
INSERT INTO PurchaseOrderDetails (OrderID, ProductID, Quantity, UnitPrice)
VALUES 
(1, 1, 10, 150.00),  -- 10 LED Monitors
(1, 2, 40, 25.00),   -- 40 Wireless Mouse
(2, 3, 25, 75.00);   -- 25 Mechanical Keyboards

SELECT *FROM PurchaseOrderDetails;

-- Insert Data into Inventory Table
INSERT INTO Inventory (ProductID, Quantity, LastUpdated)
VALUES 
(1, 50, '2025-05-01'),
(2, 150, '2025-05-01'),
(3, 100, '2025-05-01');

SELECT *FROM Inventory;

-- Insert Data into SalesOrder Table
INSERT INTO SalesOrder (CustomerName, OrderDate, TotalAmount, Status, ShippingAddress)
VALUES 
('John Doe', '2025-05-15', 500.00, 'Pending', '123 Elm St, Seattle'),
('Jane Smith', '2025-05-16', 1125.00, 'Completed', '456 Oak Ave, San Francisco');

SELECT *FROM SalesOrder;

-- Insert Data into SalesOrderDetails Table
INSERT INTO SalesOrderDetails (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
(1, 2, 10, 25.00),  -- 10 Wireless Mouse
(2, 3, 15, 75.00);  -- 15 Mechanical Keyboards

SELECT *FROM SalesOrderDetails;

-- Insert Data into Shipment Table
INSERT INTO Shipment (SalesOrderID, ShipmentDate, ShippingMethod, TrackingNumber, Status)
VALUES 
(1, '2025-05-16', 'FedEx', 'FX1234567890', 'In Transit'),
(2, '2025-05-17', 'UPS', 'UPS9876543210', 'Delivered');

SELECT *FROM Shipment;

-- JOIN Query 1: Get purchase order details, products ordered, and supplier information
SELECT 
    po.OrderID, 
    po.OrderDate, 
    po.Status AS OrderStatus, 
    s.SupplierName, 
    p.ProductName, 
    pod.Quantity, 
    pod.UnitPrice, 
    (pod.Quantity * pod.UnitPrice) AS TotalAmount
FROM 
    PurchaseOrder po
JOIN 
    PurchaseOrderDetails pod ON po.OrderID = pod.OrderID
JOIN 
    Product p ON pod.ProductID = p.ProductID
JOIN 
    Supplier s ON po.SupplierID = s.SupplierID;

-- JOIN Query 2: Get sales order details, products ordered, and shipment status
SELECT 
    so.SalesOrderID, 
    so.OrderDate, 
    so.Status AS SalesOrderStatus, 
    so.CustomerName, 
    p.ProductName, 
    sod.Quantity, 
    sod.UnitPrice, 
    (sod.Quantity * sod.UnitPrice) AS TotalAmount, 
    sh.Status AS ShipmentStatus
FROM 
    SalesOrder so
JOIN 
    SalesOrderDetails sod ON so.SalesOrderID = sod.SalesOrderID
JOIN 
    Product p ON sod.ProductID = p.ProductID
JOIN 
    Shipment sh ON so.SalesOrderID = sh.SalesOrderID;
-- Trigger 1: Automatically update Inventory when a product is received from the supplier
DELIMITER //

CREATE TRIGGER after_purchase_order_insert
AFTER INSERT ON PurchaseOrderDetails
FOR EACH ROW
BEGIN
    DECLARE current_quantity INT;
    
    -- Check the current inventory quantity
    SELECT Quantity INTO current_quantity 
    FROM Inventory 
    WHERE ProductID = NEW.ProductID;
    
    -- If the product exists in inventory, update the quantity
    IF current_quantity IS NOT NULL THEN
        UPDATE Inventory
        SET Quantity = Quantity + NEW.Quantity
        WHERE ProductID = NEW.ProductID;
    ELSE
        -- If the product doesn't exist in inventory, insert a new record
        INSERT INTO Inventory (ProductID, Quantity, LastUpdated) 
        VALUES (NEW.ProductID, NEW.Quantity, NOW());
    END IF;
END //

DELIMITER ;

-- Trigger 2: Automatically update product stock when a sales order is placed
DELIMITER //

CREATE TRIGGER after_sales_order_insert
AFTER INSERT ON SalesOrderDetails
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    
    -- Check the current stock for the ordered product
    SELECT Quantity INTO current_stock
    FROM Inventory
    WHERE ProductID = NEW.ProductID;
    
    -- If enough stock exists, decrease the stock
    IF current_stock >= NEW.Quantity THEN
        UPDATE Inventory
        SET Quantity = Quantity - NEW.Quantity, LastUpdated = NOW()
        WHERE ProductID = NEW.ProductID;
    ELSE
        -- If not enough stock, raise an error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock for this product';
    END IF;
END //

DELIMITER ;