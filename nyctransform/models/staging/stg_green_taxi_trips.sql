
{{ config(materialized='view') }}

select
    cast(VendorID as int) as vendor_id,
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,
    cast(passenger_count as bigint) as passenger_count,
    cast(trip_distance as double) as trip_distance,
    cast(RatecodeID as bigint) as rate_code_id,
    cast(store_and_fwd_flag as string) as store_and_fwd_flag,
    cast(PULocationID as int) as pickup_location_id,
    cast(DOLocationID as int) as dropoff_location_id,
    cast(payment_type as bigint) as payment_type,
    cast(fare_amount as double) as fare_amount,
    cast(extra as double) as extra,
    cast(mta_tax as double) as mta_tax,
    cast(tip_amount as double) as tip_amount,
    cast(tolls_amount as double) as tolls_amount,
    cast(improvement_surcharge as double) as improvement_surcharge,
    cast(total_amount as double) as total_amount,
    cast(congestion_surcharge as double) as congestion_surcharge,
    cast(null as double) as airport_fee,
    cast(ehail_fee as double) as ehail_fee,
    cast(trip_type as bigint) as trip_type,
    cast(cbd_congestion_fee as double) as cbd_congestion_fee,
    cast(request_source as string) as request_source,
    cast(source_month as string) as source_month,
    cast(source_file as string) as source_file,
    cast(ingested_at as timestamp) as ingested_at,
    'green' as taxi_type

from {{ source('taxi_landing', 'green_taxi_trips') }}
