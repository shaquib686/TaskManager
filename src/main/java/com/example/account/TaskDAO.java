package com.example.account;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {

    public static List<Task> getTasks(String createdBy, String taskName, String status, String priority,
                                      LocalDate fromDate, LocalDate toDate, boolean onlyPending,
                                      int page, int rowsPerPage) throws SQLException {
        List<Task> tasks = new ArrayList<>();

        StringBuilder query = new StringBuilder("SELECT * FROM tasks WHERE created_by = ?");
        List<Object> params = new ArrayList<>();
        params.add(createdBy);

        if (taskName != null && !taskName.trim().isEmpty()) {
            query.append(" AND task_name LIKE ?");
            params.add("%" + taskName.trim() + "%");
        }

        // FIXED: Proper status filtering logic
        if (onlyPending) {
            query.append(" AND status != 'Completed'");
        } else if (status != null && !status.equals("All")) {
            query.append(" AND status = ?");
            params.add(status);
        }

        if (priority != null && !priority.equals("All")) {
            query.append(" AND priority = ?");
            params.add(priority);
        }

        if (fromDate != null) {
            query.append(" AND created_time >= ?");
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null) {
            query.append(" AND created_time <= ?");
            params.add(Date.valueOf(toDate));
        }

        query.append(" ORDER BY created_time ASC LIMIT ? OFFSET ?");
        params.add(rowsPerPage);
        params.add((page - 1) * rowsPerPage);

        try (Connection con = DBUtil.getConnection();
             PreparedStatement st = con.prepareStatement(query.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }

            System.out.println("Executing query: " + query.toString());
            System.out.println("Parameters: " + params);

            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Task task = new Task();
                task.task_number = rs.getInt("task_number");
                task.task_id = rs.getString("task_id");
                task.task_name = rs.getString("task_name");
                task.created_time = rs.getTimestamp("created_time");
                task.finish_time = rs.getTimestamp("finish_time");
                task.priority = rs.getString("priority");
                task.status = rs.getString("status");
                tasks.add(task);
            }
        }

        return tasks;
    }

    public static int getTotalTaskCount(String createdBy, boolean onlyPending) throws SQLException {
        StringBuilder query = new StringBuilder("SELECT COUNT(*) FROM tasks WHERE created_by = ?");
        List<Object> params = new ArrayList<>();
        params.add(createdBy);

        if (onlyPending) {
            query.append(" AND status != 'Completed'");
        }

        try (Connection con = DBUtil.getConnection();
             PreparedStatement st = con.prepareStatement(query.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public static int getFilteredTaskCount(String createdBy, String taskName, String status,
                                        String priority, LocalDate fromDate, LocalDate toDate) throws SQLException {

        StringBuilder query = new StringBuilder("SELECT COUNT(*) FROM tasks WHERE created_by = ?");
        List<Object> params = new ArrayList<>();
        params.add(createdBy);

        if (taskName != null && !taskName.trim().isEmpty()) {
            query.append(" AND task_name LIKE ?");
            params.add("%" + taskName.trim() + "%");
        }

        if (status != null && !status.equalsIgnoreCase("All")) {
            query.append(" AND status = ?");
            params.add(status);
        }

        if (priority != null && !priority.equalsIgnoreCase("All")) {
            query.append(" AND priority = ?");
            params.add(priority);
        }

        if (fromDate != null) {
            query.append(" AND created_time >= ?");
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null) {
            query.append(" AND created_time <= ?");
            params.add(Date.valueOf(toDate));
        }

        try (Connection con = DBUtil.getConnection();
            PreparedStatement st = con.prepareStatement(query.toString())) {

            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }

            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

}