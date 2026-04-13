<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopWeb - Đăng ký</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f6f8;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .auth-card {
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            width: 100%;
            max-width: 400px;
            text-align: center;
        }
        .auth-card h2 {
            margin-bottom: 30px;
            color: #222;
            font-size: 26px;
        }
        .form-group { 
            margin-bottom: 18px; 
            text-align: left; 
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 15px;
            transition: border-color 0.3s;
        }
        .form-group input:focus {
            border-color: #000;
            outline: none;
        }
        .btn-submit {
            width: 100%;
            padding: 14px;
            background: #000;
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 15px;
            transition: background 0.3s;
        }
        .btn-submit:hover { background: #333; }
        .auth-links { 
            margin-top: 25px; 
            font-size: 14px; 
            color: #666;
        }
        .auth-links a { 
            color: #000; 
            font-weight: bold;
            text-decoration: none; 
        }
        .auth-links a:hover { text-decoration: underline; }
        .back-home { 
            display: inline-block; 
            margin-top: 20px; 
            color: #888; 
            font-size: 14px; 
            text-decoration: none; 
            transition: color 0.3s;
        }
        .back-home:hover { color: #000; }
        .alert-error {
            color: #721c24; 
            background-color: #f8d7da; 
            padding: 10px; 
            border-radius: 5px; 
            margin-bottom: 20px; 
            font-size: 14px;
            text-align: left;
        }
    </style>
</head>
<body>

<div class="auth-card">
    <h2>Tạo tài khoản mới</h2>
    
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert-error">
            <%= request.getAttribute("error") %>
        </div>
    <% } %>

    <form action="register" method="post">
        <div class="form-group">
            <label for="username">Tên đăng nhập</label>
            <%-- Giữ lại giá trị username nếu form bị lỗi --%>
            <input type="text" id="username" name="username" placeholder="Nhập username..." 
                   value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>" required>
        </div>
        <div class="form-group">
            <label for="email">Email</label>
            <%-- Giữ lại giá trị email nếu form bị lỗi --%>
            <input type="email" id="email" name="email" placeholder="example@gmail.com" 
                   value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
        </div>
        <div class="form-group">
            <label for="password">Mật khẩu</label>
            <input type="password" id="password" name="password" placeholder="Tạo mật khẩu..." required>
        </div>
        <%-- Thêm ô Xác nhận mật khẩu để đồng bộ với đoạn request.getParameter("confirmPassword") trong Servlet --%>
        <div class="form-group">
            <label for="confirmPassword">Xác nhận mật khẩu</label>
            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu..." required>
        </div>
        
        <button type="submit" class="btn-submit">Đăng ký</button>
    </form>
    
    <div class="auth-links">
        Đã có tài khoản? <a href="login.jsp">Đăng nhập</a>
    </div>
    <a href="index.jsp" class="back-home">&larr; Quay lại trang chủ</a>
</div>

</body>
</html>