{{ config(materialized="view", schema="mart") }}


with cln as (
  select * from {{ ref('regrp5_insta_orders') }}
),

violations as (
  select
    order_id,
    user_id,
    eval_set,
    order_number,
    order_dow,
    order_hour_of_day,
    days_since_prior_order,
    multiIf(
      order_id <= 0,                                        'nonpositive_order_id',
      user_id <= 0,                                         'nonpositive_user_id',
      eval_set not in ['prior','train','test'],             'invalid_eval_set',
      order_number <= 0,                                    'nonpositive_order_number',
      order_dow not in [0,1,2,3,4,5,6],                     'invalid_dow',
      (order_hour_of_day > 23 OR order_hour_of_day < 0),       'invalid_order_hour',
      days_since_prior_order is null,                       'null_prior_days',
      order_id is null,                                     'null_order_id',
      user_id is null,                                      'null_user_id',
      eval_set is null,                                     'null_eval_set',
      order_number is null,                                 'null_order_number',
      order_dow is null,                                    'null_order_dow',
      order_hour_of_day is null,                            'null_hour_of_day',
      'ok'
    ) as dq_issue
  from cln
)
select *
from violations
where dq_issue != 'ok'