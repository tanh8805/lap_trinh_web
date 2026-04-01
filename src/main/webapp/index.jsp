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
        
        /* Navbar */
        nav {
            background: #ffffff;
            padding: 15px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            letter-spacing: 1px;
            color: #000;
        }
        .menu a {
            margin-left: 25px;
            text-decoration: none;
            color: #555;
            font-weight: 500;
            transition: color 0.3s;
        }
        .menu a:hover { color: #000; }
        
        /* Main Content */
        .container {
            flex: 1;
            padding: 60px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .hero {
            background: #fff;
            padding: 60px 40px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            text-align: center;
            max-width: 600px;
            width: 100%;
        }
        .hero h2 { font-size: 32px; margin-bottom: 15px; color: #111; }
        .hero p { color: #666; font-size: 18px; margin-bottom: 30px; line-height: 1.6; }
        .btn-shop {
            display: inline-block;
            padding: 12px 30px;
            background: #000;
            color: #fff;
            text-decoration: none;
            border-radius: 6px;
            font-weight: bold;
            transition: background 0.3s, transform 0.2s;
        }
        .btn-shop:hover { 
            background: #333; 
            transform: translateY(-2px);
        }
        
        /* Footer */
        footer {
            background: #111;
            color: #fff;
            text-align: center;
            padding: 20px;
            font-size: 14px;
        }
    </style>
</head>
<body>

<nav>
    <div class="logo">ShopWeb</div>
    <div class="menu">
        <a href="index.jsp">Trang chủ</a>
        <a href="login.jsp">Đăng nhập</a>
        <a href="register.jsp">Đăng ký</a>
    </div>
</nav>

<div class="container">
    <div class="hero">
        <h2>Khám Phá Phong Cách Của Bạn</h2>
        <p>Chào mừng đến với cửa hàng. Khám phá bộ sưu tập quần áo thời trang mới nhất với chất lượng và mức giá tốt nhất.</p>
        <a href="#" class="btn-shop">Xem Sản Phẩm</a>
    </div>
</div>

<footer>
    © 2026 ShopWeb. All rights reserved.
</footer>

</body>
</html>