package Servlet;

import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * 내 조서 관리 서블릿
 * URL: /caseApi
 *
 * action 파라미터로 기능 분기:
 *   caseList    - 내 사건 목록 조회 (GET) — 같은 dept_id 팀원 사건 포함
 *   caseDetail  - 사건 상세 조회 (GET)
 *   caseCreate  - 새 사건 등록 (POST)
 *   caseDelete  - 사건 삭제 (POST)
 *   caseStatus  - 사건 상태/진행률 수정 (POST)
 *   docList     - 내 조서 목록 조회 (GET)
 *   docStats    - 조서 통계 조회 (GET)
 *   myDept      - 내 부서 정보 조회 (GET) ← myTeam 대체
 */
@WebServlet("/caseApi")
public class CaseServlet extends HttpServlet {

    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy.MM.dd");

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

        String action = nvl(req.getParameter("action"), "caseList");

        switch (action) {
            case "caseList":       handleCaseList(req, res, loginUser);       break;
            case "caseDetail":     handleCaseDetail(req, res, loginUser);     break;
            case "docList":        handleDocList(req, res, loginUser);        break;
            case "docStats":       handleDocStats(req, res, loginUser);       break;
            case "myDept":         handleMyDept(req, res, loginUser);         break; // myTeam → myDept
            case "transcriptText": handleTranscriptText(req, res, loginUser); break;
            default:               writeError(res, "알 수 없는 action");
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
            case "caseCreate":     handleCaseCreate(req, res, loginUser);     break;
            case "caseDelete":     handleCaseDelete(req, res, loginUser);     break;
            case "caseStatus":     handleCaseStatus(req, res, loginUser);     break;
            case "transcriptSave": handleTranscriptSave(req, res, loginUser); break;
            default:               writeError(res, "알 수 없는 action");
        }
    }

    // ═══════════════════════════════════════════════════════
    // 사건 목록 조회
    // - 내가 직접 등록한 사건
    // - 같은 dept_id를 가진 팀원이 등록한 사건
    // ═══════════════════════════════════════════════════════
    private void handleCaseList(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String status  = nvl(req.getParameter("status"),  "all");
        String keyword = nvl(req.getParameter("keyword"), "");

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT c.case_id, c.case_name, c.suspect, c.charge, c.status, " +
                "       c.progress, c.updated_at, c.user_id, " +
                "       u.user_name, u.user_rank, " +
                "       (SELECT COUNT(*) FROM transcripts t WHERE t.case_id = c.case_id) AS doc_count, " +
                "       (SELECT COUNT(*) FROM transcripts t WHERE t.case_id = c.case_id AND t.has_contradiction = 1) AS contradiction_count " +
                "FROM cases c " +
                "LEFT JOIN users u ON c.user_id = u.user_id " +
                // 내가 등록한 사건 OR 같은 부서(dept_id) 팀원이 등록한 사건
                "WHERE (c.user_id = ? " +
                "   OR c.user_id IN ( " +
                "       SELECT u2.user_id FROM users u2 " +
                "       JOIN users me ON me.user_id = ? " +
                "       WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL AND u2.user_id != ? " +
                "   )) "
            );

            List<Object> params = new ArrayList<>();
            params.add(loginUser); // 내가 등록한 사건
            params.add(loginUser); // me.user_id
            params.add(loginUser); // 본인 제외 (이미 위에서 포함)

            if (!"all".equals(status)) {
                sql.append("AND c.status = ? ");
                params.add(status);
            }

            if (!keyword.isEmpty()) {
                sql.append("AND (c.case_id LIKE ? OR c.case_name LIKE ? OR c.suspect LIKE ?) ");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
            }

            sql.append("ORDER BY c.updated_at DESC");

            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            rs = ps.executeQuery();

            JSONArray arr = new JSONArray();
            while (rs.next()) {
                JSONObject c = new JSONObject();
                c.put("id",             rs.getString("case_id"));
                c.put("name",           rs.getString("case_name"));
                c.put("suspect",        nvl(rs.getString("suspect"),   "미입력"));
                c.put("charge",         nvl(rs.getString("charge"),    "미입력"));
                c.put("detective",      nvl(rs.getString("user_name"), "미입력"));
                c.put("rank",           nvl(rs.getString("user_rank"), ""));
                c.put("status",         rs.getString("status"));
                c.put("progress",       rs.getInt("progress"));
                c.put("docs",           rs.getInt("doc_count"));
                c.put("contradictions", rs.getInt("contradiction_count"));
                c.put("urgent",         rs.getInt("contradiction_count") > 0);
                c.put("isMine",         loginUser.equals(rs.getString("user_id")));

                Timestamp ts = rs.getTimestamp("updated_at");
                c.put("date", ts != null ? DATE_FMT.format(ts) : "");

                arr.put(c);
            }

            res.getWriter().write(arr.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "사건 목록 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 사건 상세 조회 (조서 목록 포함)
    // 접근 권한: 내가 등록했거나 같은 부서 팀원이 등록한 사건
    // ═══════════════════════════════════════════════════════
    private void handleCaseDetail(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId = req.getParameter("caseId");
        if (isEmpty(caseId)) { writeError(res, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            // 사건 기본 정보 + 접근 권한 확인
            ps = conn.prepareStatement(
                "SELECT c.case_id, c.case_name, c.suspect, c.charge, c.status, " +
                "       c.progress, c.updated_at, c.user_id, " +
                "       u.user_name, u.user_rank, " +
                "       d.dept_name, d.org_name " +
                "FROM cases c " +
                "LEFT JOIN users u ON c.user_id = u.user_id " +
                "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
                "WHERE c.case_id = ? " +
                "AND (c.user_id = ? " +
                "   OR c.user_id IN ( " +
                "       SELECT u2.user_id FROM users u2 " +
                "       JOIN users me ON me.user_id = ? " +
                "       WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL " +
                "   ))");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            ps.setString(3, loginUser);
            rs = ps.executeQuery();

            if (!rs.next()) {
                writeError(res, "사건을 찾을 수 없거나 접근 권한이 없습니다.");
                return;
            }

            JSONObject detail = new JSONObject();
            detail.put("id",        rs.getString("case_id"));
            detail.put("name",      rs.getString("case_name"));
            detail.put("suspect",   nvl(rs.getString("suspect"),   "미입력"));
            detail.put("charge",    nvl(rs.getString("charge"),    "미입력"));
            detail.put("status",    rs.getString("status"));
            detail.put("progress",  rs.getInt("progress"));
            detail.put("isMine",    loginUser.equals(rs.getString("user_id")));
            detail.put("detective", nvl(rs.getString("user_name"), "미입력"));
            detail.put("rank",      nvl(rs.getString("user_rank"), ""));

            // 담당 부서: 부서명 + 소속 기관
            String deptName = rs.getString("dept_name");
            String orgName  = rs.getString("org_name");
            if (deptName != null && !deptName.isEmpty()) {
                detail.put("deptName", orgName != null && !orgName.isEmpty()
                    ? deptName + " (" + orgName + ")" : deptName);
            } else {
                detail.put("deptName", "미배정");
            }

            Timestamp ts = rs.getTimestamp("updated_at");
            detail.put("date", ts != null ? DATE_FMT.format(ts) : "");
            mgr.freeConnection(null, ps, rs);

            // 해당 사건의 조서 목록
            ps = conn.prepareStatement(
                "SELECT t.transcript_id, t.stmt_type, t.stmt_name, t.has_contradiction, " +
                "       t.created_at, " +
                "       CHAR_LENGTH(IFNULL(t.original_text,'')) AS text_len " +
                "FROM transcripts t " +
                "WHERE t.case_id = ? " +
                "ORDER BY t.created_at DESC");
            ps.setString(1, caseId);
            rs = ps.executeQuery();

            JSONArray docs = new JSONArray();
            while (rs.next()) {
                JSONObject d = new JSONObject();
                d.put("id",           rs.getInt("transcript_id"));
                d.put("type",         nvl(rs.getString("stmt_type"), "미분류"));
                d.put("name",         nvl(rs.getString("stmt_name"), "미입력"));
                d.put("contradiction", rs.getBoolean("has_contradiction"));
                d.put("textLen",      rs.getInt("text_len"));
                Timestamp dts = rs.getTimestamp("created_at");
                d.put("date", dts != null ? DATE_FMT.format(dts) : "");
                docs.put(d);
            }
            detail.put("docs",     docs);
            detail.put("docCount", docs.length());

            res.getWriter().write(detail.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "사건 상세 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 새 사건 등록
    // dept_id 기반으로 같은 부서원이 볼 수 있도록 등록자 user_id만 저장
    // ═══════════════════════════════════════════════════════
    private void handleCaseCreate(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId   = req.getParameter("caseId");
        String caseName = req.getParameter("caseName");
        String suspect  = nvl(req.getParameter("suspect"), "");
        String charge   = nvl(req.getParameter("charge"),  "");

        if (isEmpty(caseId) || isEmpty(caseName)) {
            writeResult(res, false, "사건번호와 사건명은 필수입니다.");
            return;
        }

        if (!caseId.matches("^\\d{4}-\\d{4}$")) {
            writeResult(res, false, "사건번호 형식이 올바르지 않습니다. (예: 2024-0312)");
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();

            // 중복 확인
            ps = conn.prepareStatement("SELECT 1 FROM cases WHERE case_id = ?");
            ps.setString(1, caseId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                rs.close();
                writeResult(res, false, "이미 존재하는 사건번호입니다.");
                return;
            }
            rs.close();
            mgr.freeConnection(null, ps);

            // 사건 INSERT (team_id 없이 user_id만 저장 — dept_id로 팀 공유)
            ps = conn.prepareStatement(
                "INSERT INTO cases (case_id, user_id, case_name, suspect, charge, status, progress) " +
                "VALUES (?, ?, ?, ?, ?, '진행중', 0)");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            ps.setString(3, caseName.trim());
            ps.setString(4, suspect.isEmpty() ? null : suspect.trim());
            ps.setString(5, charge.isEmpty()  ? null : charge.trim());
            ps.executeUpdate();

            // 내 부서 정보 조회 (응답용)
            mgr.freeConnection(null, ps);
            ps = conn.prepareStatement(
                "SELECT d.dept_name, d.org_name FROM users u " +
                "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
                "WHERE u.user_id = ?");
            ps.setString(1, loginUser);
            rs = ps.executeQuery();

            String deptLabel = "부서 미배정";
            if (rs.next()) {
                String dn = rs.getString("dept_name");
                String on = rs.getString("org_name");
                if (dn != null && !dn.isEmpty()) {
                    deptLabel = on != null && !on.isEmpty() ? dn + " (" + on + ")" : dn;
                }
            }

            JSONObject result = new JSONObject();
            result.put("success",   true);
            result.put("caseId",    caseId);
            result.put("deptLabel", deptLabel);
            result.put("message",   "사건이 등록됐습니다.");
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "사건 등록 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 사건 삭제 (등록자만 가능)
    // ═══════════════════════════════════════════════════════
    private void handleCaseDelete(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId = req.getParameter("caseId");
        if (isEmpty(caseId)) { writeResult(res, false, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();

            // 등록자 본인 확인
            ps = conn.prepareStatement("SELECT user_id FROM cases WHERE case_id = ?");
            ps.setString(1, caseId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !loginUser.equals(rs.getString("user_id"))) {
                rs.close();
                writeResult(res, false, "삭제 권한이 없습니다. (등록자만 삭제 가능)");
                return;
            }
            rs.close();
            mgr.freeConnection(null, ps);

            // CASCADE로 관련 데이터 자동 삭제
            ps = conn.prepareStatement("DELETE FROM cases WHERE case_id = ?");
            ps.setString(1, caseId);
            ps.executeUpdate();

            writeResult(res, true, "사건이 삭제됐습니다.");

        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "삭제 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 사건 상태 / 진행률 수정
    // 접근 권한: 등록자 또는 같은 부서 팀원
    // ═══════════════════════════════════════════════════════
    private void handleCaseStatus(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId  = req.getParameter("caseId");
        String status  = req.getParameter("status");
        String progStr = req.getParameter("progress");

        if (isEmpty(caseId)) { writeResult(res, false, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();

            // 접근 권한 확인 (등록자 또는 같은 부서 팀원)
            ps = conn.prepareStatement(
                "SELECT 1 FROM cases WHERE case_id = ? " +
                "AND (user_id = ? " +
                "   OR user_id IN ( " +
                "       SELECT u2.user_id FROM users u2 " +
                "       JOIN users me ON me.user_id = ? " +
                "       WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL " +
                "   ))");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            ps.setString(3, loginUser);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                rs.close();
                writeResult(res, false, "수정 권한이 없습니다.");
                return;
            }
            rs.close();
            mgr.freeConnection(null, ps);

            List<Object> params = new ArrayList<>();
            StringBuilder sql = new StringBuilder("UPDATE cases SET updated_at = NOW()");

            if (!isEmpty(status)) {
                sql.append(", status = ?");
                params.add(status);
            }
            if (!isEmpty(progStr)) {
                int progress = Math.max(0, Math.min(100, Integer.parseInt(progStr)));
                sql.append(", progress = ?");
                params.add(progress);
            }
            sql.append(" WHERE case_id = ?");
            params.add(caseId);

            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ps.executeUpdate();

            writeResult(res, true, "수정됐습니다.");

        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "수정 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 내 조서 목록 조회 (조서 탭)
    // ═══════════════════════════════════════════════════════
    private void handleDocList(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String keyword = nvl(req.getParameter("keyword"), "");

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT t.transcript_id, t.case_id, t.stmt_type, t.stmt_name, " +
                "       t.has_contradiction, t.created_at, " +
                "       CHAR_LENGTH(IFNULL(t.original_text,'')) AS text_len, " +
                "       c.case_name " +
                "FROM transcripts t " +
                "JOIN cases c ON t.case_id = c.case_id " +
                "WHERE t.user_id = ? "
            );

            List<Object> params = new ArrayList<>();
            params.add(loginUser);

            if (!keyword.isEmpty()) {
                sql.append("AND (c.case_id LIKE ? OR c.case_name LIKE ? OR t.stmt_name LIKE ?) ");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
            }

            sql.append("ORDER BY t.created_at DESC");

            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            rs = ps.executeQuery();

            JSONArray arr = new JSONArray();
            while (rs.next()) {
                String stmtType = nvl(rs.getString("stmt_type"), "미분류");
                String stmtName = nvl(rs.getString("stmt_name"), "미입력");
                boolean hasCont = rs.getBoolean("has_contradiction");

                String docStatus = hasCont ? "모순탐지" : "완료";

                JSONObject d = new JSONObject();
                d.put("id",           rs.getInt("transcript_id"));
                d.put("caseId",       rs.getString("case_id"));
                d.put("caseName",     rs.getString("case_name"));
                d.put("title",        stmtName + " " + stmtType + " 진술 조서");
                d.put("type",         stmtType);
                d.put("status",       docStatus);
                d.put("words",        rs.getInt("text_len"));
                d.put("contradiction", hasCont);

                Timestamp ts = rs.getTimestamp("created_at");
                d.put("date", ts != null ? DATE_FMT.format(ts) : "");

                arr.put(d);
            }

            res.getWriter().write(arr.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "조서 목록 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 조서 통계 조회
    // ═══════════════════════════════════════════════════════
    private void handleDocStats(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            ps = conn.prepareStatement(
                "SELECT " +
                "  COUNT(*) AS total, " +
                "  SUM(CASE WHEN has_contradiction = 1 THEN 1 ELSE 0 END) AS contradiction " +
                "FROM transcripts " +
                "WHERE user_id = ?");
            ps.setString(1, loginUser);
            rs = ps.executeQuery();

            JSONObject stats = new JSONObject();
            if (rs.next()) {
                stats.put("total",         rs.getInt("total"));
                stats.put("contradiction", rs.getInt("contradiction"));
            } else {
                stats.put("total",         0);
                stats.put("contradiction", 0);
            }

            res.getWriter().write(stats.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "통계 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 조서 저장
    // 접근 권한: 내 사건 또는 같은 부서 팀원 사건
    // ═══════════════════════════════════════════════════════
    private void handleTranscriptSave(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String caseId       = req.getParameter("caseId");
        String stmtType     = nvl(req.getParameter("stmtType"),     "");
        String stmtName     = nvl(req.getParameter("stmtName"),     "");
        String originalText = nvl(req.getParameter("originalText"), "");

        if (isEmpty(caseId)) {
            writeResult(res, false, "사건번호를 선택해 주세요.");
            return;
        }
        if (isEmpty(originalText)) {
            writeResult(res, false, "진술 내용을 입력해 주세요.");
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            // 접근 권한 확인 (내 사건 또는 같은 부서 팀원 사건)
            ps = conn.prepareStatement(
                "SELECT 1 FROM cases WHERE case_id = ? " +
                "AND (user_id = ? " +
                "   OR user_id IN ( " +
                "       SELECT u2.user_id FROM users u2 " +
                "       JOIN users me ON me.user_id = ? " +
                "       WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL " +
                "   ))");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            ps.setString(3, loginUser);
            rs = ps.executeQuery();
            if (!rs.next()) {
                writeResult(res, false, "해당 사건에 접근 권한이 없습니다.");
                return;
            }
            rs.close();
            mgr.freeConnection(null, ps);

            // transcripts INSERT
            ps = conn.prepareStatement(
                "INSERT INTO transcripts (case_id, user_id, original_text, stmt_type, stmt_name, has_contradiction) " +
                "VALUES (?, ?, ?, ?, ?, 0)",
                java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            ps.setString(3, originalText);
            ps.setString(4, stmtType.isEmpty() ? null : stmtType);
            ps.setString(5, stmtName.isEmpty() ? null : stmtName);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            rs.next();
            int newId = rs.getInt(1);

            JSONObject result = new JSONObject();
            result.put("success",      true);
            result.put("transcriptId", newId);
            result.put("message",      "조서가 저장됐습니다.");
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "조서 저장 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 조서 원문 단건 조회
    // 접근 권한: 내 사건 또는 같은 부서 팀원 사건
    // ═══════════════════════════════════════════════════════
    private void handleTranscriptText(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String idStr = req.getParameter("transcriptId");
        if (isEmpty(idStr)) { writeError(res, "transcriptId가 필요합니다."); return; }

        int transcriptId;
        try { transcriptId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) { writeError(res, "잘못된 transcriptId"); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            ps = conn.prepareStatement(
                "SELECT t.transcript_id, t.original_text, t.stmt_type, t.stmt_name " +
                "FROM transcripts t " +
                "JOIN cases c ON t.case_id = c.case_id " +
                "WHERE t.transcript_id = ? " +
                "AND (c.user_id = ? " +
                "   OR c.user_id IN ( " +
                "       SELECT u2.user_id FROM users u2 " +
                "       JOIN users me ON me.user_id = ? " +
                "       WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL " +
                "   ))");
            ps.setInt(1, transcriptId);
            ps.setString(2, loginUser);
            ps.setString(3, loginUser);
            rs = ps.executeQuery();

            if (!rs.next()) {
                writeError(res, "조서를 찾을 수 없거나 접근 권한이 없습니다.");
                return;
            }

            JSONObject result = new JSONObject();
            result.put("id",   rs.getInt("transcript_id"));
            result.put("text", nvl(rs.getString("original_text"), ""));
            result.put("type", nvl(rs.getString("stmt_type"),     ""));
            result.put("name", nvl(rs.getString("stmt_name"),     ""));
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "조서 원문 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 내 부서 정보 조회 (새 사건 등록 드로어에서 사용)
    // departments 조인으로 부서명·소속기관 반환
    // 부서 미배정이면 {"deptId":null, "deptName":"미배정"}
    // ═══════════════════════════════════════════════════════
    private void handleMyDept(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            ps = conn.prepareStatement(
                "SELECT d.dept_id, d.dept_name, d.org_name " +
                "FROM users u " +
                "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
                "WHERE u.user_id = ?");
            ps.setString(1, loginUser);
            rs = ps.executeQuery();

            JSONObject result = new JSONObject();
            if (rs.next() && rs.getString("dept_name") != null) {
                result.put("deptId",   rs.getInt("dept_id"));
                result.put("deptName", rs.getString("dept_name"));
                result.put("org",      nvl(rs.getString("org_name"), ""));
                result.put("label",    rs.getString("dept_name") + " (" + nvl(rs.getString("org_name"), "") + ")");
            } else {
                result.put("deptId",   JSONObject.NULL);
                result.put("deptName", "미배정");
                result.put("org",      "");
                result.put("label",    "부서 미배정");
            }

            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "부서 정보 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 헬퍼
    // ═══════════════════════════════════════════════════════
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

    private String nvl(String s, String def) { return (s == null || s.trim().isEmpty()) ? def : s.trim(); }
    private String nvl(String s)             { return nvl(s, ""); }
    private boolean isEmpty(String s)        { return s == null || s.trim().isEmpty(); }
}
