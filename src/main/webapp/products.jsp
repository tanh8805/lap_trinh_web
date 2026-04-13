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
       <a href="<%= request.getContextPath() %>/cart" class="cart-link" title="Giỏ hàng">
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
                    <% if (!sizesAttr.isEmpty()) { %>
                        <p class="product-sizes">Size: <%= sizesAttr %></p>
                    <% } %>
                    <a href="products/detail?id=<%= p.getId() %>" class="btn-view">Xem chi tiết</a>
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

    function updateCartBadge(count) {
    var badge = document.getElementById('cartBadge');
    if (count > 0) {
        badge.textContent   = count > 99 ? '99+' : count;
        badge.style.display = 'flex';
    } else {
        badge.style.display = 'none';
    }
}

        // Gọi server lấy số lượng khi tải trang
        fetch('<%= request.getContextPath()%>/cart/count')
            .then(function(r) { return r.json(); })
            .then(function(d) { updateCartBadge(d.cartCount || 0); })
            .catch(function() {});function updateCartBadge(count) {
            var badge = document.getElementById('cartBadge');
            if (count > 0) {
                badge.textContent   = count > 99 ? '99+' : count;
                badge.style.display = 'flex';
            } else {
                badge.style.display = 'none';
            }
        }

        // Gọi server lấy số lượng khi tải trang
        fetch('<%= request.getContextPath()%>/cart/count')
            .then(function(r) { return r.json(); })
            .then(function(d) { updateCartBadge(d.cartCount || 0); })
            .catch(function() {});
</script>

</body>
</html>
