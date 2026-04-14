package com.example.shopweb.controller;

import com.example.shopweb.dao.CartDAO;
import com.example.shopweb.dao.UserDAO;
import com.example.shopweb.model.CartItem;
import com.example.shopweb.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String registered = request.getParameter("registered");
        if ("true".equals(registered)) {
            request.setAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username").trim();
        String password = request.getParameter("password");

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập tên đăng nhập và mật khẩu.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.login(username, password);

        if (user != null) {
            // ===== FIX BUG 1: Lấy guest cart TRƯỚC khi invalidate session =====
            List<CartItem> guestCart = new ArrayList<>();
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                List<CartItem> old = (List<CartItem>) oldSession.getAttribute("cart");
                if (old != null) {
                    guestCart = old;
                }
                oldSession.invalidate();
            }

            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("loggedInUser", user);
            newSession.setMaxInactiveInterval(30 * 60);

            // Load giỏ hàng từ DB
            List<CartItem> dbCart = cartDAO.loadCart(user.getId());

            // ===== MERGE: DB cart làm nền, guest cart cộng dồn vào =====
            Map<Integer, CartItem> merged = new LinkedHashMap<>();
            for (CartItem item : dbCart) {
                merged.put(item.getVariantId(), item);
            }
            for (CartItem item : guestCart) {
                if (merged.containsKey(item.getVariantId())) {
                    // Cộng dồn số lượng nếu cùng variant
                    CartItem existing = merged.get(item.getVariantId());
                    existing.setQuantity(existing.getQuantity() + item.getQuantity());
                } else {
                    merged.put(item.getVariantId(), item);
                }
            }

            List<CartItem> finalCart = new ArrayList<>(merged.values());

            // Sync toàn bộ merged cart lên DB
            for (CartItem item : finalCart) {
                cartDAO.upsertItem(user.getId(), item.getVariantId(), item.getQuantity());
            }

            newSession.setAttribute("cart", finalCart);
            // ===== END FIX =====

            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/");
            }

        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}