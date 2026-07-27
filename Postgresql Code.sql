
-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- TheLook E-Commerce Data Analysis Project

-- -----------------------------------------------------------------------------------------------------------------------------------------------


-- Creating Tables and Importing datasets.

select * from distribution_centers;

-- Inserting data from into distribution_centers from CSV file.
copy distribution_centers
FROM 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.distribution_centers.csv'
DELIMITER ','
CSV HEADER;

-- Inserting data into events table from CSV file.
select * from events;
copy events
FROM 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.events.csv'
DELIMITER ','
CSV HEADER;
select count(*) from events;


-- Inserting data into inventory_items table from CSV file.
drop table inventory_items;

Create table inventory_items (
id bigint,
product_id bigint,
created_at varchar(500),
sold_at varchar(500),
cost float,
product_category varchar(500),
product_name varchar(500),
product_brand varchar(500),
product_retail_price float,
product_department varchar(500),
product_sku varchar(500),
product_distribution_center_id bigint
);


copy inventory_items
FROM 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.inventory_items.csv'
DELIMITER ','
CSV HEADER;

select * from inventory_items; 

-- Inserting data into order_items table from CSV file.

Create table order_items(
id int,
order_id bigint,
user_id bigint,
product_id bigint,
inventory_item_id bigint,
status varchar(200),
created_at varchar(200),
shipped_at varchar(200),
delivered_at varchar(200),
returned_at varchar(200),
sale_price float
);

copy order_items
FROM 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.order_items.csv'
DELIMITER ','
CSV HEADER;


-- Inserting data into orders table from CSV file.
Create table orders (
order_id bigint,
user_id bigint,
status varchar(200),
gender varchar(200),
created_at varchar(200),
returned_at varchar(200),
shipped_at varchar(200),
delivered_at varchar(200),
num_of_item bigint
);

copy orders
FROM 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.orders.csv'
DELIMITER ','
CSV HEADER;

select * from orders;

-- Inserting data into products table from CSV file.
drop table products;
create table products (
id bigint,
cost float,
category varchar(200),
name varchar(500),
brand varchar(200), 
retail_price float,
department varchar(200),
sku varchar(200),
distribution_center_id int
);


copy products 
from 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.products.csv'
delimiter ','
csv header;

-- Inserting data into users table from CSV file.
drop table users;
Create table users (
id bigint, 
first_name varchar(200),
last_name varchar(200),
email varchar(200),
age int, 
gender varchar(200),
state varchar(200),
street_address varchar(200),
postal_code varchar(200),
city varchar(200),
country varchar(200),
latitude float,
longitude float,
traffic_source varchar(200),
created_at varchar(200)
);

copy users
from 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.users.csv'
delimiter ','
csv header;

select * from users;

-- Importing Events Dataset. 

drop table events;
Create table events (
id int,
user_id int, 
sequence_number int, 
session_id varchar(500),
created_at varchar(500),
ip_address varchar(500),
city varchar(500),
state varchar(500),
postal_code varchar(500), 
browser varchar(500),
traffic_source varchar(500),
uri varchar(500), 
event_type varchar(500)
);

COPY events
FROM 'E:\Projects New\SQL Project\TheLook eCommerce Dataset\thelook_ecommerce.events.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Total rows in database

select (
	(select count(*) from distribution_centers) +
	(select count(*) from events) +
	(select count(*) from inventory_items) +
	(select count(*) from order_items) +
	(select count(*) from orders) + 
	(select count(*) from  products) +
	(select count(*) from users)
) as total_rows_in_database; 
	-- Total 2.2 million rows of data are present after cleaning.

-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Data cleaning of distribution_centers

select * from distribution_centers; -- No cleaning required all data are in place.

-- -----------------------------------------------------------------------------------------------------------------------------------------------
 -- Data Cleaning of events table.;

select * from events;


select 
	sum(case when id is null then 1 else 0 end) as nulls_in_id,
	sum(case when user_id is null then 1 else 0 end) as nulls_in_user_id,
	sum(case when sequence_number is null then 1 else 0 end) as nulls_in_sequence_number,
	sum(case when session_id is null then 1 else 0 end) as nulls_in_session_id,
	sum(case when created_at is null then 1 else 0 end) as nulls_in_created_at,
	sum(case when ip_address is null then 1 else 0 end) as nulls_in_ip_address,
	sum(case when city is null then 1 else 0 end) as nulls_in_city,
	sum(case when state is null then 1 else 0 end) as nulls_in_state,
	sum(case when postal_code is null then 1 else 0 end) as nulls_in_postal_code,
	sum(case when browser is null then 1 else 0 end) as nulls_in_browser,
	sum(case when traffic_source is null then 1 else 0 end) as nulls_in_traffic_source,
	sum(case when uri is null then 1 else 0 end) as nulls_in_uri,
	sum(case when event_type is null then 1 else 0 end) as nulls_in_event_type
from events; -- Only user_id have 1124065 Nulls rest of the columns have 0 nulls
  
-- Checking for duplicate values
select id, count(*) from events group by id having count(*)>1; -- No duplicates rows

-- Dropping rows where user_id is null 
delete from events where user_id is null;
select count(*) from events; -- there are 12 lakhs rows

-- Dropping session_id, ip_address  column
Alter table events drop column session_id, drop column ip_address, drop column sequence_number;

