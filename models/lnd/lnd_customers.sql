{{ config(
    materialized='incremental'
) }}

{% if not is_incremental() %}

-- Initial Load
SELECT
    s.CUSTOMER_ID,
    s.CUSTOMER_NAME,
    s.EMAIL,
    s.CITY,
    s.STATE,
    s.SIGNUP_DATE,
    s.STATUS,
    'I' AS OPERATION_FLAG,
    s.LAST_UPDATED,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP

FROM {{ source('stg','CUSTOMERS') }} s

{% else %}

-- Incremental Load
WITH latest_lnd AS (

    SELECT *
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY CUSTOMER_ID
        ORDER BY LOAD_TIMESTAMP DESC
    ) = 1

)

SELECT
    s.CUSTOMER_ID,
    s.CUSTOMER_NAME,
    s.EMAIL,
    s.CITY,
    s.STATE,
    s.SIGNUP_DATE,
    s.STATUS,

    CASE
        WHEN l.CUSTOMER_ID IS NULL THEN 'I'
        ELSE 'U'
    END AS OPERATION_FLAG,

    s.LAST_UPDATED,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP

FROM {{ source('stg','CUSTOMERS') }} s

LEFT JOIN latest_lnd l
ON s.CUSTOMER_ID = l.CUSTOMER_ID

WHERE

    l.CUSTOMER_ID IS NULL

    OR

    (
        NVL(s.CUSTOMER_NAME,'') <> NVL(l.CUSTOMER_NAME,'')
        OR NVL(s.EMAIL,'')      <> NVL(l.EMAIL,'')
        OR NVL(s.CITY,'')       <> NVL(l.CITY,'')
        OR NVL(s.STATE,'')      <> NVL(l.STATE,'')
        OR NVL(s.STATUS,'')     <> NVL(l.STATUS,'')
    )

{% endif %}