********************************************--MASTER TABLE 1 FOR MOST RENTED FILM ANALYSIS--*********************************************************

SELECT H.CUSTOMER_ID,
A.CATEGORY_ID,
A.NAME,
B.FILM_ID,
C.TITLE,
C.RELEASE_YEAR,
C.RENTAL_DURATION,
C.RENTAL_RATE,
C.RATING,
D.LANGUAGE_ID,
D.NAME AS LANGUAGE_NAME,
F.INVENTORY_ID,
F.STORE_ID,
G.RENTAL_ID,
G.RENTAL_DATE,
G.RETURN_DATE,
H.PAYMENT_ID,
H.AMOUNT,
H.PAYMENT_DATE
FROM 
CATEGORY A
LEFT JOIN FILM_CATEGORY B
ON A.CATEGORY_ID = B.CATEGORY_ID
LEFT JOIN FILM C
ON B.FILM_ID = C.FILM_ID
LEFT JOIN LANGUAGE D
ON C.LANGUAGE_ID = D.LANGUAGE_ID
LEFT JOIN INVENTORY F
ON C.FILM_ID = F.FILM_ID
LEFT JOIN RENTAL G
ON F.INVENTORY_ID = G.INVENTORY_ID
LEFT JOIN PAYMENT H
ON G.RENTAL_ID = H.RENTAL_ID
ORDER BY G.CUSTOMER_ID;
*******************************************************************************************************************************************

********************************************--MASTER TABLE 2 FOR TOP 10 CUSTOMER--*********************************************************

SELECT K.CUSTOMER_ID,
K.FIRST_NAME,
K.LAST_NAME,
K.EMAIL,
K. ADDRESS_ID,
K.ACTIVE,
K.CREATE_DATE,
L.ADDRESS,
L.ADDRESS2,
L.DISTRICT,
L.CITY_ID,
L.POSTAL_CODE,
L.PHONE,
M.CITY,
M.COUNTRY_ID,
N.COUNTRY,
O.MANAGER_STAFF_ID,
O.LAST_UPDATE
FROM 
CUSTOMER K
LEFT JOIN ADDRESS L
ON K.ADDRESS_ID = L.ADDRESS_ID
LEFT JOIN CITY M
ON L.CITY_ID = M.CITY_ID
LEFT JOIN COUNTRY N 
ON M.COUNTRY_ID=N.COUNTRY_ID
LEFT JOIN STORE O
ON K.STORE_ID=O.STORE_ID
ORDER BY CUSTOMER_ID;

*******************************************************************************************************************************************

*******************************************--MASTER TABLE For DVD Rental Analysis--********************************************************

WITH T1 AS (SELECT H.CUSTOMER_ID,
A.CATEGORY_ID,
A.NAME,
B.FILM_ID,
C.TITLE,
C.RELEASE_YEAR,
C.RENTAL_DURATION,
C.RENTAL_RATE,
C.RATING,
D.LANGUAGE_ID,
D.NAME AS LANGUAGE_NAME,
F.INVENTORY_ID,
F.STORE_ID,
G.RENTAL_ID,
G.RENTAL_DATE,
G.RETURN_DATE,
H.PAYMENT_ID,
H.AMOUNT,
H.PAYMENT_DATE
FROM 
CATEGORY A
LEFT JOIN FILM_CATEGORY B
ON A.CATEGORY_ID = B.CATEGORY_ID
LEFT JOIN FILM C
ON B.FILM_ID = C.FILM_ID
LEFT JOIN LANGUAGE D
ON C.LANGUAGE_ID = D.LANGUAGE_ID
LEFT JOIN INVENTORY F
ON C.FILM_ID = F.FILM_ID
LEFT JOIN RENTAL G
ON F.INVENTORY_ID = G.INVENTORY_ID
LEFT JOIN PAYMENT H
ON G.RENTAL_ID = H.RENTAL_ID
ORDER BY G.CUSTOMER_ID),
T2 AS (SELECT K.CUSTOMER_ID,
K.FIRST_NAME,
K.LAST_NAME,
K.EMAIL,
K. ADDRESS_ID,
K.ACTIVE,
K.CREATE_DATE,
L.ADDRESS,
L.ADDRESS2,
L.DISTRICT,
L.CITY_ID,
L.POSTAL_CODE,
L.PHONE,
M.CITY,
M.COUNTRY_ID,
N.COUNTRY,
O.MANAGER_STAFF_ID,
O.LAST_UPDATE
FROM 
CUSTOMER K
LEFT JOIN ADDRESS L
ON K.ADDRESS_ID = L.ADDRESS_ID
LEFT JOIN CITY M
ON L.CITY_ID = M.CITY_ID
LEFT JOIN COUNTRY N 
ON M.COUNTRY_ID=N.COUNTRY_ID
LEFT JOIN STORE O
ON K.STORE_ID=O.STORE_ID
ORDER BY CUSTOMER_ID)
SELECT * FROM T1
LEFT JOIN T2
ON T1.CUSTOMER_ID = T2.CUSTOMER_ID;
*******************************************************************************************************************************************

