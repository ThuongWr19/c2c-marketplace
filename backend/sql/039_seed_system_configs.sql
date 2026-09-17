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
