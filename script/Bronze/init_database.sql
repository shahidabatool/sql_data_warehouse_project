
--This script create a new Database 

use master;
GO
create database DataWarehouse;
-- create a Data warehouse
use DataWarehouse;
-- create Schema

create SCHEMA bronze;
GO
create SCHEMA silver;
GO
create SCHEMA gold;
GO
