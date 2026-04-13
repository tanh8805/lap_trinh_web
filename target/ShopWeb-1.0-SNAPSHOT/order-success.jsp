<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt hàng thành công</title>
    <style>
        body {
            font-family: Arial;
            background: #f5f5f5;
            text-align: center;
            padding-top: 100px;
        }
        .box {
            background: white;
            padding: 40px;
            border-radius: 12px;
            width: 500px;
            margin: auto;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2a9d8f;
        }
        p {
            margin: 15px 0;
        }
        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 20px;
            background: black;
            color: white;
            text-decoration: none;
            border-radius: 8px;
        }
        .btn:hover {
            background: #333;
        }
    </style>
</head>
<body>

<div class="box">
    <h1>🎉 Đặt hàng thành công!</h1>
    <p>Cảm ơn bạn đã mua hàng.</p>
    <p>Đơn hàng của bạn đang được xử lý.</p>

    <a href="<%=request.getContextPath()%>/" class="btn">Về trang chủ</a>
    <a href="<%=request.getContextPath()%>/products" class="btn">Tiếp tục mua</a>
</div>

</body>
</html>