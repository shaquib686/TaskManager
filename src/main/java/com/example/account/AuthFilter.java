package com.example.account;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

public class AuthFilter implements Filter{
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI();

        if (path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png") || path.contains("images")) {
            chain.doFilter(request, response);
            return;
        }
        
        if (path.endsWith("login.jsp") || path.endsWith("login") ||
            path.endsWith("register") || path.endsWith("register.jsp") ||
            path.endsWith("logout")) {
            chain.doFilter(request, response); // allow access
            return;
        }

        HttpSession session = req.getSession(false);
        String name = null;

        // Check first session
        if(session != null && session.getAttribute("name") != null){
            name = (String) session.getAttribute("name");
        }
        else{
            // Check cookie
            Cookie[] cookies = req.getCookies();
            if(cookies != null){
                for(Cookie cookie : cookies){
                    if("username".equals(cookie.getName())){
                        name = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8.toString());
                        session = req.getSession(true);
                        session.setAttribute("name", name);
                        break;
                    }
                }
            }
        }

        // If still no login info -> redirect to welcome page
        if(name == null){
            resp.sendRedirect("login.jsp");
        }
        else{
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
        
    }
}
