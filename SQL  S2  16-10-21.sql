----- DA with SQL - S2 - 16/10/21----

---joın

---mağaza çalışanlarını yaptıkları satışlaar ile birlikte listeleyin

SELECT*
FROM sale.staff 
--^ ÇALIŞANLARIN tablosuna göz attık 

SELECT *
FROM sale.orders  
--^Sipariş tablosuna da göz attık. siparişleri ve siparişi alan çalışanı staff_id ile görüyoruz 
--her iki tabloda da ortak sütun staff_id var. bu kolumn üzerinden join yaparız.

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.staff_id
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
ORDER BY B.order_id
--^ FROML'la tablolarımızı INNER JOIN ile birleştiririz. 
-- gelmesini istediğimiz bilgilerin yani kolumn'ları select' ile çağırırız. order'lara işlem yapan çlışanların bilgileri ve order no'ları gelmiş oldu
-- A.staf_id ORDER BY le sıralarız
--NOT: BURADA INNNER JOİNLE EŞLEŞENLER GELDİĞİ İÇİN ŞİPARİŞLERİ ALMAYAN ÇALIŞANLARI GÖREMİYORUZ yANİ NULL DEĞERLER YOK. Null olablilir. bu tan olarak istediğimizi karşılamıyor.
--sipariş almayan çalışanları bulmak için staff tablosu ana tablo olup order tablosunu left joınle birleştiririz. null olanlarda gelir.

-- İnner joın yazmadan araya virgül koyarak yazasak İNNER JOIN foin yapar. **SÜRÜM FARKLILIĞI OLABİLİR. 
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
FROM sale.staff A, sale.orders B ON A.staff_id= B.staff_id

SELECT COUNT (A.staff_id), COUNT (B.staff_id)
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
  --- STAFF VE ORDERS tablosundaki kesişen satırların toplamını verir 1615

SELECT COUNT (DISTINCT A.staff_id), COUNT (DISTINCT  B.staff_id)       
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id   
--- tekrarlayanları iptal ettiğimizde 6 tane staff_id yani çalışan olanı verdi 
--v- fakat bizim çalışanımız 10 kişi 4 kaçak var.
SELECT COUNT (DISTINCT A.staff_id), COUNT (DISTINCT  B.staff_id)       
FROM sale.staff A LEFT JOIN sale.orders B ON A.staff_id= B.staff_id  

--v- onları da bumak için alttaki sorguyu yaparız.
SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.staff_id
FROM sale.staff A LEFT JOIN sale.orders B ON A.staff_id= B.staff_id
ORDER BY B.order_id ASC
------------------------------------------------------------------------------------------------------------------------

-- CROSS JOIN
-- KARTEZYEN OLARAK BÜTÜN EŞLEŞME OLASILIKLARINI GÖSTERİR ÇOK KULLANILMAZ
--------------------------------------------------------------------------------------------------------------------------

--SELF JOIN
-- TABLONUN KENDİSİ İLE JOIN OLMASIDIR.

---------------------------------------------------------------------------------------------------------------------------

-----GROUP BY----
-- VERİ ANALİZİ İÇİN İKİ ÖNEMLİ KONU GROUPİNG VE AGGREGATİON FUNC.' DUR /*/*/*ÖNEMLİ/*/*/
--Kategorileri GROUP BY ile gruplayım AGG.FONC. ile işlem yapıp grupandırmayı yaparım.

--- HAVING 
-- GROUP BY ile kullanılır yaptığımız Agg.fonc işleminin sonucunda filtreleme yapmayı hedefliyoruz bunuda HAVİNG ile yaparız.

--NOT: sql de execute çalışma sırası; FROM > WHERE > GROUP BY > HAVİNG > SELECT > ORDER BY şeKeklinde çalışır.
  FROM VERİYİ NERİDEN ALACAĞIM  WHERE  İŞLEM YAPACAGI ANA VERİYİ ŞARTLARLA FİLİTRELİYOR  GROUP BY GRUPLAMAYI YAP
  HAVING İLE Agg.fon.uyguar SELECT İŞLEM YAPILAN SÜTUNLAR ÇAĞIRILIR. ORDER BY İLE SELECT'TEKİ COLUMN'LARI SIRALARIZ.
  


  --Örnek: Product tablosunda herhangi bir product_id'nin tekrarlayıp tekrarlamadığını kontrol ediniz.

SELECT product_id, COUNT (*) CNT_ROW
FROM product.product 
GROUP BY product_id
HAVING COUNT (*) > 1
--^ Product tablosunda product_id sütunundaki bütün (*) verileri say CNT_ROW adında bir sütun oluştur. GROUB BY grupla 
-- agg fonc. ile oluşan yeni sütunun HAVİNG'le  şrtla filtereleme yaparız.

