-- =============================================================
-- SQL Practice Answers  — Card Transactions Database
-- =============================================================


-- -------------------------
-- LEVEL 1: BASICS
-- -------------------------

-- Q1. List all users along with their country and KYC status,
--     ordered alphabetically by last name.
SELECT first_name, last_name, country, kyc_status
FROM users
ORDER BY last_name ASC;


-- Q2. Find all transactions that are still pending.
SELECT transaction_id, amount, currency, description, initiated_at
FROM transactions
WHERE status = 'pending';


-- Q3. List all merchants that operate online only.
SELECT merchant_id, name, category, country
FROM merchants
WHERE is_online = TRUE;


-- Q4. Find all cards that have expired or are blocked.
SELECT card_id, last_four, card_network, card_type, status
FROM cards
WHERE status IN ('expired', 'blocked');


-- Q5. How many users are there per country?
SELECT country, COUNT(*) AS user_count
FROM users
GROUP BY country
ORDER BY user_count DESC;


-- Q6. Find all transactions where a fee was charged.
SELECT transaction_id, type, amount, fee, description
FROM transactions
WHERE fee > 0;


-- Q7. List all accounts with a balance below $1000 that are still active.
SELECT account_id, account_number, account_type, currency, balance
FROM accounts
WHERE balance < 1000 AND status = 'active';


-- -------------------------
-- LEVEL 2: JOINs
-- -------------------------

-- Q8. Show each card's last_four, cardholder full name, and account number.
SELECT
    c.card_id,
    c.last_four,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    a.account_number
FROM cards c
JOIN users u    ON c.user_id    = u.user_id
JOIN accounts a ON c.account_id = a.account_id;


-- Q9. Every transaction with cardholder, card network, merchant name, amount, status.
SELECT
    t.transaction_id,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    c.card_network,
    COALESCE(m.name, 'N/A (ATM/P2P)')     AS merchant_name,
    t.amount,
    t.currency,
    t.status
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
ORDER BY t.initiated_at DESC;


-- Q10. Users with more than one card.
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    COUNT(c.card_id) AS card_count
FROM users u
JOIN cards c ON c.user_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(c.card_id) > 1
ORDER BY card_count DESC;


-- Q11. Merchants that have never had a transaction.
SELECT m.merchant_id, m.name, m.category
FROM merchants m
LEFT JOIN transactions t ON t.merchant_id = m.merchant_id
WHERE t.transaction_id IS NULL;


-- Q12. Users with a credit account but no purchase on their credit card.
SELECT DISTINCT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name
FROM users u
JOIN accounts a ON a.user_id = u.user_id AND a.account_type = 'credit'
JOIN cards c    ON c.account_id = a.account_id
WHERE c.card_id NOT IN (
    SELECT DISTINCT card_id
    FROM transactions
    WHERE type = 'purchase'
);


-- Q13. For each account: owner name, type, currency, balance, card count.
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS owner,
    a.account_number,
    a.account_type,
    a.currency,
    a.balance,
    COUNT(c.card_id) AS card_count
FROM accounts a
JOIN users u ON a.user_id = u.user_id
LEFT JOIN cards c ON c.account_id = a.account_id
GROUP BY a.account_id, u.first_name, u.last_name,
         a.account_number, a.account_type, a.currency, a.balance
ORDER BY a.account_id;


-- -------------------------
-- LEVEL 3: AGGREGATES & GROUPING
-- -------------------------

-- Q14. Total completed purchase spend per card network.
SELECT
    c.card_network,
    SUM(t.amount_usd) AS total_usd
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
WHERE t.type = 'purchase' AND t.status = 'completed'
GROUP BY c.card_network
ORDER BY total_usd DESC;


-- Q15. Top 3 merchants by total transaction volume (completed).
SELECT
    m.name,
    m.category,
    SUM(t.amount_usd) AS total_volume_usd
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status = 'completed'
GROUP BY m.merchant_id, m.name, m.category
ORDER BY total_volume_usd DESC
LIMIT 3;


