package com.example.shopweb.controller;

import com.example.shopweb.dao.CustomerOrderDAO;
import com.example.shopweb.model.AdminOrder;
import com.example.shopweb.model.CustomerOrderItem;
import com.example.shopweb.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/orders")
public class CustomerOrderServlet extends HttpServlet {

    private final CustomerOrderDAO customerOrderDAO = new CustomerOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = session != null ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            request.getSession().setAttribute("redirectAfterLogin", request.getContextPath() + "/orders");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<AdminOrder> orders = customerOrderDAO.getOrdersByUserId(loggedInUser.getId());
        Map<Integer, List<CustomerOrderItem>> orderItemsMap = new HashMap<>();

        for (AdminOrder order : orders) {
            order.setStatus(normalizeStatus(order.getStatus()));
            orderItemsMap.put(order.getId(), customerOrderDAO.getOrderItemsByOrderId(order.getId()));
        }

        request.setAttribute("orders", orders);
        request.setAttribute("orderItemsMap", orderItemsMap);
        request.getRequestDispatcher("/WEB-INF/orders.jsp").forward(request, response);
    }

    private String normalizeStatus(String status) {
        if (status == null) {
            return "";
        }

        switch (status.trim()) {
            case "PENDING":
            case "Chờ xử lý":
            case "Chờ duyệt":
                return "Chờ duyệt";
            case "Đang giao hàng":
            case "Đang giao":
                return "Đang giao";
            case "Hoàn thành":
            case "Giao thành công":
            case "Đã giao":
                return "Đã giao";
            case "Đã hủy":
            case "Đã huỷ":
                return "Đã huỷ";
            default:
                return status.trim();
        }
    }
}
