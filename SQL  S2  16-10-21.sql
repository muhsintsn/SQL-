----- DA with SQL - S2 - 16/10/21----

---joýn

---maðaza çalýþanlarýný yaptýklarý satýþlaar ile birlikte listeleyin

SELECT*
FROM sale.staff 
--^ ÇALIÞANLARIN tablosuna göz attýk 

SELECT *
FROM sale.orders  
--^Sipariþ tablosuna da göz attýk. sipariþleri ve sipariþi alan çalýþaný staff_id ile görüyoruz 
--her iki tabloda da ortak sütun staff_id var. bu kolumn üzerinden join yaparýz.

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.staff_id
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
ORDER BY B.order_id
--^ FROML'la tablolarýmýzý INNER JOIN ile birleþtiririz. 
-- gelmesini istediðimiz bilgilerin yani kolumn'larý select' ile çaðýrýrýz. order'lara iþlem yapan çlýþanlarýn bilgileri ve order no'larý gelmiþ oldu
-- A.staf_id ORDER BY le sýralarýz
--NOT: BURADA INNNER JOÝNLE EÞLEÞENLER GELDÝÐÝ ÝÇÝN ÞÝPARÝÞLERÝ ALMAYAN ÇALIÞANLARI GÖREMÝYORUZ yANÝ NULL DEÐERLER YOK. Null olablilir. bu tan olarak istediðimizi karþýlamýyor.
--sipariþ almayan çalýþanlarý bulmak için staff tablosu ana tablo olup order tablosunu left joýnle birleþtiririz. null olanlarda gelir.

-- Ýnner joýn yazmadan araya virgül koyarak yazasak ÝNNER JOIN foin yapar. **SÜRÜM FARKLILIÐI OLABÝLÝR. 
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
FROM sale.staff A, sale.orders B ON A.staff_id= B.staff_id

SELECT COUNT (A.staff_id), COUNT (B.staff_id)
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
  --- STAFF VE ORDERS tablosundaki kesiþen satýrlarýn toplamýný verir 1615

SELECT COUNT (DISTINCT A.staff_id), COUNT (DISTINCT  B.staff_id)       
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id   
--- tekrarlayanlarý iptal ettiðimizde 6 tane staff_id yani çalýþan olaný verdi 
--v- fakat bizim çalýþanýmýz 10 kiþi 4 kaçak var.
SELECT COUNT (DISTINCT A.staff_id), COUNT (DISTINCT  B.staff_id)       
FROM sale.staff A LEFT JOIN sale.orders B ON A.staff_id= B.staff_id  

--v- onlarý da bumak için alttaki sorguyu yaparýz.
SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.staff_id
FROM sale.staff A LEFT JOIN sale.orders B ON A.staff_id= B.staff_id
ORDER BY B.order_id ASC
------------------------------------------------------------------------------------------------------------------------

-- CROSS JOIN
-- KARTEZYEN OLARAK BÜTÜN EÞLEÞME OLASILIKLARINI GÖSTERÝR ÇOK KULLANILMAZ
--------------------------------------------------------------------------------------------------------------------------

--SELF JOIN
-- TABLONUN KENDÝSÝ ÝLE JOIN OLMASIDIR.

---------------------------------------------------------------------------------------------------------------------------

-----GROUP BY----
-- VERÝ ANALÝZÝ ÝÇÝN ÝKÝ ÖNEMLÝ KONU GROUPÝNG VE AGGREGATÝON FUNC.' DUR /*/*/*ÖNEMLÝ/*/*/
--Kategorileri GROUP BY ile gruplayým AGG.FONC. ile iþlem yapýp grupandýrmayý yaparým.

--- HAVING 
-- GROUP BY ile kullanýlýr yaptýðýmýz Agg.fonc iþleminin sonucunda filtreleme yapmayý hedefliyoruz bunuda HAVÝNG ile yaparýz.

--NOT: sql de execute çalýþma sýrasý; FROM > WHERE > GROUP BY > HAVÝNG > SELECT > ORDER BY þeKeklinde çalýþýr.
  FROM VERÝYÝ NERÝDEN ALACAÐIM  WHERE  ÝÞLEM YAPACAGI ANA VERÝYÝ ÞARTLARLA FÝLÝTRELÝYOR  GROUP BY GRUPLAMAYI YAP
  HAVING ÝLE Agg.fon.uyguar SELECT ÝÞLEM YAPILAN SÜTUNLAR ÇAÐIRILIR. ORDER BY ÝLE SELECT'TEKÝ COLUMN'LARI SIRALARIZ.
  


  --Örnek: Product tablosunda herhangi bir product_id'nin tekrarlayýp tekrarlamadýðýný kontrol ediniz.

