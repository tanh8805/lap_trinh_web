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
import java.util.LinkedHashMap;

public class ProductDAO {

    public Product getProductById(int id) {
        Product product = null;

        String sql = "SELECT p.id, p.name, p.description, p.image_url, p.category_id, "
                + "c.name AS category_name, "
                + "COALESCE(MIN(v.price), 0) AS min_price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "LEFT JOIN product_variants v ON p.id = v.product_id "
                + "WHERE p.id = ? "
                + "GROUP BY p.id, p.name, p.description, p.image_url, p.category_id, c.name";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                product = new Product();
                product.setId(rs.getInt("id"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setImageUrl(rs.getString("image_url"));
                product.setCategoryId(rs.getInt("category_id"));
                product.setCategoryName(rs.getString("category_name"));
                product.setDisplayPrice(rs.getDouble("min_price"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }


        if (product != null) {
            String variantSql = "SELECT size, price, stock_quantity "
                    + "FROM product_variants "
                    + "WHERE product_id = ? AND stock_quantity > 0";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(variantSql)) {

                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();

                List<String> sizes = new ArrayList<>();

                while (rs.next()) {
                    sizes.add(rs.getString("size"));

                }

                product.setSizes(sizes);
                product.setVariantPrices(getVariantPrices(id));
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return product;
    }

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();


        String sql = "SELECT p.id, p.name, p.description, p.image_url, p.category_id, "
                + "c.name AS category_name, "
                + "COALESCE(MIN(v.price), 0) AS min_price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "LEFT JOIN product_variants v ON p.id = v.product_id "
                + "GROUP BY p.id, p.name, p.description, p.image_url, p.category_id, c.name "
                + "ORDER BY p.id";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setCategoryName(rs.getString("category_name"));
                p.setDisplayPrice(rs.getDouble("min_price"));
                p.setSizes(new ArrayList<>());
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        String sizeSql = "SELECT product_id, size "
                + "FROM product_variants "
                + "WHERE stock_quantity > 0 "
                + "ORDER BY product_id";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sizeSql); ResultSet rs = ps.executeQuery()) {


            Map<Integer, List<String>> sizeMap = new HashMap<>();
            while (rs.next()) {
                int pid = rs.getInt("product_id");
                String size = rs.getString("size");
                sizeMap.computeIfAbsent(pid, k -> new ArrayList<>()).add(size);
            }


            for (Product p : products) {
                List<String> sizes = sizeMap.getOrDefault(p.getId(), new ArrayList<>());
                p.setSizes(sizes);
            }
            for (Product p : products) {
                p.setVariantPrices(getVariantPrices(p.getId()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Lấy Map<size, price> từ product_variants. Dùng để modal hiển thị đúng giá
     * theo size được chọn.
     */
    private Map<String, Double> getVariantPrices(int productId) {
        Map<String, Double> variantPrices = new LinkedHashMap<>();
        String sql = "SELECT size, price FROM product_variants "
                + "WHERE product_id = ? AND stock_quantity > 0 ORDER BY price";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    variantPrices.put(rs.getString("size"), rs.getDouble("price"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return variantPrices;
    }
}
