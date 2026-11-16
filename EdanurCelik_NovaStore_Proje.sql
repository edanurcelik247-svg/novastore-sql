-- NovaStore E-Ticaret Veri Yönetim Sistemi
-- Hazırlayan: Edanur Çelik

-- =============================================
-- BÖLÜM 1: VERİTABANI VE TABLOLAR (DDL)
-- =============================================

USE master;
GO

-- Betik tekrar çalıştırılırsa eski veritabanını silip baştan kuruyoruz
IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- Önce başka tabloya bağlı olmayan tablolar oluşturuluyor
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName   VARCHAR(50),
    City       VARCHAR(20),
    Email      VARCHAR(100) UNIQUE
);

CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2),
    Stock       INT DEFAULT 0,
    CategoryID  INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate   DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    DetailID  INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity  INT
);
GO

-- =============================================
-- BÖLÜM 2: VERİ EKLEME (DML)
-- =============================================

INSERT INTO Categories (CategoryName) VALUES
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yasam');

-- Bazı ürünlerin stoğu 20'nin altında (1. sorgu için)
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Kablosuz Kulaklik',     1499.90, 35, 1),
('Akilli Saat',           3299.00, 12, 1),
('Bluetooth Hoparlor',     899.50, 48, 1),
('Pamuklu Tisort',         249.90, 120, 2),
('Kot Pantolon',           799.00, 18, 2),
('Kapusonlu Sweatshirt',   649.90, 40, 2),
('Kurk Mantolu Madonna',    85.00, 60, 3),
('Sefiller',               175.50,  9, 3),
('Nemlendirici Krem',      329.90, 25, 4),
('Mat Ruj',                189.00,  5, 4),
('Seramik Kupa Seti',      279.00, 14, 5),
('Masa Lambasi',           549.00, 22, 5);

INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yilmaz',  'Istanbul',  'ahmet.yilmaz@mail.com'),
('Zeynep Kaya',   'Ankara',    'zeynep.kaya@mail.com'),
('Mehmet Demir',  'Izmir',     'mehmet.demir@mail.com'),
('Elif Sahin',    'Bursa',     'elif.sahin@mail.com'),
('Burak Ozturk',  'Antalya',   'burak.ozturk@mail.com'),
('Selin Arslan',  'Eskisehir', 'selin.arslan@mail.com');

-- Toplam tutar önce 0 giriliyor, detaylar eklendikten sonra hesaplanacak
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-01-14 10:25:00', 0),
(2, '2026-02-03 14:10:00', 0),
(1, '2026-03-22 19:45:00', 0),
(3, '2026-04-09 11:05:00', 0),
(4, '2026-05-17 16:30:00', 0),
(5, '2026-06-05 09:50:00', 0),
(2, '2026-07-11 21:15:00', 0),
(6, '2026-08-26 13:40:00', 0),
(3, '2026-09-08 18:20:00', 0),
(1, '2026-10-19 12:00:00', 0);

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1), (1, 7, 2),
(2, 4, 3), (2, 5, 1),
(3, 9, 1), (3, 10, 2),
(4, 2, 1),
(5, 11, 2), (5, 12, 1),
(6, 3, 1), (6, 6, 1),
(7, 8, 1), (7, 7, 1),
(8, 12, 2),
(9, 4, 2), (9, 9, 1),
(10, 3, 1);

-- Her siparişin toplamı = detaylardaki adet x ürün fiyatı
UPDATE o
SET o.TotalAmount = t.Toplam
FROM Orders o
JOIN (
    SELECT od.OrderID, SUM(od.Quantity * p.Price) AS Toplam
    FROM OrderDetails od
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY od.OrderID
) t ON t.OrderID = o.OrderID;
GO

-- =============================================
-- BÖLÜM 3: SORGULAR
-- =============================================

-- Sorgu 1: Stoğu 20'den az olan ürünler (stoğa göre azalan)
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

-- Sorgu 2: Müşteri adı, şehir, sipariş tarihi ve toplam tutar
SELECT c.FullName, c.City, o.OrderDate, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;

-- Sorgu 3: Ahmet Yilmaz'ın aldığı ürünler, fiyatları ve kategorileri
SELECT p.ProductName, p.Price, cat.CategoryName
FROM Customers c
INNER JOIN Orders o        ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID = o.OrderID
INNER JOIN Products p      ON p.ProductID = od.ProductID
INNER JOIN Categories cat  ON cat.CategoryID = p.CategoryID
WHERE c.FullName = 'Ahmet Yilmaz';

-- Sorgu 4: Her kategoride kaç ürün var (ürünü olmayan kategori de 0 ile gelsin)
SELECT cat.CategoryName, COUNT(p.ProductID) AS UrunSayisi
FROM Categories cat
LEFT JOIN Products p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY UrunSayisi DESC;

-- Sorgu 5: Her müşterinin toplam cirosu (en çoktan en aza)
SELECT c.FullName, SUM(o.TotalAmount) AS ToplamCiro
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.FullName
ORDER BY ToplamCiro DESC;

-- Sorgu 6: Siparişlerin üzerinden kaç gün geçmiş
SELECT o.OrderID, c.FullName, o.OrderDate,
       DATEDIFF(DAY, o.OrderDate, GETDATE()) AS GecenGun
FROM Orders o
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
ORDER BY GecenGun DESC;
GO

-- =============================================
-- BÖLÜM 4: İLERİ SEVİYE
-- =============================================

-- Sipariş özeti görünümü (CREATE VIEW kendi batch'inde olmalı)
CREATE VIEW vw_SiparisOzet AS
SELECT c.FullName     AS MusteriAdi,
       o.OrderDate    AS SiparisTarihi,
       p.ProductName  AS UrunAdi,
       od.Quantity    AS Adet
FROM Orders o
INNER JOIN Customers c     ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON od.OrderID = o.OrderID
INNER JOIN Products p      ON p.ProductID = od.ProductID;
GO

-- Görünümü test ediyoruz
SELECT * FROM vw_SiparisOzet
ORDER BY SiparisTarihi;
GO

-- Veritabanı yedeği (C:\Yedek klasörü önceden oluşturulmuş olmalı)
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT, INIT, NAME = 'NovaStoreDB Tam Yedek';
GO
