-- stg_fx_rates must have one row per payment per currency.
select payment_id, currency_code, count(*) as n
from {{ ref('stg_fx_rates') }}
group by payment_id, currency_code
having count(*) > 1
