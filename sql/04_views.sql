-- 04_views.sql
CREATE OR REPLACE VIEW vw_bottle_stock AS
SELECT
  pv.product_variant_id,
  p.name AS product_name,
  c.name AS category_name,
  pv.packaging_type,
  pv.net_content_value,
  u.code AS net_content_uom,
  COALESCE(SUM(CASE WHEN sm.uom_id = (SELECT uom_id FROM units WHERE code='EA')
                    THEN sm.qty ELSE 0 END),0) AS bottles_net
FROM product_variants pv
JOIN products p ON p.product_id = pv.product_id
JOIN categories c ON c.category_id = p.category_id
JOIN units u ON u.uom_id = pv.net_content_uom_id
LEFT JOIN stock_movements sm ON sm.product_variant_id = pv.product_variant_id
GROUP BY pv.product_variant_id, p.name, c.name, pv.packaging_type, pv.net_content_value, u.code;

CREATE OR REPLACE VIEW vw_fifo_lots AS
SELECT l.product_id, l.lot_id, l.lot_code, l.mfg_date, l.exp_date,
       SUM(sm.qty) AS qty_on_hand
FROM lots l
JOIN stock_movements sm ON sm.lot_id = l.lot_id AND sm.product_id = l.product_id
GROUP BY l.product_id, l.lot_id, l.lot_code, l.mfg_date, l.exp_date
HAVING SUM(sm.qty) > 0
ORDER BY l.mfg_date, l.lot_id;

