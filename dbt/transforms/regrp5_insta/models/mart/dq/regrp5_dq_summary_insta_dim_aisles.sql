{{ config(materialized="view", schema="mart") }}

with src as (
  select * from {{ source('raw','raw___insta_aisles') }}
),
cln as (
  select * from {{ ref('regrp5_insta_aisles') }}
),

counts as (
  select
    (select count() from src)  as row_count_raw,
    (select count() from cln)  as row_count_clean
),
nulls as (
  select
    round(100.0 * countIf(aisle_id is null) / nullif(count(),0), 2) as pct_null_aisleid,
    round(100.0 * countIf(aisle is null) / nullif(count(),0), 2) as pct_null_aisle
  from cln
),
domains as (
  select
    countIf(aisle in ('missing')) as missing_aisle
  from cln
),
bounds as (
  select
    countIf(aisle_id <= 0) as nonpositive_aisleid
  from cln
),
joined as (
  select
    counts.row_count_raw as total_rows_raw,
    counts.row_count_clean as total_rows_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.pct_null_aisleid,
    nulls.pct_null_aisle,
    domains.missing_aisle,
    bounds.nonpositive_aisleid,
    now() as dq_run_ts
  from counts
  cross join nulls
  cross join domains
  cross join bounds
)

select * from joined