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
<style>
.container {
	width : 80%;
	hieght : 400px;
	background : #ccc;
	margin : auto;
}
</style>
</head>

<body style="text-align:center; margin:0 auto; display:inline; padding-top:100px;" onload="getGrid()">
	
    <button id="a" onclick="getData()">데이터호출</button>
    <button id="insert" onclick="insertData()">등록</button>
    <button id="modify" onclick="modifyData()">수정</button>
    <div class="container">
    	<div class="ipt_div">
    		<div class="semi_box">
	    		<div class="inner_box">
	    			<label>기관</label>
	    			<select id="Institution" name="Institution">
		    				<option value="">선택</option>
		    				<c:forEach items="${orgList}" var="item">
		    					<option value="${item.orIdx}">${item.orName}</option>
							</c:forEach>
	    			</select>
	    		</div>
    		</div>
    		<div class="semi_box">
	    		<div class="inner_box">
	    			<label>날짜</label>
	    			<select id="schDate" name="schDate">
		    				<option value="bbRegDate">등록일</option>
		    				<option value="bbModDate">수정일</option>
	    			</select>
	    		</div>
	    		<div class="inner_box">
	    			<label>시작일</label>
	    			<input type="date" id="strDate" max="2999-12-31" min="1900-01-01"></input>
	    		</div>
	    		<div class="inner_box">
	    			<label>종료일</label>
	    			<input type="date" id="endDate" max="2999-12-31" min="1900-01-01"></input>
	    		</div>
    		</div>
    		<div class="semi_box">
	    		<div class="inner_box">
	    			<label>제목</label>
	    			<input type="textbox" id="bbTitle"></input>
	    		</div>
    		</div>
    		<div class="semi_box">
	    		<div class="inner_box">
	    			<button id="initial">초기화</button>
	    			<button id="schGrid" onclick="searchGrid()">조회</button>
	    		</div>
    		</div>
    	</div>
    </div>
    <div id="grid"></div>
</body>
    <script src="https://code.jquery.com/jquery-3.4.1.js"></script>
	<script type="text/javaScript" language="javascript">
		
		var bbOrIdx = null;
		var schDate = null;
		var strDate = null;
		var endDate = null;
		var bbTitle = null;
		
		function searchGrid () {
			bbOrIdx = $("#Institution").val();
			schDate = $("#schDate").val();
			strDate = $("#strDate").val();
			endDate = $("#endDate").val();
			bbTitle = $("#bbTitle").val();
			if (strDate == "" && endDate != "") {
				alert("시작일이 없을 경우 날짜 조회가 불가합니다.");
			}
					
			if (bbOrIdx == "" && strDate == "" && endDate == "" && bbTitle == "") {
				getData();
			}else {
				console.log("bbOrIdx : " + bbOrIdx + " , "
						+ "schDate : " + schDate + " , "
						+ "strDate : " + strDate + " , "
						+ "endDate : " + endDate + " , "
						+ "bbTitle : " + bbTitle);
				getSchData();
			}
		}
	
		function getData () {
			$.ajax({
				type : "GET",
				url : "dataCall.do",
				dataType : "json",
				headers: {
				        "Accept": "application/json"
				},
				success: function (data, status, xhr) {
					alert("성공");
					getGrid(data);
				},
				error: function (data, status, error) {
					alert("에러");
				}
			});
		}
		
		function getSchData () {
			$.ajax({
				type : "POST",
				url : "schDataCall.do",
				data : JSON.stringify({
					"bbOrIdx" : bbOrIdx,
					"schDate" : schDate,
					"strDate" : strDate,
					"endDate" : endDate,
					"bbTitle" : bbTitle
				}),
			    contentType: "application/json", 
				dataType : "json",
				headers: {
				        "Accept": "application/json"
				},
				success: function (data, status, xhr) {
					getGrid(data);
				},
				error: function (data, status, error) {
					alert("에러");
				}
			});
		}
		
		function getGrid (data) {
			let gridConfig = {
				dataSource: data,
				container: "#grid",
				width: "80%",
				height: "200px",
				columns: [
					{field: 'bbIdx', caption: '일렬번호', width: 100},
					{field: 'bbTitle', caption: '제목', width: 100},
					{field: 'orName', caption: '업체명', width: 100},
					{field: 'bbRegDate', caption: '등록일시', width: 100},
					{field: 'bbHit', caption: '조회수', width: 100},
					{field: 'bbOpen', caption: '공개여부', width: 100},
				],
				doCommand: (grid, name, command) => {
					switch(name) {
						case 'event' : {
							if (command.event.type == 'dblclick') {
								const value = SBGrid3.getValue(grid, command.key, 'bbIdx');
								alert(value + " 수정페이지로 이동");
								modifyData(value);
							}
							break;	
						}
					}
				},
				editable : false,
			}
			datagrid = SBGrid3.createGrid(gridConfig);
			datagrid.refresh();
		}
		
		function gridEvent () {
			alert('확인');
		}
		
		function insertData () {
			location.href = "insertBoardEditor.do";
		}
		
		function modifyData (bbIdx) {
			location.href = "insertBoardEditor.do?bbIdx=" + bbIdx;
		}
		
	</script>
</html>
