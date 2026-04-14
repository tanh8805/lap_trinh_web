<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.example.shopweb.model.AdminOrder" %>
<%!
    private String esc(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String enc(String value) {
        if (value == null) {
            return "";
        }
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildQuery(String keyword, String status, int page) {
        StringBuilder query = new StringBuilder("?page=").append(page);
        if (keyword != null && !keyword.trim().isEmpty()) {
            query.append("&keyword=").append(enc(keyword.trim()));
        }
        if (status != null && !status.trim().isEmpty()) {
            query.append("&status=").append(enc(status.trim()));
        }
        return query.toString();
    }

    private String statusCode(String status) {
        if (status == null) {
            return "";
        }

        switch (status.trim()) {
            case "Chờ duyệt":
            case "Chờ xử lý":
            case "PENDING":
                return "PENDING_REVIEW";
            case "Đang xử lý":
                return "PROCESSING";
            case "Đang giao":
            case "Đang giao hàng":
                return "SHIPPING";
            case "Đã giao":
            case "Hoàn thành":
            case "Giao thành công":
                return "DELIVERED";
            case "Đã huỷ":
            case "Đã hủy":
                return "CANCELLED";
            default:
                return "";
        }
    }

    private boolean isLockedStatus(String status) {
        String code = statusCode(status);
        return "DELIVERED".equals(code) || "CANCELLED".equals(code);
    }
%>
<%
    List<AdminOrder> orders = (List<AdminOrder>) request.getAttribute("orders");
    if (orders == null) {
        orders = Collections.emptyList();
    }

    List<String> statusOptions = (List<String>) request.getAttribute("statusOptions");
    if (statusOptions == null) {
        statusOptions = Collections.emptyList();
    }

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatusCode = (String) request.getAttribute("selectedStatusCode");

    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    Integer totalOrdersObj = (Integer) request.getAttribute("totalOrders");
    Integer startItemObj = (Integer) request.getAttribute("startItem");
    Integer endItemObj = (Integer) request.getAttribute("endItem");

    int currentPage = currentPageObj == null ? 1 : currentPageObj;
    int totalPages = totalPagesObj == null ? 1 : totalPagesObj;
    int totalOrders = totalOrdersObj == null ? 0 : totalOrdersObj;
    int startItem = startItemObj == null ? 0 : startItemObj;
    int endItem = endItemObj == null ? 0 : endItemObj;

    if (keyword == null) {
        keyword = "";
    }
    if (selectedStatusCode == null) {
        selectedStatusCode = "";
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    DecimalFormat moneyFormat = new DecimalFormat("#,##0");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý đơn hàng</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; }
        .container { display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #2c3e50; color: #fff; padding-top: 20px; }
        .sidebar a { display: block; padding: 12px 20px; color: #fff; text-decoration: none; }
        .sidebar a:hover, .sidebar a.active { background-color: #34495e; }
        .main { flex: 1; background: #ecf0f1; }
        .header { min-height: 60px; background: #fff; border-bottom: 1px solid #ddd; padding: 0 20px; display: flex; align-items: center; }
        .content { padding: 20px; }
        .card { background: #fff; border-radius: 6px; padding: 18px; box-shadow: 0 1px 2px rgba(0,0,0,.08); }

        .filter-form { display: flex; gap: 10px; align-items: end; flex-wrap: wrap; margin-bottom: 12px; }
        .filter-group { display: flex; flex-direction: column; gap: 4px; }
        .filter-group label { font-size: 13px; color: #555; }
        .filter-group input, .filter-group select { min-width: 190px; padding: 8px 10px; border: 1px solid #ccd2d9; border-radius: 4px; }
        .btn { padding: 8px 12px; border: none; border-radius: 4px; background: #2c3e50; color: #fff; cursor: pointer; text-decoration: none; font-size: 14px; }
        .btn:hover { background: #1f2d3a; }
        .btn.secondary { background: #7f8c8d; }
        .btn.secondary:hover { background: #636e72; }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; background: #fff; }
        th, td { border: 1px solid #e2e2e2; padding: 10px; text-align: left; vertical-align: top; }
        th { background: #f8f9fa; }
        .muted { color: #666; font-size: 13px; }
        .empty { padding: 20px; text-align: center; color: #666; background: #fafafa; border: 1px dashed #ddd; }

        .alert { padding: 10px 12px; border-radius: 4px; margin-bottom: 12px; font-size: 14px; }
        .alert.success { background: #eaf7ed; border: 1px solid #b7dfc2; color: #2e7d32; }
        .alert.error { background: #fdecec; border: 1px solid #f4b8b8; color: #c62828; }

        .status-form { display: flex; gap: 6px; align-items: center; }
        .status-form select { min-width: 130px; padding: 4px 8px; border: 1px solid #ccc; border-radius: 4px; }
        .save-btn { display: none; padding: 4px 10px; border: none; border-radius: 4px; background: #2c3e50; color: #fff; cursor: pointer; }
        .save-btn:hover { background: #1f2d3a; }
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 999px; font-size: 12px; background: #eceff1; color: #455a64; }

        .pagination { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 14px; align-items: center; }
        .page-link { display: inline-block; padding: 6px 10px; border: 1px solid #ccd2d9; border-radius: 4px; text-decoration: none; color: #2c3e50; background: #fff; }
        .page-link.active { background: #2c3e50; color: #fff; border-color: #2c3e50; }
    </style>
</head>
<body>
<div class="container">
    <div class="sidebar">
        <a href="<%= request.getContextPath() %>/index.jsp">Trang người dùng</a>
        <a href="<%= request.getContextPath() %>/manage-products.jsp">Quản lý sản phẩm</a>
        <a href="<%= request.getContextPath() %>/manage.jsp" class="active">Quản lý đơn hàng</a>
    </div>

    <div class="main">
        <div class="header">
            <h3>Quản lý đơn hàng</h3>
        </div>

        <div class="content">
            <div class="card">
                <% if (success != null && !success.isEmpty()) { %>
                    <div class="alert success"><%= esc(success) %></div>
                <% } %>
                <% if (error != null && !error.isEmpty()) { %>
                    <div class="alert error"><%= esc(error) %></div>
                <% } %>

                <form method="get" action="<%= request.getContextPath() %>/manage.jsp" class="filter-form">
                    <div class="filter-group">
                        <label for="keyword">Tìm theo ID hoặc tên</label>
                        <input id="keyword" name="keyword" type="text" value="<%= esc(keyword) %>" placeholder="Ví dụ: 12 hoặc admin">
                    </div>

                    <div class="filter-group">
                        <label for="status">Lọc trạng thái</label>
                        <select id="status" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <% for (String status : statusOptions) { %>
                                <option value="<%= statusCode(status) %>" <%= statusCode(status).equals(selectedStatusCode) ? "selected" : "" %>><%= esc(status) %></option>
                            <% } %>
                        </select>
                    </div>

                    <button class="btn" type="submit">Tìm kiếm</button>
                    <a class="btn secondary" href="<%= request.getContextPath() %>/manage.jsp">Xóa lọc</a>
                </form>

                <div class="muted">
                    Tổng số đơn: <strong><%= totalOrders %></strong>
                    <% if (totalOrders > 0) { %>
                        | Hiển thị <strong><%= startItem %></strong> - <strong><%= endItem %></strong>
                    <% } %>
                </div>

                <% if (orders.isEmpty()) { %>
                    <div class="empty">Không có đơn hàng nào.</div>
                <% } else { %>
                    <table>
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>User ID</th>
                            <th>Username</th>
                            <th>Ngày đặt</th>
                            <th>Số lượng SP</th>
                            <th>Tổng tiền</th>
                            <th>Phí ship</th>
                            <th>Địa chỉ</th>
                            <th>Trạng thái</th>
                            <th>Chi tiết</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (AdminOrder order : orders) { %>
                            <tr>
                                <td><%= order.getId() %></td>
                                <td><%= order.getUserId() %></td>
                                <td><%= esc(order.getUsername()) %></td>
                                <td><%= order.getOrderDate() == null ? "" : dateFormat.format(order.getOrderDate()) %></td>
                                <td><%= order.getItemCount() %></td>
                                <td><%= moneyFormat.format(order.getTotalAmount()) %> VND</td>
                                <td><%= moneyFormat.format(order.getShippingFee()) %> VND</td>
                                <td><%= esc(order.getAddress()) %></td>
                                <td>
                                    <% if (isLockedStatus(order.getStatus())) { %>
                                        <span class="status-badge"><%= esc(order.getStatus()) %></span>
                                    <% } else { %>
                                        <form method="post" action="<%= request.getContextPath() %>/manage.jsp" class="status-form">
                                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                                            <input type="hidden" name="keyword" value="<%= esc(keyword) %>">
                                            <input type="hidden" name="statusFilter" value="<%= esc(selectedStatusCode) %>">
                                            <input type="hidden" name="page" value="<%= currentPage %>">

                                            <select name="status" class="status-select" data-original="<%= statusCode(order.getStatus()) %>">
                                                <% for (String status : statusOptions) { %>
                                                    <option value="<%= statusCode(status) %>" <%= statusCode(status).equals(statusCode(order.getStatus())) ? "selected" : "" %>><%= esc(status) %></option>
                                                <% } %>
                                            </select>
                                            <button type="submit" class="save-btn">Lưu</button>
                                        </form>
                                    <% } %>
                                </td>
                                <td>
                                    <a class="btn" href="<%= request.getContextPath() %>/manage.jsp?detailId=<%= order.getId() %>&keyword=<%= enc(keyword) %>&status=<%= enc(selectedStatusCode) %>&page=<%= currentPage %>">Xem</a>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>

                    <% if (totalPages > 1) { %>
                        <div class="pagination">
                            <% if (currentPage > 1) { %>
                                <a class="page-link" href="<%= request.getContextPath() %>/manage.jsp<%= buildQuery(keyword, selectedStatusCode, currentPage - 1) %>">Trước</a>
                            <% } %>

                            <% for (int i = 1; i <= totalPages; i++) { %>
                                <a class="page-link <%= i == currentPage ? "active" : "" %>" href="<%= request.getContextPath() %>/manage.jsp<%= buildQuery(keyword, selectedStatusCode, i) %>"><%= i %></a>
                            <% } %>

                            <% if (currentPage < totalPages) { %>
                                <a class="page-link" href="<%= request.getContextPath() %>/manage.jsp<%= buildQuery(keyword, selectedStatusCode, currentPage + 1) %>">Sau</a>
                            <% } %>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script>
    (function () {
        var forms = document.querySelectorAll('.status-form');
        forms.forEach(function (form) {
            var select = form.querySelector('.status-select');
            var saveButton = form.querySelector('.save-btn');
            if (!select || !saveButton) {
                return;
            }

            var original = select.getAttribute('data-original') || '';
            var toggleButton = function () {
                saveButton.style.display = (select.value !== original) ? 'inline-block' : 'none';
            };

            select.addEventListener('change', toggleButton);
            toggleButton();
        });
    })();
</script>
</body>
</html>
