<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<form onSubmit="fileUpload.fileSave()" method="post">
	<table id="insertForm">
		<tr>
			<td colspan="2">
				<input type="checkbox" id="bbNotice" name="bbNotice" <c:if test='${bbsVo.bbNotice == 1}'>checked</c:if>>상단 고정 공지사항으로 등록</input>
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
				<input type="textbox" id="bbTitle" name="bbTitle" <c:if test='${bbsVo.bbTitle != null}'>value="${bbsVo.bbTitle}"</c:if>></input>
			</td>
		</tr>
		<tr>
			<td>
				<label>내용</label>
			</td>
			<td>
				<div style="width: 100%; height:300px;">
					<textarea id="bbContent" name="bbContent"><c:if test='${bbsVo.bbContent != null}'>${bbsVo.bbContent}</c:if></textarea>
	
			    </div>
			</td>
		</tr>
		<tr>
			<td id="fileForm">
				<label>첨부파일</label>
			</td>
			<td>
				<div class="xFreeUploader-pnl" id="fileUpload" name="fileUpload"></div>
			</td>
		</tr>
		<tr>
			<td>
				<label>공개여부</label>
			</td>
			<td>
				<c:choose>
					<c:when test="${bbsVo.bbOpen != null && bbsVo.bbOpen == 0}">
				       <input type="radio" id="bbOpenY" name="openYn" value="1">
				       <label for="openY">공개</label>
				       <input type="radio" id="bbOpenN" name="openYn" value="0" checked>
				       <label for="openN">비공개</label>
				    </c:when>
				    <c:otherwise>
					    <input type="radio" id="bbOpenY" name="openYn" value="1" checked>
					       <label for="openY">공개</label>
					       <input type="radio" id="bbOpenN" name="openYn" value="0">
					       <label for="openN">비공개</label>
					</c:otherwise>
				</c:choose>
			</td>
		</tr>
		<tr>
			<td>
				<label>등록일</label>
			</td>
			<td>
				<c:choose>
				<c:when test="${bbsVo.bbRegDate != null}">
					<fmt:formatDate value="${bbsVo.bbRegDate}" pattern="yyyy-MM-dd" />
				</c:when>
				<c:otherwise>
					<label>${today}</label>
				</c:otherwise>
				</c:choose>
			</td>
		</tr>
		<tr>
			<td>
				<label>조회수</label>
			</td>
			<td>
				<c:choose>
				<c:when test='${bbsVo.bbHit != null && bbsVo.bbHit > 0}'>
					<input type="textbox" value="${bbsVo.bbHit}" id="bbHit" disabled></input>
				</c:when>
				<c:otherwise>
					<input type="textbox" value="0" id="bbHit" disabled></input>
				</c:otherwise>
				</c:choose>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="button" id="cancelBtn" onclick="form.cancel()" value="취소"></input>
				<c:choose>
				<c:when test="${bbsVo.bbIdx > 0 && bbsVo.bbIdx != null}">
					<input type="submit" value="수정" />
				</c:when>
				<c:otherwise>
					<input type="submit" value="등록" />
				</c:otherwise>
				</c:choose>
			</td>
		</tr>
	</table>
</form>
<script type="text/javascript">

$(function(){
	
	bbsForm.init();
    
    $('#cancelBtn').on('click', function (){
    	bbsForm.cancel();
    })
    
});

