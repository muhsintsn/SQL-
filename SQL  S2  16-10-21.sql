----- DA with SQL - S2 - 16/10/21----

---jo�n

---ma�aza �al��anlar�n� yapt�klar� sat��laar ile birlikte listeleyin

SELECT*
FROM sale.staff 
--^ �ALI�ANLARIN tablosuna g�z att�k 

SELECT *
FROM sale.orders  
--^Sipari� tablosuna da g�z att�k. sipari�leri ve sipari�i alan �al��an� staff_id ile g�r�yoruz 
--her iki tabloda da ortak s�tun staff_id var. bu kolumn �zerinden join yapar�z.

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.staff_id
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
ORDER BY B.order_id
--^ FROML'la tablolar�m�z� INNER JOIN ile birle�tiririz. 
-- gelmesini istedi�imiz bilgilerin yani kolumn'lar� select' ile �a��r�r�z. order'lara i�lem yapan �l��anlar�n bilgileri ve order no'lar� gelmi� oldu
-- A.staf_id ORDER BY le s�ralar�z
--NOT: BURADA INNNER JO�NLE E�LE�ENLER GELD��� ���N ��PAR��LER� ALMAYAN �ALI�ANLARI G�REM�YORUZ yAN� NULL DE�ERLER YOK. Null olablilir. bu tan olarak istedi�imizi kar��lam�yor.
--sipari� almayan �al��anlar� bulmak i�in staff tablosu ana tablo olup order tablosunu left jo�nle birle�tiririz. null olanlarda gelir.

-- �nner jo�n yazmadan araya virg�l koyarak yazasak �NNER JOIN foin yapar. **S�R�M FARKLILI�I OLAB�L�R. 
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
FROM sale.staff A, sale.orders B ON A.staff_id= B.staff_id

SELECT COUNT (A.staff_id), COUNT (B.staff_id)
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id
  --- STAFF VE ORDERS tablosundaki kesi�en sat�rlar�n toplam�n� verir 1615

SELECT COUNT (DISTINCT A.staff_id), COUNT (DISTINCT  B.staff_id)       
FROM sale.staff A INNER JOIN sale.orders B ON A.staff_id= B.staff_id   
--- tekrarlayanlar� iptal etti�imizde 6 tane staff_id yani �al��an olan� verdi 
--v- fakat bizim �al��an�m�z 10 ki�i 4 ka�ak var.
SELECT COUNT (DISTINCT A.staff_id), COUNT (DISTINCT  B.staff_id)       
FROM sale.staff A LEFT JOIN sale.orders B ON A.staff_id= B.staff_id  

--v- onlar� da bumak i�in alttaki sorguyu yapar�z.
SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.staff_id
FROM sale.staff A LEFT JOIN sale.orders B ON A.staff_id= B.staff_id
ORDER BY B.order_id ASC
------------------------------------------------------------------------------------------------------------------------

-- CROSS JOIN
-- KARTEZYEN OLARAK B�T�N E�LE�ME OLASILIKLARINI G�STER�R �OK KULLANILMAZ
--------------------------------------------------------------------------------------------------------------------------

--SELF JOIN
-- TABLONUN KEND�S� �LE JOIN OLMASIDIR.

---------------------------------------------------------------------------------------------------------------------------

-----GROUP BY----
-- VER� ANAL�Z� ���N �K� �NEML� KONU GROUP�NG VE AGGREGAT�ON FUNC.' DUR /*/*/*�NEML�/*/*/
--Kategorileri GROUP BY ile gruplay�m AGG.FONC. ile i�lem yap�p grupand�rmay� yapar�m.

--- HAVING 
-- GROUP BY ile kullan�l�r yapt���m�z Agg.fonc i�leminin sonucunda filtreleme yapmay� hedefliyoruz bunuda HAV�NG ile yapar�z.

--NOT: sql de execute �al��ma s�ras�; FROM > WHERE > GROUP BY > HAV�NG > SELECT > ORDER BY �eKeklinde �al���r.
  FROM VER�Y� NER�DEN ALACA�IM  WHERE  ��LEM YAPACAGI ANA VER�Y� �ARTLARLA F�L�TREL�YOR  GROUP BY GRUPLAMAYI YAP
  HAVING �LE Agg.fon.uyguar SELECT ��LEM YAPILAN S�TUNLAR �A�IRILIR. ORDER BY �LE SELECT'TEK� COLUMN'LARI SIRALARIZ.
  


  --�rnek: Product tablosunda herhangi bir product_id'nin tekrarlay�p tekrarlamad���n� kontrol ediniz.

