/* Project 2 - Superstore
--------------------------------------------------------------------------------------------------------------------------------------------
Business Problem Statement:
The Regional Sales Director would like to know which product segment and which customer segment are performing the best, and why? 

The Superstore data set was expanded from 51K to 1 million rows and as such the Orders Table does not yet have a key to identify unique 
records, all items on an order_id will be returned. The Returns Table does not include product or region identification numbers, the entire 
referenced order will be returned. The sales column represents gross sales for the corresponding row. The field product_cost_to_consumer is 
equivalent to COGS (Cost of Goods Sold) and is calculated as Net Sale(Sale - Profit).

Objective:
- Conduct an analysis to identify the best-performing product segment and make data-driven recommendations based on orders,
customers, product categories, and returns.
---------------------------------------------------------------------------------------------------------------------------------------------
Hypothesis: If we look at the TOP performing product segment and customer segment, we may find an outlier that has characteristics which 
indicate a top performing segment, but does not yield comparable profit that matches performance milestones.
---------------------------------------------------------------------------------------------------------------------------------------------

Product Segment Analysis -


/* Question: How many products were ordered, and when?*/
--Wanted amount of products used count to find quantity of product in orders

select order_date as "Order Date"
, count (quantity) as "Total Products Sold"
from orders 
group by 1
order by 1 desc
;

/*--Returns Results: 
"Furniture" 192943
"Technology"   196951
"Office Supplies" 610097


/*Question: What are the product categories, which product category had the highest quantity of orders?*/

select category as "Product Category"
,  count(o.order_id) as "Number of Orders"
from orders o
left join returns rt on rt.order_id = o.order_id
join products p on p.product_id = o.product_id
group by 1
order by 2
;


/*Returns Results: Products are broken down into Technology, Furniture, and Office Supplies, Office Supplies had the highest quantity of orders
1 "Technology" 196951
2 "Furniture" 192943
3 "Office Supplies" 610097 */


/* Question: What was the overall most ordered product category/sub-category based on orders?*/
--Concatenate statement created 'categories' by combining subcategory beside category for ease of comparison

select concat(category, ':', sub_category) as "Categories"
,  count(o.order_id) as "Number of Orders"
from orders o
left join returns rt on rt.order_id = o.order_id
join products p on p.product_id = o.product_id
group by 1
order by 2; 


/*Results:The most ordered category/sub-category "Office Supplies:Binders" 120953 ordered*/


/* Question:2020 saw the least products sold to-date, why is that?*/
--Answer- The superstore dataset only includes data from Q1 in 2020.

SELECT 
     EXTRACT(YEAR FROM order_date) as "Year"
   ,EXTRACT(QUARTER FROM order_date) as "Quarter"
   ,date_trunc('year', order_date) as "Date"
FROM orders
group by 1,2,3
order by 1 desc;

/* Question: What is the total amount of products sold per year? */

select 
     EXTRACT(YEAR FROM order_date) as "Year"
   ,date_trunc('year', order_date) as "Date"
    ,count (quantity) as "Total Products Sold"
from orders
group by 1,2
order by 1 desc;

/*Results: 
/*2020 "2020-01-01 00:00:00"   18777
2019  "2019-01-01 00:00:00"   539367
2018  "2018-01-01 00:00:00"   279486
2017  "2017-01-01 00:00:00"   125069
2016  "2016-01-01 00:00:00"   37278
2015  "2015-01-01 00:00:00"   14*/

--products sold per quarter 

select 
     EXTRACT(YEAR FROM order_date) as "Year"
   ,EXTRACT(QUARTER FROM order_date) as "Quarter"
   ,date_trunc('year', order_date) as "Date"
    ,count (quantity) as "Total Products Sold"
from orders
group by 1,2,3
order by 1 desc;


/* Question: What is the total amount of products sold per category by year? */

select EXTRACT(YEAR FROM order_date) as "Year", category as "Category"
   ,count (quantity) as "Total Products Sold"   
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;
      

--the following was calculated without taking returns into account --------------------------------------------------

/* Question: What is the total overall profit for each category?*/
--Approach: Using sum for both total sales and profit
select category as "Category"
, sum (sales) as "Sum of Sales"
, sum (profit) as "Sum of Profit"          
from orders o
join products p on p.product_id = o.product_id
group by 1;


/*Returns Results: "Furniture"      330401.63  Furniture sum of profit
   "Office Supplies" 621998.31  Office Supplies sum of profit
   "Technology"        706209.15  Technology sum of profit
   */

/* Question: In percent form, what is the total overall profit for each category?*/

select category as "Category"
, sum(o.profit) as "Product Profit",
 round (100*(sum(o.profit)/(select sum(o.profit) from orders o)),2) as "Percent Profit"
