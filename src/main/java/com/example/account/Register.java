package com.example.account;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.sql.*;

public class Register extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uName = req.getParameter("username");
        String uPass = req.getParameter("password");
        String uconPass = req.getParameter("confirmpassword");

        if(uName.isEmpty() || uPass.isEmpty() || uconPass.isEmpty()){
            resp.getWriter().write("<script>alert('All fields are required!'); window.history.back();</script>");
            return ;
        }

        if(!uPass.equals(uconPass)){
            resp.getWriter().write("<script>alert('Password do not match'); window.history.back();</script>");
            return ;
        }

        try(Connection con = DBUtil.getConnection()){
            PreparedStatement st = con.prepareStatement("SELECT * FROM users WHERE username = ?");
            st.setString(1, uName);

            ResultSet rs = st.executeQuery();

            if(rs.next()){
                resp.getWriter().write("<script>alert('Username already exist!'); window.history.back();</script>");
            }
            else{
                st = con.prepareStatement("INSERT INTO users (username, userpassword) VALUES (?, ?)");
                st.setString(1, uName);
                st.setString(2, uPass);
                st.executeUpdate();

                resp.sendRedirect("login.jsp");
            }
        }
        catch(Exception e){
            e.printStackTrace();
            resp.getWriter().write("<script>alert('Error occurred while registering'); window.history.back();</script>");
        }
    }
}
