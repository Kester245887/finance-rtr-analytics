
WITH journal_summary AS (
    SELECT
        transaction_id,
        SUM(debit) AS total_debit,
        SUM(credit) AS total_credit,
        COUNT(*) AS line_count
    FROM general_ledger
    GROUP BY transaction_id
),

unbalanced_journals AS (
    SELECT COUNT(*) AS result
    FROM journal_summary
    WHERE ABS(total_debit - total_credit) > 0.01
),

unexpected_line_counts AS (
    SELECT COUNT(*) AS result
    FROM journal_summary
    WHERE line_count != 2
),

duplicate_gl_lines AS (
    SELECT COALESCE(SUM(duplicate_count - 1), 0) AS result
    FROM (
        SELECT COUNT(*) AS duplicate_count
        FROM general_ledger
        GROUP BY transaction_id, date, description,
                 department, account_code, debit, credit
        HAVING COUNT(*) > 1
    )
),

invalid_accounts AS (
    SELECT COUNT(*) AS result
    FROM general_ledger gl
    LEFT JOIN chart_of_accounts coa
        ON gl.account_code = coa.account_code
    WHERE coa.account_code IS NULL
),

outside_period AS (
    SELECT COUNT(*) AS result
    FROM general_ledger
    WHERE date < '2026-11-01'
       OR date >= '2026-12-01'
),

gl_bank AS (
    SELECT
        transaction_id,
        SUM(debit - credit) AS gl_amount
    FROM general_ledger
    WHERE account_code = 1000
      AND transaction_id != 'OPENING001'
    GROUP BY transaction_id
),

bank_grouped AS (
    SELECT
        transaction_id,
        COUNT(*) AS bank_count,
        SUM(signed_amount) AS bank_amount
    FROM bank_statement
    GROUP BY transaction_id
),

reconciliation_status AS (
    SELECT
        CASE
            WHEN b.bank_count > 1
                THEN 'Duplicate Bank Transaction'
            WHEN b.transaction_id IS NULL
                THEN 'Missing from Bank Statement'
            WHEN g.transaction_id IS NULL
                THEN 'Not Recorded in General Ledger'
            WHEN ABS(g.gl_amount - b.bank_amount) > 0.01
                THEN 'Amount Mismatch'
            ELSE 'Matched'
        END AS reconciliation_status
    FROM gl_bank g
    LEFT JOIN bank_grouped b
        ON g.transaction_id = b.transaction_id

    UNION ALL

    SELECT
        'Not Recorded in General Ledger' AS reconciliation_status
    FROM bank_grouped b
    LEFT JOIN gl_bank g
        ON b.transaction_id = g.transaction_id
    WHERE g.transaction_id IS NULL
),

open_reconciliation_exceptions AS (
    SELECT COUNT(*) AS result
    FROM reconciliation_status
    WHERE reconciliation_status != 'Matched'
),

high_severity_exceptions AS (
    SELECT COUNT(*) AS result
    FROM exception_register
    WHERE severity = 'High'
      AND status = 'Open'
),

journal_count AS (
    SELECT COUNT(DISTINCT transaction_id) AS result
    FROM general_ledger
)

SELECT
    'Journal entries reviewed' AS control,
    result,
    'Pass' AS status
FROM journal_count

UNION ALL

SELECT
    'Unbalanced journal entries',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Investigate' END
FROM unbalanced_journals

UNION ALL

SELECT
    'Unexpected journal line counts',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Investigate' END
FROM unexpected_line_counts

UNION ALL

SELECT
    'Duplicate journal lines',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Investigate' END
FROM duplicate_gl_lines

UNION ALL

SELECT
    'Invalid account codes',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Investigate' END
FROM invalid_accounts

UNION ALL

SELECT
    'Transactions outside reporting period',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Investigate' END
FROM outside_period

UNION ALL

SELECT
    'Open bank reconciliation exceptions',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Open' END
FROM open_reconciliation_exceptions

UNION ALL

SELECT
    'High-severity open exceptions',
    result,
    CASE WHEN result = 0 THEN 'Pass' ELSE 'Open' END
FROM high_severity_exceptions