**************************************--DATE DIFFRENCE BETWEEN RENTAL DATE AND RETURN DATE--***********************************************

SELECT RENTAL_ID,CUSTOMER_ID,INVENTORY_ID,EXTRACT(DAY FROM DATE_DIFFERENCE) DATE_DIFF 
FROM ( SELECT RENTAL_ID, CUSTOMER_ID, INVENTORY_ID, (RETURN_DATE - RENTAL_DATE) AS DATE_DIFFERENCE
FROM RENTAL);
*******************************************************************************************************************************************

***************************************************--RETURN STATUS OF THE FILMS--**********************************************************

WITH T1 AS(SELECT RENTAL_ID,CUSTOMER_ID,INVENTORY_ID,EXTRACT(DAY FROM DATE_DIFFERENCE) DATE_DIFF 
FROM (SELECT RENTAL_ID,CUSTOMER_ID,INVENTORY_ID,RETURN_DATE-RENTAL_DATE AS DATE_DIFFERENCE
FROM RENTAL)),
T2 AS (SELECT RENTAL_DURATION,DATE_DIFF,
CASE 
WHEN RENTAL_DURATION > DATE_DIFF THEN 'Returned early'
WHEN RENTAL_DURATION = DATE_DIFF THEN 'Returned on Time'
ELSE 'Returned late'
END AS RETURN_STATUS
FROM FILM
JOIN INVENTORY 
USING(FILM_ID)
JOIN T1
USING (INVENTORY_ID))
SELECT RETURN_STATUS, COUNT(*) AS TOTAL_NO_OF_FILMS
FROM T2
GROUP BY RETURN_STATUS;

*******************************************************************************************************************************************

*****************************************--Data Validation for Top 10 movies amount wise--*************************************************

SELECT A.NAME AS Genre,
B.FILM_ID,
C.TITLE AS Movie_Name,
SUM(AMOUNT) FROM
CATEGORY A
JOIN FILM_CATEGORY B
USING (CATEGORY_ID)
JOIN FILM C
USING (FILM_ID)
JOIN INVENTORY D
USING (FILM_ID)
JOIN RENTAL E
USING (INVENTORY_ID)
JOIN PAYMENT F
USING (RENTAL_ID)
GROUP BY A.NAME,B.FILM_ID,C.TITLE
ORDER BY SUM(AMOUNT) DESC
LIMIT 10;

*******************************************************************************************************************************************

************************************--Data Validation for Top 10 movies based on customer_count--******************************************

SELECT A.NAME AS Genre,
B.FILM_ID,
C.TITLE AS Movie_name,
COUNT(F.CUSTOMER_ID) FROM
FILM C
LEFT JOIN FILM_CATEGORY B
ON C.FILM_ID = B.FILM_ID
LEFT JOIN CATEGORY A
ON B.CATEGORY_ID = A.CATEGORY_ID
LEFT JOIN INVENTORY D
ON C.FILM_ID = D.FILM_ID
LEFT JOIN RENTAL E
ON D.INVENTORY_ID = E.INVENTORY_ID
LEFT JOIN PAYMENT F
ON E.RENTAL_ID = F.RENTAL_ID
GROUP BY A.NAME,B.FILM_ID,C.TITLE
ORDER BY COUNT(DISTINCT(F.CUSTOMER_ID)) DESC
LIMIT 10;

*******************************************************************************************************************************************

*************************************************--Revenue Rating Overall--****************************************************************
SELECT 
C.RATING,
SUM(AMOUNT) FROM
CATEGORY A
JOIN FILM_CATEGORY B
USING (CATEGORY_ID)
JOIN FILM C
USING (FILM_ID)
JOIN INVENTORY D
USING (FILM_ID)
JOIN RENTAL E
USING (INVENTORY_ID)
JOIN PAYMENT F
USING (RENTAL_ID)
GROUP BY C.RATING;

*******************************************************************************************************************************************

**********************************************--REVENUE  PER RATING GENRE WISE--***********************************************************

SELECT A.NAME as genre,
C.RATING,
SUM(AMOUNT) FROM
CATEGORY A
JOIN FILM_CATEGORY B
USING (CATEGORY_ID)
JOIN FILM C
USING (FILM_ID)
JOIN INVENTORY D
USING (FILM_ID)
JOIN RENTAL E
USING (INVENTORY_ID)
JOIN PAYMENT F
USING (RENTAL_ID)
GROUP BY A.NAME,C.RATING
ORDER BY GENRE DESC;
*******************************************************************************************************************************************
