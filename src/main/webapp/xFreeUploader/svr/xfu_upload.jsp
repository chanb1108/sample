<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
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
 * DELETE						: 파일 삭제
 * FOLDERDELETE			: 빈폴더 삭제 (파일 삭제로 인하여 발생할 수 있는 날짜명의 빈폴더 삭제)
 * REUPLOADFILEINFO	: 이어서 전송을 위한 파일정보 가져오기
 * UPLOAD					: 파일 업로드
*/

// 파라미터 통해서 데이터 Get
String state = (String) request.getParameter("state");


// 파일삭제
if(state.equals("DELETE")){
	
	String sfilePath = (String) request.getParameter("filePath");
	
	String uploadPath = getServletContext().getRealPath("/");
	int upPos = uploadPath.lastIndexOf("\\");
	uploadPath = uploadPath.substring(0, upPos);

	
	// 삭제 파일경로 가져오기
	String sDelPath = (String) request.getParameter("deleteUrl");
	if(sDelPath != null){
		
		// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
		File file = new File(cleanXSS(uploadPath + sDelPath));
        
        if( file.exists() ){
            if(file.delete()){
                out.println("파일삭제 성공");
            }else{
                out.println("파일삭제 실패");
            }
        }else{
            out.println("파일이 존재하지 않습니다. : " + sDelPath);
        }
	}	
}

// 빈폴더 삭제
else if(state.equals("FOLDERDELETE")){
	
	//String serverPath = getServletContext().getRealPath(request.getServletPath());
	String serverPath = getServletContext().getRealPath("/");
	int upPos = serverPath.lastIndexOf("\\");
	serverPath = serverPath.substring(0, upPos);
	
	String path = serverPath + (String) request.getParameter("path");
	
	File emptyForders = new File(path);
	
	out.println(deleteEmptyDir(emptyForders));
}

// 이어서 전송을 위한 파일정보 가져오기
else if(state.equals("REUPLOADFILEINFO")){
	
	//String serverPath = getServletContext().getRealPath(request.getServletPath());
	String serverPath = getServletContext().getRealPath("/");
	int upPos = serverPath.lastIndexOf("\\");
	serverPath = serverPath.substring(0, upPos);
	
	// 요청받은 검색해야할 파일명
	String searchFileName = (String) request.getParameter("fileName");
	
	String[] searchFileNameList = searchFileName.split("|");
	
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
	File resumbDir = new File(searchFolder.replace("/", "\\"));	
	File[] files2 = resumbDir.listFiles();
	
	if(files2 != null){
		
		for(File f: files2){
		
			String fileName = f.getName();
			
			// 찾을 파일이름에 "_xfuChunked" 가 들어있는 파일명이 나올때까지 찾기
			//if(fileName.indexOf(searchFileName) > -1 && fileName.indexOf("_xfuChunked") > -1){
			//if(fileName.indexOf("_xfuChunked") > -1){	
			
			for(int i=0; i<searchFileNameList.length; i++){
				
				int dot = searchFileNameList[i].lastIndexOf(".");
				
				if(dot > -1){
					
					if(fileName.indexOf(searchFileNameList[i].substring(0, dot)) > -1 && fileName.indexOf("_xfuChunked") > -1){	
					
						String fileOriName = searchFileNameList[i];			
						JsonObject obj=new JsonObject();			
						int index = fileName.lastIndexOf(".");
						String fileExt = "";
						
						if (index > 0) {
							
							fileExt = fileName.substring(index + 1);
						}
						
						String noExtFileName = fileName.replace("." + fileExt, "");
						
						// 파일원본명
						//obj.addProperty("fileName", fileOriName);
						
						// 파일경로
						obj.addProperty("savePath", f.getAbsolutePath());
						
						// rename처리된 파일명
						//obj.addProperty("fileReName", fileName);
						obj.addProperty("fileReName", noExtFileName);
						
						// 파일원본명
						fileOriName = noExtFileName.split("_")[0];
						obj.addProperty("fileName", fileOriName);
						
						
						// 파일확장자명
						obj.addProperty("fileType", fileExt);
						
						// 파일크기
						obj.addProperty("fileSize", f.length());
						
						// 배열로 저장
						arr.add(obj);	
					}
				}
			}
		}
	}
	
	// 프런트단에 json형식으로 넘긴다.
	out.println(arr.toString());
}

