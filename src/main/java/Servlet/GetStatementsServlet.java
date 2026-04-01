package Servlet;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import Servlet.DBConnectionMgr;

/**
 * GetStatementsServlet
 * 같은 사건(case_id)의 기존 진술 목록을 조회해서 JSON으로 반환.
 * Flask /analyze 호출 전에 JSP에서 먼저 호출하여 교차 모순 분석에 활용.
 *
 * GET /Polmate/GetStatementsServlet?caseId=2024-0312
 *
 * Response:
 * {
 *   "success": true,
 *   "statements": [
 *     {
 *       "transcript_id": 1,
 *       "stmt_type": "피의자",
 *       "stmt_name": "홍길동",
 *       "original_text": "저는 그날 집에 있었습니다...",
 *       "result_summary": "시간순 정리된 사건 흐름..."
 *     }
 *   ]
 * }
 */
@jakarta.servlet.annotation.WebServlet("/GetStatementsServlet")
public class GetStatementsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = resp.getWriter();
        String caseId = req.getParameter("caseId");

        if (caseId == null || caseId.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"caseId 파라미터가 없습니다.\"}");
            return;
        }

        String sql = "SELECT transcript_id, stmt_type, stmt_name, " +
                     "       original_text, result_summary " +
                     "FROM TRANSCRIPTS " +
                     "WHERE case_id = ? " +
                     "ORDER BY created_at ASC";

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = mgr.getConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, caseId.trim());
            rs = ps.executeQuery();

            StringBuilder statementsJson = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) statementsJson.append(",");
                first = false;

                statementsJson.append("{");
                statementsJson.append("\"transcript_id\":").append(rs.getInt("transcript_id")).append(",");
                statementsJson.append("\"stmt_type\":\"").append(escapeJson(rs.getString("stmt_type"))).append("\",");
                statementsJson.append("\"stmt_name\":\"").append(escapeJson(rs.getString("stmt_name"))).append("\",");
                statementsJson.append("\"original_text\":\"").append(escapeJson(rs.getString("original_text"))).append("\",");
                statementsJson.append("\"result_summary\":\"").append(escapeJson(rs.getString("result_summary"))).append("\"");
                statementsJson.append("}");
            }
            statementsJson.append("]");

            out.print("{\"success\":true,\"statements\":" + statementsJson.toString() + "}");

        } catch (Exception e) {
            out.print("{\"success\":false,\"error\":\"DB 조회 실패: " + escapeJson(e.getMessage()) + "\"}");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // JSON 문자열 이스케이프 처리 (특수문자 깨짐 방지)
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}