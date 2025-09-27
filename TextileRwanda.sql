-- STEP 3: In this step I will be creating schema for Textile Industry in Rwanda
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT
);
--product table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

-- Orders table: it will track orders from customers
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(12,2) NOT NULL
);

-- Order Details table: Links orders to products (many-to-many)
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal NUMERIC(12,2) NOT NULL
);

-- Suppliers table: Textile suppliers (local or international)
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    address TEXT
);

-- Purchases table: Records materials purchased from suppliers
CREATE TABLE purchases (
    purchase_id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_cost NUMERIC(12,2) NOT NULL
);

-- Employees table: Workers in the textile company
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    salary NUMERIC(12,2) CHECK (salary >= 0)
);

-- Insert Customers
INSERT INTO customers (name, email, phone, address) VALUES
('Jean Bosco', 'jean.bosco@gmail.com', '0788001111', 'Kigali, Rwanda'),
('Aline Uwase', 'aline.uwase@gmail.com', '0788002222', 'Huye, Rwanda'),
('Eric Mugisha', 'eric.mugisha@gmail.com', '0788003333', 'Musanze, Rwanda');

-- Insert Products
INSERT INTO products (name, category, price, stock_quantity) VALUES
('Cotton Shirt', 'Clothing', 8000, 150),
('Traditional Kitenge', 'Fabric', 15000, 80),
('School Uniform', 'Clothing', 5000, 200),
('Bed Sheets', 'Home Textile', 12000, 60);

-- Insert Orders
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2025-09-20', 16000),
(2, '2025-09-21', 15000),
(3, '2025-09-22', 24000);

-- Insert Order Details
INSERT INTO order_details (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 2, 16000),  -- Jean bought 2 Cotton Shirts
(2, 2, 1, 15000),  -- Aline bought 1 Kitenge
(3, 3, 3, 15000),  -- Eric bought 3 Uniforms
(3, 4, 1, 9000);   -- Eric also bought 1 Bed Sheet

-- Insert Suppliers
INSERT INTO suppliers (name, contact_person, phone, address) VALUES
('Rwanda Cotton Co.', 'Pauline Mukamana', '0788123456', 'Kigali SEZ, Rwanda'),
('East Africa Fabrics Ltd.', 'John Kamali', '0788234567', 'Kampala, Uganda'),
('Global Textiles Exporters', 'Li Wei', '0788345678', 'Guangzhou, China');

-- Insert Purchases
INSERT INTO purchases (supplier_id, purchase_date, total_cost) VALUES
(1, '2025-09-10', 500000),
(2, '2025-09-12', 300000),
(3, '2025-09-15', 800000);

-- Insert Employees
INSERT INTO employees (name, role, salary) VALUES
('Claudine Umutoni', 'Tailor', 150000),
('Patrick Nshimiyimana', 'Sales Manager', 300000),
('Alice Mukandayisenga', 'Designer', 250000);

-- Top customers by total revenue
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.name AS customer_name,
        SUM(od.subtotal) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.name
)
SELECT
    customer_name,
    total_revenue,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS row_num,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank_val,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS dense_rank,
    PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS percent_rank
FROM customer_revenue
ORDER BY total_revenue DESC;


-- Running totals, averages, min, max per customer by order date

WITH customer_order_totals AS (
    SELECT
        c.customer_id,
        c.name AS customer_name,
        o.order_date,
        SUM(od.subtotal) AS order_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.name, o.order_date
)
SELECT
    customer_name,
    order_date,
    order_total,
    SUM(order_total) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(order_total) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg,
    MIN(order_total) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_min,
    MAX(order_total) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_max
FROM customer_order_totals
ORDER BY customer_name, order_date;

-- Compare revenue with previous and next orders

WITH customer_order_totals AS (
    SELECT
        c.customer_id,
        c.name AS customer_name,
        o.order_date,
        SUM(od.subtotal) AS order_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.name, o.order_date
)
SELECT
    customer_name,
    order_date,
    order_total,
    LAG(order_total) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_total,
    LEAD(order_total) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_total,
    ROUND(
        (order_total - LAG(order_total) OVER (PARTITION BY customer_id ORDER BY order_date))::numeric
        / NULLIF(LAG(order_total) OVER (PARTITION BY customer_id ORDER BY order_date),0) * 100, 2
    ) AS growth_percent
FROM customer_order_totals
ORDER BY customer_name, order_date;

-- Segment customers into quartiles based on total revenue

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.name AS customer_name,
        SUM(od.subtotal) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.name
)
SELECT
    customer_name,
    total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS quartile,
    CUME_DIST() OVER (ORDER BY total_revenue DESC) AS cumulative_dist
FROM customer_revenue
ORDER BY total_revenue DESC;
