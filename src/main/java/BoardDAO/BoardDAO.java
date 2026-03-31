package BoardDAO;

import BoardDTO.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BoardDAO {

    private DBConnectionMgr pool;

    public BoardDAO() {
        pool = DBConnectionMgr.getInstance();
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 목록 조회 (카테고리 + 검색 + 정렬)
    // category: "all" | "tip" | "gear" | "free" | "mine"
    // sort:     "latest" | "popular" | "views"
    // ═══════════════════════════════════════════════════════
    public List<BoardPostDTO> getPostList(String category, String keyword, String sort, String loginUserId) {
        List<BoardPostDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder(
            "SELECT p.post_id, p.user_id, p.category, p.title, p.content, " +
            "       p.view_count, p.like_count, p.created_at, p.updated_at, " +
            "       u.user_name, " +
            "       (SELECT COUNT(*) FROM BOARD_COMMENTS c WHERE c.post_id = p.post_id) AS comment_count " +
            "FROM BOARD_POSTS p " +
            "JOIN USERS u ON p.user_id = u.user_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if ("mine".equals(category)) {
            sql.append("AND p.user_id = ? ");
            params.add(loginUserId);
        } else if (!"all".equals(category)) {
            sql.append("AND p.category = ? ");
            params.add(category);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.title LIKE ? OR p.content LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        if ("popular".equals(sort)) {
            sql.append("ORDER BY p.like_count DESC, p.created_at DESC");
        } else if ("views".equals(sort)) {
            sql.append("ORDER BY p.view_count DESC, p.created_at DESC");
        } else {
            sql.append("ORDER BY p.created_at DESC");
        }

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                BoardPostDTO dto = mapPost(rs);
                dto.setCommentCount(rs.getInt("comment_count"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        return list;
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 상세 조회 (태그 + 링크 + 좋아요 포함)
    // ═══════════════════════════════════════════════════════
    public BoardPostDTO getPostById(int postId, String loginUserId) {
        BoardPostDTO dto = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
            "SELECT p.post_id, p.user_id, p.category, p.title, p.content, " +
            "       p.view_count, p.like_count, p.created_at, p.updated_at, " +
            "       u.user_name " +
            "FROM BOARD_POSTS p " +
            "JOIN USERS u ON p.user_id = u.user_id " +
            "WHERE p.post_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            rs = ps.executeQuery();

            if (rs.next()) {
                dto = mapPost(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        if (dto != null) {
            dto.setTags(getTagsByPostId(postId));
            dto.setLinks(getLinksByPostId(postId));
            dto.setLikedByCurrentUser(isLiked(loginUserId, "post", postId));
        }

        return dto;
    }

    // ═══════════════════════════════════════════════════════
    // 조회수 증가
    // ═══════════════════════════════════════════════════════
    public void increaseViewCount(int postId) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "UPDATE BOARD_POSTS SET view_count = view_count + 1 WHERE post_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 등록 (태그 + 링크 함께 insert)
    // ═══════════════════════════════════════════════════════
    public boolean insertPost(BoardPostDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
            "INSERT INTO BOARD_POSTS (user_id, category, title, content, view_count, like_count, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, 0, 0, NOW(), NOW())";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, dto.getUserId());
            ps.setString(2, dto.getCategory());
            ps.setString(3, dto.getTitle());
            ps.setString(4, dto.getContent());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int newPostId = rs.getInt(1);
                dto.setPostId(newPostId);

                // 태그 insert
                if (dto.getTags() != null && !dto.getTags().isEmpty()) {
                    insertTags(newPostId, dto.getTags());
                }
                // 구매링크 insert (gear 카테고리만)
                if ("gear".equals(dto.getCategory()) && dto.getLinks() != null && !dto.getLinks().isEmpty()) {
                    insertLinks(newPostId, dto.getLinks());
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            pool.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 삭제 (태그·링크·댓글·좋아요 cascade 처리)
    // ═══════════════════════════════════════════════════════
    public boolean deletePost(int postId, String loginUserId) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = pool.getConnection();
            conn.setAutoCommit(false);

            // 작성자 본인 확인
            ps = conn.prepareStatement("SELECT user_id FROM BOARD_POSTS WHERE post_id = ?");
            ps.setInt(1, postId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !loginUserId.equals(rs.getString("user_id"))) {
                rs.close();
                conn.rollback();
                return false;
            }
            rs.close();
            ps.close();

            String[] deleteSqls = {
                "DELETE FROM BOARD_LIKES   WHERE target_type='post'    AND target_id = ?",
                "DELETE FROM BOARD_LIKES   WHERE target_type='comment' AND target_id IN (SELECT comment_id FROM BOARD_COMMENTS WHERE post_id = ?)",
                "DELETE FROM BOARD_COMMENTS WHERE post_id = ?",
                "DELETE FROM BOARD_TAGS    WHERE post_id = ?",
                "DELETE FROM BOARD_LINKS   WHERE post_id = ?",
                "DELETE FROM BOARD_POSTS   WHERE post_id = ?"
            };

            for (String deleteSql : deleteSqls) {
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, postId);
                ps.executeUpdate();
                ps.close();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); }
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 태그 조회
    // ═══════════════════════════════════════════════════════
    public List<BoardTagDTO> getTagsByPostId(int postId) {
        List<BoardTagDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT tag_id, post_id, tag_name FROM BOARD_TAGS WHERE post_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            rs = ps.executeQuery();

            while (rs.next()) {
                BoardTagDTO tag = new BoardTagDTO();
                tag.setTagId(rs.getInt("tag_id"));
                tag.setPostId(rs.getInt("post_id"));
                tag.setTagName(rs.getString("tag_name"));
                list.add(tag);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        return list;
    }

    // ═══════════════════════════════════════════════════════
    // 태그 등록
    // ═══════════════════════════════════════════════════════
    public void insertTags(int postId, List<BoardTagDTO> tags) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "INSERT INTO BOARD_TAGS (post_id, tag_name) VALUES (?, ?)";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            for (BoardTagDTO tag : tags) {
                ps.setInt(1, postId);
                ps.setString(2, tag.getTagName());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 구매링크 조회
    // ═══════════════════════════════════════════════════════
    public List<BoardLinkDTO> getLinksByPostId(int postId) {
        List<BoardLinkDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT link_id, post_id, link_name, link_url FROM BOARD_LINKS WHERE post_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            rs = ps.executeQuery();

            while (rs.next()) {
                BoardLinkDTO link = new BoardLinkDTO();
                link.setLinkId(rs.getInt("link_id"));
                link.setPostId(rs.getInt("post_id"));
                link.setLinkName(rs.getString("link_name"));
                link.setLinkUrl(rs.getString("link_url"));
                list.add(link);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        return list;
    }

    // ═══════════════════════════════════════════════════════
    // 구매링크 등록 (최대 3개)
    // ═══════════════════════════════════════════════════════
    public void insertLinks(int postId, List<BoardLinkDTO> links) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "INSERT INTO BOARD_LINKS (post_id, link_name, link_url) VALUES (?, ?, ?)";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            int count = Math.min(links.size(), 3); // 최대 3개
            for (int i = 0; i < count; i++) {
                ps.setInt(1, postId);
                ps.setString(2, links.get(i).getLinkName());
                ps.setString(3, links.get(i).getLinkUrl());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 댓글 목록 조회
    // ═══════════════════════════════════════════════════════
    public List<BoardCommentDTO> getComments(int postId, String loginUserId) {
        List<BoardCommentDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
            "SELECT c.comment_id, c.post_id, c.user_id, c.content, c.created_at, " +
            "       u.user_name, " +
            "       (SELECT COUNT(*) FROM BOARD_LIKES l WHERE l.target_type='comment' AND l.target_id = c.comment_id) AS like_count " +
            "FROM BOARD_COMMENTS c " +
            "JOIN USERS u ON c.user_id = u.user_id " +
            "WHERE c.post_id = ? " +
            "ORDER BY c.created_at ASC";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, postId);
            rs = ps.executeQuery();

            while (rs.next()) {
                BoardCommentDTO dto = new BoardCommentDTO();
                dto.setCommentId(rs.getInt("comment_id"));
                dto.setPostId(rs.getInt("post_id"));
                dto.setUserId(rs.getString("user_id"));
                dto.setContent(rs.getString("content"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUserName(rs.getString("user_name"));
                dto.setLikeCount(rs.getInt("like_count"));
                dto.setLikedByCurrentUser(isLiked(loginUserId, "comment", dto.getCommentId()));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        return list;
    }

    // ═══════════════════════════════════════════════════════
    // 댓글 등록
    // ═══════════════════════════════════════════════════════
    public boolean insertComment(BoardCommentDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "INSERT INTO BOARD_COMMENTS (post_id, user_id, content, created_at) VALUES (?, ?, ?, NOW())";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dto.getPostId());
            ps.setString(2, dto.getUserId());
            ps.setString(3, dto.getContent());
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            pool.freeConnection(conn, ps);
        }
    }
    
 // ═══════════════════════════════════════════════════════
    // 댓글 삭제 (본인 작성 댓글만, 좋아요도 함께 삭제)
    // ═══════════════════════════════════════════════════════
    public boolean deleteComment(int commentId, String loginUserId) {
        Connection conn = null;
        PreparedStatement ps = null;
 
        try {
            conn = pool.getConnection();
            conn.setAutoCommit(false);
 
            // 작성자 본인 확인
            ps = conn.prepareStatement("SELECT user_id FROM BOARD_COMMENTS WHERE comment_id = ?");
            ps.setInt(1, commentId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !loginUserId.equals(rs.getString("user_id"))) {
                rs.close();
                conn.rollback();
                return false;
            }
            rs.close();
            ps.close();
            
            // 댓글 좋아요 삭제
            ps = conn.prepareStatement("DELETE FROM BOARD_LIKES WHERE target_type='comment' AND target_id = ?");
            ps.setInt(1, commentId);
            ps.executeUpdate();
            ps.close();
            
            // 댓글 삭제
            ps = conn.prepareStatement("DELETE FROM BOARD_COMMENTS WHERE comment_id = ?");
            ps.setInt(1, commentId);
            ps.executeUpdate();
            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); }
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 좋아요 여부 확인
    // targetType: "post" | "comment"
    // ═══════════════════════════════════════════════════════
    public boolean isLiked(String userId, String targetType, int targetId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT COUNT(*) FROM BOARD_LIKES WHERE user_id = ? AND target_type = ? AND target_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            ps.setString(2, targetType);
            ps.setInt(3, targetId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        return false;
    }

    // ═══════════════════════════════════════════════════════
    // 좋아요 추가
    // ═══════════════════════════════════════════════════════
    public boolean insertLike(BoardLikeDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "INSERT INTO BOARD_LIKES (user_id, target_type, target_id, created_at) VALUES (?, ?, ?, NOW())";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dto.getUserId());
            ps.setString(2, dto.getTargetType());
            ps.setInt(3, dto.getTargetId());
            ps.executeUpdate();

            // 게시글 추천이면 like_count 캐시 +1
            if ("post".equals(dto.getTargetType())) {
                updateLikeCountCache(dto.getTargetId(), +1);
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 좋아요 취소
    // ═══════════════════════════════════════════════════════
    public boolean deleteLike(BoardLikeDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "DELETE FROM BOARD_LIKES WHERE user_id = ? AND target_type = ? AND target_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dto.getUserId());
            ps.setString(2, dto.getTargetType());
            ps.setInt(3, dto.getTargetId());
            ps.executeUpdate();

            // 게시글 추천이면 like_count 캐시 -1
            if ("post".equals(dto.getTargetType())) {
                updateLikeCountCache(dto.getTargetId(), -1);
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // like_count 캐시 업데이트 (정렬 성능용)
    // ═══════════════════════════════════════════════════════
    private void updateLikeCountCache(int postId, int delta) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = "UPDATE BOARD_POSTS SET like_count = like_count + ? WHERE post_id = ?";

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, delta);
            ps.setInt(2, postId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // ResultSet → BoardPostDTO 매핑 공통 메서드
    // ═══════════════════════════════════════════════════════
    private BoardPostDTO mapPost(ResultSet rs) throws SQLException {
        BoardPostDTO dto = new BoardPostDTO();
        dto.setPostId(rs.getInt("post_id"));
        dto.setUserId(rs.getString("user_id"));
        dto.setCategory(rs.getString("category"));
        dto.setTitle(rs.getString("title"));
        dto.setContent(rs.getString("content"));
        dto.setViewCount(rs.getInt("view_count"));
        dto.setLikeCount(rs.getInt("like_count"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setUpdatedAt(rs.getTimestamp("updated_at"));
        dto.setUserName(rs.getString("user_name"));
        return dto;
    }
}
