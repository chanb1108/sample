package bbs.dao;

import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import bbs.vo.BbsVO;
import bbs.vo.BbsFileVO;
import bbs.vo.OrgVO;

@Mapper("BbsDAO")
public interface BbsDAO {

	/**
	 * 글 목록 개수를 조회한다.
	 */
	int selectBbsCount(BbsVO bbsVO) throws Exception;
	/**
	 * 글 목록을 조회한다.
	 */
	List<BbsVO> selectBbsList(BbsVO bbsVO) throws Exception;
	/**
	 * 게시글 정보를 조회한다.
	 */
	BbsVO selectBbs(int bbIdx) throws Exception;
	/**
	 * 조회수를 업데이트 한다.
	 */
	int updateBbHit(int bbIdx) throws Exception;
	/**
	 * 게시글을 등록한다. 
	 */
	int insertBbs(BbsVO bbsVO) throws Exception;
	/**
	 * 게시글을 수정한다. 
	 */
	int updateBbs(BbsVO bbsVO) throws Exception;
}
