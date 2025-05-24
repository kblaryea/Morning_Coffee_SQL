# Monday Coffee Expansion SQL Project

![Company Logo](https://github.com/najirh/Monday-Coffee-Expansion-Project-P8/blob/main/1.png)

## Objective

The goal of this project is to analyze the sales data of Monday Coffee, a company that has been selling its products online since January 2023, and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand and sales performance.

An ERD diagram is included to visually represent the database schema and relationships between tables.
![ERD](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/ERD.png)

## Key Questions
1. **Coffee Consumers Count**  
   How many people in each city are estimated to consume coffee, given that 25% of the population does?
```sql
   SELECT 
	city_name,
	(population * 0.25) as coffee_consumers,
	city_rank
FROM city
Order by coffee_consumers desc
;
```
![](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/Slide2.png)

### Remarks:
Delhi leads in estimated coffee consumption with about 7.75 million consumers. Mumbai ranks second and Bangalore has a significantly low estimated consumption (3.08 million).

2. **Total Revenue from Coffee Sales**  
   What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
```sql
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
```
![](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/Slide5.png)

### Remarks:
During the period, Pune recorded the highest total revenue at approximately ₹434,000, followed by Chennai and Bangalore. On the lower end of the spectrum, Hyderabad, Ahmedabad, and Lucknow reported the least total revenue.

3. **Sales Count for Each Product**  
   How many units of each coffee product have been sold?
```sql

SELECT 
	p.product_name,
	count(s.sale_id) as total_orders
FROM products as p
LEFT JOIN sales as s
On s.product_id = p.product_id
Group by p.product_name
Order by total_orders desc
;
```
### Remarks:
The products with the highest number of orders during the period were the Cold Brew Coffee Pack, Ground Espresso Coffee, and Instant Coffee Powder. In contrast, the Coffee-Themed Notebook, Stainless Steel Tumbler, and Coffee Mug received the fewest orders.

4. **Average Sales Amount per City**  
   What is the average sales amount per customer in each city?
```sql
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
```
![](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/Slide6.png)

### Remarks
Pune, Chennai, and Bangalore reported relatively higher average revenue per customer at ₹24,198, ₹22,479, and ₹22,054 respectively. In comparison, the average revenue per customer across the remaining cities was approximately ₹15,000.

5. **City Population and Coffee Consumers**  
   Provide a list of cities along with their populations and estimated coffee consumers.
```sql
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
On cst.city_name = ctt.city_name;
```
### Remarks:
Jaipur, Delhi, and Pune recorded the highest number of unique customers, with 69, 68, and 52 respectively. Conversely, Lucknow, Hyderabad, and Indore had the lowest number of unique customers during the period.

6. **Top Selling Products by City**  
   What are the top 3 selling products in each city based on sales volume?
```sql
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
```
![](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/Slide7.png)


7. **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products?
```sql
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
```


8. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer
```sql
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
```
![](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/Slide8.png)

### Remarks: 
Pune, Chennai, and Bangalore lead in average revenue per customer, with figures of ₹24,198, ₹22,479, and ₹22,054 respectively. Cities such as Kanpur, Nagpur, and Ahmedabad showed lower average sales per customer, ranging between ₹5,835 and ₹6,101, suggesting lower spending behavior or market penetration.

Mumbai and Hyderabad had the highest average rent per customer at ₹1,167 and ₹1,071 respectively, potentially impacting profitability. Jaipur and Kanpur had the lowest rent per customer, at ₹157 and ₹231 respectively, indicating more favorable operating costs.

9. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
```sql

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
```

10. **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer
```sql

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
```
![](https://github.com/kblaryea/Morning_Coffee_SQL/blob/main/Slide11.png)

### Remarks:
- Pune (₹1,258,290), Chennai (₹944,120), and Bangalore (₹860,110) generated the highest total revenues, indicating strong market performance
- Delhi leads with an estimated 7.75 million consumers, followed by Kolkata (3.73M) and Bangalore (3.08M), reflecting significant market size potential.
- Cities such as Delhi and Kolkata have high estimated consumer bases but relatively lower revenues compared to Pune and Chennai, suggesting opportunities for deeper market penetration or improved conversion.
- Rent levels vary significantly, with Mumbai (₹31,500) and Bangalore (₹29,700) incurring the highest estimated rents, potentially impacting profitability in these locations.






## Recommendations
After analyzing the data, the recommended top three cities for new store openings are:

**City: Pune**
- Total Revenue: ₹1,258,290 (highest)
- Average Sale/Customer: ₹24,198 (highest)
- Rent/Customer: ₹294.23 (moderate)
- Estimated Consumers: 1.88 million (moderate)
**Rationale:** Pune combines strong per-customer revenue, solid total revenue, and manageable operating costs—suggesting a high-value, efficient market.


**City 2: Chennai**
- Total Revenue: ₹944,120 (2nd highest)
- Average Sale/Customer: ₹22,479 (2nd highest)
- Rent/Customer: ₹407.14 (reasonable)
- Estimated Consumers: 2.78 million
**Rationale:** High sales per customer and a large consumer base make Chennai a lucrative and scalable market.


**City 3: Bangalore**
- Total Revenue: ₹860,110
- Average Sale/Customer: ₹22,054
- Rent/Customer: ₹761.54 (higher but offset by strong revenue)
- Estimated Consumers: 3.08 million
**Rationale:** Despite higher rent, Bangalore offers a large consumer pool and high per-customer revenue, making it a strategic long-term investment.

 ### Why not Delhi or Mumbai?
- **Delhi:** High consumer base (7.75M) but much lower revenue per customer (₹11,036), suggesting weak monetization.
- **Mumbai:** High rent (₹1166.67/customer) and modest per-customer sales (₹8703.70) make it less efficient compared to others.

---
