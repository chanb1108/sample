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

public partial class content_save : System.Web.UI.Page
{
	protected void Page_Load(object sender, EventArgs e)
	{
		string jsonBuffer = Request["data"];
		
		// 데이터 내용 js파일에 저장
		string savePath = Server.MapPath("../uploads_bbs/dataobj.js");
		string jsonStringData = jsonBuffer;
		System.IO.File.WriteAllText(savePath, jsonStringData, Encoding.UTF8);
		
		// 반환 데이터 표현
		Response.Write(Request["data"]);
	}
}



