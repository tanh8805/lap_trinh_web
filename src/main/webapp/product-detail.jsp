<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.example.shopweb.model.Product" %>
<%@ page import="java.util.Map" %>

<%
    Product product = (Product) request.getAttribute("product");
    String contextPath = request.getContextPath();

    // Build JSON map size→price để JS đổi giá khi chọn size
    StringBuilder vJson = new StringBuilder("{");
    if (product.getVariantPrices() != null && !product.getVariantPrices().isEmpty()) {
        boolean fe = true;
        for (Map.Entry<String, Double> e : product.getVariantPrices().entrySet()) {
            if (!fe) vJson.append(",");
            vJson.append("\"").append(e.getKey()).append("\":")
                 .append(e.getValue().longValue());
            fe = false;
        }
    }
    vJson.append("}");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết sản phẩm</title>

    <style>
        body { font-family: Arial; margin: 0; background: #f5f5f5; }

        /* ===== NAVBAR ===== */
        nav {
            background: #fff; padding: 15px 50px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .logo { font-size: 22px; font-weight: bold; text-decoration: none; color: black; }
        .menu a { margin-left: 25px; text-decoration: none; color: #555; }
        .menu a:hover { color: black; }

        /* ===== BACK ===== */
        .btn-back {
            margin: 20px 50px; padding: 8px 15px;
            background: #fff; border: 1px solid #ccc; cursor: pointer;
        }
        .btn-back:hover { background: #eee; }

        /* ===== CONTENT ===== */
        .container { width: 80%; margin: auto; background: #fff; padding: 30px; }
        .product { display: flex; gap: 40px; }
        .product-img { width: 400px; border: 1px solid #ddd; object-fit: cover; }
        .info { flex: 1; }

        /* Giá — đổi theo size */
        .price { color: #ee4d2d; font-size: 24px; font-weight: bold; margin: 10px 0; }

        /* ===== SIZE ===== */
        .size-btn {
            padding: 8px 15px; border: 1px solid #ccc;
            margin: 5px; cursor: pointer; background: #fff; transition: all 0.2s;
        }
        .size-btn.active { border: 2px solid #ee4d2d; color: #ee4d2d; }
        .size-btn:hover { border-color: #ee4d2d; }

        /* ===== QUANTITY ===== */
        .qty-wrapper { display: flex; align-items: center; margin-top: 15px; }
        .qty-wrapper button {
            width: 35px; height: 35px; border: 1px solid #ccc;
            background: #f9f9f9; cursor: pointer; font-size: 18px;
        }
        .qty-wrapper button:hover { background: #eee; }
        .qty-wrapper input {
            width: 50px; height: 35px; text-align: center;
            border: 1px solid #ccc; border-left: none; border-right: none;
        }

        /* ===== BUTTONS ===== */
        .btn-group { margin-top: 20px; display: flex; gap: 15px; }
        .btn-cart {
            padding: 12px 25px; border: 1px solid #ee4d2d;
            color: #ee4d2d; background: #fff; cursor: pointer; font-size: 15px;
            transition: all 0.2s;
        }
        .btn-cart:hover { background: #fff5f3; }
        .btn-cart:disabled { opacity: 0.6; cursor: not-allowed; }
        .btn-buy {
            padding: 12px 25px; background: #ee4d2d; color: white;
            border: none; cursor: pointer; font-size: 15px; transition: background 0.2s;
        }
        .btn-buy:hover { background: #d84325; }

        /* ===== TOAST ===== */
        #toast {
            position: fixed; bottom: 30px; right: 30px;
            background: #222; color: #fff;
            padding: 14px 18px 14px 22px; border-radius: 8px;
            font-size: 14px; font-weight: 500;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            opacity: 0; transform: translateY(20px);
            transition: opacity 0.3s, transform 0.3s;
            z-index: 9999; pointer-events: none;
            display: flex; align-items: center; gap: 12px; min-width: 280px;
        }
        #toast.show { opacity: 1; transform: translateY(0); pointer-events: auto; }
        #toast-close {
            background: none; border: none; color: #aaa;
            font-size: 18px; cursor: pointer; margin-left: auto;
        }
        #toast-close:hover { color: #fff; }
    </style>
</head>

<body>

<!-- NAVBAR -->
<nav>
    <a href="<%= contextPath %>/index.jsp" class="logo">ShopWeb</a>
    <div class="menu">
        <a href="<%= contextPath %>/products">Sản phẩm</a>
        <% if (session.getAttribute("loggedInUser") != null) { %>
            <a href="<%= contextPath %>/logout">Đăng xuất</a>
        <% } else { %>
            <a href="<%= contextPath %>/login.jsp">Đăng nhập</a>
            <a href="<%= contextPath %>/register.jsp">Đăng ký</a>
        <% } %>
        <a href="<%= contextPath %>/cart">🛒</a>
    </div>
</nav>

<button class="btn-back" onclick="window.history.back()">← Quay lại</button>

<div class="container">
    <h1><%= product.getName() %></h1>

    <div class="product">
        <img class="product-img"
             src="<%= product.getImageUrl() %>"
             onerror="this.src='<%= contextPath %>/images/no-image.jpg'"
             alt="<%= product.getName() %>">

        <div class="info">
            <p><b>Danh mục:</b> <%= product.getCategoryName() %></p>
            <p><b>Mô tả:</b> <%= product.getDescription() %></p>

            <%-- Giá — sẽ đổi khi chọn size --%>
            <p class="price" id="productPrice">
                Từ <%= String.format("%,.0f", product.getDisplayPrice()) %> đ
            </p>

            <%-- Chọn size --%>
            <div>
                <b>Chọn size:</b><br/>
                <%
                    if (product.getSizes() != null) {
                        for (String size : product.getSizes()) {
                %>
                    <button class="size-btn" data-size="<%= size %>"><%= size %></button>
                <%
                        }
                    }
                %>
            </div>

            <%-- Số lượng --%>
            <div class="qty-wrapper">
                <button onclick="decrease()">−</button>
                <input type="text" id="quantity" value="1" readonly>
                <button onclick="increase()">+</button>
            </div>

            <%-- Nút hành động --%>
            <div class="btn-group">
                <button class="btn-cart" onclick="addToCart()">🛒 Thêm vào giỏ hàng</button>
                <button class="btn-buy"  onclick="buyNow()">Mua ngay</button>
            </div>
        </div>
    </div>
</div>

<%-- Toast thông báo --%>
<div id="toast">
    <span id="toast-message"></span>
    <button id="toast-close" onclick="closeToast()" title="Đóng">✕</button>
</div>

<script>
    var selectedSize  = null;
    // variantPrices: map size → giá lấy từ server qua JSP
    var variantPrices = <%= vJson %>;
    var productId     = <%= product.getId() %>;
    var productName   = '<%= product.getName().replace("'", "\\'") %>';

    // ===== CHỌN SIZE — cập nhật giá theo size =====
    document.querySelectorAll('.size-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.size-btn').forEach(function(b) {
                b.classList.remove('active');
            });
            this.classList.add('active');
            selectedSize = this.dataset.size;

            // Đổi giá theo size được chọn từ variantPrices
            if (variantPrices[selectedSize] !== undefined) {
                document.getElementById('productPrice').textContent =
                    Math.round(variantPrices[selectedSize]).toLocaleString('vi-VN') + ' đ';
            }
        });
    });

    // ===== TĂNG / GIẢM SỐ LƯỢNG =====
    function increase() {
        var qty = document.getElementById('quantity');
        qty.value = parseInt(qty.value) + 1;
    }

    function decrease() {
        var qty = document.getElementById('quantity');
        if (parseInt(qty.value) > 1) qty.value = parseInt(qty.value) - 1;
    }

    // ===== THÊM VÀO GIỎ — gửi productId lên CartServlet =====
    function addToCart() {
        if (!selectedSize) {
            alert('Vui lòng chọn size!');
            return;
        }

        var btn = document.querySelector('.btn-cart');
        btn.disabled = true;
        btn.textContent = 'Đang thêm...';

        // Frontend chỉ gửi productId — backend tự lấy thông tin từ DB
        fetch('<%= contextPath %>/cart?action=add', {
            method  : 'POST',
            headers : { 'Content-Type': 'application/x-www-form-urlencoded' },
            body    : 'productId=' + productId
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.success) {
                showToast('✓ Đã thêm "' + productName + '" vào giỏ hàng!');
            } else {
                showToast('✗ ' + (data.message || 'Có lỗi xảy ra'));
            }
        })
        .catch(function() {
            showToast('✗ Không thể kết nối server');
        })
        .finally(function() {
            btn.disabled = false;
            btn.textContent = '🛒 Thêm vào giỏ hàng';
        });
    }

    function buyNow() {
        if (!selectedSize) {
            alert('Vui lòng chọn size!');
            return;
        }
        alert('Tính năng mua ngay sẽ được phát triển!');
    }

    // ===== TOAST =====
    var toastTimer = null;
    function showToast(message) {
        document.getElementById('toast-message').textContent = message;
        var toast = document.getElementById('toast');
        toast.classList.add('show');
        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(closeToast, 3000);
    }
    function closeToast() {
        document.getElementById('toast').classList.remove('show');
        if (toastTimer) { clearTimeout(toastTimer); toastTimer = null; }
    }
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeToast();
    });
</script>

</body>
</html>