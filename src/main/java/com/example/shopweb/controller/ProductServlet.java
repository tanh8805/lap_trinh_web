package com.example.shopweb.controller;

import com.example.shopweb.dao.ProductDAO;
import com.example.shopweb.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> productList = productDAO.getAllProducts();

        // Lấy danh sách tên danh mục duy nhất, đã sắp xếp, để render dropdown filter
        List<String> categories = productList.stream()
                .map(Product::getCategoryName)
                .filter(c -> c != null && !c.isEmpty())
                .distinct()
                .sorted()
                .collect(Collectors.toList());

        request.setAttribute("productList", productList);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }
}