<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.example.shopweb.model.AdminOrder" %>
<%@ page import="com.example.shopweb.model.AdminOrderItem" %>
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
%>
<%
    AdminOrder order = (AdminOrder) request.getAttribute("order");
    List<AdminOrderItem> items = (List<AdminOrderItem>) request.getAttribute("items");
    if (items == null) {
        items = Collections.emptyList();
    }

    String keyword = (String) request.getAttribute("keyword");
    String selectedStatusCode = (String) request.getAttribute("selectedStatusCode");
    Integer pageObj = (Integer) request.getAttribute("page");

    if (keyword == null) keyword = "";
    if (selectedStatusCode == null) selectedStatusCode = "";
    int currentPage = pageObj == null ? 1 : pageObj;

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    DecimalFormat moneyFormat = new DecimalFormat("#,##0");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết đơn hàng</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #ecf0f1; }
        .container { max-width: 1100px; margin: 20px auto; padding: 0 12px; }
        .card { background: #fff; border-radius: 6px; padding: 18px; box-shadow: 0 1px 2px rgba(0,0,0,.08); margin-bottom: 14px; }
        .title { margin: 0 0 10px; }
        .row { display: flex; flex-wrap: wrap; gap: 16px; }
        .meta { min-width: 220px; }
        .meta .label { color: #777; font-size: 13px; }
        .meta .value { font-weight: 600; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #e2e2e2; padding: 10px; text-align: left; }
        th { background: #f8f9fa; }
        .btn { display: inline-block; padding: 8px 12px; border-radius: 4px; text-decoration: none; background: #2c3e50; color: #fff; }
        .btn:hover { background: #1f2d3a; }
        .empty { padding: 20px; text-align: center; color: #666; background: #fafafa; border: 1px dashed #ddd; }
    </style>
</head>
<body>
<div class="container">
    <div class="card">
        <h3 class="title">Chi tiết đơn hàng #<%= order == null ? "" : order.getId() %></h3>
        <% if (order != null) { %>
            <div class="row">
                <div class="meta">
                    <div class="label">Khách hàng</div>
                    <div class="value"><%= esc(order.getUsername()) %> (ID: <%= order.getUserId() %>)</div>
                </div>
                <div class="meta">
                    <div class="label">Ngày đặt</div>
                    <div class="value"><%= order.getOrderDate() == null ? "" : dateFormat.format(order.getOrderDate()) %></div>
                </div>
                <div class="meta">
                    <div class="label">Trạng thái</div>
                    <div class="value"><%= esc(order.getStatus()) %></div>
                </div>
                <div class="meta">
                    <div class="label">Số lượng sản phẩm</div>
                    <div class="value"><%= order.getItemCount() %></div>
                </div>
                <div class="meta">
                    <div class="label">Tổng tiền</div>
                    <div class="value"><%= moneyFormat.format(order.getTotalAmount()) %> VND</div>
                </div>
                <div class="meta">
                    <div class="label">Phí ship</div>
                    <div class="value"><%= moneyFormat.format(order.getShippingFee()) %> VND</div>
                </div>
                <div class="meta" style="flex: 1; min-width: 320px;">
                    <div class="label">Địa chỉ</div>
                    <div class="value"><%= esc(order.getAddress()) %></div>
                </div>
            </div>
        <% } %>
    </div>

    <div class="card">
        <h4>Danh sách sản phẩm trong đơn</h4>
        <% if (items.isEmpty()) { %>
            <div class="empty">Đơn hàng chưa có sản phẩm.</div>
        <% } else { %>
            <table>
                <thead>
                <tr>
                    <th>Tên sản phẩm</th>
                    <th>Số lượng</th>
                    <th>Đơn giá</th>
                    <th>Thành tiền</th>
                </tr>
                </thead>
                <tbody>
                <% for (AdminOrderItem item : items) { %>
                    <tr>
                        <td><%= esc(item.getProductName() == null ? "Không xác định" : item.getProductName()) %></td>
                        <td><%= item.getQuantity() %></td>
                        <td><%= moneyFormat.format(item.getPrice()) %> VND</td>
                        <td><%= moneyFormat.format(item.getLineTotal()) %> VND</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </div>

    <a class="btn" href="<%= request.getContextPath() %>/manage.jsp?keyword=<%= enc(keyword) %>&status=<%= enc(selectedStatusCode) %>&page=<%= currentPage %>">Quay lại danh sách</a>
</div>
</body>
</html>
