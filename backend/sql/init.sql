-- =====================================================
-- C2C MARKETPLACE - DATABASE SCHEMA
-- MySQL 8.0+, InnoDB, utf8mb4
-- =====================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1. USERS
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  slug VARCHAR(120) UNIQUE NOT NULL,
  avatar_url VARCHAR(512) NULL,
  bio VARCHAR(200) NULL,
  phone VARCHAR(20) UNIQUE NULL,
  phone_verified_at DATETIME NULL,
  email_verified_at DATETIME NULL,
  gender ENUM('MALE','FEMALE','OTHER') NULL,
  date_of_birth DATE NULL,
  default_address VARCHAR(255) NULL,
  latitude DECIMAL(10,8) NULL,
  longitude DECIMAL(11,8) NULL,
  role ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
  reputation_score TINYINT UNSIGNED NOT NULL DEFAULT 50,
  seller_tier ENUM('NEW','TRUSTED','PRO') NOT NULL DEFAULT 'NEW',
  identity_verified_at DATETIME NULL,
  identity_document_url VARCHAR(512) NULL,
  status ENUM('ACTIVE','LOCKED','DELETED') NOT NULL DEFAULT 'ACTIVE',
  locked_reason VARCHAR(255) NULL,
  deleted_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_role_status (role, status),
  INDEX idx_users_reputation (reputation_score),
  INDEX idx_users_seller_tier (seller_tier, status),
  INDEX idx_users_created_at (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 2. AUTH TOKENS
-- =====================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) UNIQUE NOT NULL,
  device_info VARCHAR(255) NULL,
  ip_address VARCHAR(45) NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_refresh_user_revoked (user_id, revoked_at),
  INDEX idx_refresh_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) UNIQUE NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_reset_user (user_id),
  INDEX idx_reset_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS email_verification_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) UNIQUE NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_verify_user (user_id),
  INDEX idx_verify_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS device_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token VARCHAR(255) UNIQUE NOT NULL,
  platform ENUM('IOS','ANDROID','WEB') NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_device_user_active (user_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. CATEGORIES
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  parent_id BIGINT UNSIGNED NULL,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(120) UNIQUE NOT NULL,
  icon_url VARCHAR(512) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE RESTRICT,
  INDEX idx_cat_parent_active (parent_id, is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. LISTINGS
-- =====================================================
CREATE TABLE IF NOT EXISTS listings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  seller_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  slug VARCHAR(220) UNIQUE NOT NULL,
  description TEXT NOT NULL,
  price BIGINT UNSIGNED NOT NULL,
  original_price BIGINT UNSIGNED NULL,
  condition ENUM('NEW','LIKE_NEW','GOOD','FAIR','POOR') NOT NULL,
  status ENUM('DRAFT','PENDING','ACTIVE','REJECTED','HIDDEN','RESERVED','SOLD') NOT NULL DEFAULT 'DRAFT',
  reject_reason VARCHAR(255) NULL,
  hide_reason VARCHAR(255) NULL,
  reserved_offer_id BIGINT UNSIGNED NULL,
  address VARCHAR(255) NULL,
  latitude DECIMAL(10,8) NOT NULL,
  longitude DECIMAL(11,8) NOT NULL,
  location POINT SRID 4326 NOT NULL,
  view_count INT UNSIGNED NOT NULL DEFAULT 0,
  offer_count INT UNSIGNED NOT NULL DEFAULT 0,
  wishlist_count INT UNSIGNED NOT NULL DEFAULT 0,
  is_boosted BOOLEAN NOT NULL DEFAULT FALSE,
  boosted_until DATETIME NULL,
  published_at DATETIME NULL,
  sold_at DATETIME NULL,
  version INT UNSIGNED NOT NULL DEFAULT 0,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  INDEX idx_listings_seller_status (seller_id, status),
  INDEX idx_listings_cat_status_price (category_id, status, price),
  INDEX idx_listings_status_published (status, published_at DESC),
  INDEX idx_listings_status_boosted (status, is_boosted, published_at DESC),
  SPATIAL INDEX idx_listings_location (location),
  FULLTEXT INDEX idx_listings_fts (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE IF NOT EXISTS listing_price_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  listing_id BIGINT UNSIGNED NOT NULL,
  old_price BIGINT UNSIGNED NOT NULL,
  new_price BIGINT UNSIGNED NOT NULL,
  changed_by BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_price_history_listing (listing_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 5. OFFERS & TRANSACTIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS offers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  listing_id BIGINT UNSIGNED NOT NULL,
  buyer_id BIGINT UNSIGNED NOT NULL,
  seller_id BIGINT UNSIGNED NOT NULL,
  offered_price BIGINT UNSIGNED NOT NULL,
  message VARCHAR(500) NULL,
  status ENUM('PENDING','ACCEPTED','REJECTED','EXPIRED','WITHDRAWN','COMPLETED') NOT NULL DEFAULT 'PENDING',
  reject_reason VARCHAR(255) NULL,
  responded_at DATETIME NULL,
  expires_at DATETIME NOT NULL,
  version INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE RESTRICT,
  FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_offers_listing_status (listing_id, status),
  INDEX idx_offers_buyer_status (buyer_id, status, created_at DESC),
  INDEX idx_offers_seller_status (seller_id, status, created_at DESC),
  INDEX idx_offers_pending_expires (status, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS transactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  listing_id BIGINT UNSIGNED NOT NULL,
  offer_id BIGINT UNSIGNED UNIQUE NOT NULL,
  buyer_id BIGINT UNSIGNED NOT NULL,
  seller_id BIGINT UNSIGNED NOT NULL,
  amount BIGINT UNSIGNED NOT NULL,
  commission_amount BIGINT UNSIGNED NOT NULL DEFAULT 0,
  net_amount BIGINT UNSIGNED NOT NULL DEFAULT 0,
  payment_method ENUM('WALLET','VIETQR','MOMO','ZALOPAY','CARD','COD','MEETUP') NOT NULL,
  payment_status ENUM('PENDING_PAYMENT','PAID_IN_ESCROW','COD_PENDING','SHIPPED','DISPUTED','COMPLETED','REFUNDED','PARTIALLY_REFUNDED','CANCELLED') NOT NULL DEFAULT 'PENDING_PAYMENT',
  delivery_method ENUM('SHIP','MEETUP') NOT NULL,
  shipping_address VARCHAR(500) NULL,
  tracking_number VARCHAR(100) NULL,
  shipped_at DATETIME NULL,
  received_at DATETIME NULL,
  auto_release_at DATETIME NULL,
  escrow_released_at DATETIME NULL,
  cancelled_at DATETIME NULL,
  cancel_reason VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE RESTRICT,
  FOREIGN KEY (offer_id) REFERENCES offers(id) ON DELETE RESTRICT,
  FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_tx_buyer_status (buyer_id, payment_status, created_at DESC),
  INDEX idx_tx_seller_status (seller_id, payment_status, created_at DESC),
  INDEX idx_tx_listing (listing_id),
  INDEX idx_tx_auto_release (payment_status, auto_release_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cancellation_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  transaction_id BIGINT UNSIGNED NOT NULL,
  cancelled_by BIGINT UNSIGNED NOT NULL,
  role ENUM('BUYER','SELLER','ADMIN','SYSTEM') NOT NULL,
  reason VARCHAR(255) NOT NULL,
  reputation_impact TINYINT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_cancel_tx (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  transaction_id BIGINT UNSIGNED NOT NULL,
  reviewer_id BIGINT UNSIGNED NOT NULL,
  reviewee_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT NULL,
  images JSON NULL,
  seller_reply TEXT NULL,
  seller_replied_at DATETIME NULL,
  is_visible BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_review_tx_reviewer (transaction_id, reviewer_id),
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (reviewee_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_reviews_reviewee (reviewee_id, is_visible, created_at DESC),
  INDEX idx_reviews_reviewer (reviewer_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 6. WALLETS & PAYMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS wallets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED UNIQUE NOT NULL,
  balance BIGINT NOT NULL DEFAULT 0,
  pending_balance BIGINT NOT NULL DEFAULT 0,
  frozen_balance BIGINT NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'VND',
  version INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE IF NOT EXISTS payment_intents (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  transaction_id BIGINT UNSIGNED NOT NULL,
  buyer_id BIGINT UNSIGNED NOT NULL,
  amount BIGINT UNSIGNED NOT NULL,
  method ENUM('WALLET','VIETQR','MOMO','ZALOPAY','CARD','COD','MEETUP') NOT NULL,
  status ENUM('INITIATED','PROCESSING','SUCCESS','FAILED','EXPIRED','CANCELLED') NOT NULL DEFAULT 'INITIATED',
  gateway_ref VARCHAR(128) NULL,
  gateway_response JSON NULL,
  idempotency_key VARCHAR(64) UNIQUE NOT NULL,
  expires_at DATETIME NOT NULL,
  paid_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_payment_tx (transaction_id),
  INDEX idx_payment_buyer_status (buyer_id, status),
  INDEX idx_payment_status_expires (status, expires_at),
  INDEX idx_payment_gateway (gateway_ref)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bank_accounts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  bank_code VARCHAR(20) NOT NULL,
  bank_name VARCHAR(100) NOT NULL,
  account_number_encrypted VARBINARY(512) NOT NULL,
  account_number_last4 CHAR(4) NOT NULL,
  account_number_hash CHAR(64) NOT NULL,
  account_name VARCHAR(100) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at DATETIME NULL,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_bank_user (user_id, deleted_at),
  INDEX idx_bank_hash (account_number_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS withdrawals (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  wallet_id BIGINT UNSIGNED NOT NULL,
  bank_account_id BIGINT UNSIGNED NOT NULL,
  amount BIGINT UNSIGNED NOT NULL,
  fee BIGINT UNSIGNED NOT NULL DEFAULT 0,
  net_amount BIGINT UNSIGNED NOT NULL,
  status ENUM('PENDING','APPROVED','PROCESSING','SUCCESS','FAILED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  admin_id BIGINT UNSIGNED NULL,
  approved_at DATETIME NULL,
  processed_at DATETIME NULL,
  failure_reason VARCHAR(255) NULL,
  gateway_ref VARCHAR(128) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE RESTRICT,
  FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id) ON DELETE RESTRICT,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_withdraw_user_status (user_id, status),
  INDEX idx_withdraw_status_created (status, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS refunds (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  transaction_id BIGINT UNSIGNED NOT NULL,
  amount BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NOT NULL,
  status ENUM('PENDING','APPROVED','PROCESSED','FAILED') NOT NULL DEFAULT 'PENDING',
  refunded_to ENUM('WALLET','GATEWAY') NOT NULL,
  gateway_refund_ref VARCHAR(128) NULL,
  approved_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  processed_at DATETIME NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE RESTRICT,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_refund_tx (transaction_id),
  INDEX idx_refund_status (status, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- =====================================================
-- 7. SOCIAL / CHAT / NOTIFICATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS conversations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  listing_id BIGINT UNSIGNED NOT NULL,
  buyer_id BIGINT UNSIGNED NOT NULL,
  seller_id BIGINT UNSIGNED NOT NULL,
  last_message_at DATETIME NULL,
  last_message_preview VARCHAR(200) NULL,
  buyer_unread_count INT UNSIGNED NOT NULL DEFAULT 0,
  seller_unread_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_conversation (listing_id, buyer_id, seller_id),
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
  FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_conv_buyer (buyer_id, last_message_at DESC),
  INDEX idx_conv_seller (seller_id, last_message_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS chat_messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  receiver_id BIGINT UNSIGNED NOT NULL,
  content TEXT NULL,
  image_url VARCHAR(512) NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  read_at DATETIME NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_msg_conversation (conversation_id, created_at DESC),
  INDEX idx_msg_receiver_unread (receiver_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('OFFER_CREATED','OFFER_ACCEPTED','OFFER_REJECTED','LISTING_APPROVED','LISTING_REJECTED','TRANSACTION_COMPLETED','REVIEW_RECEIVED','MESSAGE_RECEIVED','DISPUTE_OPENED','DISPUTE_RESOLVED','WITHDRAWAL_APPROVED','WITHDRAWAL_REJECTED','SYSTEM') NOT NULL,
  title VARCHAR(200) NOT NULL,
  content VARCHAR(500) NULL,
  reference_type VARCHAR(50) NULL,
  reference_id BIGINT UNSIGNED NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  read_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notif_user_read (user_id, is_read, created_at DESC),
  INDEX idx_notif_user_created (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notification_preferences (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED UNIQUE NOT NULL,
  email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  inapp_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  type_preferences JSON NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wishlists (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  listing_id BIGINT UNSIGNED NOT NULL,
  price_at_add BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_wishlist_user_listing (user_id, listing_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
  INDEX idx_wishlist_user (user_id, created_at DESC),
  INDEX idx_wishlist_listing (listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS follows (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  follower_id BIGINT UNSIGNED NOT NULL,
  following_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_follow (follower_id, following_id),
  FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_follow_following (following_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS blocks (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  blocker_id BIGINT UNSIGNED NOT NULL,
  blocked_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_block (blocker_id, blocked_id),
  FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_block_blocked (blocked_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS search_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  keyword VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_search_user (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS view_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  listing_id BIGINT UNSIGNED NOT NULL,
  viewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
  INDEX idx_view_user (user_id, viewed_at DESC),
  INDEX idx_view_listing (listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS saved_searches (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(100) NULL,
  filters JSON NOT NULL,
  notify_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  last_notified_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_saved_search_user (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS quick_replies (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(100) NOT NULL,
  content VARCHAR(500) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_quick_reply_user (user_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 8. MODERATION & AUDIT
-- =====================================================
CREATE TABLE IF NOT EXISTS reports (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reporter_id BIGINT UNSIGNED NOT NULL,
  target_type ENUM('LISTING','USER','REVIEW','MESSAGE') NOT NULL,
  target_id BIGINT UNSIGNED NOT NULL,
  reason ENUM('FAKE_GOODS','FRAUD','PROHIBITED_CONTENT','SPAM','HARASSMENT','OTHER') NOT NULL,
  description TEXT NULL,
  evidence_images JSON NULL,
  status ENUM('PENDING','REVIEWING','RESOLVED','DISMISSED') NOT NULL DEFAULT 'PENDING',
  resolved_by BIGINT UNSIGNED NULL,
  resolution_note VARCHAR(500) NULL,
  resolved_at DATETIME NULL,
  priority TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_report_target (target_type, target_id, status),
  INDEX idx_report_status_priority (status, priority DESC, created_at ASC),
  INDEX idx_report_reporter (reporter_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  entity_type VARCHAR(50) NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  action VARCHAR(100) NOT NULL,
  actor_id BIGINT UNSIGNED NULL,
  actor_role ENUM('USER','ADMIN','SYSTEM') NOT NULL,
  before_state JSON NULL,
  after_state JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_audit_entity (entity_type, entity_id, created_at DESC),
  INDEX idx_audit_actor (actor_id, created_at DESC),
  INDEX idx_audit_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS admin_audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  admin_id BIGINT UNSIGNED NOT NULL,
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(50) NOT NULL,
  target_id BIGINT UNSIGNED NULL,
  reason VARCHAR(500) NULL,
  before_state JSON NULL,
  after_state JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX idx_admin_audit_admin (admin_id, created_at DESC),
  INDEX idx_admin_audit_action (action, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS banned_keywords (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  keyword VARCHAR(100) UNIQUE NOT NULL,
  category ENUM('PROHIBITED_GOODS','FRAUD','CONTACT','OTHER') NOT NULL,
  action ENUM('FLAG','BLOCK') NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_banned_active (is_active, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 9. SYSTEM CONFIG
-- =====================================================
CREATE TABLE IF NOT EXISTS system_configs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `key` VARCHAR(100) UNIQUE NOT NULL,
  value TEXT NOT NULL,
  data_type ENUM('STRING','INT','BOOLEAN','JSON') NOT NULL,
  description VARCHAR(255) NULL,
  updated_by BIGINT UNSIGNED NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS banners (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  image_url VARCHAR(512) NOT NULL,
  link_url VARCHAR(512) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_banner_active (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 10. SEED DATA
-- =====================================================

-- Categories
INSERT IGNORE INTO categories (id, name, slug, sort_order) VALUES
(1, 'Điện tử', 'dien-tu', 1),
(2, 'Thời trang', 'thoi-trang', 2),
(3, 'Gia dụng', 'gia-dung', 3),
(4, 'Xe cộ', 'xe-co', 4),
(5, 'Sách', 'sach', 5),
(6, 'Thể thao', 'the-thao', 6),
(7, 'Đồ chơi', 'do-choi', 7),
(8, 'Khác', 'khac', 8);

INSERT IGNORE INTO categories (parent_id, name, slug, sort_order) VALUES
(1, 'Điện thoại', 'dien-thoai', 1),
(1, 'Laptop', 'laptop', 2),
(1, 'Máy ảnh', 'may-anh', 3),
(1, 'Phụ kiện', 'phu-kien', 4),
(2, 'Quần áo nam', 'quan-ao-nam', 1),
(2, 'Quần áo nữ', 'quan-ao-nu', 2),
(2, 'Giày dép', 'giay-dep', 3),
(2, 'Túi xách', 'tui-xach', 4);

-- System configs
INSERT IGNORE INTO system_configs (`key`, value, data_type, description) VALUES
('offer.min_price_percent', '30', 'INT', 'Giá offer tối thiểu so với giá niêm yết (%)'),
('offer.max_pending_per_listing', '3', 'INT', 'Số offer PENDING tối đa mỗi buyer cho một listing'),
('offer.expire_hours', '48', 'INT', 'Số giờ offer hết hạn'),
('listing.max_images', '8', 'INT', 'Số ảnh tối đa mỗi listing'),
('listing.max_image_size_mb', '5', 'INT', 'Kích thước ảnh tối đa (MB)'),
('listing.max_active_per_user', '50', 'INT', 'Số listing active tối đa mỗi user'),
('transaction.auto_confirm_days', '7', 'INT', 'Số ngày tự động xác nhận nhận hàng'),
('withdrawal.min_amount', '50000', 'INT', 'Số tiền rút tối thiểu (VND)'),
('withdrawal.max_amount_per_day', '50000000', 'INT', 'Số tiền rút tối đa mỗi ngày (VND)'),
('withdrawal.auto_approve_threshold', '5000000', 'INT', 'Ngưỡng tự động duyệt rút tiền (VND)'),
('commission.default_rate', '5.0', 'STRING', 'Tỷ lệ hoa hồng mặc định (%)'),
('commission.min_fee', '5000', 'INT', 'Phí hoa hồng tối thiểu (VND)');

SET FOREIGN_KEY_CHECKS = 1;