<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.example.shopweb.model.AdminOrder" %>
<%@ page import="com.example.shopweb.model.CustomerOrderItem" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn hàng của tôi - ShopWeb</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f7f8fa;
            color: #222;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        nav {
            background: #ffffff;
            padding: 15px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            letter-spacing: 1px;
            color: #000;
            text-decoration: none;
        }
        .menu { display: flex; align-items: center; }
        .menu a {
            margin-left: 25px;
            text-decoration: none;
            color: #555;
            font-weight: 500;
            transition: color 0.3s;
        }
        .menu a:hover, .menu a.active { color: #000; }

        .page-title {
            max-width: 1200px;
            width: 100%;
            margin: 30px auto 20px;
            padding: 0 20px;
        }
        .page-title h1 {
            font-size: 30px;
            color: #111;
            margin-bottom: 8px;
        }
        .page-title p {
            color: #666;
            font-size: 14px;
        }

        .container {
            max-width: 1200px;
            width: 100%;
            margin: 0 auto 50px;
            padding: 0 20px;
            flex: 1;
        }

        .order-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.06);
            margin-bottom: 20px;
            overflow: hidden;
        }

        .order-head {
            padding: 16px 20px;
            border-bottom: 1px solid #ececec;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
        }

        .order-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: center;
        }

        .order-code {
            font-weight: 700;
            color: #111;
        }

        .order-date {
            color: #777;
            font-size: 14px;
        }

        .status-badge {
            font-size: 12px;
            font-weight: 700;
            padding: 6px 10px;
            border-radius: 999px;
            display: inline-block;
        }

        .status-pending { background: #fff3cd; color: #856404; }
        .status-shipping { background: #d1ecf1; color: #0c5460; }
        .status-delivered { background: #d4edda; color: #155724; }
        .status-cancelled { background: #f8d7da; color: #721c24; }
        .status-default { background: #e9ecef; color: #495057; }

        .order-info {
            padding: 14px 20px;
            font-size: 14px;
            color: #555;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 8px 20px;
            border-bottom: 1px solid #ececec;
        }

        .order-info strong { color: #222; }

        .table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 720px;
        }

        th, td {
            padding: 12px 16px;
            text-align: left;
            border-bottom: 1px solid #f0f0f0;
            font-size: 14px;
        }

        th {
            background: #fafafa;
            color: #444;
            font-weight: 700;
        }

        td.text-right { text-align: right; }

        .order-total {
            padding: 12px 20px 16px;
            text-align: right;
            font-weight: 700;
            font-size: 15px;
            color: #111;
        }

        .empty {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.06);
            text-align: center;
            padding: 50px 20px;
        }

        .empty p { color: #666; margin-bottom: 15px; }

        .btn-shop {
            display: inline-block;
            padding: 10px 16px;
            border-radius: 8px;
            background: #111;
            color: #fff;
            text-decoration: none;
            font-weight: 600;
        }

        footer {
            margin-top: auto;
            background: #111;
            color: #fff;
            text-align: center;
            padding: 24px 20px;
            font-size: 14px;
        }

        @media (max-width: 768px) {
            nav {
                flex-direction: column;
                gap: 15px;
                padding: 15px 20px;
            }

            .menu {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
            }

            .menu a {
                margin: 6px 12px;
            }

            .page-title h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
<%
    String contextPath = request.getContextPath();
    List<AdminOrder> orders = (List<AdminOrder>) request.getAttribute("orders");
    Map<Integer, List<CustomerOrderItem>> orderItemsMap =
            (Map<Integer, List<CustomerOrderItem>>) request.getAttribute("orderItemsMap");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<nav>
    <a href="<%= contextPath %>/index.jsp" class="logo">ShopWeb</a>
    <div class="menu">
        <a href="<%= contextPath %>/products">Sản phẩm</a>
        <a href="<%= contextPath %>/contact.jsp">Liên hệ</a>
        <a href="<%= contextPath %>/orders" class="active">Đơn hàng</a>
        <a href="<%= contextPath %>/cart">Giỏ hàng</a>
        <a href="<%= contextPath %>/logout">Đăng xuất</a>
    </div>
</nav>

<div class="page-title">
    <h1>Đơn hàng của tôi</h1>
    <p>Theo dõi trạng thái đơn hàng và xem chi tiết sản phẩm trong từng đơn.</p>
</div>

<div class="container">
    <% if (orders == null || orders.isEmpty()) { %>
        <div class="empty">
            <p>Bạn chưa có đơn hàng nào.</p>
            <a href="<%= contextPath %>/products" class="btn-shop">Mua sắm ngay</a>
        </div>
    <% } else { %>
        <% for (AdminOrder order : orders) {
            String status = order.getStatus() != null ? order.getStatus() : "";
            String badgeClass = "status-default";
            if ("Chờ duyệt".equals(status)) {
                badgeClass = "status-pending";
            } else if ("Đang giao".equals(status)) {
                badgeClass = "status-shipping";
            } else if ("Đã giao".equals(status)) {
                badgeClass = "status-delivered";
            } else if ("Đã huỷ".equals(status)) {
                badgeClass = "status-cancelled";
            }
            List<CustomerOrderItem> items = orderItemsMap != null ? orderItemsMap.get(order.getId()) : null;
        %>
            <div class="order-card">
                <div class="order-head">
                    <div class="order-meta">
                        <span class="order-code">Mã đơn: #<%= order.getId() %></span>
                        <span class="order-date">
                            Đặt lúc: <%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "-" %>
                        </span>
                    </div>
                    <span class="status-badge <%= badgeClass %>"><%= status %></span>
                </div>

                <div class="order-info">
                    <div><strong>Số sản phẩm:</strong> <%= order.getItemCount() %></div>
                    <div><strong>Phí vận chuyển:</strong> <%= String.format("%,.0f", order.getShippingFee()) %> đ</div>
                    <div><strong>Địa chỉ:</strong> <%= order.getAddress() != null ? order.getAddress() : "-" %></div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>Size</th>
                                <th>Số lượng</th>
                                <th class="text-right">Đơn giá</th>
                                <th class="text-right">Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (items == null || items.isEmpty()) { %>
                                <tr>
                                    <td colspan="5">Không có dữ liệu chi tiết sản phẩm.</td>
                                </tr>
                            <% } else {
                                for (CustomerOrderItem item : items) { %>
                                    <tr>
                                        <td><%= item.getProductName() != null ? item.getProductName() : "Sản phẩm" %></td>
                                        <td><%= item.getSize() != null && !item.getSize().isEmpty() ? item.getSize() : "-" %></td>
                                        <td><%= item.getQuantity() %></td>
                                        <td class="text-right"><%= String.format("%,.0f", item.getPrice()) %> đ</td>
                                        <td class="text-right"><%= String.format("%,.0f", item.getLineTotal()) %> đ</td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>

                <div class="order-total">
                    Tổng đơn: <%= String.format("%,.0f", order.getTotalAmount()) %> đ
                </div>
            </div>
        <% } %>
    <% } %>
</div>

<footer>
    <p>© 2026 ShopWeb. All rights reserved.</p>
</footer>
</body>
</html>
