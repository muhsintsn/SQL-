---SQL S3 20-10-202  (Organize Complex Queries)


--SELECT*
--INTO 
--FROM 
-- B�R TABLO ���NDEK� BAZI VER�LER� KOPYALAMAK �STED���M�ZDE VEYA YAPTI�IMIZ �ZET TABLOYU �LER�DE TEKRAR KULLANMAK ���N Y�N� B�R TABLLO OLU�TURMASIDIR,

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
--Belirtilen stunlar� grouping gibi gruplar ilk �nce t�m s�tunlar� gruplar sonra sa�dan ba�layarak birer birer s�tunu iptal ederek 
--gruplamay� devam ettirir. s�ralamas� �nemlidir. en sonunda t�m s�tunlar iptal edilerek uyulanasogunun agg.func. varsa ona g�re b�t�n tabloyu  getirir.
--Veri ambar�nda u�ra�anlar sql veri analizinde kullan�l�r.

SELECT *
FROM sale.sales_summary

--brand, category, model_year s�tunlar� i�in Rollup kullanarak total sales hesaplamas� yap�n.
--�� s�tun i�in 4 farkl� gruplama varyasyonu �retmek istiyoruz.

SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		ROLLUP (brand, Category, Model_Year)
--^ group by alt�nda ROLLUP ile SELECT'te se�ti�imiz kategori s�tunlar�n� grupla.s�rayla kategorileri silerek yeni gruplama yappar 
-- en son sat�rda t�m s�tunlar nul gelir agg.fonc. ile istedi�imiz sum ile t�m tabloyu toplar. en son sat�r >>(NULL	NULL	NULL	7689113.0000) bu�ekilde return eder.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---CUBE
-- Cube'de ayn� Rollup gibi fark� daha �ok kombinasyon yapmas� yani t�m olas�l�klar� gruplama yapar.

SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		CUBE (brand, Category, Model_Year)
--^ �rne�i rollup ile yapt���m�zda 74 sat�r, cube ile yapt���m�zda 121 sat�r geldi daha �ok combim yapt�

--brand, category, model_year s�tunlar� i�in cube kullanarak total sales hesaplamas� yap�n.

--�� s�tun i�in 8 farkl� gruplama varyasyonu olu�turuyor	

SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		CUBE (brand, Category, Model_Year)
ORDER BY
		brand, Category
-----------------------------------------------------------------------------------------------------------------------

---P�VOT TABLE  
--PYTHON'da Transpoze ile ayn�d�r.Analiz sonucunda kaegorik olarak gelen sat�rlar� unie olarak stunlara �evirip hesaplanan de�erleride alt�na yazar.
--group by kullan�lmaz. ilk �nce pivot yapaca��m�z tabloyu se�eriz sonra CTE veya Subquery ile pivot yap�lacak tablonun sunurlar�  belirlenir
-- en son pivotu olu�tururuz.

--kategorilere ve model y�l�na g�re toplam sales miktar�n� summary tablosu �zerinden hesaplay�n

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

/*  pivot yapaca��m�z ana tabloyu olu�turuyoruz A alias ile isim veriyoruz. yani analiz sonucu tablomuz bu oluyor.
Sora bu tabloyu daha anla��l�r yapmak i�in P�VOT tablosuna �eviriyoruz. Pivot'un i�inde sum i�lemini yap�yoruz ve for category ile in'in i�inde s�tunlar� 
olu�yuruyoruz parntezleri kapat�yoruz pivot tablomuz olu�mu� olur.*/ 

--------------/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/--------------------------------------

