package com.example.shopweb;
 
import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;
 
/**
 * Cấu hình JAX-RS REST base path.
 * QUAN TRỌNG: Phải dùng "/api" thay vì "/" hoặc ""
 * Nếu để "/" thì JAX-RS sẽ chặn toàn bộ request, bao gồm cả /cart, /products...
 * → Kết quả: trình duyệt thấy {"status":"ok"} thay vì trang JSP
 */
@ApplicationPath("/api")
public class JakartaRestConfiguration extends Application {
}
 