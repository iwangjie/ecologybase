
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet1" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet2" class="weaver.conn.RecordSet" scope="page" />
<%
String operate = Util.fromScreen(request.getParameter("operate"),user.getLanguage());
RecordSet.executeSql("delete  outter_account where userid="+user.getUID());
RecordSet.executeSql("delete  outter_params where userid="+user.getUID());
RecordSet.executeSql("select * from outter_sys");
while(RecordSet.next()){
String sysid= RecordSet.getString("sysid");
String account = Util.fromScreen(request.getParameter("account_999_"+sysid),user.getLanguage());
String password = Util.fromScreen(request.getParameter("password_999_"+sysid),user.getLanguage());
//密码加密存储
if(!password.equals("")){
password= SecurityHelper.encryptSimple(password);
 }

String logintype = Util.fromScreen(request.getParameter("logintype_999_"+sysid),user.getLanguage());
String date = TimeUtil.getCurrentDateString();
String time = TimeUtil.getOnlyCurrentTimeString();
RecordSet1.executeSql("insert into outter_account(sysid,userid,account,password,logintype,createdate,createtime,modifydate,modifytime) values('"+sysid+"',"+user.getUID()+",'"+account+"','"+password+"','"+logintype+"','"+date+"','"+time+"','"+date+"','"+time+"')") ;
RecordSet1.executeSql("select * from outter_sysparam where paramtype=1 and  sysid='"+sysid+"'");
while(RecordSet1.next()){                  
	String paramname=RecordSet1.getString("paramname");
	String paramvalue=Util.fromScreen(request.getParameter(paramname+"_"+sysid),user.getLanguage());
    RecordSet1.executeSql("insert into outter_params(sysid,userid,paramname,paramvalue) values('"+sysid+"',"+user.getUID()+",'"+paramname+"','"+paramvalue+"')") ;
}
}

if(operate.equals("insert")) {
%>
<script>
    alert("<%=SystemEnv.getHtmlLabelName(16746,user.getLanguage())%>");
        window.location = "/interface/AccountSettingFrame.jsp";
</script>
<%}else{
    response.sendRedirect("login.jsp");
}%>

