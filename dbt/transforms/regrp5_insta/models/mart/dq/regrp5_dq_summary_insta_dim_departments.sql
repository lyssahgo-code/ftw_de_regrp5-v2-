{{ config(materialized="view", schema="mart") }}

with src as (
  select * from {{ source('raw','raw___insta_departments') }}
),
cln as (
  select * from {{ ref('regrp5_insta_departments') }}
),

counts as (
  select
    (select count() from src)  as row_count_raw,
    (select count() from cln)  as row_count_clean
),
nulls as (
  select
    round(100.0 * countIf(department_id is null) / nullif(count(),0), 2) as pct_null_departmentid,
    round(100.0 * countIf(department is null) / nullif(count(),0), 2) as pct_null_department
  from cln
),
domains as (
  select
    countIf(department in ('missing')) as missing_department
  from cln
),
bounds as (
  select
    countIf(department_id <= 0) as nonpositive_departmentid
  from cln
),
joined as (
  select
    counts.row_count_raw as total_rows_raw,
    counts.row_count_clean as total_rows_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.pct_null_departmentid,
    nulls.pct_null_department,
    domains.missing_department,
    bounds.nonpositive_departmentid,
    now() as dq_run_ts
  from counts
  cross join nulls
  cross join domains
  cross join bounds
)

select * from joined