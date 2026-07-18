{{ config(
    materialized='incremental',
    unique_key='CUSTOMER_ID'
) }}

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    EMAIL,
    CITY,
    STATE,
    SIGNUP_DATE,
    STATUS,
    LAST_UPDATED
FROM {{ source('stg', 'CUSTOMERS') }}
