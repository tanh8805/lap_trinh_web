package com.example.shopweb.dao;

import com.example.shopweb.model.Product;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductDAO {

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();

        // Lấy thông tin sản phẩm kèm tên danh mục và giá thấp nhất
        String sql = "SELECT p.id, p.name, p.description, p.image_url, p.category_id, " +
                     "c.name AS category_name, " +
                     "COALESCE(MIN(v.price), 0) AS min_price " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.id " +
                     "LEFT JOIN product_variants v ON p.id = v.product_id " +
                     "GROUP BY p.id, p.name, p.description, p.image_url, p.category_id, c.name " +
                     "ORDER BY p.id";

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
                p.setDisplayPrice(rs.getDouble("min_price"));
                p.setSizes(new ArrayList<>()); // Sẽ được điền ở bước tiếp theo
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Lấy sizes còn hàng cho tất cả sản phẩm trong 1 query (tránh N+1 query)
        String sizeSql = "SELECT product_id, size " +
                         "FROM product_variants " +
                         "WHERE stock_quantity > 0 " +
                         "ORDER BY product_id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sizeSql);
             ResultSet rs = ps.executeQuery()) {

            // Map productId → danh sách size để điền vào từng product
            Map<Integer, List<String>> sizeMap = new HashMap<>();
            while (rs.next()) {
                int pid = rs.getInt("product_id");
                String size = rs.getString("size");
                sizeMap.computeIfAbsent(pid, k -> new ArrayList<>()).add(size);
            }

            // Điền sizes vào từng product theo id
            for (Product p : products) {
                List<String> sizes = sizeMap.getOrDefault(p.getId(), new ArrayList<>());
                p.setSizes(sizes);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }
}