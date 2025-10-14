{{ config(materialized="view", schema="mart") }}


with cln as (
  select * from {{ ref('regrp5_insta_orders') }}
),

violations as (
  select
    user_id,
    multiIf(
      user_id <= 0,                      'nonpositive_userid',
      user_id is null,                   'null_user',
      'ok'
    ) as dq_issue
  from cln
)
select *
from violations
where dq_issue != 'ok'