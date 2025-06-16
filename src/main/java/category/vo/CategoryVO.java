package category.vo;

public class CategoryVO {
	
	private int caIdx;
	private String caId;
	private String caName;
	private int caDepth;
	private String caParentId;
	private int caSeq;
	private String caUse;
	private int caPoint;
	private int caOrgIdx;
	private String caRegDate;
	private String caRegId;
	private String caRegIp;
	private String caModDate;
	private String caModId;
	private String caModIp;
	
	private String orName;
	
	private String caParentName;
	
	private int beforeSeq;
	private String chgKnd;
	
	private int maxSeq;
	private int minSeq;
	
	public int getMaxSeq() {
		return maxSeq;
	}
	public void setMaxSeq(int maxSeq) {
		this.maxSeq = maxSeq;
	}
	public int getMinSeq() {
		return minSeq;
	}
	public void setMinSeq(int minSeq) {
		this.minSeq = minSeq;
	}
	public int getBeforeSeq() {
		return beforeSeq;
	}
	public void setBeforeSeq(int beforeSeq) {
		this.beforeSeq = beforeSeq;
	}
	public String getChgKnd() {
		return chgKnd;
	}
	public void setChgKnd(String chgKnd) {
		this.chgKnd = chgKnd;
	}
	public int getPageNo() {
		return pageNo;
	}
	public void setPageNo(int pageNo) {
		this.pageNo = pageNo;
	}
	public int getPageSize() {
		return pageSize;
	}
	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}
	private int pageNo;
	private int pageSize;
	

	public int getCaIdx() {
		return caIdx;
	}
	public void setCaIdx(int caIdx) {
		this.caIdx = caIdx;
	}
	public String getCaId() {
		return caId;
	}
	public void setCaId(String caId) {
		this.caId = caId;
	}
	public String getCaName() {
		return caName;
	}
	public void setCaName(String caName) {
		this.caName = caName;
	}
	public int getCaDepth() {
		return caDepth;
	}
	public void setCaDepth(int caDepth) {
		this.caDepth = caDepth;
	}
	public String getCaParentId() {
		return caParentId;
	}
	public void setCaParentId(String caParentId) {
		this.caParentId = caParentId;
	}
	public int getCaSeq() {
		return caSeq;
	}
	public void setCaSeq(int caSeq) {
		this.caSeq = caSeq;
	}
	public String getCaUse() {
		return caUse;
	}
	public void setCaUse(String caUse) {
		this.caUse = caUse;
	}
	public int getCaPoint() {
		return caPoint;
	}
	public void setCaPoint(int caPoint) {
		this.caPoint = caPoint;
	}
	public int getCaOrgIdx() {
		return caOrgIdx;
	}
	public void setCaOrgIdx(int caOrgIdx) {
		this.caOrgIdx = caOrgIdx;
	}
	public String getCaRegDate() {
		return caRegDate;
	}
	public void setCaRegDate(String caRegDate) {
		this.caRegDate = caRegDate;
	}
	public String getCaRegId() {
		return caRegId;
	}
	public void setCaRegId(String caRegId) {
		this.caRegId = caRegId;
	}
	public String getCaRegIp() {
		return caRegIp;
	}
	public void setCaRegIp(String caRegIp) {
		this.caRegIp = caRegIp;
	}
	public String getCaModDate() {
		return caModDate;
	}
	public void setCaModDate(String caModDate) {
		this.caModDate = caModDate;
	}
	public String getCaModId() {
		return caModId;
	}
	public void setCaModId(String caModId) {
		this.caModId = caModId;
	}
	public String getCaModIp() {
		return caModIp;
	}
	public void setCaModIp(String caModIp) {
		this.caModIp = caModIp;
	}
	public String getOrName() {
		return orName;
	}
	public void setOrName(String orName) {
		this.orName = orName;
	}
	public String getCaParentName() {
		return caParentName;
	}
	public void setCaParentName(String caParentName) {
		this.caParentName = caParentName;
	}
}
