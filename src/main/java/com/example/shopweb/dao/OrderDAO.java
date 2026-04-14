package com.example.shopweb.dao;

import com.example.shopweb.model.CartItem;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

public class OrderDAO {

    public boolean createOrder(int userId, List<CartItem> items, double totalAmount, double shippingFee, String address,
            String phone) {
        String insertOrder = "INSERT INTO orders (user_id, total_amount, shipping_fee, status, address, phone) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        // Thu dung variant_id truoc (schema moi).
        // Neu DB chua co cot variant_id, fallback sang product_id (schema cu).
        String insertItemNew = "INSERT INTO order_items (order_id, variant_id, quantity, price) " +
                "VALUES (?, ?, ?, ?)";
        String insertItemOld = "INSERT INTO order_items (order_id, product_id, quantity, price) " +
                "VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Buoc 1: tao don hang, lay orderId
            int orderId;
            try (PreparedStatement psOrder = conn.prepareStatement(
                    insertOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setInt(1, userId);
                psOrder.setDouble(2, totalAmount);
                psOrder.setDouble(3, shippingFee);
                psOrder.setString(4, "PENDING");
                psOrder.setString(5, address);
                psOrder.setString(6, phone);
                psOrder.executeUpdate();
                try (ResultSet keys = psOrder.getGeneratedKeys()) {
                    if (!keys.next()) {
                        conn.rollback();
                        return false;
                    }
                    orderId = keys.getInt(1);
                }
            }

            // Buoc 2: thu insert voi variant_id truoc
            try {
                insertItems(conn, insertItemNew, orderId, items, true);
            } catch (SQLException e) {
                // Neu loi (co the do chua co cot variant_id), thu fallback product_id
                if (e.getMessage() != null &&
                        (e.getMessage().contains("variant_id") || e.getMessage().contains("Unknown column"))) {
                    insertItems(conn, insertItemOld, orderId, items, false);
                } else {
                    throw e;
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void insertItems(Connection conn, String sql, int orderId,
            List<CartItem> items, boolean useVariantId)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (CartItem item : items) {
                ps.setInt(1, orderId);
                // useVariantId=true -> dung variantId (schema moi)
                // useVariantId=false -> fallback productId (schema cu)
                ps.setInt(2, useVariantId ? item.getVariantId() : item.getProductId());
                ps.setInt(3, item.getQuantity());
                ps.setDouble(4, item.getPrice());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}