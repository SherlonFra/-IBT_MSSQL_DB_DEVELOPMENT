USE Sherlon;
GO

-- Parent Table: Invoice owns InvoiceLineItems
-- DROP TABLE IF EXISTS Examples.Invoice;
CREATE TABLE Examples.Invoice 
(
	InvoiceId INT NOT NULL PRIMARY KEY
	-- SOME MORE COLUMNS
);
GO
-- Child Table: it is associated to Invoice through a Foreign Key constraint
-- DROP TABLE IF EXISTS Examples.InvoiceLineItem;
CREATE TABLE Examples.InvoiceLineItem
(
	InvoiceLineItemId INT NOT NULL PRIMARY KEY,
	InvoiceLineNumber SMALLINT NOT NULL,
	InvoiceId INT NOT NULL
		CONSTRAINT FKInvoiceLineItem_Ref_Invoice
			REFERENCES Examples.Invoice(InvoiceId)
				ON DELETE CASCADE
				ON UPDATE NO ACTION,
	CONSTRAINT AKInvoiceLineItemCombination UNIQUE (InvoiceId, InvoiceLineNumber)
);
GO

INSERT INTO Examples.Invoice (InvoiceId) VALUES (1), (2), (3);

INSERT INTO Examples.InvoiceLineItem (InvoiceLineItemId, InvoiceId, InvoiceLineNumber)
VALUES (1,1,1),(2,1,2),(3, 2, 1)

-- JOIN the two tables to see their relationship
SELECT *
FROM Examples.Invoice 
	FULL OUTER JOIN Examples.InvoiceLineItem ON Invoice.InvoiceId = InvoiceLineItem.InvoiceId;

-- ON DELETE CASCADE >> deletes one record from Invoice and 2 from InvoiceLineItem
DELETE Examples.Invoice WHERE InvoiceId = 1;
-- ON UPDATE NO ACTION >> fails with error: The UPDATE statement conflicted with the REFERENCE constraint "FKInvoiceLineItem_Ref_Invoice"
UPDATE Examples.Invoice SET InvoiceId = 4 WHERE InvoiceId = 2;
-- ON UPDATE NO ACTION >> successful since InvoiceId 3 does not have any records associated in InvoiceLineItem
UPDATE Examples.Invoice SET InvoiceId = 4 WHERE InvoiceId = 3;

-- Catalog table to store unique codes
CREATE TABLE Examples.Code
(
	Code VARCHAR(10) NOT NULL PRIMARY KEY
);
GO

-- Items that are associated with codes
CREATE TABLE Examples.CodedItem
(
	-- Related columns such as name, description, etc.
	Code VARCHAR(10) NOT NULL
		CONSTRAINT FKCodedItem_Ref_Code
			REFERENCES Examples.Code (Code) 
				ON UPDATE CASCADE
);

-- For this example, my code has a typo
INSERT INTO Examples.Code (Code) VALUES ('Blacke');
-- Use incorrect value in CodedItem
INSERT INTO Examples.CodedItem (Code) VALUES ('Blacke');

SELECT Code.Code, CodedItem.Code AS CodedItemCode
FROM Examples.Code FULL OUTER JOIN Examples.CodedItem ON Code.Code = CodedItem.Code;

-- Fix typo in code in both tables by updating the parent
UPDATE Examples.Code
SET Code = 'BLACK'
WHERE Code = 'Blacke';

-- Using catalog tables to limit values to a list
CREATE TABLE Examples.Attendee
(
	-- SOME OTHER COLUMNS: FirstName, LastName, etc.
	ShirtSize VARCHAR(8) NULL
);
GO

-- Shirt Sizes should be XS S M L XL XXL, but users can insert any value at this point
INSERT INTO Examples.Attendee VALUES ('SM');
INSERT INTO Examples.Attendee VALUES ('MED');

-- Inconsistent and unreadable data
SELECT * FROM Examples.Attendee;

-- APPROACH 1 CHECK Constraint
DELETE FROM Examples.Attendee;

ALTER TABLE Examples.Attendee
	ADD CONSTRAINT CHKAttendee_ShirtSizeDomain
		CHECK (ShirtSize IN ('S', 'M', 'L', 'XL'));

-- FAILS 
INSERT INTO Examples.Attendee VALUES ('SM');
-- SUCCESS
INSERT INTO Examples.Attendee VALUES ('S');

-- Suddenly we decided to also provide XS and XXL
-- What can be done?
-- DROP constraint and recreate it
-- If data changes a lot, it is better to use a catalog table
CREATE TABLE Examples.ShirtSize
(
	ShirtSize VARCHAR(8) NOT NULL PRIMARY KEY
);
GO
-- Now insert valid values
INSERT INTO Examples.ShirtSize (ShirtSize) VALUES ('S'), ('M'), ('L'), ('XL');
-- DROP the constraint and add the foreign key
ALTER TABLE Examples.Attendee
	DROP CONSTRAINT CHKAttendee_ShirtSizeDomain;
ALTER TABLE Examples.Attendee
	ADD CONSTRAINT FKAttendee_Ref_ShirtSize FOREIGN KEY (ShirtSize) REFERENCES Examples.ShirtSize (ShirtSize);

-- What if we want to expand the options?
INSERT INTO Examples.Attendee (ShirtSize) VALUES ('XS');

-- I can just add new values and make them available
INSERT INTO Examples.ShirtSize (ShirtSize) VALUES ('XS'), ('XXL');
INSERT INTO Examples.Attendee (ShirtSize) VALUES ('XS');