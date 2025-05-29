using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text.RegularExpressions;
using Newtonsoft.Json.Linq;

/*
using System.Drawing;
using System.Drawing.Imaging;
*/


/* 분기처리를 위한 state 값
 * DELETE						: 파일 삭제
 * FOLDERDELETE			: 빈폴더 삭제 (파일 삭제로 인하여 발생할 수 있는 날짜명의 빈폴더 삭제)
 * REUPLOADFILEINFO	: 이어서 전송을 위한 파일정보 가져오기
 * UPLOAD					: 파일 업로드
*/

public partial class xfu_upload : System.Web.UI.Page
{
	protected void Page_Load(object sender, EventArgs e)
	{
		
		string state = Request["state"];
		
		// 파일삭제
		if(state == "DELETE"){
			
			bool SuccessfullyDeleted = true;
			try
			{
				string sDelPath = Request["deleteUrl"].ToString();

				if(sDelPath.IndexOf("\\") > -1 || sDelPath.IndexOf("//") > -1) {
					
					if(sDelPath.IndexOf("\\") > -1) {
						
						sDelPath = sDelPath.Replace("\\", "//");
					}
				}
				/*
				if (sDelPath.IndexOf("../") > -1) sDelPath = "../" + sDelPath;
				else sDelPath = ".." + sDelPath;
				*/
				File.Delete(Server.MapPath(sDelPath));
			}
			catch
			{
				SuccessfullyDeleted = false;
			}
			
			Response.Write(String.Format("{{\"{0}\":{1}}}", Request["deleteUrl"].ToString(), SuccessfullyDeleted.ToString().ToLower()));
		} 
		
		// 빈폴더 삭제
		else if(state == "FOLDERDELETE"){
			
			DeleteEmptyDirectory(Server.MapPath(Request["path"]));
			
			HttpContext.Current.Response.Write("Delete Empty Folers Complete!!");
		} 
		
		// 이어서 전송을 위한 파일정보 가져오기
		else if(state == "REUPLOADFILEINFO"){
			
			// 요청받은 검색해야할 파일명
			string searchFileName = Request["fileName"];
			
			string[] searchFileNameList = searchFileName.Split(new[]{"|"},StringSplitOptions.None);
			
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
					//if(File.Name.IndexOf(searchFileName) > -1 && File.Extension.IndexOf("_xfuChunked") > -1){
					//if(File.Extension.IndexOf("_xfuChunked") > -1){	
					
					for(int i=0; i<searchFileNameList.Length; i++){
						
						int dot = searchFileNameList[i].LastIndexOf(".");
						
						if(dot > -1){
						
							if(File.Name.IndexOf(searchFileNameList[i].Substring(0, dot)) > -1 && File.Extension.IndexOf("_xfuChunked") > -1){
								
								// 파일원본명
								string fileOriName = searchFileName;
								
								// 파일경로
								string fileServerPath = File.FullName;
								
								// rename처리된 파일명
								string fileReName = File.Name;
								
								string[] fileOriNames = fileReName.Split(new[]{"_"},StringSplitOptions.None);
								fileOriName = fileOriNames[0];
								
								
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
				}
			}
			
			Response.Write(arr);
		} 
		
		// 업로드
		else if(state == "UPLOAD"){
			
			Response.Charset = "utf-8";
			Response.ContentEncoding = System.Text.Encoding.GetEncoding("utf-8");

			string sDate = DateTime.Today.ToString("yyyyMMdd");
			bool absolutePathFlag = false;
			string sfilePath = Request.Form["filePath"].ToString();
			
			// docID
			string xfu_Doc_ID = Request["xfuDocID"];
			string docID_folder = "";
			
			if(xfu_Doc_ID == "xfdocid_0000000000"){
				
				docID_folder = "xfdocid_0000000000";
			} else {
				
				docID_folder = xfu_Doc_ID;
			}
			
			if(sfilePath.IndexOf("\\") > -1 || sfilePath.IndexOf("//") > -1) {
				if(sfilePath.IndexOf("\\") > -1) sfilePath = sfilePath.Replace("\\", "//");
				absolutePathFlag = true;    // 예) C://Windows/System32/drivers/etc/hosts
			}

			if(absolutePathFlag) {
				FILES_PATH = sfilePath + "/" + sDate + "/" + docID_folder;
			}
			else{
				//if(sfilePath.IndexOf("../") > -1) FILES_PATH = "../" + sfilePath + "/" + sDate;
				//else FILES_PATH = ".." + sfilePath + "/" + sDate;
				FILES_PATH = sfilePath + "/" + sDate + "/" + docID_folder;
			}

			string FilesPath;
			switch (FILES_DISPOSITION)
			{
				case FilesDisposition.ServerRoot:
					FilesPath = Server.MapPath(FILES_PATH);
					break;
				case FilesDisposition.HandlerRoot:
					FilesPath = Server.MapPath(Path.GetDirectoryName(Request.CurrentExecutionFilePath) + FILES_PATH);
					break;
				case FilesDisposition.Absolute:
					FilesPath = FILES_PATH;
					break;
				default:
					Response.StatusCode = 500;
					Response.StatusDescription = "Configuration error (FILES_DISPOSITION)";
					return;
			}
			// prepare directory
			if (!Directory.Exists(FilesPath))
			{
				Directory.CreateDirectory(FilesPath);
			}

			string QueryFileName = Request[FILE_QUERY_VAR];
			string FullFileName = null;
			string ShortFileName = null;
			//if (!String.IsNullOrEmpty(QueryFileName))
			if (QueryFileName != null) // param specified, but maybe in wrong format (empty). else user will download json with listed files
			{
				ShortFileName = HttpUtility.UrlDecode(QueryFileName);
				FullFileName = String.Format(@"{0}\{1}", FilesPath, ShortFileName);
				if (QueryFileName.Trim().Length == 0 || !File.Exists(FullFileName))
				{
					Response.StatusCode = 404;
					Response.StatusDescription = "File not found";
					Response.End();
					return;
				}
			}

			if (Request.HttpMethod.ToUpper() == HttpMethods.GET)
			{
				if (FullFileName != null)
				{
					Response.ContentType = FILE_GET_CONTENT_TYPE;
					Response.AddHeader("Content-Disposition", String.Format("attachment; filename={0}{1}", Path.GetFileNameWithoutExtension(ShortFileName), Path.GetExtension(ShortFileName).ToUpper()));
					using (FileStream FileReader = new FileStream(FullFileName, FileMode.Open, FileAccess.Read))
					{
						FromStreamToStream(FileReader, Response.OutputStream);

						Response.OutputStream.Close();
					}
					Response.End();
					return;
				}
				else
				{
					List<FileResponse> FileResponseList = new List<FileResponse>();
					string[] FileNames = Directory.GetFiles(FilesPath);
					foreach (string FileName in FileNames)
					{
						FileResponseList.Add(CreateFileResponse(FileName, FileName, new FileInfo(FileName).Length.ToString(), String.Empty));
					}
					SerializeUploaderResponse(FileResponseList);
				}
			}
			else if (Request.HttpMethod.ToUpper() == HttpMethods.POST)
			{
				// 파일 업로드 처리
				List<FileResponse> FileResponseList = new List<FileResponse>();

				//for (int FileIndex = 0; FileIndex < Request.Files.Count; FileIndex++) {
					/*
					HttpPostedFile File = Request.Files[FileIndex];
					string FileName = String.Format(@"{0}\{1}", FilesPath, Path.GetFileName(File.FileName));
					string ErrorMessage = String.Empty;

					for (int Attempts = 0; Attempts < ATTEMPTS_TO_WRITE; Attempts++)
					{
						ErrorMessage = String.Empty;
						if (System.IO.File.Exists(FileName))
						{
							FileName = String.Format(@"{0}\{1}_{2:yyyyMMddHHmmssfff}{3}", FilesPath, Path.GetFileNameWithoutExtension(FileName), DateTime.Now, Path.GetExtension(FileName));
						}

						try
						{
							using (Stream FileStreamWriter = new FileStream(FileName, FileMode.CreateNew, FileAccess.Write))
							{
								FromStreamToStream(File.InputStream, FileStreamWriter);
							}
						}
						catch (Exception exception)
						{
							ErrorMessage = exception.Message;
							System.Threading.Thread.Sleep(ATTEMPT_WAIT);
							continue;
						}

						break;
					}
					*/

					//HttpPostedFile File = Request.Files[FileIndex];
						HttpPostedFile File = Request.Files[0];
						System.IO.Stream MyStream;
						string FileName = String.Format(@"{0}\{1}", FilesPath, Path.GetFileName(cleanXSS(File.FileName)));
						string ErrorMessage = String.Empty;

						int BufferSize = File.InputStream.Length >= BUFFER_SIZE ? BUFFER_SIZE : (int)File.InputStream.Length;
						byte[] input = new byte[BufferSize];
						System.IO.FileStream fs = null;
					
					try
					{
						

						MyStream = File.InputStream;
						MyStream.Read(input, 0, BufferSize);
						

						if (Request["nCount"].ToString() == "1") {
							if (System.IO.File.Exists(FileName)) {
								//System.IO.File.Delete(FileName);
								FileName = String.Format(@"{0}\{1}_{2:yyyyMMddHHmmssfff}{3}", FilesPath, Path.GetFileNameWithoutExtension(FileName), DateTime.Now, Path.GetExtension(FileName));
							}
							fs = System.IO.File.Create(FileName);
						} else {
							FileName = String.Format(@"{0}\{1}_{2:yyyyMMddHHmmssfff}{3}", FilesPath, Path.GetFileNameWithoutExtension(FileName), Request["chunkFileName"].ToString(), Path.GetExtension(FileName) + "_xfuChunked");

							fs = System.IO.File.Open(FileName, FileMode.Append, FileAccess.Write);
						}
						
						fs.Write(input, 0, BufferSize);
						fs.Close();
					}
					catch (Exception)
					{
						Console.WriteLine("Error reading");
					}

					// 해당 로직은 XSS공격에 대한 방어로직으로 업로드한 파일에 공격성 문자열이 존재시 업로드된 파일을 무조건 삭제처리하도록 구현된 로직입니다.
					if (!isBinary(FileName)) {
						string fText = System.IO.File.ReadAllText(FileName, Encoding.Default);
						if (checkXSS(fText))
						{
							System.IO.File.Delete(FileName);    // 만약에 해당프로젝트에서 삭제 로직이 불필요하다면 해당 줄만 주석처리 하셔도 됩니다.
							isXSSTarget = true;

							// 아래부분은 XSS공격 파일이 발견될시 에러코드와 메시지를 표현하게 합니다.
							Response.StatusCode = 405;
							Response.StatusDescription = "Defend XSS";
							Response.End();
							return;
						}
						else
						{
							isXSSTarget = false;
						}
					}

					// 응답데이터 반환
					JObject fileObj = new JObject();
					
					if (Request["nCount"].ToString() == "1") {
						
						//FileResponseList.Add(CreateFileResponse(File.FileName, FileName, File.ContentLength.ToString(), ErrorMessage));
						
						fileObj.Add("fileName", File.FileName);
						fileObj.Add("savePath", Request["filePath"].ToString() + "/" + DateTime.Today.ToString("yyyyMMdd") + "/" + Request["xfuDocID"].ToString());
						fileObj.Add("fileReName", Path.GetFileName(FileName));
						fileObj.Add("fileType",  Path.GetExtension(File.FileName).Replace(".", ""));
						fileObj.Add("fileSize", Convert.ToInt64(File.ContentLength.ToString()));
						fileObj.Add("isXSSTargetFile", isXSSTarget);
						
						
					} else {
						
						//FileResponseList.Add(CreateFileResponse(File.FileName, FileName, Request["chunkFileSize"], ErrorMessage));
						
						if(Convert.ToInt64(Request["fileSize"]) == new FileInfo(FileName).Length){
				
							if (System.IO.File.Exists(FileName)) {
							
								string _ext = Path.GetExtension(FileName).Replace("_xfuChunked", "");
								
								string _FileName = FileName;
								string reFileName = String.Format(@"{0}\{1}{2}", FilesPath, Path.GetFileNameWithoutExtension(FileName), _ext);
								
								FileInfo fFile = new FileInfo(_FileName);
								fFile.CopyTo(reFileName, true);
								
								FileInfo freNameFile = new FileInfo(reFileName);
								freNameFile.MoveTo(reFileName);
								
								if(freNameFile.Exists) { 
								
									freNameFile.MoveTo(reFileName); //이미있으면 에러
								}

								if(fFile.Exists) {
									
									fFile.Delete();
									
									fileObj.Add("fileName", File.FileName);
									fileObj.Add("savePath", Request["filePath"].ToString() + "/" + DateTime.Today.ToString("yyyyMMdd") + "/" + Request["xfuDocID"].ToString());
									fileObj.Add("fileReName", Path.GetFileName(reFileName));
									fileObj.Add("fileType",  Path.GetExtension(reFileName).Replace(".", ""));
									fileObj.Add("fileSize", freNameFile.Length);
									fileObj.Add("isXSSTargetFile", isXSSTarget);
								}
							}
						}
					}
				//}
				//SerializeUploaderResponse(FileResponseList);
				Response.Write(fileObj);
			}
			else if (Request.HttpMethod.ToUpper() == HttpMethods.DELETE)
			{
				bool SuccessfullyDeleted = true;

				try
				{
					File.Delete(FullFileName);
				}
				catch
				{
					SuccessfullyDeleted = false;
				}
				Response.Write(String.Format("{{\"{0}\":{1}}}", ShortFileName, SuccessfullyDeleted.ToString().ToLower()));
			}
			else
			{
				Response.StatusCode = 405;
				Response.StatusDescription = "Method not allowed";
				Response.End();
				return;
			}

			Response.End();
		}
		
		
	}
	
	private static readonly FilesDisposition FILES_DISPOSITION = FilesDisposition.ServerRoot;
	private static string FILES_PATH = "";

	private static readonly string FILE_QUERY_VAR = "file";
	private static readonly string FILE_GET_CONTENT_TYPE = "application/octet-stream";

	private static readonly int ATTEMPTS_TO_WRITE = 3;
	private static readonly int ATTEMPT_WAIT = 1000; //msec
	//private static readonly int BUFFER_SIZE = 2000 * 1024 * 1024;
	private static readonly int BUFFER_SIZE = 2147483647;

	private static Boolean isXSSTarget = false;

	private enum FilesDisposition
	{
		ServerRoot,
		HandlerRoot,
		Absolute
	}

	private static class HttpMethods
	{
		public static readonly string GET = "GET";
		public static readonly string POST = "POST";
		public static readonly string DELETE = "DELETE";
	}
	[DataContract]
	private class FileResponse
	{
		[DataMember]
		public string fileName;
		[DataMember]
		public string savePath;
		[DataMember]
		public string fileReName;
		[DataMember]
		public string fileType;
		[DataMember]
		public long fileSize;
		[DataMember]
		public Boolean isXSSTargetFile;
	}

	[DataContract]
	private class UploaderResponse
	{
		[DataMember]
		public FileResponse[] files;
		public UploaderResponse(FileResponse[] fileResponses)
		{
			files = fileResponses;
		}
	}

	private string CreateFileUrl(string fileName, FilesDisposition filesDisposition)
	{
		switch (filesDisposition)
		{
			case FilesDisposition.ServerRoot:
				// 1. files directory lies in root directory catalog WRONG
				return String.Format("{0}{1}/{2}", Request.Url.GetLeftPart(UriPartial.Authority),
					FILES_PATH, Path.GetFileName(fileName));
			case FilesDisposition.HandlerRoot:
				// 2. files directory lays in current page catalog WRONG
				return String.Format("{0}{1}{2}/{3}", Request.Url.GetLeftPart(UriPartial.Authority),
					Path.GetDirectoryName(Request.CurrentExecutionFilePath).Replace(@"\", @"/"), FILES_PATH, Path.GetFileName(fileName));
			case FilesDisposition.Absolute:
				// 3. files directory lays anywhere YEAH
				return String.Format("{0}?{1}={2}", Request.Url.AbsoluteUri, FILE_QUERY_VAR, HttpUtility.UrlEncode(Path.GetFileName(fileName)));
			default:
				return String.Empty;
		}
	}

	private FileResponse CreateFileResponse(string fileName, string fileReName, string size, string error)
	{
		return new FileResponse()
		{
			fileName = Path.GetFileName(fileName),
			savePath = Request["filePath"].ToString() + "/" + DateTime.Today.ToString("yyyyMMdd") + "/" + Request["xfuDocID"].ToString(),
			fileReName = Path.GetFileName(fileReName),
			fileType = Path.GetExtension(fileName).Replace(".", ""),
			fileSize = Convert.ToInt64(size),
			isXSSTargetFile = isXSSTarget
		};
	}
	private void SerializeUploaderResponse(List<FileResponse> fileResponses)
	{
		DataContractJsonSerializer Serializer = new DataContractJsonSerializer(typeof(UploaderResponse));

		Serializer.WriteObject(Response.OutputStream, new UploaderResponse(fileResponses.ToArray()));

		/*
		// 이미지 워터마크 테스트 작업중
		string sourceImage = Server.MapPath(fileResponses[0].savePath + "/" + fileResponses[0].fileReName);
		string targetImage = Server.MapPath(fileResponses[0].savePath + "/test.jpg");

		watermarkImage(sourceImage, "TAGFREE", targetImage, ImageFormat.Jpeg);
		*/
		//string logFileName = "./ulog.dat";

		//makeLogData("test");
	}

	private void FromStreamToStream(Stream source, Stream destination)
	{
		int BufferSize = source.Length >= BUFFER_SIZE ? BUFFER_SIZE : (int)source.Length;
		long BytesLeft = source.Length;
		byte[] Buffer = new byte[BufferSize];
		int BytesRead = 0;
		while (BytesLeft > 0)
		{
			BytesRead = source.Read(Buffer, 0, BytesLeft > BufferSize ? BufferSize : (int)BytesLeft);
			destination.Write(Buffer, 0, BytesRead);
			BytesLeft -= BytesRead;
		}
	}

	public void makeLogData( String strMsg )
	{
		string m_strLogPrefix = @"C:\LOG\PROJECT\LOG";
		string m_strLogExt = @".LOG";
		DateTime dtNow = DateTime.Now;
		string strDate = dtNow.ToString("yyyyMMdd");
		string strPath = String.Format("{0}{1}{2}", m_strLogPrefix, strDate, m_strLogExt);
		string strDir  = Path.GetDirectoryName(strPath);
		DirectoryInfo diDir = new DirectoryInfo(strDir);

		if (!diDir.Exists)
		{
			diDir.Create();
			diDir = new DirectoryInfo(strDir);  // 아래에 있는 if (diDir.Exists)은 Directory 생성전 상태를 나타내므로 다시 DirectoryInfo object를 생성.
		}

		if (diDir.Exists)
		{
			System.IO.StreamWriter swStream = File.AppendText(strPath);
			string strLog = String.Format("{0}: {1}", dtNow.ToString("hhmmss"), strMsg);
			swStream.WriteLine(strLog);
			swStream.Close(); ;
		}
	}

	public static bool isBinary(string path)
	{
		long length = new FileInfo(path).Length;
		if (length == 0) return false;

		using (StreamReader stream = new StreamReader(path))
		{
			int ch;
			while ((ch = stream.Read()) != -1)
			{
				if (isControlChar(ch))
				{
					return true;
				}
			}
		}
		return false;
	}

	public static bool isControlChar(int ch)
	{
		return (ch > Chars.NUL && ch < Chars.BS)
			|| (ch > Chars.CR && ch < Chars.SUB);
	}

	public static class Chars
	{
		public static char NUL = (char)0; // Null char
		public static char BS = (char)8; // Back Space
		public static char CR = (char)13; // Carriage Return
		public static char SUB = (char)26; // Substitute
	}

	private string cleanXSS(string sInput) {
		if (sInput == null)
			return string.Empty;
		string sResult = string.Empty;
		//sResult = Regex.Replace(sInput, "<", "< ");
		//sResult = Regex.Replace(sResult, @"<\s*", "< ");
		sResult = Regex.Replace(sInput, "<", "&lt;");
		sResult = Regex.Replace(sInput, ">", "&gt;");
		sResult = Regex.Replace(sInput, "\\(", "&#40;");
		sResult = Regex.Replace(sInput, "\\)", "&#41;");
		sResult = Regex.Replace(sInput, "'", "&#39;");
		sResult = Regex.Replace(sInput, "eval\\((.*)\\)", "");
		sResult = Regex.Replace(sInput, "[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");
		sResult = Regex.Replace(sInput, "script", "");
		return sResult;
	}

	private static bool checkXSS(string sInput) {
		bool bResult = false;
		if (sInput.IndexOf("<") > -1 ||
			sInput.IndexOf(">") > -1 ||
			sInput.IndexOf("\\(") > -1 ||
			sInput.IndexOf("\\)") > -1 ||
			sInput.IndexOf("'") > -1 ||
			sInput.IndexOf("eval\\((.*)\\)") > -1 ||
			sInput.IndexOf("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']") > -1 ||
			sInput.IndexOf("script") > -1) {
			bResult = true;
		}
		return bResult;
	}

	/*
	public void watermarkImage(string sourceImage, string text, string targetImage, ImageFormat fmt)
	{
		try
		{
			// open source image as stream and create a memorystream for output
			FileStream source = new FileStream(sourceImage, FileMode.OpenOrCreate);

			Stream output = new MemoryStream();
			System.Drawing.Image img = System.Drawing.Image.FromStream(source);

			// choose font for text
			Font font = new Font("NanumGothic", 30, FontStyle.Bold, GraphicsUnit.Pixel);

			//choose color and transparency
			Color color = Color.FromArgb(255, 255, 255, 0);

			//location of the watermark text in the parent image
			Point pt = new Point(10, 5);
			SolidBrush brush = new SolidBrush(color);

			//draw text on image
			Graphics graphics = Graphics.FromImage(img);
			graphics.DrawString(text, font, brush, pt);
			graphics.Dispose();

			//update image memorystream
			img.Save(output, fmt);
			System.Drawing.Image imgFinal = System.Drawing.Image.FromStream(output);

			//write modified image to file
			Bitmap bmp = new System.Drawing.Bitmap(img.Width, img.Height, img.PixelFormat);
			Graphics graphics2 = Graphics.FromImage(bmp);
			graphics2.DrawImage(imgFinal, new Point(0, 0));
			bmp.Save(targetImage, fmt);

			imgFinal.Dispose();
			img.Dispose();
		}
		catch (Exception ex) {
			//MessageBox.Show(ex.Message);
		}
	}
	*/

	public string GetFileName(string fullFileName)
	{
		if(fullFileName == null){
			
			return "";
		} 
		else {
				
			string fileName = Path.GetFileName(fullFileName);
			string fileDate = File.GetLastWriteTime(fullFileName).ToString("yyyy-MM-dd HH:mm:ss");
			string filePath = Path.GetDirectoryName(fullFileName).Replace("\\", "/");
			string fileExt = Path.GetExtension(fullFileName).Replace(".", "");
			long fileSize = new FileInfo(fullFileName).Length;

			return fileName + "\t" + fileDate + "\t" + filePath + "\t" + fileExt + "\t" + fileSize;
		}
	}
	
	public static void DeleteEmptyDirectory(string path)
	{
		string uploadRootPath = System.Web.HttpContext.Current.Server.MapPath(HttpContext.Current.Request["path"]);
		
		foreach (string directory in Directory.GetDirectories(path))
		{
			DeleteEmptyDirectory(directory);
		}

		try
		{
			System.IO.DirectoryInfo di = new System.IO.DirectoryInfo(path);			
			System.IO.FileInfo[] fi =di.GetFiles("*.*");
			
			if(fi.Length == 0){
				
				// 최상위 폴더는 지우지 않게 처리함
				if(uploadRootPath != path){
					
					HttpContext.Current.Response.Write("Delete Empty Foler Path : " + path + "\n");
					Directory.Delete(path);
				}
			}
			
		}
		catch (IOException)
		{
			//Directory.Delete(path, true);
		}
		catch (UnauthorizedAccessException)
		{
			//Directory.Delete(path, true);
		}
	}
}



