<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 사건 관계망</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<style>
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
:root {
  --deep:#0d1a33; --navy:#1a2744; --mid:#243358;
  --gold:#f0c040;
  --blue:#4a7cdc; --danger:#dc2626;
  --tp:#1a1a2e; --ts:#6b7280; --tm:#9ca3af;
  --bg:#f0f2f8; --card:#ffffff; --bd:#e2e5ee;
  --success:#16a34a; --success-bg:#f0fdf4;
  --warn-bg:#fffbeb; --warn-text:#92400e;
  --danger-bg:#fef2f2; --danger-bd:#fecaca;
  --bnav:64px;

  /* 관계 색상 */
  --c-suspect:#dc2626;
  --c-victim:#f97316;
  --c-witness:#4a7cdc;
  --c-reference:#8b5cf6;

  /* 관계선 색상 */
  --r-accomplice:#dc2626;
  --r-harm:#f97316;
  --r-witness:#4a7cdc;
  --r-acquaint:#9ca3af;
  --r-family:#16a34a;
}
html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
.screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

/* ── 헤더 ── */
.top-header { background:var(--deep); padding:52px 20px 0; position:sticky; top:0; z-index:20; }
.header-row { display:flex; align-items:center; gap:12px; padding-bottom:16px; }
.back-btn { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.12); border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
.back-btn svg { width:18px; height:18px; stroke:#fff; }
.header-text { flex:1; }
.header-title { font-size:16px; font-weight:500; color:#fff; }
.header-sub { font-size:10px; color:rgba(255,255,255,0.5); margin-top:2px; }
.header-gold-line { height:1.5px; background:linear-gradient(90deg,transparent,var(--gold) 30%,var(--gold) 70%,transparent); opacity:0.25; margin:0 -20px; }

/* ── 사건 선택 바 ── */
.case-select-bar { background:var(--deep); padding:12px 20px 16px; }
.case-select-wrap { display:flex; gap:8px; align-items:center; }
.case-select {
  flex:1; padding:10px 14px; background:rgba(255,255,255,0.08);
  border:1px solid rgba(255,255,255,0.15); border-radius:12px;
  font-size:13px; color:#fff; font-family:'Noto Sans KR',sans-serif;
  outline:none; appearance:none;
}
.case-select option { background:var(--navy); color:#fff; }
.btn-new-board {
  padding:10px 14px; background:var(--gold); border:none; border-radius:12px;
  font-size:12px; font-weight:500; color:var(--deep); cursor:pointer;
  font-family:'Noto Sans KR',sans-serif; white-space:nowrap; flex-shrink:0;
}

/* ── 콘텐츠 ── */
.content { flex:1; overflow-y:auto; padding:16px 16px calc(var(--bnav) + 20px); }

/* ── 카드 공통 ── */
.card { background:var(--card); border-radius:16px; border:1px solid var(--bd); padding:16px; margin-bottom:12px; }
.card-title { font-size:11px; font-weight:500; color:var(--ts); text-transform:uppercase; letter-spacing:0.6px; margin-bottom:12px; display:flex; align-items:center; gap:7px; }
.card-title svg { width:13px; height:13px; stroke:var(--tm); flex-shrink:0; }

/* ── 빈 상태 ── */
.empty-state { text-align:center; padding:40px 20px; }
.empty-icon { width:56px; height:56px; background:#e8edf5; border-radius:50%; margin:0 auto 14px; display:flex; align-items:center; justify-content:center; }
.empty-icon svg { width:26px; height:26px; stroke:var(--ts); }
.empty-title { font-size:14px; font-weight:500; color:var(--tp); margin-bottom:6px; }
.empty-desc { font-size:12px; color:var(--tm); line-height:1.7; }

/* ── 캔버스 관계망 ── */
.canvas-wrap {
  position:relative; width:100%; background:var(--deep);
  border-radius:16px; overflow:hidden; border:1px solid var(--bd);
  margin-bottom:12px;
}
.canvas-toolbar {
  position:absolute; top:10px; right:10px; z-index:5;
  display:flex; flex-direction:column; gap:6px;
}
.canvas-tool-btn {
  width:32px; height:32px; border-radius:8px;
  background:rgba(255,255,255,0.12); border:1px solid rgba(255,255,255,0.18);
  display:flex; align-items:center; justify-content:center;
  cursor:pointer; color:#fff; font-size:14px; font-weight:700;
}
.canvas-tool-btn:active { background:rgba(255,255,255,0.22); }
.canvas-tool-btn svg { width:15px; height:15px; stroke:#fff; }

#relationCanvas { display:block; width:100%; cursor:grab; touch-action:none; }
#relationCanvas:active { cursor:grabbing; }

.canvas-hint {
  position:absolute; bottom:10px; left:50%; transform:translateX(-50%);
  background:rgba(0,0,0,0.5); border-radius:20px; padding:5px 12px;
  font-size:10px; color:rgba(255,255,255,0.7); white-space:nowrap; pointer-events:none;
}

/* ── 범례 ── */
.legend-wrap { display:flex; flex-wrap:wrap; gap:8px; }
.legend-item { display:flex; align-items:center; gap:5px; font-size:11px; color:var(--ts); }
.legend-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.legend-line { width:18px; height:2px; flex-shrink:0; }
.legend-line.dashed { border-top:2px dashed; background:transparent; height:0; }

/* ── 인물 목록 ── */
.person-list { display:flex; flex-direction:column; gap:8px; }
.person-item {
  display:flex; align-items:center; gap:12px; padding:12px 14px;
  background:var(--bg); border-radius:12px; border:1px solid var(--bd);
  cursor:pointer; transition:border-color 0.15s;
}
.person-item:active { border-color:var(--blue); }
.person-avatar {
  width:38px; height:38px; border-radius:50%; display:flex; align-items:center;
  justify-content:center; font-size:14px; font-weight:700; flex-shrink:0; color:#fff;
}
.person-info { flex:1; min-width:0; }
.person-name { font-size:13px; font-weight:500; color:var(--tp); }
.person-role { font-size:11px; margin-top:2px; }
.person-memo { font-size:10px; color:var(--tm); margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.person-actions { display:flex; gap:6px; }
.person-action-btn {
  width:28px; height:28px; border-radius:8px; background:var(--card);
  border:1px solid var(--bd); display:flex; align-items:center; justify-content:center;
  cursor:pointer;
}
.person-action-btn svg { width:13px; height:13px; stroke:var(--ts); }

/* 역할 색상 */
.role-suspect  { background:var(--c-suspect); }
.role-victim   { background:var(--c-victim); }
.role-witness  { background:var(--c-witness); }
.role-reference{ background:var(--c-reference); }
.role-text-suspect  { color:var(--c-suspect); }
.role-text-victim   { color:var(--c-victim); }
.role-text-witness  { color:var(--c-witness); }
.role-text-reference{ color:var(--c-reference); }

/* ── 관계선 목록 ── */
.edge-list { display:flex; flex-direction:column; gap:8px; }
.edge-item {
  padding:11px 14px; background:var(--bg); border-radius:12px;
  border:1px solid var(--bd); border-left:3px solid var(--bd);
}
.edge-item.accomplice { border-left-color:var(--r-accomplice); }
.edge-item.harm       { border-left-color:var(--r-harm); }
.edge-item.witness    { border-left-color:var(--r-witness); }
.edge-item.acquaint   { border-left-color:var(--r-acquaint); }
.edge-item.family     { border-left-color:var(--r-family); }
.edge-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:5px; }
.edge-names { font-size:13px; font-weight:500; color:var(--tp); }
.edge-arrow { margin:0 6px; color:var(--tm); }
.edge-type-badge { font-size:10px; padding:2px 8px; border-radius:10px; background:var(--bg); border:1px solid var(--bd); color:var(--ts); }
.edge-meta { display:flex; gap:8px; align-items:center; }
.edge-status-dot { width:7px; height:7px; border-radius:50%; flex-shrink:0; }
.edge-status-text { font-size:11px; color:var(--tm); }
.edge-del-btn { width:24px; height:24px; border-radius:6px; background:var(--danger-bg); border:1px solid var(--danger-bd); display:flex; align-items:center; justify-content:center; cursor:pointer; flex-shrink:0; }
.edge-del-btn svg { width:12px; height:12px; stroke:var(--danger); }

/* ── 하단 액션 버튼 ── */
.action-row { display:flex; gap:8px; margin-bottom:12px; }
.btn-add {
  flex:1; padding:13px; border-radius:13px; border:none; font-size:13px;
  font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer;
  display:flex; align-items:center; justify-content:center; gap:7px;
  transition:transform 0.1s;
}
.btn-add:active { transform:scale(0.97); }
.btn-add svg { width:16px; height:16px; }
.btn-person { background:var(--deep); color:#fff; }
.btn-person svg { stroke:#fff; }
.btn-edge   { background:var(--blue); color:#fff; }
.btn-edge svg { stroke:#fff; }
.btn-save   { background:var(--success); color:#fff; }
.btn-save svg { stroke:#fff; }

/* ── 모달 공통 ── */
.modal-overlay {
  position:fixed; inset:0; background:rgba(0,0,0,0.55);
  z-index:100; display:none; align-items:flex-end; justify-content:center;
}
.modal-overlay.open { display:flex; }
.modal-sheet {
  background:var(--card); border-radius:24px 24px 0 0;
  width:100%; max-width:420px; padding:20px 20px 40px;
  animation:slideUp 0.25s ease;
}
@keyframes slideUp { from{transform:translateY(100%)} to{transform:translateY(0)} }
.modal-handle { width:36px; height:4px; background:var(--bd); border-radius:2px; margin:0 auto 18px; }
.modal-title { font-size:15px; font-weight:700; color:var(--tp); margin-bottom:16px; }

.form-field { margin-bottom:12px; }
.form-label { font-size:11px; font-weight:500; color:var(--ts); display:block; margin-bottom:5px; }
.form-input {
  width:100%; padding:11px 13px; background:var(--bg);
  border:1px solid var(--bd); border-radius:11px;
  font-size:13px; font-family:'Noto Sans KR',sans-serif;
  color:var(--tp); outline:none;
}
.form-input:focus { border-color:var(--blue); background:#fff; }
.form-select { appearance:none; }

.role-picker { display:grid; grid-template-columns:repeat(2,1fr); gap:8px; margin-bottom:12px; }
.role-option {
  padding:10px; border-radius:11px; border:2px solid var(--bd);
  text-align:center; cursor:pointer; font-size:12px; font-weight:500;
  transition:border-color 0.15s, background 0.15s; color:var(--ts);
}
.role-option.selected-suspect  { border-color:var(--c-suspect);   background:#fef2f2; color:var(--c-suspect); }
.role-option.selected-victim   { border-color:var(--c-victim);    background:#fff7ed; color:var(--c-victim); }
.role-option.selected-witness  { border-color:var(--c-witness);   background:#eff6ff; color:var(--c-witness); }
.role-option.selected-reference{ border-color:var(--c-reference); background:#f5f3ff; color:var(--c-reference); }

.rel-picker { display:flex; flex-direction:column; gap:6px; margin-bottom:12px; }
.rel-option {
  padding:10px 13px; border-radius:11px; border:2px solid var(--bd);
  cursor:pointer; font-size:12px; font-weight:500; color:var(--ts);
  display:flex; align-items:center; gap:8px; transition:all 0.15s;
}
.rel-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.rel-option.selected { border-color:var(--blue); background:var(--info-bg,#eff6ff); color:var(--blue); }

.status-picker { display:flex; gap:8px; margin-bottom:12px; }
.status-option {
  flex:1; padding:10px; border-radius:11px; border:2px solid var(--bd);
  text-align:center; cursor:pointer; font-size:11px; font-weight:500; color:var(--ts);
  transition:all 0.15s;
}
.status-option.sel-match    { border-color:#3b82f6; background:#eff6ff; color:#1e40af; }
.status-option.sel-mismatch { border-color:var(--danger); background:var(--danger-bg); color:var(--danger); }
.status-option.sel-unknown  { border-color:var(--tm); background:#f9fafb; color:var(--ts); }

.btn-modal-confirm {
  width:100%; padding:14px; border-radius:13px; background:var(--deep); color:#fff;
  border:none; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif;
  cursor:pointer; margin-top:6px;
}
.btn-modal-confirm:active { background:var(--navy); }
.btn-modal-cancel {
  width:100%; padding:11px; border-radius:13px; background:var(--bg); color:var(--ts);
  border:1px solid var(--bd); font-size:13px; font-family:'Noto Sans KR',sans-serif;
  cursor:pointer; margin-top:8px;
}

/* ── 변경 이력 ── */
.history-list { display:flex; flex-direction:column; gap:7px; }
.history-item { display:flex; gap:10px; align-items:flex-start; }
.history-dot { width:7px; height:7px; border-radius:50%; background:var(--blue); margin-top:5px; flex-shrink:0; }
.history-text { font-size:12px; color:var(--ts); line-height:1.6; }
.history-time { font-size:10px; color:var(--tm); margin-top:1px; }

/* ── 애니메이션 ── */
@keyframes fadeUp { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
@keyframes spin { to{transform:rotate(360deg)} }

/* ── 하단 네비 ── */
.bottom-nav {
  position:fixed; bottom:0; left:50%; transform:translateX(-50%);
  width:100%; max-width:420px; height:var(--bnav);
  background:var(--card); border-top:1px solid var(--bd);
  display:flex; z-index:10;
}
.nav-item { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:3px; text-decoration:none; color:var(--tm); cursor:pointer; border:none; background:none; font-family:'Noto Sans KR',sans-serif; }
.nav-item.active { color:var(--deep); }
.nav-icon { width:22px; height:22px; display:flex; align-items:center; justify-content:center; }
.nav-icon svg { width:20px; height:20px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; }
.nav-label { font-size:10px; font-weight:400; }
.nav-item.active .nav-label { font-weight:600; }
</style>
</head>
<body>
<div class="screen">

  <!-- ── 헤더 ── -->
  <div class="top-header">
    <div class="header-row">
      <button class="back-btn" onclick="history.back()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <div class="header-text">
        <div class="header-title">사건 관계망</div>
        <div class="header-sub">인물 등록 · 관계선 설정 · 보드 저장</div>
      </div>
      <button class="back-btn" onclick="openHistoryModal()" title="변경 이력">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
      </button>
    </div>
    <div class="header-gold-line"></div>

    <!-- 사건 선택 -->
    <div class="case-select-bar">
      <div class="case-select-wrap">
        <select class="case-select" id="caseSelect" onchange="loadBoard()">
          <option value="">— 사건을 선택하세요 —</option>
          <option value="2024-0312">2024-0312 절도사건</option>
          <option value="2024-0289">2024-0289 폭행사건</option>
          <option value="2024-0271">2024-0271 사기사건</option>
        </select>
        <button class="btn-new-board" onclick="newBoard()">+ 새 보드</button>
      </div>
    </div>
  </div>

  <!-- ── 콘텐츠 ── -->
  <div class="content" id="mainContent">

    <!-- 빈 상태 -->
    <div class="empty-state" id="emptyState">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round">
          <circle cx="8" cy="12" r="3"/><circle cx="18" cy="6" r="3"/><circle cx="18" cy="18" r="3"/>
          <line x1="10.8" y1="10.7" x2="15.2" y2="7.3"/><line x1="10.8" y1="13.3" x2="15.2" y2="16.7"/>
        </svg>
      </div>
      <div class="empty-title">사건을 선택하거나 새 보드를 만드세요</div>
      <div class="empty-desc">사건을 선택하면 저장된 관계망을 불러옵니다.<br>인물과 관계선을 직접 추가해 보드를 완성하세요.</div>
    </div>

    <!-- 보드 영역 (사건 선택 후 표시) -->
    <div id="boardArea" style="display:none;">

      <!-- 관계망 캔버스 -->
      <div class="canvas-wrap" id="canvasWrap">
        <div class="canvas-toolbar">
          <button class="canvas-tool-btn" onclick="zoomIn()" title="확대">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </button>
          <button class="canvas-tool-btn" onclick="zoomOut()" title="축소">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </button>
          <button class="canvas-tool-btn" onclick="resetView()" title="초기화">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.5"/></svg>
          </button>
        </div>
        <canvas id="relationCanvas" height="320"></canvas>
        <div class="canvas-hint">드래그로 이동 · 핀치로 확대/축소</div>
      </div>

      <!-- 범례 -->
      <div class="card" style="padding:12px 16px;">
        <div class="card-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
          범례
        </div>
        <div class="legend-wrap">
          <div class="legend-item"><div class="legend-dot" style="background:var(--c-suspect)"></div>피의자</div>
          <div class="legend-item"><div class="legend-dot" style="background:var(--c-victim)"></div>피해자</div>
          <div class="legend-item"><div class="legend-dot" style="background:var(--c-witness)"></div>목격자</div>
          <div class="legend-item"><div class="legend-dot" style="background:var(--c-reference)"></div>참고인</div>
        </div>
        <div style="height:8px"></div>
        <div class="legend-wrap">
          <div class="legend-item"><div class="legend-line" style="background:var(--r-accomplice)"></div>공범</div>
          <div class="legend-item"><div class="legend-line" style="background:var(--r-harm)"></div>피해관계</div>
          <div class="legend-item"><div class="legend-line" style="background:var(--r-witness)"></div>목격</div>
          <div class="legend-item"><div class="legend-line" style="background:var(--r-family)"></div>가족</div>
          <div class="legend-item"><div class="legend-line dashed" style="border-color:var(--danger)"></div>모순</div>
          <div class="legend-item"><div class="legend-line dashed" style="border-color:var(--tm)"></div>미분석</div>
        </div>
      </div>

      <!-- 인물 목록 -->
      <div class="card">
        <div class="card-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          등록 인물 (<span id="personCount">0</span>명)
        </div>
        <div class="person-list" id="personList">
          <div style="text-align:center;padding:20px 0;font-size:12px;color:var(--tm)">아직 등록된 인물이 없습니다.<br>아래 버튼으로 인물을 추가하세요.</div>
        </div>
      </div>

      <!-- 관계선 목록 -->
      <div class="card">
        <div class="card-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
          관계선 (<span id="edgeCount">0</span>개)
        </div>
        <div class="edge-list" id="edgeList">
          <div style="text-align:center;padding:16px 0;font-size:12px;color:var(--tm)">관계선이 없습니다.<br>인물 등록 후 관계선을 추가하세요.</div>
        </div>
      </div>

      <!-- 액션 버튼 -->
      <div class="action-row">
        <button class="btn-add btn-person" onclick="openPersonModal()">
          <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          인물 추가
        </button>
        <button class="btn-add btn-edge" onclick="openEdgeModal()">
          <svg viewBox="0 0 24 24"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
          관계선 추가
        </button>
      </div>
      <button class="btn-add btn-save" style="width:100%;margin-bottom:12px;" onclick="saveBoard()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
        보드 저장
      </button>

    </div><!-- /boardArea -->
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
    <a href="lawSearch.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
      <span class="nav-label">법전</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>

</div><!-- /screen -->

<!-- ═══════════════════════════════════════════════════ -->
<!-- 인물 추가 모달 -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="modal-overlay" id="personModal">
  <div class="modal-sheet">
    <div class="modal-handle"></div>
    <div class="modal-title" id="personModalTitle">인물 추가</div>

    <div class="form-field">
      <label class="form-label">이름 *</label>
      <input class="form-input" id="pName" placeholder="예) 홍길동" maxlength="20">
    </div>

    <div class="form-field">
      <label class="form-label">역할 *</label>
      <div class="role-picker">
        <div class="role-option" onclick="selectRole('suspect')"   id="role-suspect">🔴 피의자</div>
        <div class="role-option" onclick="selectRole('victim')"    id="role-victim">🟠 피해자</div>
        <div class="role-option" onclick="selectRole('witness')"   id="role-witness">🔵 목격자</div>
        <div class="role-option" onclick="selectRole('reference')" id="role-reference">🟣 참고인</div>
      </div>
    </div>

    <div class="form-field">
      <label class="form-label">메모 (선택)</label>
      <input class="form-input" id="pMemo" placeholder="예) 사건 당일 현장 근처 목격" maxlength="60">
    </div>

    <button class="btn-modal-confirm" onclick="confirmPerson()">추가하기</button>
    <button class="btn-modal-cancel"  onclick="closePersonModal()">취소</button>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!-- 관계선 추가 모달 -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="modal-overlay" id="edgeModal">
  <div class="modal-sheet">
    <div class="modal-handle"></div>
    <div class="modal-title">관계선 추가</div>

    <div class="form-field">
      <label class="form-label">출발 인물 *</label>
      <select class="form-input form-select" id="eSrc">
        <option value="">— 선택 —</option>
      </select>
    </div>
    <div class="form-field">
      <label class="form-label">도착 인물 *</label>
      <select class="form-input form-select" id="eDst">
        <option value="">— 선택 —</option>
      </select>
    </div>

    <div class="form-field">
      <label class="form-label">관계 유형 *</label>
      <div class="rel-picker" id="relPicker">
        <div class="rel-option" onclick="selectRel('accomplice')" id="rel-accomplice">
          <div class="rel-dot" style="background:var(--r-accomplice)"></div> 공범
        </div>
        <div class="rel-option" onclick="selectRel('harm')" id="rel-harm">
          <div class="rel-dot" style="background:var(--r-harm)"></div> 피해 대상 (가해→피해)
        </div>
        <div class="rel-option" onclick="selectRel('witness')" id="rel-witness">
          <div class="rel-dot" style="background:var(--r-witness)"></div> 목격
        </div>
        <div class="rel-option" onclick="selectRel('acquaint')" id="rel-acquaint">
          <div class="rel-dot" style="background:var(--r-acquaint)"></div> 지인
        </div>
        <div class="rel-option" onclick="selectRel('family')" id="rel-family">
          <div class="rel-dot" style="background:var(--r-family)"></div> 가족/친인척
        </div>
      </div>
    </div>

    <div class="form-field">
      <label class="form-label">진술 상태</label>
      <div class="status-picker">
        <div class="status-option sel-match"    onclick="selectStatus('match')"    id="st-match">일치</div>
        <div class="status-option"              onclick="selectStatus('mismatch')" id="st-mismatch">불일치(모순)</div>
        <div class="status-option sel-unknown"  onclick="selectStatus('unknown')"  id="st-unknown">미분석</div>
      </div>
    </div>

    <div class="form-field">
      <label class="form-label">사건 연관성 (선택)</label>
      <select class="form-input form-select" id="eContext">
        <option value="">— 선택 —</option>
        <option value="scene">현장 연관</option>
        <option value="time">시간 연관</option>
        <option value="evidence">증거 연관</option>
      </select>
    </div>

    <button class="btn-modal-confirm" onclick="confirmEdge()">관계선 추가</button>
    <button class="btn-modal-cancel"  onclick="closeEdgeModal()">취소</button>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!-- 변경 이력 모달 -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="modal-overlay" id="historyModal">
  <div class="modal-sheet">
    <div class="modal-handle"></div>
    <div class="modal-title">변경 이력</div>
    <div class="history-list" id="historyList">
      <div style="text-align:center;padding:24px 0;font-size:12px;color:var(--tm)">아직 변경 이력이 없습니다.</div>
    </div>
    <button class="btn-modal-cancel" style="margin-top:16px" onclick="closeHistoryModal()">닫기</button>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════ -->
<!-- 저장 완료 토스트 -->
<!-- ═══════════════════════════════════════════════════ -->
<div id="toast" style="
  position:fixed; bottom:84px; left:50%; transform:translateX(-50%) translateY(20px);
  background:#1a2744; color:#fff; padding:10px 20px; border-radius:24px;
  font-size:13px; opacity:0; transition:all 0.3s; pointer-events:none; z-index:200;
  white-space:nowrap;
"></div>

<script>
/* ═══════════════════════════════════════════════════════
   데이터 구조
═══════════════════════════════════════════════════════ */
var persons  = [];   // [{id, name, role, memo, x, y}]
var edges    = [];   // [{id, src, dst, relType, status, context}]
var history  = [];   // [{time, action}]
var currentCase = '';
var selectedRole   = '';
var selectedRel    = '';
var selectedStatus = 'unknown';
var editingPersonId = null;

/* 저장소 키 */
function storeKey(suffix) { return 'polmate_board_' + currentCase + '_' + suffix; }

/* ═══════════════════════════════════════════════════════
   사건 선택 / 보드 로드
═══════════════════════════════════════════════════════ */
function loadBoard() {
  currentCase = document.getElementById('caseSelect').value;
  if (!currentCase) {
    document.getElementById('emptyState').style.display = 'block';
    document.getElementById('boardArea').style.display  = 'none';
    return;
  }
  document.getElementById('emptyState').style.display = 'none';
  document.getElementById('boardArea').style.display  = 'block';

  // localStorage에서 불러오기
  try {
    persons = JSON.parse(localStorage.getItem(storeKey('persons')) || '[]');
    edges   = JSON.parse(localStorage.getItem(storeKey('edges'))   || '[]');
    history = JSON.parse(localStorage.getItem(storeKey('history')) || '[]');
  } catch(e) {
    persons = []; edges = []; history = [];
  }

  renderAll();
}

function newBoard() {
  var name = prompt('새 보드의 사건번호를 입력하세요 (예: 2025-0001)');
  if (!name || !name.trim()) return;
  var sel = document.getElementById('caseSelect');
  var opt = document.createElement('option');
  opt.value = name.trim();
  opt.text  = name.trim();
  sel.add(opt);
  sel.value = name.trim();
  loadBoard();
}

/* ═══════════════════════════════════════════════════════
   렌더링
═══════════════════════════════════════════════════════ */
var ROLE_COLOR = {
  suspect:'#dc2626', victim:'#f97316', witness:'#4a7cdc', reference:'#8b5cf6'
};
var ROLE_LABEL = {
  suspect:'피의자', victim:'피해자', witness:'목격자', reference:'참고인'
};
var REL_COLOR = {
  accomplice:'#dc2626', harm:'#f97316', witness:'#4a7cdc',
  acquaint:'#9ca3af', family:'#16a34a'
};
var REL_LABEL = {
  accomplice:'공범', harm:'피해관계', witness:'목격', acquaint:'지인', family:'가족'
};
var STATUS_COLOR  = { match:'#3b82f6', mismatch:'#dc2626', unknown:'#9ca3af' };
var STATUS_LABEL  = { match:'일치', mismatch:'불일치(모순)', unknown:'미분석' };
var CONTEXT_LABEL = { scene:'현장 연관', time:'시간 연관', evidence:'증거 연관' };

function renderAll() {
  renderPersonList();
  renderEdgeList();
  drawCanvas();
}

function renderPersonList() {
  document.getElementById('personCount').textContent = persons.length;
  var el = document.getElementById('personList');
  if (!persons.length) {
    el.innerHTML = '<div style="text-align:center;padding:20px 0;font-size:12px;color:var(--tm)">아직 등록된 인물이 없습니다.<br>아래 버튼으로 인물을 추가하세요.</div>';
    return;
  }
  el.innerHTML = persons.map(function(p) {
    return '<div class="person-item" id="pi-'+p.id+'">' +
      '<div class="person-avatar role-'+p.role+'" style="background:'+ROLE_COLOR[p.role]+'">'+
        p.name.charAt(0)+'</div>' +
      '<div class="person-info">' +
        '<div class="person-name">'+escHtml(p.name)+'</div>' +
        '<div class="person-role role-text-'+p.role+'">'+ROLE_LABEL[p.role]+'</div>' +
        (p.memo ? '<div class="person-memo">'+escHtml(p.memo)+'</div>' : '') +
      '</div>' +
      '<div class="person-actions">' +
        '<button class="person-action-btn" onclick="editPerson(\''+p.id+'\')" title="편집">' +
          '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>' +
        '</button>' +
        '<button class="person-action-btn" onclick="deletePerson(\''+p.id+'\')" title="삭제">' +
          '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>' +
        '</button>' +
      '</div>' +
    '</div>';
  }).join('');
}

function renderEdgeList() {
  document.getElementById('edgeCount').textContent = edges.length;
  var el = document.getElementById('edgeList');
  if (!edges.length) {
    el.innerHTML = '<div style="text-align:center;padding:16px 0;font-size:12px;color:var(--tm)">관계선이 없습니다.<br>인물 등록 후 관계선을 추가하세요.</div>';
    return;
  }
  el.innerHTML = edges.map(function(e) {
    var src = findPerson(e.src), dst = findPerson(e.dst);
    if (!src || !dst) return '';
    var stColor = STATUS_COLOR[e.status] || '#9ca3af';
    return '<div class="edge-item '+e.relType+'">' +
      '<div class="edge-header">' +
        '<span class="edge-names">' +
          escHtml(src.name) + '<span class="edge-arrow">→</span>' + escHtml(dst.name) +
        '</span>' +
        '<span class="edge-type-badge">'+(REL_LABEL[e.relType]||e.relType)+'</span>' +
      '</div>' +
      '<div class="edge-meta">' +
        '<div class="edge-status-dot" style="background:'+stColor+'"></div>' +
        '<span class="edge-status-text">'+(STATUS_LABEL[e.status]||'미분석')+
          (e.context ? ' · '+(CONTEXT_LABEL[e.context]||e.context) : '') +
        '</span>' +
        '<button class="edge-del-btn" onclick="deleteEdge(\''+e.id+'\')" style="margin-left:auto">' +
          '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
        '</button>' +
      '</div>' +
    '</div>';
  }).join('');
}

/* ═══════════════════════════════════════════════════════
   캔버스 그리기
═══════════════════════════════════════════════════════ */
var canvas, ctx;
var scale = 1, offsetX = 0, offsetY = 0;
var isDragging = false, lastX = 0, lastY = 0;

window.addEventListener('load', function() {
  canvas = document.getElementById('relationCanvas');
  ctx    = canvas.getContext('2d');
  resizeCanvas();

  // 드래그 (마우스)
  canvas.addEventListener('mousedown', function(e) { isDragging=true; lastX=e.clientX; lastY=e.clientY; });
  canvas.addEventListener('mousemove', function(e) {
    if (!isDragging) return;
    offsetX += (e.clientX-lastX)/scale; offsetY += (e.clientY-lastY)/scale;
    lastX=e.clientX; lastY=e.clientY; drawCanvas();
  });
  canvas.addEventListener('mouseup',   function(){ isDragging=false; });
  canvas.addEventListener('mouseleave',function(){ isDragging=false; });

  // 드래그 (터치)
  var lastTouchX, lastTouchY, lastDist;
  canvas.addEventListener('touchstart', function(e) {
    if (e.touches.length===1) { lastTouchX=e.touches[0].clientX; lastTouchY=e.touches[0].clientY; }
    if (e.touches.length===2) { lastDist = Math.hypot(e.touches[0].clientX-e.touches[1].clientX, e.touches[0].clientY-e.touches[1].clientY); }
    e.preventDefault();
  }, {passive:false});
  canvas.addEventListener('touchmove', function(e) {
    if (e.touches.length===1) {
      offsetX += (e.touches[0].clientX-lastTouchX)/scale;
      offsetY += (e.touches[0].clientY-lastTouchY)/scale;
      lastTouchX=e.touches[0].clientX; lastTouchY=e.touches[0].clientY;
      drawCanvas();
    }
    if (e.touches.length===2) {
      var d = Math.hypot(e.touches[0].clientX-e.touches[1].clientX, e.touches[0].clientY-e.touches[1].clientY);
      scale = Math.max(0.4, Math.min(2.5, scale * d/lastDist));
      lastDist = d; drawCanvas();
    }
    e.preventDefault();
  }, {passive:false});
});

function resizeCanvas() {
  var wrap = document.getElementById('canvasWrap');
  if (!wrap || !canvas) return;
  canvas.width  = wrap.clientWidth;
  canvas.height = 320;
  drawCanvas();
}

function drawCanvas() {
  if (!ctx) return;
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // 배경
  ctx.fillStyle = '#0d1a33';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  if (!persons.length) {
    ctx.fillStyle = 'rgba(255,255,255,0.25)';
    ctx.font = '13px Noto Sans KR, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('인물을 추가하면 여기에 관계망이 표시됩니다', canvas.width/2, canvas.height/2);
    return;
  }

  // 노드 위치 자동 배치 (원형)
  var cx = canvas.width/2, cy = canvas.height/2, r = Math.min(cx,cy)*0.62;
  persons.forEach(function(p, i) {
    var angle = (2*Math.PI*i/persons.length) - Math.PI/2;
    p._x = cx + Math.cos(angle)*r + offsetX*scale;
    p._y = cy + Math.sin(angle)*r + offsetY*scale;
  });
  if (persons.length===1) { persons[0]._x=cx+offsetX*scale; persons[0]._y=cy+offsetY*scale; }

  ctx.save();

  // 관계선 그리기
  edges.forEach(function(e) {
    var src = findPerson(e.src), dst = findPerson(e.dst);
    if (!src || !dst) return;
    var color = REL_COLOR[e.relType] || '#9ca3af';
    ctx.beginPath();
    ctx.moveTo(src._x, src._y);
    ctx.lineTo(dst._x, dst._y);
    ctx.strokeStyle = color;
    ctx.lineWidth   = 2 * scale;
    if (e.status === 'mismatch') {
      ctx.setLineDash([6*scale, 4*scale]);
      ctx.strokeStyle = '#dc2626';
    } else if (e.status === 'unknown') {
      ctx.setLineDash([4*scale, 4*scale]);
      ctx.strokeStyle = '#9ca3af';
    } else {
      ctx.setLineDash([]);
    }
    ctx.stroke();
    ctx.setLineDash([]);

    // 화살표 머리
    var ang = Math.atan2(dst._y - src._y, dst._x - src._x);
    var nr = 18*scale;
    var ax = dst._x - Math.cos(ang)*nr, ay = dst._y - Math.sin(ang)*nr;
    ctx.beginPath();
    ctx.moveTo(ax, ay);
    ctx.lineTo(ax - 8*scale*Math.cos(ang-0.4), ay - 8*scale*Math.sin(ang-0.4));
    ctx.lineTo(ax - 8*scale*Math.cos(ang+0.4), ay - 8*scale*Math.sin(ang+0.4));
    ctx.closePath();
    ctx.fillStyle = e.status==='mismatch' ? '#dc2626' : (e.status==='unknown' ? '#9ca3af' : color);
    ctx.fill();

    // 관계 유형 레이블
    var mx = (src._x+dst._x)/2, my = (src._y+dst._y)/2;
    ctx.font = (10*scale)+'px Noto Sans KR, sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.7)';
    ctx.textAlign = 'center';
    ctx.fillText(REL_LABEL[e.relType]||'', mx, my-5*scale);

    // 모순 경고 아이콘
    if (e.status === 'mismatch') {
      ctx.font = (13*scale)+'px sans-serif';
      ctx.fillText('⚠', mx, my+10*scale);
    }
  });

  // 노드 그리기
  persons.forEach(function(p) {
    var nr = 20*scale;
    // 원
    ctx.beginPath();
    ctx.arc(p._x, p._y, nr, 0, 2*Math.PI);
    ctx.fillStyle = ROLE_COLOR[p.role] || '#4a7cdc';
    ctx.fill();
    ctx.strokeStyle = '#fff';
    ctx.lineWidth = 2*scale;
    ctx.stroke();

    // 이름
    ctx.font = 'bold '+(11*scale)+'px Noto Sans KR, sans-serif';
    ctx.fillStyle = '#fff';
    ctx.textAlign = 'center';
    ctx.fillText(p.name.length>3 ? p.name.substr(0,3)+'…' : p.name, p._x, p._y+4*scale);

    // 역할 레이블
    ctx.font = (9*scale)+'px Noto Sans KR, sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.7)';
    ctx.fillText(ROLE_LABEL[p.role]||'', p._x, p._y+nr+12*scale);
  });

  ctx.restore();
}

function zoomIn()   { scale = Math.min(2.5, scale+0.2); drawCanvas(); }
function zoomOut()  { scale = Math.max(0.4, scale-0.2); drawCanvas(); }
function resetView(){ scale=1; offsetX=0; offsetY=0; drawCanvas(); }

/* ═══════════════════════════════════════════════════════
   인물 모달
═══════════════════════════════════════════════════════ */
function openPersonModal(editId) {
  editingPersonId = editId || null;
  document.getElementById('personModalTitle').textContent = editId ? '인물 편집' : '인물 추가';
  if (editId) {
    var p = findPerson(editId);
    document.getElementById('pName').value = p.name;
    document.getElementById('pMemo').value = p.memo || '';
    selectRole(p.role);
  } else {
    document.getElementById('pName').value = '';
    document.getElementById('pMemo').value = '';
    selectedRole = '';
    ['suspect','victim','witness','reference'].forEach(function(r) {
      document.getElementById('role-'+r).className = 'role-option';
    });
  }
  document.getElementById('personModal').classList.add('open');
}

function closePersonModal() {
  document.getElementById('personModal').classList.remove('open');
  editingPersonId = null;
}

function selectRole(r) {
  selectedRole = r;
  ['suspect','victim','witness','reference'].forEach(function(k) {
    document.getElementById('role-'+k).className = 'role-option' + (k===r ? ' selected-'+k : '');
  });
}

function editPerson(id) { openPersonModal(id); }

function confirmPerson() {
  var name = document.getElementById('pName').value.trim();
  var memo = document.getElementById('pMemo').value.trim();
  if (!name)         { alert('이름을 입력하세요.'); return; }
  if (!selectedRole) { alert('역할을 선택하세요.'); return; }

  if (editingPersonId) {
    // 편집
    var p = findPerson(editingPersonId);
    var old = ROLE_LABEL[p.role];
    p.name = name; p.role = selectedRole; p.memo = memo;
    addHistory('인물 편집: '+name+' ('+old+' → '+ROLE_LABEL[selectedRole]+')');
  } else {
    // 신규
    persons.push({ id: uid(), name:name, role:selectedRole, memo:memo });
    addHistory('인물 추가: '+name+' ('+ROLE_LABEL[selectedRole]+')');
  }
  closePersonModal();
  renderAll();
}

function deletePerson(id) {
  var p = findPerson(id);
  if (!confirm('"'+p.name+'"을(를) 삭제하면 관련 관계선도 모두 삭제됩니다. 삭제할까요?')) return;
  persons = persons.filter(function(x){ return x.id!==id; });
  edges   = edges.filter(function(e){ return e.src!==id && e.dst!==id; });
  addHistory('인물 삭제: '+p.name);
  renderAll();
}

/* ═══════════════════════════════════════════════════════
   관계선 모달
═══════════════════════════════════════════════════════ */
function openEdgeModal() {
  if (persons.length < 2) { alert('인물이 2명 이상이어야 관계선을 추가할 수 있습니다.'); return; }
  // 셀렉트 채우기
  var opts = '<option value="">— 선택 —</option>' +
    persons.map(function(p){ return '<option value="'+p.id+'">'+escHtml(p.name)+' ('+ROLE_LABEL[p.role]+')</option>'; }).join('');
  document.getElementById('eSrc').innerHTML = opts;
  document.getElementById('eDst').innerHTML = opts;

  selectedRel    = '';
  selectedStatus = 'unknown';
  ['accomplice','harm','witness','acquaint','family'].forEach(function(r) {
    document.getElementById('rel-'+r).className = 'rel-option';
  });
  ['match','mismatch','unknown'].forEach(function(s) {
    document.getElementById('st-'+s).className = 'status-option' + (s==='unknown' ? ' sel-unknown' : '');
  });
  document.getElementById('eContext').value = '';
  document.getElementById('edgeModal').classList.add('open');
}

function closeEdgeModal() { document.getElementById('edgeModal').classList.remove('open'); }

function selectRel(r) {
  selectedRel = r;
  ['accomplice','harm','witness','acquaint','family'].forEach(function(k) {
    document.getElementById('rel-'+k).className = 'rel-option' + (k===r ? ' selected' : '');
  });
}

function selectStatus(s) {
  selectedStatus = s;
  ['match','mismatch','unknown'].forEach(function(k) {
    var base = 'status-option';
    document.getElementById('st-'+k).className = base + (k===s ? ' sel-'+k : '');
  });
}

function confirmEdge() {
  var src = document.getElementById('eSrc').value;
  var dst = document.getElementById('eDst').value;
  if (!src)         { alert('출발 인물을 선택하세요.'); return; }
  if (!dst)         { alert('도착 인물을 선택하세요.'); return; }
  if (src===dst)    { alert('같은 인물은 선택할 수 없습니다.'); return; }
  if (!selectedRel) { alert('관계 유형을 선택하세요.'); return; }

  var sp = findPerson(src), dp = findPerson(dst);
  edges.push({
    id: uid(), src:src, dst:dst,
    relType: selectedRel, status: selectedStatus,
    context: document.getElementById('eContext').value
  });
  addHistory('관계선 추가: '+sp.name+' → '+dp.name+' ('+REL_LABEL[selectedRel]+', '+STATUS_LABEL[selectedStatus]+')');
  closeEdgeModal();
  renderAll();
}

function deleteEdge(id) {
  var e = edges.find(function(x){ return x.id===id; });
  if (!e) return;
  var sp = findPerson(e.src), dp = findPerson(e.dst);
  if (!confirm('"'+(sp?sp.name:'?')+' → '+(dp?dp.name:'?')+'" 관계선을 삭제할까요?')) return;
  edges = edges.filter(function(x){ return x.id!==id; });
  addHistory('관계선 삭제: '+(sp?sp.name:'?')+' → '+(dp?dp.name:'?'));
  renderAll();
}

/* ═══════════════════════════════════════════════════════
   변경 이력
═══════════════════════════════════════════════════════ */
function addHistory(action) {
  history.unshift({ time: new Date().toLocaleString('ko-KR'), action: action });
  if (history.length > 50) history.pop();
}

function openHistoryModal() {
  var el = document.getElementById('historyList');
  if (!history.length) {
    el.innerHTML = '<div style="text-align:center;padding:24px 0;font-size:12px;color:var(--tm)">아직 변경 이력이 없습니다.</div>';
  } else {
    el.innerHTML = history.map(function(h) {
      return '<div class="history-item">' +
        '<div class="history-dot"></div>' +
        '<div><div class="history-text">'+escHtml(h.action)+'</div>' +
        '<div class="history-time">'+h.time+'</div></div>' +
      '</div>';
    }).join('');
  }
  document.getElementById('historyModal').classList.add('open');
}

function closeHistoryModal() { document.getElementById('historyModal').classList.remove('open'); }

/* ═══════════════════════════════════════════════════════
   저장
═══════════════════════════════════════════════════════ */
function saveBoard() {
  if (!currentCase) { alert('사건을 먼저 선택해 주세요.'); return; }
  try {
    localStorage.setItem(storeKey('persons'), JSON.stringify(persons));
    localStorage.setItem(storeKey('edges'),   JSON.stringify(edges));
    localStorage.setItem(storeKey('history'), JSON.stringify(history));
    addHistory('보드 저장');
    showToast('✓ 보드가 저장되었습니다');
  } catch(e) {
    alert('저장 중 오류가 발생했습니다: ' + e.message);
  }
}

function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.style.opacity = '1';
  t.style.transform = 'translateX(-50%) translateY(0)';
  setTimeout(function() {
    t.style.opacity = '0';
    t.style.transform = 'translateX(-50%) translateY(20px)';
  }, 2200);
}

/* ═══════════════════════════════════════════════════════
   유틸
═══════════════════════════════════════════════════════ */
function uid() { return Math.random().toString(36).substr(2,9); }
function findPerson(id) { return persons.find(function(p){ return p.id===id; }); }
function escHtml(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// 오버레이 바깥 클릭 시 모달 닫기
['personModal','edgeModal','historyModal'].forEach(function(id) {
  document.getElementById(id).addEventListener('click', function(e) {
    if (e.target === this) {
      this.classList.remove('open');
      editingPersonId = null;
    }
  });
});

// 리사이즈 대응
window.addEventListener('resize', resizeCanvas);
</script>
</body>
</html>
