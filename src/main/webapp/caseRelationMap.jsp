<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, Servlet.DBConnectionMgr" %>
<%
  String loginUser = (String) session.getAttribute("loginUser");
  if (loginUser == null) { response.sendRedirect("login.jsp"); return; }
  String userName = (String) session.getAttribute("userName");
  if (userName == null) userName = loginUser;

  // ── 팀 사건 목록 조회 ────────────────────────────────────────────
  DBConnectionMgr mgr = DBConnectionMgr.getInstance();
  java.sql.Connection conn = null;
  java.util.List<String[]> caseList = new java.util.ArrayList<>();
  try {
    conn = mgr.getConnection();
    java.sql.PreparedStatement ps = conn.prepareStatement(
      "SELECT c.case_id, c.case_name, c.status " +
      "FROM cases c " +
      "WHERE (c.user_id = ? OR c.user_id IN (" +
      "  SELECT u2.user_id FROM users u2 " +
      "  JOIN users me ON me.user_id = ? " +
      "  WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL" +
      ")) ORDER BY c.updated_at DESC");
    ps.setString(1, loginUser);
    ps.setString(2, loginUser);
    java.sql.ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      caseList.add(new String[]{ rs.getString("case_id"), rs.getString("case_name"), rs.getString("status") });
    }
    rs.close(); ps.close();
  } catch (Exception e) { e.printStackTrace(); }
  finally { mgr.freeConnection(conn); }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 사건 관계망</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
:root {
  --navy:#1a2744; --navy-light:#243358; --accent:#4a7cdc; --danger:#dc2626;
  --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
  --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
  --success:#16a34a; --success-bg:#f0fdf4;
  --warn-bg:#fffbeb; --warn-text:#92400e;
  --danger-bg:#fef2f2; --danger-bd:#fecaca;
  --bottom-nav-h:64px;
  --c-suspect:#dc2626; --c-victim:#f97316; --c-witness:#4a7cdc; --c-reference:#8b5cf6;
}
html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
.screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

