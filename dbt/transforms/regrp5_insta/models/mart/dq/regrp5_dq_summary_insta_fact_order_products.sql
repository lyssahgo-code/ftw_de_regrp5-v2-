{{ config(materialized="view", schema="mart") }}

with src as (
  select * from {{ source('raw','raw___insta_order_products_prior') }}
  union all
  select * from {{ source('raw','raw___insta_order_products_train') }}
),

cln as (
  select * from {{ ref('regrp5_insta_order_products_prior') }}
  union all
  select * from {{ ref('regrp5_insta_order_products_train') }}
),

counts as (
  select
    (select count() from src)  as row_count_raw,
    (select count() from cln)  as row_count_clean
),
nulls as (
  select
    round(100.0 * countIf(order_id is null) / nullif(count(),0), 2) as pct_null_order_id,
    round(100.0 * countIf(product_id is null) / nullif(count(),0), 2) as pct_null_product_id,
    round(100.0 * countIf(add_to_cart_order is null) / nullif(count(),0), 2) as pct_null_add_to_cart
  from cln
),
domains as (
  select
    countIf(reordered not in (0,1)) as invalid_reordered_flag
  from cln
),
bounds as (
  select
    countIf(order_id <= 0) as nonpositive_order_id,
    countIf(product_id <= 0) as nonpositive_product_id,
    countIf(add_to_cart_order <= 0) as nonpositive_add_to_cart_order
  from cln
),
joined as (
  select
    counts.row_count_raw as total_rows_raw,
    counts.row_count_clean as total_rows_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.pct_null_order_id,
    nulls.pct_null_product_id,
    nulls.pct_null_add_to_cart,
    domains.invalid_reordered_flag,
    bounds.nonpositive_order_id,
    bounds.nonpositive_product_id,
    bounds.nonpositive_add_to_cart_order,
    now() as dq_run_ts
  from counts
  cross join nulls
  cross join domains
  cross join bounds
)

select * from joined