{{ config(materialized="table", schema="mart", tags=["dimension","regrp5"], cluster_by=["AisleKey"]) }}

select
  aisle_id as AisleKey,
  aisle
from {{ source('clean', 'regrp5_insta_aisles') }}
ORDER BY aisle_id