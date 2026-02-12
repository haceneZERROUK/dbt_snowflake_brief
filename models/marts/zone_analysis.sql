{{
  config(
    materialized='table',
    schema='FINAL'
  )
}}

select
  pulocationid as pickup_location_id,
  
  -- Volume
  count(*) as trip_volume,
  
  -- Revenus
  sum(total_amount) as total_revenue,
  avg(total_amount) as avg_revenue_per_trip,
  sum(tip_amount) as total_tips,
  
  -- Distance
  avg(trip_distance) as avg_distance_miles,
  
  -- Durée
  avg(trip_duration_minutes) as avg_duration_minutes,
  
  -- Popularité (pourcentage du total des trajets)
  count(*) * 100.0 / sum(count(*)) over () as popularity_percentage,
  
  -- Ranking
  row_number() over (order by count(*) desc) as popularity_rank

from {{ ref('stg_yellow_taxi_trips') }}
group by pulocationid
order by trip_volume desc
