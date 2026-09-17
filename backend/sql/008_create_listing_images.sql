CREATE TABLE IF NOT EXISTS listing_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  listing_id BIGINT UNSIGNED NOT NULL,
  object_key VARCHAR(512) NOT NULL,
  thumbnail_url VARCHAR(512) NOT NULL,
  medium_url VARCHAR(512) NOT NULL,
  original_url VARCHAR(512) NOT NULL,
  width INT UNSIGNED NULL,
  height INT UNSIGNED NULL,
  file_size INT UNSIGNED NULL,
  sort_order TINYINT UNSIGNED NOT NULL DEFAULT 0,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
  INDEX idx_images_listing_order (listing_id, deleted_at, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
