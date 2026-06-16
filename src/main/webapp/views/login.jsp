<%--
    FILE: login.jsp
    LOCATION: src/main/webapp/views/login.jsp
    
    MỤC ĐÍCH:
      Trang đăng nhập - giao diện đầu tiên user thấy.
      Hiển thị form nhập username và password.
    
    TẠI SAO CẦN:
      JSP (View) trong MVC chỉ có nhiệm vụ hiển thị giao diện.
      Logic xử lý đăng nhập nằm ở LoginServlet (Controller).
    
    DÒNG QUAN TRỌNG:
      - action="${pageContext.request.contextPath}/login" → POST đến LoginServlet
      - ${error} → Hiển thị thông báo lỗi từ Servlet setAttribute("error",...)
      - ${username} → Giữ lại username đã nhập nếu login sai
    
    MUỐN ĐỔI GIAO DIỆN:
      → Sửa CSS trong thẻ <style> hoặc class Bootstrap
      → Muốn đổi màu gradient → sửa background trong body CSS
    
    MUỐN THÊM TRƯỜNG (ví dụ: captcha):
      → Thêm input vào form
      → Thêm xử lý trong LoginServlet.doPost()
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Hệ thống Quản lý Sinh viên</title>
    <meta name="description" content="Đăng nhập vào hệ thống quản lý sinh viên">

    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        /* ============================================================
           CSS TOÀN TRANG - Gradient background + Font
        ============================================================ */
        * {
            font-family: 'Inter', sans-serif;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            /* Gradient từ tím đậm → xanh dương đậm */
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 40%, #0f3460 70%, #533483 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }

        /* Hiệu ứng bong bóng nền animated */
        body::before, body::after {
            content: '';
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.03);
            animation: float 8s ease-in-out infinite;
        }
        body::before {
            width: 400px; height: 400px;
            top: -100px; left: -100px;
        }
        body::after {
            width: 300px; height: 300px;
            bottom: -50px; right: -50px;
            animation-delay: -4s;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50%       { transform: translateY(-30px) rotate(180deg); }
        }

        /* ============================================================
           LOGIN CARD - Glassmorphism effect
        ============================================================ */
        .login-card {
            background: rgba(255, 255, 255, 0.07);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 24px;
            padding: 48px 44px;
            width: 100%;
            max-width: 440px;
            box-shadow:
                0 25px 50px rgba(0, 0, 0, 0.4),
                0 0 0 1px rgba(255, 255, 255, 0.05) inset;
            position: relative;
            z-index: 1;
            animation: slideUp 0.6s ease-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ============================================================
           LOGO & TIÊU ĐỀ
        ============================================================ */
        .login-logo {
            width: 72px; height: 72px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            font-size: 32px;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4); }
            50%       { box-shadow: 0 10px 40px rgba(102, 126, 234, 0.7); }
        }

        .login-title {
            color: #ffffff;
            font-size: 26px;
            font-weight: 700;
            text-align: center;
            margin-bottom: 6px;
        }

        .login-subtitle {
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
            text-align: center;
            margin-bottom: 36px;
        }

        /* ============================================================
           FORM FIELDS
        ============================================================ */
        .form-label {
            color: rgba(255, 255, 255, 0.75);
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
        }

        .input-group-text {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-right: none;
            color: rgba(255, 255, 255, 0.6);
        }

        .form-control {
            background: rgba(255, 255, 255, 0.08) !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            border-left: none !important;
            color: #ffffff !important;
            padding: 12px 16px;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        .form-control:focus {
            background: rgba(255, 255, 255, 0.12) !important;
            border-color: rgba(102, 126, 234, 0.8) !important;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.2) !important;
            color: #ffffff !important;
        }

        .form-control:focus ~ .input-group-text,
        .input-group:focus-within .input-group-text {
            border-color: rgba(102, 126, 234, 0.8);
        }

        /* ============================================================
           NÚT ĐĂNG NHẬP
        ============================================================ */
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 16px;
            font-weight: 600;
            letter-spacing: 0.5px;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 8px;
            position: relative;
            overflow: hidden;
        }

        .btn-login::before {
            content: '';
            position: absolute;
            top: 0; left: -100%;
            width: 100%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.15), transparent);
            transition: left 0.5s ease;
        }

        .btn-login:hover::before { left: 100%; }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
        }

        .btn-login:active { transform: translateY(0); }

        /* ============================================================
           ALERT LỖI
        ============================================================ */
        .alert-login-error {
            background: rgba(220, 53, 69, 0.15);
            border: 1px solid rgba(220, 53, 69, 0.4);
            border-radius: 10px;
            color: #ff8fa3;
            padding: 12px 16px;
            font-size: 14px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            animation: shake 0.5s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25%       { transform: translateX(-8px); }
            75%       { transform: translateX(8px); }
        }

        .alert-login-success {
            background: rgba(25, 135, 84, 0.15);
            border: 1px solid rgba(25, 135, 84, 0.4);
            border-radius: 10px;
            color: #75b798;
            padding: 12px 16px;
            font-size: 14px;
            margin-bottom: 20px;
        }

        /* ============================================================
           GỢI Ý TÀI KHOẢN
        ============================================================ */
        .login-hint {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            padding: 14px;
            margin-top: 20px;
        }

        .login-hint p {
            color: rgba(255, 255, 255, 0.4);
            font-size: 12px;
            margin: 0;
            text-align: center;
        }

        .login-hint strong {
            color: rgba(255, 255, 255, 0.6);
        }
    </style>
