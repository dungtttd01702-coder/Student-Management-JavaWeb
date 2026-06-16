package model;

/**
 * FILE: Student.java
 * PACKAGE: model
 *
 * MỤC ĐÍCH:
 *   Model đại diện cho bảng SinhVien trong cơ sở dữ liệu.
 *   Đã được chuẩn hóa để khớp với StudentServlet và StudentDAO.
 */
public class Student {
    private int id;
    private String hoTen;
    private String email;
    private String chuyenNganh;
    private double diemTB; 

    // Constructor mặc định
    public Student() {}

    // Constructor 4 tham số (Dùng khi THÊM MỚI - không cần truyền id)
    public Student(String hoTen, String email, String chuyenNganh, double diemTB) {
        this.hoTen = hoTen;
        this.email = email;
        this.chuyenNganh = chuyenNganh;
        this.diemTB = diemTB;
    }

    // Constructor 5 tham số (Dùng khi SỬA hoặc đọc từ Database lên)
    public Student(int id, String hoTen, String email, String chuyenNganh, double diemTB) {
        this.id = id;
        this.hoTen = hoTen;
        this.email = email;
        this.chuyenNganh = chuyenNganh;
        this.diemTB = diemTB;
    }

    // ==================== GETTER & SETTER ====================
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getChuyenNganh() { return chuyenNganh; }
    public void setChuyenNganh(String chuyenNganh) { this.chuyenNganh = chuyenNganh; }

    public double getDiemTB() { return diemTB; }
    public void setDiemTB(double diemTB) { this.diemTB = diemTB; }

    // ==================== LOGIC PHỤ TRỢ ====================
    public String getXepLoai() {
        if (diemTB >= 9.0)       return "Xuất sắc";
        else if (diemTB >= 8.0)  return "Giỏi";
        else if (diemTB >= 7.0)  return "Khá";
        else if (diemTB >= 5.0)  return "Trung bình";
        else if (diemTB > 0.0)   return "Yếu";
        else                     return "Chưa có điểm";
    }

    public String getXepLoaiClass() {
        if (diemTB >= 9.0)       return "badge-xuat-sac";
        else if (diemTB >= 8.0)  return "badge-gioi";
        else if (diemTB >= 7.0)  return "badge-kha";
        else if (diemTB >= 5.0)  return "badge-tb";
        else if (diemTB > 0.0)   return "badge-yeu";
        else                     return "badge-secondary bg-secondary text-white";
    }

    @Override
    public String toString() {
        return "Student{id=" + id + ", hoTen='" + hoTen + "', email='" + email + "'}";
    }
}