SELECT product_id, COUNT (*) CNT_ROW
FROM product.product 
GROUP BY product_id
HAVING COUNT (*) > 1
--^ Product tablosunda product_id sütunundaki bütün (*) verileri say CNT_ROW adýnda bir sütun oluþtur. GROUB BY grupla 
-- agg fonc. ile oluþan yeni sütunun HAVÝNG'le  þrtla filtereleme yaparýz.

-------------------------------------------------------------------------------------------------------------------------------
--Örnek : maximum list price' ý 4000' in üzerinde olan veya minimum list price' ý 500' ün altýnda olan categori id' leri getiriniz
--category name' e gerek yok.

SELECT	category_id, list_price
FROM	product.product
ORDER BY 1, 2 
--^ 1 category_id ile sýrala 2'de list_price ile sýrala demek slect'te loanlarý 1,2 diye numaralandýrdýk


SELECT	category_id,MAX (list_price) AS MAX_PRÝCE, MIN (list_price) MÝN_PRÝCE
FROM	product.product
GROUP BY category_id  
HAVING MAX (list_price) > 4000 OR MIN (list_price) < 500  


SELECT	category_id, MAX(list_price) AS MAX_PRICE, MIN (list_price) MIN_PRICE 
FROM	product.product
GROUP BY	category_id
HAVING	MAX(list_price) > 4000 AND MIN (list_price) < 500
--^ BÝZDEN ÝSTENEN  >4000 VE <500 OLDUÐU ÝÇÝN OR ÝLE YAPARIZ 
---AND ÝLE FARKLI SONUÇ ÇIKAR 

------------------------------------------------------------------------------------------------


-- ÖRNEK Markalara ait ortalama ürün fiyatlarýný bulunuz.ortalama fiyatlara göre azalan sýrayla gösteriniz.
---ortalama ürün fiyatý 1000' den yüksek olan MARKALARI getiriniz

SELECT	B.brand_id, B.brand_name, AVG(A.list_price) avg_price
FROM	product.product A, product.brand B
WHERE	A.brand_id = B.brand_id
GROUP BY
		B.brand_id, B.brand_name
HAVING AVG(A.list_price) >1000
ORDER BY 
		avg_price DESC
-- Ortalama ürün fiyatýný istdiði için AVG kullanýyoruz, grupladýk  sonra >1000 istediði için HAVÝN  ile þartýmýzý yazýp filtreledik sonra sýraladýk


-----GROUPING SETS
--Farklý gruplama kombinasyonlarýný kullanmak için yaparýz. group bayýn altýnda çeþitli gruplama ayarlamýþ oluyoruz.


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

----1. Toplam sales miktarýný hesaplayýnýz.


SELECT	SUM(total_sales_price)
FROM	sale.sales_summary
-- SUM ÝLE sale.sales_summary tablosundaki total_sales_price sütununun toplamýný buluruz
-- sum içierdeki deðerleri toplar 
-- count içerdeki deðerleri sayar

--2. Markalarýn toplam sales miktarýný hesaplayýnýz

SELECT	brand, SUM(total_sales_price) AS total_sales
FROM	sale.sales_summary
GROUP BY brand 


--3. Kategori bazýnda yapýlan toplam sales miktarýný hesaplayýnýz

SELECT	Category, SUM(total_sales_price) total_sales
FROM	sale.sales_summary
GROUP BY	Category

--4. Marka ve kategori kýrýlýmýndaki toplam sales miktarýný hesaplayýnýz

SELECT	brand, Category, SUM(total_sales_price) total_sales
FROM	sale.sales_summary
GROUP BY	brand, Category
ORDER BY brand

--^ yukarýda 4 sorguda çoþitli sorgu yaptýk bu sorgularý group by yaarak tk tek grupladýk
--  Bu bilgileri grouping sets ile tek bir sorguda çagýrbilirim.  
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

--group by'ýn altýnda grouping set ile '(' açarýz sonra gruplayacaðýmýz sütunlarý ayrý ayr parantez içinde belirtiriz,
-- burada sale.sales_summary tablosunda brand ve category sütunlarýný  SUM(total_sales_price) toplayýp belirtilen sütunlarý verir.  
-- () boþ olarak yazdýðýmýzda sorguda belirtilen agg. iþlemi tüm tabloya yapar.  NULL	NULL	7689113.0000 þeklinde sonuç verir.
------------------------------------------------------------------------------------------------------------------------------------------------

---ROLLUP
--Belirtilen stunlarý grouping gibi gruplar ilk önce tüm sütunlarý gruplar sonra saðdan baþlayarak birer birer sütunu iptal ederek 
-- gruplamayý devam ettirir. sýralamasý önemlidir. en sonunda tüm sütunlar iptal edilerek uyulanasogunun agg.func. varsa ona göre bütün tabloyu  getirir.



