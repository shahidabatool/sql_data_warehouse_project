--EXEC silver.load_silver 
-- Here is the procedure for the ETL of whole silver layers where we are performing tasks such as 
--Data Standardization,mapping, string cleaning (trim,substring), formating the data types,
--business related calculation to confirm the validity of data such as quality into price with total amount 

create or alter PROCEDURE silver.load_silver as 
BEGIN
DECLARE @start_time Datetime ,@end_time DATETIME,@batch_start_time datetime,@batch_end_time datetime;
    BEGIN TRY
        set @batch_start_time =getdate();
        PRINT '=============================================';
        PRINT 'Loading Silver layer';
        PRINT '=============================================';
        print '---------------------------------------------';
        PRINT 'Loading CRM Tables';
        print '---------------------------------------------';
    --start the time 
    set @start_time =GETDATE();
    print'>> Truncating Table:silver.crm_cust_info'
    TRUNCATE table silver.crm_cust_info
    PRINT '>>Insert data into: silver.crm_cust_info';
    insert into silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_first_name,
        cst_last_name,
        cst_marital_status,
        cst_gndr,
        cst_created_date
    )
    select 
        cst_id,
        cst_key,
    --we are standarizing the data 
        TRIM(cst_first_name) as cst_first_name,
        TRIM(cst_last_name) as cst_last_name,
        case   
            when upper(trim(cst_marital_status))='M' then 'Married'
            when upper(trim(cst_marital_status))='S' then 'Single'
            else 'Unknown' end as cst_marital_status,
        case  
            when upper(trim(cst_gndr))='F' then 'Female'
            when upper(trim(cst_gndr))='M' then 'Male'
            else 'Unknown' end as cst_gndr,
    cst_created_date
    -- we have removed duplicates here 
        FROM
        (
                select *,
                row_number() over (PARTITION by cst_id order by cst_created_date desc ) as flag_last
                from bronze.crm_cust_info
                where cst_id is not NULL
                )t where flag_last=1
        set @end_time =getdate();
    print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
    print '---------------------------------------------------------------';
    
    --loading silver.crm_prd_info
    set @start_time =GETDATE();
    print'>> Truncating Table:silver.crm_prd_info'
    TRUNCATE table silver.crm_prd_info
    PRINT '>>Insert data into: silver.crm_prd_info';
    insert into silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,--new derived column for joining in gold layer 
        SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
        prd_nm,
        isnull(prd_cost,0) as prd_cost,
        case 
            when upper(trim (prd_line))='M' then 'Mountain'
            when upper(trim (prd_line))='R' then 'Road'
            when upper(trim (prd_line))='S' then 'Other Sales'
            when upper(trim (prd_line))='T' then 'Touring'
            else 'n/a'
        end as prd_line,
        cast(prd_start_dt as date) as prd_start_dt,
        cast(LEAD(prd_start_dt) OVER(partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
    from bronze.crm_prd_info
    set @end_time =getdate();
    print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
    print '---------------------------------------------------------------';
    
    --loading silver.crm_sales_details
    set @start_time =GETDATE();
    print'>> Truncating Table:silver.crm_sales_details'
    TRUNCATE table silver.crm_sales_details
    PRINT '>>Insert data into: silver.crm_sales_details';
    insert into silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales ,
        sls_quantity,
        sls_price 
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        case 
            when sls_order_dt=0 or len(sls_order_dt)!=8 then null
            else cast(cast(sls_order_dt as varchar) as date)
        end as sls_order_dt,
        case 
            when sls_ship_dt=0 or len(sls_ship_dt)!=8 then null
            else cast(cast(sls_ship_dt as varchar) as date)
        end as sls_ship_dt,
        case
            when sls_due_dt=0 or len(sls_due_dt)!=8 then null
            else cast(cast(sls_due_dt as varchar) as date)
        end as sls_due_dt,
        case 
            when sls_sales is null or sls_sales<=0 or sls_sales !=sls_quantity*ABS(sls_price)
            then sls_quantity*abs(sls_price)
            else sls_sales
        end as sls_sales,
        sls_quantity,
        case 
            when sls_price is null or sls_price<=0
            then sls_sales/nullif (sls_quantity,0)-- no zero
            else sls_price
        end as sls_price
    from bronze.crm_sales_details
    set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + 'seconds';
        print '---------------------------------------------------------------';
        print '---------------------------------------------';
        PRINT 'Loading ERP Tables';
        print '---------------------------------------------';
    --loading silver.erp_cust_az12
    set @start_time =GETDATE();
    print'>> Truncating Table:silver.erp_cust_az12'
    TRUNCATE table silver.erp_cust_az12
    PRINT '>>Insert data into: silver.erp_cust_az12';
    insert into silver.erp_cust_az12(
        cid,
        bdate,
        gen
    )
    select 
    case 
        when cid like 'NAS%' THEN SUBSTRING(cid,4,len(cid))
        else cid
    end as cid,  
    case 
        when bdate> GETDATE() then null
        else bdate
    end as bdate,
    CASE
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('F','FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('M','MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
    from bronze.erp_cust_az12
    set @end_time =getdate();
    print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
    print '---------------------------------------------------------------';
    --loading silver.erp_loc_a101
    set @start_time =GETDATE();
    print'>> Truncating Table:silver.erp_loc_a101'
    TRUNCATE table silver.erp_loc_a101
    PRINT '>>Insert data into: silver.erp_loc_a101';
    insert into silver.erp_loc_a101(
        cid,
        cntry
    )
    select 
        replace(cid,'-','') as cid,
    CASE 
        WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = 'DE' THEN 'Germany'
        WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) IN ('US','USA') THEN 'United States'
        WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))
    END AS cntry
    FROM bronze.erp_loc_a101;
    set @end_time =getdate();
    print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
    print '---------------------------------------------------------------';
    --loading silver.erp_px_cat_g1v2
    set @start_time =GETDATE();
    print'>> Truncating Table:silver.erp_px_cat_g1v2'
    TRUNCATE table silver.erp_px_cat_g1v2
    PRINT '>>Insert data into: silver.erp_px_cat_g1v2';
    insert into silver.erp_px_cat_g1v2(
        id,
        cat,
        subcat,
        maintenance
    )
    select 
        id,
        TRIM(REPLACE(REPLACE(cat, CHAR(13), ''), CHAR(10), '')) AS cat,
        TRIM(REPLACE(REPLACE(subcat, CHAR(13), ''), CHAR(10), '')) AS subcat,
        TRIM(REPLACE(REPLACE(maintenance, CHAR(13), ''), CHAR(10), '')) AS maintenance
    from bronze.erp_px_cat_g1v2
    set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
        print '---------------------------------------------------------------';
        set @batch_end_time= GETDATE();
        PRINT 'Total Batch time '+ cast(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)as VARCHAR)+ ' seconds';
    END TRY
    BEGIN CATCH
        PRINT '===============================';
        PRINT 'Error occured during bronze layer';
        print 'Error Message'+  ERROR_MESSAGE();
        PRINT 'Error Message'+ cast(ERROR_NUMBER() AS NVARCHAR);
        PRINT '===================================';
    END CATCH 
END
