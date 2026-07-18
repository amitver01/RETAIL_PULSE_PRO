

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    EMAIL,
    CITY,
    STATE,
    SIGNUP_DATE,
    STATUS,
    LAST_UPDATED
FROM {{ ref('lnd_customers') }}



