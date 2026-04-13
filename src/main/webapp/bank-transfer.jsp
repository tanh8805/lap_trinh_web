<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Long qrAmount = (Long) session.getAttribute("qrAmount");
    String qrOrderInfo = (String) session.getAttribute("qrOrderInfo");

    if (qrAmount == null || qrOrderInfo == null) {
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }

    String bankId = "970415"; // ví dụ VietinBank
    String accountNo = "113366668888"; // thay bằng STK của bạn
    String accountName = "NGUYEN VAN A"; // thay bằng tên tài khoản, không dấu, viết hoa

    String qrUrl = "https://img.vietqr.io/image/"
            + bankId + "-" + accountNo + "-compact2.png"
            + "?amount=" + qrAmount
            + "&addInfo=" + java.net.URLEncoder.encode(qrOrderInfo, "UTF-8")
            + "&accountName=" + java.net.URLEncoder.encode(accountName, "UTF-8");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh toán chuyển khoản</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f6f6f6;
            margin: 0;
            padding: 40px 0;
        }
        .box {
            width: 520px;
            margin: 0 auto;
            background: #fff;
            padding: 28px;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.08);
            text-align: center;
        }
        .amount {
            font-size: 32px;
            font-weight: bold;
            color: #d62828;
            margin: 12px 0 20px;
        }
        .qr-img {
            width: 300px;
            height: auto;
            margin: 16px auto;
            display: block;
        }
        .note {
            margin-top: 16px;
            color: #444;
            line-height: 1.6;
        }
        .btn {
            display: inline-block;
            margin-top: 22px;
            padding: 12px 22px;
            background: #111;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="box">
        <h2>Quét mã để thanh toán</h2>
        <div class="amount"><%= String.format("%,d", qrAmount) %> đ</div>

        <img src="<%= qrUrl %>" alt="QR chuyển khoản" class="qr-img">

        <div class="note">
            Nội dung chuyển khoản: <strong><%= qrOrderInfo %></strong><br>
            Vui lòng chuyển đúng số tiền để hệ thống dễ đối soát.
        </div>

        <a class="btn" href="<%=request.getContextPath()%>/order-success.jsp">Tôi đã thanh toán</a>
    </div>
</body>
</html>