-- Q16. Count of transactions per status.
SELECT status, COUNT(*) AS count
FROM transactions
GROUP BY status
ORDER BY count DESC;


-- Q17. Average transaction amount per channel.
SELECT
    channel,
    ROUND(AVG(amount_usd), 2) AS avg_amount_usd
FROM transactions
GROUP BY channel
ORDER BY avg_amount_usd DESC;


-- Q18. Merchants where the average transaction amount > $100.
SELECT
    m.name,
    m.category,
    ROUND(AVG(t.amount_usd), 2) AS avg_txn_usd
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status = 'completed'
GROUP BY m.merchant_id, m.name, m.category
HAVING AVG(t.amount_usd) > 100
ORDER BY avg_txn_usd DESC;


-- Q19. Per user: total transactions, total spend, largest single transaction.
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    COUNT(t.transaction_id)                AS total_transactions,
    ROUND(SUM(t.amount_usd), 2)            AS total_spend_usd,
    MAX(t.amount_usd)                      AS largest_transaction_usd
FROM users u
JOIN cards c        ON c.user_id  = u.user_id
JOIN transactions t ON t.card_id  = c.card_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_spend_usd DESC;


-- Q20. Total fee collected per transaction type.
SELECT type, ROUND(SUM(fee), 2) AS total_fees
FROM transactions
WHERE fee > 0
GROUP BY type
ORDER BY total_fees DESC;


-- -------------------------
-- LEVEL 4: SUBQUERIES
-- -------------------------

-- Q21. Transactions where amount > overall average.
SELECT transaction_id, amount_usd, type, status, initiated_at
FROM transactions
WHERE amount_usd > (SELECT AVG(amount_usd) FROM transactions)
ORDER BY amount_usd DESC;


-- Q22. Users who transacted at a merchant in a different country than their own.
SELECT DISTINCT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    u.country                              AS user_country,
    m.name                                 AS merchant_name,
    m.country                              AS merchant_country
FROM transactions t
JOIN cards c    ON t.card_id      = c.card_id
JOIN users u    ON c.user_id      = u.user_id
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE u.country != m.country;


-- Q23. User with the highest total completed purchase spend.
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    ROUND(SUM(t.amount_usd), 2)            AS total_spend_usd
FROM users u
JOIN cards c        ON c.user_id  = u.user_id
JOIN transactions t ON t.card_id  = c.card_id
WHERE t.type = 'purchase' AND t.status = 'completed'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_spend_usd DESC
LIMIT 1;


-- Q24. Cards with at least one failed transaction but zero completed transactions.
SELECT c.card_id, c.last_four,
       CONCAT(u.first_name, ' ', u.last_name) AS cardholder
FROM cards c
JOIN users u ON c.user_id = u.user_id
WHERE c.card_id IN (
    SELECT card_id FROM transactions WHERE status = 'failed'
)
AND c.card_id NOT IN (
    SELECT card_id FROM transactions WHERE status = 'completed'
);


-- Q25. Each merchant labeled above/below average transaction count.
SELECT
    m.name,
    COUNT(t.transaction_id) AS txn_count,
    CASE
        WHEN COUNT(t.transaction_id) > (
            SELECT AVG(merchant_count)
            FROM (
                SELECT merchant_id, COUNT(*) AS merchant_count
                FROM transactions
                WHERE merchant_id IS NOT NULL
                GROUP BY merchant_id
            ) sub
        )
        THEN 'above average'
        ELSE 'below average'
    END AS vs_average
FROM merchants m
LEFT JOIN transactions t ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.name
ORDER BY txn_count DESC;


-- Q26. Users whose total spend > 2x the average user spend.
SELECT full_name, ROUND(total_spend, 2) AS total_spend_usd
FROM (
    SELECT
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        SUM(t.amount_usd)                      AS total_spend
    FROM users u
    JOIN cards c        ON c.user_id  = u.user_id
    JOIN transactions t ON t.card_id  = c.card_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY u.user_id, u.first_name, u.last_name
) spend
WHERE total_spend > 2 * (
    SELECT AVG(user_total)
    FROM (
        SELECT SUM(t2.amount_usd) AS user_total
        FROM transactions t2
        JOIN cards c2 ON t2.card_id = c2.card_id
        WHERE t2.type = 'purchase' AND t2.status = 'completed'
        GROUP BY c2.user_id
    ) avg_sub
)
ORDER BY total_spend_usd DESC;


