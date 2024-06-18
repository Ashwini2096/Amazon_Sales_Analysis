Create database  Amazon_Sales;
use amazon_sales;
select * from amazon1;
DESC amazon1;
ALTER TABLE amazon1
MODIFY COLUMN invoice_id VARCHAR(30),
MODIFY COLUMN branch VARCHAR(5),
MODIFY COLUMN city VARCHAR(30),
MODIFY COLUMN customer_type VARCHAR(30),
MODIFY COLUMN gender VARCHAR(10),
MODIFY COLUMN product_line VARCHAR(100),
MODIFY COLUMN unit_price DECIMAL(10, 2),
MODIFY COLUMN quantity INT,
MODIFY COLUMN VAT FLOAT(6, 4),
MODIFY COLUMN total DECIMAL(10, 2),
MODIFY COLUMN date DATE,
MODIFY COLUMN time TIME,
MODIFY COLUMN payment VARCHAR(30), -- Assuming payment method is stored as text
MODIFY COLUMN cogs DECIMAL(10, 2),
MODIFY COLUMN gross_margin_percentage FLOAT(11, 9),
MODIFY COLUMN gross_income DECIMAL(10, 2),
MODIFY COLUMN rating FLOAT(3, 1);

SET SQL_SAFE_UPDATES = 0;

-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
ALTER TABLE amazon1
ADD COLUMN timeofday VARCHAR(20);

UPDATE amazon1
SET timeofday = CASE 
                    WHEN TIME(time) >= '00:00:00' AND TIME(time) < '12:00:00' THEN 'Morning'
                    WHEN TIME(time) >= '12:00:00' AND TIME(time) < '18:00:00' THEN 'Afternoon'
                    ELSE 'Evening'
                END;

-- Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.
ALTER TABLE amazon1
ADD COLUMN dayname VARCHAR(20);
UPDATE amazon1
SET dayname = DAYNAME(date);

-- Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
ALTER TABLE amazon1
ADD COLUMN monthname VARCHAR(20);
UPDATE amazon1
SET monthname = MONTHNAME(date);

-- What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT city) AS distinct_city_count
FROM amazon1;

-- For each branch, what is the corresponding city?
SELECT branch, city
FROM amazon1
GROUP BY branch, city;

-- What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT product_line) AS distinct_product_line_count
FROM amazon1;

-- Which payment method occurs most frequently?
SELECT payment, COUNT(*) AS frequency
FROM amazon1
GROUP BY payment
ORDER BY frequency DESC
LIMIT 1;

-- Which product line has the highest sales?
SELECT product_line, SUM(unit_price * quantity) AS total_sales
FROM amazon1
GROUP BY product_line
ORDER BY total_sales DESC
LIMIT 1;

-- How much revenue is generated each month?
SELECT 
    MONTH(date) AS month,
    SUM(unit_price * quantity) AS revenue
FROM amazon1
GROUP BY MONTH(date)
ORDER BY month;

-- In which month did the cost of goods sold reach its peak?
SELECT 
    MONTH(date) AS month,
    SUM(cogs) AS total_cogs
FROM amazon1
GROUP BY MONTH(date)
ORDER BY total_cogs DESC
LIMIT 1;

-- Which product line generated the highest revenue?
SELECT 
    product_line,
    SUM(unit_price * quantity) AS total_revenue
FROM amazon1
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- In which city was the highest revenue recorded?
SELECT 
    city,
    SUM(unit_price * quantity) AS total_revenue
FROM amazon1
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- Which product line incurred the highest Value Added Tax?
SELECT 
    product_line,
    SUM(VAT) AS total_VAT
FROM amazon1
GROUP BY product_line
ORDER BY total_VAT DESC
LIMIT 1;

-- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT 
    *,
    CASE 
        WHEN (unit_price * quantity) > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_category
FROM 
    (
        SELECT 
            *,
            AVG(unit_price * quantity) OVER () AS avg_sales
        FROM amazon1
    ) AS subquery;
    
-- Identify the branch that exceeded the average number of products sold.
SELECT 
    branch,
    SUM(quantity) AS total_quantity_sold
FROM amazon1
GROUP BY branch
HAVING 
    SUM(quantity) > (SELECT AVG(quantity) FROM amazon1);
    
