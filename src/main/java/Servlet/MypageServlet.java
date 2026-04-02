package Servlet;

import com.google.gson.Gson;
import myPageDAO.MypageDAO;
import myPageDTO.MypageStatsDTO;
import myPageDTO.TranscriptDTO;
import myPageDTO.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * MypageServlet
 * URL 패턴: /mypage
 *
 * mypage.jsp에서 발생하는 모든 AJAX 요청을 처리한다.
 * action 파라미터로 기능을 구분한다:
 *
 *  GET  action=load        → 프로필 + 통계 초기 데이터 로드
 *  GET  action=history     → 내 조서 이력 조회
 *  GET  action=stats       → 활동 통계 조회
 *  POST action=updateProfile → 프로필 수정
 *  POST action=changePassword → 비밀번호 변경
 *  POST action=logout      → 세션 무효화 (로그아웃)
 */
@WebServlet("/mypage")
public class MypageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final MypageDAO dao  = new MypageDAO();
    private final Gson      gson = new Gson();

    // ════════════════════════════════════════════════════════════════
    // GET 처리
    // ════════════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        // ── 세션 체크 ────────────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            sendError(resp, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
            return;
        }

        String userId = (String) session.getAttribute("loginUser");
        String action = req.getParameter("action");

        if (action == null) action = "";

        switch (action) {

            // ── 초기 로드: 프로필 + 통계 ────────────────────────
            case "load": {
                UserDTO       user  = dao.getUserById(userId);
                MypageStatsDTO stats = dao.getStats(userId);

                if (user == null) {
                    sendError(resp, HttpServletResponse.SC_NOT_FOUND, "사용자 정보를 찾을 수 없습니다.");
                    return;
                }

                Map<String, Object> result = new HashMap<>();
                result.put("user",     toSafeUserMap(user));
                result.put("stats",    stats);
                result.put("settings", dao.getSettings(userId));
                sendJson(resp, result);
                break;
            }

            // ── 내 조서 이력 ─────────────────────────────────────
            case "history": {
                List<TranscriptDTO> history = dao.getTranscriptHistory(userId, 20);
                Map<String, Object> result  = new HashMap<>();
                result.put("history", history);
                sendJson(resp, result);
                break;
            }

            // ── 활동 통계 ────────────────────────────────────────
            case "stats": {
                MypageStatsDTO stats = dao.getStats(userId);
                sendJson(resp, stats);
                break;
            }

            default:
                sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "알 수 없는 action 파라미터입니다.");
        }
    }

    // ════════════════════════════════════════════════════════════════
    // POST 처리
    // ════════════════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        // ── 세션 체크 ────────────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            sendError(resp, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
            return;
        }

        String userId = (String) session.getAttribute("loginUser");
        String action = req.getParameter("action");

        if (action == null) action = "";

        switch (action) {

            // ── 프로필 수정 ──────────────────────────────────────
            case "updateProfile": {
                String userName  = trim(req.getParameter("userName"));
                String userRank  = trim(req.getParameter("userRank"));
                String userOrg   = trim(req.getParameter("userOrg"));
                String userPhone = trim(req.getParameter("userPhone"));

                // 입력값 검증
                if (userName.isEmpty() || userRank.isEmpty() || userOrg.isEmpty()) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "이름, 계급, 소속은 필수 입력 항목입니다.");
                    return;
                }

                UserDTO dto = new UserDTO();
                dto.setUserId(userId);
                dto.setUserName(userName);
                dto.setUserRank(userRank);
                dto.setUserOrg(userOrg);
                dto.setUserPhone(userPhone);

                boolean ok = dao.updateProfile(dto);

                if (ok) {
                    // 세션에 이름 업데이트 (상단 표시용)
                    session.setAttribute("userName", userName);
                    session.setAttribute("userRank", userRank);
                    session.setAttribute("userOrg",   userOrg);
                    session.setAttribute("userPhone", userPhone);
                    sendSuccess(resp, "프로필이 수정되었습니다.");
                } else {
                    sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "프로필 수정에 실패했습니다.");
                }
                break;
            }

            // ── 비밀번호 변경 ────────────────────────────────────
            case "changePassword": {
                String curPw  = req.getParameter("curPw");
                String newPw  = req.getParameter("newPw");
                String newPwCf= req.getParameter("newPwCf");

                // 입력값 검증
                if (isBlank(curPw) || isBlank(newPw) || isBlank(newPwCf)) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "모든 항목을 입력해 주세요.");
                    return;
                }
                if (!newPw.equals(newPwCf)) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "새 비밀번호가 일치하지 않습니다.");
                    return;
                }
                if (newPw.length() < 8) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "새 비밀번호는 8자 이상이어야 합니다.");
                    return;
                }

                // 현재 비밀번호 확인
                if (!dao.checkPassword(userId, curPw)) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "현재 비밀번호가 올바르지 않습니다.");
                    return;
                }

                // 비밀번호 변경
                boolean ok = dao.changePassword(userId, newPw);
                if (ok) {
                    sendSuccess(resp, "비밀번호가 변경되었습니다.");
                } else {
                    sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "비밀번호 변경에 실패했습니다.");
                }
                break;
            }

            // ── 알림 설정 저장 ───────────────────────────────────
            case "saveSettings": {
                boolean notifContradiction = "true".equals(req.getParameter("notifContradiction"));
                boolean notifRelation      = "true".equals(req.getParameter("notifRelation"));
                boolean nightMode          = "true".equals(req.getParameter("nightMode"));

                boolean ok = dao.saveSettings(userId, notifContradiction, notifRelation, nightMode);
                if (ok) {
                    // 세션에도 야간모드 저장 (NotificationServlet에서 참조)
                    session.setAttribute("nightMode", nightMode);
                    sendSuccess(resp, "설정이 저장되었습니다.");
                } else {
                    sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "설정 저장에 실패했습니다.");
                }
                break;
            }

            // ── 로그아웃 ─────────────────────────────────────────
            case "logout": {
                session.invalidate();
                sendSuccess(resp, "로그아웃 되었습니다.");
                break;
            }

            default:
                sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "알 수 없는 action 파라미터입니다.");
        }
    }

    // ════════════════════════════════════════════════════════════════
    // 공통 유틸
    // ════════════════════════════════════════════════════════════════

    /** 비밀번호 등 민감 정보를 제외한 안전한 사용자 Map 반환 */
    private Map<String, String> toSafeUserMap(UserDTO user) {
        Map<String, String> map = new HashMap<>();
        map.put("userId",    user.getUserId());
        map.put("userName",  user.getUserName());
        map.put("userRank",  user.getUserRank());
        map.put("userOrg",   user.getUserOrg());
        map.put("userPhone", user.getUserPhone());
        map.put("userDept",  user.getUserDept());
        return map;
    }

    private void sendJson(HttpServletResponse resp, Object data) throws IOException {
        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(data));
        }
    }

    private void sendSuccess(HttpServletResponse resp, String message) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", message);
        sendJson(resp, result);
    }

    private void sendError(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("message", message);
        sendJson(resp, result);
    }

    private String trim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
