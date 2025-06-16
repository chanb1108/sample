package category.dao;

import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import category.vo.CategoryVO;

@Mapper("CategoryDAO")
public interface CategoryDAO {

	/**
	 * 카테고리 목록 개수를 조회한다. 
	 */
	int selectCategoryCount(CategoryVO categoryVO) throws Exception;
	/**
	 * 카테고리 목록을 조회한다. 
	 */
	List<CategoryVO> selectCategoryList(CategoryVO categoryVO) throws Exception;
	/**
	 * 카테고리 상세정보를 조회한다.
	 */
	CategoryVO selectCategory(CategoryVO categoryVO) throws Exception;
	/**
	 * 카테고리 ID 및 카테고리명 중복 검사한다. 
	 */
	int selectDuplCnt(CategoryVO categoryVO) throws Exception;
	/**
	 * 카테고리 시퀀스를 재설정 한다. 
	 */
	int updateCaSeq(CategoryVO categoryVO) throws Exception;	
	/**
	 * 카테고리를 등록한다. 
	 */
	int insertCategory(CategoryVO categoryVo) throws Exception;
	/**
	 * 카테고리를 수정한다. 
	 */
	int updateCategory(CategoryVO categoryVO) throws Exception;
}
