CREATE TABLE IF NOT EXISTS wallet_transactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  wallet_id BIGINT UNSIGNED NOT NULL,
  type ENUM('DEPOSIT','PAYMENT','ESCROW_HOLD','ESCROW_RELEASE','REFUND','WITHDRAWAL','COMMISSION','ADJUSTMENT') NOT NULL,
  amount BIGINT NOT NULL,
  balance_after BIGINT NOT NULL,
  reference_type ENUM('TRANSACTION','WITHDRAWAL','TOPUP','REFUND','ADJUSTMENT') NOT NULL,
  reference_id BIGINT UNSIGNED NULL,
  description VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE RESTRICT,
  INDEX idx_wallet_tx_wallet (wallet_id, created_at DESC),
  INDEX idx_wallet_tx_ref (reference_type, reference_id),
  INDEX idx_wallet_tx_type (type, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
