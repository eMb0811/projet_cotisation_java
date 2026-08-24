<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirection automatique vers la Servlet de Login ou Dashboard
    response.sendRedirect(request.getContextPath() + "/login");
%>
