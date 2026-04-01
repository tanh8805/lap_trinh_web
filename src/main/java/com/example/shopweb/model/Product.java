package com.example.shopweb.model;

import java.util.List;

public class Product {
    private int id;
    private String name;
    private String description;
    private String imageUrl;
    private int categoryId;
    private double displayPrice; // Giá hiển thị (thấp nhất từ các variant)
    private String categoryName; // Tên danh mục để hiển thị và lọc client-side
    private List<String> sizes;  // Danh sách size còn hàng để lọc client-side

    public Product() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public double getDisplayPrice() { return displayPrice; }
    public void setDisplayPrice(double displayPrice) { this.displayPrice = displayPrice; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public List<String> getSizes() { return sizes; }
    public void setSizes(List<String> sizes) { this.sizes = sizes; }
}