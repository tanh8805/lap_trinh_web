package com.example.shopweb.controller;

import com.example.shopweb.dao.CartDAO;
import com.example.shopweb.dao.OrderDAO;
import com.example.shopweb.model.CartItem;
import com.example.shopweb.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private static final String SESSION_CART = "cart";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("variants".equals(action)) {
            handleGetVariants(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);
        double total = cart.stream().mapToDouble(CartItem::getSubtotal).sum();

        request.setAttribute("cart", cart);
        request.setAttribute("total", total);
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }


    private void handleGetVariants(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int productId = parseIntParam(request.getParameter("productId"), -1);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        PrintWriter out = response.getWriter();

        if (productId < 0) {
            out.write("{\"variants\":[]}");
            return;
        }

        List<CartItem> variants = cartDAO.getVariantsByProductId(productId);
        StringBuilder json = new StringBuilder("{\"variants\":[");
        for (int i = 0; i < variants.size(); i++) {
            CartItem v = variants.get(i);
            if (i > 0)
                json.append(",");
            String safeSize = v.getSize() != null ? v.getSize().replace("\"", "'") : "";
            json.append("{")
                    .append("\"variantId\":").append(v.getVariantId()).append(",")
                    .append("\"size\":\"").append(safeSize).append("\",")
                    .append("\"price\":").append(v.getPrice())
                    .append("}");
        }
        json.append("]}");
        out.write(json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null)
            action = "";

        switch (action) {
            case "add":
                handleAdd(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "remove":
                handleRemove(request, response);
                break;
            case "changeSize":
                handleChangeSize(request, response);
                break;
            case "checkout":
                handleCheckout(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/cart");
        }
    }


    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String vidParam = request.getParameter("variantId");
        if (vidParam == null || vidParam.trim().isEmpty()) {
            sendJsonResult(response, false, "Thieu thong tin size san pham.");
            return;
        }

        int variantId;
        try {
            variantId = Integer.parseInt(vidParam.trim());
        } catch (NumberFormatException e) {
            sendJsonResult(response, false, "Du lieu khong hop le.");
            return;
        }

        CartItem newItem = cartDAO.getCartItemByVariantId(variantId);
        if (newItem == null) {
            sendJsonResult(response, false, "San pham/size nay da het hang.");
            return;
        }

        HttpSession session = request.getSession(true);
        List<CartItem> cart = getCartFromSession(session);


        int quantity = parseIntParam(request.getParameter("quantity"), 1);
        if (quantity < 1)
            quantity = 1;

        boolean found = false;
        for (CartItem item : cart) {
            if (item.getVariantId() == variantId) {

                item.setQuantity(item.getQuantity() + quantity);
                found = true;
                break;
            }
        }
        if (!found) {
            newItem.setQuantity(quantity);
            cart.add(newItem);
        }

        session.setAttribute(SESSION_CART, cart);

        String accept = request.getHeader("Accept");
        boolean isFetch = accept != null && !accept.contains("text/html");
        if (isFetch) {
            sendJsonResult(response, true, null);
        } else {
            response.sendRedirect(request.getContextPath() + "/products?added=true");
        }
    }


    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int variantId = parseIntParam(request.getParameter("variantId"), -1);
        int delta = parseIntParam(request.getParameter("delta"), 0);

        if (variantId < 0) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);

        for (CartItem item : cart) {
            if (item.getVariantId() == variantId) {
                int newQty = item.getQuantity() + delta;
                if (newQty <= 0)
                    cart.remove(item);
                else
                    item.setQuantity(newQty);
                break;
            }
        }

        if (session != null)
            session.setAttribute(SESSION_CART, cart);
        response.sendRedirect(request.getContextPath() + "/cart");
    }


    private void handleRemove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int variantId = parseIntParam(request.getParameter("variantId"), -1);
        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);
        cart.removeIf(item -> item.getVariantId() == variantId);
        if (session != null)
            session.setAttribute(SESSION_CART, cart);
        response.sendRedirect(request.getContextPath() + "/cart");
    }


    private void handleChangeSize(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int oldVariantId = parseIntParam(request.getParameter("oldVariantId"), -1);
        int newVariantId = parseIntParam(request.getParameter("newVariantId"), -1);

        if (oldVariantId < 0 || newVariantId < 0) {
            sendJsonResult(response, false, "Du lieu khong hop le.");
            return;
        }
        if (oldVariantId == newVariantId) {

            sendJsonResult(response, true, null);
            return;
        }

        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);


        int oldQty = 1;
        for (CartItem item : cart) {
            if (item.getVariantId() == oldVariantId) {
                oldQty = item.getQuantity();
                break;
            }
        }

        CartItem newItem = cartDAO.getCartItemByVariantId(newVariantId);
        if (newItem == null) {
            sendJsonResult(response, false, "Size nay da het hang.");
            return;
        }
        newItem.setQuantity(oldQty);


        cart.removeIf(item -> item.getVariantId() == oldVariantId);


        boolean found = false;
        for (CartItem item : cart) {
            if (item.getVariantId() == newVariantId) {
                item.setQuantity(item.getQuantity() + oldQty);
                found = true;
                break;
            }
        }
        if (!found)
            cart.add(newItem);

        if (session != null)
            session.setAttribute(SESSION_CART, cart);
        sendJsonResult(response, true, null);
    }


    private void handleCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("loggedInUser");


        if (loggedInUser == null) {
            String[] selectedIds = request.getParameterValues("selectedIds");

            StringBuilder redirectUrl = new StringBuilder();
            redirectUrl.append(request.getContextPath()).append("/checkout.jsp");

            if (selectedIds != null) {
                redirectUrl.append("?");
                for (int i = 0; i < selectedIds.length; i++) {
                    if (i > 0)
                        redirectUrl.append("&");
                    redirectUrl.append("selectedIds=").append(selectedIds[i]);
                }
            }

            session.setAttribute("redirectAfterLogin", redirectUrl.toString());
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }


        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        String[] selectedIds = request.getParameterValues("selectedIds");

        if (selectedIds == null || selectedIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }


        String phone = request.getParameter("phone");
        String city = request.getParameter("city");
        String district = request.getParameter("district");
        String address = request.getParameter("address");
        String shippingMethod = request.getParameter("shippingMethod");
        String paymentMethod = request.getParameter("paymentMethod");
        String discountAmountStr = request.getParameter("discountAmount");

        if (shippingMethod == null || shippingMethod.trim().isEmpty()) {
            shippingMethod = "standard";
        }
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "cod";
        }


        phone = phone != null ? phone.trim() : "";
        city = city != null ? city.trim() : "";
        district = district != null ? district.trim() : "";
        address = address != null ? address.trim() : "";

        if (phone.isEmpty() || city.isEmpty() || district.isEmpty() || address.isEmpty()) {
            StringBuilder errorRedirect = new StringBuilder();
            errorRedirect.append(request.getContextPath()).append("/checkout.jsp?error=missing_info");

            for (String id : selectedIds) {
                errorRedirect.append("&selectedIds=").append(id);
            }

            errorRedirect.append("&phone=").append(java.net.URLEncoder.encode(phone, "UTF-8"));
            errorRedirect.append("&city=").append(java.net.URLEncoder.encode(city, "UTF-8"));
            errorRedirect.append("&district=").append(java.net.URLEncoder.encode(district, "UTF-8"));
            errorRedirect.append("&address=").append(java.net.URLEncoder.encode(address, "UTF-8"));
            errorRedirect.append("&shippingMethod=")
                    .append(java.net.URLEncoder.encode(shippingMethod == null ? "standard" : shippingMethod, "UTF-8"));
            errorRedirect.append("&paymentMethod=")
                    .append(java.net.URLEncoder.encode(paymentMethod == null ? "cod" : paymentMethod, "UTF-8"));
            errorRedirect.append("&discountAmount=")
                    .append(java.net.URLEncoder.encode(discountAmountStr == null ? "0" : discountAmountStr, "UTF-8"));

            response.sendRedirect(errorRedirect.toString());
            return;
        }

        boolean validPhone = phone.matches("^0\\d{9}$");
        boolean validCity = city.length() >= 2 && city.length() <= 100;
        boolean validDistrict = district.length() >= 2 && district.length() <= 100;
        boolean validAddress = address.length() >= 5 && address.length() <= 255;

        if (!validPhone || !validCity || !validDistrict || !validAddress) {
            StringBuilder errorRedirect = new StringBuilder();
            errorRedirect.append(request.getContextPath()).append("/checkout.jsp?error=invalid_info");

            for (String id : selectedIds) {
                errorRedirect.append("&selectedIds=").append(id);
            }

            errorRedirect.append("&phone=").append(java.net.URLEncoder.encode(phone, "UTF-8"));
            errorRedirect.append("&city=").append(java.net.URLEncoder.encode(city, "UTF-8"));
            errorRedirect.append("&district=").append(java.net.URLEncoder.encode(district, "UTF-8"));
            errorRedirect.append("&address=").append(java.net.URLEncoder.encode(address, "UTF-8"));
            errorRedirect.append("&shippingMethod=")
                    .append(java.net.URLEncoder.encode(shippingMethod == null ? "standard" : shippingMethod, "UTF-8"));
            errorRedirect.append("&paymentMethod=")
                    .append(java.net.URLEncoder.encode(paymentMethod == null ? "cod" : paymentMethod, "UTF-8"));
            errorRedirect.append("&discountAmount=")
                    .append(java.net.URLEncoder.encode(discountAmountStr == null ? "0" : discountAmountStr, "UTF-8"));

            response.sendRedirect(errorRedirect.toString());
            return;
        }


        List<CartItem> selectedItems = new ArrayList<>();
        List<CartItem> remainingItems = new ArrayList<>();

        Set<Integer> selectedIdSet = new HashSet<>();
        for (String id : selectedIds) {
            try {
                selectedIdSet.add(Integer.parseInt(id));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        for (CartItem item : cart) {
            if (selectedIdSet.contains(item.getVariantId())) {
                selectedItems.add(item);
            } else {
                remainingItems.add(item);
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

        double discount = 0;
        try {
            if (discountAmountStr != null && !discountAmountStr.trim().isEmpty()) {
                discount = Double.parseDouble(discountAmountStr);
            }
        } catch (Exception e) {
            discount = 0;
        }

        int shippingFee = "express".equalsIgnoreCase(shippingMethod) ? 50000 : 30000;

        double totalAmount = subtotal + shippingFee - discount;
        if (totalAmount < 0) {
            totalAmount = 0;
        }


        String fullAddress = address
                + (district != null && !district.trim().isEmpty() ? ", " + district : "")
                + (city != null && !city.trim().isEmpty() ? ", " + city : "");


        OrderDAO orderDAO = new OrderDAO();
        boolean orderCreated = orderDAO.createOrder(
                loggedInUser.getId(),
                selectedItems,
                totalAmount,
                shippingFee,
                fullAddress,
                phone);


        if (orderCreated) {
            session.setAttribute("cart", remainingItems);

            if ("banking".equalsIgnoreCase(paymentMethod)) {
                session.setAttribute("qrAmount", (long) totalAmount);
                session.setAttribute("qrOrderInfo", "DH" + System.currentTimeMillis());
                response.sendRedirect(request.getContextPath() + "/bank-transfer.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/order-success.jsp");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/checkout.jsp?error=order_failed");
        }
    }


    private void sendJsonResult(HttpServletResponse response, boolean ok, String msg)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        if (ok) {
            response.getWriter().write("{\"status\":\"ok\"}");
        } else {
            String safe = (msg != null) ? msg.replace("\"", "'") : "Loi";
            response.getWriter().write("{\"status\":\"error\",\"message\":\"" + safe + "\"}");
        }
    }

    @SuppressWarnings("unchecked")
    private List<CartItem> getCartFromSession(HttpSession session) {
        if (session == null)
            return new ArrayList<>();
        List<CartItem> cart = (List<CartItem>) session.getAttribute(SESSION_CART);
        return cart != null ? cart : new ArrayList<>();
    }

    private int parseIntParam(String p, int def) {
        if (p == null || p.trim().isEmpty())
            return def;
        try {
            return Integer.parseInt(p.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private double parseDoubleParam(String p, double def) {
        if (p == null || p.trim().isEmpty())
            return def;
        try {
            return Double.parseDouble(p.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private List<Integer> parseIdList(String param) {
        List<Integer> ids = new ArrayList<>();
        if (param == null || param.trim().isEmpty())
            return ids;
        for (String s : param.split(",")) {
            try {
                ids.add(Integer.parseInt(s.trim()));
            } catch (NumberFormatException e) {
                /* skip */ }
        }
        return ids;
    }
}