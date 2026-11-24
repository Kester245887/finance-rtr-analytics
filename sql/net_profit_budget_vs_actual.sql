WITH budget_totals AS (
    SELECT
        SUM(
            CASE WHEN category = 'Revenue'
                THEN budget_amount ELSE 0 END
        ) AS budget_revenue,

        SUM(
            CASE WHEN category = 'Expense'
                THEN budget_amount ELSE 0 END
        ) AS budget_expenses

    FROM budget
    WHERE period = '2026-11'
),

actual_totals AS (
    SELECT
        SUM(
            CASE WHEN coa.account_type = 'Revenue'
                THEN gl.credit - gl.debit ELSE 0 END
        ) AS actual_revenue,

        SUM(
            CASE WHEN coa.account_type = 'Expense'
                THEN gl.debit - gl.credit ELSE 0 END
        ) AS actual_expenses

    FROM general_ledger AS gl

    INNER JOIN chart_of_accounts AS coa
        ON gl.account_code = coa.account_code

    WHERE coa.account_type IN ('Revenue', 'Expense')
)

SELECT
    ROUND(budget_revenue, 2) AS budget_revenue,
    ROUND(actual_revenue, 2) AS actual_revenue,

    ROUND(budget_expenses, 2) AS budget_expenses,
    ROUND(actual_expenses, 2) AS actual_expenses,

    ROUND(budget_revenue - budget_expenses, 2)
        AS budget_net_profit,

    ROUND(actual_revenue - actual_expenses, 2)
        AS actual_net_profit,

    ROUND(
        (actual_revenue - actual_expenses)
        - (budget_revenue - budget_expenses),
        2
    ) AS net_profit_variance,

    ROUND(
        (
            (actual_revenue - actual_expenses)
            - (budget_revenue - budget_expenses)
        ) * 100.0
        / (budget_revenue - budget_expenses),
        2
    ) AS net_profit_variance_percentage

FROM budget_totals, actual_totals;