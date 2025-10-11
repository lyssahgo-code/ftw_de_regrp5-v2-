{{ config(materialized="table", schema="mart", tags=["fact","regrp5"], cluster_by=["OrderKey"]) }}

with order_products as (
    select *
    from {{ source('clean', 'regrp5_insta_order_products_prior') }} 

    union all

    select *
    from {{ source('clean', 'regrp5_insta_order_products_train') }}
)

select
    op.order_id as OrderKey,
    op.product_id,
    p.aisle_id,
    p.department_id,
    op.add_to_cart_order,
    op.reordered
from order_products op
left join {{ source('clean', 'regrp5_insta_products') }} p on op.product_id = p.product_id
order by op.order_id