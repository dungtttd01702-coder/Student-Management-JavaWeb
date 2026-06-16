package controller;

import dao.AccountDAO;
import model.Account;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * FILE: LoginServlet.java
 * PACKAGE: controller
 *
 * MỤC ĐÍCH:
 *   Controller xử lý đăng nhập và đăng xuất.
 *   URL mapping: /login (xử lý GET và POST cho trang đăng nhập)
 *                /logout (xử lý GET để đăng xuất)
 *
 * TẠI SAO CẦN:
 *   Trong MVC, Servlet là Controller - nhận request từ browser,
 *   gọi DAO để xử lý business logic, quyết định forward/redirect.
 *
 * LUỒNG ĐĂNG NHẬP:
 *   Browser → POST /login → LoginServlet.doPost()
 *   → AccountDAO.checkLogin() → SQL Server
 *   → Nếu đúng: tạo Session, redirect → /students
 *   → Nếu sai: set error message, forward → login.jsp
 *
 * LUỒNG ĐĂNG XUẤT:
 *   Browser → GET /logout → LoginServlet.doGet() với action=logout
 *   → Invalidate Session → redirect → /login
 *
 * DÒNG QUAN TRỌNG:
 *   @WebServlet: Annotation thay cho cấu hình trong web.xml
 *   session.setAttribute("account", account): Lưu thông tin login vào Session
 *   response.sendRedirect(): Chuyển hướng browser sang URL khác
 *   request.getRequestDispatcher().forward(): Forward đến JSP cùng request
 *
 * MUỐN THÊM CHỨC NĂNG "NHỚ MẬT KHẨU":
 *   → Thêm Cookie trong doPost() sau khi đăng nhập thành công
 *
 * MUỐN HASH MẬT KHẨU:
 *   → Thêm BCrypt dependency, sửa AccountDAO.checkLogin()
 *   → LoginServlet không cần sửa vì logic đã ở DAO
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    /** Tên attribute lưu thông tin tài khoản trong Session */
    private static final String SESSION_ACCOUNT = "account";

    /** DAO để tương tác với bảng TaiKhoan */
    private final AccountDAO accountDAO = new AccountDAO();

    // ============================================================
    // GET: Hiển thị trang đăng nhập hoặc xử lý đăng xuất
    // ============================================================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();

        if (uri.endsWith("/logout")) {
            // ---- XỬ LÝ ĐĂNG XUẤT ----
            HttpSession session = request.getSession(false); // false = không tạo session mới
            if (session != null) {
                session.invalidate(); // Xóa toàn bộ session
                System.out.println("[LoginServlet] ✓ User logged out");
            }
            // Redirect về trang login với thông báo
            response.sendRedirect(request.getContextPath() + "/login?msg=logout");

        } else {
            // ---- HIỂN THỊ FORM ĐĂNG NHẬP ----
            // Nếu đã đăng nhập thì chuyển thẳng đến trang quản lý
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute(SESSION_ACCOUNT) != null) {
                response.sendRedirect(request.getContextPath() + "/students");
                return;
            }

            // Forward đến login.jsp để hiển thị form
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }

    // ============================================================
    // POST: Xử lý form đăng nhập
    // ============================================================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đặt encoding để nhận được ký tự Unicode (tiếng Việt)
        request.setCharacterEncoding("UTF-8");

        // Lấy dữ liệu từ form HTML
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // ---- VALIDATE CƠ BẢN ----
        if (username == null || username.trim().isEmpty()
         || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        // ---- GỌI DAO KIỂM TRA ĐĂNG NHẬP ----
        Account account = accountDAO.checkLogin(username.trim(), password.trim());

        if (account != null) {
            // ---- ĐĂNG NHẬP THÀNH CÔNG ----
            // Tạo session mới (tránh Session Fixation Attack)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession newSession = request.getSession(true);
            newSession.setAttribute(SESSION_ACCOUNT, account); // Lưu account vào session
            newSession.setMaxInactiveInterval(30 * 60);        // Session hết hạn sau 30 phút

            System.out.println("[LoginServlet] ✓ Login success: " + account.getUsername());

            // Redirect đến trang quản lý sinh viên
            response.sendRedirect(request.getContextPath() + "/students");

        } else {
            // ---- ĐĂNG NHẬP THẤT BẠI ----
            System.out.println("[LoginServlet] ✗ Login failed for username: " + username);

            // Đặt thông báo lỗi và trả lại form đăng nhập
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.setAttribute("username", username); // Giữ lại username đã nhập

            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
}
