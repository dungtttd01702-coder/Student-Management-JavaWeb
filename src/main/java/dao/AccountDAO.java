package dao;

import model.Account;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * FILE: AccountDAO.java
 * PACKAGE: dao
 *
 * MỤC ĐÍCH:
 *   Data Access Object cho bảng Users.
 *   Xử lý đăng nhập với mật khẩu plain text.
 */
public class AccountDAO {

    // Query bảng Users (không phải TaiKhoan)
    private static final String SQL_LOGIN =
        "SELECT id, username, password "
        + "FROM Users "
        + "WHERE username = ?";

    /**
     * Kiểm tra thông tin đăng nhập.
     * Chỉ query theo username, sau đó so sánh password trong Java code.
     */
    public Account checkLogin(String username, String password) {
        Account account = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_LOGIN)) {

            // Chỉ set username
            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Lấy thông tin từ database
                    int id = rs.getInt("id");
                    String dbUsername = rs.getString("username");
                    String dbPassword = rs.getString("password");

                    // Debug log
                    System.out.println("[DEBUG] Input password: " + password);
                    System.out.println("[DEBUG] DB password: " + dbPassword);

                    // So sánh password trong Java code
                    if (password.equals(dbPassword)) {
                        account = new Account(id, dbUsername, dbPassword);
                        System.out.println("[AccountDAO] ✓ Login success: " + username);
                    } else {
                        System.out.println("[AccountDAO] ✗ Wrong password for: " + username);
                    }
                } else {
                    System.out.println("[AccountDAO] ✗ Username not found: " + username);
                }
            }

        } catch (SQLException e) {
            System.err.println("[AccountDAO] ✗ SQL Error in checkLogin: " + e.getMessage());
            e.printStackTrace();
        }

        return account;
    }
}