// 업로드
else if(state.equals("UPLOAD")){
	
	String sfilePath = (String) request.getParameter("filePath");
	int mSize = Integer.parseInt(request.getParameter("maxsize"));

	String nCount = (String) request.getParameter("nCount");
	
	if(nCount==null){
		
		nCount = "1";
	}
	
	boolean isXSSTarget = false;

	// org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
	JsonObject object1=new JsonObject();

	// org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
	// JSONObject object1=new JSONObject();



	// 업로드 폴더 경로 : 날짜별로 폴더 생성
	String sDate = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());

	//String uploadPath = getServletContext().getRealPath(request.getServletPath());
	String uploadPath = getServletContext().getRealPath("/");
	int upPos = uploadPath.lastIndexOf("\\");
	uploadPath = uploadPath.substring(0, upPos);
	
	String uploadPath2 = "";

	boolean absolutePathFlag = false;								// 절대경로 여부
	if(sfilePath.indexOf("\\") > -1 || sfilePath.indexOf("//") > -1) {
		if(sfilePath.indexOf("\\") > -1) sfilePath = sfilePath.replace("\\", "/");
		absolutePathFlag = true;	// 예) C://Windows/System32/drivers/etc/hosts
	}
	
	// docID
	String xfu_Doc_ID = (String) request.getParameter("xfuDocID");
	String docID_folder = "";
	
	if(xfu_Doc_ID.equals("xfdocid_0000000000")){
		
		docID_folder = "xfdocid_0000000000";
	} else {
		
		docID_folder = xfu_Doc_ID;
	}
	
	int pos = -1;
	if ((pos = uploadPath.lastIndexOf("/")) > 0)
	{
		uploadPath = uploadPath + sfilePath + "/" + sDate + "/" + docID_folder;
		uploadPath2 = sfilePath + "/" + sDate + "/" + docID_folder;
	}
	else if ((pos = uploadPath.lastIndexOf("\\")) > 0)
	{
		uploadPath = uploadPath + sfilePath + "\\" + sDate + "\\" + docID_folder;
		uploadPath = uploadPath.replace("\\", "/");
		
		uploadPath2 = sfilePath + "\\" + sDate + "\\" + docID_folder;
		uploadPath2 = uploadPath2.replace("\\", "/");
	}

	if(absolutePathFlag) {
		uploadPath = uploadPath + sfilePath + "/" + sDate + "/" + docID_folder;
		uploadPath = uploadPath.replace("//", "\\");	
		
		uploadPath2 = sfilePath + "/" + sDate + "/" + docID_folder;
		uploadPath2 = uploadPath2.replace("//", "\\");	
	}
	
	// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
	uploadPath = cleanXSS(uploadPath);
	
	// 업로드 폴더 생성
	File dir = new File(uploadPath);
	dir.mkdirs();

	// Windows file system인 경우 MultipartRequest에서 인식할 수 있는 경로 스타일로 바꿔줘야..
	if ((pos = uploadPath.lastIndexOf("/")) == -1)
	{
		if ((pos = uploadPath.indexOf(":\\")) > 0)
		{
			// TOMCAT에서는 드라이브 명 ("D:\\") 굳이 제거하지 않아도 잘 인식하는 듯..
			// 나중에 혹시나 싶어서 코멘트 남겨 둠..
			// uploadPath = "/" + uploadPath.substring(pos+2, uploadPath.length());
			uploadPath = usf_replace(uploadPath, "\\", "/");
		}
	}

	String encType = charsetName;
	int maxSize = 1024 * 1024 * mSize;
	request.setCharacterEncoding(encType);
	 
	String name = "";
	String fileName1 = ""; // 중복처리된 이름
	String originalName1 = ""; // 중복 처리전 실제 원본 이름
	long fileSize = 0; // 파일 사이즈
	String fileType = ""; // 파일 타입
	boolean sizeError = false;
	 
	MultipartRequest multi = null;
	 
	try{
		// cos(com.oreilly.servlet)의 MultipartRequest를 이용해서 업로드 !!!
		// request,파일저장경로,용량,인코딩타입,중복파일명에 대한 기본 정책
		multi = new MultipartRequest(request, uploadPath, maxSize, encType, new DefaultFileRenamePolicy());
		
		// form내의 input name="name" 인 녀석 value를 가져옴
		//name = multi.getParameter("upl");
		 
		// 전송한 전체 파일이름들을 가져옴
		Enumeration<?> files = multi.getFileNames();
		 
		while(files.hasMoreElements()){
			if(nCount.equals("1") && nCount != null){
				// form 태그에서 <input type="file" name="여기에 지정한 이름" />을 가져온다.
				String file1 = (String)files.nextElement(); // 파일 input에 지정한 이름을 가져옴
				// 그에 해당하는 실재 파일 이름을 가져옴
				originalName1 = multi.getOriginalFileName(file1);
				// 파일명이 중복될 경우 중복 정책에 의해 뒤에 1,2,3 처럼 붙어 unique하게 파일명을 생성하는데
				// 이때 생성된 이름을 filesystemName이라 하여 그 이름 정보를 가져온다.(중복에 대한 처리)
				fileName1 = multi.getFilesystemName(file1);
				// 파일 타입 정보를 가져옴
				fileType = multi.getContentType(file1);
				// input file name에 해당하는 실재 파일을 가져옴
				File file = multi.getFile(file1);
				// 그 파일 객체의 크기를 알아냄
				fileSize = file.length();
				
				// 해당 로직은 XSS공격에 대한 방어로직으로 업로드한 파일에 공격성 문자열이 존재시 업로드된 파일을 무조건 삭제처리하도록 구현된 로직입니다.
                //if (!isBinaryFile(file)) {
                    Scanner scan = new Scanner(file, charsetName);
                    String fText = "";
                    while(scan.hasNextLine()){
                    	fText = scan.nextLine();
                    }
                    
                    if (checkXSS(fText))
                    {
                    	isXSSTarget = true;
                        
                    	response.setStatus(405);
                    }
                    else
                    {
                        isXSSTarget = false;
                    }
                    scan.close();
                //}
				
				// JSON 데이터 정보
				out.clear();
				
				// org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
				//JsonObject object1=new JsonObject();
				//object1.addProperty("isBinaryFile",isBinaryFile(file));
				object1.addProperty("fileName",file1);
				//object1.addProperty("savePath",uploadPath);
				object1.addProperty("savePath",uploadPath2);
				//object1.addProperty("oriFileName",originalName1);
				object1.addProperty("fileReName",fileName1);
				object1.addProperty("fileType",fileType);
				object1.addProperty("fileSize",fileSize);
				object1.addProperty("isXSSTargetFile",isXSSTarget);
				
				
				/*
				// org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
				object1.put("fileName",file1);
				object1.put("savePath",uploadPath);
				object1.put("fileReName",fileName1);
				object1.put("fileType",fileType);
				object1.put("fileSize",fileSize);
				object1.put("isXSSTargetFile",isXSSTarget);
				*/
				
				
				// 파일명을 base64형식으로 rename시키고 싶은 경우.
				// encodeFileName(originalName1, originalName1, uploadPath, object1);
				
				if(isXSSTarget)	file.delete(); 				   // 만약에 해당프로젝트에서 삭제 로직이 불필요하다면 해당 줄만 주석처리 하셔도 됩니다.
				
				JsonArray jArray = new JsonArray();
				jArray.add(object1);
				out.println(jArray.toString());
				//out.println(base64Encode(jArray.toString()));
				out.flush();				
			}
			else{
				// form 태그에서 <input type="file" name="여기에 지정한 이름" />을 가져온다.
				String file1 = (String)files.nextElement(); // 파일 input에 지정한 이름을 가져옴				
				// 그에 해당하는 실재 파일 이름을 가져옴
				originalName1 = multi.getOriginalFileName(file1);
				// 파일명이 중복될 경우 중복 정책에 의해 뒤에 1,2,3 처럼 붙어 unique하게 파일명을 생성하는데
				// 이때 생성된 이름을 filesystemName이라 하여 그 이름 정보를 가져온다.(중복에 대한 처리)
				fileName1 = multi.getFilesystemName(file1);
				// 파일 타입 정보를 가져옴
				fileType = multi.getContentType(file1);				
				// input file name에 해당하는 실재 파일을 가져옴
				File file = multi.getFile(file1);
				// 그 파일 객체의 크기를 알아냄
				fileSize = file.length();
				
				combineFile(originalName1, fileName1, uploadPath, request.getParameter("chunkFileSize"), request.getParameter("chunkFileName"), object1, request.getParameter("fileSize"));
				
				if(!files.hasMoreElements()){
					
					String deleteFilePath = uploadPath+"/"+originalName1;
					deleteFilePath = deleteFilePath.replace("/", "\\");
					
					System.out.println("delete file : " + deleteFilePath);
					File delFile = new File(deleteFilePath);
					delFile.delete();
				}
				
				// JSON 데이터 정보
				out.clear();
				
				// org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
				//JsonObject object1=new JsonObject();
				//object1.addProperty("isBinaryFile",isBinaryFile(file));
				//object1.addProperty("fileName",file1);
				object1.addProperty("fileName",originalName1);
				//object1.addProperty("savePath",uploadPath);
				object1.addProperty("savePath",uploadPath2);				
				//object1.addProperty("oriFileName",originalName1);
				//object1.addProperty("fileReName",fileName1);
				object1.addProperty("fileType",fileType);
				object1.addProperty("fileSize",request.getParameter("fileSize"));
				//object1.addProperty("fileSize",fileSize);
				object1.addProperty("isXSSTargetFile",isXSSTarget);
				
				/*
				// org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
				object1.put("fileName",file1);
				object1.put("savePath",uploadPath);
				object1.put("fileType",fileType);
				object1.put("isXSSTargetFile",isXSSTarget);
				*/
				
				// org.json.simple.JSONArray 객체를 이용시 아래 구문을 사용합니다.
				JsonArray jArray = new JsonArray();
				jArray.add(object1);
				out.println(jArray.toString());
				//out.println(base64Encode(jArray.toString()));
				out.flush();				
			}
						
			
			// 로그데이터 생성
			Date logDate = new Date();
			SimpleDateFormat simple = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			
			String fileName = "ulog.dat";
			String fileFullUrl = getServletContext().getRealPath(request.getServletPath());	
			int pos2 = -1;
			if ((pos2 = fileFullUrl.lastIndexOf("/")) > 0) {
				fileFullUrl = fileFullUrl.substring(0, pos2) + "/"+fileName;
			} else if ((pos2 = fileFullUrl.lastIndexOf("\\")) > 0) {
				fileFullUrl = fileFullUrl.substring(0, pos2) + "\\"+fileName;
			}
			
			String logData = "";
			logData += simple.format(logDate) + "\t";
			logData += getClientIP(request) + "\t";
			logData += "[fileupload]\t" + fileName1 + "\t";
			logData += uploadPath + "\t";
			logData += fileType + "\t";
			logData += fileSize;
			
			//makeLogData(fileFullUrl, logData);
		}
	}catch(IOException ioe){
		
		ioe.printStackTrace();
		//e.printStackTrace();
		//System.out.println(e);
		//System.out.println(uploadPath+"/"+fileName1);
		//System.out.println(uploadPath+"\\"+fileName1);
		
		//File delFile = new File(uploadPath+"\\"+fileName1);
		//delFile.delete();
	}
}
%>
<%!
public static void combineFile(String oriFileName, String reFileName, String nFilePath, String chunkFileSize, String chunkFileName, JsonObject object1, String fileSize) throws FileNotFoundException, IOException {
	FileInputStream input = null;
    FileOutputStream output = null;
    String fileReName = "";
	String fileReName2 = "";
	File file = null;
	File reFile = null;
	
	
    try{
        
		// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
		reFileName = cleanXSS(reFileName);
		
		// 복사할 대상 파일을 지정해준다.
        file = new File(nFilePath+"\\"+reFileName);
		//file.renameTo(new File(nFilePath+"\\"+reFileName + "_xfuChunked"));
         
        // FileInputStream 는 File object를 생성자 인수로 받을 수 있다.         
        input = new FileInputStream(file);
        // 복사된 파일의 위치를 지정해준다.
        int Idx = oriFileName.lastIndexOf(".");
        String fileExt =  oriFileName.substring(Idx+1);
		fileReName = oriFileName.substring(0, Idx) + "_" + chunkFileName + "." + fileExt + "_xfuChunked";
		fileReName2 = oriFileName.substring(0, Idx) + "_" + chunkFileName + "." + fileExt;
		
		// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
		fileReName = cleanXSS(fileReName);
		
		reFile = new File(nFilePath+"\\"+fileReName); 
		
        output = new FileOutputStream(reFile, true);
        
		int readBuffer = 0;
        byte [] buffer = new byte[9999];
        while((readBuffer = input.read(buffer)) != -1) {
            output.write(buffer, 0, readBuffer);			
        }
		
    } catch (IOException e) {
		
        //System.out.println(e);
		System.out.println("upload error");
		
		//File delFile = new File(nFilePath+"\\"+reFileName);
        //delFile.delete();
		
    } finally {
        try{
            //output.flush();
			
			// 생성된 InputStream Object를 닫아준다.
            input.close();
            // 생성된 OutputStream Object를 닫아준다.
            output.close();
			
			// SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
			reFileName = cleanXSS(reFileName);
            
            File delFile = new File(nFilePath+"\\"+reFileName);
			delFile.delete();
			
			if(Long.parseLong(fileSize) == reFile.length()){
				
				reFile.renameTo(new File(nFilePath+"\\"+fileReName2));
			}
			
			System.out.println(reFile.getName() + " 파일이 복사되었습니다. / " + Long.parseLong(fileSize) + " / " + reFile.length());
		
			//object1.addProperty("fileReName", fileReName);
			object1.addProperty("fileReName", fileReName2);
			
			
        } catch(IOException io) {
			
			//System.out.println(io);
			System.out.println("delete error");
			
			//File delFile = new File(nFilePath+"\\"+reFileName);
			//delFile.delete();
		}
    }
}

