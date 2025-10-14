{{ config(materialized="table", schema="clean", tags=["staging","instacart"]) }}

-- Standardize column names/types per table; no business logic.
select
    CAST(order_id AS Int64)      AS order_id,
    CAST(user_id AS Int64)      AS user_id,
    CAST(eval_set AS String)      AS eval_set,
    CAST(order_number AS Int64)         AS order_number,
    CAST(order_dow AS Int64)         AS order_dow,
    CAST(order_hour_of_day AS Int64)         AS order_hour_of_day,
    CAST(days_since_prior_order AS String)         AS days_since_prior_order

from {{ source('raw', 'raw___insta_orders') }}

