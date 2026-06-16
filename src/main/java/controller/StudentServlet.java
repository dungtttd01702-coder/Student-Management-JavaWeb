package controller;

import dao.StudentDAO;
import model.Account;
import model.Student;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * FILE: StudentServlet.java
 * PACKAGE: controller
 *
 * MỤC ĐÍCH:
 *   Controller chính xử lý toàn bộ CRUD cho sinh viên.
 *   URL mapping: /students (tất cả action đều qua đây)
 *
 * TẠI SAO CẦN:
 *   Một Servlet duy nhất xử lý tất cả các thao tác sinh viên,
 *   phân biệt bằng parameter "action" trong request.
 *   Đây là mô hình Front Controller Pattern.
 *
 * BẢNG ACTION:
 *   action=list (hoặc mặc định) → Hiển thị danh sách
 *   action=search               → Tìm kiếm theo tên
 *   action=new                  → Hiển thị form thêm mới
 *   action=insert               → POST: Lưu sinh viên mới
 *   action=edit                 → Hiển thị form sửa (pre-fill)
 *   action=update               → POST: Lưu thay đổi
 *   action=delete               → Xóa sinh viên
 *
 * LUỒNG THÊM SINH VIÊN:
 *   GET /students?action=new → student-form.jsp (trống)
 *   → User nhập form, Submit → POST /students?action=insert
 *   → Validate → StudentDAO.insert() → redirect /students
 *
 * LUỒNG SỬA SINH VIÊN:
 *   GET /students?action=edit&id=5 → StudentDAO.findById(5)
 *   → student-form.jsp (pre-filled với dữ liệu cũ)
 *   → User sửa, Submit → POST /students?action=update
 *   → Validate → StudentDAO.update() → redirect /students
 *
 * BẢO MẬT:
 *   checkLogin(): Kiểm tra session mỗi request.
 *   Nếu chưa login → redirect về /login.
 *   Đây là cách bảo vệ các trang cần xác thực.
 *
 * MUỐN THÊM CHỨC NĂNG (ví dụ: xuất Excel):
 *   Thêm case "export" trong doGet(), gọi StudentDAO.getAll()
 *   rồi viết dữ liệu ra response dạng Excel
 */
