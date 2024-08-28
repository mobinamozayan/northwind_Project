
-- Q1 چند سفارش در مجموع ثبت شدهاست؟

SELECT COUNT(*) AS TotalOrders
FROM Orders;


-- Q2  درآمد حاصل از این سفارشها چقدر بوده است؟
select sum(price * quantity) as result_income
from ORDERS o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN PRODUCTS p ON od.ProductID = p.ProductID


-- Q3 5مشتری برتر را بر اساس مقداری که خرج کردهاند پیدا کنید
with customer_spending as ( 
    select customerID, CustomerName, amount_spent, 
	row_number() over(partition by CustomerID order by amount_spent desc) rn 
	from(
		select c.CustomerID, c.CustomerName,sum(price * quantity) amount_spent 
		from CUSTOMERS c
        JOIN Orders o ON c.CustomerID = o.CustomerID
        JOIN OrderDetails od ON o.OrderID = od.OrderID  
        JOIN PRODUCTS p ON od.ProductID = p.ProductID
        GROUP BY c.CustomerID, c.CustomerName
	)
)
select * from customer_spending
WHERE rn <= 5


-- Q4 میانگین هزینه ی سفارشات هر مشتری را به همراه id و نام او گزارش کنید
With my_table as  
( 
      SELECT c.CustomerID, c.CustomerName, o.OrderID, p.price, od.quantity 
      FROM CUSTOMERS c 
      JOIN Orders o ON c.CustomerID = o.CustomerID 
      JOIN OrderDetails od ON o.OrderID = od.OrderID 
      JOIN PRODUCTS P ON od.ProductID = P.PRODUCTID 
) ,
customer_averages as 
( 
    SELECT CustomerID, CustomerName, AVG(price * quantity) AS avg_order_cost 
    FROM my_table  
    GROUP BY CustomerID, CustomerName 
) 
SELECT * FROM customer_averages

-- secound methood  Q4 میانگین هزینه ی سفارشات هر مشتری را به همراه id و نام او گزارش کنید
SELECT c.CustomerID, c.CustomerName, AVG(price * quantity) as avg_order_cost
      FROM CUSTOMERS c
      JOIN Orders o ON c.CustomerID = o.CustomerID
      JOIN OrderDetails od ON o.OrderID = od.OrderID
      JOIN PRODUCTS P ON od.ProductID = P.PRODUCTID
          GROUP BY c.CUSTOMERID, CustomerName
          order by avg_order_cost desc


-- Q5 مشتری ان را بر اساس مقدار کل هزینهی سفارشات رتبهبندی کنید، اما فقط مشتریان ی را در نظر بگیرید که بیشتر از 5 سفارش.دادهاند
SELECT
    c.CUSTOMERID,
    c.customername,
    od.QUANTITY,
    SUM(quantity * price) AS sum_cost,
    RANK() OVER (ORDER BY SUM(quantity * price) DESC) AS customer_rank
FROM
    customers c
JOIN
    Orders o ON c.CustomerID = o.CustomerID
JOIN
    OrderDetails od ON o.OrderID = od.OrderID
JOIN
    PRODUCTS P ON od.ProductID = P.PRODUCTID
GROUP BY
    c.CUSTOMERID, c.customername,od.QUANTITY
HAVING
    SUM(quantity) > 5
ORDER BY
    sum_cost DESC;
    
 
 
-- Q6 کدام محصول در کل سفارشات ثبت شده بیشترین درآمد را ایجاد کرده است؟

WITH my_table AS (
    SELECT 
        p.PRODUCTID,
        p.PRODUCTNAME,
        quantity,
        SUM(price * quantity) AS income,
        ROW_NUMBER() OVER (ORDER BY SUM(price * quantity) DESC) AS rn
    FROM 
        PRODUCTS p
    JOIN 
        OrderDetails od ON p.ProductID = od.ProductID
    JOIN 
        Orders o ON od.OrderID = o.OrderID
    GROUP BY  
        p.PRODUCTID, p.PRODUCTNAME,quantity
)
SELECT * 
FROM my_table
WHERE rn = 1;


-- Q7 هر دسته چند محصول دارد؟
SELECT c.CategoryName, COUNT(*)  count_product
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
order by count_product desc


-- Q8 محصول پرفروش در هر دسته بر اساس درآمد را تعیین کنید

select categoryname,productname,sum(quantity * price) as income
from products p
join categories c on p.CATEGORYID = c.CATEGORYID
join orderdetails o on p.PRODUCTID = o.PRODUCTID
group by categoryname,productname
order by income desc


-- Q9 5. کارمند برتر که بااالترین درآمد را ایجاد کردند به همراه ID و نام + ‘ ‘ + نام خانوادگی
WITH my_table AS (
    SELECT 
        e.EMPLOYEEID,
        firstname,
        lastname,
        
        SUM(price * quantity) AS income,
        ROW_NUMBER() OVER (ORDER BY SUM(price * quantity) DESC) AS rn
    FROM 
        employees e
    JOIN 
        orders p ON e.EMPLOYEEID = p.EMPLOYEEID
    JOIN
        orderdetails od on p.ORDERID = od.ORDERID
    JOIN 
        products p on od.PRODUCTID = p.PRODUCTID
    
    GROUP BY  
        e.EMPLOYEEID,firstname,lastname
)
SELECT * 
FROM my_table
WHERE rn <= 5;


