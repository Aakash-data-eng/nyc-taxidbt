
{% set processing_month = var('processing_month', '2026-08') %}

{{ config(
    materialized='incremental',
    incremental_strategy='replace_where',
    incremental_predicates="source_month = '" ~ processing_month ~ "'",
    file_format='delta',
    tags=['curated', 'taxi', 'fact']
) }}

with all_trips as (

    select * from {{ ref('stg_yellow_taxi_trips') }}

    union all

    select * from {{ ref('stg_green_taxi_trips') }}

),

valid_trips as (

    select *
    from all_trips
    where
        pickup_datetime is not null
        and dropoff_datetime is not null
        and dropoff_datetime >= pickup_datetime
        and source_month = '{{ processing_month }}'

),

calculated_trips as (

    select
        *,

        datediff(
            SECOND,
            pickup_datetime,
            dropoff_datetime
        ) / 60.0 as trip_duration_minutes,

        cast(pickup_datetime as date) as pickup_date,

        hour(pickup_datetime) as pickup_hour,

        case
            when trip_distance > 0
                then fare_amount / trip_distance
            else null
        end as fare_per_mile,

        case
            when fare_amount > 0
                then (tip_amount / fare_amount) * 100.0
            else null
        end as tip_percentage,

        case
            when trip_distance > 0
                then total_amount / trip_distance
            else null
        end as total_amount_per_mile

    from valid_trips

),

classified_trips as (

    select
        *,

        case
            when trip_duration_minutes <= 15
                then 'SHORT'
            when trip_duration_minutes <= 45
                then 'MEDIUM'
            else 'LONG'
        end as duration_category,

        case
            when trip_duration_minutes > 1440
                then 'DURATION_OVER_24_HOURS'
            when trip_duration_minutes > 180
                 and trip_distance <= 2
                then 'LONG_DURATION_SHORT_DISTANCE'
            when trip_duration_minutes > 180
                 and fare_amount <= 0
                then 'LONG_DURATION_NONPOSITIVE_FARE'
            when trip_duration_minutes > 180
                then 'DURATION_OVER_3_HOURS'
            else 'NORMAL'
        end as trip_quality_flag,

        case
            when trip_distance is null
                then 'MISSING_DISTANCE'
            when trip_distance <= 0
                then 'NONPOSITIVE_DISTANCE'
            when fare_amount is null
                then 'MISSING_FARE'
            when fare_amount <= 0
                then 'NONPOSITIVE_FARE'
            when total_amount is null
                then 'MISSING_TOTAL_AMOUNT'
            when total_amount < 0
                then 'NEGATIVE_TOTAL_AMOUNT'
            else 'OK'
        end as fare_distance_quality_flag

    from calculated_trips

)

select *
from classified_trips
