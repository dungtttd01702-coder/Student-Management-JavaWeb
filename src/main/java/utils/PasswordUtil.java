package utils;

import org.mindrot.jbcrypt.BCrypt;

/**
 * FILE: PasswordUtil.java
 * PACKAGE: utils
 *
 * MỤC ĐÍCH:
 *   Cung cấp các hàm mã hóa mật khẩu sử dụng thuật toán BCrypt.
 */
public class PasswordUtil {

    /**
     * Mã hóa mật khẩu thô thành chuỗi hash BCrypt.
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) return null;
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(10));
    }

    /**
     * Kiểm tra mật khẩu thô nhập vào có khớp với chuỗi đã mã hóa trong DB hay không.
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            System.err.println("[PasswordUtil] ✗ Lỗi khi kiểm tra mật khẩu: " + e.getMessage());
            return false;
        }
    }
}
