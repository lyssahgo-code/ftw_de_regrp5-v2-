{{ config(materialized="table", schema="clean", tags=["staging","instacart"]) }}

-- Standardize column names/types per table; no business logic.
select
    CAST(department_id AS Int64)      AS department_id,
    CAST(department AS String)         AS department

from {{ source('raw', 'raw___insta_departments') }}
