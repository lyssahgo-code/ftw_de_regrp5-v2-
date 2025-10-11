{{ config(materialized="table", schema="mart", tags=["dimension","regrp5"], cluster_by=["UserKey"]) }}

select
  user_id as UserKey
from {{ source('clean', 'regrp5_insta_orders') }}
ORDER BY user_id