-- 03_indexes.sql
CREATE INDEX IF NOT EXISTS idx_sm_product ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_sm_variant ON stock_movements(product_variant_id);
CREATE INDEX IF NOT EXISTS idx_sm_lot ON stock_movements(lot_id);
CREATE INDEX IF NOT EXISTS idx_sm_wh_date ON stock_movements(warehouse_id, movement_date);

CREATE INDEX IF NOT EXISTS idx_lots_prod_code ON lots(product_id, lot_code);
CREATE INDEX IF NOT EXISTS idx_po_status ON production_orders(status);
CREATE INDEX IF NOT EXISTS idx_approvals_related ON approvals(related_type, related_id);

