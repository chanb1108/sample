<?php
##header("Content-Type: text/html; charset=utf-8");
@set_time_limit(0); 
//ini_set('max_execution_time', 600);

/* 분기처리를 위한 state 값
 * DELETE						: 파일 삭제
 * FOLDERDELETE			: 빈폴더 삭제 (파일 삭제로 인하여 발생할 수 있는 날짜명의 빈폴더 삭제)
 * REUPLOADFILEINFO	: 이어서 전송을 위한 파일정보 가져오기
 * UPLOAD					: 파일 업로드
*/
$state = $_REQUEST["state"];		



if (!function_exists('is_binary')) {
	
	/**
	* Determine if a file is binary. Useful for doing file content
	editing
	*
	* @access public
	* @param mixed $link Complete path to file (/path/to/file)
	* @return boolean
	* @link http://us3.php.net/filesystem#30152
	* @see link user notes regarding this created function
	*/
	function is_binary($link) {
		
		$tmpStr = '';
		$fp = @fopen($link, 'rb');
		$tmpStr = @fread($fp, 256);
		@fclose($fp);

		if ($tmpStr) {
			
			$tmpStr = str_replace(chr(10), '', $tmpStr);
			$tmpStr = str_replace(chr(13), '', $tmpStr);

			$tmpInt = 0;

			for ($i = 0; $i < strlen($tmpStr); $i++) {
				
				if (extension_loaded('ctype')) {
					
					if(!ctype_print($tmpStr[$i])) {
						
						$tmpInt++;
					}
				} elseif (!eregi("[[:print:]]+", $tmpStr[$i])) {
					$tmpInt++;
				}
			}

			if ($tmpInt > 5) {
				
				return false; 
			}
			else {
				
				return true;
			}
		} else {
			
			return false;
		}
	}
}

