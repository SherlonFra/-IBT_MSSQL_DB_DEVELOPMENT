USE Sherlon
GO
-- RETURNS default value of 0
CREATE PROCEDURE SimpleReturnValue
AS
	DECLARE @NoOp int;
GO

--- SQL Script to get a value from a STORED PROCEDURE
DECLARE @ReturnCode INT;

EXEC @ReturnCode = SimpleReturnValue;

SELECT @ReturnCode AS ReturnCode;
GO

-- Procedure that returns codes
CREATE PROCEDURE DoOperation
(
	@Value INT
)
-- Procedure returns via RETURN code
-- 1 successful execution, with Value = 0
-- 0 successful execution, with any value
-- -1 invalid parameter, NULL value
AS
	IF @Value = 0
		RETURN 1;
	ELSE IF @Value IS NULL
		RETURN -1;
	ELSE
		RETURN 0;
GO

DECLARE @ReturnCode INT;

EXEC @ReturnCode = DoOperation @Value=100;

SELECT @ReturnCode AS Code,
		CASE @ReturnCode WHEN 1 THEN 'Success, 0 entered'
						 WHEN -1 THEN 'Invalid input'
						 WHEN 0 THEN 'Success'
		END AS Meaning;

----Streamline existing stored procedure logic
CREATE TABLE Examples.Player
(
    PlayerId    int NOT NULL CONSTRAINT PKPlayer PRIMARY KEY,
    TeamId      int NOT NULL, --not implemented reference to Team Table
    PlayerNumber char(2) NOT NULL, 
    CONSTRAINT AKPlayer UNIQUE (TeamId, PlayerNumber)
)
INSERT INTO Examples.Player(PlayerId, TeamId, PlayerNumber)
VALUES (1,1,'18'),(2,1,'45'),(3,1,'40');
GO


-- DROP PROCEDURE IF EXISTS Examples.Player_GetByPlayerNumber;
CREATE PROCEDURE Examples.Player_GetByPlayerNumber
(
    @PlayerNumber char(2)
) AS
    SET NOCOUNT ON;
    DECLARE @PlayerList TABLE (PlayerId int NOT NULL);

    DECLARE @Cursor cursor,
            @Loop_PlayerId int,
            @Loop_PlayerNumber char(2)

    SET @cursor = CURSOR FAST_FORWARD FOR ( SELECT PlayerId, PlayerNumber
                                            FROM   Examples.Player);

    OPEN @cursor;
    WHILE (1=1)
      BEGIN
            FETCH NEXT FROM @Cursor INTO @Loop_PlayerId, @Loop_PlayerNumber
            IF @@FETCH_STATUS <> 0
                BREAK;

            IF @PlayerNumber = @Loop_PlayerNumber
                INSERT INTO @PlayerList(PlayerId)
                VALUES (@Loop_PlayerId);
		END	
GO

EXECUTE  Examples.Player_GetByPlayerNumber @PlayerNumber = '18';  
GO
      

ALTER PROCEDURE Examples.Player_GetByPlayerNumber
(
    @PlayerNumber char(2)
) AS
    SET NOCOUNT ON -- eliminates the (x rows affected) message
    SELECT Player.PlayerId, Player.TeamId
    FROM   Examples.Player
    WHERE  PlayerNumber = @PlayerNumber;
GO

EXECUTE  Examples.Player_GetByPlayerNumber @PlayerNumber = '18';      
GO


THROW 50000, 'My error message', 1;
SELECT GETDATE();

RAISERROR ('My raiserror message', 16, 1);
SELECT GETDATE();


