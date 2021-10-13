--YTD sales and Best Performer

SELECT [BusinessEntityID],
		[TerritoryID]
		,[Bonus]
		,[SalesYTD]
		,[SalesLastYear]
		,[Total YTD Sales] = sum([salesYTD]) over()
		,[Max YTD Sales] = MAX([SalesYTD]) over()
		,[% of Best Performer] = [SalesYTD]/MAX([SalesYTD]) over()
	
FROM [AdventureWorks2019].[Sales].[SalesPerson]
ORDER BY [% of Best Performer] DESC;


--Sum of line totals group by ProductID, OrderQty

SELECT 
ProductID,
SalesOrderID,
SalesOrderDetailID,
OrderQty,
UnitPrice,
UnitPriceDiscount,
LineTotal,
ProductIDlineTotal = SUM([LineTotal]) OVER(PARTITION BY [ProductID], [OrderQty])

FROM AdventureWorks2019.Sales.SalesOrderDetail
ORDER BY [ProductID], [OrderQty] DESC;


-- Ranking all records within each group of sales order IDs

SELECT 
	SalesOrderID
	,SalesOrderDetailID
	,LineTotal
	,ProductIDlineTotal = sum([LineTotal]) over(PARTITION BY [SalesOrderID])
	,Ranking = ROW_NUMBER() over(PARTITION BY [SalesOrderID] ORDER BY LineTotal)

FROM [AdventureWorks2019].[Sales].[SalesOrderDetail]

ORDER BY [SalesOrderID]