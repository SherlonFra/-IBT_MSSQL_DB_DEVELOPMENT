USE Sherlon;
GO

-- In FK relationships we have
-- Parent Tables
CREATE TABLE Examples.Parent 
(
	ParentId INT NOT NULL PRIMARY KEY
);
GO
-- Child Tables
CREATE TABLE Examples.Child
(
	ChildId INT NOT NULL PRIMARY KEY,
	ParentId INT NOT NULL
);
GO

INSERT INTO Examples.Child VALUES (1,100);
--DELETE FROM Examples.Child;

SELECT * FROM Examples.Parent;
SELECT * FROM Examples.Child;

ALTER TABLE Examples.Child
	ADD CONSTRAINT FKChild_ParentId FOREIGN KEY (ParentId) REFERENCES Examples.Parent (ParentId);

-- Fails with message: The INSERT statement conflicted with the FOREIGN KEY constraint "FKChild_ParentId"	
INSERT INTO Examples.Child VALUES (1,100);

-- ParentId values have to exist in the parent table in order to be inserted in the child table
INSERT INTO Examples.Parent VALUES (1), (2), (3);

-- Inserting valid values
INSERT INTO Examples.Child VALUES (1,1);
INSERT INTO Examples.Child VALUES (2,1);
INSERT INTO Examples.Child VALUES (3,2);
INSERT INTO Examples.Child VALUES (4,3);

-- PRIMARY KEYS can be composed of several columns
CREATE TABLE Examples.TwoPartKey
(
	KeyColumn1 INT NOT NULL,
	KeyColumn2 INT NOT NULL,
	CONSTRAINT PKTwoPartKey PRIMARY KEY (KeyColumn1, KeyColumn2)
);
GO

CREATE TABLE Examples.TwoPartKeyReference
(
	RefKeyColumn1 INT NOT NULL,
	RefKeyColumn2 INT NOT NULL,
	CONSTRAINT FKTwoPartKeyReference FOREIGN KEY (RefKeyColumn1, RefKeyColumn2) REFERENCES Examples.TwoPartKey (KeyColumn1, KeyColumn2)
);
GO