-- Handling an error
CREATE TABLE Examples.ErrorTesting
(
    ErrorTestingId int NOT NULL CONSTRAINT PKErrorTesting PRIMARY KEY,
    PositiveInteger int NOT NULL 
         CONSTRAINT CHKErrorTesting_PositiveInteger CHECK (PositiveInteger > 0)
);
GO
------Using TRY-CATCH
CREATE PROCEDURE Examples.ErrorTesting_InsertTwo
AS
    SET NOCOUNT ON;
    DECLARE @Location nvarchar(30);

    BEGIN TRY
        SET @Location = 'First statement';
        INSERT INTO Examples.ErrorTesting(ErrorTestingId, PositiveInteger)
        VALUES (6,3); --Succeeds

        SET @Location = 'Second statement';
        INSERT INTO Examples.ErrorTesting(ErrorTestingId, PositiveInteger)
        VALUES (7,-1); --Fail Constraint

        SET @Location = 'First statement';
        INSERT INTO Examples.ErrorTesting(ErrorTestingId, PositiveInteger)
        VALUES (8,1); --Will succeed if statement executes
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS ErrorProcedure, @Location AS ErrorLocation 
        SELECT ERROR_MESSAGE() as ErrorMessage;
        SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_SEVERITY() as ErrorSeverity, 
               ERROR_LINE() As ErrorLine;
	END CATCH
GO

EXECUTE Examples.ErrorTesting_InsertTwo;
GO

-- Hadling transactions
CREATE TABLE Examples.Worker
(
    WorkerId int NOT NULL IDENTITY(1,1) CONSTRAINT PKWorker PRIMARY KEY,
    WorkerName nvarchar(50) NOT NULL CONSTRAINT AKWorker UNIQUE
);

CREATE TABLE Examples.WorkerAssignment
(
    WorkerAssignmentId int IDENTITY(1,1) CONSTRAINT PKWorkerAssignment PRIMARY KEY,
    WorkerId int NOT NULL,
    CompanyName nvarchar(50) NOT NULL 
    CONSTRAINT CHKWorkerAssignment_CompanyName CHECK (CompanyName <> 'Contoso, Ltd.'),
    CONSTRAINT AKWorkerAssignment UNIQUE (WorkerId, CompanyName)
);
GO

CREATE PROCEDURE Examples.Worker_AddWithAssignment
    @WorkerName nvarchar(50),
    @CompanyName nvarchar(50)
AS
    SET NOCOUNT ON;
    --do any non-data testing before starting the transaction
    IF @WorkerName IS NULL or @CompanyName IS NULL
        THROW 50000,'Both parameters must be not null',1;

    DECLARE @Location nvarchar(30), @NewWorkerId int;
    BEGIN TRY
        BEGIN TRANSACTION;

        SET @Location = 'Creating Worker Row';
        INSERT INTO Examples.Worker(WorkerName)
        VALUES (@WorkerName);

        SELECT @NewWorkerId = SCOPE_IDENTITY(),
               @Location = 'Creating WorkAssignment Row';

        INSERT INTO Examples.WorkerAssignment(WorkerId, CompanyName)
        VALUES (@NewWorkerId, @CompanyName);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        --at the end of the call, we want the transaction rolled back
        --rollback the transaction first, so it definitely occurs as the THROW
        --statement would keep it from happening. 
        IF XACT_STATE() <> 0 --if there is a transaction in effect
                             --commitable or not   
            ROLLBACK TRANSACTION;

        --format a message that tells the error and then THROW it.
        DECLARE @ErrorMessage nvarchar(4000);
        SET @ErrorMessage = CONCAT('Error occurred during: ''',@Location,'''',
                                   ' System Error: ',
                                   ERROR_NUMBER(),':',ERROR_MESSAGE());
        THROW 50000, @ErrorMessage, 1;
    END CATCH;
GO

EXEC Examples.Worker_AddWithAssignment @WorkerName = NULL, @CompanyName = NULL;
GO

EXEC Examples.Worker_AddWithAssignment @WorkerName='David So', @CompanyName='Margie''s Travel';
GO

EXEC Examples.Worker_AddWithAssignment @WorkerName='David So', @CompanyName='Margie''s Travel';
GO

EXEC Examples.Worker_AddWithAssignment @WorkerName='Ian Palangio', @CompanyName='Contoso, Ltd.';
EXEC Examples.Worker_AddWithAssignment @WorkerName='Ian Palangio', @CompanyName='Humongous Insurance';
GO

select * from Examples.Worker;
select * from Examples.WorkerAssignment;
