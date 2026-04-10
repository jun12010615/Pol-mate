<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String loginUser = (String) session.getAttribute("loginUser");
  if (loginUser == null) { response.sendRedirect("login.jsp"); return; }
  String userName = (String) session.getAttribute("userName");
  if (userName == null) userName = loginUser;
  // 알림에서 직접 진입 시 특정 보드 자동 오픈
  String paramCaseId = request.getParameter("caseId") != null ? request.getParameter("caseId") : "";
  // 단일따옴표 JS 문자열용 이스케이프 (스크립트 안에서 replace("'",...) 쓰면 파서/빌드 오류 유발)
  String bootCaseIdJs = paramCaseId.replace("\\", "\\\\").replace("'", "\\'").replace("\r", "").replace("\n", "\\n");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 보드 조회</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
:root{
    --deep:#0d1a33; --navy:#1a2744; --mid:#243358;
    --gold:#f0c040; --gold2:#e6b830;
    --blue:#4a7cdc; --accent:#4a7cdc; --danger:#dc2626;
    --tp:#1a1a2e; --ts:#6b7280; --tm:#9ca3af;
    --bg:#f0f2f8; --card:#ffffff; --bd:#e2e5ee;
    --success:#16a34a; --success-bg:#f0fdf4; --success-bd:#bbf7d0;
    --warn-bg:#fffbeb; --warn-text:#92400e;
    --danger-bg:#fef2f2; --danger-bd:#fecaca;
    --info-bg:#eff6ff; --info-text:#1e40af;
    --bnav:64px;
    --c-suspect:#dc2626; --c-victim:#f97316; --c-witness:#4a7cdc; --c-reference:#8b5cf6;
  }
html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
.screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

