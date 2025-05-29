<?php
header("Content-Type: text/html; charset=utf-8");

/*
(공백) : 이하를 해석하지 못하는 USER_AGENT 가 있을 수 있음
+ : 공백으로 해석 또는 인식되는 경우가 있음
? : 이하 쿼리로 인식됨
# : 이하 문자를 fragment 로 인식될 수 있음
& : 쿼리의 구분으로 인식될 수 있음
/ : PATH_INFO 로 구분한다면 하나의 path 로 인식되지 않음
*/


$jsonBuffer = urldecode(file_get_contents('php://input'));
//$jsonBuffer = str_replace(",", ",\r\n", $jsonBuffer);

// 데이터 내용 js파일에 저장
$targetJS_File = fopen("../uploads_bbs/dataobj.js", "w") or die("Unable to open file!");
fwrite($targetJS_File, $jsonBuffer);
fclose($targetJS_File);

// 반환 데이터 표현
//echo str_replace(",", ",\r\n", $jsonBuffer);
echo $jsonBuffer;

?>