{{ config(materialized="view", schema="mart") }}


with cln as (
  select * from {{ ref('regrp5_insta_aisles') }}
),

violations as (
  select
    aisle_id,
    aisle,
    multiIf(
      aisle_id <= 0,         'nonpositive_aisle_id',
      aisle in ['missing'],  'missing_aisle',
      aisle_id is null,      'null_aisle_id',
      aisle is null,         'null_aisle',
      'ok'
    ) as dq_issue
  from cln
)
select *
from violations
where dq_issue != 'ok'