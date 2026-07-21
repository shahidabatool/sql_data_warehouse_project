-- if object already exist then create 


if OBJECT_ID('bronze.crm_cust_info','U') is NOT NULL 
    drop table bronze.crm_cust_info
create  table bronze.crm_cust_info(
    cst_id int,
    cst_key NVARCHAR(50),
    cst_first_name NVARCHAR(50),
    cst_last_name NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_created_date DATETIME,
);


if OBJECT_ID('bronze.crm_prd_info','U') is NOT NULL
    drop table bronze.crm_prd_info

create table bronze.crm_prd_info(
    prd_id int,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost int,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);


if OBJECT_ID('bronze.crm_sales_details','U') is NOT NULL
    drop table bronze.crm_sales_details
create table bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id int,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales  int,
    sls_quantity int,
    sls_price int
);



if OBJECT_ID('bronze.erp_loc_a101','U') is NOT NULL
    drop table bronze.erp_loc_a101
create table bronze.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
);



if OBJECT_ID('bronze.erp_cust_az12','U') is NOT NULL
    drop table bronze.erp_cust_az12
create table bronze.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);


if OBJECT_ID('bronze.erp_px_cat_g1v2','U') is NOT NULL
    drop table bronze.erp_px_cat_g1v2
create table bronze.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
