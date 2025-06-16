<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

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
	  			<button id="btnReset">초기화</button>
	  			<button id="btnSearch">조회</button>
	  		</div>
		</div>
	</div>
</div>
<div id="dataCnt" style="text-align : left;"></div>
<div id="grid"></div>
<button onclick='SBGrid3.reload(datagrid)' style="border:1px solid #000; padding : 2px; margin-left : -75%;">reload</button>

<!-- layer popup 영역 -->
<div class="layer_bg"></div>
<div class="layer_wrap" layer="cateForm">
	<table class="ctForm">
		<tr>
			<td colspan="4">
				<label id="chgKnd"></label>
				<input type="hidden" id="caDepth" value="" />
				<input type="hidden" id="caIdx" value="" />
				<input type="hidden" id="caOrgIdx" value="" />
				<input type="hidden" id="beforeSeq" value="" />
			</td>
		</tr>
		<tr>
			<td><label>상위 카테고리 ID</label></td>
			<td>
				<input type="text" id="caParentId" value="" disabled />
			</td>
			<td>상위 카테고리명</td>
			<td>
				<input type="text" id="caParentName" value="" disabled />
			</td>
		</tr>
		<tr>
			<td><label>카테고리 ID</label></td>
			<td>
				<input type="text" id="caId" value="" />
			</td>
			<td><label>카테고리 명</label></td>
			<td>
				<input type="text" id="caName" value="" />
			</td>
		</tr>
		<tr>
			<td><label>업체명</label></td>
			<td>
				<input type="text" id="orName" value="" disabled />
			</td>
			<td><label>정렬 순서</label></td>
			<td>
				<input type="number" id="caSeq" value="1" min="1" max="99" />
			</td>
		</tr>
		<tr>
			<td><label>포인트</label></td>
			<td>
				<input type="number" id="caPoint" value="0" min="0" />
			</td>
			<td><label>사용여부</label></td>
			<td>
				<input type="radio" id="caUseY" name="caUse" value="Y" checked>
		       		<label for="useY">사용</label>
		       	<input type="radio" id="caUseN" name="caUse" value="N">
		       		<label for="useN">미사용</label>
			</td>
		</tr>
		<tr>
			<td colspan="4">
				<input type="button" id="formCancel" value="취소" />
				<input type="button" id="formSubmit" value="저장" />
			</td>
		</tr>
	</table>
</div>

<script type="text/javaScript" language="javascript">
$(function(){
	
	list.init();
	
	// [초기화] 버튼 클릭 시
	$('#btnReset').on('click', function() {
		list.formReset();
	});
	// [검색] 버튼 클릭 시
	$('#btnSearch').on('click', function() {
		list.getGrid();
	});
	// Form 내 [취소] 버튼 클릭 시
	$('#formCancel').on('click', function() {
		layerPop.layerClose();
	});
	// Form 내 [저장] 버튼 클릭 시
	$('#formSubmit').on('click', function() {
		layerPop.formValidate();
	});
});
	
