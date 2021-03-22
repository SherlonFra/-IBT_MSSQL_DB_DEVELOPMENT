USE Sherlon;
GO

DROP TABLE IF EXISTS Examples.Widget;
CREATE TABLE Examples.Widget
(
	WidgetId INT CONSTRAINT PKWidget PRIMARY KEY,
	RowlastModifiedTime DATETIME2(0) NOT NULL
);
GO

INSERT INTO Examples.Widget (WidgetId, RowLastModifiedTime)
VALUES (1, SYSDATETIME());
INSERT INTO Examples.Widget (WidgetId)
VALUES (1);

ALTER TABLE Examples.Widget
	ADD CONSTRAINT DFLTWidget_RowLastModifiedTime
		DEFAULT (SYSDATETIME()) FOR RowLastModifiedTime;
GO

--Select * FROM Examples.Widget;
INSERT INTO Examples.Widget(WidgetId)
VALUES (2);
INSERT INTO Examples.Widget(WidgetId)
VALUES(3);
GO

UPDATE Examples.Widget
SET RowlastModifiedTime = DEFAULT;
-- NO ID SO I'LL UPDATE ALL THE RECORDS IN THE TABLE

ALTER TABLE Examples.Widget
	ADD EnableFlag BIT NOT NULL
	CONSTRAINT DFLWidget_EnableFlag DEFAULT(1);


--DROP TABLE Examples.ALLDefaulted
CREATE TABLE Examples.ALLDefaulted
(
	AllDefaultedId INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	RowCreatedTime DATETIME2(0) NOT NULL CONSTRAINT DFLALLDefaulted_RowCreatedTime DEFAULT(SYSDATETIME()),
	RowModifiedTime DATETIME2(0) NOT NULL CONSTRAINT DFLTALLDefault_RowModifiedTime DEFAULT(SYSDATETIME())
);
GO
--run a couple times
INSERT INTO Examples.AllDefaulted
DEFAULT VALUES;

SELECT*FROM Examples.ALLDefaulted

CREATE TABLE Examples.GadgetCatalog
(
	GadgetId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	GadgetCode VARCHAR(10) NOT NULL
);
GO

--still not unique...
INSERT INTO Examples.GadgetCatalog
VALUES ('Gadget'),('Gadget'),('Gadget');
GO

SELECT*FROM Examples.GadgetCatalog;

DELETE FROM Examples.GadgetCatalog WHERE GadgetId IN (2,3);

ALTER TABLE Examples.GadgetCatalog
	ADD CONSTRAINT AKGadgetCatalog UNIQUE (GadgetCode);

INSERT INTO Examples.GadgetCatalog
VALUES ('Widget'), ('Box'), ('Tool');

-- BY USING INT we are limiting 

CREATE TABLE Examples.GroceryItem
(
	ItemCost SMALLMONEY NULL 
		CONSTRAINT CHKGroceryItem_ItemCost_ValidRange CHECK (ItemCost > 0 AND ItemCost < 1000)

);
GO

--Fails with message: The INSERT statement conflicted with the CHECK constraint
--  "CHKGroceryItems_ItemCost_ValidRnage",
INSERT INTO Examples.GroceryItem VALUES (3000.95);
--sUCCESSFUL
INSERT INTO Examples.GroceryItem VALUES (100.99);

--Limit the format of a Value
CREATE TABLE Examples.Message
(
	MessageTag CHAR(5) NOT NULL,
	Comment NVARCHAR(MAX) NULL
);
GO

SELECT * FROM Examples.Message;

ALTER TABLE Examples. Message
	ADD CONSTRAINT CHKMessage_MessageTagFormat CHECK (MessageTag LIKE '[A-Z]-[0-9][0-9][0-9]');

ALTER TABLE Examples.Message
	ADD CONSTRAINT CHKMessage_CommentNotEmpty CHECK (LEN(Comment) > 0);

--INCORRECT MESSAGE
INSERT INTO Examples.Message (MessageTag, Comment) VALUES ('BAD','');
--SUCCESSFUL
INSERT INTO Examples.Message (MessageTag, Comment) VALUES ('A-123', 'no comment');
GO

--Coordinating values in two columns
--DROP TABLE Examples.Customer
CREATE TABLE Examples.Customer
(
	ForcedDisabledFlag BIT NOT NULL,
	ForcedEnabledFlag BIT NOT NULL,
	--0-0 doesnt make sense
	CONSTRAINT CHKCustomer_ForceStatusFlagCheckTrue CHECK (NOT(ForcedDisabledFlag= 1 AND ForcedEnabledFlag=1)),
	CONSTRAINT CHKCustomer_ForceStatusFlagCheckFalse CHECK (NOT(ForcedDisabledFlag= 0 AND ForcedEnabledFlag = 0))
);
GO

INSERT INTO Examples.Customer VALUES (0,0);
INSERT INTO Examples.Customer VALUES (1,1);
--Sucessful
INSERT INTO Examples.Customer VALUES (0,1);

SELECT*FROM Examples.Customer;
--fail
UPDATE Examples.Customer SET ForcedEnabledFlag = 0;
--successful
UPDATE Examples.Customer SET ForcedEnabledFlag = 0, ForcedDisabledFlag = 1;