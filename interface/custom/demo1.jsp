<%@ page import="a.DdAction" %><%--
  Created by IntelliJ IDEA.
  User: wangjiepc
  Date: 2017/10/31
  Time: 23:02
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<%
    String dd  = DdAction.getString();
    out.print(dd);
%>
</body>
</html>
