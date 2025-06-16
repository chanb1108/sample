<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles" %>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>

<html lang="ko">
<head>
<meta charset="UTF-8">
<link type="text/css" rel="stylesheet" href="<c:url value='/css/egovframework/sample.css'/>"/>
<link type="text/css" rel="stylesheet" href="<c:url value='/css/egovframework/empty.css'/>"/>
<script src="./SBGrid3/sbgrid3.js" type="text/javascript"></script>
<link href="./SBGrid3/css/sbgrid3.css" rel="stylesheet" /> 
</head>
<body style="text-align:center; margin:0 auto; display:inline; padding-top:100px;">
	<div class="wrap">
		<div class="header"><tiles:insertAttribute name="header" /></div>
		<div class="content">
			<div id="body"><tiles:insertAttribute name="body" /></div>
		</div>
		<div class="footer"><tiles:insertAttribute name="footer" /></div>
	</div>
</body>
</html>