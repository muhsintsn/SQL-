use SampleSales
--- use ile �al��aca��m�z DB se�eriz 

--------------------------------------------------------------------------------------
--- INNER JOIN

SELECT TOP 10*    
FROM product.product AS  A
inner join product.category as b on A.category_id = B.category_id

--- ilk �nce se�ecemiz tabloyu FROM la yaz�oruz AS ile isim veririz. Not AS kullnmadan bo�luk vererek isimlendirme yapabiliriz. 
--- bu tabloda nelerin gelmesini istiyorsak SELECT'e yazar�z. TOP 10* yazarsak tablodaki b�t�n columns'lar� ve ilk 10 sat�r� return eder.
--- B�t�n tabloyu birle�tirece�imiz i�in �NNER JOIN'le  join i�lmi yapar�z. join yapaca��m�z tabloyu join sat�r�n� yaz�p ON ile tablolar�n ortak columns'lar� yaz�p bibirine e�itleriz.
-----genelde ID'ler �zerinden join i�lemi olur. YAN� JON VARSA �ART VERMEM�Z  "JO�N_COND�T�ONS (A.category_id = B.category_id) YAZMAMIZ GEREK�R.

---------------------------------------------------------------------------------------

---�rnek: �al��anlar�n isim, soyisim ve stor namelerini  getiren bir sorgu yaz�n
SELECT A.first_name, A.last_name, B.store_name
FROM sale.staff AS A 
INNER JOIN sale.store AS B ON A.store_id = b.store_id 

----------------------------------------------------------------------------------------

---LEFT JOIN  
--- Soldaki tablo tamam� sa�daki tablodan da kesi�enleri getirir. E�le�meyenleri NULL olarak getirir.
--- product tablosunu tamam�n� getir  sale.order_item tablosunuda e�le�enlei getir. Nas�l>>  ON A.product_id = B.product_id  ile e�le�enleri.
--- product tablosunda  olupta sipari� verilmeyen yani order_item tablosunda olmayanlar� istedi�i i�in ilk �nce LEFT JOIN ile tablolar� birle�tirdik, e�le�me olmayanlar NULL geldi�i i�in 
--- yani spari� vemeyenler NULL odu�undan WHERE ile IS NULL sogulamas� yapar�z "E�er B.order_id'de NULL varsa return et".
--- DISTINCT ile tekraralayan veri varsa onlar� engellemek i�in fakat bu tablolarda tekrarlayan yok yani yazmaya gerek yok.(info)

SELECT DISTINCT A.product_id, A.product_name, B.order_id
FROM product.product AS A
LEFT JOIN sale.order_item AS B  ON A.product_id = B.product_id
WHERE B.order_id IS NULL

--- �rnek: �r�nlerin stok bilgilerin return edin. fakat her �r�n her ma�aza stogunda yok olmayanlar NULL ?
--- PRODUCT_ID 310 dan b�y�k olanlar�  istiyor  WHERE ile conditionu yaar�z.
SELECT A.product_id, A.product_name, B.store_id, B.quantity
FROM product.product AS A
LEFT JOIN product.stock B ON A.product_id = B.product_id
WHERE A.product_id > 310
ORDER BY store_id

-----------------------------------------------------------------------------

-- RIGHT JOIN
-- LEFT'�N TERS� AYNI MANTIK  ANA TABLO SA�DA OLMASI GEREK�R 


SELECT A.product_id, B.product_name, A.store_id, A.quantity
FROM product.stock AS A
RIGHT JOIN product. product B ON A.product_id = B.product_id
WHERE A.product_id > 310
ORDER BY store_id

--�RNEK: �al��anlar�n yapt�klar� sipar�lerle ilgili bilgi isteniyor.�nce tablolar�m�z� getirece�iz 
-- all staff ve order tablola�na ula�acag�z ana tablomuz staff tablosudur t�m �al��anlar�n bilgileri mevcut.
--sipariz alamlar�n bilgisine ula�maki�ir order tablosuna bakarak ula��r�z.iki tabloyu jo�n yaprak �al��anlar�n sat�� bilgisine ula��r�z.

SELECT * 
FROM SALE.staff
-- ^^�al��anlar�n bilgileri

SELECT COUNT(staff_id)
FROM sale.staff
--^^ COUNT ile ka� tane staff oldu�un bu �ekilde buluruz.10 �al��an var.

SELECT COUNT (DISTINCT A.staff_id)
FROM sale.staff A INNER JOIN sale.orders B ON  A.staff_id = B.staff_id 
--^^ staff ile order tablosunun kesi�imini  inner join ile al�p toplad���m�zda 6 �al��an ��k�yor.  4 �al��an hi� sipari� vermemi� ka�ak var.

SELECT A.staff_id, A.first_name, A.last_name, B.order_id
FROM sale.staff A LEFT JOIN sale.orders B ON  A.staff_id = B.staff_id 
--^^ left joinle staf ana tblosuna order tablosu jo�n edildi staf_id �zerinden 1619 sat�r geldi en sonda 4 tane NULL var 
--NOT: R�GHT JO�N' KULLANILIR.
------------------------------------------------------------------------------------------------------------------------------------------------------------

---FULL OUTER JOIN 
--- �K� TABLOYU B�RLE�T�R�R. SA�DA VE SOLDAK� T�M VER�LER� GT�R�R.

--�rnek: t�m �r�nler i�in sipari� ve stok bilgilerini istiyor.

SELECT *
FROM sale.order_item A FULL OUTER JOIN product.stock B ON  A.product_id = B.product_id
ORDER BY B.product_id, A.order_id
--^^ Anlaml� tablo olu�turmak i�in ORDER BY s�ralamas� �nemli 
--ORDER BY  A.order_id, B.product_id >> A'ya g�re s�rland���nda B'de veri yokmu� gibi g�r�l�yor
--ORDER BY B.product_id, A.order_id  >> B'ye g�re s�ralad���nda A'daki veriler daha anla��l�r oldu�u i�in bu �ekilde, s�ralamada d�zenleme yapar�z. 

-------------------- end 1.S. ---------------------------------------------------------------------------------------------------------------------------

