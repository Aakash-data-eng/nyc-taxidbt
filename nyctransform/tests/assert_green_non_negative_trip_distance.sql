select *
from {{ ref('stg_green_taxi_trips') }}
where trip_distance < 0