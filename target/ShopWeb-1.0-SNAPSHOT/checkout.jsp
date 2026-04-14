<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.example.shopweb.model.CartItem" %>

<%
    request.setCharacterEncoding("UTF-8");

    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
    String[] selectedIds = request.getParameterValues("selectedIds");
    String error = request.getParameter("error");

    String phone = request.getParameter("phone") != null ? request.getParameter("phone") : "";
    String city = request.getParameter("city") != null ? request.getParameter("city") : "";
    String district = request.getParameter("district") != null ? request.getParameter("district") : "";
    String address = request.getParameter("address") != null ? request.getParameter("address") : "";
    String shippingMethod = "standard";
    String paymentMethod = "cod";

    if (cart == null || cart.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }

    Set<Integer> selectedIdSet = new HashSet<Integer>();
    if (selectedIds != null) {
        for (String id : selectedIds) {
            try {
                selectedIdSet.add(Integer.parseInt(id));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    List<CartItem> selectedItems = new ArrayList<CartItem>();
    for (CartItem item : cart) {
        if (selectedIdSet.contains(item.getVariantId())) {
            selectedItems.add(item);
        }
    }

    if (selectedItems.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }

    double subtotal = 0;
    for (CartItem item : selectedItems) {
        subtotal += item.getPrice() * item.getQuantity();
    }

    int shippingFee = "express".equalsIgnoreCase(shippingMethod) ? 50000 : 30000;

    double discount = 0;
    String discountParam = request.getParameter("discountAmount");
    try {
        if (discountParam != null && !discountParam.trim().isEmpty()) {
            discount = Double.parseDouble(discountParam);
        }
    } catch (Exception e) {
        discount = 0;
    }

    double total = subtotal + shippingFee - discount;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh toán</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f7f7f7;
            margin: 0;
            padding: 0;
        }
        .checkout-container {
            width: 1100px;
            margin: 30px auto;
            display: flex;
            gap: 24px;
        }
        .checkout-left, .checkout-right {
            background: #fff;
            border-radius: 10px;
            padding: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }
        .checkout-left {
            flex: 2;
        }
        .checkout-right {
            flex: 1;
            height: fit-content;
        }
        h2, h3 {
            margin-top: 0;
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: bold;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }
        .radio-group {
            margin-bottom: 12px;
        }
        .product-item {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #eee;
            padding: 12px 0;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
        }
        .total-row {
            font-size: 20px;
            font-weight: bold;
            color: #d62828;
        }
        .btn-order {
            width: 100%;
            padding: 14px;
            background: #111;
            color: #fff;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        .btn-order:hover {
            background: #333;
        }
        .error-box {
            background: #ffe5e5;
            color: #c1121f;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 16px;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 16px;
            text-decoration: none;
            color: #333;
        }
        .product-item {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    border-bottom: 1px solid #eee;
    padding: 12px 0;
    gap: 12px;
}

.product-info {
    display: flex;
    gap: 12px;
    align-items: flex-start;
}

.product-thumb {
    width: 72px;
    height: 72px;
    object-fit: cover;
    border-radius: 8px;
    border: 1px solid #ddd;
    background: #fff;
}

.product-text {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
    </style>
</head>
<body>

<div class="checkout-container">
    <div class="checkout-left">
        <a class="back-link" href="<%=request.getContextPath()%>/cart">← Quay lại giỏ hàng</a>
        <h2>Thanh toán</h2>

        <% if ("missing_info".equals(error)) { %>
            <div class="error-box">Vui lòng nhập đầy đủ số điện thoại và địa chỉ.</div>
        <% } else if ("order_failed".equals(error)) { %>
            <div class="error-box">Đặt hàng thất bại. Vui lòng thử lại.</div>
        <% } %>

        <form action="<%=request.getContextPath()%>/cart?action=checkout" method="post">
            <% for (CartItem item : selectedItems) { %>
                <input type="hidden" name="selectedIds" value="<%=item.getVariantId()%>">
            <% } %>
            <input type="hidden" name="discountAmount" value="<%=discount%>">
            <input type="hidden" name="shippingMethod" value="standard">
            <input type="hidden" name="paymentMethod" value="cod">

            <h3>Thông tin người nhận</h3>

            <div class="form-group">
                <label>Số điện thoại</label>
                <input type="text" name="phone" placeholder="Nhập số điện thoại"
       value="<%=phone%>" required pattern="^(0[0-9]{9})$"
       title="Số điện thoại phải gồm 10 số và bắt đầu bằng 0">
            </div>

            <div class="form-group">
                <label>Tỉnh / Thành phố</label>
                <input type="text" name="city" placeholder="Ví dụ: TP.HCM"
       value="<%=city%>" required minlength="2" maxlength="100">
            </div>

            <div class="form-group">
                <label>Quận / Huyện</label>
                <input type="text" name="district" placeholder="Ví dụ: Quận 1"
       value="<%=district%>" required minlength="2" maxlength="100">
            </div>

            <div class="form-group">
                <label>Địa chỉ chi tiết</label>
                <input type="text" name="address" placeholder="Số nhà, tên đường..."
       value="<%=address%>" required minlength="5" maxlength="255">
            </div>

            <h3>Phương thức thanh toán</h3>
            <div class="radio-group">Thanh toán khi nhận hàng (COD)</div>

            <button type="submit" class="btn-order">Đặt hàng</button>
        </form>
    </div>

    <div class="checkout-right">
        <h3>Đơn hàng của bạn</h3>

        <% for (CartItem item : selectedItems) { %>
    <div class="product-item">
        <div class="product-info">
            <img src="<%=request.getContextPath()%>/images/<%=item.getImageUrl()%>"
                 alt="<%=item.getName()%>"
                 class="product-thumb">

            <div class="product-text">
                <div><strong><%=item.getName()%></strong></div>
                <div>SL: <%=item.getQuantity()%></div>
                <div>Size: <%=item.getSize()%></div>
            </div>
        </div>

        <div>
            <%=String.format("%,.0f", item.getPrice() * item.getQuantity())%> đ
        </div>
    </div>
<% } %>

        <div class="summary-row">
            <span>Tạm tính</span>
            <span id="subtotalText"><%=String.format("%,.0f", subtotal)%> đ</span>
        </div>

        <div class="summary-row">
            <span>Phí vận chuyển</span>
            <span id="shippingFeeText"><%=String.format("%,d", shippingFee)%> đ</span>
        </div>

        <div class="summary-row">
            <span>Giảm giá</span>
            <span id="discountText">- <%=String.format("%,.0f", discount)%> đ</span>
        </div>

        <hr>

        <div class="summary-row total-row">
            <span>Tổng cộng</span>
            <span id="totalText"><%=String.format("%,.0f", total)%> đ</span>
        </div>
    </div>
</div>

</body>
</html>