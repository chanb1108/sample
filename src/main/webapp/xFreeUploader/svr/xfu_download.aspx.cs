using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Web;
using System.Net;
/*
using System.Net.Http;  
using System.Net.Http.Headers;  
using System.Web.Http; 
*/
using ICSharpCode.SharpZipLib.Zip;
using Newtonsoft.Json.Linq;
using System.Runtime.CompilerServices;


/* 분기처리를 위한 state 값
 * FILELIST			: 파일 조회
 * DOWNLOAD	: 파일 다운로드
*/

public partial class XfuDownload : System.Web.UI.Page 
{
	protected void Page_Load(object sender, EventArgs e)
    {
        string state = Request["state"];
			
		// 파일 조회
		if(state == "FILELIST"){
			
			try
            {
                string fileListPath = null;
                //파라미터 정보를 가져온다
                string sfilePath = Request["path"];
                string sfilterWord = Request["filterWord"];
                bool absolutePathFlag = false;

                // 파일경로가 여러건일때
                if (sfilePath.IndexOf("|") > -1)
                {
                    /*
					List<string> multiFileList = new List<string>();

                    string[] sfilePaths = sfilePath.Split('|');
                    foreach (string sfp in sfilePaths)
                    {
                        string strFilePath = sfp;

                        // 넘어온 path정보가 절대경로인지 상대경로인지 판단
                        if (strFilePath.IndexOf("\\") > -1 || strFilePath.IndexOf("//") > -1)
                        {
                            if (strFilePath.IndexOf("\\") > -1) strFilePath = strFilePath.Replace("\\", "//");
                            absolutePathFlag = true;    // 예) C://Windows/System32/drivers/etc/hosts
                        }

                        if (absolutePathFlag)
                        {
                            fileListPath = strFilePath;
                        }
                        else
                        {
                            //if (strFilePath.IndexOf("../") > -1) fileListPath = "../" + strFilePath;
                            //else fileListPath = ".." + strFilePath;
                            fileListPath = ".." + strFilePath;
                        }

                        string url = Server.MapPath(fileListPath);
                        //string[] filelist = Directory.GetFiles(url, "*", SearchOption.AllDirectories);

                        string[] searchPatterns = sfilterWord.Split('|');
                        List<string> filelist = new List<string>();

                        foreach (string sp in searchPatterns)
                        {
                            filelist.AddRange(Directory.GetFiles(url, sp, SearchOption.AllDirectories));
                        }

                        multiFileList.AddRange(filelist);
                    }
                    DataList1.DataSource = multiFileList;
                    DataList1.DataBind();
					*/
					
					string strFilelist = "";
					
                    string[] sfilePaths = sfilePath.Split('|');
                    foreach (string sfp in sfilePaths)
                    {
                        string strFilePath = sfp;

                        // 넘어온 path정보가 절대경로인지 상대경로인지 판단
                        if (strFilePath.IndexOf("\\") > -1 || strFilePath.IndexOf("//") > -1)
                        {
                            if (strFilePath.IndexOf("\\") > -1) strFilePath = strFilePath.Replace("\\", "//");
                            absolutePathFlag = true;    // 예) C://Windows/System32/drivers/etc/hosts
                        }

                        if (absolutePathFlag)
                        {
                            fileListPath = strFilePath;
                        }
                        else
                        {
                            //if (strFilePath.IndexOf("../") > -1) fileListPath = "../" + strFilePath;
                            //else fileListPath = ".." + strFilePath;
                            fileListPath = ".." + strFilePath;
                        }

                        
                        string[] searchPatterns = sfilterWord.Split('|');
                        
                        foreach (string sp in searchPatterns)
                        {
                            string url = Server.MapPath(fileListPath);
							string[] filelist = Directory.GetFiles(url, sp, SearchOption.AllDirectories);
							
							foreach (string File in filelist)
							{
							
								strFilelist += GetFileName(File) + "\r\n";
							}
                        }
                    }
					
                    Response.Write(strFilelist);					
                }
                // 파일경로가 한건일때
                else
                {

                    /*
					// 넘어온 path정보가 절대경로인지 상대경로인지 판단
                    if (sfilePath.IndexOf("\\") > -1 || sfilePath.IndexOf("//") > -1)
                    {
                        if (sfilePath.IndexOf("\\") > -1) sfilePath = sfilePath.Replace("\\", "//");
                        absolutePathFlag = true;    // 예) C://Windows/System32/drivers/etc/hosts
                    }

                    if (absolutePathFlag)
                    {
                        fileListPath = sfilePath;
                    }
                    else
                    {
                        //if (sfilePath.IndexOf("../") > -1) fileListPath = "../" + sfilePath;
                        //else fileListPath = ".." + sfilePath;
                        fileListPath = sfilePath;
                    }

                    string url = Server.MapPath(fileListPath);
                    //string[] filelist = Directory.GetFiles(url, "*", SearchOption.AllDirectories);

                    string[] searchPatterns = sfilterWord.Split('|');
                    List<string> filelist = new List<string>();

                    foreach (string sp in searchPatterns)
                    {
                        filelist.AddRange(Directory.GetFiles(url, sp, SearchOption.AllDirectories));
                    }
                    DataList1.DataSource = filelist;
                    DataList1.DataBind();
					*/
					
					// 넘어온 path정보가 절대경로인지 상대경로인지 판단
                    if (sfilePath.IndexOf("\\") > -1 || sfilePath.IndexOf("//") > -1)
                    {
                        if (sfilePath.IndexOf("\\") > -1) sfilePath = sfilePath.Replace("\\", "//");
                        absolutePathFlag = true;    // 예) C://Windows/System32/drivers/etc/hosts
                    }

                    if (absolutePathFlag)
                    {
                        fileListPath = sfilePath;
                    }
                    else
                    {
                        //if (sfilePath.IndexOf("../") > -1) fileListPath = "../" + sfilePath;
                        //else fileListPath = ".." + sfilePath;
                        fileListPath = sfilePath;
                    }

                    string url = Server.MapPath(fileListPath);
                    string[] filelist = Directory.GetFiles(url, "*", SearchOption.AllDirectories);
					string strFilelist = "";

					
					foreach(string File in filelist){
						
						strFilelist += GetFileName(File) + "\r\n";
					}
					
					Response.Write(strFilelist);
                }
            }
            catch
            {
                Response.Write("");
            }
		} 
		
		// 이어서 전송을 위한 _xfuChunked 파일여부 정보 가져오기
		else if(state == "REDOWNLOADFILEINFO"){
			
			// 요청받은 검색해야할 파일명
			string searchFileName = Request["fileName"];
			
			// docID
			string xfu_Doc_ID = Request["xfuDocID"];
			string docID_folder = "";
			
			if(xfu_Doc_ID == "xfdocid_0000000000"){
				
				docID_folder = "xfdocid_0000000000";
			} else {
				
				docID_folder = xfu_Doc_ID;
			}
			
			// 요청받은 파일경로
			string searchFolder = Request["searchUrl"] + docID_folder;
			
			DirectoryInfo di = new DirectoryInfo(@Server.MapPath(searchFolder));			
			JArray arr = new JArray();
			
			if(di.Exists){
			
				foreach (System.IO.FileInfo File in di.GetFiles())
				{
					
					// 찾을 파일이름에 "_xfuChunked" 가 들어있는 파일명이 나올때까지 찾기
					if(File.Name.IndexOf(searchFileName) > -1 && File.Extension.IndexOf("_xfuDownload") > -1){
						
						// 파일원본명
						string fileOriName = searchFileName;
						
						// 파일경로
						string fileServerPath = File.FullName;
						
						// rename처리된 파일명
						string fileReName = File.Name;
						
						// 파일확장자명
						string fileExt = File.Extension.Replace(".", "");
						
						string noExtFileName = fileReName.Replace("." + fileExt, "");
						
						// 파일크기
						long fileSize = File.Length;
						
						JObject fileObj = new JObject();
						fileObj.Add("fileName", fileOriName);
						fileObj.Add("savePath", fileServerPath);
						//fileObj.Add("fileReName", fileReName);
						fileObj.Add("fileReName", noExtFileName);
						fileObj.Add("fileType", fileExt);
						fileObj.Add("fileSize", fileSize);
						
						arr.Add(fileObj);
					}
				}
			}
			
			Response.Write(arr);
		} 
		
		// 파일 다운로드
		else if(state == "DOWNLOAD"){
			
			try
			{
				bool absolutePathFlag = false;
				var downloadFiles = Request["downList"];
				
				// 쿠키값 세팅
				//Response.Cookies.Set("fileDownload=true; path=/");
				HttpCookie Cookie = new HttpCookie("fileDownload", "true");
				HttpCookie Cookie2 = new HttpCookie("path", "/");
				
				Response.Cookies.Add(Cookie);
				Response.Cookies.Add(Cookie2);
				
				//var serializer = new JavaScriptSerializer();
				//var listDownloadFiles = serializer.Deserialize<List<DownloadList>>(downloadFiles);

				JArray arr = JArray.Parse(downloadFiles);

				string sFileName = arr[0]["fname"].ToString();
				string sDownFilePath = arr[0]["savePath"].ToString();

				if (sDownFilePath.IndexOf("\\") > -1 || sDownFilePath.IndexOf("//") > -1 || sDownFilePath.IndexOf(":/") > -1)
				{
					if (sDownFilePath.IndexOf("\\") > -1) sDownFilePath.Replace("\\", "//");
					absolutePathFlag = true;
				}

				//if (!absolutePathFlag) sDownFilePath = ".." + sDownFilePath;
				
				if (arr.Count == 1)
				{
					if (sDownFilePath != "")
					{
						string path = Server.MapPath("~" + sDownFilePath + "/" + Server.UrlDecode(sFileName));
						//byte[] bts = System.IO.File.ReadAllBytes(path);
						System.IO.FileInfo dFile = new FileInfo(path);
						string UTF8EncodingFileName = HttpUtility.UrlEncode(sFileName, new UTF8Encoding()).Replace("+", "%20");

						if (System.IO.File.Exists(path))
						{
							Response.Clear();

							if (Request.Browser.Browser.ToLower().Contains("internetexplorer"))
							{
								Response.AddHeader("Content-Disposition", "attachment; filename=" + UTF8EncodingFileName.Replace("_xfuDownload", "")); // IE 브라우저
							}
							else
							{
								Response.AddHeader("Content-Disposition", "attachment; filename=" + sFileName.Replace("_xfuDownload", ""));   // 기타 브라우저
								//Response.AddHeader("Content-Disposition", "attachment; filename=" + Server.UrlEncode(sFileName).Replace("+", "%20"));   // 기타 브라우저
							}

							Response.AddHeader("Content-Type", "Application/octet-stream");
							Response.AddHeader("Content-Length", dFile.Length.ToString());

							//Response.BinaryWrite(bts);
							Response.TransmitFile(path);
							Response.Flush();
							//Response.End();
							
							// 다운로드 정상적으로 받은 파일명에 _xfuDownload 가 존재하면 서버상에서 삭제처리
							if(sFileName.IndexOf("download_") > -1 && sFileName.IndexOf(".zip_xfuDownload") > -1){
						
								System.IO.File.Delete(path);
							}
							
						}
						else
						{
							//Response.Write("This file does not exist. (" + sDownFilePath + "/" + sFileName + ")");
							Response.Write("This file does not exist. (" + path + ")");
						}
					}
					else
					{
						Response.Write("Please provide a file to download.");
					}

				}
				else
				{
					// 선택1) 압축파일명 표현(난수)
					//string tmpZipPath = Server.MapPath("../" + arr[0]["savePath"].ToString() + "/" + Guid.NewGuid().ToString() + ".zip");

					// 선택2) 압축파일명 표현(DateTime형식)
					DateTime dtNow = DateTime.Now;
					string strDate = dtNow.Year.ToString();
					strDate += (dtNow.Month.ToString().Length == 1) ? "0" + dtNow.Month.ToString() : dtNow.Month.ToString();
					strDate += (dtNow.Day.ToString().Length == 1) ? "0" + dtNow.Day.ToString() : dtNow.Day.ToString();

					string strTime = (dtNow.Hour.ToString().Length == 1) ? "0" + dtNow.Hour.ToString() : dtNow.Hour.ToString();
					strTime += (dtNow.Minute.ToString().Length == 1) ? "0" + dtNow.Minute.ToString() : dtNow.Minute.ToString();
					strTime += (dtNow.Second.ToString().Length == 1) ? "0" + dtNow.Second.ToString() : dtNow.Second.ToString();

					string strDateTime = strDate + strTime;

					string tmpZipPath = Server.MapPath("~" + sDownFilePath + "/download_" + strDateTime + ".zip_xfuDownload");

					ZipFile z = ZipFile.Create(tmpZipPath);
					z.BeginUpdate();
					
					int file_idx = 0;
					
					foreach (JObject obj in arr)
					{
						file_idx++;
						
						string sDownFile_path = obj["savePath"].ToString();
						string file_name = obj["fname"].ToString();
						file_name = Server.UrlDecode(file_name);
						
						int file_pos = file_name.LastIndexOf( "." );
						string file_ext = file_name.Substring( file_pos + 1 );
						string onlyFileName = file_name.Substring(0, file_pos);
						string file_rename = onlyFileName + "_" + file_idx + "." + file_ext;
						
						string fullFilePath = Server.MapPath("~" + sDownFile_path + "/" + file_name);
						//string fullReFilePath = Server.MapPath("~" + sDownFile_path + "/" + file_rename);
						
						if (System.IO.File.Exists(fullFilePath))
						{
							/*
							using (File.Create(fullFilePath))
							{
								
								
								//z.Add(fullFilePath, obj["fname"].ToString());
								z.Add(fullFilePath, file_rename);
							}
							*/
							
							FileStream fi = new FileStream(fullFilePath, FileMode.Open);
							fi.Close();
							
							z.Add(fullFilePath, file_rename);
						}
					}

					z.CommitUpdate();
					z.Close();
					z = null;

					System.IO.FileInfo ziFile = new FileInfo(tmpZipPath);

					if (System.IO.File.Exists(tmpZipPath))
					{
						Response.Clear();
						
						string _zipFileName = ziFile.Name.Replace("_xfuDownload", "");

						if (Request.Browser.Browser.ToLower().Contains("internetexplorer"))
						{
							Response.AddHeader("Content-Disposition", "attachment; filename=" + HttpUtility.UrlEncode(_zipFileName).Replace("+", "%20")); // IE 브라우저
						}
						else
						{
							Response.AppendHeader("content-disposition", "attachment; filename=\"" + _zipFileName + "\"");   // 나머진 브라우저렇게 한다.
						}
						Response.AddHeader("Content-Length", ziFile.Length.ToString());
						Response.ContentType = "application/octet-stream";
						//Response.ContentType = "application/zip";
						//Response.WriteFile(tmpZipPath);
						Response.TransmitFile(tmpZipPath);
						Response.Flush();

						System.IO.File.Delete(tmpZipPath);
					}
					
					/*
					makeZipFile(tmpZipPath, sDownFile_path, Server, arr);
					zipDownload(tmpZipPath, Response, Request);
					Response.Write(tmpZipPath);
					*/
				}
			}
			catch (Exception xe) {
				Response.ContentType = "text/plain";
				Response.Write("Download-Fail]:" + xe.Message);
				var script = "<script type='text/javascript'>alert('Download - Fail]:" + xe.Message + "');history.back();</script>";
				Response.Write(script);
				Response.End();
			}
		}
    }

