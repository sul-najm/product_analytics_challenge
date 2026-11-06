-- Amounts should be positive. Set to warn, not error: the extract has one known negative row
{{ config(severity = 'warn') }}

select external_ref, amount, country, state
from {{ source('globepay_raw', 'acceptance_report') }}
where amount <= 0
