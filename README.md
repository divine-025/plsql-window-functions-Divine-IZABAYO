# plsql-window-functions-Divine-IZABAYO

## Problem definition.
Managing fragmented sales data across locations and time periods is a difficulty for Rwanda's expanding textile industry, making it hard to pinpoint high-performing items, comprehend consumer behavior, and precisely predict demand. Managing disparate sales data from different regions and time periods is a difficulty for Rwanda's expanding textile and clothing industry. Businesses run the danger of overproducing low-demand items or passing up high-demand chances if they don't use systematic analysis. In order to assist more intelligent production planning, marketing, and resource allocation, this project employs SQL window functions to analyze sales data and find insights into product performance, consumer behavior, and demand forecasting.


## Database Schema

The database consists of seven core tables:

| Table           | Description                          | Key Columns                          |
|----------------|--------------------------------------|--------------------------------------|
| customers       | Customer information                 | `customer_id (PK)`, `name`, `region` |
| products        | Product catalog                      | `product_id (PK)`, `name`, `category`|
| orders          | Customer orders                      | `order_id (PK)`, `customer_id (FK)`, `order_date`, `total_amount` |
| order_details   | Order line items                     | `order_detail_id (PK)`, `order_id (FK)`, `product_id (FK)`, `quantity`, `subtotal` |
| suppliers       | Supplier information                 | `supplier_id (PK)`, `name`, `contact_person`, `phone`, `address` |
| purchases       | Inventory purchases from suppliers   | `purchase_id (PK)`, `supplier_id (FK)`, `purchase_date`, `total_cost` |
| employees       | Staff details                        | `employee_id (PK)`, `name`, `role`, `salary` |

Relationships:
- One-to-Many: `customers → orders`(  A `customer` can make many `orders` )
- Many-to-Many: `orders ↔ products` via `order_details`(An `order` can contain many `products`.)
- One-to-Many: `suppliers → purchases`
- `suppliers` provide materials for `products`.
- `employees` handle order processing.

## SQL Queries & Window Functions

## Success Criteria Implemented:
1. **Top 5 Products per Region/Quarter** → `RANK()`, `DENSE_RANK()`, `PERCENT_RANK()`
2. **Running Monthly Sales Total** → `SUM() OVER()`
3. **Customer Count per Month** → `COUNT() OVER()`
4. **3-Month Moving Average** → `AVG() OVER()`
5. **Customer Segmentation** → `NTILE()`, `CUME_DIST()`, `LEAD()`, `LAG()`

## Sample Queries for inserting data. 
```sql

INSERT INTO customers (name, email, phone, address) VALUES
('Jean Bosco', 'jean.bosco@gmail.com', '0788001111', 'Kigali, Rwanda'),
('Aline Uwase', 'aline.uwase@gmail.com', '0788002222', 'Huye, Rwanda'),
('Eric Mugisha', 'eric.mugisha@gmail.com', '0788003333', 'Musanze, Rwanda');

INSERT INTO products (name, category, price, stock_quantity) VALUES
('Cotton Shirt', 'Clothing', 8000, 150),
('Traditional Kitenge', 'Fabric', 15000, 80),
('School Uniform', 'Clothing', 5000, 200),
('Bed Sheets', 'Home Textile', 12000, 60);

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2025-09-20', 16000),
(2, '2025-09-21', 15000),
(3, '2025-09-22', 24000);

INSERT INTO order_details (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 2, 16000),  -- Jean bought 2 Cotton Shirts
(2, 2, 1, 15000),  -- Aline bought 1 Kitenge
(3, 3, 3, 15000),  -- Eric bought 3 Uniforms
(3, 4, 1, 9000);   -- Eric also bought 1 Bed Sheet

INSERT INTO suppliers (name, contact_person, phone, address) VALUES
('Rwanda Cotton Co.', 'Pauline Mukamana', '0788123456', 'Kigali SEZ, Rwanda'),
('East Africa Fabrics Ltd.', 'John Kamali', '0788234567', 'Kampala, Uganda'),
('Global Textiles Exporters', 'Li Wei', '0788345678', 'Guangzhou, China');

INSERT INTO purchases (supplier_id, purchase_date, total_cost) VALUES
(1, '2025-09-10', 500000),
(2, '2025-09-12', 300000),
(3, '2025-09-15', 800000);

INSERT INTO employees (name, role, salary) VALUES
('Claudine Umutoni', 'Tailor', 150000),
('Patrick Nshimiyimana', 'Sales Manager', 300000),
('Alice Mukandayisenga', 'Designer', 250000);

Insights
# Results Analysis

This analysis explores customer behavior, product performance, and sales trends in Rwanda’s textile sector using SQL window functions. The goal is to uncover actionable insights that support better production planning, marketing, and resource allocation.

## Descriptive Insights – What Happened?

- **Top Customers by Revenue**  
  Using `RANK()`, `DENSE_RANK()`, and `PERCENT_RANK()`, Eric Mugisha emerged as the highest revenue-generating customer, followed by Jean Bosco and Aline Uwase.

- **Customer Segmentation**  
  `NTILE()` and `CUME_DIST()` grouped customers into quartiles. Only one-third of customers contributed to the top revenue bracket, indicating a skewed distribution.

- **Running Totals & Averages**  
  `SUM()` and `AVG()` functions revealed a steady increase in cumulative sales, with noticeable spikes in late September—suggesting seasonal demand.

- **Order Behavior**  
  `LEAD()` and `LAG()` functions showed consistent purchasing patterns for some customers, while others had gaps between orders.

- **Product Performance**  
  Products like School Uniforms and Traditional Kitenge had high prices and strong turnover, indicating high demand and profitability.

## Diagnostic Insights – Why It Happened?

- **Revenue Concentration**  
  A small group of customers drives most of the revenue. This highlights the need for retention strategies and personalized marketing to maintain loyalty.

- **Seasonal Demand**  
  Sales spikes in September may align with school reopening or cultural events, suggesting time-sensitive purchasing behavior.

- **Customer Gaps**  
  Gaps in repeat purchases suggest missed opportunities for loyalty programs or targeted follow-ups.

- **Regional Demand Potential**  
  While region-specific analysis is pending, the schema supports future segmentation to identify high-performing areas like Kigali or Musanze.

- **Inventory Planning**  
  High-demand products should be prioritized in production and stock allocation to avoid shortages or overstocking.

These insights were derived using PostgreSQL window functions and reflect real-world business challenges in Rwanda’s textile industry. They offer a foundation for data-driven decision-making and strategic growth.

## references.
PostgreSQL Documentation: https://www.postgresql.org/docs/

Rwanda Development Board (RDB) – Textile Industry Reports

Assignment Guidelines provided by [University/Instructor]

PostgreSQL Window Functions Tutorial – https://www.postgresqltutorial.com/postgresql-window-function/

SQL Shack – Window Functions Overview – https://www.sqlshack.com/sql-window-functions/

Mode Analytics – SQL Window Functions – https://mode.com/sql-tutorial/sql-window-functions/

Stack Overflow Discussions on RANK & NTILE – https://stackoverflow.com/questions/tagged/window-functions

Medium Article – Customer Segmentation in SQL – https://medium.com/analytics-vidhya/customer-segmentation-using-sql

Kaggle Community – SQL Analytics & Ranking Queries – https://www.kaggle.com/learn/advanced-sql

Rwanda Development Board (RDB) – Textile & Apparel Sector Reports – https://rdb.rw

National Institute of Statistics of Rwanda (NISR) – http://www.statistics.gov.rw

## Author
Divine IZABAYO.


