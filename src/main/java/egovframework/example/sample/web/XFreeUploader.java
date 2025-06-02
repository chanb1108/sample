package egovframework.example.sample.web;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Base64.Encoder;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

@Controller
public class XFreeUploader{
	
	protected Logger log = LoggerFactory.getLogger(getClass());

    String charsetName = "utf-8";
    private String FILE_TARGET_PATH = "//192.168.35.217/upload/file/";

    /**
     * 업로드 관련 컨트롤러 메소드
     * @param map : "키":"값" 형식을 받기 위해 사용할 Map 타입의 파라미터
     * @param request : getServletContext() 사용을 위한 파라미터
     * @param response : 기존 로직 response 처리를 위한 파라미터
     * @return : String 타입의 결과값 반환 (기존 out.println)
     */
    @ResponseBody
    @RequestMapping(value={"/xFreeUploader/tagfree/xfuUpload.do"})
    public void xfuUploadJsp(@RequestParam Map<String, Object> map, HttpServletRequest request, HttpServletResponse response) throws Exception {

        String result = "errorUpLoadResult"; // 분기처리 되지 않을 경우 에러값을 리턴

        request.setCharacterEncoding(charsetName);
        response.setCharacterEncoding(charsetName);
        response.setContentType("text/html;charset=" + charsetName);

        /* 분기처리를 위한 state 값
         * DELETE                       : 파일 삭제
         * FOLDERDELETE         : 빈폴더 삭제 (파일 삭제로 인하여 발생할 수 있는 날짜명의 빈폴더 삭제)
         * REUPLOADFILEINFO : 이어서 전송을 위한 파일정보 가져오기
         * UPLOAD                   : 파일 업로드
        */

        // 파라미터 통해서 데이터 Get
        String state = (String) map.get("state");

        // 파일삭제
        if(state.equals("DELETE")){
            String sfilePath = (String) map.get("filePath");
            String uploadPath = request.getServletContext().getRealPath("/");
            int upPos = uploadPath.lastIndexOf("\\");
            uploadPath = uploadPath.substring(0, upPos);


            // 삭제 파일경로 가져오기
            String sDelPath = (String) map.get("deleteUrl");
            if(sDelPath != null){

                // SW취약점 - 외부 입력 변수 값에 대하여 공격의 위험이 있는 문자( “ / ￦ .. 등 )를 제거할 수 있는 조작 방지 필터 처리
                File file = new File(cleanXSS(uploadPath + sDelPath));

                if( file.exists() ){
                    if(file.delete()){
                        //out.println("파일삭제 성공");
                        result = "파일삭제 성공";
                    }else{
                        //out.println("파일삭제 실패");
                        result = "파일삭제 실패";
                    }
                }else{
                    //out.println("파일이 존재하지 않습니다. : " + sDelPath);
                    result = "파일이 존재하지 않습니다. : " + sDelPath;
                }
            }
        }

        // 빈폴더 삭제
        else if(state.equals("FOLDERDELETE")){

            //String serverPath = getServletContext().getRealPath(request.getServletPath());
            String serverPath = request.getServletContext().getRealPath("/");
            int upPos = serverPath.lastIndexOf("\\");
            serverPath = serverPath.substring(0, upPos);

            String path = serverPath + (String) map.get("path");

            File emptyForders = new File(path);

            //out.println(deleteEmptyDir(emptyForders));
            result = deleteEmptyDir(emptyForders);
        }

        // 이어서 전송을 위한 파일정보 가져오기
        else if(state.equals("REUPLOADFILEINFO")){

            //String serverPath = getServletContext().getRealPath(request.getServletPath());
            String serverPath = request.getServletContext().getRealPath("/");
            int upPos = serverPath.lastIndexOf("\\");
            serverPath = serverPath.substring(0, upPos);

            // 요청받은 검색해야할 파일명
            String searchFileName = (String) map.get("fileName");

            String[] searchFileNameList = searchFileName.split("|");

            // docID
            String xfu_Doc_ID = (String) map.get("xfuDocID");
            String docID_folder = "";

            if(xfu_Doc_ID.equals("xfdocid_0000000000")){
                docID_folder = "xfdocid_0000000000/";
            } else {
                docID_folder = xfu_Doc_ID + "/";
            }

            // 요청받은 파일경로
            String searchFolder = serverPath + (String) map.get("searchUrl") + docID_folder;
            JsonArray arr = new JsonArray();
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
            //out.println(arr.toString());
            result = arr.toString();
        }

        // 업로드
        else if(state.equals("UPLOAD")){

            String sfilePath = (String) map.get("filePath");
            int mSize = Integer.parseInt((String) map.get("maxsize"));

            String nCount = (String) map.get("nCount");

            if(nCount==null){

                nCount = "1";
            }

            boolean isXSSTarget = false;

            // org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
            JsonObject object1 = new JsonObject();

            // 업로드 폴더 경로 : 날짜별로 폴더 생성
            String sDate = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());

            //String uploadPath = getServletContext().getRealPath(request.getServletPath());
//            String uploadPath = request.getServletContext().getRealPath("/");
            String uploadPath = FILE_TARGET_PATH;
//            int upPos = uploadPath.lastIndexOf("\\");
//            uploadPath = uploadPath.substring(0, upPos);

            String uploadPath2 = "";

            boolean absolutePathFlag = false;                               // 절대경로 여부
            if(sfilePath.indexOf("\\") > -1 || sfilePath.indexOf("//") > -1) {
                if(sfilePath.indexOf("\\") > -1) sfilePath = sfilePath.replace("\\", "/");
                absolutePathFlag = true;    // 예) C://Windows/System32/drivers/etc/hosts
            }

            // docID
            String xfu_Doc_ID = (String) map.get("xfuDocID");
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

            //MultipartRequest multi = null;
            MultipartFile multi  = null;

            MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest) request;
            if (request instanceof MultipartHttpServletRequest) {
                MultipartHttpServletRequest multipartRequest1 = (MultipartHttpServletRequest) request;
                for (String fileName : multipartRequest.getFileMap().keySet()) { // 반복문 형식으로 작성하였지만 요청 시 하나의 파일만 받아오는 것으로 확인
                    multi = multipartRequest.getFile(fileName);
                }
            }
            try {
                // cos(com.oreilly.servlet)의 MultipartRequest를 이용해서 업로드 !!!
                // request,파일저장경로,용량,인코딩타입,중복파일명에 대한 기본 정책
                //multi = new MultipartRequest(request, uploadPath, maxSize, encType, new DefaultFileRenamePolicy());

                // 기존에 쓰던 cos(com.oreilly.servlet) 활용이 되지 않아 파일 이름명에 UUID를 붙여 중복 제거(파일이름@@UUID.확장자)
                // 현재 서버에 파일 저장
                String guid = UUID.randomUUID().toString();
                String tmpOriFileName = multi.getOriginalFilename();
                String tmpExtension = getFileExtension(multi.getOriginalFilename());
                if (!"".equals(tmpExtension) && tmpExtension != null && !tmpExtension.isEmpty()) { // 확장자가 있을 경우
                    tmpExtension = "." + tmpExtension; // 확장자에 . 추가
                    tmpOriFileName = tmpOriFileName.substring(0, tmpOriFileName.lastIndexOf(tmpExtension)); // 확장자 제거된 파일이름
                }

                String reFileNameTmp = cleanXSS(tmpOriFileName) + "@@" + guid + tmpExtension;
                File dest = new File(uploadPath +  "/" + reFileNameTmp);
                FileCopyUtils.copy(multi.getBytes(), dest);

                // form내의 input name="name" 인 녀석 value를 가져옴
                //name = multi.getParameter("upl");

                // 전송한 전체 파일이름들을 가져옴
                //Enumeration<?> files = multi.getFileNames();
                Enumeration<?> files = Collections.enumeration(multipartRequest.getFileMap().keySet());

                while(files.hasMoreElements()){
                    if(nCount.equals("1") && nCount != null){
                        // form 태그에서 <input type="file" name="여기에 지정한 이름" />을 가져온다.
                        String file1 = (String)files.nextElement(); // 파일 input에 지정한 이름을 가져옴
                        MultipartFile file2  = multipartRequest.getFile(file1);

                        // 그에 해당하는 실재 파일 이름을 가져옴
                        //originalName1 = multi.getOriginalFileName(file1);
                        originalName1 = file2.getOriginalFilename();

                        // 파일명이 중복될 경우 중복 정책에 의해 뒤에 1,2,3 처럼 붙어 unique하게 파일명을 생성하는데
                        // 이때 생성된 이름을 filesystemName이라 하여 그 이름 정보를 가져온다.(중복에 대한 처리)
                        //fileName1 = multi.getFilesystemName(file1);
                        fileName1 = reFileNameTmp;

                        // 파일 타입 정보를 가져옴
                        //fileType = multi.getContentType(file1);
                        fileType = file2.getContentType();

                        // input file name에 해당하는 실재 파일을 가져옴
                        //File file = multi.getFile(file1);

                        // 그 파일 객체의 크기를 알아냄
                        //fileSize = file.length();
                        fileSize = file2.getSize();

                        // 해당 로직은 XSS공격에 대한 방어로직으로 업로드한 파일에 공격성 문자열이 존재시 업로드된 파일을 무조건 삭제처리하도록 구현된 로직입니다.
                        //if (!isBinaryFile(file)) {
                            //Scanner scan = new Scanner(file, charsetName);
                            Scanner scan = new Scanner(file2.getInputStream(), charsetName);
                            String fText = "";
                            while(scan.hasNextLine()){
                                fText = scan.nextLine();
                            }

                            if (!checkWhiteList(getFileExtension(originalName1))) { // 예외 확장자인 경우는 검사하지 않는다. (XSS 공격이 불가능한 확장자 파일)
                                if (checkXSS(fText))
                                {
                                    isXSSTarget = true;
                                    response.setStatus(405);
                                    result = "checkXSS 405 ERROR";
                                }
                                else
                                {
                                    isXSSTarget = false;
                                }
                            }
                            scan.close();
                        //}

                        // JSON 데이터 정보
                        //out.clear(); → JSP가 아니므로 필요없는 구문

                        // org.json.simple.JSONObject 객체를 이용시 아래 구문을 사용합니다.
                        //JsonObject object1=new JsonObject();
                        //object1.addProperty("isBinaryFile",isBinaryFile(file));
                        //object1.addProperty("fileName",file1);
                        object1.addProperty("fileName",originalName1);
                        //object1.addProperty("savePath",uploadPath);
                        object1.addProperty("savePath",uploadPath2);
                        //object1.addProperty("oriFileName",originalName1);
                        // 화면에 보여지는 파일명에 대해서 변경이 필요할 경우 둘중 하나를 사용
                        object1.addProperty("fileReName",fileName1); // UUID 포함된 파일명
                        //object1.addProperty("fileReName",originalName1); // 유저가 업로드한 파일명

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

                        //if(isXSSTarget)   file.delete();                 // 만약에 해당프로젝트에서 삭제 로직이 불필요하다면 해당 줄만 주석처리 하셔도 됩니다.

                        JsonArray jArray = new JsonArray();
                        jArray.add(object1);

                        //out.println(jArray.toString());
                        result = jArray.toString();
                        //out.println(base64Encode(jArray.toString()));
                        //out.flush(); → JSP가 아니므로 필요없는 구문
                    }
                    else{
                        // form 태그에서 <input type="file" name="여기에 지정한 이름" />을 가져온다.
                        String file1 = (String)files.nextElement(); // 파일 input에 지정한 이름을 가져옴
                        MultipartFile file2  = multipartRequest.getFile(file1);

                        // 그에 해당하는 실재 파일 이름을 가져옴
                        //originalName1 = multi.getOriginalFileName(file1);
                        originalName1 = file2.getOriginalFilename();

                        // 파일명이 중복될 경우 중복 정책에 의해 뒤에 1,2,3 처럼 붙어 unique하게 파일명을 생성하는데
                        // 이때 생성된 이름을 filesystemName이라 하여 그 이름 정보를 가져온다.(중복에 대한 처리)
                        //fileName1 = multi.getFilesystemName(file1);
                        fileName1 = file2.getName();

                        // 파일 타입 정보를 가져옴
                        //fileType = multi.getContentType(file1);
                        fileType = file2.getContentType();

                        // input file name에 해당하는 실재 파일을 가져옴
                        //File file = multi.getFile(file1);

                        // 그 파일 객체의 크기를 알아냄
                        //fileSize = file.length();
                        fileSize = file2.getSize();

                        combineFile(originalName1, fileName1, uploadPath,(String) map.get("chunkFileSize"),(String) map.get("chunkFileName"), object1,(String) map.get("fileSize"));

                        if(!files.hasMoreElements()){

                            String deleteFilePath = uploadPath+"/"+originalName1;
                            deleteFilePath = deleteFilePath.replace("/", "\\");

                            System.out.println("delete file : " + deleteFilePath);
                            File delFile = new File(deleteFilePath);
                            delFile.delete();
                        }

                        // JSON 데이터 정보
                        //out.clear(); → JSP가 아니므로 필요없는 구문

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
                        object1.addProperty("fileSize",(String)map.get("fileSize"));
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

                        //out.println(jArray.toString());
                        result = jArray.toString();

                        //out.println(base64Encode(jArray.toString()));
                        //out.flush(); → JSP가 아니므로 필요없는 구문
                    }


                    // 로그데이터 생성
                    Date logDate = new Date();
                    SimpleDateFormat simple = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

                    String fileName = "ulog.dat";
                    String fileFullUrl = request.getServletContext().getRealPath(request.getServletPath());
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


        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().write(result);

//        return result;
    }

    /**
     * 다운로드 관련 컨트롤러 메소드
     * @param map : "키":"값" 형식을 받기 위해 사용할 Map 타입의 파라미터
     * @param request : getServletContext() 사용을 위한 파라미터
     * @param response : 기존 로직 response 처리를 위한 파라미터
     * @return : String 타입의 결과값 반환 (기존 out.println)
     */
    @ResponseBody
    @RequestMapping({"/xFreeUploader/tagfree/xfuDownload.do"})
    public void xufDownloadJsp(@RequestParam Map<String, Object> map, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String result = "errorDownLoadResult"; // 분기처리 되지 않을 경우 에러값을 리턴

        System.out.println("@RequestParam Map<String, Object> map\n"+map);
        System.out.println("HttpServletRequest request\n"+request);
        System.out.println(" HttpServletResponse response\n"+response);
        request.setCharacterEncoding(charsetName);
        response.setCharacterEncoding(charsetName);
        response.setContentType("text/html;charset=" + charsetName);

        /* 분기처리를 위한 state 값
         * FILELIST         : 파일 조회
         * DOWNLOAD : 파일 다운로드
        */

        // 코드에서는 3가지 분기가 존재.
        /* 분기처리를 위한 state 값
         * FILELIST         : 파일 조회
         * REUPLOADFILEINFO : 이어서 다운을 위한 파일정보 가져오기?
         * DOWNLOAD : 파일 다운로드
        */

        String state = (String) map.get("state");

        if(state.equals("FILELIST")){

            boolean absolutePathFlag = false;                               // 절대경로 여부
            String sfilePath = (String) map.get("path");                // 서버경로
            String filterWord = (String) map.get("filterWord");         // 필터정보

            if(sfilePath.indexOf("\\") > -1 || sfilePath.indexOf("//") > -1) {
                absolutePathFlag = true;    // 예) C:\Windows\System32\drivers\etc\hosts
            }

            // 웹자원의 최상단 루트 경로 지정
            //String RootPath = getServletContext().getRealPath(request.getServletPath());
            String RootPath = request.getServletContext().getRealPath("/");
//            String RootPath = FILE_TARGET_PATH;
            int upPos = RootPath.lastIndexOf("\\");
            RootPath = RootPath.substring(0, upPos);

            String webPath = getBaseUrl(request);

            int pos = -1;
            if ((pos = RootPath.lastIndexOf("/")) > 0)
            {
                RootPath = RootPath + sfilePath;
                webPath = webPath + "/" + sfilePath;
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
            //out.println( tRootPath ) ;
            result = tRootPath;

        } else if(state.equals("REDOWNLOADFILEINFO")){

            //String serverPath = getServletContext().getRealPath(request.getServletPath());
            String serverPath = request.getServletContext().getRealPath("/");
//        	String serverPath = FILE_TARGET_PATH + "\\";

            int upPos = serverPath.lastIndexOf("\\");
            serverPath = serverPath.substring(0, upPos);

            // 요청받은 검색해야할 파일명
            String searchFileName = (String) (String) map.get("fileName");

            // docID
            String xfu_Doc_ID = (String) (String) map.get("xfuDocID");
            String docID_folder = "";

            if(xfu_Doc_ID.equals("xfdocid_0000000000")){

                docID_folder = "xfdocid_0000000000/";
            } else {

                docID_folder = xfu_Doc_ID + "/";
            }

            // 요청받은 파일경로
            log.debug("===========searchUrl : {}",(String) (String) map.get("searchUrl"));
            log.debug("===========map : {}", map);
            String searchFolder = serverPath + (String) (String) map.get("searchUrl") + docID_folder;
//            String searchFolder = "//" + serverPath + "20250530/" + docID_folder;
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
            //out.println(arr.toString());
            result = arr.toString();

        } else if(state.equals("DOWNLOAD")){

            // 파라미터 전달 받기
            String postData = (String) map.get("downList");
            postData = postData.replaceAll("&quot;", "\"");

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
//                    String sDownPath = request.getServletContext().getRealPath("/");
                    String sDownPath = FILE_TARGET_PATH;
//                    int upPos = sDownPath.lastIndexOf("\\");
//                    sDownPath = sDownPath.substring(0, upPos);
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
                        String sMimeType = request.getServletContext().getMimeType(sFilePath);

                        if(sMimeType == null){
                            //sMimeType = "application.octec-stream";
                            sMimeType = "application/x-msdownload";
                        }

                        //response.setContentType(sMimeType);
                        // response.setHeader("Content-Type", "application/octet-stream; charset=MS949");
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
                            result = "download complete";
                            return ;
                        } catch(IOException ioe){
                            //System.out.println("errMsg : " + ioe.getMessage());
                            System.out.println("single download error");
                            result = "single download error";
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
//                        String sDownPath = request.getServletContext().getRealPath("/");
                        String sDownPath = FILE_TARGET_PATH;
//                        int upPos = sDownPath.lastIndexOf("\\");
//                        sDownPath = sDownPath.substring(0, upPos);
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

//                    String strTargetFolder = request.getServletContext().getRealPath("/");
                    String strTargetFolder = FILE_TARGET_PATH;
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
                            int file_nm_pos = file_name.lastIndexOf("@@");
                            String file_ext = file_name.substring( file_pos + 1 );
                            String onlyFileName = file_name.substring(0, file_nm_pos);
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
                        System.out.println("multi download error");
                        result = "multi download error";
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

                        return ;
//                        result = "download complete";
                    } catch(IOException ioe) {
                        //System.out.println("errMsg : " + ioe.getMessage());
                        System.out.println("multi download error");
                        result = "multi download error";
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

        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().write(result);

//        return result;
    }

    // 그 외 메소드들 (업로드 관련)

    // 추가 : 파일 이름 받아서 확장자만 반환하는 메소드
    public String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf(".") == -1) {
            return ""; // 확장자가 없는 경우 빈 문자열 반환
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }

    public void combineFile(String oriFileName, String reFileName, String nFilePath, String chunkFileSize, String chunkFileName, JsonObject object1, String fileSize) throws FileNotFoundException, IOException {
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
        final String[] WHITE_EXTENSION = { "jpg", "jpeg", "gif", "png", "mp4", "swf", "hwp", "xlsx", "xls", "doc", "pdf"};
        int len = WHITE_EXTENSION.length;
        for (int i = 0; i < len; i++) {
            if (ext.equalsIgnoreCase(WHITE_EXTENSION[i])) {
                return true;
            }
        }
        return false;
    }
    public String cleanXSS(String val) {
        val = val.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
        val = val.replaceAll("\\(", "&#40;").replaceAll("\\)", "&#41;");
        val = val.replaceAll("'", "&#39;");
        val = val.replaceAll("eval\\((.*)\\)", "");
        val = val.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");
        val = val.replaceAll("script", "");
        val = val.replaceAll("\\.{2,}[/\\\\]", "");

        return val;
    }
    private boolean checkXSS(String sInput) {
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
    public boolean isBinaryFile(File f) throws FileNotFoundException, IOException {

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
    public String deleteEmptyDir(File file) {

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



    // 그 외 메소드들 (다운로드 관련)

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

    private String cleanXSSNewLine(String value) {

        value = value.replaceAll("[\\r\\n]", "");

        return value;
    }
    public String DirectoryBrowser ( String RootPath, String filterWord, String webPath )
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

    public String getBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme() + "://";
        String serverName = request.getServerName();
        String serverPort = (request.getServerPort() == 80) ? "" : ":" + request.getServerPort();
        String contextPath = request.getContextPath();
        return scheme + serverName + serverPort + contextPath;
    }
}
