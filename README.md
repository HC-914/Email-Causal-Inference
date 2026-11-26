# Email-Causal-Inference
Causal inference analysis of email marketing effectiveness using SQL and R
# Email Marketing Effectiveness: Causal Inference with SQL & R

## Project Overview

This project evaluates the causal impact of email marketing campaigns on customer spending using the Hillstrom Email Marketing Dataset (64,000 customers).

The objective is to determine whether marketing emails generate incremental spending and whether campaign effectiveness varies across customer segments.

## Tools and Technologies

- **SQL / SQLite:** Data storage, extraction and exploration
- **R:** Statistical modelling and causal inference
- **RStudio:** Development environment
- **dplyr:** Data manipulation
- **ggplot2:** Data visualisation

## Methodology

- Average Treatment Effect (ATE) estimation
- Direct comparison of randomised marketing treatments
- Conditional Average Treatment Effect (CATE) estimation
- Linear regression with interaction terms
- Hypothesis testing and 95% confidence intervals

## Key Findings

| Comparison | Estimated incremental spending |
|---|---:|
| Men's Email vs No Email | +$0.7698 |
| Women's Email vs No Email | +$0.4244 |
| Men's Email vs Women's Email | +$0.3454 |

Both email treatments significantly increased average spending compared with the control group.

Men's Emails also generated a statistically significant higher average spending outcome than Women's Emails (p = 0.01761).

Subgroup analysis revealed differences in estimated treatment effects across shopping channels. However, the overall channel interaction test was not significant (p = 0.3524).

Historical spending and purchase recency also showed no statistically significant linear treatment interactions in the models examined.

## Business Implications

Men's Email was the strongest campaign overall in terms of gross incremental spending.

The subgroup results do not currently provide sufficient evidence to justify selecting different campaigns based solely on shopping channel.

## Project Files

- `scripts/` — R scripts for analysis
- `sql/` — SQL exploration queries
- `figures/` — CATE visualisation
- `report/` — Complete project report
- `data/` — Dataset, where redistribution is permitted

## Dataset

Kevin Hillstrom, *MineThatData E-Mail Analytics and Data Mining Challenge* (2008).

## Limitations

Customer spending is highly skewed, and subgroup effect estimates have varying degrees of uncertainty. Additional robustness checks would help evaluate the sensitivity of the conclusions.
