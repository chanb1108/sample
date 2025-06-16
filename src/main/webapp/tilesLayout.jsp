<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles" %>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link type="text/css" rel="stylesheet" href="<c:url value='/css/egovframework/sample.css'/>"/>
<link type="text/css" rel="stylesheet" href="<c:url value='/css/egovframework/base.css'/>"/>
<link rel="stylesheet" href="/SynapEditor/synapeditor.min.css" />
<link rel="stylesheet" href="/SynapEditor/externalStyle.css" />
<link rel="stylesheet" type="text/css" href="/SynapEditor/synapeditor.min.css" />
<script src='/SynapEditor/synapeditor.config.js'></script>
<script src='/SynapEditor/synapeditor.min.js'></script>
<script type="text/javascript" src='/xFreeUploader/js/xFreeUploader.js'></script>
<script src="./SBGrid3/sbgrid3.js" type="text/javascript"></script>
<link href="./SBGrid3/css/sbgrid3.css" rel="stylesheet" /> 
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
</head>
<body style="text-align:center; margin:0 auto; display:inline; padding-top:100px;">
	<div class="wrap">
		<div class="header"><tiles:insertAttribute name="header" /></div>
		<div class="content">
			<div id="sideBar"><tiles:insertAttribute name="sideBar" /></div>
			<div id="body"><tiles:insertAttribute name="body" /></div>
		</div>
		<div class="footer"><tiles:insertAttribute name="footer" /></div>
	</div>
</body>
</html>