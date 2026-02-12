{{
  config(
    materialized='table',
    schema='FINAL'
  )
}}

select
  pickup_hour,
  
  -- Demande
  count(*) as trip_demand,
  
  -- Revenus
  sum(total_amount) as total_revenue,
  avg(total_amount) as avg_revenue_per_trip,
  
  -- Vitesse
  avg(avg_speed_mph) as avg_speed_mph,
  
  -- Distance
  avg(trip_distance) as avg_distance_miles,
  
  -- Durée
  avg(trip_duration_minutes) as avg_duration_minutes,
  
  -- Pourboire
  avg(tip_percentage) as avg_tip_percentage

from {{ ref('stg_yellow_taxi_trips') }}
group by pickup_hour
order by pickup_hour
