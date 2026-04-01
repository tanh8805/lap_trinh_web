package com.example.shopweb.controller;

import com.example.shopweb.dao.UserDAO;
import com.example.shopweb.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username").trim();
        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password");
        String confirm  = request.getParameter("confirmPassword");

        if (username.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin.");
            request.setAttribute("username", username);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (username.length() < 3 || username.length() > 30) {
            request.setAttribute("error", "Tên đăng nhập phải từ 3 đến 30 ký tự.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirm)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("username", username);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.setAttribute("username", username);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.isUsernameExist(username)) {
            request.setAttribute("error", "Tên đăng nhập đã được sử dụng. Vui lòng chọn tên khác.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.isEmailExist(email)) {
            request.setAttribute("error", "Email này đã được đăng ký. Vui lòng dùng email khác.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password); 

        boolean success = userDAO.registerUser(newUser);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/login?registered=true");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.setAttribute("username", username);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}