</head>
<body>

    <div class="login-card">
        <!-- Logo -->
        <div class="login-logo">
            <i class="bi bi-mortarboard-fill text-white"></i>
        </div>

        <!-- Tiêu đề -->
        <h1 class="login-title">Chào mừng trở lại!</h1>
        <p class="login-subtitle">Đăng nhập để quản lý sinh viên</p>

        <!-- Thông báo đăng xuất thành công -->
        <c:if test="${param.msg == 'logout'}">
            <div class="alert-login-success">
                <i class="bi bi-check-circle-fill me-2"></i>
                Bạn đã đăng xuất thành công!
            </div>
        </c:if>

        <!-- Thông báo lỗi đăng nhập -->
        <c:if test="${not empty error}">
            <div class="alert-login-error">
                <i class="bi bi-exclamation-circle-fill"></i>
                ${error}
            </div>
        </c:if>

        <!-- Form đăng nhập -->
        <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm">

            <!-- Username -->
            <div class="mb-4">
                <label for="username" class="form-label">
                    <i class="bi bi-person me-1"></i>Tên đăng nhập
                </label>
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-person-fill"></i>
                    </span>
                    <input type="text"
                           class="form-control"
                           id="username"
                           name="username"
                           placeholder="Nhập tên đăng nhập..."
                           value="${not empty username ? username : ''}"
                           autocomplete="username"
                           required>
                </div>
            </div>

            <!-- Password -->
            <div class="mb-4">
                <label for="password" class="form-label">
                    <i class="bi bi-lock me-1"></i>Mật khẩu
                </label>
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-lock-fill"></i>
                    </span>
                    <input type="password"
                           class="form-control"
                           id="password"
                           name="password"
                           placeholder="Nhập mật khẩu..."
                           autocomplete="current-password"
                           required>
                </div>
            </div>

            <!-- Nút đăng nhập -->
            <button type="submit" class="btn-login" id="btnLogin">
                <i class="bi bi-box-arrow-in-right me-2"></i>Đăng nhập
            </button>
        </form>

        <!-- Gợi ý tài khoản demo -->
        <div class="login-hint">
            <p>
                <i class="bi bi-info-circle me-1"></i>
                Tài khoản demo: <strong>admin</strong> / <strong>admin123</strong>
            </p>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // Hiệu ứng loading khi submit form
        document.getElementById('loginForm').addEventListener('submit', function() {
            const btn = document.getElementById('btnLogin');
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang đăng nhập...';
            btn.disabled = true;
        });

        // Auto focus vào username input
        document.getElementById('username').focus();
    </script>
</body>
</html>
