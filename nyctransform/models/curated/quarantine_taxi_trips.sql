
{{ config(
    materialized='table',
    tags=['curated', 'taxi', 'quarantine']
) }}

with all_trips as (

    select * from {{ ref('stg_yellow_taxi_trips') }}

    union all

    select * from {{ ref('stg_green_taxi_trips') }}

)

select
    *,
    case
        when pickup_datetime is null
            then 'MISSING_PICKUP_DATETIME'
        when dropoff_datetime is null
            then 'MISSING_DROPOFF_DATETIME'
        when dropoff_datetime < pickup_datetime
            then 'DROPOFF_BEFORE_PICKUP'
    end as rejection_reason

from all_trips

where
    pickup_datetime is null
    or dropoff_datetime is null
    or dropoff_datetime < pickup_datetime
