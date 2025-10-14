{{ config(materialized="view", schema="mart") }}


with cln as (
  select * from {{ ref('regrp5_insta_products') }}
),

violations as (
  select
    product_id,
    product_name,
    aisle_id,
    department_id,
    multiIf(
      product_id <= 0,                    'nonpositive_product_id',
      product_name in ['missing'],        'missing_product_name',
      aisle_id <= 0,                      'nonpositive_aisle_id',
      department_id <= 0,                 'nonpositive_department_id',
      product_id is null,                 'null_product_id',
      product_name is null,               'null_product_name',
      aisle_id is null,                   'null_aisle_id',
      department_id is null,              'null_department_id',
      'ok'
    ) as dq_issue
  from cln
)
select *
from violations
where dq_issue != 'ok'