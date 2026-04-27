-- =============================================================
-- Advanced SQL Questions  — Card Transactions Database
-- Schema: users, accounts, cards, merchants, transactions
-- Topics: window frames, recursive CTEs, pivot, gap/island,
--         JSON, lateral joins, set ops, correlated subqueries
-- =============================================================


-- -----------------------------------------------
-- SECTION A: WINDOW FUNCTION DEEP DIVES
-- -----------------------------------------------

-- AQ1. Running 7-day average spend per user
-- For every completed purchase, compute a 7-day rolling average of
-- amount_usd for that user (including the current row's day and the
-- 6 preceding days).
-- Columns: user full name, initiated_at, amount_usd, rolling_7d_avg.
-- Hint: ROWS BETWEEN 6 PRECEDING AND CURRENT ROW inside OVER().


-- AQ2. Percentile buckets for transaction amounts
-- Divide all completed transactions into 4 equal buckets (quartiles)
-- by amount_usd using NTILE(4).
-- Show transaction_id, amount_usd, and the quartile number.
-- Then add a column that labels each quartile:
--   1 → 'low', 2 → 'mid-low', 3 → 'mid-high', 4 → 'high'.


-- AQ3. First and last transaction per merchant
-- For each merchant, show every transaction alongside:
--   - The amount of the very first transaction ever made at that merchant.
--   - The amount of the most recent transaction at that merchant.
-- Use FIRST_VALUE() and LAST_VALUE() with an appropriate frame.
-- Columns: merchant name, transaction_id, initiated_at, amount_usd,
--          first_txn_amount, last_txn_amount.


-- AQ4. Cumulative share of revenue per user
-- Rank users by total completed purchase spend descending.
-- For each user show their total spend and the cumulative spend as a
-- running percentage of the grand total (i.e. top-N cumulative share).
-- Columns: rank, full name, total_spend, cumulative_pct.


-- AQ5. Inter-transaction gap analysis
-- For each card, compute the number of minutes between consecutive
-- completed transactions (ordered by initiated_at).
-- Show card last_four, transaction_id, initiated_at, prev_initiated_at,
-- and gap_minutes.
-- Filter to gaps longer than 60 minutes only.


-- AQ6. Dense rank within category and day
-- For each merchant category and calendar date (DATE(initiated_at)),
-- dense-rank merchants by their daily completed revenue.
-- Show category, date, merchant name, daily_revenue, and daily_rank.
-- Return only rank 1 per category per day (the day's top merchant).


-- -----------------------------------------------
-- SECTION B: RECURSIVE CTEs
-- -----------------------------------------------

-- AQ7. Generate a calendar of months in range
-- Using a recursive CTE, generate every month (YYYY-MM) between the
-- earliest and latest initiated_at in the transactions table.
-- Then LEFT JOIN the monthly totals onto this calendar so months with
-- zero transactions still appear with a 0.
-- Columns: month, total_transactions, total_volume_usd.


-- AQ8. Account balance simulation
-- Using a recursive CTE, simulate the running balance for a single
-- account (pick account_id = 1) by replaying its transactions in
-- chronological order. Assume purchases/fees/atm_withdrawal are debits
-- (subtract) and refunds/transfer_in are credits (add).
-- Columns: step, transaction_id, type, amount, simulated_balance.


-- -----------------------------------------------
-- SECTION C: PIVOT / CONDITIONAL AGGREGATION
-- -----------------------------------------------

-- AQ9. Monthly spend pivot by card network
-- Produce a pivot table showing total completed purchase volume (amount_usd)
-- broken down by month (rows) and card network (columns: visa, mastercard,
-- amex, discover).
-- Use conditional aggregation (SUM + CASE).
-- Columns: month, visa, mastercard, amex, discover, grand_total.


-- AQ10. KYC status breakdown per country
-- For each country, show how many users have each kyc_status
-- (pending, verified, failed) as separate columns, plus a total column.
-- Columns: country, pending, verified, failed, total_users.


-- AQ11. Transaction type mix per user
-- For each user, show the count of each transaction type
-- (purchase, refund, atm_withdrawal, transfer_in, transfer_out, fee, chargeback)
-- as separate columns.
-- Columns: user full name + one column per type.


-- -----------------------------------------------
-- SECTION D: GAP AND ISLAND DETECTION
-- -----------------------------------------------

-- AQ12. Spending streaks (islands)
-- A "spending day" is any calendar date on which a user has at least one
-- completed purchase. Find each user's consecutive spending streaks:
-- groups of consecutive calendar days with no gaps.
-- Columns: user full name, streak_start, streak_end, streak_length_days.
-- Hint: subtract ROW_NUMBER() from the date to get an island key.


-- AQ13. Inactive periods per card
-- For each card, identify gaps of more than 30 days between consecutive
-- completed transactions (ordered by initiated_at).
-- Show card last_four, gap_start (settled_at of one txn), gap_end
-- (initiated_at of the next), and gap_days.


-- AQ14. Consecutive failed transactions (runs)
-- A "failure run" is a sequence of consecutive failed transactions on the
-- same card with no non-failed transaction in between.
-- Find every failure run of length >= 2.
-- Show card last_four, run_start (first initiated_at), run_end, run_length.


-- -----------------------------------------------
-- SECTION E: JSON COLUMN QUERIES
-- -----------------------------------------------

-- AQ15. Extract a JSON field from metadata
-- The transactions.metadata column is a JSON blob. Some rows store a key
-- "device_type" (e.g. "mobile", "desktop").
-- List all transactions where device_type = 'mobile'.
-- Columns: transaction_id, amount_usd, initiated_at, device_type.
-- Hint: JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.device_type'))
--       or the shorthand metadata->>'$.device_type'.


-- AQ16. Aggregate over a JSON array
-- Some rows store metadata->>'$.tags' as a JSON array of strings,
-- e.g. ["recurring", "subscription"].
-- Find all transactions that contain the tag "subscription".
-- Columns: transaction_id, amount_usd, merchant name, initiated_at.
-- Hint: JSON_CONTAINS(metadata->'$.tags', '"subscription"').


-- -----------------------------------------------
-- SECTION F: SET OPERATIONS
-- -----------------------------------------------

-- AQ17. Cards active in Q1 but not Q2
-- Using set operations, find cards that had at least one completed
-- transaction in Q1 (Jan–Mar) of the most recent year in the data
-- but zero completed transactions in Q2 (Apr–Jun) of the same year.
-- Show card last_four and cardholder full name.


-- AQ18. Merchants visited by all verified US users
-- Find merchants that every single verified US user has transacted at
-- (at least once, any status).
-- This is a relational division problem — solve it without a direct
-- "FORALL" operator (use NOT EXISTS / NOT IN / COUNT tricks).


-- -----------------------------------------------
-- SECTION G: CORRELATED SUBQUERIES & EXISTS
-- -----------------------------------------------

-- AQ19. Users whose most recent transaction was a refund
-- Find users where the single most recent transaction (by initiated_at)
-- has type = 'refund'.
-- Show user full name, the refund amount, and initiated_at.
-- Solve using a correlated subquery (no window functions).


-- AQ20. Merchants with above-average spend in every month they appear
-- Find merchants where, for every calendar month they received at least
-- one completed transaction, their total monthly revenue exceeded the
-- overall average monthly merchant revenue for that same month.
-- Show merchant name and the number of months they qualified.
-- Hint: use a NOT EXISTS or HAVING COUNT approach to express "every month".
