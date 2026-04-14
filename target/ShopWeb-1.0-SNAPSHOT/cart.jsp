<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.shopweb.model.CartItem" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopWeb - Giỏ hàng</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa; color: #333;
            display: flex; flex-direction: column; min-height: 100vh;
        }

        /* ===== NAVBAR ===== */
        nav {
            background: #fff; padding: 15px 50px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }
        .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; color: #000; text-decoration: none; }
        .menu { display: flex; align-items: center; }
        .menu a { margin-left: 25px; text-decoration: none; color: #555; font-weight: 500; transition: color 0.3s; }
        .menu a:hover { color: #000; }
        .menu a.active { color: #000; font-weight: 700; }

        /* ===== ALERT ===== */
        .alert {
            max-width: 1100px; width: calc(100% - 40px);
            margin: 16px auto 0; padding: 13px 20px;
            border-radius: 8px; font-size: 14px; font-weight: 500;
        }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error   { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* ===== LAYOUT ===== */
        .page-wrapper {
            flex: 1; max-width: 1100px; margin: 28px auto;
            width: 100%; padding: 0 20px;
            display: flex; gap: 28px; align-items: flex-start;
        }

        /* ===== COT TRAI ===== */
        .cart-main { flex: 1; min-width: 0; }

        .cart-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 16px;
        }
        .cart-header h2 { font-size: 24px; font-weight: 700; color: #111; }
        .select-all-label {
            display: flex; align-items: center; gap: 8px;
            font-size: 14px; color: #555; cursor: pointer; user-select: none;
        }
        .select-all-label input[type="checkbox"] {
            width: 17px; height: 17px; accent-color: #000; cursor: pointer;
        }

        /* Gio trong */
        .cart-empty {
            text-align: center; padding: 70px 20px; background: #fff;
            border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.04);
        }
        .cart-empty-icon { font-size: 68px; display: block; margin-bottom: 18px; opacity: 0.35; }
        .cart-empty h3 { font-size: 21px; color: #444; margin-bottom: 10px; }
        .cart-empty p  { font-size: 14px; color: #999; margin-bottom: 28px; line-height: 1.6; }
        .btn-continue {
            display: inline-block; padding: 12px 32px; background: #000;
            color: #fff; text-decoration: none; border-radius: 4px;
            font-weight: 600; font-size: 15px; transition: background 0.3s;
        }
        .btn-continue:hover { background: #333; }

        /* ===== BANG SAN PHAM ===== */
        .cart-table {
            width: 100%; border-collapse: collapse; background: #fff;
            border-radius: 10px; overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.04);
        }
        .cart-table th {
            text-align: left; padding: 13px 16px; font-size: 12px;
            font-weight: 700; color: #888; text-transform: uppercase;
            letter-spacing: 0.6px; border-bottom: 2px solid #eee;
        }
        .cart-table th.th-check { width: 44px; text-align: center; }
        .cart-table td {
            padding: 14px 16px; vertical-align: middle;
            border-bottom: 1px solid #f0f0f0; transition: background 0.15s;
        }
        .cart-table tr:last-child td { border-bottom: none; }
        .cart-table tbody tr:hover td { background: #fafafa; }
        .cart-table tbody tr.selected td { background: #f8fff5; }
        .cart-table tbody tr.selected:hover td { background: #f2fded; }

        /* Checkbox moi dong */
        .row-check { width: 17px; height: 17px; accent-color: #000; cursor: pointer; display: block; margin: 0 auto; }

        /* Anh + ten */
        .product-cell { display: flex; align-items: center; gap: 14px; }
        .product-img { width: 68px; height: 68px; object-fit: cover; border-radius: 8px; background: #eee; flex-shrink: 0; }
        .product-name { font-size: 15px; font-weight: 600; color: #222; }
        .product-price-unit { font-size: 12px; color: #aaa; margin-top: 3px; }

        /* Tang giam so luong */
        .qty-wrap {
            display: inline-flex; align-items: center;
            border: 1.5px solid #ddd; border-radius: 6px; overflow: hidden;
        }
        .qty-form { display: contents; }
        .qty-btn {
            width: 30px; height: 30px; border: none; background: #f5f5f5;
            font-size: 16px; cursor: pointer; color: #333; font-weight: 700;
            transition: background 0.15s; line-height: 1;
        }
        .qty-btn:hover { background: #e0e0e0; }
        .qty-val {
            width: 36px; height: 30px; text-align: center; line-height: 30px;
            border-left: 1px solid #ddd; border-right: 1px solid #ddd;
            font-size: 14px; font-weight: 600; color: #111; background: #fff;
        }

        /* Thành tiền */
        .item-subtotal { font-size: 15px; font-weight: 700; color: #e74c3c; white-space: nowrap; }

        /* Nut xoa */
        .btn-remove {
            background: none; border: none; cursor: pointer;
            color: #ccc; font-size: 18px; padding: 4px; transition: color 0.2s;
        }
        .btn-remove:hover { color: #e74c3c; }

        /* ===== COT PHAI: TOM TAT ===== */
        .cart-summary {
            width: 300px; flex-shrink: 0; background: #fff;
            border-radius: 12px; padding: 24px 22px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            position: sticky; top: 80px;
        }
        .cart-summary h3 { font-size: 17px; font-weight: 700; color: #111; margin-bottom: 20px; }

        /* Voucher */
        .voucher-label { font-size: 12px; font-weight: 700; color: #888; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; display: block; }
        .voucher-row { display: flex; gap: 7px; margin-bottom: 6px; }
        .voucher-row input {
            flex: 1; padding: 9px 11px; border: 1.5px solid #ddd;
            border-radius: 6px; font-size: 13px; outline: none;
            text-transform: uppercase; transition: border-color 0.2s;
        }
        .voucher-row input:focus { border-color: #000; }
        .btn-voucher {
            padding: 9px 13px; background: #000; color: #fff; border: none;
            border-radius: 6px; font-size: 13px; font-weight: 600;
            cursor: pointer; white-space: nowrap; transition: background 0.2s;
        }
        .btn-voucher:hover { background: #333; }
        .voucher-msg { font-size: 12px; min-height: 16px; margin-bottom: 4px; }
        .voucher-msg.ok  { color: #27ae60; }
        .voucher-msg.err { color: #e74c3c; }
        .voucher-tag {
            display: none; align-items: center; justify-content: space-between;
            background: #f0fff4; border: 1.5px solid #27ae60;
            border-radius: 6px; padding: 7px 11px;
            font-size: 12px; color: #27ae60; font-weight: 600; margin-bottom: 6px;
        }
        .btn-rm-voucher {
            background: none; border: none; cursor: pointer;
            color: #27ae60; font-size: 14px; font-weight: 700; padding: 0 0 0 6px;
        }
        .btn-rm-voucher:hover { color: #e74c3c; }

        .divider { height: 1px; background: #eee; margin: 14px 0; }

        .sum-row {
            display: flex; justify-content: space-between; align-items: baseline;
            font-size: 14px; color: #666; margin-bottom: 9px;
        }
        .sum-row.discount { color: #27ae60; }
        .sum-row.total { font-size: 16px; font-weight: 700; color: #111; margin-bottom: 0; }

        .warn-select { display: none; font-size: 12px; color: #e74c3c; text-align: center; margin-top: 8px; }

        .btn-checkout {
            width: 100%; padding: 13px; background: #000; color: #fff;
            border: none; border-radius: 8px; font-size: 15px; font-weight: 700;
            cursor: pointer; transition: background 0.3s; margin-top: 16px;
        }
        .btn-checkout:hover { background: #222; }
        .btn-checkout:disabled { background: #bbb; cursor: not-allowed; }

        .selected-summary { font-size: 12px; color: #999; text-align: center; margin-top: 8px; }

        footer { background: #111; color: #fff; text-align: center; padding: 20px; font-size: 14px; margin-top: auto; }

        @media (max-width: 800px) {
            .page-wrapper { flex-direction: column; }
            .cart-summary { width: 100%; position: static; }
            nav { padding: 15px 20px; }
        }
    </style>
</head>
<body>

<nav>
    <a href="index.jsp" class="logo">ShopWeb</a>
    <div class="menu">
        <a href="products">Sản phẩm</a>
        <a href="<%= request.getContextPath() %>/orders">Đơn hàng</a>
        <% if (session.getAttribute("loggedInUser") != null) { %>
            <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
        <% } else { %>
            <a href="login.jsp">Đăng nhập</a>
            <a href="register.jsp">Đăng ký</a>
        <% } %>
        <a href="<%= request.getContextPath() %>/cart" class="active" style="font-size:22px;">&#128722;</a>
    </div>
</nav>

<% if ("true".equals(request.getParameter("orderSuccess"))) { %>
    <div class="alert alert-success">&#10003; Đặt hàng thành công! Chúng tôi sẽ liên hệ xác nhận sớm nhất.</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-error">&#9888; <%= request.getAttribute("error") %></div>
<% } %>

<%
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cart");
    Double cartTotal         = (Double) request.getAttribute("total");
    if (cartItems == null) cartItems = new java.util.ArrayList<>();
    if (cartTotal  == null) cartTotal = 0.0;
    boolean isEmpty = cartItems.isEmpty();
    int itemCount   = cartItems.size();
%>

<div class="page-wrapper">

    <div class="cart-main">
        <div class="cart-header">
            <h2>Giỏ hàng (<%= itemCount %> sản phẩm)</h2>
            <% if (!isEmpty) { %>
            <label class="select-all-label">
                <input type="checkbox" id="checkAll"> Chọn tất cả
            </label>
            <% } %>
        </div>

        <% if (isEmpty) { %>
            <div class="cart-empty">
                <span class="cart-empty-icon">&#128722;</span>
                <h3>Giỏ hàng đang trống</h3>
                <p>Bạn chưa thêm sản phẩm nào.<br>Hãy khám phá bộ sưu tập của chúng tôi!</p>
                <a href="products" class="btn-continue">← Tiếp tục mua sắm</a>
            </div>

        <% } else { %>
            <table class="cart-table">
                <thead>
                    <tr>
                        <th class="th-check"></th>
                        <th>Sản phẩm</th>
                        <th>Size</th>
                        <th>Số lượng</th>
                        <th>Thành tiền</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="cartBody">
                <%
                    int rowIndex = 0;
                    for (CartItem item : cartItems) {
                        String imgSrc = (item.getImageUrl() != null && !item.getImageUrl().isEmpty())
                            ? (item.getImageUrl().startsWith("http") ? item.getImageUrl()
                                : request.getContextPath() + "/" + item.getImageUrl())
                            : request.getContextPath() + "/images/no-image.jpg";
                %>
                    <tr id="row-<%= rowIndex %>">
                        <td style="text-align:center;">
                            <input type="checkbox" class="row-check"
                                   data-index="<%= rowIndex %>"
                                   data-variant-id="<%= item.getVariantId() %>"
                                   data-subtotal="<%= item.getSubtotal() %>"
                                   checked>
                        </td>
                        <td>
                            <div class="product-cell">
                                <img src="<%= imgSrc %>" alt="<%= item.getName() %>" class="product-img"
                                     onerror="this.src='<%= request.getContextPath() %>/images/no-image.jpg'">
                                <div>
                                    <div class="product-name"><%= item.getName() %></div>
                                    <div class="product-price-unit"><%= String.format("%,.0f", item.getPrice()) %> đ / cái</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <%-- Nut size: bam de mo popup doi size --%>
                            <button class="btn-change-size"
                                    data-variant-id="<%= item.getVariantId() %>"
                                    data-product-id="<%= item.getProductId() %>"
                                    data-current-size="<%= item.getSize() != null ? item.getSize() : "" %>"
                                    style="padding:4px 12px;border:1.5px solid #ddd;border-radius:5px;font-size:13px;font-weight:700;color:#333;background:#f9f9f9;cursor:pointer;transition:all 0.15s;"
                                    title="Bấm để đổi size"
                                    onmouseover="this.style.borderColor='#000'"
                                    onmouseout="this.style.borderColor='#ddd'">
                                <%= item.getSize() != null && !item.getSize().isEmpty() ? item.getSize() : "-" %>
                                <span style="font-size:10px;color:#aaa;margin-left:2px;">&#9660;</span>
                            </button>
                        </td>
                        <td>
                            <div class="qty-wrap">
                                <form action="<%= request.getContextPath() %>/cart" method="post" class="qty-form">
                                    <input type="hidden" name="action"    value="update">
                                    <input type="hidden" name="variantId" value="<%= item.getVariantId() %>">
                                    <input type="hidden" name="delta"     value="-1">
                                    <button type="submit" class="qty-btn"
                                        <%= item.getQuantity() <= 1 ? "onclick=\"return confirm('Xóa sản phẩm này khỏi giỏ?')\"" : "" %>>&#8722;</button>
                                </form>
                                <span class="qty-val"><%= item.getQuantity() %></span>
                                <form action="<%= request.getContextPath() %>/cart" method="post" class="qty-form">
                                    <input type="hidden" name="action"    value="update">
                                    <input type="hidden" name="variantId" value="<%= item.getVariantId() %>">
                                    <input type="hidden" name="delta"     value="1">
                                    <button type="submit" class="qty-btn">+</button>
                                </form>
                            </div>
                        </td>
                        <td>
                            <span class="item-subtotal">
                                <%= String.format("%,.0f", item.getSubtotal()) %> đ
                            </span>
                        </td>
                        <td>
                            <form action="<%= request.getContextPath() %>/cart" method="post">
                                <input type="hidden" name="action"    value="remove">
                                <input type="hidden" name="variantId" value="<%= item.getVariantId() %>">
                                <button type="submit" class="btn-remove" title="Xóa"
                                        onclick="return confirm('Xóa sản phẩm này khỏi giỏ?')">&#10005;</button>
                            </form>
                        </td>
                    </tr>
                <%
                        rowIndex++;
                    }
                %>
                </tbody>
            </table>
        <% } %>

        <%-- Nut tro ve trang san pham --%>
        <% if (!isEmpty) { %>
        <div style="margin-top:18px;">
            <a href="<%= request.getContextPath() %>/products"
               style="display:inline-flex;align-items:center;gap:6px;color:#555;font-size:14px;font-weight:500;text-decoration:none;transition:color 0.2s;"
               onmouseover="this.style.color='#000'" onmouseout="this.style.color='#555'">
                &#8592; Tiếp tục mua sắm
            </a>
        </div>
        <% } %>
    </div>

    <% if (!isEmpty) { %>
    <aside class="cart-summary">
        <h3>Tóm tắt đơn hàng</h3>

        <span class="voucher-label">Mã giảm giá</span>
        <div class="voucher-row">
            <input type="text" id="voucherInput" placeholder="Nhập mã voucher..." maxlength="20">
            <button class="btn-voucher" id="btnApplyVoucher">Áp dụng</button>
        </div>
        <div class="voucher-msg" id="voucherMsg"></div>
        <div class="voucher-tag" id="voucherTag">
            <span id="voucherTagText"></span>
            <button class="btn-rm-voucher" id="btnRemoveVoucher">&#10005;</button>
        </div>

        <div class="divider"></div>

        <div class="sum-row">
            <span>Tạm tính (<span id="selectedCount">0</span> sản phẩm)</span>
            <span id="displaySubtotal">0 đ</span>
        </div>
        <div class="sum-row discount" id="discountRow" style="display:none;">
            <span>Giảm giá (<span id="discountLabel"></span>)</span>
            <span id="displayDiscount"></span>
        </div>
        <div class="divider"></div>
        <div class="sum-row total">
            <span>Tổng cộng</span>
            <strong id="displayTotal">0 đ</strong>
        </div>

        <p class="warn-select" id="warnSelect">⚠ Vui lòng chọn ít nhất 1 sản phẩm để thanh toán.</p>

        <form action="<%= request.getContextPath() %>/checkout.jsp" method="get" id="checkoutForm">
    <input type="hidden" name="discountAmount" id="hiddenDiscount" value="0">
    <input type="hidden" name="voucherCode" id="hiddenVoucherCode" value="">
    <div id="selectedIdsContainer"></div>
    <button type="button" class="btn-checkout" id="btnCheckout" disabled>
        🛍 Tiến hành thanh toán
    </button>
</form>
        <p class="selected-summary" id="selectedSummary"></p>
    </aside>
    <% } %>

</div>

<footer>&#169; 2026 ShopWeb. All rights reserved.</footer>

<%-- ===== POPUP DOI SIZE ===== --%>
<div id="changeSizeModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:500;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:14px;padding:26px 26px 22px;max-width:360px;width:90%;position:relative;box-shadow:0 8px 32px rgba(0,0,0,0.18);">
        <button id="btnCloseChangeSize" style="position:absolute;top:12px;right:14px;background:none;border:none;font-size:22px;cursor:pointer;color:#aaa;">&#10005;</button>
        <h3 id="csModalTitle" style="font-size:16px;font-weight:700;color:#111;margin-bottom:16px;padding-right:24px;">Đổi size</h3>
        <p style="font-size:11px;font-weight:700;color:#888;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:10px;">Chọn size mới</p>
        <div id="csSizeList" style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:16px;"></div>
        <div id="csLoading" style="display:none;text-align:center;color:#999;font-size:14px;padding:12px 0;">Đang tải...</div>
        <div id="csError"   style="display:none;color:#e74c3c;font-size:13px;margin-bottom:10px;"></div>
        <button id="btnConfirmChange" disabled
                style="width:100%;padding:12px;background:#000;color:#fff;border:none;border-radius:8px;font-size:14px;font-weight:700;cursor:pointer;opacity:0.4;transition:background 0.2s;">
            Cập nhật size
        </button>
    </div>
</div>

<script>
    // =================================================================
    //  1. Checkbox chon san pham -> cap nhat tom tat don hang realtime
    //  2. Voucher hardcode client-side
    //  3. Checkout: validate -> submit form len CartServlet
    //  Gia moi dong lay tu data-subtotal (server da tinh price * qty)
    // =================================================================

    var VOUCHERS = {
        'GIAM10':   { type: 'percent', value: 10,    minOrder: 0,      desc: 'Giảm 10%' },
        'GIAM50K':  { type: 'fixed',   value: 50000, minOrder: 200000, desc: 'Giảm 50.000đ (đơn từ 200k)' },
        'SALE20':   { type: 'percent', value: 20,    minOrder: 500000, desc: 'Giảm 20% (đơn từ 500k)' },
        'FREESHIP': { type: 'fixed',   value: 30000, minOrder: 0,      desc: 'Giảm 30.000đ phí ship' }
    };

    var appliedVoucher = null;

    function formatVND(n) {
        return Math.round(n).toLocaleString('vi-VN') + ' đ';
    }

    function getRowCheckboxes() {
        return document.querySelectorAll('.row-check');
    }

    // Cap nhat toan bo phan tom tat don hang
    function updateSummary() {
        var checkboxes  = getRowCheckboxes();
        var subtotal    = 0;
        var totalQty    = 0;
        var selectedIds = [];

        checkboxes.forEach(function(cb) {
            var idx = parseInt(cb.dataset.index);
            var row = document.getElementById('row-' + idx);
            if (cb.checked) {
                // Lay gia tu data-subtotal (server da render san: price * quantity)
                subtotal += parseFloat(cb.dataset.subtotal) || 0;
                totalQty++;
                // Dung variantId (khong phai productId) de truyen len CartServlet
                selectedIds.push(cb.dataset.variantId);
                if (row) row.classList.add('selected');
            } else {
                if (row) row.classList.remove('selected');
            }
        });

        // Tinh giam gia tu voucher
        var discount = 0;
        if (appliedVoucher && subtotal >= appliedVoucher.minOrder) {
            discount = appliedVoucher.type === 'percent'
                ? Math.round(subtotal * appliedVoucher.value / 100)
                : Math.min(appliedVoucher.value, subtotal);
        }

        var total = subtotal - discount;

        // Cap nhat DOM
        document.getElementById('selectedCount').textContent   = totalQty;
        document.getElementById('displaySubtotal').textContent = formatVND(subtotal);
        document.getElementById('displayTotal').textContent    = formatVND(total > 0 ? total : 0);
        document.getElementById('selectedSummary').textContent =
            totalQty + ' / ' + checkboxes.length + ' loại được chọn';

        // Dong giam gia
        var discRow = document.getElementById('discountRow');
        if (discount > 0) {
            discRow.style.display = 'flex';
            document.getElementById('discountLabel').textContent   = appliedVoucher.desc;
            document.getElementById('displayDiscount').textContent = '-' + formatVND(discount);
        } else {
            discRow.style.display = 'none';
        }

        // Dien vao hidden inputs de gui len server
        document.getElementById('hiddenDiscount').value    = discount;
        document.getElementById('hiddenVoucherCode').value = appliedVoucher ? appliedVoucher.code : '';
        var selectedIdsContainer = document.getElementById('selectedIdsContainer');
selectedIdsContainer.innerHTML = '';

selectedIds.forEach(function(id) {
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'selectedIds';
    input.value = id;
    selectedIdsContainer.appendChild(input);
});

        // Enable/disable nut checkout
        var btn = document.getElementById('btnCheckout');
        if (btn) btn.disabled = (totalQty === 0);

        // Dong bo "chon tat ca"
        var checkAll = document.getElementById('checkAll');
        if (checkAll) {
            var checked = document.querySelectorAll('.row-check:checked');
            checkAll.checked       = (checkboxes.length > 0 && checked.length === checkboxes.length);
            checkAll.indeterminate = (checked.length > 0 && checked.length < checkboxes.length);
        }
    }

    // Gan event cho tung checkbox dong
    getRowCheckboxes().forEach(function(cb) {
        cb.addEventListener('change', updateSummary);
    });

    // Checkbox "chon tat ca"
    var checkAllEl = document.getElementById('checkAll');
    if (checkAllEl) {
        checkAllEl.addEventListener('change', function() {
            getRowCheckboxes().forEach(function(cb) { cb.checked = checkAllEl.checked; });
            updateSummary();
        });
    }

    // Nut thanh toan
    var btnCheckout = document.getElementById('btnCheckout');
    if (btnCheckout) {
        btnCheckout.addEventListener('click', function() {
            var checked = document.querySelectorAll('.row-check:checked');
            if (checked.length === 0) {
                document.getElementById('warnSelect').style.display = 'block';
                return;
            }
            document.getElementById('warnSelect').style.display = 'none';

            // Luu variantId cua cac o KHONG duoc check vao sessionStorage
            // De sau khi trang reload (orderSuccess), cac o nay van bi bo tick
            // (cac o duoc check se bien mat khoi gio sau checkout)
            var uncheckedIds = [];
            document.querySelectorAll('.row-check:not(:checked)').forEach(function(cb) {
                uncheckedIds.push(cb.dataset.variantId);
            });
            // Dung key rieng de phan biet voi key cua +/- button
            sessionStorage.setItem('cart_uncheck_after_order', JSON.stringify(uncheckedIds));

            document.getElementById('checkoutForm').submit();
        });
    }

    // Áp dụng voucher
    document.getElementById('btnApplyVoucher').addEventListener('click', function() {
        var code = document.getElementById('voucherInput').value.trim().toUpperCase();
        if (!code) { showVoucherMsg('Vui lòng nhập mã voucher.', 'err'); return; }

        var v = VOUCHERS[code];
        if (!v) { showVoucherMsg('Mã không hợp lệ.', 'err'); return; }

        // Tinh subtotal hien tai cua cac san pham dang chon
        var sub = 0;
        document.querySelectorAll('.row-check:checked').forEach(function(cb) {
            sub += parseFloat(cb.dataset.subtotal) || 0;
        });

        if (sub < v.minOrder) {
            showVoucherMsg('Đơn tối thiểu ' + formatVND(v.minOrder) + ' để dùng mã này.', 'err');
            return;
        }

        appliedVoucher = Object.assign({ code: code }, v);
        document.getElementById('voucherInput').disabled = true;
        document.getElementById('btnApplyVoucher').disabled = true;
        document.getElementById('voucherTagText').textContent = '[' + code + '] ' + v.desc;
        document.getElementById('voucherTag').style.display = 'flex';
        showVoucherMsg('Áp dụng thành công!', 'ok');
        updateSummary();
    });

    // Bo voucher
    document.getElementById('btnRemoveVoucher').addEventListener('click', function() {
        appliedVoucher = null;
        document.getElementById('voucherInput').value    = '';
        document.getElementById('voucherInput').disabled = false;
        document.getElementById('btnApplyVoucher').disabled = false;
        document.getElementById('voucherTag').style.display = 'none';
        document.getElementById('voucherMsg').textContent   = '';
        document.getElementById('voucherMsg').className = 'voucher-msg';
        updateSummary();
    });

    function showVoucherMsg(msg, cls) {
        var el = document.getElementById('voucherMsg');
        el.textContent = msg;
        el.className   = 'voucher-msg ' + cls;
    }

    // =================================================================
    //  GIU TRANG THAI CHECKBOX QUA CAC LAN RELOAD (khi bam +/-)
    //  Truoc khi form qty submit -> luu productId cua cac o duoc check
    //  vao sessionStorage. Sau khi trang tai lai -> khoi phuc lai.
    // =================================================================
    var STORAGE_KEY = 'cart_checked_ids';

    // Khoi phuc trang thai checkbox tu sessionStorage (neu co)
    function restoreCheckboxState() {
        // Uu tien: kiem tra key tu checkout (san pham nao KHONG duoc chon)
        var uncheckedRaw = sessionStorage.getItem('cart_uncheck_after_order');
        if (uncheckedRaw) {
            sessionStorage.removeItem('cart_uncheck_after_order');
            try {
                var uncheckedIds = JSON.parse(uncheckedRaw);
                getRowCheckboxes().forEach(function(cb) {
                    // Neu variantId nay nam trong danh sach "khong chon" -> uncheck
                    cb.checked = uncheckedIds.indexOf(cb.dataset.variantId) === -1;
                });
            } catch (e) { /* mac dinh tat ca check */ }
            updateSummary();
            return;
        }

        // Key tu nut +/-: danh sach variantId DUOC check
        var raw = sessionStorage.getItem(STORAGE_KEY);
        if (!raw) {
            // Lan dau vao trang: mac dinh tick het
            updateSummary();
            return;
        }

        try {
            var savedIds = JSON.parse(raw);
            sessionStorage.removeItem(STORAGE_KEY);
            getRowCheckboxes().forEach(function(cb) {
                cb.checked = savedIds.indexOf(cb.dataset.variantId) !== -1;
            });
        } catch (e) { /* mac dinh tat ca check */ }

        updateSummary();
    }

    // Truoc khi form +/- submit: luu trang thai checkbox hien tai
    document.querySelectorAll('.qty-form button[type="submit"]').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var checkedIds = [];
            document.querySelectorAll('.row-check:checked').forEach(function(cb) {
                // Luu variantId de khoi phuc dung checkbox sau reload
                checkedIds.push(cb.dataset.variantId);
            });
            sessionStorage.setItem(STORAGE_KEY, JSON.stringify(checkedIds));
        });
    });

    // Truoc khi form xoa san pham submit: xoa luon storage de khoi phuc sach
    document.querySelectorAll('.btn-remove').forEach(function(btn) {
        btn.addEventListener('click', function() {
            sessionStorage.removeItem(STORAGE_KEY);
        });
    });

    // Khoi chay: khoi phuc trang thai (hoac mac dinh neu lan dau)
    restoreCheckboxState();

    // =================================================================
    //  DOI SIZE TRONG GIO HANG
    //  Bam vao badge size -> mo popup -> chon size moi -> POST len server
    //  Server: cap nhat variantId moi trong session (doi size = doi variant)
    // =================================================================
    var changeSizeProductId  = null;
    var changeSizeOldVariant = null;
    var changeSizeNewVariant = null;

    document.querySelectorAll('.btn-change-size').forEach(function(btn) {
        btn.addEventListener('click', function() {
            changeSizeOldVariant = btn.dataset.variantId;
            changeSizeProductId  = btn.dataset.productId;
            changeSizeNewVariant = null;

            // Reset popup
            var modal = document.getElementById('changeSizeModal');
            document.getElementById('csModalTitle').textContent =
                'Đổi size (đang chọn: ' + (btn.dataset.currentSize || '-') + ')';
            document.getElementById('csSizeList').innerHTML = '';
            document.getElementById('csLoading').style.display = 'block';
            document.getElementById('csError').style.display   = 'none';
            document.getElementById('btnConfirmChange').disabled = true;
            document.getElementById('btnConfirmChange').style.opacity = '0.4';
            modal.style.display = 'flex';

            // Lay danh sach variant cua san pham nay
            fetch('<%= request.getContextPath() %>/cart?action=variants&productId=' + changeSizeProductId, {
                credentials: 'same-origin'
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                document.getElementById('csLoading').style.display = 'none';
                if (!data.variants || data.variants.length === 0) {
                    document.getElementById('csError').textContent = 'Không còn size nào trong kho.';
                    document.getElementById('csError').style.display = 'block';
                    return;
                }
                // Render cac nut size
                var container = document.getElementById('csSizeList');
                data.variants.forEach(function(v) {
                    var b = document.createElement('button');
                    b.textContent = v.size;
                    b.title = formatVND(v.price);
                    var isCurrent = (String(v.variantId) === String(changeSizeOldVariant));
                    b.style.cssText = 'padding:8px 16px;border:1.5px solid ' +
                        (isCurrent ? '#000' : '#ddd') + ';border-radius:6px;' +
                        'font-size:14px;cursor:pointer;background:' +
                        (isCurrent ? '#000' : '#fff') + ';color:' +
                        (isCurrent ? '#fff' : '#333') + ';font-weight:600;transition:all 0.15s;';
                    if (isCurrent) {
                        b.title += ' (dang chon)';
                        changeSizeNewVariant = String(v.variantId);
                    }
                    b.addEventListener('click', function() {
                        container.querySelectorAll('button').forEach(function(x) {
                            x.style.background  = '#fff';
                            x.style.color       = '#333';
                            x.style.borderColor = '#ddd';
                        });
                        b.style.background  = '#000';
                        b.style.color       = '#fff';
                        b.style.borderColor = '#000';
                        changeSizeNewVariant = String(v.variantId);
                        document.getElementById('btnConfirmChange').disabled = false;
                        document.getElementById('btnConfirmChange').style.opacity = '1';
                    });
                    container.appendChild(b);
                });
                // Enable confirm ngay neu da chon size (chon lai size hien tai cung ok)
                document.getElementById('btnConfirmChange').disabled = (changeSizeNewVariant === null);
                document.getElementById('btnConfirmChange').style.opacity =
                    changeSizeNewVariant ? '1' : '0.4';
            })
            .catch(function() {
                document.getElementById('csLoading').style.display = 'none';
                document.getElementById('csError').textContent = 'Không thể tải danh sách size.';
                document.getElementById('csError').style.display = 'block';
            });
        });
    });

    // Dong popup doi size
    document.getElementById('btnCloseChangeSize').addEventListener('click', function() {
        document.getElementById('changeSizeModal').style.display = 'none';
    });
    document.getElementById('changeSizeModal').addEventListener('click', function(e) {
        if (e.target === this) this.style.display = 'none';
    });

    // Xac nhan doi size
    document.getElementById('btnConfirmChange').addEventListener('click', function() {
        if (!changeSizeNewVariant || !changeSizeOldVariant) return;

        // Neu chon lai size cu -> dong popup, khong lam gi
        if (changeSizeNewVariant === String(changeSizeOldVariant)) {
            document.getElementById('changeSizeModal').style.display = 'none';
            return;
        }

        // POST: remove old variant, add new variant
        // Lam tuan tu: remove truoc -> add sau
        var confirmBtn = this;
        confirmBtn.textContent = 'Đang cập nhật...';
        confirmBtn.disabled = true;

        var formData = 'action=changeSize&oldVariantId=' + changeSizeOldVariant +
                       '&newVariantId=' + changeSizeNewVariant;

        fetch('<%= request.getContextPath() %>/cart', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData,
            credentials: 'same-origin'
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.status === 'ok') {
                // Kiem tra item vua doi size co dang duoc check khong
                var wasChecked = false;
                document.querySelectorAll('.row-check').forEach(function(cb) {
                    if (cb.dataset.variantId === String(changeSizeOldVariant)) {
                        wasChecked = cb.checked;
                    }
                });

                // Giu nguyen trang thai checked cua tat ca item hien tai,
                // ngoai tru item vua doi size (dung oldVariantId de loai no ra)
                var checkedIds = [];
                document.querySelectorAll('.row-check:checked').forEach(function(cb) {
                    if (cb.dataset.variantId !== String(changeSizeOldVariant)) {
                        checkedIds.push(cb.dataset.variantId);
                    }
                });

                // Chi them newVariantId vao checked neu item cu dang duoc check
                if (wasChecked) {
                    checkedIds.push(String(changeSizeNewVariant));
                }

                sessionStorage.setItem('cart_checked_ids', JSON.stringify(checkedIds));
                window.location.href = '<%= request.getContextPath() %>/cart';
            } else {
                document.getElementById('csError').textContent =
                    data.message || 'Lỗi khi đổi size. Vui lòng thử lại.';
                document.getElementById('csError').style.display = 'block';
                confirmBtn.textContent = 'Cập nhật size';
                confirmBtn.disabled = false;
                confirmBtn.style.opacity = '1';
            }
        })
        .catch(function() {
            document.getElementById('csError').textContent = 'Lỗi kết nối.';
            document.getElementById('csError').style.display = 'block';
            confirmBtn.textContent = 'Cập nhật size';
            confirmBtn.disabled = false;
        });
    });
</script>

</body>
</html>
