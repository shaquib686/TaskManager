package com.example.account;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class TaskService {

    public List<Task> fetchAllTasks(String username, int page, int rowsPerPage) throws SQLException {
        // Only fetch non-completed tasks
        return TaskDAO.getTasks(username, null, null, null, null, null, true, page, rowsPerPage);
    }

    public int getTotalTaskCount(String username) throws SQLException {
        return TaskDAO.getTotalTaskCount(username, true);
    }

    public List<Task> searchTasks(String username, String taskName, String status, String priority,
                                  String fromDate, String toDate, int page, int rowsPerPage) throws Exception {

        LocalDate from = parseDate(fromDate);
        LocalDate to = parseDate(toDate);

        return TaskDAO.getTasks(username, taskName, status, priority, from, to, false, page, rowsPerPage);
    }

    private LocalDate parseDate(String input) {
        if (input == null || input.trim().isEmpty()) return null;
        return LocalDate.parse(input, java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy"));
    }

    public int getFilteredTaskCount(String username, String taskName, String status,
                                    String priority, String fromDate, String toDate) throws SQLException {

        LocalDate from = parseDate(fromDate);
        LocalDate to = parseDate(toDate);

        return TaskDAO.getFilteredTaskCount(username, taskName, status, priority, from, to);
    }
}
