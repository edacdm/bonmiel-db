-- 08_reports_approvals.sql

CREATE OR REPLACE VIEW vw_pending_approvals AS
SELECT
  af.flow_id,
  d.name AS department,
  af.action_type,
  a.related_type,
  a.related_id,
  a.status,
  a.note,
  a.approved_by,
  a.approved_at
FROM approvals a
JOIN approval_flows af ON af.flow_id = a.flow_id
JOIN departments d ON d.department_id = af.department_id
WHERE a.status = 'pending'
ORDER BY d.name, af.action_type, a.related_type, a.related_id;

CREATE OR REPLACE VIEW vw_approval_timeline AS
SELECT
  a.related_type,
  a.related_id,
  d.name AS department,
  af.action_type,
  a.status,
  u.full_name AS approved_by_name,
  a.approved_at,
  a.note
FROM approvals a
JOIN approval_flows af ON af.flow_id = a.flow_id
JOIN departments d ON d.department_id = af.department_id
LEFT JOIN users u ON u.user_id = a.approved_by
ORDER BY a.related_type, a.related_id, a.approved_at NULLS LAST;

CREATE OR REPLACE VIEW vw_approvals_summary AS
SELECT d.name AS department,
       af.action_type,
       COUNT(*) FILTER (WHERE a.status='pending') AS pending_count,
       COUNT(*) FILTER (WHERE a.status='approved') AS approved_count,
       COUNT(*) FILTER (WHERE a.status='rejected') AS rejected_count
FROM approval_flows af
JOIN departments d ON d.department_id = af.department_id
LEFT JOIN approvals a ON a.flow_id = af.flow_id
GROUP BY d.name, af.action_type
ORDER BY d.name, af.action_type;

