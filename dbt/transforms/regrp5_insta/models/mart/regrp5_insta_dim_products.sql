{{ config(materialized="table", schema="mart", tags=["dimension","regrp5"], cluster_by=["ProductKey"]) }}

select
  product_id as ProductKey,
  product_name
from {{ source('clean', 'regrp5_insta_products') }}
ORDER BY product_id