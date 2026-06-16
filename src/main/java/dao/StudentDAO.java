package dao;

import model.Student;
import utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * FILE: StudentDAO.java
 * PACKAGE: dao
 *
 * MỤC ĐÍCH:
 *   Data Access Object cho bảng SinhVien.
 *   Chứa toàn bộ logic CRUD (Create, Read, Update, Delete) cho sinh viên.
 *
 * TẠI SAO CẦN:
 *   Servlet không được phép viết SQL trực tiếp (vi phạm nguyên tắc MVC).
 *   DAO đóng gói tất cả logic truy vấn database, Servlet chỉ gọi phương thức.
 *
 * DANH SÁCH PHƯƠNG THỨC:
 *   getAll()        → Lấy tất cả sinh viên (trang danh sách)
 *   search()        → Tìm kiếm theo tên
 *   findById()      → Tìm theo ID (để pre-fill form sửa)
 *   insert()        → Thêm sinh viên mới
 *   update()        → Cập nhật thông tin sinh viên
 *   delete()        → Xóa sinh viên
 *
 * MUỐN THÊM CỘT:
 *   1. Thêm cột vào bảng SinhVien (database.sql)
 *   2. Thêm field vào Student.java
 *   3. Cập nhật SQL_SELECT_ALL, SQL_INSERT, SQL_UPDATE ở đây
 *   4. Cập nhật mapResultSet() để đọc cột mới
 *   5. Cập nhật Servlet để đọc parameter mới
 *   6. Cập nhật JSP để hiển thị/nhập cột mới
 */
public class StudentDAO {

    // ============================================================
    // CÂU SQL - Tập trung ở đầu để dễ bảo trì
    // ============================================================

    /** Lấy tất cả sinh viên, sắp xếp theo ID giảm dần (mới nhất lên đầu) */
    private static final String SQL_SELECT_ALL =
        "SELECT id, hoTen, email, chuyenNganh, diemTB "
        + "FROM SinhVien ORDER BY id DESC";

    /** Tìm kiếm sinh viên theo tên (LIKE - không phân biệt hoa/thường) */
    private static final String SQL_SEARCH =
        "SELECT id, hoTen, email, chuyenNganh, diemTB "
        + "FROM SinhVien "
        + "WHERE hoTen LIKE ? "
        + "ORDER BY id DESC";

    /** Tìm sinh viên theo ID */
    private static final String SQL_SELECT_BY_ID =
        "SELECT id, hoTen, email, chuyenNganh, diemTB "
        + "FROM SinhVien WHERE id = ?";

    /** Thêm sinh viên mới (id tự tăng, không cần chỉ định) */
    private static final String SQL_INSERT =
        "INSERT INTO SinhVien (hoTen, email, chuyenNganh, diemTB) "
        + "VALUES (?, ?, ?, ?)";

    /** Cập nhật thông tin sinh viên theo id */
    private static final String SQL_UPDATE =
        "UPDATE SinhVien "
        + "SET hoTen = ?, email = ?, chuyenNganh = ?, diemTB = ? "
        + "WHERE id = ?";

    /** Xóa sinh viên theo id */
    private static final String SQL_DELETE =
        "DELETE FROM SinhVien WHERE id = ?";

    // ============================================================
    // HELPER METHOD: Chuyển ResultSet thành Student object
    // ============================================================

    /**
     * Ánh xạ một dòng ResultSet thành Student object.
     * Phương thức này dùng lại ở nhiều chỗ để tránh lặp code.
     *
     * MUỐN THÊM CỘT: Thêm rs.getXxx("tenCot") vào đây
     */
    private Student mapResultSet(ResultSet rs) throws SQLException {
        return new Student(
            rs.getInt("id"),
            rs.getString("hoTen"),
            rs.getString("email"),
            rs.getString("chuyenNganh"),
            rs.getDouble("diemTB")
        );
    }

    // ============================================================
    // PHƯƠNG THỨC: Lấy tất cả sinh viên
    // ============================================================

