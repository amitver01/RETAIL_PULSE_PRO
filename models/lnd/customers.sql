{{ config(
    materialized='incremental',
    unique_key='CUSTOMER_ID'
) }}

SELECT
    CUSTOMER_ID,
    TRIM(CUSTOMER_NAME) AS CUSTOMER_NAME,
    LOWER(EMAIL) AS EMAIL,
    CITY,
    STATE,
    SIGNUP_DATE,
    STATUS
FROM {{ source('stg', 'CUSTOMERS') }}