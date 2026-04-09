package Servlet;

import Servlet.DBConnectionMgr;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.*;
import java.sql.*;
import java.util.*;

/**
 * 모순탐지 결과 서블릿
 * URL: /contradictionApi
 *
 * action 파라미터로 기능 분기:
 *   save   - 모순탐지 결과 저장 (POST)
 *   list   - 내 모순탐지 목록 조회 (GET)
 *   detail - 특정 모순탐지 상세 조회 (GET)
 *   delete - 모순탐지 결과 삭제 (POST)
 */
@WebServlet("/contradictionApi")
public class ContradictionServlet extends HttpServlet {

    private final DBConnectionMgr mgr = DBConnectionMgr.getInstance();
    private final Gson gson = new Gson();

    /** MySQL TEXT 상한(65535)에 맞춰 과도한 본문으로 인한 저장 실패를 방지 */
    private static final int MAX_AI_OR_STMT_CHARS = 65000;

    private static String clipForDb(String s, int max) {
        if (s == null) return "";
        if (s.length() <= max) return s;
        return s.substring(0, max) + "\n…(이하 생략)";
    }

    private static String saveErrorMessage(SQLException e) {
        int code = e.getErrorCode();
        String m = e.getMessage();
        if (code == 1452 || (m != null && m.toLowerCase().contains("foreign key")))
            return "등록되지 않은 사건입니다. 사건 관리에서 해당 사건을 만든 뒤, 그 화면에서 모순탐지를 실행·저장하세요.";
        if (code == 1146 || (m != null && m.contains("doesn't exist")))
            return "DB에 contradiction_results 테이블이 없습니다. 관리자에게 문의하세요.";
        if (code == 1406 || (m != null && (m.contains("Data too long") || m.contains("too long"))))
            return "저장할 분석 결과가 너무 깁니다. 분석 결과 일부를 줄인 뒤 다시 시도하세요.";
        return "저장 중 오류가 발생했습니다.";
    }

