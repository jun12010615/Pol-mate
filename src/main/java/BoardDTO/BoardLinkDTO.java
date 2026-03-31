package BoardDTO;

/**
 * BOARD_LINKS 테이블 DTO
 * 수사 장비 구매 링크 (gear 카테고리 전용, 게시글당 최대 3개)
 */
public class BoardLinkDTO {

    private int linkId;      // PK - 링크 고유 번호 (자동증가)
    private int postId;      // FK → BOARD_POSTS - 소속 게시글
    private String linkName; // 링크 이름 (예: 쿠팡, 네이버쇼핑)
    private String linkUrl;  // 구매 URL (최대 500자)

    public BoardLinkDTO() {}

    public BoardLinkDTO(int postId, String linkName, String linkUrl) {
        this.postId = postId;
        this.linkName = linkName;
        this.linkUrl = linkUrl;
    }

    // ─── Getters & Setters ──────────────────────────────────────────────

    public int getLinkId() { return linkId; }
    public void setLinkId(int linkId) { this.linkId = linkId; }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public String getLinkName() { return linkName; }
    public void setLinkName(String linkName) { this.linkName = linkName; }

    public String getLinkUrl() { return linkUrl; }
    public void setLinkUrl(String linkUrl) { this.linkUrl = linkUrl; }

    @Override
    public String toString() {
        return "BoardLinkDTO{" +
                "linkId=" + linkId +
                ", postId=" + postId +
                ", linkName='" + linkName + '\'' +
                ", linkUrl='" + linkUrl + '\'' +
                '}';
    }
}
