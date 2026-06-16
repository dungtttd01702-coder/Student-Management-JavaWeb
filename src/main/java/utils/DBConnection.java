package utils;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * FILE: DBConnection.java
 * PACKAGE: utils
 *
 * MỤC ĐÍCH:
 *   Quản lý kết nối JDBC đến SQL Server sử dụng Connection Pool HikariCP.
 *   Cung cấp getConnection() dùng chung có hiệu năng cao.
 */
public class DBConnection {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String DB_URL =
        "jdbc:sqlserver://localhost:1433;"
        + "databaseName=QuanLySinhVien;"
        + "encrypt=false;"
        + "trustServerCertificate=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "123";

    private static HikariDataSource dataSource;

    static {
        try {
            // Load driver
            Class.forName(DRIVER);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(DB_URL);
            config.setUsername(DB_USER);
            config.setPassword(DB_PASSWORD);
            config.setDriverClassName(DRIVER);

            // Cấu hình Connection Pool
            config.setMaximumPoolSize(15);         // Số lượng kết nối tối đa
            config.setMinimumIdle(5);              // Số kết nối nhàn rỗi tối thiểu
            config.setIdleTimeout(300000);         // 5 phút giải phóng kết nối thừa
            config.setConnectionTimeout(20000);    // 20 giây timeout lấy kết nối
            config.setMaxLifetime(1800000);       // Tuổi thọ tối đa của 1 kết nối (30 phút)
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            System.out.println("[DBConnection] ✓ HikariCP connection pool initialized successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] ✗ Không tìm thấy Microsoft SQL Server JDBC Driver!");
            throw new ExceptionInInitializerError(e);
        } catch (Exception e) {
            System.err.println("[DBConnection] ✗ Lỗi khởi tạo Connection Pool: " + e.getMessage());
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() {
        throw new UnsupportedOperationException("DBConnection là Utility class, không khởi tạo instance!");
    }

    /**
     * Lấy kết nối từ Connection Pool.
     * Dùng xong kết nối tự động trả về pool (khi đóng conn).
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource chưa được khởi tạo!");
        }
        return dataSource.getConnection();
    }

    /**
     * Kiểm tra kết nối database.
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("[DBConnection] ✗ Lỗi kiểm tra kết nối: " + e.getMessage());
            return false;
        }
    }
}
