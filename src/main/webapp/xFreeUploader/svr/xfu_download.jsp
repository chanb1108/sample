<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.zip.*"%>

<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.text.SimpleDateFormat"%>

<%@page import="com.google.gson.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>

<%@page import="java.io.File"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>

<%@page import="java.util.Base64"%>
<%@page import="java.util.Base64.Decoder"%>
<%@page import="java.util.Base64.Encoder"%>

<%
// charset 전역변수 처리
String charsetName = "utf-8";

request.setCharacterEncoding(charsetName);
response.setCharacterEncoding(charsetName);
response.setContentType("text/html;charset=" + charsetName); 

/* 분기처리를 위한 state 값
 * FILELIST			: 파일 조회
 * DOWNLOAD	: 파일 다운로드
*/

String state = request.getParameter("state");

if(state.equals("FILELIST")){
	
	boolean absolutePathFlag = false;								// 절대경로 여부 
	String sfilePath = request.getParameter("path");				// 서버경로
	String filterWord = request.getParameter("filterWord");			// 필터정보

	if(sfilePath.indexOf("\\") > -1 || sfilePath.indexOf("//") > -1) {
		absolutePathFlag = true;	// 예) C:\Windows\System32\drivers\etc\hosts
	}

	// 웹자원의 최상단 루트 경로 지정
	//String RootPath = getServletContext().getRealPath(request.getServletPath());	
	String RootPath = getServletContext().getRealPath("/");
	int upPos = RootPath.lastIndexOf("\\");
	RootPath = RootPath.substring(0, upPos);
	
	String webPath = getBaseUrl(request);
	
	int pos = -1;
	if ((pos = RootPath.lastIndexOf("/")) > 0)
	{
		RootPath = RootPath + sfilePath;
		webPath = webPath + sfilePath;
	}
	else if ((pos = RootPath.lastIndexOf("\\")) > 0)
	{
		sfilePath = sfilePath.replace("/", "\\");
		RootPath = RootPath + sfilePath;
		webPath = webPath + sfilePath;
	}

	if(absolutePathFlag) {
		
		RootPath = sfilePath;
	}
	
	// 파일조회 실행(하위 폴더까지 모두 조회됨) 
	String tRootPath = DirectoryBrowser ( RootPath, filterWord, webPath ) ; 
	tRootPath = tRootPath.replace ( RootPath + "/" , "" ) ;
	out.println( tRootPath ) ;
	
} else if(state.equals("REDOWNLOADFILEINFO")){
	
	//String serverPath = getServletContext().getRealPath(request.getServletPath());
	String serverPath = getServletContext().getRealPath("/");
	int upPos = serverPath.lastIndexOf("\\");
	serverPath = serverPath.substring(0, upPos);
	
	// 요청받은 검색해야할 파일명
	String searchFileName = (String) request.getParameter("fileName");
	
	// docID
	String xfu_Doc_ID = (String) request.getParameter("xfuDocID");
	String docID_folder = "";
	
	if(xfu_Doc_ID.equals("xfdocid_0000000000")){
		
		docID_folder = "xfdocid_0000000000/";
	} else {
		
		docID_folder = xfu_Doc_ID + "/";
	}
	
	// 요청받은 파일경로
	String searchFolder = serverPath + (String) request.getParameter("searchUrl") + docID_folder;	
	JsonArray arr=new JsonArray();	
	
	try{
		
		File resumbDir = new File(searchFolder.replace("//", "\\"));	
		File[] files2 = resumbDir.listFiles();
		
		for(File f: files2){
			
			String fileName = f.getName();
		
			// 찾을 파일이름에 "_xfuDownload" 가 들어있는 파일명이 나올때까지 찾기
			if(fileName.indexOf(searchFileName) > -1 && fileName.indexOf("_xfuDownload") > -1){
				
				String fileOriName = searchFileName;			
				JsonObject obj=new JsonObject();			
				int index = fileName.lastIndexOf(".");
				String fileExt = "";
				
				if (index > 0) {
					
					fileExt = fileName.substring(index + 1);
				}
				
				// 파일원본명
				obj.addProperty("fileName", fileOriName);
				
				// 파일경로
				obj.addProperty("savePath", f.getAbsolutePath());
				
				// rename처리된 파일명
				obj.addProperty("fileReName", fileName.replace("." + fileExt, ""));
				
				// 파일확장자명
				obj.addProperty("fileType", fileExt);
				
				// 파일크기
				obj.addProperty("fileSize", f.length());
				
				// 배열로 저장
				arr.add(obj);	
			}
		}
	} catch(Exception e){
		
	}
	
	
	// 프런트단에 json형식으로 넘긴다.
	out.println(arr.toString());
	
} else if(state.equals("DOWNLOAD")){
	
	// 파라미터 전달 받기
	String postData = request.getParameter("downList");
	
	try{
		JSONParser jsonParser = new JSONParser();
		
		//JSON데이터를 넣어 JSON Object 로 만들어 준다.		
		JSONArray jsonArr = (JSONArray) jsonParser.parse(postData);
		
		int jsonArrCnt = jsonArr.toArray().length;
		
		
		// single
		if(jsonArrCnt == 1){
			JSONObject jsonObj =(JSONObject) jsonArr.get(0);
			
			String fileName = URLDecoder.decode((String) jsonObj.get("fname"), charsetName);
			String filePath = (String) jsonObj.get("savePath");
			String fileRealUrl = (String) jsonObj.get("fileRealUrl");
			
			filePath = filePath.replace("\\", "//");	
			
			//String sDownPath = getServletContext().getRealPath(request.getServletPath());
			String sDownPath = getServletContext().getRealPath("/");
			int upPos = sDownPath.lastIndexOf("\\");
			sDownPath = sDownPath.substring(0, upPos);
			String sFilePath = null;

			int pos = -1;
			if ((pos = sDownPath.lastIndexOf("/")) > 0)
			{
				
				if(fileRealUrl == "" || fileRealUrl.isEmpty()){
					
					sDownPath = sDownPath + filePath;
					sFilePath = sDownPath + "/" + fileName;					
				} 
				else {
					
					sFilePath = sDownPath + fileRealUrl;
				}
			}
			else if ((pos = sDownPath.lastIndexOf("\\")) > 0)
			{
				
				if(fileRealUrl == "" || fileRealUrl.isEmpty()){
					
					sDownPath = sDownPath + filePath.replace("/", "\\");
					sFilePath = sDownPath + "\\" + fileName;					
				} 
				else {
					
					sFilePath = sDownPath + fileRealUrl.replace("/", "\\");
				}
			}
			
			// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
			sFilePath = cleanXSS(sFilePath);
			
			File oFile = new File(sFilePath);
			byte b[] = new byte[(int)oFile.length()];
			//byte b[] = new byte[1024*1024*1000];
	
			if(oFile.length() > 0 && oFile.isFile()){
				String sMimeType = getServletContext().getMimeType(sFilePath);
				
				if(sMimeType == null){
					//sMimeType = "application.octec-stream";
					sMimeType = "application/x-msdownload";
				}
						
				//response.setContentType(sMimeType);
				 response.setHeader("Content-Type", "application/octet-stream; charset=MS949");
				/*
				FileInputStream in = new FileInputStream(oFile);	
				
				//String A = new String(fileName.getBytes(charsetName), "8859_1");
				String A = new String(fileName);
				String B = charsetName;
				String sEncoding = URLEncoder.encode(A, B);
				String AA = "Content-Disposition";
				String BB = "attachment; filename=" + sEncoding;
				response.setHeader(AA, BB);
				*/
	
				String downFileName = URLEncoder.encode(new String(fileName), charsetName);
				downFileName = downFileName.replaceAll("\\+", "%20");
				downFileName = downFileName.replaceAll("_xfuDownload", "");
				
				// SW취약점 - 위반라인의 HTTP 헤더로 삽입되는 외부 입력 변수에 개행 문자 제거가 필요함((\r, \n)제거해야함
				downFileName = cleanXSSNewLine(downFileName);
						
				response.setHeader("Content-Disposition", "attachment;filename="+ downFileName + ";"); 
				response.setHeader("Content-Transper-Encoding", "binary");
				response.setHeader("Set-Cookie", "fileDownload=true; path=/");
				
				//out.clear();
				BufferedInputStream input = new BufferedInputStream(new FileInputStream(oFile));
				BufferedOutputStream output = new BufferedOutputStream(response.getOutputStream());
				
				//ServletOutputStream sos = response.getOutputStream();
				
				int numRead = 0;
				try{
					while((numRead = input.read(b)) != -1){
						output.write(b, 0, numRead);
					}
					
					output.close();
					input.close();
					
					//out = pageContext.pushBody();
					
					//sos.flush();
					//sos.close();
					//in.close();
					
					// 로그데이터 생성
					/*
					Date logDate = new Date();
					SimpleDateFormat simple = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					
					String filelogName = "ulog.dat";
					String fileFullUrl = getServletContext().getRealPath(request.getServletPath());	
					int pos2 = -1;
					if ((pos2 = fileFullUrl.lastIndexOf("/")) > 0) {
						fileFullUrl = fileFullUrl.substring(0, pos2) + "/"+filelogName;
					} else if ((pos2 = fileFullUrl.lastIndexOf("\\")) > 0) {
						fileFullUrl = fileFullUrl.substring(0, pos2) + "\\"+filelogName;
					}
					
					String logData = "";
					logData += simple.format(logDate) + "\t";
					logData += getClientIP(request) + "\t";
					logData += "[filedownload]\t" + fileName + "\t";
					logData += sDownPath + "\t";
					logData += sMimeType + "\t";
					logData += oFile.length();
					
					makeLogData(fileFullUrl, logData);
					*/
				} catch(IOException ioe){
					//System.out.println("errMsg : " + ioe.getMessage());
					System.out.println("download error");
				} finally {
					if(output != null) {output.close();}
					if(input != null) {input.close();}
					
					// 다운로드 정상적으로 받은 파일명에 _xfuDownload 가 존재하면 서버상에서 삭제처리
					String _downFileName = downFileName + "_xfuDownload";
					
					if(_downFileName.indexOf("download_") > -1 && _downFileName.indexOf(".zip_xfuDownload") > -1){
						
						oFile.delete();
					}
				}
			}
		}
		// multi
		else{
			//List<Object> fileList = new ArrayList<Object>();
			List<File> fileList = new ArrayList<>();
			
			for(int i=0; i<jsonArrCnt; i++){
				JSONObject jsonObj =(JSONObject) jsonArr.get(i);
				
				String fileName = URLDecoder.decode((String) jsonObj.get("fname"), charsetName);
				String filePath = (String) jsonObj.get("savePath");	
				String fileRealUrl = (String) jsonObj.get("fileRealUrl");
				
				filePath = filePath.replace("\\", "//");	
				
				//String sDownPath = getServletContext().getRealPath(request.getServletPath());
				String sDownPath = getServletContext().getRealPath("/");
				int upPos = sDownPath.lastIndexOf("\\");
				sDownPath = sDownPath.substring(0, upPos);
				String sFilePath = null;

				int pos = -1;
				if ((pos = sDownPath.lastIndexOf("/")) > 0)
				{
					
					if(fileRealUrl == "" || fileRealUrl.isEmpty()){
						
						sDownPath = sDownPath + filePath;
						sFilePath = sDownPath + "/" + fileName;					
					} 
					else {
						
						sFilePath = sDownPath + fileRealUrl;
					}
				}
				else if ((pos = sDownPath.lastIndexOf("\\")) > 0)
				{
					
					if(fileRealUrl == "" || fileRealUrl.isEmpty()){
						
						sDownPath = sDownPath + filePath.replace("/", "\\");
						sFilePath = sDownPath + "\\" + fileName;					
					} 
					else {
						
						sFilePath = sDownPath + fileRealUrl.replace("/", "\\");
					}
				}
								
				//fileList.add(sFilePath);
				
				File xfuFile = new File(sFilePath);
				fileList.add(xfuFile);
			}
			
			Date logDate = new Date();
			SimpleDateFormat simple = new SimpleDateFormat("yyyyMMddHHmmss");
			String zipFileName = simple.format(logDate).toString();
			
			// Create the ZIP file
			JSONObject jsonObj =(JSONObject) jsonArr.get(jsonArrCnt-1);
			String strPath = (String)jsonObj.get("savePath");
			
			String strTargetFolder = getServletContext().getRealPath("/");
			int pos = -1;
			if ((pos = strTargetFolder.lastIndexOf("/")) > 0)
			{
				strTargetFolder = strTargetFolder + strPath;
			}
			else if ((pos = strTargetFolder.lastIndexOf("\\")) > 0)
			{
				strTargetFolder = strTargetFolder + strPath.replace("/", "\\");
			}
			
			String outFilename = strTargetFolder + "\\download_" + zipFileName + ".zip_xfuDownload";
			
			// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
			outFilename = cleanXSS(outFilename);
			
			//ZipOutputStream zipOut = new ZipOutputStream(new FileOutputStream(outFilename));
			
			byte[] buf = new byte[4096];

			/*
			for(int j=0; j < fileList.size(); j++ ) {
				String f = fileList.get(j).toString();
				
				// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
				f = cleanXSS(f);
				
				FileInputStream in = new FileInputStream(f);
				zipOut.putNextEntry(new ZipEntry(f)); 
				//zipOut.setLevel(9); 

				int len = 0;
				while ((len = in.read(buf)) > 0) {
					zipOut.write(buf, 0, len);
				}

				// Complete the entry
				zipOut.closeEntry();
				in.close();						
			}
			zipOut.close();
			*/
			
			ZipOutputStream zipOut = new ZipOutputStream(new FileOutputStream(outFilename));
			FileInputStream in = null;
			
			try {
 
				int file_idx = 0;
				
				for (File file : fileList) {
					
					/*
					System.out.println("-----------------------------");
					System.out.println(file.isDirectory());
					System.out.println(file.getPath());
					System.out.println(file.exists());
					System.out.println(file.isFile());
					System.out.println(file.length());
					*/
					
					in = new FileInputStream(file);
						
					file_idx++;
					
					String file_name = file.getName();
					int file_pos = file_name.lastIndexOf( "." );
					String file_ext = file_name.substring( file_pos + 1 );
					String onlyFileName = file_name.substring(0, file_pos);
					String file_rename = onlyFileName + "_" + file_idx + "." + file_ext;
					
					//ZipEntry ze = new ZipEntry(file.getName());
					ZipEntry ze = new ZipEntry(file_rename);
					zipOut.putNextEntry(ze);
 
					int len;
					while ((len = in.read(buf)) > 0) {
						zipOut.write(buf, 0, len);
					}
 
					zipOut.closeEntry();
					
	 
				}
			} catch(IOException ioe) {
				//System.out.println("errMsg : " + ioe.getMessage());			
				System.out.println("download error");
			} finally {
				zipOut.close();
				in.close();
			}
			
			// 다운로드 하기
			boolean MSIE = getBrowser(request);
			String fileName  =  "download_" + zipFileName + ".zip";
			
			// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
			outFilename = cleanXSS(outFilename);

			File file = new File(outFilename);
			//byte bytestream[]= new byte[4096];
			byte bytestream[]= new byte[(int)file.length()];

			response.reset();
			response.setContentType("application/octet-stream");
			
			if(MSIE){   
				response.setHeader ("Content-Disposition", "attachment; filename="+new String(fileName.getBytes("KSC5601"),"ISO8859_1"));
			} else {					
				String orgfilename = new String(fileName.getBytes(charsetName),"iso-8859-1"); 
				response.setHeader("Content-Disposition", "attachment; filename=\"" + orgfilename + "\"");
				response.setHeader("Content-Type", "application/octet-stream; charset=" + charsetName);			
			}
							
			response.setHeader("Content-Length",""+file.length());	
			response.setHeader("Set-Cookie", "fileDownload=true; path=/");
			
			OutputStream bos = null;
			FileInputStream fis = new FileInputStream(file);
			
			try {				
				//out.clear();
				//out = pageContext.pushBody();
				
				bos = response.getOutputStream();
			
				int read = 0;
				while((read = fis.read(bytestream,0,bytestream.length)) != -1) {
					bos.write(bytestream,0,read);
				}
				//zipOut.close();
				
				bos.flush();				
				bos.close();	
			} catch(IOException ioe) {
				//System.out.println("errMsg : " + ioe.getMessage());			
				System.out.println("download error");
			} finally {
				if (bos != null){
					bos.close();
				}
				//zipOut.close();
				fis.close();
				file.delete(); // 임시 압축 파일 삭제함.	
			}
		}
	}catch(ParseException e){
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
}





%>
<%!
public static synchronized void makeLogData(String fileName, String logData) throws java.io.IOException{
	BufferedReader reader = null;
	BufferedWriter bw = null;

	File f = null;
	boolean bool = false;
	
	// 로그파일 생성
	try{
		f = new File(fileName);
		f.createNewFile();		
		bool = f.exists();
		
		if(bool){
			// 파일 읽기				
			reader = new BufferedReader( new FileReader(fileName));
			String str = "";
			String line = null;
			while((line = reader.readLine()) != null){
				str += line + "\n";
			}

			char intxt[] = new char[str.length()];				
			str.getChars(0, str.length(), intxt, 0);
		
			// 파일 쓰기
			bw = new BufferedWriter(new FileWriter(fileName));
			//bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName), charsetName));
			bw.write(intxt);
			bw.write(logData);
		}
		else if(!bool){
			f.createNewFile();
			
			// 파일 쓰기
			bw = new BufferedWriter(new FileWriter(fileName));
			//bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName), charsetName));
			bw.write(logData);	
		}
		if (reader != null){
			reader.close();
		}
		
		bw.flush();
		
		if (bw != null){
			bw.close();
		}
	}
	catch(IOException ioe){
		System.out.println("Not read File");
	}
	finally{
		if (reader != null){
			reader.close();
		}
		
		if (bw != null){
			bw.close();
		}
	}
}	
public String getClientIP(HttpServletRequest request) {
	String ip = request.getHeader("X-FORWARDED-FOR"); 

	if (ip == null || ip.length() == 0) {
		ip = request.getHeader("Proxy-Client-IP");
	}

	if (ip == null || ip.length() == 0) {
		ip = request.getHeader("WL-Proxy-Client-IP");  // 웹로직
	}

	if (ip == null || ip.length() == 0) {
		ip = request.getRemoteAddr() ;
	}
	return ip;
}
public boolean getBrowser(HttpServletRequest request) {
	
	String header = request.getHeader("User-Agent");
    if (header.indexOf("MSIE") > -1) {
		return true;  //return "MSIE";                   
    } else if (header.indexOf("Trident") > -1) {
        return true;
    } else if (header.indexOf("OPR") > -1) {
        return false;
    } else if (header.indexOf("Chrome") > -1) {
        return false;
    } else if (header.indexOf("Opera") > -1) {
        return false;
    } else if (header.indexOf("Firefox") > -1) {
        return false;
    } else if (header.indexOf("Safari") > -1) {
        return false;
    } else{
        return false;
    }
} 
private static String cleanXSS(String value) {
	
	value = value.replaceAll("<", "& lt;").replaceAll(">", "& gt;");
	value = value.replaceAll("\\(", "& #40;").replaceAll("\\)", "& #41;");
	value = value.replaceAll("'", "& #39;");
	value = value.replaceAll("eval\\((.*)\\)", "");
	value = value.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");
	value = value.replaceAll("script", "");
	value = value.replaceAll("\\.{2,}[/\\\\]", "");

	return value;
}
private static String cleanXSSNewLine(String value) {
	
	value = value.replaceAll("[\\r\\n]", "");

	return value;
}
public static String DirectoryBrowser ( String RootPath, String filterWord, String webPath )
{
	String File_List = "" ;
	RootPath = RootPath.replace ( "\\" , "/" ) ;
	webPath = webPath.replace ( "\\" , "/" ) ;
	
	File FindDir = new File ( RootPath ) ;
	SimpleDateFormat simple = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	try{
		String [ ] FindFile = FindDir.list ( ) ;

		for ( int i = 0 ; i < FindFile.length ; i ++ )
		{
			File tDir = new File ( FindDir + "/" + FindFile[i] ) ;
			
			if ( tDir.isDirectory ( ) == true )
			{
				File_List += DirectoryBrowser ( FindDir + "/" + FindFile[i], filterWord,  webPath + "/" + FindFile[i] ) ;
			}
			else
			{				
				String fileName = tDir.getName();
				int extIdx = fileName.lastIndexOf(".");
				int p = Math.max(fileName.lastIndexOf("/"), fileName.lastIndexOf("\\"));
				String fileDate = simple.format(tDir.lastModified());
				String filePath = webPath;
				String fileExt = " ";
				
				if(extIdx > p){
					fileExt = fileName.substring(extIdx+1);
				}
				
				long fileSize = tDir.length();
				
				// 필터정보 없이 파일전체조회
				if(filterWord.equals("*")){
					File_List += fileName + "\t" + fileDate + "\t" + filePath + "\t" + fileExt + "\t" + fileSize + "\n" ;
				}
				// 파일명 기준 파일조회
				else{
					if(!filterWord.equals("*")){
						String[] fWords = filterWord.split("\\|");
						for ( int j = 0 ; j < fWords.length ; j ++ ){							
							if(fWords[j].equals(fileName)){
								File_List += fileName + "\t" + fileDate + "\t" + filePath + "\t" + fileExt + "\t" + fileSize + "\n" ;
							}
						}
					}
				}
			}
		}		
	}
	catch(Exception e){
		
	}	
	return File_List ;
}

public static String getBaseUrl(HttpServletRequest request) {
    String scheme = request.getScheme() + "://";
    String serverName = request.getServerName();
    String serverPort = (request.getServerPort() == 80) ? "" : ":" + request.getServerPort();
    String contextPath = request.getContextPath();
    return scheme + serverName + serverPort + contextPath;
}
%>