기존 자바의 경우 JSP를 호출하여 처리하던 방식을 매핑된 주소에서 처리 후 프론트쪽으로 보내주는 방식으로 변경됐습니다.
주소 매핑을 위한 서버를 따로 돌리는 방식이 아니므로 해당 컨트롤러 파일쪽에 class 파일 세팅됐습니다.

클래스 파일의 패키지는 다음과 같습니다.
package com.tagfree.xFreeUploader

/

포함된 두 개의 파일을 프로젝트에 인식하는 파일 루트로 옮기시길 바랍니다.

- class 파일(자바 컴파일)은 java 버전에 맞는 파일을 사용하시길 바랍니다.
- XFreeUploader.java는 업로드, 다운로드 호출하는 메소드가 있는 자바 파일입니다.

파일 구성
ㆍspringboot_java8,11
ㄴXFreeUploader.java : 원본 소스
ㄴXFreeUploader_8.class : 자바8 컴파일
ㄴXFreeUploader_11.class : 자바11 컴파일

ㆍspringboot_java17
ㄴXFreeUploader.java : 원본 소스
ㄴXFreeUploader.class : 자바17 컴파일

기존 버전과 다르게 springboot 환경에서는 xFreeUploader 생성 시 다음과 같이 키값을 추가해주시길 바랍니다.

Upload
uploadUrl : "/tagfree/xfuUpload"
ex) 컨트롤러 매핑 주소가 "/xFreeUploader/tagfree/xfuUpload"라면 페이지에는 uploadUrl : "/tagfree/xfuUpload" 으로 세팅

Download
fileListUrl : "/tagfree/xfuDownload",
downloadUrl : "/tagfree/xfuDownload"

/

더 자세한 내용이 궁금하시다면 examples/springboot_example의 예제 jsp파일과
현재 디렉토리에 위치한 '작업참조내용.txt'를 확인해주시길 바랍니다.
