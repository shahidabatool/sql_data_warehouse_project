-- we are using bulf to insert data in database from csv i was using dockers (mac)
-- so for this reason I was using dockers so before bulking i push the data scourse files in dockers and then 
-- i was able to load it in the database ** always follow the steps incase using docker conatiners
USE DataWarehouse;
GO

create or alter procedure bronze.load_bronze as 
BEGIN
    DECLARE @start_time Datetime ,@end_time DATETIME,@batch_start_time datetime,@batch_end_time datetime;
    BEGIN TRY
        set @batch_start_time =getdate();
        PRINT '=============================================';
        PRINT 'Loading Bronze layer';
        PRINT '=============================================';
        print '---------------------------------------------';
        PRINT 'Loading CRM Tables';
        print '---------------------------------------------';
        set @start_time =GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE table bronze.crm_cust_info;
        PRINT '>>Insert data into: bronze.crm_cust_info';
        BULK insert bronze.crm_cust_info from '/datasets/source_crm/cust_info.csv'
        with (
            Firstrow =2,
            fieldterminator =',',
            tablock
        );
        set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
        print '---------------------------------------------------------------';
        set @start_time =GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE table bronze.crm_prd_info;
        PRINT '>>Insert data into: bronze.crm_cust_info';
        BULK insert bronze.crm_prd_info from '/datasets/source_crm/prd_info.csv'
        with (
            Firstrow =2,
            fieldterminator =',',
            tablock
        );
        set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
        print '---------------------------------------------------------------';
        set @start_time =GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE table bronze.crm_sales_details;
        PRINT '>>Insert data into: bronze.crm_cust_info';
        BULK insert bronze.crm_sales_details from '/datasets/source_crm/sales_details.csv'
        with (
            Firstrow =2,
            fieldterminator =',',
            tablock
        );
        set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + 'seconds';
        print '---------------------------------------------------------------';
        print '---------------------------------------------';
        PRINT 'Loading ERP Tables';
        print '---------------------------------------------';
        set @start_time =GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE table bronze.erp_cust_az12;
        PRINT '>>Insert data into: bronze.crm_cust_info';
        BULK insert bronze.erp_cust_az12 from '/datasets/source_erp/CUST_AZ12.csv'
        with (
            Firstrow =2,
            fieldterminator =',',
            tablock
        );
        set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
        print '---------------------------------------------------------------';
        set @start_time =GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE table bronze.erp_loc_a101;
        PRINT '>>Insert data into: bronze.crm_cust_info';
        BULK insert bronze.erp_loc_a101 from '/datasets/source_erp/LOC_A101.csv'
        with (
            Firstrow =2,
            fieldterminator =',',
            tablock
        );
        set @end_time =getdate();
        print '>> Load duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) as VARCHAR) + ' seconds';
        print '---------------------------------------------------------------';
        set @start_time =GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE table bronze.erp_px_cat_g1v2;
        PRINT '>>Insert data into: bronze.crm_cust_info';
        BULK insert bronze.erp_px_cat_g1v2 from '/datasets/source_erp/PX_CAT_G1V2.csv'
        with (
            Firstrow =2,
            fieldterminator =',',
            tablock
        );
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