public static void encodeFileName(String oriFileName, String reFileName, String nFilePath, JsonObject object1) throws FileNotFoundException, IOException {
	FileInputStream input = null;
    FileOutputStream output = null;
    
    try{
        // 복사할 대상 파일을 지정해준다.
		byte[] targetBytes = reFileName.getBytes();
		Encoder encoder = Base64.getEncoder(); 
		byte[] encodedBytes = encoder.encode(targetBytes); 
		
		//byte[] encodedBytes = Base64.encodeBase64(targetBytes); 
		
		reFileName = new String(encodedBytes);
		
        File file = new File(nFilePath+"\\"+oriFileName);
         
        // FileInputStream 는 File object를 생성자 인수로 받을 수 있다.         
        input = new FileInputStream(file);
        // 복사된 파일의 위치를 지정해준다.
        int Idx = oriFileName.lastIndexOf(".");
        String fileExt =  oriFileName.substring(Idx+1);
		String fileReName = reFileName + "." + fileExt;
        output = new FileOutputStream(new File(nFilePath+"\\"+fileReName), true);
                     
        int readBuffer = 0;
        byte [] buffer = new byte[512];
        while((readBuffer = input.read(buffer)) != -1) {
            output.write(buffer, 0, readBuffer);
        }
        System.out.println("파일이 복사되었습니다.");
		
		object1.addProperty("fileReName", fileReName);
        
    } catch (IOException e) {
		//System.out.println(e);
		System.out.println("encode error");
    } finally {
        try{
            // 생성된 InputStream Object를 닫아준다.
            input.close();
            // 생성된 OutputStream Object를 닫아준다.
            output.close();
            
            File delFile = new File(nFilePath+"\\"+reFileName);
            delFile.delete();
            
        } catch(IOException io) {}
    }
}

