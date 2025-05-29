package egovframework.example.sample.service;

import java.util.List;

public interface BoardService {

	public List<BoardVO> selectBoardList(BoardVO vo) throws Exception;
	
	public List<BoardVO> selectSchBoardList(BoardVO vo) throws Exception;
	
	public BoardVO selectBoardDetail(BoardVO boardVo) throws Exception;
	
	public List<OrgVO> selectOrgList(OrgVO vo) throws Exception;
	
	public String getToday() throws Exception;
	
	public String insertBoard(BoardVO boardVo) throws Exception;
	
	public String insertFileList(List<FileVO> fileList) throws Exception;
	
	public String modifyBoard(BoardVO boardVo) throws Exception;

}
