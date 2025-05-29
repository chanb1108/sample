package egovframework.example.sample.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.example.sample.service.BoardService;
import egovframework.example.sample.service.BoardVO;
import egovframework.example.sample.service.FileVO;
import egovframework.example.sample.service.OrgVO;

@Controller
public class BoardController {

	protected Logger log = LoggerFactory.getLogger(getClass());
	/** BoardService */
	@Resource(name = "boardService")
	private BoardService boardService;

	@RequestMapping(value = "/boardList.do")
	public String selectBoardList(Model model) throws Exception {
		
		OrgVO orgVO = new OrgVO();
		List<OrgVO> orgList = boardService.selectOrgList(orgVO);
		ArrayList<Map<String, String>> orgSchList = new ArrayList<Map<String, String>>();
		for (OrgVO vo : orgList) {
			Map<String, String> map = new HashMap<>();
			map.put("orIdx", Integer.toString(vo.getOrIdx()));
			map.put("orName", vo.getOrName());
			orgSchList.add(map);
		}
		model.addAttribute("orgList", orgSchList);

		return "board/boardList";
	}
	
	@GetMapping(value = "dataCall.do", produces = "application/json")
	@ResponseBody
	public ArrayList<Map<String, String>> dataCall() throws Exception {
		
		BoardVO boardVO = new BoardVO();
		List<BoardVO> list = boardService.selectBoardList(boardVO);
		ArrayList<Map<String, String>> arr = new ArrayList<Map<String, String>>();
		for (BoardVO vo : list) {
			Map<String, String> map = new HashMap<>();
			map.put("bbIdx", Integer.toString(vo.getBbIdx()));
			map.put("bbTitle", vo.getBbTitle());
			map.put("orName", vo.getOrName());
			map.put("bbRegDate", vo.getSdfBbRegDate());
			map.put("bbHit", Integer.toString(vo.getBbHit()));
			map.put("bbOpen", Integer.toString(vo.getBbOpen()));
			arr.add(map);
		}
		
		return arr;
	}
	
	@PostMapping(value = "schDataCall.do", produces = "application/json")
	@ResponseBody
	public ArrayList<Map<String, String>> schDataCall(@RequestBody BoardVO boardVo) throws Exception {
		
		log.debug("=========== bbOrIdx : {}",boardVo.getBbOrIdx());
		log.debug("=========== schDate : {}",boardVo.getSchDate());
		log.debug("=========== strDate : {}",boardVo.getStrDate());
		log.debug("=========== endDate : {}",boardVo.getEndDate());
		log.debug("=========== bbTitle : {}",boardVo.getBbTitle());
		
		List<BoardVO> list = boardService.selectSchBoardList(boardVo);
		ArrayList<Map<String, String>> arr = new ArrayList<Map<String, String>>();
		for (BoardVO vo : list) {
			Map<String, String> map = new HashMap<>();
			map.put("bbIdx", Integer.toString(vo.getBbIdx()));
			map.put("bbTitle", vo.getBbTitle());
			map.put("orName", vo.getOrName());
			map.put("bbRegDate", vo.getSdfBbRegDate());
			map.put("bbHit", Integer.toString(vo.getBbHit()));
			map.put("bbOpen", Integer.toString(vo.getBbOpen()));
			arr.add(map);
		}
		
		return arr;
	}
	
	@RequestMapping(value = "/insertBoardEditor.do")
	public String insertBoardEditor(HttpServletRequest request, Model model) throws Exception {
		
		BoardVO boardVo = new BoardVO();
		int bbIdx = 0;
		
		if (request.getParameterMap().containsKey("bbIdx")) {
			try {
				bbIdx = Integer.parseInt(request.getParameter("bbIdx"));
			}catch(Exception e) {
				bbIdx = 0;
			}
			if(bbIdx > 0) {
				boardVo.setBbIdx(bbIdx);
				boardVo = boardService.selectBoardDetail(boardVo);
				model.addAttribute("boardVo", boardVo);
			}
		}		

		log.debug("========request : {}",bbIdx);
		
		OrgVO orgVO = new OrgVO();
		List<OrgVO> orgList = boardService.selectOrgList(orgVO);
		ArrayList<Map<String, String>> orgSchList = new ArrayList<Map<String, String>>();
		for (OrgVO vo : orgList) {
			Map<String, String> map = new HashMap<>();
			map.put("orIdx", Integer.toString(vo.getOrIdx()));
			map.put("orName", vo.getOrName());
			orgSchList.add(map);
		}
	
		model.addAttribute("orgList", orgSchList);
		
		String today = boardService.getToday();
		model.addAttribute("today", today);
		
		return "board/insertBoardEditor";
	}
	
	@PostMapping(value = "/insertBoard.do", produces = "application/json")
	@ResponseBody
	public String insertBoard(@RequestBody BoardVO boardVo, HttpServletRequest request) throws Exception {

		String resultMsg = "";
		
		String ip = request.getRemoteAddr();
		if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
			ip = "127.0.0.1";
		}
		boardVo.setBbRegIp(ip);
		
		resultMsg = boardService.insertBoard(boardVo);
				
		List<FileVO> fileList = new ArrayList<FileVO>();
		String bfSrc = "";
		String bfExt = "";
		int i = 0;
		for (Map<String, String> file : boardVo.getBbsFile()) {
			FileVO fileVo = new FileVO();
//			log.debug("===========file.get(\"savePath\") : {}",file.get("savePath"));
			bfSrc = file.get("savePath").substring(file.get("savePath").indexOf("/20"));
			bfExt = file.get("fileType").substring(file.get("fileType").indexOf("/")+1);
			i++;
			fileVo.setBfBbsid(boardVo.getBbBbsid());
			fileVo.setBfBbIdx(boardVo.getBbIdx());
			fileVo.setBfSrc(bfSrc);
			fileVo.setBfOrgName(file.get("fileName"));
			fileVo.setBfName(file.get("fileReName"));
			fileVo.setBfExt(bfExt);
			fileVo.setBfSize(Integer.parseInt(file.get("fileSize")));
			fileVo.setBfSeq(i);
			fileVo.setBfRegId(boardVo.getBbRegId());
			fileVo.setBfRegIp(ip);
			
			log.debug("===========fileVo.getBfSrc {} : {}", i, fileVo.getBfSrc());
			log.debug("===========fileVo.getBfExt {} : {}", i, fileVo.getBfExt());
			log.debug("===========fileVo.getBfSize {} : {}", i, fileVo.getBfSize());
			log.debug("===========fileVo.getBfSeq {} : {}", i, fileVo.getBfSeq());
			
			fileList.add(fileVo);
		}
		
		log.debug("===============fileList : {}", fileList.toString());
		
		String fileRstMsg = boardService.insertFileList(fileList);
		
		return resultMsg + "," + fileRstMsg;
	}
	
	@PostMapping(value = "/modifyBoard.do", produces = "application/json")
	@ResponseBody
	public String modifyBoard(@RequestBody BoardVO boardVo, HttpServletRequest request) throws Exception {

		String resultMsg = "";
		
		String ip = request.getRemoteAddr();
		if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
			ip = "127.0.0.1";
		}
		log.debug("=========remoteAddr : {}",request.getRemoteAddr());
		log.debug("=========ip : {}", ip);
		boardVo.setBbModIp(ip);
		
		resultMsg = boardService.modifyBoard(boardVo);
		
		return resultMsg;
	}

}
