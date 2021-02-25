--*************************************************************************--
-- Title: Assignment06
-- Author: Jessica Carnes
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-22,JCarnes,Created File & Answered questions 1-9
-- 2021-02-24,JCarnes, Answered question 10
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JCarnes')
	 Begin 
	  Alter Database [Assignment06DB_JCarnes] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JCarnes;
	 End
	Create Database Assignment06DB_JCarnes;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JCarnes;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/* NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------*/

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
	SELECT CategoryID, CategoryName
	FROM dbo.Categories;
GO

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM dbo.Products;
GO

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees;
GO

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
	FROM dbo.Inventories;
GO

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;
GO

DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;
GO

DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GO

DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;
GO

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00
/*
SELECT c.CategoryName, p.ProductName, p.UnitPrice --Starting with Code from Assignment05 question 1
FROM Categories c INNER JOIN Products p
  ON c.CategoryID = p.CategoryID
ORDER BY CategoryName ASC, ProductName ASC;
GO

SELECT c.CategoryName, p.ProductName, p.UnitPrice 
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
ORDER BY CategoryName ASC, ProductName ASC;
GO

*/

CREATE VIEW vProductsByCategories
WITH SCHEMABINDING
AS
	SELECT TOP 1000000000 
	   c.CategoryName
	  ,p.ProductName
	  ,p.UnitPrice 
	FROM dbo.vCategories c INNER JOIN dbo.vProducts p
	  ON c.CategoryID = p.CategoryID
	ORDER BY CategoryName ASC, ProductName ASC;
GO

-- SELECT * FROM [dbo].[vProductsByCategories]

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

/*
SELECT p.ProductName, i.InventoryDate, i.Count --Starting with question 2 of assignment05
FROM Inventories i INNER JOIN Products p
  ON i.ProductID = p.ProductID
ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO

SELECT p.ProductName, i.InventoryDate, i.Count --Starting with question 2 of assignment05
FROM dbo.vInventories i INNER JOIN dbo.vProducts p
  ON i.ProductID = p.ProductID
ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO
*/

CREATE VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING
AS
	SELECT TOP 1000000000000 
	   p.ProductName
	  ,i.InventoryDate
	  ,i.Count
	FROM dbo.vInventories i INNER JOIN dbo.vProducts p
	  ON i.ProductID = p.ProductID
	ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO

-- SELECT * FROM [dbo].[vInventoriesByProductsByDates]


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

/*
--Starting with solution to question 3 in Assignment05
SELECT DISTINCT i.InventoryDate, [EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM Inventories i INNER JOIN Employees e
  ON i.EmployeeID = e.EmployeeID
ORDER BY i.InventoryDate ASC;
GO

SELECT DISTINCT i.InventoryDate, [EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vInventories i INNER JOIN dbo.vEmployees e
  ON i.EmployeeID = e.EmployeeID
ORDER BY i.InventoryDate ASC;
GO
*/

