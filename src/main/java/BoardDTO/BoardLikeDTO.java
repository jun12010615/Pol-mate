package BoardDTO;

import java.sql.Timestamp;

/**
 * BOARD_LIKES 테이블 DTO
 * 게시글·댓글 추천 중복 방지
 * ※ like_id PK 없음 - (user_id, target_type, target_id) UNIQUE 제약이 PK 역할
 * ※ target_type: "post" → BOARD_POSTS.post_id 참조
 *                "comment" → BOARD_COMMENTS.comment_id 참조
 */
public class BoardLikeDTO {

    private String userId;      // FK → USERS - 추천한 수사관
    private String targetType;  // 대상 종류 (post / comment)
    private int targetId;       // 대상 post_id 또는 comment_id
    private Timestamp createdAt; // 추천 일시

    public BoardLikeDTO() {}

    public BoardLikeDTO(String userId, String targetType, int targetId) {
        this.userId = userId;
        this.targetType = targetType;
        this.targetId = targetId;
    }

    // ─── Getters & Setters ──────────────────────────────────────────────

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public int getTargetId() { return targetId; }
    public void setTargetId(int targetId) { this.targetId = targetId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // ─── 편의 메서드 ────────────────────────────────────────────────────

    /** 게시글 추천 여부 */
    public boolean isPostLike() { return "post".equals(targetType); }

    /** 댓글 추천 여부 */
    public boolean isCommentLike() { return "comment".equals(targetType); }

    @Override
    public String toString() {
        return "BoardLikeDTO{" +
                "userId='" + userId + '\'' +
                ", targetType='" + targetType + '\'' +
                ", targetId=" + targetId +
                ", createdAt=" + createdAt +
                '}';
    }
}
