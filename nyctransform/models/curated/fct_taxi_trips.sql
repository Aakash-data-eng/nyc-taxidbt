
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

)

select
    *,

    datediff(
        SECOND,
        pickup_datetime,
        dropoff_datetime
    ) / 60.0 as trip_duration_minutes,

    cast(pickup_datetime as date) as pickup_date,

    hour(pickup_datetime) as pickup_hour

from valid_trips
