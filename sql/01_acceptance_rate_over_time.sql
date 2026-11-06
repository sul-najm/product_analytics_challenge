-- Acceptance rate over time (monthly)
-- Acceptance rate = accepted payments / ALL payments, by count (assumption A3).
--
-- Fault-tolerance choices:
--   * accepted_flag / declined_flag come from 00_setup.sql (UPPER(TRIM(state)), ELSE 0), so
--     case, spaces, NULL or new states cannot silently change the result.
--   * Denominator is COUNT(*): every attempt counts, including any with a NULL state. A NULL
--     outcome is still an attempt, just not an accepted one (accepted_flag = 0). AVG(is_accepted)
--     would silently drop NULL rows from the denominator and overstate the rate: 60 accepted,
--     30 declined, 10 NULL gives 60% here, but 60 / 90 = 66.7% with AVG.
--   * 100.0 forces decimal division (integer division would return 0).
--   * unclassified = rows that are neither ACCEPTED nor DECLINED. Should be 0; if not, the
--     data has an unexpected state value and needs investigating. (0 on this dataset.)
--   * change_vs_prev_month_pp is optional context: LAG() reads the previous month's rate.

WITH monthly AS (
    SELECT
        CAST(DATE_TRUNC('month', date_time) AS DATE)         AS month,
        COUNT(*)                                             AS total_payments,
        CAST(SUM(accepted_flag) AS INTEGER)                  AS accepted,
        CAST(SUM(declined_flag) AS INTEGER)                  AS declined
    FROM acceptance
    GROUP BY 1
)
SELECT
    month,
    total_payments,
    accepted,
    declined,
    total_payments - accepted - declined                                     AS unclassified,
    ROUND(100.0 * accepted / total_payments, 1)                              AS acceptance_rate_pct,
    ROUND(100.0 * accepted / total_payments
          - LAG(100.0 * accepted / total_payments) OVER (ORDER BY month), 1) AS change_vs_prev_month_pp
FROM monthly
ORDER BY month;
