package com.example.shopweb.controller;

import com.example.shopweb.dao.ProductDAO;
import com.example.shopweb.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/products/detail")
public class ProductDetailServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1. Lấy id từ URL
            String idParam = request.getParameter("id");

            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }

            int id = Integer.parseInt(idParam);

            // 2. Lấy dữ liệu từ DB
            Product product = productDAO.getProductById(id);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }

            // 3. Gửi sang JSP
            request.setAttribute("product", product);

            // 4. Forward
            request.getRequestDispatcher("/product-detail.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            // id không hợp lệ
            response.sendRedirect(request.getContextPath() + "/products");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}