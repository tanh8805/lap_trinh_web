package com.example.shopweb.model;

import java.io.Serializable;

/**
 * Một dòng sản phẩm trong giỏ hàng, lưu trong HttpSession.
 * Implements Serializable để Tomcat có thể serialize/deserialize session.
 *
 * Mỗi CartItem đại diện cho 1 variant cụ thể (productId + size).
 * Cho phép cùng 1 sản phẩm xuất hiện nhiều lần với size khác nhau.
 */
public class CartItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private int    variantId;   // ID của product_variants — key định danh duy nhất
    private int    productId;
    private String name;
    private String imageUrl;
    private String size;        // Size đã chọn (S, M, L, XL...)
    private double price;       // Giá tại thời điểm thêm vào giỏ (từ variant)
    private int    quantity;

    public CartItem() {}

    public CartItem(int variantId, int productId, String name,
                    String imageUrl, String size, double price, int quantity) {
        this.variantId = variantId;
        this.productId = productId;
        this.name      = name;
        this.imageUrl  = imageUrl;
        this.size      = size;
        this.price     = price;
        this.quantity  = quantity;
    }

    public int    getVariantId()                   { return variantId; }
    public void   setVariantId(int variantId)      { this.variantId = variantId; }

    public int    getProductId()                   { return productId; }
    public void   setProductId(int productId)      { this.productId = productId; }

    public String getName()                        { return name; }
    public void   setName(String name)             { this.name = name; }

    public String getImageUrl()                    { return imageUrl; }
    public void   setImageUrl(String imageUrl)     { this.imageUrl = imageUrl; }

    public String getSize()                        { return size; }
    public void   setSize(String size)             { this.size = size; }

    public double getPrice()                       { return price; }
    public void   setPrice(double price)           { this.price = price; }

    public int    getQuantity()                    { return quantity; }
    public void   setQuantity(int quantity)        { this.quantity = quantity; }

    public double getSubtotal()                    { return price * quantity; }
}