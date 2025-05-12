-- Step 1: Create the Database
CREATE DATABASE BankingSystem;
USE BankingSystem;

-- Step 2: Create the Tables

-- 2.1 Create Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    address TEXT,
    date_of_birth DATE
);

-- 2.2 Create Accounts Table
CREATE TABLE Accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_number VARCHAR(20) UNIQUE,
    account_type ENUM('Checking', 'Savings', 'Business'),
    balance DECIMAL(15, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 2.3 Create Transactions Table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account_id INT,
    to_account_id INT,
    amount DECIMAL(15, 2),
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer'),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account_id) REFERENCES Accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES Accounts(account_id)
);

-- Step 3: Insert Sample Customers
INSERT INTO Customers (first_name, last_name, email, phone_number, address, date_of_birth)
VALUES 
('John', 'Doe', 'john.doe@example.com', '1234567890', '123 Elm Street, Springfield', '1985-03-15'),
('Jane', 'Smith', 'jane.smith@example.com', '0987654321', '456 Oak Street, Springfield', '1990-07-25');

-- Step 4: Insert Sample Accounts
INSERT INTO Accounts (customer_id, account_number, account_type, balance)
VALUES 
(1, '1000000001', 'Checking',15000.00),
(1, '1000000002', 'Savings',25000.00),
(2, '2000000001', 'Checking',13000.00);

-- Step 5: Insert Sample Transactions

-- 5.1 Deposit $1000 to John's Savings account (account_number 1000000002)
INSERT INTO Transactions (from_account_id, to_account_id, amount, transaction_type)
VALUES (NULL, 2, 1000.00, 'Deposit');

-- 5.2 Withdraw $500 from John's Checking account (account_number 1000000001)
INSERT INTO Transactions (from_account_id, to_account_id, amount, transaction_type)
VALUES (1, NULL, 500.00, 'Withdrawal');

-- 5.3 Transfer $200 from John's Checking account to Jane's Checking account
INSERT INTO Transactions (from_account_id, to_account_id, amount, transaction_type)
VALUES (1, 3, 200.00, 'Transfer');

-- Step 6: Create Trigger to Update Balances After Each Transaction
DELIMITER $$

CREATE TRIGGER UpdateBalanceAfterTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    -- Update balance for Deposit (to_account_id)
    IF NEW.transaction_type = 'Deposit' THEN
        UPDATE Accounts 
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.to_account_id;

    -- Update balance for Withdrawal (from_account_id)
    ELSEIF NEW.transaction_type = 'Withdrawal' THEN
        UPDATE Accounts 
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.from_account_id;

    -- Update balance for Transfer (both from and to accounts)
    ELSEIF NEW.transaction_type = 'Transfer' THEN
        -- Deduct from the source account (from_account_id)
        UPDATE Accounts 
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.from_account_id;

        -- Add to the destination account (to_account_id)
        UPDATE Accounts 
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.to_account_id;
    END IF;
END$$

DELIMITER ;

-- Step 7: Check the Updated Account Balances

-- Example: Check balance of John's Checking account (account_number 1000000001)
SELECT account_number, balance
FROM Accounts
WHERE account_number = '1000000001';

-- Example: Check balance of John's Savings account (account_number 1000000002)
SELECT account_number, balance
FROM Accounts
WHERE account_number = '1000000002';

-- Example: Check balance of Jane's Checking account (account_number 2000000001)
SELECT account_number, balance
FROM Accounts
WHERE account_number = '2000000001';

-- Step 8: Transaction History Query

-- Example: View all transactions for John's Checking account (account_number 1000000001)
SELECT 
    t.transaction_id,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    a.account_number
FROM Transactions t
JOIN Accounts a ON (a.account_id = t.from_account_id OR a.account_id = t.to_account_id)
WHERE a.account_number = '1000000001'
ORDER BY t.transaction_date DESC;
SHOW TRIGGERS;

-- Step 9: Additional Queries (Optional)

-- 9.1 View All Customers
SELECT * FROM Customers;

-- 9.2 View All Accounts
UPDATE Accounts
SET balance = balance + 1000
WHERE account_number = '1000000002';  -- Assuming this is the correct account for the deposit

UPDATE Accounts
SET balance = balance - 500
WHERE account_number = '1000000001';  -- For withdrawal

UPDATE Accounts
SET balance = balance + 200
WHERE account_number = '2000000001';  -- For transfer to Jane's account
SELECT * FROM Accounts;

-- 9.3 View All Transactions
SELECT * FROM Transactions;
