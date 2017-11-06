<%@ page buffer="4kb" autoFlush="true" errorPage="/notice/error.jsp" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>
<%@ page import="weaver.file.FileUpload" %>
<jsp:useBean id="SysMaintenanceLog" class="weaver.systeminfo.SysMaintenanceLog" scope="page" />
<%@ page language="java" contentType="text/html; charset=UTF-8" %> <%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<%
if(!HrmUserVarify.checkUserRight("SystemSetEdit:Edit", user)){
	  response.sendRedirect("/notice/noright.jsp");
	  return;
}
FileUpload fu = new FileUpload(request);
String isDialog = Util.null2String(fu.getParameter("isdialog"));
String backto = Util.null2String(fu.getParameter("backto"));//返回类型
String operation = Util.fromScreen(fu.getParameter("operation"),user.getLanguage());
String id = Util.fromScreen(fu.getParameter("id"),user.getLanguage());

String encryptclass = Util.fromScreen(fu.getParameter("encryptclass"),user.getLanguage());
String encryptmethod = Util.fromScreen(fu.getParameter("encryptmethod"),user.getLanguage());
String mode = Util.fromScreen(fu.getParameter("mode"),user.getLanguage());

int userid = user.getUID();
String createdate = TimeUtil.getCurrentTimeString();
char separator = Util.getSeparator() ;
if(operation.equals("add")){
	RecordSet.executeSql("insert into outter_encryptclass(encryptclass,encryptmethod) values('"+encryptclass+"','"+encryptmethod+"')");
}
else if(operation.equals("edit")){
	RecordSet.execute("update outter_encryptclass set encryptclass = '"+encryptclass+"',encryptmethod = '"+encryptmethod+"' where id= "+id);
}
else if(operation.equals("delete")){
	List ids = Util.TokenizerString(id,",");
	if(null!=ids&&ids.size()>0)	{
		for(int i = 0;i<ids.size();i++)		{
			String tempsysid = Util.null2String((String)ids.get(i));
			
			if(!"".equals(tempsysid))			
			{
				RecordSet.execute("delete from outter_encryptclass where id = "+tempsysid);
			}
		}
	}
}
if("1".equals(isDialog)){
	
	if(!mode.equals("1")){
%>
<script language=javascript >
try{
	//var parentWin = parent.getParentWindow(window);
	var parentWin = parent.parent.getParentWindow(parent);
	parentWin.location.href="/interface/outter/outter_encryptclass.jsp?backto=<%=backto%>";
	parentWin.closeDialog();
}
catch(e){
}
</script>
<%
}else{
	
	%>
	<script language=javascript >
	try{
		
	var dialog = parent.parent.getDialog(parent);
	 dialog.callback();
     dialog.close();
	
	}
	catch(e){
	}
	</script>
	<%
}
}
else
response.sendRedirect("/interface/outter/outter_encryptclass.jsp?backto="+backto);
%>