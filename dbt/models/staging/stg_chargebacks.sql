-- Staging: one row per payment, 1:1 with the chargeback report.
-- status and source are constant and dropped, as in stg_payments.

with source as (
    select * from {{ source('globepay_raw', 'chargeback_report') }}
)

select
    trim(external_ref)  as payment_id,
    chargeback          as is_chargeback
from source
