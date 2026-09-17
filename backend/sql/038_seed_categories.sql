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
