CREATE DATABASE Sherlon;
GO

USE Sherlon;
GO

-- Create a sample schema
CREATE SCHEMA Examples;
GO

CREATE TABLE Examples.Widget
(
	WidgetCode VARCHAR(10) NOT NULL
		CONSTRAINT PKWidget PRIMARY KEY,
	WidgetName VARCHAR(100) NULL
);
GO

CREATE TABLE Examples.Widget
(
	WidgetCode VARCHAR(10) NOT NULL,
	WidgetName VARCHAR(100) NULL,	
	CONSTRAINT PKWidget PRIMARY KEY (WidgetCode)
);
GO

ALTER TABLE Examples.Widget
	ADD NotNullableColumn INT NOT NULL
	CONSTRAINT DFT_NotNullable DEFAULT ('some value');
GO

ALTER TABLE Examples.Widget
	DROP CONSTRAINT DFT_NotNullable;
GO

ALTER TABLE Examples.Widget
	DROP COLUMN NotNullableColumn;
GO