-- Checking duplicate names in STATE column
select distinct state from events; -- No duplicate names

-- Cleaning created_at column (having data like 2022-06-08 11:15:25.823859 UTC & 2022-06-08 10:33:11 UTC which are not datetime datatype)
select * from events;
select left(created_at,19) from events;

Alter table events add column new_created_at timestamp;
Update events 
set new_created_at = (cast(left(created_at,19) as Timestamp)); 

Alter table events drop column created_at; -- Dropping created_at column because it is varchar dtype.

select * from events limit 5;

-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Data Cleaning on inventory_items table

select * from inventory_items;

select 
	sum(case when id is null then 1 else 0 end) as null_in_id,
	sum(case when product_id is null then 1 else 0 end) as null_in_product_id,
	sum(case when created_at is null then 1 else 0 end) as null_in_created_at,
	sum(case when sold_at is null then 1 else 0 end) as null_in_soldat,
	sum(case when cost is null then 1 else 0 end) as null_in_cost,
	sum(case when product_category is null then 1 else 0 end) as null_in_product_category,
	sum(case when product_name is null then 1 else 0 end) as null_in_product_name,
	sum(case when product_brand is null then 1 else 0 end) as null_in_product_brand,
	sum(case when product_retail_price is null then 1 else 0 end) as null_in_productretailprice,
	sum(case when product_department is null then 1 else 0 end) as null_in_product_department,
	sum(case when product_sku is null then 1 else 0 end) as null_in_product_sku,
  	sum(case when product_distribution_center_id is null then 1 else 0 end) as null_in_product_distribution_center_id
from inventory_items; 
-- there are 3,06,949 nulls in sold_at column but not dropping the null values because assuming that there can be products that are not sold.


select * from inventory_items limit 5;

-- Working on date timestamp columns
alter table inventory_items
alter column created_at TYPE Timestamp
using left(created_at, 19) :: Timestamp;

alter table inventory_items
alter column sold_at TYPE Timestamp
using left(sold_at,19) :: Timestamp;

 -- Working on cost column
 select * from inventory_items order by random() limit 5;

select distinct cost from inventory_items order by cost asc;
select cost as cost1, cast(cost as numeric(12,4)) from inventory_items order by cost1 asc;

update inventory_items 
set cost  = cast(cost as numeric(12,4));

update inventory_items 
set product_retail_price  = cast(product_retail_price as numeric(12,4));

-- Anazlying column product sku

select product_sku, count(product_sku) from inventory_items group by product_sku having count(product_sku) > 1;

select count(distinct product_sku), count(product_sku),  count(product_sku) - count(distinct product_sku)  from inventory_items; 
 -- there are same and multiple sku 



-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- -- Data Cleaning on order_items table

select count(*) from order_items;
select * from order_items order by random() limit 5;

-- Identifying null values
select 
	sum(case when id is null then 1 else 0 end) as null_in_id,
	sum(case when order_id is null then 1 else 0 end) as null_in_order_id,
	sum(case when user_id is null then 1 else 0 end) as null_in_user_id,
	sum(case when product_id is null then 1 else 0 end) as null_in_product_id,
	sum(case when inventory_item_id is null then 1 else 0 end) as null_in_inventory_item_id,
	sum(case when status is null then 1 else 0 end) as null_in_status,
	sum(case when created_at is null then 1 else 0 end) as null_in_created_at,
	sum(case when shipped_at is null then 1 else 0 end) as null_in_shipped_at,
	sum(case when delivered_at is null then 1 else 0 end) as null_in_delivered_at,
	sum(case when returned_at is null then 1 else 0 end) as null_in_returned_at,
	sum(case when sale_price is null then 1 else 0 end) as null_in_sale_price
from order_items;
	  -- there are null values in shipped_at: 63,074, delivered_at : 1,17,755, returned_at: 1,62,765. Not dropping null values because there are orders which are cancelled

-- Changing float data type to 2 decimal dataype.
update order_items
set sale_price = cast(sale_price as numeric(12,4));

select * from order_items order by random() limit 5;

-- Changing column data type to timestamp
Alter table order_items alter column created_at type timestamp using left (created_at,19):: Timestamp;
Alter table order_items alter column shipped_at type timestamp using left(shipped_at,19):: Timestamp;
Alter table order_items alter column delivered_at type timestamp using left(delivered_at,19):: Timestamp;
Alter table order_items alter column returned_at type timestamp using left(returned_at,19):: Timestamp;


-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- -- Data Cleaning on orders table
select count(*) from orders;
select * from orders limit 5;

select 
	sum(case when order_id is null then 1 else 0 end) as null_in_order_id,
	sum(case when user_id is null then 1 else 0 end) as null_in_user_id,
	sum(case when status is null then 1 else 0 end) as null_in_status,
	sum(case when gender is null then 1 else 0 end) as null_in_gender,
	sum(case when created_at is null then 1 else 0 end) as null_in_created_at,
	sum(case when returned_at is null then 1 else 0 end) as null_in_returned_at,
	sum(case when shipped_at is null then 1 else 0 end) as null_in_shipped_at,
	sum(case when delivered_at is null then 1 else 0 end) as null_in_delivered_at,
	sum(case when num_of_item is null then 1 else 0 end) as null_in_num_of_item