// 파일삭제
if($state == "DELETE"){
	
	$deleteUrl = $_REQUEST["deleteUrl"];							// 삭제경로
	$serverPath = $_SERVER['DOCUMENT_ROOT'];
	$deleteFullPath = $serverPath.$deleteUrl;
	unlink($deleteFullPath);

	echo "Deleted File : ".$deleteFullPath;
}
// 빈폴더 삭제
elseif($state == "FOLDERDELETE"){
	
	$serverPath = $_SERVER['DOCUMENT_ROOT'];
	$path = $serverPath.$_REQUEST["path"];

	function rmdirr($dirname){ 
	
		$rootPath = $_SERVER['DOCUMENT_ROOT'].$_REQUEST["path"];
		echo $dirname."\n";
		@chmod($dirname, 0777);

		$dirs = dir($dirname);	 
		
		while(false !== ($entry = $dirs->read())) {
			
			if(($entry != '.') && ($entry != '..')) {
				
				if(is_dir($dirname.'/'.$entry)) {
					
					rmdirr($dirname.'/'.$entry);				
				} else {
					
					//@chmod($dirname."/".$entry,0777);
					//@unlink($dirname.'/'.$entry);				
				}
			}		
		}
		$dirs->close();
		
		if($dirname != $rootPath){
			
			@rmdir($dirname); 
		}		
	} 

	if (rmdirr($path)){ 
	
		//echo "TEST FERo"; 
		echo "빈 폴더 삭제완료1";
	} 
	else{ 
	
		//echo "something went wrong."; 
		echo "빈 폴더 삭제완료2";
	} 
}
// 이어서 전송을 위한 파일정보 가져오기
elseif($state == "REUPLOADFILEINFO"){
	
	$serverPath = $_SERVER['DOCUMENT_ROOT'];	

	// 요청받은 검색해야할 파일명
	$searchFileName = $_REQUEST["fileName"];
	
	$searchFileNameList = explode("|", $searchFileName);
	
	// docID
	$docID_folder = isset($_REQUEST["xfuDocID"]) ? $_REQUEST["xfuDocID"]."/" : "xfdocid_0000000000/";

	// 요청받은 파일경로
	$searchFolder = $serverPath.$_REQUEST["searchUrl"].$docID_folder;

	$arr = array();

	if (is_dir($searchFolder)){            
	
		if ($dh = opendir($searchFolder)){
			
			while (($file = readdir($dh)) !== false){   				
			
				// 찾을 파일이름에 "_xfuChunked" 가 들어있는 파일명이 나올때까지 찾기
				//if(strpos($file, $searchFileName) > -1 && strpos($file, "_xfuChunked") > -1){	
				//if(strpos($file, "_xfuChunked") > -1){	
				
				for($i=0; $i<count($searchFileNameList); $i++){
				
					if(strpos($file, substr($searchFileNameList[$i], 0, strrpos($searchFileNameList[$i], "."))) > -1 && strpos($file, "_xfuChunked") > -1){	
						
						// 파일원본명
						//$fileOriName = $searchFileName;
						
						
						// 파일경로
						$fileServerPath = $searchFolder.$file;
						
						// rename처리된 파일명
						$fileReName = substr($file, 0, strrpos($file, "."));
						
						// 파일원본명
						$fileOriName = substr($fileReName, 0, strrpos($fileReName, "_"));
						
						// 파일확장자명
						$fileExt = explode(".", $file);
						
						// 파일크기
						$fileSize = filesize($searchFolder.$file);
						
						// 배열로 저장
						$arr[] = array(
							"fileName" => $fileOriName, 
							"savePath" => $fileServerPath, 
							"fileReName" => $fileReName, 
							"fileType" => end($fileExt),
							"fileSize" => $fileSize
						);
					}
				}
			}                                           
			closedir($dh);                              
		}                                             
	}

	// 프런트단에 json형식으로 넘긴다.
	echo json_encode($arr);
}
// 업로드
elseif($state == "UPLOAD"){
	
	$saveUrl = $_REQUEST["filePath"];								// 서버경로
	$maxSize = $_REQUEST["maxsize"];								// 업로드 사이즈
	$uploadNm = str_replace("[]", "", $_REQUEST["upname"]);		// 업로드 name
								// 상태
	$chunkFileCnt = $_REQUEST["nCount"];
	$fileSize = $_REQUEST["fileSize"];
	$isXSSTarget = false;						// XSS대상파일여부

	ini_set("upload_max_filesize", $maxSize."M");
	ini_set("post_max_size", $maxSize."M");

	// 업로드할 날짜폴더명
	$date = date("Y").date("m").date("d");

	$absolutePathFlag = false;
	
	if(strpos($saveUrl, "\\") > -1 || strpos($saveUrl, "//") > -1){
		
		if(strpos($saveUrl, "\\") > -1) {
			
			$saveUrl = str_replace("\\", "//", $saveUrl);
		}
		$absolutePathFlag = true;
	}

	//if($absolutePathFlag) $uploads_dir = $saveUrl."//";
	//else $uploads_dir = "..".$saveUrl."/";

	$serverPath = $_SERVER['DOCUMENT_ROOT'];	
	$uploads_dir = $serverPath.$saveUrl;

	// 웹경로
	$protocol = stripos($_SERVER['SERVER_PROTOCOL'],'https') === true ? 'https://' : 'http://';
	$serverWebPath= $_SERVER["HTTP_HOST"]; 
	$web_dir = $protocol.$serverWebPath.$saveUrl;
	$docID_folder = isset($_REQUEST["xfuDocID"]) ? $_REQUEST["xfuDocID"] : "xfdocid_0000000000";
	
	
	@mkdir($uploads_dir."/".$date."/".$docID_folder, 0777, true);

	if(is_array($_FILES[$uploadNm]["error"]) || is_object($_FILES[$uploadNm]["error"])) {
	
		$arr = array();
		
		foreach($_FILES[$uploadNm]["error"] as $key => $error){

			// 변수 정리
			$error = $_FILES[$uploadNm]["error"][$key];
			$name = $_FILES[$uploadNm]["name"][$key];
			$nmExplode = explode(".", $name);
			$ext = array_pop($nmExplode);

			// 오류 확인
			if( $error != UPLOAD_ERR_OK ) {
				
				switch( $error ) {
					
					case UPLOAD_ERR_INI_SIZE:
					case UPLOAD_ERR_FORM_SIZE:
						echo "파일이 너무 큽니다. ($error)";
						break;
						
					case UPLOAD_ERR_NO_FILE:
						echo "파일이 첨부되지 않았습니다. ($error)";
						break;
						
					default:
						echo "파일이 제대로 업로드되지 않았습니다. ($error)";
				}
				exit;
			}
		 
			if($chunkFileCnt == "1"){
				$fileNm = GetUniqFileName($name, $uploads_dir."/".$date."/".$docID_folder);
				
				// 띄어쓰기는 언더바(_)로 치환 처리
				$isReplaceBlankToUnderBar = $_REQUEST["isReplaceBlankToUnderBar"];				
				if($isReplaceBlankToUnderBar == "true"){
				
					$fileNm = preg_replace("/\s+/", "_", $fileNm);
				}
		
				// 파일 이동
				//move_uploaded_file( $_FILES[$uploadNm]["tmp_name"][$key], "$uploads_dir/$date/$fileNm");
				$uploadFullUrl = $uploads_dir."/".$date."/".$docID_folder."/".$fileNm;

				if(move_uploaded_file( $_FILES[$uploadNm]["tmp_name"][$key], $uploadFullUrl)){
					
					// 파일 정보 출력
					/*
					echo "<h2>파일 정보</h2>
					<ul>
						<li>파일명: $name</li>
						<li>저장경로: $uploads_dir$date$fileNm</li>
						<li>원본파일명: $name</li>
						<li>중복처리된파일명: $fileNm</li>
						<li>확장자: $ext</li>
						<li>파일형식: {$_FILES[$uploadNm]["type"][$key]}</li>
						<li>파일크기: {$_FILES[$uploadNm]["size"][$key]} 바이트</li>
					</ul>";
					*/

					// 해당 로직은 XSS공격에 대한 방어로직으로 업로드한 파일에 공격성 문자열이 존재시 업로드된 파일을 무조건 삭제처리하도록 구현된 로직입니다.
					
                    if (is_binary($uploadFullUrl)) {
						
                        $fileOpen = fopen($uploadFullUrl,"r"); 
						$fText = fread($fileOpen, filesize($uploadFullUrl));
						
                        if (checkXSS($fText)) {
							
                            unlink($uploadFullUrl);						
                            $isXSSTarget = true;

							header("Defend XSS", true, 405);
							http_response_code(405);
                        }
                        else {
							
                            $isXSSTarget = false;
                        }
						fclose($fileOpen);
                    }
					
					$savePath = $uploadFullUrl;
		
					$arr = array(
						"fileName"=>$fileNm, 
						//"savePath"=>$savePath, 
						//"savePath"=>$web_dir."/".$date."/".$docID_folder,
						"savePath"=>$saveUrl."/".$date."/".$docID_folder,
						"fileReName"=>$fileNm, 
						"ext"=>$ext, 
						"fileType"=>$_FILES[$uploadNm]["type"][0], 
						"fileSize"=>$_FILES[$uploadNm]["size"][0],
						"isXSSTargetFile"=>$isXSSTarget
					);

					if($isXSSTarget) {
						
						unlink($uploadFullUrl);			    // 만약에 해당프로젝트에서 삭제 로직이 불필요하다면 해당 줄만 주석처리 하셔도 됩니다.	
					}
		
					//echo json_encode($arr);
		
					// 로깅
					//$logFileName = "./ulog.dat";		
					//makeLogData($logFileName, $arr);
				}
				else{
					
					die("FileUpload Fail : ".$uploadFullUrl);
				}
			} else {
				
				$chunkFileName = $_REQUEST["chunkFileName"];
				$chunkFileSize = $_REQUEST["chunkFileSize"];
				
				$fileNm = $name;
				$fileNm2 = GetUniqFileName2($name, $uploads_dir."/".$date."/".$docID_folder);
				
				$uploadFullUrl = $uploads_dir."/".$date."/".$docID_folder."/".$fileNm;
				$uploadFullUrl2 = $uploads_dir."/".$date."/".$docID_folder."/".$fileNm2."_xfuChunked";
				
				// 파일 이동
				if(move_uploaded_file( $_FILES[$uploadNm]["tmp_name"][$key], $uploadFullUrl2)){
					
					//ob_start();
					
					if(file_exists($uploadFullUrl2)){
						
						$file = fopen($uploadFullUrl2, 'r');
						$buff = fread($file, $_FILES[$uploadNm]["size"][0]);											
						
						fclose($file);

						$fileExt = substr(strrchr($fileNm, "."), 1); // 확장자 추출
						$fileName = substr($fileNm, 0, strlen($fileNm) - strlen($fileExt) - 1)."_".$chunkFileName.".".$fileExt; // 화일명 추출
						$fileName2 = $uploads_dir."/".$date."/".$docID_folder."/".$fileName;
						
						$uploadFullUrl3 = $uploads_dir."/".$date."/".$docID_folder."/".$fileName."_xfuChunked";

						$final = fopen($uploadFullUrl3, 'a');
						$write = fwrite($final, $buff);							
						
						fclose($final);
						
						unlink($uploadFullUrl2);
					}
					
					if(file_exists($uploadFullUrl3)){
						
						// 청크 업로드가 모두 수행된 시점에서 파일명 변경
						if((int)$fileSize == (int)filesize($uploads_dir."/".$date."/".$docID_folder."/".$fileName."_xfuChunked")){
					
							rename($uploadFullUrl3, $fileName2);
														
							//ob_end_clean();
							//ob_clean();
							
							
							// 해당 로직은 XSS공격에 대한 방어로직으로 업로드한 파일에 공격성 문자열이 존재시 업로드된 파일을 무조건 삭제처리하도록 구현된 로직입니다.
							/*
							//if (is_binary($uploadFullUrl2)) {
								$fileOpen = fopen($uploadFullUrl2,"r"); 
								$fText = fread($fileOpen, filesize($uploadFullUrl2));
								if (checkXSS($fText))
								{
									//unlink($uploadFullUrl2);						
									$isXSSTarget = true;
								}
								else
								{
									$isXSSTarget = false;
								}
								fclose($fileOpen);
							//}
							*/
							
							$savePath = $uploads_dir."/".$date."/".$docID_folder;
				
							$arr = array(
								"fileName"=>$fileNm, 
								//"savePath"=>$savePath, 
								//"savePath"=>$web_dir."/".$date."/".$docID_folder, 
								"savePath"=>$saveUrl."/".$date."/".$docID_folder,
								"fileReName"=>$fileName, 
								"ext"=>$ext, 
								"fileType"=>$_FILES[$uploadNm]["type"][0], 
								"fileSize"=>$chunkFileSize,
								"isXSSTargetFile"=>$isXSSTarget
							);

							if($isXSSTarget) {
								
								unlink($uploadFullUrl2);			    // 만약에 해당프로젝트에서 삭제 로직이 불필요하다면 해당 줄만 주석처리 하셔도 됩니다.
							}
							
							//echo json_encode($arr);
						}
					}
				}
				else{
					die("FileUpload Fail : ".$uploadFullUrl2);
				}
			}
		}
		
		echo json_encode($arr);
	}
}

