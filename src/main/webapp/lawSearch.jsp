<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 법전 조회</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  :root {
    --navy:#1a2744; --accent:#4a7cdc; --danger:#dc2626;
    --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
    --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
    --success:#16a34a; --success-bg:#f0fdf4;
    --info-bg:#eff6ff; --info-text:#1e40af; --info-border:#bfdbfe;
    --bottom-nav-h:64px;
  }
  html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
  .screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

  /* ── 헤더 ── */
  .top-header { background:var(--navy); padding:52px 20px 16px; position:sticky; top:0; z-index:10; }
  .header-row { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
  .header-title { font-size:17px; font-weight:500; color:#fff; }
  .header-sub   { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }

  /* 검색창 */
  .search-wrap { position:relative; }
  .search-input-main {
    width:100%; background:rgba(255,255,255,0.12); border:1px solid rgba(255,255,255,0.2);
    border-radius:14px; padding:13px 50px 13px 44px;
    font-size:14px; font-family:'Noto Sans KR',sans-serif; color:#fff; outline:none;
    transition:background 0.2s;
  }
  .search-input-main::placeholder { color:rgba(255,255,255,0.45); }
  .search-input-main:focus { background:rgba(255,255,255,0.18); }
  .search-icon-left  { position:absolute; left:14px;  top:50%; transform:translateY(-50%); width:18px; height:18px; stroke:rgba(255,255,255,0.6); pointer-events:none; }
  .search-btn {
    position:absolute; right:8px; top:50%; transform:translateY(-50%);
    background:rgba(255,255,255,0.2); border:none; border-radius:10px;
    padding:6px 12px; color:#fff; font-size:12px; font-family:'Noto Sans KR',sans-serif;
    cursor:pointer; white-space:nowrap;
  }

  /* AI 모드 토글 */
  .mode-row { display:flex; align-items:center; justify-content:space-between; margin-top:12px; }
  .mode-label { font-size:11px; color:rgba(255,255,255,0.6); display:flex; align-items:center; gap:6px; }
  .mode-label svg { width:13px; height:13px; stroke:rgba(255,255,255,0.6); }
  .toggle-wrap { position:relative; width:40px; height:23px; }
  .toggle-input { opacity:0; width:0; height:0; position:absolute; }
  .toggle-slider { position:absolute; inset:0; background:rgba(255,255,255,0.2); border-radius:12px; cursor:pointer; transition:background 0.25s; }
  .toggle-slider::before { content:''; position:absolute; width:17px; height:17px; border-radius:50%; background:#fff; top:3px; left:3px; transition:transform 0.25s; box-shadow:0 1px 3px rgba(0,0,0,0.3); }
  .toggle-input:checked + .toggle-slider { background:#4ade80; }
  .toggle-input:checked + .toggle-slider::before { transform:translateX(17px); }

  /* ── 콘텐츠 ── */
  .content { flex:1; overflow-y:auto; padding-bottom:calc(var(--bottom-nav-h) + 16px); }

  /* 빠른 접근 카테고리 */
  .quick-section { padding:16px 16px 8px; }
  .section-label { font-size:10px; font-weight:500; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.6px; margin-bottom:10px; }
  .cat-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:8px; }
  .cat-card {
    background:var(--card); border-radius:14px; border:1px solid var(--border);
    padding:14px 10px; text-align:center; cursor:pointer; transition:border-color 0.2s, background 0.15s;
    animation:fadeUp 0.3s ease both;
  }
  .cat-card:active { background:var(--bg); }
  .cat-icon { width:36px; height:36px; border-radius:10px; margin:0 auto 8px; display:flex; align-items:center; justify-content:center; }
  .cat-icon svg { width:18px; height:18px; }
  .cat-name { font-size:11px; font-weight:500; color:var(--text-primary); line-height:1.4; }

  /* 최근 검색 */
  .recent-row { display:flex; gap:8px; padding:0 16px 4px; overflow-x:auto; -ms-overflow-style:none; scrollbar-width:none; }
  .recent-row::-webkit-scrollbar { display:none; }
  .recent-chip {
    flex-shrink:0; background:var(--card); border:1px solid var(--border); border-radius:20px;
    padding:6px 12px; font-size:11px; color:var(--text-secondary); cursor:pointer; white-space:nowrap;
    display:flex; align-items:center; gap:5px; transition:background 0.15s;
  }
  .recent-chip svg { width:11px; height:11px; stroke:var(--text-muted); }
  .recent-chip:active { background:var(--bg); }

  /* 법령 카드 */
  .law-list   { padding:0 16px; display:flex; flex-direction:column; gap:10px; }
  .law-card   {
    background:var(--card); border-radius:14px; border:1px solid var(--border);
    padding:16px; cursor:pointer; transition:border-color 0.2s;
    animation:fadeUp 0.3s ease both;
  }
  .law-card:active { background:var(--bg); }
  .law-card-top    { display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:8px; }
  .law-act  { font-size:11px; color:var(--accent); font-weight:500; margin-bottom:3px; }
  .law-name { font-size:14px; font-weight:500; color:var(--text-primary); line-height:1.4; }
  .law-num  { font-size:10px; color:var(--text-muted); white-space:nowrap; flex-shrink:0; margin-left:8px; margin-top:2px; }
  .law-preview { font-size:12px; color:var(--text-secondary); line-height:1.7; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
  .law-tags { display:flex; gap:6px; margin-top:10px; flex-wrap:wrap; }
  .law-tag  { font-size:10px; background:var(--bg); border:1px solid var(--border); border-radius:10px; padding:3px 8px; color:var(--text-muted); }

  /* AI 응답 카드 */
  .ai-card {
    background:var(--card); border-radius:16px; border:1px solid var(--info-border);
    padding:18px; margin:0 16px; animation:fadeUp 0.35s ease both; display:none;
  }
  .ai-card-head { display:flex; align-items:center; gap:10px; margin-bottom:12px; }
  .ai-badge { background:var(--info-bg); color:var(--info-text); font-size:10px; font-weight:500; border-radius:20px; padding:3px 10px; }
  .ai-model { font-size:10px; color:var(--text-muted); margin-left:auto; }
  .ai-body  { font-size:13px; color:var(--text-primary); line-height:1.9; white-space:pre-wrap; max-height:320px; overflow-y:auto; }
  .ai-spinner { display:flex; align-items:center; gap:10px; }
  .spinner-sm { width:18px; height:18px; border:2px solid var(--border); border-top-color:var(--navy); border-radius:50%; animation:spin 0.7s linear infinite; }

  /* 빈 상태 */
  .empty-state { padding:48px 20px; text-align:center; display:none; }
  .empty-icon  { width:60px; height:60px; background:var(--bg); border-radius:50%; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; }
  .empty-icon svg { width:28px; height:28px; stroke:var(--text-muted); }
  .empty-title { font-size:14px; font-weight:500; color:var(--text-secondary); margin-bottom:6px; }
  .empty-desc  { font-size:12px; color:var(--text-muted); line-height:1.8; }

  /* ── 드로어: 법령 상세 ── */
  .overlay { position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:200; display:none; align-items:flex-end; justify-content:center; }
  .overlay.open { display:flex; }
  .drawer { background:var(--card); border-radius:20px 20px 0 0; width:100%; max-width:420px; padding:0 0 36px; animation:slideUp 0.28s ease both; max-height:88vh; overflow-y:auto; }
  .drawer-handle { width:36px; height:4px; background:var(--border); border-radius:2px; margin:12px auto 0; }
  .drawer-head { padding:16px 20px; border-bottom:1px solid var(--border); }
  .drawer-act   { font-size:11px; color:var(--accent); font-weight:500; margin-bottom:4px; }
  .drawer-title { font-size:16px; font-weight:500; color:var(--text-primary); line-height:1.4; }
  .drawer-body  { padding:20px; }
  .law-full-text {
    background:var(--bg); border-radius:12px; padding:16px; font-size:13px;
    color:var(--text-primary); line-height:2; border-left:3px solid var(--navy);
    margin-bottom:14px; white-space:pre-wrap;
  }
  .interpretation-box {
    background:var(--info-bg); border:1px solid var(--info-border); border-radius:12px; padding:14px;
    font-size:12px; color:var(--info-text); line-height:1.8; margin-bottom:14px;
  }
  .interp-label { font-size:10px; font-weight:500; margin-bottom:6px; display:flex; align-items:center; gap:5px; }
  .interp-label svg { width:12px; height:12px; }
  .btn-ai-explain {
    width:100%; background:var(--navy); color:#fff; border:none; border-radius:12px;
    padding:14px; font-size:13px; font-weight:500; font-family:'Noto Sans KR',sans-serif;
    cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px;
    margin-bottom:8px; transition:transform 0.1s;
  }
  .btn-ai-explain:active { transform:scale(0.98); }
  .btn-ai-explain svg { width:15px; height:15px; stroke:#fff; }
  .btn-close-drawer {
    width:100%; background:var(--bg); color:var(--text-secondary); border:1px solid var(--border);
    border-radius:12px; padding:13px; font-size:13px; font-family:'Noto Sans KR',sans-serif; cursor:pointer;
  }

  /* ── 하단 네비 ── */
  .bottom-nav { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:420px; height:var(--bottom-nav-h); background:var(--card); border-top:1px solid var(--border); display:flex; justify-content:space-around; align-items:center; padding:0 8px; z-index:100; }
  .nav-item { display:flex; flex-direction:column; align-items:center; gap:3px; flex:1; cursor:pointer; text-decoration:none; padding:6px 0; }
  .nav-icon { width:24px; height:24px; display:flex; align-items:center; justify-content:center; }
  .nav-icon svg { width:22px; height:22px; }
  .nav-label { font-size:9px; }
  .nav-item.active .nav-icon svg { stroke:var(--navy); }
  .nav-item.active .nav-label    { color:var(--navy); font-weight:500; }
  .nav-item:not(.active) .nav-icon svg { stroke:var(--text-muted); }
  .nav-item:not(.active) .nav-label    { color:var(--text-muted); }

  @keyframes fadeUp  { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
  @keyframes slideUp { from{transform:translateY(100%);opacity:0} to{transform:translateY(0);opacity:1} }
  @keyframes spin    { to{transform:rotate(360deg)} }
  @media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }
</style>
</head>
<body>
<div class="screen">

  <!-- 헤더 -->
  <div class="top-header">
    <div class="header-row">
      <div>
        <div class="header-title">법전 조회</div>
        <div class="header-sub">형사소송법 · 경찰관직무집행법 · 헌법</div>
      </div>
    </div>

    <div class="search-wrap">
      <svg class="search-icon-left" viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input type="text" class="search-input-main" id="lawSearchInput"
             placeholder="조문 번호 또는 키워드 검색..."
             onkeydown="if(event.key==='Enter') doSearch()">
      <button class="search-btn" onclick="doSearch()">검색</button>
    </div>

    <div class="mode-row">
      <label class="mode-label">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
        AI 법령 해석 모드
      </label>
      <label class="toggle-wrap">
        <input type="checkbox" class="toggle-input" id="aiToggle" onchange="toggleAIMode()">
        <span class="toggle-slider"></span>
      </label>
    </div>
  </div>

  <div class="content" id="mainContent">

    <!-- 빠른 카테고리 -->
    <div class="quick-section" id="quickSection">
      <div class="section-label">자주 찾는 법령</div>
      <div class="cat-grid">
        <div class="cat-card" style="animation-delay:0.05s" onclick="searchBy('미란다 원칙')">
          <div class="cat-icon" style="background:#fef3c7;"><svg viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
          <div class="cat-name">미란다 원칙</div>
        </div>
        <div class="cat-card" style="animation-delay:0.08s" onclick="searchBy('체포영장')">
          <div class="cat-icon" style="background:#eff6ff;"><svg viewBox="0 0 24 24" fill="none" stroke="#1d4ed8" stroke-width="1.8" stroke-linecap="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
          <div class="cat-name">체포영장</div>
        </div>
        <div class="cat-card" style="animation-delay:0.11s" onclick="searchBy('묵비권')">
          <div class="cat-icon" style="background:#f0fdf4;"><svg viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="1.8" stroke-linecap="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg></div>
          <div class="cat-name">진술거부권</div>
        </div>
        <div class="cat-card" style="animation-delay:0.14s" onclick="searchBy('압수수색')">
          <div class="cat-icon" style="background:#f5f3ff;"><svg viewBox="0 0 24 24" fill="none" stroke="#7c3aed" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
          <div class="cat-name">압수수색</div>
        </div>
        <div class="cat-card" style="animation-delay:0.17s" onclick="searchBy('구속영장')">
          <div class="cat-icon" style="background:#fef2f2;"><svg viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
          <div class="cat-name">구속영장</div>
        </div>
        <div class="cat-card" style="animation-delay:0.20s" onclick="searchBy('변호인 조력권')">
          <div class="cat-icon" style="background:#f0f3f9;"><svg viewBox="0 0 24 24" fill="none" stroke="#1a2744" stroke-width="1.8" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
          <div class="cat-name">변호인 조력권</div>
        </div>
      </div>
    </div>

    <!-- 최근 검색어 -->
    <div id="recentSection">
      <div style="padding:4px 16px 8px; display:flex; align-items:center; justify-content:space-between;">
        <span style="font-size:10px; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.6px; font-weight:500;">최근 검색</span>
        <button onclick="clearRecent()" style="font-size:10px; color:var(--text-muted); background:none; border:none; cursor:pointer; font-family:'Noto Sans KR',sans-serif;">전체 삭제</button>
      </div>
      <div class="recent-row" id="recentRow"></div>
    </div>

    <!-- AI 응답 카드 -->
    <div class="ai-card" id="aiCard" style="margin-bottom:14px;">
      <div class="ai-card-head">
        <span class="ai-badge">AI 법령 해석</span>
        <span class="ai-model">gemma3:1b</span>
      </div>
      <div class="ai-body" id="aiBody">
        <div class="ai-spinner">
          <div class="spinner-sm"></div>
          <span style="font-size:12px; color:var(--text-muted);">분석 중...</span>
        </div>
      </div>
    </div>

    <!-- 검색 결과 -->
    <div id="resultSection" style="display:none;">
      <div style="padding:4px 16px 10px; display:flex; align-items:center; justify-content:space-between;">
        <span style="font-size:10px; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.6px; font-weight:500;">검색 결과</span>
        <span style="font-size:11px; color:var(--text-muted);" id="resultCount"></span>
      </div>
      <div class="law-list" id="lawList"></div>
    </div>

    <!-- 빈 상태 -->
    <div class="empty-state" id="emptyState">
      <div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
      <div class="empty-title">검색 결과가 없습니다</div>
      <div class="empty-desc">다른 키워드로 검색하거나<br>AI 해석 모드를 켜고 질문해 보세요</div>
    </div>

  </div><!-- /content -->

  <!-- 하단 네비 -->
  <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
      <span class="nav-label">홈</span>
    </a>
    <a href="myCase.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
      <span class="nav-label">조서</span>
    </a>
    <a href="askAI" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg></div>
      <span class="nav-label">AI</span>
    </a>
    <a href="lawSearch.jsp" class="nav-item active">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
      <span class="nav-label">법전</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>
</div>

<!-- ═══ 법령 상세 드로어 ═══ -->
<div class="overlay" id="lawDrawer" onclick="closeOnBg(event,'lawDrawer')">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-head" style="padding:16px 20px;">
      <div class="drawer-act"  id="drawerAct"></div>
      <div class="drawer-title" id="drawerLawTitle"></div>
    </div>
    <div class="drawer-body">
      <div class="law-full-text" id="drawerFullText"></div>
      <div class="interpretation-box" id="drawerInterp">
        <div class="interp-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--info-text)" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
          수사 실무 포인트
        </div>
        <div id="drawerInterpText"></div>
      </div>
      <button class="btn-ai-explain" onclick="explainWithAI()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
        AI로 쉽게 설명하기
      </button>
      <div class="interpretation-box" id="aiExplainBox" style="display:none; margin-top:0;">
        <div class="interp-label">AI 설명 (gemma3:1b)</div>
        <div id="aiExplainText"></div>
      </div>
      <button class="btn-close-drawer" onclick="closeDrawer('lawDrawer')">닫기</button>
    </div>
  </div>
</div>

<script>
// ── 법령 데이터베이스 (임시 내장 데이터) ─────────────────────────
var LAW_DB = [
  {
    id:'L001', act:'형사소송법', num:'제244조의3',
    name:'피의자에 대한 진술거부권 등의 고지',
    preview:'검사 또는 사법경찰관은 피의자를 신문하기 전에 진술거부권, 변호인 조력권 등을 고지하여야 한다.',
    full:'① 검사 또는 사법경찰관은 피의자를 신문하기 전에 다음 각 호의 사항을 알려주어야 한다.\n1. 일체의 진술을 하지 아니하거나 개개의 질문에 대하여 진술을 하지 아니할 수 있다는 것\n2. 진술을 하지 아니하더라도 불이익을 받지 아니한다는 것\n3. 진술을 거부할 권리를 포기하고 행한 진술은 법정에서 유죄의 증거로 사용될 수 있다는 것\n4. 신문을 받을 때에는 변호인을 참여하게 하는 등 변호인의 조력을 받을 수 있다는 것\n② 검사 또는 사법경찰관은 제1항에 따라 알려준 때에는 피의자가 진술을 거부할 권리와 변호인의 조력을 받을 권리를 행사할 것인지의 여부를 질문하고, 이에 대한 피의자의 답변을 조서에 기재하여야 한다.',
    interp:'신문 전 반드시 고지 필수. 미고지 시 이후 모든 자백·진술의 증거능력 상실. 피의자의 답변 내용도 조서에 반드시 기재해야 함.',
    tags:['미란다원칙','진술거부권','묵비권','변호인조력권']
  },
  {
    id:'L002', act:'형사소송법', num:'제200조의2',
    name:'영장에 의한 체포',
    preview:'피의자가 죄를 범하였다고 의심할 만한 상당한 이유가 있고 정당한 이유 없이 출석요구에 응하지 아니하거나 응하지 아니할 우려가 있는 때에는 체포영장을 발부받아 체포할 수 있다.',
    full:'① 피의자가 죄를 범하였다고 의심할 만한 상당한 이유가 있고, 정당한 이유 없이 제200조의 규정에 의한 출석요구에 응하지 아니하거나 응하지 아니할 우려가 있는 때에는 검사는 관할 지방법원판사에게 청구하여 체포영장을 발부받아 피의자를 체포할 수 있고, 사법경찰관은 검사에게 신청하여 검사의 청구로 관할 지방법원판사의 체포영장을 발부받아 피의자를 체포할 수 있다.\n⑤ 체포한 피의자를 구속하고자 할 때에는 체포한 때부터 48시간 이내에 제201조의 규정에 의하여 구속영장을 청구하여야 하고, 그 기간 내에 구속영장을 청구하지 아니하는 때에는 피의자를 즉시 석방하여야 한다.',
    interp:'체포영장은 검사를 통해 판사에게 청구. 체포 후 48시간 이내 구속영장 청구 또는 석방 의무.',
    tags:['체포영장','48시간','구속영장']
  },
  {
    id:'L003', act:'형사소송법', num:'제309조',
    name:'강제 등 자백의 증거능력',
    preview:'피고인의 자백이 고문, 폭행, 협박, 신체구속의 부당한 장기화 또는 기망 기타의 방법으로 임의로 진술한 것이 아니라고 의심할 만한 이유가 있는 때에는 이를 유죄의 증거로 하지 못한다.',
    full:'피고인의 자백이 고문, 폭행, 협박, 신체구속의 부당한 장기화 또는 기망 기타의 방법으로 임의로 진술한 것이 아니라고 의심할 만한 이유가 있는 때에는 이를 유죄의 증거로 하지 못한다.',
    interp:'자백 배제 법칙. 강압·고문·협박·기망으로 얻은 자백은 증거능력 없음. 임의성 의심 시 즉시 배제 대상.',
    tags:['자백배제','임의성','증거능력','강압수사금지']
  },
  {
    id:'L004', act:'형사소송법', num:'제243조의2',
    name:'변호인의 피의자신문 참여권',
    preview:'검사 또는 사법경찰관은 피의자 또는 그 변호인·법정대리인 등의 신청이 있는 경우 정당한 사유가 없는 한 피의자에 대한 신문에 변호인을 참여하게 하여야 한다.',
    full:'① 검사 또는 사법경찰관은 피의자 또는 그 변호인·법정대리인·배우자·직계친족·형제자매의 신청에 따라 변호인을 피의자와 접견하게 하거나 정당한 사유가 없는 한 피의자에 대한 신문에 참여하게 하여야 한다.\n② 신문에 참여하고자 하는 변호인이 2인 이상인 때에는 피의자가 신문에 참여할 변호인 1인을 지정한다. 지정이 없는 경우에 검사 또는 사법경찰관이 이를 지정할 수 있다.\n③ 신문에 참여한 변호인은 신문 후 의견을 진술할 수 있다.',
    interp:'변호인 참여 신청 시 정당한 사유 없이 거부 불가. 참여 변호인은 신문 후 의견 진술 가능.',
    tags:['변호인','신문참여','변호인조력권']
  },
  {
    id:'L005', act:'형사소송법', num:'제218조',
    name:'영장에 의하지 아니한 압수',
    preview:'검사, 사법경찰관은 피의자 기타인의 유류한 물건이나 소유자, 소지자 또는 보관자가 임의로 제출한 물건을 영장 없이 압수할 수 있다.',
    full:'검사, 사법경찰관은 피의자 기타인의 유류한 물건이나 소유자, 소지자 또는 보관자가 임의로 제출한 물건을 영장 없이 압수할 수 있다.',
    interp:'임의 제출의 경우에만 영장 없이 압수 가능. 임의 제출 동의서 반드시 징구 필요. 동의 없는 영장 없는 압수는 위법.',
    tags:['압수','영장','임의제출','동의서']
  },
  {
    id:'L006', act:'헌법', num:'제12조',
    name:'신체의 자유 및 적법절차 원칙',
    preview:'모든 국민은 신체의 자유를 가진다. 누구든지 법률에 의하지 아니하고는 체포·구속·압수·수색 또는 심문을 받지 아니하며, 법률과 적법한 절차에 의하지 아니하고는 처벌·보안처분 또는 강제노역을 받지 아니한다.',
    full:'① 모든 국민은 신체의 자유를 가진다. 누구든지 법률에 의하지 아니하고는 체포·구속·압수·수색 또는 심문을 받지 아니하며, 법률과 적법한 절차에 의하지 아니하고는 처벌·보안처분 또는 강제노역을 받지 아니한다.\n② 모든 국민은 고문을 받지 아니하며, 형사상 자기에게 불리한 진술을 강요당하지 아니한다.\n③ 체포·구속·압수 또는 수색을 할 때에는 적법한 절차에 따라 검사의 신청에 의하여 법관이 발부한 영장을 제시하여야 한다.',
    interp:'모든 형사 절차의 헌법적 근거. 적법절차 원칙 위반 시 위헌. 제2항은 자백강요 금지의 헌법적 근거.',
    tags:['신체의자유','적법절차','영장주의','자백강요금지']
  },
  {
    id:'L007', act:'경찰관직무집행법', num:'제3조',
    name:'불심검문',
    preview:'경찰관은 수상한 거동 기타 주위의 사정을 합리적으로 판단하여 어떠한 죄를 범하였거나 범하려 하고 있다고 의심할 만한 상당한 이유가 있는 사람을 정지시켜 질문할 수 있다.',
    full:'① 경찰관은 수상한 거동 기타 주위의 사정을 합리적으로 판단하여 다음 각 호의 어느 하나에 해당함이 명백한 자를 정지시켜 질문할 수 있다.\n1. 수상한 거동 기타 주위의 사정을 합리적으로 판단하여 어떠한 죄를 범하였거나 범하려 하고 있다고 의심할 만한 상당한 이유가 있는 자\n2. 이미 행하여진 범죄나 행하여지려는 범죄행위에 관한 사실을 안다고 인정되는 자\n② 그 장소에서 제1항의 질문을 하는 것이 당해인에게 불리하거나 교통에 방해가 된다고 인정될 때에는 질문하기 위하여 가까운 경찰관서에 동행할 것을 요구할 수 있다.',
    interp:'불심검문은 임의동행 원칙. 강제연행 불가. 동행 거부 시 강제할 수 없음. 동행 시 즉시 귀가 가능 사실 고지 필수.',
    tags:['불심검문','임의동행','정지','질문']
  },
  {
    id:'L008', act:'형사소송법', num:'제201조의2',
    name:'구속 전 피의자 심문',
    preview:'검사가 제201조에 따라 피의자에 대한 구속영장을 청구한 경우 판사는 지체 없이 피의자를 심문하여야 한다.',
    full:'① 제200조의2·제200조의3 또는 제212조에 따라 체포된 피의자에 대하여 구속영장을 청구받은 판사는 지체 없이 피의자를 심문하여야 한다.\n② 제1항 외의 피의자에 대하여 구속영장을 청구받은 판사는 피의자가 죄를 범하였다고 의심할 만한 이유가 있는 경우에 구인을 위한 구속영장을 발부하여 피의자를 구인한 후 심문하여야 한다.',
    interp:'영장실질심사. 판사가 직접 피의자를 심문하는 절차. 피의자에게 변호인 선임 및 참여 기회 반드시 보장.',
    tags:['영장실질심사','구속전심문','구속영장']
  }
];

var recentSearches = ['미란다 원칙', '체포 후 48시간', '임의동행'];
var aiModeOn = false;
var currentLawId = null;

// ── 초기화 ───────────────────────────────────────────────────────
renderRecent();

function renderRecent() {
  var html = recentSearches.map(function(q) {
    return '<button class="recent-chip" onclick="searchBy(\'' + q + '\')">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>' + q + '</button>';
  }).join('');
  document.getElementById('recentRow').innerHTML = html;
}

function clearRecent() {
  recentSearches = [];
  renderRecent();
}

// ── AI 모드 토글 ─────────────────────────────────────────────────
function toggleAIMode() {
  aiModeOn = document.getElementById('aiToggle').checked;
  document.getElementById('lawSearchInput').placeholder = aiModeOn
    ? 'AI에게 법령 질문하기...' : '조문 번호 또는 키워드 검색...';
}

// ── 검색 ─────────────────────────────────────────────────────────
function searchBy(q) {
  document.getElementById('lawSearchInput').value = q;
  doSearch();
}

function doSearch() {
  var q = document.getElementById('lawSearchInput').value.trim();
  if (!q) return;

  // 최근 검색어 저장
  if (!recentSearches.includes(q)) {
    recentSearches.unshift(q);
    if (recentSearches.length > 5) recentSearches.pop();
    renderRecent();
  }

  document.getElementById('quickSection').style.display   = 'none';
  document.getElementById('recentSection').style.display  = 'none';
  document.getElementById('emptyState').style.display     = 'none';
  document.getElementById('resultSection').style.display  = 'none';

  if (aiModeOn) {
    // AI 모드 — Ollama로 법령 해석
    document.getElementById('aiCard').style.display = 'block';
    document.getElementById('aiBody').innerHTML =
      '<div class="ai-spinner"><div class="spinner-sm"></div><span style="font-size:12px;color:var(--text-muted);">Ollama 분석 중...</span></div>';
    callLawAI(q);
  } else {
    // ── 국가법령정보 API 호출 (LawApiServlet 경유) ──────────────
    document.getElementById('aiCard').style.display = 'block';
    document.getElementById('aiBody').innerHTML =
      '<div class="ai-spinner"><div class="spinner-sm"></div>' +
      '<span style="font-size:12px;color:var(--text-muted);">국가법령정보 검색 중...</span></div>';

    fetch('lawApi?query=' + encodeURIComponent(q) + '&target=law&display=10')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        document.getElementById('aiCard').style.display = 'none';

        // API 키 미설정 또는 오류 → 내장 DB 폴백
        if (!data.success || data.fallback) {
          searchLocalDb(q);
          return;
        }

        // API 응답 파싱
        // 응답 구조: data.data.LawSearch.law = [{법령명한글, 법령일련번호, ...}]
        try {
          var lawSearch = data.data.LawSearch;
          var laws = lawSearch.law;
          if (!laws) { searchLocalDb(q); return; }

          // 배열이 아닌 경우(결과 1건) 배열로 변환
          if (!Array.isArray(laws)) laws = [laws];

          document.getElementById('resultCount').textContent = (lawSearch.totalCnt || laws.length) + '건';
          document.getElementById('resultSection').style.display = 'block';

          if (laws.length === 0) {
            document.getElementById('emptyState').style.display = 'block';
            document.getElementById('resultSection').style.display = 'none';
          } else {
            renderApiLaws(laws);
          }
        } catch(e) {
          // JSON 파싱 실패 시 내장 DB로 폴백
          searchLocalDb(q);
        }
      })
      .catch(function() {
        document.getElementById('aiCard').style.display = 'none';
        // 서블릿 연결 실패 시 내장 DB 폴백
        searchLocalDb(q);
      });
  }
  window.scrollTo(0, 0);
}

// ── 내장 DB 검색 (폴백) ──────────────────────────────────────────
function searchLocalDb(q) {
  var results = LAW_DB.filter(function(l) {
    return l.name.includes(q) || l.num.includes(q) || l.act.includes(q) ||
           l.preview.includes(q) || l.tags.some(function(t) { return t.includes(q.replace(' ','')); });
  });
  document.getElementById('resultCount').textContent = results.length + '건 (내장 DB)';
  document.getElementById('resultSection').style.display = 'block';
  if (!results.length) {
    document.getElementById('emptyState').style.display = 'block';
    document.getElementById('resultSection').style.display = 'none';
  } else {
    renderLaws(results);
  }
}

// ── 국가법령정보 API 결과 렌더 ────────────────────────────────────
function renderApiLaws(laws) {
  var html = laws.map(function(l, i) {
    var lawName = l['법령명한글'] || l['법령명'] || '';
    var mst     = l['법령일련번호'] || '';
    var dept    = l['소관부처명'] || '';
    var date    = l['시행일자']   || '';
    return '<div class="law-card" style="animation-delay:' + (i*0.06) + 's" onclick="openApiLaw(\'' + mst + '\',\'' + escStr(lawName) + '\')">' +
      '<div class="law-card-top">' +
        '<div>' +
          '<div class="law-act">' + dept + '</div>' +
          '<div class="law-name">' + lawName + '</div>' +
        '</div>' +
      '</div>' +
      '<div class="law-preview">시행일: ' + date + '</div>' +
      '<div class="law-tags">' +
        '<span class="law-tag">국가법령정보 API</span>' +
      '</div>' +
    '</div>';
  }).join('');
  document.getElementById('lawList').innerHTML = html;
}

// ── 국가법령정보 API 법령 상세 조회 ──────────────────────────────
function openApiLaw(mst, lawName) {
  if (!mst) return;

  // 드로어 열고 로딩 상태 표시
  document.getElementById('drawerAct').textContent      = '국가법령정보';
  document.getElementById('drawerLawTitle').textContent = lawName;
  document.getElementById('drawerFullText').textContent = '조문 로딩 중...';
  document.getElementById('drawerInterpText').textContent = '';
  document.getElementById('aiExplainBox').style.display = 'none';
  document.getElementById('lawDrawer').classList.add('open');
  document.body.style.overflow = 'hidden';
  currentLawId = null; // API 조회 모드

  fetch('lawApi?query=' + encodeURIComponent(lawName) + '&mst=' + encodeURIComponent(mst))
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (!data.success || !data.contentData) {
        document.getElementById('drawerFullText').textContent = '조문 조회에 실패했습니다.';
        return;
      }
      try {
        // 법령 본문 파싱
        // 구조: contentData.법령.조문.조문내용 등 (API 버전마다 상이)
        var contentStr = JSON.stringify(data.contentData, null, 2);
        document.getElementById('drawerFullText').textContent = contentStr;
      } catch(e) {
        document.getElementById('drawerFullText').textContent = JSON.stringify(data.contentData);
      }
    })
    .catch(function() {
      document.getElementById('drawerFullText').textContent = '조문 조회 중 오류가 발생했습니다.';
    });
}

function escStr(s) { return (s||'').replace(/'/g, "\\'"); }

// ── 법령 렌더 ────────────────────────────────────────────────────
function renderLaws(list) {
  var html = list.map(function(l, i) {
    var tagsHtml = l.tags.map(function(t) { return '<span class="law-tag">' + t + '</span>'; }).join('');
    return '<div class="law-card" style="animation-delay:' + (i*0.06) + 's" onclick="openLaw(\'' + l.id + '\')">' +
      '<div class="law-card-top">' +
        '<div><div class="law-act">' + l.act + '</div><div class="law-name">' + l.num + ' ' + l.name + '</div></div>' +
      '</div>' +
      '<div class="law-preview">' + l.preview + '</div>' +
      '<div class="law-tags">' + tagsHtml + '</div>' +
    '</div>';
  }).join('');
  document.getElementById('lawList').innerHTML = html;
}

// ── 법령 상세 드로어 ─────────────────────────────────────────────
function openLaw(id) {
  var l = LAW_DB.find(function(x) { return x.id === id; });
  if (!l) return;
  currentLawId = id;
  document.getElementById('drawerAct').textContent       = l.act + ' ' + l.num;
  document.getElementById('drawerLawTitle').textContent  = l.name;
  document.getElementById('drawerFullText').textContent  = l.full;
  document.getElementById('drawerInterpText').textContent = l.interp;
  document.getElementById('aiExplainBox').style.display  = 'none';
  document.getElementById('lawDrawer').classList.add('open');
  document.body.style.overflow = 'hidden';
}

// ── AI 법령 해석 ─────────────────────────────────────────────────
function explainWithAI() {
  var l = LAW_DB.find(function(x) { return x.id === currentLawId; });
  if (!l) return;
  var box = document.getElementById('aiExplainBox');
  var txt = document.getElementById('aiExplainText');
  box.style.display = 'block';
  txt.innerHTML = '<div class="ai-spinner"><div class="spinner-sm"></div><span style="font-size:12px;color:var(--text-muted);">설명 생성 중...</span></div>';

  var prompt = '다음 법 조문을 현직 경찰 수사관이 실무에서 바로 적용할 수 있도록 쉽고 구체적으로 한국어로 설명해주세요.\n\n' +
    '[법령] ' + l.act + ' ' + l.num + ' ' + l.name + '\n\n' +
    '[조문]\n' + l.full + '\n\n' +
    '다음을 포함해 설명해주세요:\n1. 핵심 의미 (2줄 이내)\n2. 수사관이 주의해야 할 점\n3. 위반 시 결과\n4. 실무 적용 예시';

  callOllamaRaw(prompt, function(res) {
    txt.textContent = res;
  }, function() {
    txt.textContent = '(Ollama 미연결 — 실무 포인트를 참고하세요)\n\n' + l.interp;
  });
}

function callLawAI(q) {
  var prompt = '경찰 수사관의 질문에 관련 법령을 인용하여 한국어로 답변해주세요.\n\n질문: ' + q + '\n\n' +
    '다음을 포함해 답변하세요:\n1. 관련 법령 (법명 + 조문 번호)\n2. 조문 핵심 내용\n3. 실무 적용 방법\n4. 주의사항';
  callOllamaRaw(prompt, function(res) {
    document.getElementById('aiBody').textContent = res;
  }, function() {
    document.getElementById('aiBody').textContent =
      '(Ollama 미연결 — 키워드 검색 모드를 이용해 주세요)\n\n' +
      '관련 법령: 형사소송법 제244조의3 (진술거부권 고지)\n\n' +
      '수사관은 피의자 신문 전 반드시 다음을 고지해야 합니다:\n' +
      '- 진술을 거부할 권리 (묵비권)\n- 변호인 선임 및 조력을 받을 권리\n\n' +
      '미고지 시 이후 모든 진술의 증거능력이 부정될 수 있습니다.';
  });
}

function callOllamaRaw(prompt, onSuccess, onError) {
  fetch('http://localhost:11434/api/generate', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ model:'gemma3:1b', prompt:prompt, stream:false })
  })
  .then(function(r) { return r.json(); })
  .then(function(d) { onSuccess(d.response || '응답 없음'); })
  .catch(function() { onError(); });
}

function closeDrawer(id) {
  document.getElementById(id).classList.remove('open');
  document.body.style.overflow = '';
}
function closeOnBg(e, id) {
  if (e.target === document.getElementById(id)) closeDrawer(id);
}
</script>
</body>
</html>
