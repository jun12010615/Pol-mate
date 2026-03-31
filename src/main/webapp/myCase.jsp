<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 내 조서 관리</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  :root {
    --navy:#1a2744; --accent:#4a7cdc; --danger:#dc2626;
    --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
    --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
    --success:#16a34a; --success-bg:#f0fdf4; --success-border:#bbf7d0;
    --warn-bg:#fffbeb; --warn-text:#92400e;
    --danger-bg:#fef2f2; --danger-border:#fecaca;
    --info-bg:#eff6ff; --info-text:#1e40af;
    --bottom-nav-h:64px;
  }
  html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
  .screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

  /* ── 헤더 ── */
  .top-header { background:var(--navy); padding:52px 20px 0; position:sticky; top:0; z-index:10; }
  .header-row { display:flex; align-items:center; justify-content:space-between; padding-bottom:14px; }
  .header-title { font-size:17px; font-weight:500; color:#fff; }
  .btn-new {
    background:rgba(255,255,255,0.15); border:1px solid rgba(255,255,255,0.25);
    color:#fff; border-radius:20px; padding:7px 14px; font-size:12px;
    font-family:'Noto Sans KR',sans-serif; cursor:pointer; display:flex; align-items:center; gap:5px;
  }
  .btn-new svg { width:13px; height:13px; stroke:#fff; }

  /* 탭 */
  .tab-row { display:flex; border-top:1px solid rgba(255,255,255,0.1); }
  .tab-btn {
    flex:1; padding:12px 0; font-size:13px; font-weight:400;
    color:rgba(255,255,255,0.5); background:none; border:none;
    cursor:pointer; font-family:'Noto Sans KR',sans-serif;
    border-bottom:2px solid transparent; transition:all 0.2s;
  }
  .tab-btn.active { color:#fff; border-bottom-color:#fff; font-weight:500; }

  /* 검색 바 */
  .search-wrap { background:var(--navy); padding:0 16px 16px; }
  .search-box {
    background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.2);
    border-radius:12px; display:flex; align-items:center; gap:10px; padding:10px 14px;
  }
  .search-box svg { width:16px; height:16px; stroke:rgba(255,255,255,0.5); flex-shrink:0; }
  .search-input {
    flex:1; background:none; border:none; outline:none;
    font-size:13px; color:#fff; font-family:'Noto Sans KR',sans-serif;
  }
  .search-input::placeholder { color:rgba(255,255,255,0.4); }

  /* ── 콘텐츠 ── */
  .content { flex:1; overflow-y:auto; padding-bottom:calc(var(--bottom-nav-h) + 16px); }

  .tab-panel { display:none; }
  .tab-panel.active { display:block; }

  /* 필터 칩 */
  .filter-row {
    display:flex; gap:8px; padding:14px 16px 10px; overflow-x:auto;
    -ms-overflow-style:none; scrollbar-width:none;
  }
  .filter-row::-webkit-scrollbar { display:none; }
  .chip {
    flex-shrink:0; padding:6px 14px; border-radius:20px; font-size:12px;
    border:1px solid var(--border); background:var(--card); color:var(--text-secondary);
    cursor:pointer; white-space:nowrap; transition:all 0.15s; font-family:'Noto Sans KR',sans-serif;
  }
  .chip.active { background:var(--navy); color:#fff; border-color:var(--navy); }

  /* 사건 카드 */
  .case-list { padding:0 16px; display:flex; flex-direction:column; gap:10px; }

  .case-card {
    background:var(--card); border-radius:16px; border:1px solid var(--border);
    padding:16px; cursor:pointer; transition:border-color 0.2s;
    animation:fadeUp 0.3s ease both; text-decoration:none; display:block;
  }
  .case-card:active { background:var(--bg); }
  .case-card.urgent { border-left:3px solid var(--danger); }

  .case-top { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:10px; }
  .case-num  { font-size:12px; color:var(--text-muted); margin-bottom:3px; }
  .case-name { font-size:15px; font-weight:500; color:var(--text-primary); }

  .badge { font-size:10px; font-weight:500; padding:4px 10px; border-radius:20px; white-space:nowrap; flex-shrink:0; }
  .badge-warn   { background:var(--warn-bg);    color:var(--warn-text); }
  .badge-ok     { background:var(--success-bg); color:var(--success); }
  .badge-info   { background:var(--info-bg);    color:var(--info-text); }
  .badge-done   { background:#f3f4f6;            color:var(--text-muted); }
  .badge-danger { background:var(--danger-bg);  color:var(--danger); }

  .case-meta { display:flex; gap:14px; margin-bottom:10px; }
  .meta-item { display:flex; align-items:center; gap:5px; font-size:11px; color:var(--text-muted); }
  .meta-item svg { width:12px; height:12px; stroke:var(--text-muted); }

  .case-progress-wrap { display:flex; align-items:center; gap:10px; }
  .case-progress-bar  { flex:1; height:4px; background:var(--border); border-radius:2px; overflow:hidden; }
  .case-progress-fill { height:100%; border-radius:2px; transition:width 0.4s; }
  .fill-blue   { background:var(--accent); }
  .fill-green  { background:var(--success); }
  .fill-amber  { background:#f59e0b; }
  .case-progress-pct  { font-size:10px; color:var(--text-muted); white-space:nowrap; }

  /* 조서 리스트 (탭2) */
  .doc-card {
    background:var(--card); border-radius:14px; border:1px solid var(--border);
    margin:0 16px 10px; padding:15px 16px; display:flex; align-items:center; gap:14px;
    cursor:pointer; transition:background 0.15s; animation:fadeUp 0.3s ease both;
  }
  .doc-card:active { background:var(--bg); }
  .doc-icon { width:40px; height:40px; border-radius:12px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  .doc-icon svg { width:20px; height:20px; }
  .di-blue   { background:#eff6ff; }
  .di-green  { background:var(--success-bg); }
  .di-amber  { background:var(--warn-bg); }
  .di-gray   { background:#f3f4f6; }
  .doc-info  { flex:1; min-width:0; }
  .doc-title { font-size:13px; font-weight:500; color:var(--text-primary); margin-bottom:3px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .doc-meta  { font-size:11px; color:var(--text-muted); }
  .doc-right { display:flex; flex-direction:column; align-items:flex-end; gap:5px; }
  .doc-date  { font-size:10px; color:var(--text-muted); }

  /* 통계 헤더 (탭2) */
  .stats-strip {
    display:grid; grid-template-columns:repeat(3,1fr); gap:10px;
    padding:14px 16px 10px;
  }
  .stat-mini { background:var(--card); border-radius:12px; border:1px solid var(--border); padding:12px; text-align:center; }
  .stat-num  { font-size:20px; font-weight:700; color:var(--navy); }
  .stat-lbl  { font-size:10px; color:var(--text-muted); margin-top:2px; }

  /* 빈 상태 */
  .empty-state { padding:48px 20px; text-align:center; }
  .empty-icon  { width:60px; height:60px; background:var(--bg); border-radius:50%; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; }
  .empty-icon svg { width:28px; height:28px; stroke:var(--text-muted); }
  .empty-title { font-size:14px; font-weight:500; color:var(--text-secondary); margin-bottom:6px; }
  .empty-desc  { font-size:12px; color:var(--text-muted); }

  /* 섹션 라벨 */
  .section-label { font-size:10px; font-weight:500; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.6px; padding:14px 16px 8px; }

  /* ── 드로어: 사건 상세 ── */
  .overlay { position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:200; display:none; align-items:flex-end; justify-content:center; }
  .overlay.open { display:flex; }
  .drawer { background:var(--card); border-radius:20px 20px 0 0; width:100%; max-width:420px; padding:0 0 36px; animation:slideUp 0.28s ease both; max-height:88vh; overflow-y:auto; }
  .drawer-handle { width:36px; height:4px; background:var(--border); border-radius:2px; margin:12px auto 0; }
  .drawer-head   { padding:16px 20px; border-bottom:1px solid var(--border); }
  .drawer-title  { font-size:16px; font-weight:500; color:var(--text-primary); }
  .drawer-sub    { font-size:12px; color:var(--text-muted); margin-top:3px; }
  .drawer-body   { padding:16px 20px; }

  .detail-row { display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid var(--border); }
  .detail-row:last-child { border-bottom:none; }
  .detail-key { font-size:12px; color:var(--text-muted); }
  .detail-val { font-size:12px; font-weight:500; color:var(--text-primary); text-align:right; }

  .action-grid { display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-top:16px; }
  .action-btn {
    background:var(--bg); border:1px solid var(--border); border-radius:12px;
    padding:14px 10px; text-align:center; cursor:pointer; text-decoration:none; display:block;
    transition:background 0.15s;
  }
  .action-btn:active { background:var(--border); }
  .action-btn svg { width:20px; height:20px; display:block; margin:0 auto 6px; }
  .action-btn span { font-size:11px; color:var(--text-secondary); }
  .action-btn.primary { background:var(--navy); border-color:var(--navy); }
  .action-btn.primary svg { stroke:#fff; }
  .action-btn.primary span { color:#fff; }

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
  @media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }
</style>
</head>
<body>
<div class="screen">

  <!-- 헤더 -->
  <div class="top-header">
    <div class="header-row">
      <span class="header-title">내 조서 관리</span>
      <button class="btn-new" onclick="location.href='voiceTranscript.jsp'">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        새 조서
      </button>
    </div>
    <div class="tab-row">
      <button class="tab-btn active" id="tabCase" onclick="switchTab('case')">사건 목록</button>
      <button class="tab-btn"        id="tabDoc"  onclick="switchTab('doc')">조서 목록</button>
    </div>
    <div class="search-wrap">
      <div class="search-box">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" class="search-input" id="searchInput" placeholder="사건번호 또는 사건명 검색..." oninput="filterItems()">
      </div>
    </div>
  </div>

  <div class="content">

    <!-- ═══ 사건 목록 탭 ═══ -->
    <div class="tab-panel active" id="panelCase">

      <div class="filter-row">
        <button class="chip active" onclick="setFilter(this,'all')">전체</button>
        <button class="chip" onclick="setFilter(this,'검토필요')">검토필요</button>
        <button class="chip" onclick="setFilter(this,'진행중')">진행중</button>
        <button class="chip" onclick="setFilter(this,'완료')">완료</button>
        <button class="chip" onclick="setFilter(this,'모순탐지')">모순탐지</button>
      </div>

      <div class="case-list" id="caseList">
        <!-- JS로 렌더 -->
      </div>
    </div>

    <!-- ═══ 조서 목록 탭 ═══ -->
    <div class="tab-panel" id="panelDoc">

      <div class="stats-strip">
        <div class="stat-mini"><div class="stat-num">28</div><div class="stat-lbl">전체 조서</div></div>
        <div class="stat-mini"><div class="stat-num">5</div><div class="stat-lbl">작성중</div></div>
        <div class="stat-mini"><div class="stat-num">3</div><div class="stat-lbl">모순탐지</div></div>
      </div>

      <div class="section-label">최근 조서</div>
      <div id="docList">
        <!-- JS로 렌더 -->
      </div>
    </div>

  </div><!-- /content -->

  <!-- 하단 네비 -->
  <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
      <span class="nav-label">홈</span>
    </a>
    <a href="myCase.jsp" class="nav-item active">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
      <span class="nav-label">조서</span>
    </a>
    <a href="askAI" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg></div>
      <span class="nav-label">AI</span>
    </a>
    <a href="board.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
      <span class="nav-label">커뮤니티</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>
</div>

<!-- ═══ 사건 상세 드로어 ═══ -->
<div class="overlay" id="caseDrawer" onclick="closeOnBg(event,'caseDrawer')">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-head">
      <div class="drawer-title" id="drawerTitle">-</div>
      <div class="drawer-sub"   id="drawerSub">-</div>
    </div>
    <div class="drawer-body">
      <div id="drawerDetails"></div>
      <div class="action-grid" id="drawerActions"></div>
    </div>
  </div>
</div>

<script>
// ── 임시 데이터 (DB 연동 후 서블릿으로 교체) ─────────────────────
var CASES = [
  { id:'2024-0312', name:'절도사건', suspect:'홍길동', date:'2025.03.24', status:'검토필요', progress:75, urgent:true,  docs:3, stage:'조서 분석 완료' },
  { id:'2024-0289', name:'폭행사건', suspect:'김철수', date:'2025.03.21', status:'진행중',   progress:45, urgent:false, docs:2, stage:'조서 작성 중' },
  { id:'2024-0271', name:'사기사건', suspect:'이영희', date:'2025.03.18', status:'완료',     progress:100,urgent:false, docs:4, stage:'관계망 업데이트 완료' },
  { id:'2024-0255', name:'협박사건', suspect:'박민수', date:'2025.03.12', status:'모순탐지', progress:60, urgent:true,  docs:2, stage:'모순 항목 검토 필요' },
  { id:'2024-0244', name:'강도사건', suspect:'최수진', date:'2025.03.10', status:'완료',     progress:100,urgent:false, docs:5, stage:'최종 제출 완료' },
  { id:'2024-0230', name:'마약사건', suspect:'정태양', date:'2025.03.05', status:'진행중',   progress:30, urgent:false, docs:1, stage:'초기 조사 중' }
];

var DOCS = [
  { id:'D001', caseId:'2024-0312', title:'홍길동 1차 진술 조서', type:'피의자', date:'2025.03.24', status:'검토필요', words:1240 },
  { id:'D002', caseId:'2024-0312', title:'목격자 A 진술 조서',   type:'목격자', date:'2025.03.23', status:'완료',     words:820  },
  { id:'D003', caseId:'2024-0289', title:'김철수 1차 진술 조서', type:'피의자', date:'2025.03.21', status:'작성중',   words:560  },
  { id:'D004', caseId:'2024-0255', title:'박민수 2차 진술 조서', type:'피의자', date:'2025.03.14', status:'모순탐지', words:1580 },
  { id:'D005', caseId:'2024-0271', title:'이영희 최종 조서',     type:'피의자', date:'2025.03.18', status:'완료',     words:2100 },
  { id:'D006', caseId:'2024-0244', title:'강도사건 수사보고서',  type:'보고서', date:'2025.03.11', status:'완료',     words:3200 }
];

var currentFilter = 'all';
var currentTab    = 'case';

// ── 탭 전환 ──────────────────────────────────────────────────────
function switchTab(tab) {
  currentTab = tab;
  document.getElementById('panelCase').classList.toggle('active', tab === 'case');
  document.getElementById('panelDoc').classList.toggle('active',  tab === 'doc');
  document.getElementById('tabCase').classList.toggle('active',   tab === 'case');
  document.getElementById('tabDoc').classList.toggle('active',    tab === 'doc');
  document.getElementById('searchInput').value = '';
  filterItems();
}

// ── 필터 ─────────────────────────────────────────────────────────
function setFilter(el, val) {
  document.querySelectorAll('.chip').forEach(function(c) { c.classList.remove('active'); });
  el.classList.add('active');
  currentFilter = val;
  renderCases(CASES);
}

function filterItems() {
  var q = document.getElementById('searchInput').value.trim().toLowerCase();
  if (currentTab === 'case') {
    var filtered = CASES.filter(function(c) {
      var matchFilter = (currentFilter === 'all') || (c.status === currentFilter);
      var matchSearch = !q || c.id.toLowerCase().includes(q) || c.name.includes(q) || c.suspect.includes(q);
      return matchFilter && matchSearch;
    });
    renderCases(filtered);
  } else {
    var filtered2 = DOCS.filter(function(d) {
      return !q || d.title.includes(q) || d.caseId.toLowerCase().includes(q);
    });
    renderDocs(filtered2);
  }
}

// ── 사건 렌더 ────────────────────────────────────────────────────
function renderCases(list) {
  var html = '';
  if (!list.length) {
    html = '<div class="empty-state"><div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div><div class="empty-title">검색 결과가 없습니다</div><div class="empty-desc">다른 검색어나 필터를 사용해 보세요</div></div>';
    document.getElementById('caseList').innerHTML = html;
    return;
  }
  list.forEach(function(c, i) {
    var badgeCls = { '검토필요':'badge-warn', '진행중':'badge-ok', '완료':'badge-done', '모순탐지':'badge-danger' }[c.status] || 'badge-info';
    var fillCls  = c.progress === 100 ? 'fill-green' : (c.progress >= 60 ? 'fill-blue' : 'fill-amber');
    html += '<div class="case-card' + (c.urgent ? ' urgent' : '') + '" style="animation-delay:' + (i*0.05) + 's" onclick="openCase(\'' + c.id + '\')">' +
      '<div class="case-top">' +
        '<div><div class="case-num">' + c.id + '</div><div class="case-name">' + c.name + '</div></div>' +
        '<span class="badge ' + badgeCls + '">' + c.status + '</span>' +
      '</div>' +
      '<div class="case-meta">' +
        '<div class="meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>' + c.suspect + '</div>' +
        '<div class="meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>' + c.date + '</div>' +
        '<div class="meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>조서 ' + c.docs + '건</div>' +
      '</div>' +
      '<div class="case-progress-wrap">' +
        '<div class="case-progress-bar"><div class="case-progress-fill ' + fillCls + '" style="width:' + c.progress + '%"></div></div>' +
        '<span class="case-progress-pct">' + c.progress + '%</span>' +
      '</div>' +
    '</div>';
  });
  document.getElementById('caseList').innerHTML = html;
}

// ── 조서 렌더 ────────────────────────────────────────────────────
function renderDocs(list) {
  var html = '';
  list.forEach(function(d, i) {
    var iconCls  = { '피의자':'di-blue', '목격자':'di-green', '참고인':'di-amber', '보고서':'di-gray' }[d.type] || 'di-gray';
    var strokeCl = { '피의자':'#1d4ed8', '목격자':'#15803d', '참고인':'#b45309', '보고서':'#6b7280' }[d.type] || '#6b7280';
    var badgeCls = { '검토필요':'badge-warn', '완료':'badge-done', '작성중':'badge-ok', '모순탐지':'badge-danger' }[d.status] || 'badge-info';
    html += '<div class="doc-card" style="animation-delay:' + (i*0.05) + 's">' +
      '<div class="doc-icon ' + iconCls + '"><svg viewBox="0 0 24 24" fill="none" stroke="' + strokeCl + '" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></div>' +
      '<div class="doc-info">' +
        '<div class="doc-title">' + d.title + '</div>' +
        '<div class="doc-meta">' + d.caseId + ' · ' + d.type + ' · ' + d.words.toLocaleString() + '자</div>' +
      '</div>' +
      '<div class="doc-right">' +
        '<span class="badge ' + badgeCls + '">' + d.status + '</span>' +
        '<span class="doc-date">' + d.date + '</span>' +
      '</div>' +
    '</div>';
  });
  if (!html) html = '<div class="empty-state"><div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg></div><div class="empty-title">조서가 없습니다</div><div class="empty-desc">새 조서를 작성해 보세요</div></div>';
  document.getElementById('docList').innerHTML = html;
}

// ── 사건 상세 드로어 ─────────────────────────────────────────────
function openCase(id) {
  var c = CASES.find(function(x) { return x.id === id; });
  if (!c) return;
  document.getElementById('drawerTitle').textContent = c.id + ' ' + c.name;
  document.getElementById('drawerSub').textContent   = c.stage;
  var badgeCls = { '검토필요':'badge-warn', '진행중':'badge-ok', '완료':'badge-done', '모순탐지':'badge-danger' }[c.status] || '';
  document.getElementById('drawerDetails').innerHTML =
    '<div class="detail-row"><span class="detail-key">피의자</span><span class="detail-val">' + c.suspect + '</span></div>' +
    '<div class="detail-row"><span class="detail-key">최종 수정</span><span class="detail-val">' + c.date + '</span></div>' +
    '<div class="detail-row"><span class="detail-key">진행률</span><span class="detail-val">' + c.progress + '%</span></div>' +
    '<div class="detail-row"><span class="detail-key">조서 수</span><span class="detail-val">' + c.docs + '건</span></div>' +
    '<div class="detail-row"><span class="detail-key">상태</span><span class="detail-val"><span class="badge ' + badgeCls + '">' + c.status + '</span></span></div>';
  document.getElementById('drawerActions').innerHTML =
    '<a href="voiceTranscript.jsp" class="action-btn primary">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" y1="19" x2="12" y2="23"/><line x1="8" y1="23" x2="16" y2="23"/></svg>' +
      '<span>조서 추가</span>' +
    '</a>' +
    '<a href="caseRelationMap.jsp" class="action-btn">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="var(--navy)" stroke-width="1.8" stroke-linecap="round"><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="5" r="2.5"/><circle cx="18" cy="19" r="2.5"/><line x1="8.4" y1="11.0" x2="15.6" y2="6.5"/><line x1="8.4" y1="13.0" x2="15.6" y2="17.5"/></svg>' +
      '<span>관계망 보기</span>' +
    '</a>' +
    '<a href="voiceTranscript.jsp" class="action-btn">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="var(--navy)" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>' +
      '<span>모순 분석</span>' +
    '</a>' +
    '<button class="action-btn" onclick="closeDrawer(\'caseDrawer\')" style="border:none; cursor:pointer;">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" stroke-width="1.8" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
      '<span>닫기</span>' +
    '</button>';
  document.getElementById('caseDrawer').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeDrawer(id) {
  document.getElementById(id).classList.remove('open');
  document.body.style.overflow = '';
}
function closeOnBg(e, id) {
  if (e.target === document.getElementById(id)) closeDrawer(id);
}

// 초기 렌더
renderCases(CASES);
renderDocs(DOCS);
</script>
</body>
</html>
