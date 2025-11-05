-- 06_functions_uom.sql

CREATE OR REPLACE FUNCTION fn_uom_convert_factor(from_uom INT, to_uom INT)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE
  factor NUMERIC := 1;
BEGIN
  IF from_uom = to_uom THEN
    RETURN 1;
  END IF;

  WITH RECURSIVE up_from(uom_id, base_uom_id, ratio, depth, acc) AS (
    SELECT u.uom_id, u.base_uom_id, u.ratio, 0, 1::NUMERIC
    FROM units u WHERE u.uom_id = from_uom
    UNION ALL
    SELECT u.uom_id, u.base_uom_id, u.ratio, f.depth+1,
           CASE WHEN f.base_uom_id IS NULL THEN f.acc
                ELSE f.acc / COALESCE(f.ratio,1) END
    FROM up_from f
    JOIN units u ON u.uom_id = f.base_uom_id
    WHERE f.base_uom_id IS NOT NULL
  ),
  up_to(uom_id, base_uom_id, ratio, depth, acc) AS (
    SELECT u.uom_id, u.base_uom_id, u.ratio, 0, 1::NUMERIC
    FROM units u WHERE u.uom_id = to_uom
    UNION ALL
    SELECT u.uom_id, u.base_uom_id, u.ratio, t.depth+1,
           CASE WHEN t.base_uom_id IS NULL THEN t.acc
                ELSE t.acc / COALESCE(t.ratio,1) END
    FROM up_to t
    JOIN units u ON u.uom_id = t.base_uom_id
    WHERE t.base_uom_id IS NOT NULL
  ),
  roots AS (
    SELECT f.uom_id as from_branch_uom, t.uom_id as to_branch_uom,
           f.depth as d_from, t.depth as d_to,
           f.acc as acc_from, t.acc as acc_to
    FROM up_from f
    JOIN up_to t ON f.uom_id = t.uom_id
    ORDER BY f.depth ASC, t.depth ASC
    LIMIT 1
  )
  SELECT (r.acc_from / r.acc_to) INTO factor FROM roots r;

  IF factor IS NULL THEN
    RAISE EXCEPTION 'Cannot convert from uom % to %', from_uom, to_uom;
  END IF;

  RETURN factor;
END $$;

CREATE OR REPLACE FUNCTION fn_uom_convert(qty NUMERIC, from_uom INT, to_uom INT)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
  RETURN qty * fn_uom_convert_factor(from_uom, to_uom);
END $$;

