package myPageDTO;

/**
 * 마이페이지 "활동 통계" 드로어 전용 DTO
 * CASES, TRANSCRIPTS 집계 결과를 담는다.
 */
public class MypageStatsDTO {

    private int activeCases;       // 진행 중인 사건 수 (status = '진행중')
    private int contradictionCount;// 모순 탐지된 조서 수 (has_contradiction = 1)
    private int completedTranscripts; // 완료 조서 수 (case status = '완료')
    private int totalCases;        // 전체 담당 사건 수
    private int totalTranscripts;  // 전체 작성 조서 수
    private int relationEdges;     // 등록 관계망 수 (RELATION_PERSONS 기준)

    public MypageStatsDTO() {}

    // ── Getters ───────────────────────────────────────────
    public int getActiveCases()            { return activeCases; }
    public int getContradictionCount()     { return contradictionCount; }
    public int getCompletedTranscripts()   { return completedTranscripts; }
    public int getTotalCases()             { return totalCases; }
    public int getTotalTranscripts()       { return totalTranscripts; }
    public int getRelationEdges()          { return relationEdges; }

    // ── Setters ───────────────────────────────────────────
    public void setActiveCases(int activeCases)                   { this.activeCases            = activeCases; }
    public void setContradictionCount(int contradictionCount)     { this.contradictionCount     = contradictionCount; }
    public void setCompletedTranscripts(int completedTranscripts) { this.completedTranscripts   = completedTranscripts; }
    public void setTotalCases(int totalCases)                     { this.totalCases             = totalCases; }
    public void setTotalTranscripts(int totalTranscripts)         { this.totalTranscripts       = totalTranscripts; }
    public void setRelationEdges(int relationEdges)               { this.relationEdges          = relationEdges; }

    @Override
    public String toString() {
        return "MypageStatsDTO{activeCases=" + activeCases +
               ", contradictionCount=" + contradictionCount +
               ", completedTranscripts=" + completedTranscripts +
               ", totalCases=" + totalCases + "}";
    }
}
