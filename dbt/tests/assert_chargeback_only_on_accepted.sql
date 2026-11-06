-- A declined payment moves no money, so it cannot be charged back (assumption A5).
-- Any row here means the two reports disagree.

select a.external_ref, a.state, c.chargeback
from {{ source('globepay_raw', 'acceptance_report') }} a
join {{ source('globepay_raw', 'chargeback_report') }} c
  on trim(a.external_ref) = trim(c.external_ref)
where c.chargeback
  and upper(trim(a.state)) <> 'ACCEPTED'
