# NovaStore E-Ticaret Veri Yönetim Sistemi

SQL Server (T-SQL) ile hazırlanmış bir e-ticaret veritabanı projesi. Kategoriler, ürünler, müşteriler, siparişler ve sipariş detayları tablolarından oluşur.

## İçerik

`EdanurCelik_NovaStore_Proje.sql` dosyası tek seferde baştan sona çalıştırılabilir:

1. **DDL:** `NovaStoreDB` veritabanı ve 5 tablo (Categories, Customers, Products, Orders, OrderDetails), birincil ve yabancı anahtarlar
2. **DML:** 5 kategori, 12 ürün, 6 müşteri, 10 sipariş ve sipariş detayları. Sipariş toplamları detaylardan hesaplanır.
3. **Sorgular:** düşük stoklu ürünler, müşteri-sipariş listesi, zincirleme JOIN, kategori bazında ürün sayısı, müşteri cirosu, siparişlerin üzerinden geçen gün
4. **İleri seviye:** `vw_SiparisOzet` görünümü ve `BACKUP DATABASE` ile yedekleme

## Çalıştırma

1. SQL Server Management Studio (SSMS) ile sunucuya bağlan.
2. Yedekleme için `C:\Yedek` klasörünün var olduğundan emin ol.
3. `EdanurCelik_NovaStore_Proje.sql` dosyasını aç ve **Execute (F5)** ile çalıştır.

## Tablolar arası ilişkiler

- Categories 1 - N Products
- Customers 1 - N Orders
- Orders 1 - N OrderDetails
- Products 1 - N OrderDetails
