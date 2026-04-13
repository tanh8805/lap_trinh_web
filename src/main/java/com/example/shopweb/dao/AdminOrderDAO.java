package com.example.shopweb.dao;

import com.example.shopweb.model.AdminOrder;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AdminOrderDAO {

    public List<AdminOrder> getAllOrders() {
        String sql = "SELECT o.id, o.user_id, u.username, o.order_date, o.total_amount, o.shipping_fee, o.status, o.address "
                +
                "FROM orders o LEFT JOIN users u ON o.user_id = u.id ORDER BY o.order_date DESC, o.id DESC";
        return fetchOrders(sql, Collections.emptyList());
    }

    public List<AdminOrder> getOrders(String keyword, String statusFilter, int page, int pageSize) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder(
                "SELECT o.id, o.user_id, u.username, o.order_date, o.total_amount, o.shipping_fee, o.status, o.address "
                        +
                        "FROM orders o LEFT JOIN users u ON o.user_id = u.id ");

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

    public List<AdminOrder> getOrdersByStatus(String status) {
        String sql = "SELECT o.id, o.user_id, u.username, o.order_date, o.total_amount, o.shipping_fee, o.status, o.address "
                +
                "FROM orders o LEFT JOIN users u ON o.user_id = u.id " +
                "WHERE o.status = ? ORDER BY o.order_date DESC, o.id DESC";
        return fetchOrders(sql, status);
    }

    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private List<AdminOrder> fetchOrders(String sql, String status) {
        if (status == null) {
            return fetchOrders(sql, Collections.emptyList());
        }

        List<Object> params = new ArrayList<>();
        params.add(status);
        return fetchOrders(sql, params);
    }

    private List<AdminOrder> fetchOrders(String sql, List<Object> params) {
        List<AdminOrder> orders = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminOrder order = new AdminOrder();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setUsername(rs.getString("username"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setShippingFee(rs.getDouble("shipping_fee"));
                    order.setStatus(rs.getString("status"));
                    order.setAddress(rs.getString("address"));
                    orders.add(order);
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
                case "Giao thành công":
                    clauses.add("o.status IN (?, ?)");
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
}
