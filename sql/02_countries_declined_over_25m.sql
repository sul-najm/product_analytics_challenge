-- Countries where the declined amount (USD) went over $25M
-- Measured over the full period in the data (2019-01-01 to 2019-06-30).
--
-- Fault-tolerance choices:
--   * state and country are already cleaned with UPPER(TRIM()) in 00_setup.sql, so 'Declined',
--     'DECLINED ' or 'fr' cannot split or drop a country.
--   * amount_usd = amount / rates[currency], using each row's own rate (rates change daily).
--   * missing_fx_rows counts declined rows whose currency has no rate in the JSON. Those rows
--     would have a NULL amount_usd and be silently left out of SUM(). Should be 0 (0 here).
--   * HAVING filters on the aggregate; WHERE could not, because the total does not exist yet.

SELECT
    country,
    COUNT(*)                                                        AS declined_payments,
    CAST(SUM(CASE WHEN amount_usd IS NULL THEN 1 ELSE 0 END) AS INTEGER) AS missing_fx_rows,
    ROUND(SUM(amount_usd), 2)                                       AS declined_amount_usd,
    ROUND(SUM(amount_usd) / 1000000, 2)                             AS declined_amount_usd_m
FROM acceptance
WHERE declined_flag = 1
GROUP BY country
HAVING SUM(amount_usd) > 25000000
ORDER BY declined_amount_usd DESC;
