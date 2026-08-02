USE ecommerce;
DESCRIBE olist_customers_dataset;
SELECT COUNT(*) from olist_customers_dataset;
SELECT COUNT(customer_id) AS refferal_id,
COUNT(customer_unique_id) AS customer_code,
COUNT(customer_zip_code_prefix) AS area_code,
COUNT(customer_city) AS placed_city,
COUNT(customer_state) AS ordered_state
FROM olist_customers_dataset;
SELECT customer_state,customer_city,COUNT(customer_city) AS city
FROM olist_customers_dataset
GROUP BY customer_state,customer_city
ORDER BY city DESC;
SELECT customer_city,COUNT(customer_zip_code_prefix) AS area_code
FROM olist_customers_dataset
GROUP BY customer_city
ORDER BY area_code DESC;
SELECT customer_state,customer_city, COUNT(customer_id) AS customer_refferal
FROM olist_customers_dataset
GROUP BY customer_state,customer_city
ORDER BY customer_refferal DESC;
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM olist_customers_dataset;
SELECT customer_zip_code_prefix,COUNT(customer_id) AS customers
FROM olist_customers_dataset
GROUP BY customer_zip_code_prefix
ORDER BY customers DESC;
SELECT customer_state,COUNT(customer_id) AS customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY customers DESC;


DESCRIBE olist_orders_dataset;
SELECT COUNT(order_id) AS orders,
COUNT(customer_id) AS customers,
COUNT(order_status) AS ordered_status,
COUNT(order_purchase_timestamp) AS purchased_time,
COUNT(order_approved_at)AS approval_time,
COUNT(order_delivered_carrier_date) AS delivere_carrier_time,
COUNT(order_delivered_customer_date) AS deliver_to_customer_time,
COUNT(order_estimated_delivery_date) AS delivery_date
FROM olist_orders_dataset;
SELECT customer_id,COUNT(order_id)AS orders
FROM olist_orders_dataset
GROUP BY customer_id
HAVING orders>1
ORDER BY orders DESC;
SELECT COUNT(DISTINCT order_id) AS different_orders
FROM olist_orders_dataset;
SELECT order_status, COUNT( order_status) AS statuses
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY statuses DESC;
WITH purchase AS (
SELECT STR_TO_DATE(order_purchase_timestamp, "%d-%m-%Y %H:%i")AS purchase_time
FROM olist_orders_dataset)
SELECT YEAR(purchase_time) AS purchase_year, 
MONTH(purchase_time) AS purchase_month,
DAY(purchase_time) AS purchased_date,
MONTHNAME(purchase_time ) AS month_name,
COUNT(*) AS total_orders
FROM purchase
GROUP BY purchase_year,purchase_month,month_name,purchased_date
ORDER BY purchase_year,purchase_month,purchased_date;

WITH time_per AS (
SELECT order_id,order_status,STR_TO_DATE(NULLIF(order_purchase_timestamp,"NULL"), "%d-%m-%Y %H:%i")AS purchase_time,
STR_TO_DATE(NULLIF(order_approved_at,"NULL"), "%d-%m-%Y %H:%i")AS approved_time,
STR_TO_DATE(NULLIF(order_delivered_carrier_date,'NULL'), "%d-%m-%Y %H:%i") AS delivered_carrier_time,
STR_TO_DATE(NULLIF(order_delivered_customer_date,"NULL"), "%d-%m-%Y %H:%i")AS customer_date,
STR_TO_DATE(NULLIF(order_estimated_delivery_date,"NULL"), "%d-%m-%Y %H:%i")AS estimated_time
FROM olist_orders_dataset),
TIMEDIFFERENCE AS(
SELECT *,TIMESTAMPDIFF(HOUR,purchase_time,approved_time) AS approval_hours,
TIMESTAMPDIFF(MINUTE, purchase_time,approved_time) AS approval_minutes,
TIMESTAMPDIFF(HOUR,approved_time,delivered_carrier_time) AS delivering_time_duration,
TIMESTAMPDIFF(DAY,purchase_time,customer_date) AS get_order_duration,
TIMESTAMPDIFF(DAY,estimated_time,customer_date) AS ordered_date_to_get_order,
CASE
WHEN customer_date=estimated_time THEN "ON_TIME"
WHEN customer_date<estimated_time THEN " EARLY"
WHEN customer_date>Estimated_time THEN "LATE"
ELSE "NOT_DELIVERED"
END AS DELIERY_STATUS
FROM time_per)
SELECT*FROM TIMEDIFFERENCE;

WITH JOINS AS(
SELECT 
o.order_id,
c.customer_id,
c.customer_unique_id,
o.order_status,
c.customer_city,
c.customer_state
FROM olist_customers_dataset AS c
INNER JOIN olist_orders_dataset AS o
ON c.customer_id=o.customer_id
ORDER BY o.order_status DESC
)
SELECT * FROM JOINS;

SELECT c.customer_state,
COUNT(*) AS total_orders
FROM olist_customers_dataset AS c
INNER JOIN olist_orders_dataset AS o
ON o.customer_id=c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

