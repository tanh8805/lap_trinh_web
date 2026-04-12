<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopWeb - Giỏ hàng</title>
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
        .menu a.active { color: #000; font-weight: 700; }

        /* Icon giỏ hàng với badge */
        .cart-link {
            position: relative;
            margin-left: 25px;
            text-decoration: none;
            color: #000; /* active vì đang ở trang giỏ hàng */
            font-size: 22px;
            display: flex;
            align-items: center;
            transition: color 0.3s;
        }
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
            display: none;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
        }

        /* ===== MAIN CONTENT ===== */
        .container {
            flex: 1;
            max-width: 900px;
            margin: 60px auto;
            width: 100%;
            padding: 0 20px;
        }

        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: #111;
            margin-bottom: 40px;
            padding-bottom: 15px;
            border-bottom: 2px solid #eee;
        }

        /* ===== TRẠNG THÁI GIỎ TRỐNG ===== */
        .cart-empty {
            text-align: center;
            padding: 80px 20px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.04);
        }
        .cart-empty-icon {
            font-size: 72px;
            margin-bottom: 20px;
            display: block;
            opacity: 0.4;
        }
        .cart-empty h3 {
            font-size: 22px;
            color: #444;
            margin-bottom: 10px;
            font-weight: 600;
        }
        .cart-empty p {
            font-size: 15px;
            color: #999;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .btn-continue {
            display: inline-block;
            padding: 13px 35px;
            background: #000;
            color: #fff;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 600;
            font-size: 15px;
            transition: background 0.3s;
        }
        .btn-continue:hover { background: #333; }

        /* Footer */
        footer {
            background: #111; color: #fff;
            text-align: center; padding: 20px;
            font-size: 14px; margin-top: auto;
        }
    </style>
</head>
<body>

<nav>
    <a href="index.jsp" class="logo">ShopWeb</a>
    <div class="menu">
        <a href="products">Sản phẩm</a>

        <%-- Logic kiểm tra Session đăng nhập --%>
        <% if (session.getAttribute("loggedInUser") != null) { %>
            <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
        <% } else { %>
            <a href="login.jsp">Đăng nhập</a>
            <a href="register.jsp">Đăng ký</a>
        <% } %>

        <%-- Icon giỏ hàng — active vì đang ở trang này --%>
        <a href="cart.jsp" class="cart-link" title="Giỏ hàng">
<<<<<<< HEAD
            🛒
=======
            Giỏ hàng🛒
>>>>>>> origin/feature-add-to-cart-button
            <span class="cart-badge" id="cartBadge">0</span>
        </a>
    </div>
</nav>

<div class="container">
    <h2 class="page-title">Giỏ hàng của bạn</h2>

    <%-- Placeholder — chức năng giỏ hàng sẽ được phát triển sau --%>
    <div class="cart-empty">
        <span class="cart-empty-icon">🛒</span>
        <h3>Giỏ hàng đang trống</h3>
        <p>Bạn chưa thêm sản phẩm nào vào giỏ.<br>Hãy khám phá bộ sưu tập của chúng tôi!</p>
        <a href="products" class="btn-continue">Tiếp tục mua sắm</a>
    </div>
</div>

<footer>© 2026 ShopWeb. All rights reserved.</footer>

<script>
    // ===== Đọc số lượng giỏ hàng từ localStorage để cập nhật badge =====
    function updateCartBadge() {
        var badge = document.getElementById('cartBadge');
        try {
            var cart = JSON.parse(localStorage.getItem('shopweb_cart') || '[]');
            var totalQty = cart.reduce(function(sum, item) {
                return sum + (parseInt(item.quantity) || 0);
            }, 0);

            if (totalQty > 0) {
                badge.textContent = totalQty > 99 ? '99+' : totalQty;
                badge.style.display = 'flex';
            } else {
                badge.style.display = 'none';
            }
        } catch (e) {
            badge.style.display = 'none';
        }
    }

    updateCartBadge();
    window.addEventListener('storage', updateCartBadge);
</script>

</body>
</html>