SELECT product_id, COUNT (*) CNT_ROW
FROM product.product 
GROUP BY product_id
HAVING COUNT (*) > 1
--^ Product tablosunda product_id s�tunundaki b�t�n (*) verileri say CNT_ROW ad�nda bir s�tun olu�tur. GROUB BY grupla 
-- agg fonc. ile olu�an yeni s�tunun HAV�NG'le  �rtla filtereleme yapar�z.

-------------------------------------------------------------------------------------------------------------------------------
--�rnek : maximum list price' � 4000' in �zerinde olan veya minimum list price' � 500' �n alt�nda olan categori id' leri getiriniz
--category name' e gerek yok.

SELECT	category_id, list_price
FROM	product.product
ORDER BY 1, 2 
--^ 1 category_id ile s�rala 2'de list_price ile s�rala demek slect'te loanlar� 1,2 diye numaraland�rd�k


SELECT	category_id,MAX (list_price) AS MAX_PR�CE, MIN (list_price) M�N_PR�CE
FROM	product.product
GROUP BY category_id  
HAVING MAX (list_price) > 4000 OR MIN (list_price) < 500  


SELECT	category_id, MAX(list_price) AS MAX_PRICE, MIN (list_price) MIN_PRICE 
FROM	product.product
GROUP BY	category_id
HAVING	MAX(list_price) > 4000 AND MIN (list_price) < 500
--^ B�ZDEN �STENEN  >4000 VE <500 OLDU�U ���N OR �LE YAPARIZ 
---AND �LE FARKLI SONU� �IKAR 

------------------------------------------------------------------------------------------------


-- �RNEK Markalara ait ortalama �r�n fiyatlar�n� bulunuz.ortalama fiyatlara g�re azalan s�rayla g�steriniz.
---ortalama �r�n fiyat� 1000' den y�ksek olan MARKALARI getiriniz

SELECT	B.brand_id, B.brand_name, AVG(A.list_price) avg_price
FROM	product.product A, product.brand B
WHERE	A.brand_id = B.brand_id
GROUP BY
		B.brand_id, B.brand_name
HAVING AVG(A.list_price) >1000
ORDER BY 
		avg_price DESC
-- Ortalama �r�n fiyat�n� istdi�i i�in AVG kullan�yoruz, gruplad�k  sonra >1000 istedi�i i�in HAV�N  ile �art�m�z� yaz�p filtreledik sonra s�ralad�k


-----GROUPING SETS
--Farkl� gruplama kombinasyonlar�n� kullanmak i�in yapar�z. group bay�n alt�nda �e�itli gruplama ayarlam�� oluyoruz.


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

----1. Toplam sales miktar�n� hesaplay�n�z.


SELECT	SUM(total_sales_price)
FROM	sale.sales_summary
-- SUM �LE sale.sales_summary tablosundaki total_sales_price s�tununun toplam�n� buluruz
-- sum i�ierdeki de�erleri toplar 
-- count i�erdeki de�erleri sayar

--2. Markalar�n toplam sales miktar�n� hesaplay�n�z

SELECT	brand, SUM(total_sales_price) AS total_sales
FROM	sale.sales_summary
GROUP BY brand 


--3. Kategori baz�nda yap�lan toplam sales miktar�n� hesaplay�n�z

SELECT	Category, SUM(total_sales_price) total_sales
FROM	sale.sales_summary
GROUP BY	Category

--4. Marka ve kategori k�r�l�m�ndaki toplam sales miktar�n� hesaplay�n�z

SELECT	brand, Category, SUM(total_sales_price) total_sales
FROM	sale.sales_summary
GROUP BY	brand, Category
ORDER BY brand

--^ yukar�da 4 sorguda �o�itli sorgu yapt�k bu sorgular� group by yaarak tk tek gruplad�k
--  Bu bilgileri grouping sets ile tek bir sorguda �ag�rbilirim.  
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

--group by'�n alt�nda grouping set ile '(' a�ar�z sonra gruplayaca��m�z s�tunlar� ayr� ayr parantez i�inde belirtiriz,
-- burada sale.sales_summary tablosunda brand ve category s�tunlar�n�  SUM(total_sales_price) toplay�p belirtilen s�tunlar� verir.  
-- () bo� olarak yazd���m�zda sorguda belirtilen agg. i�lemi t�m tabloya yapar.  NULL	NULL	7689113.0000 �eklinde sonu� verir.
------------------------------------------------------------------------------------------------------------------------------------------------

---ROLLUP
--Belirtilen stunlar� grouping gibi gruplar ilk �nce t�m s�tunlar� gruplar sonra sa�dan ba�layarak birer birer s�tunu iptal ederek 
-- gruplamay� devam ettirir. s�ralamas� �nemlidir. en sonunda t�m s�tunlar iptal edilerek uyulanasogunun agg.func. varsa ona g�re b�t�n tabloyu  getirir.



