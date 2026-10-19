
{{ config(
    materialized='table',
    tags=['curated', 'taxi', 'data_quality']
) }}

SELECT
    taxi_type,
    source_month,
    source_file,
    pickup_datetime,
    dropoff_datetime,
    trip_duration_minutes,
    trip_distance,
    fare_amount,
    total_amount,

    CASE
        WHEN trip_duration_minutes > 1440
            THEN 'DURATION_OVER_24_HOURS'

        WHEN trip_duration_minutes > 180
             AND trip_distance <= 2
            THEN 'LONG_DURATION_SHORT_DISTANCE'

        WHEN trip_duration_minutes > 180
             AND fare_amount <= 0
            THEN 'LONG_DURATION_NONPOSITIVE_FARE'

        WHEN trip_duration_minutes > 180
            THEN 'DURATION_OVER_3_HOURS'
    END AS anomaly_reason

FROM {{ ref('fct_taxi_trips') }}

WHERE
    trip_duration_minutes > 180
