/*
 * [XFU 샘플화면을 위한 공통 함수 JS파일]
 */

var xfu_ex_common = {
	
	// 예외처리 도메인 등록
	isValidDomainList : ["tagfree.com", "webtagfree.web4in1.com"],
	
	// 예외처리 도메인 여부체크
	checkDomain : function(){

		var isCheckDomain = false;

		for(var i=0; i<this.isValidDomainList.length; i++){
		
			if(document.domain.indexOf(this.isValidDomainList[i]) > -1){
			
				isCheckDomain = true;
			}
		}
		
		return isCheckDomain;
	}
};


