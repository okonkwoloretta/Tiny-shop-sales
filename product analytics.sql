
-- creating table names

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

-- inserting details to the table

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

-- Case Study Questions

--1) Which product has the highest price? Only return a single row.

SELECT product_name AS product, price
FROM products
WHERE price = (SELECT MAX(price) AS highest_price
              FROM products)


--2) Which customer has made the most orders?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer, oi.quantity AS order_quantity
FROM customers c
JOIN orders  o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE quantity = (SELECT MAX(quantity)
                  FROM order_items)
GROUP BY CONCAT(c.first_name, ' ', c.last_name), oi.quantity

--3) What�s the total revenue per product?
SELECT product_name, SUM(price*quantity) AS revenue
FROM products p
JOIN order_items oi
ON oi.product_id = p.product_id
GROUP BY product_name 
ORDER BY revenue DESC

--4) Find the day with the highest revenue.
WITH CTE_rev AS(
SELECT SUM(price*quantity) AS revenue, order_date
FROM products p
JOIN order_items oi
  ON oi.product_id = p.product_id
JOIN orders o
  ON o.order_id = oi.order_id
GROUP BY order_date)

SELECT MAX(revenue) AS highest_rev, order_date
FROM CTE_rev
GROUP BY order_date
HAVING MAX(revenue) = (SELECT MAX(revenue)
					   FROM CTE_rev)

--5) Find the first order (by date) for each customer.

SELECT CONCAT(first_name, ' ', last_name) AS customer, order_date
FROM
  (
    SELECT first_name, last_name, order_date,
      ROW_NUMBER() OVER (PARTITION BY c.first_name, c.last_name ORDER BY order_date) AS row_num
    FROM
      orders o
    JOIN customers c
	  ON o.customer_id = c.customer_id
  ) AS t
WHERE row_num = 1
ORDER BY order_date

--6) Find the top 3 customers who have ordered the most distinct products

SELECT TOP(3) CONCAT(first_name, ' ', last_name) AS customer, quantity
FROM
  (
    SELECT c.first_name, c.last_name, COUNT(DISTINCT oi.product_id) AS quantity,
      ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT oi.product_id) DESC) AS row_num
    FROM order_items oi
    JOIN orders o 
	  ON o.order_id = oi.order_id
    JOIN customers c 
	  ON o.customer_id = c.customer_id
    GROUP BY c.first_name, c.last_name
  ) AS t
WHERE row_num <= 3
ORDER BY quantity DESC;


--7) Which product has been bought the least in terms of quantity?

SELECT product_name AS product, MIN(quantity) AS quantity
FROM order_items oi
JOIN products p
  ON oi.product_id = p.product_id
WHERE quantity  <= 1
GROUP BY product_name
ORDER BY quantity

--8) What is the median order total?
WITH CTE_order AS (
SELECT SUM(p.price * oi.quantity) AS order_total,
           ROW_NUMBER() OVER (ORDER BY SUM(p.price * oi.quantity)) AS row_num,
           COUNT(*) OVER () AS total_orders
FROM order_items oi
JOIN products p
  ON oi.product_id = p.product_id
GROUP BY oi.order_id
)
SELECT order_total AS median_order_total
FROM CTE_order
WHERE row_num = (total_orders + 1) / 2

--9) For each order, determine if it was �Expensive� (total over 300), �Affordable� (total over 100), or �Cheap�.
SELECT oi.order_id, SUM(p.price * oi.quantity) AS order_total,
  CASE
    WHEN SUM(p.price * oi.quantity) > 300 THEN 'Expensive'
    WHEN SUM(p.price * oi.quantity) > 100 THEN 'Affordable'
    ELSE 'Cheap'
  END AS order_category
FROM order_items oi
JOIN products p
   ON oi.product_id = p.product_id
GROUP BY oi.order_id

--10) Find customers who have ordered the product with the highest price.
WITH CTE_max_price AS (
    SELECT MAX(price) AS max_price
    FROM products
)
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer, p.product_name AS product, p.price
FROM customers c
JOIN orders o 
  ON c.customer_id = o.customer_id
JOIN order_items oi 
  ON o.order_id = oi.order_id
JOIN products p
  ON oi.product_id = p.product_id
CROSS JOIN CTE_max_price mp
WHERE p.price = mp.max_price


