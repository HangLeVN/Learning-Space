/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id, sum(price) As total_spending
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
On s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, count(order_date) As visited_days
FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT s.customer_id, MIN(s.product_id) AS FIRST_ITEM_ON_MENU
FROM dannys_diner.sales s
INNER JOIN (
SELECT customer_id, min(order_date)
  FROM dannys_diner.sales
  GROUP BY customer_id
  ) f
on s.customer_id = f.customer_id
GROUP BY s.customer_id;
 
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, count(s.product_id)
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
on s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY count(s.product_id) DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH CTE AS (
  SELECT customer_id,
		product_id,
        count(product_id) as count, 
        row_number() OVER (partition by customer_id ORDER BY count(product_id) DESC) as ranking
        
FROM dannys_diner.sales 
GROUP BY customer_id, product_id
ORDER BY customer_id, count DESC)

SELECT CTE.customer_id, CTE.product_id, m.product_name
FROM CTE  
JOIN dannys_diner.menu m
ON CTE.product_id = m.product_id
WHERE CTE.ranking = 1;
