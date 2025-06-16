<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<html lang="ko">
<table  id="detailTable">
	<tr>
		<td>PPOPOP</td>
		<td>${bbsVo.bbTitle}</td>
	</tr>
	<tr>
		<td>기관</td>
		<td>${bbsVo.orName}</td>
	</tr>
	<tr>
		<td>등록일</td>
		<td>${bbsVo.bbRegDate}</td>
	</tr>
	<tr id="fileForm">
		<td>첨부파일</td>
		<td><div class="xFreeUploader-pnl" id="fileDownload"></div></td>
	</tr>
	<tr>
		<td colspan="2">${bbsVo.bbContent}</td>
	</tr>
	<tr>
		<td colspan="2">
			<button id="bbsListBtn" onclick="location.href ='bbsList.do'">뒤로</button>
			<button id="modBtn">수정</button>
		</td>
	</tr>
</table>
<script type="text/javaScript" language="javascript">

$(function(){

	var bbIdx = '${bbsVo.bbIdx}';
	
	list.init();
	
	$('#modBtn').on('click', function (){
		location.href = 'insertBbsForm.do?bbIdx=' + bbIdx; 
	})
    
});

let list = {
		
		
	init : function(){
		fileDown.getFileDown();
    }
        
    , getFileData : function () {	
		<c:forEach items='${bbsFileList}' var='item'>
			fileDown.wFileDownload.fileAttachAddTxt('${item.bfOrgName}','${item.bfSrc}','${item.bfSize}','${item.bfRegDate}','');
		</c:forEach>
	}
    
}

let fileDown = {
	wFileDownload : ''
	
	, getFileDown : function () {
		this.wFileDownload = new xFreeUploader({
			render : 'fileDownload'
				, basePath : '/xFreeUploader'
				, selectMode : 'download'
				, serverType : 'jsp'
				, bodyHeight : 250
				, fileListUrl : '/tagfree/xfuDownload.do'
				, downloadUrl : '/tagfree/xfuDownload.do'
				, onBeforeSearch : function(data) { console.log('파일 조회 전'); }
				, onLoad : function(data) { 
					console.log('파일 조회 진행');
					list.getFileData();
				}
				, onSearchCallback : function(data) { console.log('파일 조회 후'); }
				, onBeforeSubmit : function(data) { console.log('다운로드 받기 전');	}
				, onSuccessCallback : function(data) { console.log('다운로드 받은 후'); }
				, onFailCallback : function(data){ console.log('파일다운로드 실패'); }
			});
	}
}
</script>
</html>
