<%
    HttpSession sess = request.getSession(false);
    String name = (sess != null && sess.getAttribute("name") != null)
                  ? (String) sess.getAttribute("name")
                  : null;
%>

<div class="header">
    <div class="navbar-container">
        <div class="logo-container">
            <img src="images/to-do-list.png" alt="Logo" class="logo">
            <span class="app-title">ToDo App</span>
        </div>

        <div class="user-greeting">
            <% if(name != null) { %>
                Hi, <%=  name %>
            <%} else { %>
                Hi, Guest
            <% } %>
        </div>

        <div class="logout-form">
            <% if (name != null) { %>
                <form action="logout" method="post">
                    <button type="submit" class="logout-button">Logout</button>
                </form>
            <% } else { %>
                <form action="login.jsp" method="get">
                    <button type="submit" class="logout-button">Login</button>
                </form>
            <% } %>
        </div>
    </div>
</div>