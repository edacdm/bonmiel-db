-- 09_seed.sql

INSERT INTO units(code,name) VALUES
 ('EA','Adet'),('ML','Mililitre'),('L','Litre'),('G','Gram'),('KG','Kilogram')
ON CONFLICT DO NOTHING;

UPDATE units SET base_uom_id = (SELECT uom_id FROM units WHERE code='L'), ratio=1000 WHERE code='ML';
UPDATE units SET base_uom_id = (SELECT uom_id FROM units WHERE code='KG'), ratio=1000 WHERE code='G';

INSERT INTO categories(name) VALUES ('Şurup'),('Püre'),('Sos') ON CONFLICT DO NOTHING;

INSERT INTO warehouses(name) VALUES ('Ana Depo') ON CONFLICT DO NOTHING;

INSERT INTO departments(name) VALUES ('warehouse'),('quality'),('rd'),('planner'),('sales') ON CONFLICT DO NOTHING;

INSERT INTO users(full_name, role, department_id)
SELECT 'Depo Sorumlusu','warehouse', (SELECT department_id FROM departments WHERE name='warehouse')
WHERE NOT EXISTS (SELECT 1 FROM users WHERE full_name='Depo Sorumlusu');

INSERT INTO products(category_id,name,code,is_raw_material) VALUES
  ((SELECT category_id FROM categories WHERE name='Şurup'),'Çilek Şurubu','SRP-STR',FALSE),
  ((SELECT category_id FROM categories WHERE name='Püre'),'Mango Püresi','PRE-MNG',FALSE),
  ((SELECT category_id FROM categories WHERE name='Sos'),'Çikolata Sosu','SOS-CHK',FALSE),
  ((SELECT category_id FROM categories WHERE name='Şurup'),'Şeker Şurubu','RM-SUGS',TRUE),
  ((SELECT category_id FROM categories WHERE name='Şurup'),'Doğal Aroma Konsantresi','RM-AROM',TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO product_variants(product_id,packaging_type,net_content_value,net_content_uom_id)
VALUES
  ((SELECT product_id FROM products WHERE code='SRP-STR'),'Şişe',700,(SELECT uom_id FROM units WHERE code='ML')),
  ((SELECT product_id FROM products WHERE code='SRP-STR'),'Şişe',250,(SELECT uom_id FROM units WHERE code='ML')),
  ((SELECT product_id FROM products WHERE code='PRE-MNG'),'Şişe',500,(SELECT uom_id FROM units WHERE code='ML'))
ON CONFLICT DO NOTHING;

INSERT INTO lots(product_id, lot_code, mfg_date, exp_date) VALUES
  ((SELECT product_id FROM products WHERE code='RM-SUGS'),'SUGS-2025-01','2025-10-01','2026-10-01'),
  ((SELECT product_id FROM products WHERE code='RM-AROM'),'AROM-2025-01','2025-10-01','2026-04-01')
ON CONFLICT DO NOTHING;

INSERT INTO suppliers(name) VALUES ('Tedarik A.Ş.') ON CONFLICT DO NOTHING;

INSERT INTO purchase_receipts(supplier_id, doc_no, receipt_date)
VALUES ((SELECT supplier_id FROM suppliers WHERE name='Tedarik A.Ş.'), 'GIRIS-0001', CURRENT_DATE);

INSERT INTO purchase_receipt_lines(receipt_id, product_id, lot_id, warehouse_id, uom_id, qty)
VALUES
  ((SELECT receipt_id FROM purchase_receipts ORDER BY receipt_id DESC LIMIT 1),
   (SELECT product_id FROM products WHERE code='RM-SUGS'),
   (SELECT lot_id FROM lots WHERE lot_code='SUGS-2025-01'),
   (SELECT warehouse_id FROM warehouses WHERE name='Ana Depo'),
   (SELECT uom_id FROM units WHERE code='KG'), 200),
  ((SELECT receipt_id FROM purchase_receipts ORDER BY receipt_id DESC LIMIT 1),
   (SELECT product_id FROM products WHERE code='RM-AROM'),
   (SELECT lot_id FROM lots WHERE lot_code='AROM-2025-01'),
   (SELECT warehouse_id FROM warehouses WHERE name='Ana Depo'),
   (SELECT uom_id FROM units WHERE code='L'), 50);

INSERT INTO recipes(product_variant_id, name, yield_bottles, notes)
VALUES (
  (SELECT product_variant_id FROM product_variants pv
   JOIN products p ON p.product_id=pv.product_id
   WHERE p.code='SRP-STR' AND pv.net_content_value=700),
  'Çilek Şurubu 700 ml Batch',
  100,
  'Örnek reçete'
);

INSERT INTO recipe_items(recipe_id, component_product_id, qty_per_batch, uom_id)
VALUES
((SELECT recipe_id FROM recipes ORDER BY recipe_id DESC LIMIT 1),
 (SELECT product_id FROM products WHERE code='RM-SUGS'),
 15, (SELECT uom_id FROM units WHERE code='KG')),
((SELECT recipe_id FROM recipes ORDER BY recipe_id DESC LIMIT 1),
 (SELECT product_id FROM products WHERE code='RM-AROM'),
 2, (SELECT uom_id FROM units WHERE code='L'));

