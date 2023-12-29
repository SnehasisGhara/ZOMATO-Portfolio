USE Zomato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid int Primary Key,gold_signup_date date); 


INSERT INTO goldusers_signup (userid, gold_signup_date) 
VALUES 
(3, '2017-04-21'),
(1, '2017-09-22');



drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users (userid, signup_date)
VALUES
(1, '2014-09-02'),
(2, '2015-01-15'),
(3, '2014-04-11');


drop table if exists sales;                                         
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales (userid, created_date, product_id)
VALUES
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3);



drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product (product_id, product_name, price) 
VALUES
(1, 'p1', 980),
(2, 'p2', 870),
(3, 'p3', 330);





select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1. What is the total amount each customer spent on ZOMATO?
SELECT SUM(Price )
FROM product;

SELECT s.userid,sum(p.price) as total_amount_spent
FROM sales  s
INNER JOIN  product  p   ON s.product_id=p.product_id
GROUP BY s.userid;

-- 2. How many days each customer visited ZOMATO?
SELECT   userid ,COUNT( DISTINCT created_date)  days  FROM sales
GROUP BY userid;

-- 3. What was the First PRODUCT purches by each customer?

SELECT * FROM sales
INNER JOIN product;
SELECT  s.userid , p.product_name , p.price FROM product p 
INNER JOIN sales s 

LIMIT 1;

SELECT userid, MIN(purchase_date) AS first_purchase_date, FIRST_VALUE(product_id) OVER (PARTITION BY userid ORDER BY purchase_date) AS first_product_purchased
FROM sales
GROUP BY userid;
SELECT * FROM
(SELECT * ,rank() over (partition by userid order by created_date )rnk from sales) a where rnk=1;


-- 4. What is the most purchased item on the mwnu and how many times was it purchsed  by all customer ??
-- step 1:

SELECT  product_id  FROM sales
WHERE product_id = 2 
GROUP BY product_id
ORDER BY COUNT(product_id) DESC
LIMIT 1;

-- 2nd step 

SELECT * FROM sales WHERE product_id=(SELECT  product_id  FROM sales
WHERE product_id =2 
GROUP BY product_id
ORDER BY COUNT(product_id) DESC
);

-- step 3:
SELECT userid, COUNT(product_id) FROM sales WHERE product_id=(SELECT  product_id  FROM sales
WHERE product_id =2 
GROUP BY product_id
ORDER BY COUNT(product_id) DESC
)
GROUP BY userid
ORDER BY (userid)ASC;

-- 5 Which Item was the most popular for each Customer ??
                      -- step 1 :
 
SELECT userid,product_id,COUNT(product_id) cnt  FROM sales
GROUP BY userid,product_id;
                       -- step 2 :
SELECT *, RANK()  OVER( PARTITION BY  userid  ORDER BY cnt DESC) rnk FROM
(SELECT userid,product_id,COUNT(product_id) cnt  FROM sales
GROUP BY userid,product_id)a;



                       
                        -- step 3 :

SELECT * FROM
(SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk
FROM
    (SELECT
      userid,
      product_id,
      COUNT(product_id) AS cnt
    FROM
      sales
    GROUP BY
      userid,
      product_id) a) b
WHERE
  rnk = 1;


-- 6 Which item purchased first by the customer after they become a gold mamber ?

SELECT * FROM 
(SELECT a.*,RANK() OVER (partition by userid order by created_date) rnk FROM
(SELECT  s.userid,s.created_date,s.product_id,g.gold_signup_date FROM sales s INNER JOIN goldusers_signup g 
ON s.userid = g. userid and created_date > gold_signup_date)a)b WHERE rnk = 1;


-- 7 Which item was purchased just before the customer became a goldmember ??

SELECT * FROM 
(SELECT a.*,RANK() OVER (partition by userid order by created_date desc) rnk FROM
(SELECT  s.userid,s.created_date,s.product_id,g.gold_signup_date FROM sales s INNER JOIN goldusers_signup g 
ON s.userid = g. userid and created_date <= gold_signup_date)a)b WHERE rnk = 1;

-- 8 What is the total orders and amount spent for each member before  they become a member ?

SELECT userid, COUNT(created_date)   total_order , SUM(price)  total_amount  FROM 
(SELECT a.* , p.price FROM
(SELECT s.userid, s.created_date,s.product_id, g.gold_signup_date FROM sales s INNER JOIN goldusers_signup g 
ON s.userid = g.userid)a INNER JOIN product p 
ON a.product_id = p.product_id)b
GROUP BY userid; 













 



