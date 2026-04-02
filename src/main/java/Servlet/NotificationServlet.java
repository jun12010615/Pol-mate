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
 * NotificationServlet
 * URL: /notifApi
 *
 * action 파라미터:
 *   list        - 내 알림 목록 조회 (GET) + 비밀번호 만료 체크 포함
 *   unreadCount - 미읽음 알림 수 조회 (GET)  ← 상단 뱃지용
 *   markRead    - 특정 알림 읽음 처리 (POST)
 *   markAllRead - 전체 읽음 처리 (POST)
 */
@WebServlet("/notifApi")
public class NotificationServlet extends HttpServlet {

    private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("yyyy.MM.dd HH:mm");
    // 비밀번호 변경 권고 주기 (일)
    private static final int PW_WARN_DAYS = 90;

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

        String action = nvl(req.getParameter("action"), "list");

        switch (action) {
            case "list":        handleList(req, res, loginUser);        break;
            case "unreadCount": handleUnreadCount(res, loginUser);      break;
            default:            writeError(res, "알 수 없는 action");
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
            case "markRead":    handleMarkRead(req, res, loginUser);    break;
            case "markAllRead": handleMarkAllRead(res, loginUser);      break;
            default:            writeError(res, "알 수 없는 action");
        }
    }

    // ═══════════════════════════════════════════════════════
    // 알림 목록 조회
    // - 비밀번호 만료 경고 알림을 실시간으로 앞에 붙여서 반환
    // - 야간 방해금지 시간대에는 빈 배열 반환
    // ═══════════════════════════════════════════════════════
    private void handleList(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        // 야간 방해금지 시간대 체크
        if (isNightMode(loginUser) && isNightTime()) {
            res.getWriter().write("[]");
            return;
        }

        String typeFilter = nvl(req.getParameter("type"), "all");

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            JSONArray arr = new JSONArray();

            // ── 1. 비밀번호 만료 경고 (DB 저장 없이 실시간 계산) ──
            if ("all".equals(typeFilter) || "sys".equals(typeFilter)) {
                ps = conn.prepareStatement(
                    "SELECT DATEDIFF(NOW(), IFNULL(password_changed_at, created_at)) AS days_since " +
                    "FROM users WHERE user_id = ?");
                ps.setString(1, loginUser);
                rs = ps.executeQuery();
                if (rs.next()) {
                    int daysSince = rs.getInt("days_since");
                    if (daysSince >= PW_WARN_DAYS) {
                        JSONObject pw = new JSONObject();
                        pw.put("notifId",     -1);              // 가상 ID (DB 없음)
                        pw.put("type",        "sys");
                        pw.put("tag",         "보안");
                        pw.put("title",       "비밀번호 변경 권고");
                        pw.put("description", "마지막 비밀번호 변경 후 " + daysSince + "일이 경과했습니다. 보안을 위해 비밀번호를 변경해 주세요.");
                        pw.put("link",        "mypage.jsp");
                        pw.put("isUnread",    true);
                        pw.put("isCritical",  daysSince >= 180);  // 180일 이상이면 긴급
                        pw.put("timeLabel",   "보안 알림");
                        arr.put(pw);
                    }
                }
                rs.close();
                mgr.freeConnection(null, ps);
            }

            // ── 2. DB 알림 목록 조회 ──
            StringBuilder sql = new StringBuilder(
                "SELECT notif_id, type, tag, title, description, link, " +
                "       is_unread, is_critical, created_at " +
                "FROM notifications " +
                "WHERE user_id = ? ");

            List<Object> params = new ArrayList<>();
            params.add(loginUser);

            if (!"all".equals(typeFilter)) {
                sql.append("AND type = ? ");
                params.add(typeFilter);
            }

            sql.append("ORDER BY created_at DESC LIMIT 100");

            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject n = new JSONObject();
                n.put("notifId",     rs.getInt("notif_id"));
                n.put("type",        nvl(rs.getString("type"),        "sys"));
                n.put("tag",         nvl(rs.getString("tag"),         ""));
                n.put("title",       nvl(rs.getString("title"),       ""));
                n.put("description", nvl(rs.getString("description"), ""));
                n.put("link",        nvl(rs.getString("link"),        ""));
                n.put("isUnread",    rs.getBoolean("is_unread"));
                n.put("isCritical",  rs.getBoolean("is_critical"));

                Timestamp ts = rs.getTimestamp("created_at");
                n.put("timeLabel", ts != null ? relativeTime(ts) : "");
                arr.put(n);
            }

            res.getWriter().write(arr.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "알림 목록 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 미읽음 수 조회 (상단 뱃지)
    // 비밀번호 만료 경고도 포함해서 카운트
    // 야간 방해금지 시간(22:00~07:00)에는 0 반환
    // ═══════════════════════════════════════════════════════
    private void handleUnreadCount(HttpServletResponse res, String loginUser)
            throws IOException {

        // 야간 방해금지 시간대 체크
        if (isNightMode(loginUser) && isNightTime()) {
            JSONObject result = new JSONObject();
            result.put("count", 0);
            res.getWriter().write(result.toString());
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            // DB 미읽음 수
            ps = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM notifications WHERE user_id = ? AND is_unread = 1");
            ps.setString(1, loginUser);
            rs = ps.executeQuery();
            int cnt = rs.next() ? rs.getInt("cnt") : 0;
            rs.close();
            mgr.freeConnection(null, ps);

            // 비밀번호 만료 여부
            ps = conn.prepareStatement(
                "SELECT DATEDIFF(NOW(), IFNULL(password_changed_at, created_at)) AS days_since " +
                "FROM users WHERE user_id = ?");
            ps.setString(1, loginUser);
            rs = ps.executeQuery();
            if (rs.next() && rs.getInt("days_since") >= PW_WARN_DAYS) {
                cnt++;
            }

            JSONObject result = new JSONObject();
            result.put("count", cnt);
            res.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, "미읽음 수 조회 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 특정 알림 읽음 처리
    // ═══════════════════════════════════════════════════════
    private void handleMarkRead(HttpServletRequest req, HttpServletResponse res, String loginUser)
            throws IOException {

        String idStr = nvl(req.getParameter("notifId"), "");
        if (idStr.isEmpty()) { writeResult(res, false, "notifId가 필요합니다."); return; }

        int notifId;
        try { notifId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) { writeResult(res, false, "잘못된 notifId"); return; }

        // notifId == -1 은 비밀번호 경고 가상 알림이므로 DB 처리 불필요
        if (notifId == -1) {
            writeResult(res, true, "읽음 처리됐습니다.");
            return;
        }

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();
            ps = conn.prepareStatement(
                "UPDATE notifications SET is_unread = 0 WHERE notif_id = ? AND user_id = ?");
            ps.setInt(1, notifId);
            ps.setString(2, loginUser);
            ps.executeUpdate();
            writeResult(res, true, "읽음 처리됐습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "읽음 처리 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 전체 읽음 처리
    // ═══════════════════════════════════════════════════════
    private void handleMarkAllRead(HttpServletResponse res, String loginUser)
            throws IOException {

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = mgr.getConnection();
            ps = conn.prepareStatement(
                "UPDATE notifications SET is_unread = 0 WHERE user_id = ? AND is_unread = 1");
            ps.setString(1, loginUser);
            ps.executeUpdate();
            writeResult(res, true, "모두 읽음 처리됐습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            writeResult(res, false, "전체 읽음 처리 중 오류가 발생했습니다.");
        } finally {
            mgr.freeConnection(conn, ps);
        }
    }

    // ═══════════════════════════════════════════════════════
    // 야간 방해금지 헬퍼
    // ═══════════════════════════════════════════════════════

    /** DB에서 해당 유저의 night_mode 설정 조회 */
    private boolean isNightMode(String userId) {
        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = mgr.getConnection();
            ps = conn.prepareStatement("SELECT night_mode FROM users WHERE user_id = ?");
            ps.setString(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("night_mode") == 1;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, ps, rs);
        }
        return false;
    }

    /** 현재 시각이 야간 방해금지 시간(22:00~07:00)인지 확인 */
    private boolean isNightTime() {
        int hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY);
        return hour >= 22 || hour < 7;
    }

    // ═══════════════════════════════════════════════════════
    // 유틸: 알림 INSERT 헬퍼 (CaseServlet 등 타 서블릿에서 호출)
    // conn은 호출자가 관리 (트랜잭션 공유 가능)
    // ═══════════════════════════════════════════════════════
    public static void insertNotification(Connection conn,
                                          String userId,
                                          String type,
                                          String tag,
                                          String title,
                                          String description,
                                          String link,
                                          boolean isCritical) throws SQLException {
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(
                "INSERT INTO notifications (user_id, type, tag, title, description, link, is_unread, is_critical) " +
                "VALUES (?, ?, ?, ?, ?, ?, 1, ?)");
            ps.setString(1, userId);
            ps.setString(2, type);
            ps.setString(3, tag);
            ps.setString(4, title);
            ps.setString(5, description);
            ps.setString(6, link);
            ps.setBoolean(7, isCritical);
            ps.executeUpdate();
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }

    // ═══════════════════════════════════════════════════════
    // 유틸: 상대 시간 문자열
    // ═══════════════════════════════════════════════════════
    private String relativeTime(Timestamp ts) {
        long diff = System.currentTimeMillis() - ts.getTime();
        long min  = diff / 60000;
        if (min < 1)   return "방금 전";
        if (min < 60)  return min + "분 전";
        long hour = min / 60;
        if (hour < 24) return hour + "시간 전";
        long day = hour / 24;
        if (day < 7)   return day + "일 전";
        return new SimpleDateFormat("MM.dd").format(ts);
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

    private String nvl(String s, String def) {
        return (s == null || s.trim().isEmpty()) ? def : s.trim();
    }
}
