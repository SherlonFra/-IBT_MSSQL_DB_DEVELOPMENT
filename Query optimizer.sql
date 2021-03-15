/*
Missing Index Details from Session2.sql - localhost\SQLEXPRESS01.WideWorldImporters (localhost\Sherlon (61))
The Query Processor estimates that implementing the following index could improve the query cost by 56.0881%.
*/

/*
USE [WideWorldImporters]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Sales].[CustomerTransactions] ([PaymentMethodID])
INCLUDE ([CustomerTransactionID],[CustomerID],[TransactionTypeID],[InvoiceID],[AmountExcludingTax],[TaxAmount],[TransactionAmount],[OutstandingBalance],[FinalizationDate],[IsFinalized],[LastEditedBy],[LastEditedWhen])
GO
*/