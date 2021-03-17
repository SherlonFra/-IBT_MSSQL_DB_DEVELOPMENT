USE Sherlon;
GO

CREATE TABLE Examples.GadgetType
(
	GadgetType VARCHAR(10) NOT NULL PRIMARY KEY,
	Description VARCHAR(200) NOT NULL
);
GO

SELECT * FROM Examples.GadgetType;

INSERT INTO Examples.GadgetType (GadgetType, Description)
VALUES ('Manual', 'No batteries'),
		('Electronic', 'Lots of batteries');

ALTER TABLE Examples.Gadget
	ADD CONSTRAINT FKGadget_GadgetType
	FOREIGN KEY (GadgetType) REFERENCES Examples.GadgetType (GadgetType);
GO

CREATE VIEW Examples.GadgetExtension
AS
	SELECT Gadget.GadgetId, Gadget.GadgetNumber, Gadget.GadgetType,
			GadgetType.GadgetType AS DomainGadgetType, GadgetType.Description AS GadgetTypeDescription
	FROM Examples.Gadget JOIN Examples.GadgetType ON Gadget.GadgetType = GadgetType.GadgetType;
GO

SELECT * FROM Examples.GadgetExtension;

INSERT INTO Examples.GadgetExtension(GadgetId, GadgetNumber, GadgetType, DomainGadgetType, GadgetTypeDescription)
VALUES(7,'00000007','Acoustic','Acoustic','Sound');
GO


INSERT INTO Examples.GadgetExtension(DomainGadgetType, GadgetTypeDescription)
VALUES('Acoustic','Sound');
GO



INSERT INTO Examples.GadgetExtension(GadgetId, GadgetNumber, GadgetType)
VALUES(7,'00000007','Acoustic');
GO


UPDATE Examples.GadgetExtension
SET GadgetTypeDescription = 'Uses AA batteries'
WHERE GadgetId = 1;


DELETE FROM Examples.GadgetExtension 
WHERE GadgetId = 1;


CREATE TABLE Examples.Invoices_NorthAmerica
(
	InvoiceId INT NOT NULL PRIMARY KEY 
		CONSTRAINT CHK_Invoices_PartKey1 CHECK (InvoiceId BETWEEN 1 AND 10000),
	CustomerId INT NOT NULL,
	InvoiceDate DATE NOT NULL
);
GO

CREATE TABLE Examples.Invoices_Europe
(
	InvoiceId INT NOT NULL PRIMARY KEY 
		CONSTRAINT CHK_Invoices_PartKey2 CHECK (InvoiceId BETWEEN 10001 AND 20000),
	CustomerId INT NOT NULL,
	InvoiceDate DATE NOT NULL
);
GO

INSERT INTO Examples.Invoices_NorthAmerica (InvoiceId, CustomerId, InvoiceDate)
SELECT InvoiceId, CustomerId, InvoiceDate
FROM WideWorldImporters.Sales.Invoices 
WHERE InvoiceId BETWEEN 1 AND 10000;

INSERT INTO Examples.Invoices_Europe (InvoiceId, CustomerId, InvoiceDate)
SELECT InvoiceId, CustomerId, InvoiceDate
FROM WideWorldImporters.Sales.Invoices
WHERE InvoiceID BETWEEN 10001 AND 20000;

SELECT * FROM Examples.Invoices_NorthAmerica;
SELECT * FROM Examples.Invoices_Europe;
GO

CREATE VIEW Examples.InvoicesPartitioned
AS
	SELECT InvoiceId, CustomerId, InvoiceDate
	FROM Examples.Invoices_NorthAmerica
	UNION ALL
	SELECT InvoiceId, CustomerId, InvoiceDate
	FROM Examples.Invoices_Europe;
GO


SELECT * FROM Examples.InvoicesPartitioned WHERE InvoiceId = 5000;


SELECT * FROM Examples.InvoicesPartitioned WHERE InvoiceDate = '2013-01-01';

USE WideWorldImporters;
GO


CREATE VIEW Sales.InvoiceCustomerInvoiceAggregates
WITH SCHEMABINDING
AS
SELECT Invoices.CustomerId,
       SUM(ExtendedPrice * Quantity) AS SumCost,
       SUM(LineProfit) AS SumProfit,
       COUNT_BIG(*) AS TotalItemCount 
FROM  Sales.Invoices
          JOIN Sales.InvoiceLines
                 ON  Invoices.InvoiceID = InvoiceLines.InvoiceID
GROUP  BY Invoices.CustomerID;
GO

SELECT *
FROM   Sales.InvoiceCustomerInvoiceAggregates;
GO

CREATE UNIQUE CLUSTERED INDEX XPKInvoiceCustomerInvoiceAggregates on Sales.InvoiceCustomerInvoiceAggregates(CustomerID);
GO