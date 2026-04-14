package Servlet;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
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
    static { DATE_FMT.setTimeZone(TimeZone.getTimeZone("Asia/Seoul")); }

    /** Pol-mate-Serv 베이스 URL (WEB-INF/config.properties 의 POL_MATE_SERV_BASE_URL) */
    private String polMateServBaseUrl = "http://113.198.238.108:5001";

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            Properties props = new Properties();
            InputStream is = getServletContext().getResourceAsStream("/WEB-INF/config.properties");
            if (is != null) {
                props.load(is);
                String u = props.getProperty("POL_MATE_SERV_BASE_URL", "").trim();
                if (!u.isEmpty()) {
                    while (u.endsWith("/")) u = u.substring(0, u.length() - 1);
                    polMateServBaseUrl = u;
                }
            }
        } catch (IOException e) {
            log("CaseServlet: config.properties 로드 실패 — 기본 Pol-mate-Serv URL 사용");
        }
    }

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
            case "transcriptSave":     handleTranscriptSave(req, res, loginUser);     break;
            case "transcriptSummarize": handleTranscriptSummarize(req, res, loginUser); break;
            default:                   writeError(res, "알 수 없는 action");
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
                "       c.created_at, c.user_id, " +
                "       u.user_name, u.user_rank, " +
                "       (SELECT COUNT(*) FROM transcripts t WHERE t.case_id = c.case_id) AS doc_count, " +
                "       (SELECT COUNT(*) FROM transcripts t WHERE t.case_id = c.case_id AND t.has_contradiction = 1) AS contradiction_count " +
                "FROM cases c " +
                "LEFT JOIN users u ON c.user_id = u.user_id " +
                // 사건 등록 시 고정된 cases.dept_id = 내 현재 dept_id 인 사건만 조회
                // 등록자가 부서를 옮겨도 사건은 cases.dept_id(고정)에 묶여 원래 부서에 남음
                "WHERE c.dept_id = (SELECT me.dept_id FROM users me WHERE me.user_id = ?) "
            );

            List<Object> params = new ArrayList<>();
            params.add(loginUser); // me.user_id

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
                c.put("docs",           rs.getInt("doc_count"));
                c.put("contradictions", rs.getInt("contradiction_count"));
                c.put("urgent",         rs.getInt("contradiction_count") > 0);
                c.put("isMine",         loginUser.equals(rs.getString("user_id")));

                Timestamp ts = rs.getTimestamp("created_at");
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
                "       c.created_at, c.user_id, c.dept_id AS case_dept_id, " +
                "       u.user_name, u.user_rank, " +
                "       d.dept_name, d.org_name " +
                "FROM cases c " +
                "LEFT JOIN users u ON c.user_id = u.user_id " +
                "LEFT JOIN departments d ON c.dept_id = d.dept_id " +
                "WHERE c.case_id = ? " +
                "AND c.dept_id = (SELECT me.dept_id FROM users me WHERE me.user_id = ?)");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
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

            Timestamp ts = rs.getTimestamp("created_at");
            detail.put("date", ts != null ? DATE_FMT.format(ts) : "");
            mgr.freeConnection(null, ps, rs);

            // 해당 사건의 조서 목록
            ps = conn.prepareStatement(
                "SELECT t.transcript_id, t.stmt_type, t.stmt_name, t.has_contradiction, " +
                "       t.created_at, t.user_id, u.user_name, u.user_rank, " +
                "       CHAR_LENGTH(IFNULL(t.original_text,'')) AS text_len " +
                "FROM transcripts t " +
                "LEFT JOIN users u ON t.user_id = u.user_id " +
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
                d.put("writerId",     nvl(rs.getString("user_id"),   ""));
                d.put("writerName",   nvl(rs.getString("user_name"), "알 수 없음"));
                d.put("writerRank",   nvl(rs.getString("user_rank"), ""));
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

            // 등록자의 dept_id 조회 (등록 시점 고정용)
            ps = conn.prepareStatement(
                "SELECT u.dept_id, d.dept_name, d.org_name FROM users u " +
                "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
                "WHERE u.user_id = ?");
            ps.setString(1, loginUser);
            rs = ps.executeQuery();

            Integer creatorDeptId = null;
            String deptLabel = "부서 미배정";
            if (rs.next()) {
                int deptIdVal = rs.getInt("dept_id");
                if (!rs.wasNull()) {
                    creatorDeptId = deptIdVal;
                    String dn = rs.getString("dept_name");
                    String on = rs.getString("org_name");
                    if (dn != null && !dn.isEmpty()) {
                        deptLabel = on != null && !on.isEmpty() ? dn + " (" + on + ")" : dn;
                    }
                }
            }
            rs.close();
            mgr.freeConnection(null, ps);

            // 사건 INSERT — 등록 시점의 dept_id를 cases 테이블에 함께 저장
            ps = conn.prepareStatement(
                "INSERT INTO cases (case_id, user_id, dept_id, case_name, suspect, charge, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, '진행중')");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            if (creatorDeptId != null) ps.setInt(3, creatorDeptId);
            else                       ps.setNull(3, java.sql.Types.INTEGER);
            ps.setString(4, caseName.trim());
            ps.setString(5, suspect.isEmpty() ? null : suspect.trim());
            ps.setString(6, charge.isEmpty()  ? null : charge.trim());
            ps.executeUpdate();
            mgr.freeConnection(null, ps);

            // 응답용 부서 정보는 이미 위에서 조회함
            rs = null;
            ps = null;

            // ── 같은 부서 팀원(본인 제외)에게 알림 발송 (실패해도 등록은 유지) ──
            try {
                // cases.dept_id(고정값) 기준으로 같은 부서 팀원 조회
                ps = conn.prepareStatement(
                    "SELECT u2.user_id FROM users u2 " +
                    "WHERE u2.dept_id = ? AND u2.dept_id IS NOT NULL " +
                    "  AND u2.user_id != ? AND u2.notif_relation = 1");
                if (creatorDeptId != null) ps.setInt(1, creatorDeptId);
                else                       ps.setNull(1, java.sql.Types.INTEGER);
                ps.setString(2, loginUser);
                ResultSet rsTeam = ps.executeQuery();
                List<String> teammates = new ArrayList<>();
                while (rsTeam.next()) teammates.add(rsTeam.getString("user_id"));
                rsTeam.close();
                mgr.freeConnection(null, ps);
                ps = null;

                String notifTitle = "팀 새 사건 등록: " + caseName.trim();
                String notifDesc  = "사건 " + caseId + "(" + caseName.trim() + ")이(가) 팀에 등록됐습니다.";
                for (String teammate : teammates) {
                    try {
                        NotificationServlet.insertNotification(
                            conn, teammate, "case", "새 사건", notifTitle, notifDesc,
                            "myCase.jsp?caseId=" + caseId, false);
                    } catch (Exception ignored) {}
                }
            } catch (SQLException notifEx) {
                notifEx.printStackTrace();
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

        if (isEmpty(caseId)) { writeResult(res, false, "caseId가 필요합니다."); return; }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();

            // 접근 권한 확인
            ps = conn.prepareStatement(
                "SELECT 1 FROM cases WHERE case_id = ? " +
                "AND dept_id = (SELECT me.dept_id FROM users me WHERE me.user_id = ?)");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
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
            sql.append(" WHERE case_id = ?");
            params.add(caseId);

            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ps.executeUpdate();

            // ── 상태 변경 시 팀원 알림 발송 (설정 확인) ──────────
            if (!isEmpty(status)) {
                mgr.freeConnection(null, ps);
                boolean isCritical = "모순탐지".equals(status);
                String notifCol   = isCritical ? "notif_contradiction" : "notif_relation";
                // 사건에 고정된 dept_id 기준으로 팀원 조회
                ps = conn.prepareStatement(
                    "SELECT u2.user_id FROM users u2 " +
                    "JOIN cases c ON c.case_id = ? " +
                    "WHERE u2.dept_id = c.dept_id AND c.dept_id IS NOT NULL " +
                    "  AND u2.user_id != ? AND u2." + notifCol + " = 1");
                ps.setString(1, caseId);
                ps.setString(2, loginUser);
                ResultSet rsTeam = ps.executeQuery();
                List<String> teammates = new ArrayList<>();
                while (rsTeam.next()) teammates.add(rsTeam.getString("user_id"));
                rsTeam.close();
                mgr.freeConnection(null, ps);

                String notifTitle = "사건 상태 변경: " + caseId;
                String notifDesc  = "사건 " + caseId + "의 상태가 [" + status + "](으)로 변경됐습니다.";
                String tag        = isCritical ? "경고" : "새 사건";
                for (String teammate : teammates) {
                    try {
                        NotificationServlet.insertNotification(
                            conn, teammate, "case", tag,
                            notifTitle, notifDesc,
                            "myCase.jsp?caseId=" + caseId, isCritical);
                    } catch (Exception ignored) {}
                }
            }

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

            // 접근 권한 확인 (내 사건 또는 같은 부서 팀원 사건 — 등록 시 고정된 dept_id 기준)
            ps = conn.prepareStatement(
                "SELECT 1 FROM cases WHERE case_id = ? " +
                "AND dept_id = (SELECT me.dept_id FROM users me WHERE me.user_id = ?)");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
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

            // ── 같은 부서 팀원(본인 제외)에게 알림 발송 — 사건 고정 dept_id 기준 ──────────
            mgr.freeConnection(null, ps);
            ps = conn.prepareStatement(
                "SELECT u2.user_id FROM users u2 " +
                "JOIN cases c ON c.case_id = ? " +
                "WHERE u2.dept_id = c.dept_id AND c.dept_id IS NOT NULL " +
                "  AND u2.user_id != ? AND u2.notif_contradiction = 1");
            ps.setString(1, caseId);
            ps.setString(2, loginUser);
            ResultSet rsTeam = ps.executeQuery();
            List<String> teammates = new ArrayList<>();
            while (rsTeam.next()) teammates.add(rsTeam.getString("user_id"));
            rsTeam.close();
            mgr.freeConnection(null, ps);

            String who   = stmtName.isEmpty() ? "" : stmtName + " ";
            String tDesc = "사건 " + caseId + "에 " + who + (stmtType.isEmpty() ? "" : stmtType + " ") + "조서가 추가됐습니다.";
            for (String teammate : teammates) {
                try {
                    NotificationServlet.insertNotification(
                        conn, teammate, "case", "조서",
                        "새 조서 등록: " + caseId, tDesc,
                        "myCase.jsp?caseId=" + caseId, false);
                } catch (Exception ignored) {}
            }

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
                "SELECT t.transcript_id, t.original_text, t.stmt_type, t.stmt_name, t.ai_result " +
                "FROM transcripts t " +
                "JOIN cases c ON t.case_id = c.case_id " +
                "WHERE t.transcript_id = ? " +
                "AND c.dept_id = (SELECT me.dept_id FROM users me WHERE me.user_id = ?)");
            ps.setInt(1, transcriptId);
            ps.setString(2, loginUser);
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
            String ar = rs.getString("ai_result");
            result.put("summary", (ar != null && !ar.isEmpty()) ? ar : "");
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "조서 원문 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 조서 AI 요약 저장 (transcripts.ai_result)
    // Pol-mate-Serv POST /summarize 호출 후 DB 반영
    // ═══════════════════════════════════════════════════════
    private void handleTranscriptSummarize(HttpServletRequest req, HttpServletResponse res, String loginUser)
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

        String caseId = null;
        String originalText = null;
        String stmtType = null;
        String stmtName = null;

        try {
            conn = mgr.getConnection();

            ps = conn.prepareStatement(
                "SELECT t.case_id, t.original_text, t.stmt_type, t.stmt_name " +
                "FROM transcripts t " +
                "JOIN cases c ON t.case_id = c.case_id " +
                "WHERE t.transcript_id = ? " +
                "AND c.dept_id = (SELECT me.dept_id FROM users me WHERE me.user_id = ?)");
            ps.setInt(1, transcriptId);
            ps.setString(2, loginUser);
            rs = ps.executeQuery();

            if (!rs.next()) {
                writeError(res, "조서를 찾을 수 없거나 접근 권한이 없습니다.");
                return;
            }

            caseId = rs.getString("case_id");
            originalText = rs.getString("original_text");
            stmtType = rs.getString("stmt_type");
            stmtName = rs.getString("stmt_name");
            mgr.freeConnection(null, ps, rs);
            ps = null;
            rs = null;

            if (originalText == null || originalText.trim().isEmpty()) {
                writeResult(res, false, "요약할 진술 본문이 없습니다.");
                return;
            }

            JSONObject body = new JSONObject();
            body.put("caseNum", caseId != null ? caseId : "미입력");
            body.put("text", originalText);
            body.put("stmtType", stmtType != null && !stmtType.trim().isEmpty() ? stmtType.trim() : "진술자");
            body.put("stmtName", stmtName != null && !stmtName.trim().isEmpty() ? stmtName.trim() : "미입력");

            String structured = callPolMateSummarize(body);
            if (structured == null) {
                writeResult(res, false, "요약 서버 호출에 실패했습니다.");
                return;
            }

            ps = conn.prepareStatement(
                "UPDATE transcripts SET ai_result = ? WHERE transcript_id = ?");
            ps.setString(1, structured);
            ps.setInt(2, transcriptId);
            int n = ps.executeUpdate();
            mgr.freeConnection(null, ps);
            ps = null;

            JSONObject out = new JSONObject();
            out.put("success", n > 0);
            out.put("message", n > 0 ? "요약이 저장되었습니다." : "요약 저장에 실패했습니다.");
            res.getWriter().write(out.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            writeResult(res, false, "요약 저장 중 DB 오류가 발생했습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "요약 처리 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    /** Pol-mate-Serv /summarize — 성공 시 structured_summary 문자열, 실패 시 null */
    private String callPolMateSummarize(JSONObject body) {
        HttpURLConnection hc = null;
        try {
            URL url = new URL(polMateServBaseUrl + "/summarize");
            hc = (HttpURLConnection) url.openConnection();
            hc.setRequestMethod("POST");
            hc.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            hc.setDoOutput(true);
            hc.setConnectTimeout(15000);
            hc.setReadTimeout(120000);

            byte[] bytes = body.toString().getBytes(StandardCharsets.UTF_8);
            try (OutputStream os = hc.getOutputStream()) {
                os.write(bytes);
            }

            int code = hc.getResponseCode();
            InputStream inStream = (code >= 200 && code < 300) ? hc.getInputStream() : hc.getErrorStream();
            if (inStream == null) return null;

            StringBuilder sb = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(inStream, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) sb.append(line);
            }

            JSONObject j = new JSONObject(sb.toString());
            if (!j.optBoolean("success", false)) return null;
            String structured = j.optString("structured_summary", null);
            if (structured == null || structured.isEmpty()) return null;
            return structured;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (hc != null) hc.disconnect();
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