-- Q10 میانگین درآمد هر کارمند به ازای هر سفارش چقدر بودهاست؟

 SELECT e.employeeid, od.orderid, AVG (quantity * price) AS avg_income
    FROM employees e
         JOIN orders p ON e.EMPLOYEEID = p.EMPLOYEEID
         JOIN orderdetails od ON p.ORDERID = od.ORDERID
         JOIN products p ON od.PRODUCTID = p.PRODUCTID
GROUP BY e.employeeid, od.orderid
ORDER BY avg_income desc



-- Q11 کدام کشور بیشترین تعداد سفارشات را ثبت کرده است؟
WITH my_table AS (
    SELECT 
        country,
        quantity,
        ROW_NUMBER() OVER (ORDER BY quantity DESC) AS rn
    FROM 
        customers c
    JOIN 
        orders o ON c.CUSTOMERID = o.CUSTOMERID
    JOIN
        orderdetails od on o.ORDERID = od.ORDERID
    
    GROUP BY  
       country,quantity
        
)
SELECT * 
FROM my_table
WHERE rn = 1;



-- Q12 مجموع درآمد از سفارشات هر کشور چقدر بوده؟

select o.orderid,country,sum(quantity * price) as sum_income
from customers c
join orders o on c.CUSTOMERID = o.CUSTOMERID
join orderdetails od on o.ORDERID = od.ORDERID
join products p on od.PRODUCTID = p.PRODUCTID
group by o.orderid,country
order by sum_income desc


-- Q13 میانگین قیمت هر دسته چقدر است؟
select c.categoryid,categoryname,avg(price) as avg_price
from categories c
join products p on c.CATEGORYID = p.CATEGORYID
group by c.categoryid,categoryname
order by avg_price desc


-- Q14 گران ترین دسته بندی کدام است؟

WITH my_table AS (
    SELECT 
        c.categoryid,
        categoryname,
        avg(price) as avg_price,
        ROW_NUMBER() OVER (ORDER BY avg(price) DESC) AS rn
    FROM 
        categories c
    JOIN
        products p on c.CATEGORYID = p.CATEGORYID
    
    GROUP BY  
       c.categoryid,categoryname
        
)
SELECT * 
FROM my_table
WHERE rn = 1;


-- Q15 طی سال 6991 هر ماه چند سفارش ثبت شده است؟
SELECT TO_CHAR(orderdate, 'MM') as month,quantity
FROM orders o
JOIN orderdetails od ON o.ORDERID = od.ORDERID
WHERE TO_CHAR(orderdate, 'YYYY') = '1996'
GROUP BY TO_CHAR(orderdate, 'MM'),quantity
ORDER BY TO_CHAR(orderdate, 'MM')


-- Q16 میانگین فاصله ی زمانی بین سفارشات هر مشتری چقدر بوده؟

SELECT 
    customerid, 
    customername, 
    AVG(avg_time) AS avg_time
FROM 
    (SELECT 
         c.customerid, 
         customername, 
         orderdate - LAG(orderdate) OVER (PARTITION BY c.customerid ORDER BY orderdate desc) AS avg_time 
     FROM 
         orders o 
     JOIN  
         customers c ON o.CUSTOMERID = c.CUSTOMERID)
GROUP BY 
    customerid, customername;
    
    
-- Q17 در هر فصل جمع سفارشات چقدر بودهاست؟ )اینجا براساس ماه نوشتم
-- month
SELECT 
     
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(quantity) AS total_amount
FROM 
    orders o
    join orderdetails od on o.ORDERID = od.ORDERID
GROUP BY 
     TO_CHAR(o.orderdate, 'YYYY-MM')
     order by month desc
     
     
 -- Q17 براساس فصل    
-- season 
 
SELECT 
    TO_CHAR(o.orderdate, 'YYYY-Q') AS quarter,
    SUM(od.quantity) AS total_amount
FROM 
    orders o
JOIN 
    orderdetails od ON o.ORDERID = od.ORDERID
GROUP BY 
    TO_CHAR(o.orderdate, 'YYYY-Q')
ORDER BY 
    quarter DESC;
    
    
-- Q18 کدام تامین کننده بیشترین تعداد کاال را تامین کرده است؟
SELECT 
    supplierid, 
    suppliername,
    total_quantity
FROM (
    SELECT 
        s.supplierid, 
        s.suppliername,
        SUM(od.quantity) AS total_quantity,
        row_number() OVER (ORDER BY SUM(od.quantity) DESC) AS rn
    FROM 
        orderdetails od
    JOIN 
        products p ON od.productid = p.productid
    JOIN 
        suppliers s ON p.supplierid = s.supplierid
    GROUP BY 
        s.supplierid, s.suppliername
)
WHERE 
    rn = 1;
    
    
-- Q19 میانگین قیمت کاالی تامین شده توسط هر تامیکننده چقدر بوده
SELECT 
    s.SUPPLIERID, 
    suppliername,
    AVG(price) AS average_price
FROM 
    products p
JOIN 
    suppliers s ON p.SUPPLIERID = s.SUPPLIERID

GROUP BY 
    s.SUPPLIERID, suppliername
    order by average_price desc

