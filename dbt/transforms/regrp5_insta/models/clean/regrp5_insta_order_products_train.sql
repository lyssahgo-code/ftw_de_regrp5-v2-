{{ config(materialized="table", schema="clean", tags=["staging","instacart"]) }}

-- Standardize column names/types per table; no business logic.
select
    CAST(order_id AS Int64)      AS order_id,
    CAST(product_id AS Int64)      AS product_id,
    CAST(add_to_cart_order AS Int64)         AS add_to_cart_order,
    CAST(reordered AS Bool)         AS reordered

from {{ source('raw', 'raw___insta_order_products_train') }}
