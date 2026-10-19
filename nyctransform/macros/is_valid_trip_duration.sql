
{% macro is_valid_trip_duration(pickup_col, dropoff_col) %}
    (
        {{ pickup_col }} IS NOT NULL
        AND {{ dropoff_col }} IS NOT NULL
        AND {{ dropoff_col }} >= {{ pickup_col }}
    )
{% endmacro %}
