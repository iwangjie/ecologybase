
<%@page import="weaver.interfaces.outter.CheckIpNetWork"%>
<%@page import="weaver.interfaces.outter.OutterUtil"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ page import="java.lang.reflect.*" %>
<%@page import="weaver.outter.OutterDisplayHelper"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet1" class="weaver.conn.RecordSet" scope="page" />
<%@ page contentType="text/html;charset=GBK" language="java"%>
<%

	String sysid = Util.null2String(request.getParameter("id"));//ϵͳ��ʶ
	String gopage = Util.null2String(request.getParameter("gopage"));//��½��ֱ����ʾ�ĸ�ҳ��
	//Ȩ���ж�
	//�õ���Ȩ�޲鿴�ļ��ɵ�¼
OutterDisplayHelper ohp=new OutterDisplayHelper();
String sqlright=ohp.getShareOutterSql(user);
String sql="select sysid from outter_sys a where sysid='"+sysid+"' and EXISTS (select 1 from ("+sqlright+") b where a.sysid=b.sysid )";
RecordSet.executeSql(sql);

if(RecordSet.getCounts()<1){
	response.sendRedirect("/notice/noright.jsp");
 	return;
}

	String account = "";
	String password = "";
	String logintype = "1";//��������
	String requesttype = "";//����ʽ
	String encrypttype = "";//�����㷨
	String baseparam1 = "";//�˺Ų�����
	String baseparam2 = "";//���������
	
	String encryptclass = "";
	String encryptmethod = "";
	Object object = null;
	Method method = null;
	
	String urlparaencrypt1 = "";//�Ƿ�����˺Ų�����
	String encryptcode1 = "";//������Կ
	String urlparaencrypt2 = "";//�Ƿ�������������
	String encryptcode2 = "";//������Կ
	String urlparaencrypt = "";//�Ƿ���ܲ���������
	String encryptcode = "";//������Կ

	int basetype1 = 0;//�Ƿ�ʹ��ecology�˺�
	int basetype2 = 0;//�Ƿ�ʹ��ecology����
	String urlencodeflag="";  //�Ƿ����
	String autologinflag="";  //�Ƿ��������Զ���¼
	String encryptclassId="";  //�Զ�������㷨id
	
	RecordSet.executeSql("select t1.*,t2.encryptclass as encryptclass1,t2.encryptmethod as encryptmethod1 from outter_sys t1 LEFT JOIN outter_encryptclass t2 on t1.encryptclassId=t2.id where sysid='"+ sysid + "'");
	String serverurl = "AccountSetting.jsp?sysid=" + sysid;
	String iurl = "";
	String ourl = "";
	String typename = "";
	if (RecordSet.next()) {
		requesttype = Util.null2String(RecordSet.getString("requesttype"));
		if(requesttype.equals("")||requesttype==null){
			requesttype="POST";
		}
		encrypttype = Util.null2String(RecordSet.getString("encrypttype"));
		
		encryptclass = Util.null2String(RecordSet.getString("encryptclass1"));
		encryptmethod = Util.null2String(RecordSet.getString("encryptmethod1"));
		
		baseparam1 = Util.null2String(RecordSet.getString("baseparam1"));
		urlparaencrypt1 = Util.null2String(RecordSet.getString("urlparaencrypt1"));//�Ƿ����
		encryptcode1 = Util.null2String(RecordSet.getString("encryptcode1"));//������Կ
		
		baseparam2 = Util.null2String(RecordSet.getString("baseparam2"));
		urlparaencrypt2 = Util.null2String(RecordSet.getString("urlparaencrypt2"));//�Ƿ����
		encryptcode2 = Util.null2String(RecordSet.getString("encryptcode2"));//������Կ
		
		basetype1 = Util.getIntValue(RecordSet.getString("basetype1"),0);
		basetype2 = Util.getIntValue(RecordSet.getString("basetype2"),0);
		iurl = Util.null2String(RecordSet.getString("iurl"));
		ourl = Util.null2String(RecordSet.getString("ourl"));
		urlparaencrypt = Util.null2String(RecordSet.getString("urlparaencrypt"));//�Ƿ����
		encryptcode = Util.null2String(RecordSet.getString("encryptcode"));//������Կ
		
		typename = Util.null2String(RecordSet.getString("typename"));
		urlencodeflag = Util.null2String(RecordSet.getString("urlencodeflag"));
		autologinflag = Util.null2String(RecordSet.getString("autologin"));  //�������Զ���¼
		//encryptclassId = Util.null2String(RecordSet.getString("encryptclassId"));  //�Զ�������㷨id
	}

	if(!"".equals(encryptclass)&&!"".equals(encryptmethod))
	{
		try
		{
			Class clazz = Class.forName(encryptclass);
			object = clazz.newInstance();
			Class [] paramtype = new Class[1];
			paramtype[0] = java.lang.String.class;
			method = clazz.getMethod(encryptmethod, paramtype);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	RecordSet.executeSql("select account,password,logintype from outter_account where sysid='"+ sysid + "' and userid=" + user.getUID());
	if (RecordSet.next()) {
		account = RecordSet.getString("account");
		password = RecordSet.getString("password");
		//����
        if(!password.equals("")){
        password=SecurityHelper.decryptSimple(password);
        }
		if (basetype1 == 1) {//ʹ��ecology�˺�
			account = user.getLoginid();
		}
		if (basetype2 == 1) {//ʹ��ecology����
			password = (String) session.getAttribute("password");
		}
		if(autologinflag.equals("1"))  //�����������Զ���¼
		{
			CheckIpNetWork checkipnetwork = new CheckIpNetWork();
			String clientIP = request.getRemoteAddr();
			boolean checktmp = checkipnetwork.checkIpSeg(clientIP,sysid);//true��ʾ������֮��,false��ʾ������֮��
			if(checktmp){//true��ʾ������֮��
				serverurl = ourl;
			}else{
				serverurl = iurl;//false��ʾ������֮��
			}
		}else{
		logintype = RecordSet.getString("logintype");
		if (logintype.equals("1"))
			serverurl = iurl;
		else
			serverurl = ourl;
		}
	}else{//����ʹ��ecology�˺ź�ʹ��ecology���룬�Զ���outter_account�м������ݣ������û���������ҳ��
		//ʹ��ecology�˺š�ʹ��ecology���룬����ͬʱû�в�����
		if ((basetype1 == 1 && basetype2 == 1 && !baseparam1.equals("") && !baseparam2.equals("")) 
			|| (baseparam1.equals("") && baseparam2.equals(""))
			|| (baseparam1.equals("") && basetype2 == 1 && !baseparam2.equals(""))
			|| (baseparam2.equals("") && basetype1 == 1 && !baseparam1.equals(""))
		) {
			//������ϸ���в�������Ϊ�û�¼��Ĳ�������Ϊ0���Զ�������ݲſ�����
			RecordSet.executeSql("select * from outter_sysparam where paramtype=1 and sysid='"+ sysid + "' order by indexid");
			if(RecordSet.getCounts()==0){
			account = user.getLoginid();
			password = (String) session.getAttribute("password");
			//��������
			String date = TimeUtil.getCurrentDateString();
			String time = TimeUtil.getOnlyCurrentTimeString();
			RecordSet1.executeSql("insert into outter_account(sysid,userid,logintype,createdate,createtime,modifydate,modifytime) values('"+sysid+"',"+user.getUID()+","+logintype+",'"+date+"','"+time+"','"+date+"','"+time+"')") ;
			//���ص�ַ
			if(autologinflag.equals("1"))  //�����������Զ���¼
		  	{
			CheckIpNetWork checkipnetwork = new CheckIpNetWork();
			String clientIP = request.getRemoteAddr();
			boolean checktmp = checkipnetwork.checkIpSeg(clientIP,sysid);//true��ʾ������֮��,false��ʾ������֮��
			if(checktmp){//true��ʾ������֮��
				serverurl = ourl;
			}else{
				serverurl = iurl;//false��ʾ������֮��
			}
		}else{
			if (logintype.equals("1")){
				serverurl = iurl;
			}else{
				serverurl = ourl;
			}
			}
		}
		}
	}
	if (serverurl.indexOf("AccountSetting.jsp") > -1) {
		response.sendRedirect(serverurl);
		return;
	}
	
	if("1".equals(typename)) {
		response.sendRedirect("NcEntrance.jsp?id="+sysid);
		return;
	}
	String requesttypestr = requesttype;
	if("1".equals(encrypttype)&&"1".equals(urlparaencrypt1)&&!"".equals(account))
	{
		encryptcode1 = "".equals(encryptcode1)?"ecology":encryptcode1;
		account = SecurityHelper.encrypt(encryptcode1,account);
	}
	else if("2".equals(encrypttype)&&"1".equals(urlparaencrypt1)&&!"".equals(account))
	{
		if(null!=object&&null!=method)
		{
			try
			{
				Object [] paramvalue = new Object[1];
				paramvalue[0] = account;
				account = (String)method.invoke(object, paramvalue);
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
	}else if("3".equals(encrypttype)&&"1".equals(urlparaencrypt1)&&!"".equals(account))  //��׼MD5����
	{
		account = OutterMD5.encrypt(account,"UTF-8");
	}
	if("1".equals(encrypttype)&&"1".equals(urlparaencrypt2)&&!"".equals(password))
	{
		encryptcode2 = "".equals(encryptcode2)?"ecology":encryptcode2;
		password = SecurityHelper.encrypt(encryptcode2,password);
	}
	else if("2".equals(encrypttype)&&"1".equals(urlparaencrypt2)&&!"".equals(password))
	{
		if(null!=object&&null!=method)
		{
			try
			{
				Object [] paramvalue = new Object[1];
				paramvalue[0] = password;
				password = (String)method.invoke(object, paramvalue);
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
	}else if("3".equals(encrypttype)&&"1".equals(urlparaencrypt2)&&!"".equals(password))
	{
		password = OutterMD5.encrypt(password,"UTF-8");
	}
	String param_get = "";
	if(serverurl.indexOf("ftp://")>-1){
		String ftpurl = "ftp://" + account + ":" + password + "@" + serverurl.substring(6);
		response.sendRedirect(ftpurl);
		return;
	}else{
		String str = "<html><body>\n"
				+ "<form name=Loginform action='"
				+ serverurl
				+ "' method="+requesttypestr+" target='_self'><INPUT type='hidden' NAME='gopage' VALUE='"
				+ gopage + "'>";
		RecordSet.executeSql("select * from outter_sysparam where sysid='"+ sysid + "' order by indexid");
		while (RecordSet.next()) {
			int paramtype = Util.getIntValue(RecordSet.getString("paramtype"), 0);
			String paramname = RecordSet.getString("paramname");
			String paramvalue = RecordSet.getString("paramvalue");
			String dparaencrypt = RecordSet.getString("paraencrypt");//�Ƿ����
			String dencryptcode = RecordSet.getString("encryptcode");//������Կ
			if (paramtype == 0) {//�̶�ֵ
				;
			} else if (paramtype == 1) {//�û�����
				RecordSet1.executeSql("select * from outter_params where sysid='"
								+ sysid
								+ "' and userid="
								+ user.getUID()
								+ " and paramname='" + paramname + "'");
				if (RecordSet1.next())
					paramvalue = RecordSet1.getString("paramvalue");
	
			} else if (paramtype == 2) {//�ֲ�
				paramvalue = "" + user.getUserSubCompany1();
			} else if (paramtype == 3) {//����
				paramvalue = "" + user.getUserDepartment();
			}else if(paramtype == 4){  //���ʽ
				
				OutterUtil tu=new OutterUtil();
				paramvalue = tu.getExpressionValue(paramvalue,sysid,user,(String)session.getAttribute("password"));
			}else if(paramtype == 5){ //���ʽ����
				continue;  
			}
			if("1".equals(encrypttype)&&"1".equals(dparaencrypt)&&!"".equals(paramvalue))
			{
				dencryptcode = "".equals(dencryptcode)?"ecology":dencryptcode;
				paramvalue = SecurityHelper.encrypt(dencryptcode,paramvalue);
			}
			else if("2".equals(encrypttype)&&"1".equals(dparaencrypt)&&!"".equals(paramvalue))
			{
				if(null!=object&&null!=method)
				{
					try
					{
						Object [] paramvalue1 = new Object[1];
						paramvalue1[0] = paramvalue;
						paramvalue = (String)method.invoke(object, paramvalue1);
					}
					catch(Exception e)
					{
						e.printStackTrace();
					}
				}
			}else if("3".equals(encrypttype)&&"1".equals(dparaencrypt)&&!"".equals(paramvalue))
			{
				paramvalue = OutterMD5.encrypt(paramvalue,"UTF-8");
			}
			str += "<INPUT type='hidden' NAME='" + paramname + "' VALUE='"+  paramvalue+ "'>";
			param_get+=(param_get.length()==0?"":"&")+paramname+"="+encodestr(paramvalue,urlencodeflag);
		}
		if(!"".equals(baseparam1)){
			str += "<INPUT type='hidden' NAME='" + baseparam1 + "' VALUE='" + account+ "'>" ;
			param_get+=(param_get.length()==0?"":"&")+baseparam1+"="+encodestr(account,urlencodeflag)+"";
		}
		if(!"".equals(baseparam2)){
			str += "<INPUT type='hidden' NAME='" + baseparam2 + "' VALUE='" + password + "'>";
			param_get+=(param_get.length()==0?"":"&")+baseparam2+"="+encodestr(password,urlencodeflag)+"";
		}
		Enumeration em = request.getParameterNames();
		if(null!=em)
		{
			while(em.hasMoreElements())
			{
				String temppname = Util.null2String((String)em.nextElement());
				if(!"id".equals(temppname)&&!"gopage".equals(temppname))
				{
					String temppvalue = Util.null2String(request.getParameter(temppname));
					str += "<INPUT type='hidden' NAME='" + temppname + "' VALUE='"+ temppvalue + "'>";
					param_get+=(param_get.length()==0?"":"&")+temppname+"="+encodestr(temppvalue,urlencodeflag)+"";
				}
			}
		}
		if (sysid.equals("1")) {
			//todo,add yourselves html fields
			str += "</form></body></html>"
					+ "<script>Loginform.submit();</script>";
			out.print(str);
		} else if (sysid.equals("2")) {
			//todo,add yourselves html fields
			str += "</form></body></html>"
					+ "<script>Loginform.submit();</script>";
			out.print(str);
		} else {
			if(requesttypestr.equalsIgnoreCase("POST")){
				str += "</form></body></html>"
					+ "<script>Loginform.submit();</script>";
					RecordSet.writeLog(str);
				out.print(str);
			}else if(requesttypestr.equalsIgnoreCase("GET")){
				String url = "";
				if(serverurl.indexOf("?")>-1){
				url=serverurl+"&"+param_get;
				}else{
				url=serverurl+"?"+param_get;
				}
				//new weaver.general.BaseBean().writeLog("sso url : " + url) ;
				out.println("<script language='javascript'>");
				if(urlencodeflag.equals("1")){
				out.println("window.location.href=encodeURI('"+url+"')");
				}else{
				out.println("window.location.href='"+url+"'");
				}
				out.println("</script>");
			}
		}
	}
	
%>
<%!
public String encodestr(String str,String flag){
if(flag.equals("1")){
	return java.net.URLEncoder.encode(str);
}else{
	return str;
	}
}
 %>