from orders;
		-- Null in retuned_at: 112,353, shipped_at: 43,671, delivered_at: 81,325 

-- Chaning date column type from varhcar to timestamp dtype. 
select * from orders limit 5;

Alter table orders alter column created_at type timestamp using left(created_at,19):: Timestamp;
Alter table orders alter column returned_at type timestamp using left(returned_at,19):: Timestamp;
Alter table orders alter column shipped_at type timestamp using left(shipped_at,19):: Timestamp;
Alter table orders alter column delivered_at type timestamp using left(delivered_at,19):: Timestamp;

--- Searching for duplicate values
select order_id, count(order_id) from orders group by order_id having count(order_id) >1; -- No duplicate values.

-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Data cleaning on products table

select * from products limit 5;
select count(*) from products; -- 29120 products

alter table products alter column cost type numeric(12,4);
alter table products alter column retail_price type numeric(12,4);

select id, count(id) from products group by id having count(*) >1; -- No duplicate rows

-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Data cleaning on users tables

select * from users limit 5;

-- Checking for duplicate rows. 
select id, count(id) from users group by id having count(*) >1; -- No duplicate rows.

-- Dropping street_address, postal_code column as it is not required 
alter table users drop column street_address;
alter table users drop column postal_code;

-- unique cities in column
select count(distinct city) from users; -- 7880 different cities.

-- Changing created_at data type to timestamp dtype.
alter table users alter column created_at type timestamp using left(created_at,19):: timestamp;


-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Creating ERD and realtionship to understand the database more clearly.

-- Provlem : There are many ids column in every table which is creating confusion so altering the name of ids column with respective column name

-- It will done in ERD itself
select * from inventory_items limit 5;

-- Change in ERD is not reflecting in the database, so we have to change it via SQL query.
Alter table inventory_items rename column id  to inventory_items_id;

select * from events;
Alter table events rename column id to events_id;

select * from products limit 5;
Alter table products rename column id to product_id;

select * from order_items limit 5; 
Alter table order_items rename column id to order_items_id;

select * from distribution_centers limit 5;
Alter table distribution_centers rename column id to distribution_centers_id;

select * from users limit 5;
Alter table users rename column id to users_id;


-- -----------------------------------------------------------------------------------------------------------------------------------------------

-- Customer Analytics

-----------------------------------------------------------------------------------------------------------------------------------------------

-- 1.Who are the top 10 customers by lifetime value (LTV)?

select * from order_items;

select user_id, round(sum(sale_price)::Numeric,2) total_spending 
from order_items
where status = 'Complete'
group by user_id
order by total_spending  desc
limit 10;


-- 2.What percentage of customers are repeat customers versus one-time customers?
select * from orders;

with cte as (
select 
	user_id, 
	count(user_id), 
	case when count(user_id)> 1 then 'repeat_customer' else 'one-time_customer' end as category
from orders
group by user_id
)
select 
	category, 
	count(user_id) user_count, 
	concat(round(count(user_id)*100 / sum(count(user_id)) over(),2),'%') as percentage
from cte
group by category;
	-- Insight: 62.49% of customers are one time customers on the other hand 37.51% are repeated customers.


-- 3.What is the average time gap between two consecutive purchases for each customer?

select * from orders limit 5;

with cte as (
select  
	user_id, order_id, status, created_at, date(created_at),
	lead( date(created_at)) over(partition by user_id order by  date(created_at) asc ) as next_order_date
from orders
where status = 'Complete'
)
select round(avg(next_order_date - date),2) as days 
from cte 
where next_order_date is not null;
  -- Overall average time gap between the consecutive purchases for each customer is 189 days


with cte as (
select  
	user_id, order_id, status, created_at, date(created_at),
	lead( date(created_at)) over(partition by user_id order by  date(created_at) asc ) as next_order_date
from orders
where status = 'Complete'
)
select user_id from cte 
where next_order_date is not null
group by user_id
order by user_id asc;
 -- List of user_id that has placed consecutive purchases



-- 4.Identify customers who have not placed an order in the last 180 days but had previously made purchases.


select max(date(created_at)) from orders; -- 2022-06-08


with cte as (
	select user_id, max(date(created_at)) as latest_order_date
	from orders
	group by user_id
)
select count(user_id) from cte
where latest_order_date < (select max(date(created_at)) - interval '180 days' from orders);
	-- Insight: There are 38964 customer who have not placed an order in the last 180 days but had previously made purchases. 


-- 5.Which age group contributes the highest revenue?

select users_id, age, gender from users;
select order_items_id, order_id, user_id from order_items;
select order_id, user_id from orders;


-- select 
-- 	u.users_id, u.age,
-- 	oi.sale_price
-- from order_items oi
-- left join  orders o
-- on oi.order_id = o.order_id and oi.user_id = o.user_id
-- left join users u
-- on oi.user_id = o.user_id

		-- Above Query taking more than 2 min to run and still it was not executing. Hence Optimizing the query usng CTE.

with cte as(
select 
	oi.user_id, oi.sale_price
from order_items oi
left join  orders o
on oi.order_id = o.order_id and oi.user_id = o.user_id
)
select
	case when age between 12 and 20 then 'Teen (12-20)'
		when age between 21 and 25 then 'Young Adult (21-25)'
		when age between 26 and 59 then 'Adult (26-59)'
		when age >= 60 then 'Senior Citizen (60 >)'
	end as category,
	round(count(user_id)::Numeric,2) as user_count,
	round(sum(cte.sale_price)::Numeric,2) as Revenue
