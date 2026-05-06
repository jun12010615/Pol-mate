<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Servlet.DBConnectionMgr, java.sql.*" %>
<%
String loginUser = (String) session.getAttribute("loginUser");
String userName  = (String) session.getAttribute("userName");
if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/desktop/login.jsp"); return; }

request.setAttribute("currentPage", "dashboard");
request.setAttribute("breadcrumb",  new String[]{"POL-MATE", "&#45824;&#49884;&#48372;&#46300;"});

int cntActive = 0, cntContradiction = 0, cntTranscript = 0, cntBoard = 0;
java.util.List<String[]> recentCases = new java.util.ArrayList<>();
String alertCaseId = null;

DBConnectionMgr mgr = DBConnectionMgr.getInstance();
Connection conn = null;
try {
    conn = mgr.getConnection();
    PreparedStatement ps;
    ResultSet rs;

    ps = conn.prepareStatement("SELECT COUNT(*) FROM cases WHERE user_id=? AND status='진행중'");
    ps.setString(1, loginUser); rs = ps.executeQuery();
    if (rs.next()) cntActive = rs.getInt(1);
    rs.close(); ps.close();

    ps = conn.prepareStatement("SELECT COUNT(*) FROM cases WHERE user_id=? AND status='모순탐지'");
    ps.setString(1, loginUser); rs = ps.executeQuery();
    if (rs.next()) cntContradiction = rs.getInt(1);
    rs.close(); ps.close();

    ps = conn.prepareStatement("SELECT COUNT(*) FROM transcripts WHERE user_id=?");
    ps.setString(1, loginUser); rs = ps.executeQuery();
    if (rs.next()) cntTranscript = rs.getInt(1);
    rs.close(); ps.close();

    ps = conn.prepareStatement("SELECT COUNT(*) FROM board_posts WHERE user_id=?");
    ps.setString(1, loginUser); rs = ps.executeQuery();
    if (rs.next()) cntBoard = rs.getInt(1);
    rs.close(); ps.close();

    ps = conn.prepareStatement(
        "SELECT case_id, case_name, status, updated_at FROM cases WHERE user_id=? ORDER BY updated_at DESC LIMIT 5");
    ps.setString(1, loginUser); rs = ps.executeQuery();
    while (rs.next()) {
        String upd = rs.getString("updated_at");
        recentCases.add(new String[]{
            rs.getString("case_id"),
            rs.getString("case_name"),
            rs.getString("status"),
            upd != null && upd.length() >= 10 ? upd.substring(0, 10) : ""
        });
        if (alertCaseId == null && "모순탐지".equals(rs.getString("status")))
            alertCaseId = rs.getString("case_id");
    }
    rs.close(); ps.close();
} catch (Exception e) {
    e.printStackTrace();
} finally {
    mgr.freeConnection(conn);
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>POL-MATE | &#45824;&#49884;&#48372;&#46300;</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/polmate.css">
<script>var _ctx = '<%= request.getContextPath() %>';</script>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: #f4f6fb; color: #1a1a2e; -webkit-font-smoothing: antialiased; word-break: keep-all; }
.pm-page { padding: 32px 36px 56px; max-width: 1280px; margin: 0 auto; }
.pm-greeting-sub { font-size: 11px; color: #9ca3af; letter-spacing: 0.8px; text-transform: uppercase; margin-bottom: 4px; }
.pm-greeting-name { font-size: 22px; font-weight: 500; color: #1a1a2e; }
.pm-greeting-name strong { font-family: 'Space Grotesk', sans-serif; font-weight: 700; }
.pm-greeting-hint { font-size: 12px; color: #6b7280; margin-top: 4px; }
.pm-stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin: 28px 0; }
.pm-stat-card { background: #fff; border: 1px solid #e2e5ee; border-radius: 16px; padding: 20px; text-align: center; }
.pm-stat-val { font-family: 'Space Grotesk', sans-serif; font-size: 32px; font-weight: 700; color: #0d1a33; line-height: 1.1; }
.pm-stat-val.danger { color: #dc2626; }
.pm-stat-lbl { font-size: 11px; color: #9ca3af; margin-top: 6px; letter-spacing: 0.3px; }
.pm-sec-label {
    font-size: 11px; font-weight: 500; color: #6b7280;
    text-transform: uppercase; letter-spacing: 0.8px;
    display: flex; align-items: center; gap: 10px; margin-bottom: 14px;
}
.pm-sec-label::after { content: ''; flex: 1; height: 1px; background: #e2e5ee; }
.pm-tool-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 36px; }
.pm-tool-card {
    background: #0d1a33; color: #fff;
    border-radius: 16px; padding: 22px;
    cursor: pointer; position: relative; overflow: hidden;
    min-height: 170px; display: flex; flex-direction: column;
    border: 1px solid rgba(240,192,64,0.12);
    transition: transform 0.15s, box-shadow 0.15s;
    text-decoration: none;
}
.pm-tool-card:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(13,26,51,0.18); }
.pm-tool-card::after {
    content: ''; position: absolute;
    bottom: 0; left: 24px; right: 24px; height: 2px;
    background: linear-gradient(90deg, transparent, #f0c040, transparent);
    opacity: 0.32;
}
.pm-tool-icon {
    width: 46px; height: 46px; border-radius: 11px;
    background: rgba(240,192,64,0.12); border: 1px solid rgba(240,192,64,0.22);
    color: #f0c040;
    display: flex; align-items: center; justify-content: center;
    margin-bottom: 14px; position: relative; flex-shrink: 0;
}
.pm-urgent-dot {
    position: absolute; top: -4px; right: -4px;
    width: 10px; height: 10px; border-radius: 50%;
    background: #dc2626; border: 2px solid #0d1a33;
}
.pm-tool-title { font-size: 15px; font-weight: 500; margin-bottom: 4px; }
.pm-tool-desc { font-size: 11px; color: rgba(255,255,255,0.52); line-height: 1.6; flex: 1; }
.pm-tool-meta { margin-top: 12px; font-size: 10px; color: rgba(255,255,255,0.42); letter-spacing: 0.4px; }
.pm-lower-grid { display: grid; grid-template-columns: 1fr 340px; gap: 20px; }
.pm-case-table { background: #fff; border: 1px solid #e2e5ee; border-radius: 16px; overflow: hidden; }
.pm-case-table-head { display: grid; grid-template-columns: 120px 1fr 100px 90px; padding: 10px 16px; border-bottom: 1px solid #e2e5ee; }
.pm-case-th { font-size: 10px; font-weight: 500; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.6px; }
.pm-case-row {
    display: grid; grid-template-columns: 120px 1fr 100px 90px;
    padding: 12px 16px; border-bottom: 1px solid #e2e5ee;
    text-decoration: none; color: inherit;
    transition: background 0.12s; align-items: center;
}
.pm-case-row:last-child { border-bottom: none; }
.pm-case-row:hover { background: #f4f6fb; }
.pm-case-row.urgent { border-left: 3px solid #dc2626; padding-left: 13px; }
.pm-case-id { font-size: 11px; color: #9ca3af; font-family: 'Space Grotesk', sans-serif; }
.pm-case-name { font-size: 13px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.pm-badge { display: inline-flex; align-items: center; font-size: 10px; font-weight: 500; padding: 3px 9px; border-radius: 20px; }
.pm-badge-jinhaeng { background: #f0fdf4; color: #16a34a; }
.pm-badge-wanryo   { background: #eff6ff; color: #1e40af; }
.pm-badge-moosun   { background: #fef2f2; color: #dc2626; }
.pm-badge-geomto   { background: #fffbeb; color: #92400e; }
.pm-case-date { font-size: 11px; color: #9ca3af; }
.pm-activity-feed { background: #fff; border: 1px solid #e2e5ee; border-radius: 16px; padding: 16px; }
.pm-activity-item { display: flex; align-items: flex-start; gap: 10px; padding: 10px 0; border-bottom: 1px solid #e2e5ee; }
.pm-activity-item:last-child { border-bottom: none; }
.pm-act-icon { width: 30px; height: 30px; border-radius: 8px; background: #f4f6fb; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.pm-act-title { font-size: 12px; font-weight: 500; margin-bottom: 2px; }
.pm-act-when { font-size: 10px; color: #9ca3af; margin-top: 2px; }
.pm-alert-banner {
    background: #fef2f2; border: 1px solid #fecaca;
    border-radius: 14px; padding: 12px 16px;
    display: flex; align-items: center; gap: 10px;
    margin-bottom: 20px; cursor: pointer;
    font-size: 13px; color: #dc2626; text-decoration: none;
}
.pm-alert-pulse { width: 8px; height: 8px; border-radius: 50%; background: #dc2626; animation: pmPulse 1.8s infinite; flex-shrink: 0; }
@keyframes pmPulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:0.5;transform:scale(1.3)} }
@media (max-width: 1100px) {
    .pm-stat-grid { grid-template-columns: repeat(2, 1fr); }
    .pm-tool-grid  { grid-template-columns: repeat(2, 1fr); }
    .pm-lower-grid { grid-template-columns: 1fr; }
}
@media (max-width: 700px) {
    .pm-page { padding: 20px 16px 40px; }
    .pm-tool-grid { grid-template-columns: 1fr 1fr; }
}
</style>
</head>
<body>
<div class="pm-layout">

<%@ include file="sidebar.jsp" %>
<div class="pm-content">
<%@ include file="appbar.jsp" %>

<main class="pm-page">

    <% if (alertCaseId != null) { %>
    <a href="<%= request.getContextPath() %>/desktop/myCase.jsp" class="pm-alert-banner">
        <span class="pm-alert-pulse"></span>
        <span>&#49324;&#44148; <strong><%= alertCaseId %></strong>&#50640;&#49436; &#51652;&#49696; &#47784;&#49692;&#51060; &#53456;&#51648;&#46104;&#50632;&#49845;&#45768;&#45796;.</span>
    </a>
    <% } %>

    <div style="margin-bottom:28px;">
        <div class="pm-greeting-sub">&#50504;&#45397;&#54616;&#49464;&#50836;,</div>
        <div class="pm-greeting-name"><strong><%= userName != null ? userName : loginUser %></strong> &#49688;&#49324;&#44288;</div>
        <% if (cntContradiction > 0) { %>
        <div class="pm-greeting-hint">&#49888;&#44508; &#47784;&#49692; &#53456;&#51648; <strong style="color:#dc2626"><%= cntContradiction %>&#44148;</strong>&#51060; &#51080;&#49845;&#45768;&#45796;.</div>
        <% } %>
    </div>

    <div class="pm-stat-grid">
        <div class="pm-stat-card"><div class="pm-stat-val"><%= cntActive %></div><div class="pm-stat-lbl">&#51652;&#54665; &#51473;&#51064; &#49324;&#44148;</div></div>
        <div class="pm-stat-card"><div class="pm-stat-val danger"><%= cntContradiction %></div><div class="pm-stat-lbl">&#47784;&#49692; &#53456;&#51648;</div></div>
        <div class="pm-stat-card"><div class="pm-stat-val"><%= cntTranscript %></div><div class="pm-stat-lbl">&#51089;&#49457;&#54620; &#51312;&#49436;</div></div>
        <div class="pm-stat-card"><div class="pm-stat-val"><%= cntBoard %></div><div class="pm-stat-lbl">&#44172;&#49884;&#54032; &#44544;</div></div>
    </div>

    <div class="pm-sec-label">&#51452;&#50836; &#49688;&#49324; &#46020;&#44396;</div>
    <div class="pm-tool-grid">
        <a href="<%= request.getContextPath() %>/desktop/writeTranscript.jsp" class="pm-tool-card">
            <div class="pm-tool-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
                    <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                    <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                    <line x1="12" y1="19" x2="12" y2="23"/>
                </svg>
            </div>
            <div class="pm-tool-title">&#51652;&#49696; &#51312;&#49436; &#51089;&#49457;</div>
            <div class="pm-tool-desc">STT&#47196; &#51020;&#49457; &#51064;&#49885; &#54980; &#51088;&#46041; &#51312;&#49436;&#54868;</div>
            <div class="pm-tool-meta">&#50624;&#45212; &#51089;&#49457; <%= cntTranscript %>&#44148;</div>
        </a>
        <a href="<%= request.getContextPath() %>/desktop/voiceTranscript.jsp" class="pm-tool-card">
            <div class="pm-tool-icon">
                <% if (cntContradiction > 0) { %><span class="pm-urgent-dot"></span><% } %>
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
            </div>
            <div class="pm-tool-title">&#47784;&#49692; &#53456;&#51648;</div>
            <div class="pm-tool-desc">AI&#47196; &#51312;&#49436; &#44036; &#51652;&#49696; &#48520;&#51068;&#52824; &#51088;&#46041; &#48156;&#44604;</div>
            <div class="pm-tool-meta">&#49888;&#44508; <%= cntContradiction %>&#44148;</div>
        </a>
        <a href="<%= request.getContextPath() %>/desktop/caseRelationMap.jsp" class="pm-tool-card">
            <div class="pm-tool-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
                    <circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="5" r="2.5"/><circle cx="18" cy="19" r="2.5"/>
                    <line x1="8.4" y1="11" x2="15.6" y2="6.5"/><line x1="8.4" y1="13" x2="15.6" y2="17.5"/>
                </svg>
            </div>
            <div class="pm-tool-title">&#49324;&#44148; &#44288;&#44228;&#47581;</div>
            <div class="pm-tool-desc">&#51064;&#47932; &#51088;&#46041; &#52628;&#52636; &middot; &#44288;&#44228; &#49884;&#44033;&#54868;</div>
            <div class="pm-tool-meta">&nbsp;</div>
        </a>
        <a href="<%= request.getContextPath() %>/desktop/cctvAnalysis.jsp" class="pm-tool-card">
            <div class="pm-tool-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
                    <path d="M23 7 16 12 23 17V7z"/>
                    <rect x="1" y="5" width="15" height="14" rx="2"/>
                </svg>
            </div>
            <div class="pm-tool-title">&#50689;&#49345; &#48516;&#49437;</div>
            <div class="pm-tool-desc">CCTV&#50640;&#49436; &#48264;&#54840;&#54032; &middot; &#54665;&#51201; &#52628;&#52636;</div>
            <div class="pm-tool-meta">&nbsp;</div>
        </a>
    </div>

    <div class="pm-lower-grid">
        <div>
            <div class="pm-sec-label">&#52572;&#44540; &#49324;&#44148;</div>
            <div class="pm-case-table">
                <div class="pm-case-table-head">
                    <span class="pm-case-th">&#49324;&#44148;&#48264;&#54840;</span>
                    <span class="pm-case-th">&#49324;&#44148;&#47749;</span>
                    <span class="pm-case-th">&#49345;&#53468;</span>
                    <span class="pm-case-th">&#52572;&#51333;&#49688;&#51221;</span>
                </div>
                <% for (String[] rc : recentCases) {
                    String badgeCls = "진행중".equals(rc[2]) ? "pm-badge-jinhaeng"
                                    : "완료".equals(rc[2])   ? "pm-badge-wanryo"
                                    : "모순탐지".equals(rc[2]) ? "pm-badge-moosun"
                                    : "pm-badge-geomto";
                %>
                <a href="<%= request.getContextPath() %>/desktop/myCase.jsp?caseId=<%= rc[0] %>"
                   class="pm-case-row <%= "모순탐지".equals(rc[2]) ? "urgent" : "" %>">
                    <span class="pm-case-id"><%= rc[0] %></span>
                    <span class="pm-case-name"><%= rc[1] %></span>
                    <span><span class="pm-badge <%= badgeCls %>"><%= rc[2] %></span></span>
                    <span class="pm-case-date"><%= rc[3] %></span>
                </a>
                <% } %>
                <% if (recentCases.isEmpty()) { %>
                <div style="padding:24px;text-align:center;color:#9ca3af;font-size:13px;">&#46321;&#47197;&#46108; &#49324;&#44148;&#51060; &#50630;&#49845;&#45768;&#45796;</div>
                <% } %>
            </div>
        </div>

        <div>
            <div class="pm-sec-label">&#52572;&#44540; &#54876;&#46041;</div>
            <div class="pm-activity-feed" id="pmActivityFeed">
                <div style="padding:16px;text-align:center;color:#9ca3af;font-size:12px;">&#47196;&#46377; &#51473;...</div>
            </div>
        </div>
    </div>

</main>

</div>
</div>

<script>
(function() {
    fetch(_ctx + '/notifApi?action=list', {credentials: 'same-origin'})
        .then(function(r) { return r.json(); })
        .then(function(d) {
            var feed = document.getElementById('pmActivityFeed');
            if (!feed) return;
            var items = d.notifications || [];
            if (items.length === 0) {
                feed.innerHTML = '<div style="padding:16px;text-align:center;color:#9ca3af;font-size:12px;">&#52572;&#44540; &#54876;&#46041;&#51060; &#50630;&#49845;&#45768;&#45796;</div>';
                return;
            }
            feed.innerHTML = items.slice(0, 6).map(function(n) {
                return '<div class="pm-activity-item">'
                    + '<div class="pm-act-icon"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#4a7cdc" stroke-width="1.8" stroke-linecap="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/></svg></div>'
                    + '<div style="flex:1;min-width:0">'
                    + '<div class="pm-act-title">' + (n.message || '') + '</div>'
                    + '<div class="pm-act-when">' + (n.created_at || '') + '</div>'
                    + '</div></div>';
            }).join('');
        })
        .catch(function() {
            var feed = document.getElementById('pmActivityFeed');
            if (feed) feed.innerHTML = '<div style="padding:16px;text-align:center;color:#9ca3af;font-size:12px;">&#48266;&#47140;&#50625; &#49688; &#50630;&#49845;&#45768;&#45796;</div>';
        });
})();
</script>
</body>
</html>
