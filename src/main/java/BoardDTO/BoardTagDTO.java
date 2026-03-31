package BoardDTO;

/**
 * BOARD_TAGS 테이블 DTO
 * 게시글 태그 (게시글 1개에 여러 태그 가능, 별도 테이블 분리)
 */
public class BoardTagDTO {

    private int tagId;      // PK - 태그 고유 번호 (자동증가)
    private int postId;     // FK → BOARD_POSTS - 소속 게시글
    private String tagName; // 태그 텍스트 (예: 절도, 심문기법)

    public BoardTagDTO() {}

    public BoardTagDTO(int postId, String tagName) {
        this.postId = postId;
        this.tagName = tagName;
    }

    // ─── Getters & Setters ──────────────────────────────────────────────

    public int getTagId() { return tagId; }
    public void setTagId(int tagId) { this.tagId = tagId; }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public String getTagName() { return tagName; }
    public void setTagName(String tagName) { this.tagName = tagName; }

    @Override
    public String toString() {
        return "BoardTagDTO{" +
                "tagId=" + tagId +
                ", postId=" + postId +
                ", tagName='" + tagName + '\'' +
                '}';
    }
}
