package Servlet;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import Servlet.DBConnectionMgr;

/**
 * SaveTranscriptServlet
 * Flask /analyze 결과를 TRANSCRIPTS 테이블에 저장.
 * 모순 탐지 시:
 *   - CASES.status → '모순탐지' 업데이트
 *   - 같은 팀 수사관 전원에게 NOTIFICATIONS INSERT
 *
 * POST /Polmate/SaveTranscriptServlet
 * Content-Type: application/json
 *
 * Request Body:
 * {
 *   "caseId":          "2024-0312",
 *   "userId":          "officer01",
 *   "stmtType":        "피의자",
 *   "stmtName":        "홍길동",
 *   "originalText":    "저는 그날 집에...",
 *   "aiResult":        "【진술 구조 요약】...",
 *   "resultSummary":   "시간순 정리...",
 *   "contradictionJson": "[{...}]",
 *   "furtherChecks":   "[\"확인사항1\"]",
 *   "hasContradiction": true
 * }
 *
 * Response:
 * { "success": true, "transcriptId": 42 }
 */
@jakarta.servlet.annotation.WebServlet("/SaveTranscriptServlet")
public class SaveTranscriptServlet extends HttpServlet {

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        setCorsHeaders(resp);
        resp.setStatus(HttpServletResponse.SC_OK);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        setCorsHeaders(resp);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        String loginUser = (session != null) ? (String) session.getAttribute("loginUser") : null;
        if (loginUser == null || loginUser.trim().isEmpty()) {
            resp.getWriter().print("{\"success\":false,\"error\":\"로그인이 필요합니다.\"}");
            return;
        }