    /**
     * Lấy danh sách tất cả sinh viên.
     * Dùng ở: StudentServlet → action "list"
     *
     * @return List<Student> (rỗng nếu chưa có sinh viên nào)
     */
    public List<Student> getAll() {
        List<Student> students = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_ALL);
             ResultSet rs = ps.executeQuery()) {

            // Duyệt từng dòng kết quả và thêm vào list
            while (rs.next()) {
                students.add(mapResultSet(rs));
            }
            System.out.println("[StudentDAO] getAll() → " + students.size() + " records");

        } catch (SQLException e) {
            System.err.println("[StudentDAO] ✗ Error in getAll(): " + e.getMessage());
        }

        return students;
    }

    // ============================================================
    // PHƯƠNG THỨC: Tìm kiếm sinh viên theo tên
    // ============================================================

    /**
     * Tìm kiếm sinh viên theo tên (LIKE %keyword%).
     * Dùng ở: StudentServlet → action "search"
     *
     * @param keyword Từ khóa tìm kiếm
     * @return List<Student> chứa các sinh viên có tên khớp
     */
    public List<Student> search(String keyword) {
        List<Student> students = new ArrayList<>();

        // Bọc keyword trong dấu % để tìm kiếm ở bất kỳ vị trí nào
        // Ví dụ: keyword="an" → LIKE '%an%' → tìm "Nguyễn Văn An", "Bảo An"...
        String searchPattern = "%" + keyword + "%";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SEARCH)) {

            ps.setString(1, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    students.add(mapResultSet(rs));
                }
            }
            System.out.println("[StudentDAO] search('" + keyword + "') → " + students.size() + " records");

        } catch (SQLException e) {
            System.err.println("[StudentDAO] ✗ Error in search(): " + e.getMessage());
        }

        return students;
    }

    // ============================================================
    // PHƯƠNG THỨC: Tìm sinh viên theo ID
    // ============================================================

    /**
     * Tìm một sinh viên theo ID.
     * Dùng ở: StudentServlet → action "edit" (load form sửa)
     *
     * @param id Mã sinh viên
     * @return Student nếu tìm thấy, null nếu không tồn tại
     */
    public Student findById(int id) {
        Student student = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_ID)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    student = mapResultSet(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("[StudentDAO] ✗ Error in findById(" + id + "): " + e.getMessage());
        }

        return student;
    }

    // ============================================================
    // PHƯƠNG THỨC: Thêm sinh viên mới
    // ============================================================

    /**
     * Thêm một sinh viên mới vào database.
     * Dùng ở: StudentServlet → action "insert" (POST)
     *
     * @param student Student object cần thêm (id sẽ được DB tự tạo)
     * @return true nếu thêm thành công, false nếu thất bại
     */
    public boolean insert(Student student) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            // Set lần lượt các tham số ?
            ps.setString(1, student.getHoTen());       // ? 1
            ps.setString(2, student.getEmail());        // ? 2
            ps.setString(3, student.getChuyenNganh()); // ? 3
            ps.setDouble(4, student.getDiemTB());      // ? 4

            int rowsAffected = ps.executeUpdate();
            System.out.println("[StudentDAO] insert() → " + rowsAffected + " row(s) inserted");
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("[StudentDAO] ✗ Error in insert(): " + e.getMessage());
            return false;
        }
    }

    // ============================================================
    // PHƯƠNG THỨC: Cập nhật sinh viên
    // ============================================================

    /**
     * Cập nhật thông tin sinh viên.
     * Dùng ở: StudentServlet → action "update" (POST)
     *
     * @param student Student object đã có ID và thông tin mới
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean update(Student student) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {

            ps.setString(1, student.getHoTen());       // ? 1: SET hoTen
            ps.setString(2, student.getEmail());        // ? 2: SET email
            ps.setString(3, student.getChuyenNganh()); // ? 3: SET chuyenNganh
            ps.setDouble(4, student.getDiemTB());      // ? 4: SET diemTB
            ps.setInt   (5, student.getId());           // ? 5: WHERE id

            int rowsAffected = ps.executeUpdate();
            System.out.println("[StudentDAO] update(id=" + student.getId() + ") → " + rowsAffected + " row(s) updated");
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("[StudentDAO] ✗ Error in update(): " + e.getMessage());
            return false;
        }
    }

    // ============================================================
    // PHƯƠNG THỨC: Xóa sinh viên
    // ============================================================

    /**
     * Xóa sinh viên theo ID.
     * Dùng ở: StudentServlet → action "delete" (GET với param id)
     *
     * @param id Mã sinh viên cần xóa
     * @return true nếu xóa thành công, false nếu thất bại
     */
    public boolean delete(int id) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {

            ps.setInt(1, id);
            int rowsAffected = ps.executeUpdate();
            System.out.println("[StudentDAO] delete(id=" + id + ") → " + rowsAffected + " row(s) deleted");
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("[StudentDAO] ✗ Error in delete(" + id + "): " + e.getMessage());
            return false;
        }
    }
}
