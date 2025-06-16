package bbs.dao;

import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import bbs.vo.BbsVO;
import bbs.vo.BbsFileVO;
import bbs.vo.OrgVO;

@Mapper("OrgDAO")
public interface OrgDAO {

	/**
	 * 업체 목록을 조회한다.
	 */
	List<OrgVO> selectOrgList(OrgVO orgVO) throws Exception;
	
}
