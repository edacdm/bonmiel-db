-- 10_test.sql

-- 1) Üretim emri
INSERT INTO production_orders(recipe_id, warehouse_id, planned_bottles, status)
VALUES (
  (SELECT recipe_id FROM recipes WHERE name='Çilek Şurubu 700 ml Batch'),
  (SELECT warehouse_id FROM warehouses WHERE name='Ana Depo'),
  350, 'approved'
)
RETURNING production_order_id;

-- 2) Sarf (örnek)
INSERT INTO production_consumptions(production_order_id, product_id, lot_id, uom_id, qty)
VALUES
((SELECT production_order_id FROM production_orders ORDER BY production_order_id DESC LIMIT 1),
 (SELECT product_id FROM products WHERE code='RM-SUGS'),
 (SELECT lot_id FROM lots WHERE lot_code='SUGS-2025-01'),
 (SELECT uom_id FROM units WHERE code='KG'), 52.5),
((SELECT production_order_id FROM production_orders ORDER BY production_order_id DESC LIMIT 1),
 (SELECT product_id FROM products WHERE code='RM-AROM'),
 (SELECT lot_id FROM lots WHERE lot_code='AROM-2025-01'),
 (SELECT uom_id FROM units WHERE code='L'), 7);

-- 3) Çıktı
INSERT INTO production_outputs(production_order_id, product_variant_id, lot_id, uom_id, qty_bottles)
VALUES (
 (SELECT production_order_id FROM production_orders ORDER BY production_order_id DESC LIMIT 1),
 (SELECT product_variant_id FROM product_variants pv
  JOIN products p ON p.product_id=pv.product_id
  WHERE p.code='SRP-STR' AND pv.net_content_value=700),
 NULL,
 (SELECT uom_id FROM units WHERE code='EA'),
 340
);

-- 4) Raporlar
SELECT * FROM vw_production_yield ORDER BY production_order_id DESC LIMIT 5;
SELECT * FROM vw_production_material_variance ORDER BY production_order_id DESC LIMIT 20;