let list = {
	// 초기함수
	init : function () {
		list.getGrid();
		$('.layer_bg, .layer_wrap').hide();
	}
	
	, formReset : function () {
		$('select[name=Institution] option[value=""]').prop('selected',true);
	}
	
	, totCnt : ''
	
	, getDataCnt : function (data) {
		$.ajax({
			type : 'GET'
			, url : 'getCategorySearchCnt.do'
			, data : data
			, dataType : 'text'
			, success : function (data, status, xhr) {
				console.log(data);
				let dataCnt = data.replaceAll('"', '');
				$('#dataCnt').text('총 '+ dataCnt+'개');
				list.totCnt = dataCnt;
			}
			, error: function (data, status, error) {
				alert('처리중 오류가 발생하였습니다.');
			}
		})
	}
	
	, getGridData : async function (request) {
    	
    	var caOrgIdx = $('#Institution').val();
			
		if(caOrgIdx == ''){
			caOrgIdx = '0';
		}
    	var gridData = {
   			caOrgIdx : caOrgIdx
   			, pageNo  : request.pageNo
   			, pageSize : request.pageSize
   		};
    	
    	list.getDataCnt(gridData);
    	
    	return new Promise((resolve) => {
    		$.ajax({
    			url : 'getCategorySearch.do'
    			, method : 'GET'
    			, data : gridData
    			, success : function (result) {
    				resolve({data : result, total : list.totCnt});
    			}
    		})
    	})
    }
    
	, getGrid : function(){
		
		let gridConfig = {
			dataSource: {
				ajax : {
					select : async (request) => await list.getGridData(request)
					, selected: 'data'
				    , total: 'total'
				}
				,tree : {
					master : 'caId'
					, parent : 'caParentId'
					, level : 'caDepth'
				}
				, orders : [{field : 'caSeq', dir : 'asc'}]
			}
			, container: '#grid'
			, width: '100%'
			, height: '400px'
			, toolBar: ['excel']
			, columns: [
				{field: 'caId', type: 'tree', caption: '카테고리', width: 150}
				, {field: 'caParentId', caption: '상위 카테고리', width: 150}
				, {field: 'caSeq', caption: '시퀀스', width: 50}
				, {field: 'caIdx', caption: '일련번호', width: 80}
				, {field: 'caName', caption: '카테고리명', width: 200}
				, {
					field: 'caUse'
					, caption: '사용여부'
					, width: 100
					, getValue : (value, field, rowItem) => {
						if (value == 'Y') {
							value = '공개';
							return value;
						} else {
							value = '미공개';
							return value;
						}
					}
				}
				, {field: 'caPoint', caption: '포인트', width: 50}
				, {field: 'orName', caption: '업체명', width: 150}
				, {
					field : 'btn'
					, type : 'button'
					, caption : '등록'
					, width : 80
					, command : (container, data) => {
						if (data.level <= 1) {
							let btn = document.createElement('button');
							btn.innerText = '등록';
							btn.onclick = () => layerPop.showPop(data.data.caIdx, 'regist');
							container.appendChild(btn);
						}
					}
				}
				, {
					field : 'btn'
					, type : 'button'
					, caption : '수정'
					, width : 80
					, command : (container, data) => {
						let btn = document.createElement('button');
						btn.innerText = '수정';
						btn.onclick = () => layerPop.showPop(data.data.caIdx, 'modify');
						container.appendChild(btn);
					}
				}
			]
			, excelExport: {
		       fileName: 'category_data.xlsx'
		      , includeFormula : true
		    }
			, editable : false
		}
		
		datagrid = SBGrid3.createGrid(gridConfig);
		datagrid.refresh();
	}
}