-------------------------------------------------------------------------------------------------------------------------------
--Örnek : maximum list price' ı 4000' in üzerinde olan veya minimum list price' ı 500' ün altında olan categori id' leri getiriniz
--category name' e gerek yok.

SELECT	category_id, list_price
FROM	product.product
ORDER BY 1, 2 
--^ 1 category_id ile sırala 2'de list_price ile sırala demek slect'te loanları 1,2 diye numaralandırdık


SELECT	category_id,MAX (list_price) AS MAX_PRİCE, MIN (list_price) MİN_PRİCE
FROM	product.product
GROUP BY category_id  
HAVING MAX (list_price) > 4000 OR MIN (list_price) < 500  


SELECT	category_id, MAX(list_price) AS MAX_PRICE, MIN (list_price) MIN_PRICE 
FROM	product.product
GROUP BY	category_id
HAVING	MAX(list_price) > 4000 AND MIN (list_price) < 500
--^ BİZDEN İSTENEN  >4000 VE <500 OLDUĞU İÇİN OR İLE YAPARIZ 
---AND İLE FARKLI SONUÇ ÇIKAR 

------------------------------------------------------------------------------------------------


-- ÖRNEK Markalara ait ortalama ürün fiyatlarını bulunuz.ortalama fiyatlara göre azalan sırayla gösteriniz.
---ortalama ürün fiyatı 1000' den yüksek olan MARKALARI getiriniz

SELECT	B.brand_id, B.brand_name, AVG(A.list_price) avg_price
FROM	product.product A, product.brand B
WHERE	A.brand_id = B.brand_id
GROUP BY
		B.brand_id, B.brand_name
HAVING AVG(A.list_price) >1000
ORDER BY 
		avg_price DESC
-- Ortalama ürün fiyatını istdiği için AVG kullanıyoruz, grupladık  sonra >1000 istediği için HAVİN  ile şartımızı yazıp filtreledik sonra sıraladık


-----GROUPING SETS
--Farklı gruplama kombinasyonlarını kullanmak için yaparız. group bayın altında çeşitli gruplama ayarlamış oluyoruz.


SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year, 
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price
INTO	sale.sales_summary

FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year


-----GROUPING SETS


SELECT *
FROM	sale.sales_summary

----1. Toplam sales miktarını hesaplayınız.


SELECT	SUM(total_sales_price)
FROM	sale.sales_summary
-- SUM İLE sale.sales_summary tablosundaki total_sales_price sütununun toplamını buluruz
-- sum içierdeki değerleri toplar 
-- count içerdeki değerleri sayar

--2. Markaların toplam sales miktarını hesaplayınız

SELECT	brand, SUM(total_sales_price) AS total_sales
FROM	sale.sales_summary
GROUP BY brand 


--3. Kategori bazında yapılan toplam sales miktarını hesaplayınız

SELECT	Category, SUM(total_sales_price) total_sales
FROM	sale.sales_summary
GROUP BY	Category

--4. Marka ve kategori kırılımındaki toplam sales miktarını hesaplayınız

SELECT	brand, Category, SUM(total_sales_price) total_sales
FROM	sale.sales_summary
GROUP BY	brand, Category
ORDER BY brand

--^ yukarıda 4 sorguda çoşitli sorgu yaptık bu sorguları group by yaarak tk tek grupladık
--  Bu bilgileri grouping sets ile tek bir sorguda çagırbilirim.  
SELECT	brand, category, SUM(total_sales_price) 
FROM	sale.sales_summary
GROUP BY
		GROUPING SETS (
				(brand, category),
				(brand),
				(category),
				()
				)
ORDER BY
	brand, category

--group by'ın altında grouping set ile '(' açarız sonra gruplayacağımız sütunları ayrı ayr parantez içinde belirtiriz,
-- burada sale.sales_summary tablosunda brand ve category sütunlarını  SUM(total_sales_price) toplayıp belirtilen sütunları verir.  
-- () boş olarak yazdığımızda sorguda belirtilen agg. işlemi tüm tabloya yapar.  NULL	NULL	7689113.0000 şeklinde sonuç verir.
------------------------------------------------------------------------------------------------------------------------------------------------

---ROLLUP
--Belirtilen sütunları grouping gibi gruplar ilk önce tüm sütunları gruplar sonra sağdan başlayarak birer birer sütunu iptal ederek 
-- gruplamayı devam ettirir. sıralaması önemlidir. en sonunda tüm sütunlar iptal edilerek uyulanan sorgunun agg.func. varsa ona göre bütün tabloyu  getirir.



