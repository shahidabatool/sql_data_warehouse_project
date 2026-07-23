use DataWarehouse
GO 
--====Change over time ======----
--Its important to understand the trends over time 
-- sum[measure] by [DateDimension]
--e.g total_sales by year
--e.g avg_cost by month 
-- we usually use fact table because it have dates 

--1: Analyze sales performance over time 
select 
year(order_date) as order_year,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is NOT NULL
group by year(order_date)
order by year(order_date)
--2: add total number of customers in the previous one 
select 
year(order_date) as order_year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers 
from gold.fact_sales
where order_date is NOT NULL
group by year(order_date)
order by year(order_date)
--3: add total number of quantities 
select 
year(order_date) as order_year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is NOT NULL
group by year(order_date)
order by year(order_date)
--4: now we do it in month
select 
MONTH(order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is NOT NULL
group by MONTH(order_date)
order by month(order_date)
--5: now for both year and months 
select 
    year(order_date) as order_year,
    MONTH(order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is NOT NULL
group by year(order_date),MONTH(order_date)
order by year(order_date),month(order_date)

--6: using date trunc function (i am unable to use this one as i have old version 2019 )
select 
    DATETRUNC(month,order_date)as order_date,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is NOT NULL
group by DATETRUNC(month,order_date)
order by DATETRUNC(month,order_date)

--7: change the format as you want 
select 
    FORMAT(order_date,'yyyy-MMM')as order_date,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customers,
    sum(quantity) as total_quantity
from gold.fact_sales
where order_date is NOT NULL
group by  FORMAT(order_date,'yyyy-MMM')
order by  FORMAT(order_date,'yyyy-MMM')


--====Cumulative Analysis ======----
--agg data progressively over time 
--helps to understand how our business is growing over time
--sum[cumulative measure] by [DateDimension]
--e.g running total sales by year 
--e.g moving avg of sales by month

--1:calculate the total sales per month 
select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total 
FROM
(
select
DATEADD(month, DATEDIFF(month, 0, order_date), 0) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is NOT NULL
group by DATEADD(month, DATEDIFF(month, 0, order_date), 0) 
)t

--2:find the moving average 
select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total,
avg(avg_price)over(order by order_date) as moving_avg
FROM
(
select
DATEADD(month, DATEDIFF(month, 0, order_date), 0) as order_date,
sum(sales_amount) as total_sales,
AVG(price) as avg_price
from gold.fact_sales
where order_date is NOT NULL
group by DATEADD(month, DATEDIFF(month, 0, order_date), 0) 
)t



--=============Performance Analysis==========-----
/*comparing the current value to a target value
help measure success and compare performance
current[measure]-target[measures]
e.g current sale -avg
e.g current years sales-previous year sales
e.g current sales- lowest sales*/

--1: Analyze the yearly performance of the products by comparing 
-- each products sales to both its average sales performance and the previous years sales



with yearly_sales_product_sales as (
select 
    year(f.order_date) as order_year,
    p.product_name,
    sum(f.sales_amount) as current_sales
from gold.fact_sales f  
left join gold.dim_products p
on f.product_key=p.product_key
where order_date is not NULL
group by year(f.order_date),p.product_name
)
select 
order_year,
product_name,
current_sales,
avg(current_sales) over(PARTITION BY product_name) as avg_sale,
current_sales-AVG(current_sales)over(PARTITION BY product_name) as diff_avg,
case 
    when current_sales-AVG(current_sales)over(PARTITION BY product_name)>0 then 'Above Average'
    when current_sales-AVG(current_sales)over(PARTITION BY product_name)<0 then 'below Average'
    else 'Average'
end as avg_change,
--year over year analysis and if you want to do month then change year to month 
lag(current_sales) over(PARTITION BY product_name order by order_year) as previous_year_sale,
current_sales-lag(current_sales) over(PARTITION BY product_name order by order_year) as diff_py,
CASE
    when current_sales-lag(current_sales) over(PARTITION BY product_name order by order_year) >0 then 'Increase'
    when current_sales-lag(current_sales) over(PARTITION BY product_name order by order_year) <0 then 'Decrease'
    else 'No change'
end as py_change
from yearly_sales_product_sales
order by product_name, order_year;

--=========Part to whole analysis =============--
/*Analyze how an individual part os performing compared to the overall,
allowing us to understand which category has the greatest impact on the business
[measure] /total[meausure]*100 by [dimension]
sale/totalsale* 100 by category
quantity/total quantity *100 by country */

--which categories contributed the most to overall sales
with category_sales as (
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key=p.product_key
GROUP BY category
)
select 
category, total_sales,
sum(total_sales)over() as overall_sale,
concat(ROUND((cast(total_sales as float)/sum(total_sales)over())*100,2),'%') as percentage_sale
from category_sales
order by total_sales desc

--========== Data segmentation ===========----
/* group data based on specific range
helps understand the correlation between two measures
[measure] by [measure]
e.g total products by sale range
e.g total customers by age range */

-- 1: segment products into cost ranges and count how many products fall into each segment
with product_segmnet as (
select 
product_key,
product_name,
cost,
case 
    when cost<100 then'Below 100'
    when cost BETWEEN 100 and 500 then '100-500'
    when cost between 500 and 1000 then '500-1000'
    else 'above 1000'
end as cost_range
from
gold.dim_products
)
select 
cost_range,
count(product_key) as total_products
from product_segmnet
group by cost_range
order by total_products

--2: Group customers into 3 segment based on their spending behavior 
--vip atleasr 12 month of history and spending >5000
--regular atleast 12 month of history spending <5000
--new lifespan less than 12 month 


with customer_spending as (
select 
c.customer_key,
sum(f.sales_amount) as total_spending,
min(f.order_date) as first_order,
max(f.order_date) as lasr_order,
DATEDIFF(month,min(order_date),max(order_date)) as lifespan
from gold.fact_sales f   
left join  gold.dim_customer c 
on f.customer_key=c.customer_key
group by c.customer_key
)
select customer_segment,
count(customer_key) as total_customers
from 
(
select 
customer_key,
case 
    WHEN total_spending>5000 and lifespan>=12 then 'VIP'
    when total_spending<=5000 and lifespan>=12 then 'Regular'
    else 'New'
end as customer_segment
from customer_spending)t 
group by customer_segment
order by total_customers


--==============Final Report ======================--------
/*
Purpose:
    - This report consolidates key customer metrics and behaviors 

Highlights:
    1. Gather essential fields such as names,ages and transaction details
    2. Segment customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics :
        - total orders
        - total_sales
        - total quantity purchased
        - total products
        - lifespan 
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
----------------------------------------------------------------
*/
--========Base CTE============----
create view gold.report_customers as
with base_query AS(
select 
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.cutomer_number,
    concat(c.first_name,' ',c.last_name) as customer_name,
    datediff(year,c.birthdate,GETDATE()) as age 
from gold.fact_sales f 
left join gold.dim_customer c  
on f.customer_key=c.customer_key
where order_date is not null
)
--==============Aggregate CTE=============------
, customer_aggregation as (
select 
    customer_key,
    cutomer_number,
    customer_name,
    age,
    count(distinct order_number)as total_order,
    sum(sales_amount)as total_sales,
    sum(quantity) as total_quantity,
    count (distinct product_key) as total_products,
    max(order_date) as last_order_date,
    datediff(month,min(order_date),max(order_date)) as lifespan
 from base_query
 group by customer_key,
    cutomer_number,
    customer_name,
    age
)
---==================

select 
    customer_key,
    cutomer_number,
    customer_name,
    age,
    case 
        when age<20 then 'under 20'
        when age between 20 and 29 then '20-29'
        when age between 30 and 39 then '30-39'
        when age between 40 and 49 then '40-49'
        else '50 and above'
    end as age_group,
    case 
        WHEN total_sales>5000 and lifespan>=12 then 'VIP'
        when total_sales<=5000 and lifespan>=12 then 'Regular'
        else 'New'
    end as customer_segment,
    last_order_date,
    datediff(month,last_order_date,GETDATE()) as recency,
    total_order,
    total_quantity,
    total_products,
    total_sales,
    lifespan,
    -- compute avg order value(avo)
    case 
        when total_sales=0 then 0
        else 
        total_sales/total_order
    end as avg_monthly_value,
    --compute monthly spend
     case 
        when lifespan=0 then total_sales
        else 
        total_sales/lifespan
    end as avg_monthly_spend
from customer_aggregation




select * from gold.report_customers
