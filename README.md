# Deel x Globepay: Product Analytics Challenge

Code and data behind the analysis of Globepay card payments (5,430 payments, Jan-Jun 2019).

## Structure
| Path | What it is |
|---|---|
| `notebook/analysis.ipynb` | Exploration, data checks, analysis, charts |
| `sql/` | The three queries, plus a setup view over the CSVs |
| `dbt/` | Data model: staging, intermediate, marts, tests |
| `docs/` | Data model diagrams (lineage, ER) in Mermaid |
| `figures/` | Charts exported by the notebook, and the two diagrams as PNGs |
| `data/raw/` | The two provided CSVs |

## How to run
Requires Python 3.9-3.13 (the range dbt 1.10 supports). From the `product_analytics_challenge` folder:

```bash
python3 -m venv .venv
source .venv/bin/activate             # Windows: .venv\Scripts\activate
pip install -r requirements.txt

python sql/run_queries.py             # prints the 3 query results
cd dbt && dbt build && cd ..          # dbt must run from inside dbt/; expect 59 pass, 1 known warning
jupyter lab notebook/analysis.ipynb   # opens in the browser; Run All. Ctrl+C in the terminal to stop
```

## Key assumptions
Referenced by ID in code comments.

| # | Assumption |
|---|---|
| A1 | `amount` is in major units (1020.46 = $1,020.46), although the API spec says minor units |
| A2 | USD = amount / rates[currency]; `rates` gives units of each currency per 1 USD |
| A2a | `rates` is a per-payment FX snapshot, so each payment is converted at its own rate |
| A2b | UAE payments are in USD, not AED |
| A2c | Timestamps are UTC, and all day and month buckets are UTC |
| A3 | Acceptance rate = accepted / all payments, by count |
| A4 | Chargeback data only covers payments up to 20 Jan 2019, so it isn't used for trends |
| A5 | Chargeback rate is measured on accepted payments only |
| A6 | The one negative amount (-£23.78) is kept and flagged, not removed |
| A7 | The PDF API spec provided is the same as the `globepay_api.html` named in the brief |
| A8 | `country` is the card's issuing country, as the spec defines it |
| A9 | `status` and `source` are dropped because they're constant; warn-level dbt tests flag any new value |
