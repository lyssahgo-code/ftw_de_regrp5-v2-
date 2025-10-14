{{ config(materialized="view", schema="mart") }}

with cln as (
  select *, 'prior' as source_table from {{ ref('regrp5_insta_order_products_prior') }}
  union all
  select *, 'train' as source_table from {{ ref('regrp5_insta_order_products_train') }}
),


violations as (
  select
    source_table,
    order_id,
    product_id,
    add_to_cart_order,
    reordered,
    multiIf(
      order_id <= 0, 'nonpositive_order_id',
      product_id <= 0, 'nonpositive_product_id',
      add_to_cart_order <= 0, 'nonpositive_add_to_cart_order',
      product_id is null, 'null_product_id',
      order_id is null, 'null_order_id',
      reordered not in (0,1), 'invalid_reordered_flag',
      'ok'
    ) as dq_issue
  from cln
)

select *
from violations
where dq_issue != 'ok'
