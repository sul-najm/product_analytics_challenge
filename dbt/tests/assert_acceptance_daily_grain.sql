-- acceptance_daily must have one row per day x country x currency.
select attempt_date, country_code, currency_code, count(*) as n
from {{ ref('acceptance_daily') }}
group by attempt_date, country_code, currency_code
having count(*) > 1