// 업로드파일명 중복체크하여 Rename처리
function GetUniqFileName($FN, $PN) {
	
	$FileCnt = 0;
	$FileExt = substr(strrchr($FN, "."), 1); // 확장자 추출
	$FileName = substr($FN, 0, strlen($FN) - strlen($FileExt) - 1); // 화일명 추출

	$ret = "$FileName.$FileExt";
	
	// 화일명이 중복되지 않을때 까지 반복
	while(file_exists($PN."/".$ret))  {
		
		$FileCnt++;
		$ret = $FileName."(".$FileCnt.").".$FileExt; // 화일명뒤에 (_1 ~ n)의 값을 붙여서....
	}
	return($ret); // 중복되지 않는 화일명 리턴
}

function GetUniqFileName2($FN, $PN) {
	
	$FileCnt = 0;
	$FileExt = substr(strrchr($FN, "."), 1); // 확장자 추출
	$FileName = substr($FN, 0, strlen($FN) - strlen($FileExt) - 1); // 화일명 추출

	$ret = "$FileName.$FileExt";
	
	// 화일명이 중복되지 않을때 까지 반복
	while(file_exists($PN."/".$ret)) {
		
		$FileCnt++;
		$ret = $FileName.$FileExt.$FileCnt; // 화일명뒤에 (_1 ~ n)의 값을 붙여서....
	}

	return($ret); // 중복되지 않는 화일명 리턴
}

