use SampleSales
--- use ile çalýþacaðýmýz DB seçeriz 

--------------------------------------------------------------------------------------
--- INNER JOIN

SELECT TOP 10*    
FROM product.product AS  A
inner join product.category as b on A.category_id = B.category_id

--- ilk önce seçecemiz tabloyu FROM la yazýoruz AS ile isim veririz. Not AS kullnmadan boþluk vererek isimlendirme yapabiliriz. 
--- bu tabloda nelerin gelmesini istiyorsak SELECT'e yazarýz. TOP 10* yazarsak tablodaki bütün columns'larý ve ilk 10 satýrý return eder.
--- BÜtün tabloyu birleþtireceðimiz için ÝNNER JOIN'le  join iþlmi yaparýz. join yapacaðýmýz tabloyu join satýrýný yazýp ON ile tablolarýn ortak columns'larý yazýp bibirine eþitleriz.
-----genelde ID'ler üzerinden join iþlemi olur. YANÝ JON VARSA ÞART VERMEMÝZ  "JOÝN_CONDÝTÝONS (A.category_id = B.category_id) YAZMAMIZ GEREKÝR.

---------------------------------------------------------------------------------------

---örnek: çalýþanlarýn isim, soyisim ve stor namelerini  getiren bir sorgu yazýn
SELECT A.first_name, A.last_name, B.store_name
FROM sale.staff AS A 
INNER JOIN sale.store AS B ON A.store_id = b.store_id 

----------------------------------------------------------------------------------------

---LEFT JOIN  
--- Soldaki tablo tamamý saðdaki tablodan da kesiþenleri getirir. Eþleþmeyenleri NULL olarak getirir.
--- product tablosunu tamamýný getir  sale.order_item tablosunuda eþleþenlei getir. Nasýl>>  ON A.product_id = B.product_id  ile eþleþenleri.
--- product tablosunda  olupta sipariþ verilmeyen yani order_item tablosunda olmayanlarý istediði için ilk önce LEFT JOIN ile tablolarý birleþtirdik, eþleþme olmayanlar NULL geldiði için 
--- yani spariþ vemeyenler NULL oduðundan WHERE ile IS NULL sogulamasý yaparýz "Eðer B.order_id'de NULL varsa return et".
--- DISTINCT ile tekraralayan veri varsa onlarý engellemek için fakat bu tablolarda tekrarlayan yok yani yazmaya gerek yok.(info)

SELECT DISTINCT A.product_id, A.product_name, B.order_id
FROM product.product AS A
LEFT JOIN sale.order_item AS B  ON A.product_id = B.product_id
WHERE B.order_id IS NULL

--- örnek: ürünlerin stok bilgilerin return edin. fakat her ürün her maðaza stogunda yok olmayanlar NULL ?
--- PRODUCT_ID 310 dan büyük olanlarý  istiyor  WHERE ile conditionu yaarýz.
SELECT A.product_id, A.product_name, B.store_id, B.quantity
FROM product.product AS A
LEFT JOIN product.stock B ON A.product_id = B.product_id
WHERE A.product_id > 310
ORDER BY store_id

-----------------------------------------------------------------------------

-- RIGHT JOIN
-- LEFT'ÝN TERSÝ AYNI MANTIK  ANA TABLO SAÐDA OLMASI GEREKÝR 


SELECT A.product_id, B.product_name, A.store_id, A.quantity
FROM product.stock AS A
RIGHT JOIN product. product B ON A.product_id = B.product_id
WHERE A.product_id > 310
ORDER BY store_id

--ÖRNEK: Çalýþanlarýn yaptýklarý siparþlerle ilgili bilgi isteniyor.Önce tablolarýmýzý getireceðiz 
-- all staff ve order tablolaýna ulaþacagýz ana tablomuz staff tablosudur tüm çalýþanlarýn bilgileri mevcut.
--sipariz alamlarýn bilgisine ulaþmakiçir order tablosuna bakarak ulaþýrýz.iki tabloyu joýn yaprak çalýþanlarýn satýþ bilgisine ulaþýrýz.

SELECT * 
FROM SALE.staff
-- ^^çalýþanlarýn bilgileri

SELECT COUNT(staff_id)
FROM sale.staff
--^^ COUNT ile kaç tane staff olduðun bu þekilde buluruz.10 çalýþan var.

SELECT COUNT (DISTINCT A.staff_id)
FROM sale.staff A INNER JOIN sale.orders B ON  A.staff_id = B.staff_id 
--^^ staff ile order tablosunun kesiþimini  inner join ile alýp topladýðýmýzda 6 çalýþan çýkýyor.  4 çalýþan hiç sipariþ vermemiþ kaçak var.

SELECT A.staff_id, A.first_name, A.last_name, B.order_id
FROM sale.staff A LEFT JOIN sale.orders B ON  A.staff_id = B.staff_id 
--^^ left joinle staf ana tblosuna order tablosu joýn edildi staf_id üzerinden 1619 satýr geldi en sonda 4 tane NULL var 
--NOT: RÝGHT JOÝN' KULLANILIR.
------------------------------------------------------------------------------------------------------------------------------------------------------------

---FULL OUTER JOIN 
--- ÝKÝ TABLOYU BÝRLEÞTÝRÝR. SAÐDA VE SOLDAKÝ TÜM VERÝLERÝ GTÝRÝR.

--Örnek: tüm ürünler için sipariþ ve stok bilgilerini istiyor.

SELECT *
FROM sale.order_item A FULL OUTER JOIN product.stock B ON  A.product_id = B.product_id
ORDER BY B.product_id, A.order_id
--^^ Anlamlý tablo oluþturmak için ORDER BY sýralamasý önemli 
--ORDER BY  A.order_id, B.product_id >> A'ya göre sýrlandýðýnda B'de veri yokmuþ gibi görülüyor
--ORDER BY B.product_id, A.order_id  >> B'ye göre sýraladýðýnda A'daki veriler daha anlaþýlýr olduðu için bu þekilde, sýralamada düzenleme yaparýz. 

-------------------- end 1.S. ---------------------------------------------------------------------------------------------------------------------------