-- -------------------------
-- LEVEL 5: WINDOW FUNCTIONS
-- -------------------------

-- Q27. Running total of amount_usd per user (by initiated_at).
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    t.transaction_id,
    t.amount_usd,
    t.initiated_at,
    SUM(t.amount_usd) OVER (
        PARTITION BY u.user_id
        ORDER BY t.initiated_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_usd
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
ORDER BY u.user_id, t.initiated_at;


-- Q28. Rank users by total completed purchase spend.
SELECT
    CONCAT(u.first_name, ' ', u.last_name)                AS full_name,
    ROUND(SUM(t.amount_usd), 2)                           AS total_spend_usd,
    RANK() OVER (ORDER BY SUM(t.amount_usd) DESC)         AS spend_rank
FROM users u
JOIN cards c        ON c.user_id  = u.user_id
JOIN transactions t ON t.card_id  = c.card_id
WHERE t.type = 'purchase' AND t.status = 'completed'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY spend_rank;


-- Q29. Previous transaction amount on the same card and the difference.
SELECT
    t.transaction_id,
    t.card_id,
    t.amount_usd,
    t.initiated_at,
    LAG(t.amount_usd) OVER (
        PARTITION BY t.card_id ORDER BY t.initiated_at
    ) AS prev_amount_usd,
    t.amount_usd - LAG(t.amount_usd) OVER (
        PARTITION BY t.card_id ORDER BY t.initiated_at
    ) AS amount_diff
FROM transactions t
ORDER BY t.card_id, t.initiated_at;


-- Q30. Each transaction as a % of its merchant's total completed revenue.
SELECT
    m.name AS merchant,
    t.transaction_id,
    t.amount_usd,
    SUM(t.amount_usd) OVER (PARTITION BY t.merchant_id)  AS merchant_total,
    ROUND(
        t.amount_usd / SUM(t.amount_usd) OVER (PARTITION BY t.merchant_id) * 100
    , 2) AS pct_of_merchant_total
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status = 'completed'
ORDER BY m.name, t.transaction_id;


-- Q31. Within each category, rank merchants by total revenue.
SELECT
    m.name,
    m.category,
    ROUND(SUM(t.amount_usd), 2) AS total_revenue,
    RANK() OVER (
        PARTITION BY m.category
        ORDER BY SUM(t.amount_usd) DESC
    ) AS rank_in_category
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status = 'completed' AND t.type = 'purchase'
GROUP BY m.merchant_id, m.name, m.category
ORDER BY m.category, rank_in_category;


-- Q32. Top 1 most expensive transaction per user using ROW_NUMBER().
SELECT full_name, transaction_id, amount_usd, merchant_name, initiated_at
FROM (
    SELECT
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        t.transaction_id,
        t.amount_usd,
        m.name                                 AS merchant_name,
        t.initiated_at,
        ROW_NUMBER() OVER (
            PARTITION BY u.user_id
            ORDER BY t.amount_usd DESC
        ) AS rn
    FROM transactions t
    JOIN cards c ON t.card_id = c.card_id
    JOIN users u ON c.user_id = u.user_id
    LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
) ranked
WHERE rn = 1
ORDER BY amount_usd DESC;


-- -------------------------
-- LEVEL 6: CTEs
-- -------------------------

-- Q33. Users who spent > $500 total on completed purchases, with their country.
WITH user_spend AS (
    SELECT
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        u.country,
        SUM(t.amount_usd) AS total_spend
    FROM users u
    JOIN cards c        ON c.user_id  = u.user_id
    JOIN transactions t ON t.card_id  = c.card_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY u.user_id, u.first_name, u.last_name, u.country
)
SELECT full_name, country, ROUND(total_spend, 2) AS total_spend_usd
FROM user_spend
WHERE total_spend > 500
ORDER BY total_spend DESC;


-- Q34. Monthly total spend, find the highest-spend month.
WITH monthly_spend AS (
    SELECT
        DATE_FORMAT(t.initiated_at, '%Y-%m-01') AS month,
        SUM(t.amount_usd)                       AS total_spend
    FROM transactions t
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY DATE_FORMAT(t.initiated_at, '%Y-%m-01')
)
SELECT month, ROUND(total_spend, 2) AS total_spend_usd
FROM monthly_spend
ORDER BY total_spend DESC
LIMIT 1;


-- Q35. Cards with disputed or reversed transactions.
WITH problem_txns AS (
    SELECT
        t.card_id,
        COUNT(*) AS problem_count
    FROM transactions t
    WHERE t.status IN ('disputed', 'reversed')
    GROUP BY t.card_id
)
SELECT
    c.last_four,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    pt.problem_count
FROM problem_txns pt
JOIN cards c ON pt.card_id = c.card_id
JOIN users u ON c.user_id  = u.user_id
ORDER BY pt.problem_count DESC;


-- Q36. Each merchant's spend vs its category total, with percentage.
WITH merchant_totals AS (
    SELECT
        t.merchant_id,
        SUM(t.amount_usd) AS merchant_total
    FROM transactions t
    WHERE t.status = 'completed' AND t.type = 'purchase'
    GROUP BY t.merchant_id
),
category_totals AS (
    SELECT
        m.category,
        SUM(mt.merchant_total) AS category_total
    FROM merchant_totals mt
    JOIN merchants m ON mt.merchant_id = m.merchant_id
    GROUP BY m.category
)
SELECT
    m.name                                   AS merchant,
    m.category,
    ROUND(mt.merchant_total, 2)              AS merchant_spend,
    ROUND(ct.category_total, 2)              AS category_spend,
    ROUND(mt.merchant_total / ct.category_total * 100, 1) AS pct_of_category
FROM merchant_totals mt
JOIN merchants m      ON mt.merchant_id = m.merchant_id
JOIN category_totals ct ON m.category  = ct.category
ORDER BY m.category, pct_of_category DESC;


-- -------------------------
-- LEVEL 7: ADVANCED / MIXED
-- -------------------------

-- Q37. Pairs of users who both transacted at the same merchant.
SELECT DISTINCT
    CONCAT(u1.first_name, ' ', u1.last_name) AS user_1,
    CONCAT(u2.first_name, ' ', u2.last_name) AS user_2,
    m.name                                   AS shared_merchant
FROM transactions t1
JOIN transactions t2 ON t1.merchant_id = t2.merchant_id
                     AND t1.card_id    < t2.card_id   -- avoid duplicates & self-pairs
JOIN cards c1 ON t1.card_id = c1.card_id
JOIN cards c2 ON t2.card_id = c2.card_id
JOIN users u1 ON c1.user_id = u1.user_id
JOIN users u2 ON c2.user_id = u2.user_id
JOIN merchants m ON t1.merchant_id = m.merchant_id
ORDER BY shared_merchant, user_1;


-- Q38. Risk score per user based on transaction anomalies.
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    SUM(
        CASE t.status
            WHEN 'failed'   THEN 1
            WHEN 'disputed' THEN 2
            ELSE 0
        END +
        CASE t.type
            WHEN 'chargeback' THEN 3
            ELSE 0
        END
    ) AS risk_score
FROM users u
JOIN cards c        ON c.user_id  = u.user_id
JOIN transactions t ON t.card_id  = c.card_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING risk_score > 0
ORDER BY risk_score DESC;


-- Q39. Month-over-month % change in total transaction volume.
WITH monthly AS (
    SELECT
        DATE_FORMAT(initiated_at, '%Y-%m-01') AS month,
        SUM(amount_usd)                       AS total_volume
    FROM transactions
    GROUP BY DATE_FORMAT(initiated_at, '%Y-%m-01')
)
SELECT
    month,
    ROUND(total_volume, 2) AS total_volume,
    ROUND(LAG(total_volume) OVER (ORDER BY month), 2) AS prev_month_volume,
    ROUND(
        (total_volume - LAG(total_volume) OVER (ORDER BY month))
        / LAG(total_volume) OVER (ORDER BY month) * 100
    , 1) AS pct_change
FROM monthly
ORDER BY month;


-- Q40. Cards where total spend in a single day exceeded $500.
SELECT
    c.last_four,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    DATE(t.initiated_at)                   AS txn_date,
    ROUND(SUM(t.amount_usd), 2)            AS daily_total
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
WHERE t.type = 'purchase'
GROUP BY c.card_id, c.last_four, u.first_name, u.last_name, DATE(t.initiated_at)
HAVING SUM(t.amount_usd) > 500
ORDER BY daily_total DESC;


-- Q41. Each user's first and most recent transaction side by side.
WITH ordered AS (
    SELECT
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        t.transaction_id,
        t.amount_usd,
        m.name                                 AS merchant,
        t.initiated_at,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY t.initiated_at ASC)  AS rn_first,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY t.initiated_at DESC) AS rn_last
    FROM transactions t
    JOIN cards c ON t.card_id = c.card_id
    JOIN users u ON c.user_id = u.user_id
    LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
)
SELECT
    f.full_name,
    f.amount_usd   AS first_txn_amount,
    f.merchant     AS first_merchant,
    f.initiated_at AS first_txn_date,
    l.amount_usd   AS latest_txn_amount,
    l.merchant     AS latest_merchant,
    l.initiated_at AS latest_txn_date
