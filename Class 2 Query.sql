  
USE Eduardo;

CREATE TABLE Examples.UniquenessConstraint
(
	PrimaryUniqueValue INT NOT NULL,
	AlternateUniqueValue1 INT NULL,
	AlternateUniqueValue2 INT NULL
);

INSERT INTO Examples.UniquenessConstraint VALUES (1,1,1);
INSERT INTO Examples.UniquenessConstraint VALUES (2,1,1);
INSERT INTO Examples.UniquenessConstraint VALUES (3,1,1);
-- SELECT * FROM Examples.UniquenessConstraint;
-- DELETE FROM Examples.UniquenessConstraint;

ALTER TABLE Examples.UniquenessConstraint
	ADD CONSTRAINT PKUniquenessConstraint PRIMARY KEY (PrimaryUniqueValue);
	
CREATE TABLE Examples.Invoice
(
	InvoiceId INT NOT NULL CONSTRAINT PKInvoice PRIMARY KEY
);
GO

CREATE TABLE Examples.DiscountType
(
	DiscountTypeId INT NOT NULL CONSTRAINT PKDiscountType PRIMARY KEY
);
GO
-- DROP TABLE IF EXISTS Examples.InvoiceLineItem;
CREATE TABLE Examples.InvoiceLineItem
(
	InvoiceLineItemId INT NOT NULL CONSTRAINT PKInvoiceLineItem PRIMARY KEY,
	InvoiceId INT NOT NULL CONSTRAINT FKInvoiceLineItem_Ref_Invoice REFERENCES Examples.Invoice (InvoiceId),
	DiscountTypeId INT NULL CONSTRAINT FKInvoiceLineItem_Ref_DiscountType REFERENCES Examples.DiscountType (DiscountTypeId)
);
GO

CREATE INDEX IDX_InvoiceLineItem_InvoiceId ON Examples.InvoiceLineItem (InvoiceId);
GO

CREATE INDEX IDX_InvoiceLineItem_DiscountTypeId ON Examples.InvoiceLineItem (DiscountTypeId)
	WHERE DiscountTypeId IS NOT NULL;
GO

CREATE UNIQUE INDEX IDX_InvoiceLineItem_InvoiceColumns ON Examples.InvoiceLineItem (InvoiceId, InvoiceLineItemId);
GO;

SELECT * FROM Examples.InvoiceLineItem WHERE DiscountTypeId IS NULL;
SELECT * FROM Examples.InvoiceLineItem WHERE DiscountTypeId = 100;

USE [WideWorldImporters];
GO

SELECT *
FROM Sales.CustomerTransactions
WHERE PaymentMethodID = 4;

-- CREATING RECOMMENDED INDEX
CREATE NONCLUSTERED INDEX IDX_CustomerTransactions_PaymentMethodId
ON [Sales].[CustomerTransactions] ([PaymentMethodID])
INCLUDE ([CustomerTransactionID],[CustomerID],[TransactionTypeID],[InvoiceID],[AmountExcludingTax],[TaxAmount],[TransactionAmount],[OutstandingBalance],[FinalizationDate],[IsFinalized],[LastEditedBy],[LastEditedWhen])
GO
