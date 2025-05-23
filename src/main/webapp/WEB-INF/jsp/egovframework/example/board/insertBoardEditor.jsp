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
    <link rel="stylesheet" href="/page/SynapEditor/synapeditor.min.css" />
    <link rel="stylesheet" href="/page/SynapEditor/externalStyle.css" />
    <link rel="stylesheet" type="text/css" href="/page/SynapEditor/synapeditor.min.css" />
	<script src='/page/SynapEditor/synapeditor.config.js'></script>
	<script src='/page/SynapEditor/synapeditor.min.js'></script>
	<script type="text/javascript" src='/page/xFreeUploader/js/xFreeUploader.js'></script>
	<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
</head>
<script>

	var se = null;
	function initEditor() {
	    se = new SynapEditor("bbContent", synapEditorConfig);
	}
	
	function isEditor(){
		if(!se.isEmpty()) {
			return false;
		}else {
			return true;	
		}
	}
</script>

<script type="text/javascript">

	var wFileUpload = new xFreeUploader({
		render : "fileUpload",
		basePath : location.protocol + "//" + document.domain + ":" + location.port + "/page/xFreeUploader",
		selectMode : "upload",
		filePath : "/uploads",
		serverType : "aspx",
		bodyHeight : 250,
		onAddFile : function(data){ console.log("파일추가"); },
		onDeleteFile : function(data){ console.log("항목제거"); },
		onDeleteAllFile : function(data){ console.log("항목전체제거"); },
		onBeforeSubmit : function(data){ console.log("파일전송하기전"); },
		onSuccessCallback:function(data){ console.log("upload success"); },
		onFailCallback:function(error){ console.log("upload fail"); }
	});

</script>
<body style="text-align:center; margin:0 auto; display:inline; padding-top:100px;" onload="initEditor()">
	
	<table border>
		<tr>
			<td colspan="2">
				<input type="checkbox" id="bbNotice"">상단 고정 공지사항으로 등록</input>
			</td>
		</tr>
		<tr>
			<td>
				<label>기관</label>
			</td>
			<td>
				<select id="Institution" name="Institution">
	    				<option value="">선택</option>
	    				<c:forEach items="${orgList}" var="item">
	    					<option value="${item.orIdx}">${item.orName}</option>
						</c:forEach>
    			</select>
			</td>
		</tr>
		<tr>
			<td>
				<label>제목</label>
			</td>
			<td>
				<input type="textbox" id="bbTitle"></input>
			</td>
		</tr>
		<tr>
			<td>
				<label>내용</label>
			</td>
			<td>
				<div style="width: 1000px; height:300px;">
			        <textarea id="bbContent"></textarea>
			    </div>
			</td>
		</tr>
		<tr>
			<td>
				<label>첨부파일</label>
			</td>
			<td>
				<div class="xFreeUploader-pnl" id="fileUpload"></div>
			</td>
		</tr>
		<tr>
			<td>
				<label>공개여부</label>
			</td>
			<td>
		       <input type="radio" id="bbOpenY" name="openYn" value="1" checked>
		       <label for="openY">공개</label>
		       <input type="radio" id="bbOpenN" name="openYn" value="0">
		       <label for="openN">비공개</label>
			</td>
		</tr>
		<tr>
			<td>
				<label>등록일</label>
			</td>
			<td>
				<input type="date" max="2999-12-31" min="1900-01-01" value="${today}" id="bbRegDate" disabled></input>
			</td>
		</tr>
		<tr>
			<td>
				<label>조회수</label>
			</td>
			<td>
				<input type="textbox" value="0" id="bbHit" disabled></input>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<button id="cansle">취소</button>
				<button id="save">등록</button>
			</td>
		</tr>
	</table>
</body>
<script type="text/javascript">
	
	var bbNotice = null;
	var orIdx = null;
	var bbTitle = null;
	var bbContent = null;
	var bbOpen = null;

	$("#cansle").on("click", function (){
		alert("입력 취소")
		initEditor();
	})
	
	$("#save").on("click", function (){
		saveValidate();
	})
	
	function saveValidate () {
		if (!$("#Institution").val()) {
			return alert("기관 미선택");
		} else {
			orIdx = $("#Institution").val();
		}
		
		if (!$("#bbTitle").val()) {
			return alert("제목 미기입");
		} else {
			bbTitle = $("#bbTitle").val();
		}
		
		if (isEditor()){
			return alert("내용 미기입")
		} else {
			bbContent = $("#bbContent").val();
		}
		
		if ($("input[name=openYn]:checked").val() > 1 || $("input[name=openYn]:checked").val() == null || $("input[name=openYn]:checked").val() == "") {
			alert($("input[name=openYn]:checked").val() + "오류")
		} else {
			bbOpen = $("input[name=openYn]:checked").val();
		}
		
		if ($('#bbNotice').is(':checked')) {
			bbNotice = "1"
		}else{
			bbNotice = "0"
		}
		
		saveBb();
	}
	
	function saveBb () {
		$.ajax({
			type : "POST",
			url : "insertBoard.do",
			contentType : "application/json",
			data : JSON.stringify({
				"bbNotice" : bbNotice,
				"bbOrIdx" : orIdx,
				"bbTitle" : bbTitle,
				"bbContent" : bbContent,
				"bbOpen" : bbOpen,
			}),
			dataType : "text",
			success: function (data, status, xhr) {
				alert(data);
			},
			error: function (data, status, error) {
				alert(data);
			}
		});
	}
</script>
</html>
