-- Staging: one row per payment attempt, 1:1 with the acceptance report.
-- Faithful rename + type cleaning only.
-- TRIM on keys, UPPER(TRIM()) on codes, UTC timestamps.
-- status and source are constant (TRUE / GLOBALPAY) so they are dropped.
-- rates is unpacked separately in stg_fx_rates.

with source as (
    select * from {{ source('globepay_raw', 'acceptance_report') }}
)

select
    trim(external_ref)                               as payment_id,
    trim(ref)                                        as provider_ref,
    date_time at time zone 'UTC'                     as attempted_at_utc,   -- assumption A2c
    cast(date_time at time zone 'UTC' as date)       as attempt_date,
    upper(trim(state))                               as state,
    upper(trim(state)) = 'ACCEPTED'                  as is_accepted,
    cvv_provided,
    cast(amount as decimal(18, 2))                   as amount_local,       -- major units, assumption A1
    upper(trim(currency))                            as currency_code,
    upper(trim(country))                             as country_code
from source
