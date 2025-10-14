{{ config(materialized="view", schema="mart") }}

with src as (
  select * from {{ source('raw','raw___insta_products') }}
),
cln as (
  select * from {{ ref('regrp5_insta_products') }}
),

counts as (
  select
    (select count() from src)  as row_count_raw,
    (select count() from cln)  as row_count_clean
),
nulls as (
  select
    round(100.0 * countIf(product_id is null) / nullif(count(),0), 2) as pct_null_product_id,
    round(100.0 * countIf(product_name is null) / nullif(count(),0), 2) as pct_null_product_name,
    round(100.0 * countIf(aisle_id is null) / nullif(count(),0), 2) as pct_null_aisle_id,
    round(100.0 * countIf(department_id is null) / nullif(count(),0), 2) as pct_null_department_id
  from cln
),
domains as (
  select
    countIf(product_name in ('missing')) as missing_product_name
  from cln
),
bounds as (
  select
    countIf(product_id <= 0)           as nonpositive_product_id,
    countIf(aisle_id <= 0)           as nonpositive_aisle_id,
    countIf(department_id <= 0)           as nonpositive_department_id
  from cln
),
joined as (
  select
    counts.row_count_raw as total_rows_raw,
    counts.row_count_clean as total_rows_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.pct_null_product_id,
    nulls.pct_null_product_name,
    nulls.pct_null_aisle_id,
    nulls.pct_null_department_id,
    domains.missing_product_name,
    bounds.nonpositive_product_id,
    bounds.nonpositive_aisle_id,
    now() as dq_run_ts
  from counts
  cross join nulls
  cross join domains
  cross join bounds
)

select * from joined