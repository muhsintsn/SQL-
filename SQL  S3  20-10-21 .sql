---SQL S3 20-10-202  (Organize Complex Queries)


--SELECT*
--INTO 
--FROM 
-- BÝR TABLO ÝÇÝNDEKÝ BAZI VERÝLERÝ KOPYALAMAK ÝSTEDÝÐÝMÝZDE VEYA YAPTIÐIMIZ ÖZET TABLOYU ÝLERÝDE TEKRAR KULLANMAK ÝÇÝN YÝNÝ BÝR TABLLO OLUÞTURMASIDIR,

SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year, 
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price
INTO	sale.sales_summary

FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year



---ROLLUP
--Belirtilen stunlarý grouping gibi gruplar ilk önce tüm sütunlarý gruplar sonra saðdan baþlayarak birer birer sütunu iptal ederek 
--gruplamayý devam ettirir. sýralamasý önemlidir. en sonunda tüm sütunlar iptal edilerek uyulanasogunun agg.func. varsa ona göre bütün tabloyu  getirir.
--Veri ambarýnda uðraþanlar sql veri analizinde kullanýlýr.

SELECT *
FROM sale.sales_summary

--brand, category, model_year sütunlarý için Rollup kullanarak total sales hesaplamasý yapýn.
--üç sütun için 4 farklý gruplama varyasyonu üretmek istiyoruz.

SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		ROLLUP (brand, Category, Model_Year)
--^ group by altýnda ROLLUP ile SELECT'te seçtiðimiz kategori sütunlarýný grupla.sýrayla kategorileri silerek yeni gruplama yappar 
-- en son satýrda tüm sütunlar nul gelir agg.fonc. ile istediðimiz sum ile tüm tabloyu toplar. en son satýr >>(NULL	NULL	NULL	7689113.0000) buþekilde return eder.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---CUBE
-- Cube'de ayný Rollup gibi farký daha çok kombinasyon yapmasý yani tüm olasýlýklarý gruplama yapar.

SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		CUBE (brand, Category, Model_Year)
--^ Örneði rollup ile yaptýðýmýzda 74 satýr, cube ile yaptýðýmýzda 121 satýr geldi daha çok combim yaptý

--brand, category, model_year sütunlarý için cube kullanarak total sales hesaplamasý yapýn.

--üç sütun için 8 farklý gruplama varyasyonu oluþturuyor	

SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		CUBE (brand, Category, Model_Year)
ORDER BY
		brand, Category
-----------------------------------------------------------------------------------------------------------------------

---PÝVOT TABLE  
--PYTHON'da Transpoze ile aynýdýr.Analiz sonucunda kaegorik olarak gelen satýrlarý unie olarak stunlara çevirip hesaplanan deðerleride altýna yazar.
--group by kullanýlmaz. ilk önce pivot yapacaðýmýz tabloyu seçeriz sonra CTE veya Subquery ile pivot yapýlacak tablonun sunurlarý  belirlenir
-- en son pivotu oluþtururuz.

--kategorilere ve model yýlýna göre toplam sales miktarýný summary tablosu üzerinden hesaplayýn

SELECT Category, Model_Year, SUM(total_sales_price)
FROM SALE.sales_summary
GROUP BY Category, Model_Year
ORDER BY 1,2 

-------------------------

SELECT *
FROM
	(
	SELECT Category, Model_Year, total_sales_price
	FROM	SALE.sales_summary
	) A
PIVOT
	(
	SUM(total_sales_price)
	FOR Category
	IN (
		[Children Bicycles], 
		[Comfort Bicycles], 
		[Cruisers Bicycles], 
		[Cyclocross Bicycles], 
		[Electric Bikes], 
		[Mountain Bikes], 
		[Road Bikes]
		)
	) AS P1

/*  pivot yapacaðýmýz ana tabloyu oluþturuyoruz A alias ile isim veriyoruz. yani analiz sonucu tablomuz bu oluyor.
Sora bu tabloyu daha anlaþýlýr yapmak için PÝVOT tablosuna çeviriyoruz. Pivot'un içinde sum iþlemini yapýyoruz ve for category ile in'in içinde sütunlarý 
oluþyuruyoruz parntezleri kapatýyoruz pivot tablomuz oluþmuþ olur.*/ 

--------------/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/--------------------------------------