---            OROGAN�ZED COMPLEX QUER�SE                  -----
-- SUBQEUR�ES
-- V�EWS
--COMMON TABLE EXPRESS�ON (CTE's)

-- B�y�k tablolar� b�lerek sorgular�m�z�n daha h�zl� �al��mas�n� sa�lar�z.

-------- SUBQEUR�ES----

--SINGLE - ROW SUBQEUR�ES  : = > < >= <0=  <> oprerat�rleri koullan�l�r tek sat�r d�nd�r�r�.  

--order id' lere g�re toplam list price lar� hesaplay�n.

SELECT	DISTINCT order_id,
		(SELECT SUM(list_price) FROM sale.order_item B) SUM_PR�CE
FROM	sale.order_item A
--^ Select alt�nda subquery olu�turuyoruz. Ama�; sale.order_item tablosundan order_id ve list_price toplam�n� g�rmek.
-- �nemli select alt�nadki subquery'de tek bir de�er s�tun d�nmesi gerekir.


---CORRELATED


SELECT	DISTINCT order_id,
		(SELECT SUM(list_price) FROM sale.order_item B WHERE A.order_id = B.order_id) SUM_PRICE
FROM	sale.order_item A

--bir �nceki sorguyla ayn� sadece korelated olarak verdi. ilgili �d'lr �zerinden corele sonu� verdi.

--�rnek (where i�inde subquery)

-- Maria Cussona'n�n �al��t��� ma�azadaki t�m personelleri listeleyin.

SELECT *
FROM SALE.staff
WHERE first_name = 'Maria' AND last_name ='Cussona'
--^ marian�nbilgilerine staff tablosundan ula�t�k

SELECT store_id
FROM SALE.staff
WHERE first_name = 'Maria' AND last_name ='Cussona'
--^ marian�n store_id sini bulduk bu taplo single row d�d�rd�
-- bu sorguyu kullanarak yani marian�n �al��t��� ma�azan�n store_id �zerinden �al��anlar�n� bulacag�z,
-- bu sorguyu altsorgu olarak where i�ine yazar�z.

SELECT first_name, last_name
FROM  sale.staff
WHERE store_id = (
					SELECT store_id
					FROM SALE.staff
					WHERE first_name = 'Maria' AND last_name ='Cussona'
				)
-- maria'n�n store_id'sinden  staff tablosundan �al��anlar�n isim soyisimlerine ula�t�k 

 


-- �rnek :Jane	Destrey'�n y�neticisi oldu�u personelleri listeleyin.

SELECT *
FROM  sale.staff
WHERE manager_id = (				
				SELECT staff_id
				FROM SALE.staff
				WHERE first_name = 'Jane' AND last_name ='Destrey'
				)


--MULTIPLE - ROW SUBQEUR�ES : IN, NOT IN, ANY ALL kullan�l�r = > < kullan�lacaksa ANY ve ALL ile kullan�l�r.

-- Holbrook �ehrinde oturan m��terilerin sipari� tarihlerini listeleyin.


SELECT*
FROM sale.customer
WHERE city = 'Holbrook'
--Holbrook �ehrindeki m��teri bilgisine ula�t�k. g�r�ld��� gibi 3 rows return etti.
--Bu sorguyu subquery olarak where i�inde kullan�r�z.


SELECT customer_id, order_id, order_date
FROM SALE.orders
WHERE customer_id IN (
						SELECT customer_id
						FROM sale.customer
						WHERE city = 'Holbrook'
						)

-- Abby	Parks isimli m��terinin al��veri� yapt��� tarihte/tarihlerde al��veri� yapan t�m m��terileri listeleyin.
-- M��teri ad�, soyad� ve sipari� tarihi bilgilerini listeleyin.

SELECT A.first_name, A.last_name, B.customer_id, B.order_id, b.order_date
FROM Sale.customer A INNER JOIN Sale.orders B ON A.customer_id = B.customer_id
WHERE first_name = 'Abby' AND last_name = 'Parks'
--^ �ncelikle abby nin al��veri� yapt��� tarihleri buluruz bunun i�in Sale.customer  Sale.orders tablolar�n� jo�n yapar�z ve ilgili bilgileri iteriz 
-- order tarihini buluruz.
-- sonra bu iki farkl� g�nde sipari� veren m��terileri arayaca��z.

-- Yukar�daki sorguyu Subquery olarak la�r�z tar�hlari vedi�i i�in  bu suruyu order tablosu ile jo�n yaparuz, order_date �zerinden 
--bize bu trihlerdeki t�m sipari� veren customer_id yi bulmu� olduk.

select* 
from sale.orders A INNER JOIN (
								SELECT A.first_name, A.last_name, B.customer_id, B.order_id, b.order_date
								FROM Sale.customer A INNER JOIN Sale.orders B ON A.customer_id = B.customer_id
								WHERE first_name = 'Abby' AND last_name = 'Parks'
								) B
	ON A.order_date = B.order_date


-- buldu�umuz customer_id 'lerin ismlerini ��renmek istiyoruz tekrar yukar�daki sorguyu fromu'un i�inde inner jo�n yapar�z.
--sale.customer C ON A.customer_id = C.customer_id �eklinde isimlere ula��r�z.

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

-- B�t�n elektrikli bisikletlerden pahal� olan bisikletleri listelyin.
-- �r�n ad�, model_y�l� ve fiyat bilgilerini y�ksek fiyattan d���k fiyata do�ru s�ralay�n�z.
-- ALL ve ANY kullan�m�

--�nce elektrikli bisikletlerin fiyatlar�n� getirmek i�in iki tabloyu joinleriz (product ve category) 

select list_price
from product.product A inner join product.category B ON A.category_id= B.category_id
where b.category_name = 'Electric Bikes'

--sonra yukar�daki sorguyu where i�inde subquery yapar�z ��nk� burada d�nen s�art olarak kullan�p sonucu > ALL   ile filtreleyip 4999,99 dan b�y�k ve 2020 model olanlar� bulaca��z. 

select product_name, list_price
from product.product
where list_price > ALL (
						select list_price
						from product.product A inner join product.category B ON A.category_id= B.category_id
						where b.category_name = 'Electric Bikes'
						)
and model_year = 2020  

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---          EX�STS / NOT EX�STS   VAR/ YOK 

		-- SUBQERY ile ana QUERY tablolar�n�n birbiri ile join edilmesi, birbirine ba�lanmas�d�r.

--- Bunlar genelde EXISTS ve NOT EXISTS ile kullan�l�yor.

-- EXIST kulland���n zaman; subquery herhangi bir sonu� d�nd�r�rse �stteki query'i �ALI�TIR anlam�na geliyor
-- NOT EXIST ; subquery herhangi bir sonu� d�nd�r�rse �stteki query'i �ALI�TIRMA anlam�na geliyor

-- alt sorgudan gelen de�er varsa exists �st sorguyu �al��t�r�r
--alt sorgudan gelen de�er varsa not exists �st sorguyu �al��t�rma
--veya
-- alt sorgudan gelen de�er yok exists �st sorguyu �al��t�r�ma
--alt sorgudan gelen de�er yok  not exists �st sorguyu �al��t�r�r


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




