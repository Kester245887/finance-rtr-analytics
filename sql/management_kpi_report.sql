WITH financials AS (
    SELECT
        SUM(
            CASE WHEN coa.account_type = 'Revenue'
                THEN gl.credit - gl.debit ELSE 0 END
        ) AS total_revenue,

        SUM(
            CASE WHEN coa.account_type = 'Expense'
                THEN gl.debit - gl.credit ELSE 0 END
        ) AS total_expenses

    FROM general_ledger AS gl

    INNER JOIN chart_of_accounts AS coa
        ON gl.account_code = coa.account_code

    WHERE coa.account_type IN ('Revenue', 'Expense')
),

budgets AS (
    SELECT
        SUM(CASE WHEN category = 'Revenue'
            THEN budget_amount ELSE 0 END) AS budget_revenue,

        SUM(CASE WHEN category = 'Expense'
            THEN budget_amount ELSE 0 END) AS budget_expenses

    FROM budget
    WHERE period = '2026-11'
),

gl_bank AS (
    SELECT
        transaction_id,
        ROUND(SUM(debit - credit), 2) AS gl_signed_amount
    FROM general_ledger
    WHERE account_code = 1000
      AND transaction_id != 'OPENING001'
    GROUP BY transaction_id
),

bank AS (
    SELECT
        transaction_id,
        COUNT(*) AS bank_record_count,
        ROUND(SUM(signed_amount), 2) AS bank_signed_amount
    FROM bank_statement
    GROUP BY transaction_id
),

all_transactions AS (
    SELECT transaction_id FROM gl_bank
    UNION
    SELECT transaction_id FROM bank
),

reconciliation AS (
    SELECT
        t.transaction_id,
        g.gl_signed_amount,
        b.bank_signed_amount,
        b.bank_record_count,

        CASE
            WHEN b.bank_record_count > 1
                THEN 'Duplicate Bank Transaction'
            WHEN g.transaction_id IS NULL
                THEN 'Not Recorded in General Ledger'
            WHEN b.transaction_id IS NULL
                THEN 'Missing from Bank Statement'
            WHEN ABS(g.gl_signed_amount - b.bank_signed_amount) > 0.01
                THEN 'Amount Mismatch'
            ELSE 'Matched'
        END AS reconciliation_status

    FROM all_transactions AS t

    LEFT JOIN gl_bank AS g
        ON t.transaction_id = g.transaction_id

    LEFT JOIN bank AS b
        ON t.transaction_id = b.transaction_id
),

reconciliation_kpis AS (
    SELECT
        SUM(
            CASE WHEN reconciliation_status != 'Matched'
                THEN 1 ELSE 0 END
        ) AS open_exceptions,

        SUM(
            CASE WHEN reconciliation_status != 'Matched'
                THEN
                    CASE
                        WHEN gl_signed_amount IS NOT NULL
                            THEN ABS(gl_signed_amount)
                        ELSE ABS(bank_signed_amount)
                    END
                ELSE 0
            END
        ) AS flagged_transaction_value

    FROM reconciliation
),

journal_kpis AS (
    SELECT
        COUNT(DISTINCT transaction_id) AS journal_entries_reviewed
    FROM general_ledger
),

metrics AS (
    SELECT
        f.total_revenue,
        f.total_expenses,
        f.total_revenue - f.total_expenses AS net_profit,

        (f.total_revenue - f.total_expenses)
            * 100.0 / NULLIF(f.total_revenue, 0)
            AS net_profit_margin,

        (f.total_revenue - b.budget_revenue)
            * 100.0 / NULLIF(b.budget_revenue, 0)
            AS revenue_budget_variance_pct,

        (f.total_expenses - b.budget_expenses)
            * 100.0 / NULLIF(b.budget_expenses, 0)
            AS expense_budget_variance_pct,

        (
            (f.total_revenue - f.total_expenses)
            - (b.budget_revenue - b.budget_expenses)
        ) * 100.0
            / NULLIF(
                b.budget_revenue - b.budget_expenses, 0
            ) AS net_profit_budget_variance_pct,

        r.open_exceptions,
        r.flagged_transaction_value,
        j.journal_entries_reviewed

    FROM financials AS f
    CROSS JOIN budgets AS b
    CROSS JOIN reconciliation_kpis AS r
    CROSS JOIN journal_kpis AS j
)

SELECT 'Total Revenue' AS indicator,
       ROUND(total_revenue, 2) AS value
FROM metrics

UNION ALL

SELECT 'Total Expenses',
       ROUND(total_expenses, 2)
FROM metrics

UNION ALL

SELECT 'Net Profit',
       ROUND(net_profit, 2)
FROM metrics

UNION ALL

SELECT 'Net Profit Margin',
       ROUND(net_profit_margin, 6)
FROM metrics

UNION ALL

SELECT 'Revenue Budget Variance (%)',
       ROUND(revenue_budget_variance_pct, 6)
FROM metrics

UNION ALL

SELECT 'Expense Budget Variance (%)',
       ROUND(expense_budget_variance_pct, 6)
FROM metrics

UNION ALL

SELECT 'Net Profit Budget Variance (%)',
       ROUND(net_profit_budget_variance_pct, 6)
FROM metrics

UNION ALL

SELECT 'Open Reconciliation Exceptions',
       open_exceptions
FROM metrics

UNION ALL

SELECT 'Total Flagged Transaction Value',
       ROUND(flagged_transaction_value, 2)
FROM metrics

UNION ALL

SELECT 'Journal Entries Reviewed',
       journal_entries_reviewed
FROM metrics;