package BoardDTO;

import java.sql.Timestamp;
import java.util.List;

/**
 * BOARD_POSTS 테이블 DTO
 * 게시글 본체 (카테고리: tip / gear / free)
 */
public class BoardPostDTO {

    private int postId;           // PK - 게시글 고유 번호 (자동증가)
    private String userId;        // FK → USERS - 작성 수사관
    private String category;      // 카테고리 (tip / gear / free)
    private String title;         // 게시글 제목
    private String content;       // 본문 내용
    private int viewCount;        // 조회수 (기본값 0)
    private int likeCount;        // 추천수 캐시 (기본값 0) - 정렬 성능용
    private Timestamp createdAt;  // 작성 일시
    private Timestamp updatedAt;  // 수정 일시
    private boolean anonymous;  //익명글


	// 조회 시 함께 가져오는 연관 데이터 (DB 컬럼 아님)
    private String userName;              // 작성자 실명 (USERS.user_name)
    private boolean isHot;               // 런타임 계산: likeCount >= 40
    private boolean likedByCurrentUser;  // 현재 로그인 수사관의 추천 여부
    private List<BoardTagDTO> tags;       // 태그 목록
    private List<BoardLinkDTO> links;    // 구매 링크 목록 (gear 전용, 최대 3개)
    private int commentCount;            // 댓글 수 (집계)

    public BoardPostDTO() {}

    // ─── Getters & Setters ──────────────────────────────────────────────

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public boolean isAnonymous() {return anonymous;}
  	public void setAnonymous(boolean anonymous) {this.anonymous = anonymous;}

    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public boolean isHot() { return likeCount >= 40; }  // board.jsp 기준

    public boolean isLikedByCurrentUser() { return likedByCurrentUser; }
    public void setLikedByCurrentUser(boolean likedByCurrentUser) { this.likedByCurrentUser = likedByCurrentUser; }

    public List<BoardTagDTO> getTags() { return tags; }
    public void setTags(List<BoardTagDTO> tags) { this.tags = tags; }

    public List<BoardLinkDTO> getLinks() { return links; }
    public void setLinks(List<BoardLinkDTO> links) { this.links = links; }

    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }

    @Override
    public String toString() {
        return "BoardPostDTO{" +
                "postId=" + postId +
                ", userId='" + userId + '\'' +
                ", category='" + category + '\'' +
                ", title='" + title + '\'' +
                ", viewCount=" + viewCount +
                ", likeCount=" + likeCount +
                ", createdAt=" + createdAt +
                '}';
    }
}
