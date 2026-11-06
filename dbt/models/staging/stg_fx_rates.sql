-- Staging: the rates JSON unpacked, one row per payment per currency.
-- Grain is per payment not per day: on the same day the same currency has slightly
-- different rates in different countries (1,086 snapshots over 181 days, assumption A2a),
-- so (rate_date, currency_code) is not unique - keeping the payment grain
-- units_per_usd: units of the currency per 1 USD (assumption A2), e.g. MXN ~ 19-25.

with source as (
    select
        trim(external_ref)                          as payment_id,
        cast(date_time at time zone 'UTC' as date)  as rate_date,
        cast(rates as json)                         as rates
    from {{ source('globepay_raw', 'acceptance_report') }}
),

unpacked as (
    select
        payment_id,
        rate_date,
        key                                         as rate_key,
        rates
    from source, unnest(json_keys(rates)) as k(key)
)

select
    payment_id,
    upper(trim(rate_key))                                          as currency_code,
    rate_date,
    cast(json_extract(rates, '$.' || rate_key) as double)          as units_per_usd
from unpacked
