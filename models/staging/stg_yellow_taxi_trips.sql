{{
  config(
    materialized='view',
    schema='STAGING'
  )
}}

with source as (
  select *
  from {{ source('nyc_taxi', 'yellow_taxi_trips') }}
),

cleaned as (
  select
    -- IDs
    vendorid,
    ratecodeid,
    pulocationid,
    dolocationid,
    
    -- Dates (conversion si epoch/number → timestamp)
    to_timestamp(tpep_pickup_datetime) as pickup_datetime,
    to_timestamp(tpep_dropoff_datetime) as dropoff_datetime,
    
    -- Métriques de base
    passenger_count,
    trip_distance,
    
    -- Montants
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    
    -- Paiement
    payment_type,
    store_and_fwd_flag,
    
    -- ===== ENRICHISSEMENTS =====
    
    -- Durée du trajet (minutes)
    datediff('minute', to_timestamp(tpep_pickup_datetime), to_timestamp(tpep_dropoff_datetime)) as trip_duration_minutes,
    
    -- Vitesse moyenne (mph)
    case 
      when datediff('minute', to_timestamp(tpep_pickup_datetime), to_timestamp(tpep_dropoff_datetime)) > 0
      then (trip_distance / (datediff('minute', to_timestamp(tpep_pickup_datetime), to_timestamp(tpep_dropoff_datetime)) / 60.0))
      else null
    end as avg_speed_mph,
    
    -- Pourcentage de pourboire
    case 
      when fare_amount > 0 
      then (tip_amount / fare_amount) * 100
      else 0
    end as tip_percentage,
    
    -- Dimensions temporelles
    date_trunc('day', to_timestamp(tpep_pickup_datetime)) as pickup_date,
    extract(hour from to_timestamp(tpep_pickup_datetime)) as pickup_hour,
    extract(dayofweek from to_timestamp(tpep_pickup_datetime)) as pickup_dayofweek,
    dayname(to_timestamp(tpep_pickup_datetime)) as pickup_day_name,
    extract(month from to_timestamp(tpep_pickup_datetime)) as pickup_month,
    monthname(to_timestamp(tpep_pickup_datetime)) as pickup_month_name,
    extract(year from to_timestamp(tpep_pickup_datetime)) as pickup_year
    
  from source
  
  where 
    -- ===== FILTRES QUALITÉ =====
    fare_amount >= 0
    and total_amount >= 0
    and to_timestamp(tpep_pickup_datetime) < to_timestamp(tpep_dropoff_datetime)
    and trip_distance between 0.1 and 100
    and pulocationid is not null
    and dolocationid is not null
)

select * from cleaned
