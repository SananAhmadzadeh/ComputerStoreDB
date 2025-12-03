--Komputer satışı ilə məşğul olan mağaza uçun database yaradın. 

CREATE DATABASE ComputerStoreDB

USE ComputerStoreDB

--(Filiallar)
CREATE TABLE Branches
(
	Id     INT PRIMARY KEY IDENTITY,
	BranchName NVARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Branches (BranchName)
VALUES ('Nərimanov'), ('Əhmədli'), ('28 May');

--(İşçilər)
CREATE TABLE Employees
(
	Id	        INT PRIMARY KEY IDENTITY,
	FirstName	NVARCHAR(50) NOT NULL,
	LastName	NVARCHAR(50) NOT NULL,
	FatherName	NVARCHAR(50) NOT NULL,
	BirthDate	DATE NOT NULL,
	BranchId	INT NOT NULL FOREIGN KEY REFERENCES Branches(Id),
	Salary	    DECIMAL(10, 2) NOT NULL
);

INSERT INTO Employees (FirstName, LastName, FatherName, BirthDate, BranchId, Salary)
VALUES
('Murad', 'Həsənov', 'Elşad', '1998-05-12', 1, 1200),   -- Murad (tapşırıq 4)
('Aysel', 'Quliyeva', 'Sahib', '2003-09-21', 2, 900),   -- 25-dən kiçik
('Rauf', 'İsmayılov', 'Rəşid', '1995-03-11', 1, 1500),
('Kənan', 'Əliyev', 'Maqsud', '2004-01-15', 3, 800),    -- 25-dən kiçik
('Nigar', 'Məmmədova', 'Rövşən', '1990-07-07', 2, 2000);


--Categories
CREATE TABLE Categories
(
	Id     INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Categories (CategoryName)
VALUES ('Notebook'), ('PC'), ('Monitor'), ('Accessories');

--Products (Məhsullar)
CREATE TABLE Products
(
	Id             INT PRIMARY KEY IDENTITY,
	ProductName NVARCHAR(100) NOT NULL UNIQUE,
	Brand          NVARCHAR(100) NOT NULL,
	[Model]        NVARCHAR(100) NOT NULL,
	Price          DECIMAL(10, 2) NOT NULL,
	CategoryId     INT FOREIGN KEY REFERENCES Categories(Id)
);

INSERT INTO Products (ProductName, Brand, Model, Price, CategoryId)
VALUES
-- Notebooks
('Lenovo IdeaPad 3', 'Lenovo', 'IdeaPad 3', 1200, 1),
('Lenovo IdeaPad 3 - Version 2', 'Lenovo', 'IdeaPad 3', 1180, 1),

('HP Pavilion 15', 'HP', 'Pavilion 15', 1500, 1),
('HP Pavilion 15 (Silver)', 'HP', 'Pavilion 15', 1480, 1),

-- PC
('Acer Nitro PC', 'Acer', 'Nitro', 2200, 2),

-- Monitors
('Samsung 24"', 'Samsung', 'S24F350', 350, 3),
('Samsung 24" - Version B', 'Samsung', 'S24F350', 340, 3),

-- Accessories
('Logitech Mouse M185', 'Logitech', 'M185', 25, 4);


--Sales (Satışlar)
CREATE TABLE Sales
(
   Id INT PRIMARY KEY IDENTITY,
   ProductId INT FOREIGN KEY REFERENCES Products(Id),
   EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
   BranchId	INT FOREIGN KEY REFERENCES Branches(Id),
   Quantity	INT NOT NULL,
   SaleDate	DATE NOT NULL
);

INSERT INTO Sales (ProductId, EmployeeId, BranchId, Quantity, SaleDate) 
VALUES
-- Murad – orta satış
(1, 1, 1, 3, '2025-12-02'),
(2, 1, 1, 1, '2025-12-05'),

-- Aysel – yüksək satış
(3, 2, 2, 4, '2025-12-04'),
(4, 2, 2, 3, '2025-12-08'),

-- Rauf – az satış
(7, 3, 1, 1, '2025-12-03'),

-- Kənan – ən az satış 
(8, 4, 3, 1, '2025-12-01'),

-- Nigar – çox satış
(5, 5, 2, 3, '2025-12-07'),
(6, 5, 2, 5, '2025-12-09');

------------------------------------------------------------------------------

--1. Bütün məhsulların siyahısına baxmaq üçün sorğu yazın
SELECT * FROM Products

--2. Bütün işçilərin siyahısına baxmaq üçün sorğu yazın
SELECT * FROM Employees

--3. Məhsullara kateqoriyaları ilə birgə baxmaq üçün sorğu yazın
SELECT 
    P.Id,
    P.ProductName,
    P.Brand,
    P.Model,
    P.Price,
    C.CategoryName
FROM Products AS P
INNER JOIN Categories AS C 
    ON P.CategoryId = C.Id
ORDER BY C.Id;

--4. Adı Murad olan işçinin məlumatlarına baxmaq üçün sorğu yazın
SELECT * FROM Employees AS E WHERE E.FirstName = 'Murad'

--5. Yaşı 25-dən kiçik olan işçilərin siyahısına baxmaq üçün sorğu
SELECT *
FROM Employees
WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) < 25;

--6. Hər modeldən neçə məhsulun olduğunu tapın
SELECT 
      P.Model,
      COUNT(P.Model) ModelinSayi
FROM Products AS P 
GROUP BY P.Model

--7. Hər markada hər modelin neçə məhsulu olduğunu tapın
SELECT 
    P.Brand,
    P.Model,
    COUNT(*) AS ModelinSayi
FROM Products AS P
GROUP BY 
    P.Brand,
    P.Model
ORDER BY 
    P.Brand, 
    P.Model;

--8. Hər filial üzrə aylıq satış məbləğinin hesablanması
SELECT 
     B.BranchName AS [Filial],
     SUM(P.Price * S.Quantity) AS [Aylıq satış]
FROM Branches AS B
INNER JOIN Sales AS S ON B.Id = S.BranchId
INNER JOIN Products AS P ON S.ProductId = P.Id
GROUP BY B.Id, B.BranchName;

--9. Ay ərzində ən çox satış olunan model
SELECT TOP 1
    P.Model,
    SUM(S.Quantity) AS TotalSold
FROM Sales AS S
JOIN Products AS P ON S.ProductId = P.Id
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
GROUP BY P.Model
ORDER BY TotalSold DESC;

--10. Ay ərzində ən az satış edən işçi
SELECT TOP 1
     E.Id EmployeeID,
     E.FirstName  + ' ' + E.LastName [Employee FullName],
     SUM(S.Quantity) AS TotalSold
FROM Employees AS E
INNER JOIN Sales AS S ON E.Id = S.EmployeeId
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
GROUP BY E.Id, E.FirstName, E.LastName
ORDER BY TotalSold ASC

--11. Ay ərzində 3000-dən çox satış edən işçilərin siyahısı
SELECT
     E.Id EmployeeID,
     E.FirstName  + ' ' + E.LastName [Employee FullName],
     SUM(S.Quantity) AS TotalSold
FROM Employees AS E
INNER JOIN Sales AS S ON E.Id = S.EmployeeId
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
GROUP BY E.Id, E.FirstName, E.LastName
HAVING SUM(S.Quantity) > 3000
ORDER BY TotalSold DESC


--12. İşcilərin ad soyad və ata adlarını eyni xanada göstərən sorğu yazın
SELECT
     E.FirstName + ' ' + 
     E.LastName + ' ' + 
     E.FatherName [Employee FullName]
FROM Employees AS E


--13. Məhsulun ad və qarşısında adın uzunluğunu göstərən sorğu yazın. Məs : Lenova (7)
SELECT 
    ProductName + ' (' + CAST(LEN(ProductName) AS NVARCHAR(10)) + ')' AS ProductWithLength
FROM Products;

--14. Ən bahalı Məhsulu göstərən sorğu yazın
SELECT
    ProductName,
    Price AS [Product Price]
FROM Products
WHERE Price = (SELECT MAX(Price) FROM Products);

--15. Ən bahalı və ən ucuz məhsulu eyni sorğuda göstərin
SELECT 
    ProductName,
    Price AS [Product Price],
    'Ən Bahalı' AS [Type]
FROM Products
WHERE Price = (SELECT MAX(Price) FROM Products)

UNION ALL

SELECT 
    ProductName,
    Price AS [Product Price],
    'Ən Ucuz' AS [Type]
FROM Products
WHERE Price = (SELECT MIN(Price) FROM Products);

--16. Məhsulları qiymətinə görə kateqoriyalara bölün. Qiyməti:
--1000AZN-dən aşağı – münasib
--1000-2500AZN –orta qiymətli
--2500-dən yuxarı – baha olaraq qeyd edin
SELECT
     ProductName,  
     Price,    
CASE 
    WHEN Price < 1000 THEN N'münasib'
    WHEN Price BETWEEN 1000 AND 2500 THEN N'orta qiymətli'
    WHEN Price > 2500 THEN N'baha'
END

   PriceCategory
   
FROM Products AS P

--17. Cari ayda olan bütün satışların cəmini tapın
SELECT
      SUM(P.Price * S.Quantity) AS [Aylıq satış]
FROM Sales AS S 
INNER JOIN Products AS P ON S.ProductId = P.Id
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025

--18. Cari ayda ən çox satış edən işçinin məlumatlarını çıxaran sorğu yazın 
SELECT TOP 1
     E.Id EmployeeID,
     E.FirstName  + ' ' + E.LastName [Employee FullName],
     SUM(S.Quantity) AS TotalSold
FROM Employees AS E
INNER JOIN Sales AS S ON E.Id = S.EmployeeId
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
GROUP BY E.Id, E.FirstName, E.LastName
ORDER BY TotalSold DESC

-- 19. Cari ayda ən çox qazanc gətirən işçinin məlumatları
SELECT TOP 1
     E.Id,
     E.FirstName + ' ' + E.LastName + ' ' + E.FatherName AS [Employee FullName],
     E.BirthDate, 
     E.BranchId, 
     E.Salary,
     SUM(S.Quantity * P.Price) AS TotalSold
FROM Employees AS E
INNER JOIN Sales AS S ON E.Id = S.EmployeeId
INNER JOIN Products AS P ON S.ProductId = P.Id
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
GROUP BY E.Id, E.FirstName, E.LastName, E.FatherName, E.BirthDate, E.BranchId, E.Salary
ORDER BY TotalSold DESC;

--20. Ən çox satış edən işçinin cari ay maaşını 50% artırın
SELECT TOP 1
     E.Id,
     E.FirstName + ' ' + E.LastName + ' ' + E.FatherName AS [Employee FullName],
     E.BirthDate, 
     E.BranchId, 
     E.Salary,
     SUM(S.Quantity * P.Price) AS TotalSold
FROM Employees AS E
INNER JOIN Sales AS S ON E.Id = S.EmployeeId
INNER JOIN Products AS P ON S.ProductId = P.Id
WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
GROUP BY E.Id, E.FirstName, E.LastName, E.FatherName, E.BirthDate, E.BranchId, E.Salary
ORDER BY TotalSold DESC;


UPDATE E
SET E.Salary = E.Salary * 1.5
FROM Employees AS E
INNER JOIN (
    SELECT TOP 1
           E.Id,
           SUM(S.Quantity * P.Price) AS TotalSold
    FROM Employees AS E
    INNER JOIN Sales AS S ON E.Id = S.EmployeeId
    INNER JOIN Products AS P ON S.ProductId = P.Id
    WHERE MONTH(S.SaleDate) = 12 AND YEAR(S.SaleDate) = 2025
    GROUP BY E.Id
    ORDER BY TotalSold DESC
) AS TopEmployee ON E.Id = TopEmployee.Id;


----------------------------------------------------------------------------------------------------
--21. Hər filialdakı işçi sayını tapın
SELECT
     B.BranchName,
     COUNT(E.Id) AS [işçi sayı]
FROM Branches AS B
JOIN Employees AS E ON E.BranchId = B.Id
GROUP BY B.Id, B.BranchName
ORDER BY B.Id  

--22. Hər filialda mövcud olan məhsul sayını tapın
SELECT  
     B.BranchName,
     COUNT(P.Id)
FROM Branches AS B
JOIN Sales AS S ON B.Id = S.BranchId
JOIN Products AS P ON S.ProductId = P.Id
GROUP BY B.Id, B.BranchName
ORDER BY B.Id  

--23. Hər işçinin cari ayda satdığı məhsulların yekun qiymətini tapın
SELECT 
     E.Id, E.FirstName, E.LastName,
     SUM(S.Quantity * P.Price) AS [Işçinin cari ayda satdığı məhsulların yekun qiyməti]
FROM Sales AS S 
JOIN Products AS P ON S.ProductId = P.Id 
JOIN Employees AS E ON S.EmployeeId = E.Id
WHERE YEAR(S.SaleDate) = YEAR(GETDATE()) 
  AND MONTH(S.SaleDate) = MONTH(GETDATE())
GROUP BY E.Id, E.FirstName, E.LastName
ORDER BY E.Id;

--24. Satılan hər məhsuldan 1% qazanc əldə etdiyini nəzərə alaraq car ayda 
--hər bir satıcının maaşını hesablayın (rəsmi maaş : 350 AZN)
SELECT
    E.Id,
    E.FirstName,
    E.LastName,
    350 AS [Rəsmi Maaş],
    SUM(S.Quantity * P.Price * 0.01) AS [1% Komissiya],
    350 + SUM(S.Quantity * P.Price * 0.01) AS [Yekun Maaş]
FROM Employees AS E
LEFT JOIN Sales AS S ON S.EmployeeId = E.Id
LEFT JOIN Products AS P ON P.Id = S.ProductId
WHERE YEAR(S.SaleDate) = YEAR(GETDATE())
  AND MONTH(S.SaleDate) = MONTH(GETDATE())
GROUP BY E.Id, E.FirstName, E.LastName
ORDER BY E.Id;


--25. Hər filial üzrə cari aydakı qazancı hesablayın.
SELECT 
    B.BranchName AS [Filial],
    SUM(P.Price * S.Quantity) AS [Aylıq satış]
FROM Branches AS B
INNER JOIN Sales AS S ON B.Id = S.BranchId
INNER JOIN Products AS P ON S.ProductId = P.Id
WHERE YEAR(S.SaleDate) = YEAR(GETDATE()) 
  AND MONTH(S.SaleDate) = MONTH(GETDATE())
GROUP BY B.Id, B.BranchName
ORDER BY B.Id;

--26. Cari ay üzrə aylıq hesabatı çıxaran sorğu yazın
SELECT
    B.BranchName AS [Filial],
    P.ProductName AS [Məhsul],
    SUM(S.Quantity) AS [Satılan Məhsul Say],
    SUM(S.Quantity * P.Price) AS [Ümumi Qazanc]
FROM Sales AS S
JOIN Branches AS B ON B.Id = S.BranchId
JOIN Products AS P ON P.Id = S.ProductId
WHERE YEAR(S.SaleDate) = YEAR(GETDATE())
  AND MONTH(S.SaleDate) = MONTH(GETDATE())
GROUP BY 
    B.Id, B.BranchName,
    P.Id, P.ProductName
ORDER BY 
    B.Id,
    P.ProductName;
