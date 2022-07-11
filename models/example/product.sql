{ { config(
    alias = env_var(
        'DESTINATION_TABLE',
        var('destination_table', '')
    )
) } } with temp_table as (
    select
        seller_sku as Sku,
        asin1 as Asin,
        'DE' as "Marketplace",
        item_name as "Item Name",
        status as "Listing Status",
        case
            when "item_condition" = '1' then 'Used; Like New'
            when "item_condition" = '2' then 'Used; Very Good'
            when "item_condition" = '3' then 'Used; Good'
            when "item_condition" = '4' then 'Used; Acceptable'
            when "item_condition" = '5' then 'Collectible; Like New'
            when "item_condition" = '6' then 'Collectible; Very Good'
            when "item_condition" = '7' then 'Collectible; Good'
            when "item_condition" = '8' then 'Collectible; Acceptable'
            when "item_condition" = '10' then 'Refurbished'
            else 'New'
        end as "Item Condition",
        case
            when Marketplace is not null then cd."sellable_inventory"
            else quantity
        end as "Sellable Inventory",
        item_description as "item description",
        case
            when Marketplace is not null then true
            else false
        end as "Is FBA",
        price as "Amazon Item Price"
    from
        { { source(
            env_var('DATABASE_SCHEMA', var('source_schema', '')),
            env_var(
                'SOURCE_MERCHANT_LISTING_ALL_DATA',
                var('source_table', '')
            )
        ) } } mlad
        left join (
            select
                sku,
                marketplace,
                sum(sellable_inventory) as "sellable_inventory"
            from
                { { source(
                    env_var('DATABASE_SCHEMA', var('source_schema', '')),
                    env_var(
                        'SOURCE_FBA_FULFILLMENT_CURRENT_INVENTORY_REPORT',
                        var('source_table', '')
                    )
                ) } }
            where
                "marketplace" = 'DE'
                and "snapshot_date" =(
                    select
                        distinct snapshot_date
                    from
                        { { source(
                            env_var('DATABASE_SCHEMA', var('source_schema', '')),
                            env_var(
                                'SOURCE_FBA_FULFILLMENT_CURRENT_INVENTORY_REPORT',
                                var('source_table', '')
                            )
                        ) } }
                    order by
                        snapshot_date desc
                    limit
                        1
                )
            group by
                sku,
                marketplace,
                snapshot_date
        ) cd on mlad.seller_sku = cd.sku
)
select
    *
from
    temp_table