{{
  config(
    materialized='table',
    schema='FINAL'
  )
}}

select
  pickup_date,
  
  -- Volume
  count(*) as total_trips,
  
  -- Distance
  avg(trip_distance) as avg_distance_miles,
  sum(trip_distance) as total_distance_miles,
  
  -- Revenus
  sum(total_amount) as total_revenue,
  avg(total_amount) as avg_revenue_per_trip,
  sum(tip_amount) as total_tips,
  
  -- Durée
  avg(trip_duration_minutes) as avg_duration_minutes,
  
  -- Pourboire
  avg(tip_percentage) as avg_tip_percentage,
  
  -- Passagers
  avg(passenger_count) as avg_passengers

from {{ ref('stg_yellow_taxi_trips') }}
group by pickup_date
order by pickup_date
