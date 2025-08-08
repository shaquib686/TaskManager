package com.example.account;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

public class EditTask extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String taskID = "";
        taskID = req.getParameter("taskId");
        System.out.println(taskID);
        resp.sendRedirect("task");
    }
}
