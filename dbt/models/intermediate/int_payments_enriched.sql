-- Intermediate: joins the FX rate and chargeback record onto each payment.
--   * USD conversion at the payment's own rate (amount_local / units_per_usd)
--   * chargeback join (left join, so a missing record shows up as has_chargeback_record = false)
--   * data-quality flags (missing FX rate, negative amount, chargeback coverage window)
-- One row per payment, 1:1 with stg_payments.

with payments as (
    select * from {{ ref('stg_payments') }}
),

fx as (
    select * from {{ ref('stg_fx_rates') }}
),

chargebacks as (
    select * from {{ ref('stg_chargebacks') }}
)

select
    p.payment_id,
    p.provider_ref,
    p.attempted_at_utc,
    p.attempt_date,
    cast(date_trunc('month', p.attempt_date) as date)          as attempt_month,
    p.country_code,
    p.currency_code,
    p.currency_code = 'USD'                                     as is_usd_currency,
    p.state,
    p.is_accepted,
    not p.is_accepted                                           as is_declined,
    p.cvv_provided,
    p.amount_local,
    fx.units_per_usd                                            as fx_rate_to_usd,
    cast(p.amount_local / fx.units_per_usd as decimal(18, 6))   as amount_usd,
    fx.units_per_usd is not null                                as has_fx_rate,
    coalesce(cb.is_chargeback, false)                           as is_chargeback,
    cb.payment_id is not null                                   as has_chargeback_record,
    -- The chargeback report only covers payments up to 20 Jan 2019 (assumption A4); later payments
    -- show no chargeback because they weren't covered, not because they were clean.
    -- Update the date when Globepay confirms the report window.
    p.attempt_date <= date '2019-01-20'                         as is_chargeback_data_reliable,
    p.amount_local < 0                                          as is_negative_amount   -- assumption A6
from payments p
left join fx
    on  fx.payment_id    = p.payment_id
    and fx.currency_code = p.currency_code
left join chargebacks cb
    on  cb.payment_id = p.payment_id
