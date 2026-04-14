package com.example.shopweb.controller;

import com.example.shopweb.dao.UserDAO;
import com.example.shopweb.model.User;
import com.example.shopweb.model.CartItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

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

            // ===== LẤY SESSION CŨ =====
            HttpSession oldSession = request.getSession(false);

            List<CartItem> oldCart = null;
            String redirectAfterLogin = null;

            if (oldSession != null) {
                oldCart = (List<CartItem>) oldSession.getAttribute("cart");
                redirectAfterLogin = (String) oldSession.getAttribute("redirectAfterLogin");
                oldSession.invalidate();
            }

            // ===== TẠO SESSION MỚI =====
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("loggedInUser", user);
            newSession.setMaxInactiveInterval(30 * 60);

            // ===== KHÔI PHỤC GIỎ HÀNG =====
            if (oldCart != null) {
                newSession.setAttribute("cart", oldCart);
            }

            // ===== ƯU TIÊN redirect từ URL =====
            String redirect = request.getParameter("redirect");

            if (!user.isAdmin() && redirect != null && !redirect.isEmpty()) {
                response.sendRedirect(redirect);
                return;
            }

            // ===== FALLBACK redirect từ session =====
            if (!user.isAdmin() && redirectAfterLogin != null && !redirectAfterLogin.isEmpty()) {
                response.sendRedirect(redirectAfterLogin);
                return;
            }

            // ===== DEFAULT =====
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