public String usf_replace(String src, String oldstr, String newstr)
{
	if (src == null) return null;
	StringBuffer dest = new StringBuffer("");
	try
	{
		int  len = oldstr.length();
		int  srclen = src.length();
		int  pos = 0;
		int  oldpos = 0;

		while ((pos = src.indexOf(oldstr, oldpos)) >= 0)
		{
			dest.append(src.substring(oldpos, pos));
			dest.append(newstr);
			oldpos = pos + len;
		}

		if (oldpos < srclen)
			dest.append(src.substring(oldpos, srclen));
	}
	catch ( Exception e )
	{
		e.printStackTrace();
	}
	return dest.toString();
}

public boolean FileExists(String sPath) throws Exception
{
	File file = new File(sPath);
	if (file.exists())
		return true;
	else
		return false;
}

 /**
 * 파일의 확장자를 체크하여 필터링된 확장자를 포함한 파일인 경우에 true를 리턴한다.
 * @param extension
 * */
public static boolean checkWhiteList(String extension) {		 
	String ext = extension.substring(extension.lastIndexOf(".") + 1, extension.length());        
	final String[] WHITE_EXTENSION = { "jpg", "jpeg", "gif", "png", "mp4", "swf" }; 
	int len = WHITE_EXTENSION.length;        
	for (int i = 0; i < len; i++) {        	
		if (ext.equalsIgnoreCase(WHITE_EXTENSION[i])) {
			return true; 
		}
	}        
	return false;
}	 
public static String cleanXSS(String val) {			
	val = val.replaceAll("<", "&lt;").replaceAll(">", "&gt;");		  
	val = val.replaceAll("\\(", "&#40;").replaceAll("\\)", "&#41;");		  
	val = val.replaceAll("'", "&#39;");        		  
	val = val.replaceAll("eval\\((.*)\\)", ""); 		  
	val = val.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");		  
	val = val.replaceAll("script", "");
	val = val.replaceAll("\\.{2,}[/\\\\]", ""); 
	  
	return val;
}
private static boolean checkXSS(String sInput) {
	boolean bResult = false;
    if (sInput.indexOf("<") > -1 ||
        sInput.indexOf(">") > -1 ||
        sInput.indexOf("\\(") > -1 ||
        sInput.indexOf("\\)") > -1 ||
        sInput.indexOf("'") > -1 ||
        sInput.indexOf("eval\\((.*)\\)") > -1 ||
        sInput.indexOf("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']") > -1 ||
        sInput.indexOf("script") > -1) {
        bResult = true;
    }
    return bResult;
}
/**
 * Binary 파일 여부 체크
 * @param file
 * */
