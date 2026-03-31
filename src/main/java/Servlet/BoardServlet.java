package Servlet;


import java.io.*;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * 커뮤니티 게시판 서블릿 (DAO/DTO 리팩토링 버전)
 * URL: /board
 *
 * action 파라미터로 기능 분기:
 *   list    - 게시글 목록 조회 (GET)
 *   detail  - 게시글 상세 + 댓글 조회 (GET)
 *   write   - 게시글 등록 (POST)
 *   delete  - 게시글 삭제 (POST)
 *   comment - 댓글 등록 (POST)
 *   like    - 게시글/댓글 추천 토글 (POST)
 */
@WebServlet("/board")
public class BoardServlet extends HttpServlet {

    private final BoardDAO dao = new BoardDAO();
    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy.MM.dd");

    // ═══════════════════════════════════════════════════════
    // GET → list / detail
    // ═══════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json;charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        String loginUser = getLoginUser(req, res);
        if (loginUser == null) return;

        String action = nvl(req.getParameter("action"), "list");

        switch (action) {
            case "list":   handleList(req, res, loginUser);   break;
            case "detail": handleDetail(req, res, loginUser); break;
            default:       writeError(res, "알 수 없는 action");
        }
    }

    // ═══════════════════════════════════════════════════════
    // POST → write / delete / comment / like
    // ═══════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json;charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        String loginUser = getLoginUser(req, res);
        if (loginUser == null) return;

        String action = nvl(req.getParameter("action"), "");

        switch (action) {
            case "write":   handleWrite(request, response, loginUser);   break;
            case "delete":  handleDelete(request, response, loginUser);  break;
            case "comment": handleComment(request, response, loginUser); break;
            case "deleteComment": handleDeleteComment(request, response, loginUser); break;
            case "like":    handleLike(request, response, loginUser);    break;
            default:
                response.getWriter().write("{\"error\":\"알 수 없는 action\"}");
        }
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 목록 조회
    // ═══════════════════════════════════════════════════════
    private void handleList(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String category = nvl(req.getParameter("category"), "all");
        String sort     = nvl(req.getParameter("sort"),     "latest");
        String keyword  = nvl(req.getParameter("keyword"),  "");

        List<BoardPostDTO> posts = dao.getPostList(category, keyword, sort, loginUser);

        JSONArray arr = new JSONArray();
        for (BoardPostDTO post : posts) {
            arr.put(postToJson(post, loginUser, true));
        }
        res.getWriter().write(arr.toString());
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 상세 조회 (조회수 +1, 댓글 포함)
    // ═══════════════════════════════════════════════════════
    private void handleDetail(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        int postId = parseIntParam(req, res, "id");
        if (postId < 0) return;

        // 조회수 증가
        dao.increaseViewCount(postId);

        // 게시글 상세 (태그·링크·추천여부 포함)
        BoardPostDTO post = dao.getPostById(postId, loginUser);
        if (post == null) {
            writeError(res, "게시글을 찾을 수 없습니다.");
            return;
        }

        JSONObject json = postToJson(post, loginUser, false);

        // 댓글 목록
        List<BoardCommentDTO> comments = dao.getComments(postId, loginUser);
        JSONArray cmtArr = new JSONArray();
        for (BoardCommentDTO c : comments) {
            cmtArr.put(commentToJson(c, loginUser));
        }
        json.put("comments", cmtArr);

        res.getWriter().write(json.toString());
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 등록
    // ═══════════════════════════════════════════════════════
    private void handleWrite(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String category = req.getParameter("category");
        String title    = req.getParameter("title");
        String content  = req.getParameter("content");
        String tagsRaw  = nvl(req.getParameter("tags"), "");

        if (isEmpty(category) || isEmpty(title) || isEmpty(content)) {
            writeResult(res, false, "필수 항목을 모두 입력하세요.");
            return;
        }

        // 게시글 DTO 구성
        BoardPostDTO post = new BoardPostDTO();
        post.setUserId(loginUser);
        post.setCategory(category.trim());
        post.setTitle(title.trim());
        post.setContent(content.trim());

        // 태그 파싱
        List<BoardTagDTO> tags = new ArrayList<>();
        for (String t : tagsRaw.split(",")) {
            String trimmed = t.trim();
            if (!trimmed.isEmpty()) tags.add(new BoardTagDTO(0, trimmed));
        }
        post.setTags(tags);

        // 구매링크 파싱 (gear 전용, 최대 3개)
        List<BoardLinkDTO> links = new ArrayList<>();
        if ("gear".equals(category)) {
            String[] linkNames = req.getParameterValues("linkNames");
            String[] linkUrls  = req.getParameterValues("linkUrls");
            if (linkNames != null && linkUrls != null) {
                int max = Math.min(linkNames.length, Math.min(linkUrls.length, 3));
                for (int i = 0; i < max; i++) {
                    String lname = linkNames[i].trim();
                    String lurl  = linkUrls[i].trim();
                    if (!lname.isEmpty() && !lurl.isEmpty()) {
                        links.add(new BoardLinkDTO(0, lname, lurl));
                    }
                }
            }
        }
        post.setLinks(links);

        boolean ok = dao.insertPost(post);
        if (ok) {
            res.getWriter().write("{\"success\":true,\"postId\":" + post.getPostId() + "}");
        } else {
            writeResult(res, false, "게시글 등록 중 오류가 발생했습니다.");
        }
    }

    // ═══════════════════════════════════════════════════════
    // 게시글 삭제 (본인 글만)
    // ═══════════════════════════════════════════════════════
    private void handleDelete(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String idStr = req.getParameter("postId");
        if (idStr == null) {
            res.getWriter().write("{\"success\":false,\"error\":\"postId 필요\"}");
            return;
        }
        int postId;
        try { postId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) {
            res.getWriter().write("{\"success\":false,\"error\":\"잘못된 postId\"}");
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = mgr.getConnection();

            // 작성자 확인
            pstmt = conn.prepareStatement(
                "SELECT user_id FROM board_posts WHERE post_id=?");
            pstmt.setInt(1, postId);
            ResultSet rs = pstmt.executeQuery();
            if (!rs.next() || !loginUser.equals(rs.getString("user_id"))) {
                res.getWriter().write("{\"success\":false,\"error\":\"삭제 권한이 없습니다.\"}");
                rs.close();
                try { conn.rollback(); } catch (Exception ignored) {}
                try { conn.setAutoCommit(true); } catch (Exception ignored) {}  // ← 이게 핵심!
                mgr.freeConnection(conn, pstmt, rs);
                return;
            }
            mgr.freeConnection(null, pstmt, rs);
            pstmt = null;

            // 삭제 (CASCADE로 댓글·태그·링크·추천 자동 삭제)
            pstmt = conn.prepareStatement("DELETE FROM board_posts WHERE post_id=?");
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();

            res.getWriter().write("{\"success\":true}");

        boolean ok = dao.deletePost(postId, loginUser);
        if (ok) {
            writeResult(res, true, "삭제됐습니다.");
        } else {
            writeResult(res, false, "삭제 권한이 없거나 오류가 발생했습니다.");
        }
    }

    // ═══════════════════════════════════════════════════════
    // 댓글 등록
    // ═══════════════════════════════════════════════════════
    private void handleComment(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        int postId = parseIntParam(req, res, "postId");
        if (postId < 0) return;

        String content = req.getParameter("content");
        if (isEmpty(content)) {
            writeResult(res, false, "내용을 입력하세요.");
            return;
        }

        BoardCommentDTO comment = new BoardCommentDTO();
        comment.setPostId(postId);
        comment.setUserId(loginUser);
        comment.setContent(content.trim());

        boolean ok = dao.insertComment(comment);
        writeResult(res, ok, ok ? "등록됐습니다." : "댓글 등록 중 오류가 발생했습니다.");
    }

    /* ═══════════════════════════════════════════════
       댓글 삭제 (본인 댓글만)
       파라미터: commentId
    ═══════════════════════════════════════════════ */
    private void handleDeleteComment(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String idStr = req.getParameter("commentId");
        if (idStr == null) {
            res.getWriter().write("{\"success\":false,\"error\":\"commentId 필요\"}");
            return;
        }
        int commentId;
        try { commentId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) {
            res.getWriter().write("{\"success\":false,\"error\":\"잘못된 commentId\"}");
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();
            conn.setAutoCommit(false);

            // 작성자 확인
            pstmt = conn.prepareStatement(
                "SELECT user_id FROM board_comments WHERE comment_id=?");
            pstmt.setInt(1, commentId);
            rs = pstmt.executeQuery();
            if (!rs.next() || !loginUser.equals(rs.getString("user_id"))) {
                res.getWriter().write("{\"success\":false,\"error\":\"삭제 권한이 없습니다.\"}");
                mgr.freeConnection(conn, pstmt, rs);
                return;
            }
            mgr.freeConnection(null, pstmt, rs);
            pstmt = null; rs = null;

            // 댓글 좋아요 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_likes WHERE target_type='comment' AND target_id=?");
            pstmt.setInt(1, commentId);
            pstmt.executeUpdate();
            mgr.freeConnection(null, pstmt);
            pstmt = null;

            // 댓글 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_comments WHERE comment_id=?");
            pstmt.setInt(1, commentId);
            pstmt.executeUpdate();

            conn.commit();
            res.getWriter().write("{\"success\":true}");

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ignored) {}
            res.getWriter().write("{\"success\":false,\"error\":\"댓글 삭제 중 오류가 발생했습니다.\"}");
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception ignored) {}
            mgr.freeConnection(conn, pstmt, rs);
        }
    }

    /* ═══════════════════════════════════════════════
       추천 토글 (게시글 / 댓글 공용)
       파라미터: targetType(post/comment), targetId
    ═══════════════════════════════════════════════ */
    private void handleLike(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String targetType  = req.getParameter("targetType");
        String targetIdStr = req.getParameter("targetId");

        if (targetType == null || targetIdStr == null) {
            writeResult(res, false, "파라미터 부족");
            return;
        }
        if (!"post".equals(targetType) && !"comment".equals(targetType)) {
            writeResult(res, false, "잘못된 targetType");
            return;
        }

        int targetId;
        try { targetId = Integer.parseInt(targetIdStr); }
        catch (NumberFormatException e) {
            writeResult(res, false, "잘못된 targetId");
            return;
        }

        BoardLikeDTO likeDto = new BoardLikeDTO(loginUser, targetType, targetId);
        boolean alreadyLiked = dao.isLiked(loginUser, targetType, targetId);

        boolean ok = alreadyLiked ? dao.deleteLike(likeDto) : dao.insertLike(likeDto);
        if (!ok) {
            writeResult(res, false, "추천 처리 중 오류가 발생했습니다.");
            return;
        }

        // 현재 추천수 조회
        int currentLikes = 0;
        if ("post".equals(targetType)) {
            BoardPostDTO post = dao.getPostById(targetId, loginUser);
            if (post != null) currentLikes = post.getLikeCount();
        } else {
            currentLikes = dao.getCommentLikeCount(targetId);
        }

        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("liked",   !alreadyLiked);
        result.put("likes",   currentLikes);
        res.getWriter().write(result.toString());
    }

    // ═══════════════════════════════════════════════════════
    // BoardPostDTO → JSONObject 변환
    // listMode=true : 목록용 (preview 80자 + commentCount)
    // listMode=false: 상세용 (전체 content)
    // ═══════════════════════════════════════════════════════
    private JSONObject postToJson(BoardPostDTO p, String loginUser, boolean listMode) {
        JSONObject json = new JSONObject();
        json.put("id",     p.getPostId());
        json.put("cat",    p.getCategory());
        json.put("title",  p.getTitle());
        json.put("views",  p.getViewCount());
        json.put("likes",  p.getLikeCount());
        json.put("hot",    p.isHot());
        json.put("userId", p.getUserId());
        json.put("author", nvl(p.getUserName(), "탈퇴한 수사관"));
        json.put("isMine", loginUser.equals(p.getUserId()));
        json.put("liked",  p.isLikedByCurrentUser());
        json.put("date",   p.getCreatedAt() != null ? DATE_FMT.format(p.getCreatedAt()) : "");

        if (listMode) {
            String content = nvl(p.getContent(), "");
            json.put("preview", content.length() > 80 ? content.substring(0, 80) + "..." : content);
            json.put("commentCount", p.getCommentCount());
        } else {
            json.put("content", nvl(p.getContent(), ""));
        }

        // 태그
        JSONArray tagArr = new JSONArray();
        if (p.getTags() != null) {
            for (BoardTagDTO t : p.getTags()) tagArr.put(t.getTagName());
        }
        json.put("tags", tagArr);

        // 구매링크
        JSONArray linkArr = new JSONArray();
        if (p.getLinks() != null) {
            for (BoardLinkDTO l : p.getLinks()) {
                JSONObject lk = new JSONObject();
                lk.put("name", l.getLinkName());
                lk.put("url",  l.getLinkUrl());
                linkArr.put(lk);
            }
        }
        json.put("links", linkArr);

        return json;
    }

    // ═══════════════════════════════════════════════════════
    // BoardCommentDTO → JSONObject 변환
    // ═══════════════════════════════════════════════════════
    private JSONObject commentToJson(BoardCommentDTO c, String loginUser) {
        JSONObject json = new JSONObject();
        json.put("id",     c.getCommentId());
        json.put("userId", c.getUserId());
        json.put("author", nvl(c.getUserName(), "탈퇴한 수사관"));
        json.put("text",   nvl(c.getContent(), ""));
        json.put("likes",  c.getLikeCount());
        json.put("liked",  c.isLikedByCurrentUser());
        json.put("isMine", loginUser.equals(c.getUserId()));
        json.put("time",   c.getCreatedAt() != null ? formatRelativeTime(c.getCreatedAt()) : "");
        return json;
    }

    // ═══════════════════════════════════════════════════════
    // 헬퍼 메서드
    // ═══════════════════════════════════════════════════════

    /** 세션에서 loginUser 추출. 없으면 오류 응답 후 null 반환 */
    private String getLoginUser(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        String loginUser = (session != null) ? (String) session.getAttribute("loginUser") : null;
        if (loginUser == null) writeError(res, "로그인이 필요합니다.");
        return loginUser;
    }

    /** int 파라미터 파싱. 실패 시 오류 응답 후 -1 반환 */
    private int parseIntParam(HttpServletRequest req, HttpServletResponse res, String name)
            throws IOException {
        String val = req.getParameter(name);
        if (val == null || val.isEmpty()) {
            writeResult(res, false, name + "이(가) 필요합니다.");
            return -1;
        }
        try {
            return Integer.parseInt(val);
        } catch (NumberFormatException e) {
            writeResult(res, false, "잘못된 " + name);
            return -1;
        }
    }

    private void writeError(HttpServletResponse res, String msg) throws IOException {
        res.getWriter().write(new JSONObject().put("error", msg).toString());
    }

    private void writeResult(HttpServletResponse res, boolean success, String msg) throws IOException {
        JSONObject json = new JSONObject();
        json.put("success", success);
        json.put("message", msg);
        res.getWriter().write(json.toString());
    }

    private String nvl(String s, String def) { return (s == null || s.isEmpty()) ? def : s; }
    private String nvl(String s)             { return nvl(s, ""); }
    private boolean isEmpty(String s)        { return s == null || s.trim().isEmpty(); }

    /** N분 전 / N시간 전 / N일 전 포맷 */
    private String formatRelativeTime(Timestamp ts) {
        long minutes = (System.currentTimeMillis() - ts.getTime()) / 60_000;
        if (minutes < 1)  return "방금 전";
        if (minutes < 60) return minutes + "분 전";
        long hours = minutes / 60;
        if (hours < 24)   return hours + "시간 전";
        return (hours / 24) + "일 전";
    }
}
