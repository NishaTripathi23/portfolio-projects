CREATE DATABASE ZOMATO_CASESTUDY;

USE ZOMATO_CASESTUDY;

DROP TABLE ZOMATO;

CREATE TABLE ZOMATO 
(
Restaurant_ID INT,	
Restaurant_Name	VARCHAR(250),
Country_Code	INT,
City VARCHAR(250),	
Address	VARCHAR(500),
Locality VARCHAR(500),	
Locality_Verbose VARCHAR(500),	
Cuisines VARCHAR(250),	
Average_Cost_for_two INT,	
Currency VARCHAR(100),	
Has_Table_booking	VARCHAR(10),
Has_Online_delivery	VARCHAR(10),
Is_delivering_now	VARCHAR(10),
Switch_to_order_menu	VARCHAR(10),
Price_range	INT,
Aggregate_rating DECIMAL(2,1),	
Rating_color VARCHAR(100),	
Rating_text	VARCHAR(100),
Votes BIGINT
);

load data local infile 'D:/ZOMATO.csv' into table ZOMATO
fields terminated by ','
enclosed by '"' lines terminated by '\n' ignore 1 rows;

show global variables like 'secure_file_priv'

set global local_infile=1
select * from ZOMATO;
LOAD DATA local INFILE  
'D:/ZOMATO.csv'
into table ZOMATO
CHARACTER SET LATIN1
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

SELECT * FROM ZOMATO;

CREATE TABLE CITY_REGION
(
CITY VARCHAR(50),
REGION VARCHAR(10)
);

LOAD DATA local INFILE  
'D:/REGIONCODE.csv'
into table CITY_REGION
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

SELECT * FROM CITY_REGION;

CREATE TABLE COUNTRY_CODE
(
COUNTRY_CODE INT,
COUNTRY VARCHAR(20)
);

LOAD DATA local INFILE  
'D:/COUNTRY_CODE.csv'
into table COUNTRY_CODE
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

SELECT * FROM COUNTRY_CODE;

SET SQL_SAFE_UPDATES = 0;
DELETE 
FROM ZOMATO
WHERE COUNTRY_CODE NOT IN(SELECT COUNTRY_CODE
						  FROM COUNTRY_CODE
                          WHERE COUNTRY = 'India');
                          
SELECT * FROM ZOMATO;

DELETE 
FROM ZOMATO
WHERE CITY NOT IN (SELECT CITY
                   FROM CITY_REGION
                   WHERE REGION = 'Central');
                   
DELETE
FROM ZOMATO
WHERE CUISINE NOT LIKE "%North Indian%";

SELECT * FROM ZOMATO;
SELECT * FROM COUNTRY_CODE;
SELECT * FROM CITY_REGION;

-- 1.WHICH CITIES HAVE MOST NUMBER OF EATERIES --

SELECT CITY, COUNT(*) AS NUMBER_OF_EATERIES
FROM ZOMATO 
GROUP BY CITY
ORDER BY COUNT(*) DESC;

-- 2. Which low-competition cities have the most eateries with aggregated ratings more than 4? --

SELECT CITY,
SUM(CASE WHEN AGGREGATE_RATING >= 4.0 THEN 1 
ELSE 0
END) AS 'NO_OF_EATERIES'
FROM ZOMATO
WHERE CITY NOT IN ('New Delhi', 'Noida')
GROUP BY CITY
ORDER BY SUM(CASE WHEN AGGREGATE_RATING >= 4.0 THEN 1 
ELSE 0
END) DESC;

/* 3. What is the relationship between the Aggregate rating and the Average cost for two people 
at eateries in Allahabad, Varanasi, and Ghaziabad? 
*/

SELECT CITY, 
ROUND(AVG(AGGREGATE_RATING),2) AS AVG_AGGREGATE_RATING,
ROUND(AVG(AVERAGE_COST_FOR_TWO),0) AS AVG_COST
FROM ZOMATO
WHERE CITY IN ('Allahabad', 'Varanasi', 'Ghaziabad')
GROUP BY CITY
ORDER BY AVG_COST DESC;

/*
4. How many eateries have a
price range of 1, 2, 3, or 4
in Allahabad, Varanasi,
and Ghaziabad?
*/

SELECT CITY,
COUNT(CASE WHEN PRICE_RANGE = 1 THEN Restaurant_ID END) AS 'PRICE_RANGE 1',
COUNT(CASE WHEN PRICE_RANGE = 2 THEN Restaurant_ID END) AS 'PRICE_RANGE 2',
COUNT(CASE WHEN PRICE_RANGE = 3 THEN Restaurant_ID END) AS 'PRICE_RANGE 3',
COUNT(CASE WHEN PRICE_RANGE = 4 THEN Restaurant_ID END) AS 'PRICE_RANGE 4'
FROM ZOMATO
WHERE CITY IN ('Allahabad', 'Varanasi', 'Ghaziabad')
GROUP BY CITY;

/*
5. How many eateries have an
average cost for two people of
less than Rs. 500, between Rs.
500 and Rs. 1000, and more
than Rs. 1000 in Allahabad,
Varanasi, and Ghaziabad? 
*/

SELECT CITY,
SUM(CASE WHEN AVERAGE_COST_FOR_TWO <= 500 THEN 1 ELSE 0 END) AS 'LESS THAN OR EQUAL TO 500',
SUM(CASE WHEN AVERAGE_COST_FOR_TWO BETWEEN 500 AND 1000 THEN 1 ELSE 0 END) AS 'BETWEEN 500 AND 1000',
SUM(CASE WHEN AVERAGE_COST_FOR_TWO > 1000 THEN 1 ELSE 0 END) AS 'GREATER THAN 1000'
FROM ZOMATO
WHERE CITY IN ('Allahabad', 'Varanasi', 'Ghaziabad')
GROUP BY CITY;

/*
6. How do eateries with table
booking or online delivery services
compare in terms of pricing with
eateries that do not offer these
services in Allahabad, Varanasi,
and Ghaziabad?
*/

SELECT
CASE 
WHEN HAS_TABLE_BOOKING = 'Yes' OR HAS_ONLINE_DELIVERY = 'Yes'
THEN 'WITH MINIMUM ONE SERVICE'
ELSE 'WITHOUT ANY SERVICES'
END AS SERVICE_TYPE,
ROUND(AVG(AVERAGE_COST_FOR_TWO),0) AS AVERAGE_COST
FROM ZOMATO
WHERE CITY IN ('Allahabad', 'Varanasi', 'Ghaziabad')
GROUP BY SERVICE_TYPE
ORDER BY AVERAGE_COST DESC;

/* 
7. How many eateries offer Online
delivery or Table booking service
and what are their average
consumer votes in Allahabad,
Varanasi, and Ghaziabad?
*/

SELECT CITY,
ROUND(AVG(VOTES),0) AS AVG_CUSTOMER_VOTES,
SUM(CASE WHEN HAS_TABLE_BOOKING = 'Yes' THEN 1 ELSE 0 END) AS TABLE_BOOKING,
SUM(CASE WHEN HAS_ONLINE_DELIVERY = 'Yes' THEN 1 ELSE 0 END) AS ONLINE_DELIVERY
FROM ZOMATO
WHERE CITY IN ('Allahabad', 'Varanasi', 'Ghaziabad')
GROUP BY CITY;












