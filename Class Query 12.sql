USE Sherlon;
GO

-- Business requirement: Each account can only have one primary contact. That is one record where primarycontactflag is 1.
CREATE TABLE Examples.AccountContact
(
	AccountContactId INT NOT NULL PRIMARY KEY,
	AccountId CHAR(4) NOT NULL,
	PrimaryContactFlag BIT NOT NULL
);
GO

-- SELECT statement to check that I have more than one primary contacts
SELECT AccountId, SUM(CASE WHEN PrimaryContactFlag = 1 THEN 1 ELSE 0 END) AS Count
FROM Examples.AccountContact
GROUP BY AccountId
HAVING SUM(CASE WHEN PrimaryContactFlag = 1 THEN 1 ELSE 0 END) <> 1;
GO

CREATE TRIGGER Examples.AccountContact_TriggerAfterInsertUpdate
ON Examples.AccountContact
AFTER INSERT, UPDATE
AS
	SET NOCOUNT ON;
	SET ROWCOUNT 0; 
	BEGIN TRY
		IF EXISTS (SELECT AccountId
					FROM Examples.AccountContact
					WHERE EXISTS (					
							SELECT * FROM inserted WHERE inserted.AccountId = AccountContact.AccountId
							UNION ALL
							SELECT * FROM deleted WHERE deleted.AccountId = AccountContact.AccountId					
						)
					GROUP BY AccountId
					HAVING SUM(CASE WHEN PrimaryContactFlag = 1 THEN 1 ELSE 0 END) <> 1)
			THROW 50000, 'Accounts do not have only one primary contact.', 1;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
GO

--Success, 1 row
INSERT INTO Examples.AccountContact(AccountContactId, AccountId, PrimaryContactFlag)
VALUES (1,1,1);
--Success, two rows
INSERT INTO Examples.AccountContact(AccountContactId, AccountId, PrimaryContactFlag)
VALUES (2,2,1),(3,3,1);
--Two rows, same account
INSERT INTO Examples.AccountContact(AccountContactId, AccountId, PrimaryContactFlag)
VALUES (4,4,1),(5,4,0);
--Invalid, two contacts, same account, both contacts are primary
INSERT INTO Examples.AccountContact(AccountContactId, AccountId, PrimaryContactFlag)
VALUES (6,5,1),(7,5,1);
GO
--Invalid, no primary
INSERT INTO Examples.AccountContact(AccountContactId, AccountId, PrimaryContactFlag)
VALUES (8,6,0),(9,6,0);
GO

SELECT * FROM Examples.AccountContact;


-- Adding verification in response to an action
CREATE TABLE Examples.Promise
(
	PromiseId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	PromiseAmount MONEY NOT NULL
);
GO

CREATE TABLE Examples.VerifyPromise
(
	VerifyPromiseId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	PromiseId INT NOT NULL UNIQUE
);
GO


CREATE TRIGGER Examples.Promise_TriggerInsertUpdate
ON Examples.Promise
AFTER INSERT, UPDATE
AS
	SET NOCOUNT ON;
	SET ROWCOUNT 0;
	BEGIN TRY
		INSERT INTO Examples.VerifyPromise
		SELECT PromiseId
		FROM inserted -- inserted values
		WHERE PromiseAmount > 10000.00
			AND NOT EXISTS (
				SELECT * FROM VerifyPromise WHERE VerifyPromise.PromiseId = inserted.PromiseId
			)
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
GO

-- No need to verify
INSERT INTO Examples.Promise VALUES (100); 
-- No need to verify
INSERT INTO Examples.Promise VALUES (1000); 
-- Just there 
INSERT INTO Examples.Promise VALUES (10000); 
-- Needs verification
INSERT INTO Examples.Promise VALUES (10001); 

SELECT * FROM Examples.Promise;
SELECT * FROM Examples.VerifyPromise;


-- Ensuring columnar data is modified
CREATE TABLE Examples.Items
(
	ItemId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Value VARCHAR(100) NOT NULL,
	RowCreatedDateTime DATETIME2(0) NOT NULL DEFAULT(SYSDATETIME()), -- date and time when record was created
	RowLastModifiedDateTime DATETIME2(0) NOT NULL DEFAULT(SYSDATETIME()) -- date and time when record was created or updated for the last time
);
GO

SELECT SYSDATETIME();
GO

CREATE TRIGGER Examples.Items_TriggerInsteadOfInsert
ON Examples.Items
INSTEAD OF INSERT
AS
	SET NOCOUNT ON;
	SET ROWCOUNT 0;
	BEGIN TRY
		INSERT INTO Examples.Items ([Value])
		SELECT [Value]
		FROM inserted;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;
		THROW
	END CATCH
GO

-- Two invalid date time values
INSERT INTO Examples.Items(Value, RowCreatedDateTime, RowLastModifiedDateTime)
VALUES ('Monitor','1900-01-01','1900-01-01');
GO
-- One invalid date time value
INSERT INTO Examples.Items(Value, RowCreatedDateTime)
VALUES ('Keyboard','1900-01-01');
GO
-- Only value
INSERT INTO Examples.Items(Value)
VALUES ('Laptop');
GO

SELECT * FROM Examples.Items;
GO

CREATE TRIGGER Examples.Items_TriggerInsteadOfUpdate
ON Examples.Items
INSTEAD OF UPDATE
AS
	SET NOCOUNT ON;
	SET ROWCOUNT 0;
	BEGIN TRY
		UPDATE Examples.Items
		SET Value = inserted.Value,
			RowLastModifiedDateTime = DEFAULT
		FROM Examples.Items JOIN inserted ON Items.ItemId = inserted.ItemId;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
GO

UPDATE Examples.Items
SET    Value = '4K Monitor',
       RowCreatedDateTime = '1900-01-01',
       RowLastModifiedDateTime = '1900-01-01'
WHERE ItemId = 1;
GO

SELECT *
FROM   Examples.Items;
GO
