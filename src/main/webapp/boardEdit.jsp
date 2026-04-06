<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, Servlet.DBConnectionMgr" %>
<%
  String loginUser = (String) session.getAttribute("loginUser");
  if (loginUser == null) { response.sendRedirect("login.jsp"); return; }
  String userName = (String) session.getAttribute("userName");
  if (userName == null) userName = loginUser;

  String paramCaseId = request.getParameter("caseId") != null ? request.getParameter("caseId") : "";
  String paramCaseName = "";
  if (!paramCaseId.isEmpty()) {
    DBConnectionMgr mgr = DBConnectionMgr.getInstance();
    java.sql.Connection conn = null;
    try {
      conn = mgr.getConnection();
      java.sql.PreparedStatement ps = conn.prepareStatement("SELECT case_name FROM cases WHERE case_id = ?");
      ps.setString(1, paramCaseId);
      java.sql.ResultSet rs = ps.executeQuery();
      if (rs.next()) paramCaseName = rs.getString("case_name");
      rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); }
    finally { mgr.freeConnection(conn); }
  }
  if (paramCaseName == null) paramCaseName = "";
  String safeCaseIdAttr = paramCaseId.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;").replace("<", "&lt;");
  String safeCaseNameAttr = paramCaseName.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;").replace("<", "&lt;");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 관계망 편집</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
:root {
  --navy:#1a2744; --navy-light:#243358; --accent:#4a7cdc; --danger:#dc2626;
  --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
  --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
  --success:#16a34a; --success-bg:#f0fdf4;
  --danger-bg:#fef2f2; --danger-bd:#fecaca;
  --bottom-nav-h:64px;
  --c-suspect:#dc2626; --c-victim:#f97316; --c-witness:#4a7cdc; --c-reference:#8b5cf6;
}
html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); }
.screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

