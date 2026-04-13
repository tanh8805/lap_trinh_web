package com.example.shopweb.controller;

import com.example.shopweb.dao.AdminOrderDAO;
import com.example.shopweb.model.AdminOrder;
import com.example.shopweb.model.AdminOrderItem;
import com.example.shopweb.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(urlPatterns = {
        "/manage.jsp",
        "/orders/manage.jsp"
})
public class AdminOrderServlet extends HttpServlet {

    private final AdminOrderDAO adminOrderDAO = new AdminOrderDAO();
    private static final int PAGE_SIZE = 10;

    private static final List<String> DISPLAY_STATUSES = Arrays.asList(
            "Chờ duyệt",
            "Đang xử lý",
            "Đang giao",
            "Đã giao",
            "Đã huỷ");

    private static final Set<String> ALLOWED_STATUSES = new HashSet<>(DISPLAY_STATUSES);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            handleNoPermission(request, response, session);
            return;
        }

        String keyword = trimToEmpty(request.getParameter("keyword"));
        String selectedStatusCode = trimToEmpty(request.getParameter("status"));
        String detailIdRaw = trimToEmpty(request.getParameter("detailId"));
        String statusFilter = statusFromCode(selectedStatusCode);
        int requestedPage = parsePage(request.getParameter("page"));

        if (!detailIdRaw.isEmpty()) {
            showOrderDetail(request, response, session, detailIdRaw, keyword, selectedStatusCode, requestedPage);
            return;
        }

        int totalOrders = adminOrderDAO.countOrders(keyword, statusFilter);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) PAGE_SIZE));
        int currentPage = Math.min(requestedPage, totalPages);

        List<AdminOrder> orders = adminOrderDAO.getOrders(keyword, statusFilter, currentPage, PAGE_SIZE);
        List<AdminOrder> normalizedOrders = new ArrayList<>();
        for (AdminOrder order : orders) {
            AdminOrder normalized = new AdminOrder();
            normalized.setId(order.getId());
            normalized.setUserId(order.getUserId());
            normalized.setUsername(order.getUsername());
            normalized.setOrderDate(order.getOrderDate());
            normalized.setTotalAmount(order.getTotalAmount());
            normalized.setShippingFee(order.getShippingFee());
            normalized.setAddress(order.getAddress());
            normalized.setStatus(normalizeStatus(order.getStatus()));
            normalizedOrders.add(normalized);
        }

        request.setAttribute("orders", normalizedOrders);
        request.setAttribute("statusOptions", DISPLAY_STATUSES);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatusCode", statusCode(statusFilter));
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("startItem", totalOrders == 0 ? 0 : ((currentPage - 1) * PAGE_SIZE + 1));
        request.setAttribute("endItem", Math.min(currentPage * PAGE_SIZE, totalOrders));
        request.setAttribute("success", session.getAttribute("success"));
        request.setAttribute("error", session.getAttribute("error"));
        session.removeAttribute("success");
        session.removeAttribute("error");

        request.getRequestDispatcher("/WEB-INF/manage.jsp").forward(request, response);
    }

    private void showOrderDetail(HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            String detailIdRaw,
            String keyword,
            String statusCode,
            int page) throws ServletException, IOException {
        try {
            int orderId = Integer.parseInt(detailIdRaw);
            AdminOrder order = adminOrderDAO.getOrderById(orderId);

            if (order == null) {
                session.setAttribute("error", "Không tìm thấy đơn hàng.");
                response.sendRedirect(request.getContextPath() + buildManageUrl(keyword, statusCode, page));
                return;
            }

            List<AdminOrderItem> items = adminOrderDAO.getOrderItemsByOrderId(orderId);

            request.setAttribute("order", order);
            request.setAttribute("items", items);
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedStatusCode", statusCode);
            request.setAttribute("page", page);
            request.getRequestDispatcher("/WEB-INF/manage-order-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
            response.sendRedirect(request.getContextPath() + buildManageUrl(keyword, statusCode, page));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            handleNoPermission(request, response, session);
            return;
        }

        String orderIdRaw = request.getParameter("orderId");
        String newStatus = statusFromCode(request.getParameter("status"));
        String keyword = trimToEmpty(request.getParameter("keyword"));
        String statusFilterCode = trimToEmpty(request.getParameter("statusFilter"));
        int page = parsePage(request.getParameter("page"));

        String redirectPath = buildManageUrl(keyword, statusFilterCode, page);

        if (orderIdRaw == null || newStatus == null || !ALLOWED_STATUSES.contains(newStatus)) {
            session.setAttribute("error", "Dữ liệu cập nhật không hợp lệ.");
            response.sendRedirect(request.getContextPath() + redirectPath);
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdRaw);
            boolean updated = adminOrderDAO.updateOrderStatusIfEditable(orderId, newStatus);
            if (updated) {
                session.setAttribute("success", "Cập nhật trạng thái đơn hàng thành công.");
            } else {
                session.setAttribute("error", "Đơn hàng đã ở trạng thái cuối, không thể cập nhật.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + redirectPath);
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null || session.getAttribute("loggedInUser") == null) {
            return false;
        }

        User user = (User) session.getAttribute("loggedInUser");
        return "ADMIN".equals(user.getRole());
    }

    private void handleNoPermission(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        if (session == null || session.getAttribute("loggedInUser") == null) {
            request.getSession().setAttribute("error", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        session.setAttribute("error", "Bạn không đủ quyền hạn!");
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }

    private int parsePage(String pageRaw) {
        try {
            int page = Integer.parseInt(pageRaw);
            return Math.max(page, 1);
        } catch (Exception e) {
            return 1;
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
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

    private String statusCode(String status) {
        switch (normalizeStatus(status)) {
            case "Chờ duyệt":
                return "PENDING_REVIEW";
            case "Đang xử lý":
                return "PROCESSING";
            case "Đang giao":
                return "SHIPPING";
            case "Đã giao":
                return "DELIVERED";
            case "Đã huỷ":
                return "CANCELLED";
            default:
                return "";
        }
    }

    private String statusFromCode(String code) {
        if (code == null) {
            return null;
        }

        switch (code.trim()) {
            case "PENDING_REVIEW":
                return "Chờ duyệt";
            case "PROCESSING":
                return "Đang xử lý";
            case "SHIPPING":
                return "Đang giao";
            case "DELIVERED":
                return "Đã giao";
            case "CANCELLED":
                return "Đã huỷ";
            default:
                return normalizeStatus(code);
        }
    }

    private String buildManageUrl(String keyword, String statusCode, int page) {
        StringBuilder url = new StringBuilder("/manage.jsp");
        boolean hasQuery = false;

        if (keyword != null && !keyword.isEmpty()) {
            url.append(hasQuery ? "&" : "?")
                    .append("keyword=")
                    .append(urlEncode(keyword));
            hasQuery = true;
        }

        if (statusCode != null && !statusCode.isEmpty()) {
            url.append(hasQuery ? "&" : "?")
                    .append("status=")
                    .append(urlEncode(statusCode));
            hasQuery = true;
        }

        if (page > 1) {
            url.append(hasQuery ? "&" : "?").append("page=").append(page);
        }

        return url.toString();
    }

    private String urlEncode(String value) {
        try {
            return URLEncoder.encode(value, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            return value;
        }
    }
}
