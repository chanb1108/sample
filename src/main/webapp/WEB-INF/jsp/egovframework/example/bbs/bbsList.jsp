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
	  			<button id="btnReset">초기화</button>
	  			<button id="btnSearch">조회</button>
	  			<button id="regBtn" onclick="location.href='insertBbsForm.do'">등록</button>
	  		</div>
 		</div>
 	</div>
 </div>
  <div id="grid"></div>
  <button onclick='SBGrid3.reload(datagrid)' style="border:1px solid #000; padding : 2px; margin-left : -75%;">reload</button>
<script type="text/javaScript" language="javascript">
$(function(){
	
    list.init();
	
	// [초기화] 버튼 클릭 시
    $('#btnReset').on('click', function(){
        list.formReset();
    });
    // [검색] 버튼 클릭 시
    $('#btnSearch').on('click', function(){
    	list.getGrid();
    });
    
});

let list = {
    // 초기함수
    init : function(){
    	list.getGrid();
    	list.chgCol();
    }
    
	, formReset : function(){
		$('select[name=Institution] option[value=""]').prop('selected',true);
		$('select[name=schDate] option[value=bbRegDate]').prop('selected',true);
		$('#bbTitle').val(null);
		$('#strDate').val(null);
		$('#endDate').val(null);
    }
	
	, getDataCnt : function(data) {
		$.ajax({
			type : 'GET'
			, url : 'getBbsSearchCnt.do'
			, data : data
			, dataType : 'text'
			, success : function (data, status, xhr) {
				let dataCnt = data.replaceAll('"', '');
				list.totCnt = dataCnt;
			}
			, error: function (data, status, error) {
				alert('처리중 오류가 발생하였습니다.');
			}
		})
	}
    
    , getGridData : async function (request) {
    	
    	if ($('#strDate').val() == '' && $('#endDate').val() != '') {

			alert('시작일이 없을 경우 날짜 조회가 불가합니다.');
			
		} else if ($('#strDate').val() != '' && $('#endDate').val() != '') {
			
			if($('#strDate').val() >= $('#endDate').val()){
				alert('날짜선택이 잘못되었습니다. 다시 선택해 주시길 바랍니다.');	
			}
			
		} else {

	    	var bbOrIdx = $('#Institution').val();
			
			if(bbOrIdx == ''){
				bbOrIdx = '0';
			}
	    	var gridData = {
	   			bbOrIdx : bbOrIdx
	   			, schDate : $('#schDate').val()
	   			, strDate : $('#strDate').val()
	   			, endDate : $('#endDate').val()
	   			, bbTitle : $('#bbTitle').val()
	   			, pageNo  : request.pageNo
	   			, pageSize : request.pageSize
	   		};
	    	list.getDataCnt(gridData);
		}
    	
    	return new Promise((resolve) => {
    		$.ajax({
    			url : 'getBbsSearch.do'
    			, method : 'GET'
    			, data : gridData
    			, success : function (result) {
    				console.log(result);
    				resolve({data : result, total : list.totCnt});
    			}
    		})
    	})
    }
    
	, totCnt : ''
	
	, getGrid : function(){

		let gridConfig = {
			dataSource: {
				ajax : {
					select : async (request) => await list.getGridData(request)
					, selected: 'data'
				    , total: 'total'
				}
				, pageSize : 10
				, serverPaging : true
				, orders : [{field : 'bbRegDate', dir : 'desc'}]
			}
			, container: '#grid'
			, width: '100%'
			, height: '400px'
			, pagerBar: {
				left : [
					(container) => {
						let message = '<span>전체 :'+list.totCnt+' 개 |</span>';
						$(container).append(message);
					}
					, 'pageSizes'
					, (container) => {
						let message = '개 씩 보기';
						$(container).append(message);
					}
				]
				, center : 'pager'
			}
			, scrollRange : 'page'
			,pageable: { 
		       pager :{
		    	buttonCount : 5 ,numeric : true, previousNext : true }  
		       , pagerCombo : { listCount : 5 } 
		       , pageSizes :  [10,20,30] 
		    }
			, toolBar: ['excel']
			, reverseRowNo : true
			, columns: [
				{field: 'bbIdx', caption: '번호', width: 80, visible : false}
				, {
					field : 'bbBbsid'
					, caption:'게시 유형'
					, width: 100
					, getValue : (value, field, rowItem) => {
						switch (value) {
							case 'support' : return '지원';
							case 'news' : return 'NEWS';
							case 'faq' : return 'FAQ';
							case 'manual' : return '메뉴얼';
							case 'merge' : return '합병';
							case 'consult' : return '상담';
							case 'notice' : return '일반';
							case 'inno' : return '혁신';
							case 'prefer' : return '선호';
							case 'soc' : return 'SOC';
							case 'perform' : return '수행';
							case 'policy' : return '정책';
							default : return '기타';
						}
					}
				}
				,{field: 'bbTitle', caption: '제목', width: 200}
				, {field: 'orName', caption: '업체명', width: 200}
				, {field: 'bbRegDate', caption: '등록일시', width: 200}
				, {field: 'bbHit', caption: '조회수', width: 100}
				, {
					field: 'bbOpen'
					, caption: '공개여부'
					, width: 100
					, getValue : (value, field, rowItem) => {
						if(value == '1') {
							value = '공개';
							return value;
						} else {
							value = '미공개';
							return value;
						}
					}
				}
			]
			, excelExport: {
		       fileName: 'bbs_data.xlsx'
		      , includeFormula : true
		    }
			, doCommand: (grid, name, command) => {
				switch(name) {
					case 'event' : {
						if (command.event.type == 'dblclick') {
							const value = SBGrid3.getValue(grid, command.key, 'bbIdx');
							alert(value + ' 상세페이지로 이동');
							location.href = 'bbsDetail.do?bbIdx='+value;
						}
						break;	
					}
				}
			}
			, editable : false
		}
		datagrid = SBGrid3.createGrid(gridConfig);
		datagrid.refresh();
	}
	
	, chgCol : function () {
		const column = SBGrid3.getColumn(datagrid, 0)[0];
		SBGrid3.setCaption(datagrid, column, '순번');
	}
}
</script>
