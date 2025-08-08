package com.example.account;

import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;

public class AddTask extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String taskName = req.getParameter("task-name");
        String priority = req.getParameter("task-priority");
        String finishTimeStr = req.getParameter("completion-date");

        HttpSession session = req.getSession(false);
        String createdBy = (session != null) ? (String) session.getAttribute("name") : null;

        // Validate inputs
        if (createdBy == null || createdBy.trim().isEmpty() ||
            taskName == null || taskName.trim().isEmpty() ||
            priority == null || priority.trim().isEmpty()) {

            resp.getWriter().write("<script>alert('Invalid input. Please check again.'); window.history.back();</script>");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {

            // Get new task_number for this user
            int taskNumber = 1;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(MAX(task_number), 0) + 1 FROM tasks WHERE created_by = ?")) {
                ps.setString(1, createdBy);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    taskNumber = rs.getInt(1);
                }
            }

            String taskId = "task" + taskNumber;
            LocalDateTime createdTime = LocalDateTime.now();
            LocalDateTime finishTime = (finishTimeStr != null) ? LocalDateTime.parse(finishTimeStr) : createdTime;

            // Insert the task
            try (PreparedStatement insert = con.prepareStatement(
                    "INSERT INTO tasks (task_number, task_id, task_name, created_time, finish_time, priority, created_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)")) {

                insert.setInt(1, taskNumber);
                insert.setString(2, taskId);
                insert.setString(3, taskName);
                insert.setTimestamp(4, Timestamp.valueOf(createdTime));
                insert.setTimestamp(5, Timestamp.valueOf(finishTime));
                insert.setString(6, priority);
                insert.setString(7, createdBy);

                insert.executeUpdate();
                resp.sendRedirect("task");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace(); // Optional: log to file
            resp.getWriter().write("<script>alert('Error occurred while adding task'); window.history.back();</script>");
        }
    }
}