from orders o
inner join products p on p.product_id = o.product_id
group by 1
order by "Percent Profit" desc
;

/*Returns Results:
   "Technology"        42.58
   "Office Supplies"  37.50
   "Furniture"       19.92
   */

/* Question: What is the total profit for each category by year?*/

select EXTRACT(YEAR FROM order_date) as "Year", category as "Category"
, sum (profit) as "Total Profit" 
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;


/* Question: What percentage of profit does each category of products account for?*/

select EXTRACT(YEAR FROM order_date) as "Year", category as "Category"
, sum (profit) as "Total Profit" 
, round (100*(sum(o.profit)/(select sum(o.profit) from orders o)),2) as "Percent Profit"
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;

/* Question: How much profit does each subcategory of products account for?*/


select EXTRACT(YEAR FROM order_date) as "Year", concat(category, ':', sub_category) as "Categories"
, sum (profit) as "Total Profit" 
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;

/*Results/Findings:
2019  "Furniture:Tables"   -27880.80*/

/* Question: In percent form, what is the total profit for each subcategory?*/

select EXTRACT(YEAR FROM order_date) as "Year", concat(category, ':', sub_category) as "Categories"
, sum (profit) as "Total Profit" 
, round (100*(sum(o.profit)/(select sum(o.profit) from orders o)),2) as "Percent Profit"
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;

----------------
--Key Discovery:  Furnishings:Tables are displaying negative profit, to be investigated further, time permitting!
----------------

/* I need a glimpse into sales as well*/ 

/*Question: How much in sales did each product category generate per year?*/

select EXTRACT(YEAR FROM order_date) as "Year", category as "Category"
, sum (sales) as "Total Sales"
, sum (profit) as "Total Profit" 
, round (100*(sum(o.profit)/(select sum(o.profit) from orders o)),2) as "Percent Profit"
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;

/* Question: How much in sales did each product subcategory generate per year?*/

select EXTRACT(YEAR FROM order_date) as "Year", concat(category, ':', sub_category) as "Categories"
, sum (sales) as "Total Sales"
, sum (profit) as "Total Profit" 
, round (100*(sum(o.profit)/(select sum(o.profit) from orders o)),2) as "Percent Profit"
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;

/* Question: What were the total sales per year by quarter?*/
select
     EXTRACT(YEAR FROM order_date) as "Year"
   ,EXTRACT(QUARTER FROM order_date) as "Quarter"
   ,date_trunc('year', order_date) as "Date"
   , sum(sales) as "Total Sales"
from orders
group by 1,2,3
order by 1 desc;
 
 --/* Question: What is the profit margin for each category/subcategory by year?*/
select EXTRACT(YEAR FROM order_date) as "Year", concat(category, ':', sub_category) as "Categories"
, sum (profit) as "Total Profit" 
, sum (sales) as "Total Sales"
, round (sum(profit)/sum(sales),5) as "Profit Margin"
from orders o
join products p on p.product_id = o.product_id
group by 1,2
order by 1 desc;

/* The the top performing product segment overall appears to be Office Supplies. In 2020 office supply binders has the highest 
profit margin. Since 2020 data only covers Q1, in 2019 Office Supplies is again the highest grossing product category in profit 
less overhead expenses whereas the furniture segment found itself in the negative in overall profit and margin for tables in 2019. 
In 2018 Office Supplies again fared well overall with Labels and Paper bringing in the most profit*/
------------------------------------------------------------------------------------------------------------------------------------------

/*I wanted to look at returns, based on my knowledge of retail, I know that returns are generally either refunded to the customer, or 
written off by the company as shrink in which case it does not generally get considered in profit when calculations are performed */

--Question: What is the total number of returns for each product category based on orders?*/
/*Returns Results: Office Supplies had the highest returns
1 "Technology" 9603 returns   
2 "Furniture"  10611 returns
3 "Office Supplies"  31036 returns */

select category as "Category"
,  count(o.order_id) as "Total Orders"
,  count(rt.order_id) as "Total Returns"
from orders o
left join returns rt on rt.order_id = o.order_id
join products p on p.product_id = o.product_id
group by 1
order by 2,3 
;

--by subcategory

select category as "Category", concat(category, ':', sub_category) as "Categories"
,  count(o.order_id) as "Total Orders"
,  count(rt.order_id) as "Total Returns"
from orders o
left join returns rt on rt.order_id = o.order_id
join products p on p.product_id = o.product_id
group by 1,2
order by 2,3 
;

--Returns were made after a product was purchased, that needs to be considered in identifying the top performing product.
/*In considering returns after a sales was made, I assumed returns were refunded for the following analysis*/


/*Question: What is the the top performing product segment overall, or the highest profiting category and subcategory less returns?*/

 /*To factor in returns made when looking at sales and profit, I left joined table Orders with table Returns and excluded all 
 orders that have been returned to reflect real sales figures, assuming that returned orders might have been refunded.*/
