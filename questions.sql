-- =============================================================
-- SQL Practice Questions  — Card Transactions Database
-- Schema: users, accounts, cards, merchants, transactions
-- =============================================================


-- -------------------------
-- LEVEL 1: BASICS
-- -------------------------

-- Q1.
-- List all users along with their country and KYC status,
-- ordered alphabetically by last name.

-- Q2.
-- Find all transactions that are still pending.
-- Show the transaction_id, amount, currency, description, and initiated_at.

-- Q3.
-- List all merchants that operate online only (is_online = TRUE).

-- Q4.
-- Find all cards that have expired (status = 'expired') or are blocked.

-- Q5.
-- How many users are there per country?

-- Q6.
-- Find all transactions where a fee was charged (fee > 0).
-- Show the transaction_id, type, amount, fee, and description.

-- Q7.
-- List all accounts with a balance below $1000 that are still active.


-- -------------------------
-- LEVEL 2: JOINs
-- -------------------------

-- Q8.
-- Show each card's last_four digits alongside the full name of the cardholder
-- and the account_number it belongs to.

-- Q9.
-- List every transaction with the cardholder's full name, card network,
-- merchant name (if any), amount, and status.
-- Include ATM transactions (no merchant).

-- Q10.
-- Which users have more than one card? Show their full name and card count.

-- Q11.
-- Show all merchants that have never had a transaction.

-- Q12.
-- List all users who have a credit account but have never made a purchase
-- on their credit card.

-- Q13.
-- For each account, show the owner's full name, account type, currency,
-- balance, and how many cards are linked to it.


-- -------------------------
-- LEVEL 3: AGGREGATES & GROUPING
-- -------------------------

-- Q14.
-- What is the total amount spent (completed purchases only) per card network
-- (visa, mastercard, amex, discover)?

-- Q15.
-- Find the top 3 merchants by total transaction volume (amount_usd),
-- considering only completed transactions.

-- Q16.
-- How many transactions of each status exist?
-- Show status and count, ordered by count descending.

-- Q17.
-- What is the average transaction amount per channel
-- (card_present, contactless, online, atm)?

-- Q18.
-- Find all merchants where the average transaction amount is greater than $100.

-- Q19.
-- For each user, show the total number of transactions, total spend in USD,
-- and the largest single transaction they have made.

-- Q20.
-- What is the total fee collected per transaction type?


-- -------------------------
-- LEVEL 4: SUBQUERIES
-- -------------------------

-- Q21.
-- Find all transactions where the amount is greater than the overall
-- average transaction amount.

-- Q22.
-- Which users have made at least one transaction at a merchant
-- in a different country than the user's own country?
-- (Hint: join user country with merchant country)

-- Q23.
-- Find the user who has spent the most in total (completed purchases, USD).
-- Show their full name and total spend.

-- Q24.
-- List all cards that have had a failed transaction but no completed transaction.

-- Q25.
-- Show each merchant and whether they are above or below the average
-- number of transactions per merchant.
-- Label them 'above average' or 'below average'.

-- Q26.
-- Find users whose total spend is more than 2x the average spend
-- across all users.


-- -------------------------
-- LEVEL 5: WINDOW FUNCTIONS
-- -------------------------

-- Q27.
-- For each transaction, show the running total of amount_usd
-- per user (ordered by initiated_at).

-- Q28.
-- Rank all users by their total completed purchase spend (highest = rank 1).
-- Show user full name, total spend, and rank.

-- Q29.
-- For each transaction, show the previous transaction amount on the same card
-- and the difference between them.
-- (Hint: LAG)

-- Q30.
-- For each merchant, show each transaction and what percentage of that
-- merchant's total completed revenue it represents.

-- Q31.
-- Within each merchant category, rank merchants by total revenue.
-- Show merchant name, category, total revenue, and their rank within the category.

-- Q32.
-- Show the top 1 most expensive transaction per user using ROW_NUMBER().


-- -------------------------
-- LEVEL 6: CTEs
-- -------------------------

-- Q33.
-- Using a CTE, find all users who have spent more than $500 in total
-- on completed purchases, then show their full name and which countries they are from.

-- Q34.
-- Write a CTE that calculates each user's monthly spend, then use it
-- to find the month in which overall spending was the highest.

-- Q35.
-- Using a CTE, identify cards that have a "disputed" or "reversed" transaction.
-- Show the card's last_four, the cardholder name, and the number of such transactions.

-- Q36.
-- Using two CTEs:
--   1. Calculate total spend per merchant.
--   2. Calculate total spend per merchant category.
-- Then show each merchant with its own total and its category's total,
-- and what percentage of the category total it represents.


-- -------------------------
-- LEVEL 7: ADVANCED / MIXED
-- -------------------------

-- Q37.
-- Find pairs of users who have both transacted at the same merchant.
-- Show the two user names and the merchant name.
-- (Hint: self-join on transactions via merchant_id)

-- Q38.
-- For each user, calculate a 'risk score' as follows:
--   +1 point for every failed transaction
--   +2 points for every disputed transaction
--   +3 points for every chargeback
-- Show users with a risk score > 0, ordered by score descending.

-- Q39.
-- Show the month-over-month percentage change in total transaction volume
-- across all users combined.
-- Columns: month, total_volume, prev_month_volume, pct_change.

-- Q40.
-- Find any card where the total amount spent in a single day exceeded $500.
-- Show the card's last_four, the date, and the daily total.

-- Q41.
-- For each user, show their most recent transaction and their very first
-- transaction side by side (amount, merchant, date for each).

-- Q42.
-- Identify users who have transactions in more than one currency.
-- Show user full name and the list of currencies they've transacted in.

-- Q43.
-- Write a query to detect potential duplicate transactions:
-- same card, same merchant, same amount, within 10 minutes of each other.
-- Show both transaction IDs and the time difference between them.

-- Q44.
-- For each merchant category, find the single highest-spending user
-- (by total completed purchases at merchants in that category).
-- Show category, user full name, and their spend in that category.

-- Q45.
-- Calculate the "conversion rate" per card — the percentage of that card's
-- transactions that ended in 'completed' status (out of all non-pending ones).
-- Show last_four, cardholder, total attempts, completed count, and conversion %.
