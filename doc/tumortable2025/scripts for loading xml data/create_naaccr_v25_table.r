# you could use different connection methods like RJDBC.

library(RJDBC)

# create a connection to NAACCR database and the following connection would be depending on your system configuration.
drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver","[Path to JDBC Driver]/mssql-jdbc-12.4.1.jre8.jar", identifier.quote="`")
conn <- dbConnect(drv,"jdbc:sqlserver://hc-redwdb1stg.healthcare.uiowa.edu:1433;DatabaseName=[database name];integratedSecurity=true;encrypt=true;trustServerCertificate=true") # modify it as needed for your configuration


# load item v25 
tmp = dbGetQuery(conn, "select item_num, length, XML_NAACCR_ID from [schema name].[NAACCR_ITEM_v25] order by PARENT_XML_ELEMENT, Item_num")

# create script to create naaccr_v25 table [database name].[schema name].naaccr_v25.
sql = paste0("create table [schema name].naaccr_v25( PATID varchar(18), ")  # PATID is synthetic ID used in Pcornet 

for(i in 1:(length(tmp[,1])-1))
{
    if(tmp[i,2] < 6)
        sql = paste0(sql, tmp[i,3], " char(", tmp[i,2], "), ")
    else
        sql = paste0(sql, tmp[i,3], " varchar(", tmp[i,2], "), ")
}

sql = paste0(sql, tmp[length(tmp[,1]), 3], " varchar(", tmp[length(tmp[,1]), 2], "))")

# run the script to create a table
dbSendUpdate(conn, sql)

# close connection
dbDisconnect(conn)

