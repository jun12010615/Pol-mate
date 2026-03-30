<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 알림</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  :root {
    --navy:#1a2744; --accent:#4a7cdc; --danger:#dc2626;
    --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
    --bg:#f4f6fb; --card:#fff; --border:#e5e7eb;
    --success:#16a34a; --success-bg:#f0fdf4;
    --warn-bg:#fffbeb; --warn-text:#92400e;
    --danger-bg:#fef2f2; --danger-border:#fecaca;
    --info-bg:#eff6ff; --info-text:#1e40af;
    --bottom-nav-h:64px;
  }
  html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
  .screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

  /* 헤더 */
  .top-header { background:var(--navy); padding:52px 20px 16px; position:sticky; top:0; z-index:10; }
  .header-row { display:flex; align-items:center; gap:12px; }
  .back-btn { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
  .back-btn svg { width:18px; height:18px; stroke:#fff; }
  .header-title { font-size:17px; font-weight:500; color:#fff; flex:1; }
  .btn-read-all { background:none; border:none; color:rgba(255,255,255,0.7); font-size:12px; font-family:'Noto Sans KR',sans-serif; cursor:pointer; white-space:nowrap; }
  .btn-read-all:hover { color:#fff; }

  /* 탭 */
  .tab-row { display:flex; border-top:1px solid rgba(255,255,255,0.1); margin-top:12px; }
  .tab-btn { flex:1; padding:11px 0; font-size:12px; color:rgba(255,255,255,0.5); background:none; border:none; cursor:pointer; font-family:'Noto Sans KR',sans-serif; border-bottom:2px solid transparent; transition:all 0.2s; }
  .tab-btn.active { color:#fff; border-bottom-color:#fff; font-weight:500; }

  /* 콘텐츠 */
  .content { flex:1; overflow-y:auto; padding-bottom:calc(var(--bottom-nav-h) + 16px); }

  .tab-panel { display:none; }
  .tab-panel.active { display:block; }

  /* 알림 그룹 */
  .notif-group { margin-bottom:4px; }
  .group-label { font-size:10px; font-weight:500; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.6px; padding:14px 16px 8px; }

  /* 알림 아이템 */
  .notif-item {
    background:var(--card); border-bottom:1px solid var(--border);
    padding:15px 16px; display:flex; gap:13px; align-items:flex-start;
    cursor:pointer; transition:background 0.15s; position:relative;
  }
  .notif-item:first-child { border-top:1px solid var(--border); }
  .notif-item.unread { background:#f8faff; }
  .notif-item:active { background:var(--bg); }

  /* 읽지 않음 점 */
  .unread-dot { position:absolute; top:18px; right:16px; width:7px; height:7px; border-radius:50%; background:var(--accent); }

  /* 아이콘 */
  .notif-icon { width:40px; height:40px; border-radius:12px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  .notif-icon svg { width:20px; height:20px; }
  .ni-red    { background:var(--danger-bg); }
  .ni-amber  { background:var(--warn-bg); }
  .ni-blue   { background:var(--info-bg); }
  .ni-green  { background:var(--success-bg); }
  .ni-gray   { background:#f3f4f6; }
  .ni-navy   { background:#f0f3f9; }

  .notif-body { flex:1; min-width:0; }
  .notif-title { font-size:13px; font-weight:500; color:var(--text-primary); margin-bottom:3px; line-height:1.4; }
  .notif-item.unread .notif-title { font-weight:700; }
  .notif-desc  { font-size:11px; color:var(--text-secondary); line-height:1.6; margin-bottom:4px; }
  .notif-time  { font-size:10px; color:var(--text-muted); }
  .notif-tag   { display:inline-block; font-size:10px; background:var(--bg); border:1px solid var(--border); border-radius:5px; padding:2px 7px; color:var(--text-muted); margin-bottom:4px; }

  /* 중요 알림 강조 */
  .notif-item.critical { border-left:3px solid var(--danger); }
  .notif-item.critical .notif-title { color:var(--danger); }

  /* 빈 상태 */
  .empty-state { padding:60px 20px; text-align:center; }
  .empty-icon  { width:64px; height:64px; background:var(--bg); border-radius:50%; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; border:1px solid var(--border); }
  .empty-icon svg { width:28px; height:28px; stroke:var(--text-muted); }
  .empty-title { font-size:14px; font-weight:500; color:var(--text-secondary); margin-bottom:6px; }
  .empty-desc  { font-size:12px; color:var(--text-muted); }

  /* 전체 읽음 처리 완료 토스트 */
  .toast {
    position:fixed; bottom:calc(var(--bottom-nav-h) + 16px); left:50%; transform:translateX(-50%);
    background:#1a1a2e; color:#fff; font-size:12px; padding:10px 20px; border-radius:20px;
    white-space:nowrap; z-index:300; opacity:0; transition:opacity 0.3s;
    font-family:'Noto Sans KR',sans-serif;
  }
  .toast.show { opacity:1; }

  /* 하단 네비 */
  .bottom-nav { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:420px; height:var(--bottom-nav-h); background:var(--card); border-top:1px solid var(--border); display:flex; justify-content:space-around; align-items:center; padding:0 8px; z-index:100; }
  .nav-item { display:flex; flex-direction:column; align-items:center; gap:3px; flex:1; cursor:pointer; text-decoration:none; padding:6px 0; }
  .nav-icon { width:24px; height:24px; display:flex; align-items:center; justify-content:center; }
  .nav-icon svg { width:22px; height:22px; }
  .nav-label { font-size:9px; }
  .nav-item.active .nav-icon svg { stroke:var(--navy); }
  .nav-item.active .nav-label    { color:var(--navy); font-weight:500; }
  .nav-item:not(.active) .nav-icon svg { stroke:var(--text-muted); }
  .nav-item:not(.active) .nav-label    { color:var(--text-muted); }

  @keyframes fadeUp { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
  @media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }
</style>
</head>
<body>
<div class="screen">

  <div class="top-header">
    <div class="header-row">
      <button class="back-btn" onclick="history.back()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <span class="header-title">알림 <span id="unreadBadge" style="font-size:12px; background:#ef4444; color:#fff; border-radius:10px; padding:1px 7px; margin-left:4px; vertical-align:middle;"></span></span>
      <button class="btn-read-all" onclick="markAllRead()">모두 읽음</button>
    </div>
    <div class="tab-row">
      <button class="tab-btn active" id="tabAll"  onclick="switchTab('all')">전체</button>
      <button class="tab-btn"        id="tabAlert" onclick="switchTab('alert')">경고</button>
      <button class="tab-btn"        id="tabCase"  onclick="switchTab('case')">사건</button>
      <button class="tab-btn"        id="tabSys"   onclick="switchTab('sys')">시스템</button>
    </div>
  </div>

  <div class="content" id="contentArea"></div>

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
    <a href="lawSearch.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
      <span class="nav-label">법전</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>
</div>

<div class="toast" id="toast">모든 알림을 읽음 처리했습니다</div>

<script>
// ── 임시 알림 데이터 (DB 연동 후 서블릿으로 교체) ─────────────────
var NOTIFS = [
  {
    id:1, type:'alert', unread:true, critical:true,
    icon:'ni-red',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="1.8" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>',
    tag:'모순 탐지',
    title:'진술 모순 탐지 — 즉시 확인 필요',
    desc:'사건 2024-0312(절도사건) 홍길동 진술에서 알리바이 불일치가 탐지되었습니다.',
    time:'방금 전', link:'voiceTranscript.jsp'
  },
  {
    id:2, type:'alert', unread:true, critical:true,
    icon:'ni-amber',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>',
    tag:'관계망',
    title:'변호인 고지 누락 경고',
    desc:'사건 2024-0255(협박사건) 진행 중 변호인 조력권 고지 여부가 확인되지 않았습니다.',
    time:'12분 전', link:'caseRelationMap.jsp'
  },
  {
    id:3, type:'case', unread:true, critical:false,
    icon:'ni-blue',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#1d4ed8" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>',
    tag:'조서',
    title:'조서 작성 완료 — 서명 필요',
    desc:'사건 2024-0289(폭행사건) 1차 조서 작성이 완료되었습니다. 피의자 서명이 필요합니다.',
    time:'1시간 전', link:'myCase.jsp'
  },
  {
    id:4, type:'case', unread:true, critical:false,
    icon:'ni-green',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="1.8" stroke-linecap="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>',
    tag:'관계망',
    title:'사건 2024-0271 관계망 확인',
    desc:'사기사건 인물 관계망을 확인하고 보드를 업데이트하세요.',
    time:'3시간 전', link:'caseRelationMap.jsp'
  },
  {
    id:5, type:'sys', unread:false, critical:false,
    icon:'ni-navy',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#1a2744" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>',
    tag:'시스템',
    title:'AI 모델 업데이트 완료',
    desc:'Ollama gemma3:1b 모델이 최신 버전으로 업데이트되었습니다. 응답 정확도가 향상되었습니다.',
    time:'어제', link:'askAI'
  },
  {
    id:6, type:'sys', unread:false, critical:false,
    icon:'ni-gray',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#6b7280" stroke-width="1.8" stroke-linecap="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>',
    tag:'보안',
    title:'로그인 보안 정책 안내',
    desc:'비밀번호 정기 변경 권고 주기(90일)가 도래했습니다. 마이페이지에서 변경해 주세요.',
    time:'2일 전', link:'mypage.jsp'
  },
  {
    id:7, type:'case', unread:false, critical:false,
    icon:'ni-blue',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#1d4ed8" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>',
    tag:'사건',
    title:'사건 2024-0230 신규 배정',
    desc:'마약사건이 담당 수사관으로 배정되었습니다. 초기 조사를 시작해 주세요.',
    time:'3일 전', link:'caseList.jsp'
  },
  {
    id:8, type:'sys', unread:false, critical:false,
    icon:'ni-gray',
    iconSvg:'<svg viewBox="0 0 24 24" fill="none" stroke="#6b7280" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93A10 10 0 1 0 4.93 19.07"/></svg>',
    tag:'시스템',
    title:'POL-MATE v1.0.0 출시',
    desc:'형사사법정보지원 시스템 POL-MATE가 정식 출시되었습니다. 주요 기능을 확인해 보세요.',
    time:'1주 전', link:'main.jsp'
  }
];

var currentTab = 'all';

function switchTab(tab) {
  currentTab = tab;
  ['all','alert','case','sys'].forEach(function(t) {
    document.getElementById('tab' + (t==='all'?'All':t==='alert'?'Alert':t==='case'?'Case':'Sys')).classList.toggle('active', t===tab);
  });
  render();
}

function render() {
  var list = currentTab === 'all' ? NOTIFS : NOTIFS.filter(function(n){ return n.type===currentTab; });

  if (!list.length) {
    document.getElementById('contentArea').innerHTML =
      '<div class="empty-state">' +
        '<div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></div>' +
        '<div class="empty-title">알림이 없습니다</div>' +
        '<div class="empty-desc">새로운 알림이 오면 여기에 표시됩니다</div>' +
      '</div>';
    return;
  }

  // 오늘 / 이전으로 그룹핑
  var todayItems = list.filter(function(n){ return ['방금 전','12분 전','1시간 전','3시간 전'].includes(n.time); });
  var pastItems  = list.filter(function(n){ return !['방금 전','12분 전','1시간 전','3시간 전'].includes(n.time); });

  var html = '';
  if (todayItems.length) {
    html += '<div class="notif-group"><div class="group-label">오늘</div>';
    todayItems.forEach(function(n){ html += renderItem(n); });
    html += '</div>';
  }
  if (pastItems.length) {
    html += '<div class="notif-group"><div class="group-label">이전</div>';
    pastItems.forEach(function(n){ html += renderItem(n); });
    html += '</div>';
  }
  document.getElementById('contentArea').innerHTML = html;
  updateBadge();
}

function renderItem(n) {
  return '<div class="notif-item' + (n.unread?' unread':'') + (n.critical?' critical':'') + '" onclick="readItem(' + n.id + ',\'' + n.link + '\')">' +
    (n.unread ? '<div class="unread-dot"></div>' : '') +
    '<div class="notif-icon ' + n.icon + '">' + n.iconSvg + '</div>' +
    '<div class="notif-body">' +
      '<div class="notif-tag">' + n.tag + '</div>' +
      '<div class="notif-title">' + n.title + '</div>' +
      '<div class="notif-desc">' + n.desc + '</div>' +
      '<div class="notif-time">' + n.time + '</div>' +
    '</div>' +
  '</div>';
}

function readItem(id, link) {
  var n = NOTIFS.find(function(x){ return x.id===id; });
  if (n) n.unread = false;
  updateBadge();
  location.href = link;
}

function markAllRead() {
  NOTIFS.forEach(function(n){ n.unread = false; });
  render();
  var t = document.getElementById('toast');
  t.classList.add('show');
  setTimeout(function(){ t.classList.remove('show'); }, 2000);
}

function updateBadge() {
  var cnt = NOTIFS.filter(function(n){ return n.unread; }).length;
  var el = document.getElementById('unreadBadge');
  el.textContent = cnt > 0 ? cnt : '';
  el.style.display = cnt > 0 ? '' : 'none';
}

render();
</script>
</body>
</html>
