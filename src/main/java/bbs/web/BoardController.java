package bbs.web;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import bbs.serivce.BbsService;
import bbs.vo.BbsVO;
import bbs.vo.BbsFileVO;
import bbs.vo.OrgVO;

@Controller
public class BoardController {

	protected Logger log = LoggerFactory.getLogger(getClass());
	/** BoardService */
	@Resource(name = "bbsService")
	private BbsService bbsService;

	@RequestMapping(value = "/bbsList.do")
	public String selectBbsList(Model model) throws Exception {
		
		OrgVO orgVO = new OrgVO();
		List<OrgVO> orgList = bbsService.getOrgList(orgVO);
		model.addAttribute("orgList", orgList);

		return "bbs/bbsList";
	}
	
	@GetMapping(value = "getBbsSearchCnt.do", produces = "application/json")
	@ResponseBody
	public String getBbsSearchCnt(@ModelAttribute BbsVO bbsVo) throws Exception {
		
		
		int cnt = bbsService.getBbsListCnt(bbsVo);
		log.debug("====list cnt = {}", cnt);
		
		return Integer.toString(cnt);
	}
	
	@GetMapping(value = "getBbsSearch.do", produces = "application/json")
	@ResponseBody
	public List<BbsVO> getBbsSearch(@ModelAttribute BbsVO bbsVo) throws Exception {
		
		log.debug("===============pageNO : {}", bbsVo.getPageNo());
		log.debug("===============pageSize : {}", bbsVo.getPageSize());
		
		if(bbsVo.getPageNo() > 0) {
			bbsVo.setPageNo(bbsVo.getPageNo() * bbsVo.getPageSize());
		}
		
		log.debug("===============pageNO : {}", bbsVo.getPageNo());
		
		List<BbsVO> bbsList = bbsService.getBbsList(bbsVo);
		
		return bbsList;
	}
	
	@GetMapping(value = "/bbsDetail.do")
	public String bbsDetail(@RequestParam("bbIdx") int bbIdx, Model model) throws Exception {
		
		BbsVO bbsVo = new BbsVO();
		if(bbIdx > 0) {
			bbsService.modifyBbHit(bbIdx);			
			bbsVo = bbsService.getBbsDetail(bbIdx);
		}

		model.addAttribute("bbsVo", bbsVo);
		
		List<BbsFileVO> bbsFileList = new ArrayList<BbsFileVO>();
		bbsFileList = bbsService.getBbsFile(bbIdx); 
		
		model.addAttribute("bbsFileList", bbsFileList);
				
		return "bbs/bbsDetail";
		
	}
		
	@RequestMapping(value = "/insertBbsForm.do")
	public String insertBbsForm(@RequestParam(required = false) Integer bbIdx, Model model) throws Exception {
		
		if (bbIdx == null) {
			bbIdx = 0;
		}
		
		BbsVO bbsVo = new BbsVO();
		
		if(bbIdx > 0) {
			bbsVo.setBbIdx(bbIdx);
			bbsVo = bbsService.getBbsDetail(bbIdx);
			model.addAttribute("bbsVo", bbsVo);
			
			List<BbsFileVO> bbsFileList = new ArrayList<BbsFileVO>();
			bbsFileList = bbsService.getBbsFile(bbIdx); 
			
			model.addAttribute("bbsFileList", bbsFileList);
		}
		
		OrgVO orgVO = new OrgVO();
		List<OrgVO> orgList = bbsService.getOrgList(orgVO);
	
		model.addAttribute("orgList", orgList);
		
		Date date = new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		String today = sdf.format(date);
		
		model.addAttribute("today", today);
		
		return "bbs/insertBbsForm";
	}
	
	@PostMapping(value = "/insertBbs.do", produces = "application/json")
	@ResponseBody
	public String insertBbs(@RequestBody BbsVO bbsVo, HttpServletRequest request) throws Exception {

		String resultMsg = "";
		
		String ip = request.getRemoteAddr();
		
		log.debug("========ip : {}", ip);
		
		if(bbsVo.getBbIdx() > 0) {
			bbsVo.setBbModIp(ip);
			resultMsg = bbsService.modifyBbs(bbsVo);
		} else {
			bbsVo.setBbRegIp(ip);
			resultMsg = bbsService.registBbs(bbsVo);
		}

		return resultMsg;
	}

}
