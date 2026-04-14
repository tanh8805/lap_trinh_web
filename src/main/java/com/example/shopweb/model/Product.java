package com.example.shopweb.model;

import java.util.List;
import java.util.Map;

public class Product {

    private int id;
    private String name;
    private String description;
    private String imageUrl;
    private int categoryId;
    private double displayPrice;
    private String categoryName;
    private List<String> sizes;
    private List<String[]> variants;
    private Map<String, Double> variantPrices;

    public Product() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public double getDisplayPrice() {
        return displayPrice;
    }

    public void setDisplayPrice(double displayPrice) {
        this.displayPrice = displayPrice;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public List<String> getSizes() {
        return sizes;
    }

    public void setSizes(List<String> sizes) {
        this.sizes = sizes;
    }

    public List<String[]> getVariants() {
        return variants;
    }

    public void setVariants(List<String[]> variants) {
        this.variants = variants;
    }

    public Map<String, Double> getVariantPrices() {
        return variantPrices;
    }

    public void setVariantPrices(Map<String, Double> variantPrices) {
        this.variantPrices = variantPrices;
    }
}
