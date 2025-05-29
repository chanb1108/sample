<?php
##header("Content-Type: text/html; charset=utf-8");
@set_time_limit(0); 
//ini_set('max_execution_time', 600);

/* 분기처리를 위한 state 값
 * FILELIST			: 파일 조회
 * DOWNLOAD	: 파일 다운로드
*/
$state = $_REQUEST["state"];

// 파일 조회
if($state == "FILELIST"){
	
	header("Content-Type: text/html; charset=utf-8");

	$filePath = $_REQUEST["path"];				// 서버경로
	$filterWord = $_REQUEST["filterWord"];		// 필터링정보

	$absolutePathFlag = false;
	
	if(strpos($filePath, "\\") > -1 || strpos($filePath, "//") > -1){
		
		if(strpos($filePath, "\\") > -1) {
			
			$filePath = str_replace($filePath, "\\", "//");
		}
		$absolutePathFlag = true;
	}
	/*
	if($absolutePathFlag) $dir = $filePath;
	else {
		$serverPath = $_SERVER['DOCUMENT_ROOT'];
		$dir = $serverPath.$filePath;	
	}
	*/

	// 최상단 루트경로
	$serverPath = $_SERVER['DOCUMENT_ROOT'];	
	// 최상단 루트에 filePath의 조합 -> 절대경로 표현
	$dir = $serverPath.$filePath;

	// 웹경로
	$protocol = stripos($_SERVER['SERVER_PROTOCOL'],'https') === true ? 'https://' : 'http://';
	$serverWebPath= $_SERVER["HTTP_HOST"]; 
	$web_dir = $protocol.$serverWebPath;

	// 파일목록 조회실행
	DirectoryBrowser($dir, $filterWord, $web_dir, $serverPath);

}
// 이어서 전송을 위한 _xfuChunked 파일여부 정보 가져오기
elseif($state == "REDOWNLOADFILEINFO"){
	
	$serverPath = $_SERVER['DOCUMENT_ROOT'];	

	// 요청받은 검색해야할 파일명
	$searchFileName = $_REQUEST["fileName"];
	
	// docID
	$docID_folder = isset($_REQUEST["xfuDocID"]) ? $_REQUEST["xfuDocID"]."/" : "xfdocid_0000000000/";

	// 요청받은 파일경로
	$searchFolder = $serverPath.$_REQUEST["searchUrl"].$docID_folder;

	$arr = array();

	if (is_dir($searchFolder)){        
    
		if ($dh = opendir($searchFolder)){
			
			while (($file = readdir($dh)) !== false){   				
			
				// 찾을 파일이름에 "_xfuChunked" 가 들어있는 파일명이 나올때까지 찾기
				if(strpos($file, $searchFileName) > -1 && strpos($file, "_xfuDownload") > -1){	
					
					// 파일확장자명
					$fileExt = explode(".", $file);
					
					// 확장자명 끝에 "_xfuChunked" 가 나올때까지 찾기 -- 압축파일 생성완료 상태
					if(strpos(end($fileExt), "_xfuDownload") > -1){
						
						// 파일원본명
						$fileOriName = $searchFileName;
						
						// 파일경로
						$fileServerPath = $searchFolder.$file;
						
						// rename처리된 파일명
						$fileReName = substr($file, 0, strrpos($file, "."));
						
						
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

// 파일 다운로드
elseif($state == "DOWNLOAD"){
	
	//$downList = $_POST["downList"];
	$downList = isset($_REQUEST["downList"]) ? $_REQUEST["downList"] : null;
	$downList = str_replace("'", "\"", $downList);

	header('Set-Cookie: fileDownload=true; path=/');

	/**
	* 프론트단으로부터 받은 연계데이터가 존재할 때
	*/
	if($downList != null){
		
		//ob_start();
		
		$json_downList = json_decode($downList, true);
		
		$fileDir = $json_downList[0]["savePath"];

		/*
		$pos = strrpos($fileDir, "://");
		if($pos === false){
			$fileDir = "..".$fileDir."/";
		}
		elseif(is_bool($pos) && !$pos){
			$fileDir = "..".$fileDir."/";
		}
		*/
		$serverPath = $_SERVER['DOCUMENT_ROOT'];	
		$fileDir = $serverPath.$fileDir."/";

		/**
		* 다운로드 받을 파일이 단건인 경우
		*/
		if(count($json_downList) == 1){
			
			$fileName = urldecode($json_downList[0]["fname"]);
			
			$fileRealUrl = $json_downList[0]["fileRealUrl"];
			
			$checkedFileNameDir = $fileDir.$fileName;
			
			if($fileRealUrl != ""){
					
				$checkedFileNameDir = $serverPath.$json_downList[0]["fileRealUrl"];
			}
			
			// 파일 존재 유/무 체크
			if(file_exists($checkedFileNameDir)){
				
				//ob_start();				
				$down = $checkedFileNameDir;
				
				/*
				header('Content-Type: application/octet-stream');			
				header('Content-Disposition: attachment; filename="' . $fileName . '"');
				header('Content-Transfer-Encoding:binary');
				header('Content-Length: ' . (filesize($down)) );
				header('Cache-Control:cache,must-revalidate');
				header('Pragma:no-cache');
				header('Expires:0');
				*/
				
				header("Cache-control: private");
				header("Content-type: ".user_mime_content_type($down)."");
				header('Content-Disposition: attachment; filename="' . basename(str_replace("_xfuDownload", "", $fileName)) . '"');
				header("Content-Length: ".filesize($down));
				header("Cache-Control: cache, must-revalidate");
				header("Content-Description: PHP3 Generated Data");
				header("Pragma: no-cache");
				header("Expires: 0");
				
				if(is_file($down)){
					
					$fp = fopen($down,"rb") or die("Failed to open file.");
					
					while(!feof($fp)){
						
						$buf = fread($fp,1024);
						//$read = strlen($buf);
						print($buf); 
						//passthru($buf);
						flush();
					}				
					fclose($fp);
				}
				clearstatcache();
				
				// 다운로드 정상적으로 받은 파일명에 _xfuDownload 가 존재하면 서버상에서 삭제처리
				if(strpos($fileName, "download_") > -1 && strpos($fileName, "_xfuDownload") > -1){
					
					unlink($down);
				}
				
				//ob_end_clean();
				
				//ob_clean();
				//flush();

				//readfile($down);
				
				// 로깅
				/*
				$logFileName = "./ulog.dat";
				$handle = fopen($logFileName, "a+");
		
				fwrite($handle, "\r\n");		
				fwrite($handle, date("Y-m-d H:i:s")."\t");
				fwrite($handle, $_SERVER['REMOTE_ADDR']."\t");
				fwrite($handle, "[filedownload]\t");
				fwrite($handle, iconv("UTF-8", "EUC-KR", $fileName)."\t");
				fwrite($handle, $_GET["fpath"]."\t");
				fwrite($handle, user_mime_content_type($fileDir.$fileName)."\t");
				fwrite($handle, filesize($fileDir.$fileName));
		
				fclose($handle);
		
				$handle = fopen($logFileName, "r");
				echo fread($handle, filesize($logFileName));
				fclose($handle);
				*/	
			}
		}
		
		/**
		* 다운로드 받을 파일이 2건 이상일때 경우
		*/
		else{
			
			/**
			* 프론트단으로부터 정의한 압축파일명을 적용한다.
			*/
			//$sZipFileName = "download_".date("YmdHis").".zip";
			$sZipFileName = isset($_REQUEST["zipFileName"]) ? $_REQUEST["zipFileName"]."_xfuDownload" : "download_".date("YmdHis").".zip_xfuDownload";
			$sTmpZipFile = $serverPath.$json_downList[count($json_downList)-1]["savePath"]."/".$sZipFileName;			
			$files_to_zip = array();
			$cnt = 0;

			/**
			* 다중 파일들을 압축
			*/
			foreach($json_downList as $files){
				
				$file = $serverPath.$json_downList[$cnt]["savePath"]."/".urldecode($files["fname"]);
				/*
				if($json_downList[$cnt]["fileAnotherNameCheck"]){
					
					$file = $serverPath.$json_downList[$cnt]["savePath"];
				}
				*/
				if(file_exists($file)) {
					
					$files_to_zip[] = $file;				
				}	
				$cnt++;
			}
			
			/**
			* zip 파일 생성
			*/
			$file_result = create_zip($files_to_zip, $sTmpZipFile);
				
			if($file_result) {				
				
				/**
				* zip파일 형성 완료되고나면 다운로드 진행
				*/
				//header('Content-Type: application/octet-stream');
				header("Content-type: ".user_mime_content_type($sTmpZipFile)."");	
				header('Content-Disposition: attachment; filename="' . basename(str_replace("_xfuDownload", "", $sZipFileName)) . '"');
				//header('Content-Disposition: attachment; filename="' . $sZipFileName . '"');
				header('Content-Transfer-Encoding:binary');
				header('Content-Length: ' . (filesize($sTmpZipFile)) );
				header('Cache-Control:cache,must-revalidate');
				header('Pragma:no-cache');
				header('Expires:0');
				
				//ob_clean();
				//flush();
				
				if(is_file($sTmpZipFile)){
					
					$fp = fopen($sTmpZipFile,"rb") or die("Failed to open file.");
					
					while(!feof($fp)){
						
						$buf = fread($fp,1024);
						//$read = strlen($buf);
						print($buf);
						flush();
					}
					fclose($fp);
				}
					
				/**
				* 파일이 다운로드 되지만 0 bytes 일 경우 파일의 권한 문제일 수 있습니다.
				*/
				//readfile($sTmpZipFile);	
					
				/**
				* 파일 다운로드를 하였으니 해당 zip 파일을 서버에서 삭제해준다.
				*/
				unlink($sTmpZipFile);			
				//ob_end_clean();
			}
		}
	}
}



/* creates a compressed zip file */
function create_zip($files = array(), $destination = '', $overwrite = false) {
		
	//if the zip file already exists and overwrite is false, return false
	if(file_exists($destination) && !$overwrite) {
		
		return false; 
	}
		
	//vars
	$valid_files = array();
	
	//if files were passed in...
	if(is_array($files)) {
		
		//cycle through each file
		foreach($files as $file) {
			
			//make sure the file exists
			if(file_exists($file)) {			
					
				$valid_files[] = $file;
			}
		}
	}
		
	//if we have good files...
	if(count($valid_files)) {
		
		//create the archive
		$zip = new ZipArchive();
		
		if($zip->open($destination, $overwrite ? ZIPARCHIVE::OVERWRITE : ZIPARCHIVE::CREATE) !== true) {
			
			return false;
		}
		
		$file_idx = 0;
		
		//add the files
		foreach($valid_files as $file) {
			
			$file_idx++;
			
			$file_name = basename($file);
			$file_ext = pathinfo($file_name)["extension"];
			$file_rename = basename($file, ".".$file_ext)."_".$file_idx.".".$file_ext;
			
			//$zip->addFile($file, basename($file));
			$zip->addFile($file, $file_rename);
		}
		//debug
		//echo 'The zip archive contains ',$zip->numFiles,' files with a status of ',$zip->status;
			
		//close the zip -- done!
		$zip->close();
			
		//check to make sure the file exists
		return file_exists($destination);
	}
	else {
		
		return false;
	}
}


// mime타입 정보 리턴
function user_mime_content_type($filename) { 

	if(!function_exists('mime_content_type')) { 
	
		$type = array( 
		'txt' => 'text/plain', 
		'htm' => 'text/html', 
		'html' => 'text/html', 
		'php' => 'text/html', 
		'css' => 'text/css', 
		'js' => 'application/javascript', 
		'json' => 'application/json', 
		'xml' => 'application/xml', 
		'swf' => 'application/x-shockwave-flash', 
		'flv' => 'video/x-flv', 

		// images 
		'png' => 'image/png', 
		'jpe' => 'image/jpeg', 
		'jpeg' => 'image/jpeg', 
		'jpg' => 'image/jpeg', 
		'gif' => 'image/gif', 
		'bmp' => 'image/bmp', 
		'ico' => 'image/vnd.microsoft.icon', 
		'tiff' => 'image/tiff', 
		'tif' => 'image/tiff', 
		'svg' => 'image/svg+xml', 
		'svgz' => 'image/svg+xml', 

		// archives 
		'zip' => 'application/zip', 
		'rar' => 'application/x-rar-compressed', 
		'exe' => 'application/x-msdownload', 
		'msi' => 'application/x-msdownload', 
		'cab' => 'application/vnd.ms-cab-compressed', 

		// audio/video 
		'mp3' => 'audio/mpeg', 
		'qt' => 'video/quicktime', 
		'mov' => 'video/quicktime', 

		// adobe 
		'pdf' => 'application/pdf', 
		'psd' => 'image/vnd.adobe.photoshop', 
		'ai' => 'application/postscript', 
		'eps' => 'application/postscript', 
		'ps' => 'application/postscript', 

		// ms office 
		'doc' => 'application/msword', 
		'rtf' => 'application/rtf', 
		'xls' => 'application/vnd.ms-excel', 
		'ppt' => 'application/vnd.ms-powerpoint', 

		// open office 
		'odt'=>'application/vnd.oasis.opendocument.text', 
		'ods'=>'application/vnd.oasis.opendocument.spreadsheet', 
		); 
		
		//$ext = strtolower(array_pop(explode('.',$filename))); 
		$ext_explode = explode('.',$filename);
		$ext_array_pop = array_pop($ext_explode);
		$ext_strtolower = strtolower($ext_array_pop);
		$ext = $ext_strtolower;
		
		if (array_key_exists($ext, $type)) { 
		
			return $type[$ext]; 
		} 
		elseif (function_exists('finfo_open')) { 
		
			$finfo = finfo_open(FILEINFO_MIME); 
			$mimetype = finfo_file($finfo, $filename); 
			finfo_close($finfo); 
			return $mimetype; 
		} 
		else { 
		
			return 'application/octet-stream'; 
		} 
	} 
	else { 
	
		return mime_content_type($filename); 
	} 
} 

// 파일조회 함수
// @$dir : (string) 조회할 디렉토리 폴더 절대경로
// return : 파일이름 / 저장한 날짜 / 저장경로 / 파일종류 / 파일크기
function DirectoryBrowser($dir, $filterWord, $web_dir, $serverPath) {
	
	if(is_dir($dir)) {
		
		if($dh = opendir($dir)) {
			
			while(($entry = readdir($dh)) !== false) {
				
				if($entry == "." || $entry == "..") {
					
					continue;
				}

				$subdir = $dir."/".$entry;
				
				// 최하위폴더가 존재할때까지 모두 조회
				if(is_dir($subdir)) {
					
					DirectoryBrowser($subdir, $filterWord, $web_dir, $serverPath);
				} 
				else {
					
					try{
						
						if(is_file($subdir)){
							
							// 파일이름
							$fileName = pathinfo($subdir, PATHINFO_BASENAME);
							// 저장한 날짜
							$fileDate = date("Y.m.d H:i:s", filemtime($subdir));
							// 저장경로
							//$filePath = pathinfo($subdir, PATHINFO_DIRNAME);
							$filePath = str_replace($serverPath, $web_dir, pathinfo($subdir, PATHINFO_DIRNAME));
							
							// 파일종류
							$fileExt = pathinfo($subdir, PATHINFO_EXTENSION);
							// 파일크기
							$fileSize = filesize($subdir);

							// 필터정보 없이 파일전체조회
							if($filterWord == "*"){
								
								// 조합
								echo $fileName."\t".$fileDate."\t".$filePath."\t".$fileExt."\t".$fileSize."\n";
							}
							// 파일명 기준 파일조회
							else{
								
								if($filterWord != "*"){
									
									$fWords = explode("|", $filterWord);
									
									for($i=0; $i<count($fWords); $i++){
										
										if($fWords[$i] == $fileName){
											
											echo $fileName."\t".$fileDate."\t".$filePath."\t".$fileExt."\t".$fileSize."\n";
										}
									}
								}
							}
						}
						
					} catch(Exception $e) {
						
						
					}
					
					
					/*
					$arr = array(
						"fileName"=> $fileName, 
						"fileDate"=>$fileDate, 
						"filePath"=>$filePath, 
						"fileExt"=>$fileExt, 
						"fileSize"=>$fileSize
					);					
					echo json_encode($arr);
					*/
				}
			}
			closedir($dh);
		}
	}
}
?>