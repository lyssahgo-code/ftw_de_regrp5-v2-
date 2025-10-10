{{ config(materialized="view", schema="clean", tags=["staging","insta"]) }}

--SELECT SQL statement goes here

FROM {{ source('raw', 'raw___insta_order_products_train') }}