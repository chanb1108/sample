package egovframework.example.sample.service.impl;

import java.util.List;

import egovframework.example.sample.service.BoardVO;
import egovframework.example.sample.service.FileVO;
import egovframework.example.sample.service.OrgVO;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper("boardMapper")
public interface BoardMapper {

	/**
	 * 글 목록을 조회한다.
	 */
	List<BoardVO> selectBoardList(BoardVO boardVO) throws Exception;
	/**
	 * 검색 조건에 맞는 글 목록을 조회한다.
	 */
	List<BoardVO> selectSchBoardList(BoardVO boardVO) throws Exception;
	/**
	 * 게시글 정보를 조회한다.
	 */
	BoardVO selectBoardDetail(BoardVO boardVO) throws Exception;	
	/**
	 * 업체 목록을 조회한다.
	 */
	List<OrgVO> selectOrgList(OrgVO orgVO) throws Exception;
	/**
	 * 게시글을 등록한다. 
	 */
	int insertBoard(BoardVO boardVO) throws Exception;
	/**
	 * 게시글을 등록한다. 
	 */
	int insertFileList(List<FileVO> fileList) throws Exception;	
	/**
	 * 게시글을 등록한다. 
	 */
	int modifyBoard(BoardVO boardVO) throws Exception;
}
