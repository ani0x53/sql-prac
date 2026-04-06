-- =============================================================
-- Seed Data  (MySQL 8.0+)
-- =============================================================

-- -------------------------------------------------------------
-- USERS
-- -------------------------------------------------------------
INSERT INTO users (first_name, last_name, email, phone, date_of_birth, country, kyc_status) VALUES
('Alice',   'Johnson',  'alice@example.com',   '+14155550101', '1990-03-15', 'US', 'verified'),
('Bob',     'Smith',    'bob@example.com',     '+14155550102', '1985-07-22', 'US', 'verified'),
('Carol',   'Williams', 'carol@example.com',   '+14155550103', '1992-11-08', 'US', 'verified'),
('David',   'Brown',    'david@example.com',   '+44207550104', '1978-01-30', 'GB', 'verified'),
('Eva',     'Garcia',   'eva@example.com',     '+34915550105', '1995-06-12', 'ES', 'pending'),
('Frank',   'Martinez', 'frank@example.com',   '+14155550106', '1988-09-25', 'US', 'verified'),
('Grace',   'Lee',      'grace@example.com',   '+14155550107', '2000-02-14', 'US', 'verified'),
('Henry',   'Wilson',   'henry@example.com',   '+14155550108', '1975-12-03', 'US', 'failed'),
('Isla',    'Taylor',   'isla@example.com',    '+61295550109', '1993-04-19', 'AU', 'verified'),
('James',   'Anderson', 'james@example.com',   '+14155550110', '1982-08-07', 'US', 'verified');


-- -------------------------------------------------------------
-- ACCOUNTS
-- -------------------------------------------------------------
INSERT INTO accounts (user_id, account_number, account_type, currency, balance, credit_limit, status) VALUES
-- Alice: checking + credit
(1,  'ACC-US-000001', 'checking', 'USD',  4250.00,    NULL,      'active'),
(1,  'ACC-US-000002', 'credit',   'USD',     0.00,    5000.00,   'active'),
-- Bob: checking + savings
(2,  'ACC-US-000003', 'checking', 'USD',  12800.00,   NULL,      'active'),
(2,  'ACC-US-000004', 'savings',  'USD',  35000.00,   NULL,      'active'),
-- Carol: checking only
(3,  'ACC-US-000005', 'checking', 'USD',   1900.50,   NULL,      'active'),
-- David: checking (GBP)
(4,  'ACC-GB-000006', 'checking', 'GBP',   8400.00,   NULL,      'active'),
-- Eva: checking (EUR)
(5,  'ACC-ES-000007', 'checking', 'EUR',    320.00,   NULL,      'active'),
-- Frank: credit
(6,  'ACC-US-000008', 'credit',   'USD',      0.00,  10000.00,   'active'),
-- Grace: checking
(7,  'ACC-US-000009', 'checking', 'USD',   2100.00,   NULL,      'active'),
-- Henry: frozen account
(8,  'ACC-US-000010', 'checking', 'USD',    500.00,   NULL,      'frozen'),
-- Isla: checking (AUD)
(9,  'ACC-AU-000011', 'checking', 'AUD',   7600.00,   NULL,      'active'),
-- James: checking + savings
(10, 'ACC-US-000012', 'checking', 'USD',   3300.00,   NULL,      'active'),
(10, 'ACC-US-000013', 'savings',  'USD',  22000.00,   NULL,      'active');


