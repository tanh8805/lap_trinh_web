<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.shopweb.model.Product" %>
<%@ page import="com.example.shopweb.model.User" %>
<%
    User admin            = (User) session.getAttribute("loggedInUser");
    List<Product> productList = (List<Product>) request.getAttribute("productList");
    List<String[]> categories = (List<String[]>) request.getAttribute("categories");
    Product editProduct   = (Product) request.getAttribute("editProduct");
    String  currentAction = (String) request.getAttribute("action");
    String  success       = (String) request.getAttribute("success");
    String  error         = (String) request.getAttribute("error");
    boolean isEdit        = "edit".equals(currentAction) && editProduct != null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý sản phẩm</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #ecf0f1; margin: 0; }
        .container { display: flex; min-height: 100vh; }

        /* ===== SIDEBAR — giữ nguyên style của admin-dashboard.jsp ===== */
        .sidebar { width: 250px; background: #2c3e50; color: #fff; padding-top: 20px; flex-shrink: 0; }
        .sidebar a { display: block; padding: 12px 20px; color: #fff; text-decoration: none; }
        .sidebar a:hover { background: #34495e; }
        .sidebar a.active { background: #34495e; font-weight: bold; }

        /* ===== MAIN ===== */
        .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
        .header {
            height: 60px; background: #fff;
            display: flex; align-items: center; padding: 0 20px;
            justify-content: space-between; border-bottom: 1px solid #ddd;
        }
        .header h3 { font-size: 18px; color: #2c3e50; }
        .logout-btn {
            background: #e74c3c; color: #fff;
            padding: 8px 16px; border: none; cursor: pointer;
        }
        .logout-btn:hover { background: #c0392b; }

        .content { padding: 24px; flex: 1; }

        /* ===== ALERT ===== */
        .alert {
            padding: 12px 16px; border-radius: 5px;
            margin-bottom: 18px; font-size: 14px;
        }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error   { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* ===== FORM THÊM / SỬA ===== */
        .form-card {
            background: #fff; border-radius: 5px;
            padding: 24px; margin-bottom: 24px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }
        .form-card h4 { font-size: 16px; margin-bottom: 16px; color: #2c3e50; }

        .form-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 14px; }
        .form-group { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px; }
        .form-group label { font-size: 13px; font-weight: 700; color: #555; }
        .form-group input, .form-group textarea, .form-group select {
            padding: 9px 12px; border: 1px solid #ddd; border-radius: 4px;
            font-size: 14px; outline: none; width: 100%;
        }
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            border-color: #2c3e50;
        }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .form-group.full { flex-basis: 100%; }

        /* Preview ảnh */
        #imgPreview {
            margin-top: 8px; width: 100px; height: 100px;
            object-fit: cover; border-radius: 5px;
            border: 1px solid #ddd; display: none;
        }

        .form-actions { display: flex; gap: 10px; margin-top: 6px; }
        .btn-submit {
            padding: 9px 22px; background: #2c3e50; color: #fff;
            border: none; border-radius: 4px; font-size: 14px;
            font-weight: 600; cursor: pointer;
        }
        .btn-submit:hover { background: #34495e; }
        .btn-cancel {
            padding: 9px 22px; background: #bdc3c7; color: #fff;
            border: none; border-radius: 4px; font-size: 14px;
            text-decoration: none; font-weight: 600; cursor: pointer;
        }
        .btn-cancel:hover { background: #95a5a6; }
        
         /* ===== VARIANT ROWS — size + giá + số lượng ===== */
        #variantContainer { margin-bottom: 10px; }
        .variant-row {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 8px;
        }
        .variant-row input {
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 13px;
            outline: none;
        }
        .variant-row input[name="size[]"]  { flex: 1; }
        .variant-row input[name="price[]"] { flex: 1; }
        .variant-row input[name="stock[]"] { flex: 1; }
        .variant-row button {
            padding: 6px 12px;
            background: #e74c3c; color: #fff;
            border: none; border-radius: 4px;
            cursor: pointer; font-size: 13px; flex-shrink: 0;
        }
        .variant-row button:hover { background: #c0392b; }
        .btn-add-row {
            padding: 7px 14px; background: #ecf0f1; color: #555;
            border: 1px solid #ddd; border-radius: 4px;
            font-size: 13px; cursor: pointer; margin-bottom: 14px;
        }
        .btn-add-row:hover { background: #dfe6e9; }
        
        /* ===== BẢNG SẢN PHẨM ===== */
        .table-card {
            background: #fff; border-radius: 5px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        .table-header {
            padding: 16px 20px; display: flex;
            justify-content: space-between; align-items: center;
            border-bottom: 1px solid #eee;
        }
        .table-header h4 { font-size: 16px; color: #2c3e50; }
        .count-badge {
            background: #ecf0f1; color: #555;
            padding: 4px 12px; border-radius: 12px; font-size: 13px;
        }

        table { width: 100%; border-collapse: collapse; }
        thead { background: #f8f9fa; }
        th {
            padding: 12px 16px; text-align: left;
            font-size: 13px; font-weight: 700; color: #555;
            text-transform: uppercase; letter-spacing: 0.4px;
        }
        td {
            padding: 12px 16px; font-size: 14px; color: #333;
            border-top: 1px solid #f0f0f0; vertical-align: middle;
        }
        tr:hover td { background: #fafafa; }

        .product-thumb {
            width: 48px; height: 48px;
            object-fit: cover; border-radius: 5px; background: #eee;
        }
        .badge-cat {
            background: #e8f0fe; color: #1a73e8;
            padding: 3px 10px; border-radius: 12px; font-size: 12px;
        }

        .btn-edit {
            padding: 5px 14px; background: #f39c12; color: #fff;
            border: none; border-radius: 4px; font-size: 13px;
            text-decoration: none; cursor: pointer;
        }
        .btn-edit:hover { background: #d68910; }
        .btn-delete {
            padding: 5px 14px; background: #e74c3c; color: #fff;
            border: none; border-radius: 4px; font-size: 13px; cursor: pointer;
        }
        .btn-delete:hover { background: #c0392b; }
    </style>
</head>
<body>

<div class="container">
<%-- ===== SIDEBAR — đồng bộ với admin-dashboard.jsp ===== --%>
<div class="sidebar">
    <a href="<%= request.getContextPath() %>/index.jsp">🏠 Trang người dùng</a>
    <a href="<%= request.getContextPath() %>/manage-products" class="active">📦 Quản lý sản phẩm</a>
    <a href="<%= request.getContextPath() %>/manage.jsp">🧾 Quản lý đơn hàng</a>
</div>

<div class="main">
    <div class="header">
        <h3>📦 Quản lý sản phẩm</h3>
        <form action="<%= request.getContextPath() %>/logout" method="get">
            <button class="logout-btn">Logout</button>
        </form>
    </div>

    <div class="content">

        <%-- Thông báo kết quả thao tác --%>
        <% if ("added".equals(success)) { %>
            <div class="alert alert-success">✓ Thêm sản phẩm thành công!</div>
        <% } else if ("updated".equals(success)) { %>
            <div class="alert alert-success">✓ Cập nhật sản phẩm thành công!</div>
        <% } else if ("deleted".equals(success)) { %>
            <div class="alert alert-success">✓ Xóa sản phẩm thành công!</div>
        <% } %>
        <% if (error != null) { %>
            <div class="alert alert-error">⚠ <%= error %></div>
        <% } %>

        <%-- ===== FORM THÊM MỚI / SỬA ===== --%>
        <div class="form-card">
            <h4><%= isEdit ? "✏ Sửa sản phẩm: " + editProduct.getName() : "✚ Thêm sản phẩm mới" %></h4>

            <form action="<%= request.getContextPath() %>/manage-products" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "edit" : "add" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= editProduct.getId() %>">
                <% } %>

                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Tên sản phẩm *</label>
                        <input type="text" id="name" name="name" required
                               value="<%= isEdit ? editProduct.getName() : "" %>"
                               placeholder="Nhập tên sản phẩm...">
                    </div>
                    <div class="form-group">
                        <label for="categoryId">Danh mục *</label>
                        <select id="categoryId" name="categoryId" required>
                            <option value="">-- Chọn danh mục --</option>
                            <% if (categories != null) {
                                   for (String[] cat : categories) {
                                       boolean sel = isEdit && editProduct.getCategoryName().equals(cat[1]);
                            %>
                                <option value="<%= cat[0] %>" <%= sel ? "selected" : "" %>>
                                    <%= cat[1] %>
                                </option>
                            <%     }
                               } %>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group full">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description"
                                  placeholder="Nhập mô tả..."><%= isEdit && editProduct.getDescription() != null ? editProduct.getDescription() : "" %></textarea>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group full">
                        <label for="imageUrl">URL hình ảnh</label>
                        <input type="text" id="imageUrl" name="imageUrl"
                               value="<%= isEdit && editProduct.getImageUrl() != null ? editProduct.getImageUrl() : "" %>"
                               placeholder="https://... hoặc đường dẫn tương đối"
                               oninput="previewImage(this.value)">
                        <img id="imgPreview" src="" alt="Preview">
                    </div>
                </div>
                <div id="variantContainer">
                    <% if (isEdit && editProduct.getVariants() != null && !editProduct.getVariants().isEmpty()) {
                        for (String[] v : editProduct.getVariants()) {%>
                    <div class="variant-row">
                        <input type="hidden" name="variantId[]" value="<%= v[0]%>">
                        <input type="text"   name="size[]"  placeholder="Size"      value="<%= v[1]%>">
                        <input type="number" name="price[]" placeholder="Giá"       value="<%= v[2]%>">
                        <input type="number" name="stock[]" placeholder="Số lượng"  value="<%= v[3]%>">
                        <button type="button" onclick="removeRow(this)">X</button>
                    </div>
                    <%     }
                    }%>
                </div>
                <button type="button" class="btn-add-row" onclick="addRow()">+ Thêm size</button>
                <div class="form-actions">
                    <button type="submit" class="btn-submit">
                        <%= isEdit ? "💾 Lưu thay đổi" : "✚ Thêm sản phẩm" %>
                    </button>
                    <% if (isEdit) { %>
                        <a href="<%= request.getContextPath() %>/manage-products" class="btn-cancel">Hủy</a>
                    <% } %>
                </div>
            </form>
        </div>

        <%-- ===== BẢNG DANH SÁCH SẢN PHẨM ===== --%>
        <div class="table-card">
            <div class="table-header">
                <h4>Danh sách sản phẩm</h4>
                <span class="count-badge">
                    <%= productList != null ? productList.size() : 0 %> sản phẩm
                </span>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Ảnh</th>
                        <th>Tên sản phẩm</th>
                        <th>Danh mục</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                <% if (productList != null && !productList.isEmpty()) {
                       for (Product p : productList) {
                           String imgSrc = (p.getImageUrl() != null && !p.getImageUrl().isEmpty())
                               ? p.getImageUrl()
                               : request.getContextPath() + "/images/no-image.jpg";
                %>
                    <tr>
                        <td><%= p.getId() %></td>
                        <td>
                            <img src="<%= imgSrc %>" class="product-thumb"
                                 onerror="this.src='<%= request.getContextPath() %>/images/no-image.jpg'">
                        </td>
                        <td><b><%= p.getName() %></b>
                            <% if (p.getDescription() != null && !p.getDescription().isEmpty()) { %>
                                <br><small style="color:#999;font-size:12px;">
                                    <%= p.getDescription().length() > 60
                                        ? p.getDescription().substring(0, 60) + "..."
                                        : p.getDescription() %>
                                </small>
                            <% } %>
                        </td>
                        <td>
                            <% if (p.getCategoryName() != null) { %>
                                <span class="badge-cat"><%= p.getCategoryName() %></span>
                            <% } %>
                        </td>
                        <td>
                            <a href="<%= request.getContextPath() %>/manage-products?action=edit&id=<%= p.getId() %>"
                               class="btn-edit">✏ Sửa</a>
                            &nbsp;
                            <button class="btn-delete"
                                    data-name="<%= p.getName() != null ? p.getName().replace("\"", "&quot;") : "" %>"
                                    onclick="confirmDelete(<%= p.getId() %>, this.getAttribute('data-name'))">
                                🗑 Xóa
                            </button>
                        </td>
                    </tr>
                <%     }
                   } else { %>
                    <tr>
                        <td colspan="5" style="text-align:center;color:#999;padding:40px;">
                            Chưa có sản phẩm nào.
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

    </div>
</div>

<script>

    function previewImage(url) {
        var preview = document.getElementById('imgPreview');
        if (url && url.trim() !== '') {
            preview.src = url.trim();
            preview.style.display = 'block';
        } else {
            preview.style.display = 'none';
        }
    }


    window.addEventListener('load', function() {
        var urlInput = document.getElementById('imageUrl');
        if (urlInput && urlInput.value) previewImage(urlInput.value);
    });


    function confirmDelete(id, name) {
        if (confirm('Xóa "' + name + '"?\nThao tác này không thể hoàn tác!')) {
            window.location.href = '<%= request.getContextPath() %>/manage-products?action=delete&id=' + id;
        }
    }

    function addRow() {
        let div = document.createElement("div");
        div.className = "variant-row";
        div.innerHTML = `
            <input type="hidden" name="variantId[]" value="">
            <input type="text"   name="size[]"  placeholder="Size (S, M, XL...)">
            <input type="number" name="price[]" placeholder="Giá">
            <input type="number" name="stock[]" placeholder="Số lượng">
            <button type="button" onclick="removeRow(this)">X</button>
        `;
        document.getElementById("variantContainer").appendChild(div);
    }

function removeRow(btn) {
    btn.parentElement.remove();
}
</script>
</body>
</html>