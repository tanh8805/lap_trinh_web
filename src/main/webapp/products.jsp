<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="com.example.shopweb.model.Product" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopWeb - Sản phẩm</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* ===== NAVBAR ===== */
        nav {
            background: #ffffff;
            padding: 15px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; color: #000; text-decoration: none; }
        .menu { display: flex; align-items: center; }
        .menu a {
            margin-left: 25px; text-decoration: none; color: #555;
            font-weight: 500; transition: color 0.3s;
        }
        .menu a:hover { color: #000; }

        /* Icon giỏ hàng với badge */
        .cart-link {
            position: relative;
            margin-left: 25px;
            text-decoration: none;
            color: #555;
            font-size: 22px;
            display: flex;
            align-items: center;
            transition: color 0.3s;
        }
        .cart-link:hover { color: #000; }
        .cart-badge {
            position: absolute;
            top: -8px;
            right: -10px;
            background: #e74c3c;
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            min-width: 18px;
            height: 18px;
            border-radius: 9px;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
        }

        /* ===== LAYOUT: SIDEBAR + MAIN ===== */
        .page-wrapper {
            flex: 1;
            display: flex;
            max-width: 1200px;
            margin: 40px auto;
            width: 100%;
            padding: 0 50px;
            gap: 30px;
        }

        /* ===== SIDEBAR BỘ LỌC ===== */
        .filter-sidebar {
            width: 240px;
            flex-shrink: 0;
        }
        .filter-sidebar h3 {
            font-size: 16px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 20px;
            color: #111;
        }
        .filter-group {
            margin-bottom: 25px;
            padding-bottom: 25px;
            border-bottom: 1px solid #eee;
        }
        .filter-group:last-child { border-bottom: none; }
        .filter-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Search input */
        #searchInput {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }
        #searchInput:focus { border-color: #000; }

        /* Category select */
        #categoryFilter {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            background: #fff;
            outline: none;
            cursor: pointer;
        }

        /* Price range */
        .price-inputs {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .price-inputs input {
            width: 0;
            flex: 1;
            padding: 9px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 13px;
            outline: none;
        }
        .price-inputs input:focus { border-color: #000; }
        .price-inputs span { color: #999; font-size: 13px; }

        /* Size buttons — có thể chọn nhiều */
        .size-options {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .size-btn {
            padding: 6px 12px;
            border: 1.5px solid #ddd;
            border-radius: 4px;
            font-size: 13px;
            cursor: pointer;
            background: #fff;
            transition: all 0.2s;
            user-select: none;
        }
        .size-btn.active {
            background: #000;
            color: #fff;
            border-color: #000;
        }

        /* Nút reset */
        #btnReset {
            width: 100%;
            padding: 10px;
            background: #f1f1f1;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 5px;
        }
        #btnReset:hover { background: #e0e0e0; }

        /* ===== PRODUCT GRID ===== */
        .main-content { flex: 1; min-width: 0; }
        .result-count {
            font-size: 14px;
            color: #888;
            margin-bottom: 20px;
        }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 25px;
        }
        .product-card {
            background: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            display: flex;
            flex-direction: column;
        }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }

        /* Card bị lọc ẩn đi */
        .product-card.hidden { display: none; }

        .product-image { width: 100%; height: 280px; object-fit: cover; background-color: #eee; }
        .product-info { padding: 18px; text-align: center; flex: 1; display: flex; flex-direction: column; }
        .product-name { font-size: 16px; margin-bottom: 8px; color: #222; }
        .product-category { font-size: 12px; color: #999; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        .product-price { font-size: 15px; font-weight: bold; color: #e74c3c; margin-bottom: 10px; }
        .product-sizes { font-size: 12px; color: #aaa; margin-bottom: 12px; }

        .btn-view {
            margin-top: auto;
            display: inline-block;
            padding: 10px 0;
            width: 100%;
            background: #000;
            color: #fff;
            text-decoration: none;
            border-radius: 4px;
            font-weight: 600;
            transition: background 0.3s;
            font-size: 14px;
            text-align: center;
        }
        .btn-view:hover { background: #333; }
        
        
        /* ===== HÀNG 2 NÚT ===== */
        .btn-row {
            margin-top: auto;
            display: flex;
            gap: 8px;
        }
        .btn-row .btn-view {
            flex: 1;
            margin-top: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            width: auto;
        }

        /* Nút giỏ hàng nhỏ cạnh "Xem chi tiết" */
        .btn-open-modal {
            width: 42px;
            flex-shrink: 0;
            background: #fff;
            color: #000;
            border: 1.5px solid #000;
            border-radius: 4px;
            font-size: 18px;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .btn-open-modal:hover { background: #000; color: #fff; }
        .btn-open-modal:disabled { opacity: 0.35; cursor: not-allowed; }

        /* ===== MODAL GIỮA MÀN HÌNH ===== */
        #cartModal {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 1000;
        }
        #cartModal .modal-backdrop {
            position: absolute;
            inset: 0;
            background: rgba(0,0,0,0.5);
        }
        #cartModal .modal-panel {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 420px;
            background: #fff;
            border-radius: 12px;
            padding: 28px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.2);
        }
        .modal-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid #eee;
        }
        .modal-product-img {
            width: 90px;
            height: 90px;
            object-fit: cover;
            border-radius: 8px;
            flex-shrink: 0;
            background: #eee;
        }
        .modal-product-info { flex: 1; }
        .modal-product-name {
            font-size: 16px;
            font-weight: 600;
            color: #111;
            margin-bottom: 6px;
            line-height: 1.4;
        }
        .modal-product-price {
            font-size: 20px;
            font-weight: 700;
            color: #e74c3c;
        }
        .modal-close {
            background: none;
            border: none;
            font-size: 22px;
            cursor: pointer;
            color: #999;
            line-height: 1;
            padding: 0;
            flex-shrink: 0;
        }
        .modal-close:hover { color: #333; }
        .modal-label {
            font-size: 13px;
            font-weight: 600;
            color: #555;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
        }
        .modal-sizes {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 24px;
        }
        .modal-size-btn {
            padding: 8px 18px;
            border: 1.5px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            background: #fff;
            transition: all 0.15s;
            user-select: none;
        }
        .modal-size-btn:hover  { border-color: #000; }
        .modal-size-btn.active { background: #000; color: #fff; border-color: #000; }
        .modal-btn-add {
            width: 100%;
            padding: 15px;
            background: #e74c3c;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }
        .modal-btn-add:hover    { background: #c0392b; }
        .modal-btn-add:disabled { background: #ccc; cursor: not-allowed; }

        /* ===== TOAST ===== */
        #toast {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background: #222;
            color: #fff;
            padding: 14px 22px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.3s, transform 0.3s;
            z-index: 9999;
            pointer-events: none;
        }
        #toast.show { 
            opacity: 1; 
            transform: translateY(0);
            pointer-events: auto;
        }
        #toast-close {
            background: none;
            border: none;
            color: #aaa;
            font-size: 18px;
            cursor: pointer;
            line-height: 1;
            padding: 0;
            margin-left: auto;
            flex-shrink: 0;
            transition: color 0.2s;
        }
        #toast-close:hover { color: #fff; }
        
        
        /* Thông báo không có kết quả */
        #noResult {
            display: none;
            grid-column: 1 / -1;
            text-align: center;
            color: #999;
            padding: 60px 0;
            font-size: 16px;
        }

        footer {
            background: #111; color: #fff;
            text-align: center; padding: 20px;
            font-size: 14px; margin-top: auto;
        }
    </style>
</head>
<body>

<nav>
    <a href="index.jsp" class="logo">ShopWeb</a>
    <div class="menu">
        <a href="products">Sản phẩm</a>

        <% if (session.getAttribute("loggedInUser") != null) { %>
            <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
        <% } else { %>
            <a href="login.jsp">Đăng nhập</a>
            <a href="register.jsp">Đăng ký</a>
        <% } %>

        <%-- Icon giỏ hàng --%>
        <a href="cart.jsp" class="cart-link" title="Giỏ hàng">
            🛒
            <span class="cart-badge" id="cartBadge">0</span>
        </a>
    </div>
</nav>

<div class="page-wrapper">

    <%-- ===== SIDEBAR BỘ LỌC ===== --%>
    <aside class="filter-sidebar">
        <h3>Bộ lọc</h3>

        <%-- Tìm kiếm theo tên --%>
        <div class="filter-group">
            <label for="searchInput">Tìm kiếm</label>
            <input type="text" id="searchInput" placeholder="Nhập tên sản phẩm...">
        </div>

        <%-- Lọc theo danh mục --%>
        <div class="filter-group">
            <label for="categoryFilter">Danh mục</label>
            <select id="categoryFilter">
                <option value="">Tất cả danh mục</option>
                <%
                    List<String> categories = (List<String>) request.getAttribute("categories");
                    if (categories != null) {
                        for (String cat : categories) {
                %>
                    <option value="<%= cat %>"><%= cat %></option>
                <%
                        }
                    }
                %>
            </select>
        </div>

        <%-- Lọc theo khoảng giá --%>
        <div class="filter-group">
            <label>Khoảng giá (đ)</label>
            <div class="price-inputs">
                <input type="number" id="priceMin" placeholder="Từ" min="0">
                <span>—</span>
                <input type="number" id="priceMax" placeholder="Đến" min="0">
            </div>
        </div>

        <%-- Lọc theo size — render các size duy nhất từ tất cả sản phẩm --%>
        <div class="filter-group">
            <label>Size</label>
            <div class="size-options" id="sizeOptions">
                <%
                    List<Product> productList = (List<Product>) request.getAttribute("productList");
                    LinkedHashSet<String> allSizes = new LinkedHashSet<>();

                    // Thứ tự hiển thị size chuẩn
                    List<String> sizeOrder = Arrays.asList("XS", "S", "M", "L", "XL", "XXL", "3XL");

                    if (productList != null) {
                        for (Product p : productList) {
                            if (p.getSizes() != null) allSizes.addAll(p.getSizes());
                        }
                    }

                    // Sắp xếp: size chuẩn trước, size lạ thêm vào cuối
                    List<String> sortedSizes = new ArrayList<>();
                    for (String s : sizeOrder) { if (allSizes.contains(s)) sortedSizes.add(s); }
                    for (String s : allSizes)   { if (!sortedSizes.contains(s)) sortedSizes.add(s); }

                    for (String size : sortedSizes) {
                %>
                    <span class="size-btn" data-size="<%= size %>"><%= size %></span>
                <%
                    }
                %>
            </div>
        </div>

        <button id="btnReset">↺ Xóa bộ lọc</button>
    </aside>

    <%-- ===== MAIN CONTENT ===== --%>
    <main class="main-content">
        <p class="result-count" id="resultCount"></p>

        <div class="product-grid" id="productGrid">
            <%
                if (productList != null && !productList.isEmpty()) {
                    for (Product p : productList) {

                        // Xử lý đường dẫn ảnh
                        String rawUrl = p.getImageUrl();
                        String imagePath = request.getContextPath() + "/images/no-image.jpg";
                        if (rawUrl != null && !rawUrl.isEmpty()) {
                            imagePath = (rawUrl.startsWith("http") || rawUrl.startsWith("data:image"))
                                ? rawUrl
                                : request.getContextPath() + "/" + rawUrl;
                        }

                        // Nối sizes thành chuỗi "S,M,L,XL" để lưu vào data attribute
                        String sizesAttr = "";
                        if (p.getSizes() != null && !p.getSizes().isEmpty()) {
                            sizesAttr = String.join(",", p.getSizes());
                        }

                        String categoryAttr = (p.getCategoryName() != null) ? p.getCategoryName() : "";
            %>
            <%-- data-* chứa toàn bộ thông tin cần thiết để JS lọc client-side --%>
            <div class="product-card"
                 data-name="<%= p.getName().toLowerCase() %>"
                 data-category="<%= categoryAttr %>"
                 data-price="<%= p.getDisplayPrice() %>"
                 data-sizes="<%= sizesAttr %>">

                <img src="<%= imagePath %>" alt="<%= p.getName() %>" class="product-image"
                     onerror="this.src='<%= request.getContextPath() %>/images/no-image.jpg'">

                <div class="product-info">
                    <% if (!categoryAttr.isEmpty()) { %>
                        <p class="product-category"><%= categoryAttr %></p>
                    <% } %>
                    <h3 class="product-name"><%= p.getName() %></h3>
                    <% if (p.getDisplayPrice() > 0) { %>
                        <p class="product-price">Từ <%= String.format("%,.0f", p.getDisplayPrice()) %> đ</p>
                    <% } else { %>
                        <p class="product-price">Đang cập nhật giá</p>
                    <% } %>
                     <%-- Hàng 2 nút: Xem chi tiết + mở modal giỏ hàng --%>
                    <div class="btn-row">
                        <a href="#" class="btn-view">Xem chi tiết</a>
                        <%
                            // Build variantJson an toàn — dùng data attribute thay vì inline onclick
                            // tránh bị vỡ JS khi tên sản phẩm có dấu nháy hoặc ký tự đặc biệt
                            StringBuilder variantJson = new StringBuilder("{");
                            if (p.getVariantPrices() != null && !p.getVariantPrices().isEmpty()) {
                                boolean firstEntry = true;
                                for (Map.Entry<String, Double> entry : p.getVariantPrices().entrySet()) {
                                    if (!firstEntry) {
                                        variantJson.append(",");
                                    }
                                    variantJson.append("\"")
                                            .append(entry.getKey().replace("\"", "\\\""))
                                            .append("\":")
                                            .append(entry.getValue().longValue());
                                    firstEntry = false;
                                }
                            }
                            variantJson.append("}");
                        %>
                        <% if (!sizesAttr.isEmpty()) {%>
                        <button class="btn-open-modal"
                                title="Thêm vào giỏ"
                                data-product-id="<%= p.getId()%>"
                                data-product-name="<%= p.getName().replace("\"", "&quot;").replace("'", "&#39;")%>"
                                data-product-price="<%= (long) p.getDisplayPrice()%>"
                                data-product-image="<%= imagePath%>"
                                data-product-sizes="<%= sizesAttr%>"
                                data-variant-prices='<%= variantJson%>'>🛒</button>
                        <% } else { %>
                        <button class="btn-open-modal" disabled title="Hết hàng">🛒</button>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                    }
                }
            %>
            <p id="noResult">Không tìm thấy sản phẩm phù hợp.</p>
        </div>
    </main>

</div>

<footer>© 2026 ShopWeb. All rights reserved.</footer>
<%-- ===== MODAL CHỌN SIZE ===== --%>
<div id="cartModal">
    <div class="modal-backdrop" onclick="closeCartModal()"></div>
    <div class="modal-panel">

        <div class="modal-header">
            <img id="modalImg" src="" alt="" class="modal-product-img">
            <div class="modal-product-info">
                <p id="modalName" class="modal-product-name"></p>
                <p id="modalPrice" class="modal-product-price"></p>
            </div>
            <button class="modal-close" onclick="closeCartModal()">✕</button>
        </div>

        <p class="modal-label">Chọn Size</p>
        <div class="modal-sizes" id="modalSizes"></div>

        <button class="modal-btn-add" id="modalBtnAdd"
                onclick="confirmAddToCart()" disabled>
            Thêm vào Giỏ hàng
        </button>

    </div>
</div>

<%-- Toast thông báo --%>
<div id="toast">
    <span id="toast-message"></span>
    <button id="toast-close" onclick="closeToast()" title="Đóng">✕</button>
</div>
<script>
    // ===== BỘ LỌC CLIENT-SIDE =====
    // Toàn bộ logic lọc chạy trên DOM — không reload trang, không gọi server

    const cards          = document.querySelectorAll('.product-card');
    const searchInput    = document.getElementById('searchInput');
    const categoryFilter = document.getElementById('categoryFilter');
    const priceMin       = document.getElementById('priceMin');
    const priceMax       = document.getElementById('priceMax');
    const sizeBtns       = document.querySelectorAll('.size-btn');
    const resultCount    = document.getElementById('resultCount');
    const noResult       = document.getElementById('noResult');
    const btnReset       = document.getElementById('btnReset');

    // Tập hợp các size đang được chọn (hỗ trợ chọn nhiều cùng lúc)
    const selectedSizes = new Set();

    // Toggle chọn / bỏ chọn size
    sizeBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const size = btn.dataset.size;
            if (selectedSizes.has(size)) {
                selectedSizes.delete(size);
                btn.classList.remove('active');
            } else {
                selectedSizes.add(size);
                btn.classList.add('active');
            }
            applyFilter();
        });
    });

    // Lắng nghe thay đổi trên các bộ lọc còn lại
    searchInput.addEventListener('input', applyFilter);
    categoryFilter.addEventListener('change', applyFilter);
    priceMin.addEventListener('input', applyFilter);
    priceMax.addEventListener('input', applyFilter);

    function applyFilter() {
        const keyword  = searchInput.value.trim().toLowerCase();
        const category = categoryFilter.value;
        const minVal   = parseFloat(priceMin.value) || 0;
        const maxVal   = parseFloat(priceMax.value) || Infinity;

        let visibleCount = 0;

        cards.forEach(card => {
            const name      = card.dataset.name;
            const cat       = card.dataset.category;
            const price     = parseFloat(card.dataset.price) || 0;
            const cardSizes = card.dataset.sizes ? card.dataset.sizes.split(',') : [];

            const matchName     = name.includes(keyword);
            const matchCategory = !category || cat === category;
            const matchPrice    = price >= minVal && price <= maxVal;

            // Nếu chưa chọn size nào thì bỏ qua điều kiện size
            const matchSize = selectedSizes.size === 0
                || cardSizes.some(s => selectedSizes.has(s));

            if (matchName && matchCategory && matchPrice && matchSize) {
                card.classList.remove('hidden');
                visibleCount++;
            } else {
                card.classList.add('hidden');
            }
        });

        resultCount.textContent = 'Hiển thị ' + visibleCount + ' / ' + cards.length + ' sản phẩm';
        noResult.style.display = visibleCount === 0 ? 'block' : 'none';
    }

    // Xóa toàn bộ bộ lọc
    btnReset.addEventListener('click', () => {
        searchInput.value    = '';
        categoryFilter.value = '';
        priceMin.value       = '';
        priceMax.value       = '';
        selectedSizes.clear();
        sizeBtns.forEach(btn => btn.classList.remove('active'));
        applyFilter();
    });

    // ===== Đọc query param ?category=... từ URL để pre-filter khi vào từ trang chủ =====
    (function() {
        var params = new URLSearchParams(window.location.search);
        var cat = params.get('category');
        if (cat) {
            // Pre-fill dropdown đúng với category được chọn
            categoryFilter.value = cat;
        }
        // Luôn chạy applyFilter dù có param hay không
        applyFilter();
    })();

    // ===== Cập nhật badge từ JSON server trả về =====
    function updateCartBadge(count) {
        var badge = document.getElementById('cartBadge');
        if (count > 0) {
            badge.textContent   = count > 99 ? '99+' : count;
            badge.style.display = 'flex';
        } else {
            badge.style.display = 'none';
        }
    }

    // Khởi tạo badge từ số lượng server render vào trang (Session)
    updateCartBadge(<%= session.getAttribute("cartCount") != null ? session.getAttribute("cartCount") : 0 %>);
    
    // ===== MODAL GIỎ HÀNG =====
    // Lưu tạm thông tin sản phẩm đang thao tác trong modal
    var _modal = { productId: null, name: '', price: 0, imageUrl: '', selectedSize: '', variantPrices: {} };

    // Dùng event listener thay vì onclick inline — tránh lỗi ký tự đặc biệt trong tên sản phẩm
    document.querySelectorAll('.btn-open-modal:not([disabled])').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var productId    = this.dataset.productId;
            var name         = this.dataset.productName;
            var defaultPrice = parseFloat(this.dataset.productPrice) || 0;
            var imageUrl     = this.dataset.productImage;
            var sizesStr     = this.dataset.productSizes;
            var variantPrices = {};

            // Parse JSON variantPrices từ data attribute
            try {
                variantPrices = JSON.parse(this.dataset.variantPrices || '{}');
            } catch (e) {
                variantPrices = {};
            }

            _modal.productId     = parseInt(productId);
            _modal.name          = name;
            _modal.price         = defaultPrice;
            _modal.imageUrl      = imageUrl;
            _modal.selectedSize  = '';
            _modal.variantPrices = variantPrices;

            document.getElementById('modalImg').src          = imageUrl;
            document.getElementById('modalImg').alt          = name;
            document.getElementById('modalName').textContent = name;
            document.getElementById('modalPrice').textContent =
                'Từ ' + Math.round(defaultPrice).toLocaleString('vi-VN') + ' đ';

            // Render nút size
            var sizesContainer = document.getElementById('modalSizes');
            sizesContainer.innerHTML = '';
            sizesStr.split(',').filter(function(s) { return s.trim() !== ''; })
                .forEach(function(size) {
                    var sizeBtn = document.createElement('button');
                    sizeBtn.className   = 'modal-size-btn';
                    sizeBtn.textContent = size.trim();
                    sizeBtn.addEventListener('click', function() {
                        selectModalSize(this, size.trim());
                    });
                    sizesContainer.appendChild(sizeBtn);
                });

            document.getElementById('modalBtnAdd').disabled = true;
            document.getElementById('cartModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        });
    });

    function closeCartModal() {
        document.getElementById('cartModal').style.display = 'none';
        document.body.style.overflow = '';
    }

    function selectModalSize(btn, size) {
        document.querySelectorAll('.modal-size-btn').forEach(function(b) {
            b.classList.remove('active');
        });
        btn.classList.add('active');
        _modal.selectedSize = size;

        // Cập nhật giá theo size được chọn từ variantPrices
        var priceEl = document.getElementById('modalPrice');
        if (_modal.variantPrices && _modal.variantPrices[size] !== undefined) {
            var sizePrice = _modal.variantPrices[size];
            _modal.price  = sizePrice; // Cập nhật giá hiện tại để lưu vào giỏ
            priceEl.textContent = Math.round(sizePrice).toLocaleString('vi-VN') + ' đ';
        }

        document.getElementById('modalBtnAdd').disabled = false;
    }

    function confirmAddToCart() {
        if (!_modal.selectedSize) return;

        // Chặn double-click
        var addBtn = document.getElementById('modalBtnAdd');
        addBtn.disabled = true;
        addBtn.textContent = 'Đang thêm...';

        // Frontend chỉ gửi productId lên server — backend tự lấy thông tin từ DB
        fetch('<%= request.getContextPath() %>/cart?action=add', {
            method  : 'POST',
            headers : { 'Content-Type': 'application/x-www-form-urlencoded' },
            body    : 'productId=' + _modal.productId
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.success) {
                // Cập nhật badge bằng số server trả về
                updateCartBadge(data.cartCount);
                closeCartModal();
                showToast('✓ Đã thêm "' + _modal.name + '" vào giỏ hàng!');
            } else {
                showToast('✗ ' + (data.message || 'Có lỗi xảy ra'));
                addBtn.disabled = false;
                addBtn.textContent = 'Thêm vào Giỏ hàng';
            }
        })
        .catch(function() {
            showToast('✗ Không thể kết nối server');
            addBtn.disabled = false;
            addBtn.textContent = 'Thêm vào Giỏ hàng';
        });
    }
    
    // ===== TOAST =====
    var toastTimer = null;

    function showToast(message) {
        document.getElementById('toast-message').textContent = message;
        var toast = document.getElementById('toast');
        toast.classList.add('show');

        // Tự động ẩn sau 3 giây, reset nếu gọi liên tiếp
        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(closeToast, 3000);
    }

    function closeToast() {
        document.getElementById('toast').classList.remove('show');
        if (toastTimer) { clearTimeout(toastTimer); toastTimer = null; }
    }

    // Nhấn ESC: đóng modal nếu đang mở, nếu không thì đóng toast
    document.addEventListener('keydown', function(e) {
        if (e.key !== 'Escape') return;
        if (document.getElementById('cartModal').style.display === 'block') {
            closeCartModal();
        } else {
            closeToast();
        }
    });
</script>

</body>
</html>
