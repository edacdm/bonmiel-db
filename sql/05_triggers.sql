-- 05_triggers.sql

-- Purchase receipt line -> stock movement (+)
CREATE OR REPLACE FUNCTION trg_purchase_line_to_movement()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO stock_movements(
    movement_date, warehouse_id, product_id, product_variant_id, lot_id, uom_id, qty, reason, ref_type, ref_id
  )
  VALUES (now(), NEW.warehouse_id, NEW.product_id, NULL, NEW.lot_id, NEW.uom_id, NEW.qty,
          'purchase','PO', NEW.receipt_id);
  RETURN NEW;
END $$;

CREATE TRIGGER t_purchase_line_ai
AFTER INSERT ON purchase_receipt_lines
FOR EACH ROW EXECUTE FUNCTION trg_purchase_line_to_movement();

-- Production consumption -> stock movement (-)
CREATE OR REPLACE FUNCTION trg_prod_consume_to_movement()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_warehouse INT;
BEGIN
  SELECT warehouse_id INTO v_warehouse
  FROM production_orders WHERE production_order_id = NEW.production_order_id;

  INSERT INTO stock_movements(
    movement_date, warehouse_id, product_id, product_variant_id, lot_id, uom_id, qty, reason, ref_type, ref_id
  )
  VALUES (now(), v_warehouse, NEW.product_id, NULL, NEW.lot_id, NEW.uom_id, -1 * NEW.qty,
          'prod-consume','PROD', NEW.production_order_id);
  RETURN NEW;
END $$;

CREATE TRIGGER t_prod_consume_ai
AFTER INSERT ON production_consumptions
FOR EACH ROW EXECUTE FUNCTION trg_prod_consume_to_movement();

-- Production outputs -> stock movement (+)
CREATE OR REPLACE FUNCTION trg_prod_output_to_movement()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_warehouse INT;
  v_product INT;
BEGIN
  SELECT warehouse_id INTO v_warehouse
  FROM production_orders WHERE production_order_id = NEW.production_order_id;

  SELECT product_id INTO v_product FROM product_variants WHERE product_variant_id = NEW.product_variant_id;

  INSERT INTO stock_movements(
    movement_date, warehouse_id, product_id, product_variant_id, lot_id, uom_id, qty, reason, ref_type, ref_id
  )
  VALUES (now(), v_warehouse, v_product, NEW.product_variant_id, NEW.lot_id, NEW.uom_id, NEW.qty_bottles,
          'prod-output','PROD', NEW.production_order_id);
  RETURN NEW;
END $$;

CREATE TRIGGER t_prod_output_ai
AFTER INSERT ON production_outputs
FOR EACH ROW EXECUTE FUNCTION trg_prod_output_to_movement();

