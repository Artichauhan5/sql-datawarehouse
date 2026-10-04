EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

-- Data Transformations for SILVER cust_info
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_gender,
    cst_marital_status,
    cst_create_date
)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
     WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
     ELSE 'n/a'
END AS cst_gender,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
     WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
     ELSE 'n/a'
END as cst_marital_status,
cst_create_date
FROM (
SELECT
*,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t 
WHERE flag = 1

-- Data Transformations for SILVER prd_info
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
    prd_id,
    category_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,                                                   -- 1. prd_id
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS category_id, -- 2. category_id
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,           -- 3. prd_key
    prd_nm,                                                   -- 4. prd_nm
    COALESCE(prd_cost, 0) AS prd_cost,                        -- 5. prd_cost
    CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
         WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
         WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
         WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
         ELSE 'n/a' END AS prd_line,                         -- 6. prd_line
    CAST(prd_start_dt AS DATE) AS prd_start_dt,               -- 7. prd_start_dt
    CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt -- 8. prd_end_dt
FROM bronze.crm_prd_info;

-- Data Transformations for SILVER sales details
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)

SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END sls_due_dt,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / COALESCE(sls_quantity, 0)
     ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details

-- Data Transformations for SILVER customer AZ12
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (
    cid,
    birthdate,
    gen
)

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END AS cid,
CASE WHEN birthdate > GETDATE() THEN NULL
     ELSE birthdate
END AS birthdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
     ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

-- Data Transformations for SILVER LOCATION
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (
    cid,
    country
)

SELECT
REPLACE(cid, '-', '') AS cid,
CASE WHEN TRIM(country) = 'DE' THEN 'Germany'
     WHEN TRIM(country) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(country) = '' OR country IS NULL THEN 'n/a'
     ELSE country
END AS country
FROM bronze.erp_loc_a101

--Data Transformation for Category table
TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)

SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

END