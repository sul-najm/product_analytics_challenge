-- Transactions in the Acceptance report that are missing chargeback data
-- "Missing" = no matching row in the Chargeback report (anti-join on external_ref),
-- or a matching row whose chargeback value is NULL.
--
-- Fault-tolerance choices:
--   * LEFT JOIN keeps every acceptance row; unmatched ones have NULL chargeback columns.
--     (An INNER JOIN would silently hide exactly the rows we are looking for.)
--   * external_ref is TRIMmed on both sides in 00_setup.sql, so a stray space cannot make a
--     match look missing.
--   * Both failure types are caught and labelled in missing_reason.
--
-- Result on this dataset: 0 rows. Every one of the 5,430 payments has a chargeback record.
-- (Chargebacks only appear on payments up to 20 Jan, so later records are likely not yet
-- reported: see assumption A4.)

SELECT
    a.external_ref,
    a.date_time,
    a.state,
    a.country,
    a.currency,
    a.amount,
    ROUND(a.amount_usd, 2)                                       AS amount_usd,
    CASE WHEN c.external_ref IS NULL THEN 'no chargeback record'
         ELSE 'chargeback value is NULL' END                     AS missing_reason
FROM acceptance a
LEFT JOIN chargeback c
       ON a.external_ref = c.external_ref
WHERE c.external_ref IS NULL
   OR c.chargeback IS NULL
ORDER BY a.date_time;
