{{ config(
    materialized='incremental'
) }}

{% if not is_incremental() %}

SELECT
    PRODUCT_ID,
    PRODUCT_NAME,
    CATEGORY,
    BRAND,
    UNIT_PRICE,
    STOCK_QTY,
    STATUS,
    'I' AS OPERATION_FLAG,
    LAST_UPDATED,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP

FROM {{ source('stg','PRODUCTS') }}

{% else %}

WITH latest_product AS (

    SELECT *
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER
    (
        PARTITION BY PRODUCT_ID
        ORDER BY LOAD_TIMESTAMP DESC
    ) = 1

)

SELECT

    s.PRODUCT_ID,
    s.PRODUCT_NAME,
    s.CATEGORY,
    s.BRAND,
    s.UNIT_PRICE,
    s.STOCK_QTY,
    s.STATUS,

    CASE
        WHEN l.PRODUCT_ID IS NULL THEN 'I'
        ELSE 'U'
    END AS OPERATION_FLAG,

    s.LAST_UPDATED,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP

FROM {{ source('stg','PRODUCTS') }} s

LEFT JOIN latest_product l
ON s.PRODUCT_ID = l.PRODUCT_ID

WHERE

    l.PRODUCT_ID IS NULL

OR

(
       NVL(s.PRODUCT_NAME,'') <> NVL(l.PRODUCT_NAME,'')
    OR NVL(s.CATEGORY,'')     <> NVL(l.CATEGORY,'')
    OR NVL(s.BRAND,'')        <> NVL(l.BRAND,'')
    OR s.UNIT_PRICE           <> l.UNIT_PRICE
    OR s.STOCK_QTY            <> l.STOCK_QTY
    OR NVL(s.STATUS,'')       <> NVL(l.STATUS,'')
)

{% endif %}