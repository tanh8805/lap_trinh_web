package com.example.shopweb.dao;

import com.example.shopweb.model.Product;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý CRUD sản phẩm dành riêng cho Admin.
 */
public class AdminProductDAO {

    // ===== LẤY TẤT CẢ SẢN PHẨM =====
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.id, p.name, p.description, p.image_url, " +
                     "p.category_id, c.name AS category_name " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "ORDER BY p.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setCategoryName(rs.getString("category_name"));
                
                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== LẤY 1 SẢN PHẨM THEO ID =====
    public Product getProductById(int id) {
        String sql = "SELECT p.id, p.name, p.description, p.image_url, " +
                     "p.category_id, c.name AS category_name " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "WHERE p.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setDescription(rs.getString("description"));
                    p.setImageUrl(rs.getString("image_url"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    // Lấy danh sách variants (size, price, stock) để hiển thị khi sửa
                    p.setVariants(getVariantsByProductId(id));
                    return p;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ===== THÊM SẢN PHẨM =====
    public int insertProduct(String name, String description,
                         String imageUrl, int categoryId) {

    String sql = "INSERT INTO products (name, description, image_url, category_id) VALUES (?, ?, ?, ?)";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

        ps.setString(1, name);
        ps.setString(2, description);
        ps.setString(3, imageUrl);
        ps.setInt(4, categoryId);

        ps.executeUpdate();

        ResultSet rs = ps.getGeneratedKeys();
        if (rs.next()) {
            return rs.getInt(1); // 👉 LẤY product_id
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
    return -1;
}

    // ===== SỬA SẢN PHẨM =====
    public boolean updateProduct(int id, String name, String description,
                                  String imageUrl, int categoryId) {
        String sql = "UPDATE products SET name = ?, description = ?, " +
                     "image_url = ?, category_id = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, description);
            ps.setString(3, imageUrl);
            ps.setInt(4, categoryId);
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== XÓA SẢN PHẨM =====
    // Xóa variants trước (FK constraint), sau đó xóa product
    public boolean deleteProduct(int id) {
        String deleteVariants = "DELETE FROM product_variants WHERE product_id = ?";
        String deleteProduct  = "DELETE FROM products WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            // Dùng transaction đảm bảo 2 lệnh DELETE là nguyên tử
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(deleteVariants);
                 PreparedStatement ps2 = conn.prepareStatement(deleteProduct)) {

                ps1.setInt(1, id);
                ps1.executeUpdate();

                ps2.setInt(1, id);
                ps2.executeUpdate();

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ===== LẤY DANH SÁCH CATEGORIES =====
    public List<String[]> getAllCategories() {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT id, name FROM categories ORDER BY name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new String[]{ rs.getString("id"), rs.getString("name") });
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    public List<String[]> getVariantsByProductId(int productId) {
        List<String[]> list = new ArrayList<>();

        String sql = "SELECT id, size, price, stock_quantity FROM product_variants WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new String[]{
                    rs.getString("id"),
                    rs.getString("size"),
                    rs.getString("price"),
                    rs.getString("stock_quantity")
                });
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
    public boolean insertVariant(int productId, String size, double price, int stock) {

        String sql = "INSERT INTO product_variants (product_id, size, price, stock_quantity) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setString(2, size);
            ps.setDouble(3, price);
            ps.setInt(4, stock);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
    public boolean deleteVariantsByProductId(int productId) {
        String sql = "DELETE FROM product_variants WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    // ===== UPDATE VARIANT =====

    public boolean updateVariant(int variantId, String size, double price, int stock) {
        String sql = "UPDATE product_variants SET size = ?, price = ?, stock_quantity = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, size);
            ps.setDouble(2, price);
            ps.setInt(3, stock);
            ps.setInt(4, variantId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

// ===== DELETE VARIANTS NOT IN LIST =====
    public boolean deleteVariantsNotInList(int productId, List<Integer> variantIds) {
        if (variantIds.isEmpty()) {
            return deleteVariantsByProductId(productId);
        }

        String placeholders = String.join(",", variantIds.stream().map(v -> "?").toList());
        String sql = "DELETE FROM product_variants WHERE product_id = ? AND id NOT IN (" + placeholders + ")";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            int index = 2;
            for (int id : variantIds) {
                ps.setInt(index++, id);
            }

            ps.executeUpdate();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}