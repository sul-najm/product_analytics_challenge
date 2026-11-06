-- Mart: one row per payment attempt. The table BI reads for drill-downs.
-- Declined/accepted USD are pre-split so dashboards sum a column instead of re-writing CASE logic.
-- In production this would be incremental on attempted_at_utc; the extract is small, so a table here.

select
    payment_id,
    provider_ref,
    attempted_at_utc,
    attempt_date,
    attempt_month,
    country_code,
    currency_code,
    is_usd_currency,
    state,
    is_accepted,
    is_declined,
    cvv_provided,
    amount_local,
    fx_rate_to_usd,
    amount_usd,
    cast(case when is_accepted then amount_usd else 0 end as decimal(18, 6))  as accepted_amount_usd,
    cast(case when is_declined then amount_usd else 0 end as decimal(18, 6))  as declined_amount_usd,
    is_chargeback,
    is_chargeback_data_reliable,
    is_negative_amount,
    cast(current_timestamp at time zone 'UTC' as timestamp)  as dbt_loaded_at   -- UTC, like attempted_at_utc
from {{ ref('int_payments_enriched') }}