from cte 
left join users u
on cte.user_id = u.users_id
group by category
order by Revenue desc;

	-- This query worked under 0.225 ms
	-- Insight: We generate more that 60 Lakhs of revenue from Adult which have age ranges from 25 to 59.


-- Q5.1:  Which Gender group contributes the highest revenue.
with cte as(
select 
	oi.user_id, oi.sale_price
from order_items oi
left join  orders o
on oi.order_id = o.order_id and oi.user_id = o.user_id
)
select
	u.gender,
	round(sum(cte.sale_price)::Numeric,2) as Revenue
from cte 
left join users u
on cte.user_id = u.users_id
group by gender
order by Revenue desc;
 
  -- Insight: Male has genederated more revenue than Female.



-- 6.Which customer acquisition channel (traffic_source) produces highest customers?

Select e.traffic_source, count(distinct o.user_id) as user_count from orders o
left join events e
using (user_id)
where traffic_source is not null and status = 'Complete'
group by e.traffic_source
order by user_count desc;

	-- Insight: Most of the users ordered through EMAIL follwing by ADWORDS and other sources.


-- 7.Which states have the highest customer retention rate?
-- Formula of Retension rate : Retention Rate = Customers with more than one order * 100 ÷ Total customers

with cte as(
	select 
		u.state, u.users_id , count(distinct o.order_id) as total_orders 
	from orders o
	join users u
	on o.user_id = u.users_id 
	group by users_id, u.state 
)
Select  state, count(users_id) as total_customers,
	count(case when total_orders > 1 then 1 end) as retained_customers,
	count(case when total_orders > 1 then 1 end)*100 / count(users_id) as retention_rate
from cte
group by state
order by retention_rate desc;
	-- Insight: Vermont and Shiga has 100% retention rate because it only has 1 customers which are retained.	


-- 8. Calculate the customer churn rate month-over-month.
-- (Customer which ordered this month but didnt ordered in next month)

-- Formula: Churn Rate = Churned Customers / Previous Month Customers × 100	

with cte as (
	select distinct date_trunc('month', created_at)::date as order_month, user_id 
	from orders
),
cte_2 as (
	select 
		this_month.order_month, 
		this_month.user_id, 
		next_month.user_id as next_month_customer 
	from cte as this_month
	left join cte as next_month
		on this_month.user_id = next_month.user_id  
		and  next_month.order_month = this_month.order_month + interval '1 month'
)
select
	order_month, count(user_id) as active_customer, 
	count((case when next_month_customer is  null then 1 end)) as churned_customers,
	round(count(case when next_month_customer is  null then 1 end) *100 / count(user_id),2) as churn_rate
from cte_2
group by order_month
order by order_month;


-- 9.Find the top 5 customers whose average order value is significantly higher than the overall average order value (AOV).

with cte as (
	select user_id, order_id, sum(sale_price) as total_order_value 
	from order_items
	where status = 'Complete'
	group by user_id, order_id
	order by user_id, order_id
),
cte2 as (
	select user_id, round(avg(total_order_value)::Numeric,2) as avg_order_value from cte
	group by user_id
) 
select * from cte2 
where avg_order_value > (select avg(total_order_value) from cte)
order by avg_order_value desc limit 5;
	-- Insight: There are 9240 Users where average order value is higher than overall average value.
	


-- 10.Which customers have the highest product return rate?

Select user_id,order_items_id, returned_at  from order_items;

select 
	user_id, 
	count(case when returned_at is not null then 1 end) return_count,
	count(order_items_id) total_orders,
	count(case when returned_at is not null then 1 end) *100 / count(order_items_id) as return_rate 
from order_items
group by user_id
order by return_rate desc;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Sales & Revenue Analytics

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 11.Calculate monthly revenue growth percentage (MoM Growth %).
-- Formula: (current_month_revenue - prev_revenue) / prev_revenue * 100 

with cte as (
	select date_trunc('month',created_at)::date as yr_month, 
		round(sum(sale_price)::Numeric,2) as month_revenue,
		lag(round(sum(sale_price)::Numeric,2)) over(order by date_trunc('month',created_at)) as prev_revenue
	from order_items
	where status = 'Complete'
	group by date_trunc('month',created_at)
	order by yr_month asc
)
select *, coalesce(round((month_revenue - prev_revenue) *100 / prev_revenue ,2),0) as mom_growth_percent from cte;



-- 12.Calculate cumulative revenue over time.

with cte as (
	select date_trunc('month', created_at)::date as yr_month, sum(sale_price) monthly_revenue
	from order_items
	where status = 'Complete'
	group by date_trunc('month', created_at)
)
select 
	yr_month, 
	round(monthly_revenue::Numeric,2) as monthly_revenue, 
	round(sum(monthly_revenue) over(order by yr_month rows between unbounded preceding and current row)::Numeric,2) as cumulative_monthly_revenue 
from cte;


-- 13.Identify the top 10 revenue-generating products contributing to 80% of total revenue (Pareto Analysis).

