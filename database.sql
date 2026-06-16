-- ============================================================
--  FILE: database.sql
--  MỤC ĐÍCH: Tạo database, bảng và dữ liệu mẫu cho hệ thống
--             Quản lý Sinh viên (Bản đầy đủ)
--  CÁCH DÙNG: Chạy file này trên SQL Server Management Studio
--             hoặc Azure Data Studio, kết nối server localhost,
--             user sa, password 123
-- ============================================================

-- BƯỚC 1: Tạo Database
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLySinhVien')
BEGIN
    ALTER DATABASE QuanLySinhVien SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLySinhVien;
END
GO

CREATE DATABASE QuanLySinhVien
    COLLATE Vietnamese_CI_AS;  -- Hỗ trợ tiếng Việt
GO

USE QuanLySinhVien;
GO

-- ============================================================
-- BƯỚC 2: Tạo bảng Users (lưu thông tin người dùng & phân quyền)
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
-- BƯỚC 3: Tạo bảng Classes (quản lý lớp học)
-- ============================================================
CREATE TABLE Classes (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    class_name  NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(255) NULL,
    created_at  DATETIME      DEFAULT GETDATE()
);
GO

-- ============================================================
-- BƯỚC 4: Tạo bảng Students (quản lý thông tin sinh viên)
-- ============================================================
CREATE TABLE Students (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    student_code  NVARCHAR(20)  NOT NULL UNIQUE,
    full_name     NVARCHAR(100) NOT NULL,
    email         NVARCHAR(100) NOT NULL UNIQUE,
    phone         NVARCHAR(20)  NULL,
    gender        NVARCHAR(10)  NULL CHECK (gender IN (N'Nam', N'Nữ', N'Khác')),
    date_of_birth DATE          NULL,
    address       NVARCHAR(255) NULL,
    class_id      INT           FOREIGN KEY REFERENCES Classes(id) ON DELETE SET NULL,
    status        NVARCHAR(20)  DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    created_at    DATETIME      DEFAULT GETDATE()
);
GO

-- ============================================================
-- BƯỚC 5: Tạo bảng Scores (quản lý điểm số sinh viên)
-- ============================================================
CREATE TABLE Scores (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    student_id    INT           FOREIGN KEY REFERENCES Students(id) ON DELETE CASCADE,
    subject_name  NVARCHAR(100) NOT NULL,
    midterm_score DECIMAL(4,2)  NOT NULL CHECK (midterm_score >= 0 AND midterm_score <= 10),
    final_score   DECIMAL(4,2)  NOT NULL CHECK (final_score >= 0 AND final_score <= 10),
    gpa           DECIMAL(4,2)  NOT NULL CHECK (gpa >= 0 AND gpa <= 10),
    semester      NVARCHAR(20)  NOT NULL
);
GO

-- ============================================================
-- BƯỚC 6: Tạo bảng AuditLogs (theo dõi lịch sử hoạt động)
-- ============================================================
CREATE TABLE AuditLogs (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    username    NVARCHAR(50)  NOT NULL,
    action      NVARCHAR(100) NOT NULL,
    description NVARCHAR(255) NULL,
    created_at  DATETIME      DEFAULT GETDATE()
);
GO

-- ============================================================
-- BƯỚC 7: Chèn dữ liệu mẫu
-- ============================================================

-- Mật khẩu đã hash bằng BCrypt (đều có raw password là: admin123 và teacher123)
-- admin: $2a$10$wR67hVw/d5U1g8n9o0m1ue4Z9L3.Y8M6jC3b7K6C5v8m2t4o9u0w6 (admin123)
-- teacher: $2a$10$vI8aWBnW3fPy.reDV8B/kuK4YJ3e2X65JdZ4Q6Q/1M92n2p6K07xO (teacher123)
INSERT INTO Users (username, password, role) VALUES
    (N'admin', N'$2a$10$wR67hVw/d5U1g8n9o0m1ue4Z9L3.Y8M6jC3b7K6C5v8m2t4o9u0w6', N'Admin'),
    (N'teacher', N'$2a$10$vI8aWBnW3fPy.reDV8B/kuK4YJ3e2X65JdZ4Q6Q/1M92n2p6K07xO', N'User');
GO

-- Lớp học mẫu
INSERT INTO Classes (class_name, description) VALUES
    (N'Lớp CNTT K16A', N'Công nghệ thông tin - Khóa 16 - Lớp A'),
    (N'Lớp KHMT K16B', N'Khoa học máy tính - Khóa 16 - Lớp B'),
    (N'Lớp KTPM K16C', N'Kỹ thuật phần mềm - Khóa 16 - Lớp C');
GO

