package category.service;

import java.util.List;

import category.vo.CategoryVO;


public interface CategoryService {

	public int getCategoryListCnt(CategoryVO vo) throws Exception;
	
	public List<CategoryVO> getCategoryList(CategoryVO vo) throws Exception;
	
	public CategoryVO getCategory(CategoryVO vo) throws Exception;
	
	public int getDuplCnt(CategoryVO vo) throws Exception;
	
	public int registCategory(CategoryVO vo) throws Exception;
	
	public int modifyCategory(CategoryVO vo) throws Exception;	
}
