<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 모순탐지 목록</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  :root {
    --navy:#1a2744; --navy-light:#243358; --accent:#4a7cdc;
    --danger:#e74c3c; --danger-bg:#fef2f2; --danger-border:#fecaca;
    --success:#16a34a; --success-bg:#f0fdf4;
    --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
    --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
    --warn-bg:#fffbeb; --warn-text:#92400e;
    --bottom-nav-h:64px;
  }
  html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }

  .screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

  /* ── 헤더 ── */
  .top-header {
    background:var(--navy); padding:52px 20px 16px;
    position:sticky; top:0; z-index:10;
    display:flex; align-items:center; gap:12px;
  }
  .back-btn {
    width:36px; height:36px; border-radius:50%;
    background:rgba(255,255,255,0.12); border:none;
    display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0;
  }
  .back-btn svg { width:18px; height:18px; stroke:#fff; }
  .header-text { flex:1; }
  .header-title { font-size:16px; font-weight:500; color:#fff; }
  .header-sub   { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }

  /* ── 필터 탭 ── */
  .filter-bar {
    background:var(--navy);
    padding:0 16px 14px;
    display:flex; gap:8px;
  }
  .filter-btn {
    padding:6px 14px; border-radius:20px; border:none; cursor:pointer;
    font-size:12px; font-family:'Noto Sans KR',sans-serif;
    background:rgba(255,255,255,0.12); color:rgba(255,255,255,0.65);
    transition:all 0.2s;
  }
  .filter-btn.active { background:#fff; color:var(--navy); font-weight:500; }

  /* ── 스크롤 콘텐츠 ── */
  .content { flex:1; overflow-y:auto; padding:16px 16px calc(var(--bottom-nav-h)+20px); }

  /* ── 요약 배너 ── */
  .summary-card {
    background:var(--card); border-radius:14px; border:1px solid var(--border);
    padding:16px 20px; margin-bottom:14px;
    display:flex; align-items:center; gap:16px;
  }
  .summary-stat { text-align:center; flex:1; }
  .summary-num  { font-size:22px; font-weight:700; color:var(--navy); }
  .summary-lbl  { font-size:10px; color:var(--text-muted); margin-top:2px; }
  .summary-num.red { color:var(--danger); }
  .summary-divider { width:1px; height:36px; background:var(--border); }

  /* ── 리스트 아이템 ── */
  .list-item {
    background:var(--card); border-radius:14px; border:1px solid var(--border);
    padding:16px; margin-bottom:10px; cursor:pointer;
    transition:transform 0.15s, box-shadow 0.15s;
    animation:fadeUp 0.3s ease both;
  }
  .list-item:active { transform:scale(0.99); box-shadow:none; }
  .list-item.has-contra { border-left:3px solid var(--danger); }
  .list-item.no-contra  { border-left:3px solid var(--success); }

  .item-header { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
  .item-badge {
    font-size:10px; padding:3px 8px; border-radius:20px; white-space:nowrap; flex-shrink:0;
    font-weight:500;
  }
  .badge-contra { background:var(--danger-bg); color:var(--danger); }
  .badge-clean  { background:var(--success-bg); color:var(--success); }

  .item-case {
    font-size:10px; color:var(--text-muted); margin-left:auto;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:120px;
  }

  .item-name  { font-size:14px; font-weight:500; color:var(--text-primary); margin-bottom:4px; }
  .item-meta  { font-size:11px; color:var(--text-muted); display:flex; align-items:center; gap:8px; }
  .meta-dot   { width:3px; height:3px; border-radius:50%; background:var(--border); }

  .item-preview {
    font-size:11px; color:var(--text-secondary); margin-top:8px;
    padding-top:8px; border-top:1px solid var(--border);
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
    line-height:1.6;
  }

  .item-arrow {
    position:absolute; right:16px; top:50%; transform:translateY(-50%);
    width:16px; height:16px; stroke:var(--text-muted);
  }

  .list-item { position:relative; }

  /* ── 빈 상태 ── */
  .empty-state {
    text-align:center; padding:60px 20px;
    animation:fadeUp 0.35s ease both;
  }
  .empty-icon {
    width:60px; height:60px; border-radius:50%;
    background:#f3f4f6; margin:0 auto 16px;
    display:flex; align-items:center; justify-content:center;
  }
  .empty-icon svg { width:26px; height:26px; stroke:var(--text-muted); }
  .empty-title { font-size:15px; font-weight:500; color:var(--text-primary); margin-bottom:8px; }
  .empty-desc  { font-size:12px; color:var(--text-muted); line-height:1.7; }
  .empty-btn {
    margin-top:20px; display:inline-block; padding:10px 24px;
    background:var(--navy); color:#fff; border-radius:12px;
    font-size:13px; text-decoration:none; font-family:'Noto Sans KR',sans-serif;
  }

  /* ── 상세 드로어 ── */
  .overlay {
    position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:200;
    display:none; align-items:flex-end; justify-content:center;
  }
  .overlay.open { display:flex; }

  .drawer {
    background:var(--card); border-radius:20px 20px 0 0;
    width:100%; max-width:420px; padding:0 0 32px;
    animation:slideUp 0.28s ease both; max-height:88vh; overflow-y:auto;
  }
  .drawer-handle {
    width:36px; height:4px; background:var(--border);
    border-radius:2px; margin:12px auto 0;
  }
  .drawer-header {
    padding:16px 20px; border-bottom:1px solid var(--border);
    display:flex; align-items:center; justify-content:space-between;
  }
  .drawer-title { font-size:15px; font-weight:500; color:var(--text-primary); }
  .drawer-close {
    width:28px; height:28px; border-radius:50%; border:none;
    background:var(--bg); cursor:pointer;
    display:flex; align-items:center; justify-content:center;
  }
  .drawer-close svg { width:14px; height:14px; stroke:var(--text-secondary); }

  .drawer-body { padding:20px; }

  .detail-badge {
    display:inline-flex; align-items:center; gap:6px;
    padding:6px 14px; border-radius:20px; font-size:12px; font-weight:500;
    margin-bottom:16px;
  }
  .detail-badge.contra { background:var(--danger-bg); color:var(--danger); }
  .detail-badge.clean  { background:var(--success-bg); color:var(--success); }
  .detail-badge svg { width:12px; height:12px; }

  .detail-section { margin-bottom:16px; }
  .detail-label {
    font-size:10px; font-weight:500; color:var(--text-muted);
    text-transform:uppercase; letter-spacing:0.6px; margin-bottom:6px;
  }
  .detail-value {
    font-size:13px; color:var(--text-primary); line-height:1.65;
    background:var(--bg); border-radius:10px; padding:12px 14px;
    white-space:pre-wrap; word-break:break-all;
  }

  .detail-meta-row {
    display:flex; gap:8px; flex-wrap:wrap; margin-bottom:16px;
  }
  .detail-chip {
    font-size:11px; color:var(--text-secondary); background:var(--bg);
    border:1px solid var(--border); border-radius:20px; padding:4px 10px;
  }

  .btn-delete {
    width:100%; padding:13px; border-radius:12px;
    background:var(--danger-bg); border:1px solid var(--danger-border);
    color:var(--danger); font-size:13px; font-weight:500;
    font-family:'Noto Sans KR',sans-serif; cursor:pointer;
    display:flex; align-items:center; justify-content:center; gap:7px;
    margin-top:6px;
  }
  .btn-delete svg { width:14px; height:14px; stroke:var(--danger); }

  /* ── 하단 네비 ── */
  .bottom-nav {
    position:fixed; bottom:0; left:50%; transform:translateX(-50%);
    width:100%; max-width:420px; height:64px;
    background:#ffffff; border-top:1px solid #e2e5ee;
    display:flex; z-index:100;
  }
  .nav-item { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:3px; text-decoration:none; color:#9ca3af; cursor:pointer; border:none; background:none; font-family:'Noto Sans KR',sans-serif; }
  .nav-item.active { color:#0d1a33; }
  .nav-item.active .nav-label { font-weight:600; }
  .nav-icon { width:22px; height:22px; display:flex; align-items:center; justify-content:center; }
  .nav-icon svg { width:20px; height:20px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; }
  .nav-label { font-size:10px; }

  /* ── 로딩 ── */
  .loading-wrap { text-align:center; padding:48px 20px; color:var(--text-muted); font-size:13px; }
  .spinner {
    width:28px; height:28px; border:2px solid var(--border);
    border-top-color:var(--accent); border-radius:50%;
    animation:spin 0.7s linear infinite; margin:0 auto 12px;
  }

  /* ── 토스트 ── */
  .toast {
    position:fixed; bottom:80px; left:50%; transform:translateX(-50%);
    background:var(--navy); color:#fff; padding:10px 20px; border-radius:20px;
    font-size:13px; opacity:0; transition:opacity 0.3s; z-index:500; white-space:nowrap;
  }
  .toast.show { opacity:1; }

  @keyframes fadeUp   { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  @keyframes slideUp  { from { transform:translateY(100%); opacity:0; } to { transform:translateY(0); opacity:1; } }
  @keyframes spin     { to { transform:rotate(360deg); } }

  @media (min-width:421px) {
    .screen { box-shadow:0 0 40px rgba(0,0,0,0.1); }
    .drawer { max-width:420px; }
  }
</style>
</head>
<body>

<%
  HttpSession sess = request.getSession(false);
  if (sess == null || sess.getAttribute("loginUser") == null) {
      response.sendRedirect("login.jsp"); return;
  }
%>

<div class="screen">

  <!-- ── 헤더 ── -->
  <div class="top-header">
    <button class="back-btn" onclick="history.back()">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
        <polyline points="15 18 9 12 15 6"/>
      </svg>
    </button>
    <div class="header-text">
      <div class="header-title">모순탐지 목록</div>
      <div class="header-sub">저장된 AI 모순탐지 결과</div>
    </div>
  </div>

  <!-- ── 필터 탭 ── -->
  <div class="filter-bar">
    <button class="filter-btn active" id="filterAll"     onclick="setFilter('all',this)">전체</button>
    <button class="filter-btn"        id="filterContra"  onclick="setFilter('contra',this)">모순 탐지</button>
    <button class="filter-btn"        id="filterClean"   onclick="setFilter('clean',this)">이상 없음</button>
  </div>

  <!-- ── 스크롤 콘텐츠 ── -->
  <div class="content">

    <!-- 요약 카드 -->
    <div class="summary-card" id="summaryCard" style="display:none;">
      <div class="summary-stat">
        <div class="summary-num" id="summaryTotal">0</div>
        <div class="summary-lbl">전체</div>
      </div>
      <div class="summary-divider"></div>
      <div class="summary-stat">
        <div class="summary-num red" id="summaryContra">0</div>
        <div class="summary-lbl">모순 탐지</div>
      </div>
      <div class="summary-divider"></div>
      <div class="summary-stat">
        <div class="summary-num" id="summaryClean">0</div>
        <div class="summary-lbl">이상 없음</div>
      </div>
    </div>

    <!-- 리스트 -->
    <div id="listArea">
      <div class="loading-wrap">
        <div class="spinner"></div>
        불러오는 중...
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
      <span class="nav-label">사건</span>
    </a>
    <a href="askAI" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg></div>
      <span class="nav-label">AI</span>
    </a>
    <a href="board.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
      <span class="nav-label">커뮤니티</span>
    </a>
    <a href="mypage.jsp" class="nav-item active">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>

</div><!-- /screen -->

<!-- ── 상세 드로어 ── -->
<div class="overlay" id="detailOverlay" onclick="closeDetailIfOutside(event)">
  <div class="drawer" id="detailDrawer">
    <div class="drawer-handle"></div>
    <div class="drawer-header">
      <div class="drawer-title" id="drawerTitle">탐지 결과 상세</div>
      <button class="drawer-close" onclick="closeDetail()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
          <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
      </button>
    </div>
    <div class="drawer-body" id="drawerBody">
      <!-- 동적으로 채워짐 -->
    </div>
  </div>
</div>

<!-- ── 토스트 ── -->
<div class="toast" id="toast"></div>

<script>
var allData     = [];
var currentFilter = 'all';
var currentResultId = null;

// ── 초기 로드 ─────────────────────────────────────────────
window.addEventListener('DOMContentLoaded', function() {
  loadList();
});

function loadList() {
  document.getElementById('listArea').innerHTML =
    '<div class="loading-wrap"><div class="spinner"></div>불러오는 중...</div>';

  fetch('contradictionApi?action=list')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.error) {
        document.getElementById('listArea').innerHTML =
          '<div class="empty-state"><div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div><div class="empty-title">불러오기 실패</div><div class="empty-desc">' + esc(data.error) + '</div></div>';
        return;
      }
      allData = Array.isArray(data) ? data : [];
      updateSummary();
      renderList();
    })
    .catch(function() {
      document.getElementById('listArea').innerHTML =
        '<div class="empty-state"><div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg></div><div class="empty-title">오류 발생</div><div class="empty-desc">서버에 연결할 수 없습니다.</div></div>';
    });
}

// ── 요약 업데이트 ─────────────────────────────────────────
function updateSummary() {
  var total  = allData.length;
  var contra = allData.filter(function(d) { return d.hasContradiction; }).length;
  var clean  = total - contra;

  document.getElementById('summaryTotal').textContent  = total;
  document.getElementById('summaryContra').textContent = contra;
  document.getElementById('summaryClean').textContent  = clean;
  document.getElementById('summaryCard').style.display = total > 0 ? 'flex' : 'none';
}

// ── 필터 ─────────────────────────────────────────────────
function setFilter(type, btn) {
  currentFilter = type;
  document.querySelectorAll('.filter-btn').forEach(function(b) { b.classList.remove('active'); });
  btn.classList.add('active');
  renderList();
}

// ── 렌더 ─────────────────────────────────────────────────
function renderList() {
  var filtered = allData.filter(function(d) {
    if (currentFilter === 'contra') return  d.hasContradiction;
    if (currentFilter === 'clean')  return !d.hasContradiction;
    return true;
  });

  if (filtered.length === 0) {
    var msg = currentFilter === 'contra' ? '모순이 탐지된 결과가 없습니다.' :
              currentFilter === 'clean'  ? '이상 없음 결과가 없습니다.' :
              '저장된 모순탐지 결과가 없습니다.';
    document.getElementById('listArea').innerHTML =
      '<div class="empty-state">' +
        '<div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>' +
        '<div class="empty-title">결과 없음</div>' +
        '<div class="empty-desc">' + msg + '</div>' +
        (currentFilter === 'all' ? '<a href="voiceTranscript.jsp" class="empty-btn">모순탐지 시작하기</a>' : '') +
      '</div>';
    return;
  }

  var html = filtered.map(function(d, idx) {
    var isContra  = d.hasContradiction;
    var badgeCls  = isContra ? 'badge-contra' : 'badge-clean';
    var badgeTxt  = isContra ? '모순 탐지' : '이상 없음';
    var itemCls   = isContra ? 'has-contra' : 'no-contra';
    var stmtLabel = (d.stmtName || '진술자 미입력') + (d.stmtType ? ' · ' + d.stmtType : '');
    var caseTxt   = d.caseId ? (d.caseId + (d.caseName ? ' ' + d.caseName : '')) : '사건 미연결';
    var preview   = (d.aiResult || '').substring(0, 100);

    return '<div class="list-item ' + itemCls + '" onclick="openDetail(' + d.resultId + ')" style="animation-delay:' + (idx * 0.04) + 's">' +
      '<div class="item-header">' +
        '<span class="item-badge ' + badgeCls + '">' + badgeTxt + '</span>' +
        '<span class="item-case">' + esc(caseTxt) + '</span>' +
      '</div>' +
      '<div class="item-name">' + esc(stmtLabel) + '</div>' +
      '<div class="item-meta">' +
        '<span>' + esc(d.createdAt) + '</span>' +
      '</div>' +
      (preview ? '<div class="item-preview">' + esc(preview) + '…</div>' : '') +
      '<svg class="item-arrow" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>' +
    '</div>';
  }).join('');

  document.getElementById('listArea').innerHTML = html;
}

// ── 상세 드로어 열기 ──────────────────────────────────────
function openDetail(resultId) {
  currentResultId = resultId;
  document.getElementById('drawerBody').innerHTML =
    '<div class="loading-wrap"><div class="spinner"></div>불러오는 중...</div>';
  document.getElementById('detailOverlay').classList.add('open');

  fetch('contradictionApi?action=detail&resultId=' + resultId)
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.error) {
        document.getElementById('drawerBody').innerHTML =
          '<p style="color:var(--danger);font-size:13px;">' + esc(d.error) + '</p>';
        return;
      }
      renderDetail(d);
    })
    .catch(function() {
      document.getElementById('drawerBody').innerHTML =
        '<p style="color:var(--danger);font-size:13px;">오류가 발생했습니다.</p>';
    });
}

function renderDetail(d) {
  var isContra  = d.hasContradiction;
  var badgeCls  = isContra ? 'contra' : 'clean';
  var badgeTxt  = isContra ? '모순 항목이 탐지되었습니다' : '명확한 모순이 탐지되지 않았습니다';
  var badgeIcon = isContra
    ? '<path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>'
    : '<polyline points="20 6 9 17 4 12"/>';

  document.getElementById('drawerTitle').textContent = (d.stmtName || '진술') + ' 탐지 결과';

  var html =
    '<div class="detail-badge ' + badgeCls + '">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">' + badgeIcon + '</svg>' +
      badgeTxt +
    '</div>' +
    '<div class="detail-meta-row">' +
      (d.caseId ? '<span class="detail-chip">📁 ' + esc(d.caseId) + (d.caseName ? ' ' + esc(d.caseName) : '') + '</span>' : '') +
      (d.stmtName ? '<span class="detail-chip">👤 ' + esc(d.stmtName) + '</span>' : '') +
      (d.stmtType ? '<span class="detail-chip">' + esc(d.stmtType) + '</span>' : '') +
      '<span class="detail-chip">🗓 ' + esc(d.createdAt) + '</span>' +
    '</div>';

  if (d.stmtText) {
    html +=
      '<div class="detail-section">' +
        '<div class="detail-label">진술 텍스트</div>' +
        '<div class="detail-value" style="max-height:120px;overflow-y:auto;">' + esc(d.stmtText) + '</div>' +
      '</div>';
  }

  html +=
    '<div class="detail-section">' +
      '<div class="detail-label">AI 분석 결과</div>' +
      '<div class="detail-value" style="max-height:200px;overflow-y:auto;">' + esc(d.aiResult) + '</div>' +
    '</div>' +
    '<button class="btn-delete" onclick="deleteResult(' + d.resultId + ')">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>' +
      '이 결과 삭제하기' +
    '</button>';

  document.getElementById('drawerBody').innerHTML = html;
}

function closeDetail() {
  document.getElementById('detailOverlay').classList.remove('open');
  currentResultId = null;
}

function closeDetailIfOutside(e) {
  if (e.target === document.getElementById('detailOverlay')) closeDetail();
}

// ── 삭제 ─────────────────────────────────────────────────
function deleteResult(resultId) {
  if (!confirm('이 모순탐지 결과를 삭제하시겠습니까?\n삭제 후 복구할 수 없습니다.')) return;

  var params = new URLSearchParams();
  params.append('action', 'delete');
  params.append('resultId', resultId);

  fetch('contradictionApi', { method:'POST', body:params })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.success) {
        closeDetail();
        allData = allData.filter(function(d) { return d.resultId !== resultId; });
        updateSummary();
        renderList();
        showToast('삭제되었습니다.');
      } else {
        alert(data.error || '삭제에 실패했습니다.');
      }
    })
    .catch(function() { alert('오류가 발생했습니다.'); });
}

// ── 유틸 ─────────────────────────────────────────────────
function esc(s) {
  if (s == null) return '';
  return String(s)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
    .replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(function() { t.classList.remove('show'); }, 2500);
}
</script>
</body>
</html>
