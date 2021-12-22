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

SELECT ProductID,
       SalesOrderID,
       SalesOrderDetailID,
       OrderQty,
       UnitPrice,
       UnitPriceDiscount,
       LineTotal,
       ProductIDlineTotal = SUM([LineTotal]) OVER(PARTITION BY [ProductID], [OrderQty])
FROM AdventureWorks2019.Sales.SalesOrderDetail
ORDER BY [ProductID],
         [OrderQty] DESC;

-- Ranking all records within each group of sales order IDs

SELECT SalesOrderID ,
       SalesOrderDetailID ,
       LineTotal ,
       ProductIDlineTotal = sum([LineTotal]) over(PARTITION BY [SalesOrderID]) ,
       Ranking = ROW_NUMBER() over(PARTITION BY [SalesOrderID]
                              ORDER BY LineTotal)
FROM [AdventureWorks2019].[Sales].[SalesOrderDetail]
ORDER BY [SalesOrderID]


-- LineTotal of each order for each Category 

SELECT *
FROM
  (SELECT D.Name AS ProductCategoryName,
          A.LineTotal,
          a.SalesOrderID
   FROM Sales.SalesOrderDetail A
   JOIN Production.Product B ON A.ProductID = B.ProductID
   JOIN Production.ProductSubcategory C ON B.ProductSubcategoryID = C.ProductSubcategoryID
   JOIN Production.ProductCategory D ON C.ProductCategoryID = D.ProductCategoryID) A 

PIVOT (SUM(LineTotal)
      FOR ProductCategoryName IN([Bikes], [Clothing], [Accessories], [Components]))B
ORDER BY 1

-- find the sum of top 10 order every month VS PRE MONTH
  SELECT A.OrderMonth,
       A.Top10Total,
       PrevTop10Total = B.Top10Total
FROM
  (SELECT OrderMonth,
          Top10Total = Sum(TotalDue)
   FROM
     (SELECT OrderDate,
             TotalDue,
             OrderMonth = DATEFROMPARTS(Year(OrderDate), Month(OrderDate), 1),
             OrderRank = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(Year(OrderDate), Month(OrderDate), 1)
                                            ORDER BY TotalDue DESC)
      FROM sales.SalesOrderHeader) x
   WHERE OrderRank <=10
   GROUP BY OrderMonth) A
LEFT JOIN
  (SELECT OrderMonth,
          Top10Total = Sum(TotalDue)
   FROM
     (SELECT OrderDate,
             TotalDue,
             OrderMonth = DATEFROMPARTS(Year(OrderDate), Month(OrderDate), 1),
             OrderRank = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(Year(OrderDate), Month(OrderDate), 1)
                                            ORDER BY TotalDue DESC)
      FROM sales.SalesOrderHeader) x
   WHERE OrderRank <=10
   GROUP BY OrderMonth) B ON A.OrderMonth = DATEADD(MONTH, 1, B.OrderMonth)
ORDER BY A.OrderMonth

--- Count the SaleOrderID Groupby ReasonName - Reason Cat (1 Reason or n-Reason)
WITH new as 
(SELECT a.SalesOrderID,
		a.SalesReasonID,
		b.Name as ReasonName
FROM Sales.SalesOrderHeaderSalesReason a JOIN SALES.SalesReason b
ON a.SalesReasonID = b.SalesReasonID) 

SELECT R.ReasonName, R.ReasonCat, Count(*) as SalesOrderCount
FROM(
SELECT SalesOrderID,
		ReasonName
		,ReasonCat = CASE WHEN (SELECT COUNT(SalesOrderID) FROM new x WHERE x.SalesOrderID = y.SalesOrderID)  > 1 THEN 'n-reasons' 
						ELSE '1-Reason' END
FROM new y
) R
GROUP BY r.ReasonName, r.ReasonCat
ORDER BY SalesOrderCount desc;

--- OPTION 2
WITH newtable As 
(SELECT a.SalesOrderID,
		b.Name as ReasonName,
		ReasonCat = CASE WHEN count(a.SalesOrderID) > 1 Then 'n-reason'
					ELSE '1-reason'
					END
FROM Sales.SalesOrderHeaderSalesReason a JOIN SALES.SalesReason b
ON a.SalesReasonID = b.SalesReasonID
JOIN  Sales.SalesOrderHeaderSalesReason aa on a.SalesOrderID = aa.SalesOrderID
GROUP BY A.SalesOrderID,B.Name
) 

SELECT 
ReasonName,
ReasonCat,
count(*) as SalesOrderCount
FROM newtable
GROUP BY ReasonName, ReasonCat
ORDER BY SalesOrderCount desc

--Calculate total Orders for each region and percentage of online orders

SELECT b.Name AS Khu_Vuc,
count(DISTINCT a.SalesOrderID) as Tong_HD,
"%_HD_Dat_Online" = ROUND(Convert(float,SUM(CASE WHEN a.OnlineOrderFlag = 1 THEN 1 ELSE 0 END))*100/count(DISTINCT a.SalesOrderID),2) ,
"%_HD_Mua_tai_Shop" = ROUND(Convert(float,SUM(CASE WHEN a.OnlineOrderFlag = 0 THEN 1 ELSE 0 END))*100/count(DISTINCT a.SalesOrderID),2),
Year = YEAR(A.OrderDate)
 
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] a
JOIN sales.SalesTerritory b ON a.TerritoryID = b.TerritoryID
WHERE YEAR(A.OrderDate) = 2012
GROUP BY b.Name, YEAR(A.OrderDate)