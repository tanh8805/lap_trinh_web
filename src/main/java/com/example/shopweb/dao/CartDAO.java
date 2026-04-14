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
                        0
                    );
                    variants.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return variants;
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
                        1
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
}