--THE DDL script
-- if object already exist then create 
--this one is to create table which we will later on load with cleaned data from bronze layer 





if OBJECT_ID('silver.crm_cust_info','U') is NOT NULL 
    drop table silver.crm_cust_info
create  table silver.crm_cust_info(
    cst_id int,
    cst_key NVARCHAR(50),
    cst_first_name NVARCHAR(50),
    cst_last_name NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_created_date DATETIME,
    dwh_create_date datetime2 DEFAULT GETDATE()
);
if OBJECT_ID('silver.crm_prd_info','U') is NOT NULL
    drop table silver.crm_prd_info
create table silver.crm_prd_info(
    prd_id int,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost int,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date datetime2 DEFAULT GETDATE()
);
if OBJECT_ID('silver.crm_sales_details','U') is NOT NULL
    drop table silver.crm_sales_details
create table silver.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id int,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales  int,
    sls_quantity int,
    sls_price int,
    dwh_create_date datetime2 DEFAULT GETDATE()
);

if OBJECT_ID('silver.erp_loc_a101','U') is NOT NULL
    drop table silver.erp_loc_a101
create table silver.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date datetime2 DEFAULT GETDATE()
);
if OBJECT_ID('silver.erp_cust_az12','U') is NOT NULL
    drop table silver.erp_cust_az12
create table silver.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
    dwh_create_date datetime2 DEFAULT GETDATE()
);
if OBJECT_ID('silver.erp_px_cat_g1v2','U') is NOT NULL
    drop table silver.erp_px_cat_g1v2
create table silver.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
     dwh_create_date datetime2 DEFAULT GETDATE()
);
