package category.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import category.dao.CategoryDAO;
import category.service.CategoryService;
import category.vo.CategoryVO;


@Service("categoryService")
public class CategoryServiceImpl implements CategoryService {

	protected Logger log = LoggerFactory.getLogger(getClass());

	/** DAO */
	@Resource(name="CategoryDAO")
	private CategoryDAO categoryDAO;

	@Override
	public int getCategoryListCnt(CategoryVO vo) throws Exception {
		return categoryDAO.selectCategoryCount(vo);
	}

	@Override
	public List<CategoryVO> getCategoryList(CategoryVO vo) throws Exception {
		return categoryDAO.selectCategoryList(vo);
	}
	
	@Override
	public CategoryVO getCategory(CategoryVO vo) throws Exception {
		return categoryDAO.selectCategory(vo);
	}
	
	@Override
	public int getDuplCnt(CategoryVO vo) throws Exception {
		return categoryDAO.selectDuplCnt(vo);
	}

	@Override
	public int registCategory(CategoryVO vo) throws Exception {
				
		vo.setCaRegIp(this.ipSetting(vo.getCaRegIp()));
		vo.setCaRegId("pcb");
		
		log.debug("==========확인용 : {}", vo.getCaSeq());
		// 카테고리 시퀀스 재설정
		int updSeqCnt = categoryDAO.updateCaSeq(vo);
		log.debug("==========시퀀스 정렬 : {}",updSeqCnt);
		// 카테고리 등록 진행
		int istCnt = categoryDAO.insertCategory(vo);
		
		return istCnt;
	}
	
	@Override
	public int modifyCategory(CategoryVO vo) throws Exception {
		
		vo.setCaModIp(this.ipSetting(vo.getCaModIp()));
		vo.setCaModId("pcb");
		// 시퀀스 재설정
		if (vo.getBeforeSeq() != vo.getCaSeq()) {
			
			if (vo.getBeforeSeq() > vo.getCaSeq()) {
				vo.setMaxSeq(vo.getBeforeSeq());
				vo.setMinSeq(vo.getCaSeq());
			}else {
				vo.setMaxSeq(vo.getCaSeq());
				vo.setMinSeq(vo.getBeforeSeq());
			}
			int updSeqCnt = categoryDAO.updateCaSeq(vo);
			log.debug("==========시퀀스 정렬 : {}",updSeqCnt);
		}
		// 카테고리 수정 진행
		int updCnt = categoryDAO.updateCategory(vo);
		
		return updCnt;
	}
	
	private String ipSetting(String ip) throws Exception {
		
		String rtnIp = "";
		if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
			rtnIp = "127.0.0.1";
		} else {
			rtnIp = ip;
		}
		
		return rtnIp;
	}
}
