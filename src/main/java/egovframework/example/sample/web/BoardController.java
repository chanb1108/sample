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
	
	@RequestMapping(value = "/insertBoardEditor.do")
	public String insertBoardEditor(Model model) throws Exception {
		
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
		log.debug("=========remoteAddr : {}",request.getRemoteAddr());
		log.debug("=========ip : {}", ip);
		
		resultMsg = boardService.insertBoard(boardVo);
		
		return resultMsg;
	}

}