with cte as (
	select 
		p.name, 
		sum(oi.sale_price) as revenue  
	from order_items oi
	left join products p
		on oi.product_id = p.product_id
	where status = 'Complete'
	group by name
),
cte2 as (
	select 
		name, 
		revenue , 
		round(sum(revenue) over()::Numeric,2), 
		round(revenue ::Numeric *100 / sum(revenue) over()::Numeric,2) as total_revenue_percent 
	from cte
),
cte3 as (
	select 
		name,
		round(revenue::Numeric,2) as revenue , 
		sum(total_revenue_percent) over(order by revenue desc rows between unbounded preceding and current row) cumm_percent 
	from cte2
	order by revenue desc
)
select * from cte3 where cumm_percent <=80
order by revenue desc 
limit 10;

	-- Insight: There are more than 1000 products and it is difficult to see which product made more revenue hence we are grouping by product category 


-- 13.1 Category that generated 80% of the Revenue

-- CREATE VIEW pareto_analysis_category AS 
-- Create table pareto_analysis_category_table as 

with cte as (
	select 
		p.category, 
		sum(oi.sale_price):: Numeric as total_revenue  
	from order_items oi
	left join products p
	on oi.product_id = p.product_id
	where status = 'Complete'
	group by category
),
cte2 as (
	select *,
		sum(total_revenue) over(), 
		round((total_revenue *100) /sum(total_revenue) over()::Numeric,2)  percent
	from cte
),
cte3 as (
Select *, sum(percent) over(order by total_revenue desc rows between unbounded preceding and current row) as percent_desc from cte2
)
select category, round(total_revenue::Numeric,2) as total_revenue, percent_desc 
from cte3 
where percent_desc <= 80 order by percent desc;
	-- Jeans, Outerwear & Coats, Sweaters and others are the leading category generated 80% of revenue

select * from pareto_analysis_category;





-- 14.Which product categories have the highest profit margins?
		-- Formula:  Profit Margin = (Profit / Revenue) *100

select p.category, oi.status, p.cost, oi.sale_price  from order_items oi
left join products p
on oi.product_id = p.product_id
order by random() limit 10;

select p.category,  
	round(sum(p.cost)::Numeric,2) as total_cost, 
	round(sum(oi.sale_price)::Numeric,2) as total_revenue,  
	round(sum(oi.sale_price)::Numeric - sum(p.cost) :: Numeric,2) as total_profit,
	
	round((sum(oi.sale_price)::Numeric - sum(p.cost) :: Numeric) *100 / sum(oi.sale_price)::Numeric,2) as profit_margin
from order_items oi
left join products p
on oi.product_id = p.product_id
where status = 'Complete'
group by category
order by profit_margin desc;
	-- Insight: Blazers & Jackets category has highest profit margin.

	

-- 15. Which Category have high sales volume but low profit margins?

select p.category, count(order_items_id) order_count, 
	round(sum(p.cost)::Numeric,2) as total_cost, 
	round(sum(oi.sale_price)::Numeric,2) as total_revenue,  
	round(sum(oi.sale_price)::Numeric - sum(p.cost) :: Numeric,2) as total_profit,
	
	round((sum(oi.sale_price)::Numeric - sum(p.cost) :: Numeric) *100 / sum(oi.sale_price)::Numeric,2) as profit_margin
from order_items oi
left join products p
on oi.product_id = p.product_id
where status = 'Complete'
group by category
order by order_count desc, profit_margin asc;
	-- Insight: Intimates category has low profit margin with 46.70% but high sales volumne with 3348 orders.



-- 16. Calculate Average Order Value (AOV) by month and identify seasonality.
 		-- Formula: Average Order Value (AOV) = (Total Revenue / Total Number of Distinct Orders) * 100

select * from orders;

select 
	date_trunc('month',o.created_at)::Date, 
	count(distinct o.order_id) order_count, 
	round(sum(oi.sale_price)::Numeric,2) as total_revenue,
	round(sum(oi.sale_price)::Numeric / count(distinct o.order_id) ::Numeric ,2) as avg
from orders o
join order_items oi
on o.order_id = oi.order_id and o.user_id = oi.user_id
where o.status =  'Complete'
group by date_trunc('month',o.created_at)::Date;


-- 17. Find the top-selling product in each category.

select distinct category from products; -- 26 categories,

with cte as (
	select products.category, products.name, count(name) total_count, round(sum(order_items.sale_price)::Numeric,2) as total_revenue  from order_items
	join products
	on products.product_id = order_items.product_id 
	group by products.category, products.name
),
cte2 as(
select *, rank() over(partition by category order by total_count desc) rnk from cte
)
select category, name, total_count, total_revenue from cte2 where rnk = 1
order by total_count desc;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Inventory & Supply Chain Analytics

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 18. Calculate average inventory holding time for each category 


select 24* 60* 60 ; -- 24 hour * 60 min * 60 seconds = 86400 seconds/day

select p.category,
	round(AVG(EXTRACT(EPOCH FROM (it.sold_at - it.created_at)) / 86400),2)avg_inventory_holding_days
from inventory_items it
join products p on p.product_id = it.product_id 
where sold_at is not null
group by p.category
order by avg_inventory_holding_days desc;


-- 19. Which distribution centers take the longest time to sell their inventory

select 
	dc.name,
	round(avg(extract(EPOCH from (sold_at - created_at))/86400),2) as longest_time_to_sell_inventory
