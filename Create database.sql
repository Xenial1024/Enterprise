CREATE DATABASE Enterprise
GO

USE Enterprise
GO

CREATE TABLE Products 
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Price MONEY NULL
)
GO

CREATE TABLE Clients 
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(30) NULL,
    LastName NVARCHAR(50) NULL,
    City NVARCHAR(50) NULL,
    PhoneNumber VARCHAR(17) NULL,
    Email VARCHAR(60) NULL
)
GO

CREATE TABLE Invoices 
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Number VARCHAR(23) NULL,
    ClientNumber INT NOT NULL,
    CreatedDate DATE NOT NULL,
    CONSTRAINT FK_Invoices_Clients FOREIGN KEY (ClientNumber) REFERENCES Clients(Id)
)
GO

CREATE TABLE InvoicePositions 
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    InvoiceId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity SMALLINT NOT NULL,
    CONSTRAINT FK_InvoicePositions_Invoices FOREIGN KEY (InvoiceId) REFERENCES Invoices(Id),
    CONSTRAINT FK_InvoicePositions_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
)
GO

/*
CREATE TRIGGER trgGenerateInvoiceNumber
ON Invoices
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Invoices (ClientNumber, CreatedDate, Number)
    SELECT 
        i.ClientNumber, 
        i.CreatedDate,
        ''--'fv-' + FORMAT(i.CreatedDate, 'yyyyMMdd') + '-' + CAST(i.Id AS VARCHAR)
    FROM 
        inserted i;
END
GO
*/

CREATE TRIGGER trgGenerateInvoiceNumber
ON Invoices
AFTER INSERT
AS
BEGIN
    -- Aktualizacja numerów faktur
    UPDATE i
    SET Number = 'fv-' + FORMAT(i.CreatedDate, 'yyyyMMdd') + '-' + CAST(i.Id AS VARCHAR)
    FROM Invoices i
    INNER JOIN inserted ins ON i.Id = ins.Id;
END
GO

CREATE PROCEDURE AddClient
    @FirstName NVARCHAR(30) NULL,
    @LastName NVARCHAR(50) NULL,
    @City NVARCHAR(50) NULL,
    @PhoneNumber INT NULL,
    @Email VARCHAR(60) NULL
AS
BEGIN
    INSERT INTO Clients (FirstName, LastName, City, PhoneNumber, Email) 
    VALUES (@FirstName, @LastName, @City, @PhoneNumber, @Email)
END
GO

CREATE PROCEDURE UpdateClient
    @Id INT,
    @FirstName NVARCHAR(30) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @City NVARCHAR(50) = NULL,
    @PhoneNumber INT = NULL,
    @Email VARCHAR(60) = NULL
AS
BEGIN
	UPDATE Clients
	SET 
		FirstName = COALESCE(@FirstName, FirstName),
		LastName = COALESCE(@LastName, LastName),
		City = COALESCE(@City, City),
		PhoneNumber = COALESCE(@PhoneNumber, PhoneNumber),
		Email = COALESCE(@Email, Email)
	WHERE 
		Id = @Id
END
GO

CREATE PROCEDURE DeleteClient
    @Id INT
AS
BEGIN
DELETE FROM Clients
WHERE Id = @Id
END
GO

EXEC AddClient 'Jan', 'Lis', N'Kraków', '111222333', 'janlis@email.pl'
EXEC AddClient 'Ewa', 'Kot', N'Łódź', '123456789', 'ewcia@email.pl'
EXEC AddClient N'Rafał', N'Żukowski', 'Opole', '123456789', 'rafizuk@email.pl'
EXEC UpdateClient 
    @Id = 3,  
    @City = N'Gdańsk',
    @PhoneNumber = 112233456
EXEC DeleteClient 1
GO

INSERT INTO Products (Name, Price)
VALUES 
(N'lodówka',1400),
('czajnik',80),
('radio',40),
('mysz',20)

UPDATE Products
SET Price = 90 --inflacja
WHERE Name = 'czajnik'

UPDATE Products
SET Price = 1350 --promocja
WHERE Name = 'lodówka'

DELETE From Products
WHERE Name = 'radio'

INSERT INTO Invoices (ClientNumber, CreatedDate)
VALUES 
(2, GETDATE()),
(3, GETDATE()),
(2, GETDATE())


INSERT INTO InvoicePositions (InvoiceId, ProductId, Quantity)
VALUES 
    (1, 1, 2),  -- Faktura 1, Produkt 1 (lodówka), Ilość 2
    (1, 2, 3),  -- Faktura 1, Produkt 2 (czajnik), Ilość 3
    (2, 2, 1),  -- Faktura 2, Produkt 2 (czajnik), Ilość 1
    (2, 4, 5),  -- Faktura 2, Produkt 4 (mysz), Ilość 5
	(3, 4, 1)	-- Faktura 3, Produkt 4 (mysz), Ilość 1

