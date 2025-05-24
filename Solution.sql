-- CREATING TABLES

DROP TABLE if Exists sales;
DROP TABLE if Exists customers;
DROP TABLE if Exists products;
Drop TABLE if Exists city;

-- Creating city table
CREATE TABLE city(
	city_id INT PRIMARY KEY,
	city_name VARCHAR (20), 
	population BIGINT,
	estimated_rent FLOAT,
	city_rank INT
);

-- Creating customers table
CREATE TABLE customers(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(20),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- Creating products table
CREATE TABLE products (
	product_id INT PRIMARY KEY,
	product_name VARCHAR(34),
	price float
);

-- Creating sales table
CREATE TABLE sales (
	sale_id INT PRIMARY KEY,
	sale_date DATE,
	product_id INT,
	customer_id INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales; 

-- REPORTS AND DATA ANALYSIS

-- Q1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does


SELECT 
	city_name,
	(population * 0.25) as coffee_consumers,
	city_rank
FROM city
Order by coffee_consumers desc
;

-- Q2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT
	city_id,
	city_name,
	sum(total) as total_revenue
FROM 
(
SELECT 
	s.sale_date,
	To_char(s.sale_date, 'YYYY-MM') as month_year,
	s.sale_id,
	s.total, 
	ct.city_id, 
	ct.city_name
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ct
ON c.city_id = ct.city_id
) as t1
Where month_year between '2023-10' and '2023-12'
Group by city_id, city_name
Order by total_revenue desc;
;
-- Q3. Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	count(s.sale_id) as total_orders
FROM products as p
LEFT JOIN sales as s
On s.product_id = p.product_id
Group by p.product_name
Order by total_orders desc
;

-- Q4. Average Sales Amount per City
--What is the average sales amount per customer in each city?

Select
	ct.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_customers,
	round(sum(s.total)::numeric/count(Distinct s.customer_id)::numeric, 2) as avg_sale_per_customer
From sales as s 
Join customers as c
On s.customer_id = c.customer_id
Join city as ct
On ct.city_id = c.city_id
Group by ct.city_name
Order by total_revenue desc
;
	
--Q5. City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers. 
-- Return city_name, total current consumers, estimated coffee consumers (25%)

With city_table 
As
(
	SELECT 
		city_name,
		(population * 0.25) as coffee_consumers,
		city_rank
	FROM city
),

customers_table
As
(
	Select 
		ct.city_name,
		count(distinct c.customer_id) as unique_customers
	From sales as s
	Join customers as c
	On c.customer_id = s.customer_id
	Join city as ct
	On ct.city_id = c.city_id
	Group by ct.city_name
)

SELECT 
	ctt.city_name,
	ctt.coffee_consumers,
	cst.unique_customers
FROM city_table ctt
Join customers_table as cst
On cst.city_name = ctt.city_name
Order by unique_customers desc
;

--Q6. Top Selling Products by City
--What are the top 3 selling products in each city based on sales volume? 

Select *
From
(
Select
	ct.city_name,
	p.product_name,
	count(s.sale_id) as total_orders,
	rank() Over(Partition by ct.city_name Order by count(s.sale_id) desc) as city_ranking
From sales as s
Join products as p
On s.product_id = p.product_id
Join customers as c
On s.customer_id = c.customer_id
Join city as ct
On c.city_id = ct.city_id
Group by p.product_name, ct.city_name
Order by ct.city_name
) as t1
Where city_ranking <=3
;

--Q7. Customers Segmentation
-- How many unique customers are there in each city who have purchased coffee products?

Select
	ct.city_name,
	count(distinct c.customer_id) as number_of_customers
From sales as s
Join products as p
On s.product_id = p.product_id
Join customers as c
On s.customer_id = c.customer_id
Join city as ct
On c.city_id = ct.city_id
Where p.product_name ilike '%coffee%'
Group by ct.city_name;


-- Q8. Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

Select
	ct.city_name,
	count(distinct c.customer_id) as number_of_customers,
	sum(s.total) as total_sales,
	avg(ct.estimated_rent) as avg_rent,
	round(sum(s.total)::numeric/count(distinct c.customer_id)::numeric, 2) as avg_sale_per_customer,
	round(avg(ct.estimated_rent)::numeric/count(distinct c.customer_id)::numeric, 2) as avg_rent_per_customer
From sales as s
Join customers as c
On s.customer_id = c.customer_id
Join city as ct
On c.city_id = ct.city_id
Group by ct.city_name
Order by ct.city_name;

--Q9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or deline) in sales over different times periods (monthly) by each city

Select 
	*,
	coalesce(round((total_revenue - previous_revenue)/previous_revenue*100, 2), 0) as growth_ratio
From
(
Select 
	ct.city_name,
	To_char(sale_date, 'YYYY-MM') as month_year,
	sum(s.total)::numeric as total_revenue, 
	lag (sum(s.total), 1) Over(Partition by ct.city_name Order by To_char(sale_date, 'YYYY-MM'))::numeric as previous_revenue
From sales as s
Join customers as c
On s.customer_id = c.customer_id
Join city as ct
On c.city_id = ct.city_id
Group by month_year, ct.city_name
Order by ct.city_name 
);


--Q10.
-- Market Potential Analysis
-- Identify top 3 cities based on highest sales. Return city name, total sale, total rent, total customers, estimated coffee consumer

Select 
	ct.city_name, 
	sum(s.total)::numeric as total_revenue,
	avg(ct.estimated_rent) as estimated_rent, 
	count(distinct c.customer_id) as number_of_customers,
	population*0.25 as estimated_consumers
From sales as s
Join customers as c
On s.customer_id = c.customer_id
Join city as ct
On c.city_id = ct.city_id
Group by ct.city_name, estimated_consumers
Order by ct.city_name;