from distribution_centers dc
join products p
on dc.distribution_centers_id = p.distribution_center_id  
join inventory_items it
on it.product_id = p.product_id
where it.sold_at is not null
group by dc.name
order by longest_time desc
	--	Insight: Mobile AL takes the longest time to sell their inventory.


-- 20.Which products remain unsold for the longest period?

select p.name,  
	round(avg(extract(EPOCH from (sold_at - created_at))/86400),2) as avg_day_to_sell
from inventory_items it
left join  products p
on p.product_id = it.product_id
where sold_at is not null
group by p.name
order by avg_day_to_sell desc;


-- 21.Identify products that have a high inventory cost but low sales volume.

with cte as(
	select p.name, oi.order_id, oi.sale_price, it.cost from order_items oi
	left join inventory_items it
		on it.inventory_items_id = oi.inventory_item_id
	left join products p
		on oi.product_id = p.product_id
	where oi.status = 'Complete'
)
select name, round(sum(cost)::Numeric,2) inventory_cost, count(order_id) as sales_count from cte
group by name
order by inventory_cost desc, sales_count asc




-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Logistics & Operations Analytics

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 22. Calculate average delivery time by state. 

select u.state,round(avg(extract(EPOCH from (o.delivered_at - o.shipped_at))/ 86400),2) avg_delivery_time 
from orders o
left join users u 
	on u.users_id = o.user_id
where shipped_at is not null and delivered_at is not null
group by u.state
order by avg_delivery_time desc;
	-- Insight: Mie State has highest average delivery time.


-- 23.Which states experience the highest return rates?

select 
	u.state, count(*) as total_items, count(case when oi.returned_at is not null then 1 end) as returned_items,
	round(count(case when oi.returned_at is not null then 1 end)::Numeric *100 / count(*),2)as return_rate
from order_items oi
left join users u 
	on u.users_id = oi.user_id
group by state
order by return_rate desc;


-- 24.Which category experience the highest return rates?

select 
	p.category,
	count(oi.order_items_id) as total_count, 
	count(case when returned_at is not null then 1 end) as returned_count,
	round(count(case when returned_at is not null then 1 end)::Numeric *100 / count(oi.order_items_id),2) as return_rate_percent
from order_items oi
join products p
on p.product_id = oi.product_id
group by p.category
order by return_rate_percent desc;
	-- Insight: Highest Return Rate Percent is for Clothing Sets with over 11.89%


-- 25.Find customers whose orders consistently take longer than average to deliver.

with cte as (
	select 
		oi.user_id, 
		round(avg(extract(EPOCH from (oi.delivered_at - oi.shipped_at)))::Numeric /86400,2) as avg_delivery_days
	from order_items oi
	join users u
		on u.users_id = oi.user_id
	where oi.status = 'Complete'
	group by oi.user_id
	order by avg_delivery_days desc
)
select user_id,concat(u.first_name,' ', u.last_name),avg_delivery_days as full_name  from cte 
join users u 
on u.users_id = cte.user_id
where avg_delivery_days > (select avg(avg_delivery_days) from cte )
	-- Insight: There are 13,641 users where customers orders consistently but take longer than average to deliver.



-- 26.Identify distribution centers responsible for delayed deliveries.

select 
	dc.name,
	round(avg(extract(EPOCH from (oi.delivered_at - oi.shipped_at)) / 86400),2) as avg_delivery_days
from order_items oi
join products p
on p.product_id = oi.product_id
join distribution_centers dc
	on dc.distribution_centers_id = p.distribution_center_id
where oi.status = 'Complete'
group by dc.name
order by avg_delivery_days desc




-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Marketing Analytics

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 27.Calculate conversion rates by traffic source: Events → Orders

with traffic_users as (
	Select distinct traffic_source, user_id from events
)
select 
	tu.traffic_source,
	count(distinct tu.user_id) as event_users,
	count(distinct o.user_id) as converted_users,
	round(count(distinct o.user_id)::Numeric *100 / count(distinct tu.user_id)::Numeric,2) conversion_rate
from traffic_users tu
left join orders o
on tu.user_id = o.user_id and o.status = 'Complete'
group by traffic_source
order by conversion_rate;


-- 28.Which browser generates the highest conversion rate?
 	-- Formula: distint user_id from orders / distinct user_id from events *100
	 
with cte as (
	select distinct browser, user_id from events 
)
select browser, count(distinct c.user_id)event_users, count(distinct o.user_id) converted_users,
	round(count(distinct o.user_id)::Numeric *100 / count(distinct c.user_id),2) conversion_rate
from cte c
left join orders o
on c.user_id = o.user_id and o.status = 'Complete'
group by browser
order by conversion_rate desc;



-- 29.Calculate average time between a customer's first website event and first purchase.


select distinct event_type from events;

with cte as (
	select user_id, min(new_created_at) as min_date from events  
	group by user_id
),
cte2 as (
	select user_id,  min(created_at) as min_date from orders
	where status='Complete'
	group by user_id	 
)
select
	round(avg(extract(EPOCH from (cte2.min_date - cte.min_date))::Numeric / 86400),2) avg_days_to_first_purchase from cte
join cte2
using(user_id);


-- 30. Which traffic source produces the shortest purchase journey? first event → first order

select * from events;

