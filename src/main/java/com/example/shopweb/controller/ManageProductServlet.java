package com.example.shopweb.controller;

import com.example.shopweb.dao.AdminProductDAO;
import com.example.shopweb.model.Product;
import com.example.shopweb.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/manage-products")
public class ManageProductServlet extends HttpServlet {

    private final AdminProductDAO productDAO = new AdminProductDAO();

    /**
     * Kiểm tra quyền ADMIN — chặn non-admin truy cập.
     */
    private boolean checkAdmin(HttpServletRequest request,
                                HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {

            case "edit":
                // Load form sửa với dữ liệu sản phẩm hiện tại
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Product product = productDAO.getProductById(id);

                    // 👉 LOAD VARIANTS
                    product.setVariants(productDAO.getVariantsByProductId(id));
                    if (product == null) {
                        response.sendRedirect(request.getContextPath() + "/manage-products");
                        return;
                    }
                    request.setAttribute("editProduct", product);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/manage-products");
                    return;
                }
                // Tiếp tục load danh sách + categories
                request.setAttribute("productList", productDAO.getAllProducts());
                request.setAttribute("categories", productDAO.getAllCategories());
                request.setAttribute("action", "edit");
                request.getRequestDispatcher("/manage-products.jsp").forward(request, response);
                break;

            case "delete":
                // Xóa sản phẩm rồi redirect về danh sách
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    productDAO.deleteProduct(id);
                } catch (NumberFormatException ignored) {}
                response.sendRedirect(request.getContextPath() + "/manage-products?success=deleted");
                break;

            default:
                // Danh sách + form thêm mới
                request.setAttribute("productList", productDAO.getAllProducts());
                request.setAttribute("categories", productDAO.getAllCategories());
                request.setAttribute("action", "list");

                String success = request.getParameter("success");
                if (success != null) request.setAttribute("success", success);

                request.getRequestDispatcher("/manage-products.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAdmin(request, response)) return;

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "add": {
                String name = request.getParameter("name").trim();
                String desc = request.getParameter("description").trim();
                String imageUrl = request.getParameter("imageUrl").trim();
                int catId = Integer.parseInt(request.getParameter("categoryId"));

                if (name.isEmpty()) {
                    request.setAttribute("error", "Tên sản phẩm không được để trống.");
                    request.setAttribute("productList", productDAO.getAllProducts());
                    request.setAttribute("categories", productDAO.getAllCategories());
                    request.setAttribute("action", "list");
                    request.getRequestDispatcher("/manage-products.jsp").forward(request, response);
                    return;
                }

                int productId = productDAO.insertProduct(name, desc, imageUrl, catId);
                String[] sizes = request.getParameterValues("size[]");
                String[] prices = request.getParameterValues("price[]");
                String[] stocks = request.getParameterValues("stock[]");

                if (sizes != null) {
                    for (int i = 0; i < sizes.length; i++) {
                        if (sizes[i] != null && !sizes[i].trim().isEmpty()) {
                            double price = 0;
                            int stock = 0;
                            try {
                                price = Double.parseDouble(prices[i]);
                            } catch (Exception ignored) {
                            }
                            try {
                                stock = Integer.parseInt(stocks[i]);
                            } catch (Exception ignored) {
                            }
                            productDAO.insertVariant(productId, sizes[i].trim(), price, stock);
                        }
                    }
                }
                response.sendRedirect(request.getContextPath() + "/manage-products?success=added");
                break;
            }

            case "edit": {
                int editId = Integer.parseInt(request.getParameter("id"));
                String editName = request.getParameter("name").trim();
                String editDesc = request.getParameter("description").trim();
                String editImg = request.getParameter("imageUrl").trim();
                int editCatId = Integer.parseInt(request.getParameter("categoryId"));

                productDAO.updateProduct(editId, editName, editDesc, editImg, editCatId);
                productDAO.deleteVariantsByProductId(editId);

                String[] sizes = request.getParameterValues("size[]");
                String[] prices = request.getParameterValues("price[]");
                String[] stocks = request.getParameterValues("stock[]");

                if (sizes != null) {
                    for (int i = 0; i < sizes.length; i++) {
                        // ✅ Kiểm tra null và bounds
                        String size = (sizes[i] != null) ? sizes[i].trim() : "";
                        if (!size.isEmpty()) {
                            double price = 0;
                            int stock = 0;

                            try {
                                price = Double.parseDouble((prices != null && i < prices.length) ? prices[i] : "0");
                            } catch (NumberFormatException ignored) {
                            }

                            try {
                                stock = Integer.parseInt((stocks != null && i < stocks.length) ? stocks[i] : "0");
                            } catch (NumberFormatException ignored) {
                            }

                            productDAO.insertVariant(editId, size, price, stock);
                        }
                    }
                }

            response.sendRedirect(request.getContextPath() + "/manage-products?success=updated");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/manage-products");
        }
    }
}