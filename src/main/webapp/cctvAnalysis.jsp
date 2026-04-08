<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String userName  = (String) session.getAttribute("userName");
    if (loginUser == null) { response.sendRedirect("login.jsp"); return; }
    String userInitial = (userName != null && userName.length() > 0) ? String.valueOf(userName.charAt(0)) : "경";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 영상 분석</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  :root {
    --navy:#1a2744; --accent:#4a7cdc; --danger:#dc2626;
    --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
    --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
    --success:#16a34a; --success-bg:#f0fdf4;
    --bottom-nav-h:64px;
  }
  html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
  .screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

  /* 헤더 */
  .top-header { background:var(--navy); padding:52px 20px 16px; display:flex; align-items:center; gap:12px; flex-shrink:0; }
  .back-btn { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
  .back-btn svg { width:18px; height:18px; stroke:#fff; fill:none; stroke-width:2; stroke-linecap:round; }
  .header-title { font-size:16px; font-weight:500; color:#fff; flex:1; }
  .header-badge { font-size:10px; background:rgba(74,124,220,0.4); color:#93c5fd; border-radius:6px; padding:3px 8px; }

  /* 콘텐츠 */
  .content { flex:1; overflow-y:auto; padding:16px 16px calc(var(--bottom-nav-h) + 24px); display:flex; flex-direction:column; gap:14px; }

  /* 카드 */
  .card { background:var(--card); border-radius:16px; border:1px solid var(--border); padding:16px; }
  .card-title { font-size:13px; font-weight:600; color:var(--navy); margin-bottom:12px; display:flex; align-items:center; gap:7px; }
  .card-title svg { width:15px; height:15px; stroke:var(--navy); fill:none; stroke-width:2; stroke-linecap:round; }

  /* 영상 업로드 */
  .upload-zone {
    border:2px dashed var(--border); border-radius:12px; padding:28px 16px;
    text-align:center; cursor:pointer; transition:all 0.2s; background:var(--bg);
  }
  .upload-zone:hover { border-color:var(--accent); background:#eff6ff; }
  .upload-zone.has-file { border-color:var(--success); background:var(--success-bg); border-style:solid; }
  .upload-icon { width:40px; height:40px; background:var(--navy); border-radius:12px; margin:0 auto 10px; display:flex; align-items:center; justify-content:center; }
  .upload-icon svg { width:20px; height:20px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; }
  .upload-text { font-size:13px; font-weight:500; color:var(--text-primary); margin-bottom:4px; }
  .upload-sub  { font-size:11px; color:var(--text-muted); }
  .upload-filename { font-size:12px; font-weight:500; color:var(--success); margin-top:6px; }
  #videoInput { display:none; }

  /* 색상 선택 */
  .color-label { font-size:11px; color:var(--text-muted); font-weight:500; margin-bottom:7px; display:block; }
  .color-grid { display:grid; grid-template-columns:repeat(5, 1fr); gap:7px; }
  .color-chip {
    aspect-ratio:1; border-radius:10px; border:2px solid transparent;
    cursor:pointer; transition:all 0.15s; position:relative;
    display:flex; align-items:center; justify-content:center;
  }
  .color-chip.selected { border-color:var(--navy); transform:scale(1.12); }
  .color-chip.selected::after {
    content:'✓'; position:absolute; font-size:10px; font-weight:700;
    color:#fff; text-shadow:0 1px 2px rgba(0,0,0,0.6);
  }
  .color-none { background:var(--bg); border:1px solid var(--border); border-radius:10px; padding:6px; text-align:center; font-size:10px; color:var(--text-muted); cursor:pointer; transition:all 0.15s; }
  .color-none.selected { background:var(--navy); color:#fff; border-color:var(--navy); }

  /* 번호판 입력 */
  .plate-input {
    width:100%; padding:11px 14px; border:1px solid var(--border); border-radius:10px;
    font-size:14px; font-family:'Noto Sans KR',sans-serif; outline:none;
    color:var(--text-primary); background:var(--bg); letter-spacing:2px;
  }
  .plate-input:focus { border-color:var(--accent); background:#fff; }
  .plate-input::placeholder { color:var(--text-muted); letter-spacing:0; }
  .plate-hint { font-size:10px; color:var(--text-muted); margin-top:5px; }

  /* 분석 버튼 */
  .btn-analyze {
    width:100%; padding:14px; background:var(--navy); color:#fff; border:none;
    border-radius:12px; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif;
    cursor:pointer; transition:opacity 0.15s; display:flex; align-items:center; justify-content:center; gap:8px;
  }
  .btn-analyze:disabled { opacity:0.45; cursor:not-allowed; }
  .btn-analyze svg { width:16px; height:16px; stroke:#fff; fill:none; stroke-width:2; stroke-linecap:round; }

  /* 진행률 */
  .progress-wrap { display:none; flex-direction:column; gap:8px; }
  .progress-wrap.show { display:flex; }
  .progress-bar-bg { height:8px; background:var(--border); border-radius:4px; overflow:hidden; }
  .progress-bar-fill { height:100%; background:var(--accent); border-radius:4px; transition:width 0.4s; width:0%; }
  .progress-text { font-size:12px; color:var(--text-secondary); text-align:center; }

  /* 결과 */
  .result-wrap { display:none; flex-direction:column; gap:8px; }
  .result-wrap.show { display:flex; }
  .result-empty { text-align:center; padding:24px 0; font-size:13px; color:var(--text-muted); }
  .result-item {
    display:flex; align-items:flex-start; gap:10px;
    background:var(--bg); border:1px solid var(--border); border-radius:12px; padding:12px 14px;
    animation:fadeUp 0.3s ease both;
  }
  .result-item.person { border-left:3px solid var(--accent); }
  .result-item.vehicle { border-left:3px solid var(--success); }
  .result-icon { width:32px; height:32px; border-radius:9px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  .result-icon.person  { background:#eff6ff; }
  .result-icon.vehicle { background:var(--success-bg); }
  .result-icon svg { width:16px; height:16px; fill:none; stroke-width:1.8; stroke-linecap:round; }
  .result-icon.person  svg { stroke:var(--accent); }
  .result-icon.vehicle svg { stroke:var(--success); }
  .result-time { font-size:11px; font-weight:600; color:var(--navy); margin-bottom:2px; }
  .result-desc { font-size:12px; color:var(--text-secondary); }

  /* 요약 배너 */
  .summary-banner {
    background:var(--navy); border-radius:12px; padding:12px 14px;
    display:flex; align-items:center; gap:10px;
  }
  .summary-banner svg { width:16px; height:16px; stroke:#fff; fill:none; stroke-width:2; flex-shrink:0; }
  .summary-text { font-size:12px; color:#e2e8f0; line-height:1.6; }
  .summary-text strong { color:#fff; }

  /* 네비 */
  .bottom-nav { position:fixed; bottom:0; left:50%; transform:translateX(-50%); width:100%; max-width:420px; height:64px; background:#fff; border-top:1px solid #e2e5ee; display:flex; z-index:100; }
  .nav-item { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:3px; text-decoration:none; color:#9ca3af; cursor:pointer; border:none; background:none; font-family:'Noto Sans KR',sans-serif; }
  .nav-item.active { color:#0d1a33; }
  .nav-item.active .nav-label { font-weight:600; }
  .nav-icon { width:22px; height:22px; display:flex; align-items:center; justify-content:center; }
  .nav-icon svg { width:20px; height:20px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; }
  .nav-label { font-size:10px; }

  @keyframes fadeUp { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
  @keyframes spin { to{transform:rotate(360deg)} }
  .spinner { width:16px; height:16px; border:2px solid rgba(255,255,255,0.3); border-top-color:#fff; border-radius:50%; animation:spin 0.7s linear infinite; }
  @media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }
</style>
</head>
<body>
<div class="screen">

  <!-- 헤더 -->
  <div class="top-header">
    <button class="back-btn" onclick="history.back()">
      <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <div class="header-title">영상 분석</div>
    <span class="header-badge">AI 탐지</span>
  </div>

  <div class="content">

    <!-- 영상 업로드 -->
    <div class="card">
      <div class="card-title">
        <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="2"/><polygon points="10 8 16 12 10 16 10 8"/></svg>
        영상 파일 업로드
      </div>
      <div class="upload-zone" id="uploadZone" onclick="document.getElementById('videoInput').click()">
        <div class="upload-icon">
          <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
        </div>
        <div class="upload-text">영상 파일을 선택하세요</div>
        <div class="upload-sub">MP4, MOV, AVI 지원 · 최대 500MB</div>
        <div class="upload-filename" id="uploadFilename"></div>
      </div>
      <input type="file" id="videoInput" accept="video/*" onchange="onFileSelect(this)">
    </div>

    <!-- 인상착의 조건 -->
    <div class="card">
      <div class="card-title">
        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        인상착의 조건
      </div>

      <label class="color-label">상의 색상</label>
      <div class="color-grid" id="topColors"></div>
      <div class="color-none selected" id="topNone" onclick="selectColor('top', '', this)" style="margin-top:7px;">무관 (조건 없음)</div>

      <div style="margin-top:14px;"></div>
      <label class="color-label">하의 색상</label>
      <div class="color-grid" id="bottomColors"></div>
      <div class="color-none selected" id="bottomNone" onclick="selectColor('bottom', '', this)" style="margin-top:7px;">무관 (조건 없음)</div>
    </div>

    <!-- 번호판 조건 -->
    <div class="card">
      <div class="card-title">
        <svg viewBox="0 0 24 24"><rect x="1" y="6" width="22" height="12" rx="2"/><line x1="7" y1="10" x2="7" y2="14"/><line x1="12" y1="10" x2="12" y2="14"/><line x1="17" y1="10" x2="17" y2="14"/></svg>
        차량 번호판 (선택)
      </div>
      <input type="text" class="plate-input" id="plateInput" placeholder="예: 12가3456 (일부만 입력 가능)" maxlength="20">
      <div class="plate-hint">번호판 일부만 입력해도 검색됩니다. 비우면 번호판 조건 없이 분석합니다.</div>
    </div>

    <!-- 분석 시작 버튼 -->
    <button class="btn-analyze" id="analyzeBtn" onclick="startAnalysis()">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      분석 시작
    </button>

    <!-- 진행률 -->
    <div class="card progress-wrap" id="progressWrap">
      <div class="card-title">
        <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
        분석 중...
      </div>
      <div class="progress-bar-bg"><div class="progress-bar-fill" id="progressFill"></div></div>
      <div class="progress-text" id="progressText">영상을 분석하고 있습니다...</div>
    </div>

    <!-- 결과 -->
    <div class="card result-wrap" id="resultWrap">
      <div class="card-title">
        <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        분석 결과
      </div>
      <div class="summary-banner" id="summaryBanner" style="display:none;">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <div class="summary-text" id="summaryText"></div>
      </div>
      <div id="resultList"></div>
    </div>

  </div>

  <!-- 하단 네비 -->
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

<script>
var PYTHON_SERVER = 'http://113.198.238.110:5001';
var selectedFile = null;
var selectedTopColor = '';
var selectedBottomColor = '';
var pollTimer = null;

// 색상 목록
var COLORS = [
  { name:'검정', hex:'#1a1a1a' },
  { name:'흰색', hex:'#f5f5f5', border:true },
  { name:'회색', hex:'#9ca3af' },
  { name:'빨강', hex:'#ef4444' },
  { name:'파랑', hex:'#3b82f6' },
  { name:'초록', hex:'#22c55e' },
  { name:'노랑', hex:'#eab308' },
  { name:'갈색', hex:'#92400e' },
  { name:'주황', hex:'#f97316' },
  { name:'보라', hex:'#a855f7' },
];

// 색상 칩 렌더링
function renderColors() {
  ['top', 'bottom'].forEach(function(part) {
    var container = document.getElementById(part + 'Colors');
    COLORS.forEach(function(c) {
      var chip = document.createElement('div');
      chip.className = 'color-chip';
      chip.style.background = c.hex;
      if (c.border) chip.style.border = '2px solid #e5e7eb';
      chip.title = c.name;
      chip.onclick = (function(name, el) {
        return function() { selectColor(part, name, el); };
      })(c.name, chip);
      container.appendChild(chip);
    });
  });
}

function selectColor(part, name, el) {
  var isTop = part === 'top';
  var container = document.getElementById(part + 'Colors');
  var noneBtn = document.getElementById(part + 'None');

  // 모두 해제
  container.querySelectorAll('.color-chip').forEach(function(c) { c.classList.remove('selected'); });
  noneBtn.classList.remove('selected');

  if (name === '') {
    noneBtn.classList.add('selected');
  } else {
    el.classList.add('selected');
  }

  if (isTop) selectedTopColor = name;
  else selectedBottomColor = name;
}

function onFileSelect(input) {
  var file = input.files[0];
  if (!file) return;
  selectedFile = file;
  var zone = document.getElementById('uploadZone');
  zone.classList.add('has-file');
  document.getElementById('uploadFilename').textContent = '✓ ' + file.name + ' (' + (file.size / 1024 / 1024).toFixed(1) + 'MB)';
}

function startAnalysis() {
  if (!selectedFile) { alert('영상 파일을 먼저 선택해주세요.'); return; }
  if (!selectedTopColor && !selectedBottomColor && !document.getElementById('plateInput').value.trim()) {
    alert('인상착의 색상 또는 번호판 조건 중 하나 이상 입력해주세요.'); return;
  }

  var btn = document.getElementById('analyzeBtn');
  btn.disabled = true;
  btn.innerHTML = '<div class="spinner"></div> 업로드 중...';

  document.getElementById('progressWrap').classList.add('show');
  document.getElementById('resultWrap').classList.remove('show');
  document.getElementById('progressFill').style.width = '0%';
  document.getElementById('progressText').textContent = '영상을 서버에 업로드하는 중...';

  var formData = new FormData();
  formData.append('video', selectedFile);
  formData.append('colorTop', selectedTopColor);
  formData.append('colorBottom', selectedBottomColor);
  formData.append('plate', document.getElementById('plateInput').value.trim());

  fetch(PYTHON_SERVER + '/cctv/analyze', { method: 'POST', body: formData })
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (!d.success) { showError(d.error || '분석 시작 실패'); return; }
      btn.innerHTML = '<div class="spinner"></div> 분석 중...';
      document.getElementById('progressText').textContent = '영상을 프레임별로 분석하는 중...';
      pollStatus(d.jobId);
    })
    .catch(function(e) { showError('서버 연결 실패: ' + e.message); });
}

function pollStatus(jobId) {
  pollTimer = setInterval(function() {
    fetch(PYTHON_SERVER + '/cctv/status/' + jobId)
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (!d.success) { clearInterval(pollTimer); showError(d.error || '조회 실패'); return; }

        // 진행률 업데이트
        var pct = d.progress || 0;
        document.getElementById('progressFill').style.width = pct + '%';
        document.getElementById('progressText').textContent = '분석 중... ' + pct + '%';

        if (d.status === 'done') {
          clearInterval(pollTimer);
          showResults(d.results || []);
        } else if (d.status === 'error') {
          clearInterval(pollTimer);
          showError(d.error || '분석 중 오류 발생');
        }
      })
      .catch(function() { /* 네트워크 오류 무시 */ });
  }, 1500);
}

function showResults(results) {
  document.getElementById('progressWrap').classList.remove('show');
  document.getElementById('resultWrap').classList.add('show');

  var btn = document.getElementById('analyzeBtn');
  btn.disabled = false;
  btn.innerHTML = '<svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg> 다시 분석';

  // 요약 배너
  var banner = document.getElementById('summaryBanner');
  var summaryText = document.getElementById('summaryText');
  var personCount = results.filter(function(r) { return r.type === 'person'; }).length;
  var vehicleCount = results.filter(function(r) { return r.type === 'vehicle'; }).length;
  if (results.length > 0) {
    banner.style.display = 'flex';
    var parts = [];
    if (personCount > 0) parts.push('<strong>인물 ' + personCount + '건</strong>');
    if (vehicleCount > 0) parts.push('<strong>차량 ' + vehicleCount + '건</strong>');
    summaryText.innerHTML = '탐지 완료 · ' + parts.join(', ') + ' 발견';
  } else {
    banner.style.display = 'none';
  }

  // 결과 목록
  var list = document.getElementById('resultList');
  if (results.length === 0) {
    list.innerHTML = '<div class="result-empty">조건에 맞는 인물/차량을 찾지 못했습니다.<br>조건을 변경해 다시 시도해보세요.</div>';
    return;
  }
  list.innerHTML = '';
  results.forEach(function(r, i) {
    var isPerson = r.type === 'person';
    var item = document.createElement('div');
    item.className = 'result-item ' + r.type;
    item.style.animationDelay = (i * 0.05) + 's';
    item.innerHTML =
      '<div class="result-icon ' + r.type + '">' +
        (isPerson
          ? '<svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>'
          : '<svg viewBox="0 0 24 24"><rect x="1" y="6" width="22" height="12" rx="2"/><line x1="7" y1="10" x2="7" y2="14"/><line x1="12" y1="10" x2="12" y2="14"/><line x1="17" y1="10" x2="17" y2="14"/></svg>') +
      '</div>' +
      '<div>' +
        '<div class="result-time">' + r.timestamp + '</div>' +
        '<div class="result-desc">' + r.desc + '</div>' +
      '</div>';
    list.appendChild(item);
  });
}

function showError(msg) {
  document.getElementById('progressWrap').classList.remove('show');
  var btn = document.getElementById('analyzeBtn');
  btn.disabled = false;
  btn.innerHTML = '<svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg> 분석 시작';
  alert('오류: ' + msg);
}

renderColors();
</script>
</body>
</html>
