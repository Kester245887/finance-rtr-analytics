-- =====================================================
-- NORTHSTAR GLOBAL SERVICES LTD.
-- November 2026 Bank Reconciliation
-- =====================================================

WITH gl_bank AS (
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
)

SELECT
    t.transaction_id,
    g.gl_signed_amount,
    b.bank_signed_amount,
    COALESCE(b.bank_record_count, 0) AS bank_record_count,

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

ORDER BY t.transaction_id;