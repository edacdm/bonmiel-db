-- ==========================================
-- BonMiel Veritabanı - init.sql
-- Tüm tablolar CREATE komutları
-- ==========================================

CREATE TABLE units (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES categories(id),
    unit_id INT REFERENCES units(id)
);

CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    sku VARCHAR(50),
    description TEXT
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location TEXT
);

CREATE TABLE purchase_receipts (
    id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(id),
    receipt_date DATE NOT NULL
);

CREATE TABLE purchase_receipt_lines (
    id SERIAL PRIMARY KEY,
    receipt_id INT REFERENCES purchase_receipts(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2) NOT NULL,
    unit_price NUMERIC(10,2)
);

CREATE TABLE recipes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    product_id INT REFERENCES products(id)
);

CREATE TABLE recipe_items (
    id SERIAL PRIMARY KEY,
    recipe_id INT REFERENCES recipes(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2)
);

CREATE TABLE production_orders (
    id SERIAL PRIMARY KEY,
    recipe_id INT REFERENCES recipes(id),
    quantity NUMERIC(10,2),
    order_date DATE NOT NULL
);

CREATE TABLE production_outputs (
    id SERIAL PRIMARY KEY,
    production_order_id INT REFERENCES production_orders(id),
    quantity NUMERIC(10,2),
    output_date DATE
);

CREATE TABLE production_consumptions (
    id SERIAL PRIMARY KEY,
    production_order_id INT REFERENCES production_orders(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2)
);

CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    warehouse_id INT REFERENCES warehouses(id),
    movement_type VARCHAR(20),
    quantity NUMERIC(10,2),
    movement_date DATE
);

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT REFERENCES departments(id)
);

CREATE TABLE approval_flows (
    id SERIAL PRIMARY KEY,
    department_id INT REFERENCES departments(id),
    step_order INT,
    role VARCHAR(100)
);

CREATE TABLE approvals (
    id SERIAL PRIMARY KEY,
    flow_id INT REFERENCES approval_flows(id),
    user_id INT REFERENCES users(id),
    approved BOOLEAN,
    approved_at TIMESTAMP
);

CREATE TABLE sales_orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    order_date DATE NOT NULL
);

CREATE TABLE sales_order_lines (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sales_orders(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2)
);

CREATE TABLE lots (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    lot_number VARCHAR(50),
    expiration_date DATE
);
