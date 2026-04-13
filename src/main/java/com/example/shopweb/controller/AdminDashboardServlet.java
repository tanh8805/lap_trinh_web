package com.example.shopweb.controller;

import com.example.shopweb.model.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            request.getSession().setAttribute("error", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }


        User user = (User) session.getAttribute("loggedInUser");

        if (!"ADMIN".equals(user.getRole())) {
            session.setAttribute("error", "Bạn không đủ quyền hạn!");
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

       
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}