-- What is the Average List Price by Category and by SubCategory?


SELECT P.[Name] AS ProductName
		, p.ListPrice
		, S.[Name] As ProductSubcategory
		, c.[Name] AS ProductCategory
		, [AvgPriceByCategory] = AVG(p.[ListPrice]) over(PARTITION BY S.ProductCategoryID)
		, [AvgPriceByCategoryAndSubcategory] = AVG(p.[ListPrice]) over(PARTITION BY S.ProductCategoryID, P.ProductSubcategoryID)

FROM [AdventureWorks2019].[Production].[Product] P
	JOIN [AdventureWorks2019].[Production].[ProductSubcategory] S
	ON P.ProductSubcategoryID = S.ProductSubcategoryID
	JOIN [AdventureWorks2019].[Production].[ProductCategory] C
	ON S.ProductCategoryID = c.ProductCategoryID

-- Find the most expensive List Price

SELECT P.[Name] AS ProductName
		, p.ListPrice
		, S.[Name] As ProductSubcategory
		, c.[Name] AS ProductCategory
		, [Price Rank] = ROW_NUMBER() OVER(ORDER BY p.ListPrice DESC)
		, [Category Price Rank] = RANK() OVER(PARTITION BY S.ProductCategoryID ORDER BY p.ListPrice DESC)
		, [Top 3 Price In Category] = 
				CASE WHEN DENSE_RANK() OVER(PARTITION BY S.ProductCategoryID ORDER BY p.ListPrice DESC) <= 3 THEN 'YES' 
					ELSE 'NO'
					END

FROM [AdventureWorks2019].[Production].[Product] P
	JOIN [AdventureWorks2019].[Production].[ProductSubcategory] S
	ON P.ProductSubcategoryID = S.ProductSubcategoryID
	JOIN [AdventureWorks2019].[Production].[ProductCategory] C
	ON S.ProductCategoryID = c.ProductCategoryID

ORDER BY 4;