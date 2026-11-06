-- Every payment's currency must have a positive rate in its rates JSON.
-- Otherwise amount_usd is NULL and silently drops out of every USD total.

select external_ref, currency, rates
from {{ source('globepay_raw', 'acceptance_report') }}
where try_cast(json_extract(rates, '$.' || upper(trim(currency))) as double) is null
   or try_cast(json_extract(rates, '$.' || upper(trim(currency))) as double) <= 0
