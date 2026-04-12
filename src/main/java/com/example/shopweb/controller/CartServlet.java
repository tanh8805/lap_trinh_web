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
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO  cartDAO  = new CartDAO();
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

        request.setAttribute("cart",  cart);
        request.setAttribute("total", total);
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    // Tra JSON danh sach variant (size + gia) cho popup
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
            if (i > 0) json.append(",");
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
        if (action == null) action = "";

        switch (action) {
            case "add":        handleAdd(request, response);        break;
            case "update":     handleUpdate(request, response);     break;
            case "remove":     handleRemove(request, response);     break;
            case "changeSize": handleChangeSize(request, response); break;
            case "checkout":   handleCheckout(request, response);   break;
            default:
                response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    // Them san pham vao gio voi variantId cu the
    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String vidParam = request.getParameter("variantId");
        if (vidParam == null || vidParam.trim().isEmpty()) {
            sendJsonResult(response, false, "Thieu thong tin size san pham.");
            return;
        }

        int variantId;
        try { variantId = Integer.parseInt(vidParam.trim()); }
        catch (NumberFormatException e) {
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

        boolean found = false;
        for (CartItem item : cart) {
            if (item.getVariantId() == variantId) {
                item.setQuantity(item.getQuantity() + 1);
                found = true;
                break;
            }
        }
        if (!found) cart.add(newItem);

        session.setAttribute(SESSION_CART, cart);

        String accept = request.getHeader("Accept");
        boolean isFetch = accept != null && !accept.contains("text/html");
        if (isFetch) {
            sendJsonResult(response, true, null);
        } else {
            response.sendRedirect(request.getContextPath() + "/products?added=true");
        }
    }

    // Cap nhat so luong theo variantId
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int variantId = parseIntParam(request.getParameter("variantId"), -1);
        int delta     = parseIntParam(request.getParameter("delta"), 0);

        if (variantId < 0) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);

        for (CartItem item : cart) {
            if (item.getVariantId() == variantId) {
                int newQty = item.getQuantity() + delta;
                if (newQty <= 0) cart.remove(item);
                else             item.setQuantity(newQty);
                break;
            }
        }

        if (session != null) session.setAttribute(SESSION_CART, cart);
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    // Xoa 1 variant khoi gio
    private void handleRemove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int variantId = parseIntParam(request.getParameter("variantId"), -1);
        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);
        cart.removeIf(item -> item.getVariantId() == variantId);
        if (session != null) session.setAttribute(SESSION_CART, cart);
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    // Doi size: xoa variant cu, them variant moi, giu nguyen so luong
    private void handleChangeSize(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int oldVariantId = parseIntParam(request.getParameter("oldVariantId"), -1);
        int newVariantId = parseIntParam(request.getParameter("newVariantId"), -1);

        if (oldVariantId < 0 || newVariantId < 0) {
            sendJsonResult(response, false, "Du lieu khong hop le.");
            return;
        }
        if (oldVariantId == newVariantId) {
            // Chon lai size cu, khong can lam gi
            sendJsonResult(response, true, null);
            return;
        }

        HttpSession session = request.getSession(false);
        List<CartItem> cart = getCartFromSession(session);

        // Lay quantity cua variant cu truoc khi xoa
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

        // Xoa variant cu
        cart.removeIf(item -> item.getVariantId() == oldVariantId);

        // Neu variant moi da co trong gio thi tang so luong
        boolean found = false;
        for (CartItem item : cart) {
            if (item.getVariantId() == newVariantId) {
                item.setQuantity(item.getQuantity() + oldQty);
                found = true;
                break;
            }
        }
        if (!found) cart.add(newItem);

        if (session != null) session.setAttribute(SESSION_CART, cart);
        sendJsonResult(response, true, null);
    }

    // Thanh toan cac san pham duoc chon, giu lai phan con lai
    private void handleCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null)
                ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<CartItem> fullCart = getCartFromSession(session);
        if (fullCart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        List<Integer> selectedIds = parseIdList(request.getParameter("selectedIds"));
        if (selectedIds.isEmpty()) {
            request.setAttribute("error", "Vui long chon it nhat 1 san pham de thanh toan.");
            doGet(request, response);
            return;
        }

        // Tach gio: selected -> thanh toan, remaining -> giu lai
        List<CartItem> selectedItems  = new ArrayList<>();
        List<CartItem> remainingItems = new ArrayList<>();
        for (CartItem item : fullCart) {
            if (selectedIds.contains(item.getVariantId())) selectedItems.add(item);
            else                                            remainingItems.add(item);
        }

        if (selectedItems.isEmpty()) {
            request.setAttribute("error", "Khong tim thay san pham da chon. Vui long thu lai.");
            doGet(request, response);
            return;
        }

        String address = request.getParameter("address");
        if (address == null) address = "";

        double discount    = parseDoubleParam(request.getParameter("discountAmount"), 0.0);
        double subtotal    = selectedItems.stream().mapToDouble(CartItem::getSubtotal).sum();
        double totalAmount = Math.max(0, subtotal - discount);

        boolean success = orderDAO.createOrder(
                loggedInUser.getId(), selectedItems, totalAmount, address.trim());

        if (success) {
            if (session != null) {
                if (remainingItems.isEmpty()) session.removeAttribute(SESSION_CART);
                else                         session.setAttribute(SESSION_CART, remainingItems);
            }
            response.sendRedirect(request.getContextPath() + "/cart?orderSuccess=true");
        } else {
            request.setAttribute("error", "Da xay ra loi khi dat hang. Vui long thu lai.");
            doGet(request, response);
        }
    }

    // Helper: tra JSON cho fetch request
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
        if (session == null) return new ArrayList<>();
        List<CartItem> cart = (List<CartItem>) session.getAttribute(SESSION_CART);
        return cart != null ? cart : new ArrayList<>();
    }

    private int parseIntParam(String p, int def) {
        if (p == null || p.trim().isEmpty()) return def;
        try { return Integer.parseInt(p.trim()); } catch (NumberFormatException e) { return def; }
    }

    private double parseDoubleParam(String p, double def) {
        if (p == null || p.trim().isEmpty()) return def;
        try { return Double.parseDouble(p.trim()); } catch (NumberFormatException e) { return def; }
    }

    private List<Integer> parseIdList(String param) {
        List<Integer> ids = new ArrayList<>();
        if (param == null || param.trim().isEmpty()) return ids;
        for (String s : param.split(",")) {
            try { ids.add(Integer.parseInt(s.trim())); } catch (NumberFormatException e) { /* skip */ }
        }
        return ids;
    }
}