@WebServlet(name = "StudentServlet", urlPatterns = {"/students"})
public class StudentServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    // ============================================================
    // GET: Hiển thị danh sách, form thêm/sửa, tìm kiếm, xóa
    // ============================================================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ---- KIỂM TRA ĐĂNG NHẬP ----
        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy action từ request parameter (mặc định là "list")
        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "list";
        }

        System.out.println("[StudentServlet] GET action=" + action);

        // Điều hướng đến phương thức xử lý tương ứng
        switch (action) {
            case "list":
                showList(request, response);
                break;
            case "search":
                searchStudents(request, response);
                break;
            case "new":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteStudent(request, response);
                break;
            default:
                showList(request, response);
        }
    }

    // ============================================================
    // POST: Xử lý form thêm mới và cập nhật
    // ============================================================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ---- KIỂM TRA ĐĂNG NHẬP ----
        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("[StudentServlet] POST action=" + action);

        if ("insert".equals(action)) {
            insertStudent(request, response);
        } else if ("update".equals(action)) {
            updateStudent(request, response);
        } else {
            showList(request, response);
        }
    }

    // ============================================================
    // HELPER: Kiểm tra trạng thái đăng nhập
    // ============================================================

    /**
     * Kiểm tra session có tài khoản đăng nhập không.
     * @return true nếu đã đăng nhập, false nếu chưa
     */
    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("account") != null;
    }

    // ============================================================
    // ACTION: Hiển thị danh sách tất cả sinh viên
    // ============================================================

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Student> students = studentDAO.getAll();
        request.setAttribute("students", students);
        request.setAttribute("totalCount", students.size());
        request.getRequestDispatcher("/views/student-list.jsp").forward(request, response);
    }

    // ============================================================
    // ACTION: Tìm kiếm sinh viên theo tên
    // ============================================================

    private void searchStudents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        List<Student> students;
        if (keyword.trim().isEmpty()) {
            // Keyword rỗng → hiển thị tất cả
            students = studentDAO.getAll();
        } else {
            students = studentDAO.search(keyword.trim());
        }

        request.setAttribute("students", students);
        request.setAttribute("keyword", keyword);       // Giữ lại keyword trong search box
        request.setAttribute("totalCount", students.size());
        request.getRequestDispatcher("/views/student-list.jsp").forward(request, response);
    }

    // ============================================================
    // ACTION: Hiển thị form THÊM mới (trống)
    // ============================================================

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Không cần set student attribute → JSP sẽ hiển thị form trống
        request.setAttribute("formAction", "insert");
        request.setAttribute("pageTitle", "Thêm sinh viên mới");
        request.getRequestDispatcher("/views/student-form.jsp").forward(request, response);
    }

    // ============================================================
    // ACTION: Hiển thị form SỬA (pre-filled với dữ liệu cũ)
    // ============================================================

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        // Validate ID parameter
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/students?error=invalid_id");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            Student student = studentDAO.findById(id);

            if (student == null) {
                // Sinh viên không tồn tại
                response.sendRedirect(request.getContextPath() + "/students?error=not_found");
                return;
            }

            // Truyền student object vào request để JSP pre-fill form
            request.setAttribute("student", student);
            request.setAttribute("formAction", "update");
            request.setAttribute("pageTitle", "Chỉnh sửa thông tin sinh viên");
            request.getRequestDispatcher("/views/student-form.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/students?error=invalid_id");
        }
    }

    // ============================================================
    // ACTION: Xóa sinh viên
    // ============================================================

    private void deleteStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                boolean success = studentDAO.delete(id);

                if (success) {
                    // Thêm thông báo thành công vào URL
                    response.sendRedirect(request.getContextPath() + "/students?success=deleted");
                } else {
                    response.sendRedirect(request.getContextPath() + "/students?error=delete_failed");
                }

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/students?error=invalid_id");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/students?error=invalid_id");
        }
    }

    // ============================================================
    // ACTION: Lưu sinh viên MỚI (POST)
    // ============================================================

    private void insertStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy và validate dữ liệu từ form
        String hoTen       = request.getParameter("hoTen");
        String email       = request.getParameter("email");
        String chuyenNganh = request.getParameter("chuyenNganh");
        String diemTBStr   = request.getParameter("diemTB");

        // Validate các trường
        String validationError = validateStudentInput(hoTen, email, chuyenNganh, diemTBStr);

        if (validationError != null) {
            // Có lỗi validate → trả lại form với thông báo lỗi
            request.setAttribute("error", validationError);
            request.setAttribute("formAction", "insert");
            request.setAttribute("pageTitle", "Thêm sinh viên mới");
            // Giữ lại dữ liệu đã nhập để user không phải nhập lại
            request.setAttribute("inputHoTen", hoTen);
            request.setAttribute("inputEmail", email);
            request.setAttribute("inputChuyenNganh", chuyenNganh);
            request.setAttribute("inputDiemTB", diemTBStr);
            request.getRequestDispatcher("/views/student-form.jsp").forward(request, response);
            return;
        }

        // Tạo Student object và lưu vào DB
        double diemTB = Double.parseDouble(diemTBStr.trim());
        Student newStudent = new Student(hoTen.trim(), email.trim(), chuyenNganh.trim(), diemTB);

        boolean success = studentDAO.insert(newStudent);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/students?success=added");
        } else {
            request.setAttribute("error", "Có lỗi khi thêm sinh viên. Email có thể đã tồn tại!");
            request.setAttribute("formAction", "insert");
            request.setAttribute("pageTitle", "Thêm sinh viên mới");
            request.getRequestDispatcher("/views/student-form.jsp").forward(request, response);
        }
    }

    // ============================================================
    // ACTION: Cập nhật sinh viên (POST)
    // ============================================================

    private void updateStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam     = request.getParameter("id");
        String hoTen       = request.getParameter("hoTen");
        String email       = request.getParameter("email");
        String chuyenNganh = request.getParameter("chuyenNganh");
        String diemTBStr   = request.getParameter("diemTB");

        // Validate ID
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/students?error=invalid_id");
            return;
        }

        // Validate sinh viên data
        String validationError = validateStudentInput(hoTen, email, chuyenNganh, diemTBStr);
        int id;

        try {
            id = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/students?error=invalid_id");
            return;
        }

        if (validationError != null) {
            // Có lỗi validate → tạo Student object để pre-fill form
            Student student = new Student(id, hoTen, email, chuyenNganh, 0);
            request.setAttribute("student", student);
            request.setAttribute("inputDiemTB", diemTBStr);
            request.setAttribute("error", validationError);
            request.setAttribute("formAction", "update");
            request.setAttribute("pageTitle", "Chỉnh sửa thông tin sinh viên");
            request.getRequestDispatcher("/views/student-form.jsp").forward(request, response);
            return;
        }

        double diemTB = Double.parseDouble(diemTBStr.trim());
        Student updatedStudent = new Student(id, hoTen.trim(), email.trim(), chuyenNganh.trim(), diemTB);

        boolean success = studentDAO.update(updatedStudent);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/students?success=updated");
        } else {
            request.setAttribute("error", "Có lỗi khi cập nhật. Email có thể đã tồn tại!");
            request.setAttribute("student", updatedStudent);
            request.setAttribute("formAction", "update");
            request.setAttribute("pageTitle", "Chỉnh sửa thông tin sinh viên");
            request.getRequestDispatcher("/views/student-form.jsp").forward(request, response);
        }
    }

    // ============================================================
    // HELPER: Validate dữ liệu sinh viên
    // ============================================================

    /**
     * Kiểm tra tính hợp lệ của dữ liệu sinh viên.
     *
     * QUY TẮC VALIDATE:
     *   - Họ tên: không được rỗng
     *   - Email: phải đúng định dạng xxx@xxx.xxx
     *   - Chuyên ngành: không được rỗng
     *   - Điểm TB: phải là số, trong khoảng 0.0 - 10.0
     *
     * MUỐN THÊM QUY TẮC VALIDATE:
     *   → Thêm điều kiện if vào phương thức này
     *
     * @return null nếu hợp lệ, chuỗi thông báo lỗi nếu không hợp lệ
     */
    private String validateStudentInput(String hoTen, String email,
                                        String chuyenNganh, String diemTBStr) {

        // Kiểm tra Họ tên
        if (hoTen == null || hoTen.trim().isEmpty()) {
            return "Họ tên không được để trống!";
        }
        if (hoTen.trim().length() < 2 || hoTen.trim().length() > 100) {
            return "Họ tên phải từ 2 đến 100 ký tự!";
        }

        // Kiểm tra Email
        if (email == null || email.trim().isEmpty()) {
            return "Email không được để trống!";
        }
        // Regex validate email cơ bản
        if (!email.trim().matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$")) {
            return "Email không đúng định dạng! (ví dụ: example@email.com)";
        }

        // Kiểm tra Chuyên ngành
        if (chuyenNganh == null || chuyenNganh.trim().isEmpty()) {
            return "Chuyên ngành không được để trống!";
        }

        // Kiểm tra Điểm trung bình
        if (diemTBStr == null || diemTBStr.trim().isEmpty()) {
            return "Điểm trung bình không được để trống!";
        }
        try {
            double diemTB = Double.parseDouble(diemTBStr.trim());
            if (diemTB < 0 || diemTB > 10) {
                return "Điểm trung bình phải từ 0 đến 10!";
            }
        } catch (NumberFormatException e) {
            return "Điểm trung bình phải là số! (ví dụ: 7.5)";
        }

        return null; // Hợp lệ
    }
}
