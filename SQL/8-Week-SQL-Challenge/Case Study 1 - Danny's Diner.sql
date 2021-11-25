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

-- 6. Which item was purchased first by the customer after they became a member?
WITH first AS(
  SELECT s.customer_id, s.product_id,
		row_number() over(partition by s.customer_id ORDER BY order_date)

FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date)

SELECT first.customer_id, m.product_name
FROM first 
JOIN dannys_diner.menu m
on first.product_id = m.product_id
WHERE first.row_number = 1
ORDER BY customer_id;

-- 7. Which item was purchased just before the customer became a member?

WITH first AS(
  SELECT s.customer_id, s.product_id, s.order_date,
		row_number() over(partition by s.customer_id ORDER BY order_date DESC)

FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date)

SELECT first.customer_id, m.product_name
FROM first 
JOIN dannys_diner.menu m
on first.product_id = m.product_id
WHERE first.row_number = 1
ORDER BY customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?

WITH first AS(
  SELECT s.*
		

FROM dannys_diner.sales s
FULL OUTER JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date
)
  
SELECT first.customer_id, count(first.product_id) as total_product_count, sum(m.price) as Total_spending
FROM first 
JOIN dannys_diner.menu m
on first.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH t as (
  SELECT s.customer_id, m.product_name, 
		count(s.product_id) as product_count,
		(CASE WHEN m.product_name = 'sushi' THEN 20
        ELSE 10
        END) as mul,
        m.price
FROM dannys_diner.sales s  
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name, m.price
ORDER BY customer_id)

SELECT customer_id, sum(product_count * mul * price)
FROM t
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH t as (
  SELECT s.customer_id, 
  		s.order_date,
  		m.product_name, 
		count(s.product_id) as product_count,
        mem.join_date,
        mem.join_date + interval '7' day as end_date_2x, 
        (CASE WHEN m.product_name = 'sushi' or s.order_date between mem.join_date and mem.join_date + interval '7' day THEN m.price*20
        ELSE m.price*10
        END) as points
FROM dannys_diner.sales s
JOIN dannys_diner.members mem
ON s.customer_id = mem.customer_id  
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, s.order_date, m.product_name, mem.join_date, m.price
ORDER BY customer_id)

SELECT customer_id, sum(product_count * points) 
FROM t
WHERE extract(month from order_date) = 1
GROUP BY customer_id


