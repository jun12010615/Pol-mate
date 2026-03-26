<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 수사 절차 체크리스트</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
  :root {
    --navy: #1a2744; --accent: #4a7cdc; --danger: #dc2626;
    --text-primary: #1a1a2e; --text-secondary: #6b7280; --text-muted: #9ca3af;
    --bg: #f4f6fb; --card: #ffffff; --border: #e5e7eb;
    --success: #16a34a; --success-bg: #f0fdf4; --success-border: #bbf7d0;
    --warn-bg: #fffbeb; --warn-border: #fde68a; --warn-text: #92400e;
    --danger-bg: #fef2f2; --danger-border: #fecaca;
    --bottom-nav-h: 64px;
  }
  html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: var(--bg); overflow-x: hidden; }

  .screen { width: 100%; max-width: 420px; min-height: 100vh; margin: 0 auto; background: var(--bg); display: flex; flex-direction: column; }

  /* ── 헤더 ── */
  .top-header { background: var(--navy); padding: 52px 20px 0; position: sticky; top: 0; z-index: 10; }
  .header-row { display: flex; align-items: center; gap: 12px; padding-bottom: 16px; }
  .back-btn { width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.12); border: none; display: flex; align-items: center; justify-content: center; cursor: pointer; flex-shrink: 0; }
  .back-btn svg { width: 18px; height: 18px; stroke: #fff; }
  .header-text { flex: 1; }
  .header-title { font-size: 16px; font-weight: 500; color: #fff; }
  .header-sub   { font-size: 10px; color: rgba(255,255,255,0.5); margin-top: 2px; }

  /* 진행 탭 */
  .stage-tabs { display: flex; overflow-x: auto; gap: 0; border-top: 1px solid rgba(255,255,255,0.1); -ms-overflow-style: none; scrollbar-width: none; }
  .stage-tabs::-webkit-scrollbar { display: none; }
  .stage-tab { flex-shrink: 0; padding: 12px 16px; font-size: 12px; color: rgba(255,255,255,0.5); background: none; border: none; cursor: pointer; font-family: 'Noto Sans KR', sans-serif; border-bottom: 2px solid transparent; white-space: nowrap; transition: all 0.2s; }
  .stage-tab.active { color: #fff; border-bottom-color: #fff; font-weight: 500; }
  .stage-tab.done   { color: #4ade80; }

  /* ── 전체 진행률 ── */
  .progress-wrap { background: var(--navy); padding: 0 20px 20px; }
  .progress-card {
    background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15);
    border-radius: 14px; padding: 14px 16px;
    display: flex; align-items: center; gap: 14px;
  }
  .progress-ring { position: relative; width: 52px; height: 52px; flex-shrink: 0; }
  .progress-ring svg { transform: rotate(-90deg); }
  .ring-bg   { fill: none; stroke: rgba(255,255,255,0.15); stroke-width: 4; }
  .ring-fill { fill: none; stroke: #4ade80; stroke-width: 4; stroke-linecap: round; transition: stroke-dashoffset 0.5s; }
  .ring-text { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 700; color: #fff; }
  .progress-info { flex: 1; }
  .progress-label { font-size: 12px; color: rgba(255,255,255,0.7); margin-bottom: 4px; }
  .progress-bar-wrap { background: rgba(255,255,255,0.15); border-radius: 4px; height: 6px; overflow: hidden; }
  .progress-bar { height: 100%; background: #4ade80; border-radius: 4px; transition: width 0.5s; }
  .progress-counts { font-size: 10px; color: rgba(255,255,255,0.5); margin-top: 4px; }

  /* ── 콘텐츠 ── */
  .content { flex: 1; overflow-y: auto; padding: 16px 16px calc(var(--bottom-nav-h) + 16px); }

  /* 단계 패널 */
  .stage-panel { display: none; }
  .stage-panel.active { display: block; }

  /* 단계 헤더 */
  .stage-header {
    background: var(--card); border-radius: 14px; border: 1px solid var(--border);
    padding: 16px 18px; margin-bottom: 12px; display: flex; align-items: center; gap: 14px;
  }
  .stage-icon { width: 44px; height: 44px; border-radius: 13px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
  .stage-icon svg { width: 22px; height: 22px; }
  .stage-name { font-size: 15px; font-weight: 500; color: var(--text-primary); margin-bottom: 3px; }
  .stage-desc { font-size: 11px; color: var(--text-muted); }
  .stage-badge { margin-left: auto; font-size: 11px; font-weight: 500; padding: 4px 10px; border-radius: 20px; white-space: nowrap; flex-shrink: 0; }
  .badge-ok   { background: var(--success-bg); color: var(--success); }
  .badge-warn { background: var(--warn-bg);    color: var(--warn-text); }
  .badge-todo { background: var(--bg);         color: var(--text-muted); border: 1px solid var(--border); }

  /* 체크리스트 아이템 */
  .checklist { display: flex; flex-direction: column; gap: 8px; margin-bottom: 14px; }

  .chk-item {
    background: var(--card); border-radius: 12px; border: 1px solid var(--border);
    padding: 14px 16px; display: flex; align-items: flex-start; gap: 12px;
    cursor: pointer; transition: border-color 0.2s, background 0.15s;
    position: relative;
  }
  .chk-item.checked  { border-color: var(--success-border); background: var(--success-bg); }
  .chk-item.critical { border-left: 3px solid var(--danger); }
  .chk-item.skipped  { opacity: 0.5; }
  .chk-item:active   { background: var(--bg); }

  .chk-box {
    width: 22px; height: 22px; border-radius: 6px; border: 2px solid var(--border);
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    margin-top: 1px; transition: all 0.2s;
  }
  .chk-box svg { width: 12px; height: 12px; stroke: #fff; display: none; }
  .chk-item.checked  .chk-box { background: var(--success); border-color: var(--success); }
  .chk-item.checked  .chk-box svg { display: block; }
  .chk-item.critical .chk-box { border-color: var(--danger); }
  .chk-item.critical:not(.checked) .chk-box { background: #fff0f0; }

  .chk-content { flex: 1; }
  .chk-title { font-size: 13px; font-weight: 500; color: var(--text-primary); margin-bottom: 3px; line-height: 1.4; }
  .chk-item.checked .chk-title { color: var(--success); text-decoration: line-through; text-decoration-color: rgba(22,163,74,0.4); }
  .chk-desc  { font-size: 11px; color: var(--text-muted); line-height: 1.6; }

  .critical-tag {
    font-size: 9px; background: var(--danger-bg); color: var(--danger);
    border-radius: 4px; padding: 2px 6px; margin-left: 6px; vertical-align: middle; font-weight: 500;
  }

  .law-ref {
    font-size: 10px; color: var(--accent); margin-top: 4px; display: block;
  }

  /* 사유 입력 필드 (미확인 시 강제) */
  .reason-box {
    margin-top: 10px; display: none;
  }
  .reason-input {
    width: 100%; padding: 9px 12px; background: #fff;
    border: 1px solid var(--warn-border); border-radius: 8px;
    font-size: 12px; font-family: 'Noto Sans KR', sans-serif;
    color: var(--text-primary); outline: none;
  }
  .reason-input::placeholder { color: var(--text-muted); }
  .reason-label { font-size: 10px; color: var(--warn-text); margin-bottom: 5px; display: flex; align-items: center; gap: 5px; }
  .reason-label svg { width: 12px; height: 12px; stroke: var(--warn-text); }

  /* 다음 단계 버튼 */
  .btn-next {
    width: 100%; background: var(--navy); color: #fff; border: none;
    border-radius: 14px; padding: 15px; font-size: 14px; font-weight: 500;
    font-family: 'Noto Sans KR', sans-serif; cursor: pointer;
    display: flex; align-items: center; justify-content: center; gap: 8px;
    transition: transform 0.1s, background 0.2s; margin-bottom: 8px;
  }
  .btn-next:active  { transform: scale(0.98); }
  .btn-next svg { width: 16px; height: 16px; stroke: #fff; }
  .btn-next:disabled { background: var(--border); color: var(--text-muted); cursor: not-allowed; }

  /* 완료 화면 */
  .done-screen { display: none; padding: 32px 0; text-align: center; }
  .done-icon { width: 80px; height: 80px; background: var(--success-bg); border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; }
  .done-icon svg { width: 40px; height: 40px; stroke: var(--success); }
  .done-title { font-size: 20px; font-weight: 700; color: var(--navy); margin-bottom: 8px; }
  .done-desc  { font-size: 13px; color: var(--text-secondary); line-height: 1.9; margin-bottom: 28px; }
  .done-log   { background: var(--card); border-radius: 14px; border: 1px solid var(--border); padding: 16px; text-align: left; margin-bottom: 16px; }
  .done-log-title { font-size: 11px; font-weight: 500; color: var(--text-secondary); margin-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; }
  .log-row { display: flex; justify-content: space-between; font-size: 12px; padding: 5px 0; border-bottom: 1px solid var(--border); }
  .log-row:last-child { border-bottom: none; }
  .log-key { color: var(--text-muted); }
  .log-val { font-weight: 500; color: var(--text-primary); }
  .log-val.ok   { color: var(--success); }
  .log-val.warn { color: var(--warn-text); }

  /* ── 위반 경고 팝업 ── */
  .alert-overlay {
    position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 500;
    display: none; align-items: center; justify-content: center; padding: 20px;
  }
  .alert-overlay.open { display: flex; }

  .alert-popup {
    background: var(--card); border-radius: 20px; width: 100%; max-width: 360px;
    overflow: hidden; animation: popIn 0.25s cubic-bezier(0.34,1.56,0.64,1) both;
  }
  .alert-popup-header { background: var(--danger); padding: 20px 20px 16px; }
  .alert-popup-icon { width: 44px; height: 44px; background: rgba(255,255,255,0.2); border-radius: 50%; margin: 0 auto 10px; display: flex; align-items: center; justify-content: center; }
  .alert-popup-icon svg { width: 22px; height: 22px; stroke: #fff; }
  .alert-popup-title { font-size: 16px; font-weight: 700; color: #fff; text-align: center; }
  .alert-popup-body  { padding: 20px; }
  .alert-popup-msg   { font-size: 13px; color: var(--text-primary); line-height: 1.8; margin-bottom: 14px; }
  .alert-law { background: var(--danger-bg); border-radius: 10px; padding: 10px 14px; font-size: 11px; color: var(--danger); line-height: 1.7; margin-bottom: 16px; }

  .alert-reason-label { font-size: 11px; color: var(--text-secondary); margin-bottom: 6px; font-weight: 500; }
  .alert-reason-input {
    width: 100%; padding: 11px 14px; background: var(--bg);
    border: 1px solid var(--border); border-radius: 10px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif; outline: none;
    margin-bottom: 16px; transition: border-color 0.2s;
  }
  .alert-reason-input:focus { border-color: var(--accent); background: #fff; }
  .alert-reason-input::placeholder { color: var(--text-muted); font-size: 12px; }

  .alert-btns { display: flex; gap: 8px; }
  .alert-btn-confirm {
    flex: 1; background: var(--danger); color: #fff; border: none; border-radius: 12px;
    padding: 13px; font-size: 13px; font-weight: 500; font-family: 'Noto Sans KR', sans-serif; cursor: pointer;
  }
  .alert-btn-back {
    flex: 1; background: var(--bg); color: var(--text-secondary); border: 1px solid var(--border);
    border-radius: 12px; padding: 13px; font-size: 13px; font-family: 'Noto Sans KR', sans-serif; cursor: pointer;
  }

  /* ── 하단 네비 ── */
  .bottom-nav { position: fixed; bottom: 0; left: 50%; transform: translateX(-50%); width: 100%; max-width: 420px; height: var(--bottom-nav-h); background: var(--card); border-top: 1px solid var(--border); display: flex; justify-content: space-around; align-items: center; padding: 0 8px; z-index: 100; }
  .nav-item { display: flex; flex-direction: column; align-items: center; gap: 3px; flex: 1; cursor: pointer; text-decoration: none; padding: 6px 0; }
  .nav-icon { width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; }
  .nav-icon svg { width: 22px; height: 22px; }
  .nav-label { font-size: 9px; }
  .nav-item.active .nav-icon svg { stroke: var(--navy); }
  .nav-item.active .nav-label    { color: var(--navy); font-weight: 500; }
  .nav-item:not(.active) .nav-icon svg { stroke: var(--text-muted); }
  .nav-item:not(.active) .nav-label    { color: var(--text-muted); }

  @keyframes fadeUp { from { opacity:0; transform: translateY(12px); } to { opacity:1; transform: translateY(0); } }
  @keyframes popIn  { from { opacity:0; transform: scale(0.85); } to { opacity:1; transform: scale(1); } }
  @keyframes shake  { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-6px)} 75%{transform:translateX(6px)} }

  @media (min-width: 421px) { .screen { box-shadow: 0 0 40px rgba(0,0,0,0.1); } }
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
        <div class="header-title">수사 절차 체크리스트</div>
        <div class="header-sub">단계별 절차 위반 방지</div>
      </div>
    </div>
    <!-- 단계 탭 -->
    <div class="stage-tabs" id="stageTabs">
      <button class="stage-tab active" onclick="goStage(0)">① 체포·조사</button>
      <button class="stage-tab"        onclick="goStage(1)">② 권리고지</button>
      <button class="stage-tab"        onclick="goStage(2)">③ 조서작성</button>
      <button class="stage-tab"        onclick="goStage(3)">④ 구금·석방</button>
    </div>
  </div>

  <!-- 전체 진행률 -->
  <div class="progress-wrap">
    <div class="progress-card">
      <div class="progress-ring">
        <svg width="52" height="52" viewBox="0 0 52 52">
          <circle class="ring-bg"   cx="26" cy="26" r="22"/>
          <circle class="ring-fill" cx="26" cy="26" r="22"
                  stroke-dasharray="138.2"
                  id="ringFill" stroke-dashoffset="138.2"/>
        </svg>
        <div class="ring-text" id="ringPct">0%</div>
      </div>
      <div class="progress-info">
        <div class="progress-label">전체 절차 이행률</div>
        <div class="progress-bar-wrap">
          <div class="progress-bar" id="progressBar" style="width:0%"></div>
        </div>
        <div class="progress-counts" id="progressCounts">0 / 0 항목 완료</div>
      </div>
    </div>
  </div>

  <!-- 콘텐츠 -->
  <div class="content">

    <!-- ═══ 단계 0: 체포·조사 개시 ═══ -->
    <div class="stage-panel active" id="panel0">
      <div class="stage-header">
        <div class="stage-icon" style="background:#eff6ff;">
          <svg viewBox="0 0 24 24" fill="none" stroke="#1d4ed8" stroke-width="1.8" stroke-linecap="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
        <div>
          <div class="stage-name">체포 · 조사 개시</div>
          <div class="stage-desc">피의자 확보 및 조사 시작 전 필수 절차</div>
        </div>
        <span class="stage-badge badge-todo" id="badge0">진행중</span>
      </div>

      <div class="checklist" id="list0">

        <div class="chk-item critical" data-stage="0" data-id="0-0" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">체포영장 또는 긴급체포 요건 확인 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">영장 제시 또는 긴급체포 요건(현행범·긴급성) 해당 여부 확인</div>
            <span class="law-ref">형사소송법 제200조의2, 제212조</span>
          </div>
        </div>

        <div class="chk-item critical" data-stage="0" data-id="0-1" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">피의자 신원 확인 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">신분증 제시 요구 또는 기타 방법으로 신원 특정</div>
            <span class="law-ref">형사소송법 제200조</span>
          </div>
        </div>

        <div class="chk-item" data-stage="0" data-id="0-2" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">체포 일시 및 장소 기록</div>
            <div class="chk-desc">체포 시각, 장소, 담당 수사관 정보 즉시 기재</div>
          </div>
        </div>

        <div class="chk-item" data-stage="0" data-id="0-3" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">증거물 임의 제출 또는 영장에 의한 압수</div>
            <div class="chk-desc">압수수색영장 없이 임의 압수 금지. 임의 제출 동의서 징구</div>
            <span class="law-ref">형사소송법 제218조</span>
          </div>
        </div>

      </div>
      <button class="btn-next" onclick="nextStage(0)">
        다음 단계
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>
      </button>
    </div>

    <!-- ═══ 단계 1: 권리 고지 ═══ -->
    <div class="stage-panel" id="panel1">
      <div class="stage-header">
        <div class="stage-icon" style="background:#fef3c7;">
          <svg viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <div>
          <div class="stage-name">권리 고지 (미란다 원칙)</div>
          <div class="stage-desc">피의자 권리 고지 — 미이행 시 증거 능력 상실</div>
        </div>
        <span class="stage-badge badge-todo" id="badge1">진행중</span>
      </div>

      <div class="checklist" id="list1">

        <div class="chk-item critical" data-stage="1" data-id="1-0" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">진술 거부권(묵비권) 고지 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">"진술을 거부할 권리가 있으며 진술한 내용은 법정에서 불리하게 사용될 수 있습니다"</div>
            <span class="law-ref">형사소송법 제244조의3 · 헌법 제12조 제2항</span>
          </div>
        </div>

        <div class="chk-item critical" data-stage="1" data-id="1-1" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">변호인 조력권 고지 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">변호인 선임 권리 및 국선변호인 신청 권리 안내. 피의자 요청 시 즉시 연락 허용</div>
            <span class="law-ref">형사소송법 제30조, 제244조의3</span>
          </div>
        </div>

        <div class="chk-item critical" data-stage="1" data-id="1-2" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">체포·구속 이유 고지 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">피의사실의 요지, 체포·구속의 이유와 변호인 선임권 고지</div>
            <span class="law-ref">형사소송법 제72조, 제209조</span>
          </div>
        </div>

        <div class="chk-item" data-stage="1" data-id="1-3" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">가족 등 통지</div>
            <div class="chk-desc">피의자 요청 시 가족·지인에게 체포 사실 통지</div>
            <span class="law-ref">형사소송법 제87조</span>
          </div>
        </div>

        <div class="chk-item" data-stage="1" data-id="1-4" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">권리 고지 확인서 서명 징구</div>
            <div class="chk-desc">피의자가 권리 고지 내용을 충분히 이해하였음을 확인하는 서면 작성</div>
          </div>
        </div>

      </div>
      <button class="btn-next" onclick="nextStage(1)">
        다음 단계
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>
      </button>
    </div>

    <!-- ═══ 단계 2: 조서 작성 ═══ -->
    <div class="stage-panel" id="panel2">
      <div class="stage-header">
        <div class="stage-icon" style="background:#f0fdf4;">
          <svg viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        </div>
        <div>
          <div class="stage-name">조서 작성</div>
          <div class="stage-desc">적법한 조서 작성 및 서명 절차</div>
        </div>
        <span class="stage-badge badge-todo" id="badge2">진행중</span>
      </div>

      <div class="checklist" id="list2">

        <div class="chk-item critical" data-stage="2" data-id="2-0" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">임의 진술 여부 확인 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">강압·협박·회유 없이 자유로운 의사에 의한 진술임을 확인</div>
            <span class="law-ref">형사소송법 제309조 (강제자백 배제 원칙)</span>
          </div>
        </div>

        <div class="chk-item" data-stage="2" data-id="2-1" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">조서 열람·낭독 후 서명</div>
            <div class="chk-desc">작성된 조서를 피의자에게 열람 또는 낭독하고 서명날인 징구</div>
            <span class="law-ref">형사소송법 제244조</span>
          </div>
        </div>

        <div class="chk-item" data-stage="2" data-id="2-2" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">정정·추가 내용 반영</div>
            <div class="chk-desc">피의자가 조서 내용에 이의 제기 시 정정 또는 추가 기재</div>
          </div>
        </div>

        <div class="chk-item" data-stage="2" data-id="2-3" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">변호인 참여 여부 기재</div>
            <div class="chk-desc">변호인 참여 시 성명 기재, 미참여 시 그 이유 기재</div>
            <span class="law-ref">형사소송법 제243조의2</span>
          </div>
        </div>

        <div class="chk-item" data-stage="2" data-id="2-4" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">조사 일시 · 장소 · 시간 기록</div>
            <div class="chk-desc">조사 시작·종료 시각, 장소, 휴식 시간 모두 기재</div>
          </div>
        </div>

      </div>
      <button class="btn-next" onclick="nextStage(2)">
        다음 단계
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>
      </button>
    </div>

    <!-- ═══ 단계 3: 구금·석방 ═══ -->
    <div class="stage-panel" id="panel3">
      <div class="stage-header">
        <div class="stage-icon" style="background:#f5f3ff;">
          <svg viewBox="0 0 24 24" fill="none" stroke="#7c3aed" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        </div>
        <div>
          <div class="stage-name">구금 · 석방</div>
          <div class="stage-desc">구금 기간 준수 및 적법한 석방 절차</div>
        </div>
        <span class="stage-badge badge-todo" id="badge3">진행중</span>
      </div>

      <div class="checklist" id="list3">

        <div class="chk-item critical" data-stage="3" data-id="3-0" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">체포 후 48시간 내 처리 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">체포 후 48시간 이내 석방 또는 구속영장 청구. 초과 시 즉시 석방 의무</div>
            <span class="law-ref">형사소송법 제200조의2 제5항</span>
          </div>
        </div>

        <div class="chk-item critical" data-stage="3" data-id="3-1" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">심야 조사 금지 준수 <span class="critical-tag">필수</span></div>
            <div class="chk-desc">자정~오전 6시 조사 원칙적 금지. 예외 시 피의자 동의서 징구 필수</div>
            <span class="law-ref">인권보호를 위한 경찰관 직무규칙 제56조</span>
          </div>
        </div>

        <div class="chk-item" data-stage="3" data-id="3-2" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">구속영장 청구 시 판사 심문 절차</div>
            <div class="chk-desc">구속 전 피의자 심문(영장실질심사) 일정 안내 및 참여 보장</div>
            <span class="law-ref">형사소송법 제201조의2</span>
          </div>
        </div>

        <div class="chk-item" data-stage="3" data-id="3-3" onclick="toggleCheck(this)">
          <div class="chk-box"><svg viewBox="0 0 12 10" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="1 5 4 8 11 1"/></svg></div>
          <div class="chk-content">
            <div class="chk-title">석방 시 석방확인서 교부</div>
            <div class="chk-desc">석방 일시·장소·사유를 기재한 확인서 피의자에게 교부</div>
          </div>
        </div>

      </div>

      <button class="btn-next" onclick="completeAll()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
        전체 절차 완료
      </button>
    </div>

    <!-- ═══ 완료 화면 ═══ -->
    <div class="done-screen" id="doneScreen">
      <div class="done-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
      </div>
      <div class="done-title">절차 이행 완료</div>
      <div class="done-desc">모든 수사 절차가 기록되었습니다.<br>이력은 DB에 자동 저장됩니다.</div>

      <div class="done-log">
        <div class="done-log-title">절차 이행 요약</div>
        <div id="doneLogContent"></div>
      </div>

      <button class="btn-next" onclick="location.href='main.jsp'">메인으로 돌아가기</button>
      <button style="width:100%; background:none; border:none; color:var(--accent); font-size:13px; padding:12px; cursor:pointer; font-family:'Noto Sans KR',sans-serif;" onclick="resetAll()">처음부터 다시 시작</button>
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
    <a href="askAI" class="nav-item active">
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

<!-- ═══ 위반 경고 팝업 ═══ -->
<div class="alert-overlay" id="alertOverlay">
  <div class="alert-popup">
    <div class="alert-popup-header">
      <div class="alert-popup-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
      </div>
      <div class="alert-popup-title" id="alertTitle">절차 위반 경고</div>
    </div>
    <div class="alert-popup-body">
      <div class="alert-popup-msg" id="alertMsg"></div>
      <div class="alert-law" id="alertLaw"></div>
      <div class="alert-reason-label">미이행 사유를 반드시 입력하세요 (의사결정 이력 기록)</div>
      <input type="text" class="alert-reason-input" id="alertReasonInput" placeholder="예: 피의자 동의 하에 다음 단계 진행">
      <div class="alert-btns">
        <button class="alert-btn-back"    onclick="closeAlert(false)">이전으로</button>
        <button class="alert-btn-confirm" onclick="closeAlert(true)">사유 입력 후 진행</button>
      </div>
    </div>
  </div>
</div>

<script>
// ── 전체 체크 상태 관리 ───────────────────────────────────────────
var checked    = {};  // { '0-0': true, ... }
var skipReasons = {}; // { '1-0': '사유 내용', ... }
var pendingSkip = null;
var currentStage = 0;

// 단계별 총 항목 수
var stageTotals = [4, 5, 5, 4];

// 필수(critical) 항목 목록
var criticalItems = ['0-0','0-1','1-0','1-1','1-2','2-0','3-0','3-1'];

// ── 체크 토글 ─────────────────────────────────────────────────────
function toggleCheck(el) {
  var id = el.getAttribute('data-id');
  if (checked[id]) {
    // 해제
    checked[id] = false;
    el.classList.remove('checked');
  } else {
    // 체크
    checked[id] = true;
    el.classList.add('checked');
  }
  updateProgress();
  updateStageBadge(parseInt(el.getAttribute('data-stage')));
}

// ── 진행률 업데이트 ───────────────────────────────────────────────
function updateProgress() {
  var total = 0;
  var done  = 0;
  stageTotals.forEach(function(n) { total += n; });
  Object.keys(checked).forEach(function(k) { if (checked[k]) done++; });

  var pct = total > 0 ? Math.round(done / total * 100) : 0;
  var circumference = 138.2;
  var offset = circumference - (pct / 100 * circumference);

  document.getElementById('ringFill').setAttribute('stroke-dashoffset', offset.toFixed(1));
  document.getElementById('ringPct').textContent = pct + '%';
  document.getElementById('progressBar').style.width = pct + '%';
  document.getElementById('progressCounts').textContent = done + ' / ' + total + ' 항목 완료';
}

function updateStageBadge(stageIdx) {
  var ids = getStageIds(stageIdx);
  var doneCount = ids.filter(function(id) { return checked[id]; }).length;
  var badge = document.getElementById('badge' + stageIdx);
  if (doneCount === ids.length) {
    badge.className = 'stage-badge badge-ok';
    badge.textContent = '완료';
    var tab = document.querySelectorAll('.stage-tab')[stageIdx];
    if (tab) tab.classList.add('done');
  } else if (doneCount > 0) {
    badge.className = 'stage-badge badge-warn';
    badge.textContent = doneCount + '/' + ids.length + ' 완료';
  } else {
    badge.className = 'stage-badge badge-todo';
    badge.textContent = '진행중';
  }
}

function getStageIds(stageIdx) {
  var n = stageTotals[stageIdx];
  var ids = [];
  for (var i = 0; i < n; i++) ids.push(stageIdx + '-' + i);
  return ids;
}

// ── 단계 이동 ─────────────────────────────────────────────────────
function goStage(idx) {
  document.querySelectorAll('.stage-panel').forEach(function(p) { p.classList.remove('active'); });
  document.querySelectorAll('.stage-tab').forEach(function(t,i) {
    t.classList.remove('active');
    if (i === idx) t.classList.add('active');
  });
  document.getElementById('panel' + idx).classList.add('active');
  document.getElementById('doneScreen').style.display = 'none';
  currentStage = idx;
  window.scrollTo(0, 0);
}

// ── 다음 단계 (미완료 필수 항목 체크) ────────────────────────────
function nextStage(stageIdx) {
  var ids = getStageIds(stageIdx);
  var missingCritical = ids.filter(function(id) {
    return criticalItems.indexOf(id) >= 0 && !checked[id];
  });

  if (missingCritical.length > 0) {
    // 가장 첫 번째 미완료 필수 항목 경고
    showAlert(missingCritical[0], stageIdx);
  } else {
    // 완료 처리 후 다음 단계
    markStageDone(stageIdx);
    goStage(stageIdx + 1);
  }
}

function markStageDone(idx) {
  var tab = document.querySelectorAll('.stage-tab')[idx];
  if (tab) { tab.classList.add('done'); tab.classList.remove('active'); }
}

// ── 경고 팝업 ─────────────────────────────────────────────────────
var alertMessages = {
  '0-0': { title: '체포영장 미확인 경고', msg: '체포영장 또는 긴급체포 요건이 확인되지 않았습니다.\n영장 없는 체포는 위법 체포로 향후 증거 능력이 부정될 수 있습니다.', law: '형사소송법 제200조의2 — 영장에 의한 체포 원칙\n※ 위반 시 해당 증거물 증거능력 상실 위험' },
  '0-1': { title: '피의자 신원 미확인 경고', msg: '피의자 신원이 확인되지 않았습니다.\n신원 불명 상태에서의 조사는 절차 하자로 인정될 수 있습니다.', law: '형사소송법 제200조' },
  '1-0': { title: '묵비권 미고지 — 심각한 위반!', msg: '진술 거부권(묵비권)이 고지되지 않았습니다.\n이 경우 이후 모든 자백 및 진술의 증거능력이 부정될 수 있으며, 유죄 판결이 무죄로 뒤집힐 수 있습니다.', law: '형사소송법 제244조의3 · 헌법 제12조 제2항\n※ 미란다 원칙 위반 — 수사 전체 무효화 위험' },
  '1-1': { title: '변호인 조력권 미고지 — 심각한 위반!', msg: '변호인 조력권이 고지되지 않았습니다.\n피의자는 언제든지 변호인의 도움을 받을 권리가 있습니다.', law: '형사소송법 제30조, 제244조의3\n※ 미란다 원칙 위반 — 수사 전체 무효화 위험' },
  '1-2': { title: '체포 이유 미고지 경고', msg: '피의자에게 체포 이유가 고지되지 않았습니다.\n이유 없는 구금은 위헌으로 판단될 수 있습니다.', law: '형사소송법 제72조, 제209조' },
  '2-0': { title: '임의 진술 미확인 경고', msg: '임의 진술 여부가 확인되지 않았습니다.\n강압 또는 회유에 의한 자백은 증거능력이 없습니다.', law: '형사소송법 제309조 (자백 배제 법칙)' },
  '3-0': { title: '구금 기간 초과 주의', msg: '체포 후 48시간 이내 처리 여부가 확인되지 않았습니다.\n기간 초과 시 피의자를 즉시 석방해야 합니다.', law: '형사소송법 제200조의2 제5항\n※ 위반 시 불법감금죄 성립 가능' },
  '3-1': { title: '심야 조사 금지 준수 확인', msg: '심야(자정~오전 6시) 조사 금지 규정 준수 여부가 확인되지 않았습니다.', law: '인권보호를 위한 경찰관 직무규칙 제56조' }
};

var alertTargetStage = -1;

function showAlert(itemId, stageIdx) {
  var info = alertMessages[itemId] || { title: '절차 미이행 경고', msg: '필수 절차가 이행되지 않았습니다.', law: '' };
  document.getElementById('alertTitle').textContent = info.title;
  document.getElementById('alertMsg').textContent   = info.msg;
  document.getElementById('alertLaw').textContent   = info.law;
  document.getElementById('alertReasonInput').value = '';
  pendingSkip      = { itemId: itemId, stageIdx: stageIdx };
  alertTargetStage = stageIdx;
  document.getElementById('alertOverlay').classList.add('open');
}

function closeAlert(proceed) {
  if (proceed) {
    var reason = document.getElementById('alertReasonInput').value.trim();
    if (!reason) {
      document.getElementById('alertReasonInput').style.animation = 'shake 0.3s ease';
      setTimeout(function() { document.getElementById('alertReasonInput').style.animation = ''; }, 300);
      return;
    }
    // 사유 기록 후 해당 항목 건너뜀
    skipReasons[pendingSkip.itemId] = reason;
    var el = document.querySelector('[data-id="' + pendingSkip.itemId + '"]');
    if (el) el.classList.add('skipped');
    document.getElementById('alertOverlay').classList.remove('open');
    // 다시 nextStage 호출 (다음 필수 항목 확인)
    nextStage(pendingSkip.stageIdx);
  } else {
    document.getElementById('alertOverlay').classList.remove('open');
  }
  pendingSkip = null;
}

// ── 전체 완료 ─────────────────────────────────────────────────────
function completeAll() {
  var ids = getStageIds(3);
  var missingCritical = ids.filter(function(id) {
    return criticalItems.indexOf(id) >= 0 && !checked[id];
  });
  if (missingCritical.length > 0) {
    showAlert(missingCritical[0], 3);
    return;
  }
  markStageDone(3);
  showDoneScreen();
}

function showDoneScreen() {
  document.querySelectorAll('.stage-panel').forEach(function(p) { p.classList.remove('active'); });
  var done = document.getElementById('doneScreen');
  done.style.display = 'block';

  // 로그 생성
  var names = ['체포·조사 개시', '권리 고지', '조서 작성', '구금·석방'];
  var html = '';
  for (var s = 0; s < 4; s++) {
    var sIds   = getStageIds(s);
    var doneN  = sIds.filter(function(id) { return checked[id]; }).length;
    var skipN  = sIds.filter(function(id) { return skipReasons[id]; }).length;
    var cls    = (doneN + skipN === sIds.length) ? 'ok' : 'warn';
    html += '<div class="log-row"><span class="log-key">' + names[s] + '</span><span class="log-val ' + cls + '">' + doneN + '/' + sIds.length + ' 완료' + (skipN > 0 ? ' (' + skipN + '건 사유기록)' : '') + '</span></div>';
  }
  var skips = Object.keys(skipReasons).length;
  html += '<div class="log-row"><span class="log-key">미이행 사유 기록</span><span class="log-val ' + (skips > 0 ? 'warn' : 'ok') + '">' + skips + '건</span></div>';
  document.getElementById('doneLogContent').innerHTML = html;
  updateProgress();
  window.scrollTo(0, 0);
}

function resetAll() {
  checked = {};
  skipReasons = {};
  pendingSkip = null;
  document.querySelectorAll('.chk-item').forEach(function(el) {
    el.classList.remove('checked','skipped');
  });
  document.getElementById('doneScreen').style.display = 'none';
  goStage(0);
  updateProgress();
  [0,1,2,3].forEach(function(i) { updateStageBadge(i); });
  document.querySelectorAll('.stage-tab').forEach(function(t) { t.classList.remove('done'); });
}

// 초기화
updateProgress();
</script>
</body>
</html>
