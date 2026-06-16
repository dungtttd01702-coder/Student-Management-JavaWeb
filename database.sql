-- BƯỚC 1: Xóa Database cũ (nếu có) và tạo mới
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLySinhVien')
BEGIN
    ALTER DATABASE QuanLySinhVien SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLySinhVien;
END
GO

CREATE DATABASE QuanLySinhVien
    COLLATE Vietnamese_CI_AS; -- Hỗ trợ tiếng Việt
GO

USE QuanLySinhVien;
GO

-- ============================================================
-- BƯỚC 2: Tạo bảng Users (Dùng cho chức năng Đăng nhập)
-- ============================================================
CREATE TABLE Users (
    id         INT IDENTITY(1,1) PRIMARY KEY,
    username   NVARCHAR(50)  NOT NULL UNIQUE,
    password   NVARCHAR(255) NOT NULL,
    role       NVARCHAR(20)  NOT NULL CHECK (role IN ('Admin', 'User')),
    created_at DATETIME      DEFAULT GETDATE()
);
GO

-- ============================================================
-- BƯỚC 3: Tạo bảng SinhVien (Khớp 100% với StudentDAO.java)
-- ============================================================
CREATE TABLE SinhVien (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    hoTen       NVARCHAR(100) NOT NULL,
    email       VARCHAR(100)  NOT NULL UNIQUE,
    chuyenNganh NVARCHAR(100) NOT NULL,
    diemTB      FLOAT         NOT NULL
);
GO

-- ============================================================
-- BƯỚC 4: Chèn dữ liệu mẫu
-- ============================================================

-- 1. Dữ liệu bảng Users 
-- (Mật khẩu để ở dạng plain text để khớp với logic so sánh trong AccountDAO.java hiện tại)
INSERT INTO Users (username, password, role) VALUES
    (N'admin', N'admin123', N'Admin'),
    (N'teacher', N'teacher123', N'User');
GO

-- 2. Dữ liệu bảng SinhVien (Danh sách sinh viên mẫu)
INSERT INTO SinhVien (hoTen, email, chuyenNganh, diemTB) VALUES
(N'Nguyễn Văn An', 'an@fpt.edu.vn', N'Công nghệ thông tin', 8.5),
(N'Trần Thị Bình', 'binh@fpt.edu.vn', N'Khoa học máy tính', 9.0),
(N'Lê Minh Cường', 'cuong@fpt.edu.vn', N'Kỹ thuật phần mềm', 7.2),
(N'Phạm Thị Dung', 'dung@fpt.edu.vn', N'An toàn thông tin', 6.8),
(N'Hoàng Văn Em', 'em@fpt.edu.vn', N'Hệ thống thông tin', 8.9),
(N'Vũ Thị Phương', 'phuong@fpt.edu.vn', N'Công nghệ thông tin', 7.5),
(N'Đặng Văn Giang', 'giang@fpt.edu.vn', N'Khoa học máy tính', 6.0),
(N'Bùi Thị Hoa', 'hoa@fpt.edu.vn', N'Kỹ thuật phần mềm', 8.2);
GO
