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
</head>

<body style="text-align:center; margin:0 auto; display:inline; padding-top:100px;">
	
    <button id="a" onclick="getData()">데이터호출</button>
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
	    			<input type="date" max="2999-12-31" min="1900-01-01"></input>
	    		</div>
	    		<div class="inner_box">
	    			<label>종료일</label>
	    			<input type="date" max="2999-12-31" min="1900-01-01"></input>
	    		</div>
    		</div>
    		<div class="semi_box">
	    		<div class="inner_box">
	    			<label>제목</label>
	    			<input type="textbox"></input>
	    		</div>
    		</div>
    	</div>
    </div>
    <div id="grid"></div>
</body>
    <script src="https://code.jquery.com/jquery-3.4.1.js"></script>
	<script type="text/javaScript" language="javascript">
		
		var fakeData = [
			{'bbIdx':'1', 'bbTitle':'test_title1','orName':'test_center1','bbRegDate':'2025-05-21 16:50:55','bbHit':'10','bbOpen':'미공개'},
			{'bbIdx':'2', 'bbTitle':'test_title2','orName':'test_center2','bbRegDate':'2025-05-21 16:50:55','bbHit':'10','bbOpen':'공개'},
			{'bbIdx':'3', 'bbTitle':'test_title3','orName':'test_center3','bbRegDate':'2025-05-21 16:50:55','bbOpen':'미공개' ,'bbHit':'10'},
		]
	
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
		
		function getGrid (data) {
			let gridConfig = {
				dataSource: data,
				container: "#grid",
				width: "80%",
				height: "200px",
				columns: [
					{field: 'bbTitle', caption: '제목', width: 100},
					{field: 'orName', caption: '업체명', width: 100},
					{field: 'bbRegDate', caption: '등록일시', width: 100},
					{field: 'bbHit', caption: '조회수', width: 100},
					{field: 'bbOpen', caption: '공개여부', width: 100},
				],
			}
			datagrid = SBGrid3.createGrid(gridConfig);
			datagrid.refresh();
		}
		
	</script>
</html>