-- Which product line is most frequently associated with each gender?
SELECT 
    gender,
    product_line,
    COUNT(*) AS frequency
FROM 
    amazon1
GROUP BY 
    gender,
    product_line
HAVING 
    COUNT(*) = (
        SELECT MAX(freq)
        FROM 
            (
                SELECT 
                    gender,
                    product_line,
                    COUNT(*) AS freq
                FROM amazon1
                GROUP BY 
                    gender,
                    product_line
            ) AS subquery
        WHERE subquery.gender = amazon1.gender
    );

-- Calculate the average rating for each product line.
SELECT 
    product_line,
    AVG(rating) AS average_rating
FROM amazon1
GROUP BY product_line;

-- Count the sales occurrences for each time of day on every weekday.
SELECT 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    CASE 
        WHEN WEEKDAY(date) = 0 THEN 'Monday'
        WHEN WEEKDAY(date) = 1 THEN 'Tuesday'
        WHEN WEEKDAY(date) = 2 THEN 'Wednesday'
        WHEN WEEKDAY(date) = 3 THEN 'Thursday'
        WHEN WEEKDAY(date) = 4 THEN 'Friday'
        WHEN WEEKDAY(date) = 5 THEN 'Saturday'
        WHEN WEEKDAY(date) = 6 THEN 'Sunday'
    END AS weekday,
    COUNT(*) AS sales_occurrences
FROM amazon1
GROUP BY 
    time_of_day,
    weekday
ORDER BY 
    FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');
    
-- Identify the customer type contributing the highest revenue.
SELECT 
    customer_type,
    SUM(unit_price * quantity) AS total_revenue
FROM amazon1
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- Determine the city with the highest VAT percentage.
SELECT 
    city,
    SUM(VAT) AS total_VAT,
    SUM(total) AS total_sales,
    (SUM(VAT) / SUM(total)) * 100 AS VAT_percentage
FROM amazon1
GROUP BY city
ORDER BY VAT_percentage DESC
LIMIT 1;

-- Identify the customer type with the highest VAT payments.
SELECT 
    customer_type,
    SUM(VAT) AS total_VAT_payments
FROM amazon1
GROUP BY customer_type
ORDER BY total_VAT_payments DESC
LIMIT 1;

-- What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types_count
FROM amazon1;

-- What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment) AS distinct_payment_methods_count
FROM amazon1;

-- Which customer type occurs most frequently?
SELECT customer_type, COUNT(*) AS frequency
FROM amazon1
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;

-- Identify the customer type with the highest purchase frequency.
SELECT 
    customer_type,
    COUNT(*) AS purchase_frequency
FROM amazon1
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

-- Determine the predominant gender among customers.
SELECT 
    gender,
    COUNT(*) AS frequency
FROM amazon1
GROUP BY gender
ORDER BY frequency DESC
LIMIT 1;

-- Examine the distribution of genders within each branch.
SELECT 
    branch,
    gender,
    COUNT(*) AS gender_count
FROM amazon1
GROUP BY 
    branch,
    gender
ORDER BY 
    branch,
    gender_count DESC;
    
-- Identify the time of day when customers provide the most ratings.
SELECT 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS rating_count
FROM amazon1
GROUP BY time_of_day
ORDER BY rating_count DESC
LIMIT 1;

-- Determine the time of day with the highest customer ratings for each branch.
SELECT 
    branch,
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS rating_count
FROM 
    amazon1
GROUP BY 
    branch,
    time_of_day
ORDER BY 
    branch,
    rating_count DESC;
    

-- Identify the day of the week with the highest average ratings.
SELECT 
    DAYNAME(date) AS day_of_week,
    AVG(rating) AS average_rating
FROM 
    amazon1
GROUP BY 
    day_of_week
ORDER BY 
    average_rating DESC
LIMIT 1;

-- Determine the day of the week with the highest average ratings for each branch.
SELECT 
    branch,
    DAYNAME(date) AS day_of_week,
    AVG(rating) AS average_rating
FROM 
    amazon1
GROUP BY 
    branch,
    day_of_week
ORDER BY 
    branch,
    average_rating DESC;




