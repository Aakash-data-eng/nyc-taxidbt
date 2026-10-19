
select *
from {{ ref('stg_yellow_taxi_trips') }}
where trip_distance < 0
