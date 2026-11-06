-- Setup: views over the raw CSVs (DuckDB reads them in place; nothing is loaded or copied).
-- Run from the repo root. Shared by every query in this folder.
--
-- Defensive cleaning is done ONCE here, so every query benefits:
--   UPPER(TRIM(x)) on text codes. TRIM removes leading/trailing spaces ('ACCEPTED ' -> 'ACCEPTED');
--                  UPPER makes case consistent ('Accepted' -> 'ACCEPTED'). The API spec documents
--                  state as "Accepted or Declined" while the data has 'ACCEPTED', so a plain
--                  state = 'ACCEPTED' would silently misclassify rows if the format ever changed.
--   accepted_flag  1 / 0 integer (0 also for NULL or unexpected states), so a rate is a plain
--                  SUM / COUNT(*) and no row drops out of the denominator.
--   date_time      converted to naive UTC; values end in 'Z' (UTC), but tools display them in the
--                  session time zone, which would shift month/day buckets (assumption A2c).
--   amount_usd     amount / rates[currency]; amounts assumed to be major units (assumption A1).

CREATE OR REPLACE VIEW acceptance AS
SELECT
    TRIM(external_ref)                                                 AS external_ref,
    ref,
    status,
    source,
    date_time AT TIME ZONE 'UTC'                                       AS date_time,
    UPPER(TRIM(state))                                                 AS state,
    CASE WHEN UPPER(TRIM(state)) = 'ACCEPTED' THEN 1 ELSE 0 END        AS accepted_flag,
    CASE WHEN UPPER(TRIM(state)) = 'DECLINED' THEN 1 ELSE 0 END        AS declined_flag,
    cvv_provided,
    amount,
    UPPER(TRIM(country))                                               AS country,
    UPPER(TRIM(currency))                                              AS currency,
    rates,
    CAST(json_extract(rates, '$.' || UPPER(TRIM(currency))) AS DOUBLE) AS fx,
    amount / CAST(json_extract(rates, '$.' || UPPER(TRIM(currency))) AS DOUBLE) AS amount_usd
FROM read_csv('data/raw/acceptance_report.csv', delim = ';', header = true);

-- Chargeback report: ','-separated. One row per payment, joined on external_ref.
-- external_ref is trimmed on both sides so a stray space cannot break the join.
CREATE OR REPLACE VIEW chargeback AS
SELECT
    TRIM(external_ref)                                                 AS external_ref,
    status,
    source,
    chargeback
FROM read_csv('data/raw/chargeback_report.csv', header = true);
