-- Checcking Safe update settings
SELECT @@SQL_SAFE_UPDATES;

-- Disabling safe updates
Set SQL_SAFE_UPDATES=0;

-- Deleting null values from the table
DELETE FROM retail_sales
WHERE transactions_id IS NULL 
   OR sale_date IS NULL 
   OR sale_time IS NULL 
   OR customer_id IS NULL 
   OR gender IS NULL 
   OR age IS NULL 
   OR category IS NULL 
   OR quantiy IS NULL 
   OR price_per_unit IS NULL 
   OR cogs IS NULL 
   OR total_sale IS NULL;
   
   -- Write a SQL query to retrieve all columns for sales made on '2022-11-05

-- Note: Since Sale Date column was stored in Varchar we were unable to change the format to correct date format- yyyy-mm-dd.
-- Hence we are creating a new date coulmn and tranferring date data to it

-- Add new column
ALTER TABLE retail_sales ADD COLUMN sale_date_new DATE;
-- Add Date data to it
UPDATE retail_sales 
SET sale_date_new = STR_TO_DATE(sale_date, '%d-%m-%Y');
-- dropping old colmn and renaming new column
Alter table retail_sales drop column sale_date;
Alter table retail_sales change column sale_date_new Sale_date date;

Select * from retail_sales where
sale_date= '2022-11-05';

-- Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

-- Method 1
Select * from retail_sales where sale_date between '2022-11-01' and '2022-11-30' 
AND category='Clothing'
AND quantiy>=4;

-- Method 2
Select * from retail_sales where
date_format(sale_date,'%Y-%m')='2022-11'
AND category='Clothing'
AND quantiy>=4;

-- Write a SQL query to calculate the total sales (total_sale) for each category

Select Category, SUM(Total_sale) as TotalSale from retail_sales
Group by category
Order by TotalSale;

-- Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category
Select  AVG(Age) as Age from retail_sales where category = 'Beauty' ;

-- Write a SQL query to find all transactions where the total_sale is greater than 1000
Select Transactions_ID from Retail_Sales where total_sale>1000;

-- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category
Select Gender, category,Count(transactions_ID) as Transactions from retail_sales
group by Gender,category;

-- Write a SQL query to calculate the average sale for each month. Find out best selling month in each year


Select * from (Select Year(Sale_date) as Year, Month(Sale_Date) As 'Month', Round(AVG(Total_Sale),2) as Average_Sale,
RANK() over(partition by YEAR(Sale_Date) order by Round(AVG(Total_Sale),2)desc) As Rank1
From retail_sales Group by 1,2) as TEMP
where RANK1<2
Order by 1;

-- Write a SQL query to find the top 5 customers based on the highest total sales
Select Customer_ID, SUM(Total_Sale) as Total_Sales from Retail_Sales
group by 1
Order by Total_Sales DESC limit 5;

-- identify customers who have made at least one purchase from all available categories
SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) = (SELECT COUNT(DISTINCT category) FROM retail_sales);

-- Write a SQL query to find the number of unique customers who purchased items from each category

Select Category,
Count(Distinct(Customer_ID))
from Retail_Sales
Group by Category;

-- Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

Select * from Retail_Sales;

-- Using Case
Select Count(TRansactions_ID) as NUM,
Case
when Hour(Sale_time) < 12 then 'Morning'
when Hour(Sale_time) between 12 AND 17 then 'Afternoon'
Else 'Evening'
END as Shift
 from Retail_Sales
 Group by shift;

-- Using CTE

With Temp as
(Select Transactions_ID,
Case
when Hour(sale_time) < 12 then 'Morning'
when Hour(sale_time) between 12 AND 17 then 'Afternoon'
Else 'Evening'
END as Shift
from Retail_Sales)
Select Count(transactions_ID) as NumOrders,
Shift
from Temp
Group by Shift;

-- Method 3 CTE Extract Hour

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift

DESCRIBE  retail_sales;
