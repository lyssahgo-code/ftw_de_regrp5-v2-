{{ config(materialized="view", schema="mart") }}


with cln as (
  select * from {{ ref('regrp5_insta_departments') }}
),

violations as (
  select
    department_id,
    department,
    multiIf(
      department_id <= 0,             'nonpositive_department_id',
      department in ['missing'],      'missing_department',
      department_id is null,          'null_department_id',
      department is null,             'null_deparment',
      'ok'
    ) as dq_issue
  from cln
)
select *
from violations
where dq_issue != 'ok'