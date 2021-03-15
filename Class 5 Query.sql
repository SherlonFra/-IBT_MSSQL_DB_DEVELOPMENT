USE WideWorldImporters;
GO

-- NOW THE QUERY IS REUSABLE
SELECT TOP 100 * FROM Sales.Orders12MonthsMultipleItems;
GO

SELECT PersonId, IsPermittedToLogon, IsEmployee, IsSalesPerson
FROM [Application].People
GO

CREATE VIEW [Application].PeopleEmployeeStatus
AS
SELECT PersonId, IsPermittedToLogon, IsEmployee, IsSalesPerson,
	CASE WHEN IsPermittedToLogon = 1 THEN 'Can Logon' 
		ELSE 'Can''t Logon' END AS LogonRights,
	CASE WHEN IsEmployee = 1 AND IsSalesperson = 1 THEN 'Sales Person'
		 WHEN IsEmployee = 1 AND IsSalesPerson = 0 THEN 'Regular'
		 ELSE 'Not an Employee' END AS EmployeeType
FROM [Application].People;
GO

SELECT PersonId, LogonRights, EmployeeType FROM [Application].PeopleEmployeeStatus;
GO

CREATE SCHEMA Reports;
GO

-- DROP VIEW IF EXISTS Reports.InvoiceSummaryBasis;
CREATE VIEW Reports.InvoiceSummaryBasis
AS
SELECT Invoices.InvoiceId, CustomerCategories.CustomerCategoryName,
       Cities.CityName, StateProvinces.StateProvinceName,
       StateProvinces.SalesTerritory,
       Invoices.InvoiceDate,
       --the grain of the report is at the invoice, so total 
       --the amounts for invoice
       SUM(InvoiceLines.LineProfit) as InvoiceProfit,
       SUM(InvoiceLines.ExtendedPrice) as InvoiceExtendedPrice
FROM Sales.Invoices JOIN Sales.InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
     JOIN Sales.Customers ON Customers.CustomerID = Invoices.CustomerID
     JOIN Sales.CustomerCategories ON Customers.CustomerCategoryID = CustomerCategories.CustomerCategoryID
     JOIN Application.Cities ON Customers.DeliveryCityID = Cities.CityID
     JOIN Application.StateProvinces ON StateProvinces.StateProvinceID = Cities.StateProvinceID
GROUP BY Invoices.InvoiceId, CustomerCategories.CustomerCategoryName,
       Cities.CityName, StateProvinces.StateProvinceName,
       StateProvinces.SalesTerritory,
       Invoices.InvoiceDate;
GO

SELECT TOP 5 SalesTerritory, SUM(InvoiceProfit) AS InvoiceProfitTotal
FROM Reports.InvoiceSummaryBasis
WHERE InvoiceDate > '2016-05-01'
GROUP BY SalesTerritory
ORDER BY InvoiceProfitTotal DESC; -- 536,367.60
GO

SELECT TOP 5 StateProvinceName, CustomerCategoryName, 
       SUM(InvoiceExtendedPrice) AS InvoiceExtendedPriceTotal
FROM Reports.InvoiceSummaryBasis
WHERE InvoiceDate > '2016-05-01'
GROUP BY StateProvinceName, CustomerCategoryName
ORDER BY InvoiceExtendedPriceTotal DESC;
GO

USE Sherlon;
GO

CREATE TABLE Examples.Gadget
(
    GadgetId    int NOT NULL CONSTRAINT PKGadget PRIMARY KEY,
    GadgetNumber char(8) NOT NULL CONSTRAINT AKGadget UNIQUE,
    GadgetType  varchar(10) NOT NULL
);
GO

INSERT INTO Examples.Gadget(GadgetId, GadgetNumber, GadgetType)
VALUES  (1,'00000001','Electronic'),
        (2,'00000002','Manual'),
        (3,'00000003','Manual');
GO

CREATE VIEW Examples.ElectronicGadget
AS
	SELECT GadgetId, GadgetNumber, GadgetType,
			UPPER(GadgetType) AS UpperGadgetType
	FROM Examples.Gadget
	WHERE GadgetType = 'Electronic';
GO

SELECT * FROM Examples.Gadget;
GO
SELECT * FROM Examples.ElectronicGadget;
GO

SELECT ElectronicGadget.GadgetNumber as FromView, Gadget.GadgetNumber as FromTable,
        Gadget.GadgetType, ElectronicGadget.UpperGadgetType
FROM   Examples.ElectronicGadget
         FULL OUTER JOIN Examples.Gadget
            ON ElectronicGadget.GadgetId = Gadget.GadgetId;
GO

-- INSERT NEW VALUES
INSERT INTO Examples.ElectronicGadget (GadgetId, GadgetNumber, GadgetType)
VALUES (4, '00000004', 'Electronic'),
		(5, '00000005', 'Manual');

-- UPDATE VALUES out of the view
UPDATE Examples.ElectronicGadget
SET GadgetType = 'Manual'
WHERE GadgetNumber = '00000004'

-- UPDATE VALUES to appear in the view
UPDATE Examples.ElectronicGadget
SET GadgetType = 'Electronic'
WHERE GadgetNumber = '00000005'
GO

ALTER VIEW Examples.ElectronicGadget
AS
SELECT GadgetId, GadgetNumber, GadgetType,
			UPPER(GadgetType) AS UpperGadgetType
	FROM Examples.Gadget
	WHERE GadgetType = 'Electronic'
	WITH CHECK OPTION;
GO

INSERT INTO Examples.ElectronicGadget (GadgetId, GadgetNumber, GadgetType)
VALUES (6, '00000006', 'Manual');