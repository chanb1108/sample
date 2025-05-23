<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="com.google.gson.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>

<%@page import="java.util.Base64"%>
<%@page import="java.util.Base64.Decoder"%>
<%@page import="java.util.Base64.Encoder"%>

<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8"); 

/*
(공백) : 이하를 해석하지 못하는 USER_AGENT 가 있을 수 있음
+ : 공백으로 해석 또는 인식되는 경우가 있음
? : 이하 쿼리로 인식됨
# : 이하 문자를 fragment 로 인식될 수 있음
& : 쿼리의 구분으로 인식될 수 있음
/ : PATH_INFO 로 구분한다면 하나의 path 로 인식되지 않음
*/


Enumeration params = request.getParameterNames();
String jsonBuffer = "";

while(params.hasMoreElements()) {
	
	jsonBuffer += (String) params.nextElement();	
}

String path = request.getServletContext().getRealPath("/xFreeUploader/examples/v2/bbs/uploads_bbs/");
System.out.println(path + "dataobj.js");

// 데이터 내용 js파일에 저장
File file = new File(path + "dataobj.js");
String str = jsonBuffer;

try {
    //BufferedWriter writer = new BufferedWriter(new FileWriter(file));
	BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"));
    writer.write(str);
    writer.close();
} catch (IOException e) {
    e.printStackTrace();
}

// 반환 데이터 표현
out.println(jsonBuffer);

%>