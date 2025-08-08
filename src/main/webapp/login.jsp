<%
    if (session != null && session.getAttribute("name") != null) {
        response.sendRedirect("welcome.jsp");
        return;
    }

    // Optional: Check cookie for persistent login
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("username".equals(c.getName())) {
                // Restore session
                session = request.getSession(true);
                session.setAttribute("name", c.getValue());
                response.sendRedirect("welcome.jsp");
                return;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login/Register</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="navbar.css">
</head>
<body>
    <jsp:include page="navbar.jsp" />
    <div class="page-content">
        <div class="container">
            <div class="tabs">
                <button id="login-tab" class="active" onclick="switchTab('login')">Login</button>
                <span class="or">OR</span>
                <button id="register-tab" onclick="switchTab('register')">Register</button>
            </div>

            <!-- Login Form -->
            <form id="login-form" class="form" method="post" action="login">
                <div class="input-group">
                    <input type="text" placeholder="Enter Username" name="username" required>
                </div>
                <div class="input-group">
                    <input type="password" placeholder="Enter Password" name="password" required>
                </div>
                <button type="submit" class="submit-btn">Login</button>
            </form>

            <!-- Register Form -->
            <form id="register-form" class="form hidden" action="register" method="post">
                <div class="input-group">
                    <input type="text" placeholder="Username" name="username" required>
                </div>
                <div class="input-group">
                    <input type="password" placeholder="Password" name="password" required>
                </div>
                <div class="input-group">
                    <input type="password" placeholder="Confirm Password" name="confirmpassword" required>
                </div>
                <button type="submit" class="submit-btn">Register</button>
            </form>
        </div>
    </div>
    <script>
        function switchTab(tab) {
            document.getElementById('login-tab').classList.remove('active');
            document.getElementById('register-tab').classList.remove('active');
            document.getElementById('login-form').classList.add('hidden');
            document.getElementById('register-form').classList.add('hidden');

            if (tab === 'login') {
                document.getElementById('login-tab').classList.add('active');
                document.getElementById('login-form').classList.remove('hidden');
            } else {
                document.getElementById('register-tab').classList.add('active');
                document.getElementById('register-form').classList.remove('hidden');
            }
        }
    </script>
</body>
</html>
