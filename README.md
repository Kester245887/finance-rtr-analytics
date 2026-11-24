# Month-End Financial Close & Reconciliation Analytics System

## Project Overview

This project demonstrates a practical, data-driven approach to the month-end Record-to-Report (RtR) process for a fictional company, Northstar Global Services Ltd.

The project covers financial data preparation, general ledger validation, bank reconciliation, financial statement preparation, budget-versus-actual analysis, internal control monitoring, and management reporting for November 2026.

It combines Python and SQL to demonstrate how financial operations can be supported through data analysis, automated checks, and structured reporting.

> **Data disclaimer:** Northstar Global Services Ltd. is fictional. All financial records and transactions in this project are synthetically generated for educational and portfolio demonstration purposes.

## Business Objectives

The project was designed to demonstrate the ability to:

- Validate general ledger transactions and journal entries.
- Reconcile bank statement transactions against general ledger records.
- Identify, classify, and document reconciliation exceptions.
- Prepare a Profit and Loss Statement and Balance Sheet.
- Compare actual financial performance against budget.
- Monitor month-end financial controls.
- Produce management reporting and an audit trail.
- Validate consistency between Python-based and SQL-based financial reporting.

## Technology Stack

| Technology | Application |
|---|---|
| Python | Financial data processing and automation |
| pandas | Data manipulation and financial reporting |
| NumPy | Numerical operations |
| Matplotlib | Financial exception visualisation |
| SQLite | Relational financial data storage |
| SQL | Financial reporting and control queries |
| Jupyter Notebook | Reproducible analysis and documentation |
| Git / GitHub | Version control and project presentation |

## Project Workflow

### 1. Financial Data Preparation

Synthetic datasets were generated for:

- General ledger
- Chart of accounts
- Bank statement
- Accounts payable
- Accounts receivable
- Budget

### 2. General Ledger Validation

Journal entries were checked for:

- Debit and credit balancing
- Expected journal line counts
- Duplicate journal lines
- Valid account codes
- Transactions within the reporting period

### 3. Bank Reconciliation

Bank statement transactions were matched against general ledger bank-account movements.

The reconciliation process identified:

- Transactions missing from the bank statement
- Duplicate bank transactions
- Amount mismatches
- Transactions not recorded in the general ledger

An unrecorded bank service fee was also identified and posted through a simulated adjustment journal.

### 4. Financial Statement Preparation

The project generated:

- Profit and Loss Statement
- Balance Sheet
- Financial summary

The Balance Sheet was checked against the accounting equation:

**Assets = Liabilities + Equity**

### 5. Budget vs Actual Analysis

Actual revenue and expenses were compared with the approved synthetic budget.

The analysis includes:

- Budget amounts
- Actual amounts
- Variances
- Variance percentages
- Favourable and unfavourable classifications

### 6. Internal Controls and Audit Trail

Month-end controls were designed to monitor journal integrity, account validity, reporting-period accuracy, and outstanding bank reconciliation exceptions.

An exception register and audit trail were created to document identified issues and simulated resolution actions.

### 7. SQL Financial Reporting

The raw financial datasets were loaded into SQLite.

SQL queries independently reproduced key financial reports, including:

- Account balances
- Net profit
- Bank reconciliation
- Budget vs actual
- Management KPIs
- Month-end control summary

Python and SQL outputs were compared to verify consistency.

## Key Financial Results

**Reporting period:** November 2026  
**Reporting currency:** EUR

| Financial Indicator | Result |
|---|---:|
| Total Revenue | €101,563.91 |
| Total Expenses | €68,915.59 |
| Net Profit | €32,648.32 |
| Net Profit Margin | 32.15% |
| Total Assets | €117,497.99 |
| Total Liabilities | €34,849.67 |
| Total Equity | €82,648.32 |

The Balance Sheet reconciled, with a difference of €0.00.

## Reconciliation Findings

The bank reconciliation identified two outstanding exceptions:

| Exception | Transaction | Amount | Severity | Status |
|---|---|---:|---|---|
| Missing from Bank Statement | TXN00015 | €11,780.60 | High | Open |
| Duplicate Bank Transaction | TXN00018 | €11,340.88 | High | Open |

The total flagged transaction value was €23,121.48. This represents the value of flagged records, not a confirmed financial loss.

The bank service fee of €45 was recorded through a simulated adjustment journal and marked as resolved in the audit trail.

## Internal Control Results

The month-end control review covered eight controls:

| Control | Result |
|---|---:|
| Journal entries reviewed | 52 |
| Unbalanced journal entries | 0 |
| Unexpected journal line counts | 0 |
| Duplicate journal lines | 0 |
| Invalid account codes | 0 |
| Transactions outside reporting period | 0 |
| Open bank reconciliation exceptions | 2 |
| High-severity open exceptions | 2 |

The two outstanding reconciliation exceptions remain open for investigation.

## Python vs SQL Validation

Independent Python and SQL outputs were compared across the eight month-end controls.

- Controls compared: 8
- Passed: 8
- Requiring investigation due to Python/SQL disagreement: 0

**Overall validation result: PASS**

This confirms consistency between the two reporting implementations. It does not mean that all underlying financial exceptions have been resolved.

## Management Reporting

The project produces a management report in PDF and Markdown formats, summarising financial performance, reconciliation findings, internal controls, and recommended management actions.

See the `reports/` directory.

## Project Structure

```text
finance-rtr-analytics/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── 01_project_setup.ipynb
│   ├── 02_generate_financial_data.ipynb
│   ├── 03_month_end_analysis.ipynb
│   └── 04_sql_financial_reporting.ipynb
│
├── sql/
│   ├── bank_reconciliation.sql
│   ├── budget_vs_actual.sql
│   ├── management_kpi_report.sql
│   ├── month_end_control_report.sql
│   └── net_profit_budget_vs_actual.sql
│
├── reports/
│   ├── bank_reconciliation_exceptions.png
│   ├── november_2026_management_report.md
│   └── November_2026_Management_Report_FINAL.pdf
│
├── src/
├── dashboard/
├── README.md
└── .gitignore
```

## How to Run the Project

1. Clone or download the repository.
2. Install the required Python packages:

```bash
pip install pandas numpy matplotlib jupyter
```

3. Open the project in Jupyter Notebook.
4. Run the notebooks in numerical order, beginning with `01_project_setup.ipynb`.
5. The SQL reporting notebook uses Python's built-in `sqlite3` module to create and query the SQLite database.

The project uses synthetic data, so no external financial data connection is required.

## Limitations

- All company and transaction records are fictional.
- Reconciliation exceptions are simulated and require investigation; they do not establish actual fraud or financial loss.
- Audit-trail actions demonstrate a simulated workflow and are not external evidence of completed approvals.
- The project is a portfolio demonstration, not a production accounting system.
- Financial reporting and control logic are designed for the stated synthetic dataset and reporting period.

## Professional Relevance

This project demonstrates practical skills relevant to Record-to-Report and finance operations, including:

- General ledger analysis
- Bank reconciliation
- Financial data validation
- Month-end close support
- Budget monitoring
- Exception management
- Internal control reporting
- SQL-based financial reporting
- Management reporting

It demonstrates how Python and SQL can support accurate, traceable, and repeatable financial reporting processes.
