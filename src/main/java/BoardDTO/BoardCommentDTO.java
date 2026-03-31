package BoardDTO;

import java.sql.Timestamp;

/**
 * BOARD_COMMENTS 테이블 DTO
 * 게시글 댓글
 * ※ like_count 컬럼 없음 - BOARD_LIKES 집계로 처리
 */
public class BoardCommentDTO {

    private int commentId;        // PK - 댓글 고유 번호 (자동증가)
    private int postId;           // FK → BOARD_POSTS - 소속 게시글
    private String userId;        // FK → USERS - 작성 수사관
    private String content;       // 댓글 내용
    private Timestamp createdAt;  // 작성 일시

    // 조회 시 함께 가져오는 연관 데이터 (DB 컬럼 아님)
    private String userName;             // 작성자 실명 (USERS.user_name)
    private int likeCount;              // BOARD_LIKES에서 집계한 추천수
    private boolean likedByCurrentUser; // 현재 로그인 수사관의 추천 여부

    public BoardCommentDTO() {}

    // ─── Getters & Setters ──────────────────────────────────────────────

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public boolean isLikedByCurrentUser() { return likedByCurrentUser; }
    public void setLikedByCurrentUser(boolean likedByCurrentUser) { this.likedByCurrentUser = likedByCurrentUser; }

    @Override
    public String toString() {
        return "BoardCommentDTO{" +
                "commentId=" + commentId +
                ", postId=" + postId +
                ", userId='" + userId + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
