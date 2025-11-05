-- 02_schema.sql
SET TIME ZONE 'Europe/Istanbul';

CREATE TABLE departments (
  department_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  department_id INT REFERENCES departments(department_id),
  full_name TEXT NOT NULL,
  email TEXT UNIQUE,
  role TEXT CHECK (role IN ('admin','planner','quality','warehouse','finance','rd','sales')) NOT NULL
);

CREATE TABLE units (
  uom_id SERIAL PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  base_uom_id INT REFERENCES units(uom_id),
  ratio NUMERIC(18,6),
  CHECK (
    (base_uom_id IS NULL AND ratio IS NULL) OR
    (base_uom_id IS NOT NULL AND ratio > 0)
  )
);

CREATE TABLE categories (
  category_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  category_id INT NOT NULL REFERENCES categories(category_id),
  name TEXT NOT NULL,
  code TEXT UNIQUE,
  is_raw_material BOOLEAN NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE product_variants (
  product_variant_id SERIAL PRIMARY KEY,
  product_id INT NOT NULL REFERENCES products(product_id),
  packaging_type TEXT,
  net_content_value NUMERIC(18,3),
  net_content_uom_id INT REFERENCES units(uom_id),
  UNIQUE(product_id, packaging_type, net_content_value, net_content_uom_id)
);

CREATE TABLE warehouses (
  warehouse_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE lots (
  lot_id SERIAL PRIMARY KEY,
  product_id INT NOT NULL REFERENCES products(product_id),
  lot_code TEXT NOT NULL,
  mfg_date DATE,
  exp_date DATE,
  UNIQUE(product_id, lot_code)
);

CREATE TABLE stock_movements (
  movement_id BIGSERIAL PRIMARY KEY,
  movement_date TIMESTAMP NOT NULL DEFAULT now(),
  warehouse_id INT NOT NULL REFERENCES warehouses(warehouse_id),
  product_id INT NOT NULL REFERENCES products(product_id),
  product_variant_id INT REFERENCES product_variants(product_variant_id),
  lot_id INT REFERENCES lots(lot_id),
  uom_id INT NOT NULL REFERENCES units(uom_id),
  qty NUMERIC(18,3) NOT NULL,
  reason TEXT NOT NULL,
  ref_type TEXT,
  ref_id BIGINT
);

CREATE TABLE recipes (
  recipe_id SERIAL PRIMARY KEY,
  product_variant_id INT NOT NULL REFERENCES product_variants(product_variant_id),
  name TEXT NOT NULL,
  yield_bottles INT NOT NULL CHECK (yield_bottles > 0),
  notes TEXT
);

CREATE TABLE recipe_items (
  recipe_item_id SERIAL PRIMARY KEY,
  recipe_id INT NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
  component_product_id INT NOT NULL REFERENCES products(product_id),
  qty_per_batch NUMERIC(18,3) NOT NULL,
  uom_id INT NOT NULL REFERENCES units(uom_id),
  is_optional BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (recipe_id, component_product_id)
);

CREATE TABLE production_orders (
  production_order_id SERIAL PRIMARY KEY,
  recipe_id INT NOT NULL REFERENCES recipes(recipe_id),
  warehouse_id INT NOT NULL REFERENCES warehouses(warehouse_id),
  planned_bottles INT NOT NULL CHECK (planned_bottles > 0),
  status TEXT NOT NULL CHECK (status IN ('draft','awaiting_approval','approved','in_progress','completed','cancelled')) DEFAULT 'draft',
  created_by INT REFERENCES users(user_id),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE production_consumptions (
  prod_consume_id BIGSERIAL PRIMARY KEY,
  production_order_id INT NOT NULL REFERENCES production_orders(production_order_id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(product_id),
  lot_id INT REFERENCES lots(lot_id),
  uom_id INT NOT NULL REFERENCES units(uom_id),
  qty NUMERIC(18,3) NOT NULL
);

CREATE TABLE production_outputs (
  prod_output_id BIGSERIAL PRIMARY KEY,
  production_order_id INT NOT NULL REFERENCES production_orders(production_order_id) ON DELETE CASCADE,
  product_variant_id INT NOT NULL REFERENCES product_variants(product_variant_id),
  lot_id INT REFERENCES lots(lot_id),
  uom_id INT NOT NULL REFERENCES units(uom_id),
  qty_bottles INT NOT NULL CHECK (qty_bottles >= 0)
);

CREATE TABLE suppliers (
  supplier_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE purchase_receipts (
  receipt_id SERIAL PRIMARY KEY,
  supplier_id INT REFERENCES suppliers(supplier_id),
  doc_no TEXT,
  receipt_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE purchase_receipt_lines (
  receipt_line_id SERIAL PRIMARY KEY,
  receipt_id INT NOT NULL REFERENCES purchase_receipts(receipt_id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(product_id),
  lot_id INT REFERENCES lots(lot_id),
  warehouse_id INT NOT NULL REFERENCES warehouses(warehouse_id),
  uom_id INT NOT NULL REFERENCES units(uom_id),
  qty NUMERIC(18,3) NOT NULL CHECK (qty > 0)
);

CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE sales_orders (
  sales_order_id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customers(customer_id),
  order_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status TEXT NOT NULL CHECK (status IN ('draft','awaiting_approval','approved','allocated','shipped','cancelled')) DEFAULT 'draft'
);

CREATE TABLE sales_order_lines (
  so_line_id SERIAL PRIMARY KEY,
  sales_order_id INT NOT NULL REFERENCES sales_orders(sales_order_id) ON DELETE CASCADE,
  product_variant_id INT NOT NULL REFERENCES product_variants(product_variant_id),
  qty_bottles INT NOT NULL CHECK (qty_bottles > 0)
);

CREATE TABLE approval_flows (
  flow_id SERIAL PRIMARY KEY,
  department_id INT NOT NULL REFERENCES departments(department_id),
  action_type TEXT NOT NULL,
  min_level INT NOT NULL DEFAULT 1,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE(department_id, action_type)
);

CREATE TABLE approvals (
  approval_id BIGSERIAL PRIMARY KEY,
  flow_id INT NOT NULL REFERENCES approval_flows(flow_id),
  related_type TEXT NOT NULL,
  related_id BIGINT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','approved','rejected')) DEFAULT 'pending',
  approved_by INT REFERENCES users(user_id),
  approved_at TIMESTAMP,
  note TEXT
);

-- Basit bütünlük kuralı örneği (ürün_variant tutarlılığı)
ALTER TABLE stock_movements
ADD CONSTRAINT chk_variant_product_match
CHECK (
  product_variant_id IS NULL
  OR product_id = (SELECT product_id FROM product_variants WHERE product_variant_id = stock_movements.product_variant_id)
);

