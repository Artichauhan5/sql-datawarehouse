CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER(ORDER BY p.prd_start_dt, p.prd_key) AS product_key,
p.prd_id AS product_id,
p.prd_key AS product_number,
p.prd_nm AS product_name,
p.category_id ,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
p.prd_cost AS cost,
p.prd_line AS product_line,
p.prd_start_dt AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON p.category_id = pc.id
WHERE P.prd_end_dt IS NULL -- filtering the current data
