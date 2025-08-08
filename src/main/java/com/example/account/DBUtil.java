package com.example.account;

import java.sql.*;

public class DBUtil {
    public static final String username = "root";
    public static final String password = "India@123";
    public static final String url = "jdbc:mysql://localhost:3306/userdb";
    
    static{
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}
