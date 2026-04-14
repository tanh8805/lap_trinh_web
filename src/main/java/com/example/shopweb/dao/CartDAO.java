package com.example.shopweb.dao;

import com.example.shopweb.model.CartItem;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý các thao tác liên quan đến giỏ hàng phía Database.
 */
public class CartDAO {

    /**
     * Lấy danh sách tất cả variant (size + giá) của một sản phẩm.
     * Dùng để hiển thị popup chọn size trước khi thêm vào giỏ.
     */
    public List<CartItem> getVariantsByProductId(int productId) {
        List<CartItem> variants = new ArrayList<>();

        String sql = "SELECT v.id AS variant_id, v.size, v.price, v.stock_quantity, " +
                     "p.id AS product_id, p.name, p.image_url " +
                     "FROM product_variants v " +
                     "JOIN products p ON v.product_id = p.id " +
                     "WHERE v.product_id = ? AND v.stock_quantity > 0 " +
                     "ORDER BY v.size";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem(
                        rs.getInt("variant_id"),
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getString("image_url"),
                        rs.getString("size"),
                        rs.getDouble("price"),
                        0 // quantity chưa xác định ở bước này
                    );
                    variants.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return variants;
    }

    // ===== CART DB PERSISTENCE =====

    /**
     * Load toàn bộ giỏ hàng của user từ DB.
     */
    public List<CartItem> loadCart(int userId) {
        List<CartItem> cart = new ArrayList<>();
        String sql = "SELECT c.variant_id, c.quantity, v.size, v.price, " +
                     "p.id AS product_id, p.name, p.image_url " +
                     "FROM cart c " +
                     "JOIN product_variants v ON c.variant_id = v.id " +
                     "JOIN products p ON v.product_id = p.id " +
                     "WHERE c.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    cart.add(new CartItem(
                        rs.getInt("variant_id"),
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getString("image_url"),
                        rs.getString("size"),
                        rs.getDouble("price"),
                        rs.getInt("quantity")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cart;
    }

    /**
     * Thêm hoặc cập nhật số lượng 1 item trong DB.
     */
    public void upsertItem(int userId, int variantId, int quantity) {
        String sql = "INSERT INTO cart (user_id, variant_id, quantity) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE quantity = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, variantId);
            ps.setInt(3, quantity);
            ps.setInt(4, quantity);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Xóa 1 item khỏi DB theo variantId.
     */
    public void removeItem(int userId, int variantId) {
        String sql = "DELETE FROM cart WHERE user_id = ? AND variant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, variantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Xóa toàn bộ giỏ hàng của user trong DB (dùng sau checkout).
     */
    public void clearCart(int userId) {
        String sql = "DELETE FROM cart WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy thông tin 1 variant cụ thể theo variantId.
     * Dùng khi user đã chọn size và bấm "Thêm vào giỏ".
     */
    public CartItem getCartItemByVariantId(int variantId) {
        String sql = "SELECT v.id AS variant_id, v.size, v.price, v.stock_quantity, " +
                     "p.id AS product_id, p.name, p.image_url " +
                     "FROM product_variants v " +
                     "JOIN products p ON v.product_id = p.id " +
                     "WHERE v.id = ? AND v.stock_quantity > 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, variantId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CartItem(
                        rs.getInt("variant_id"),
                        rs.getInt("product_id"),
                        rs.getString("name"),
                        rs.getString("image_url"),
                        rs.getString("size"),
                        rs.getDouble("price"),
                        1 // mặc định thêm 1 cái
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
}