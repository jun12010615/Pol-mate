package Servlet;

import BoardDAO.BoardDAO;
import BoardDTO.*;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.util.List;

/**
 * BoardServlet
 * board.jsp 의 모든 AJAX 요청을 처리합니다.
 *
 * [URL 구조]
 * GET  /board                          → board.jsp 포워드 (목록 페이지)
 * GET  /board?action=list              → 게시글 목록 JSON
 * GET  /board?action=detail&postId=1   → 게시글 상세 JSON
 * POST /board?action=write             → 게시글 등록
 * POST /board?action=delete            → 게시글 삭제
 * POST /board?action=comment           → 댓글 등록
 * POST /board?action=like              → 좋아요 토글 (post / comment)
 */
@WebServlet("/board")
public class BoardServlet extends HttpServlet {

    private BoardDAO boardDAO;

    @Override
    public void init() {
        boardDAO = new BoardDAO();
    }

    // ═══════════════════════════════════════════════════════
    // GET
    // ═══════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        // action 없으면 → board.jsp 포워드
        if (action == null) {
            req.getRequestDispatcher("/board.jsp").forward(req, resp);
            return;
        }

        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // 로그인 체크
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            out.print("{\"result\":\"fail\",\"msg\":\"로그인이 필요합니다.\"}");
            return;
        }
        String loginUserId = (String) session.getAttribute("loginUser");

        switch (action) {

            // ── 게시글 목록 ──────────────────────────────────
            case "list":
                String category = nvl(req.getParameter("category"), "all");
                String keyword  = nvl(req.getParameter("keyword"),  "");
                String sort     = nvl(req.getParameter("sort"),     "latest");

                List<BoardPostDTO> posts = boardDAO.getPostList(category, keyword, sort, loginUserId);
                out.print(postListToJson(posts));
                break;

            // ── 게시글 상세 ──────────────────────────────────
            case "detail":
                int postId = toInt(req.getParameter("postId"), 0);
                if (postId == 0) {
                    out.print("{\"result\":\"fail\",\"msg\":\"잘못된 요청입니다.\"}");
                    break;
                }
                boardDAO.increaseViewCount(postId);
                BoardPostDTO post = boardDAO.getPostById(postId, loginUserId);
                List<BoardCommentDTO> comments = boardDAO.getComments(postId, loginUserId);

                if (post == null) {
                    out.print("{\"result\":\"fail\",\"msg\":\"게시글을 찾을 수 없습니다.\"}");
                } else {
                    out.print(postDetailToJson(post, comments));
                }
                break;

            default:
                out.print("{\"result\":\"fail\",\"msg\":\"알 수 없는 요청입니다.\"}");
        }
    }

    // ═══════════════════════════════════════════════════════
    // POST
    // ═══════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        PrintWriter out = resp.getWriter();

        // 로그인 체크
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            out.print("{\"result\":\"fail\",\"msg\":\"로그인이 필요합니다.\"}");
            return;
        }
        String loginUserId = (String) session.getAttribute("loginUser");

        String action = nvl(req.getParameter("action"), "");

        switch (action) {

            // ── 게시글 등록 ──────────────────────────────────
            case "write":
                String category = nvl(req.getParameter("category"), "");
                String title    = nvl(req.getParameter("title"),    "");
                String content  = nvl(req.getParameter("content"),  "");
                String tagsRaw  = nvl(req.getParameter("tags"),     "");

                if (category.isEmpty() || title.isEmpty() || content.isEmpty()) {
                    out.print("{\"result\":\"fail\",\"msg\":\"카테고리, 제목, 내용은 필수입니다.\"}");
                    break;
                }

                BoardPostDTO newPost = new BoardPostDTO();
                newPost.setUserId(loginUserId);
                newPost.setCategory(category);
                newPost.setTitle(title);
                newPost.setContent(content);

                // 태그 파싱 (쉼표 구분)
                if (!tagsRaw.isEmpty()) {
                    List<BoardTagDTO> tagList = new java.util.ArrayList<>();
                    for (String t : tagsRaw.split(",")) {
                        String trimmed = t.trim();
                        if (!trimmed.isEmpty()) {
                            tagList.add(new BoardTagDTO(0, trimmed));
                        }
                    }
                    newPost.setTags(tagList);
                }

                // 구매링크 파싱 (gear 전용, 최대 3개)
                // 파라미터: linkName0, linkUrl0, linkName1, linkUrl1, linkName2, linkUrl2
                if ("gear".equals(category)) {
                    List<BoardLinkDTO> linkList = new java.util.ArrayList<>();
                    for (int i = 0; i < 3; i++) {
                        String lName = nvl(req.getParameter("linkName" + i), "");
                        String lUrl  = nvl(req.getParameter("linkUrl"  + i), "");
                        if (!lName.isEmpty() && !lUrl.isEmpty()) {
                            linkList.add(new BoardLinkDTO(0, lName, lUrl));
                        }
                    }
                    newPost.setLinks(linkList);
                }

                boolean writeOk = boardDAO.insertPost(newPost);
                out.print(writeOk
                    ? "{\"result\":\"ok\",\"msg\":\"게시글이 등록됐습니다.\",\"postId\":" + newPost.getPostId() + "}"
                    : "{\"result\":\"fail\",\"msg\":\"게시글 등록에 실패했습니다.\"}");
                break;

            // ── 게시글 삭제 ──────────────────────────────────
            case "delete":
                int deletePostId = toInt(req.getParameter("postId"), 0);
                if (deletePostId == 0) {
                    out.print("{\"result\":\"fail\",\"msg\":\"잘못된 요청입니다.\"}");
                    break;
                }
                boolean deleteOk = boardDAO.deletePost(deletePostId, loginUserId);
                out.print(deleteOk
                    ? "{\"result\":\"ok\",\"msg\":\"삭제됐습니다.\"}"
                    : "{\"result\":\"fail\",\"msg\":\"삭제 권한이 없거나 실패했습니다.\"}");
                break;

            // ── 댓글 등록 ────────────────────────────────────
            case "comment":
                int commentPostId = toInt(req.getParameter("postId"), 0);
                String commentContent = nvl(req.getParameter("content"), "");

                if (commentPostId == 0 || commentContent.isEmpty()) {
                    out.print("{\"result\":\"fail\",\"msg\":\"댓글 내용을 입력하세요.\"}");
                    break;
                }

                BoardCommentDTO newComment = new BoardCommentDTO();
                newComment.setPostId(commentPostId);
                newComment.setUserId(loginUserId);
                newComment.setContent(commentContent);

                boolean commentOk = boardDAO.insertComment(newComment);
                out.print(commentOk
                    ? "{\"result\":\"ok\",\"msg\":\"댓글이 등록됐습니다.\"}"
                    : "{\"result\":\"fail\",\"msg\":\"댓글 등록에 실패했습니다.\"}");
                break;

            // ── 좋아요 토글 ──────────────────────────────────
            // targetType: "post" | "comment"
            case "like":
                String targetType = nvl(req.getParameter("targetType"), "");
                int    targetId   = toInt(req.getParameter("targetId"), 0);

                if (targetId == 0 || (!targetType.equals("post") && !targetType.equals("comment"))) {
                    out.print("{\"result\":\"fail\",\"msg\":\"잘못된 요청입니다.\"}");
                    break;
                }

                BoardLikeDTO likeDto = new BoardLikeDTO(loginUserId, targetType, targetId);
                boolean alreadyLiked = boardDAO.isLiked(loginUserId, targetType, targetId);

                boolean likeOk;
                String  likeState;
                if (alreadyLiked) {
                    likeOk    = boardDAO.deleteLike(likeDto);
                    likeState = "unliked";
                } else {
                    likeOk    = boardDAO.insertLike(likeDto);
                    likeState = "liked";
                }

                out.print(likeOk
                    ? "{\"result\":\"ok\",\"state\":\"" + likeState + "\"}"
                    : "{\"result\":\"fail\",\"msg\":\"좋아요 처리에 실패했습니다.\"}");
                break;

            default:
                out.print("{\"result\":\"fail\",\"msg\":\"알 수 없는 요청입니다.\"}");
        }
    }

    // ═══════════════════════════════════════════════════════
    // JSON 직렬화 - 게시글 목록
    // ═══════════════════════════════════════════════════════
    private String postListToJson(List<BoardPostDTO> list) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"result\":\"ok\",\"posts\":[");
        for (int i = 0; i < list.size(); i++) {
            BoardPostDTO p = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"postId\":"      ).append(p.getPostId()).append(",");
            sb.append("\"userId\":\""    ).append(esc(p.getUserId())).append("\",");
            sb.append("\"userName\":\""  ).append(esc(p.getUserName())).append("\",");
            sb.append("\"category\":\""  ).append(esc(p.getCategory())).append("\",");
            sb.append("\"title\":\""     ).append(esc(p.getTitle())).append("\",");
            sb.append("\"preview\":\""   ).append(esc(preview(p.getContent()))).append("\",");
            sb.append("\"viewCount\":"   ).append(p.getViewCount()).append(",");
            sb.append("\"likeCount\":"   ).append(p.getLikeCount()).append(",");
            sb.append("\"commentCount\":").append(p.getCommentCount()).append(",");
            sb.append("\"isHot\":"       ).append(p.isHot()).append(",");
            sb.append("\"createdAt\":\""  ).append(p.getCreatedAt()).append("\"");
            sb.append("}");
        }
        sb.append("]}");
        return sb.toString();
    }

    // ═══════════════════════════════════════════════════════
    // JSON 직렬화 - 게시글 상세
    // ═══════════════════════════════════════════════════════
    private String postDetailToJson(BoardPostDTO p, List<BoardCommentDTO> comments) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"result\":\"ok\",\"post\":{");
        sb.append("\"postId\":"     ).append(p.getPostId()).append(",");
        sb.append("\"userId\":\""   ).append(esc(p.getUserId())).append("\",");
        sb.append("\"userName\":\"" ).append(esc(p.getUserName())).append("\",");
        sb.append("\"category\":\"" ).append(esc(p.getCategory())).append("\",");
        sb.append("\"title\":\""    ).append(esc(p.getTitle())).append("\",");
        sb.append("\"content\":\""  ).append(esc(p.getContent())).append("\",");
        sb.append("\"viewCount\":"  ).append(p.getViewCount()).append(",");
        sb.append("\"likeCount\":"  ).append(p.getLikeCount()).append(",");
        sb.append("\"isHot\":"      ).append(p.isHot()).append(",");
        sb.append("\"liked\":"      ).append(p.isLikedByCurrentUser()).append(",");
        sb.append("\"createdAt\":\"").append(p.getCreatedAt()).append("\",");
        sb.append("\"updatedAt\":\"").append(p.getUpdatedAt()).append("\",");

        // 태그
        sb.append("\"tags\":[");
        List<BoardTagDTO> tags = p.getTags();
        if (tags != null) {
            for (int i = 0; i < tags.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append("\"").append(esc(tags.get(i).getTagName())).append("\"");
            }
        }
        sb.append("],");

        // 구매링크
        sb.append("\"links\":[");
        List<BoardLinkDTO> links = p.getLinks();
        if (links != null) {
            for (int i = 0; i < links.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"linkName\":\"").append(esc(links.get(i).getLinkName())).append("\",");
                sb.append("\"linkUrl\":\"" ).append(esc(links.get(i).getLinkUrl())).append("\"");
                sb.append("}");
            }
        }
        sb.append("]},");

        // 댓글
        sb.append("\"comments\":[");
        for (int i = 0; i < comments.size(); i++) {
            BoardCommentDTO c = comments.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"commentId\":"  ).append(c.getCommentId()).append(",");
            sb.append("\"userId\":\""   ).append(esc(c.getUserId())).append("\",");
            sb.append("\"userName\":\"" ).append(esc(c.getUserName())).append("\",");
            sb.append("\"content\":\""  ).append(esc(c.getContent())).append("\",");
            sb.append("\"likeCount\":"  ).append(c.getLikeCount()).append(",");
            sb.append("\"liked\":"      ).append(c.isLikedByCurrentUser()).append(",");
            sb.append("\"createdAt\":\"").append(c.getCreatedAt()).append("\"");
            sb.append("}");
        }
        sb.append("]}");

        return sb.toString();
    }

    // ═══════════════════════════════════════════════════════
    // 유틸
    // ═══════════════════════════════════════════════════════

    /** null 이면 기본값 반환 */
    private String nvl(String s, String def) {
        return (s != null && !s.isEmpty()) ? s : def;
    }

    /** 숫자 파싱 실패 시 기본값 반환 */
    private int toInt(String s, int def) {
        try { return Integer.parseInt(s); }
        catch (Exception e) { return def; }
    }

    /** JSON 문자열 이스케이프 */
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    /** 미리보기 텍스트 (80자 자르기) */
    private String preview(String content) {
        if (content == null) return "";
        return content.length() > 80 ? content.substring(0, 80) + "..." : content;
    }
}
