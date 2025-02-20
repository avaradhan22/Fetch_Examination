# Exploring Data

# data ranges from mid June 2024 to early September 2024 (summer time)
select min(purchase_Date) 
,max(purchase_date)
, min(scan_date)
,max(scan_date)
from fetch.transaction_takehome

#No duplicate records in transaction table
SELECT *,
       COUNT(*) AS duplicate_count
FROM fetch.transaction_takehome
GROUP BY id
,receipt_id
,purchase_date
,scan_date
,store_name
,user_id
,barcode
,final_quantity
,final_sale
HAVING duplicate_count > 1;

#Vagueness on defintions for category 1-4
SELECT category_1 department
,category_2 class
,category_3 subclass
,category_4 item_type
,manufacturer
,brand
,barcode
FROM fetch.products_takehome

# Roughly 27% of the products in the products data table is missing an associated brand
select
brand,
count(*)
from fetch.products_takehome
where brand is null
group by brand;

select count(*) from fetch.products_takehome;

# Of the 100,000 only 91 are matched to the transaction table, heavily skewed towards females
SELECT DISTINCT b.id
,gender
FROM fetch.user_takehome b
INNER JOIN fetch.transaction_takehome a ON b.id = a.user_id;
