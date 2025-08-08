<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String name = (String) session.getAttribute("name");
    
    // Safely get preserved filter values with null checks
    String searchTaskName = "";
    String filterStatus = "Pending"; // Default status
    String filterPriority = "All"; // Default priority
    String dateFrom = "";
    String dateTo = "";
    int currentRowsPerPage = 10; // Default rows
    
    try {
        Object searchTaskNameObj = request.getAttribute("searchTaskName");
        if (searchTaskNameObj != null) {
            searchTaskName = searchTaskNameObj.toString();
        }
        
        Object filterStatusObj = request.getAttribute("filterStatus");
        if (filterStatusObj != null) {
            filterStatus = filterStatusObj.toString();
        }
        
        Object filterPriorityObj = request.getAttribute("filterPriority");
        if (filterPriorityObj != null) {
            filterPriority = filterPriorityObj.toString();
        }
        
        Object dateFromObj = request.getAttribute("dateFrom");
        if (dateFromObj != null) {
            dateFrom = dateFromObj.toString();
        }
        
        Object dateToObj = request.getAttribute("dateTo");
        if (dateToObj != null) {
            dateTo = dateToObj.toString();
        }
        
        Object rowsPerPageObj = request.getAttribute("rowsPerPage");
        if (rowsPerPageObj != null) {
            currentRowsPerPage = Integer.parseInt(rowsPerPageObj.toString());
        }
    } catch (Exception e) {
        // Use defaults if any error occurs
        System.out.println("Error reading attributes: " + e.getMessage());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="navbar.css">
    <link rel="stylesheet" href="welcomecss.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Flatpickr CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <title>Welcome</title>
    <style>
        /* Additional styles for checkboxes and action buttons */
        .task-checkbox {
            margin-right: 8px;
        }
        
        .header-checkbox {
            margin-right: 8px;
        }
        
        .action-dropdown:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        .action-dropdown option:disabled {
            color: #999;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-completed {
            background-color: #d4edda;
            color: #155724;
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />
    <div class="page-content">
    <div class="main-content-wrapper">
        <!-- Left 80% -->
        <div class="main-panel">
            <!-- Add Task Section -->
            <div class="add-task-panel">
                <form action="addtask" method="post" class="add-task-form">
                    <input type="text" placeholder="Enter Task Name" class="task-name" name="task-name" required>
                    <input type="datetime-local" class="task-date" name="completion-date" id="completion-date" onfocus="this.min = new Date().toISOString().slice(0,16)">
                    <select class="task-priority" name="task-priority">
                        <option value="">All</option>
                        <option value="High" selected>High</option>
                        <option value="Medium">Medium</option>
                        <option value="Low">Low</option>
                    </select>
                    <button class="add-task-btn">Add Task</button>
                </form>
            </div>
            
            <!-- Search and Filter Panel -->
            <div class="task-filter-panel">
                <form action="task" method="post" class="task-filter-form">

                    <!-- Row 1: Search Box -->
                    <div class="form-row">
                        <div class="search-wrapper">
                            <input type="text" name="searchTaskName" placeholder="Enter Task Name" 
                                   class="search-task-input" value="<%= searchTaskName %>">
                            <button type="submit" class="search-icon-btn" title="Search">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>

                    <!-- 2nd Row: Filters - Status, Priority, From, To (same line) -->
                    <div class="filter-criteria-row">
                        <!-- 60% Part: Status and Priority -->
                        <div class="filter-left">
                            <div class="form-group-inline">
                                <label for="status">Status</label>
                                <select class="filter-status" id="status" name="status">
                                    <option value="All" <%= "All".equals(filterStatus) ? "selected" : "" %>>All</option>
                                    <option value="Completed" <%= "Completed".equals(filterStatus) ? "selected" : "" %>>Completed</option>
                                    <option value="Pending" <%= "Pending".equals(filterStatus) ? "selected" : "" %>>Pending</option>
                                </select>
                            </div>
                            <div class="form-group-inline">
                                <label for="priority">Priority</label>
                                <select class="filter-priority" id="priority" name="priority">
                                    <option value="All" <%= "All".equals(filterPriority) ? "selected" : "" %>>All</option>
                                    <option value="High" <%= "High".equals(filterPriority) ? "selected" : "" %>>High</option>
                                    <option value="Medium" <%= "Medium".equals(filterPriority) ? "selected" : "" %>>Medium</option>
                                    <option value="Low" <%= "Low".equals(filterPriority) ? "selected" : "" %>>Low</option>
                                </select>
                            </div>
                        </div>

                        <!-- 40% Part: From-To Date -->
                        <div class="filter-right date-range-group">
                            <div class="floating-input">
                                <input type="text" id="date-from" class="filter-date-from" placeholder=" " 
                                       name="date-from" value="<%= dateFrom %>" />
                                <label for="date-from">From</label>
                            </div>
                            <div class="to-text">to</div>
                            <div class="floating-input">
                                <input type="text" id="date-to" class="filter-date-to" placeholder=" " 
                                       name="date-to" value="<%= dateTo %>" />
                                <label for="date-to">To</label>
                            </div>
                        </div>
                    </div>

                    <!-- Row 3: Action Buttons -->
                    <div class="form-row button-row">
                        <button type="submit" class="btn-apply-filter">Apply Filter</button>
                        <button type="reset" class="btn-reset-filter" onclick="resetFilters()">Reset</button>
                    </div>
                </form>
            </div>

            <!-- Number of rows, next page and action button -->
            <div class="pagging-panel">
                <!-- Rows per page -->
                <select class="rows-dropdown" id="rows-per-page">
                    <option value="10" <%= (currentRowsPerPage == 10) ? "selected" : "" %>>10</option>
                    <option value="20" <%= (currentRowsPerPage == 20) ? "selected" : "" %>>20</option>
                    <option value="50" <%= (currentRowsPerPage == 50) ? "selected" : "" %>>50</option>
                </select>

                <!-- Paging controls -->
                <div class="paging-controls">
                    <button id="prev-page" class="paging-btn" title="Previous Page">&lt;</button>
                    <span id="current-page" class="current-page"><%= request.getAttribute("currentPage") != null ? request.getAttribute("currentPage") : 1 %></span>
                    <span class="slash">/</span>
                    <span id="total-pages" class="total-pages"><%= request.getAttribute("totalPages") != null ? request.getAttribute("totalPages") : 1 %></span>
                    <button id="next-page" class="paging-btn" title="Next Page">&gt;</button>
                </div>

                <!-- Action dropdown -->
                <select class="action-dropdown" id="action-type">
                    <option value="" selected>Action</option>
                    <option value="Complete" disabled>Mark Complete</option>
                    <option value="Delete" disabled>Delete All</option>
                </select>
            </div>

            <!-- Task List Section -->
            <div class="task-list">
                <table class="task-table">
                    <thead>
                        <tr>
                            <th>
                                <input type="checkbox" id="select-all-checkbox" class="header-checkbox" onchange="toggleSelectAll()">#
                            </th> 
                            <th>Task ID</th>
                            <th>Task Name</th>
                            <th>Created Date</th>
                            <th>Status</th>
                            <th>Completion Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="task-body">
                        <jsp:include page="TaskList.jsp" />
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Right 20% -->
        <div class="side-panel">
            <jsp:include page="reportCard.jsp" />
        </div>
    </div>
</div>

    <!-- Flatpickr JS -->
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    
    <script>
        // Enhanced JavaScript with JSP compatibility fix
        
        document.addEventListener('DOMContentLoaded', function () {
            // DateTime input validation
            const datetimeInput = document.getElementById('completion-date');
            
            function setMinDateTime() {
                const now = new Date();
                now.setSeconds(0);
                now.setMilliseconds(0);

                const year = now.getFullYear();
                const month = String(now.getMonth() + 1).padStart(2, '0');
                const day = String(now.getDate()).padStart(2, '0');
                const hours = String(now.getHours()).padStart(2, '0');
                const minutes = String(now.getMinutes()).padStart(2, '0');

                const minDateTime = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes;
                datetimeInput.min = minDateTime;

                if (datetimeInput.value && datetimeInput.value < minDateTime) {
                    datetimeInput.value = minDateTime;
                }
            }

            setMinDateTime();
            setInterval(setMinDateTime, 30000);

            // Flatpickr initialization
            const fromInput = document.getElementById("date-from");
            const toInput = document.getElementById("date-to");

            const fp = flatpickr(fromInput, {
                mode: "range",
                dateFormat: "d-m-Y",
                onChange: function (selectedDates) {
                    if (selectedDates.length === 2) {
                        fromInput.value = flatpickr.formatDate(selectedDates[0], "d-m-Y");
                        toInput.value = flatpickr.formatDate(selectedDates[1], "d-m-Y");
                    }
                },
            });

            toInput.addEventListener("focus", function () {
                fp.open();
            });

            // Initialize pagination and rows-per-page functionality
            initializePagination();
            initializeRowsPerPageHandler();
        });

        function initializePagination() {
            const prevBtn = document.getElementById("prev-page");
            const nextBtn = document.getElementById("next-page");

            if (prevBtn) {
                // Remove existing event listeners to prevent duplicates
                prevBtn.onclick = null;
                prevBtn.addEventListener("click", function () {
                    const current = parseInt(document.getElementById("current-page").innerText);
                    if (current > 1) {
                        loadPage(current - 1);
                    }
                });
            }

            if (nextBtn) {
                // Remove existing event listeners to prevent duplicates
                nextBtn.onclick = null;
                nextBtn.addEventListener("click", function () {
                    const current = parseInt(document.getElementById("current-page").innerText);
                    const total = parseInt(document.getElementById("total-pages").innerText);
                    if (current < total) {
                        loadPage(current + 1);
                    }
                });
            }
        }

        function initializeRowsPerPageHandler() {
            const rowsDropdown = document.getElementById("rows-per-page");
            if (rowsDropdown) {
                // Remove existing event listeners to prevent duplicates
                rowsDropdown.onchange = null;
                rowsDropdown.addEventListener("change", function () {
                    // Reset to page 1 when changing rows per page
                    loadPage(1);
                });
            }
        }

        function loadPage(page) {
            console.log("Loading page:", page);
            
            const rows = document.getElementById("rows-per-page").value;
            
            // Get current filter values to maintain state
            const currentFilters = getCurrentFilterParams();
            
            // Build query parameters using string concatenation to avoid JSP conflicts
            let queryParams = "page=" + page + "&rows=" + rows + "&ajax=true";
            
            if (currentFilters.length > 0) {
                queryParams += '&' + currentFilters.join('&');
            }
            
            const url = "task?" + queryParams;
            
            fetch(url)
                .then(function(res) {
                    if (!res.ok) {
                        throw new Error('HTTP error! status: ' + res.status);
                    }
                    return res.text();
                })
                .then(function(html) {
                    document.getElementById("task-body").innerHTML = html;
                    document.getElementById("current-page").innerText = page;
                    
                    // Re-initialize pagination after content load
                    initializePagination();
                })
                .catch(function(error) {
                    console.error('Error loading page:', error);
                    alert('Error loading tasks. Please try again.');
                });
        }

        function getCurrentFilterParams() {
            const params = [];
            
            // Get search task name
            const searchTaskName = document.querySelector('input[name="searchTaskName"]').value;
            if (searchTaskName && searchTaskName.trim() !== '') {
                params.push("searchTaskName=" + encodeURIComponent(searchTaskName.trim()));
            }
            
            // Get status filter
            const status = document.querySelector('select[name="status"]').value;
            if (status && status !== 'All') {
                params.push("status=" + encodeURIComponent(status));
            }
            
            // Get priority filter
            const priority = document.querySelector('select[name="priority"]').value;
            if (priority && priority !== 'All') {
                params.push("priority=" + encodeURIComponent(priority));
            }
            
            // Get date range
            const dateFrom = document.querySelector('input[name="date-from"]').value;
            if (dateFrom && dateFrom.trim() !== '') {
                params.push("date-from=" + encodeURIComponent(dateFrom.trim()));
            }
            
            const dateTo = document.querySelector('input[name="date-to"]').value;
            if (dateTo && dateTo.trim() !== '') {
                params.push("date-to=" + encodeURIComponent(dateTo.trim()));
            }
            
            return params;
        }

        function resetFilters() {
            // Reset form fields
            document.querySelector('input[name="searchTaskName"]').value = '';
            document.querySelector('select[name="status"]').value = 'Pending';
            document.querySelector('select[name="priority"]').value = 'All';
            document.querySelector('input[name="date-from"]').value = '';
            document.querySelector('input[name="date-to"]').value = '';
            
            // Redirect to default view
            setTimeout(function() {
                window.location.href = 'task';
            }, 100);
        }
    
        function toggleSelectAll() {
            const selectAllCheckbox = document.getElementById('select-all-checkbox');
            const taskCheckboxes = document.querySelectorAll('.task-checkbox');
            
            taskCheckboxes.forEach(checkbox => {
                checkbox.checked = selectAllCheckbox.checked;
            });
            
            // updateActionButtons();
        }

    </script>

</body>
</html>