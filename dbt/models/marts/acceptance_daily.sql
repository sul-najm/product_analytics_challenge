-- Mart: one row per day x country x currency. The table dashboards read.

select
    attempt_date,
    country_code,
    currency_code,
    count(*)                                              as total_attempts,
    count(case when is_accepted then 1 end)               as accepted_attempts,
    count(case when is_declined then 1 end)               as declined_attempts,
    cast(sum(amount_usd) as decimal(18, 2))               as total_amount_usd,
    cast(sum(accepted_amount_usd) as decimal(18, 2))      as accepted_amount_usd,
    cast(sum(declined_amount_usd) as decimal(18, 2))      as declined_amount_usd,
    count(case when is_chargeback then 1 end)             as chargebacks,
    count(case when cvv_provided then 1 end)              as cvv_provided_attempts
from {{ ref('payment_attempts') }}
group by attempt_date, country_code, currency_code
