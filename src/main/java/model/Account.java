    package model;

    /**
     * FILE: Account.java
     * PACKAGE: model
     *
     * MỤC ĐÍCH:
     *   Model (POJO) đại diện cho một tài khoản đăng nhập trong hệ thống.
     *   Ánh xạ trực tiếp với bảng TaiKhoan trong SQL Server.
     *
     * TẠI SAO CẦN:
     *   Trong MVC, Model lưu trữ dữ liệu và chuyển đó giữa các tầng.
     *   AccountDAO trả về Account object, LoginServlet dùng Account object
     *   để kiểm tra thông tin đăng nhập.
     *
     * MUỐN THÊM CỘT DỮ LIỆU:
     *   1. Thêm field mới ở đây (ví dụ: private String email)
     *   2. Thêm getter/setter tương ứng
     *   3. Cập nhật bảng TaiKhoan trong database.sql
     *   4. Cập nhật AccountDAO để SELECT cột mới
     *
     * ÁNH XẠ VỚI DATABASE:
     *   id       → cột id (INT IDENTITY)
     *   username → cột username (NVARCHAR 50)
     *   password → cột password (NVARCHAR 255)
     */
    public class Account {

        // ============================================================
        // FIELDS - Các thuộc tính tương ứng cột trong bảng TaiKhoan
        // ============================================================
        private int    id;        // Khóa chính
        private String username;  // Tên đăng nhập
        private String password;  // Mật khẩu

        // ============================================================
        // CONSTRUCTORS
        // ============================================================

        /** Constructor không tham số - cần thiết cho một số framework */
        public Account() {}

        /**
         * Constructor đầy đủ - dùng trong AccountDAO khi đọc từ ResultSet
         */
        public Account(int id, String username, String password) {
            this.id       = id;
            this.username = username;
            this.password = password;
        }

        // ============================================================
        // GETTERS & SETTERS
        // ============================================================

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        // ============================================================
        // toString - hữu ích khi debug
        // ============================================================
        @Override
        public String toString() {
            return "Account{id=" + id + ", username='" + username + "'}";
        }
    }
