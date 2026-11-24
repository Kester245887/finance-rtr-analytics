WITH actuals AS (
    SELECT
        gl.account_code,
        ROUND(
            SUM(
                CASE
                    WHEN coa.account_type = 'Revenue'
                        THEN gl.credit - gl.debit
                    WHEN coa.account_type = 'Expense'
                        THEN gl.debit - gl.credit
                    ELSE 0
                END
            ), 2
        ) AS actual_amount

    FROM general_ledger AS gl

    INNER JOIN chart_of_accounts AS coa
        ON gl.account_code = coa.account_code

    WHERE coa.account_type IN ('Revenue', 'Expense')

    GROUP BY gl.account_code
)

SELECT
    b.account_code,
    b.account_name,
    b.category,
    b.budget_amount,
    COALESCE(a.actual_amount, 0) AS actual_amount,

    ROUND(
        CASE
            WHEN b.category = 'Revenue'
                THEN COALESCE(a.actual_amount, 0) - b.budget_amount
            ELSE b.budget_amount - COALESCE(a.actual_amount, 0)
        END, 2
    ) AS variance,

    ROUND(
        CASE
            WHEN b.budget_amount = 0 THEN NULL
            ELSE
                (
                    CASE
                        WHEN b.category = 'Revenue'
                            THEN COALESCE(a.actual_amount, 0) - b.budget_amount
                        ELSE b.budget_amount - COALESCE(a.actual_amount, 0)
                    END
                ) * 100.0 / b.budget_amount
        END, 2
    ) AS variance_percentage,

    CASE
        WHEN ABS(
            CASE
                WHEN b.category = 'Revenue'
                    THEN COALESCE(a.actual_amount, 0) - b.budget_amount
                ELSE b.budget_amount - COALESCE(a.actual_amount, 0)
            END
        ) < 0.01
            THEN 'On Budget'

        WHEN
            CASE
                WHEN b.category = 'Revenue'
                    THEN COALESCE(a.actual_amount, 0) - b.budget_amount
                ELSE b.budget_amount - COALESCE(a.actual_amount, 0)
            END > 0
            THEN 'Favourable'

        ELSE 'Unfavourable'
    END AS performance_status

FROM budget AS b

LEFT JOIN actuals AS a
    ON b.account_code = a.account_code

WHERE b.period = '2026-11'

ORDER BY
    b.category,
    b.account_code;