-- -------------------------------------------------------------
-- CARDS
-- -------------------------------------------------------------
INSERT INTO cards (account_id, user_id, last_four, card_network, card_type, expiry_date, is_virtual, status) VALUES
-- Alice
(1,  1, '4321', 'visa',       'debit',   '2027-06-30', FALSE, 'active'),
(2,  1, '9988', 'mastercard', 'credit',  '2026-12-31', FALSE, 'active'),
(2,  1, '1122', 'mastercard', 'credit',  '2026-12-31', TRUE,  'active'),   -- virtual card
-- Bob
(3,  2, '5678', 'visa',       'debit',   '2025-09-30', FALSE, 'active'),
(3,  2, '3344', 'visa',       'debit',   '2028-03-31', FALSE, 'active'),   -- replacement card
-- Carol
(5,  3, '7890', 'mastercard', 'debit',   '2026-04-30', FALSE, 'active'),
-- David
(6,  4, '2211', 'visa',       'debit',   '2027-11-30', FALSE, 'active'),
-- Eva
(7,  5, '6655', 'mastercard', 'debit',   '2025-12-31', FALSE, 'blocked'),
-- Frank
(8,  6, '4477', 'amex',       'credit',  '2027-08-31', FALSE, 'active'),
-- Grace
(9,  7, '8899', 'discover',   'debit',   '2026-07-31', FALSE, 'active'),
-- Henry (expired)
(10, 8, '0011', 'visa',       'debit',   '2024-03-31', FALSE, 'expired'),
-- Isla
(11, 9, '3322', 'visa',       'debit',   '2027-05-31', FALSE, 'active'),
-- James
(12, 10,'7744', 'mastercard', 'debit',   '2028-01-31', FALSE, 'active');


-- -------------------------------------------------------------
-- MERCHANTS
-- -------------------------------------------------------------
INSERT INTO merchants (name, mcc_code, category, country, city, is_online) VALUES
('Amazon',           '5999', 'Online Retail',     'US', NULL,          TRUE),
('Walmart',          '5411', 'Grocery',           'US', 'Bentonville', FALSE),
('Starbucks',        '5812', 'Food & Beverage',   'US', 'Seattle',     FALSE),
('Netflix',          '7841', 'Entertainment',     'US', NULL,          TRUE),
('Uber',             '4121', 'Transportation',    'US', NULL,          TRUE),
('Apple Store',      '5732', 'Electronics',       'US', 'Cupertino',   FALSE),
('Shell',            '5541', 'Gas Station',       'GB', 'London',      FALSE),
('Zara',             '5621', 'Clothing',          'ES', 'Madrid',      FALSE),
('Airbnb',           '7011', 'Lodging',           'US', NULL,          TRUE),
('McDonald''s',      '5812', 'Food & Beverage',   'US', 'Chicago',     FALSE),
('Spotify',          '7929', 'Entertainment',     'SE', NULL,          TRUE),
('Whole Foods',      '5411', 'Grocery',           'US', 'Austin',      FALSE),
('Delta Airlines',   '4511', 'Travel',            'US', 'Atlanta',     TRUE),
('CVS Pharmacy',     '5912', 'Health & Pharmacy', 'US', 'Woonsocket',  FALSE),
('Stripe (Test)',    '7372', 'Software/SaaS',     'US', NULL,          TRUE);


-- -------------------------------------------------------------
-- TRANSACTIONS  (mix of dates, statuses, types, currencies)
-- -------------------------------------------------------------
INSERT INTO transactions (card_id, merchant_id, amount, currency, fx_rate, fee, type, status, channel, description, reference_id, initiated_at, settled_at) VALUES

