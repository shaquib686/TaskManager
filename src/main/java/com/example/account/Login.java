package com.example.account;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;

public class Login extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // If no session or cookie login, show login.jsp
        resp.sendRedirect("login.jsp");
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uname = request.getParameter("username");
        String upass = request.getParameter("password");

        try(Connection con = DBUtil.getConnection()){
            PreparedStatement st = con.prepareStatement("SELECT * FROM users WHERE username = ? AND userpassword = ?");
            st.setString(1, uname);
            st.setString(2, upass);

            ResultSet rs = st.executeQuery();

            if(rs.next()){
                HttpSession session = request.getSession();
                session.setAttribute("name", uname);

                String encodedString = URLEncoder.encode(uname, StandardCharsets.UTF_8.toString());
                Cookie loginCookie = new Cookie("username", encodedString);
                loginCookie.setMaxAge(60 * 60 * 24 * 60); // 60 days
                response.addCookie(loginCookie);
                
                response.sendRedirect("task");
            }
            else{
                response.getWriter().write("<script>alert('Invalid username or password!'); window.history.back();</script>");
            }
        }
        catch(Exception e){
            e.printStackTrace();
            response.getWriter().write("<script>alert('Database error occurred!'); window.history.back();</script>");
        }
    }
}