select EXTRACT(YEAR FROM order_date) as "Year", concat(category, ':', sub_category) as "Categories"
, sum (profit) as "Total Profit" 
, sum (sales) as "Total Sales"
, round (sum(profit)/sum(sales),5) as "Profit Margin"
from orders o
join products p on p.product_id = o.product_id
left join returns rt on rt.order_id = o.order_id
where rt.reason_returned is null 
group by 1,2
order by 1 desc;


/*Justification: The superstore dataset only includes data from Q1 in 2020, so I expanded my analysis back into 2019 as numbers can be 
analyzed across a full 4 quarters this way. I joined products to get an idea of products sold yearly for each category, but that was not 
enough to determine the highest performing product segment. To get a better idea of performance, I want to know what amount of profit each 
product category is responsible for. If there was a return after an order, then no profit was made. That needs to be considered in 
identifying the top performing product.

Approach: To factor in product returns made when looking at sales and profit, I left joined table Orders with table Returns and excluded 
all orders that have been returned to reflect real sales figures, and assumed that returned orders might have been refunded. High gross 
profit margin indicates that a company is successfully meeting and exceeding its overhead. I will apply this notion to the product segment 
by saying, that the top performing product category/subcategory will have the highest profit margin. I then calculated Profit Margin as 
profit/sales. 

Findings: The top performing product segment overall is Office Supplies. In 2020 office supply binders has the highest profit margin. 
Since 2020 data only covers Q1, in 2019 Office Supplies is again the highest grossing product category. Office Supplies:Labels earned 
the most profit less overhead expenses in 2019 whereas the furniture segment still found itself in the negative in overall profit and 
margin for tables in 2019 after returns were considered. In 2018 Office Supplies fared well overall with Labels and Paper bringing in 
the most profit after returned product was factored in.
*/
-------------------------------------------------------------------------------------------------------------------------------------------
/* Objective:Conduct an analysis to identify the best-performing product segment and make data-driven recommendations based on orders,
customers, product categories, and returns.
---------------------------------------------------------------------------------------------------------------------------------------------
--Question -  Who are the customers, how much money did they spend, and how many of returns are they each responsible for?*/

select category as "Category",customer_name as "Customer Name", concat(category, ':', sub_category) as "Categories"
, product_name as "Products"
,  count(o.order_id) as "Total Orders"
,  count(rt.order_id) as "Total Returns"
from orders o
left join returns rt on rt.order_id = o.order_id
join products p on p.product_id = o.product_id
join customers c on c.customer_id = o.customer_id 
group by 1,2,3,4
order by 2,3 
;

--What customer spent the most money at superstore, and returned the least products? This person is our top customer. 
--What consumer segment did they belong to? This is out TOP Customer Segment
/*
"Technology" "Tamara Chand" "Technology:Copiers" "Corporate" 153   9043.78  1
"Technology"   "Raymond Buch" "Technology:Copiers" "Consumer"  51 7411.68  0 */
select category as "Category",customer_name as "Customer", concat(category, ':', sub_category) as "Categories"
, segment as "Customer Segment"
,  count(o.order_id) as "Total Orders"
, sum (profit) as "Total Spent"  
,  count(rt.order_id) as "Total Returns"
from orders o
left join returns rt on rt.order_id = o.order_id
join products p on p.product_id = o.product_id
join customers c on c.customer_id = o.customer_id 
group by 1,2,3,4
order by 6 desc
;

/*Justification:To identify the best-performing product segment, I again made another assumption. It is generally common knowledge that preferred, 
or TOP, customers are the ones who spend the most, and return the least at any company or establishment. That being said, I wanted to 
find out who the customers are, how much money they spent, and how many returns they are each responsible for. I joined customers to 
orders get a list of customers and used the CONCAT function to combine category and subcategory beside one another for ease of 
comparison, then I joined products to orders and pulled in products to drill down further to the specific item and view its 
performance among customers i.e. what customer spent the most money at superstore, returned the least products. 

Findings:Referring to the business inquiry from the Regional Director of Superstore, I need to identify the TOP performing Customer 
Segment. I left joined returns as I wanted to pull in returns and used COUNT to retrieve returns for each customer in the list. I joined customers 
since the table is only 3 columns, and I need two of them as I wanted to pull in customers and customer segment they each belong to. 
Tamara Chand from the Corporate Customer segment placed 153 orders and spent $9043.78, the most money in Superstore. While Tamara made 
only 1 return, I do not know the amount of that return. If the amount of the item returned by Tamara exceeds $2,000, then Raymond Buch 
of the Consumer segment would then be the TOP performing as he placed 51 orders and spent $7411.68 and made 0 returns.




