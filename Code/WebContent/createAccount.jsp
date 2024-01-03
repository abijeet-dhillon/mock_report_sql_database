<%@ page import="java.io.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>
<%@ include file="jdbc.jsp"%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Account Screen</title>
    <link rel="stylesheet" type="text/css" href="css/style.css" />
</head>
<body>

<div style="margin:0 auto;text-align:center;display:inline">

<h3>Create a new account!</h3>

<form method="post" action="createAccount.jsp">
    <table style="display:inline">
        <tr>
            <td><label for="firstName">First Name:</label></td>
            <td><input type="text" name="firstName" required></td>
        </tr>
        <tr>
            <td><label for="lastName">Last Name:</label></td>
            <td><input type="text" name="lastName" required></td>
        </tr>
        <tr>
            <td><label for="email">Email:</label></td>
            <td><input type="email" name="email" required></td>
        </tr>
        <tr>
            <td><label for="phoneNumber">Phone Number:</label></td>
            <td><input type="text" name="phoneNumber" pattern="\d+" title="Please enter only numbers" required></td>
        </tr>
        <tr>
            <td><label for="address">Address:</label></td>
            <td><input type="text" name="address" required></td>
        </tr>
        <tr>
            <td><label for="city">City:</label></td>
            <td><input type="text" name="city" required></td>
        </tr>
        <tr>
            <td><label for="state">State:</label></td>
            <td><input type="text" name="state" required></td>
        </tr>
        <tr>
            <td><label for="postalCode">Postal Code:</label></td>
            <td><input type="text" name="postalCode" pattern="\w{6}" title="Postal code must be 6 alphanumeric characters" required></td>
        </tr>
        <tr>
            <td><label for="country">Country:</label></td>
            <td>
                <select name="country" required>
                    <option value="Canada" selected>Canada</option>
                </select>
            </td>
        </tr>
        <tr>
            <td><label for="userid">User ID:</label></td>
            <td><input type="text" name="userid" required></td>
        </tr>
        <tr>
            <td><label for="password">Password:</label></td>
            <td><input type="password" name="password" required></td>
        </tr>
    </table>

    <br/>
    <input type="submit" value="Create Account">
</form>

<%!
    // Function to check if a string is null or empty
    boolean isNullOrEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
%>

<%

    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Retrieve form parameters
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String postalCode = request.getParameter("postalCode");
        String country = request.getParameter("country");
        String userid = request.getParameter("userid");
        String password = request.getParameter("password");

        // Validate form data
        boolean hasErrors = false;
        StringBuilder errorMessage = new StringBuilder();

        if (isNullOrEmpty(firstName) || isNullOrEmpty(lastName) || isNullOrEmpty(email) ||
            isNullOrEmpty(phoneNumber) || isNullOrEmpty(address) || isNullOrEmpty(city) ||
            isNullOrEmpty(state) || isNullOrEmpty(postalCode) || isNullOrEmpty(country) ||
            isNullOrEmpty(userid) || isNullOrEmpty(password)) {
            hasErrors = true;
            errorMessage.append("All fields are required.<br>");
        }

        // Validate email format
        // You can use a more sophisticated email validation if needed
        if (!email.matches(".+@.+\\..+")) {
            hasErrors = true;
            errorMessage.append("Invalid email format.<br>");
        }

        // Validate phone number (only numbers allowed)
        if (!phoneNumber.matches("\\d+")) {
            hasErrors = true;
            errorMessage.append("Phone number must contain only numbers.<br>");
        }

        // Validate postal code (only 6 digits allowed)
        if (postalCode.length() != 6) {
            hasErrors = true;
            errorMessage.append("Postal code must be 6 digits long.<br>");
        }

        if (hasErrors) {
            out.println("<div class='error'>" + errorMessage.toString() + "</div>");
        } else {
            try {
                // Make the connection
                getConnection();
                // Check if the userId already exists
                String checkUserIdQuery = "SELECT COUNT(*) FROM customer WHERE userid=?";
                PreparedStatement checkUserIdStmt = con.prepareStatement(checkUserIdQuery);
                checkUserIdStmt.setString(1, userid);
                ResultSet existingUsers = checkUserIdStmt.executeQuery();
                existingUsers.next();
                int userCount = existingUsers.getInt(1);
                if (userCount > 0) {
                    // Display error message if userId is taken
                    out.println("<div class='error'>The selected User ID is already taken. Please choose another one.</div>");
                } else {
                    // Create a prepared statement to insert data
                    String insertQuery = "INSERT INTO customer (firstName, lastName, email, phonenum, " +
                            "address, city, state, postalCode, country, userid, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement pstmt1 = con.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS);
                    pstmt1.setString(1, firstName);
                    pstmt1.setString(2, lastName);
                    pstmt1.setString(3, email);
                    pstmt1.setString(4, phoneNumber);
                    pstmt1.setString(5, address);
                    pstmt1.setString(6, city);
                    pstmt1.setString(7, state);
                    pstmt1.setString(8, postalCode);
                    pstmt1.setString(9, country);
                    pstmt1.setString(10, userid);
                    pstmt1.setString(11, password);
                    // Execute the statement
                    int rows_affected = pstmt1.executeUpdate();
                    // Retrieve auto-generated id
                    if(rows_affected > 0) {
                        // Retrieve auto-generated id
                        ResultSet keys = pstmt1.getGeneratedKeys();
                        keys.next();
                        int customerId = keys.getInt(1);
                    }
                    // Close resources
                    pstmt1.close();
                    closeConnection();
                    // Display success message and button to login page
                    out.println("<br><div>Account created successfully!</div>");
                }
                // Close resources
                checkUserIdStmt.close();
            } catch (SQLException e) {
                // Handle exceptions (display error message or redirect to an error page)
                out.println(e);
                out.println("<div class='error'>Error creating account. Please try again later.</div>");
            }
        }
    }
%>
</div>

</body>
</html>