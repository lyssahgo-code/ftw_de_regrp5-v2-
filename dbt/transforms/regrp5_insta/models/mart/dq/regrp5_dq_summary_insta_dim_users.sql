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
    round(100.0 * countIf(user_id is null) / nullif(count(),0), 2) as pct_null_user_id
  from cln
),

bounds as (
  select
    countIf(user_id <= 0) as nonpositive_user_id
  from cln
),
joined as (
  select
    counts.row_count_raw as total_rows_raw,
    counts.row_count_clean as total_rows_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.pct_null_user_id,
    bounds.nonpositive_user_id,
    now() as dq_run_ts
  from counts
  cross join nulls
  cross join bounds
)

select * from joined