    [MethodImpl(MethodImplOptions.Synchronized)]
    public void makeZipFile(string tmpZipPath, string sDownFilePath, HttpServerUtility Server, JArray arr) {
        ZipFile z = ZipFile.Create(tmpZipPath);
        z.BeginUpdate();

        foreach (JObject obj in arr)
        {
            string fullFilePath = Server.MapPath("~" + sDownFilePath + "/" + obj["fname"].ToString());
            if (System.IO.File.Exists(fullFilePath))
            {
                z.Add(fullFilePath, obj["fname"].ToString());
            }
        }
        z.CommitUpdate();
        z.Close();
        z = null;        
    }

    public static void zipDownload(string tmpZipPath, HttpResponse Response, HttpRequest Request) {
        try
        {
            System.IO.FileInfo ziFile = new FileInfo(tmpZipPath);

            if (System.IO.File.Exists(tmpZipPath))
            {
                Response.Clear();

                if (Request.Browser.Browser.ToLower().Contains("internetexplorer"))
                {
                    Response.AddHeader("Content-Disposition", "attachment; filename=" + HttpUtility.UrlEncode(ziFile.Name).Replace("+", "%20")); // IE 브라우저
                }
                else
                {
                    Response.AppendHeader("content-disposition", "attachment; filename=\"" + ziFile.Name + "\"");   // 나머진 브라우저렇게 한다.
                }
                //Response.AddHeader("Content-Length", ziFile.Length.ToString());
                //Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Type", "Application/octet-stream");
                Response.AddHeader("Content-Length", ziFile.Length.ToString());

                //Response.WriteFile(tmpZipPath);
                Response.TransmitFile(tmpZipPath);
                Response.Flush();
            }
            else
            {
                Response.Write("This file does not exist. (" + tmpZipPath + ")");
            }
        }
        catch (Exception xe)
        {
            Response.ContentType = "text/plain";
            Response.Write("Download-Fail]:" + xe.Message);
            var script = "<script type='text/javascript'>alert('Download - Fail]:" + xe.Message + "');history.back();</script>";
            Response.Write(script);
            Response.End();
        }
        finally
        {
            System.IO.File.Delete(tmpZipPath);
        }
    }
        
