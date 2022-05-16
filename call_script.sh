#!/bin/bash 

DATABASE_HOST=localhost \
DATABASE_PORT=5432 \
DATABASE_USERNAME=postgres \
DATABASE_PASSWORD=test3 \
DATABASE_NAME=priceloop \
DATABASE_SCHEMA=public \
SOURCE_MERCHANT_LISTING_ALL_DATA=con_norm \
SOURCE_FBA_FULFILLMENT_CURRENT_INVENTORY_REPORT=get_fba_fulfillment_current_inventory_data \
DESTINATION_TABLE=generated_product \
dbt run  --profiles-dir .
