package utils;

import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        try {
            Connection conn = DBConnection.getConnection();
            if (conn != null) {
                System.out.println("✅ Kết nối database THÀNH CÔNG!");
                System.out.println("Database: " + conn.getCatalog());
                conn.close();
            }
        } catch (Exception e) {
            System.out.println("❌ Lỗi kết nối database:");
            e.printStackTrace();
        }
    }
}