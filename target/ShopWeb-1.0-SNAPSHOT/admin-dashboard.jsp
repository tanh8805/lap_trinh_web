<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
        }

        .container {
            display: flex;
            height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: 250px;
            background-color: #2c3e50;
            color: white;
            padding-top: 20px;
        }

        .sidebar a {
            display: block;
            padding: 12px 20px;
            color: white;
            text-decoration: none;
        }

        .sidebar a:hover {
            background-color: #34495e;
        }

        .dropdown {
            padding-left: 10px;
        }

        .dropdown a {
            padding-left: 30px;
            font-size: 14px;
        }

        /* Main */
        .main {
            flex: 1;
            background-color: #ecf0f1;
        }

        /* Header */
        .header {
            height: 60px;
            background-color: #fff;
            display: flex;
            align-items: center;
            padding: 0 20px;
            justify-content: space-between;
            border-bottom: 1px solid #ddd;
        }

        .logout-btn {
            background-color: #e74c3c;
            color: white;
            padding: 8px 16px;
            border: none;
            cursor: pointer;
        }

        .logout-btn:hover {
            background-color: #c0392b;
        }

        /* Content */
        .content {
            padding: 20px;
        }

        .card {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
    </style>

    <script>
        function toggleDropdown() {
            var dropdown = document.getElementById("orderDropdown");
            dropdown.style.display =
                dropdown.style.display === "block" ? "none" : "block";
        }
    </script>
</head>
<body>

<div class="container">

    <!-- Sidebar -->
    <div class="sidebar">
        <a href="<%= request.getContextPath() %>/index.jsp">🏠 Trang người dùng</a>

        <a href="<%= request.getContextPath() %>/manage-products.jsp">📦 Quản lý sản phẩm</a>

        <a href="javascript:void(0)" onclick="toggleDropdown()">
            🧾 Quản lý đơn hàng ▼
        </a>

        <div id="orderDropdown" class="dropdown" style="display:none;">
            <a href="<%= request.getContextPath() %>/orders/all-products.jsp">Tất cả đơn</a>
            <a href="<%= request.getContextPath() %>/orders/process-products.jsp">Đang xử lý</a>
            <a href="<%= request.getContextPath() %>/orders/done-products.jsp">Hoàn thành</a>
        </div>
    </div>

    <div class="main">

        <div class="header">
            <h3>Admin Dashboard</h3>

            <form action="<%= request.getContextPath() %>/logout" method="get">
                <button class="logout-btn">Logout</button>
            </form>
        </div>
    </div>

</div>

</body>
</html>