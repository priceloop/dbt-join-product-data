
{{ 
    config(
        alias=env_var('DESTINATION_TABLE', var('destination_table', ''))
    )
 }}

with temp_table as (
    select
        seller_sku as SKU,
        asin1 as ASIN,
        item_name as "item name",
        item_description as "item description",
        status as "status",
        merchant_shipping_group as "merchant shipping group",
        item_condition as "item condition",
        cd."sellable_inventory" as "sellable inventory",
        cd.marketplace as "marketplace"
        -- cd."fulfillment-center-id" as "fulfillment"
        -- cd.fulfillment as "fulfillment"
        
    from  {{ 
        source(
            env_var('DATABASE_SCHEMA', var('source_schema', '')),
            env_var('SOURCE_MERCHANT_LISTING_ALL_DATA', var('source_table', ''))
        ) 
    }}  mlad
    inner join {{
        source(
            env_var('DATABASE_SCHEMA', var('source_schema', '')),
            env_var('SOURCE_FBA_FULFILLMENT_CURRENT_INVENTORY_REPORT', var('source_table', ''))
        )
    }} cd on mlad.seller_sku = cd.sku 
)

select 
    *
    from temp_table