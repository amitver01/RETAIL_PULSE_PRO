{{ config(
    materialized='incremental',
    unique_key='CUSTOMER_ID',
    incremental_strategy='merge'
) }}

WITH latest_lnd AS (

    SELECT
        CUSTOMER_ID,
        CUSTOMER_NAME,
        EMAIL,
        CITY,
        STATE,
        SIGNUP_DATE,
        STATUS,
        LAST_UPDATED,
        OPERATION_FLAG,
        LOAD_TIMESTAMP,

        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER_ID
            ORDER BY LOAD_TIMESTAMP DESC
        ) AS RN

    FROM {{ ref('lnd_customers') }}

)

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    EMAIL,
    CITY,
    STATE,
    SIGNUP_DATE,
    STATUS,
    LAST_UPDATED,
    OPERATION_FLAG,
    LOAD_TIMESTAMP

FROM latest_lnd

WHERE RN = 1