let layerPop = {
	
	chgKnd : ''
	
	, showPop : function (caIdx, chgKnd) {
		
		console.log('====caIdx : '+ caIdx)
		
		layerPop.chgKnd = chgKnd;
		
		layerPop.dataCall(caIdx);
		
		$('.layer_wrap[layer=cateForm]').fadeIn();
		$('.layer_bg').fadeIn();
		if (chgKnd === 'modify') {
			$('#chgKnd').text('수정');	
		} else {
			$('#chgKnd').text('등록');
		}		
		layerPop.layerPosition();
		
		$('.layer_bg').click(function (e) {
	      if(!$('.layer_wrap').has(e.target).length){
	        layerPop.layerClose();
	      };
	    });
	}
	
	, layerPosition : function () {
		var win_W = $(window).width();
	    var win_H = $(window).height();
	    $('.layer_wrap').css({'left':(win_W-800)/2, 'top':(win_H-400)/2});
	}
	
	, layerClose : function () {
		$('.layer_wrap, .layer_bg').fadeOut();
		layerPop.dataReset();
	}
	
	, dataCall : function (caIdx) {		
		$.ajax ({
			type : 'GET'
			, url : 'getCategoryForm.do?caIdx='+caIdx
			, dataType : 'json'
			, success : function (data, status, xhr) {
				console.log(data);
				layerPop.dataSetting(data, chgKnd);
			}
			, error: function (data, status, error) {
				alert('처리중 오류가 발생하였습니다.');
				layerPop.layerClose();
			}
		})
	}
	
	, dataSetting : function (data) {
		console.log('변경전 : '+ data.caDepth);
		
		if (layerPop.chgKnd === 'modify') {
			// 수정 요청 시
			$('#caDepth').val(data.caDepth);
			$('#caIdx').val(data.caIdx);
			$('#caParentId').val(data.caParentId);
			$('#caParentName').val(data.caParentName);
			$('#caId').val(data.caId);
			$('#caName').val(data.caName);
			$('#caOrgIdx').val(data.caOrgIdx);
			$('#orName').val(data.orName);
			$('#caSeq').val(data.caSeq);
			$('#caPoint').val(data.caPoint);
			if (data.caUse !== 'Y') {
				$('input[name=caUse][value=N]').prop('checked', true);
			}
			$('#beforeSeq').val(data.caSeq);
		}else {
			// 등록 요청 시
			$('#caDepth').val(data.caDepth+1);
			$('#caParentId').val(data.caId);
			$('#caParentName').val(data.caName);
			$('#caOrgIdx').val(data.caOrgIdx);
			$('#orName').val(data.orName);
		}		
	}
	
	, dataReset : function () {
		$('#caDepth').val('');
		$('#caIdx').val('');
		$('#caParentId').val('');
		$('#caParentName').val('');
		$('#caId').val('');
		$('#caName').val('');
		$('#caOrgIdx').val('');
		$('#orName').val('');
		$('#caSeq').val('0');
		$('#caPoint').val('0');
		$('input[name=caUse][value=Y]').prop('checked', true);
	}
	
	// validation check
	, formValidate : function() {
		if ($('#caId').val() === null || $('#caId').val === '') {
			alert('카테고리 ID가 존재하지 않습니다.');
		} else if ($('#caName').val()===null || $('#caName').val() === '') {
			alert('카테고리명이 존재하지 않습니다.')
		} else if ($('#caSeq').val() <= 0 || $('#caSeq').val() > 99) {
			alert('정렬순서는 1 ~ 99까지 입력이 가능합니다.');
		} else if ($('#caPoint').val() < 0) {
			alert('포인트는 0보다 작을 수 없습니다.')
		} else {
			layerPop.formSave();
		}
	}
	
	, formSave : function () {
		let reqData = {};
		if (layerPop.chgKnd === 'modify') {
			// 수정 데이터 세팅
			reqData = {
				 'caIdx' : $('#caIdx').val()
				, 'caDepth' : $('#caDepth').val()
				, 'caOrgIdx' : $('#caOrgIdx').val()
				, 'beforeSeq' : $('#beforeSeq').val()
				, 'caParentId' : $('#caParentId').val()
				, 'caId' : $('#caId').val()
				, 'caName' : $('#caName').val()
				, 'caOrgIdx' : $('#caOrgIdx').val()
				, 'caSeq' : $('#caSeq').val()
				, 'caPoint' : $('#caPoint').val()
				, 'caUse' : $('input[name=caUse]:checked').val()
			}	
		} else {
			// 등록 데이터 세팅
			reqData = {
				 'caDepth' : $('#caDepth').val()
				, 'caOrgIdx' : $('#caOrgIdx').val()
				, 'caParentId' : $('#caParentId').val()
				, 'caId' : $('#caId').val()
				, 'caName' : $('#caName').val()
				, 'caOrgIdx' : $('#caOrgIdx').val()
				, 'caSeq' : $('#caSeq').val()
				, 'caPoint' : $('#caPoint').val()
				, 'caUse' : $('input[name=caUse]:checked').val()
			}
		}
		console.log(reqData);
		$. ajax({
			type : 'POST'
			, url : 'saveCategory.do'
			, contentType : 'application/json'
			, data : JSON.stringify(reqData)
			, dataType : 'text'
			, success : function (data, status, xhr) {
				let msg = data.replaceAll('"', '');
				alert(msg);
				if (msg === 'success') {
					layerPop.layerClose();
					list.getGrid();	
				}
			}
			, error : function (data, status, error) {
				console.log(data);
				alert('에러 발생');
			}
		})
	}
		
}
</script>
