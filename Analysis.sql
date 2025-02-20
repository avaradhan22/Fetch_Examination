-- Formatting birthday to correct data type
WITH clean_user AS (
    SELECT 
        DISTINCT *
        , STR_TO_DATE(birth_date, '%Y-%m-%d') AS birthday
    FROM fetch.user_takehome
),

-- Constructing generations
User_generation AS (
    SELECT
        id, 
        birthday,
        created_date,
        gender,
        TIMESTAMPDIFF(YEAR, birthday, CURDATE()) AS age,
        CASE
			when TIMESTAMPDIFF(YEAR, birthday, CURDATE()) is null then 0 
            WHEN TIMESTAMPDIFF(YEAR, birthday, CURDATE()) BETWEEN 18 AND 25 THEN '18-25'
            WHEN TIMESTAMPDIFF(YEAR, birthday, CURDATE()) BETWEEN 26 AND 35 THEN '26-35'
            WHEN TIMESTAMPDIFF(YEAR, birthday, CURDATE()) BETWEEN 36 AND 45 THEN '36-45'
            WHEN TIMESTAMPDIFF(YEAR, birthday, CURDATE()) BETWEEN 46 AND 55 THEN '46-55'
            WHEN TIMESTAMPDIFF(YEAR, birthday, CURDATE()) BETWEEN 56 AND 65 THEN '56-65'
            WHEN TIMESTAMPDIFF(YEAR, birthday, CURDATE()) > 65 THEN '66+'
            ELSE 'Under 18'
        END AS generation
    FROM clean_user
),
 -- Brand receipt counts for users 21+
brand_age AS (
    SELECT
        c.brand,
        COUNT(a.receipt_id) AS receipt_count
    FROM fetch.transaction_takehome a
    inner JOIN User_generation b ON a.user_ID = b.id
    inner JOIN fetch.products_takehome c ON a.barcode = c.barcode
    WHERE TIMESTAMPDIFF(YEAR, b.birthday, CURDATE()) > 20
    GROUP BY c.brand
)

 -- Brand total sales for users who created an account within the last 6 months
,brands_sales AS (
    SELECT
        c.brand,
        SUM(a.final_sale) AS total_sale
    FROM fetch.transaction_takehome a
    inner JOIN User_generation b ON a.user_ID = b.id
    inner JOIN fetch.products_takehome c ON a.barcode = c.barcode
    WHERE TIMESTAMPDIFF(MONTH, b.created_date, CURDATE()) >= 6
    GROUP BY c.brand
)

-- Leading brands in sales by gender (skewed towards females since majority of users in transaction table are females)
,brands_gender AS (
    SELECT
        c.brand,
        gender,
        SUM(a.final_sale) AS total_sale
    FROM fetch.transaction_takehome a
    inner JOIN User_generation b ON a.user_ID = b.id
    inner JOIN fetch.products_takehome c ON a.barcode = c.barcode
    -- WHERE TIMESTAMPDIFF(MONTH, b.created_date, CURDATE()) >= 6
    GROUP BY c.brand
    ,gender
)

-- Brands leading in sales and receipts for class Dips and Salsa
,Dips_Salsa AS (
    SELECT
        'Dips & Salsa' AS Class,
        c.brand,
        SUM(a.final_sale) AS total_sales,
        COUNT(a.receipt_id) AS total_receipts
    FROM fetch.transaction_takehome a
    LEFT JOIN User_generation b ON a.user_ID = b.id
    LEFT JOIN fetch.products_takehome c ON a.barcode = c.barcode
    WHERE c.category_2 = 'Dips & Salsa'
    GROUP BY c.brand
)

-- Brands leading in sales and receipts for class Dips and Salsa by Gender and Generation
,Dips_Salsa_generation AS (
    SELECT
        'Dips & Salsa' AS Class,
        c.brand,
        generation,
        gender,
        SUM(a.final_sale) AS total_sales,
        COUNT(a.receipt_id) AS total_receipts
    FROM fetch.transaction_takehome a
    inner JOIN User_generation b ON a.user_ID = b.id
    inner JOIN fetch.products_takehome c ON a.barcode = c.barcode
    WHERE c.category_2 = 'Dips & Salsa'
    GROUP BY c.brand,
    generation,
    gender
)


-- Select the top 5 brands by receipt count from brand_age
SELECT * 
FROM brand_age
ORDER BY receipt_count DESC
LIMIT 5;

#CVS(72.00),Trident(46.72),Dove(42.88),Coors Light(34.96),Qauaker (16.60) were the top 5 brands by sales amount user that have had their account for atleast 6 months
select * from brands_sales
order by total_sale desc
limit 5;



#Tostitos leading in total sales(239.54) and total receipts (66)
select * from Dips_Salsa
order by total_sales desc
 ;

