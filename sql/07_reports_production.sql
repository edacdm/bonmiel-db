-- 07_reports_production.sql

CREATE OR REPLACE VIEW vw_production_yield AS
SELECT
  po.production_order_id,
  po.created_at::date AS order_date,
  po.status,
  r.recipe_id,
  r.name AS recipe_name,
  r.yield_bottles,
  po.planned_bottles,
  COALESCE(SUM(o.qty_bottles),0) AS actual_bottles,
  CASE WHEN po.planned_bottles > 0
       THEN ROUND( (COALESCE(SUM(o.qty_bottles),0)::NUMERIC / po.planned_bottles) * 100, 2)
       ELSE NULL END AS yield_percent,
  (po.planned_bottles - COALESCE(SUM(o.qty_bottles),0)) AS shortfall_bottles
FROM production_orders po
JOIN recipes r ON r.recipe_id = po.recipe_id
LEFT JOIN production_outputs o ON o.production_order_id = po.production_order_id
GROUP BY po.production_order_id, po.created_at, po.status, r.recipe_id, r.name, r.yield_bottles, po.planned_bottles
ORDER BY po.production_order_id DESC;

CREATE OR REPLACE VIEW vw_production_material_variance AS
WITH scale AS (
  SELECT
    po.production_order_id,
    po.planned_bottles::NUMERIC / r.yield_bottles::NUMERIC AS scale_factor,
    r.recipe_id
  FROM production_orders po
  JOIN recipes r ON r.recipe_id = po.recipe_id
),
theoretical AS (
  SELECT
    s.production_order_id,
    ri.component_product_id,
    ri.uom_id AS recipe_uom_id,
    (ri.qty_per_batch * s.scale_factor) AS required_qty
  FROM scale s
  JOIN recipe_items ri ON ri.recipe_id = s.recipe_id
),
actual AS (
  SELECT
    pc.production_order_id,
    pc.product_id AS component_product_id,
    pc.uom_id AS actual_uom_id,
    SUM(pc.qty) AS actual_qty
  FROM production_consumptions pc
  GROUP BY pc.production_order_id, pc.product_id, pc.uom_id
),
merged AS (
  SELECT
    t.production_order_id,
    t.component_product_id,
    t.recipe_uom_id,
    t.required_qty,
    a.actual_uom_id,
    a.actual_qty,
    CASE
      WHEN a.actual_qty IS NULL THEN 0
      ELSE fn_uom_convert(a.actual_qty, a.actual_uom_id, t.recipe_uom_id)
    END AS actual_in_recipe_uom
  FROM theoretical t
  LEFT JOIN actual a
    ON a.production_order_id = t.production_order_id
   AND a.component_product_id = t.component_product_id
)
SELECT
  m.production_order_id,
  p.name AS component_name,
  u_rec.code AS uom,
  ROUND(m.required_qty, 3) AS required_qty,
  ROUND(m.actual_in_recipe_uom, 3) AS actual_qty,
  ROUND(m.actual_in_recipe_uom - m.required_qty, 3) AS variance_qty,
  CASE
    WHEN m.required_qty = 0 THEN NULL
    ELSE ROUND(((m.actual_in_recipe_uom - m.required_qty) / m.required_qty) * 100, 2)
  END AS variance_percent
FROM merged m
JOIN products p ON p.product_id = m.component_product_id
JOIN units u_rec ON u_rec.uom_id = m.recipe_uom_id
ORDER BY m.production_order_id DESC, p.name;

