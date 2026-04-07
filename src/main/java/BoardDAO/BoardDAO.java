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
    // sort:     "latest" | "popular"
    // ═══════════════════════════════════════════════════════
    public List<BoardPostDTO> getPostList(String category, String keyword, String sort, String loginUserId) {
        List<BoardPostDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder(
            "SELECT p.post_id, p.user_id, p.category, p.title, p.content, " +
            "       p.view_count, p.like_count, p.created_at, p.updated_at, p.anonymous, " +
            "       u.user_name, " +
            "       (SELECT COUNT(*) FROM board_comments c WHERE c.post_id = p.post_id) AS comment_count " +
            "FROM board_posts p " +
            "LEFT JOIN users u ON p.user_id = u.user_id " +
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
    // 게시글 상세 조회 (태그 + 링크 + 추천여부 포함)
    // ═══════════════════════════════════════════════════════
    public BoardPostDTO getPostById(int postId, String loginUserId) {
        BoardPostDTO dto = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
            "SELECT p.post_id, p.user_id, p.category, p.title, p.content, " +
            "       p.view_count, p.like_count, p.created_at, p.updated_at, p.anonymous, " +
            "       u.user_name " +
            "FROM board_posts p " +
            "LEFT JOIN users u ON p.user_id = u.user_id " +
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

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "UPDATE board_posts SET view_count = view_count + 1 WHERE post_id = ?");
            ps.setInt(1, postId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 등록 (태그 + 링크 함께 insert, 트랜잭션)
    // ═══════════════════════════════════════════════════════
    public boolean insertPost(BoardPostDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = pool.getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(
                "INSERT INTO board_posts (user_id, category, title, content, anonymous) VALUES (?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, dto.getUserId());
            ps.setString(2, dto.getCategory());
            ps.setString(3, dto.getTitle());
            ps.setString(4, dto.getContent());
            ps.setInt(5, dto.isAnonymous() ? 1 : 0);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int newPostId = rs.getInt(1);
                dto.setPostId(newPostId);

                // 태그 insert
                if (dto.getTags() != null && !dto.getTags().isEmpty()) {
                    insertTags(conn, newPostId, dto.getTags());
                }
                // 구매링크 insert (gear 카테고리만)
                if ("gear".equals(dto.getCategory()) && dto.getLinks() != null && !dto.getLinks().isEmpty()) {
                    insertLinks(conn, newPostId, dto.getLinks());
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); }
            pool.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 삭제 (본인 확인 + 트랜잭션)
    // ═══════════════════════════════════════════════════════
    public boolean deletePost(int postId, String loginUserId) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = pool.getConnection();
            conn.setAutoCommit(false);

            // 작성자 본인 확인
            ps = conn.prepareStatement("SELECT user_id FROM board_posts WHERE post_id = ?");
            ps.setInt(1, postId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !loginUserId.equals(rs.getString("user_id"))) {
                rs.close();
                conn.rollback();
                return false;
            }
            rs.close();
            ps.close();

            // CASCADE 수동 삭제 (FK 설정이 없는 환경 대비)
            String[] deleteSqls = {
                "DELETE FROM board_likes    WHERE target_type='post'    AND target_id = ?",
                "DELETE FROM board_likes    WHERE target_type='comment' AND target_id IN (SELECT comment_id FROM board_comments WHERE post_id = ?)",
                "DELETE FROM board_comments WHERE post_id = ?",
                "DELETE FROM board_tags     WHERE post_id = ?",
                "DELETE FROM board_links    WHERE post_id = ?",
                "DELETE FROM board_posts    WHERE post_id = ?"
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

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "SELECT tag_id, post_id, tag_name FROM board_tags WHERE post_id = ? ORDER BY tag_id");
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
    // 태그 등록 (배치, 트랜잭션 내 호출용)
    // ═══════════════════════════════════════════════════════
    private void insertTags(Connection conn, int postId, List<BoardTagDTO> tags) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO board_tags (post_id, tag_name) VALUES (?, ?)");
        for (BoardTagDTO tag : tags) {
            ps.setInt(1, postId);
            ps.setString(2, tag.getTagName());
            ps.addBatch();
        }
        ps.executeBatch();
        ps.close();
    }

    // ═══════════════════════════════════════════════════════
    // 구매링크 조회
    // ═══════════════════════════════════════════════════════
    public List<BoardLinkDTO> getLinksByPostId(int postId) {
        List<BoardLinkDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "SELECT link_id, post_id, link_name, link_url FROM board_links WHERE post_id = ? ORDER BY link_id");
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
    // 구매링크 등록 (배치, 트랜잭션 내 호출용, 최대 3개)
    // ═══════════════════════════════════════════════════════
    private void insertLinks(Connection conn, int postId, List<BoardLinkDTO> links) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO board_links (post_id, link_name, link_url) VALUES (?, ?, ?)");
        int count = Math.min(links.size(), 3);
        for (int i = 0; i < count; i++) {
            ps.setInt(1, postId);
            ps.setString(2, links.get(i).getLinkName());
            ps.setString(3, links.get(i).getLinkUrl());
            ps.addBatch();
        }
        ps.executeBatch();
        ps.close();
    }

    // ═══════════════════════════════════════════════════════
    // 댓글 목록 조회 (좋아요 집계 + 현재 사용자 추천 여부 포함)
    // ═══════════════════════════════════════════════════════
    public List<BoardCommentDTO> getComments(int postId, String loginUserId) {
        List<BoardCommentDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
            "SELECT c.comment_id, c.post_id, c.user_id, c.content, c.created_at, " +
            "       u.user_name, " +
            "       (SELECT COUNT(*) FROM board_likes l " +
            "        WHERE l.target_type='comment' AND l.target_id = c.comment_id) AS like_count " +
            "FROM board_comments c " +
            "LEFT JOIN users u ON c.user_id = u.user_id " +
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

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO board_comments (post_id, user_id, content) VALUES (?, ?, ?)");
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
    // 추천 여부 확인
    // ═══════════════════════════════════════════════════════
    public boolean isLiked(String userId, String targetType, int targetId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM board_likes " +
                "WHERE user_id = ? AND target_type = ? AND target_id = ?");
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
    // 추천 추가 (like_count 캐시 +1)
    // ═══════════════════════════════════════════════════════
    public boolean insertLike(BoardLikeDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "INSERT INTO board_likes (user_id, target_type, target_id) VALUES (?, ?, ?)");
            ps.setString(1, dto.getUserId());
            ps.setString(2, dto.getTargetType());
            ps.setInt(3, dto.getTargetId());
            ps.executeUpdate();

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
    // 추천 취소 (like_count 캐시 -1)
    // ═══════════════════════════════════════════════════════
    public boolean deleteLike(BoardLikeDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "DELETE FROM board_likes " +
                "WHERE user_id = ? AND target_type = ? AND target_id = ?");
            ps.setString(1, dto.getUserId());
            ps.setString(2, dto.getTargetType());
            ps.setInt(3, dto.getTargetId());
            ps.executeUpdate();

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
    // 댓글 추천 수 조회 (BoardServlet handleLike에서 사용)
    // ═══════════════════════════════════════════════════════
    public int getCommentLikeCount(int commentId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = pool.getConnection();
            ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM board_likes " +
                "WHERE target_type = 'comment' AND target_id = ?");
            ps.setInt(1, commentId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, ps, rs);
        }

        return 0;
    }

    // ═══════════════════════════════════════════════════════
    // like_count 캐시 업데이트 (정렬 성능용)
    // ═══════════════════════════════════════════════════════
    private void updateLikeCountCache(int postId, int delta) {
        Connection conn = null;
        PreparedStatement ps = null;

        String sql = delta > 0
            ? "UPDATE board_posts SET like_count = like_count + 1 WHERE post_id = ?"
            : "UPDATE board_posts SET like_count = GREATEST(like_count - 1, 0) WHERE post_id = ?";

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
    // ResultSet → BoardPostDTO 공통 매핑
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
        dto.setUserName(rs.getString("user_name"));
        dto.setAnonymous(rs.getInt("anonymous") == 1);
        return dto;
    }
}