with cte as (
	select  user_id,traffic_source, new_created_at,
		row_number() over(partition by user_id order by new_created_at) as rn
	from events
),
cte2 as (
	select user_id, min(created_at) as first_order 
	from order_items
	where status = 'Complete'
	group by user_id
)
select 
	cte.traffic_source, 
	round(avg(extract(EPOCH from (first_order - new_created_at))::Numeric / 86400),2)  as avg_days
from cte 
join cte2 
using (user_id)
where rn = 1
group by cte.traffic_source
order by avg_days asc;



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Advanced Analytics

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 31. Top 5 customers within each state based on revenue generated.

with cte as (
	select u.state, oi.user_id, concat(u.first_name, ' ', u.last_name) as full_name , round(sum(oi.sale_price)::Numeric,2) as total_revenue 
	from order_items oi
	join users u
	on u.users_id = oi.user_id
	where oi.status = 'Complete'
	group by user_id, u.state,u.first_name, u.last_name
),
cte2 as (
	select *, row_number() over(partition by state order by total_revenue desc)  as rnk from cte
)
select * from cte2 where rnk <= 5;



-- 32. Find customers whose spending in the current month exceeds their previous month's spending by more than 50%.
-- Formula: Growth_percent:  Current_revenue - Previous_month_revenue)/ Previous_month_revenue * 100
-- Formula2:  Current_revenue > Previous_revenue * 1.5 (1.5 means 50%)

with cte as( 
	select date_trunc('month',oi.delivered_at) as month, oi.user_id, concat(u.first_name, ' ', u.last_name) as full_name , 
		round(sum(oi.sale_price)::Numeric,2) as total_revenue 
	from order_items oi 
	join users u 
		on u.users_id = oi.user_id where oi.status = 'Complete' 
	group by date_trunc('month',oi.delivered_at), user_id,u.first_name, u.last_name
), 
cte2 as( 
	select 
		month1.month as previous_month,
		month2.month as current_month, 
		month1.user_id, 
		month1.full_name, 
		month1.total_revenue as previous_revenue,
		month2.total_revenue as current_revenue 
	from cte month1 
	join cte month2
		on month1.user_id = month2.user_id and month2.month = month1.month + interval '1 month' 
)
select *, round((current_revenue - previous_revenue)*100 /previous_revenue,2) as growth_percent
from cte2
where current_revenue > previous_revenue * 1.5
order by growth_percent desc;


-- 33.Calculate rolling 30-day revenue.

with cte as(
	select 
		date(created_at) as order_date,
		sum(sale_price) as revenue
	from order_items
	where status = 'Complete'
	group by date(created_at)
)
select *, sum(revenue) over(order by order_date range between interval '29 days' preceding and current row) as rolling_30day_revenye
from cte;


-- 34.Calculate a 7-day moving average of orders.

with cte as(
	select 
		date(created_at) as order_date,
		count(distinct order_id) as total_orders
	from order_items
	where status = 'Complete'
	group by date(created_at)
)
select *, 
	round(avg(total_orders) over(order by order_date range between interval '6 days' preceding and current row),2) as "7_day_moving_avg_orders"
from cte;



-- 35.Find products whose sales have declined for 3 consecutive months.

with cte as(
	select date_trunc('month',created_at)::Date as date, product_id, sum(sale_price) total_revenue
	from order_items
	group by date_trunc('month',created_at)::Date, product_id
),
cte2 as (
	select *, 
	round(lag(total_revenue) over(partition by product_id order by date)::Numeric,2) as  "2_month_ago", -- using lag will show previous month sales
	round(lag(total_revenue,2) over(partition by product_id order by date)::Numeric,2) as "3_month_ago"  
	from cte
)
select * from cte2
where "3_month_ago" >"2_month_ago" and "2_month_ago" > total_revenue;



-- 36. Identify customers who upgraded from lower-priced products to higher-priced products over time.

with cte as(
	select user_id, product_id, created_at, sale_price,
		lag(sale_price) over(partition by user_id order by created_at) as previous_price
	from order_items
	where status = 'Complete'
)
Select distinct user_id, concat(first_name,' ',last_name) full_name from cte
join users
on cte.user_id = users.users_id
where sale_price > previous_price
order by user_id ;
	-- There are 6846 Customers who have upgraded from lower priced products to higher-priced products over time.



-- 37.Find the first product and latest product purchased by every customer.

with cte as (
	select oi.user_id, p.name, oi.product_id, oi.created_at,
		row_number() over(partition by oi.user_id order by oi.created_at asc) as first_product,
		row_number() over(partition by oi.user_id order by oi.created_at desc) as last_product
	from order_items oi
	left join products p
	on p.product_id = oi.product_id
	where oi.status = 'Complete'
)
select user_id, 
	min(case when first_product =1 then name end) as first_product,
	min(case when last_product =1 then name end) as last_product
from cte 
group by user_id
order by user_id;



-- 38.Calculate the percentage contribution of each category to total revenue within its department.
with cte as(
	select p.category, p.department, round(sum(oi.sale_price)::Numeric,2) revenue
	from order_items oi
	join products p
	on oi.product_id = p.product_id
	where oi.status = 'Complete'
	group by p.category, p.department
)
select *,
	sum(revenue) over(partition by department) as department_revenue,
	round(revenue::Numeric *100/ sum(revenue) over(partition by department),2) percent from cte
