CREATE TABLE IF NOT EXISTS commission_configs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id BIGINT UNSIGNED NULL,
  seller_tier ENUM('NEW','TRUSTED','PRO') NULL,
  rate_percent DECIMAL(5,2) NOT NULL,
  min_fee BIGINT UNSIGNED NOT NULL DEFAULT 0,
  max_fee BIGINT UNSIGNED NULL,
  effective_from DATETIME NOT NULL,
  effective_to DATETIME NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_commission_cat_tier (category_id, seller_tier, is_active),
  INDEX idx_commission_dates (effective_from, effective_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
