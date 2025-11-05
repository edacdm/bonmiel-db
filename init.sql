-- ==========================================
-- BonMiel Veritabanı - init.sql
-- Tabloların oluşturulması
-- ==========================================

-- 1. Units (Birimler)
CREATE TABLE units (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- 2. Categories (Kategori)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 3. Products (Ürünler)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES categories(id),
    unit_id INT REFERENCES units(id)
);

-- 4. Product Variants (Ürün varyantları)
CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    sku VARCHAR(50),
    description TEXT
);

-- 5. Suppliers (Tedarikçiler)
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

-- 6. Customers (Müşteriler)
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

-- 7. Warehouses (Depolar)
CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location TEXT
);

-- 8. Purchase Receipts (Satın alma fişleri)
CREATE TABLE purchase_receipts (
    id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(id),
    receipt_date DATE NOT NULL
);

-- 9. Purchase Receipt Lines (Satın alma fiş kalemleri)
CREATE TABLE purchase_receipt_lines (
    id SERIAL PRIMARY KEY,
    receipt_id INT REFERENCES purchase_receipts(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2) NOT NULL,
    unit_price NUMERIC(10,2)
);

-- 10. Recipes (Tarifler)
CREATE TABLE recipes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    product_id INT REFERENCES products(id)
);

-- 11. Recipe Items (Tarif kalemleri)
CREATE TABLE recipe_items (
    id SERIAL PRIMARY KEY,
    recipe_id INT REFERENCES recipes(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2)
);

-- 12. Production Orders (Üretim siparişleri)
CREATE TABLE production_orders (
    id SERIAL PRIMARY KEY,
    recipe_id INT REFERENCES recipes(id),
    quantity NUMERIC(10,2),
    order_date DATE NOT NULL
);

-- 13. Production Outputs (Üretim çıktıları)
CREATE TABLE production_outputs (
    id SERIAL PRIMARY KEY,
    production_order_id INT REFERENCES production_orders(id),
    quantity NUMERIC(10,2),
    output_date DATE
);

-- 14. Production Consumptions (Üretim tüketimleri)
CREATE TABLE production_consumptions (
    id SERIAL PRIMARY KEY,
    production_order_id INT REFERENCES production_orders(id),
    product_id INT REFERENCES products(id),
    quantity NUMERIC(10,2)
);

-- 15. Stock Movements (Stok hareketleri)
CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    warehouse_id INT REFERENCES warehouses(id),
    movement_type VARCHAR(20), -- 'in' veya 'out'
    quantity NUMERIC(10,2),
    movement_date DATE
);

-- 16. Users (Kullanıcılar)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT REFERENCES departments(id)
);

-- 17. Departments (Departmanlar)
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 18. Approval Flows (Onay akışları)
CREATE TABLE approval_flows (
    id SERIAL PRIMARY KEY,
    department_id INT REFERENCES departments(id),
    step_order INT,
    role VARCHAR(100)
);

-- 19. Approvals (Onaylar)
CREATE TABLE approvals (
    id SERIAL PRIMARY KEY,
    flow_id INT REFERENCES approval_flows(id),
    user_id INT REFERENCES users(id),
    approved BOOLEAN,
    approved_at TIMESTAMP
);

-- 20. Sales Orders (Satış siparişleri)
CREATE TABLE sales_orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    order_date DATE NOT NULL
);

-- 21. Sales Order Lines (Satış sipariş kalemleri)
CREATE TABLE sa

