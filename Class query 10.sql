USE sherlon;

CREATE TABLE Examples.SimpleTable
(
	SimpleTableId INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	Value1 VARCHAR(20) NOT NULL,
	Value2 VARCHAR(20) NOT NULL
);
GO

CREATE PROCEDURE Examples.SimpleTable_Insert
	@Value1 VARCHAR(20) ,
	@Value2 VARCHAR(20) 

AS
	INSERT INTO Examples.SimpleTable (Value1, Value2) VALUES (@Value1, @Value2);
GO

CREATE PROCEDURE Examples.SimpleTable_Update
	@SimpleTableId INT,
	@Value1 VARCHAR(20),
	@Value2 VARCHAR(20)
AS
	UPDATE Examples.SimpleTable
		SET Value1 = @Value1,
			Value2 = @Value2
		WHERE @SimpleTableId = @SimpleTableId;
GO

CREATE PROCEDURE Examples.SimpleTable_Delete
	@SimpleTableId INT
AS
	DELETE FROM Examples.SimpleTable
	WHERE SimpleTableId = @SimpleTableId;
GO

CREATE PROCEDURE Examples.SimpleTable_Select
AS
	SELECT SimpleTableId, Value1, Value2
	FROM Examples.SimpleTable
	ORDER BY Value1;
GO

CREATE PROCEDURE Examples.SimpleTable_SelectValue1StartWithQorZ
AS
	SELECT SimpleTableId, Value1, Value2
	FROM Examples.SimpleTable
	WHERE Value1 LIKE 'Q%'
	ORDER BY Value1;

	SELECT SimpleTableId, Value1, Value2
	FROM Examples.SimpleTable
	WHERE Value1 LIKE 'Z%'
	ORDER BY Value1;

GO

CREATE PROCEDURE Examples.SimpleTable_SelectValue1StartWithQorZOnWeekday
AS
	IF DATENAME(WEEKDAY,GETDATE()) NOT IN ('Saturday','Sunday')
		SELECT SimpleTableId, Value1, Value2
		FROM Examples.SimpleTable
		WHERE Value1 LIKE '[QZ]%'
		ORDER BY Value1;
	GO

	EXECUTE Examples.SimpleTable_Select;
	EXECUTE Examples.SimpleTable_SelectValue1StartWithQorZ;


CREATE TABLE Examples.Parameter
(
	ParameterId INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	Value1 VARCHAR(20) NOT NULL,
	Value2 VARCHAR(20) NOT NULL
);
GO

CREATE PROCEDURE Examples.Parameter_Insert
	@Value1 VARCHAR(20) = 'NO ENTRY GIVEN',
	@Value2 VARCHAR(20) = 'NO ENTRY GIVEN'
AS
	SET NOCOUNT ON;
	INSERT INTO Examples.Parameter (Value1, Value2) VALUES (@Value1, @Value2);
GO

EXEC Examples.Parameter_Insert;

EXEC Examples.Parameter_Insert 'My parameter 1';

EXEC Examples.Parameter_Insert 'My Parameter 1', 'My parameter 2';

EXEC Examples.Parameter_Insert @Value1 = 'Param1';

SELECT*FROM Examples.Parameter;
GO  

ALTER PROCEDURE Examples.Parameter_Insert
	@Value1 VARCHAR(20) = 'NO ENTRY GIVEN',
	@Value2 VARCHAR(20) = 'NO ENTRY GIVEN' OUTPUT,
	@NewParameterId INT = NULL OUTPUT

AS
	SET NOCOUNT ON;
	SET @Value1 = UPPER(@Value1);
	SET @Value2 = LOWER(@Value2);

	INSERT INTO Examples.Parameter (Value1, Value2) VALUES (@Value1, @Value2);

	SET @NewParameterId = SCOPE_IDENTITY();
	GO

DECLARE @Value1 VARCHAR(20) = 'Test value1',
		@Value2 VARCHAR(20) = 'Test value2',
		@NewParameterId INT = -200;

SELECT @NewParameterId, @Value1, @Value2;

EXEC Examples.Parameter_Insert @Value1, @Value2 OUTPUT, @NewParameterId OUTPUT;

SELECT @NewParameterId, @Value1, @Value2;

--SELECT*FROM Examples.Parameter;
	