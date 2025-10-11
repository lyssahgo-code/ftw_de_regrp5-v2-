{{ config(materialized="table", schema="mart", tags=["dimension","regrp5"], cluster_by=["TimeKey"]) }}

WITH dow AS (
    SELECT 
        order_dow AS day_of_week,
        multiIf(
            order_dow = 0, 'Sunday',
            order_dow = 1, 'Monday',
            order_dow = 2, 'Tuesday',
            order_dow = 3, 'Wednesday',
            order_dow = 4, 'Thursday',
            order_dow = 5, 'Friday',
            order_dow = 6, 'Saturday',
            NULL
        ) AS day_name
    FROM 
        {{ source('clean', 'regrp5_insta_orders') }} 
    GROUP BY order_dow
),

hour AS (
    SELECT 
        order_hour_of_day AS hour_of_day,
        multiIf(
            order_hour_of_day = 0, 'Midnight',
            (order_hour_of_day >= 1 AND order_hour_of_day <= 6), 'Early Morning',
            (order_hour_of_day >= 7 AND order_hour_of_day <= 11), 'Morning',
            order_hour_of_day = 12, 'Noon',
            (order_hour_of_day >= 13 AND order_hour_of_day <= 17), 'Afternoon',
            (order_hour_of_day >= 18 AND order_hour_of_day <= 20), 'Evening',
            (order_hour_of_day >= 21 AND order_hour_of_day <= 23), 'Late Evening',
            NULL
        ) AS time_of_day
    FROM 
        {{ source('clean', 'regrp5_insta_orders') }}
    GROUP BY order_hour_of_day
)

SELECT
    concat(leftPad(CAST(d.day_of_week AS String), 1), leftPad(CAST(h.hour_of_day AS String), 2, '0')) AS TimeKey,
    d.day_name AS day,
    h.time_of_day AS time
FROM dow d
JOIN hour h
ON 1 = 1
ORDER BY TimeKey