    /// <summary>
    /// 특정 폴더를 ZIP으로 압축
    /// </summary>
    /// <param name="targetFolderPath">압축 대상 폴더 경로</param>
    /// <param name="zipFilePath">저장할 ZIP 파일 경로</param>
    /// <param name="password">압축 암호</param>
    /// <param name="isDeleteFolder">폴더 삭제 여부</param>
    /// <returns>압축 성공 여부</returns>
    public static bool ZipFiles(string targetFolderPath, string zipFilePath, string password, bool isDeleteFolder)
    {
        bool retVal = false;
        // 폴더가 존재하는 경우에만 수행.
        if (Directory.Exists(targetFolderPath))
        {
            // 압축 대상 폴더의 파일 목록.
            ArrayList ar = GenerateFileList(targetFolderPath);
            // 압축 대상 폴더 경로의 길이 + 1
            int TrimLength = (Directory.GetParent(targetFolderPath)).ToString().Length + 1;
            // find number of chars to remove. from orginal file path. remove '\'
            FileStream ostream;
            byte[] obuffer;
            string outPath = zipFilePath;
            // ZIP 스트림 생성.
            ZipOutputStream oZipStream = new ZipOutputStream(File.Create(outPath));

            try
            {
                // 패스워드가 있는 경우 패스워드 지정.
                if (password != null && password != String.Empty)
                    oZipStream.Password = password;
                oZipStream.SetLevel(9); // 암호화 레벨.(최대 압축)
                ZipEntry oZipEntry;
                foreach (string Fil in ar)
                {
                    oZipEntry = new ZipEntry(Fil.Remove(0, TrimLength));
                    oZipStream.PutNextEntry(oZipEntry);
                    // 파일인 경우.
                    if (!Fil.EndsWith(@"/"))
                    {
                        ostream = File.OpenRead(Fil);
                        obuffer = new byte[ostream.Length];
                        ostream.Read(obuffer, 0, obuffer.Length);
                        oZipStream.Write(obuffer, 0, obuffer.Length);
                    }
                }
                retVal = true;
            }
            catch
            {
                retVal = false;

                // 오류가 난 경우 생성 했던 파일을 삭제.
                if (File.Exists(outPath))
                    File.Delete(outPath);
            }
            finally
            {
                // 압축 종료.
                oZipStream.Finish();
                oZipStream.Close();
            }
            // 폴더 삭제를 원할 경우 폴더 삭제.
            if (isDeleteFolder)
                try
                {
                    Directory.Delete(targetFolderPath, true);
                }
                catch { }
        }
        return retVal;
    }
   