function cleanXSS($sInput) {
	
    if ($sInput == null){
		
        return "";
	}
	
    $sResult = "";
    $sResult = str_replace("<", "&lt;", $sInput);
    $sResult = str_replace(">", "&gt;", $sInput);
    $sResult = str_replace("\\(", "&#40;", $sInput);
    $sResult = str_replace("\\)", "&#41;", $sInput);
    $sResult = str_replace("'", "&#39;", $sInput);
    $sResult = str_replace("eval\\((.*)\\)", "", $sInput);
    $sResult = str_replace("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"", $sInput);
    $sResult = str_replace("script", "", $sInput);
	
    return $sResult;
}

function checkXSS($cInput) {
	
    $cResult = false;
    
	if (strpos($cInput, "<") !== false ||
        strpos($cInput, ">") !== false ||
        strpos($cInput, "\\(") !== false ||
        strpos($cInput, "\\)") !== false ||
        strpos($cInput, "'") !== false ||
        strpos($cInput, "eval\\((.*)\\)") !== false ||
        strpos($cInput, "[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']") !== false ||
        strpos($cInput, "script") !== false) {
        $cResult = true;
    }
	
    return $cResult;
}

function makeLogData($logFileName, $arr) {
	
	$handle = fopen($logFileName, "a+");
	
	fwrite($handle, "\r\n");		
	fwrite($handle, date("Y-m-d H:i:s")."\t");
	fwrite($handle, $_SERVER['REMOTE_ADDR']."\t");
	fwrite($handle, "[fileupload]\t");
	fwrite($handle, iconv("UTF-8", "EUC-KR", $arr["fileReName"])."\t");
	fwrite($handle, $arr["savePath"]."\t");
	fwrite($handle, $arr["fileType"]."\t");
	fwrite($handle, $arr["fileSize"]);
	
	fclose($handle);
	
	$handle = fopen($logFileName, "r");
	echo fread($handle, filesize($logFileName));
	fclose($handle);
}


?>