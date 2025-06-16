package bbs.serivce;

import java.util.List;

import bbs.vo.BbsVO;
import bbs.vo.BbsFileVO;
import bbs.vo.OrgVO;

public interface BbsService {

	public int getBbsListCnt(BbsVO bbsVo) throws Exception;
	
	public List<BbsVO> getBbsList(BbsVO bbsVo) throws Exception;
	
	public BbsVO getBbsDetail(int bbIdx) throws Exception;
	
	public List<OrgVO> getOrgList(OrgVO orgVo) throws Exception;
	
	public String registBbs(BbsVO bbsVo) throws Exception;
	
	public String registBbsFileList(List<BbsFileVO> bbsFileList) throws Exception;
	
	public String modifyBbs(BbsVO bbsVo) throws Exception;
	
	public List<BbsFileVO> getBbsFile(int bbsIdx) throws Exception;
	
	public void modifyBbHit (int bbIdx) throws Exception; 

}
