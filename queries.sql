-- =============================================================
-- Practice Queries  (MySQL 8.0+)
-- =============================================================


-- -------------------------
-- 1. BASIC FILTERING
-- -------------------------

-- All completed transactions above $100
SELECT transaction_id, amount, currency, description, initiated_at
FROM transactions
WHERE status = 'completed' AND amount > 100
ORDER BY amount DESC;

-- All active cards with their card network
SELECT c.card_id, c.last_four, c.card_network, c.card_type, u.first_name, u.last_name
FROM cards c
JOIN users u ON c.user_id = u.user_id
WHERE c.status = 'active';

-- Users who have not completed KYC
SELECT user_id, first_name, last_name, email, kyc_status
FROM users
WHERE kyc_status != 'verified';


-- -------------------------
-- 2. AGGREGATES
-- -------------------------

-- Total spend per user (completed purchases only)
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    COUNT(t.transaction_id)                AS num_transactions,
    SUM(t.amount_usd)                      AS total_spent_usd,
    AVG(t.amount_usd)                      AS avg_transaction_usd
FROM users u
JOIN cards c        ON c.user_id  = u.user_id
JOIN transactions t ON t.card_id  = c.card_id
WHERE t.type = 'purchase' AND t.status = 'completed'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_spent_usd DESC;

-- Transaction count and total volume by merchant category
SELECT
    m.category,
    COUNT(*)           AS num_transactions,
    SUM(t.amount_usd)  AS total_usd,
    AVG(t.amount_usd)  AS avg_usd,
    MAX(t.amount_usd)  AS max_usd
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status = 'completed'
GROUP BY m.category
ORDER BY total_usd DESC;

-- Daily transaction volume over the last 30 days
SELECT
    DATE(initiated_at)  AS txn_date,
    COUNT(*)            AS num_txns,
    SUM(amount_usd)     AS daily_volume_usd
FROM transactions
WHERE initiated_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(initiated_at)
ORDER BY txn_date;


-- -------------------------
-- 3. JOINs
-- -------------------------

-- Full transaction details: user → card → merchant
SELECT
    t.transaction_id,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    c.last_four,
    c.card_network,
    m.name                                 AS merchant_name,
    m.category,
    t.amount,
    t.currency,
    t.amount_usd,
    t.type,
    t.status,
    t.initiated_at
FROM transactions t
JOIN cards    c ON t.card_id     = c.card_id
JOIN users    u ON c.user_id     = u.user_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
ORDER BY t.initiated_at DESC;

-- Users with no transactions at all
SELECT u.user_id, u.first_name, u.last_name
FROM users u
LEFT JOIN cards c       ON c.user_id  = u.user_id
LEFT JOIN transactions t ON t.card_id = c.card_id
WHERE t.transaction_id IS NULL;


-- -------------------------
-- 4. SUBQUERIES
-- -------------------------

-- Users whose total spend (USD) is above the average user spend
SELECT full_name, total_spent_usd
FROM (
    SELECT
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        SUM(t.amount_usd)                      AS total_spent_usd
    FROM users u
    JOIN cards c        ON c.user_id  = u.user_id
    JOIN transactions t ON t.card_id  = c.card_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY u.user_id, u.first_name, u.last_name
) spend
WHERE total_spent_usd > (
    SELECT AVG(user_total)
    FROM (
        SELECT SUM(t2.amount_usd) AS user_total
        FROM transactions t2
        JOIN cards c2 ON t2.card_id = c2.card_id
        WHERE t2.type = 'purchase' AND t2.status = 'completed'
        GROUP BY c2.user_id
    ) sub
)
ORDER BY total_spent_usd DESC;

