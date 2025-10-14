{{ config(materialized="table", schema="clean", tags=["staging","instacart"]) }}

-- Standardize column names/types per table; no business logic.
select
    CAST(aisle_id AS Int64)      AS aisle_id,
    CAST(aisle AS String)         AS aisle

from {{ source('raw', 'raw___insta_aisles') }}
