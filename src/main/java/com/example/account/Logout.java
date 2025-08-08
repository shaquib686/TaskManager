package com.example.account;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class Logout extends HttpServlet{
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // Invalidate the session
        HttpSession session = req.getSession(false);
        if(session != null){
            session.invalidate();
        }

        // Remove the username cookie
        Cookie[] cookies = req.getCookies();
        if(cookies != null){
            for(Cookie cookie : cookies){
                if("username".equals(cookie.getName())){
                    cookie.setValue("");
                    cookie.setMaxAge(0);
                    resp.addCookie(cookie);
                }
            }
        }

        // Redirect to welcome page
        resp.sendRedirect("login.jsp");
    }
}
