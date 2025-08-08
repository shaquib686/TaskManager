<%@ page import="com.example.account.Task" %>
<%@ page import="java.util.*" %>

<%
    List<Task> tasks = (List<Task>) request.getAttribute("tasks");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");

    if (tasks != null && !tasks.isEmpty()) {
        for (Task task : tasks) {
            String rowClass = "";
            if ("High".equalsIgnoreCase(task.priority)) rowClass = "priority-high";
            else if ("Medium".equalsIgnoreCase(task.priority)) rowClass = "priority-medium";
%>
<tr class="<%= rowClass %>">
    <td>
        <input type="checkbox" class="task-checkbox" 
                       value="<%= task.task_id %>" 
                       data-status="<%= task.status %>"
                       onchange="updateActionButtons()">
    </td>
    <td><%= task.task_id %></td>
    <td class="task-name-cell"><%= task.task_name %></td>
    <td><%= task.created_time.toLocalDateTime().toLocalDate() %></td>
    <td><%= task.status %></td>
    <td><%= task.finish_time.toLocalDateTime().toLocalDate() %></td>
    <td>
        <form action="editTask" method="post" style="display:inline;">
            <input type="hidden" name="taskId" value="<%= task.task_id %>">
            <button class="action-btn edit-icon" title="Edit"><i class="fas fa-edit"></i></button>
        </form>
        <form action="deleteTask" method="post" style="display:inline;">
            <input type="hidden" name="taskId" value="<%= task.task_id %>">
            <button class="action-btn delete-icon" title="Delete"><i class="fas fa-trash-alt"></i></button>
        </form>
    </td>
</tr>
<%
        }
    } else {
%>
<tr><td colspan="7" style="text-align:center;">No tasks found.</td></tr>
<%
    }
%>

