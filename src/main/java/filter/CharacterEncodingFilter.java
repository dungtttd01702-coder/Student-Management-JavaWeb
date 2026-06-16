package filter;

import jakarta.servlet.*;
import java.io.IOException;

/**
 * FILE: CharacterEncodingFilter.java
 * PACKAGE: filter
 *
 * MỤC ĐÍCH:
 *   Filter dùng để thiết lập Character Encoding (UTF-8) cho tất cả request và response.
 *   Giúp hiển thị và xử lý tiếng Việt có dấu chuẩn xác trong toàn bộ ứng dụng.
 *
 * TẠI SAO CẦN:
 *   Thay vì phải gọi request.setCharacterEncoding("UTF-8") ở tất cả các Servlet,
 *   Filter này sẽ tự động chặn và xử lý cho tất cả các request trước khi đến Servlet.
 */
public class CharacterEncodingFilter implements Filter {

    private String encoding = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String encodingParam = filterConfig.getInitParameter("encoding");
        if (encodingParam != null && !encodingParam.trim().isEmpty()) {
            this.encoding = encodingParam;
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Thiết lập encoding cho request và response
        request.setCharacterEncoding(encoding);
        response.setCharacterEncoding(encoding);
        
        // Chuyển tiếp request đến filter tiếp theo hoặc servlet đích
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Dọn dẹp tài nguyên nếu cần
    }
}
