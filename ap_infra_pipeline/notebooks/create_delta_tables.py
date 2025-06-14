import os

# Tenta pegar do ambiente, se não encontrar usa valor default
volume_path = os.getenv("VOLUME_PATH", "/Volumes/ted_dev/default/raw")
schema_path = os.getenv("SCHEMA_NAME", "dev_default")
catalog_name =  os.getenv("CATALOG_NAME", "dev_default")

# Tabelas do Meltano (JSONL)
json_tables = [
    "PurchaseOrderDetail",
    "PurchaseOrderHeader",
    "SalesOrderDetail",
    "SalesOrderHeader"
]

# Tabelas do Embulk (Parquet)
parquet_tables = [
    "humanresources_department",
    "humanresources_employee",
    "humanresources_employeedepartmenthistory",
    "humanresources_employeepayhistory",
    "humanresources_jobcandidate",
    "humanresources_shift",
    "person_address",
    "person_addresstype",
    "person_businessentity",
    "person_businessentityaddress",
    "person_businessentitycontact",
    "person_contacttype",
    "person_countryregion",
    "person_emailaddress",
    "person_password",
    "person_person",
    "person_personphone",
    "person_phonenumbertype",
    "person_stateprovince",
    "production_billofmaterials",
    "production_culture",
    "production_document",
    "production_illustration",
    "production_location",
    "production_product",
    "production_productcategory",
    "production_productcosthistory",
    "production_productdescription",
    "production_productdocument",
    "production_productinventory",
    "production_productlistpricehistory",
    "production_productmodel",
    "production_productmodelillustration",
    "production_productmodelproductdescriptionculture",
    "production_productphoto",
    "production_productproductphoto",
    "production_productreview",
    "production_productsubcategory",
    "production_scrapreason",
    "production_transactionhistory",
    "production_transactionhistoryarchive",
    "production_unitmeasure",
    "production_workorder",
    "production_workorderrouting",
    "purchasing_productvendor",
    "purchasing_shipmethod",
    "purchasing_vendor",
    "sales_countryregioncurrency",
    "sales_creditcard",
    "sales_currency",
    "sales_currencyrate",
    "sales_customer",
    "sales_personcreditcard",
    "sales_salesorderheadersalesreason",
    "sales_salesperson",
    "sales_salespersonquotahistory",
    "sales_salesreason",
    "sales_salestaxrate",
    "sales_salesterritory",
    "sales_salesterritoryhistory",
    "sales_shoppingcartitem",
    "sales_specialoffer",
    "sales_specialofferproduct",
    "sales_store"
]


# JSONL -> Delta
for table in json_tables:
    path = f"{volume_path}.db/api_{table}.jsonl"
    delta = f"{catalog_name}.{schema_path}.api_{table.lower()}"
    print(f"▶ Criando tabela Delta: {delta}")
    spark.sql(f"""
        CREATE OR REPLACE TABLE {delta}
        USING DELTA
        AS SELECT * FROM json.{path}
    """)

# Parquet -> Delta
for table in parquet_tables:
    path = f"{volume_path}/db_{table}.parquet"
    delta = f"{catalog_name}.{schema_path}.db_{table}"
    print(f"▶ Criando tabela Delta: {delta}")
    spark.sql(f"""
        CREATE OR REPLACE TABLE {delta}
        USING DELTA
        AS SELECT * FROM parquet.{path}
    """)