.top-header { background:var(--deep); padding:52px 20px 0; position:sticky; top:0; z-index:20; }
.header-row { display:flex; align-items:center; gap:12px; padding-bottom:16px; }
.back-btn { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
.back-btn svg { width:18px; height:18px; stroke:#fff; }
.header-text { flex:1; }
.header-title { font-size:17px; font-weight:500; color:#fff; }
.header-sub { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }
.header-gold-line { height:1.5px; background:linear-gradient(90deg,transparent,#f0c040 30%,#f0c040 70%,transparent); opacity:0.25; margin:0 -20px; }

.content { flex:1; overflow-y:auto; padding:20px 16px calc(var(--bnav) + 24px); }

/* 보드 카드 */
.board-card {
  background:var(--card); border-radius:16px; border:1px solid var(--bd);
  overflow:hidden; margin-bottom:12px; cursor:pointer;
  transition:border-color 0.15s; animation:fadeUp 0.35s ease both;
}
.board-card:active { border-color:var(--accent); }
.board-card-header {
  padding:14px 16px 10px;
  display:flex; align-items:flex-start; justify-content:space-between; gap:10px;
}
.board-case-id   { font-size:10px; color:var(--tm); margin-bottom:3px; }
.board-case-name { font-size:15px; font-weight:500; color:var(--tp); }
.board-badge { font-size:10px; padding:3px 9px; border-radius:20px; white-space:nowrap; flex-shrink:0; margin-top:2px; }
.badge-active { background:var(--success-bg); color:var(--success); }
.badge-done   { background:#eff6ff; color:#1e40af; }
.badge-warn   { background:var(--warn-bg); color:var(--warn-text); }
.badge-danger { background:var(--danger-bg); color:var(--danger); }
.board-meta-row {
  padding:10px 16px 14px;
  display:flex; align-items:center; justify-content:space-between;
  border-top:1px solid var(--bd); background:#fafbfd;
}
.board-meta-item { display:flex; align-items:center; gap:5px; font-size:11px; color:var(--ts); }
.board-meta-item svg { width:12px; height:12px; stroke:var(--tm); flex-shrink:0; }
.board-preview { padding:0 16px 14px; }
/* 미니 캔버스 */
.board-mini-canvas { background:#0d1a33; border-radius:10px; width:100%; }

/* 빈 상태 */
.empty-box { background:var(--card); border-radius:16px; border:1px solid var(--bd); padding:56px 20px; text-align:center; }
.empty-icon-wrap { width:60px; height:60px; border-radius:50%; background:#f0f3f9; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; }
.empty-icon-wrap svg { width:28px; height:28px; stroke:var(--ts); }
.empty-title { font-size:14px; font-weight:500; color:var(--tp); margin-bottom:6px; }
.empty-desc  { font-size:12px; color:var(--tm); line-height:1.7; }

/* 팝업 오버레이 (보드 상세) */
.detail-overlay {
  position:fixed; inset:0; background:rgba(0,0,0,0.6);
  z-index:300; display:none; align-items:flex-end; justify-content:center;
}
.detail-overlay.open { display:flex; }
.detail-sheet {
  background:var(--bg); border-radius:24px 24px 0 0;
  width:100%; max-width:420px; height:90vh;
  display:flex; flex-direction:column; animation:slideUp 0.3s ease both;
}
.detail-header {
  background:var(--navy); padding:16px 20px;
  display:flex; align-items:center; gap:12px; flex-shrink:0; border-radius:24px 24px 0 0;
}
.detail-title { flex:1; font-size:15px; font-weight:500; color:#fff; }
.detail-sub   { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }
.close-btn { width:32px; height:32px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
.close-btn svg { width:16px; height:16px; stroke:#fff; }
.detail-body { flex:1; overflow-y:auto; padding:16px; }
.detail-canvas-wrap { position:relative; background:#0d1a33; border-radius:14px; overflow:hidden; margin-bottom:12px; }
.canvas-toolbar { position:absolute; top:10px; right:10px; z-index:5; display:flex; flex-direction:column; gap:6px; }
.canvas-tool-btn { width:32px; height:32px; border-radius:8px; background:rgba(255,255,255,0.12); border:1px solid rgba(255,255,255,0.18); display:flex; align-items:center; justify-content:center; cursor:pointer; }
.canvas-tool-btn svg { width:15px; height:15px; stroke:#fff; }
.canvas-hint { position:absolute; bottom:10px; left:50%; transform:translateX(-50%); background:rgba(0,0,0,0.5); border-radius:20px; padding:5px 12px; font-size:10px; color:rgba(255,255,255,0.7); white-space:nowrap; pointer-events:none; }

/* 편집 이동 버튼 */
.btn-go-edit {
  width:100%; padding:14px; border-radius:12px; border:none;
  background:var(--accent); color:#fff; font-size:14px; font-weight:500;
  font-family:'Noto Sans KR',sans-serif; cursor:pointer;
  display:flex; align-items:center; justify-content:center; gap:7px;
  margin-top:4px;
}
.btn-go-edit svg { width:16px; height:16px; stroke:#fff; }

/* 하단 네비 */
.bottom-nav{
  position:fixed;bottom:0;left:50%;transform:translateX(-50%);
  width:100%;max-width:420px;height:var(--bnav);
  background:var(--card);border-top:1px solid var(--bd);
  display:flex;z-index:100;
}
.nav-item{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;text-decoration:none;color:var(--tm);cursor:pointer;border:none;background:none;font-family:'Noto Sans KR',sans-serif;}
.nav-item.active{color:var(--deep);}
.nav-item.active .nav-label{font-weight:600;}
.nav-icon{width:22px;height:22px;display:flex;align-items:center;justify-content:center;}
.nav-icon svg{width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;}
.nav-label{font-size:10px;}

@keyframes slideUp { from{transform:translateY(100%);opacity:0} to{transform:translateY(0);opacity:1} }
@keyframes fadeUp  { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
@media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }
</style>
</head>
<body>
<div class="screen">

  <div class="top-header">
    <div class="header-row">
      <button class="back-btn" onclick="location.href='main.jsp'">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <div class="header-text">
        <div class="header-title">보드 조회</div>
        <div class="header-sub">팀 사건 관계망 보드 목록</div>
      </div>
    </div>
    <div class="header-gold-line"></div>
  </div>

  <div class="content" id="boardListContent">
    <div style="text-align:center;padding:48px 0;font-size:13px;color:var(--tm);">불러오는 중...</div>
  </div>

      <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div><span class="nav-label">홈</span></a>
    <a href="myCase.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div><span class="nav-label">사건</span></a>
    <a href="askAI" class="nav-item"><div class="nav-icon"><svg width="22" height="22" viewBox="0 0 86 86" fill="none"><path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="currentColor" stroke-width="5"/><circle cx="43" cy="40" r="11" fill="none" stroke="currentColor" stroke-width="3"/><circle cx="43" cy="40" r="5" fill="currentColor"/><circle cx="43" cy="40" r="2.5" fill="white"/><circle cx="43" cy="22" r="2.8" fill="currentColor"/><circle cx="43" cy="58" r="2.8" fill="currentColor"/><circle cx="28" cy="40" r="2.8" fill="currentColor"/><circle cx="58" cy="40" r="2.8" fill="currentColor"/></svg></div><span class="nav-label">AI</span></a>
    <a href="board.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div><span class="nav-label">커뮤니티</span></a>
    <a href="mypage.jsp" class="nav-item"><div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div><span class="nav-label">마이페이지</span></a>
  </nav>
</div>

<!-- 보드 상세 팝업 -->
<div class="detail-overlay" id="detailOverlay">
  <div class="detail-sheet">
    <div class="detail-header">
      <button class="close-btn" onclick="closeDetail()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
      <div>
        <div class="detail-title" id="detailTitle"></div>
        <div class="detail-sub"  id="detailSub"></div>
      </div>
    </div>
    <div class="detail-body">
      <div class="detail-canvas-wrap" id="detailCanvasWrap">
        <div class="canvas-toolbar">
          <button class="canvas-tool-btn" onclick="dZoomIn()">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </button>
          <button class="canvas-tool-btn" onclick="dZoomOut()">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </button>
          <button class="canvas-tool-btn" onclick="dReset()">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.5"/></svg>
          </button>
        </div>
        <canvas id="detailCanvas" height="340"></canvas>
        <div class="canvas-hint">드래그로 이동 · 핀치로 확대/축소</div>
      </div>
      <button class="btn-go-edit" id="btnGoEdit" onclick="">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
        </svg>
        관계망 편집하러 가기
      </button>
    </div>
  </div>
</div>

<script>
var ROLE_COLOR = {suspect:'#dc2626',victim:'#f97316',witness:'#4a7cdc',reference:'#8b5cf6'};
var ROLE_LABEL = {suspect:'피의자',victim:'피해자',witness:'목격자',reference:'참고인'};
var REL_COLOR  = {accomplice:'#dc2626',harm:'#f97316',witness:'#4a7cdc',acquaint:'#9ca3af',family:'#16a34a'};
var REL_LABEL  = {accomplice:'공범',harm:'피해관계',witness:'목격',acquaint:'지인',family:'가족'};
var EDGE_MISMATCH_STROKE = '#f97316';

function normalizeRelTypeBV(r) {
  if (!r) return 'acquaint';
  var t = String(r).toLowerCase().trim();
  if (t.indexOf('|') >= 0) t = t.split('|')[0].trim();
  if (['accomplice','harm','witness','acquaint','family'].indexOf(t) >= 0) return t;
  var u = String(r);
  if (u.indexOf('공범') >= 0 || t.indexOf('accomplice') >= 0) return 'accomplice';
  if (u.indexOf('피해') >= 0 || t.indexOf('harm') >= 0) return 'harm';
  if (u.indexOf('목격') >= 0 || t.indexOf('witness') >= 0) return 'witness';
  if (u.indexOf('가족') >= 0 || t.indexOf('family') >= 0) return 'family';
  if (u.indexOf('지인') >= 0 || u.indexOf('지언') >= 0 || t.indexOf('acquaint') >= 0) return 'acquaint';
  return 'acquaint';
}
function normalizeEdgeStatusBV(s) {
  if (!s) return 'unknown';
  var raw = String(s).trim();
  var t = raw.toLowerCase();
  if (t.indexOf('|') >= 0) { t = t.split('|')[0].trim(); raw = raw.split('|')[0].trim(); }
  if (['match','mismatch','unknown'].indexOf(t) >= 0) return t;
  if (raw.indexOf('진술') >= 0 && raw.indexOf('불일치') >= 0) return 'mismatch';
  if (raw.indexOf('불일치') >= 0 || t.indexOf('mismatch') >= 0) return 'mismatch';
  if ((raw.indexOf('일치') >= 0 || t === 'match') && raw.indexOf('불일치') < 0) return 'match';
  return 'unknown';
}
function paintMismatchEdgeLabelBV(ctx, lx, ly, subText, sc, bgRgba) {
  sc = sc || 1;
  subText = String(subText || '').trim();
  var fzM = 10 * sc, fzS = 8 * sc, gap = 3 * sc, padX = 4 * sc, padY = 3 * sc;
  ctx.textAlign = 'center';
  var line1 = '진술 불일치';
  ctx.font = fzM + 'px Noto Sans KR,sans-serif';
  var w1 = ctx.measureText(line1).width;
  var w2 = 0;
  if (subText) {
    ctx.font = fzS + 'px Noto Sans KR,sans-serif';
    w2 = ctx.measureText(subText).width;
  }
  var tw = Math.max(w1, w2 || w1, 1);
  var innerH = subText ? fzM + gap + fzS : fzM;
  var boxH = innerH + 2 * padY;
  var y0 = ly - boxH / 2;
  ctx.fillStyle = bgRgba || 'rgba(10,20,50,0.75)';
  ctx.fillRect(lx - tw / 2 - padX, y0, tw + 2 * padX, boxH);
  ctx.fillStyle = 'rgba(255,255,255,0.92)';
  ctx.font = fzM + 'px Noto Sans KR,sans-serif';
  ctx.fillText(line1, lx, y0 + padY + fzM * 0.72);
  if (subText) {
    ctx.fillStyle = 'rgba(255,255,255,0.7)';
    ctx.font = fzS + 'px Noto Sans KR,sans-serif';
    ctx.fillText(subText, lx, y0 + padY + fzM + gap + fzS * 0.72);
  }
}
function edgeUndirectedKeyBV(e) {
  if (e.src < e.dst) return e.src + '\x1e' + e.dst;
  return e.dst + '\x1e' + e.src;
}
function groupEdgesByPairBV(allEdges) {
  var m = {};
  (allEdges || []).forEach(function(e) {
    var k = edgeUndirectedKeyBV(e);
    if (!m[k]) m[k] = [];
    m[k].push(e);
  });
  return m;
}
function mergeEdgeGroupForDrawBV(edgeList) {
  var anyMis = false;
  var orderLabs = [], seen = {};
  var nonMisLabs = [], seenNM = {};
  edgeList.forEach(function(e) {
    if (normalizeEdgeStatusBV(e.status) === 'mismatch') anyMis = true;
    var rt = normalizeRelTypeBV(e.relType);
    var lab = REL_LABEL[rt] || String(e.relType || '').trim();
    if (lab && !seen[lab]) { seen[lab] = true; orderLabs.push(lab); }
  });
  edgeList.forEach(function(e) {
    if (normalizeEdgeStatusBV(e.status) === 'mismatch') return;
    var rt = normalizeRelTypeBV(e.relType);
    var lab = REL_LABEL[rt] || String(e.relType || '').trim();
    if (lab && !seenNM[lab]) { seenNM[lab] = true; nonMisLabs.push(lab); }
  });
  var subMis = nonMisLabs.length ? nonMisLabs.join(' · ') : orderLabs.join(' · ');
  var rts = edgeList.map(function(e) { return normalizeRelTypeBV(e.relType); });
  var sameRt = rts.length && rts.every(function(rt) { return rt === rts[0]; });
  var strokeColor;
  if (anyMis) strokeColor = EDGE_MISMATCH_STROKE;
  else if (sameRt) strokeColor = REL_COLOR[rts[0]] || '#9ca3af';
  else strokeColor = '#9ca3af';
  return { anyMis: anyMis, subMis: subMis, lines: orderLabs, strokeColor: strokeColor, rep: edgeList[0] };
}
function paintMultilineRelLabelsBV(ctx, lx, ly, lines, sc, bgRgba) {
  if (!lines || !lines.length) return;
  sc = sc || 1;
  var fz = 10 * sc, gap = 2 * sc, padX = 4 * sc, padY = 3 * sc;
  ctx.textAlign = 'center';
  var maxW = 0;
  lines.forEach(function(line) {
    ctx.font = fz + 'px Noto Sans KR,sans-serif';
    maxW = Math.max(maxW, ctx.measureText(line).width);
  });
  var innerH = lines.length * fz + (lines.length - 1) * gap;
  var boxH = innerH + 2 * padY;
  var y0 = ly - boxH / 2;
  ctx.fillStyle = bgRgba || 'rgba(10,20,50,0.75)';
  ctx.fillRect(lx - maxW / 2 - padX, y0, maxW + 2 * padX, boxH);
  ctx.fillStyle = 'rgba(255,255,255,0.92)';
  lines.forEach(function(line, i) {
    ctx.font = fz + 'px Noto Sans KR,sans-serif';
    var y = y0 + padY + fz * 0.72 + i * (fz + gap);
    ctx.fillText(line, lx, y);
  });
}

// ── 보드 목록 로드 ────────────────────────────────────────────────
function loadBoardList() {
  fetch('boardApi?action=listBoards')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var el = document.getElementById('boardListContent');
      if (data.error) {
        el.innerHTML = '<div style="text-align:center;padding:40px;color:var(--danger);font-size:13px;">' + data.error + '</div>';
        return;
      }
      var boards = data.boards || [];
      if (!boards.length) {
        el.innerHTML =
          '<div class="empty-box">' +
            '<div class="empty-icon-wrap"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="8" cy="12" r="3"/><circle cx="18" cy="6" r="3"/><circle cx="18" cy="18" r="3"/><line x1="10.8" y1="10.7" x2="15.2" y2="7.3"/><line x1="10.8" y1="13.3" x2="15.2" y2="16.7"/></svg></div>' +
            '<div class="empty-title">저장된 보드가 없습니다</div>' +
            '<div class="empty-desc">사건 관계망에서 보드를 저장하면<br>여기서 바로 조회할 수 있습니다.</div>' +
          '</div>';
        return;
      }
      el.innerHTML = '';
      boards.forEach(function(b, i) {
        var statusBadge = '진행중'===b.status?'badge-active':'완료'===b.status?'badge-done':'모순탐지'===b.status?'badge-danger':'badge-warn';
        var card = document.createElement('div');
        card.className = 'board-card';
        card.style.animationDelay = (i*0.05) + 's';
        card.innerHTML =
          '<div class="board-card-header">' +
            '<div>' +
              '<div class="board-case-id">' + escHtml(b.caseId) + '</div>' +
              '<div class="board-case-name">' + escHtml(b.caseName) + '</div>' +
            '</div>' +
            '<span class="board-badge ' + statusBadge + '">' + escHtml(b.status) + '</span>' +
          '</div>' +
          '<div class="board-meta-row">' +
            '<div class="board-meta-item">' +
              '<svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>' +
              b.personCount + '명' +
            '</div>' +
            '<div class="board-meta-item">' +
              '<svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>' +
              b.edgeCount + '개' +
            '</div>' +
            '<div class="board-meta-item">' +
              '<svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>' +
              escHtml(b.updatedAt ? b.updatedAt.substring(0,10) : '') +
            '</div>' +
            '<div class="board-meta-item">' + escHtml(b.updaterName) + '</div>' +
          '</div>';
        (function(board) {
          card.addEventListener('click', function() { openDetail(board); });
        })(b);
        el.appendChild(card);
      });
    })
    .catch(function() {
      document.getElementById('boardListContent').innerHTML =
        '<div style="text-align:center;padding:40px;color:var(--danger);font-size:13px;">보드 목록을 불러오지 못했습니다.</div>';
    });
}

// ── 보드 상세 팝업 ────────────────────────────────────────────────
var detailPersons=[], detailEdges=[];
var dCanvas, dCtx, dScale=1, dOffsetX=0, dOffsetY=0, dDrag=false, dLastX=0, dLastY=0;

function openDetail(board) {
  // 팝업 먼저 열고 로딩 표시
  document.getElementById('detailTitle').textContent = board.caseId + ' ' + board.caseName;
  document.getElementById('detailSub').textContent   = '불러오는 중...';
  document.getElementById('btnGoEdit').onclick = function() {
    location.href = 'boardEdit.jsp?caseId=' + encodeURIComponent(board.caseId);
  };
  document.getElementById('detailOverlay').classList.add('open');
  document.body.style.overflow = 'hidden';
  dScale=1; dOffsetX=0; dOffsetY=0;

  // boardApi/load 로 boardJson 실시간 조회
  fetch('boardApi?action=load&caseId=' + encodeURIComponent(board.caseId))
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.error || !data.boardExists) {
        document.getElementById('detailSub').textContent = '보드 데이터가 없습니다.';
        detailPersons = []; detailEdges = [];
        initDetailCanvas(); resizeDetailCanvas(); drawDetailCanvas();
        return;
      }

      var bj;
      try { bj = JSON.parse(data.boardJson); } catch(e) { bj = {}; }

      detailPersons = (bj.persons || []).map(function(p) {
        var o = {id:uid(), name:p.name||'', role:p.role||'reference', memo:p.memo||''};
        var lx = Number(p.layoutX), ly = Number(p.layoutY);
        if (!isNaN(lx) && !isNaN(ly)) {
          o.layoutX = lx; o.layoutY = ly;
          o._x = lx; o._y = ly; o._vx = 0; o._vy = 0;
        }
        return o;
      }).filter(function(p){ return p.name; });

      detailEdges = (bj.edges || []).map(function(e) {
        var srcN = e.srcName || e.src || '';
        var dstN = e.dstName || e.dst || '';
        var sp = detailPersons.find(function(p){ return p.name === srcN; });
        var dp = detailPersons.find(function(p){ return p.name === dstN; });
        if (!sp || !dp) return null;
        return {id:uid(), src:sp.id, dst:dp.id,
                relType:e.relType||'acquaint', status:e.status||'unknown'};
      }).filter(Boolean);

      document.getElementById('detailSub').textContent =
        '인물 ' + detailPersons.length + '명 · 관계선 ' + detailEdges.length + '개 · ' +
        (data.updatedAt || board.updatedAt || '');

      setTimeout(function() { initDetailCanvas(); resizeDetailCanvas(); drawDetailCanvas(); }, 80);
    })
    .catch(function(err) {
      console.error('보드 상세 조회 실패:', err);
      document.getElementById('detailSub').textContent = '불러오기 실패 — 다시 시도해 주세요.';
      detailPersons = []; detailEdges = [];
      initDetailCanvas(); resizeDetailCanvas(); drawDetailCanvas();
    });
}

function closeDetail() {
  document.getElementById('detailOverlay').classList.remove('open');
  document.body.style.overflow = '';
}

function initDetailCanvas() {
  if (dCanvas) return;
  dCanvas = document.getElementById('detailCanvas');
  dCtx = dCanvas.getContext('2d');
  dCanvas.addEventListener('mousedown',  function(e){dDrag=true;dLastX=e.clientX;dLastY=e.clientY;});
  dCanvas.addEventListener('mousemove',  function(e){if(!dDrag)return;dOffsetX+=(e.clientX-dLastX)/dScale;dOffsetY+=(e.clientY-dLastY)/dScale;dLastX=e.clientX;dLastY=e.clientY;drawDetailCanvas();});
  dCanvas.addEventListener('mouseup',    function(){dDrag=false;});
  dCanvas.addEventListener('mouseleave', function(){dDrag=false;});
  var ltx,lty,ld;
  dCanvas.addEventListener('touchstart',function(e){if(e.touches.length===1){ltx=e.touches[0].clientX;lty=e.touches[0].clientY;}if(e.touches.length===2){ld=Math.hypot(e.touches[0].clientX-e.touches[1].clientX,e.touches[0].clientY-e.touches[1].clientY);}e.preventDefault();},{passive:false});
  dCanvas.addEventListener('touchmove',function(e){if(e.touches.length===1){dOffsetX+=(e.touches[0].clientX-ltx)/dScale;dOffsetY+=(e.touches[0].clientY-lty)/dScale;ltx=e.touches[0].clientX;lty=e.touches[0].clientY;drawDetailCanvas();}if(e.touches.length===2){var d=Math.hypot(e.touches[0].clientX-e.touches[1].clientX,e.touches[0].clientY-e.touches[1].clientY);dScale=Math.max(0.4,Math.min(2.5,dScale*d/ld));ld=d;drawDetailCanvas();}e.preventDefault();},{passive:false});
}

function resizeDetailCanvas() {
  var w = document.getElementById('detailCanvasWrap');
  if (!w||!dCanvas) return;
  var prevW = dCanvas.width, prevH = dCanvas.height;
  dCanvas.width=w.clientWidth; dCanvas.height=340;
  var allPos = detailPersons.length && detailPersons.every(function(p) {
    return typeof p._x === 'number' && typeof p._y === 'number' && !isNaN(p._x) && !isNaN(p._y);
  });
  if (allPos && prevW > 0 && (dCanvas.width !== prevW || dCanvas.height !== prevH)) {
    var sx = dCanvas.width / prevW, sy = dCanvas.height / prevH;
    detailPersons.forEach(function(p) {
      p._x *= sx; p._y *= sy;
      if (typeof p.layoutX === 'number') { p.layoutX = p._x; p.layoutY = p._y; }
    });
  }
  drawDetailCanvas();
}
// Force-directed 레이아웃 (boardView용)
function initDetailForce(w, h) {
  var cx = w/2, cy = h/2, n = detailPersons.length;
  var minDim = Math.min(w, h);
  var area = Math.max(w * h, 1);
  var k0 = Math.sqrt(area / Math.max(n, 1)) * 0.82;
  var r = Math.min(minDim * 0.36, k0 * Math.sqrt(Math.max(n, 2)) * 0.52);
  var jitter = k0 * 0.16;
  detailPersons.forEach(function(p, i) {
    var a = (2*Math.PI*i/n) - Math.PI/2;
    p._x = cx + Math.cos(a)*r + (Math.random()-0.5)*jitter;
    p._y = cy + Math.sin(a)*r + (Math.random()-0.5)*jitter;
    p._vx = 0; p._vy = 0;
  });
  if (n===1) { detailPersons[0]._x=cx; detailPersons[0]._y=cy; }
  for (var i=0; i<300; i++) runDetailForce(w, h);
}
function runDetailForce(w, h) {
  var n = detailPersons.length;
  if (n<2) return;
  var area = Math.max(w * h, 1);
  var k = Math.sqrt(area / n) * 0.82;
  var repK = k * k, attract = 0.052, pad = 52;
  var cx = w/2, cy = h/2, damping = 0.86, grav = 0.018, vmax = k * 0.38;
  detailPersons.forEach(function(p){ p._fx=0; p._fy=0; });
  for (var i=0; i<n; i++) {
    for (var j=i+1; j<n; j++) {
      var pi=detailPersons[i], pj=detailPersons[j];
      var dx=pi._x-pj._x, dy=pi._y-pj._y;
      var dist=Math.sqrt(dx*dx+dy*dy); if (dist<0.01) dist=0.01;
      var f=repK/dist;
      pi._fx+=dx/dist*f; pi._fy+=dy/dist*f;
      pj._fx-=dx/dist*f; pj._fy-=dy/dist*f;
    }
  }
  detailEdges.forEach(function(e){
    var sp=detailPersons.find(function(p){return p.id===e.src;}),
        dp=detailPersons.find(function(p){return p.id===e.dst;});
    if(!sp||!dp) return;
    var dx=dp._x-sp._x, dy=dp._y-sp._y;
    var dist=Math.sqrt(dx*dx+dy*dy); if (dist<0.01) dist=0.01;
    var f=attract*(dist-k);
    sp._fx+=dx/dist*f; sp._fy+=dy/dist*f;
    dp._fx-=dx/dist*f; dp._fy-=dy/dist*f;
  });
  detailPersons.forEach(function(p){
    p._fx+=(cx-p._x)*grav; p._fy+=(cy-p._y)*grav;
    p._vx=(p._vx+p._fx)*damping; p._vy=(p._vy+p._fy)*damping;
    var v = Math.sqrt(p._vx*p._vx + p._vy*p._vy);
    if (v > vmax && v > 0) { p._vx *= vmax/v; p._vy *= vmax/v; }
    p._x=Math.max(pad,Math.min(w-pad, p._x+p._vx));
    p._y=Math.max(pad,Math.min(h-pad, p._y+p._vy));
  });
}
function drawDetailCanvas() {
  if (!dCtx) return;
  var c=dCanvas, ctx=dCtx;
  ctx.clearRect(0,0,c.width,c.height);
  ctx.fillStyle='#0d1a33'; ctx.fillRect(0,0,c.width,c.height);
  if (!detailPersons.length) {
    ctx.fillStyle='rgba(255,255,255,0.3)'; ctx.font='13px Noto Sans KR,sans-serif';
    ctx.textAlign='center'; ctx.fillText('인물 정보가 없습니다', c.width/2, c.height/2);
    return;
  }
  var allSavedPos = detailPersons.every(function(p) {
    return typeof p._x === 'number' && typeof p._y === 'number' && !isNaN(p._x) && !isNaN(p._y);
  });
  if (!allSavedPos) {
    initDetailForce(c.width, c.height);
  } else {
    var pad = 52;
    detailPersons.forEach(function(p) {
      p._x = Math.max(pad, Math.min(c.width - pad, p._x));
      p._y = Math.max(pad, Math.min(c.height - pad, p._y));
    });
  }

  ctx.save();
  ctx.translate(dOffsetX*dScale, dOffsetY*dScale);
  ctx.scale(dScale, dScale);

  var pairMapBV = groupEdgesByPairBV(detailEdges);
  Object.keys(pairMapBV).forEach(function(pk) {
    var group = pairMapBV[pk];
    var idsB = pk.split('\x1e');
    var sp = detailPersons.find(function(p){return p.id===idsB[0];}),
        dp = detailPersons.find(function(p){return p.id===idsB[1];});
    if (!sp||!dp) return;
    var merged = mergeEdgeGroupForDrawBV(group);
    ctx.lineWidth=2; ctx.strokeStyle=merged.strokeColor;
    ctx.setLineDash([]);
    var mx=(sp._x+dp._x)/2, my=(sp._y+dp._y)/2;
    var dx=dp._x-sp._x, dy=dp._y-sp._y, len=Math.sqrt(dx*dx+dy*dy)||1;
    ctx.beginPath(); ctx.moveTo(sp._x,sp._y); ctx.lineTo(dp._x,dp._y);
    ctx.stroke(); ctx.setLineDash([]);
    var ang=Math.atan2(dp._y-sp._y,dp._x-sp._x);
    var nr=22, ax=dp._x-Math.cos(ang)*nr, ay=dp._y-Math.sin(ang)*nr;
    ctx.beginPath(); ctx.moveTo(ax,ay);
    ctx.lineTo(ax-9*Math.cos(ang-0.4),ay-9*Math.sin(ang-0.4));
    ctx.lineTo(ax-9*Math.cos(ang+0.4),ay-9*Math.sin(ang+0.4));
    ctx.closePath(); ctx.fillStyle=merged.strokeColor; ctx.fill(); ctx.setLineDash([]);
    var lx=mx, ly=my;
    var perpX=-(dy/len), perpY=dx/len;
    lx+=perpX*12; ly+=perpY*12;
    ctx.textAlign='center';
    if (merged.anyMis) {
      paintMismatchEdgeLabelBV(ctx,lx,ly,merged.subMis,1,'rgba(10,20,50,0.75)');
    } else if (merged.lines.length > 1) {
      paintMultilineRelLabelsBV(ctx,lx,ly,merged.lines,1,'rgba(10,20,50,0.75)');
    } else if (merged.lines.length === 1) {
      var label=merged.lines[0];
      ctx.font='10px Noto Sans KR,sans-serif';
      var tw=ctx.measureText(label).width;
      ctx.fillStyle='rgba(10,20,50,0.75)';
      ctx.beginPath();
      if(ctx.roundRect) ctx.roundRect(lx-tw/2-4,ly-9,tw+8,13,3);
      else ctx.rect(lx-tw/2-4,ly-9,tw+8,13);
      ctx.fill();
      ctx.fillStyle='#fff'; ctx.fillText(label,lx,ly);
    }
  });
  // 노드
  detailPersons.forEach(function(p){
    var nr=22;
    ctx.beginPath(); ctx.arc(p._x,p._y,nr,0,2*Math.PI);
    ctx.fillStyle=ROLE_COLOR[p.role]||'#4a7cdc'; ctx.fill();
    ctx.strokeStyle='#fff'; ctx.lineWidth=2.5; ctx.stroke();
    ctx.font='bold 11px Noto Sans KR,sans-serif';
    ctx.fillStyle='#fff'; ctx.textAlign='center';
    ctx.fillText(p.name.length>3?p.name.substr(0,3)+'…':p.name,p._x,p._y+4);
    ctx.font='9px Noto Sans KR,sans-serif'; ctx.fillStyle='rgba(255,255,255,0.75)';
    ctx.fillText(ROLE_LABEL[p.role]||'',p._x,p._y+nr+13);
  });
  ctx.restore();
}
function dZoomIn()  { dScale=Math.min(2.5,dScale+0.2); drawDetailCanvas(); }
function dZoomOut() { dScale=Math.max(0.4,dScale-0.2); drawDetailCanvas(); }
function dReset()   { dScale=1; dOffsetX=0; dOffsetY=0; drawDetailCanvas(); }

function uid() { return Math.random().toString(36).substr(2,9); }
function escHtml(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

loadBoardList();

// 알림에서 caseId 파라미터로 직접 진입 시 해당 보드 자동 오픈
(function() {
  var targetCaseId = '<%= bootCaseIdJs %>';
  if (!targetCaseId) return;
  // 보드 목록 로드 완료 후 해당 보드 자동 오픈
  var maxTry = 20, tried = 0;
  var timer = setInterval(function() {
    tried++;
    // loadBoardList에서 boards 변수가 채워질 때까지 대기
    var cards = document.querySelectorAll('.board-card');
    if (cards.length > 0) {
      clearInterval(timer);
      // caseId가 일치하는 카드 찾아서 클릭
      var found = false;
      cards.forEach(function(card) {
        var idEl = card.querySelector('.board-case-id');
        if (idEl && idEl.textContent.trim() === targetCaseId) {
          card.click();
          found = true;
        }
      });
      // 카드가 없으면 boardApi로 직접 로드
      if (!found) {
        fetch('boardApi?action=load&caseId=' + encodeURIComponent(targetCaseId))
          .then(function(r){ return r.json(); })
          .then(function(data){
            if (data.success && data.boardExists) {
              openDetail({
                caseId:   targetCaseId,
                caseName: data.caseName || '',
                updatedAt: data.updatedAt || ''
              });
            }
          })
          .catch(function(){});
      }
    } else if (tried >= maxTry) {
      clearInterval(timer);
    }
  }, 150);
})();
</script>
</body>
</html>