/* ── 헤더 ── */
.top-header { background:var(--navy); padding:52px 20px 0; position:sticky; top:0; z-index:20; }
.header-row  { display:flex; align-items:center; gap:12px; padding-bottom:14px; }
.back-btn    { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
.back-btn svg{ width:18px; height:18px; stroke:#fff; }
.header-text { flex:1; min-width:0; }
.header-title{ font-size:16px; font-weight:500; color:#fff; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.header-sub  { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }
.header-gold-line { height:1.5px; background:linear-gradient(90deg,transparent,#f0c040 30%,#f0c040 70%,transparent); opacity:0.25; margin:0 -20px; }

/* ── 콘텐츠 ── */
.content { flex:1; overflow-y:auto; padding:16px 16px calc(var(--bottom-nav-h) + 80px); }

/* ── 캔버스 ── */
.canvas-card { background:#0d1a33; border-radius:16px; overflow:hidden; position:relative; margin-bottom:12px; border:1px solid rgba(255,255,255,0.06); }
.canvas-toolbar { position:absolute; top:10px; right:10px; z-index:5; display:flex; flex-direction:column; gap:6px; }
.canvas-tool-btn { width:32px; height:32px; border-radius:8px; background:rgba(255,255,255,0.12); border:1px solid rgba(255,255,255,0.18); display:flex; align-items:center; justify-content:center; cursor:pointer; transition:background 0.15s; }
.canvas-tool-btn:active { background:rgba(255,255,255,0.25); }
.canvas-tool-btn svg { width:15px; height:15px; stroke:#fff; }
#boardCanvas { display:block; width:100%; cursor:grab; touch-action:none; }
#boardCanvas:active { cursor:grabbing; }
.canvas-hint { position:absolute; bottom:10px; left:50%; transform:translateX(-50%); background:rgba(0,0,0,0.55); border-radius:20px; padding:5px 14px; font-size:10px; color:rgba(255,255,255,0.75); white-space:nowrap; pointer-events:none; }

/* ── 범례 ── */
.legend-card { background:var(--card); border-radius:14px; border:1px solid var(--border); padding:12px 14px; margin-bottom:12px; }
.legend-wrap { display:flex; flex-wrap:wrap; gap:8px; }
.legend-item { display:flex; align-items:center; gap:5px; font-size:11px; color:var(--text-secondary); }
.legend-dot  { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.legend-line { width:18px; height:2px; flex-shrink:0; }

/* ── 섹션 카드 ── */
.section-card { background:var(--card); border-radius:16px; border:1px solid var(--border); margin-bottom:12px; overflow:hidden; }
.section-header { display:flex; align-items:center; justify-content:space-between; padding:14px 16px 12px; border-bottom:1px solid var(--border); }
.section-title { font-size:13px; font-weight:500; color:var(--text-primary); display:flex; align-items:center; gap:7px; }
.section-title svg { width:15px; height:15px; stroke:var(--text-secondary); flex-shrink:0; }
.count-badge { font-size:11px; background:#f0f3f9; color:var(--navy); padding:2px 9px; border-radius:20px; }
.btn-add-inline { background:none; border:none; cursor:pointer; width:28px; height:28px; border-radius:8px; background:var(--accent); display:flex; align-items:center; justify-content:center; transition:transform 0.1s; }
.btn-add-inline:active { transform:scale(0.92); }
.btn-add-inline svg { width:14px; height:14px; stroke:#fff; }

/* ── 인물 리스트 ── */
.person-list { padding:8px 12px 12px; display:flex; flex-direction:column; gap:7px; }
.person-item { display:flex; align-items:center; gap:11px; padding:10px 12px; background:var(--bg); border-radius:12px; border:1px solid var(--border); }
.person-avatar { width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:700; color:#fff; flex-shrink:0; }
.person-info { flex:1; min-width:0; }
.person-name { font-size:13px; font-weight:500; color:var(--text-primary); }
.person-role-label { font-size:11px; margin-top:2px; }
.person-memo { font-size:10px; color:var(--text-muted); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.item-actions { display:flex; gap:5px; }
.item-btn { width:27px; height:27px; border-radius:8px; background:var(--card); border:1px solid var(--border); display:flex; align-items:center; justify-content:center; cursor:pointer; }
.item-btn svg { width:12px; height:12px; stroke:var(--text-secondary); }
.item-btn.del svg { stroke:var(--danger); }
.item-btn.del { background:var(--danger-bg); border-color:var(--danger-bd); }
.empty-list { text-align:center; padding:20px 16px; font-size:12px; color:var(--text-muted); }

/* ── 관계선 리스트 ── */
.edge-list { padding:8px 12px 12px; display:flex; flex-direction:column; gap:7px; }
.edge-item { padding:10px 12px; background:var(--bg); border-radius:12px; border:1px solid var(--border); border-left:3px solid var(--border); display:flex; align-items:center; gap:10px; }
.edge-item.accomplice { border-left-color:#dc2626; } .edge-item.harm    { border-left-color:#f97316; }
.edge-item.witness   { border-left-color:#4a7cdc; } .edge-item.acquaint{ border-left-color:#9ca3af; }
.edge-item.family    { border-left-color:#16a34a; }
.edge-text { flex:1; }
.edge-names { font-size:13px; font-weight:500; color:var(--text-primary); }
.edge-rel   { font-size:11px; color:var(--text-muted); margin-top:2px; }

/* ── 저장 버튼 (하단 고정) ── */
.save-bar { position:fixed; bottom:calc(var(--bottom-nav-h)); left:50%; transform:translateX(-50%); width:100%; max-width:420px; padding:10px 16px; background:var(--card); border-top:1px solid var(--border); z-index:15; }
.btn-save { width:100%; padding:14px; border-radius:13px; border:none; background:var(--success); color:#fff; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; transition:transform 0.1s, background 0.2s; }
.btn-save:active { transform:scale(0.98); }
.btn-save svg { width:16px; height:16px; stroke:#fff; }

/* ── 드로어 (인물/관계선 추가·편집) ── */
.drawer-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:200; display:none; align-items:flex-end; justify-content:center; }
.drawer-overlay.open { display:flex; }
.drawer { background:var(--card); border-radius:20px 20px 0 0; width:100%; max-width:420px; padding:0 0 36px; animation:slideUp 0.28s ease both; max-height:88vh; overflow-y:auto; }
.drawer-handle { width:36px; height:4px; background:var(--border); border-radius:2px; margin:12px auto 0; }
.drawer-head { display:flex; align-items:center; justify-content:space-between; padding:16px 20px 14px; border-bottom:1px solid var(--border); }
.drawer-title { font-size:15px; font-weight:500; color:var(--text-primary); }
.drawer-close { width:30px; height:30px; border-radius:50%; background:var(--bg); border:none; cursor:pointer; display:flex; align-items:center; justify-content:center; }
.drawer-close svg { width:15px; height:15px; stroke:var(--text-secondary); }
.drawer-body { padding:18px 20px 0; }
.form-label { font-size:11px; font-weight:500; color:var(--text-secondary); display:block; margin-bottom:6px; }
.form-input { width:100%; padding:11px 13px; background:var(--bg); border:1px solid var(--border); border-radius:11px; font-size:13px; font-family:'Noto Sans KR',sans-serif; color:var(--text-primary); outline:none; margin-bottom:12px; appearance:none; }
.form-input:focus { border-color:var(--accent); background:#fff; }

/* 역할 선택 */
.role-grid { display:grid; grid-template-columns:repeat(2,1fr); gap:7px; margin-bottom:14px; }
.role-opt { padding:10px; border-radius:11px; border:2px solid var(--border); text-align:center; cursor:pointer; font-size:12px; font-weight:500; color:var(--text-secondary); transition:all 0.15s; }
.role-opt.sel-suspect   { border-color:var(--c-suspect);  background:#fef2f2; color:var(--c-suspect); }
.role-opt.sel-victim    { border-color:var(--c-victim);   background:#fff7ed; color:var(--c-victim); }
.role-opt.sel-witness   { border-color:var(--c-witness);  background:#eff6ff; color:var(--c-witness); }
.role-opt.sel-reference { border-color:var(--c-reference);background:#f5f3ff; color:var(--c-reference); }

/* 관계 유형 선택 */
.rel-list { display:flex; flex-direction:column; gap:6px; margin-bottom:14px; }
.rel-opt { padding:11px 13px; border-radius:11px; border:2px solid var(--border); cursor:pointer; font-size:13px; font-weight:500; color:var(--text-secondary); display:flex; align-items:center; gap:9px; transition:all 0.15s; }
.rel-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.rel-opt.sel { border-color:var(--accent); background:#eff6ff; color:var(--accent); }

/* 드로어 버튼 */
.btn-drawer-confirm { width:100%; padding:14px; border-radius:13px; background:var(--navy); color:#fff; border:none; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; margin-top:4px; transition:transform 0.1s; }
.btn-drawer-confirm:active { transform:scale(0.98); }
.btn-drawer-cancel  { width:100%; padding:12px; border-radius:13px; background:var(--bg); color:var(--text-secondary); border:1px solid var(--border); font-size:13px; font-family:'Noto Sans KR',sans-serif; cursor:pointer; margin-top:8px; }

/* ── 확인 다이얼로그 (커스텀) ── */
.confirm-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:400; display:none; align-items:center; justify-content:center; padding:20px; }
.confirm-overlay.open { display:flex; }
.confirm-box { background:var(--card); border-radius:20px; padding:24px 20px 20px; width:100%; max-width:320px; animation:fadeUp 0.22s ease both; }
.confirm-icon { width:52px; height:52px; border-radius:50%; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; }
.confirm-icon.warn { background:var(--success-bg); }
.confirm-icon svg  { width:26px; height:26px; }
.confirm-title { font-size:16px; font-weight:700; color:var(--text-primary); text-align:center; margin-bottom:8px; }
.confirm-desc  { font-size:13px; color:var(--text-secondary); text-align:center; line-height:1.7; margin-bottom:20px; }
.confirm-btns  { display:flex; gap:8px; }
.confirm-btn   { flex:1; padding:13px; border-radius:12px; border:none; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; transition:transform 0.1s; }
.confirm-btn:active { transform:scale(0.97); }
.confirm-btn.ok     { background:var(--success); color:#fff; }
.confirm-btn.cancel { background:var(--bg); color:var(--text-secondary); border:1px solid var(--border); }

/* ── 토스트 ── */
#toast { position:fixed; bottom:calc(var(--bottom-nav-h) + 74px); left:50%; transform:translateX(-50%) translateY(20px); background:#1a2744; color:#fff; padding:11px 22px; border-radius:24px; font-size:13px; opacity:0; transition:all 0.3s; pointer-events:none; z-index:500; white-space:nowrap; max-width:320px; text-align:center; }

/* ── 하단 네비 ── */
.bottom-nav { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:420px; height:var(--bottom-nav-h); background:#fff; border-top:1px solid #e2e5ee; display:flex; z-index:100; }
.nav-item { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:3px; text-decoration:none; color:#9ca3af; cursor:pointer; border:none; background:none; font-family:'Noto Sans KR',sans-serif; }
.nav-item.active { color:#0d1a33; }
.nav-item.active .nav-label { font-weight:600; }
.nav-icon { width:22px; height:22px; display:flex; align-items:center; justify-content:center; }
.nav-icon svg { width:20px; height:20px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; }
.nav-label { font-size:10px; }

@keyframes slideUp { from{transform:translateY(100%);opacity:0} to{transform:translateY(0);opacity:1} }
@keyframes fadeUp  { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
@media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }
</style>
</head>
<body>
<div class="screen">

  <!-- 헤더 -->
  <div class="top-header">
    <div class="header-row">
      <button class="back-btn" onclick="history.back()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <div class="header-text">
        <div class="header-title" id="pageTitle"><%= paramCaseId.isEmpty() ? "관계망 편집" : paramCaseId + " " + paramCaseName %></div>
        <div class="header-sub">인물 · 관계선 편집 및 보드 저장</div>
      </div>
    </div>
    <div class="header-gold-line"></div>
  </div>

  <!-- 콘텐츠 -->
  <div class="content">

    <!-- 캔버스 -->
    <div class="canvas-card" id="canvasWrap">
      <div class="canvas-toolbar">
        <button type="button" class="canvas-tool-btn" onclick="zoomIn()">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
        <button type="button" class="canvas-tool-btn" onclick="zoomOut()">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
        <button type="button" class="canvas-tool-btn" onclick="resetView()">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.5"/></svg>
        </button>
      </div>
      <canvas id="boardCanvas" height="360"></canvas>
      <div class="canvas-hint">노드 끌어 배치 · 빈 곳 드래그로 화면 이동 · 핀치로 확대</div>
    </div>

    <!-- 범례 -->
    <div class="legend-card">
      <div class="legend-wrap">
        <div class="legend-item"><div class="legend-dot" style="background:var(--c-suspect)"></div>피의자</div>
        <div class="legend-item"><div class="legend-dot" style="background:var(--c-victim)"></div>피해자</div>
        <div class="legend-item"><div class="legend-dot" style="background:var(--c-witness)"></div>목격자</div>
        <div class="legend-item"><div class="legend-dot" style="background:var(--c-reference)"></div>참고인</div>
        <div class="legend-item"><div class="legend-line" style="background:#dc2626"></div>공범</div>
        <div class="legend-item"><div class="legend-line" style="background:#f97316"></div>피해관계</div>
        <div class="legend-item"><div class="legend-line" style="background:#4a7cdc"></div>목격</div>
        <div class="legend-item"><div class="legend-line" style="background:#16a34a"></div>가족</div>
        <div class="legend-item"><div class="legend-line" style="background:#9ca3af"></div>지인·기타</div>
        <div class="legend-item"><div class="legend-line" style="background:#f59e0b"></div>진술 불일치</div>
      </div>
    </div>

    <!-- 등록 인물 카드 -->
    <div class="section-card">
      <div class="section-header">
        <div class="section-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          등록 인물 <span class="count-badge" id="personCountBadge">0명</span>
        </div>
        <button type="button" class="btn-add-inline" onclick="openPersonDrawer(null)" title="인물 추가">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
      </div>
      <div class="person-list" id="personList">
        <div class="empty-list">인물이 없습니다.</div>
      </div>
    </div>

    <!-- 관계선 카드 -->
    <div class="section-card">
      <div class="section-header">
        <div class="section-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
          관계선 <span class="count-badge" id="edgeCountBadge">0개</span>
        </div>
        <button type="button" class="btn-add-inline" onclick="openEdgeDrawer()" title="관계선 추가">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
      </div>
      <div class="edge-list" id="edgeList">
        <div class="empty-list">관계선이 없습니다.</div>
      </div>
    </div>

  </div><!-- /content -->

  <!-- 저장 바 -->
  <div class="save-bar">
    <button type="button" class="btn-save" id="btnSave" onclick="confirmSave()">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
        <polyline points="17 21 17 13 7 13 7 21"/>
      </svg>
      <span id="saveBtnText">보드 저장</span>
    </button>
  </div>

  <!-- 하단 네비 -->
    <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div><span class="nav-label">홈</span></a>
    <a href="myCase.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div><span class="nav-label">조서</span></a>
    <a href="askAI" class="nav-item active"><div class="nav-icon"><svg width="22" height="22" viewBox="0 0 86 86" fill="none"><path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="currentColor" stroke-width="5"/><circle cx="43" cy="40" r="11" fill="none" stroke="currentColor" stroke-width="3"/><circle cx="43" cy="40" r="5" fill="currentColor"/><circle cx="43" cy="40" r="2.5" fill="white"/><circle cx="43" cy="22" r="2.8" fill="currentColor"/><circle cx="43" cy="58" r="2.8" fill="currentColor"/><circle cx="28" cy="40" r="2.8" fill="currentColor"/><circle cx="58" cy="40" r="2.8" fill="currentColor"/></svg></div><span class="nav-label">AI</span></a>
    <a href="board.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div><span class="nav-label">커뮤니티</span></a>
    <a href="mypage.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div><span class="nav-label">마이페이지</span></a>
  </nav>
</div>

<!-- ── 인물 드로어 ── -->
<div class="drawer-overlay" id="personDrawer">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-head">
      <div class="drawer-title" id="personDrawerTitle">인물 추가</div>
      <button type="button" class="drawer-close" onclick="closePersonDrawer()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
    <div class="drawer-body">
      <label class="form-label">이름 <span style="color:var(--danger)">*</span></label>
      <input type="text" class="form-input" id="pName" placeholder="예) 홍길동" maxlength="20">
      <label class="form-label">역할 <span style="color:var(--danger)">*</span></label>
      <div class="role-grid">
        <div class="role-opt" id="role-suspect"   onclick="selRole('suspect')">🔴 피의자</div>
        <div class="role-opt" id="role-victim"    onclick="selRole('victim')">🟠 피해자</div>
        <div class="role-opt" id="role-witness"   onclick="selRole('witness')">🔵 목격자</div>
        <div class="role-opt" id="role-reference" onclick="selRole('reference')">🟣 참고인</div>
      </div>
      <label class="form-label">메모 (선택)</label>
      <input type="text" class="form-input" id="pMemo" placeholder="예) 사건 당일 현장 목격" maxlength="60">
      <button type="button" class="btn-drawer-confirm" onclick="confirmPerson()">확인</button>
      <button type="button" class="btn-drawer-cancel"  onclick="closePersonDrawer()">취소</button>
    </div>
  </div>
</div>

<!-- ── 관계선 드로어 ── -->
<div class="drawer-overlay" id="edgeDrawer">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-head">
      <div class="drawer-title">관계선 추가</div>
      <button type="button" class="drawer-close" onclick="closeEdgeDrawer()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
    <div class="drawer-body">
      <label class="form-label">출발 인물 <span style="color:var(--danger)">*</span></label>
      <select class="form-input" id="eSrc"><option value="">선택하세요</option></select>
      <label class="form-label">도착 인물 <span style="color:var(--danger)">*</span></label>
      <select class="form-input" id="eDst"><option value="">선택하세요</option></select>
      <label class="form-label">관계 유형 <span style="color:var(--danger)">*</span></label>
      <div class="rel-list">
        <div class="rel-opt" id="rel-accomplice" onclick="selRel('accomplice')"><div class="rel-dot" style="background:#dc2626"></div>공범</div>
        <div class="rel-opt" id="rel-harm"       onclick="selRel('harm')"><div class="rel-dot" style="background:#f97316"></div>피해관계</div>
        <div class="rel-opt" id="rel-witness"    onclick="selRel('witness')"><div class="rel-dot" style="background:#4a7cdc"></div>목격</div>
        <div class="rel-opt" id="rel-acquaint"   onclick="selRel('acquaint')"><div class="rel-dot" style="background:#9ca3af"></div>지인</div>
        <div class="rel-opt" id="rel-family"     onclick="selRel('family')"><div class="rel-dot" style="background:#16a34a"></div>가족/친인척</div>
      </div>
      <button type="button" class="btn-drawer-confirm" onclick="confirmEdge()">추가</button>
      <button type="button" class="btn-drawer-cancel"  onclick="closeEdgeDrawer()">취소</button>
    </div>
  </div>
</div>

<!-- ── 커스텀 확인 다이얼로그 ── -->
<div class="confirm-overlay" id="confirmOverlay">
  <div class="confirm-box">
    <div class="confirm-icon warn">
      <svg viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2" stroke-linecap="round">
        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
        <polyline points="17 21 17 13 7 13 7 21"/>
      </svg>
    </div>
    <div class="confirm-title" id="confirmTitle">보드 업데이트</div>
    <div class="confirm-desc"  id="confirmDesc">기존 보드가 현재 내용으로 교체됩니다.<br>계속하시겠습니까?</div>
    <div class="confirm-btns">
      <button type="button" class="confirm-btn cancel" onclick="closeConfirm()">취소</button>
      <button type="button" class="confirm-btn ok"     id="confirmOkBtn" onclick="">확인</button>
    </div>
  </div>
</div>

<div id="toast"></div>
<div id="_boardEditPageBoot" hidden data-case-id="<%= safeCaseIdAttr %>" data-case-name="<%= safeCaseNameAttr %>"></div>

<script>
// ── 상태: data-* 에서 사건 ID·이름 로드 (스크립트 안에 퍼센트+등호 조합을 쓰면 JSP가 표현식으로 오인식함) ──
var _beBoot = document.getElementById('_boardEditPageBoot');
var currentCaseId   = _beBoot ? (_beBoot.getAttribute('data-case-id')   || '') : '';
var currentCaseName = _beBoot ? (_beBoot.getAttribute('data-case-name') || '') : '';
var persons = [], edges = [];
var boardExistsInDb = false;
var _fdInit = false;
var editingPersonId = null;
var selectedRole = '', selectedRel = '';

// 인물: 피의자 빨강 · 피해 주황 · 목격 파랑 · 참고 보라
var ROLE_COLOR = {suspect:'#dc2626',victim:'#f97316',witness:'#4a7cdc',reference:'#8b5cf6'};
var ROLE_LABEL = {suspect:'피의자',victim:'피해자',witness:'목격자',reference:'참고인'};
// 관계선: 공범 빨강 · 피해 주황 · 목격 파랑 · 가족 초록 · 그 외(지인 등) 회색
var REL_COLOR  = {accomplice:'#dc2626',harm:'#f97316',witness:'#4a7cdc',acquaint:'#9ca3af',family:'#16a34a'};
var REL_LABEL  = {accomplice:'공범',harm:'피해관계',witness:'목격',acquaint:'지인',family:'가족'};
var EDGE_MISMATCH_STROKE = '#f59e0b'; // 불일치 — 공범 빨강과 구분

// ── 초기화 ───────────────────────────────────────────────────────
window.addEventListener('load', function() {
  var loaded = false;
  var urlFromAi = /[?&]fromAi=1(?:&|$)/.test(window.location.search || '');
  var sc = String(currentCaseId || '').trim();

  // sessionStorage: 관계망 페이지에서 방금 저장한 AI 분석 결과(기존 DB 보드보다 우선)
  try {
    var sid = sessionStorage.getItem('boardEdit_caseId');
    var ss = String(sid != null ? sid : '').trim();
    if (sid != null && ss === sc && sc) {
      var bj = JSON.parse(sessionStorage.getItem('boardEdit_json') || '{}');
      persons = (bj.persons || []).map(function(p) {
        return {id:uid(), name:p.name||'', role:p.role||'reference', memo:p.memo||''};
      }).filter(function(p){ return p.name; });
      edges = (bj.edges || []).map(function(e) {
        var sp = persons.find(function(p){ return p.name === (e.srcName||''); });
        var dp = persons.find(function(p){ return p.name === (e.dstName||''); });
        if (!sp||!dp) return null;
        return {id:uid(),src:sp.id,dst:dp.id,relType:e.relType||'acquaint',status:e.status||'unknown'};
      }).filter(Boolean);
      var hasData = persons.length > 0 || edges.length > 0;
      if (hasData) {
        sessionStorage.removeItem('boardEdit_caseId');
        sessionStorage.removeItem('boardEdit_caseName');
        sessionStorage.removeItem('boardEdit_json');
        loaded = true;
      } else {
        sessionStorage.removeItem('boardEdit_caseId');
        sessionStorage.removeItem('boardEdit_caseName');
        sessionStorage.removeItem('boardEdit_json');
        loaded = false;
      }
    }
  } catch(ex) {
    try {
      sessionStorage.removeItem('boardEdit_caseId');
      sessionStorage.removeItem('boardEdit_caseName');
      sessionStorage.removeItem('boardEdit_json');
    } catch (ignore) {}
  }

  initCanvas();

  if (!loaded && currentCaseId) {
    if (urlFromAi) {
      showToast('AI 분석 결과를 불러오지 못했습니다. 저장된 보드를 표시합니다.');
    }
    loadFromDb();
  } else {
    if (loaded && urlFromAi && sc) {
      try {
        history.replaceState({}, '', 'boardEdit.jsp?caseId=' + encodeURIComponent(sc));
      } catch (e1) {}
    }
    checkDbExists();
    renderAll();
  }
});

function loadFromDb() {
  fetch('boardApi?action=load&caseId=' + encodeURIComponent(currentCaseId))
    .then(function(r){ return r.json(); })
    .then(function(data) {
      if (data.success && data.boardExists) {
        boardExistsInDb = true;
        var bj;
        try { bj = JSON.parse(data.boardJson); } catch(e){ bj={}; }
        persons = (bj.persons||[]).map(function(p){
          return {id:uid(),name:p.name||'',role:p.role||'reference',memo:p.memo||''};
        }).filter(function(p){ return p.name; });
        edges = (bj.edges||[]).map(function(e){
          var sp=persons.find(function(p){ return p.name===(e.srcName||e.src||''); });
          var dp=persons.find(function(p){ return p.name===(e.dstName||e.dst||''); });
          if(!sp||!dp) return null;
          return {id:uid(),src:sp.id,dst:dp.id,relType:e.relType||'acquaint',status:e.status||'unknown'};
        }).filter(Boolean);
        updateSaveBtn();
      }
      renderAll();
    })
    .catch(function(){ renderAll(); });
}

function checkDbExists() {
  if (!currentCaseId) return;
  fetch('boardApi?action=load&caseId=' + encodeURIComponent(currentCaseId))
    .then(function(r){ return r.json(); })
    .then(function(d){ boardExistsInDb = !!(d.success && d.boardExists); updateSaveBtn(); })
    .catch(function(){});
}

function updateSaveBtn() {
  var el = document.getElementById('saveBtnText');
  if (el) el.textContent = boardExistsInDb ? '보드 업데이트' : '보드 저장';
}

// ── 렌더링 ───────────────────────────────────────────────────────
function renderAll() {
  renderPersonList();
  renderEdgeList();
  _fdInit = false;
  drawCanvas();
}

function renderPersonList() {
  document.getElementById('personCountBadge').textContent = persons.length + '명';
  var el = document.getElementById('personList');
  if (!persons.length) {
    el.innerHTML = '<div class="empty-list">인물이 없습니다. + 버튼으로 추가하세요.</div>';
    return;
  }
  el.innerHTML = '';
  persons.forEach(function(p) {
    var item = document.createElement('div');
    item.className = 'person-item';

    var avatar = document.createElement('div');
    avatar.className = 'person-avatar';
    avatar.style.background = ROLE_COLOR[p.role] || '#4a7cdc';
    avatar.textContent = p.name.charAt(0);

    var info = document.createElement('div');
    info.className = 'person-info';
    info.innerHTML =
      '<div class="person-name">' + escHtml(p.name) + '</div>' +
      '<div class="person-role-label" style="color:' + (ROLE_COLOR[p.role]||'#4a7cdc') + '">' + (ROLE_LABEL[p.role]||p.role) + '</div>' +
      (p.memo ? '<div class="person-memo">' + escHtml(p.memo) + '</div>' : '');

    var acts = document.createElement('div');
    acts.className = 'item-actions';

    var editBtn = document.createElement('button');
    editBtn.className = 'item-btn';
    editBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>';

    var delBtn = document.createElement('button');
    delBtn.className = 'item-btn del';
    delBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>';

    (function(pid) {
      editBtn.addEventListener('click', function() { openPersonDrawer(pid); });
    })(p.id);
    (function(pid, pname) {
      delBtn.addEventListener('click', function() {
        showConfirm(
          '인물 삭제',
          '"' + pname + '"을(를) 삭제하면 관련 관계선도\n함께 삭제됩니다.',
          function() {
            persons = persons.filter(function(x){ return x.id !== pid; });
            edges   = edges.filter(function(e){ return e.src !== pid && e.dst !== pid; });
            renderAll();
            showToast(pname + ' 삭제됨');
          }
        );
      });
    })(p.id, p.name);

    acts.appendChild(editBtn);
    acts.appendChild(delBtn);
    item.appendChild(avatar);
    item.appendChild(info);
    item.appendChild(acts);
    el.appendChild(item);
  });
}

function renderEdgeList() {
  document.getElementById('edgeCountBadge').textContent = edges.length + '개';
  var el = document.getElementById('edgeList');
  if (!edges.length) {
    el.innerHTML = '<div class="empty-list">관계선이 없습니다. + 버튼으로 추가하세요.</div>';
    return;
  }
  el.innerHTML = '';
  edges.forEach(function(e) {
    var sp = persons.find(function(p){ return p.id===e.src; }),
        dp = persons.find(function(p){ return p.id===e.dst; });
    if (!sp||!dp) return;

    var item = document.createElement('div');
    item.className = 'edge-item ' + e.relType;

    var txt = document.createElement('div');
    txt.className = 'edge-text';
    txt.innerHTML =
      '<div class="edge-names">' + escHtml(sp.name) + ' <span style="color:var(--text-muted)">→</span> ' + escHtml(dp.name) + '</div>' +
      '<div class="edge-rel">' + (REL_LABEL[e.relType]||e.relType) + '</div>';

    var delBtn = document.createElement('button');
    delBtn.className = 'item-btn del';
    delBtn.style.cssText = 'flex-shrink:0;';
    delBtn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';

    (function(eid, sn, dn) {
      delBtn.addEventListener('click', function() {
        showConfirm(
          '관계선 삭제',
          '"' + sn + ' → ' + dn + '" 관계선을 삭제할까요?',
          function() {
            edges = edges.filter(function(x){ return x.id !== eid; });
            renderAll();
            showToast('관계선 삭제됨');
          }
        );
      });
    })(e.id, sp.name, dp.name);

    item.appendChild(txt);
    item.appendChild(delBtn);
    el.appendChild(item);
  });
}

// ── 인물 드로어 ──────────────────────────────────────────────────
function openPersonDrawer(editId) {
  editingPersonId = editId || null;
  selectedRole = '';
  ['suspect','victim','witness','reference'].forEach(function(k){
    document.getElementById('role-'+k).className = 'role-opt';
  });
  if (editId) {
    var p = persons.find(function(x){ return x.id === editId; });
    if (!p) return;
    document.getElementById('pName').value = p.name;
    document.getElementById('pMemo').value = p.memo || '';
    selRole(p.role);
    document.getElementById('personDrawerTitle').textContent = '인물 편집';
  } else {
    document.getElementById('pName').value = '';
    document.getElementById('pMemo').value = '';
    document.getElementById('personDrawerTitle').textContent = '인물 추가';
  }
  document.getElementById('personDrawer').classList.add('open');
  document.body.style.overflow = 'hidden';
  setTimeout(function(){ document.getElementById('pName').focus(); }, 300);
}

function closePersonDrawer() {
  document.getElementById('personDrawer').classList.remove('open');
  document.body.style.overflow = '';
  editingPersonId = null;
}

function selRole(r) {
  selectedRole = r;
  ['suspect','victim','witness','reference'].forEach(function(k){
    document.getElementById('role-'+k).className = 'role-opt' + (k===r ? ' sel-'+k : '');
  });
}

function confirmPerson() {
  var name = document.getElementById('pName').value.trim();
  var memo = document.getElementById('pMemo').value.trim();
  if (!name) { showToast('이름을 입력하세요.'); return; }
  if (!selectedRole) selectedRole = 'reference';

  if (editingPersonId) {
    var p = persons.find(function(x){ return x.id === editingPersonId; });
    if (p) { p.name = name; p.role = selectedRole; p.memo = memo; }
    closePersonDrawer();
    renderAll();
    showToast('인물이 수정됐습니다.');
  } else {
    var dup = persons.find(function(p){ return p.name.trim().toLowerCase() === name.toLowerCase(); });
    if (dup) { showToast('"' + name + '"은(는) 이미 등록된 인물입니다.'); return; }
    persons.push({id:uid(), name:name, role:selectedRole, memo:memo});
    closePersonDrawer();
    renderAll();
    showToast('인물이 추가됐습니다.');
  }
}

// ── 관계선 드로어 ─────────────────────────────────────────────────
function openEdgeDrawer() {
  if (persons.length < 2) { showToast('인물이 2명 이상이어야 관계선을 추가할 수 있습니다.'); return; }
  selectedRel = '';
  ['accomplice','harm','witness','acquaint','family'].forEach(function(k){
    document.getElementById('rel-'+k).className = 'rel-opt';
  });
  var opts = '<option value="">선택하세요</option>' + persons.map(function(p){
    return '<option value="' + p.id + '">' + escHtml(p.name) + ' (' + (ROLE_LABEL[p.role]||'') + ')</option>';
  }).join('');
  document.getElementById('eSrc').innerHTML = opts;
  document.getElementById('eDst').innerHTML = opts;
  document.getElementById('edgeDrawer').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeEdgeDrawer() {
  document.getElementById('edgeDrawer').classList.remove('open');
  document.body.style.overflow = '';
}

function selRel(r) {
  selectedRel = r;
  ['accomplice','harm','witness','acquaint','family'].forEach(function(k){
    document.getElementById('rel-'+k).className = 'rel-opt' + (k===r ? ' sel' : '');
  });
}

function confirmEdge() {
  var src = document.getElementById('eSrc').value;
  var dst = document.getElementById('eDst').value;
  if (!src) { showToast('출발 인물을 선택하세요.'); return; }
  if (!dst) { showToast('도착 인물을 선택하세요.'); return; }
  if (src === dst) { showToast('같은 인물은 선택할 수 없습니다.'); return; }
  if (!selectedRel) { showToast('관계 유형을 선택하세요.'); return; }
  var dup = edges.find(function(e){ return e.src===src && e.dst===dst && e.relType===selectedRel; });
  if (dup) { showToast('이미 동일한 관계선이 있습니다.'); return; }
  edges.push({id:uid(), src:src, dst:dst, relType:selectedRel, status:'unknown'});
  closeEdgeDrawer();
  renderAll();
  showToast('관계선이 추가됐습니다.');
}

// ── 커스텀 확인 다이얼로그 ────────────────────────────────────────
function showConfirm(title, desc, onOk) {
  document.getElementById('confirmTitle').textContent = title;
  document.getElementById('confirmDesc').textContent  = desc;
  document.getElementById('confirmOkBtn').onclick = function() {
    closeConfirm();
    onOk();
  };
  document.getElementById('confirmOverlay').classList.add('open');
}

function closeConfirm() {
  document.getElementById('confirmOverlay').classList.remove('open');
}

// 오버레이 배경 클릭으로 닫기
document.getElementById('personDrawer').addEventListener('click', function(e){ if(e.target===this) closePersonDrawer(); });
document.getElementById('edgeDrawer').addEventListener('click',   function(e){ if(e.target===this) closeEdgeDrawer(); });
document.getElementById('confirmOverlay').addEventListener('click', function(e){ if(e.target===this) closeConfirm(); });

// ── 보드 저장 ────────────────────────────────────────────────────
function confirmSave() {
  if (!currentCaseId) { showToast('사건 ID가 없습니다.'); return; }
  if (!persons.length) { showToast('등록된 인물이 없습니다.'); return; }

  if (boardExistsInDb) {
    showConfirm(
      '보드 업데이트',
      '기존 보드가 현재 내용으로 교체됩니다.\n계속하시겠습니까?',
      doSave
    );
  } else {
    doSave();
  }
}

function doSave() {
  var btn = document.getElementById('btnSave');
  var origHTML = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = '<span>저장 중...</span>';

  var edgesForJson = edges.map(function(e){
    var sp=persons.find(function(p){return p.id===e.src;}),
        dp=persons.find(function(p){return p.id===e.dst;});
    return {srcName:sp?sp.name:'',dstName:dp?dp.name:'',relType:e.relType,status:e.status,context:''};
  }).filter(function(e){ return e.srcName&&e.dstName; });

  var timeout = setTimeout(function(){
    btn.disabled=false; btn.innerHTML=origHTML;
    showToast('저장 시간 초과. 다시 시도해 주세요.');
  }, 10000);

  fetch('boardApi?action=save', {
    method:'POST',
    headers:{'Content-Type':'application/json; charset=UTF-8'},
    body: JSON.stringify({
      caseId: currentCaseId,
      boardJson: JSON.stringify({persons:persons, edges:edgesForJson}),
      isUpdate: boardExistsInDb
    })
  })
  .then(function(r){ return r.ok ? r.json() : r.text().then(function(t){ throw new Error(t.substring(0,80)); }); })
  .then(function(d){
    clearTimeout(timeout);
    btn.disabled = false;
    if (d.error) { btn.innerHTML=origHTML; updateSaveBtn(); showToast(d.error); return; }
    boardExistsInDb = true;
    updateSaveBtn();
    btn.innerHTML = '<span>' + (d.isUpdate ? '업데이트 완료' : '저장 완료') + '</span>';
    showToast(d.message || (d.isUpdate ? '보드가 업데이트됐습니다.' : '보드가 저장됐습니다.'));
    setTimeout(function(){ btn.innerHTML = origHTML; updateSaveBtn(); }, 2000);
  })
  .catch(function(err){
    clearTimeout(timeout);
    btn.disabled=false; btn.innerHTML=origHTML;
    showToast('저장 중 오류가 발생했습니다.');
  });
}

// ── 캔버스 ───────────────────────────────────────────────────────
var canvas, ctx;
var cScale=1, cOffsetX=0, cOffsetY=0, cDrag=false, cLastX=0, cLastY=0;
var cDraggingNode = null;

function boardClientToDevice(clientX, clientY) {
  if (!canvas) return {x:0,y:0};
  var rect = canvas.getBoundingClientRect();
  var sx = canvas.width / (rect.width || 1);
  var sy = canvas.height / (rect.height || 1);
  return { x: (clientX - rect.left) * sx, y: (clientY - rect.top) * sy };
}
function boardClientToWorld(clientX, clientY) {
  var d = boardClientToDevice(clientX, clientY);
  return {
    x: (d.x - cOffsetX * cScale) / cScale,
    y: (d.y - cOffsetY * cScale) / cScale
  };
}
function boardHitPerson(wx, wy) {
  var nr = 22, r2 = nr * nr * 1.44;
  for (var i = persons.length - 1; i >= 0; i--) {
    var p = persons[i];
    var dx = wx - p._x, dy = wy - p._y;
    if (dx * dx + dy * dy <= r2) return p;
  }
  return null;
}
function clampBoardPerson(p) {
  var pad = 32;
  p._x = Math.max(pad, Math.min(canvas.width - pad, p._x));
  p._y = Math.max(pad, Math.min(canvas.height - pad, p._y));
}

function initCanvas() {
  canvas = document.getElementById('boardCanvas');
  ctx    = canvas.getContext('2d');

  canvas.addEventListener('mousedown', function(e) {
    if (!persons.length) {
      cDraggingNode = null;
      cDrag = true;
    } else {
      var w = boardClientToWorld(e.clientX, e.clientY);
      var hit = boardHitPerson(w.x, w.y);
      if (hit) {
        cDraggingNode = hit;
        cDrag = false;
        canvas.style.cursor = 'grabbing';
      } else {
        cDraggingNode = null;
        cDrag = true;
      }
    }
    cLastX = e.clientX;
    cLastY = e.clientY;
  });
  canvas.addEventListener('mousemove', function(e) {
    if (cDraggingNode) {
      var w0 = boardClientToWorld(cLastX, cLastY);
      var w1 = boardClientToWorld(e.clientX, e.clientY);
      cDraggingNode._x += w1.x - w0.x;
      cDraggingNode._y += w1.y - w0.y;
      clampBoardPerson(cDraggingNode);
      cLastX = e.clientX;
      cLastY = e.clientY;
      drawCanvas();
      return;
    }
    if (cDrag) {
      cOffsetX += (e.clientX - cLastX) / cScale;
      cOffsetY += (e.clientY - cLastY) / cScale;
      cLastX = e.clientX;
      cLastY = e.clientY;
      drawCanvas();
      return;
    }
    if (persons.length) {
      var wh = boardClientToWorld(e.clientX, e.clientY);
      canvas.style.cursor = boardHitPerson(wh.x, wh.y) ? 'grab' : 'default';
    }
  });
  canvas.addEventListener('mouseup', function() {
    cDraggingNode = null;
    cDrag = false;
    canvas.style.cursor = '';
  });
  canvas.addEventListener('mouseleave', function() {
    cDraggingNode = null;
    cDrag = false;
    canvas.style.cursor = '';
  });

  var touchLx, touchLy, pinchD0;
  canvas.addEventListener('touchstart', function(e) {
    if (e.touches.length === 2) {
      cDraggingNode = null;
      cDrag = false;
      pinchD0 = Math.hypot(e.touches[0].clientX - e.touches[1].clientX, e.touches[0].clientY - e.touches[1].clientY);
      e.preventDefault();
      return;
    }
    if (e.touches.length === 1) {
      var t = e.touches[0];
      if (persons.length) {
        var w = boardClientToWorld(t.clientX, t.clientY);
        var hit = boardHitPerson(w.x, w.y);
        if (hit) {
          cDraggingNode = hit;
          cDrag = false;
        } else {
          cDraggingNode = null;
          cDrag = true;
        }
      } else {
        cDraggingNode = null;
        cDrag = true;
      }
      touchLx = t.clientX;
      touchLy = t.clientY;
      cLastX = t.clientX;
      cLastY = t.clientY;
    }
    e.preventDefault();
  }, {passive:false});
  canvas.addEventListener('touchmove', function(e) {
    if (e.touches.length === 2) {
      var d = Math.hypot(e.touches[0].clientX - e.touches[1].clientX, e.touches[0].clientY - e.touches[1].clientY);
      cScale = Math.max(0.4, Math.min(2.5, cScale * d / pinchD0));
      pinchD0 = d;
      drawCanvas();
      e.preventDefault();
      return;
    }
    if (e.touches.length === 1 && cDraggingNode) {
      var tn = e.touches[0];
      var w0 = boardClientToWorld(touchLx, touchLy);
      var w1 = boardClientToWorld(tn.clientX, tn.clientY);
      cDraggingNode._x += w1.x - w0.x;
      cDraggingNode._y += w1.y - w0.y;
      clampBoardPerson(cDraggingNode);
      touchLx = tn.clientX;
      touchLy = tn.clientY;
      drawCanvas();
      e.preventDefault();
      return;
    }
    if (e.touches.length === 1 && cDrag) {
      var tp = e.touches[0];
      cOffsetX += (tp.clientX - touchLx) / cScale;
      cOffsetY += (tp.clientY - touchLy) / cScale;
      touchLx = tp.clientX;
      touchLy = tp.clientY;
      drawCanvas();
      e.preventDefault();
    }
  }, {passive:false});
  canvas.addEventListener('touchend', function(e) {
    if (e.touches.length === 0) {
      cDraggingNode = null;
      cDrag = false;
    } else if (e.touches.length === 1) {
      var tr = e.touches[0];
      touchLx = tr.clientX;
      touchLy = tr.clientY;
      cLastX = tr.clientX;
      cLastY = tr.clientY;
    }
  });

  resizeCanvas();
  window.addEventListener('resize', resizeCanvas);
}

function resizeCanvas() {
  var w = document.getElementById('canvasWrap');
  if (!w||!canvas) return;
  canvas.width=w.clientWidth; canvas.height=360; drawCanvas();
}

// Force-directed 레이아웃
function initForce() {
  var n=persons.length, cx=canvas.width/2, cy=canvas.height/2;
  persons.forEach(function(p,i){
    var a=(2*Math.PI*i/n)-Math.PI/2, r=Math.min(cx,cy)*0.55;
    p._x=cx+Math.cos(a)*r; p._y=cy+Math.sin(a)*r; p._vx=0; p._vy=0;
  });
  if(n===1){persons[0]._x=cx;persons[0]._y=cy;}
  for(var i=0;i<150;i++) runForce();
  _fdInit=true;
}
function runForce(){
  var n=persons.length, ideal=Math.min(canvas.width,canvas.height)*0.38, pad=32;
  var cx=canvas.width/2, cy=canvas.height/2;
  persons.forEach(function(p){p._fx=0;p._fy=0;});
  for(var i=0;i<n;i++){for(var j=i+1;j<n;j++){
    var pi=persons[i],pj=persons[j],dx=pi._x-pj._x,dy=pi._y-pj._y,dist=Math.sqrt(dx*dx+dy*dy)||1;
    var f=3200/(dist*dist);pi._fx+=dx/dist*f;pi._fy+=dy/dist*f;pj._fx-=dx/dist*f;pj._fy-=dy/dist*f;
  }}
  edges.forEach(function(e){
    var sp=persons.find(function(p){return p.id===e.src;}),dp=persons.find(function(p){return p.id===e.dst;});
    if(!sp||!dp)return;
    var dx=dp._x-sp._x,dy=dp._y-sp._y,dist=Math.sqrt(dx*dx+dy*dy)||1,f=0.018*(dist-ideal);
    sp._fx+=dx/dist*f;sp._fy+=dy/dist*f;dp._fx-=dx/dist*f;dp._fy-=dy/dist*f;
  });
  persons.forEach(function(p){
    p._fx+=(cx-p._x)*0.008;p._fy+=(cy-p._y)*0.008;
    p._vx=(p._vx+p._fx)*0.82;p._vy=(p._vy+p._fy)*0.82;
    p._x=Math.max(pad,Math.min(canvas.width-pad,p._x+p._vx));
    p._y=Math.max(pad,Math.min(canvas.height-pad,p._y+p._vy));
  });
}
function calcCurve(e){
  var pairs=edges.filter(function(x){return(x.src===e.src&&x.dst===e.dst)||(x.src===e.dst&&x.dst===e.src);});
  var idx=pairs.indexOf(e);if(pairs.length===1)return 0;
  return(Math.floor(idx/2)+1)*55*(idx%2===0?1:-1);
}
function drawCanvas(){
  if(!ctx)return;
  ctx.clearRect(0,0,canvas.width,canvas.height);
  ctx.fillStyle='#0d1a33';ctx.fillRect(0,0,canvas.width,canvas.height);
  if(!persons.length){
    ctx.fillStyle='rgba(255,255,255,0.3)';ctx.font='13px Noto Sans KR,sans-serif';
    ctx.textAlign='center';ctx.fillText('인물을 추가하면 관계망이 표시됩니다',canvas.width/2,canvas.height/2);
    return;
  }
  if(!_fdInit)initForce();
  ctx.save();
  ctx.translate(cOffsetX*cScale,cOffsetY*cScale);
  ctx.scale(cScale,cScale);
  // 관계선
  edges.forEach(function(e){
    var sp=persons.find(function(p){return p.id===e.src;}),dp=persons.find(function(p){return p.id===e.dst;});
    if(!sp||!dp)return;
    var curve=calcCurve(e),color=REL_COLOR[e.relType]||'#9ca3af';
    var isMis=e.status==='mismatch',isUnk=e.status==='unknown';
    var sc=isMis?EDGE_MISMATCH_STROKE:isUnk?'#9ca3af':color;
    ctx.lineWidth=2;ctx.strokeStyle=sc;
    if(isMis)ctx.setLineDash([6,4]);else if(isUnk)ctx.setLineDash([4,4]);else ctx.setLineDash([]);
    var mx=(sp._x+dp._x)/2,my=(sp._y+dp._y)/2,dx=dp._x-sp._x,dy=dp._y-sp._y,len=Math.sqrt(dx*dx+dy*dy)||1;
    var cpx=mx-(dy/len)*curve,cpy=my+(dx/len)*curve;
    ctx.beginPath();ctx.moveTo(sp._x,sp._y);
    if(curve===0)ctx.lineTo(dp._x,dp._y);else ctx.quadraticCurveTo(cpx,cpy,dp._x,dp._y);
    ctx.stroke();ctx.setLineDash([]);
    var ang=curve===0?Math.atan2(dp._y-sp._y,dp._x-sp._x):Math.atan2(dp._y-cpy,dp._x-cpx);
    var nr=22,ax=dp._x-Math.cos(ang)*nr,ay=dp._y-Math.sin(ang)*nr;
    ctx.beginPath();ctx.moveTo(ax,ay);ctx.lineTo(ax-9*Math.cos(ang-0.4),ay-9*Math.sin(ang-0.4));ctx.lineTo(ax-9*Math.cos(ang+0.4),ay-9*Math.sin(ang+0.4));ctx.closePath();ctx.fillStyle=sc;ctx.fill();
    var t=0.5;
    var lx=curve===0?mx:(1-t)*(1-t)*sp._x+2*(1-t)*t*cpx+t*t*dp._x;
    var ly=curve===0?my:(1-t)*(1-t)*sp._y+2*(1-t)*t*cpy+t*t*dp._y;
    var perpX=-(dy/len),perpY=dx/len;if(curve===0){lx+=perpX*12;ly+=perpY*12;}
    var label=REL_LABEL[e.relType]||'';
    if(label){
      ctx.font='10px Noto Sans KR,sans-serif';var tw=ctx.measureText(label).width;
      ctx.fillStyle='rgba(10,20,50,0.75)';ctx.beginPath();
      if(ctx.roundRect)ctx.roundRect(lx-tw/2-4,ly-9,tw+8,13,3);else ctx.rect(lx-tw/2-4,ly-9,tw+8,13);
      ctx.fill();ctx.fillStyle='#fff';ctx.textAlign='center';ctx.fillText(label,lx,ly);
    }
  });
  // 노드
  persons.forEach(function(p){
    var nr=22;
    ctx.beginPath();ctx.arc(p._x,p._y,nr,0,2*Math.PI);
    ctx.fillStyle=ROLE_COLOR[p.role]||'#4a7cdc';ctx.fill();
    ctx.strokeStyle='#fff';ctx.lineWidth=2.5;ctx.stroke();
    ctx.font='bold 11px Noto Sans KR,sans-serif';ctx.fillStyle='#fff';ctx.textAlign='center';
    ctx.fillText(p.name.length>3?p.name.substr(0,3)+'…':p.name,p._x,p._y+4);
    ctx.font='9px Noto Sans KR,sans-serif';ctx.fillStyle='rgba(255,255,255,0.75)';
    ctx.fillText(ROLE_LABEL[p.role]||'',p._x,p._y+nr+13);
  });
  ctx.restore();
}
function zoomIn()    { cScale=Math.min(2.5,cScale+0.2); drawCanvas(); }
function zoomOut()   { cScale=Math.max(0.4,cScale-0.2); drawCanvas(); }
function resetView() { cScale=1;cOffsetX=0;cOffsetY=0;cDraggingNode=null;cDrag=false;drawCanvas(); }

// ── 유틸 ─────────────────────────────────────────────────────────
function uid() { return Math.random().toString(36).substr(2,9); }
function escHtml(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function showToast(msg) {
  var t=document.getElementById('toast');
  if (!t) return;
  t.textContent=msg;
  t.style.opacity='1';t.style.transform='translateX(-50%) translateY(0)';
  clearTimeout(t._timer);
  t._timer=setTimeout(function(){t.style.opacity='0';t.style.transform='translateX(-50%) translateY(20px)';},2500);
}
</script>
</body>
</html>