    // ══════════════════════════════════════════════════════
    // GET
    // ══════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            resp.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
            return;
        }

        String userId = (String) session.getAttribute("loginUser");
        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":   handleList(req, resp, userId);   break;
            case "detail": handleDetail(req, resp, userId); break;
            default:
                resp.getWriter().write("{\"error\":\"알 수 없는 action\"}");
        }
    }

    // ══════════════════════════════════════════════════════
    // POST
    // ══════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            resp.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
            return;
        }

        String userId = (String) session.getAttribute("loginUser");
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "save":   handleSave(req, resp, userId);   break;
            case "delete": handleDelete(req, resp, userId); break;
            default:
                resp.getWriter().write("{\"error\":\"알 수 없는 action\"}");
        }
    }

    // ──────────────────────────────────────────────────────
    // 목록 조회
    // ──────────────────────────────────────────────────────
    private void handleList(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PrintWriter out = resp.getWriter();

        try {
            conn = mgr.getConnection();
            String sql =
                "SELECT cr.result_id, cr.case_id, cr.stmt_name, cr.stmt_type, " +
                "       cr.has_contradiction, cr.ai_result, cr.stmt_text, " +
                "       cr.created_at, c.case_name " +
                "FROM contradiction_results cr " +
                "LEFT JOIN cases c ON cr.case_id = c.case_id " +
                "WHERE cr.user_id = ? " +
                "ORDER BY cr.created_at DESC";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            JSONArray arr = new JSONArray();
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("resultId",        rs.getInt("result_id"));
                obj.put("caseId",          rs.getString("case_id") != null ? rs.getString("case_id") : "");
                obj.put("caseName",        rs.getString("case_name") != null ? rs.getString("case_name") : "");
                obj.put("stmtName",        rs.getString("stmt_name") != null ? rs.getString("stmt_name") : "");
                obj.put("stmtType",        rs.getString("stmt_type") != null ? rs.getString("stmt_type") : "");
                obj.put("hasContradiction", rs.getBoolean("has_contradiction"));
                obj.put("aiResult",        rs.getString("ai_result") != null ? rs.getString("ai_result") : "");
                obj.put("stmtText",        rs.getString("stmt_text") != null ? rs.getString("stmt_text") : "");
                Timestamp ts = rs.getTimestamp("created_at");
                obj.put("createdAt", ts != null ? ts.toString().substring(0, 10).replace("-", ".") : "");
                arr.put(obj);
            }
            out.write(arr.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"error\":\"목록 조회 중 오류가 발생했습니다.\"}");
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
    }

    // ──────────────────────────────────────────────────────
    // 상세 조회
    // ──────────────────────────────────────────────────────
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {

        String resultIdStr = req.getParameter("resultId");
        PrintWriter out = resp.getWriter();

        if (resultIdStr == null) {
            out.write("{\"error\":\"resultId가 필요합니다.\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();
            String sql =
                "SELECT cr.result_id, cr.case_id, cr.stmt_name, cr.stmt_type, " +
                "       cr.has_contradiction, cr.ai_result, cr.stmt_text, " +
                "       cr.created_at, c.case_name " +
                "FROM contradiction_results cr " +
                "LEFT JOIN cases c ON cr.case_id = c.case_id " +
                "WHERE cr.result_id = ? AND cr.user_id = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(resultIdStr));
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("resultId",        rs.getInt("result_id"));
                obj.put("caseId",          rs.getString("case_id") != null ? rs.getString("case_id") : "");
                obj.put("caseName",        rs.getString("case_name") != null ? rs.getString("case_name") : "");
                obj.put("stmtName",        rs.getString("stmt_name") != null ? rs.getString("stmt_name") : "");
                obj.put("stmtType",        rs.getString("stmt_type") != null ? rs.getString("stmt_type") : "");
                obj.put("hasContradiction", rs.getBoolean("has_contradiction"));
                obj.put("aiResult",        rs.getString("ai_result") != null ? rs.getString("ai_result") : "");
                obj.put("stmtText",        rs.getString("stmt_text") != null ? rs.getString("stmt_text") : "");
                Timestamp ts = rs.getTimestamp("created_at");
                obj.put("createdAt", ts != null ? ts.toString().substring(0, 16).replace("-", ".").replace("T", " ") : "");
                out.write(obj.toString());
            } else {
                out.write("{\"error\":\"결과를 찾을 수 없습니다.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"error\":\"상세 조회 중 오류가 발생했습니다.\"}");
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
    }

    // ──────────────────────────────────────────────────────
    // 저장
    // ──────────────────────────────────────────────────────
    private void handleSave(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {

        String caseId          = req.getParameter("caseId");
        String stmtName        = req.getParameter("stmtName");
        String stmtType        = req.getParameter("stmtType");
        String hasContraStr    = req.getParameter("hasContradiction");
        String aiResult        = req.getParameter("aiResult");
        String stmtText        = req.getParameter("stmtText");
        PrintWriter out        = resp.getWriter();

        boolean hasContradiction = "true".equalsIgnoreCase(hasContraStr) || "1".equals(hasContraStr);

        String aiStored = clipForDb(aiResult, MAX_AI_OR_STMT_CHARS);
        String stmtStored = clipForDb(stmtText, MAX_AI_OR_STMT_CHARS);

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = mgr.getConnection();
            String sql =
                "INSERT INTO contradiction_results " +
                "(user_id, case_id, stmt_name, stmt_type, has_contradiction, ai_result, stmt_text) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, userId);
            pstmt.setString(2, (caseId != null && !caseId.trim().isEmpty()) ? caseId.trim() : null);
            pstmt.setString(3, stmtName != null ? stmtName.trim() : "");
            pstmt.setString(4, stmtType != null ? stmtType.trim() : "");
            pstmt.setBoolean(5, hasContradiction);
            pstmt.setString(6, aiStored);
            pstmt.setString(7, stmtStored);
            pstmt.executeUpdate();

            ResultSet generatedKeys = pstmt.getGeneratedKeys();
            int newId = 0;
            if (generatedKeys.next()) {
                newId = generatedKeys.getInt(1);
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("resultId", newId);
            out.write(result.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("success", false);
            err.put("error", saveErrorMessage(e));
            out.write(err.toString());
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\":false,\"error\":\"저장 중 오류가 발생했습니다.\"}");
        } finally {
            mgr.freeConnection(conn, pstmt, null);
        }
    }

    // ──────────────────────────────────────────────────────
    // 삭제
    // ──────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, String userId)
            throws IOException {

        String resultIdStr = req.getParameter("resultId");
        PrintWriter out = resp.getWriter();

        if (resultIdStr == null) {
            out.write("{\"success\":false,\"error\":\"resultId가 필요합니다.\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = mgr.getConnection();
            String sql = "DELETE FROM contradiction_results WHERE result_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(resultIdStr));
            pstmt.setString(2, userId);
            int affected = pstmt.executeUpdate();

            JSONObject result = new JSONObject();
            result.put("success", affected > 0);
            out.write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\":false,\"error\":\"삭제 중 오류가 발생했습니다.\"}");
        } finally {
            mgr.freeConnection(conn, pstmt, null);
        }
    }
}
