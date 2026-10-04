CREATE VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
c.cst_id AS customer_id,
c.cst_key AS customer_number,
c.cst_firstname AS first_name,
c.cst_lastname AS last_name,
l.country AS country,
c.cst_marital_status AS marital_status,
CASE WHEN c.cst_gender != 'n/a' THEN cst_gender 
	 ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.birthdate AS birthdate,
c.cst_create_date AS create_date
FROM silver.crm_cust_info c
LEFT JOIN silver.erp_cust_az12 ca
ON c.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 l
ON c.cst_key = l.cid

-- handling 2 gender columns
SELECT DISTINCT
c.cst_gender,
ca.gen,
CASE WHEN c.cst_gender != 'n/a' THEN cst_gender 
	 ELSE COALESCE(ca.gen, 'n/a')
END AS new_gen
FROM silver.crm_cust_info c
LEFT JOIN silver.erp_cust_az12 ca
ON c.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 l
ON c.cst_key = l.cid
ORDER BY 1, 2