FROM ordered f
JOIN ordered l ON f.user_id = l.user_id
WHERE f.rn_first = 1 AND l.rn_last = 1
ORDER BY f.full_name;


-- Q42. Users who have transacted in more than one currency.
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    COUNT(DISTINCT t.currency)             AS currency_count,
    GROUP_CONCAT(DISTINCT t.currency ORDER BY t.currency) AS currencies
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(DISTINCT t.currency) > 1
ORDER BY currency_count DESC;


-- Q43. Potential duplicate transactions: same card + merchant + amount within 10 minutes.
SELECT
    t1.transaction_id AS txn_1,
    t2.transaction_id AS txn_2,
    t1.card_id,
    t1.merchant_id,
    t1.amount_usd,
    t1.initiated_at   AS time_1,
    t2.initiated_at   AS time_2,
    TIMESTAMPDIFF(SECOND, t1.initiated_at, t2.initiated_at) AS seconds_apart
FROM transactions t1
JOIN transactions t2
    ON  t1.card_id     = t2.card_id
    AND t1.merchant_id = t2.merchant_id
    AND t1.amount      = t2.amount
    AND t1.transaction_id < t2.transaction_id
    AND ABS(TIMESTAMPDIFF(SECOND, t1.initiated_at, t2.initiated_at)) <= 600
ORDER BY seconds_apart;


-- Q44. Top-spending user per merchant category.
WITH category_user_spend AS (
    SELECT
        m.category,
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        SUM(t.amount_usd)                       AS spend,
        RANK() OVER (
            PARTITION BY m.category
            ORDER BY SUM(t.amount_usd) DESC
        ) AS rnk
    FROM transactions t
    JOIN cards c     ON t.card_id      = c.card_id
    JOIN users u     ON c.user_id      = u.user_id
    JOIN merchants m ON t.merchant_id  = m.merchant_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY m.category, u.user_id, u.first_name, u.last_name
)
SELECT category, full_name, ROUND(spend, 2) AS total_spend_usd
FROM category_user_spend
WHERE rnk = 1
ORDER BY category;


-- Q45. Conversion rate per card (completed / all non-pending transactions).
SELECT
    c.last_four,
    CONCAT(u.first_name, ' ', u.last_name)          AS cardholder,
    COUNT(*)                                         AS total_attempts,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    ROUND(
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END)
        / COUNT(*) * 100
    , 1) AS conversion_pct
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
WHERE t.status != 'pending'
GROUP BY c.card_id, c.last_four, u.first_name, u.last_name
ORDER BY conversion_pct ASC;