        // Request Body 파싱
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }

        String bodyStr = sb.toString().trim();

        // 필드 추출 (간단한 JSON 파서 대신 직접 파싱)
        String  caseId            = parseJsonString(bodyStr, "caseId").trim();
        String  userId            = loginUser.trim(); // 세션 값 우선
        String  stmtType          = parseJsonString(bodyStr, "stmtType");
        String  stmtName          = parseJsonString(bodyStr, "stmtName");
        String  originalText      = parseJsonString(bodyStr, "originalText");
        String  aiResult          = parseJsonString(bodyStr, "aiResult");
        String  resultSummary     = parseJsonString(bodyStr, "resultSummary");
        String  contradictionJson = parseJsonString(bodyStr, "contradictionJson");
        String  furtherChecks     = parseJsonString(bodyStr, "furtherChecks");
        boolean hasContradiction  = parseJsonBoolean(bodyStr, "hasContradiction");

        if (contradictionJson.isEmpty()) contradictionJson = "[]";
        if (furtherChecks.isEmpty())     furtherChecks     = "[]";

        if (caseId.isEmpty() || userId.isEmpty()) {
            resp.getWriter().print("{\"success\":false,\"error\":\"caseId 또는 userId가 없습니다.\"}");
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        try {
            conn = mgr.getConnection();
            boolean prevAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);

            // ── 1. TRANSCRIPTS INSERT ─────────────────────────────────
            int transcriptId = insertTranscript(conn,
                caseId, userId, stmtType, stmtName,
                originalText, aiResult, resultSummary,
                contradictionJson, furtherChecks,
                hasContradiction ? 1 : 0);

            // ── 2. 모순 탐지 시 CASES 상태 업데이트 + 알림 ───────────
            if (hasContradiction) {
                updateCaseStatus(conn, caseId, "모순탐지");
                sendNotificationsToTeam(conn, caseId, stmtName, stmtType);
            }

            conn.commit();
            conn.setAutoCommit(prevAutoCommit);

            resp.getWriter().print("{\"success\":true,\"transcriptId\":" + transcriptId + "}");

        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
            resp.getWriter().print("{\"success\":false,\"error\":\"DB 저장 실패: " + escapeJson(e.getMessage()) + "\"}");
        } finally {
            mgr.freeConnection(conn);
        }
    }

    // ── TRANSCRIPTS INSERT ────────────────────────────────────────────
    private int insertTranscript(Connection conn,
            String caseId, String userId, String stmtType, String stmtName,
            String originalText, String aiResult, String resultSummary,
            String contradictionJson, String furtherChecks,
            int hasContradiction) throws SQLException {

        String sql = "INSERT INTO TRANSCRIPTS " +
            "(case_id, user_id, stmt_type, stmt_name, " +
            " original_text, ai_result, result_summary, " +
            " contradiction_json, further_checks, has_contradiction) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1,  caseId);
            ps.setString(2,  userId);
            ps.setString(3,  stmtType);
            ps.setString(4,  stmtName);
            ps.setString(5,  originalText);
            ps.setString(6,  aiResult);
            ps.setString(7,  resultSummary);
            ps.setString(8,  contradictionJson);
            ps.setString(9,  furtherChecks);
            ps.setInt(10,    hasContradiction);
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        }
    }

    // ── CASES 상태 업데이트 ───────────────────────────────────────────
    private void updateCaseStatus(Connection conn, String caseId, String status)
            throws SQLException {
        String sql = "UPDATE CASES SET status=?, updated_at=NOW() WHERE case_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, caseId);
            ps.executeUpdate();
        }
    }

    // ── 팀원 전체 알림 발송 ───────────────────────────────────────────
    private void sendNotificationsToTeam(Connection conn, String caseId,
            String stmtName, String stmtType) throws SQLException {

        String selectSql =
            "SELECT tm.user_id FROM TEAM_MEMBERS tm " +
            "JOIN CASES c ON c.team_id = tm.team_id " +
            "WHERE c.case_id = ?";

        String insertSql =
            "INSERT INTO NOTIFICATIONS " +
            "(user_id, type, tag, title, description, link, is_unread, is_critical) " +
            "VALUES (?, 'case', '모순탐지', ?, ?, ?, 1, 1)";

        String title = "[모순탐지] " + stmtType + " " + stmtName + "의 진술에서 모순이 탐지되었습니다.";
        String desc  = "AI가 원문 근거가 확인된 모순을 탐지했습니다. 진술 내용을 확인해주세요.";
        String link  = "/Polmate/voiceTranscript.jsp?caseId=" + caseId;

        try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
            selectPs.setString(1, caseId);
            ResultSet rs = selectPs.executeQuery();

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                while (rs.next()) {
                    insertPs.setString(1, rs.getString("user_id"));
                    insertPs.setString(2, title);
                    insertPs.setString(3, desc);
                    insertPs.setString(4, link);
                    insertPs.addBatch();
                }
                insertPs.executeBatch();
            }
        }
    }

    // ── JSON 파싱 유틸 ────────────────────────────────────────────────

    /**
     * JSON 문자열에서 특정 키의 문자열 값을 추출.
     * "key":"value" 또는 "key": "value" 형태 지원.
     * contradictionJson / furtherChecks 처럼 값 자체가 JSON 배열/객체인 경우도 처리.
     */
    private String parseJsonString(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIdx = json.indexOf(search);
        if (keyIdx < 0) return "";

        int colonIdx = json.indexOf(":", keyIdx + search.length());
        if (colonIdx < 0) return "";

        // 콜론 이후 첫 비공백 문자 탐색
        int start = colonIdx + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;
        if (start >= json.length()) return "";

        char first = json.charAt(start);

        // 값이 문자열("...")인 경우
        if (first == '"') {
            StringBuilder result = new StringBuilder();
            int i = start + 1;
            while (i < json.length()) {
                char c = json.charAt(i);
                if (c == '\\' && i + 1 < json.length()) {
                    char next = json.charAt(i + 1);
                    switch (next) {
                        case '"':  result.append('"');  i += 2; break;
                        case '\\': result.append('\\'); i += 2; break;
                        case 'n':  result.append('\n'); i += 2; break;
                        case 'r':  result.append('\r'); i += 2; break;
                        case 't':  result.append('\t'); i += 2; break;
                        default:   result.append(next); i += 2; break;
                    }
                } else if (c == '"') {
                    break;
                } else {
                    result.append(c);
                    i++;
                }
            }
            return result.toString();
        }

        // 값이 배열([...]) 또는 객체({...})인 경우
        if (first == '[' || first == '{') {
            char open  = first;
            char close = (first == '[') ? ']' : '}';
            int depth = 0;
            int i = start;
            StringBuilder result = new StringBuilder();
            while (i < json.length()) {
                char c = json.charAt(i);
                if (c == open)  depth++;
                if (c == close) depth--;
                result.append(c);
                i++;
                if (depth == 0) break;
            }
            return result.toString();
        }

        return "";
    }

    /**
     * JSON 문자열에서 특정 키의 boolean 값을 추출.
     */
    private boolean parseJsonBoolean(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIdx = json.indexOf(search);
        if (keyIdx < 0) return false;

        int colonIdx = json.indexOf(":", keyIdx + search.length());
        if (colonIdx < 0) return false;

        int start = colonIdx + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;

        return json.startsWith("true", start);
    }

    // ── JSON 이스케이프 ───────────────────────────────────────────────
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }

    private void setCorsHeaders(HttpServletResponse resp) {
        resp.setHeader("Access-Control-Allow-Origin",  "*");
        resp.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
    }
}