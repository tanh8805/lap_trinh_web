<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="com.example.shopweb.model.CartItem"%>

<%
    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

    // Demo data de test ngay khi chua co san pham that
    if (cart == null || cart.isEmpty()) {
        cart = new ArrayList<>();
        cart.add(new CartItem(
                1,
                1,
                "Nike Style Tee",
                "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=800&auto=format&fit=crop",
                "M",
                300000,
                2
        ));
        cart.add(new CartItem(
                2,
                2,
                "Training Shorts",
                "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=800&auto=format&fit=crop",
                "L",
                500000,
                1
        ));
        session.setAttribute("cart", cart);
    }

    String selectedIdsParam = request.getParameter("selectedIds");
    String discountParam = request.getParameter("discountAmount");

    List<Integer> selectedIds = new ArrayList<>();
    if (selectedIdsParam != null && !selectedIdsParam.trim().isEmpty()) {
        for (String s : selectedIdsParam.split(",")) {
            try {
                selectedIds.add(Integer.parseInt(s.trim()));
            } catch (Exception e) {
                // Bo qua gia tri loi
            }
        }
    }

    if (selectedIds.isEmpty()) {
        for (CartItem item : cart) {
            selectedIds.add(item.getVariantId());
        }
    }

    double passedDiscount = 0;
    try {
        if (discountParam != null && !discountParam.trim().isEmpty()) {
            passedDiscount = Double.parseDouble(discountParam.trim());
        }
    } catch (Exception e) {
        passedDiscount = 0;
    }

    List<CartItem> selectedItems = new ArrayList<>();
    double subtotal = 0;

    for (CartItem item : cart) {
        if (selectedIds.contains(item.getVariantId())) {
            selectedItems.add(item);
            subtotal += item.getSubtotal();
        }
    }

    StringBuilder idsBuilder = new StringBuilder();
    for (int i = 0; i < selectedItems.size(); i++) {
        if (i > 0) idsBuilder.append(",");
        idsBuilder.append(selectedItems.get(i).getVariantId());
    }
    selectedIdsParam = idsBuilder.toString();

    double defaultShipping = subtotal >= 1000000 ? 0 : 30000;
    double total = subtotal + defaultShipping - passedDiscount;
    if (total < 0) total = 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán | ShopWeb</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, Helvetica, sans-serif;
        }

        body {
            background: #ffffff;
            color: #111111;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        .topbar {
            height: 72px;
            border-bottom: 1px solid #ececec;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #fff;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .topbar-inner {
            width: 100%;
            max-width: 1280px;
            padding: 0 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .brand {
            font-size: 28px;
            font-weight: 900;
            letter-spacing: 0.5px;
        }

        .topbar-right {
            font-size: 13px;
            color: #666;
            font-weight: 600;
        }

        .page {
            max-width: 1280px;
            margin: 0 auto;
            padding: 32px;
        }

        .breadcrumb {
            font-size: 13px;
            color: #8a8a8a;
            margin-bottom: 22px;
        }

        .checkout-layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 420px;
            gap: 56px;
            align-items: start;
        }

        .hero {
            margin-bottom: 34px;
        }

        .hero-title {
            font-size: 42px;
            line-height: 1.08;
            font-weight: 900;
            letter-spacing: -1px;
            margin-bottom: 12px;
        }

        .hero-desc {
            max-width: 760px;
            color: #666;
            font-size: 15px;
            line-height: 1.7;
        }

        .section {
            padding: 0 0 34px 0;
            margin-bottom: 34px;
            border-bottom: 1px solid #efefef;
        }

        .section-title {
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 18px;
        }

        .section-note {
            font-size: 14px;
            color: #666;
            line-height: 1.7;
            margin-bottom: 18px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .full {
            grid-column: 1 / -1;
        }

        label {
            font-size: 13px;
            font-weight: 700;
            color: #222;
        }

        input, select, textarea {
            width: 100%;
            min-height: 54px;
            padding: 14px 16px;
            border: 1px solid #d9d9d9;
            border-radius: 12px;
            background: #fff;
            color: #111;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        textarea {
            min-height: 110px;
            resize: vertical;
        }

        input:focus, select:focus, textarea:focus {
            border-color: #111;
            box-shadow: 0 0 0 3px rgba(17,17,17,0.06);
        }

        .choice-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .choice-card {
            border: 1px solid #dfdfdf;
            border-radius: 16px;
            padding: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            cursor: pointer;
            transition: border-color 0.2s ease, background 0.2s ease;
        }

        .choice-card:hover {
            border-color: #111;
            background: #fafafa;
        }

        .choice-left {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }

        .choice-left input[type="radio"] {
            width: 18px;
            height: 18px;
            margin-top: 2px;
            accent-color: #111;
        }

        .choice-title {
            font-size: 15px;
            font-weight: 800;
            margin-bottom: 4px;
        }

        .choice-desc {
            font-size: 13px;
            color: #666;
            line-height: 1.55;
        }

        .choice-price {
            font-size: 14px;
            font-weight: 800;
            white-space: nowrap;
        }

        .summary-box {
            position: sticky;
            top: 104px;
            border: 1px solid #ececec;
            border-radius: 22px;
            padding: 28px;
            background: #fff;
        }

        .summary-title {
            font-size: 26px;
            font-weight: 900;
            margin-bottom: 8px;
        }

        .summary-subtitle {
            font-size: 14px;
            color: #666;
            line-height: 1.7;
            margin-bottom: 22px;
        }

        .product-list {
            display: flex;
            flex-direction: column;
            gap: 18px;
            margin-bottom: 22px;
        }

        .product-item {
            display: grid;
            grid-template-columns: 84px minmax(0, 1fr);
            gap: 14px;
        }

        .product-item img {
            width: 84px;
            height: 84px;
            object-fit: cover;
            border-radius: 14px;
            background: #f3f3f3;
            border: 1px solid #efefef;
        }

        .product-top {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 6px;
        }

        .product-name {
            font-size: 15px;
            font-weight: 800;
            line-height: 1.45;
        }

        .product-price {
            font-size: 15px;
            font-weight: 800;
            white-space: nowrap;
        }

        .product-meta {
            font-size: 13px;
            color: #666;
            line-height: 1.6;
        }

        .promo-wrap {
            margin: 22px 0;
        }

        .promo-label {
            display: block;
            font-size: 12px;
            font-weight: 800;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            margin-bottom: 10px;
        }

        .promo-row {
            display: grid;
            grid-template-columns: 1fr 110px;
            gap: 10px;
        }

        .promo-btn {
            border: none;
            border-radius: 12px;
            background: #111;
            color: #fff;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
        }

        .promo-msg {
            min-height: 18px;
            margin-top: 10px;
            font-size: 12px;
        }

        .promo-msg.ok {
            color: #27ae60;
        }

        .promo-msg.err {
            color: #e74c3c;
        }

        .summary-lines {
            border-top: 1px solid #efefef;
            padding-top: 20px;
        }

        .line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            margin-bottom: 14px;
            color: #444;
        }

        .line.discount {
            color: #27ae60;
        }

        .line.total {
            padding-top: 18px;
            margin-top: 18px;
            margin-bottom: 0;
            border-top: 1px solid #efefef;
            font-size: 24px;
            font-weight: 900;
            color: #111;
        }

        .order-btn {
            width: 100%;
            height: 58px;
            margin-top: 26px;
            border: none;
            border-radius: 999px;
            background: #111;
            color: #fff;
            font-size: 16px;
            font-weight: 800;
            cursor: pointer;
        }

        .secure-note {
            margin-top: 14px;
            text-align: center;
            color: #777;
            font-size: 12px;
            line-height: 1.6;
        }

        @media (max-width: 1100px) {
            .checkout-layout {
                grid-template-columns: 1fr;
                gap: 30px;
            }

            .summary-box {
                position: static;
            }
        }

        @media (max-width: 640px) {
            .topbar-inner,
            .page {
                padding-left: 16px;
                padding-right: 16px;
            }

            .hero-title {
                font-size: 32px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .promo-row {
                grid-template-columns: 1fr;
            }

            .product-item {
                grid-template-columns: 1fr;
            }

            .product-item img {
                width: 100%;
                height: 220px;
            }
        }
    </style>
</head>
<body>

<div class="topbar">
    <div class="topbar-inner">
        <a href="<%= request.getContextPath() %>/index.jsp" class="brand">SHOPWEB</a>
        <div class="topbar-right">Secure Checkout</div>
    </div>
</div>

<div class="page">
    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/cart">Giỏ hàng</a> &gt; Thanh toán
    </div>

    <div class="checkout-layout">
        <div>
            <div class="hero">
                <div class="hero-title">Thông tin giao hàng</div>
                <div class="hero-desc">
                    Đây là bản demo để bạn test giao diện và luồng thanh toán trước khi có dữ liệu sản phẩm thật.
                </div>
            </div>

            <form action="<%= request.getContextPath() %>/cart" method="post" id="checkoutForm">
                <input type="hidden" name="action" value="checkout">
                <input type="hidden" name="selectedIds" value="<%= selectedIdsParam %>">
                <input type="hidden" name="discountAmount" id="discountAmountInput" value="<%= passedDiscount %>">

                <div class="section">
                    <div class="section-title">Thông tin người nhận</div>
                    <div class="section-note">Nhập thông tin cơ bản để test submit checkout.</div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="fullName">Họ và tên</label>
                            <input type="text" id="fullName" placeholder="Nguyễn Văn A">
                        </div>

                        <div class="form-group">
                            <label for="phone">Số điện thoại</label>
                            <input type="text" id="phone" placeholder="09xxxxxxxx">
                        </div>

                        <div class="form-group full">
                            <label for="address">Địa chỉ giao hàng</label>
                            <textarea name="address" id="address" placeholder="Số nhà, tên đường, phường/xã..." required></textarea>
                        </div>

                        <div class="form-group">
                            <label for="city">Tỉnh / Thành phố</label>
                            <select id="city">
                                <option value="">Chọn tỉnh / thành phố</option>
                                <option>Hồ Chí Minh</option>
                                <option>Hà Nội</option>
                                <option>Đà Nẵng</option>
                                <option>Cần Thơ</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="district">Quận / Huyện</label>
                            <input type="text" id="district" placeholder="Quận / Huyện">
                        </div>
                    </div>
                </div>

                <div class="section">
                    <div class="section-title">Phương thức giao hàng</div>
                    <div class="choice-list">
                        <label class="choice-card">
                            <div class="choice-left">
                                <input type="radio" name="shippingMethodUi" value="standard" checked>
                                <div>
                                    <div class="choice-title">Giao hàng tiêu chuẩn</div>
                                    <div class="choice-desc">Nhận hàng trong 3 - 5 ngày làm việc.</div>
                                </div>
                            </div>
                            <div class="choice-price">30.000đ</div>
                        </label>

                        <label class="choice-card">
                            <div class="choice-left">
                                <input type="radio" name="shippingMethodUi" value="fast">
                                <div>
                                    <div class="choice-title">Giao hàng nhanh</div>
                                    <div class="choice-desc">Nhận hàng trong 1 - 2 ngày làm việc.</div>
                                </div>
                            </div>
                            <div class="choice-price">45.000đ</div>
                        </label>
                    </div>
                </div>

                <div class="section">
                    <div class="section-title">Phương thức thanh toán</div>
                    <div class="choice-list">
                        <label class="choice-card">
                            <div class="choice-left">
                                <input type="radio" name="paymentMethodUi" value="cod" checked>
                                <div>
                                    <div class="choice-title">Thanh toán khi nhận hàng</div>
                                    <div class="choice-desc">Thanh toán trực tiếp khi nhận sản phẩm.</div>
                                </div>
                            </div>
                        </label>

                        <label class="choice-card">
                            <div class="choice-left">
                                <input type="radio" name="paymentMethodUi" value="banking">
                                <div>
                                    <div class="choice-title">Chuyển khoản ngân hàng</div>
                                    <div class="choice-desc">Tùy chọn demo để test UI.</div>
                                </div>
                            </div>
                        </label>
                    </div>
                </div>
            </form>
        </div>

        <div>
            <div class="summary-box">
                <div class="summary-title">Đơn hàng</div>
                <div class="summary-subtitle">
                    <%= selectedItems.size() %> sản phẩm demo đang được dùng để test checkout.
                </div>

                <div class="product-list">
                    <% for (CartItem item : selectedItems) { %>
                    <div class="product-item">
                        <img src="<%= item.getImageUrl() %>" alt="<%= item.getName() %>">
                        <div>
                            <div class="product-top">
                                <div class="product-name"><%= item.getName() %></div>
                                <div class="product-price"><%= String.format("%,.0f", item.getSubtotal()) %>đ</div>
                            </div>
                            <div class="product-meta">
                                Size: <%= item.getSize() %><br>
                                Đơn giá: <%= String.format("%,.0f", item.getPrice()) %>đ<br>
                                Số lượng: <%= item.getQuantity() %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="promo-wrap">
                    <span class="promo-label">Mã giảm giá</span>
                    <div class="promo-row">
                        <input type="text" id="promoCode" placeholder="Nhập mã voucher">
                        <button type="button" class="promo-btn" onclick="applyPromo()">Áp dụng</button>
                    </div>
                    <div class="promo-msg" id="promoMsg"></div>
                </div>

                <div class="summary-lines">
                    <div class="line">
                        <span>Tạm tính</span>
                        <span id="subtotalText"><%= String.format("%,.0f", subtotal) %>đ</span>
                    </div>

                    <div class="line">
                        <span>Phí vận chuyển</span>
                        <span id="shippingText"><%= String.format("%,.0f", defaultShipping) %>đ</span>
                    </div>

                    <div class="line discount" id="discountRow" style="<%= passedDiscount > 0 ? "display:flex;" : "display:none;" %>">
                        <span>Giảm giá</span>
                        <span id="discountText">-<%= String.format("%,.0f", passedDiscount) %>đ</span>
                    </div>

                    <div class="line total">
                        <span>Tổng cộng</span>
                        <span id="totalText"><%= String.format("%,.0f", total) %>đ</span>
                    </div>
                </div>

                <button type="button" class="order-btn" onclick="submitCheckout()">Đặt hàng</button>
                <div class="secure-note">Bản demo để test giao diện và luồng submit.</div>
            </div>
        </div>
    </div>
</div>

<script>
    var subtotal = <%= subtotal %>;
    var discountAmount = <%= passedDiscount %>;

    function formatVND(value) {
        return Math.round(value).toLocaleString('vi-VN') + 'đ';
    }

    function getShippingFee() {
        var selected = document.querySelector('input[name="shippingMethodUi"]:checked');
        if (!selected) {
            return subtotal >= 1000000 ? 0 : 30000;
        }
        if (selected.value === 'fast') {
            return 45000;
        }
        return subtotal >= 1000000 ? 0 : 30000;
    }

    function updateSummary() {
        var shippingFee = getShippingFee();
        var total = subtotal + shippingFee - discountAmount;
        if (total < 0) total = 0;

        document.getElementById('shippingText').innerText = formatVND(shippingFee);
        document.getElementById('subtotalText').innerText = formatVND(subtotal);
        document.getElementById('totalText').innerText = formatVND(total);
        document.getElementById('discountAmountInput').value = discountAmount;

        var discountRow = document.getElementById('discountRow');
        if (discountAmount > 0) {
            discountRow.style.display = 'flex';
            document.getElementById('discountText').innerText = '-' + formatVND(discountAmount);
        } else {
            discountRow.style.display = 'none';
        }
    }

    function applyPromo() {
        var promoInput = document.getElementById('promoCode');
        var promoMsg = document.getElementById('promoMsg');
        var code = promoInput.value.trim().toUpperCase();

        promoMsg.className = 'promo-msg';

        if (code === '') {
            discountAmount = 0;
            promoMsg.className += ' err';
            promoMsg.innerText = 'Vui lòng nhập mã giảm giá.';
            updateSummary();
            return;
        }

        if (code === 'GIAM10') {
            discountAmount = Math.round(subtotal * 0.1);
            promoMsg.className += ' ok';
            promoMsg.innerText = 'Áp dụng mã GIAM10 thành công.';
        } else if (code === 'GIAM50K' && subtotal >= 200000) {
            discountAmount = 50000;
            promoMsg.className += ' ok';
            promoMsg.innerText = 'Áp dụng mã GIAM50K thành công.';
        } else if (code === 'SALE20' && subtotal >= 500000) {
            discountAmount = Math.round(subtotal * 0.2);
            promoMsg.className += ' ok';
            promoMsg.innerText = 'Áp dụng mã SALE20 thành công.';
        } else if (code === 'FREESHIP') {
            discountAmount = 30000;
            promoMsg.className += ' ok';
            promoMsg.innerText = 'Áp dụng mã FREESHIP thành công.';
        } else {
            discountAmount = 0;
            promoMsg.className += ' err';
            promoMsg.innerText = 'Mã không hợp lệ hoặc chưa đủ điều kiện áp dụng.';
        }

        updateSummary();
    }

    function submitCheckout() {
        var fullName = document.getElementById('fullName').value.trim();
        var phone = document.getElementById('phone').value.trim();
        var address = document.getElementById('address').value.trim();
        var city = document.getElementById('city').value.trim();

        if (fullName === '') {
            alert('Vui lòng nhập họ và tên.');
            document.getElementById('fullName').focus();
            return;
        }

        if (phone === '') {
            alert('Vui lòng nhập số điện thoại.');
            document.getElementById('phone').focus();
            return;
        }

        if (!/^[0-9]{9,11}$/.test(phone)) {
            alert('Số điện thoại không hợp lệ.');
            document.getElementById('phone').focus();
            return;
        }

        if (address === '') {
            alert('Vui lòng nhập địa chỉ giao hàng.');
            document.getElementById('address').focus();
            return;
        }

        if (city === '') {
            alert('Vui lòng chọn tỉnh / thành phố.');
            document.getElementById('city').focus();
            return;
        }

        document.getElementById('checkoutForm').submit();
    }

    document.querySelectorAll('input[name="shippingMethodUi"]').forEach(function(radio) {
        radio.addEventListener('change', updateSummary);
    });

    updateSummary();
</script>

</body>
</html>