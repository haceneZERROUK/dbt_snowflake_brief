{{
  config(
    materialized='table',
    schema='STAGING'
  )
}}

select * from {{ ref('stg_yellow_taxi_trips') }}
