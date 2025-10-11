{{ config(materialized="table", schema="clean", tags=["staging","instacart"]) }}

-- Standardize column names/types per table; no business logic.
select
    CAST(product_id AS (Int64)) AS product_id,
    CAST(product_name AS (String)) AS product_name,
    CAST(aisle_id AS (Int64)) AS aisle_id,
    CAST(department_id AS (Int64)) AS department_id

from {{ source('raw', 'raw___insta_products') }}

