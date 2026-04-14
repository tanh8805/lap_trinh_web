package com.example.shopweb.dao;

import com.example.shopweb.model.Contact;
import com.example.shopweb.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ContactDAO {




    public boolean insertContact(Contact contact) {
        String sql = "INSERT INTO contacts(name, email, phone, message) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, contact.getName());
            ps.setString(2, contact.getEmail());
            ps.setString(3, contact.getPhone());
            ps.setString(4, contact.getMessage());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            System.out.println("❌ Lỗi insertContact: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }




    public List<Contact> getAllContacts() {
        List<Contact> list = new ArrayList<>();

        String sql = "SELECT id, name, email, phone, message FROM contacts ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Contact c = new Contact();

                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setEmail(rs.getString("email"));
                c.setPhone(rs.getString("phone"));
                c.setMessage(rs.getString("message"));

                list.add(c);
            }

        } catch (Exception e) {
            System.out.println("❌ Lỗi getAllContacts: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }
}