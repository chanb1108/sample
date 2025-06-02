<%@page import="java.util.List"%>
<%@page import="egovframework.example.sample.service.FileVO"%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title><spring:message code="title.sample" /></title>
    <link type="text/css" rel="stylesheet" href="<c:url value='/css/egovframework/sample.css'/>"/>
    <script type="text/javaScript" language="javascript" defer="defer"></script>
    <script src="./SBGrid3/sbgrid3.js" type="text/javascript"></script>
    <link href="./SBGrid3/css/sbgrid3.css" rel="stylesheet" /> 
	<script type="text/javascript" src='/page/xFreeUploader/js/xFreeUploader.js'></script>
	<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
</head>
<script type="text/javascript">

	var wFileDownload = new xFreeUploader({
		render : "fileDownload",
		basePath : location.protocol + "//" + document.domain + ":" + location.port + "/page/xFreeUploader",
		selectMode : "download",
		serverType : "jsp",
		bodyHeight : 250,
		fileListUrl : "/tagfree/xfuDownload.do",
		downloadUrl : "/tagfree/xfuDownload.do",
		onBeforeSearch : function(data) { console.log("파일 조회 전"); },
		onLoad : function(data) { 
			console.log("파일 조회 진행");
			console.log(data);
			getFileData();
		},
		onSearchCallback : function(data) { console.log("파일 조회 후"); },
		onBeforeSubmit : function(data) { 
			console.log("다운로드 받기 전");
			console.log(data);
		},
		onSuccessCallback : function(data) { console.log("다운로드 받은 후"); },
		onFailCallback : function(data){ console.log("파일다운로드 실패"); }
	});
	
	function getFileData() {	
		<c:forEach items="${fileList}" var="item">
			wFileDownload.fileAttachAddTxt("${item.bfName}","${item.bfSrc}","${item.bfSize}","${item.bfRegDate}","");
		</c:forEach>
	}
</script>
<body style="text-align:center; margin:0 auto; display:inline; padding-top:100px;">
	<table border>
		<tr>
			<td>제목</td>
			<td>${boardVo.bbTitle}</td>
		</tr>
		<tr>
			<td>기관</td>
			<td>${boardVo.orName}</td>
		</tr>
		<tr>
			<td>등록일</td>
			<td>${boardVo.sdfBbRegDate}</td>
		</tr>
		<tr>
			<td>첨부파일</td>
			<td><div class="xFreeUploader-pnl" id="fileDownload"></div></td>
		</tr>
		<tr>
			<td colspan="2">${boardVo.bbContent}</td>
		</tr>
		<tr>
			<td colspan="2">
				<button id="goList">뒤로</button>
				<button id="goModify">수정</button>
			</td>
		</tr>
	</table>
</body>
<script type="text/javaScript" language="javascript">
	
	var bbIdx = "${boardVo.bbIdx}";
	
	console.log(bbIdx);

	$("#goModify").on("click", function (){
		location.href = "insertBoardEditor.do?bbIdx=" + bbIdx;
	})
	
	$("#goList").on("click", function (){
		location.href = "boardList.do";
	})
</script>
</html>
