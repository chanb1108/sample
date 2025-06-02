package egovframework.example.sample.service;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class FileVO {

	private int bfIdx;
	private String bfBbsid;
	private int bfBbIdx;
	private String bfSrc;
	private String bfOrgName;
	private String bfName;
	private String bfExt;
	private int bfSize;
	private int bfSeq;
	private Timestamp bfRegDate;
	private String bfRegId;
	private String bfRegIp;
	private Timestamp bfModDate;
	private String bfModId;
	private String bfModIp;
	
	public int getBfIdx() {
		return bfIdx;
	}
	public void setBfIdx(int bfIdx) {
		this.bfIdx = bfIdx;
	}
	public String getBfBbsid() {
		return bfBbsid;
	}
	public void setBfBbsid(String bfBbsid) {
		this.bfBbsid = bfBbsid;
	}
	public int getBfBbIdx() {
		return bfBbIdx;
	}
	public void setBfBbIdx(int bfBbIdx) {
		this.bfBbIdx = bfBbIdx;
	}
	public String getBfSrc() {
		return bfSrc;
	}
	public void setBfSrc(String bfSrc) {
		this.bfSrc = bfSrc;
	}
	public String getBfOrgName() {
		return bfOrgName;
	}
	public void setBfOrgName(String bfOrgName) {
		this.bfOrgName = bfOrgName;
	}
	public String getBfName() {
		return bfName;
	}
	public void setBfName(String bfName) {
		this.bfName = bfName;
	}
	public String getBfExt() {
		return bfExt;
	}
	public void setBfExt(String bfExt) {
		this.bfExt = bfExt;
	}
	public int getBfSize() {
		return bfSize;
	}
	public void setBfSize(int bfSize) {
		this.bfSize = bfSize;
	}
	public int getBfSeq() {
		return bfSeq;
	}
	public void setBfSeq(int bfSeq) {
		this.bfSeq = bfSeq;
	}
	public Timestamp getBfRegDate() {
		return bfRegDate;
	}
	public void setBfRegDate(Timestamp bfRegDate) {
		this.bfRegDate = bfRegDate;
	}
	public String getBfRegId() {
		return bfRegId;
	}
	public void setBfRegId(String bfRegId) {
		this.bfRegId = bfRegId;
	}
	public String getBfRegIp() {
		return bfRegIp;
	}
	public void setBfRegIp(String bfRegIp) {
		this.bfRegIp = bfRegIp;
	}
	public Timestamp getBfModDate() {
		return bfModDate;
	}
	public void setBfModDate(Timestamp bfModDate) {
		this.bfModDate = bfModDate;
	}
	public String getBfModId() {
		return bfModId;
	}
	public void setBfModId(String bfModId) {
		this.bfModId = bfModId;
	}
	public String getBfModIp() {
		return bfModIp;
	}
	public void setBfModIp(String bfModIp) {
		this.bfModIp = bfModIp;
	}
	
	private String sdfBfRegDate;
	private String sdfBfModDate;
	
	public String getSdfBfRegDate() {
		sdfBfRegDate = setSdfDate(bfRegDate);
		return sdfBfRegDate;
	}
	public String getSdfBfModDate() {
		sdfBfModDate = setSdfDate(bfModDate);
		return sdfBfModDate;
	}
	public String setSdfDate(Timestamp date) {
		SimpleDateFormat sdf = new SimpleDateFormat();
		return sdf.format(date);
	}
	private String downloadPath;
	
	public String getDownloadPath() {
		return downloadPath;
	}
	public void setDownloadPath(String downloadPath) {
		this.downloadPath = downloadPath;
	}
}
