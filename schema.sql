-- =============================================================
-- Card Transaction Practice Database  (MySQL 8.0+)
-- Tables: users, accounts, cards, merchants, transactions
-- =============================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;


-- -------------------------------------------------------------
-- USERS
-- -------------------------------------------------------------
CREATE TABLE users (
    user_id       INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    date_of_birth DATE,
    country       CHAR(2)      NOT NULL DEFAULT 'US',   -- ISO 3166-1 alpha-2
    kyc_status    VARCHAR(20)  NOT NULL DEFAULT 'pending'
                      CHECK (kyc_status IN ('pending', 'verified', 'failed')),
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------
-- ACCOUNTS  (one user can have multiple accounts)
-- -------------------------------------------------------------
CREATE TABLE accounts (
    account_id     INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id        INT           NOT NULL,
    account_number VARCHAR(20)   NOT NULL UNIQUE,
    account_type   VARCHAR(20)   NOT NULL CHECK (account_type IN ('checking', 'savings', 'credit')),
    currency       CHAR(3)       NOT NULL DEFAULT 'USD',
    balance        DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    credit_limit   DECIMAL(15,2),                        -- NULL for non-credit accounts
    status         VARCHAR(20)   NOT NULL DEFAULT 'active'
                       CHECK (status IN ('active', 'frozen', 'closed')),
    opened_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at      DATETIME,
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------
-- CARDS  (one account can have multiple cards)
-- -------------------------------------------------------------
CREATE TABLE cards (
    card_id        INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
    account_id     INT         NOT NULL,
    user_id        INT         NOT NULL,
    last_four      CHAR(4)     NOT NULL,
    card_network   VARCHAR(20) NOT NULL CHECK (card_network IN ('visa', 'mastercard', 'amex', 'discover')),
    card_type      VARCHAR(20) NOT NULL CHECK (card_type IN ('debit', 'credit', 'prepaid')),
    expiry_date    DATE        NOT NULL,
    is_virtual     BOOLEAN     NOT NULL DEFAULT FALSE,
    status         VARCHAR(20) NOT NULL DEFAULT 'active'
                       CHECK (status IN ('active', 'blocked', 'expired', 'cancelled')),
    issued_at      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cards_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_cards_user    FOREIGN KEY (user_id)    REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------
-- MERCHANTS
-- -------------------------------------------------------------
CREATE TABLE merchants (
    merchant_id   INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    mcc_code      CHAR(4)      NOT NULL,   -- Merchant Category Code
    category      VARCHAR(50)  NOT NULL,   -- human-readable category
    country       CHAR(2)      NOT NULL DEFAULT 'US',
    city          VARCHAR(50),
    is_online     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------
-- TRANSACTIONS
-- -------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id   INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
    card_id          INT           NOT NULL,
    merchant_id      INT,                                                -- NULL for ATM/P2P
    amount           DECIMAL(12,2) NOT NULL,
    currency         CHAR(3)       NOT NULL DEFAULT 'USD',
    fx_rate          DECIMAL(10,6) NOT NULL DEFAULT 1.000000,           -- 1.0 if no FX conversion
    amount_usd       DECIMAL(12,2) GENERATED ALWAYS AS (ROUND(amount * fx_rate, 2)) STORED,
    fee              DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
    type             VARCHAR(30)   NOT NULL
                         CHECK (type IN ('purchase', 'refund', 'atm_withdrawal',
                                         'transfer_in', 'transfer_out', 'fee', 'chargeback')),
    status           VARCHAR(20)   NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending', 'completed', 'failed',
                                           'reversed', 'disputed')),
    channel          VARCHAR(20)   NOT NULL DEFAULT 'card_present'
                         CHECK (channel IN ('card_present', 'card_not_present',
                                            'contactless', 'atm', 'online')),
    description      VARCHAR(200),
    reference_id     VARCHAR(50)   UNIQUE,                              -- external ref / idempotency key
    initiated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    settled_at       DATETIME,
    metadata         JSON,                                              -- flexible bag for extra fields
    CONSTRAINT fk_transactions_card     FOREIGN KEY (card_id)     REFERENCES cards(card_id),
    CONSTRAINT fk_transactions_merchant FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Useful indexes for practice queries
CREATE INDEX idx_transactions_card_id      ON transactions(card_id);
CREATE INDEX idx_transactions_merchant_id  ON transactions(merchant_id);
CREATE INDEX idx_transactions_initiated_at ON transactions(initiated_at);
CREATE INDEX idx_transactions_status       ON transactions(status);
CREATE INDEX idx_accounts_user_id          ON accounts(user_id);
CREATE INDEX idx_cards_account_id          ON cards(account_id);
