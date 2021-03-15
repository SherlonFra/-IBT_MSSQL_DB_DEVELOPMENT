USE WideWorldImporters;
GO

-- SLIDE 27 TO 45
SELECT CustomerId, OrderId, OrderDate, ExpectedDeliveryDate
FROM Sales.Orders
WHERE CustomerPurchaseOrderNumber = '16374';

USE [WideWorldImporters]
GO
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerPurchaseOrderNumber
ON [Sales].[Orders] ([CustomerPurchaseOrderNumber])
GO

SELECT SalespersonPersonId, OrderDate
FROM Sales.Orders
ORDER BY SalespersonPersonID ASC, OrderDate DESC

CREATE INDEX IDX_Orders_SalespersonPersonID_OrderDate
ON Sales.Orders (SalespersonPersonId ASC, OrderDate DESC)
GO

SELECT OrderId, OrderDate, ExpectedDeliveryDate, People.FullName
FROM Sales.Orders
	JOIN [Application].People
		ON People.PersonID = Orders.ContactPersonID
WHERE People.PreferredName = 'Aakriti';

 -- INDEXED COLUMN
USE [WideWorldImporters]
GO
CREATE NONCLUSTERED INDEX IDX_People_PreferredName
ON [Application].[People] ([PreferredName])
GO

-- INDEX WITH INCLUDED COLUMNS
CREATE NONCLUSTERED INDEX IDX_ContactPersonId_Include_OrderDate_ExpectedDeliveryDate
ON Sales.Orders (ContactPersonId)
INCLUDE (OrderDate, ExpectedDeliveryDate)
ON USERDATA; -- THE PLACE WHERE THESE INCLUDED COLUMNS ARE SAVED
GO

-- DROP INDEX IDX_People_PreferredName ON [Application].People;
CREATE NONCLUSTERED INDEX IDX_People_PreferredName
ON [Application].People (PreferredName)
INCLUDE (FullName)
ON USERDATA;
GO

CREATE VIEW Sales.Orders12MonthsMultipleItems
AS
SELECT OrderId, CustomerId, SalespersonPersonId, OrderDate, ExpectedDeliveryDate
FROM Sales.Orders
WHERE OrderDate >= DATEADD(Month, -12, '2016-12-31') --- DATEADD CALCULATES A DATE (TODAY - 12 MONTH)
AND (SELECT Count(*) FROM Sales.OrderLines WHERE OrderLines.OrderId = Orders.OrderId) > 1;
GO

-- NOW THE QUERY IS REUSABLE
SELECT * FROM Sales.Orders12MonthsMultipleItems;