public static boolean isBinaryFile(File f) throws FileNotFoundException, IOException {
	
	FileInputStream in = new FileInputStream(f);
	
	int ascii = 0;
	int other = 0;
	
	try{
	
		int size = in.available();
		if(size > 1024) size = 1024;
		byte[] data = new byte[size];
		in.read(data);
		//in.close();

		for(int i = 0; i < data.length; i++) {
			byte b = data[i];
			if( b < 0x09 ) return true;

			if( b == 0x09 || b == 0x0A || b == 0x0C || b == 0x0D ) ascii++;
			else if( b >= 0x20  &&  b <= 0x7E ) ascii++;
			else other++;
		}
	} 
	catch(IOException ioe){
		//System.out.println("errMsg : " + ioe.getMessage());
		System.out.println("download error");
	}
	finally{
		in.close();
	}

	if( other == 0 ) return false;

	return 100 * other / (ascii + other) > 95;
}

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
		/*
		if (reader != null){
			reader.close();
		}
		bw.flush();
		if (bw != null){
			bw.close();
		}
		*/
	}
	catch(IOException ioe){
		System.out.println("Not read File");
	}
	finally{
		if (reader != null){
			reader.close();
		}
		bw.flush();
		if (bw != null){
			bw.close();
		}
	}
}
/*
// base64Encode
public static String base64Encode(String str)  throws java.io.IOException {
	if ( str == null || str.equals("") ) {
		return "";
	} else {
		sun.misc.BASE64Encoder encoder = new sun.misc.BASE64Encoder();
		byte[] b1 = str.getBytes();
		String result = encoder.encode(b1);
		return result;
	}
}
// base64Decode 
public static String base64Decode(String str)  throws java.io.IOException {
	if ( str == null || str.equals("") ) {
		return "";
	} else {
		sun.misc.BASE64Decoder decoder = new sun.misc.BASE64Decoder();
		byte[] b1 = decoder.decodeBuffer(str);
		String result = new String(b1);
		return result;
	}
}
*/
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

/**
 * 폴더가 비워져 있으면 삭제한다 (하위디렉토리까지 포함) 
 * @param file
 * @return 삭제된 폴더수 
 */
public static String deleteEmptyDir(File file) {

	if (!file.isDirectory()) {
		
		//return 0;'
		return "Delete EmptyFolder Count : 0";
	}
	
	String strPath = "";
	//int delCnt=0;
	
	for (File subFile : file.listFiles()) {
		
		if (subFile.isDirectory()) {
			
			//delCnt+=deleteEmptyDir(subFile);
			strPath += deleteEmptyDir(subFile) + "\n";
		}
	}
	
	if (file.listFiles().length==0) {
		
		//out.println(file.getAbsolutePath());
		strPath += file.getAbsolutePath() + "\n";
		
		file.delete();
		//delCnt++;
	}        
	//return delCnt;	
	return strPath;
}

%>