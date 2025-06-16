package category.web;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import bbs.serivce.BbsService;
import bbs.vo.OrgVO;
import category.service.CategoryService;
import category.vo.CategoryVO;

@Controller
public class CategoryController {

	protected Logger log = LoggerFactory.getLogger(getClass());
	/*BbsService*/
	@Resource(name = "bbsService")
	private BbsService bbsService;
	/** CatogoryService */
	@Resource(name = "categoryService")
	private CategoryService categoryService;

	@GetMapping(value = "/category.do")
	public String selectCategoryList(Model model) throws Exception {
		OrgVO orgVO = new OrgVO();
		List<OrgVO> orgList = bbsService.getOrgList(orgVO);
		model.addAttribute("orgList", orgList);
		
		return "category/categoryList";
	}
	
	@GetMapping(value = "getCategorySearchCnt.do", produces = "application/json")
	@ResponseBody
	public String getCategorySearchCnt(@ModelAttribute CategoryVO categoryVo) throws Exception {

		log.debug("=================getCate : {}","list 수량 확인");
		int cnt = categoryService.getCategoryListCnt(categoryVo);
		log.debug("=================getCate : {}",cnt);
		return Integer.toString(cnt);
	}
	
	@GetMapping(value = "getCategorySearch.do", produces = "application/json")
	@ResponseBody
	public List<CategoryVO> getCategorySearch(@ModelAttribute CategoryVO categoryVo) throws Exception {
		log.debug("=================getCate : {}","list 확인"); 
		if(categoryVo.getPageNo() > 0) {
			categoryVo.setPageNo(categoryVo.getPageNo() * categoryVo.getPageSize()); 
		}
		 log.debug("=================getCate : {}",categoryVo.getPageNo());
		List<CategoryVO> categoryList = categoryService.getCategoryList(categoryVo);
		
		return categoryList;
	}
	
	@GetMapping(value = "getCategoryForm.do")
	@ResponseBody
	public CategoryVO getCategoryForm(@RequestParam(required = false) String caIdx) throws Exception {
		
		log.debug("===========caIdx : {}", caIdx);
		
		CategoryVO categoryVo = new CategoryVO();
		categoryVo.setCaIdx(Integer.parseInt(caIdx));
		
		categoryVo = categoryService.getCategory(categoryVo);
		
		log.debug("==========categoryVo : {}", categoryVo);			
		
		return categoryVo;
	}
	
	@PostMapping(value = "saveCategory.do", produces = "application/json")
	@ResponseBody
	public String saveCategory(@RequestBody CategoryVO categoryVo, HttpServletRequest request) throws Exception {
		
		String resultMsg = "success";
		int rtnCnt = 0;
		String ip = request.getRemoteAddr();
		// 카테고리명 또는 카테고리 ID 중복 검사
		if (categoryVo.getCaIdx() == 0) {
			int duplCnt = categoryService.getDuplCnt(categoryVo);
			if (duplCnt > 0) {
				return "중복된 카테고리 ID 또는 카테고리명이 존재합니다.";
			}
			categoryVo.setCaRegIp(ip);
			rtnCnt = categoryService.registCategory(categoryVo);
			if (rtnCnt <= 0) {
				resultMsg = "카테고리 등록에 실패하였습니다. 다시 진행 바랍니다.";
			}
		} else {
			categoryVo.setCaModIp(ip);
			rtnCnt = categoryService.modifyCategory(categoryVo);
			if (rtnCnt <= 0) {
				resultMsg = "카테고리 수정에 실패하였습니다. 다시 진행 바랍니다.";
			}
		}
		
		return resultMsg;
	}
	
}
