{{ config(materialized="table", schema="mart", tags=["fact","regrp5"], cluster_by=["OrderKey"]) }}

select
    order_id as OrderKey,
    user_id,
    order_number,
    concat(leftPad(CAST(order_dow AS String), 1), leftPad(CAST(order_hour_of_day AS String), 2, '0')) AS time_id,
    days_since_prior_order
from {{ source('clean', 'regrp5_insta_orders') }}
order by order_id