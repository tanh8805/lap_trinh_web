package com.example.shopweb.dao;

import com.example.shopweb.model.AdminOrder;
import com.example.shopweb.model.AdminOrderItem;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminOrderDAO {

    public List<AdminOrder> getOrders(String keyword, String statusFilter, int page, int pageSize) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder(
                "SELECT o.id, o.user_id, u.username, o.order_date, o.total_amount, o.shipping_fee, o.status, o.address, "
                        +
                        "COALESCE(oi_stats.item_count, 0) AS item_count " +
                        "FROM orders o " +
                        "LEFT JOIN users u ON o.user_id = u.id " +
                        "LEFT JOIN (" +
                        "   SELECT order_id, SUM(quantity) AS item_count " +
                        "   FROM order_items GROUP BY order_id" +
                        ") oi_stats ON oi_stats.order_id = o.id ");

        List<Object> params = new ArrayList<>();
        appendWhereClause(sql, params, keyword, statusFilter);
        sql.append(" ORDER BY o.order_date DESC, o.id DESC LIMIT ? OFFSET ?");
        params.add(safePageSize);
        params.add(offset);

        return fetchOrders(sql.toString(), params);
    }

    public int countOrders(String keyword, String statusFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM orders o LEFT JOIN users u ON o.user_id = u.id ");

        List<Object> params = new ArrayList<>();
        appendWhereClause(sql, params, keyword, statusFilter);

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public AdminOrder getOrderById(int orderId) {
        String sql = "SELECT o.id, o.user_id, u.username, o.order_date, o.total_amount, o.shipping_fee, o.status, o.address, "
                +
                "COALESCE(oi_stats.item_count, 0) AS item_count " +
                "FROM orders o " +
                "LEFT JOIN users u ON o.user_id = u.id " +
                "LEFT JOIN (" +
                "   SELECT order_id, SUM(quantity) AS item_count " +
                "   FROM order_items GROUP BY order_id" +
                ") oi_stats ON oi_stats.order_id = o.id " +
                "WHERE o.id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAdminOrder(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<AdminOrderItem> getOrderItemsByOrderId(int orderId) {
        String sql = "SELECT oi.order_id, oi.variant_id, oi.quantity, oi.price, (oi.quantity * oi.price) AS line_total, "
                +
                "p.name AS product_name " +
                "FROM order_items oi " +
                "LEFT JOIN product_variants pv ON oi.variant_id = pv.id " +
                "LEFT JOIN products p ON pv.product_id = p.id " +
                "WHERE oi.order_id = ? ORDER BY oi.id ASC";

        List<AdminOrderItem> items = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminOrderItem item = new AdminOrderItem();
                    item.setOrderId(rs.getInt("order_id"));
                    item.setVariantId(rs.getInt("variant_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setPrice(rs.getDouble("price"));
                    item.setLineTotal(rs.getDouble("line_total"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    public boolean updateOrderStatusIfEditable(int orderId, String newStatus) {
        String sql = "UPDATE orders SET status = ? WHERE id = ? AND status NOT IN (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            ps.setString(3, "Đã giao");
            ps.setString(4, "Đã huỷ");
            ps.setString(5, "Đã hủy");
            ps.setString(6, "Giao thành công");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private List<AdminOrder> fetchOrders(String sql, List<Object> params) {
        List<AdminOrder> orders = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapAdminOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orders;
    }

    private void appendWhereClause(StringBuilder sql, List<Object> params, String keyword, String statusFilter) {
        List<String> clauses = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String likeKeyword = "%" + keyword.trim() + "%";
            clauses.add("(CAST(o.id AS CHAR) LIKE ? OR u.username LIKE ?)");
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            switch (statusFilter) {
                case "Chờ duyệt":
                    clauses.add("o.status IN (?, ?, ?)");
                    params.add("Chờ duyệt");
                    params.add("Chờ xử lý");
                    params.add("PENDING");
                    break;
                case "Đang giao":
                    clauses.add("o.status IN (?, ?)");
                    params.add("Đang giao");
                    params.add("Đang giao hàng");
                    break;
                case "Đã giao":
                    clauses.add("o.status IN (?, ?, ?)");
                    params.add("Đã giao");
                    params.add("Giao thành công");
                    params.add("Hoàn thành");
                    break;
                case "Đã huỷ":
                    clauses.add("o.status IN (?, ?)");
                    params.add("Đã huỷ");
                    params.add("Đã hủy");
                    break;
                default:
                    clauses.add("o.status = ?");
                    params.add(statusFilter);
                    break;
            }
        }

        if (!clauses.isEmpty()) {
            sql.append(" WHERE ").append(String.join(" AND ", clauses));
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                ps.setInt(i + 1, (Integer) value);
            } else {
                ps.setString(i + 1, String.valueOf(value));
            }
        }
    }

    private AdminOrder mapAdminOrder(ResultSet rs) throws SQLException {
        AdminOrder order = new AdminOrder();
        order.setId(rs.getInt("id"));
        order.setUserId(rs.getInt("user_id"));
        order.setUsername(rs.getString("username"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setShippingFee(rs.getDouble("shipping_fee"));
        order.setStatus(rs.getString("status"));
        order.setAddress(rs.getString("address"));
        order.setItemCount(rs.getInt("item_count"));
        return order;
    }
}
