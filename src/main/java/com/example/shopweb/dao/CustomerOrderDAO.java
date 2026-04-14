package com.example.shopweb.dao;

import com.example.shopweb.model.AdminOrder;
import com.example.shopweb.model.CustomerOrderItem;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CustomerOrderDAO {

    public List<AdminOrder> getOrdersByUserId(int userId) {
        String sql = "SELECT o.id, o.user_id, o.order_date, o.total_amount, o.shipping_fee, o.status, o.address, " +
                "COALESCE(oi_stats.item_count, 0) AS item_count " +
                "FROM orders o " +
                "LEFT JOIN (" +
                "   SELECT order_id, SUM(quantity) AS item_count " +
                "   FROM order_items GROUP BY order_id" +
                ") oi_stats ON oi_stats.order_id = o.id " +
                "WHERE o.user_id = ? " +
                "ORDER BY o.order_date DESC, o.id DESC";

        List<AdminOrder> orders = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminOrder order = new AdminOrder();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setShippingFee(rs.getDouble("shipping_fee"));
                    order.setStatus(rs.getString("status"));
                    order.setAddress(rs.getString("address"));
                    order.setItemCount(rs.getInt("item_count"));
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orders;
    }

    public List<CustomerOrderItem> getOrderItemsByOrderId(int orderId) {
        String sqlVariant = "SELECT oi.order_id, oi.quantity, oi.price, (oi.quantity * oi.price) AS line_total, " +
                "p.name AS product_name, pv.size AS size " +
                "FROM order_items oi " +
                "LEFT JOIN product_variants pv ON oi.variant_id = pv.id " +
                "LEFT JOIN products p ON pv.product_id = p.id " +
                "WHERE oi.order_id = ? ORDER BY oi.id ASC";

        String sqlProduct = "SELECT oi.order_id, oi.quantity, oi.price, (oi.quantity * oi.price) AS line_total, " +
                "p.name AS product_name " +
                "FROM order_items oi " +
                "LEFT JOIN products p ON oi.product_id = p.id " +
                "WHERE oi.order_id = ? ORDER BY oi.id ASC";

        try {
            return fetchItems(orderId, sqlVariant, true);
        } catch (SQLException e) {
            if (e.getMessage() != null &&
                    (e.getMessage().contains("variant_id") || e.getMessage().contains("Unknown column"))) {
                try {
                    return fetchItems(orderId, sqlProduct, false);
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            } else {
                e.printStackTrace();
            }
        }

        return new ArrayList<>();
    }

    public boolean cancelOrderIfAllowed(int userId, int orderId) {
        String sql = "UPDATE orders SET status = ? " +
                "WHERE id = ? AND user_id = ? " +
                "AND status IN (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "Đã huỷ");
            ps.setInt(2, orderId);
            ps.setInt(3, userId);
            ps.setString(4, "PENDING");
            ps.setString(5, "PENDING_REVIEW");
            ps.setString(6, "Chờ duyệt");
            ps.setString(7, "Chờ xử lý");
            ps.setString(8, "PROCESSING");
            ps.setString(9, "Đang xử lý");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private List<CustomerOrderItem> fetchItems(int orderId, String sql, boolean hasSize)
            throws SQLException {
        List<CustomerOrderItem> items = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerOrderItem item = new CustomerOrderItem();
                    item.setOrderId(rs.getInt("order_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setSize(hasSize ? rs.getString("size") : null);
                    item.setQuantity(rs.getInt("quantity"));
                    item.setPrice(rs.getDouble("price"));
                    item.setLineTotal(rs.getDouble("line_total"));
                    items.add(item);
                }
            }
        }

        return items;
    }
}
