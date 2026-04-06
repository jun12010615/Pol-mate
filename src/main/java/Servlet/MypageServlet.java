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
                UserDTO        user  = dao.getUserById(userId);
                MypageStatsDTO stats = dao.getStats(userId);

                if (user == null) {
                    sendError(resp, HttpServletResponse.SC_NOT_FOUND, "사용자 정보를 찾을 수 없습니다.");
                    return;
                }

                // 설정값 조회
                Map<String, Object> settings = dao.getSettings(userId);

                Map<String, Object> result = new HashMap<>();
                result.put("user",     toSafeUserMap(user));
                result.put("stats",    stats);
                result.put("settings", settings);
                sendJson(resp, result);
                break;
            }

            // ── 기관별 부서 목록 조회 ────────────────────────────
            case "getDepts": {
                String org = req.getParameter("org");
                if (org == null || org.trim().isEmpty()) {
                    resp.getWriter().print("[]");
                    return;
                }
                DBConnectionMgr mgr2 = DBConnectionMgr.getInstance();
                java.sql.Connection conn2 = null;
                java.sql.PreparedStatement ps2 = null;
                java.sql.ResultSet rs2 = null;
                try {
                    conn2 = mgr2.getConnection();
                    ps2 = conn2.prepareStatement(
                        "SELECT dept_id, dept_name FROM departments WHERE org_name = ? ORDER BY dept_name");
                    ps2.setString(1, org.trim());
                    rs2 = ps2.executeQuery();
                    StringBuilder sb = new StringBuilder("[");
                    boolean first = true;
                    while (rs2.next()) {
                        if (!first) sb.append(",");
                        sb.append("{\"dept_id\":").append(rs2.getInt("dept_id"))
                          .append(",\"dept_name\":\"").append(rs2.getString("dept_name").replace("\"","\\\"")).append("\"}");
                        first = false;
                    }
                    sb.append("]");
                    resp.getWriter().print(sb.toString());
                } catch (Exception e) {
                    e.printStackTrace();
                    resp.getWriter().print("[]");
                } finally {
                    mgr2.freeConnection(conn2, ps2, rs2);
                }
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

            // ── 활동 통계 (기간별 + 월별 차트) ─────────────────
            case "stats": {
                String period = req.getParameter("period");
                if (period == null || period.isEmpty()) period = "all";

                MypageStatsDTO stats = "all".equals(period)
                    ? dao.getStats(userId)
                    : dao.getStatsByPeriod(userId, period);

                java.util.Map<String, Integer> monthly = dao.getMonthlyTranscripts(userId);

                java.util.Map<String, Object> result = new java.util.HashMap<>();
                result.put("totalCases",         stats.getTotalCases());
                result.put("activeCases",        stats.getActiveCases());
                result.put("totalTranscripts",   stats.getTotalTranscripts());
                result.put("contradictionCount", stats.getContradictionCount());
                result.put("relationEdges",      stats.getRelationEdges());
                result.put("monthly",            monthly);
                sendJson(resp, result);
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

            // ── 설정 저장 ────────────────────────────────────────
            case "saveSettings": {
                boolean notifContradiction = "1".equals(req.getParameter("notifContradiction"));
                boolean notifRelation      = "1".equals(req.getParameter("notifRelation"));
                boolean nightMode          = "1".equals(req.getParameter("nightMode"));

                boolean ok = dao.saveSettings(userId, notifContradiction, notifRelation, nightMode);
                if (ok) {
                    sendSuccess(resp, "설정이 저장되었습니다.");
                } else {
                    sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "설정 저장에 실패했습니다.");
                }
                break;
            }

            // ── 프로필 수정 ──────────────────────────────────────
            case "updateProfile": {
                String userName  = trim(req.getParameter("userName"));
                String userRank  = trim(req.getParameter("userRank"));
                String userOrg   = trim(req.getParameter("userOrg"));
                String userPhone = trim(req.getParameter("userPhone"));
                String deptIdStr = trim(req.getParameter("deptId"));

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
                try {
                    dto.setDeptId(deptIdStr.isEmpty() ? null : Integer.parseInt(deptIdStr));
                } catch (NumberFormatException e) {
                    dto.setDeptId(null);
                }

                boolean ok = dao.updateProfile(dto);

                if (ok) {
                    session.setAttribute("userName", userName);
                    session.setAttribute("userRank", userRank);
                    session.setAttribute("userOrg",  userOrg);
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

            // ── 회원탈퇴 ─────────────────────────────────────────
            case "withdraw": {
                String password = req.getParameter("password");

                // 입력값 검증
                if (isBlank(password)) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "비밀번호를 입력해 주세요.");
                    return;
                }

                // 현재 비밀번호 확인
                if (!dao.checkPassword(userId, password)) {
                    sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "비밀번호가 올바르지 않습니다.");
                    return;
                }

                // 탈퇴 처리 (트랜잭션으로 관련 데이터 일괄 삭제)
                boolean ok = dao.withdrawUser(userId);
                if (ok) {
                    session.invalidate(); // 세션 무효화
                    sendSuccess(resp, "회원탈퇴가 완료되었습니다.");
                } else {
                    sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "탈퇴 처리 중 오류가 발생했습니다.");
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

    private Map<String, Object> toSafeUserMap(UserDTO user) {
        Map<String, Object> map = new HashMap<>();
        map.put("userId",    user.getUserId());
        map.put("userName",  user.getUserName());
        map.put("userRank",  user.getUserRank());
        map.put("userOrg",   user.getUserOrg());
        map.put("userPhone", user.getUserPhone());
        map.put("userDept",  user.getUserDept());
        map.put("deptId",    user.getDeptId());
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
