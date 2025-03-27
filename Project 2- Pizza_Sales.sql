-- BASIC
-- Ques 1 Retrieve the total number of orders placed.

Select Count(order_ID) from order_details;

-- Ques 2 Calculate the total revenue generated from pizza sales

Select SUM(p.price*od.quantity) as Revenue_Generated 
from order_details od
join pizzas p on od.pizza_id=p.pizza_id;


select sum(price) from orders o inner join order_details od on o.order_id=od.order_id inner join pizzas p on p.pizza_id=od.pizza_id

-- Ques 3 Identify the highest-priced pizza.

Select pt.name, MAx(p.price) as Highest_Price from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by Highest_price Desc Limit 1;

-- Ques 4 Identify the most common pizza size ordered.

Select SUM(od.quantity) as Total_Quanity ,pt.name from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on od.pizza_id=p.pizza_id
group by pt.name
order by Total_Quanity Desc Limit 1;

-- Ques 5 List the top 5 most ordered pizza types along with their quantities.

Select SUM(od.quantity) as Total_Quanity ,pt.name from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on od.pizza_id=p.pizza_id
group by pt.name
order by Total_Quanity Desc Limit 5;


-- INTERMEDIATE
-- Ques 1 Join the necessary tables to find the total quantity of each pizza category ordered.

Select SUM(od.quantity) as Total_Quanity ,pt.category from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on od.pizza_id=p.pizza_id
group by pt.category
order by Total_Quanity Desc;

-- Ques 2 Determine the distribution of orders by hour of the day.

select count(*) as OrderNums, HOUR(orders.time) from orders
group by HOUR(orders.time)
order by OrderNums;

-- Ques 3 Join relevant tables to find the category-wise distribution of pizzas.

select category, count(*) from pizza_types group by category;

-- Ques 4 Group the orders by date and calculate the average number of pizzas ordered per day.

Select Order_Date, AVG(quantity) as AVGOrders from
(Select o.date as Order_Date, SUM(od.quantity) as Quantity
from 
order_details od join
orders o
on od.order_id=o.order_id
group by Order_Date) as Temp
group by Order_Date
order by AVGOrders Desc;

-- Ques 5 Determine the top 3 most ordered pizza types based on revenue.

Select pt.name, Round(SUM(od.quantity*p.price),0) as Revenue
from pizza_types pt
join 
pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.name
order by Revenue Desc limit 3;


-- ADVANCE

-- Ques 1 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    (sum(order_details.quantity * pizzas.price)/(select sum(price) from orders o inner join order_details od on o.order_id=od.order_id inner join pizzas p on p.pizza_id=od.pizza_id) ) *100 as revenuepizzas
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id group by pizza_types.category
ORDER BY revenuepizzas DESC;

-- Ques 2 Analyze the cumulative revenue generated over time.

select sales.date,sum(revenue) over (order by sales.date) as cum_revenue 
from (select orders.date,sum(order_details.quantity*pizzas.price) as revenue from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id=order_details.order_id group by orders.date)as sales;

-- Ques 3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

-- Using CTE

With PizzaRevenue as(
Select 
pt.pizza_type_id,
pt.name,
SUM(p.price*od.quantity) as Revenue,
Rank() over (partition by Pt.category order by SUM(p.price*od.quantity) Desc) rankR
from pizza_types pt 
join
pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on p.pizza_id=od.pizza_id
group by pt.category,pt.name,pt.pizza_type_id
)

select pizza_type_id,name,Revenue from Pizzarevenue
where rankR<=3;


-- Usng Subquery

Select temp.category,Temp.Pizza_type_ID,temp.name,temp.Revenue from (
Select pt.name,pt.pizza_type_id,pt.category,SUM(od.quantity*p.price) as Revenue, 
Rank() over(partition by pt.category order by SUM(od.quantity*p.price) desc) as RR 
from order_details od join pizzas p
on od.pizza_id=p.pizza_id join pizza_types pt on p.pizza_type_id=pt.pizza_type_id group by pt.pizza_type_id,pt.category,pt.name) as Temp
where RR<=3
order by temp.category;


