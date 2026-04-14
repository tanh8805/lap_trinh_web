<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopWeb - Trang chủ</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        
        /* ===== NAVBAR ===== */
        nav {
            background: #ffffff;
            padding: 15px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; color: #000; text-decoration: none; }
        .menu { display: flex; align-items: center; }
        .menu a {
            margin-left: 25px; text-decoration: none; color: #555;
            font-weight: 500; transition: color 0.3s;
        }
        .menu a:hover { color: #000; }

        /* Icon giỏ hàng với badge số lượng */
        .cart-link {
            position: relative;
            margin-left: 25px;
            text-decoration: none;
            color: #555;
            font-size: 22px;
            display: flex;
            align-items: center;
            transition: color 0.3s;
        }
        .cart-link:hover { color: #000; }
        .cart-badge {
            position: absolute;
            top: -8px;
            right: -10px;
            background: #e74c3c;
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            min-width: 18px;
            height: 18px;
            border-radius: 9px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
            /* Ẩn khi số lượng = 0 */
            display: none;
        }
        
        /* ===== HERO ===== */
        .hero {
            background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)),
                        url('https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80') center/cover;
            color: #fff;
            padding: 100px 20px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 400px;
        }
        .hero h1 { font-size: 48px; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 2px; }
        .hero p { font-size: 18px; margin-bottom: 30px; max-width: 600px; line-height: 1.6; }
        .btn-shop {
            display: inline-block; padding: 15px 35px; background: #fff; color: #000;
            text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 16px;
            transition: background 0.3s, transform 0.2s;
        }
        .btn-shop:hover { background: #eee; transform: translateY(-2px); }
        
        /* ===== MAIN CONTAINER ===== */
        .container { flex: 1; padding: 60px 20px; max-width: 1200px; margin: 0 auto; width: 100%; }
        .section-title { text-align: center; font-size: 32px; margin-bottom: 40px; color: #111; }
        
        /* Categories Grid */
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }
        .category-card {
            background: #fff; border-radius: 8px; overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); text-align: center;
            transition: transform 0.3s; cursor: pointer;
        }
        .category-card:hover { transform: translateY(-5px); }
        .category-img { width: 100%; height: 250px; object-fit: cover; }
        .category-name { padding: 20px; font-size: 20px; font-weight: 600; color: #222; }

        /* Features Section */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
        }
        .feature-item { text-align: center; padding: 20px; }
        .feature-icon { font-size: 40px; margin-bottom: 15px; }
        .feature-title { font-size: 18px; font-weight: bold; margin-bottom: 10px; color: #111; }
        .feature-desc { font-size: 14px; color: #666; line-height: 1.5; }
        
        /* Footer */
        footer { background: #111; color: #fff; text-align: center; padding: 30px 20px; font-size: 14px; margin-top: auto; }
        
        /* Responsive */
        @media (max-width: 768px) {
            .features-grid { grid-template-columns: 1fr; }
            .hero h1 { font-size: 32px; }
            nav { flex-direction: column; gap: 15px; }
        }
    </style>
</head>
<body>

<nav>
    <a href="index.jsp" class="logo">ShopWeb</a>
    <div class="menu">
        <a href="products">Sản phẩm</a>
        <a href="contact.jsp">Liên Hệ</a>
        <a href="<%= request.getContextPath() %>/orders">Đơn hàng</a>
        <%-- Logic kiểm tra Session đăng nhập --%>
        <% if (session.getAttribute("loggedInUser") != null) { %>
            <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
        <% } else { %>
            <a href="login.jsp">Đăng nhập</a>
            <a href="register.jsp">Đăng ký</a>
        <% } %>

        <%-- Icon giỏ hàng — badge số lượng được cập nhật từ localStorage --%>
        <a href="cart.jsp" class="cart-link" title="Giỏ hàng">
            🛒
            <span class="cart-badge" id="cartBadge">0</span>
        </a>
    </div>
</nav>

<header class="hero">
    <h1>Khám Phá Phong Cách Mới</h1>
    <p>Cập nhật tủ đồ của bạn với những bộ sưu tập thời trang xu hướng nhất năm nay. Chất lượng cao cấp, thiết kế hiện đại và giá cả hợp lý.</p>
    <a href="products" class="btn-shop">Mua Sắm Ngay</a>
</header>

<div class="container">
    
    <h2 class="section-title">Danh Mục Nổi Bật</h2>
    <div class="category-grid">
        <div class="category-card" onclick="window.location.href='<%= request.getContextPath() %>/products?category=%C3%81o%20Nam'">
            <img src="https://images.unsplash.com/photo-1516257984-b1b4d707412e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Áo Nam" class="category-img">
            <div class="category-name">Áo Nam</div>
        </div>
        <div class="category-card" onclick="window.location.href='<%= request.getContextPath() %>/products?category=Qu%E1%BA%A7n%20Nam'">
            <img src="https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcTxEWNKYjUbMqhb_CiVqpcX8kyFeug-lzsS6n9uIoDNeWZfFBjJjJPNdnulLCBASF3BqsxtCXQ9y9spRY5iq_dYHWJmrS9PY9mrMYS7dqCsjzLMIwxNM7gvcw" alt="Quần Nam" class="category-img">
            <div class="category-name">Quần Nam</div>
        </div>
        <div class="category-card" onclick="window.location.href='<%= request.getContextPath() %>/products?category=Ph%E1%BB%A5%20Ki%E1%BB%87n'">
            <img src="https://images.unsplash.com/photo-1523206489230-c012c64b2b48?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60" alt="Phụ Kiện" class="category-img">
            <div class="category-name">Phụ Kiện</div>
        </div>
    </div>

    <div class="features-grid">
        <div class="feature-item">
            <div class="feature-icon">🚚</div>
            <div class="feature-title">Giao Hàng Nhanh</div>
            <div class="feature-desc">Miễn phí giao hàng cho đơn từ 500.000đ trên toàn quốc.</div>
        </div>
        <div class="feature-item">
            <div class="feature-icon">🔄</div>
            <div class="feature-title">Đổi Trả Dễ Dàng</div>
            <div class="feature-desc">Hỗ trợ đổi size hoặc trả hàng trong vòng 7 ngày nếu có lỗi.</div>
        </div>
        <div class="feature-item">
            <div class="feature-icon">🎧</div>
            <div class="feature-title">Hỗ Trợ 24/7</div>
            <div class="feature-desc">Đội ngũ chăm sóc khách hàng luôn sẵn sàng giải đáp thắc mắc.</div>
        </div>
    </div>

</div>

<footer>
    <p>© 2026 ShopWeb. All rights reserved.</p>
    <p style="margin-top: 10px; color: #888; font-size: 12px;">Đồ án thiết kế website bán quần áo</p>
</footer>

<script>
    // ===== Đọc số lượng sản phẩm trong giỏ từ server session =====
    function updateCartBadge() {
        fetch('<%= request.getContextPath() %>/cart?action=count')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var badge = document.getElementById('cartBadge');
                if (data.count > 0) {
                    badge.textContent = data.count > 99 ? '99+' : data.count;
                    badge.style.display = 'flex';
                } else {
                    badge.style.display = 'none';
                }
            })
            .catch(function() {
                document.getElementById('cartBadge').style.display = 'none';
            });
    }

    updateCartBadge();
</script>

</body>
</html>
