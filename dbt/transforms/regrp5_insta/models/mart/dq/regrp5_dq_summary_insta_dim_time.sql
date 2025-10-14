{{ config(materialized="view", schema="mart") }}

with src as (
  select * from {{ source('raw','raw___insta_orders') }}
),
cln as (
  select * from {{ ref('regrp5_insta_orders') }}
),

counts as (
  select
    (select count() from src)  as row_count_raw,
    (select count() from cln)  as row_count_clean
),
nulls as (
  select
    round(100.0 * countIf(order_id is null) / nullif(count(),0), 2) as pct_null_order_id,
    round(100.0 * countIf(user_id is null) / nullif(count(),0), 2) as pct_null_user_id,
    round(100.0 * countIf(eval_set is null) / nullif(count(),0), 2) as pct_null_eval_set,
    round(100.0 * countIf(order_number is null) / nullif(count(),0), 2) as pct_null_order_number,
    round(100.0 * countIf(order_dow is null) / nullif(count(),0), 2) as pct_null_order_dow,
    round(100.0 * countIf(order_hour_of_day is null) / nullif(count(),0), 2) as pct_null_hour_of_day,
    round(100.0 * countIf(days_since_prior_order is null) / nullif(count(),0), 2) as pct_null_prior_days
  from cln
),
domains as (
  select
    countIf(eval_set not in ('prior','train','test')) as invalid_eval_set,
    countIf(order_dow not in (0,1,2,3,4,5,6)) as invalid_order_dow
  from cln
),
bounds as (
  select
    countIf(order_id <= 0) as nonpositive_order_id,
    countIf(user_id <= 0) as nonpositive_user_id,
    countIf(order_number <= 0) as nonpositive_order_number,
    countIf(order_hour_of_day > 23 or order_hour_of_day < 0) as out_of_range_order_hour
  from cln
),
joined as (
  select
    counts.row_count_raw as total_rows_raw,
    counts.row_count_clean as total_rows_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.pct_null_order_id,
    nulls.pct_null_user_id,
    nulls.pct_null_eval_set,
    nulls.pct_null_order_number,
    nulls.pct_null_order_dow,
    nulls.pct_null_hour_of_day,
    nulls.pct_null_prior_days,
    domains.invalid_eval_set,
    domains.invalid_order_dow,
    bounds.nonpositive_order_id,
    bounds.nonpositive_user_id,
    bounds.nonpositive_order_number,
    bounds.out_of_range_order_hour,
    now() as dq_run_ts
  from counts
  cross join nulls
  cross join domains
  cross join bounds
)

select * from joined