    /// <summary>
    /// 파일, 폴더 목록 생성
    /// </summary>
    /// <param name="Dir">폴더 경로</param>
    /// <returns>폴더, 파일 목록(ArrayList)</returns>
    private static ArrayList GenerateFileList(string Dir)
    {
        ArrayList fils = new ArrayList();
        bool Empty = true;
        // 폴더 내의 파일 추가.
        foreach (string file in Directory.GetFiles(Dir))
        {
            fils.Add(file);
            Empty = false;
        }
        if (Empty)
        {
            // 파일이 없고, 폴더도 없는 경우 자신의 폴더 추가.
            if (Directory.GetDirectories(Dir).Length == 0)
                fils.Add(Dir + @"/");
        }
        // 폴더 내 폴더 목록.
        foreach (string dirs in Directory.GetDirectories(Dir))
        {
            // 해당 폴더로 다시 GenerateFileList 재귀 호출
            foreach (object obj in GenerateFileList(dirs))
            {
                // 해당 폴더 내의 파일, 폴더 추가.
                fils.Add(obj);
            }
        }
        return fils;
    }
    /// <summary>
    /// 압축 파일 풀기
    /// </summary>
    /// <param name="zipFilePath">ZIP파일 경로</param>
    /// <param name="unZipTargetFolderPath">압축 풀 폴더 경로</param>
    /// <param name="password">해지 암호</param>
    /// <param name="isDeleteZipFile">zip파일 삭제 여부</param>
    /// <returns>압축 풀기 성공 여부 </returns>
    public static bool UnZipFiles(string zipFilePath, string unZipTargetFolderPath, string password, bool isDeleteZipFile)
    {
        bool retVal = false;
        // ZIP 파일이 있는 경우만 수행.
        if (File.Exists(zipFilePath))
        {
            // ZIP 스트림 생성.
            ZipInputStream zipInputStream = new ZipInputStream(File.OpenRead(zipFilePath));
            // 패스워드가 있는 경우 패스워드 지정.
            if (password != null && password != String.Empty)
                zipInputStream.Password = password;

            try
            {
                ZipEntry theEntry;
                // 반복하며 파일을 가져옴.
                while ((theEntry = zipInputStream.GetNextEntry()) != null)
                {
                    // 폴더
                    string directoryName = Path.GetDirectoryName(theEntry.Name);
                    string fileName = Path.GetFileName(theEntry.Name); // 파일
                                                                       // 폴더 생성
                    Directory.CreateDirectory(unZipTargetFolderPath + directoryName);

                    // 파일 이름이 있는 경우
                    if (fileName != String.Empty)
                    {
                        // 파일 스트림 생성.(파일생성)
                        FileStream streamWriter =
                              File.Create((unZipTargetFolderPath + theEntry.Name));

                        int size = 2048;
                        byte[] data = new byte[2048];

                        // 파일 복사
                        while (true)
                        {
                            size = zipInputStream.Read(data, 0, data.Length);

                            if (size > 0)
                                streamWriter.Write(data, 0, size);
                            else
                                break;
                        }

                        // 파일스트림 종료
                        streamWriter.Close();
                    }
                }
                retVal = true;
            }
            catch
            {
                retVal = false;
            }
            finally
            {
                // ZIP 파일 스트림 종료
                zipInputStream.Close();
            }

            // ZIP파일 삭제를 원할 경우 파일 삭제.
            if (isDeleteZipFile)
                try
                {
                    File.Delete(zipFilePath);
                }
                catch { }
        }

        return retVal;
    }
    /*
    [Serializable]
    public class DownloadList {
        public string fname { get; set; }
        public string savePath { get; set; }
    }
    */
	
	public string GetFileName(string fullFileName)
	{
		// 파일명
		string fileName = Path.GetFileName(fullFileName);
		
		// 파일날짜
		string fileDate = File.GetLastWriteTime(fullFileName).ToString("yyyy-MM-dd HH:mm:ss");
		
		// 파일경로(웹경로로 변경처리)
		string rootPath = Server.MapPath("~");		
		string absolutePath = Path.GetDirectoryName(fullFileName).Replace(rootPath, "");
		absolutePath = absolutePath.Replace("\\", "/");				
		string filePath = Request.Url.Scheme + "://" + Request.Url.Host + ":" + Request.Url.Port + "/" + absolutePath;
		
		// 파일확장자
		string fileExt = Path.GetExtension(fullFileName).Replace(".", "");
		
		// 파일크기
		long fileSize = new FileInfo(fullFileName).Length;

		return fileName + "\t" + fileDate + "\t" + filePath + "\t" + fileExt + "\t" + fileSize;
	}
}