order by percent desc;
	-- Insight: Jeans in Men department have highest total_revenue percent


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

--	 END

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------





-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

--	 Queries to validate Power BI DAX function.

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- Stakeholder view cross check for all line graph
select date_trunc('month', created_at)::Date ,
	round(sum(case when status = 'Complete' then sale_price end)::Numeric ,2) as total_revenue,
	count(distinct case when status = 'Complete' then order_id end) as total_orders,
	count( case when status = 'Returned' then user_id end) as return_cnt,
	count(distinct case when status = 'Complete' then user_id end) as distinct_cust_cnt
 from order_items
group by date_trunc('month', created_at)


select date_trunc('month',created_at), sum(sale_price) from order_items
where status = 'Complete'
group by date_trunc('month',created_at)
order by sum(sale_price) desc;



select count(*) from order_items
where status = 'Complete'


select * from order_items limit 5
select * from products limit 5
select * from distribution_centers;

select date_trunc('month',created_at), count(order_items_id) from order_items
where status = 'Returned'
group by date_trunc('month',created_at)
order by sum(sale_price) desc;

select max(created_at) from order_items;



-- Deeper analysis on high number of return orders increase in MAY 2022.
select date_trunc('month',returned_at)::Date date, count(order_items_id) as cnt from order_items
where returned_at is not null
group by date_trunc('month',returned_at)::Date
order by date;


select p.category, count(oi.order_items_id) return_cnt as cnt 
from order_items oi
join products p
on oi.product_id = p.product_id
where returned_at is not null and date_trunc('month',oi.returned_at)::Date = '2022-05-01'
group by p.category
order by cnt desc;
	-- Intimates category has highest count return in MAY 2022 leading with Jeans and Tops&Tees category.



select distinct category from products;


-- total orders by department (power bi is showing equal and need to check this)
select department, count(order_items_id) from products p
join order_items oi
on p.product_id = oi.product_id
where oi.status = 'Complete'
group by department;



-- 
select distinct status from order_items;


-- 

select oi1.order_items_id, oi1.user_id, oi1.created_at, oi2.returned_at  from order_items oi1
join order_items oi2
on oi1.order_items_id = oi2.order_items_id and oi1.user_id = oi2.user_id

--
select count(*) from events;

select traffic_source, round(sum(sale_price)::Numeric,2) from order_items oi join events e on oi.user_id = e.user_id 
where status = 'Complete'
group by traffic_source
 order by round(sum(sale_price)::Numeric,2) desc ; 


 select distinct traffic_source from users; 


-- Found Null values in users.city column.
select count(case when city is null then 1 end) from users; -- 0 nulls

select * from users where city = 'null'; -- 962 Nulls

select user_id, u.country, u.city, e.city from users u
join events e
on e.user_id = u.users_id
where u.city = 'null'
	-- While creating dashboard i found out there are some cities with null values in it, try to fetch city details from the events table but still there was null
	-- So Updating value to "others" where "null" values are present.

Update users 
set city = 'Others' where city = 'null';
select * from users where city = 'Others'; -- 962 rows changed


-- Operations & Inventory Dashboard

select * from inventory_items
where sold_at is null -- Total unsold products 306949

select  inventory_items_id, product_id from inventory_items ;

select inventory_items_id, count(product_id) as cnt from inventory_items
group by inventory_items_id
order by cnt desc;

select count(*) from inventory_items; -- 487901
select count(distinct inventory_items_id) from inventory_items; -- 487901

-- 
select * from inventory_items;


-- creating custom column in inventory_items table where sold_at - created_at in days
select created_at, sold_at, sold_at ::date - created_at::date from inventory_items;

Alter table inventory_items add column days_took_to_sold Integer;
update  inventory_items set days_took_to_sold = sold_at ::date - created_at::date;

select product_name, avg(days_took_to_sold)  from inventory_items 
group by product_name order by avg(days_took_to_sold) desc;

select product_name from inventory_items where product_name = 'null';

select distinct product_department from inventory_items;


select dc.distribution_centers_id, ii.product_distribution_center_id from inventory_items ii
join distribution_centers dc
on dc.distribution_centers_id = ii.product_distribution_center_id
order by random() limit 10; -- checking whether both column has same id or not, so that i can create relation between these 2 tables in power bi.

select distinct status from order_items;


-- brands that sold in 2 days
select * from (select product_brand, avg(days_took_to_sold) avg_days from  inventory_items
group by product_brand
order by avg(days_took_to_sold) asc)
where avg_days <= 20;


-- avg shipping days 
select * from order_items;

select created_at, shipped_at, shipped_at::date - created_at::date,shipping_days  from order_items;

alter table order_items add column shipping_days integer;
update order_items set shipping_days = shipped_at::date - created_at::date;

select avg(shipping_days) from order_items
where shipped_at is not null and shipping_days >= 0;

-- Avg delivery time

select * from order_items where status = 'Complete';


select created_at, delivered_at, delivered_at::date - created_at::date, delivery_days  from order_items
where delivered_at is not null
order by delivery_days desc;

alter table order_items add column delivery_days integer;
update order_items set delivery_days = delivered_at::date - created_at::date;

select avg(delivery_days) from order_items
where  delivery_days >= 0;



select p.product_id, p.cost, ii.cost from inventory_items ii
join products p
on p.product_id = ii.product_id