-- Sinh viên mẫu
INSERT INTO Students (student_code, full_name, email, phone, gender, date_of_birth, address, class_id, status) VALUES
    (N'SV001', N'Nguyễn Văn An', N'nguyenvanan@email.com', N'0912345678', N'Nam', '2004-05-15', N'Hà Nội', 1, 'Active'),
    (N'SV002', N'Trần Thị Bình', N'tranthibinh@email.com', N'0923456789', N'Nữ', '2004-08-20', N'Đà Nẵng', 1, 'Active'),
    (N'SV003', N'Lê Minh Cường', N'leminhcuong@email.com', N'0934567890', N'Nam', '2004-12-10', N'TP. Hồ Chí Minh', 2, 'Active'),
    (N'SV004', N'Phạm Thị Dung', N'phamthidung@email.com', N'0945678901', N'Nữ', '2004-02-25', N'Cần Thơ', 2, 'Active'),
    (N'SV005', N'Hoàng Văn Em', N'hoangvanem@email.com', N'0956789012', N'Nam', '2004-07-07', N'Hải Phòng', 3, 'Active'),
    (N'SV006', N'Vũ Thị Phương', N'vuthiphuong@email.com', N'0967890123', N'Nữ', '2004-11-30', N'Quảng Ninh', 1, 'Active'),
    (N'SV007', N'Đặng Văn Giang', N'dangvangiang@email.com', N'0978901234', N'Nam', '2004-03-12', N'Nghệ An', 2, 'Active'),
    (N'SV008', N'Bùi Thị Hoa', N'buithihoa@email.com', N'0989012345', N'Nữ', '2004-09-05', N'Thanh Hóa', 3, 'Active'),
    (N'SV009', N'Ngô Văn Ích', N'ngovanich@email.com', N'0990123456', N'Nam', '2004-06-18', N'Bắc Ninh', 1, 'Active'),
    (N'SV010', N'Trịnh Thị Kim', N'trinhthikim@email.com', N'0901234567', N'Nữ', '2004-01-22', N'Huế', 3, 'Active'),
    (N'SV011', N'Đinh Văn Long', N'dinhvanlong@email.com', N'0911111111', N'Nam', '2004-10-02', N'Hải Dương', 1, 'Active'),
    (N'SV012', N'Lý Thị Mây', N'lythimay@email.com', N'0922222222', N'Nữ', '2004-04-14', N'Lâm Đồng', 2, 'Active');
GO

-- Điểm mẫu
INSERT INTO Scores (student_id, subject_name, midterm_score, final_score, gpa, semester) VALUES
    (1, N'Lập trình Java Web', 8.5, 9.0, 8.85, N'Học kỳ 2 - 2025'),
    (1, N'Cơ sở dữ liệu SQL Server', 7.5, 8.0, 7.85, N'Học kỳ 2 - 2025'),
    (2, N'Lập trình Java Web', 9.0, 9.5, 9.35, N'Học kỳ 2 - 2025'),
    (2, N'Cơ sở dữ liệu SQL Server', 8.0, 8.5, 8.35, N'Học kỳ 2 - 2025'),
    (3, N'Toán rời rạc nâng cao', 6.0, 7.0, 6.70, N'Học kỳ 2 - 2025'),
    (3, N'Lập trình Java Web', 7.0, 8.0, 7.70, N'Học kỳ 2 - 2025'),
    (4, N'Cấu trúc dữ liệu & Giải thuật', 5.0, 6.5, 6.05, N'Học kỳ 2 - 2025'),
    (5, N'Mạng máy tính cơ bản', 8.0, 7.0, 7.30, N'Học kỳ 2 - 2025'),
    (6, N'Lập trình Java Web', 9.0, 9.0, 9.00, N'Học kỳ 2 - 2025'),
    (7, N'Toán rời rạc nâng cao', 5.5, 6.0, 5.85, N'Học kỳ 2 - 2025'),
    (8, N'Mạng máy tính cơ bản', 7.5, 8.0, 7.85, N'Học kỳ 2 - 2025'),
    (9, N'Lập trình Java Web', 8.0, 8.5, 8.35, N'Học kỳ 2 - 2025'),
    (10, N'Mạng máy tính cơ bản', 9.5, 9.5, 9.50, N'Học kỳ 2 - 2025'),
    (11, N'Cơ sở dữ liệu SQL Server', 6.5, 7.0, 6.85, N'Học kỳ 2 - 2025'),
    (12, N'Toán rời rạc nâng cao', 8.0, 8.2, 8.14, N'Học kỳ 2 - 2025');
GO

-- Hoạt động mẫu
INSERT INTO AuditLogs (username, action, description) VALUES
    (N'system', N'Initialize DB', N'Hệ thống khởi tạo thành công dữ liệu mẫu.'),
    (N'admin', N'Đăng nhập', N'Quản trị viên đăng nhập vào hệ thống.'),
    (N'admin', N'Thêm lớp học', N'Thêm lớp học CNTT K16A.');
GO
