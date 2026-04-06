package Servlet;

import java.io.*;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * RelationBoardServlet
 * URL: /boardApi
 *
 * action 파라미터:
 *   GET  load       - 사건 보드 조회 (boardJson + 메타)
 *   GET  listBoards - 팀 전체 사건 보드 목록 (메인화면 보드조회용)
 *   POST save       - 보드 저장/업데이트 (사건당 1개, 기존 덮어쓰기)
 *   POST delete     - 보드 삭제
 */
@WebServlet("/boardApi")
public class RelationBoardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ═══════════════════════════════════════════════════════
    // GET
    // ═══════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json;charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        String loginUser = getLoginUser(req, res);
        if (loginUser == null) return;

        String action = nvl(req.getParameter("action"), "load");

        switch (action) {
            case "load":       handleLoad(req, res, loginUser);       break;
            case "listBoards": handleListBoards(req, res, loginUser); break;
            default:           writeError(res, "알 수 없는 action");
        }
    }

    // ═══════════════════════════════════════════════════════
    // POST
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
            case "save":   handleSave(req, res, loginUser);   break;
            case "delete": handleDelete(req, res, loginUser); break;
            default:       writeError(res, "알 수 없는 action");
        }
    }

    // ═══════════════════════════════════════════════════════
    // 보드 조회
    // ═══════════════════════════════════════════════════════
    private void handleLoad(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId = req.getParameter("caseId");
        if (isEmpty(caseId)) { writeError(res, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            // 팀 접근 권한 확인
            if (!hasAccess(conn, caseId, loginUser)) {
                writeError(res, "접근 권한이 없습니다."); return;
            }

            ps = conn.prepareStatement(
                "SELECT b.board_id, b.case_id, b.board_json, " +
                "       b.created_at, b.updated_at, " +
                "       u1.user_name AS creator_name, u2.user_name AS updater_name, " +
                "       c.case_name " +
                "FROM relation_boards b " +
                "LEFT JOIN users u1 ON b.created_by = u1.user_id " +
                "LEFT JOIN users u2 ON b.updated_by = u2.user_id " +
                "LEFT JOIN cases c  ON b.case_id    = c.case_id " +
                "WHERE b.case_id = ?");
            ps.setString(1, caseId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                // 보드 없음
                JSONObject empty = new JSONObject();
                empty.put("success",   false);
                empty.put("boardExists", false);
                empty.put("message",   "저장된 보드가 없습니다.");
                res.getWriter().write(empty.toString());
                return;
            }

            JSONObject result = new JSONObject();
            result.put("success",     true);
            result.put("boardExists", true);
            result.put("boardId",     rs.getInt("board_id"));
            result.put("caseId",      rs.getString("case_id"));
            result.put("caseName",    nvl(rs.getString("case_name"), ""));
            result.put("boardJson",   rs.getString("board_json"));
            result.put("creatorName", nvl(rs.getString("creator_name"), ""));
            result.put("updaterName", nvl(rs.getString("updater_name"), ""));
            result.put("createdAt",   rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toString().substring(0,16) : "");
            result.put("updatedAt",   rs.getTimestamp("updated_at") != null
                ? rs.getTimestamp("updated_at").toString().substring(0,16) : "");

            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "보드 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 팀 보드 목록 (메인화면 보드조회용)
    // ═══════════════════════════════════════════════════════
    private void handleListBoards(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            ps = conn.prepareStatement(
                "SELECT b.board_id, b.case_id, c.case_name, c.status, " +
                "       b.updated_at, u.user_name AS updater_name, " +
                "       b.board_json " +
                "FROM relation_boards b " +
                "JOIN cases c ON b.case_id = c.case_id " +
                "LEFT JOIN users u ON b.updated_by = u.user_id " +
                "WHERE (c.user_id = ? OR c.user_id IN (" +
                "  SELECT u2.user_id FROM users u2 " +
                "  JOIN users me ON me.user_id = ? " +
                "  WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL" +
                ")) " +
                "ORDER BY b.updated_at DESC");
            ps.setString(1, loginUser);
            ps.setString(2, loginUser);
            rs = ps.executeQuery();

            JSONArray arr = new JSONArray();
            while (rs.next()) {
                JSONObject b = new JSONObject();
                b.put("boardId",     rs.getInt("board_id"));
                b.put("caseId",      rs.getString("case_id"));
                b.put("caseName",    nvl(rs.getString("case_name"), ""));
                b.put("status",      nvl(rs.getString("status"),    "진행중"));
                b.put("updatedAt",   rs.getTimestamp("updated_at") != null
                    ? rs.getTimestamp("updated_at").toString().substring(0,16) : "");
                b.put("updaterName", nvl(rs.getString("updater_name"), ""));

                // 인물/관계선 수 간단히 파싱
                try {
                    JSONObject bj = new JSONObject(nvl(rs.getString("board_json"), "{}"));
                    b.put("personCount", bj.optJSONArray("persons") != null
                        ? bj.optJSONArray("persons").length() : 0);
                    b.put("edgeCount",   bj.optJSONArray("edges") != null
                        ? bj.optJSONArray("edges").length()   : 0);
                } catch (Exception ignored) {
                    b.put("personCount", 0);
                    b.put("edgeCount",   0);
                }
                arr.put(b);
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("boards",  arr);
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "보드 목록 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 보드 저장 / 업데이트 (UPSERT — 사건당 1개)
    // ═══════════════════════════════════════════════════════
    private void handleSave(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        // JSON body 읽기
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }

        JSONObject body;
        try { body = new JSONObject(sb.toString()); }
        catch (Exception e) { writeError(res, "요청 JSON이 올바르지 않습니다."); return; }

        String caseId    = nvl(body.optString("caseId"),    "");
        String boardJson = body.optString("boardJson",      "{}");
        boolean isUpdate = body.optBoolean("isUpdate",      false);

        if (isEmpty(caseId)) { writeError(res, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            // 접근 권한
            if (!hasAccess(conn, caseId, loginUser)) {
                writeError(res, "접근 권한이 없습니다."); return;
            }

            // 기존 보드 존재 여부 확인
            ps = conn.prepareStatement(
                "SELECT board_id, created_by FROM relation_boards WHERE case_id = ?");
            ps.setString(1, caseId);
            rs = ps.executeQuery();
            boolean exists = rs.next();
            String originalCreator = exists ? rs.getString("created_by") : null;
            rs.close();
            mgr.freeConnection(null, ps);

            if (exists) {
                // UPDATE (기존 보드 덮어쓰기)
                ps = conn.prepareStatement(
                    "UPDATE relation_boards SET board_json=?, updated_by=?, updated_at=NOW() " +
                    "WHERE case_id=?");
                ps.setString(1, boardJson);
                ps.setString(2, loginUser);
                ps.setString(3, caseId);
            } else {
                // INSERT (신규)
                ps = conn.prepareStatement(
                    "INSERT INTO relation_boards (case_id, created_by, updated_by, board_json) " +
                    "VALUES (?, ?, ?, ?)");
                ps.setString(1, caseId);
                ps.setString(2, loginUser);
                ps.setString(3, loginUser);
                ps.setString(4, boardJson);
            }
            ps.executeUpdate();
            mgr.freeConnection(null, ps);

            // relation_persons / relation_edges 동기화
            syncPersonsAndEdges(conn, caseId, boardJson, loginUser);

            // 팀원 알림 발송
            String caseName = getCaseName(conn, caseId);
            String notifTag   = isUpdate ? "관계망" : "새 사건";
            String notifTitle = isUpdate
                ? "관계망 보드 업데이트: " + caseId
                : "관계망 보드 등록: " + caseId;
            String notifDesc  = isUpdate
                ? "사건 " + caseId + "(" + caseName + ")의 관계망 보드가 업데이트됐습니다."
                : "사건 " + caseId + "(" + caseName + ")의 관계망 보드가 등록됐습니다.";

            sendTeamNotif(conn, loginUser, caseId, notifTag, notifTitle, notifDesc);

            JSONObject result = new JSONObject();
            result.put("success",  true);
            result.put("isUpdate", exists);
            result.put("message",  exists ? "보드가 업데이트됐습니다." : "보드가 저장됐습니다.");
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "보드 저장 중 오류가 발생했습니다: " + e.getMessage());
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 보드 삭제
    // ═══════════════════════════════════════════════════════
    private void handleDelete(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId = req.getParameter("caseId");
        if (isEmpty(caseId)) { writeError(res, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();
            if (!hasAccess(conn, caseId, loginUser)) {
                writeError(res, "접근 권한이 없습니다."); return;
            }

            ps = conn.prepareStatement("DELETE FROM relation_boards WHERE case_id = ?");
            ps.setString(1, caseId);
            ps.executeUpdate();

            writeResult(res, true, "보드가 삭제됐습니다.");

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "보드 삭제 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // relation_persons / relation_edges 동기화
    // (보드 저장 시 항상 최신 상태로 덮어씀)
    // ═══════════════════════════════════════════════════════
    private void syncPersonsAndEdges(Connection conn, String caseId, String boardJson, String userId)
            throws Exception {

        JSONObject bj = new JSONObject(boardJson);
        JSONArray persons = bj.optJSONArray("persons");
        JSONArray edges   = bj.optJSONArray("edges");

        // 기존 데이터 삭제 후 재삽입
        PreparedStatement ps = conn.prepareStatement(
            "DELETE FROM relation_edges   WHERE case_id = ?");
        ps.setString(1, caseId); ps.executeUpdate(); ps.close();

        ps = conn.prepareStatement(
            "DELETE FROM relation_persons WHERE case_id = ?");
        ps.setString(1, caseId); ps.executeUpdate(); ps.close();

        // 인물 삽입 & name→person_id 맵 구성 (이름 기준 중복 제거)
        Map<String, Integer> nameToId = new HashMap<>();
        if (persons != null) {
            ps = conn.prepareStatement(
                "INSERT INTO relation_persons (case_id, person_name, role, memo) VALUES (?, ?, ?, ?)",
                java.sql.Statement.RETURN_GENERATED_KEYS);
            for (int i = 0; i < persons.length(); i++) {
                JSONObject p = persons.getJSONObject(i);
                String pName = nvl(p.optString("name"), "").trim();
                if (pName.isEmpty()) continue;
                // 이름 중복 건너뜀
                if (nameToId.containsKey(pName)) continue;
                ps.setString(1, caseId);
                ps.setString(2, pName);
                ps.setString(3, nvl(p.optString("role"), "reference"));
                ps.setString(4, nvl(p.optString("memo"), ""));
                ps.executeUpdate();
                ResultSet gk = ps.getGeneratedKeys();
                if (gk.next()) nameToId.put(pName, gk.getInt(1));
                gk.close();
            }
            ps.close();
        }

        // 관계선 삽입
        if (edges != null && !nameToId.isEmpty()) {
            ps = conn.prepareStatement(
                "INSERT INTO relation_edges " +
                "(case_id, src_person_id, dst_person_id, rel_type, status, context) " +
                "VALUES (?, ?, ?, ?, ?, ?)");
            for (int i = 0; i < edges.length(); i++) {
                JSONObject e = edges.getJSONObject(i);
                String srcName = nvl(e.optString("srcName"), "");
                String dstName = nvl(e.optString("dstName"), "");
                Integer srcId = nameToId.get(srcName);
                Integer dstId = nameToId.get(dstName);
                if (srcId == null || dstId == null) continue;
                ps.setString(1, caseId);
                ps.setString(2, String.valueOf(srcId));
                ps.setString(3, String.valueOf(dstId));
                ps.setString(4, nvl(e.optString("relType"), "acquaint"));
                ps.setString(5, nvl(e.optString("status"),  "unknown"));
                // context 허용값: scene / time / evidence 만 저장, 그 외는 null
                String ctx = e.optString("context", "").trim();
                if (!ctx.equals("scene") && !ctx.equals("time") && !ctx.equals("evidence")) {
                    ctx = "";
                }
                ps.setString(6, ctx.isEmpty() ? null : ctx);
                ps.executeUpdate();
            }
            ps.close();
        }

        // 변경 이력 기록
        ps = conn.prepareStatement(
            "INSERT INTO relation_history (case_id, user_id, action) VALUES (?, ?, ?)");
        int pCount = persons != null ? persons.length() : 0;
        int eCount = edges   != null ? edges.length()   : 0;
        ps.setString(1, caseId);
        ps.setString(2, userId);
        ps.setString(3, "보드 저장: 인물 " + pCount + "명, 관계선 " + eCount + "개");
        ps.executeUpdate();
        ps.close();
    }

    // ═══════════════════════════════════════════════════════
    // 팀원 알림 발송 헬퍼
    // ═══════════════════════════════════════════════════════
    private void sendTeamNotif(Connection conn, String loginUser, String caseId,
                               String tag, String title, String desc) {
        try {
            // notif_relation = 1 인 팀원에게만 발송
            PreparedStatement ps = conn.prepareStatement(
                "SELECT u2.user_id FROM users u2 " +
                "JOIN users me ON me.user_id = ? " +
                "WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL " +
                "  AND u2.user_id != ? " +
                "  AND u2.notif_relation = 1");
            ps.setString(1, loginUser);
            ps.setString(2, loginUser);
            ResultSet rs = ps.executeQuery();
            List<String> teammates = new ArrayList<>();
            while (rs.next()) teammates.add(rs.getString("user_id"));
            rs.close(); ps.close();

            for (String tm : teammates) {
                try {
                    NotificationServlet.insertNotification(
                        conn, tm, "case", tag, title, desc,
                        "boardView.jsp?caseId=" + caseId, false);
                } catch (Exception ignored) {}
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ═══════════════════════════════════════════════════════
    // 헬퍼
    // ═══════════════════════════════════════════════════════
    private boolean hasAccess(Connection conn, String caseId, String userId) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT 1 FROM cases WHERE case_id = ? " +
            "AND (user_id = ? OR user_id IN (" +
            "  SELECT u2.user_id FROM users u2 " +
            "  JOIN users me ON me.user_id = ? " +
            "  WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL))");
        ps.setString(1, caseId); ps.setString(2, userId); ps.setString(3, userId);
        ResultSet rs = ps.executeQuery();
        boolean ok = rs.next();
        rs.close(); ps.close();
        return ok;
    }

    private String getCaseName(Connection conn, String caseId) {
        try {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT case_name FROM cases WHERE case_id = ?");
            ps.setString(1, caseId);
            ResultSet rs = ps.executeQuery();
            String name = rs.next() ? rs.getString("case_name") : "";
            rs.close(); ps.close();
            return name;
        } catch (Exception e) { return ""; }
    }

    private String getLoginUser(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        String u = (session != null) ? (String) session.getAttribute("loginUser") : null;
        if (u == null) writeError(res, "로그인이 필요합니다.");
        return u;
    }

    private void writeError(HttpServletResponse res, String msg) throws IOException {
        res.getWriter().write(new JSONObject().put("error", msg).toString());
    }

    private void writeResult(HttpServletResponse res, boolean ok, String msg) throws IOException {
        JSONObject j = new JSONObject();
        j.put("success", ok);
        j.put("message", msg);
        res.getWriter().write(j.toString());
    }

    private String nvl(String s, String def) {
        return (s == null || s.trim().isEmpty()) ? def : s.trim();
    }
    private boolean isEmpty(String s) { return s == null || s.trim().isEmpty(); }
}
