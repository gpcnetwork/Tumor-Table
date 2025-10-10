options(java.parameters = "-Xmx4096m")

library(XML)
library(xml2)
library(RJDBC)

#options("width"=Sys.getenv("COLUMNS")) # ictssqlsbs1  CLTSQL2COPY

SortMat <- function(Mat, Sort, decreasing)
{ 
    if(decreasing == F){
        m <- do.call("order", c(as.data.frame(Mat[, Sort]),na.last = TRUE,decreasing = FALSE))
    }else{
        m <- do.call("order", c(as.data.frame(Mat[, Sort]),na.last = TRUE,decreasing = TRUE))
    }
    return(Mat[m, ]) 
}

SpRange <- function(str)
{
    return (t(data.frame(unlist(strsplit(str, "-")))))
}

xmlNs <- function(exp)
{ 
    if(!is.na(str_locate(exp, "^\\s*<Item")[1])){
        return(1)
    }else if(!is.na(str_locate(exp, "^\\s*<Patient>")[1])){
        return(2)
    }else if(!is.na(str_locate(exp, "^\\s*<Tumor>")[1])){
        return(3)
    }else return(0)
}

xmlNe <- function(exp)
{ 
    if(!is.na(str_locate(exp, "</Item>\\s*$")[1])){
        return(1)
    }else if(!is.na(str_locate(exp, "</Patient>\\s*$")[1])){
        return(2)
    }else if(!is.na(str_locate(exp, "</Tumor>\\s*$")[1])){
        return(3)
    }else return(0)
}

# create a connection to NAACCR database and the following connection would be depending on your system configuration.
drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver","[Path to JDBC Driver]/mssql-jdbc-12.4.1.jre8.jar", identifier.quote="`")
conn <- dbConnect(drv,"jdbc:sqlserver://[database server]:1433;DatabaseName=[database name];integratedSecurity=true;encrypt=true;trustServerCertificate=true") # modify it as needed for your configuration


# load item v25 
item = dbGetQuery(conn, "SELECT * FROM [schema name].[NAACCR_ITEM_v25] order by PARENT_XML_ELEMENT, item_Num")

###############################################################################################

# load NAACCR xml file "sample.XML"
con = file("[path to sample.XML]/sample.XML", open="r")
linn <-readLines(con)
close(con)

status = 0
lenI = 1
lenP = 1
lenT = 1
items = list()
patients = list()
tumors = list()
pnote = ""
tnote = ""

for(i in 1:length(linn))
{
    if(xmlNs(linn[i]) == 3){ 
        status = 3
  #      tnote = linn[i]
        next
    }else if(xmlNe(linn[i]) == 3){
        tumors[lenT] = tnote # paste0(tnote,"\n", linn[i])
        tnote = ""
        status = 0
        lenT = lenT + 1
        next
    }else if((status == 2) && (xmlNs(linn[i]) == 1)){
        pnote = paste0(pnote,"\n", linn[i])
        next
    }else if((status == 3) && (xmlNs(linn[i]) == 1)){
        tnote = paste0(tnote,"\n", linn[i])
        next
    }else if((status == 0) && (xmlNs(linn[i]) == 1)){
        items[lenI] = linn[i]
        lenI = lenI + 1
        next 
    }else if(xmlNs(linn[i]) == 2){
        status = 2
        pnote = linn[i]
        next
    }else if(xmlNe(linn[i]) == 2){
        for(j in 1:(lenT - 1)){
            patients[lenP] = paste0(pnote,"\n",tumors[j], "\n", linn[i])
            lenP = lenP + 1
        }
        status = 0
        pnote = ""
        lenT = 1
        tumors = list()
    }
}

######################################################################################
# load objects to table 

nr = xmlRoot(xmlParse(items[1][[1]]))
inlist = xmlGetAttr(nr, "naaccrId")
ivlist = paste0("'", xmlValue(nr), "'")

for(i in 2:length(items))
{
    nr = xmlRoot(xmlParse(items[i][[1]]))
    inlist = paste0(inlist, ",", xmlGetAttr(nr, "naaccrId"))
    ivlist = paste0(ivlist, ",'", xmlValue(nr), "'")
}

for(i in 1:length(patients))
{
    pnlist = inlist
    pvlist = ivlist
    nr = xmlRoot(xmlParse(patients[i][[1]]))
    for(j in 1:xmlSize(nr))
    {
        pnlist = paste0(pnlist,",", xmlGetAttr(nr[[j]], "naaccrId"))
        pvlist = paste0(pvlist,",'", gsub("'","''",xmlValue(nr[[j]])), "'")
    }
    sql = paste0("insert into [schema name].naaccr_v25 (", pnlist, ") values ( ",pvlist,")")
    dbSendUpdate(conn, sql)
}

################################################################################################################
# close database connection
dbDisconnect(conn)