let bbsForm = {
	
	init : function () {
		bbsForm.dataChk();
		editor.initEditor();
		fileUpload.getFileUploader();
	}
	
	, dataChk : function () {
		if ('${bbsVo.bbOrIdx}' != null && '${bbsVo.bbOrIdx}' != '') {
			$('select[name=Institution] option[value=${bbsVo.bbOrIdx}]').prop('selected',true);
		}
	}
	
	, getFileData : function (wFileUpload) {	
		<c:forEach items='${bbsFileList}' var='item'>
			console.log('${item.bfIdx}');
			wFileUpload.fileAttachAddTxt('${item.bfOrgName}','${item.bfSrc}','${item.bfSize}','${item.bfRegDate}','');
		</c:forEach>
	}
	
	, cancel : function () {
		if ('${bbsVo.bbIdx}' != '') {
			alert('상세페이지로 이동합니다.');
			location.href = 'bbsDetail.do?bbIdx=' + '${bbsVo.bbIdx}';
		}else {
			alert('게시판 목록 페이지로 이동합니다.');
			location.href = 'bbsList.do';
		}
	}
	
	, saveValidate : function () {
		
		editor.isEditor();
		
		if (!$('#Institution').val()) {
			return alert('기관 미선택');
		} 
		else if (!$('#bbTitle').val()) {
			return alert('제목 미기입');
		} 
		else if (editor.contValidate){
			return alert('내용 미기입');
		} 
		else if ($('input[name=openYn]:checked').val() > 1 || $('input[name=openYn]:checked').val() == null || $('input[name=openYn]:checked').val() == '') {
			return alert($('input[name=openYn]:checked').val() + '오류')
		} 

		fileUpload.wFileUpload.fileSubmit();
		
	}
	
	, dataSetting : function (bbsFile) {
		
		var bbNotice = null;
		
		if ($('#bbNotice').is(':checked')) {
			bbNotice = '1'
		}else{
			bbNotice = '0'
		}
		
		var formData = {
				'bbIdx' : '${bbsVo.bbIdx}'
				, 'bbNotice' : bbNotice
				, 'bbOrIdx' : $('#Institution').val()
				, 'bbTitle' : $('#bbTitle').val()
				, 'bbContent' : $('#bbContent').val()
				, 'bbOpen' : $('input[name=openYn]:checked').val()
				, 'bbsFile' : bbsFile
		};
		
		console.log(formData);
		bbsForm.registBbs(formData);
	}
	
	, registBbs : function (formData) {
		$.ajax({
			type : 'POST'
			, url : 'insertBbs.do'
			, contentType : 'application/json'
			, data : JSON.stringify(formData)
			, dataType : 'text'
			, success: function (data, status, xhr) {
				alert(data.replaceAll('"',''));
				location.href = 'bbsDetail.do?bbIdx='+data.replaceAll('"','');
			}
			, error: function (data, status, error) {
				alert(data);
			}
		});
	}
	
};

let editor = {
		
	se : ''
	
	, contValidate : ''
	
	, initEditor : function () {
	    editor.se = new SynapEditor('bbContent', synapEditorConfig);
	}
	
	, isEditor : function (){
		if(!editor.se.isEmpty()) {
			editor.contValidate = false;
		}else {
			editor.contValidate = true;	
		}
	}
};

let fileUpload = {
	
	wFileUpload : ''
	
	, getFileUploader : function () {
		
		this.wFileUpload = new xFreeUploader({
			render : 'fileUpload'
			, basePath : '/xFreeUploader'
			, selectMode : 'upload'
			, filePath : ''
			, serverType : 'jsp'
			, bodyHeight : 250
			, fileListUrl : '/tagfree/xfuDownload.do'
			, uploadUrl : '/tagfree/xfuUpload.do'
			, onLoad : function(data) {
				console.log('파일 조회 진행'); 
				bbsForm.getFileData(fileUpload.wFileUpload);
			}
			, onAddFile : function(data){ console.log('파일추가'); }
			, onDeleteFile : function(data){ console.log('항목제거'); }
			, onDeleteAllFile : function(data){ console.log('항목전체제거'); }
			, onBeforeSubmit : function(data){ console.log('파일전송하기전'); }
			, onSuccessCallback:function(data){ console.log('upload success'); }
			, onAllSuccessCallback : function(data) {
				console.log('all upload success');
				bbsForm.dataSetting(data);
			}
			, onFailCallback:function(error){ console.log('upload fail'); }
		});
		
	}
	
	, fileSave : function () {
		event.preventDefault();
		bbsForm.saveValidate();
	}
}
</script>