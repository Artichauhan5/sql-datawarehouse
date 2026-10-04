-- Clean and load crm_cust_into

SELECT * FROM bronze.crm_cust_info

-- Nulls and duplicated check in primary key
SELECT
cst_id,
COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Unwanted spaces check
SELECT
cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data standardization and consistency
SELECT DISTINCT cst_gender FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info;

-- Clean and load crm_prd_info
SELECT * FROM bronze.crm_prd_info;

SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
-- RESULT - no duplicates in the primary key

-- Unwanted spaces
SELECT
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
-- RESULT -- no unwanted spaces

-- check for nulls and negative numbers in cost
SELECT 
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data standardization and consistency
SELECT DISTINCT
prd_line
FROM bronze.crm_prd_info

-- Check the Invalid order dates
SELECT
*
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- CLEAN SALES_DETAILS

SELECT * FROM bronze.crm_sales_details

-- Check invalid dates
SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8

-- Check Invalid order and ship dates
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt

-- Check data consistency between price, quantity and sales
SELECT
sls_sales AS old_sales,
sls_quantity,
sls_price AS old_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / COALESCE(sls_quantity, 0)
     ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity 
OR sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL
OR sls_sales <= 0 OR sls_price <= 0 OR sls_quantity <= 0

-- CLEAN customer az12

-- see out of the range dates
SELECT
birthdate
FROM bronze.erp_cust_az12
WHERE birthdate < '1926-01-01' OR birthdate > GETDATE()

SELECT DISTINCT
gen
FROM bronze.erp_cust_az12

-- CLEAN Location table
SELECT DISTINCT
country
FROM bronze.erp_loc_a101

-- CLEAN category table

-- Unwanted spaces
SELECT 
*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat)
-- RESULT: Clean

-- Data standardization and normalization
SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2