<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Liên hệ</title>

    <style>
        body {
            font-family: Arial;
            margin: 0;
            background: #f5f5f5;
        }

        /* ===== NAVBAR ===== */
        nav {
            background: #fff;
            padding: 15px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .logo {
            font-size: 22px;
            font-weight: bold;
            text-decoration: none;
            color: black;
        }

        .menu a {
            margin-left: 25px;
            text-decoration: none;
            color: #555;
        }

        .menu a:hover {
            color: black;
        }

        /* ===== LAYOUT ===== */
        .container {
            width: 80%;
            margin: 40px auto;
            display: flex;
            gap: 50px;
        }

        .left, .right {
            background: #fff;
            padding: 25px;
            border-radius: 6px;
        }

        .left { flex: 2; }
        .right { flex: 1; }

        h2 { margin-bottom: 10px; }

        p.desc {
            color: #666;
            margin-bottom: 20px;
        }

        /* ===== FORM ===== */
        input, textarea {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .row {
            display: flex;
            gap: 15px;
        }

        .row input { flex: 1; }

        textarea {
            height: 120px;
            resize: none;
        }

        .btn-submit {
            padding: 12px 20px;
            background: #ccc;
            border: none;
            color: red;
            cursor: pointer;
        }

        .btn-submit:hover {
            background: #bbb;
        }

        /* ===== MESSAGE ===== */
        .msg-success {
            color: green;
            margin-bottom: 10px;
        }

        .msg-error {
            color: red;
            margin-bottom: 10px;
        }

        /* ===== RIGHT INFO ===== */
        .info-item {
            margin-bottom: 20px;
        }

        .info-title {
            font-weight: bold;
            margin-bottom: 5px;
        }

        .info-text {
            color: #555;
            font-size: 14px;
        }
    </style>
</head>

<body>

<!-- ===== NAVBAR ===== -->
<nav>
    <a href="index.jsp" class="logo">ShopWeb</a>

    <div class="menu">
        <a href="products">Sản phẩm</a>
        <a href="contact.jsp">Liên hệ</a>
        <a href="<%= request.getContextPath() %>/orders">Đơn hàng</a>

        <% if (session.getAttribute("loggedInUser") != null) { %>
            <a href="logout">Đăng xuất</a>
        <% } else { %>
            <a href="login.jsp">Đăng nhập</a>
            <a href="register.jsp">Đăng ký</a>
        <% } %>

        <a href="cart.jsp">🛒</a>
    </div>
</nav>

<!-- ===== CONTENT ===== -->
<div class="container">

    <!-- LEFT: FORM -->
    <div class="left">
        <h2>Gửi thắc mắc cho chúng tôi</h2>
        <p class="desc">
            Nếu bạn có thắc mắc gì, hãy gửi cho chúng tôi, chúng tôi sẽ phản hồi sớm nhất.
        </p>

        <!-- HIỂN THỊ THÔNG BÁO -->
        <% if (request.getAttribute("success") != null) { %>
            <p class="msg-success"><%= request.getAttribute("success") %></p>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
            <p class="msg-error"><%= request.getAttribute("error") %></p>
        <% } %>

        <!-- FORM -->
        <form action="contact" method="post">

            <input type="text" name="name" placeholder="Tên của bạn" required>

            <div class="row">
                <input type="email" name="email" placeholder="Email của bạn" required>
                <input type="text" name="phone" placeholder="Số điện thoại của bạn">
            </div>

            <textarea name="message" placeholder="Nội dung" required></textarea>

            <button type="submit" class="btn-submit">
                GỬI CHO CHÚNG TÔI
            </button>

        </form>
    </div>

    <!-- RIGHT: INFO -->
    <div class="right">
        <h2>Thông tin liên hệ</h2>

        <div class="info-item">
            <div class="info-title">📍 Địa chỉ</div>
            <div class="info-text">
                Tầng 8, tòa nhà Ford, số 313 Trường Chinh, Hà Nội
            </div>
        </div>

        <div class="info-item">
            <div class="info-title">📞 Điện thoại</div>
            <div class="info-text">0356.635.853</div>
        </div>

        <div class="info-item">
            <div class="info-title">⏰ Thời gian làm việc</div>
            <div class="info-text">
                Thứ 2 - Thứ 6: 8h30 - 18h<br/>
                Thứ 7: 8h30 - 12h00
            </div>
        </div>

        <div class="info-item">
            <div class="info-title">✉️ Email</div>
            <div class="info-text">cskh@shopweb.vn</div>
        </div>
    </div>

</div>

</body>
</html>