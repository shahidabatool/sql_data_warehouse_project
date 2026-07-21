-- we will be using view, try to join via left join with master table at left
use DataWarehouse
go 


create VIEW gold.dim_customer AS
SELECT 
    ROW_NUMBER()over (order by cst_id) as customer_key,
    ci.cst_id as customer_id,
    ci.cst_key as cutomer_number,
    ci.cst_first_name as first_name,
    ci.cst_last_name as last_name,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    case 
        when ci.cst_gndr not in ('n/a','unknown') then ci.cst_gndr --CRM is the master for gndr
        else COALESCE(ca.gen,'n/a')
    end as gender,
    ca.bdate as birthdate,
    ci.cst_created_date as create_date  
from silver.crm_cust_info ci 
left join silver.erp_cust_az12 ca 
on         ci.cst_key=ca.cid
LEFT JOIN silver.erp_loc_a101 la  
on       ci.cst_key=la.cid;

--Rule one after joining check for duplicates using count and group by 
--select cst_id,count(*) from()t
--group by cst_id
--having count(*)> 1

--two coulmns are same so for that we will do a data integration
-- this method where we are integrating two column into one is called data integration 
SELECT distinct 
    ci.cst_gndr,
    ca.gen,
    case 
        when ci.cst_gndr not in ('n/a','unknown') then ci.cst_gndr --CRM is the master for gndr
        else COALESCE(ca.gen,'n/a')
    end as new_gen
from silver.crm_cust_info ci 
left join silver.erp_cust_az12 ca 
on         ci.cst_key=ca.cid
LEFT JOIN silver.erp_loc_a101 la  
on       ci.cst_key=la.cid
order by 1,2


-- create a suurogate key to use in model 
--check data quality 
SELECt * from gold.dim_customer
-------------------------------------------------------------------
-- comibing next table now in this we only keep product that are in market 
create view gold.dim_products as 
select 
ROW_NUMBER()over(order by pn.prd_start_dt,pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as catergory_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
from silver.crm_prd_info pn 
left join silver.erp_px_cat_g1v2 pc 
on pn.cat_id=pc.id
where prd_end_dt is null  -- filter out old historical data null mean product is still in market


-- check the view
select * from gold.dim_products

--------------------------------------------------------
--data look up when we join table to get a column form another table 
create view gold.fact_sales as 
select 
    sd.sls_ord_num as order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as shipping_date,
    sd.sls_due_dt as due_date,
    sd.sls_sales as sales_amount,
    sd.sls_quantity as quantity,
    sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_products pr  
on sd.sls_prd_key=pr.product_number
left join gold.dim_customer cu  
on sd.sls_cust_id=cu.customer_id

select * from gold.fact_sales
