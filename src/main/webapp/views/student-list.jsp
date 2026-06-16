<%--
    FILE: student-list.jsp
    LOCATION: src/main/webapp/views/student-list.jsp

    MỤC ĐÍCH:
      Trang dashboard hiển thị danh sách sinh viên với đầy đủ chức năng:
      - Xem danh sách, tìm kiếm, thêm/sửa/xóa sinh viên
      - Hiển thị thống kê (tổng số, điểm TB, điểm cao/thấp)

    TẠI SAO CẦN:
      View trong MVC chỉ hiển thị dữ liệu mà Servlet đã chuẩn bị.
      Dữ liệu được truyền qua request.setAttribute() từ StudentServlet.

    DÒNG QUAN TRỌNG:
      - ${account.username}         → Lấy tên user từ Session
      - <c:forEach items="${students}"> → Lặp qua list sinh viên
      - ${student.xepLoai}          → Gọi getter getXepLoai() trong Student.java
      - ?action=delete&id=...       → Gửi request xóa đến StudentServlet

    MUỐN ĐỔI GIAO DIỆN:
      → Sửa CSS trong thẻ <style>
      → Muốn đổi màu theme → sửa các biến CSS (--primary-color, ...)

    MUỐN THÊM CỘT DỮ LIỆU:
      → Thêm <th> vào bảng header và <td> vào vòng lặp c:forEach
      → Đảm bảo Student.java và StudentDAO.java đã cập nhật cột đó
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sinh viên - Dashboard</title>
    <meta name="description" content="Hệ thống quản lý sinh viên - Danh sách sinh viên">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary:       #6366f1;
            --primary-dark:  #4f46e5;
            --primary-light: #818cf8;
            --success:       #10b981;
            --warning:       #f59e0b;
            --danger:        #ef4444;
            --sidebar-bg:    #0f172a;
            --sidebar-w:     260px;
            --body-bg:       #0f172a;
            --card-bg:       #1e293b;
            --card-border:   #334155;
            --text-primary:  #f1f5f9;
            --text-muted:    #94a3b8;
        }

        * { font-family: 'Inter', sans-serif; margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background: var(--body-bg);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
        }

        /* ── SIDEBAR ────────────────────────────────────────────── */
        .sidebar {
            width: var(--sidebar-w);
            background: #0a1628;
            border-right: 1px solid #1e2d4a;
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 100;
            transition: transform 0.3s ease;
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

        .brand-name {
            font-size: 16px; font-weight: 700; color: var(--text-primary);
            line-height: 1.2;
        }
        .brand-sub {
            font-size: 12px; color: var(--text-muted); margin-top: 2px;
        }

        .sidebar-nav { padding: 16px 12px; flex: 1; }

        .nav-section-title {
            font-size: 11px; font-weight: 600; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: 1px;
            padding: 8px 12px 6px; margin-bottom: 4px;
        }

        .nav-item-link {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 14px; border-radius: 10px;
            color: var(--text-muted); text-decoration: none;
            font-size: 14px; font-weight: 500;
            transition: all 0.2s ease; margin-bottom: 2px;
        }

        .nav-item-link:hover,
        .nav-item-link.active {
            background: rgba(99, 102, 241, 0.15);
            color: var(--primary-light);
        }
        .nav-item-link.active { background: rgba(99, 102, 241, 0.2); }

        .sidebar-footer {
            padding: 16px 12px;
            border-top: 1px solid #1e2d4a;
        }

        .user-info {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 12px; border-radius: 10px;
            background: rgba(255,255,255,0.03);
            margin-bottom: 8px;
        }
        .user-avatar {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, var(--primary), #8b5cf6);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 700; color: white;
            flex-shrink: 0;
        }
        .user-name { font-size: 14px; font-weight: 600; color: var(--text-primary); }
        .user-role { font-size: 11px; color: var(--text-muted); }

        .btn-logout {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 9px 14px;
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.25);
            border-radius: 10px;
            color: #f87171; font-size: 14px; font-weight: 500;
            text-decoration: none; transition: all 0.2s ease;
        }
        .btn-logout:hover {
            background: rgba(239, 68, 68, 0.2);
            color: #fca5a5;
        }

        /* ── MAIN CONTENT ───────────────────────────────────────── */
        .main-content {
            margin-left: var(--sidebar-w);
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* ── TOPBAR ─────────────────────────────────────────────── */
        .topbar {
            background: rgba(10, 22, 40, 0.8);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid #1e2d4a;
            padding: 16px 32px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 99;
        }

        .page-title { font-size: 20px; font-weight: 700; color: var(--text-primary); }
        .page-breadcrumb { font-size: 13px; color: var(--text-muted); margin-top: 2px; }

        .btn-add-student {
            display: flex; align-items: center; gap: 8px;
            padding: 10px 20px;
            background: linear-gradient(135deg, var(--primary), #8b5cf6);
            border: none; border-radius: 10px;
            color: white; font-size: 14px; font-weight: 600;
            text-decoration: none; cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);
        }
        .btn-add-student:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(99, 102, 241, 0.5);
            color: white;
        }

        /* ── PAGE BODY ──────────────────────────────────────────── */
        .page-body { padding: 28px 32px; flex: 1; }

        /* ── STAT CARDS ─────────────────────────────────────────── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 20px;
            display: flex; align-items: center; gap: 16px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }

        .stat-icon {
            width: 52px; height: 52px;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; flex-shrink: 0;
        }
        .stat-icon.blue   { background: rgba(99,102,241,0.15); color: #818cf8; }
        .stat-icon.green  { background: rgba(16,185,129,0.15); color: #34d399; }
        .stat-icon.yellow { background: rgba(245,158,11,0.15); color: #fbbf24; }
        .stat-icon.red    { background: rgba(239,68,68,0.15);  color: #f87171; }

        .stat-value { font-size: 28px; font-weight: 800; color: var(--text-primary); line-height: 1; }
        .stat-label { font-size: 13px; color: var(--text-muted); margin-top: 4px; }

        /* ── SEARCH & FILTER BAR ────────────────────────────────── */
        .toolbar-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 18px 20px;
            margin-bottom: 20px;
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }

        .search-wrapper {
            position: relative; flex: 1; min-width: 260px;
        }
        .search-wrapper .bi-search {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: var(--text-muted); font-size: 15px;
        }
        .search-input {
            width: 100%; padding: 10px 16px 10px 42px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--card-border);
            border-radius: 10px; color: var(--text-primary); font-size: 14px;
            outline: none; transition: all 0.2s;
        }
        .search-input:focus {
            border-color: var(--primary);
            background: rgba(99,102,241,0.08);
            box-shadow: 0 0 0 3px rgba(99,102,241,0.15);
        }
        .search-input::placeholder { color: var(--text-muted); }

        .btn-search {
            padding: 10px 20px; border-radius: 10px;
            background: var(--primary); border: none;
            color: white; font-size: 14px; font-weight: 500;
            cursor: pointer; transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-search:hover { background: var(--primary-dark); }

        .btn-reset {
            padding: 10px 16px; border-radius: 10px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--card-border);
            color: var(--text-muted); font-size: 14px;
            cursor: pointer; transition: all 0.2s; text-decoration: none;
            display: flex; align-items: center; gap: 6px;
        }
        .btn-reset:hover { color: var(--text-primary); background: rgba(255,255,255,0.08); }

        /* ── TOAST ALERTS ───────────────────────────────────────── */
        .alert-toast {
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 9999;
            min-width: 320px;
            max-width: 400px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
            border-radius: 12px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 500;
            animation: slideInRight 0.35s cubic-bezier(0.68, -0.55, 0.27, 1.55);
        }
        @keyframes slideInRight {
            from { transform: translateX(120%); opacity: 0; }
            to   { transform: translateX(0); opacity: 1; }
        }
        .alert-success-custom {
            background: #064e3b !important;
            border: 1px solid #059669 !important;
            color: #34d399 !important;
        }
        .alert-error-custom {
            background: #7f1d1d !important;
            border: 1px solid #dc2626 !important;
            color: #fca5a5 !important;
        }

        /* ── DATA TABLE ─────────────────────────────────────────── */
        .table-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            overflow: hidden;
        }

        .table-card-header {
            padding: 18px 20px;
            border-bottom: 1px solid var(--card-border);
            display: flex; align-items: center; justify-content: space-between;
        }
        .table-card-title { font-size: 16px; font-weight: 700; color: var(--text-primary); }
        .table-record-count {
            font-size: 13px; color: var(--text-muted);
            background: rgba(255,255,255,0.05);
            padding: 4px 12px; border-radius: 20px;
        }

        .table-responsive {
            background-color: var(--card-bg) !important;
        }

        .table {
            margin: 0;
            background-color: var(--card-bg) !important;
            --bs-table-bg: var(--card-bg) !important;
            --bs-table-color: var(--text-primary) !important;
        }

        .table thead th {
            background-color: rgba(255, 255, 255, 0.02) !important;
            border-color: var(--card-border) !important;
            color: var(--text-muted) !important;
            font-size: 12px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.8px;
            padding: 13px 16px; white-space: nowrap;
        }

        .table tbody td {
            background-color: var(--card-bg) !important;
            border-color: var(--card-border) !important;
            color: var(--text-primary) !important;
            font-size: 14px;
            padding: 14px 16px;
            vertical-align: middle;
        }

        .table tbody tr {
            background-color: var(--card-bg) !important;
            transition: background 0.15s ease;
        }
        .table tbody tr:hover td {
            background-color: rgba(99, 102, 241, 0.08) !important;
        }

        /* ID Badge */
        .id-badge {
            display: inline-flex; align-items: center; justify-content: center;
            width: 34px; height: 34px;
            background: rgba(99,102,241,0.15);
            border-radius: 8px;
            color: var(--primary-light);
            font-size: 13px; font-weight: 700;
        }

        /* Student name cell */
        .student-name { font-weight: 600; color: var(--text-primary); }
        .student-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

        /* Xếp loại badges */
        .badge-xuat-sac {
            background: linear-gradient(135deg,#f59e0b,#d97706);
            color: white; padding: 4px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
        }
        .badge-gioi {
            background: linear-gradient(135deg,#6366f1,#8b5cf6);
            color: white; padding: 4px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
        }
        .badge-kha {
            background: linear-gradient(135deg,#10b981,#059669);
            color: white; padding: 4px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
        }
        .badge-tb {
            background: rgba(148,163,184,0.15);
            color: #94a3b8; padding: 4px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
            border: 1px solid rgba(148,163,184,0.3);
        }
        .badge-yeu {
            background: rgba(239,68,68,0.15);
            color: #f87171; padding: 4px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
            border: 1px solid rgba(239,68,68,0.3);
        }

        /* Điểm số */
        .score-value {
            font-size: 16px; font-weight: 700;
        }
        .score-high  { color: #fbbf24; }
        .score-good  { color: #818cf8; }
        .score-avg   { color: #34d399; }
        .score-low   { color: #94a3b8; }
        .score-fail  { color: #f87171; }

        /* Action buttons */
        .btn-action {
            width: 34px; height: 34px; border-radius: 8px;
            display: inline-flex; align-items: center; justify-content: center;
            border: none; cursor: pointer; transition: all 0.2s ease;
            font-size: 14px; text-decoration: none;
        }
        .btn-action-edit {
            background: rgba(99,102,241,0.12);
            color: var(--primary-light);
        }
        .btn-action-edit:hover {
            background: rgba(99,102,241,0.25);
            color: var(--primary-light);
            transform: scale(1.1);
        }
        .btn-action-delete {
            background: rgba(239,68,68,0.12);
            color: #f87171;
        }
        .btn-action-delete:hover {
            background: rgba(239,68,68,0.25);
            color: #fca5a5;
            transform: scale(1.1);
        }

        /* Empty state */
        .empty-state {
            text-align: center; padding: 60px 20px;
        }
        .empty-state-icon {
            font-size: 56px; color: var(--text-muted);
            opacity: 0.4; margin-bottom: 16px;
        }
        .empty-state h5 { color: var(--text-muted); font-weight: 600; }
        .empty-state p { color: var(--text-muted); font-size: 14px; opacity: 0.7; }

        /* ── DELETE MODAL ───────────────────────────────────────── */
        .modal-content {
            background: #1e293b;
            border: 1px solid var(--card-border);
            border-radius: 20px;
        }
        .modal-header {
            border-bottom: 1px solid var(--card-border);
            padding: 20px 24px;
        }
        .modal-body { padding: 24px; }
        .modal-footer {
            border-top: 1px solid var(--card-border);
            padding: 16px 24px;
        }
        .modal-title { color: var(--text-primary); font-weight: 700; }
        .modal-body p { color: var(--text-muted); font-size: 15px; }
        .modal-body strong { color: var(--text-primary); }

        .delete-icon-wrapper {
            width: 64px; height: 64px;
            background: rgba(239,68,68,0.15);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 28px; color: #f87171;
            margin: 0 auto 16px;
        }

        .btn-confirm-delete {
            background: linear-gradient(135deg,#ef4444,#dc2626);
            border: none; color: white;
            padding: 10px 24px; border-radius: 10px; font-weight: 600;
            transition: all 0.2s;
        }
        .btn-confirm-delete:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(239,68,68,0.4); }

        .btn-cancel-modal {
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--card-border);
            color: var(--text-muted);
            padding: 10px 24px; border-radius: 10px; font-weight: 500;
            transition: all 0.2s;
        }
        .btn-cancel-modal:hover { background: rgba(255,255,255,0.1); color: var(--text-primary); }

        /* Responsive */
        @media (max-width: 992px) {
            .stats-grid { grid-template-columns: repeat(2,1fr); }
        }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; }
            .stats-grid { grid-template-columns: repeat(2,1fr); }
            .page-body { padding: 20px 16px; }
            .topbar { padding: 14px 16px; }
        }
    </style>
</head>
<body>

    <!-- ============================================================
         SIDEBAR
    ============================================================ -->
    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-logo"><i class="bi bi-mortarboard-fill text-white"></i></div>
            <div class="brand-name">EduManage</div>
            <div class="brand-sub">Hệ thống Quản lý Sinh viên</div>
        </div>

        <div class="sidebar-nav">
            <div class="nav-section-title">Chức năng</div>
            <a href="${pageContext.request.contextPath}/students" class="nav-item-link active">
                <i class="bi bi-people-fill"></i> Quản lý Sinh viên
            </a>
            <a href="${pageContext.request.contextPath}/students?action=new" class="nav-item-link">
                <i class="bi bi-person-plus-fill"></i> Thêm Sinh viên
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.username}">
                            ${fn:toUpperCase(fn:substring(sessionScope.account.username,0,1))}
                        </c:when>
                        <c:otherwise>A</c:otherwise>
                    </c:choose>
                </div>
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

    <!-- ============================================================
         MAIN CONTENT
    ============================================================ -->
    <div class="main-content">

        <!-- TOPBAR -->
        <div class="topbar">
            <div>
                <div class="page-title">
                    <i class="bi bi-people me-2" style="color:var(--primary-light)"></i>Quản lý Sinh viên
                </div>
                <div class="page-breadcrumb">
                    Trang chủ &rsaquo; Danh sách sinh viên
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/students?action=new" class="btn-add-student" id="btnAddStudent">
                <i class="bi bi-plus-lg"></i> Thêm sinh viên
            </a>
        </div>

        <!-- PAGE BODY -->
        <div class="page-body">

            <!-- Toast thông báo -->
            <c:if test="${param.success == 'added'}">
                <div class="alert-toast alert-success-custom">
                    <i class="bi bi-check-circle-fill fs-5"></i>
                    <span>Thêm sinh viên mới thành công!</span>
                </div>
            </c:if>
            <c:if test="${param.success == 'updated'}">
                <div class="alert-toast alert-success-custom">
                    <i class="bi bi-check-circle-fill fs-5"></i>
                    <span>Cập nhật thông tin sinh viên thành công!</span>
                </div>
            </c:if>
            <c:if test="${param.success == 'deleted'}">
                <div class="alert-toast alert-success-custom">
                    <i class="bi bi-trash-fill fs-5"></i>
                    <span>Đã xóa sinh viên thành công!</span>
                </div>
            </c:if>
            <c:if test="${param.error == 'delete_failed'}">
                <div class="alert-toast alert-error-custom">
                    <i class="bi bi-exclamation-circle-fill fs-5"></i>
                    <span>Có lỗi xảy ra khi xóa sinh viên!</span>
                </div>
            </c:if>

            <!-- STAT CARDS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="bi bi-people-fill"></i></div>
                    <div>
                        <div class="stat-value" id="statTotal">${totalCount}</div>
                        <div class="stat-label">Tổng sinh viên</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="bi bi-trophy-fill"></i></div>
                    <div>
                        <%-- Tính điểm TB chung --%>
                        <c:set var="tongDiem" value="0"/>
                        <c:forEach items="${students}" var="s">
                            <c:set var="tongDiem" value="${tongDiem + s.diemTB}"/>
                        </c:forEach>
                        <div class="stat-value" id="statAvg">
                            <c:choose>
                                <c:when test="${totalCount > 0}">
                                    <fmt:formatNumber value="${tongDiem / totalCount}" pattern="0.00"/>
                                </c:when>
                                <c:otherwise>0.00</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="stat-label">Điểm TB chung</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon yellow"><i class="bi bi-star-fill"></i></div>
                    <div>
                        <%-- Đếm sinh viên giỏi (>= 8.0) --%>
                        <c:set var="svGioi" value="0"/>
                        <c:forEach items="${students}" var="s">
                            <c:if test="${s.diemTB >= 8.0}">
                                <c:set var="svGioi" value="${svGioi + 1}"/>
                            </c:if>
                        </c:forEach>
                        <div class="stat-value" id="statGood">${svGioi}</div>
                        <div class="stat-label">Sinh viên giỏi (≥ 8.0)</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div>
                        <%-- Đếm sinh viên yếu (< 5.0) --%>
                        <c:set var="svYeu" value="0"/>
                        <c:forEach items="${students}" var="s">
                            <c:if test="${s.diemTB < 5.0}">
                                <c:set var="svYeu" value="${svYeu + 1}"/>
                            </c:if>
                        </c:forEach>
                        <div class="stat-value" id="statPoor">${svYeu}</div>
                        <div class="stat-label">Sinh viên yếu (&lt; 5.0)</div>
                    </div>
                </div>
            </div>

            <!-- TOOLBAR: Search -->
            <div class="toolbar-card">
                <form action="${pageContext.request.contextPath}/students" method="get"
                      class="d-flex align-items-center gap-2 flex-wrap w-100" id="searchForm">
                    <input type="hidden" name="action" value="search">
                    <div class="search-wrapper">
                        <i class="bi bi-search"></i>
                        <input type="text"
                               class="search-input"
                               id="searchInput"
                               name="keyword"
                               placeholder="Tìm kiếm theo họ tên sinh viên..."
                               value="${not empty keyword ? keyword : ''}">
                    </div>
                    <button type="submit" class="btn-search" id="btnSearch">
                        <i class="bi bi-search me-1"></i> Tìm kiếm
                    </button>
                    <a href="${pageContext.request.contextPath}/students" class="btn-reset" id="btnReset">
                        <i class="bi bi-arrow-clockwise"></i> Đặt lại
                    </a>
                </form>

                <c:if test="${not empty keyword}">
                    <div style="width:100%; padding-top:8px;">
                        <small style="color:var(--text-muted)">
                            <i class="bi bi-info-circle me-1"></i>
                            Kết quả tìm kiếm cho: <strong style="color:var(--primary-light)">"${keyword}"</strong>
                            — Tìm thấy <strong>${totalCount}</strong> sinh viên
                        </small>
                    </div>
                </c:if>
            </div>

            <!-- DATA TABLE -->
            <div class="table-card">
                <div class="table-card-header">
                    <div class="table-card-title">
                        <i class="bi bi-table me-2" style="color:var(--primary-light)"></i>
                        Danh sách Sinh viên
                    </div>
                    <span class="table-record-count">${totalCount} bản ghi</span>
                </div>

                <c:choose>
                    <c:when test="${empty students}">
                        <!-- Trạng thái rỗng -->
                        <div class="empty-state">
                            <div class="empty-state-icon"><i class="bi bi-person-x"></i></div>
                            <h5>Không tìm thấy sinh viên nào</h5>
                            <p>
                                <c:choose>
                                    <c:when test="${not empty keyword}">
                                        Không có kết quả cho từ khóa "<strong>${keyword}</strong>"
                                    </c:when>
                                    <c:otherwise>Chưa có sinh viên nào trong hệ thống</c:otherwise>
                                </c:choose>
                            </p>
                            <a href="${pageContext.request.contextPath}/students?action=new"
                               class="btn-add-student mt-3 d-inline-flex" style="text-decoration:none">
                                <i class="bi bi-plus-lg"></i> Thêm sinh viên đầu tiên
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-borderless" id="studentTable">
                                <thead>
                                    <tr>
                                        <th style="width:60px">ID</th>
                                        <th>Họ tên / Email</th>
                                        <th>Chuyên ngành</th>
                                        <th style="width:110px; text-align:center">Điểm TB</th>
                                        <th style="width:120px; text-align:center">Xếp loại</th>
                                        <th style="width:100px; text-align:center">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${students}" var="student" varStatus="loop">
                                        <tr>
                                            <!-- ID -->
                                            <td>
                                                <span class="id-badge">${student.id}</span>
                                            </td>

                                            <!-- Họ tên + email -->
                                            <td>
                                                <div class="student-name">${student.hoTen}</div>
                                                <div class="student-email">
                                                    <i class="bi bi-envelope me-1"></i>${student.email}
                                                </div>
                                            </td>

                                            <!-- Chuyên ngành -->
                                            <td>
                                                <span style="color:var(--text-muted); font-size:13px;">
                                                    <i class="bi bi-building me-1"></i>${student.chuyenNganh}
                                                </span>
                                            </td>

                                            <!-- Điểm TB -->
                                            <td style="text-align:center">
                                                <span class="score-value
                                                    <c:choose>
                                                        <c:when test='${student.diemTB >= 9.0}'>score-high</c:when>
                                                        <c:when test='${student.diemTB >= 8.0}'>score-good</c:when>
                                                        <c:when test='${student.diemTB >= 7.0}'>score-avg</c:when>
                                                        <c:when test='${student.diemTB >= 5.0}'>score-low</c:when>
                                                        <c:otherwise>score-fail</c:otherwise>
                                                    </c:choose>">
                                                    <fmt:formatNumber value="${student.diemTB}" pattern="0.00"/>
                                                </span>
                                            </td>

                                            <!-- Xếp loại -->
                                            <td style="text-align:center">
                                                <span class="${student.xepLoaiClass}">
                                                    ${student.xepLoai}
                                                </span>
                                            </td>

                                            <!-- Thao tác -->
                                            <td style="text-align:center">
                                                <div class="d-flex gap-2 justify-content-center">
                                                    <!-- Nút Sửa -->
                                                    <a href="${pageContext.request.contextPath}/students?action=edit&id=${student.id}"
                                                       class="btn-action btn-action-edit"
                                                       title="Chỉnh sửa">
                                                        <i class="bi bi-pencil-fill"></i>
                                                    </a>
                                                    <!-- Nút Xóa (mở modal xác nhận) -->
                                                    <button class="btn-action btn-action-delete"
                                                            title="Xóa sinh viên"
                                                            onclick="confirmDelete(${student.id}, '${student.hoTen}')">
                                                        <i class="bi bi-trash-fill"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><!-- /page-body -->
    </div><!-- /main-content -->

    <!-- ============================================================
         MODAL XÁC NHẬN XÓA
    ============================================================ -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title" id="deleteModalLabel">
                        <i class="bi bi-exclamation-triangle-fill text-danger me-2"></i>
                        Xác nhận xóa
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center">
                    <div class="delete-icon-wrapper">
                        <i class="bi bi-person-x-fill"></i>
                    </div>
                    <p>Bạn có chắc muốn xóa sinh viên</p>
                    <p><strong id="deleteStudentName" class="fs-5"></strong> không?</p>
                    <p style="font-size:13px; color:#64748b; margin-top:8px">
                        Hành động này không thể hoàn tác!
                    </p>
                </div>
                <div class="modal-footer border-0 justify-content-center gap-3">
                    <button type="button" class="btn-cancel-modal" data-bs-dismiss="modal">
                        <i class="bi bi-x-lg me-1"></i>Hủy bỏ
                    </button>
                    <a href="#" id="confirmDeleteBtn" class="btn-confirm-delete">
                        <i class="bi bi-trash-fill me-1"></i>Xóa ngay
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const contextPath = '${pageContext.request.contextPath}';

        /**
         * Mở modal xác nhận xóa và set thông tin sinh viên cần xóa
         * @param {number} id - ID sinh viên
         * @param {string} name - Họ tên sinh viên
         */
        function confirmDelete(id, name) {
            document.getElementById('deleteStudentName').textContent = name;
            document.getElementById('confirmDeleteBtn').href =
                contextPath + '/students?action=delete&id=' + id;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        // Tự động ẩn toast alert sau 4 giây
        setTimeout(() => {
            document.querySelectorAll('.alert-toast').forEach(el => {
                el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                el.style.opacity = '0';
                el.style.transform = 'translateX(120%)';
                setTimeout(() => el.remove(), 500);
            });
        }, 4000);

        // ── DỰ ÁN ĐIỂM CỘNG: TÌM KIẾM DYNAMIC KHÔNG TẢI LẠI TRANG + CẬP NHẬT STATS REALTIME ──
        function performSearch() {
            const keyword = document.getElementById('searchInput').value.trim().toLowerCase();
            const rows = document.querySelectorAll('#studentTable tbody tr');
            let totalCount = 0;
            let sumScore = 0;
            let goodCount = 0;
            let poorCount = 0;
            let hasMatches = false;

            rows.forEach(row => {
                const nameNode = row.querySelector('.student-name');
                const emailNode = row.querySelector('.student-email');
                if (!nameNode || !emailNode) return;

                const nameText = nameNode.textContent.toLowerCase();
                const emailText = emailNode.textContent.toLowerCase();
                const deptText = row.cells[2] ? row.cells[2].textContent.toLowerCase() : '';

                if (nameText.includes(keyword) || emailText.includes(keyword) || deptText.includes(keyword)) {
                    row.style.display = '';
                    totalCount++;
                    hasMatches = true;

                    // Get score
                    const scoreValNode = row.querySelector('.score-value');
                    if (scoreValNode) {
                        const scoreText = scoreValNode.textContent.replace(',', '.').trim();
                        const score = parseFloat(scoreText);
                        if (!isNaN(score)) {
                            sumScore += score;
                            if (score >= 8.0) goodCount++;
                            if (score < 5.0) poorCount++;
                        }
                    }
                } else {
                    row.style.display = 'none';
                }
            });

            // Update stats cards in DOM
            const avgScore = totalCount > 0 ? (sumScore / totalCount).toFixed(2) : '0.00';
            
            document.getElementById('statTotal').textContent = totalCount;
            document.getElementById('statAvg').textContent = avgScore.replace('.', ',');
            document.getElementById('statGood').textContent = goodCount;
            document.getElementById('statPoor').textContent = poorCount;
            
            const countLabel = document.querySelector('.table-card-header .table-record-count');
            if (countLabel) {
                countLabel.textContent = totalCount + ' bản ghi';
            }

            // Show/hide empty state
            let emptyState = document.getElementById('emptyStateDiv');
            const tableContainer = document.querySelector('.table-responsive');

            if (!hasMatches) {
                if (!emptyState) {
                    emptyState = document.createElement('div');
                    emptyState.id = 'emptyStateDiv';
                    emptyState.className = 'empty-state';
                    emptyState.innerHTML = `
                        <div class="empty-state-icon"><i class="bi bi-person-x"></i></div>
                        <h5>Không tìm thấy sinh viên nào</h5>
                        <p>Không có kết quả khớp với từ khóa "<strong>${document.getElementById('searchInput').value}</strong>"</p>
                    `;
                    document.querySelector('.table-card').appendChild(emptyState);
                } else {
                    emptyState.style.display = 'block';
                    emptyState.querySelector('strong').textContent = document.getElementById('searchInput').value;
                }
                if (tableContainer) tableContainer.style.display = 'none';
            } else {
                if (emptyState) emptyState.style.display = 'none';
                if (tableContainer) tableContainer.style.display = 'block';
            }
        }

        // Gắn sự kiện
        document.getElementById('searchForm').addEventListener('submit', function(e) {
            e.preventDefault();
            performSearch();
        });

        document.getElementById('searchInput').addEventListener('input', function() {
            performSearch();
        });

        document.getElementById('btnReset').addEventListener('click', function(e) {
            e.preventDefault();
            document.getElementById('searchInput').value = '';
            performSearch();
        });
    </script>
</body>
</html>