CREATE VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING
AS
	SELECT DISTINCT TOP 1000000000 
	   i.InventoryDate
	  ,[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM dbo.vInventories i INNER JOIN dbo.vEmployees e
	  ON i.EmployeeID = e.EmployeeID
	ORDER BY i.InventoryDate ASC;
GO

--SELECT * FROM [dbo].[vInventoriesByEmployeesByDates]

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

/*
--Starting with solution to Assignment05 question 4
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count
FROM Categories c INNER JOIN Products p
  ON c.CategoryID = p.CategoryID
 INNER JOIN inventories i
  ON i.ProductID = p.ProductID
ORDER BY c.CategoryName ASC, p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO

SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count
FROM vCategories c INNER JOIN vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vInventories i
  ON i.ProductID = p.ProductID
ORDER BY c.CategoryName ASC, p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO
*/

CREATE VIEW vInventoriesByProductsByCategories
WITH SCHEMABINDING
AS
	SELECT TOP 1000000000 
	   c.CategoryName
	  ,p.ProductName
	  ,i.InventoryDate
	  ,i.Count
	FROM dbo.vCategories c INNER JOIN dbo.vProducts p
	  ON c.CategoryID = p.CategoryID
	 INNER JOIN dbo.vInventories i
	  ON i.ProductID = p.ProductID
	ORDER BY c.CategoryName ASC, p.ProductName ASC, i.InventoryDate ASC, i.Count DESC;
GO

--SELECT * FROM [dbo].[vInventoriesByProductsByCategories]


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

/*
--Starting with solution from Assignment05 question 5
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count, EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM Categories c INNER JOIN Products p
  ON c.CategoryID = p.CategoryID
 INNER JOIN inventories i
  ON i.ProductID = p.ProductID
 LEFT OUTER JOIN Employees e
  ON e.EmployeeID = i.EmployeeID
ORDER BY  i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO

SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count, EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vinventories i
  ON i.ProductID = p.ProductID
 LEFT OUTER JOIN dbo.vEmployees e
  ON e.EmployeeID = i.EmployeeID
ORDER BY  i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO
*/

CREATE VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING
AS
	SELECT TOP 1000000000 
	   c.CategoryName
	  ,p.ProductName
	  ,i.InventoryDate
	  ,i.Count
	  ,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM dbo.vCategories c INNER JOIN dbo.vProducts p
	  ON c.CategoryID = p.CategoryID
	 INNER JOIN dbo.vinventories i
	  ON i.ProductID = p.ProductID
	 LEFT OUTER JOIN dbo.vEmployees e
	  ON e.EmployeeID = i.EmployeeID
	ORDER BY  i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO

-- SELECT * FROM [dbo].[vInventoriesByProductsByEmployees]

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

/*
--Starting with solution to assignment05 question 6
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count, EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM Categories c INNER JOIN Products p
  ON c.CategoryID = p.CategoryID
 INNER JOIN inventories i
  ON i.ProductID = p.ProductID
 LEFT OUTER JOIN Employees e
  ON e.EmployeeID = i.EmployeeID
WHERE p.ProductID in (
  SELECT ProductID
  FROM Products
  WHERE ProductName in ('Chai', 'Chang')
  )
ORDER BY  i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO

SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.Count, EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vinventories i
  ON i.ProductID = p.ProductID
 LEFT OUTER JOIN dbo.vEmployees e
  ON e.EmployeeID = i.EmployeeID
WHERE p.ProductID in (
  SELECT ProductID
  FROM dbo.vProducts
  WHERE ProductName in ('Chai', 'Chang')
  )
ORDER BY  i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO
*/

CREATE VIEW vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING
AS
	SELECT TOP 1000000000 
	   c.CategoryName
	   ,p.ProductName
	   ,i.InventoryDate
	   ,i.Count
	   ,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM dbo.vCategories c INNER JOIN dbo.vProducts p
	  ON c.CategoryID = p.CategoryID
	 INNER JOIN dbo.vInventories i
	  ON i.ProductID = p.ProductID
	 LEFT OUTER JOIN dbo.vEmployees e
	  ON e.EmployeeID = i.EmployeeID
	WHERE p.ProductID in (
	  SELECT ProductID
	  FROM dbo.vProducts
	  WHERE ProductName in ('Chai', 'Chang')
	  )
	ORDER BY  i.InventoryDate ASC, c.CategoryName ASC, p.ProductName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO

--SELECT * FROM [dbo].[vInventoriesForChaiAndChangByEmployees]


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

/*
--Starting with solution from Assignment05 question 7
SELECT 
  [Manager] =  m.EmployeeFirstName + ' ' + m.EmployeeLastName
 ,[Employee] =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM Employees e LEFT OUTER JOIN Employees m
 ON e.ManagerID = m.EmployeeID
ORDER BY m.EmployeeFirstName + ' ' + m.EmployeeLastName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO

SELECT 
  [Manager] =  m.EmployeeFirstName + ' ' + m.EmployeeLastName
 ,[Employee] =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM dbo.vEmployees e LEFT OUTER JOIN dbo.vEmployees m
 ON e.ManagerID = m.EmployeeID
ORDER BY m.EmployeeFirstName + ' ' + m.EmployeeLastName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO
*/

CREATE VIEW vEmployeesByManager
WITH SCHEMABINDING
AS
	SELECT TOP 1000000000
	  [Manager] =  m.EmployeeFirstName + ' ' + m.EmployeeLastName
	 ,[Employee] =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM dbo.vEmployees e LEFT OUTER JOIN dbo.vEmployees m
	 ON e.ManagerID = m.EmployeeID
	ORDER BY m.EmployeeFirstName + ' ' + m.EmployeeLastName ASC, e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO

--SELECT * FROM [dbo].[vEmployeesByManager]


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan
/*
SELECT *
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vInventories i
  ON i.ProductID = p.ProductID
 INNER JOIN dbo.vEmployees e
  ON e.EmployeeID = i.EmployeeID
 INNER JOIN dbo.vEmployees m
  ON e.ManagerID = m.EmployeeID;

SELECT 
   c.CategoryID
  ,c.CategoryName
  ,p.ProductID
  ,p.ProductName
  ,p.UnitPrice
  ,i.InventoryID
  ,i.InventoryDate
  ,i.Count
  ,i.EmployeeID	 
  ,[Employee] =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
  ,[Manager] =  m.EmployeeFirstName + ' ' + m.EmployeeLastName
FROM dbo.vCategories c INNER JOIN dbo.vProducts p
  ON c.CategoryID = p.CategoryID
 INNER JOIN dbo.vInventories i
  ON i.ProductID = p.ProductID
 INNER JOIN dbo.vEmployees e
  ON e.EmployeeID = i.EmployeeID
 INNER JOIN dbo.vEmployees m
  ON e.ManagerID = m.EmployeeID;
*/

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING
AS
	SELECT
	   c.CategoryID
	  ,c.CategoryName
	  ,p.ProductID
	  ,p.ProductName
	  ,p.UnitPrice
	  ,i.InventoryID
	  ,i.InventoryDate
	  ,i.Count
	  ,i.EmployeeID	 
	  ,[Employee] =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
	  ,[Manager] =  m.EmployeeFirstName + ' ' + m.EmployeeLastName
	FROM dbo.vCategories c INNER JOIN dbo.vProducts p
	  ON c.CategoryID = p.CategoryID
	 INNER JOIN dbo.vInventories i
	  ON i.ProductID = p.ProductID
	 INNER JOIN dbo.vEmployees e
	  ON e.EmployeeID = i.EmployeeID
	 INNER JOIN dbo.vEmployees m
	  ON e.ManagerID = m.EmployeeID;
GO

--SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/