/* ── 헤더 ── */
.top-header { background:var(--navy); padding:52px 20px 0; position:sticky; top:0; z-index:20; }
.header-row { display:flex; align-items:center; gap:12px; padding-bottom:16px; }
.back-btn { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
.back-btn svg { width:18px; height:18px; stroke:#fff; }
.header-text { flex:1; }
.header-title { font-size:17px; font-weight:500; color:#fff; }
.header-sub { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }
.header-gold-line { height:1.5px; background:linear-gradient(90deg,transparent,#f0c040 30%,#f0c040 70%,transparent); opacity:0.25; margin:0 -20px; }

/* ── 스크롤 콘텐츠 ── */
.content { flex:1; overflow-y:auto; padding:20px 16px calc(var(--bottom-nav-h) + 24px); }

/* ── 섹션 라벨 ── */
.section-label { font-size:10px; font-weight:500; color:var(--text-muted); letter-spacing:0.8px; text-transform:uppercase; margin-bottom:8px; padding-left:2px; }

/* ── 사건 선택 카드 ── */
.case-select-card { background:var(--card); border-radius:16px; border:1px solid var(--border); overflow:hidden; margin-bottom:16px; }
.case-item { display:flex; align-items:center; padding:14px 16px; border-bottom:1px solid var(--border); cursor:pointer; transition:background 0.15s; gap:12px; }
.case-item:last-child { border-bottom:none; }
.case-item:active { background:var(--bg); }
.case-item.selected { background:#eff6ff; border-left:3px solid var(--accent); padding-left:13px; }
.case-icon { width:38px; height:38px; border-radius:10px; background:#f0f3f9; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.case-icon svg { width:18px; height:18px; stroke:var(--navy); }
.case-info { flex:1; min-width:0; }
.case-id { font-size:11px; color:var(--text-muted); margin-bottom:2px; }
.case-name { font-size:14px; font-weight:500; color:var(--text-primary); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.case-badge { font-size:10px; padding:3px 9px; border-radius:20px; white-space:nowrap; flex-shrink:0; }
.badge-active { background:var(--success-bg); color:var(--success); }
.badge-done   { background:#eff6ff; color:#1e40af; }
.badge-warn   { background:var(--warn-bg); color:var(--warn-text); }
.badge-danger { background:var(--danger-bg); color:var(--danger); }
.case-arrow svg { width:16px; height:16px; stroke:var(--text-muted); }

/* ── 빈 상태 ── */
.empty-box { background:var(--card); border-radius:16px; border:1px solid var(--border); padding:48px 20px; text-align:center; margin-bottom:16px; }
.empty-icon-wrap { width:60px; height:60px; border-radius:50%; background:#f0f3f9; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; }
.empty-icon-wrap svg { width:28px; height:28px; stroke:var(--text-secondary); }
.empty-title { font-size:14px; font-weight:500; color:var(--text-primary); margin-bottom:6px; }
.empty-desc  { font-size:12px; color:var(--text-muted); line-height:1.7; }

/* ── AI 분석 섹션 ── */
.ai-section { background:var(--card); border-radius:16px; border:1px solid var(--border); padding:16px; margin-bottom:16px; }
.ai-section-title { font-size:13px; font-weight:500; color:var(--text-primary); margin-bottom:4px; display:flex; align-items:center; gap:7px; }
.ai-section-title svg { width:16px; height:16px; }
.ai-section-desc { font-size:11px; color:var(--text-muted); margin-bottom:14px; line-height:1.6; }
.transcript-list { display:flex; flex-direction:column; gap:7px; margin-bottom:14px; }
.transcript-item { display:flex; align-items:center; gap:10px; padding:11px 13px; background:var(--bg); border-radius:11px; border:1px solid var(--border); cursor:pointer; transition:border-color 0.15s; }
.transcript-item.checked { border-color:var(--accent); background:#eff6ff; }
.transcript-chk { width:18px; height:18px; border-radius:5px; border:1.5px solid var(--border); flex-shrink:0; display:flex; align-items:center; justify-content:center; transition:all 0.15s; }
.transcript-item.checked .transcript-chk { background:var(--accent); border-color:var(--accent); }
.transcript-chk svg { width:10px; height:10px; stroke:#fff; display:none; }
.transcript-item.checked .transcript-chk svg { display:block; }
.transcript-info { flex:1; min-width:0; }
.transcript-title { font-size:13px; font-weight:500; color:var(--text-primary); }
.transcript-meta  { font-size:10px; color:var(--text-muted); margin-top:2px; }
.transcript-badge { font-size:10px; padding:2px 8px; border-radius:20px; white-space:nowrap; flex-shrink:0; }
.tb-contradiction { background:var(--danger-bg); color:var(--danger); }
.tb-normal        { background:var(--success-bg); color:var(--success); }

/* ── AI 분석 버튼 ── */
.btn-ai-analyze { width:100%; padding:14px; border-radius:13px; border:none; background:linear-gradient(135deg,var(--navy),#243358); color:#fff; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; transition:transform 0.1s; }
.btn-ai-analyze:active { transform:scale(0.98); }
.btn-ai-analyze:disabled { background:#9ca3af; cursor:not-allowed; }
.btn-ai-analyze svg { width:16px; height:16px; stroke:#fff; }

/* AI 분석 중 상태 */
.ai-loading { display:none; align-items:center; gap:10px; padding:14px; background:#f0f3f9; border-radius:12px; margin-top:10px; }
.ai-loading.show { display:flex; }
.ai-loading-dot { width:7px; height:7px; border-radius:50%; background:var(--accent); animation:aiBounce 1.2s infinite; flex-shrink:0; }
.ai-loading-dot:nth-child(2) { animation-delay:0.2s; }
.ai-loading-dot:nth-child(3) { animation-delay:0.4s; }
.ai-loading-text { font-size:12px; color:var(--text-secondary); }

/* AI 결과 */
.ai-result-box { background:#f0f3f9; border-radius:12px; padding:12px 14px; margin-top:10px; display:none; }
.ai-result-box.show { display:block; }
.ai-result-label { font-size:10px; font-weight:500; color:var(--accent); margin-bottom:6px; text-transform:uppercase; letter-spacing:0.5px; }
.ai-result-text { font-size:12px; color:var(--text-secondary); line-height:1.7; }

/* ── 관계망 보드 섹션 ── */
.board-section { background:var(--card); border-radius:16px; border:1px solid var(--border); padding:16px; margin-bottom:16px; }
.board-section-title { font-size:13px; font-weight:500; color:var(--text-primary); margin-bottom:14px; display:flex; align-items:center; gap:7px; }
.board-section-title svg { width:16px; height:16px; stroke:var(--text-primary); }

/* 인물 그리드 */
.person-grid { display:grid; grid-template-columns:repeat(2,1fr); gap:8px; margin-bottom:14px; }
.person-card { background:var(--bg); border-radius:12px; border:1px solid var(--border); padding:12px; display:flex; align-items:center; gap:10px; }
.person-avatar { width:36px; height:36px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:700; color:#fff; flex-shrink:0; }
.person-card-name { font-size:13px; font-weight:500; color:var(--text-primary); }
.person-card-role { font-size:10px; margin-top:2px; }
.role-suspect  { color:var(--c-suspect); }
.role-victim   { color:var(--c-victim); }
.role-witness  { color:var(--c-witness); }
.role-reference{ color:var(--c-reference); }

/* 관계선 리스트 */
.edge-list { display:flex; flex-direction:column; gap:7px; margin-bottom:14px; }
.edge-item { padding:10px 13px; background:var(--bg); border-radius:11px; border:1px solid var(--border); border-left:3px solid var(--border); }
.edge-item.accomplice { border-left-color:#dc2626; }
.edge-item.harm       { border-left-color:#f97316; }
.edge-item.witness    { border-left-color:#4a7cdc; }
.edge-item.acquaint   { border-left-color:#9ca3af; }
.edge-item.family     { border-left-color:#16a34a; }
.edge-names { font-size:13px; font-weight:500; color:var(--text-primary); }
.edge-rel   { font-size:11px; color:var(--text-muted); margin-top:3px; }
.edge-arrow { color:var(--text-muted); margin:0 4px; }

/* 보드 그리기 버튼 */
.btn-draw { width:100%; padding:14px; border-radius:13px; border:none; background:var(--accent); color:#fff; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; transition:transform 0.1s; margin-bottom:12px; }
.btn-draw:active { transform:scale(0.98); }
.btn-draw svg { width:16px; height:16px; stroke:#fff; }

/* 캔버스 */
.canvas-wrap { position:relative; width:100%; background:#0d1a33; border-radius:14px; overflow:hidden; border:1px solid var(--border); margin-bottom:10px; }
.canvas-toolbar { position:absolute; top:10px; right:10px; z-index:5; display:flex; flex-direction:column; gap:6px; }
.canvas-tool-btn { width:32px; height:32px; border-radius:8px; background:rgba(255,255,255,0.12); border:1px solid rgba(255,255,255,0.18); display:flex; align-items:center; justify-content:center; cursor:pointer; }
.canvas-tool-btn svg { width:15px; height:15px; stroke:#fff; }
#relationCanvas { display:block; width:100%; cursor:grab; touch-action:none; }
.canvas-hint { position:absolute; bottom:10px; left:50%; transform:translateX(-50%); background:rgba(0,0,0,0.5); border-radius:20px; padding:5px 12px; font-size:10px; color:rgba(255,255,255,0.7); white-space:nowrap; pointer-events:none; }

/* 범례 */
.legend-wrap { display:flex; flex-wrap:wrap; gap:8px; margin-top:10px; }
.legend-item { display:flex; align-items:center; gap:5px; font-size:11px; color:var(--text-secondary); }
.legend-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.legend-line { width:18px; height:2px; flex-shrink:0; }

/* ── 드로어 오버레이 ── */
.overlay { position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:200; display:none; align-items:flex-end; justify-content:center; }
.overlay.open { display:flex; }
.drawer { background:var(--card); border-radius:20px 20px 0 0; width:100%; max-width:420px; padding:0 0 32px; animation:slideUp 0.28s ease both; max-height:90vh; overflow-y:auto; }
.drawer-handle { width:36px; height:4px; background:var(--border); border-radius:2px; margin:12px auto 20px; }
.drawer-title { font-size:16px; font-weight:500; color:var(--text-primary); padding:0 20px 16px; border-bottom:1px solid var(--border); }
.drawer-body { padding:20px; }
.d-btn { width:100%; background:var(--navy); color:#fff; border:none; border-radius:12px; padding:14px; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; margin-top:6px; transition:transform 0.1s; }
.d-btn:active { transform:scale(0.98); }
.d-btn-cancel { width:100%; background:var(--bg); color:var(--text-secondary); border:1px solid var(--border); border-radius:12px; padding:13px; font-size:14px; font-family:'Noto Sans KR',sans-serif; cursor:pointer; margin-top:8px; }

/* ── 하단 네비 ── */
.bottom-nav { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:420px; height:var(--bottom-nav-h); background:#fff; border-top:1px solid #e2e5ee; display:flex; z-index:100; }
.nav-item { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:3px; text-decoration:none; color:#9ca3af; cursor:pointer; border:none; background:none; font-family:'Noto Sans KR',sans-serif; }
.nav-item.active { color:#0d1a33; }
.nav-item.active .nav-label { font-weight:600; }
.nav-icon { width:22px; height:22px; display:flex; align-items:center; justify-content:center; }
.nav-icon svg { width:20px; height:20px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; }
.nav-label { font-size:10px; }

/* ── 토스트 ── */
#toast { position:fixed; bottom:84px; left:50%; transform:translateX(-50%) translateY(20px); background:#1a2744; color:#fff; padding:10px 20px; border-radius:24px; font-size:13px; opacity:0; transition:all 0.3s; pointer-events:none; z-index:300; white-space:nowrap; }

@keyframes slideUp { from{transform:translateY(100%);opacity:0} to{transform:translateY(0);opacity:1} }
@keyframes fadeUp  { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
@keyframes aiBounce { 0%,80%,100%{transform:translateY(0)} 40%{transform:translateY(-5px)} }
@media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} .drawer{max-width:420px;} }
</style>
</head>
<body>
<div class="screen">

  <!-- ── 헤더 ── -->
  <div class="top-header">
    <div class="header-row">
      <button class="back-btn" onclick="location.href='main.jsp'">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <div class="header-text">
        <div class="header-title">사건 관계망</div>
        <div class="header-sub">사건 선택 · AI 분석 · 관계망 시각화</div>
      </div>
    </div>
    <div class="header-gold-line"></div>
  </div>

  <!-- ── 콘텐츠 ── -->
  <div class="content">

    <!-- STEP 1: 사건 선택 -->
    <div class="section-label" style="margin-top:4px;">① 사건 선택</div>

    <% if (caseList.isEmpty()) { %>
    <div class="empty-box">
      <div class="empty-icon-wrap">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
      </div>
      <div class="empty-title">담당 사건이 없습니다</div>
      <div class="empty-desc">사건 등록 후 관계망을 분석할 수 있습니다.</div>
    </div>
    <% } else { %>
    <div class="case-select-card" id="caseSelectCard">
      <% for (String[] c : caseList) {
           String statusBadge = "진행중".equals(c[2]) ? "badge-active" :
                                "완료".equals(c[2])   ? "badge-done"   :
                                "모순탐지".equals(c[2]) ? "badge-danger" : "badge-warn";
           String statusLabel = c[2] != null ? c[2] : "진행중";
      %>
      <div class="case-item" id="caseItem_<%= c[0].replace("-","_") %>"
           onclick="selectCase('<%= c[0] %>','<%= c[1].replace("'","\\'") %>')">
        <div class="case-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
          </svg>
        </div>
        <div class="case-info">
          <div class="case-id"><%= c[0] %></div>
          <div class="case-name"><%= c[1] %></div>
        </div>
        <span class="case-badge <%= statusBadge %>"><%= statusLabel %></span>
        <div class="case-arrow">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>
        </div>
      </div>
      <% } %>
    </div>
    <% } %>

    <!-- STEP 2: AI 조서 분석 (사건 선택 후 표시) -->
    <div id="aiSection" style="display:none;">
      <div class="section-label">② AI 조서 분석</div>
      <div class="ai-section">
        <div class="ai-section-title">
          <svg viewBox="0 0 86 86" fill="none" style="width:16px;height:16px;">
            <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="var(--navy)" stroke-width="5"/>
            <circle cx="43" cy="40" r="5" fill="var(--navy)"/>
          </svg>
          조서를 선택해 관계망을 분석합니다
        </div>
        <div class="ai-section-desc">조서를 1개 이상 선택하면 AI가 등장인물과 관계를 자동으로 분석합니다.</div>

        <div class="transcript-list" id="transcriptList">
          <div style="text-align:center;padding:20px;font-size:12px;color:var(--text-muted);">사건을 선택하면 조서 목록이 표시됩니다.</div>
        </div>

        <button class="btn-ai-analyze" id="btnAnalyze" onclick="analyzeWithAI()" disabled>
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
            <circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/>
          </svg>
          AI 관계망 분석 시작
        </button>

        <div class="ai-loading" id="aiLoading">
          <div class="ai-loading-dot"></div>
          <div class="ai-loading-dot"></div>
          <div class="ai-loading-dot"></div>
          <div class="ai-loading-text" id="aiLoadingText">AI가 조서를 분석하는 중...</div>
        </div>

        <div class="ai-result-box" id="aiResultBox">
          <div class="ai-result-label">AI 분석 결과</div>
          <div class="ai-result-text" id="aiResultText"></div>
        </div>
      </div>
    </div>

    <!-- STEP 3: 관계망 보드 (분석 완료 후 표시) -->
    <div id="boardSection" style="display:none;">
      <div class="section-label">③ 관계망 보드</div>

      <!-- 등록 인물 -->
      <div class="board-section">
        <div class="board-section-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
          </svg>
          등록 인물 &nbsp;<span id="personCountBadge" style="font-size:11px;background:#f0f3f9;color:var(--navy);padding:2px 8px;border-radius:20px;font-weight:400;">0명</span>
        </div>
        <div class="person-grid" id="personGrid">
          <div style="grid-column:span 2;text-align:center;padding:16px 0;font-size:12px;color:var(--text-muted);">분석 완료 후 인물이 표시됩니다.</div>
        </div>
      </div>

      <!-- 관계선 -->
      <div class="board-section">
        <div class="board-section-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
            <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
          </svg>
          관계선 &nbsp;<span id="edgeCountBadge" style="font-size:11px;background:#f0f3f9;color:var(--navy);padding:2px 8px;border-radius:20px;font-weight:400;">0개</span>
        </div>
        <div class="edge-list" id="edgeListView">
          <div style="text-align:center;padding:12px 0;font-size:12px;color:var(--text-muted);">분석 완료 후 관계선이 표시됩니다.</div>
        </div>
      </div>

      <!-- 보드 그리기 버튼 -->
      <button class="btn-draw" onclick="drawBoard()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
          <circle cx="8" cy="12" r="3"/><circle cx="18" cy="6" r="3"/><circle cx="18" cy="18" r="3"/>
          <line x1="10.8" y1="10.7" x2="15.2" y2="7.3"/><line x1="10.8" y1="13.3" x2="15.2" y2="16.7"/>
        </svg>
        보드 그리기
      </button>

      <!-- 캔버스 -->
      <div id="canvasContainer" style="display:none;">
        <div class="canvas-wrap" id="canvasWrap">
          <div class="canvas-toolbar">
            <button class="canvas-tool-btn" onclick="zoomIn()">
              <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </button>
            <button class="canvas-tool-btn" onclick="zoomOut()">
              <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </button>
            <button class="canvas-tool-btn" onclick="resetView()">
              <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.5"/></svg>
            </button>
          </div>
          <canvas id="relationCanvas" height="340"></canvas>
          <div class="canvas-hint">드래그로 이동 · 핀치로 확대/축소</div>
        </div>

        <!-- 범례 -->
        <div style="background:var(--card);border-radius:14px;border:1px solid var(--border);padding:14px 16px;margin-bottom:12px;">
          <div class="legend-wrap">
            <div class="legend-item"><div class="legend-dot" style="background:var(--c-suspect)"></div>피의자</div>
            <div class="legend-item"><div class="legend-dot" style="background:var(--c-victim)"></div>피해자</div>
            <div class="legend-item"><div class="legend-dot" style="background:var(--c-witness)"></div>목격자</div>
            <div class="legend-item"><div class="legend-dot" style="background:var(--c-reference)"></div>참고인</div>
            <div class="legend-item"><div class="legend-line" style="background:#dc2626;height:2px;"></div>공범</div>
            <div class="legend-item"><div class="legend-line" style="background:#f97316;height:2px;"></div>피해관계</div>
            <div class="legend-item"><div class="legend-line" style="background:#4a7cdc;height:2px;"></div>목격</div>
            <div class="legend-item"><div class="legend-line" style="background:#16a34a;height:2px;"></div>가족</div>
          </div>
        </div>
      </div>
    </div>

  </div><!-- /content -->

  <!-- ── 하단 네비 ── -->
  <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
      <span class="nav-label">홈</span>
    </a>
    <a href="myCase.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
      <span class="nav-label">조서</span>
    </a>
    <a href="askAI" class="nav-item active">
      <div class="nav-icon">
        <svg width="22" height="22" viewBox="0 0 86 86" fill="none">
          <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="currentColor" stroke-width="5"/>
          <circle cx="43" cy="40" r="11" fill="none" stroke="currentColor" stroke-width="3"/>
          <circle cx="43" cy="40" r="5" fill="currentColor"/>
          <circle cx="43" cy="40" r="2.5" fill="white"/>
          <circle cx="43" cy="22" r="2.8" fill="currentColor"/>
          <circle cx="43" cy="58" r="2.8" fill="currentColor"/>
          <circle cx="28" cy="40" r="2.8" fill="currentColor"/>
          <circle cx="58" cy="40" r="2.8" fill="currentColor"/>
        </svg>
      </div>
      <span class="nav-label">AI</span>
    </a>
    <a href="board.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
      <span class="nav-label">커뮤니티</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>
</div>

<div id="toast"></div>

<script>
// ── 전역 상태 ──────────────────────────────────────────────────────
var currentCaseId   = '';
var currentCaseName = '';
var persons = [];
var edges   = [];
var checkedTranscripts = [];

var ROLE_COLOR = {suspect:'#dc2626',victim:'#f97316',witness:'#4a7cdc',reference:'#8b5cf6'};
var ROLE_LABEL = {suspect:'피의자',victim:'피해자',witness:'목격자',reference:'참고인'};
var REL_COLOR  = {accomplice:'#dc2626',harm:'#f97316',witness:'#4a7cdc',acquaint:'#9ca3af',family:'#16a34a'};
var REL_LABEL  = {accomplice:'공범',harm:'피해관계',witness:'목격',acquaint:'지인',family:'가족'};

// ── STEP 1: 사건 선택 ────────────────────────────────────────────
function selectCase(caseId, caseName) {
  currentCaseId   = caseId;
  currentCaseName = caseName;

  // 선택 표시
  document.querySelectorAll('.case-item').forEach(function(el) {
    el.classList.remove('selected');
  });
  var key = caseId.replace(/-/g, '_');
  var el = document.getElementById('caseItem_' + key);
  if (el) el.classList.add('selected');

  // AI 섹션 표시 + 조서 목록 로드
  document.getElementById('aiSection').style.display   = 'block';
  document.getElementById('boardSection').style.display = 'none';
  checkedTranscripts = [];
  loadTranscripts(caseId);

  // 부드럽게 스크롤
  setTimeout(function() {
    document.getElementById('aiSection').scrollIntoView({behavior:'smooth', block:'start'});
  }, 100);
}

// ── 조서 목록 로드 (caseApi action=caseDetail) ──────────────────
function loadTranscripts(caseId) {
  var list = document.getElementById('transcriptList');
  list.innerHTML = '<div style="text-align:center;padding:20px;font-size:12px;color:var(--text-muted);">불러오는 중...</div>';
  document.getElementById('btnAnalyze').disabled = true;

  fetch('caseApi?action=caseDetail&caseId=' + encodeURIComponent(caseId))
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.error) {
        list.innerHTML = '<div style="text-align:center;padding:20px;font-size:12px;color:var(--danger);">' + escHtml(data.error) + '</div>';
        return;
      }
      var docs = data.docs || [];
      if (!docs.length) {
        list.innerHTML = '<div style="text-align:center;padding:20px;font-size:12px;color:var(--text-muted);">이 사건에 등록된 조서가 없습니다.</div>';
        return;
      }
      // 조서 아이템을 DOM으로 직접 생성 (innerHTML onclick은 따옴표 충돌 위험)
      list.innerHTML = '';
      docs.forEach(function(d) {
        var badgeCls  = d.contradiction ? 'tb-contradiction' : 'tb-normal';
        var badgeTxt  = d.contradiction ? '모순탐지' : '정상';
        var typeLabel = {'피의자':'피의자','피해자':'피해자','목격자':'목격자','참고인':'참고인'}[d.type] || d.type || '미분류';

        var item = document.createElement('div');
        item.className = 'transcript-item';
        item.id = 'tr_' + d.id;

        var chk = document.createElement('div');
        chk.className = 'transcript-chk';
        chk.innerHTML = '<svg viewBox="0 0 12 12" fill="none" stroke-width="2.5" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg>';

        var info = document.createElement('div');
        info.className = 'transcript-info';
        info.innerHTML =
          '<div class="transcript-title">' + escHtml(d.name || '미입력') + ' · ' + escHtml(typeLabel) + '</div>' +
          '<div class="transcript-meta">' + escHtml(d.date) + ' · ' + (d.words || 0) + '자</div>';

        var badge = document.createElement('span');
        badge.className = 'transcript-badge ' + badgeCls;
        badge.textContent = badgeTxt;

        item.appendChild(chk);
        item.appendChild(info);
        item.appendChild(badge);

        // 클릭 이벤트를 addEventListener로 안전하게 등록
        (function(transcriptId, transcriptName, transcriptType, transcriptDate) {
          item.addEventListener('click', function() {
            toggleTranscript(transcriptId, transcriptName, transcriptType, transcriptDate);
          });
        })(String(d.id), d.name || '', d.type || '', d.date || '');

        list.appendChild(item);
      });
    })
    .catch(function() {
      list.innerHTML = '<div style="text-align:center;padding:20px;font-size:12px;color:var(--danger);">조서 목록을 불러오지 못했습니다.</div>';
    });
}

// ── 조서 체크/해제 ────────────────────────────────────────────────
function toggleTranscript(id, name, type, date) {
  id = String(id); // 타입 통일 (숫자/문자열 혼용 방지)
  var el = document.getElementById('tr_' + id);
  if (!el) return;
  var idx = checkedTranscripts.findIndex(function(t) { return String(t.id) === id; });
  if (idx >= 0) {
    checkedTranscripts.splice(idx, 1);
    el.classList.remove('checked');
  } else {
    checkedTranscripts.push({id:id, name:name, type:type, date:date});
    el.classList.add('checked');
  }
  document.getElementById('btnAnalyze').disabled = checkedTranscripts.length < 1;
}

// ── STEP 2: AI 분석 ───────────────────────────────────────────────
function analyzeWithAI() {
  if (checkedTranscripts.length < 1) {
    showToast('조서를 1개 이상 선택해 주세요.'); return;
  }

  document.getElementById('btnAnalyze').disabled  = true;
  document.getElementById('aiLoading').classList.add('show');
  document.getElementById('aiResultBox').classList.remove('show');
  document.getElementById('aiLoadingText').textContent = '조서 내용을 불러오는 중...';

  // 선택된 조서들의 원문 가져오기
  var fetchPromises = checkedTranscripts.map(function(t) {
    return fetch('caseApi?action=transcriptText&transcriptId=' + t.id)
      .then(function(r) { return r.json(); })
      .then(function(d) { return { meta: t, text: d.text || '' }; })
      .catch(function() { return { meta: t, text: '' }; });
  });

  Promise.all(fetchPromises).then(function(results) {
    document.getElementById('aiLoadingText').textContent = 'Ollama AI가 관계망을 분석하는 중...';

    // AI에게 보낼 프롬프트 구성
    var transcriptBlock = results.map(function(r, i) {
      return '[조서 ' + (i+1) + '] 진술자: ' + r.meta.name + ' (' + r.meta.type + ')\n' + r.text;
    }).join('\n\n---\n\n');

    var prompt = '당신은 형사사건 조서 분석 AI입니다.\n' +
      '아래 조서들을 분석하여 등장인물과 인물 간 관계를 추출하세요.\n\n' +
      '사건번호: ' + currentCaseId + ' ' + currentCaseName + '\n\n' +
      transcriptBlock + '\n\n' +
      '분석 결과를 반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 포함하지 마세요:\n' +
      '{"persons":[{"name":"이름","role":"suspect|victim|witness|reference","memo":"간단한 메모"}],' +
      '"edges":[{"src":"출발인물이름","dst":"도착인물이름","relType":"accomplice|harm|witness|acquaint|family","status":"match|mismatch|unknown","context":"scene|time|evidence|"}]}';

    // Ollama API 호출
    fetch('http://localhost:11434/api/generate', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({model:'gemma3:1b', prompt:prompt, stream:false})
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var raw = data.response || '';
      parseAndApplyAiResult(raw);
    })
    .catch(function(err) {
      // Ollama 연결 실패 시 서버 사이드 프록시로 시도
      callAiViaServlet(prompt);
    });
  });
}

// ── 서버 프록시 경유 AI 호출 (Ollama 직접 접근 불가 시) ──────────
function callAiViaServlet(prompt) {
  document.getElementById('aiLoadingText').textContent = '서버를 통해 AI 분석 중...';

  var params = new URLSearchParams();
  params.append('userMsg', prompt);
  params.append('category', '관계망분석');

  fetch('askAI', { method:'POST', body:params })
    .then(function(r) { return r.text(); })
    .then(function(html) {
      // 서블릿이 JSP로 forward하므로 result attribute 직접 호출 불가
      // 대신 별도 JSON 엔드포인트 시도 또는 fallback
      fallbackManualMode();
    })
    .catch(function() {
      fallbackManualMode();
    });
}

// ── AI 응답 파싱 & 적용 ──────────────────────────────────────────
function parseAndApplyAiResult(raw) {
  document.getElementById('aiLoading').classList.remove('show');

  // JSON 추출 시도
  var jsonMatch = raw.match(/\{[\s\S]*\}/);
  if (!jsonMatch) {
    showToast('AI 응답 파싱 실패. 수동으로 입력해 주세요.');
    document.getElementById('aiResultBox').classList.add('show');
    document.getElementById('aiResultText').textContent = 'AI 응답: ' + raw.substring(0, 200);
    document.getElementById('btnAnalyze').disabled = false;
    showBoardSection([], []);
    return;
  }

  try {
    var result = JSON.parse(jsonMatch[0]);
    var rawPersons = result.persons || [];
    var rawEdges   = result.edges   || [];

    // uid 부여
    var parsedPersons = rawPersons.map(function(p) {
      return {id: uid(), name: p.name, role: p.role || 'reference', memo: p.memo || ''};
    });

    // 엣지 src/dst 이름 → id 변환
    var parsedEdges = rawEdges.map(function(e) {
      var sp = parsedPersons.find(function(p) { return p.name === e.src; });
      var dp = parsedPersons.find(function(p) { return p.name === e.dst; });
      if (!sp || !dp) return null;
      return {id:uid(), src:sp.id, dst:dp.id, relType:e.relType||'acquaint', status:e.status||'unknown', context:e.context||''};
    }).filter(Boolean);

    // DB 저장
    saveToDb(currentCaseId, parsedPersons, parsedEdges, function(ok) {
      var summary = '인물 ' + parsedPersons.length + '명, 관계선 ' + parsedEdges.length + '개 분석 완료';
      if (!ok) summary += ' (DB 저장 실패 — 로컬 표시만)';

      document.getElementById('aiResultBox').classList.add('show');
      document.getElementById('aiResultText').textContent = summary;
      document.getElementById('btnAnalyze').disabled = false;
      showToast('✅ ' + summary);
      showBoardSection(parsedPersons, parsedEdges);
    });

  } catch (e) {
    showToast('AI 응답 파싱 오류. 수동으로 입력해 주세요.');
    document.getElementById('aiResultText').textContent = raw.substring(0, 300);
    document.getElementById('aiResultBox').classList.add('show');
    document.getElementById('btnAnalyze').disabled = false;
    showBoardSection([], []);
  }
}

// ── Ollama 미실행 fallback ────────────────────────────────────────
function fallbackManualMode() {
  document.getElementById('aiLoading').classList.remove('show');
  document.getElementById('aiResultBox').classList.add('show');
  document.getElementById('aiResultText').textContent = 'AI 서버(Ollama)에 연결할 수 없습니다. 서버에서 "ollama run gemma3:1b"를 실행한 후 다시 시도해 주세요.';
  document.getElementById('btnAnalyze').disabled = false;
  showToast('Ollama 서버에 연결할 수 없습니다.');
  showBoardSection([], []);
}

// ── DB 저장 ──────────────────────────────────────────────────────
function saveToDb(caseId, parsedPersons, parsedEdges, callback) {
  var edgesWithName = parsedEdges.map(function(e) {
    var sp = parsedPersons.find(function(p) { return p.id === e.src; });
    var dp = parsedPersons.find(function(p) { return p.id === e.dst; });
    return {srcName:sp?sp.name:'', dstName:dp?dp.name:'', relType:e.relType, status:e.status, context:e.context||''};
  }).filter(function(e) { return e.srcName && e.dstName; });

  fetch('/Polmate/saveBoardAction.do', {
    method: 'POST',
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: JSON.stringify({caseId:caseId, personList:parsedPersons, edgeList:edgesWithName})
  })
  .then(function(r) { return r.json(); })
  .then(function(d) { callback(d.success); })
  .catch(function() { callback(false); });
}

// ── STEP 3: 보드 섹션 표시 ──────────────────────────────────────
function showBoardSection(parsedPersons, parsedEdges) {
  persons = parsedPersons;
  edges   = parsedEdges;

  document.getElementById('boardSection').style.display = 'block';
  renderPersonGrid();
  renderEdgeList();

  setTimeout(function() {
    document.getElementById('boardSection').scrollIntoView({behavior:'smooth', block:'start'});
  }, 200);
}

// ── 인물 그리드 렌더링 ───────────────────────────────────────────
function renderPersonGrid() {
  document.getElementById('personCountBadge').textContent = persons.length + '명';
  var el = document.getElementById('personGrid');
  if (!persons.length) {
    el.innerHTML = '<div style="grid-column:span 2;text-align:center;padding:16px 0;font-size:12px;color:var(--text-muted);">등록된 인물이 없습니다.</div>';
    return;
  }
  el.innerHTML = persons.map(function(p) {
    return '<div class="person-card">' +
      '<div class="person-avatar" style="background:' + (ROLE_COLOR[p.role]||'#4a7cdc') + '">' + escHtml(p.name.charAt(0)) + '</div>' +
      '<div>' +
        '<div class="person-card-name">' + escHtml(p.name) + '</div>' +
        '<div class="person-card-role role-' + p.role + '">' + (ROLE_LABEL[p.role]||p.role) + '</div>' +
      '</div>' +
    '</div>';
  }).join('');
}

// ── 관계선 리스트 렌더링 ─────────────────────────────────────────
function renderEdgeList() {
  document.getElementById('edgeCountBadge').textContent = edges.length + '개';
  var el = document.getElementById('edgeListView');
  if (!edges.length) {
    el.innerHTML = '<div style="text-align:center;padding:12px 0;font-size:12px;color:var(--text-muted);">관계선이 없습니다.</div>';
    return;
  }
  el.innerHTML = edges.map(function(e) {
    var sp = persons.find(function(p) { return p.id === e.src; });
    var dp = persons.find(function(p) { return p.id === e.dst; });
    if (!sp || !dp) return '';
    return '<div class="edge-item ' + e.relType + '">' +
      '<div class="edge-names">' + escHtml(sp.name) + '<span class="edge-arrow">→</span>' + escHtml(dp.name) + '</div>' +
      '<div class="edge-rel">' + (REL_LABEL[e.relType]||e.relType) + (e.status !== 'unknown' ? ' · ' + (e.status==='match'?'일치':'불일치') : '') + '</div>' +
    '</div>';
  }).join('');
}

// ── 보드 그리기 ──────────────────────────────────────────────────
function drawBoard() {
  if (!persons.length) { showToast('표시할 인물이 없습니다.'); return; }
  var container = document.getElementById('canvasContainer');
  container.style.display = 'block';
  setTimeout(function() {
    resizeCanvas();
    drawCanvas();
    container.scrollIntoView({behavior:'smooth', block:'start'});
  }, 100);
}

// ── 캔버스 ───────────────────────────────────────────────────────
var canvas, ctx, scale=1, offsetX=0, offsetY=0, isDragging=false, lastX=0, lastY=0;

window.addEventListener('load', function() {
  canvas = document.getElementById('relationCanvas');
  if (!canvas) return;
  ctx = canvas.getContext('2d');
  resizeCanvas();

  canvas.addEventListener('mousedown',  function(e) { isDragging=true; lastX=e.clientX; lastY=e.clientY; });
  canvas.addEventListener('mousemove',  function(e) { if(!isDragging)return; offsetX+=(e.clientX-lastX)/scale; offsetY+=(e.clientY-lastY)/scale; lastX=e.clientX; lastY=e.clientY; drawCanvas(); });
  canvas.addEventListener('mouseup',    function()  { isDragging=false; });
  canvas.addEventListener('mouseleave', function()  { isDragging=false; });

  var ltx, lty, ld;
  canvas.addEventListener('touchstart', function(e) {
    if(e.touches.length===1){ltx=e.touches[0].clientX;lty=e.touches[0].clientY;}
    if(e.touches.length===2){ld=Math.hypot(e.touches[0].clientX-e.touches[1].clientX,e.touches[0].clientY-e.touches[1].clientY);}
    e.preventDefault();
  },{passive:false});
  canvas.addEventListener('touchmove', function(e) {
    if(e.touches.length===1){offsetX+=(e.touches[0].clientX-ltx)/scale;offsetY+=(e.touches[0].clientY-lty)/scale;ltx=e.touches[0].clientX;lty=e.touches[0].clientY;drawCanvas();}
    if(e.touches.length===2){var d=Math.hypot(e.touches[0].clientX-e.touches[1].clientX,e.touches[0].clientY-e.touches[1].clientY);scale=Math.max(0.4,Math.min(2.5,scale*d/ld));ld=d;drawCanvas();}
    e.preventDefault();
  },{passive:false});
});

function resizeCanvas() {
  var w = document.getElementById('canvasWrap');
  if (!w || !canvas) return;
  canvas.width  = w.clientWidth;
  canvas.height = 340;
  drawCanvas();
}

function drawCanvas() {
  if (!ctx) return;
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#0d1a33';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  if (!persons.length) {
    ctx.fillStyle = 'rgba(255,255,255,0.3)';
    ctx.font = '13px Noto Sans KR,sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('보드 그리기를 누르면 관계망이 표시됩니다', canvas.width/2, canvas.height/2);
    return;
  }

  var cx = canvas.width/2, cy = canvas.height/2;
  var r  = Math.min(cx, cy) * 0.62;

  persons.forEach(function(p, i) {
    var a = (2*Math.PI*i/persons.length) - Math.PI/2;
    p._x = cx + Math.cos(a)*r + offsetX*scale;
    p._y = cy + Math.sin(a)*r + offsetY*scale;
  });
  if (persons.length === 1) { persons[0]._x = cx+offsetX*scale; persons[0]._y = cy+offsetY*scale; }

  ctx.save();

  // 관계선 그리기
  edges.forEach(function(e) {
    var sp = persons.find(function(p){return p.id===e.src;}),
        dp = persons.find(function(p){return p.id===e.dst;});
    if (!sp||!dp) return;
    var color = REL_COLOR[e.relType] || '#9ca3af';
    ctx.beginPath(); ctx.moveTo(sp._x,sp._y); ctx.lineTo(dp._x,dp._y);
    ctx.lineWidth = 2*scale;
    if (e.status==='mismatch')     { ctx.setLineDash([6*scale,4*scale]); ctx.strokeStyle='#dc2626'; }
    else if (e.status==='unknown') { ctx.setLineDash([4*scale,4*scale]); ctx.strokeStyle='#9ca3af'; }
    else                           { ctx.setLineDash([]); ctx.strokeStyle=color; }
    ctx.stroke(); ctx.setLineDash([]);

    // 화살표
    var ang=Math.atan2(dp._y-sp._y,dp._x-sp._x), nr=20*scale,
        ax=dp._x-Math.cos(ang)*nr, ay=dp._y-Math.sin(ang)*nr;
    ctx.beginPath();
    ctx.moveTo(ax,ay);
    ctx.lineTo(ax-8*scale*Math.cos(ang-0.4), ay-8*scale*Math.sin(ang-0.4));
    ctx.lineTo(ax-8*scale*Math.cos(ang+0.4), ay-8*scale*Math.sin(ang+0.4));
    ctx.closePath();
    ctx.fillStyle = e.status==='mismatch'?'#dc2626':(e.status==='unknown'?'#9ca3af':color);
    ctx.fill();

    // 관계 레이블
    var mx=(sp._x+dp._x)/2, my=(sp._y+dp._y)/2;
    ctx.font=(10*scale)+'px Noto Sans KR,sans-serif'; ctx.fillStyle='rgba(255,255,255,0.75)'; ctx.textAlign='center';
    ctx.fillText(REL_LABEL[e.relType]||'', mx, my-5*scale);
    if (e.status==='mismatch') { ctx.font=(13*scale)+'px sans-serif'; ctx.fillText('⚠', mx, my+12*scale); }
  });

  // 인물 노드 그리기
  persons.forEach(function(p) {
    var nr = 20*scale;
    ctx.beginPath(); ctx.arc(p._x, p._y, nr, 0, 2*Math.PI);
    ctx.fillStyle = ROLE_COLOR[p.role]||'#4a7cdc'; ctx.fill();
    ctx.strokeStyle='#fff'; ctx.lineWidth=2*scale; ctx.stroke();
    ctx.font='bold '+(11*scale)+'px Noto Sans KR,sans-serif';
    ctx.fillStyle='#fff'; ctx.textAlign='center';
    ctx.fillText(p.name.length>3?p.name.substr(0,3)+'…':p.name, p._x, p._y+4*scale);
    ctx.font=(9*scale)+'px Noto Sans KR,sans-serif'; ctx.fillStyle='rgba(255,255,255,0.7)';
    ctx.fillText(ROLE_LABEL[p.role]||'', p._x, p._y+nr+12*scale);
  });

  ctx.restore();
}

function zoomIn()    { scale=Math.min(2.5,scale+0.2); drawCanvas(); }
function zoomOut()   { scale=Math.max(0.4,scale-0.2); drawCanvas(); }
function resetView() { scale=1; offsetX=0; offsetY=0; drawCanvas(); }

// ── 유틸 ─────────────────────────────────────────────────────────
function uid() { return Math.random().toString(36).substr(2,9); }
function escHtml(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.style.opacity='1'; t.style.transform='translateX(-50%) translateY(0)';
  setTimeout(function() { t.style.opacity='0'; t.style.transform='translateX(-50%) translateY(20px)'; }, 2500);
}

window.addEventListener('resize', resizeCanvas);
</script>
</body>
</html>
