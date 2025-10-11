{{ config(materialized="table", schema="mart", tags=["dimension","regrp5"], cluster_by=["DepartmentKey"]) }}

select
  department_id as DepartmentKey,
  department
from {{ source('clean', 'regrp5_insta_departments') }}
ORDER BY department_id