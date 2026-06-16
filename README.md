# 🎓 Hệ Thống Quản Lý Sinh Viên | Java Web MVC

Một ứng dụng web toàn diện để quản lý thông tin sinh viên, lớp học và hồ sơ học tập. Xây dựng với **Java Servlet/JSP**, **JDBC**, và **SQL Server** theo kiến trúc **MVC**.

---

## ✨ Tính Năng Chính

- 🔐 **Xác Thực & Phân Quyền**: Đăng nhập an toàn với phân quyền theo vai trò (Admin/User)
- 👥 **Quản Lý Sinh Viên**: Thêm, sửa, xóa, tìm kiếm và lọc thông tin sinh viên
- 📚 **Quản Lý Lớp Học**: Tổ chức và quản lý các lớp học
- 📊 **Quản Lý Điểm**: Nhập điểm, tính GPA tự động
- 📈 **Bảng Điều Khiển**: Thống kê và biểu đồ dữ liệu
- 📱 **Giao Diện Responsive**: Tương thích trên mobile với Bootstrap 5
- 📥 **Xuất Báo Cáo**: Xuất dữ liệu ra file Excel

---

## 🛠️ Công Nghệ Sử Dụng

| Lĩnh Vực | Công Nghệ |
|----------|-----------|
| **Backend** | Java 11+, Servlet, JSP, JDBC, Maven |
| **Cơ Sở Dữ Liệu** | SQL Server 2019+ |
| **Frontend** | HTML5, CSS3, Bootstrap 5, JavaScript, Chart.js |
| **Server** | Apache Tomcat 9+ |
| **Công Cụ** | NetBeans/Eclipse, Git, GitHub |

---

## 📁 Cấu Trúc Dự Án

```
Student-Management-JavaWeb/
├── src/main/java/com/studentmanagement/
│   ├── controller/        # Các lớp Servlet
│   ├── model/             # Các lớp Entity
│   ├── dao/               # Data Access Objects
│   ├── service/           # Logic kinh doanh
│   └── util/              # Kết nối DB & trợ giúp
├── src/main/webapp/
│   ├── views/             # Các trang JSP
│   ├── assets/            # CSS, JS, hình ảnh
│   └── WEB-INF/           # File cấu hình
├── database.sql           # Schema cơ sở dữ liệu
├── pom.xml               # Các phụ thuộc Maven
└── README.md             # Tài liệu này
```

---

## 📋 Yêu Cầu Hệ Thống

- ☕ Java 11 trở lên
- 📦 Apache Maven 3.6+
- 🗄️ SQL Server 2019+
- 🚀 Apache Tomcat 9+
- 💻 IDE: NetBeans, Eclipse hoặc IntelliJ IDEA

---

## ⚙️ Hướng Dẫn Cài Đặt & Chạy

### 1️⃣ Clone Repository

```bash
git clone https://github.com/dungtttd01702-coder/Student-Management-JavaWeb.git
cd Student-Management-JavaWeb
```

### 2️⃣ Thiết Lập Cơ Sở Dữ Liệu

1. Mở **SQL Server Management Studio**
2. Chạy script `database.sql` để tạo database và dữ liệu mẫu
3. Cập nhật thông tin kết nối database trong:
   - `src/main/java/com/studentmanagement/util/DBConnection.java`

```java
// Ví dụ:
String server = "localhost";
String username = "sa";
String password = "123";
String database = "QuanLySinhVien";
```

### 3️⃣ Build & Deploy

```bash
# Xóa build cũ và build lại dự án
mvn clean package

# Copy file .war vào thư mục webapps của Tomcat
cp target/StudentManagement.war /path/to/tomcat/webapps/
```

### 4️⃣ Chạy Ứng Dụng

1. Khởi động Apache Tomcat server
2. Truy cập: `http://localhost:8080/StudentManagement`

### 5️⃣ Thông Tin Đăng Nhập Mặc Định

| Vai Trò | Username | Password |
|---------|----------|----------|
| 👨‍💼 Admin | `admin` | `admin123` |
| 👨‍🏫 User | `teacher` | `teacher123` |

---

## 🎯 Các Tính Năng Chi Tiết

### 👥 Quản Lý Sinh Viên
- ✅ Thêm, sửa, xóa thông tin sinh viên
- 🔍 Tìm kiếm theo tên, mã sinh viên, lớp học
- 🎓 Lọc theo trạng thái (Hoạt động / Không hoạt động)
- 📄 Phân trang (10 bản ghi trên mỗi trang)

### 📊 Quản Lý Điểm
- 📝 Nhập điểm giữa kỳ và cuối kỳ
- 🧮 Tính toán GPA tự động
- 📥 Xuất báo cáo điểm ra Excel
- 📈 Xem thống kê điểm theo học kỳ

### 📱 Bảng Điều Khiển
- 📊 Tổng số sinh viên, lớp học
- 📈 Biểu đồ phân bố sinh viên
- 📋 Lịch sử hoạt động gần đây
- ⭐ Danh sách sinh viên xuất sắc

---

## 🔒 Tính Năng Bảo Mật

- 🛡️ Phòng chống SQL Injection bằng PreparedStatement
- 🔐 Bảo vệ XSS (Cross-Site Scripting)
- ⏱️ Quản lý session và timeout
- 👤 Kiểm soát truy cập dựa trên vai trò (RBAC)

---

## 📊 Sơ Đồ Cơ Sở Dữ Liệu

### Các Bảng Chính:

| Bảng | Mô Tả |
|------|-------|
| **Users** | Người dùng hệ thống với vai trò |
| **Students** | Thông tin sinh viên |
| **Classes** | Quản lý lớp học |
| **Scores** | Hồ sơ học tập, điểm số |
| **AuditLogs** | Lịch sử hoạt động |

---

## 🧪 Hướng Dẫn Kiểm Thử

Kiểm thử các tính năng sau:

- ✅ Đăng nhập/Đăng xuất
- ✅ Thêm, sửa, xóa sinh viên
- ✅ Tính toán GPA
- ✅ Tìm kiếm và lọc dữ liệu
- ✅ Giao diện responsive trên mobile
- ✅ Xuất báo cáo Excel

---

## 📚 Kiến Thức Học Được

Dự án này minh họa:

- 🏗️ Triển khai kiến trúc MVC
- 🗄️ Kết nối và quản lý JDBC/Database
- 📍 Quản lý session trong Java Web
- 📱 Thiết kế responsive với Bootstrap
- 📝 Nguyên tắc viết code sạch
- 🔗 Kiểm soát phiên bản với Git

---

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork dự án
2. Tạo nhánh feature (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên nhánh (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

---

## 👨‍💼 Tác Giả

**Trần Trung Dũng**

- 📧 Email: [dungtttd01702@gmail.com](mailto:dungtttd01702@gmail.com)
- 📍 Địa chỉ: Đà Nẵng, Việt Nam
- 🎓 FPT Polytechnic - Chương trình Phát Triển Phần Mềm
- 🔗 GitHub: [@dungtttd01702-coder](https://github.com/dungtttd01702-coder)

---

## 📄 Giấy Phép

Dự án này là mã nguồn mở và được cấp phép theo **MIT License**.

Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

---

<div align="center">

**Xây dựng với ❤️ như một dự án học tập cho FPT Polytechnic**

*Made with ❤️ for learning at FPT Polytechnic*

[⬆ Về đầu](#-hệ-thống-quản-lý-sinh-viên--java-web-mvc)

</div>