SELECT c.customer_city,
COUNT(*) AS total_orders_by_city
FROM olist_customers_dataset AS c
INNER JOIN olist_orders_dataset AS o
ON o.customer_id=c.customer_id
GROUP BY c.customer_city
ORDER  BY total_orders_by_city DESC
LIMIT 10;

SELECT c.customer_state,
o.order_status,
COUNT(*) AS total_orders
FROM olist_customers_dataset AS c
INNER JOIN olist_orders_dataset AS o
ON o.customer_id=c.customer_id
GROUP BY c.customer_state,o.order_status
ORDER BY c.customer_state,o.order_status DESC;


SELECT * FROM olist_order_items_dataset
LIMIT 10;
DESCRIBE olist_order_items_dataset;

SELECT COUNT(*) FROM olist_order_items_dataset;

SELECT COUNT(order_id) AS order_id,
COUNT(order_item_id) AS item_id,
COUNT(product_id) AS product_id,
COUNT(seller_id) AS seller_id,
COUNT(shipping_limit_date) AS date_column,
COUNT(price) AS price,
COUNT(freight_value) AS freight_value
FROM olist_order_items_dataset;


SELECT COUNT(DISTINCT seller_id) AS DIFFERENT_SELLERS
FROM olist_order_items_dataset;
SELECT MAX(price) AS mximum_price_product,
MIN(price) AS minimum_price_product
FROM olist_order_items_dataset;
SELECT MAX(ROUND(freight_value ,2)) AS MIAXIMUM_FREIGHT_VALUE,
MIN(freight_value) AS minimum_freight_value
FROM olist_order_items_dataset;

SELECT COUNT(DISTINCT product_id) AS unique_product
FROM olist_order_items_dataset;
SELECT COUNT(DISTINCT product_id) AS unique_orders
FROM olist_products_dataset;
SELECT COUNT(*)
FROM olist_order_items_dataset AS oi
LEFT JOIN olist_products_dataset p
ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;
SELECT COUNT(DISTINCT oi.product_id)
FROM olist_order_items_dataset AS oi
LEFT JOIN olist_products_dataset AS p
ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;
SELECT order_id ,MAX(order_item_id) AS maximum_order_item
FROM olist_order_items_dataset
GROUP BY order_id
ORDER BY maximum_order_item DESC
LIMIT 1;

SELECT ROUND(SUM(price),2) AS total_tem_price,
ROUND(SUM(freight_value),2) AS total_freight_value,
ROUND(SUM(price+freight_value),2) AS total_of_freight_and_price_value
FROM olist_order_items_dataset;

DESCRIBE olist_order_payments_dataset;
SELECT COUNT(*) AS TOTAL_ROWS
FROM olist_order_payments_dataset;
SELECT COUNT(order_id) AS order_id,
COUNT(payment_sequential) AS PAYMENT_SEQUENTIAL,
COUNT(PAYMENT_TYPE) AS PAYMENT_TYPE,
COUNT(payment_installments) AS payment_installments,
COUNT(payment_value) AS payment_value
FROM olist_order_payments_dataset;
SELECT order_id,payment_type,COUNT(*) AS payment_COUNT
FROM olist_order_payments_dataset
GROUP BY order_id,payment_type
ORDER BY payment_COUNT DESC;

SELECT payment_type,COUNT(payment_type) AS payment_type
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY payment_type DESC;

SELECT MAX(payment_installments) AS maximum_installment,
MIN(payment_installments) AS minimum_installments
FROM olist_order_payments_dataset; 
SELECT payment_type,MAX(payment_value) AS maximum_value,
MIN(payment_value) AS minimum_value
FROM olist_order_payments_dataset
GROUP BY payment_type 
ORDER BY maximum_value DESC;
SELECT* FROM olist_order_payments_dataset
ORDER BY payment_sequential DESC
LIMIT 10;
SELECT payment_type,SUM(payment_value) AS total_value
FROM olist_order_payments_dataset
GROUP BY payment_type;
SELECT payment_type,COUNT(payment_value) AS payment_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY payment_value DESC;
SELECT payment_type, ROUND(AVG(payment_value),2) AS average_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY average_value DESC;
show tables ;
DESCRIBE olist_products_dataset;
SELECT COUNT(*) AS TOTAL_ROWS
FROM olist_products_dataset;
SELECT COUNT(product_id) AS product_id,
COUNT(product_category_name) AS product_name,
COUNT(product_name_lenght) AS LENGHT,
COUNT(product_description_lenght) AS DESCRITION_LENGHT,
COUNT(product_photos_qty) AS photo_qty,
COUNT(product_weight_g) AS weight_g,
COUNT(product_length_cm) AS product_cm,
COUNT(product_height_cm) AS height_cm,
COUNT(product_width_cm) AS width
FROM olist_products_dataset;

SELECT COUNT(DISTINCT product_id) AS unique_products
FROM olist_products_dataset;
SELECT COUNT(DISTINCT product_category_name) AS name_products
FROM olist_products_dataset;

 
SELECT product_category_name,COUNT(product_id) AS product_count
FROM olist_products_dataset
GROUP BY product_category_name
ORDER BY product_count DESC;