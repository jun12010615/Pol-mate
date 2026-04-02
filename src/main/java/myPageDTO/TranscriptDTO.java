package myPageDTO;

import java.sql.Timestamp;

/**
 * TRANSCRIPTS 테이블 매핑 DTO
 * 마이페이지 "내 조서 이력" 드로어에서 사용
 */
public class TranscriptDTO {

    private int    transcriptId;     // 조서 고유 번호 (PK)
    private String caseId;           // 소속 사건 (FK → CASES)
    private String userId;           // 작성 수사관 (FK → USERS)
    private String originalText;     // STT 원문 / 직접 입력 진술
    private String aiResult;         // AI 분석 결과
    private int    hasContradiction; // 모순 탐지 여부 (1=탐지, 0=없음)
    private String stmtType;         // 진술 유형 (피의자/피해자/참고인/목격자)
    private String stmtName;         // 진술자 성명
    private Timestamp createdAt;     // 저장 일시

    // 마이페이지 이력 표시용 JOIN 컬럼 (CASES 테이블)
    private String caseName;         // 사건명
    private String caseStatus;       // 사건 진행 상태

    public TranscriptDTO() {}

    // ── Getters ───────────────────────────────────────────
    public int    getTranscriptId()    { return transcriptId; }
    public String getCaseId()          { return caseId; }
    public String getUserId()          { return userId; }
    public String getOriginalText()    { return originalText; }
    public String getAiResult()        { return aiResult; }
    public int    getHasContradiction(){ return hasContradiction; }
    public String getStmtType()        { return stmtType; }
    public String getStmtName()        { return stmtName; }
    public Timestamp getCreatedAt()    { return createdAt; }
    public String getCaseName()        { return caseName; }
    public String getCaseStatus()      { return caseStatus; }

    // ── Setters ───────────────────────────────────────────
    public void setTranscriptId(int transcriptId)         { this.transcriptId    = transcriptId; }
    public void setCaseId(String caseId)                  { this.caseId          = caseId; }
    public void setUserId(String userId)                  { this.userId          = userId; }
    public void setOriginalText(String originalText)      { this.originalText    = originalText; }
    public void setAiResult(String aiResult)              { this.aiResult        = aiResult; }
    public void setHasContradiction(int hasContradiction) { this.hasContradiction= hasContradiction; }
    public void setStmtType(String stmtType)              { this.stmtType        = stmtType; }
    public void setStmtName(String stmtName)              { this.stmtName        = stmtName; }
    public void setCreatedAt(Timestamp createdAt)         { this.createdAt       = createdAt; }
    public void setCaseName(String caseName)              { this.caseName        = caseName; }
    public void setCaseStatus(String caseStatus)          { this.caseStatus      = caseStatus; }

    @Override
    public String toString() {
        return "TranscriptDTO{transcriptId=" + transcriptId +
               ", caseId='" + caseId + "', stmtName='" + stmtName +
               "', caseStatus='" + caseStatus + "'}";
    }
}