-- Alice debit card (card 1) — USD purchases
(1,  3,   6.50,  'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Morning coffee',          'TXN-0001', DATE_SUB(NOW(), INTERVAL 30 DAY),  DATE_SUB(NOW(), INTERVAL 29 DAY)),
(1,  2,  112.34, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Weekly groceries',        'TXN-0002', DATE_SUB(NOW(), INTERVAL 28 DAY),  DATE_SUB(NOW(), INTERVAL 27 DAY)),
(1,  5,  22.00,  'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Uber ride to airport',    'TXN-0003', DATE_SUB(NOW(), INTERVAL 27 DAY),  DATE_SUB(NOW(), INTERVAL 26 DAY)),
(1,  1,  299.99, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Amazon order #112',       'TXN-0004', DATE_SUB(NOW(), INTERVAL 25 DAY),  DATE_SUB(NOW(), INTERVAL 24 DAY)),
(1,  3,   5.75,  'USD', 1.0,     0.00, 'purchase',      'completed', 'contactless',  'Starbucks latte',         'TXN-0005', DATE_SUB(NOW(), INTERVAL 22 DAY),  DATE_SUB(NOW(), INTERVAL 21 DAY)),
(1,  NULL,200.00,'USD', 1.0,     2.50, 'atm_withdrawal', 'completed', 'atm',          'ATM cash withdrawal',     'TXN-0006', DATE_SUB(NOW(), INTERVAL 20 DAY),  DATE_SUB(NOW(), INTERVAL 20 DAY)),
(1,  12,  87.60, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Whole Foods shop',        'TXN-0007', DATE_SUB(NOW(), INTERVAL 15 DAY),  DATE_SUB(NOW(), INTERVAL 14 DAY)),
(1,  10,  15.49, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'McDonald''s lunch',       'TXN-0008', DATE_SUB(NOW(), INTERVAL 12 DAY),  DATE_SUB(NOW(), INTERVAL 11 DAY)),
(1,  1,   45.00, 'USD', 1.0,     0.00, 'purchase',      'pending',   'online',       'Amazon order #234',       'TXN-0009', DATE_SUB(NOW(), INTERVAL 1 DAY),   NULL),
(1,  10,  15.49, 'USD', 1.0,     0.00, 'refund',        'completed', 'card_present', 'McDonald''s refund',      'TXN-0010', DATE_SUB(NOW(), INTERVAL 10 DAY),  DATE_SUB(NOW(), INTERVAL 9 DAY)),

-- Alice credit card (card 2) — credit purchases
(2,  6,  999.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'iPhone case + cable',     'TXN-0011', DATE_SUB(NOW(), INTERVAL 18 DAY),  DATE_SUB(NOW(), INTERVAL 17 DAY)),
(2,  4,   15.99, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Netflix monthly',         'TXN-0012', DATE_SUB(NOW(), INTERVAL 14 DAY),  DATE_SUB(NOW(), INTERVAL 13 DAY)),
(2,  11,   9.99, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Spotify premium',         'TXN-0013', DATE_SUB(NOW(), INTERVAL 14 DAY),  DATE_SUB(NOW(), INTERVAL 13 DAY)),
(2,  13, 420.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Flight NYC-LAX',          'TXN-0014', DATE_SUB(NOW(), INTERVAL 10 DAY),  DATE_SUB(NOW(), INTERVAL 9 DAY)),
(2,  9,  180.00, 'USD', 1.0,     0.00, 'purchase',      'disputed',  'online',       'Airbnb booking',          'TXN-0015', DATE_SUB(NOW(), INTERVAL 5 DAY),   NULL),

-- Bob debit card (card 5, the active replacement)
(5,  2,  205.18, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Costco run',              'TXN-0016', DATE_SUB(NOW(), INTERVAL 29 DAY),  DATE_SUB(NOW(), INTERVAL 28 DAY)),
(5,  3,   7.25,  'USD', 1.0,     0.00, 'purchase',      'completed', 'contactless',  'Coffee',                  'TXN-0017', DATE_SUB(NOW(), INTERVAL 26 DAY),  DATE_SUB(NOW(), INTERVAL 25 DAY)),
(5,  5,  35.00,  'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Uber Eats',               'TXN-0018', DATE_SUB(NOW(), INTERVAL 20 DAY),  DATE_SUB(NOW(), INTERVAL 19 DAY)),
(5,  1,  129.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Amazon Prime renewal',    'TXN-0019', DATE_SUB(NOW(), INTERVAL 15 DAY),  DATE_SUB(NOW(), INTERVAL 14 DAY)),
(5,  NULL,100.00,'USD', 1.0,     1.50, 'atm_withdrawal', 'completed', 'atm',          'ATM withdrawal',          'TXN-0020', DATE_SUB(NOW(), INTERVAL 10 DAY),  DATE_SUB(NOW(), INTERVAL 10 DAY)),
(5,  14,  42.75, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'CVS pharmacy',            'TXN-0021', DATE_SUB(NOW(), INTERVAL 7 DAY),   DATE_SUB(NOW(), INTERVAL 6 DAY)),
(5,  12,  95.40, 'USD', 1.0,     0.00, 'purchase',      'failed',    'card_present', 'Whole Foods (declined)',  'TXN-0022', DATE_SUB(NOW(), INTERVAL 3 DAY),   NULL),
(5,  3,   6.00,  'USD', 1.0,     0.00, 'purchase',      'pending',   'contactless',  'Starbucks',               'TXN-0023', DATE_SUB(NOW(), INTERVAL 2 HOUR),  NULL),

-- Carol debit card (card 6)
(6,  10,  9.99,  'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'McDonald''s',             'TXN-0024', DATE_SUB(NOW(), INTERVAL 25 DAY),  DATE_SUB(NOW(), INTERVAL 24 DAY)),
(6,  2,  67.33,  'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Grocery run',             'TXN-0025', DATE_SUB(NOW(), INTERVAL 18 DAY),  DATE_SUB(NOW(), INTERVAL 17 DAY)),
(6,  4,  15.99,  'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Netflix',                 'TXN-0026', DATE_SUB(NOW(), INTERVAL 14 DAY),  DATE_SUB(NOW(), INTERVAL 13 DAY)),
(6,  5,  14.50,  'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Uber ride',               'TXN-0027', DATE_SUB(NOW(), INTERVAL 8 DAY),   DATE_SUB(NOW(), INTERVAL 7 DAY)),
(6,  NULL, 60.00,'USD', 1.0,     1.00, 'atm_withdrawal', 'completed', 'atm',          'Cash withdrawal',         'TXN-0028', DATE_SUB(NOW(), INTERVAL 4 DAY),   DATE_SUB(NOW(), INTERVAL 4 DAY)),

-- David debit card (card 7) — GBP with FX
(7,  7,  55.00,  'GBP', 1.265,  0.00, 'purchase',      'completed', 'card_present', 'Shell petrol',            'TXN-0029', DATE_SUB(NOW(), INTERVAL 22 DAY),  DATE_SUB(NOW(), INTERVAL 21 DAY)),
(7,  1,  39.99,  'GBP', 1.265,  0.00, 'purchase',      'completed', 'online',       'Amazon UK',               'TXN-0030', DATE_SUB(NOW(), INTERVAL 14 DAY),  DATE_SUB(NOW(), INTERVAL 13 DAY)),
(7,  4,  10.99,  'GBP', 1.265,  0.00, 'purchase',      'completed', 'online',       'Netflix UK',              'TXN-0031', DATE_SUB(NOW(), INTERVAL 14 DAY),  DATE_SUB(NOW(), INTERVAL 13 DAY)),

-- Frank amex credit card (card 9)
(9,  6,  1299.00,'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'MacBook accessory kit',   'TXN-0032', DATE_SUB(NOW(), INTERVAL 20 DAY),  DATE_SUB(NOW(), INTERVAL 19 DAY)),
(9,  13, 850.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Business flight',         'TXN-0033', DATE_SUB(NOW(), INTERVAL 16 DAY),  DATE_SUB(NOW(), INTERVAL 15 DAY)),
(9,  9,  220.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Hotel via Airbnb',        'TXN-0034', DATE_SUB(NOW(), INTERVAL 12 DAY),  DATE_SUB(NOW(), INTERVAL 11 DAY)),
(9,  15,  99.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'SaaS subscription',       'TXN-0035', DATE_SUB(NOW(), INTERVAL 5 DAY),   DATE_SUB(NOW(), INTERVAL 4 DAY)),
(9,  1,  350.00, 'USD', 1.0,     0.00, 'purchase',      'pending',   'online',       'Amazon bulk order',       'TXN-0036', DATE_SUB(NOW(), INTERVAL 6 HOUR),  NULL),

-- Grace discover debit card (card 10)
(10, 3,   4.95,  'USD', 1.0,     0.00, 'purchase',      'completed', 'contactless',  'Starbucks',               'TXN-0037', DATE_SUB(NOW(), INTERVAL 27 DAY),  DATE_SUB(NOW(), INTERVAL 26 DAY)),
(10, 2,  133.77, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Walmart grocery',         'TXN-0038', DATE_SUB(NOW(), INTERVAL 20 DAY),  DATE_SUB(NOW(), INTERVAL 19 DAY)),
(10, 5,   9.75,  'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Uber pool',               'TXN-0039', DATE_SUB(NOW(), INTERVAL 11 DAY),  DATE_SUB(NOW(), INTERVAL 10 DAY)),
(10, 14,  28.00, 'USD', 1.0,     0.00, 'purchase',      'reversed',  'card_present', 'CVS (reversed)',          'TXN-0040', DATE_SUB(NOW(), INTERVAL 6 DAY),   NULL),

-- Isla debit card (card 12) — AUD with FX
(12, 1,  120.00, 'AUD', 0.645,  0.00, 'purchase',      'completed', 'online',       'Amazon AU',               'TXN-0041', DATE_SUB(NOW(), INTERVAL 21 DAY),  DATE_SUB(NOW(), INTERVAL 20 DAY)),
(12, 11,  12.99, 'AUD', 0.645,  0.00, 'purchase',      'completed', 'online',       'Spotify AU',              'TXN-0042', DATE_SUB(NOW(), INTERVAL 14 DAY),  DATE_SUB(NOW(), INTERVAL 13 DAY)),
(12, 5,   25.00, 'AUD', 0.645,  0.00, 'purchase',      'completed', 'online',       'Uber Sydney',             'TXN-0043', DATE_SUB(NOW(), INTERVAL 8 DAY),   DATE_SUB(NOW(), INTERVAL 7 DAY)),

-- James debit card (card 13)
(13, 2,  245.10, 'USD', 1.0,     0.00, 'purchase',      'completed', 'card_present', 'Walmart big shop',        'TXN-0044', DATE_SUB(NOW(), INTERVAL 29 DAY),  DATE_SUB(NOW(), INTERVAL 28 DAY)),
(13, 3,   6.80,  'USD', 1.0,     0.00, 'purchase',      'completed', 'contactless',  'Coffee',                  'TXN-0045', DATE_SUB(NOW(), INTERVAL 24 DAY),  DATE_SUB(NOW(), INTERVAL 23 DAY)),
(13, 1,  499.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Amazon electronics',      'TXN-0046', DATE_SUB(NOW(), INTERVAL 18 DAY),  DATE_SUB(NOW(), INTERVAL 17 DAY)),
(13, 13, 310.00, 'USD', 1.0,     0.00, 'purchase',      'completed', 'online',       'Delta flight',            'TXN-0047', DATE_SUB(NOW(), INTERVAL 10 DAY),  DATE_SUB(NOW(), INTERVAL 9 DAY)),
(13, NULL,300.00,'USD', 1.0,     3.00, 'atm_withdrawal', 'completed', 'atm',          'Large cash withdrawal',   'TXN-0048', DATE_SUB(NOW(), INTERVAL 5 DAY),   DATE_SUB(NOW(), INTERVAL 5 DAY)),
(13, 15,  49.00, 'USD', 1.0,     0.00, 'purchase',      'pending',   'online',       'SaaS tool',               'TXN-0049', DATE_SUB(NOW(), INTERVAL 3 HOUR),  NULL),

-- A chargeback example
(2,  1,  299.99, 'USD', 1.0,     0.00, 'chargeback',    'completed', 'online',       'Chargeback for TXN-0004', 'TXN-0050', DATE_SUB(NOW(), INTERVAL 20 DAY),  DATE_SUB(NOW(), INTERVAL 18 DAY));
