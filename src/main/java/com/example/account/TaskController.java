package com.example.account;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class TaskController extends HttpServlet {
    private static final int DEFAULT_ROW = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    private void handleRequest(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String name = (session != null) ? (String) session.getAttribute("name") : null;
        if (name == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // Parse pagination parameters
        int page = 1;
        int rowsPerPage = DEFAULT_ROW;
        try {
            if (req.getParameter("rows") != null) {
                rowsPerPage = Integer.parseInt(req.getParameter("rows"));
            }
            if (req.getParameter("page") != null) {
                page = Integer.parseInt(req.getParameter("page"));
            }
        } catch (NumberFormatException e) {
            System.out.println("Invalid pagination parameters, using defaults");
        }

        // Get filter parameters
        String taskName = req.getParameter("searchTaskName");
        String status = req.getParameter("status");
        String priority = req.getParameter("priority");
        String fromDate = req.getParameter("date-from");
        String toDate = req.getParameter("date-to");

        // Normalize empty strings to null
        taskName = (taskName != null && taskName.trim().isEmpty()) ? null : taskName;
        fromDate = (fromDate != null && fromDate.trim().isEmpty()) ? null : fromDate;
        toDate = (toDate != null && toDate.trim().isEmpty()) ? null : toDate;

        try (Connection con = DBUtil.getConnection()) {
            TaskService taskService = new TaskService();
            
            // Determine if this is a search/filter request
            boolean isSearch = (taskName != null && !taskName.isEmpty()) ||
                               (status != null && !status.equals("All") && !status.equals("Pending")) ||
                               (priority != null && !priority.equals("All")) ||
                               (fromDate != null && !fromDate.isEmpty()) ||
                               (toDate != null && !toDate.isEmpty());

            List<Task> tasks;
            int totalTask;
            
            if (isSearch) {
                // Apply search/filter with all parameters
                tasks = taskService.searchTasks(name, taskName, status, priority, fromDate, toDate, page, rowsPerPage);
                totalTask = taskService.getFilteredTaskCount(name, taskName, status, priority, fromDate, toDate);
            } else {
                // Default view - show only pending tasks
                tasks = taskService.fetchAllTasks(name, page, rowsPerPage);
                totalTask = taskService.getTotalTaskCount(name);
            }

            int totalPages = Math.max(1, (int) Math.ceil((double) totalTask / rowsPerPage));

            // Set attributes for JSP
            req.setAttribute("tasks", tasks);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("currentPage", page);
            req.setAttribute("rowsPerPage", rowsPerPage);
            
            // Preserve filter values for the form - handle nulls properly
            req.setAttribute("searchTaskName", taskName != null ? taskName : "");
            req.setAttribute("filterStatus", status != null ? status : "Pending");
            req.setAttribute("filterPriority", priority != null ? priority : "All");
            req.setAttribute("dateFrom", fromDate != null ? fromDate : "");
            req.setAttribute("dateTo", toDate != null ? toDate : "");

            // Handle AJAX requests vs full page requests
            if ("true".equals(req.getParameter("ajax"))) {
                try {
                    req.getRequestDispatcher("TaskList.jsp").forward(req, resp);
                } catch (Exception e) {
                    System.err.println("Error forwarding to TaskList.jsp: " + e.getMessage());
                    e.printStackTrace();
                    resp.setContentType("text/plain");
                    resp.getWriter().write("Error loading task list.");
                }
            } else {
                try {
                    req.getRequestDispatcher("welcome.jsp").forward(req, resp);
                } catch (Exception e) {
                    System.err.println("Error forwarding to welcome.jsp: " + e.getMessage());
                    e.printStackTrace();
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading page");
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error in TaskController: " + e.getMessage());
            e.printStackTrace();
            
            if ("true".equals(req.getParameter("ajax"))) {
                resp.setContentType("text/plain");
                resp.getWriter().write("Error fetching tasks: " + e.getMessage());
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching tasks");
            }
        }
    }
}