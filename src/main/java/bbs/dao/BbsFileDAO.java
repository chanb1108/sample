package bbs.dao;

import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import bbs.vo.BbsVO;
import bbs.vo.BbsFileVO;
import bbs.vo.OrgVO;

@Mapper("BbsFileDAO")
public interface BbsFileDAO {

	
	/**
	 * 게시글 첨부파일을 등록한다. 
	 */
	int insertBbsFileList(List<BbsFileVO> bbsFileVO) throws Exception;	
	/**
	 * 게시글 첨부파일 조회한다.
	 */
	List<BbsFileVO> selectBbsFile(int bbIdx) throws Exception;
}
