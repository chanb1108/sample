package bbs.serivce.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import bbs.dao.BbsDAO;
import bbs.dao.BbsFileDAO;
import bbs.dao.OrgDAO;
import bbs.serivce.BbsService;
import bbs.vo.BbsVO;
import bbs.vo.BbsFileVO;
import bbs.vo.OrgVO;


@Service("bbsService")
public class BbsServiceImpl implements BbsService {

	protected Logger log = LoggerFactory.getLogger(getClass());

	/** DAO */
	@Resource(name="BbsDAO")
	private BbsDAO bbsDAO;
	@Resource(name="OrgDAO")
	private OrgDAO orgDAO;
	@Resource(name="BbsFileDAO")
	private BbsFileDAO bbsFileDAO;
	
	private String SUCCESS = "success";
	
	@Override
	public int getBbsListCnt(BbsVO vo) throws Exception {
		return bbsDAO.selectBbsCount(vo);
	}

	@Override
	public List<BbsVO> getBbsList(BbsVO vo) throws Exception {
		return bbsDAO.selectBbsList(vo);
	}
	
	@Override
	public BbsVO getBbsDetail(int bbIdx) throws Exception {
		BbsVO vo = new BbsVO();
		vo = bbsDAO.selectBbs(bbIdx);
		return vo;
	}
	
	@Override
	public List<OrgVO> getOrgList(OrgVO vo) throws Exception {
		return orgDAO.selectOrgList(vo);
	}
	
	@Override
	public List<BbsFileVO> getBbsFile(int bbIdx) throws Exception {
		return bbsFileDAO.selectBbsFile(bbIdx);
	}
	
	@Override
	public String registBbs(BbsVO bbsVo) throws Exception {
		
		String resultMsg = "success";		

		if ("0:0:0:0:0:0:0:1".equals(bbsVo.getBbRegIp()) || "::1".equals(bbsVo.getBbRegIp())) {
			bbsVo.setBbRegIp("127.0.0.1");
		}
		
		bbsVo.setBbBbsid("notice");
		bbsVo.setBbSeq(0);
		bbsVo.setBbConfirm(0);
		bbsVo.setBbStatus(0);
		bbsVo.setBbOpenType(0);
		bbsVo.setBbCoIdx(0);
		bbsVo.setBbRegId("psb");
		
		int istResult = bbsDAO.insertBbs(bbsVo);
		
		if (istResult <= 0) {
			resultMsg = "fail";
		}
		
		List<BbsFileVO> bbsFileList = new ArrayList<BbsFileVO>();
		String bfSrc = "";
		String bfExt = "";
		int i = 0;
		for (Map<String, String> file : bbsVo.getBbsFile()) {
			BbsFileVO bbsFileVo = new BbsFileVO();
			
			bfSrc = file.get("savePath").substring(file.get("savePath").indexOf("/20"));
			bfExt = file.get("fileType").substring(file.get("fileType").indexOf("/")+1);
			i++;
			bbsFileVo.setBfBbsid(bbsVo.getBbBbsid());
			bbsFileVo.setBfBbIdx(bbsVo.getBbIdx());
			bbsFileVo.setBfSrc(bfSrc);
			bbsFileVo.setBfOrgName(file.get("fileName"));
			bbsFileVo.setBfName(file.get("fileReName"));
			bbsFileVo.setBfExt(bfExt);
			bbsFileVo.setBfSize(Integer.parseInt(file.get("fileSize")));
			bbsFileVo.setBfSeq(i);
			bbsFileVo.setBfRegId(bbsVo.getBbRegId());
			bbsFileVo.setBfRegIp(bbsVo.getBbRegIp());
			
			bbsFileList.add(bbsFileVo);
		}
	
		String fileRstMsg = this.registBbsFileList(bbsFileList);
		if (!SUCCESS.equals(fileRstMsg)) {
			resultMsg = "fail";
		}
		
		resultMsg = Integer.toString(bbsVo.getBbIdx());
		
		return resultMsg;
	}
	
	@Override
	public String modifyBbs(BbsVO bbsVo) throws Exception {
		
		String resultMsg = "success";

		if ("0:0:0:0:0:0:0:1".equals(bbsVo.getBbModIp()) || "::1".equals(bbsVo.getBbModIp())) {
			bbsVo.setBbModIp("127.0.0.1");
		}
		
		bbsVo.setBbModId("psb");
		
		int istResult = bbsDAO.updateBbs(bbsVo);
		
		if (istResult <= 0) {
			resultMsg = "fail";
		}
		
		resultMsg = Integer.toString(bbsVo.getBbIdx());
		
		return resultMsg;
	}
	
	@Override
	public String registBbsFileList(List<BbsFileVO> bbsFileList) throws Exception {
		
		String resultMsg = "success";
		
		int istResult = bbsFileDAO.insertBbsFileList(bbsFileList);
		
		if (istResult < bbsFileList.size()) {
			resultMsg = "fail";
		}
		
		return resultMsg;
	}
	
	public void modifyBbHit (int bbIdx) throws Exception {
		bbsDAO.updateBbHit(bbIdx);
	}

}
