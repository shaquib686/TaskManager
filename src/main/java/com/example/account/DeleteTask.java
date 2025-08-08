package com.example.account;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

public class DeleteTask extends HttpServlet{
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String taskId = req.getParameter("taskId");
        HttpSession session = req.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("name") : null;
        if(username != "null" && taskId != ""){
            try(Connection con = DBUtil.getConnection()){
                PreparedStatement st = con.prepareStatement("DELETE FROM tasks WHERE task_id = ? AND created_by = ?");
                st.setString(1, taskId);
                st.setString(2, username);
                st.executeUpdate();
            }
            catch(Exception e){
                e.printStackTrace();
                resp.getWriter().write("Error fetching tasks.");
            }
        }
        resp.sendRedirect("task");
    }

}
