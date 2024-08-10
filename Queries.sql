USE Enterprise
GO

--Wyświetl numer faktury, imię i nazwisko klienta.

SELECT 
	i.Number AS [Numer faktury],
	c.FirstName AS Imię,
	c.LastName AS Nazwisko
FROM
	Enterprise.dbo.Invoices i
INNER JOIN 
	Enterprise.dbo.Clients c 
ON 
	c.Id = i.ClientNumber

--Wyświetl wszystkie pozycje z numerem faktury, nazwą produktu oraz ceną.

SELECT 
	i.Number AS [Numer faktury],
	p.Name AS [Nazwa produktu],
    p.Price AS [Cena za sztukę]
FROM 
	Enterprise.dbo.InvoicePositions ip
INNER JOIN 
    Enterprise.dbo.Invoices i ON ip.InvoiceId = i.Id
INNER JOIN
Enterprise.dbo.Products p ON ip.ProductId = p.Id

--Wyświetl numery faktur wraz z sumą ilości produktów (wszystkie sztuki) na tej fakturze.

SELECT 
	i.Number AS [Numer faktury],
	SUM(ip.Quantity) AS [Liczba produktów]
FROM
	Enterprise.dbo.Invoices i 
INNER JOIN 
    Enterprise.dbo.InvoicePositions ip ON ip.InvoiceId = i.Id
GROUP BY 
    i.Number

--Wyświetl numery faktur wraz z ceną całkowitą.

SELECT 
	i.Number AS [Numer faktury],
	SUM(ip.Quantity*p.Price) AS [Całkowita cena]
FROM
	Enterprise.dbo.Invoices i
INNER JOIN 
    Enterprise.dbo.InvoicePositions ip ON ip.InvoiceId = i.Id
INNER JOIN
Enterprise.dbo.Products p ON ip.ProductId = p.Id
GROUP BY 
    i.Number
