package com.example.shopweb.controller;

import com.example.shopweb.dao.AdminOrderDAO;
import com.example.shopweb.model.AdminOrder;
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
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;

@WebServlet(urlPatterns = {
        "/orders/manage.jsp",
        "/orders/all-products.jsp",
        "/orders/process-products.jsp",
        "/orders/done-products.jsp"
})
public class AdminOrderServlet extends HttpServlet {

    private final AdminOrderDAO adminOrderDAO = new AdminOrderDAO();
    private static final int PAGE_SIZE = 10;
    private static final String MANAGE_PATH = "/orders/manage.jsp";
    private static final Set<String> ALLOWED_STATUSES = new HashSet<>(
            Arrays.asList(
                    "PENDING",
                    "Chờ xử lý",
                    "Chờ duyệt",
                    "Đang xử lý",
                    "Đang giao hàng",
                    "Hoàn thành",
                    "Giao thành công",
                    "Đã hủy",
                    "Đã huỷ"));
    private static final List<String> DISPLAY_STATUSES = Arrays.asList(
            "Chờ duyệt",
            "Đang xử lý",
            "Đang giao hàng",
            "Giao thành công",
            "Đã huỷ");

    private boolean isAdmin(HttpSession session) {
        if (session == null || session.getAttribute("loggedInUser") == null) {
            return false;
        }

        User user = (User) session.getAttribute("loggedInUser");
        return "ADMIN".equals(user.getRole());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            request.getSession().setAttribute("error", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("error", "Bạn không đủ quyền hạn!");
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String orderIdRaw = request.getParameter("orderId");
        String newStatus = parseStatusInput(request.getParameter("status"));
        String keyword = trimToEmpty(request.getParameter("keyword"));
        String statusFilter = parseStatusFilter(request.getParameter("statusFilter"));
        int page = parsePage(request.getParameter("page"));

        String redirectPath = buildManageUrl(keyword, statusToCode(statusFilter), page);

        if (orderIdRaw == null || newStatus == null || !ALLOWED_STATUSES.contains(newStatus)) {
            session.setAttribute("error", "Dữ liệu cập nhật không hợp lệ.");
            response.sendRedirect(request.getContextPath() + redirectPath);
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdRaw);
            boolean updated = adminOrderDAO.updateOrderStatus(orderId, newStatus);

            if (updated) {
                session.setAttribute("success", "Cập nhật trạng thái đơn hàng thành công.");
            } else {
                session.setAttribute("error", "Không thể cập nhật trạng thái đơn hàng.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + redirectPath);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedInUser") == null) {
            request.getSession().setAttribute("error", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("error", "Bạn không đủ quyền hạn!");
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String servletPath = request.getServletPath();
        if (!MANAGE_PATH.equals(servletPath)) {
            response.sendRedirect(request.getContextPath() + MANAGE_PATH);
            return;
        }

        String keyword = trimToEmpty(request.getParameter("keyword"));
        String statusCode = trimToEmpty(request.getParameter("status"));
        String statusFilter = parseStatusFilter(statusCode);
        int requestedPage = parsePage(request.getParameter("page"));

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
        request.setAttribute("pageTitle", "Quản lý đơn hàng");
        request.setAttribute("statusOptions", DISPLAY_STATUSES);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatusCode", statusToCode(statusFilter));
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("startItem", totalOrders == 0 ? 0 : ((currentPage - 1) * PAGE_SIZE + 1));
        request.setAttribute("endItem", Math.min(currentPage * PAGE_SIZE, totalOrders));
        request.setAttribute("success", session.getAttribute("success"));
        request.setAttribute("error", session.getAttribute("error"));
        session.removeAttribute("success");
        session.removeAttribute("error");
        request.getRequestDispatcher("/WEB-INF/orders/manage-orders.jsp").forward(request, response);
    }

    private String normalizeStatus(String status) {
        if (status == null) {
            return null;
        }

        switch (status.trim()) {
            case "PENDING":
            case "Chờ xử lý":
            case "Chờ duyệt":
                return "Chờ duyệt";
            case "Hoàn thành":
            case "Giao thành công":
                return "Giao thành công";
            case "Đã hủy":
            case "Đã huỷ":
                return "Đã huỷ";
            default:
                return status.trim();
        }
    }

    private String parseStatusFilter(String statusFilterRaw) {
        if (statusFilterRaw == null || statusFilterRaw.trim().isEmpty()) {
            return "";
        }

        String byCode = codeToStatus(statusFilterRaw.trim());
        String normalized = byCode == null ? normalizeStatus(statusFilterRaw) : byCode;

        return DISPLAY_STATUSES.contains(normalized) ? normalized : "";
    }

    private String parseStatusInput(String statusRaw) {
        if (statusRaw == null || statusRaw.trim().isEmpty()) {
            return null;
        }

        String byCode = codeToStatus(statusRaw.trim());
        return byCode == null ? normalizeStatus(statusRaw) : byCode;
    }

    private String codeToStatus(String statusCode) {
        switch (statusCode) {
            case "PENDING_REVIEW":
                return "Chờ duyệt";
            case "PROCESSING":
                return "Đang xử lý";
            case "SHIPPING":
                return "Đang giao hàng";
            case "DELIVERED":
                return "Giao thành công";
            case "CANCELLED":
                return "Đã huỷ";
            default:
                return null;
        }
    }

    private String statusToCode(String status) {
        String normalized = normalizeStatus(status);
        if (normalized == null) {
            return "";
        }

        switch (normalized) {
            case "Chờ duyệt":
                return "PENDING_REVIEW";
            case "Đang xử lý":
                return "PROCESSING";
            case "Đang giao hàng":
                return "SHIPPING";
            case "Giao thành công":
                return "DELIVERED";
            case "Đã huỷ":
                return "CANCELLED";
            default:
                return "";
        }
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

    private String buildManageUrl(String keyword, String statusCode, int page) {
        StringBuilder url = new StringBuilder(MANAGE_PATH);
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