---            OROGANÝZED COMPLEX QUERÝSE                  -----
-- SUBQEURÝES
-- VÝEWS
--COMMON TABLE EXPRESSÝON (CTE's)

-- Büyük tablolarý bölerek sorgularýmýzýn daha hýzlý çalýþmasýný saðlarýz.

-------- SUBQEURÝES----

--SINGLE - ROW SUBQEURÝES  : = > < >= <0=  <> opreratörleri koullanýlýr tek satýr döndürürü.  

--order id' lere göre toplam list price larý hesaplayýn.

SELECT	DISTINCT order_id,
		(SELECT SUM(list_price) FROM sale.order_item B) SUM_PRÝCE
FROM	sale.order_item A
--^ Select altýnda subquery oluþturuyoruz. Amaç; sale.order_item tablosundan order_id ve list_price toplamýný görmek.
-- önemli select altýnadki subquery'de tek bir deðer sütun dönmesi gerekir.


---CORRELATED


SELECT	DISTINCT order_id,
		(SELECT SUM(list_price) FROM sale.order_item B WHERE A.order_id = B.order_id) SUM_PRICE
FROM	sale.order_item A

--bir önceki sorguyla ayný sadece korelated olarak verdi. ilgili ýd'lr üzerinden corele sonuç verdi.

--örnek (where içinde subquery)

-- Maria Cussona'nýn çalýþtýðý maðazadaki tüm personelleri listeleyin.

SELECT *
FROM SALE.staff
WHERE first_name = 'Maria' AND last_name ='Cussona'
--^ marianýnbilgilerine staff tablosundan ulaþtýk

SELECT store_id
FROM SALE.staff
WHERE first_name = 'Maria' AND last_name ='Cussona'
--^ marianýn store_id sini bulduk bu taplo single row dödürdü
-- bu sorguyu kullanarak yani marianýn çalýþtýðý maðazanýn store_id üzerinden çalýþanlarýný bulacagýz,
-- bu sorguyu altsorgu olarak where içine yazarýz.

SELECT first_name, last_name
FROM  sale.staff
WHERE store_id = (
					SELECT store_id
					FROM SALE.staff
					WHERE first_name = 'Maria' AND last_name ='Cussona'
				)
-- maria'nýn store_id'sinden  staff tablosundan çalýþanlarýn isim soyisimlerine ulaþtýk 

 


-- örnek :Jane	Destrey'ýn yöneticisi olduðu personelleri listeleyin.

SELECT *
FROM  sale.staff
WHERE manager_id = (				
				SELECT staff_id
				FROM SALE.staff
				WHERE first_name = 'Jane' AND last_name ='Destrey'
				)


--MULTIPLE - ROW SUBQEURÝES : IN, NOT IN, ANY ALL kullanýlýr = > < kullanýlacaksa ANY ve ALL ile kullanýlýr.

-- Holbrook þehrinde oturan müþterilerin sipariþ tarihlerini listeleyin.


SELECT*
FROM sale.customer
WHERE city = 'Holbrook'
--Holbrook þehrindeki müþteri bilgisine ulaþtýk. görüldüðü gibi 3 rows return etti.
--Bu sorguyu subquery olarak where içinde kullanýrýz.


SELECT customer_id, order_id, order_date
FROM SALE.orders
WHERE customer_id IN (
						SELECT customer_id
						FROM sale.customer
						WHERE city = 'Holbrook'
						)

-- Abby	Parks isimli müþterinin alýþveriþ yaptýðý tarihte/tarihlerde alýþveriþ yapan tüm müþterileri listeleyin.
-- Müþteri adý, soyadý ve sipariþ tarihi bilgilerini listeleyin.

SELECT A.first_name, A.last_name, B.customer_id, B.order_id, b.order_date
FROM Sale.customer A INNER JOIN Sale.orders B ON A.customer_id = B.customer_id
WHERE first_name = 'Abby' AND last_name = 'Parks'
--^ öncelikle abby nin alýþveriþ yaptýðý tarihleri buluruz bunun için Sale.customer  Sale.orders tablolarýný joýn yaparýz ve ilgili bilgileri iteriz 
-- order tarihini buluruz.
-- sonra bu iki farklý günde sipariþ veren müþterileri arayacaðýz.

-- Yukarýdaki sorguyu Subquery olarak laýrýz tarýhlari vediði için  bu suruyu order tablosu ile joýn yaparuz, order_date üzerinden 
--bize bu trihlerdeki tüm sipariþ veren customer_id yi bulmuþ olduk.

select* 
from sale.orders A INNER JOIN (
								SELECT A.first_name, A.last_name, B.customer_id, B.order_id, b.order_date
								FROM Sale.customer A INNER JOIN Sale.orders B ON A.customer_id = B.customer_id
								WHERE first_name = 'Abby' AND last_name = 'Parks'
								) B
	ON A.order_date = B.order_date


-- bulduðumuz customer_id 'lerin ismlerini öðrenmek istiyoruz tekrar yukarýdaki sorguyu fromu'un içinde inner joýn yaparýz.
--sale.customer C ON A.customer_id = C.customer_id þeklinde isimlere ulaþýrýz.

select C.first_name, C.last_name, A.order_id, A.order_date
from sale.orders A 
INNER JOIN (
			SELECT A.first_name, A.last_name, B.customer_id, B.order_id, b.order_date
			FROM Sale.customer A INNER JOIN Sale.orders B ON A.customer_id = B.customer_id
			WHERE first_name = 'Abby' AND last_name = 'Parks'
			) B
ON A.order_date = B.order_date
INNER JOIN sale.customer C ON A.customer_id = C.customer_id

--------------------------------------------------------------------------------------------------------

-- Bütün elektrikli bisikletlerden pahalý olan bisikletleri listelyin.
-- Ürün adý, model_yýlý ve fiyat bilgilerini yüksek fiyattan düþük fiyata doðru sýralayýnýz.
-- ALL ve ANY kullanýmý

--önce elektrikli bisikletlerin fiyatlarýný getirmek için iki tabloyu joinleriz (product ve category) 

select list_price
from product.product A inner join product.category B ON A.category_id= B.category_id
where b.category_name = 'Electric Bikes'

--sonra yukarýdaki sorguyu where içinde subquery yaparýz çünkü burada dönen sþart olarak kullanýp sonucu > ALL   ile filtreleyip 4999,99 dan büyük ve 2020 model olanlarý bulacaðýz. 

select product_name, list_price
from product.product
where list_price > ALL (
						select list_price
						from product.product A inner join product.category B ON A.category_id= B.category_id
						where b.category_name = 'Electric Bikes'
						)
and model_year = 2020  

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---          EXÝSTS / NOT EXÝSTS   VAR/ YOK 

		-- SUBQERY ile ana QUERY tablolarýnýn birbiri ile join edilmesi, birbirine baðlanmasýdýr.

--- Bunlar genelde EXISTS ve NOT EXISTS ile kullanýlýyor.

-- EXIST kullandýðýn zaman; subquery herhangi bir sonuç döndürürse üstteki query'i ÇALIÞTIR anlamýna geliyor
-- NOT EXIST ; subquery herhangi bir sonuç döndürürse üstteki query'i ÇALIÞTIRMA anlamýna geliyor

-- alt sorgudan gelen deðer varsa exists üst sorguyu çalýþtýrýr
--alt sorgudan gelen deðer varsa not exists üst sorguyu çalýþtýrma
--veya
-- alt sorgudan gelen deðer yok exists üst sorguyu çalýþtýrýma
--alt sorgudan gelen deðer yok  not exists üst sorguyu çalýþtýrýr


SELECT DISTINCT B.first_name, B.last_name, A.order_date
FROM Sale.orders A
JOIN Sale.customer B
ON A.customer_id = B.customer_id
WHERE EXISTS (
					SELECT 1
					FROM Sale.customer A
					JOIN Sale.orders B
					ON A.customer_id = B.customer_id
					WHERE first_name = 'Abby' AND last_name = 'Parks'
					)

---CORRELATED



SELECT DISTINCT B.first_name, B.last_name, A.order_date
FROM Sale.orders A
JOIN Sale.customer B
ON A.customer_id = B.customer_id
WHERE EXISTS (
					SELECT 1
					FROM Sale.customer C
					JOIN Sale.orders D
					ON C.customer_id = D.customer_id
					WHERE first_name = 'Abby' AND last_name = 'Parks'
					AND		A.order_date = D.order_date
					)



---

SELECT DISTINCT B.first_name, B.last_name, A.order_date
FROM Sale.orders A
JOIN Sale.customer B
ON A.customer_id = B.customer_id
WHERE NOT EXISTS (
					SELECT 1
					FROM Sale.customer A
					JOIN Sale.orders B
					ON A.customer_id = B.customer_id
					WHERE first_name = 'Abbay' AND last_name = 'Parks'
					)




