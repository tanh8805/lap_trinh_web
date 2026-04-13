package com.example.shopweb.controller;

import com.example.shopweb.dao.ContactDAO;
import com.example.shopweb.model.Contact;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {

    private ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String message = request.getParameter("message");

        System.out.println(name + " - " + email); // debug

        Contact contact = new Contact();
        contact.setName(name);
        contact.setEmail(email);
        contact.setPhone(phone);
        contact.setMessage(message);

        boolean result = contactDAO.insertContact(contact);

        if (result) {
            request.setAttribute("success", "Gửi thành công!");
        } else {
            request.setAttribute("error", "Gửi thất bại!");
        }

        request.getRequestDispatcher("contact.jsp").forward(request, response);
    }
}