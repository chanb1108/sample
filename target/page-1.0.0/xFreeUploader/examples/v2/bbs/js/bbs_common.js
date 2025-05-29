/*
 * [게시판 화면을 위한 공통 함수 JS파일]
 * 해당 게시판 예제는 DB를 사용하지 않고 dataobj.js에 json데이터를 텍스트로 저장하여 활용한 예제로 
 * XFU를 연동한 게시판의 가장 기본적인 CRUD의 흐름을 개발자분들이 이해하기 쉽게 샘플로 제작한 페이지이므로 
 * 일부분 정도만 참고하시면 됩니다.
 */

var bbs_common = {
	
	// XFE 사용여부 지정
	isXFE : false,
	
	// 서버타입
	serverType: "php",
	
	// 공통 ajax함수 호출
	loadData : function (argUrl, callback, argData){
		
		if(typeof(argData) !== "undefined"){
		
			if(Object.keys(argData).indexOf("deleteUrl") === -1){
			
				argData = JSON.stringify(argData);
				
				argData = bbs_common.replaceSpecialChar(argData, false);
			}
		}
		
		var svrType = bbs_common.serverType;
		var ajaxType = "POST";
		
		// 서버타입 자동세팅(/index.html로 접근시에만 정상적으로 동작)
		if(parent.document.getElementById("serverType")){
		
			svrType = parent.document.getElementById("serverType").value;
		}
		
		if(svrType === "aspx"){
			
			ajaxType = "GET";
			argUrl += "?data=" + argData;
		}
		
		this.serverType = svrType;
		
		
		$.ajax({
			type : ajaxType,
			url : argUrl,
			dataType : "text",
			data : argData,
			success : function(data){
				
				// 게시물 데이터 보관 js의 내용이 아무것도 없을때 예외처리
				if(argUrl.indexOf("/dataobj.js") > -1){
					
					if(typeof(data) === "undefined" || data === ""){
						
						data = "[]";
					}
				}
				
				if(data !== ""){
					
					data = bbs_common.replaceSpecialChar(data, true);
					
					var listData = JSON.parse(data);
				}
				callback(listData);
				
				//console.log(listData);
			},
			error : function(){
				
				alert('통신실패!!');
			}
		});
	},

	// get 파라미터 값 반환받기
	getParameter : function (key){

		var url = location.href;
		var parameters = [];    
		var qs = null;

		// url has parameter's
		if ( url.indexOf("?") != -1 ){
			
			qs = {};
			parameters = url.substring(url.indexOf("?")+1, url.length).split("&");
			
			for ( var k =0; k < parameters.length; k++ ){
				
				if ( parameters[k].split("=")[1].split('').join('').length > 0 ){
					
					qs[parameters[k].split("=")[0]] = parameters[k].split("=")[1];
				}
			}
			
			return qs[key] == undefined ? null : qs[key];
		}
		else{
			
			return null;
		}	
	},

	// 현재 날짜 반환받기
	getToday : function (){
		
		var now = new Date();
		var year = bbs_common._fillZero(4, String(now.getFullYear()));
		var month = bbs_common._fillZero(2, String(now.getMonth() + 1));
		var date = bbs_common._fillZero(2, String(now.getDate()));
		var hours = bbs_common._fillZero(2, String(now.getHours()));
		var minutes = bbs_common._fillZero(2, String(now.getMinutes()));
		var seconds = bbs_common._fillZero(2, String(now.getSeconds()));
		
		return year + month + date + hours + minutes + seconds;		//20220310133755
	},

	// 앞에 남는 자리수 만큼 0을 채우기
	_fillZero : function (width, str){
			
		return str.length >= width ? str:new Array(width-str.length+1).join('0')+str;//남는 길이만큼 0으로 채움
	},

	// 14자리의 날짜시간정보를 mask 처리
	maskDate : function (strDate){
		
		var fullDate = bbs_common._fillZero(14, strDate);
		
		var year = fullDate.substr(0, 4);
		var month = fullDate.substr(4, 2);
		var date = fullDate.substr(6, 2);
		var hours = fullDate.substr(8, 2);
		var minutes = fullDate.substr(10, 2);
		var seconds = fullDate.substr(12, 2);
		
		return year + "-" + month + "-" + date + " " + hours + ":" + minutes + ":" + seconds;	
	},
	
	// 특수문자 치환 처리
	replaceSpecialChar : function(str, isBoolean){
		
		var strData = str;
		
		if(isBoolean){
			
			strData = strData.replace(/%2B/gi, "+");
			strData = strData.replace(/%AD/gi, "&#63;");
			strData = strData.replace(/%23/gi, "#");
			strData = strData.replace(/%26/gi, "&");
			strData = strData.replace(/%2F/gi, "&#47;");
			strData = strData.replace(/%3B/gi, ";");
			strData = strData.replace(/%27/gi, "'");
			//strData = strData.replace(/%22/gi, "\"");
		} 
		else {
			
			strData = strData.replace(/\+/gi, "%2B");
			strData = strData.replace(/\?/gi, "&#63;");
			strData = strData.replace(/#/gi, "%23");
			strData = strData.replace(/&/gi, "%26");
			strData = strData.replace(/\//gi, "%2F");
			strData = strData.replace(/;/gi, "%3B");
			strData = strData.replace(/\'/gi, "%27");
			//strData = strData.replace(/\"/gi, "%22");
		}
		
		return strData;
	},
	
	// json데이터 정렬 처리
	sortJSON : function (data, key, type){
	
		if (type == undefined) {

			type = "asc";
		}
		return data.sort(function(a, b) {

			var x = a[key];
			var y = b[key];
			
			if (type == "desc") {
			
				return x > y ? -1 : x < y ? 1 : 0;
			} else if (type == "asc") {

				return x < y ? -1 : x > y ? 1 : 0;
			}
		});
	},
	
	// 현재날짜와 게시물 날짜 비교하여 이전 게시물 내용 모두 삭제처리(작업중)
	compareDateDataObj : function(bbsDate){
		
		if(bbs_common.getToday().substring(0, 8) > bbsDate){
			
			// 해당 json데이터 저장 프로세스로 전달
			var saveServerFileUrl = "./svr/content_save." + this.serverType;
			
			bbs_common.loadData(saveServerFileUrl, function(data){
			
				console.log(data);
				//alert("데이터가 저장되었습니다.");
				//location.href = "./list.html";
				
				// 태그프리 홈페이지 분기처리
				if(xfu_ex_common.checkDomain()){
					
					bbs_common.serverAllFileDelete("/xfu_test/v2/xFreeUploader/examples/v2/bbs/uploads_bbs");
				} else {
					
					bbs_common.serverAllFileDelete("/xFreeUploader/examples/v2/bbs/uploads_bbs");
				}
			}, []);
		}		
	},
	
	serverAllFileDelete : function(filePath){
		
		// 해당 json데이터 저장 프로세스로 전달
		var delServerFileUrl = "./svr/attach_file_remove." + this.serverType;
		
		bbs_common.loadData(delServerFileUrl, function(data){
		
			console.log(data);
			//location.href = "./list.html";
		}, {
			"deleteUrl" : filePath
		});
	}
};