-- Top merchant per user (by number of purchases)
-- Uses ROW_NUMBER() since MySQL has no DISTINCT ON
SELECT cardholder, favourite_merchant, visit_count
FROM (
    SELECT
        CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
        m.name                                 AS favourite_merchant,
        COUNT(*)                               AS visit_count,
        ROW_NUMBER() OVER (
            PARTITION BY u.user_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM transactions t
    JOIN cards c    ON t.card_id    = c.card_id
    JOIN users u    ON c.user_id    = u.user_id
    JOIN merchants m ON t.merchant_id = m.merchant_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY u.user_id, u.first_name, u.last_name, m.merchant_id, m.name
) ranked
WHERE rn = 1
ORDER BY cardholder;


-- -------------------------
-- 5. WINDOW FUNCTIONS
-- -------------------------

-- Running total spend per card (chronological)
SELECT
    t.transaction_id,
    c.last_four,
    t.amount_usd,
    t.initiated_at,
    SUM(t.amount_usd) OVER (
        PARTITION BY t.card_id
        ORDER BY t.initiated_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
WHERE t.type = 'purchase' AND t.status = 'completed'
ORDER BY c.card_id, t.initiated_at;

-- Rank merchants by total revenue (completed purchases)
SELECT
    m.name,
    m.category,
    SUM(t.amount_usd)                                    AS total_revenue,
    RANK() OVER (ORDER BY SUM(t.amount_usd) DESC)        AS revenue_rank,
    RANK() OVER (PARTITION BY m.category
                 ORDER BY SUM(t.amount_usd) DESC)         AS rank_in_category
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status = 'completed' AND t.type = 'purchase'
GROUP BY m.merchant_id, m.name, m.category
ORDER BY total_revenue DESC;

-- Month-over-month spend change per user
-- DATE_FORMAT truncates to the first of each month
WITH monthly AS (
    SELECT
        c.user_id,
        DATE_FORMAT(t.initiated_at, '%Y-%m-01') AS month,
        SUM(t.amount_usd)                       AS monthly_spend
    FROM transactions t
    JOIN cards c ON t.card_id = c.card_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY c.user_id, DATE_FORMAT(t.initiated_at, '%Y-%m-01')
)
SELECT
    user_id,
    month,
    monthly_spend,
    LAG(monthly_spend) OVER (PARTITION BY user_id ORDER BY month) AS prev_month_spend,
    monthly_spend
        - LAG(monthly_spend) OVER (PARTITION BY user_id ORDER BY month) AS mom_change
FROM monthly
ORDER BY user_id, month;


-- -------------------------
-- 6. CTEs
-- -------------------------

-- High-value customers: users with > 3 completed purchases AND total spend > $200
WITH user_stats AS (
    SELECT
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        COUNT(*)          AS purchase_count,
        SUM(t.amount_usd) AS total_usd
    FROM users u
    JOIN cards c        ON c.user_id  = u.user_id
    JOIN transactions t ON t.card_id  = c.card_id
    WHERE t.type = 'purchase' AND t.status = 'completed'
    GROUP BY u.user_id, u.first_name, u.last_name
)
SELECT * FROM user_stats
WHERE purchase_count > 3 AND total_usd > 200
ORDER BY total_usd DESC;

-- Flag transactions where the amount is more than 3x the user's average
WITH user_avg AS (
    SELECT
        c.user_id,
        AVG(t.amount_usd) AS avg_txn_usd
    FROM transactions t
    JOIN cards c ON t.card_id = c.card_id
    WHERE t.type = 'purchase'
    GROUP BY c.user_id
)
SELECT
    t.transaction_id,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    t.amount_usd,
    ROUND(ua.avg_txn_usd, 2)               AS user_avg_usd,
    ROUND(t.amount_usd / ua.avg_txn_usd, 2) AS multiple_of_avg,
    m.name                                 AS merchant
FROM transactions t
JOIN cards c    ON t.card_id    = c.card_id
JOIN users u    ON c.user_id    = u.user_id
JOIN user_avg ua ON ua.user_id  = c.user_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.amount_usd > (ua.avg_txn_usd * 3)
ORDER BY multiple_of_avg DESC;


-- -------------------------
-- 7. FRAUD / ANOMALY PATTERNS
-- -------------------------

-- Cards with more than 1 failed transaction
SELECT
    c.card_id,
    c.last_four,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    COUNT(*) AS failed_count
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
WHERE t.status = 'failed'
GROUP BY c.card_id, c.last_four, u.first_name, u.last_name
HAVING COUNT(*) > 1
ORDER BY failed_count DESC;

-- Transactions with non-standard statuses (disputed, reversed, chargeback)
SELECT
    t.transaction_id,
    CONCAT(u.first_name, ' ', u.last_name) AS cardholder,
    t.amount_usd,
    t.type,
    t.status,
    m.name AS merchant,
    t.initiated_at
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN users u ON c.user_id = u.user_id
LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.status IN ('disputed', 'reversed', 'chargeback')
   OR t.type   = 'chargeback'
ORDER BY t.initiated_at DESC;

-- Accounts where the balance is below $500 (potential overdraft risk)
SELECT
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    a.currency,
    CONCAT(u.first_name, ' ', u.last_name) AS owner
FROM accounts a
JOIN users u ON a.user_id = u.user_id
WHERE a.balance < 500 AND a.status = 'active' AND a.account_type != 'credit'
ORDER BY a.balance ASC;


-- -------------------------
-- 8. MULTI-CURRENCY ANALYSIS
-- -------------------------

-- Total spend in native currency vs USD equivalent, grouped by currency
SELECT
    t.currency,
    COUNT(*)          AS num_txns,
    SUM(t.amount)     AS total_native,
    SUM(t.amount_usd) AS total_usd_equivalent
FROM transactions t
WHERE t.type = 'purchase' AND t.status = 'completed'
GROUP BY t.currency
ORDER BY total_usd_equivalent DESC;
