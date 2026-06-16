<%--
    FILE: student-form.jsp
    LOCATION: src/main/webapp/views/student-form.jsp

    MỤC ĐÍCH:
      Form dùng chung cho cả THÊM MỚI và CHỈNH SỬA sinh viên.
      Phân biệt qua attribute "formAction" (insert / update).

    TẠI SAO DÙNG CHUNG 1 FILE:
      Tránh lặp code. Thêm và sửa có cùng các trường dữ liệu.
      Chỉ khác nhau ở action URL, tiêu đề, và dữ liệu pre-fill.

    DÒNG QUAN TRỌNG:
      - ${not empty student ? student.hoTen : param.inputHoTen}
          → Ưu tiên hiển thị data cũ khi sửa, hoặc data đã nhập khi validate lỗi
      - <c:if test="${formAction == 'update'}">
          → Chèn hidden field id khi là form sửa
      - ${error} → Hiển thị lỗi validate từ Servlet

    VALIDATE PHÍA CLIENT (JavaScript):
      → Kiểm tra trước khi submit để UX tốt hơn
      → Servlet vẫn validate phía server (bảo mật)

    MUỐN ĐỔI DANH SÁCH CHUYÊN NGÀNH:
      → Sửa các <option> trong select chuyenNganh bên dưới

    MUỐN THÊM TRƯỜNG MỚI (ví dụ: ngày sinh):
      1. Thêm input vào form này
      2. Thêm field vào Student.java
      3. Thêm cột vào bảng SQL
      4. Cập nhật StudentDAO (INSERT, UPDATE)
      5. Cập nhật StudentServlet (đọc param, validate)
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Quản lý Sinh viên</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary:      #6366f1;
            --primary-dark: #4f46e5;
            --sidebar-w:    260px;
            --body-bg:      #0f172a;
            --card-bg:      #1e293b;
            --card-border:  #334155;
            --text-primary: #f1f5f9;
            --text-muted:   #94a3b8;
        }

        * { font-family: 'Inter', sans-serif; box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: var(--body-bg);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
        }

        /* ── SIDEBAR (rút gọn, giống student-list.jsp) ───────── */
        .sidebar {
            width: var(--sidebar-w);
            background: #0a1628;
            border-right: 1px solid #1e2d4a;
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; bottom: 0;
            z-index: 100;
        }
        .sidebar-brand {
            padding: 28px 24px 20px;
            border-bottom: 1px solid #1e2d4a;
        }
        .brand-logo {
            width: 44px; height: 44px;
            background: linear-gradient(135deg, var(--primary), #8b5cf6);
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; margin-bottom: 12px;
        }
        .brand-name { font-size: 16px; font-weight: 700; color: var(--text-primary); }
        .brand-sub  { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .sidebar-nav { padding: 16px 12px; flex: 1; }
        .nav-section-title {
            font-size: 11px; font-weight: 600; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: 1px;
            padding: 8px 12px 6px;
        }
        .nav-item-link {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 14px; border-radius: 10px;
            color: var(--text-muted); text-decoration: none;
            font-size: 14px; font-weight: 500;
            transition: all 0.2s; margin-bottom: 2px;
        }
        .nav-item-link:hover, .nav-item-link.active {
            background: rgba(99,102,241,0.15); color: #818cf8;
        }
        .sidebar-footer {
            padding: 16px 12px;
            border-top: 1px solid #1e2d4a;
        }
        .user-info {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 12px; border-radius: 10px;
            background: rgba(255,255,255,0.03); margin-bottom: 8px;
        }
        .user-avatar {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, var(--primary), #8b5cf6);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 700; color: white; flex-shrink: 0;
        }
        .user-name { font-size: 14px; font-weight: 600; color: var(--text-primary); }
        .user-role { font-size: 11px; color: var(--text-muted); }
        .btn-logout {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 9px 14px;
            background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.25);
            border-radius: 10px; color: #f87171; font-size: 14px; font-weight: 500;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-logout:hover { background: rgba(239,68,68,0.2); color: #fca5a5; }

        /* ── MAIN ────────────────────────────────────────────── */
        .main-content { margin-left: var(--sidebar-w); flex: 1; display: flex; flex-direction: column; }

        .topbar {
            background: rgba(10,22,40,0.8);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid #1e2d4a;
            padding: 16px 32px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 99;
        }
        .page-title { font-size: 20px; font-weight: 700; }
        .page-breadcrumb { font-size: 13px; color: var(--text-muted); margin-top: 2px; }

        .btn-back {
            display: flex; align-items: center; gap: 8px;
            padding: 10px 18px; border-radius: 10px;
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--card-border);
            color: var(--text-muted); font-size: 14px; font-weight: 500;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-back:hover { background: rgba(255,255,255,0.1); color: var(--text-primary); }

        .page-body { padding: 32px; flex: 1; }

        /* ── FORM CARD ───────────────────────────────────────── */
        .form-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            max-width: 720px;
            margin: 0 auto;
            overflow: hidden;
            animation: fadeIn 0.4s ease;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .form-card-header {
            padding: 28px 32px 20px;
            border-bottom: 1px solid var(--card-border);
            display: flex; align-items: center; gap: 16px;
        }
        .form-header-icon {
            width: 52px; height: 52px;
            background: linear-gradient(135deg, var(--primary), #8b5cf6);
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px;
        }
        .form-header-title { font-size: 20px; font-weight: 700; }
        .form-header-sub   { font-size: 13px; color: var(--text-muted); margin-top: 3px; }

        .form-card-body { padding: 28px 32px; }

        /* ── FORM ELEMENTS ───────────────────────────────────── */
        .form-group-label {
            display: flex; align-items: center; gap: 6px;
            color: var(--text-muted); font-size: 13px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            margin-bottom: 8px;
        }
        .required-star { color: #f87171; }

        .form-input {
            width: 100%; padding: 12px 16px;
            background: rgba(255,255,255,0.04);
            border: 1.5px solid var(--card-border);
            border-radius: 12px; color: var(--text-primary);
            font-size: 15px; outline: none;
            transition: all 0.2s ease;
        }
        .form-input option {
            background-color: #1e293b;
            color: #f1f5f9;
        }
        .form-input::placeholder { color: #475569; }
        .form-input:focus {
            border-color: var(--primary);
            background: rgba(99,102,241,0.06);
            box-shadow: 0 0 0 3px rgba(99,102,241,0.15);
        }
        .form-input.is-invalid-custom {
            border-color: #ef4444;
            background: rgba(239,68,68,0.05);
        }

        .form-hint {
            font-size: 12px; color: #475569; margin-top: 5px;
            display: flex; align-items: center; gap: 4px;
        }

        /* Score slider */
        .score-preview {
            display: flex; align-items: center; gap: 12px; margin-top: 8px;
        }
        .score-bar {
            flex: 1; height: 6px;
            background: var(--card-border); border-radius: 3px; overflow: hidden;
        }
        .score-bar-fill {
            height: 100%; border-radius: 3px;
            transition: all 0.3s ease;
            background: linear-gradient(90deg, #ef4444, #f59e0b, #10b981, #6366f1);
        }
        .score-label {
            font-size: 13px; font-weight: 700;
            min-width: 60px; text-align: right;
        }

        /* Divider */
        .form-divider {
            height: 1px; background: var(--card-border); margin: 24px 0;
        }

        /* ── ERROR ALERT ─────────────────────────────────────── */
        .alert-form-error {
            background: rgba(239,68,68,0.1);
            border: 1px solid rgba(239,68,68,0.35);
            border-radius: 12px;
            padding: 14px 18px; margin-bottom: 24px;
            display: flex; align-items: flex-start; gap: 10px;
            color: #fca5a5; font-size: 14px;
            animation: shake 0.4s ease;
        }
        @keyframes shake {
            0%,100%{transform:translateX(0)} 25%{transform:translateX(-6px)} 75%{transform:translateX(6px)}
        }

        /* ── SUBMIT BUTTONS ──────────────────────────────────── */
        .form-card-footer {
            padding: 20px 32px 28px;
            display: flex; align-items: center; gap: 12px;
        }

        .btn-submit {
            flex: 1; padding: 13px;
            background: linear-gradient(135deg, var(--primary), #8b5cf6);
            border: none; border-radius: 12px;
            color: white; font-size: 15px; font-weight: 600;
            cursor: pointer; transition: all 0.3s;
            display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(99,102,241,0.45);
        }

        .btn-cancel-form {
            padding: 13px 24px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--card-border);
            border-radius: 12px;
            color: var(--text-muted); font-size: 15px; font-weight: 500;
            cursor: pointer; transition: all 0.2s; text-decoration: none;
            display: flex; align-items: center; gap: 8px;
        }
        .btn-cancel-form:hover { background: rgba(255,255,255,0.1); color: var(--text-primary); }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; }
            .page-body { padding: 16px; }
            .form-card-header, .form-card-body, .form-card-footer { padding: 20px 16px; }
        }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-logo"><i class="bi bi-mortarboard-fill text-white"></i></div>
            <div class="brand-name">EduManage</div>
            <div class="brand-sub">Hệ thống Quản lý Sinh viên</div>
        </div>
        <div class="sidebar-nav">
            <div class="nav-section-title">Chức năng</div>
            <a href="${pageContext.request.contextPath}/students" class="nav-item-link">
                <i class="bi bi-people-fill"></i> Quản lý Sinh viên
            </a>
            <a href="${pageContext.request.contextPath}/students?action=new"
               class="nav-item-link ${formAction == 'insert' ? 'active' : ''}">
                <i class="bi bi-person-plus-fill"></i> Thêm Sinh viên
            </a>
        </div>
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">A</div>
                <div>
                    <div class="user-name">${sessionScope.account.username}</div>
                    <div class="user-role">Quản trị viên</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="bi bi-box-arrow-left"></i> Đăng xuất
            </a>
        </div>
    </nav>

    <!-- MAIN CONTENT -->
    <div class="main-content">

        <!-- TOPBAR -->
        <div class="topbar">
            <div>
                <div class="page-title">
                    <c:choose>
                        <c:when test="${formAction == 'insert'}">
                            <i class="bi bi-person-plus me-2" style="color:#818cf8"></i>Thêm sinh viên mới
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-pencil-square me-2" style="color:#818cf8"></i>Chỉnh sửa sinh viên
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="page-breadcrumb">
                    Trang chủ &rsaquo; Sinh viên &rsaquo; ${pageTitle}
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/students" class="btn-back">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>
        </div>

        <!-- PAGE BODY -->
        <div class="page-body">
            <div class="form-card">

                <!-- FORM HEADER -->
                <div class="form-card-header">
                    <div class="form-header-icon">
                        <c:choose>
                            <c:when test="${formAction == 'insert'}">
                                <i class="bi bi-person-plus-fill text-white"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-pencil-fill text-white"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <div class="form-header-title">${pageTitle}</div>
                        <div class="form-header-sub">
                            <c:choose>
                                <c:when test="${formAction == 'insert'}">
                                    Điền đầy đủ thông tin bên dưới để thêm sinh viên vào hệ thống
                                </c:when>
                                <c:otherwise>
                                    Chỉnh sửa thông tin sinh viên — ID: <strong>#${student.id}</strong>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- FORM BODY -->
                <div class="form-card-body">

                    <!-- Thông báo lỗi validate -->
                    <c:if test="${not empty error}">
                        <div class="alert-form-error">
                            <i class="bi bi-exclamation-circle-fill fs-5 flex-shrink-0"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <!-- ======================================
                         FORM - action thay đổi theo insert/update
                    ====================================== -->
                    <form action="${pageContext.request.contextPath}/students"
                          method="post"
                          id="studentForm"
                          novalidate>

                        <!-- Hidden fields -->
                        <input type="hidden" name="action" value="${formAction}">
                        <c:if test="${formAction == 'update'}">
                            <input type="hidden" name="id" value="${student.id}">
                        </c:if>

                        <!-- ── ROW 1: Họ tên ── -->
                        <div class="mb-4">
                            <label for="hoTen" class="form-group-label">
                                <i class="bi bi-person"></i>
                                Họ và tên <span class="required-star">*</span>
                            </label>
                            <input type="text"
                                   id="hoTen"
                                   name="hoTen"
                                   class="form-input"
                                   placeholder="Ví dụ: Nguyễn Văn An"
                                   maxlength="100"
                                   value="${not empty student ? student.hoTen : (not empty inputHoTen ? inputHoTen : '')}"
                                   required>
                            <div class="form-hint">
                                <i class="bi bi-info-circle"></i>
                                Nhập họ tên đầy đủ, từ 2 đến 100 ký tự
                            </div>
                        </div>

                        <!-- ── ROW 2: Email ── -->
                        <div class="mb-4">
                            <label for="email" class="form-group-label">
                                <i class="bi bi-envelope"></i>
                                Email <span class="required-star">*</span>
                            </label>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   class="form-input"
                                   placeholder="Ví dụ: sinhvien@email.com"
                                   maxlength="100"
                                   value="${not empty student ? student.email : (not empty inputEmail ? inputEmail : '')}"
                                   required>
                            <div class="form-hint">
                                <i class="bi bi-info-circle"></i>
                                Email phải đúng định dạng và chưa được đăng ký
                            </div>
                        </div>

                        <!-- ── ROW 3: Chuyên ngành ── -->
                        <div class="mb-4">
                            <label for="chuyenNganh" class="form-group-label">
                                <i class="bi bi-building"></i>
                                Chuyên ngành <span class="required-star">*</span>
                            </label>

                            <%-- Lấy giá trị hiện tại để so sánh selected --%>
                            <c:set var="currentCN"
                                   value="${not empty student ? student.chuyenNganh : (not empty inputChuyenNganh ? inputChuyenNganh : '')}"/>

                            <select id="chuyenNganh" name="chuyenNganh" class="form-input" required>
                                <option value="" disabled ${empty currentCN ? 'selected' : ''}>
                                    — Chọn chuyên ngành —
                                </option>
                                <c:set var="options" value="Công nghệ thông tin,Khoa học máy tính,Kỹ thuật phần mềm,Hệ thống thông tin,Mạng máy tính,An toàn thông tin,Trí tuệ nhân tạo,Khoa học dữ liệu"/>
                                <c:forTokens items="${options}" delims="," var="cn">
                                    <option value="${cn}" ${currentCN == cn ? 'selected' : ''}>${cn}</option>
                                </c:forTokens>
                            </select>
                            <div class="form-hint">
                                <i class="bi bi-info-circle"></i>
                                Chọn chuyên ngành phù hợp từ danh sách
                            </div>
                        </div>

                        <div class="form-divider"></div>

                        <!-- ── ROW 4: Điểm TB ── -->
                        <div class="mb-2">
                            <label for="diemTB" class="form-group-label">
                                <i class="bi bi-bar-chart"></i>
                                Điểm trung bình <span class="required-star">*</span>
                            </label>
                            <input type="number"
                                   id="diemTB"
                                   name="diemTB"
                                   class="form-input"
                                   placeholder="Ví dụ: 7.5"
                                   min="0" max="10" step="0.01"
                                   value="${not empty student && student.diemTB > 0 ? student.diemTB : (not empty inputDiemTB ? inputDiemTB : '')}"
                                   oninput="updateScoreBar(this.value)"
                                   required>

                            <!-- Thanh hiển thị điểm trực quan -->
                            <div class="score-preview">
                                <div class="score-bar">
                                    <div class="score-bar-fill" id="scoreBarFill" style="width:0%"></div>
                                </div>
                                <div class="score-label" id="scoreLabel" style="color: var(--text-muted)">
                                    —
                                </div>
                            </div>

                            <div class="form-hint">
                                <i class="bi bi-info-circle"></i>
                                Điểm từ 0.0 đến 10.0 (chấp nhận số thập phân, ví dụ: 8.5)
                            </div>
                        </div>

                    </form>
                </div><!-- /form-card-body -->

                <!-- FORM FOOTER - Buttons -->
                <div class="form-card-footer">
                    <a href="${pageContext.request.contextPath}/students" class="btn-cancel-form">
                        <i class="bi bi-x-lg"></i> Hủy
                    </a>
                    <button type="submit" form="studentForm" class="btn-submit" id="btnSubmit">
                        <c:choose>
                            <c:when test="${formAction == 'insert'}">
                                <i class="bi bi-plus-circle-fill"></i>
                                Thêm sinh viên
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-check-circle-fill"></i>
                                Lưu thay đổi
                            </c:otherwise>
                        </c:choose>
                    </button>
                </div>

            </div><!-- /form-card -->
        </div><!-- /page-body -->
    </div><!-- /main-content -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        /**
         * Cập nhật thanh điểm trực quan khi người dùng nhập điểm
         * MUỐN ĐỔI MÀU/NHÃN: Sửa các điều kiện if bên dưới
         */
        function updateScoreBar(value) {
            const fill  = document.getElementById('scoreBarFill');
            const label = document.getElementById('scoreLabel');
            const score = parseFloat(value);

            if (isNaN(score) || value === '') {
                fill.style.width = '0%';
                label.textContent = '—';
                label.style.color = 'var(--text-muted)';
                return;
            }

            const pct = Math.min(Math.max(score / 10 * 100, 0), 100);
            fill.style.width = pct + '%';

            if (score >= 9.0) {
                label.textContent = 'Xuất sắc';
                label.style.color = '#fbbf24';
            } else if (score >= 8.0) {
                label.textContent = 'Giỏi';
                label.style.color = '#818cf8';
            } else if (score >= 7.0) {
                label.textContent = 'Khá';
                label.style.color = '#34d399';
            } else if (score >= 5.0) {
                label.textContent = 'Trung bình';
                label.style.color = '#94a3b8';
            } else {
                label.textContent = 'Yếu';
                label.style.color = '#f87171';
            }
        }

        // Khởi tạo thanh điểm nếu đang ở form sửa (đã có giá trị)
        const initialScore = document.getElementById('diemTB').value;
        if (initialScore) updateScoreBar(initialScore);

        // Validate phía client trước khi submit
        document.getElementById('studentForm').addEventListener('submit', function(e) {
            const hoTen  = document.getElementById('hoTen').value.trim();
            const email  = document.getElementById('email').value.trim();
            const cn     = document.getElementById('chuyenNganh').value;
            const diem   = parseFloat(document.getElementById('diemTB').value);
            const emailRx = /^[\w._%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$/;

            if (!hoTen) {
                alert('Vui lòng nhập họ tên!');
                document.getElementById('hoTen').focus();
                e.preventDefault(); return;
            }
            if (!emailRx.test(email)) {
                alert('Email không đúng định dạng!');
                document.getElementById('email').focus();
                e.preventDefault(); return;
            }
            if (!cn) {
                alert('Vui lòng chọn chuyên ngành!');
                document.getElementById('chuyenNganh').focus();
                e.preventDefault(); return;
            }
            if (isNaN(diem) || diem < 0 || diem > 10) {
                alert('Điểm trung bình phải từ 0 đến 10!');
                document.getElementById('diemTB').focus();
                e.preventDefault(); return;
            }

            // Loading state
            const btn = document.getElementById('btnSubmit');
            btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Đang lưu...';
            btn.disabled = true;
        });
    </script>
</body>
</html>
