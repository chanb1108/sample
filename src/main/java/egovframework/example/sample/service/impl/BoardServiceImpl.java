package egovframework.example.sample.service.impl;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import egovframework.example.sample.service.BoardService;
import egovframework.example.sample.service.BoardVO;
import egovframework.example.sample.service.OrgVO;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;


@Service("boardService")
public class BoardServiceImpl implements BoardService {

	protected Logger log = LoggerFactory.getLogger(getClass());

	/** SampleDAO */
	@Resource(name="boardMapper")
	private BoardMapper boardDAO;

	/** ID Generation */
//	@Resource(name = "egovIdGnrService")
//	private EgovIdGnrService egovIdGnrService;

	@Override
	public List<BoardVO> selectBoardList(BoardVO vo) throws Exception {
		return boardDAO.selectBoardList(vo);
	}
	
	@Override
	public List<OrgVO> selectOrgList(OrgVO vo) throws Exception {
		return boardDAO.selectOrgList(vo);
	}
	
	@Override
	public String getToday() throws Exception {
		Date date = new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		String today = sdf.format(date);
		return today;
	}
	
	@Override
	public String insertBoard(BoardVO boardVo) throws Exception {
		
		String resultMsg = "success";
		
		boardVo.setBbBbsid("notice");
		boardVo.setBbSeq(0);
		boardVo.setBbConfirm(0);
		boardVo.setBbStatus(0);
		boardVo.setBbOpenType(0);
		boardVo.setBbCoIdx(0);
		boardVo.setBbRegId("psb");
		
		int istResult = boardDAO.insertBoard(boardVo);
		
		if (istResult <= 0) {
			resultMsg = "fail";
		}
		
		return resultMsg;
	}

}
