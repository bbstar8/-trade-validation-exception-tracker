-- Trade validation checks in SQLite
-- Tables: trades, counterparties, products
-- Each query counts the exceptions for one rule on the dataset.

-- 1. Missing fields (expected value: 25)
SELECT COUNT(*) AS exceptions
FROM trades
WHERE counterparty_id IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR settlement_date IS NULL;

-- 2. Unknown counterparty (expected value: 25)
SELECT COUNT(*) AS exceptions
FROM trades t
LEFT JOIN counterparties c ON t.counterparty_id = c.counterparty_id
WHERE t.counterparty_id IS NOT NULL
  AND c.counterparty_id IS NULL;

-- 3. Quantity over the product limit (expected value: 25)
SELECT COUNT(*) AS exceptions
FROM trades t
JOIN products p ON t.product_id = p.product_id
WHERE t.quantity > p.max_quantity;

-- 4. Settlement date on a weekend (expected value: 22)
-- strftime('%w') returns 0 for Sunday and 6 for Saturday
SELECT COUNT(*) AS exceptions
FROM trades
WHERE strftime('%w', settlement_date) IN ('0', '6');

-- 5. Duplicate trade IDs (expected: 15 IDs)
-- SQL counts each duplicated ID once.
SELECT COUNT(*) AS duplicated_ids
FROM (
    SELECT trade_id
    FROM trades
    GROUP BY trade_id
    HAVING COUNT(*) > 1
);
