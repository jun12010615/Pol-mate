<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 마이페이지</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }

  :root {
    --navy: #1a2744;
    --navy-light: #243358;
    --accent: #4a7cdc;
    --danger: #e74c3c;
    --text-primary: #1a1a2e;
    --text-secondary: #6b7280;
    --text-muted: #9ca3af;
    --bg: #f4f6fb;
    --card: #ffffff;
    --border: #e5e7eb;
    --success: #16a34a;
    --success-bg: #f0fdf4;
    --bottom-nav-h: 64px;
  }

  html, body {
    height: 100%;
    font-family: 'Noto Sans KR', sans-serif;
    background: var(--bg);
    overflow-x: hidden;
  }

  .screen {
    width: 100%;
    max-width: 420px;
    min-height: 100vh;
    margin: 0 auto;
    background: var(--bg);
    display: flex;
    flex-direction: column;
  }

  /* ── 헤더 ── */
  .top-header {
    background: var(--navy);
    padding: 52px 20px 0;
    position: sticky;
    top: 0;
    z-index: 10;
  }

  .header-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 20px;
  }

  .header-title { font-size: 17px; font-weight: 500; color: #fff; }

  .edit-btn {
    background: rgba(255,255,255,0.12);
    border: 1px solid rgba(255,255,255,0.2);
    color: #fff;
    border-radius: 20px;
    padding: 6px 14px;
    font-size: 12px;
    font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer;
    transition: background 0.2s;
  }
  .edit-btn:active { background: rgba(255,255,255,0.2); }

  /* ── 프로필 카드 ── */
  .profile-band {
    background: var(--navy);
    padding: 0 20px 28px;
  }

  .profile-card {
    background: rgba(255,255,255,0.08);
    border: 1px solid rgba(255,255,255,0.15);
    border-radius: 18px;
    padding: 20px;
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .avatar-lg {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: rgba(255,255,255,0.2);
    border: 2px solid rgba(255,255,255,0.35);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    font-weight: 700;
    color: #fff;
    flex-shrink: 0;
  }

  .profile-info { flex: 1; min-width: 0; }

  .profile-name {
    font-size: 17px;
    font-weight: 700;
    color: #fff;
    margin-bottom: 4px;
  }

  .profile-rank {
    font-size: 12px;
    color: rgba(255,255,255,0.65);
    margin-bottom: 6px;
  }

  .profile-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    background: rgba(255,255,255,0.15);
    border-radius: 20px;
    padding: 3px 10px;
    font-size: 10px;
    color: rgba(255,255,255,0.85);
  }

  .badge-dot {
    width: 5px;
    height: 5px;
    border-radius: 50%;
    background: #4ade80;
  }

  /* ── 통계 띠 ── */
  .stats-band {
    background: var(--navy);
    padding: 0 20px 0;
  }

  .stats-strip {
    background: var(--card);
    border-radius: 16px 16px 0 0;
    padding: 16px 0 0;
    display: grid;
    grid-template-columns: repeat(3, 1fr);
  }

  .stat-col {
    text-align: center;
    padding: 10px 0 16px;
    position: relative;
  }

  .stat-col::after {
    content: '';
    position: absolute;
    right: 0; top: 20%; bottom: 20%;
    width: 1px;
    background: var(--border);
  }
  .stat-col:last-child::after { display: none; }

  .stat-num { font-size: 22px; font-weight: 700; color: var(--navy); }
  .stat-lbl { font-size: 10px; color: var(--text-muted); margin-top: 3px; }

  /* ── 스크롤 영역 ── */
  .content {
    flex: 1;
    overflow-y: auto;
    padding-bottom: calc(var(--bottom-nav-h) + 16px);
    background: var(--bg);
  }

  .section {
    padding: 16px 16px 0;
  }

  .section-label {
    font-size: 10px;
    font-weight: 500;
    color: var(--text-muted);
    letter-spacing: 0.8px;
    text-transform: uppercase;
    margin-bottom: 8px;
    padding-left: 4px;
  }

  /* ── 메뉴 리스트 카드 ── */
  .menu-list {
    background: var(--card);
    border-radius: 14px;
    border: 1px solid var(--border);
    overflow: hidden;
    margin-bottom: 0;
  }

  .menu-row {
    display: flex;
    align-items: center;
    padding: 15px 16px;
    cursor: pointer;
    transition: background 0.15s;
    text-decoration: none;
    border-bottom: 1px solid var(--border);
  }
  .menu-row:last-child { border-bottom: none; }
  .menu-row:active { background: var(--bg); }

  .menu-icon-wrap {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 14px;
    flex-shrink: 0;
  }

  .menu-icon-wrap svg { width: 18px; height: 18px; }

  .bg-blue   { background: #eff6ff; }
  .bg-green  { background: #f0fdf4; }
  .bg-amber  { background: #fffbeb; }
  .bg-purple { background: #f5f3ff; }
  .bg-red    { background: #fef2f2; }
  .bg-gray   { background: #f3f4f6; }
  .bg-navy   { background: #f0f3f9; }

  .stroke-blue   { stroke: #1d4ed8; }
  .stroke-green  { stroke: #15803d; }
  .stroke-amber  { stroke: #b45309; }
  .stroke-purple { stroke: #7c3aed; }
  .stroke-red    { stroke: #dc2626; }
  .stroke-gray   { stroke: #6b7280; }
  .stroke-navy   { stroke: #1a2744; }

  .menu-text { flex: 1; }
  .menu-name { font-size: 14px; color: var(--text-primary); font-weight: 400; }
  .menu-sub  { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

  .menu-right {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .menu-value { font-size: 12px; color: var(--text-muted); }
  .menu-arrow svg { width: 16px; height: 16px; stroke: var(--text-muted); }

  .toggle-wrap { position: relative; width: 44px; height: 26px; }
  .toggle-input { opacity: 0; width: 0; height: 0; position: absolute; }
  .toggle-slider {
    position: absolute; inset: 0;
    background: var(--border);
    border-radius: 13px;
    cursor: pointer;
    transition: background 0.25s;
  }
  .toggle-slider::before {
    content: '';
    position: absolute;
    width: 20px; height: 20px;
    border-radius: 50%;
    background: #fff;
    top: 3px; left: 3px;
    transition: transform 0.25s;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
  .toggle-input:checked + .toggle-slider { background: var(--navy); }
  .toggle-input:checked + .toggle-slider::before { transform: translateX(18px); }

  /* ── 드로어 오버레이 ── */
  .overlay {
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.45);
    z-index: 200;
    display: none;
    align-items: flex-end;
    justify-content: center;
  }
  .overlay.open { display: flex; }

  .drawer {
    background: var(--card);
    border-radius: 20px 20px 0 0;
    width: 100%;
    max-width: 420px;
    padding: 0 0 32px;
    animation: slideUp 0.28s ease both;
    max-height: 90vh;
    overflow-y: auto;
  }

  .drawer-handle {
    width: 36px; height: 4px;
    background: var(--border);
    border-radius: 2px;
    margin: 12px auto 20px;
  }

  .drawer-title {
    font-size: 16px;
    font-weight: 500;
    color: var(--text-primary);
    padding: 0 20px 16px;
    border-bottom: 1px solid var(--border);
  }

  .drawer-body { padding: 20px; }

  .d-field { margin-bottom: 14px; }
  .d-label {
    font-size: 11px;
    font-weight: 500;
    color: var(--text-secondary);
    display: block;
    margin-bottom: 6px;
  }
  .d-input {
    width: 100%;
    padding: 12px 14px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 10px;
    font-size: 14px;
    font-family: 'Noto Sans KR', sans-serif;
    color: var(--text-primary);
    outline: none;
    transition: border-color 0.2s;
  }
  .d-input:focus { border-color: var(--accent); background: #fff; }
  .d-input:disabled { color: var(--text-muted); }

  .d-btn {
    width: 100%;
    background: var(--navy);
    color: #fff;
    border: none;
    border-radius: 12px;
    padding: 14px;
    font-size: 14px;
    font-weight: 500;
    font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer;
    margin-top: 6px;
    transition: transform 0.1s;
  }
  .d-btn:active { transform: scale(0.98); }

  .d-btn-cancel {
    width: 100%;
    background: var(--bg);
    color: var(--text-secondary);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 13px;
    font-size: 14px;
    font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer;
    margin-top: 8px;
  }

  /* 조서 이력 리스트 */
  .history-list { padding: 0 20px; }
  .history-item {
    padding: 14px 0;
    border-bottom: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }
  .history-item:last-child { border-bottom: none; }
  .h-title { font-size: 13px; font-weight: 500; color: var(--text-primary); margin-bottom: 4px; }
  .h-meta  { font-size: 11px; color: var(--text-muted); }
  .h-badge {
    font-size: 10px; padding: 3px 9px; border-radius: 20px; white-space: nowrap; flex-shrink: 0;
  }
  .h-badge-ok   { background: #f0fdf4; color: #15803d; }
  .h-badge-warn { background: #fffbeb; color: #92400e; }
  .h-badge-done { background: #eff6ff; color: #1e40af; }

  /* 로그아웃 버튼 */
  .logout-btn {
    width: calc(100% - 32px);
    margin: 0 16px;
    background: var(--card);
    border: 1px solid #fca5a5;
    border-radius: 12px;
    padding: 15px;
    color: var(--danger);
    font-size: 14px;
    font-weight: 500;
    font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: background 0.2s;
  }
  .logout-btn svg { width: 16px; height: 16px; stroke: var(--danger); }
  .logout-btn:active { background: #fef2f2; }

  /* 앱 정보 */
  .app-info-card {
    background: var(--card);
    border-radius: 14px;
    border: 1px solid var(--border);
    padding: 20px;
    text-align: center;
  }
  .app-ver  { font-size: 13px; color: var(--text-secondary); margin-bottom: 6px; }
  .app-name { font-size: 20px; font-weight: 700; color: var(--navy); letter-spacing: 2px; margin-bottom: 4px; }
  .app-copy { font-size: 10px; color: var(--text-muted); }

  /* ── 하단 네비 ── */
  .bottom-nav {
    position: fixed;
    bottom: 0; left: 50%;
    transform: translateX(-50%);
    width: 100%; max-width: 420px;
    height: var(--bottom-nav-h);
    background: var(--card);
    border-top: 1px solid var(--border);
    display: flex; justify-content: space-around; align-items: center;
    padding: 0 8px; z-index: 100;
  }
  .nav-item {
    display: flex; flex-direction: column; align-items: center; gap: 3px;
    flex: 1; cursor: pointer; text-decoration: none; padding: 6px 0;
  }
  .nav-icon { width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; }
  .nav-icon svg { width: 22px; height: 22px; }
  .nav-label { font-size: 9px; }
  .nav-item.active .nav-icon svg { stroke: var(--navy); }
  .nav-item.active .nav-label    { color: var(--navy); font-weight: 500; }
  .nav-item:not(.active) .nav-icon svg { stroke: var(--text-muted); }
  .nav-item:not(.active) .nav-label    { color: var(--text-muted); }

  @keyframes slideUp {
    from { transform: translateY(100%); opacity: 0; }
    to   { transform: translateY(0);    opacity: 1; }
  }
  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  @media (min-width: 421px) {
    .screen { box-shadow: 0 0 40px rgba(0,0,0,0.1); }
    .drawer { max-width: 420px; }
  }
</style>
</head>
<body>

<%
  // 세션 체크 (DB 연동 후 활성화)
  // HttpSession sess = request.getSession(false);
  // if (sess == null || sess.getAttribute("loginUser") == null) {
  //     response.sendRedirect("login.jsp"); return;
  // }
  String userName  = "김민준";   // 임시
  String userRank  = "경위";
  String userOrg   = "서울지방경찰청 형사과";
  String userPhone = "010-1234-5678";
  String userId    = "test";
%>

<div class="screen">

  <!-- ── 헤더 ── -->
  <div class="top-header">
    <div class="header-row">
      <span class="header-title">마이페이지</span>
      <button class="edit-btn" onclick="openDrawer('profileDrawer')">프로필 편집</button>
    </div>
  </div>

  <!-- ── 프로필 카드 ── -->
  <div class="profile-band">
    <div class="profile-card">
      <div class="avatar-lg"><%= userName.length() >= 2 ? userName.substring(0,2) : userName %></div>
      <div class="profile-info">
        <div class="profile-name"><%= userName %> <%= userRank %></div>
        <div class="profile-rank"><%= userOrg %></div>
        <div class="profile-badge">
          <span class="badge-dot"></span>
          <span>접속 중 · <%= userId %></span>
        </div>
      </div>
    </div>
  </div>

  <!-- ── 통계 띠 ── -->
  <div class="stats-band">
    <div class="stats-strip">
      <div class="stat-col">
        <div class="stat-num">12</div>
        <div class="stat-lbl">진행 사건</div>
      </div>
      <div class="stat-col">
        <div class="stat-num">3</div>
        <div class="stat-lbl">모순 탐지</div>
      </div>
      <div class="stat-col">
        <div class="stat-num">28</div>
        <div class="stat-lbl">완료 조서</div>
      </div>
    </div>
  </div>

  <!-- ── 스크롤 콘텐츠 ── -->
  <div class="content">

    <!-- 계정 관리 -->
    <div class="section" style="margin-top:16px;">
      <div class="section-label">계정 관리</div>
      <div class="menu-list">

        <div class="menu-row" onclick="openDrawer('profileDrawer')">
          <div class="menu-icon-wrap bg-blue">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-blue">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">프로필 정보</div>
            <div class="menu-sub">이름 · 계급 · 소속 · 연락처</div>
          </div>
          <div class="menu-right">
            <div class="menu-arrow"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg></div>
          </div>
        </div>

        <div class="menu-row" onclick="openDrawer('pwDrawer')">
          <div class="menu-icon-wrap bg-amber">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-amber">
              <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">비밀번호 변경</div>
            <div class="menu-sub">현재 비밀번호 확인 후 변경</div>
          </div>
          <div class="menu-right">
            <div class="menu-arrow"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg></div>
          </div>
        </div>

      </div>
    </div>

    <!-- 수사 활동 -->
    <div class="section" style="margin-top:16px;">
      <div class="section-label">수사 활동</div>
      <div class="menu-list">

        <div class="menu-row" onclick="openDrawer('historyDrawer')">
          <div class="menu-icon-wrap bg-navy">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-navy">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">내 조서 이력</div>
            <div class="menu-sub">작성 · 수정 · 완료 기록</div>
          </div>
          <div class="menu-right">
            <span class="menu-value">28건</span>
            <div class="menu-arrow"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg></div>
          </div>
        </div>

        <div class="menu-row" onclick="openDrawer('statsDrawer')">
          <div class="menu-icon-wrap bg-green">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-green">
              <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">활동 통계</div>
            <div class="menu-sub">처리 사건 수 · 기간별 현황</div>
          </div>
          <div class="menu-right">
            <div class="menu-arrow"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg></div>
          </div>
        </div>

      </div>
    </div>

    <!-- 설정 -->
    <div class="section" style="margin-top:16px;">
      <div class="section-label">설정</div>
      <div class="menu-list">

        <div class="menu-row">
          <div class="menu-icon-wrap bg-purple">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-purple">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">모순 탐지 알림</div>
            <div class="menu-sub">탐지 시 즉시 알림</div>
          </div>
          <div class="menu-right">
            <label class="toggle-wrap">
              <input type="checkbox" class="toggle-input" checked>
              <span class="toggle-slider"></span>
            </label>
          </div>
        </div>

        <div class="menu-row">
          <div class="menu-icon-wrap bg-purple">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-purple">
              <circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="5" r="2.5"/><circle cx="18" cy="19" r="2.5"/>
              <line x1="8.4" y1="11.0" x2="15.6" y2="6.5"/><line x1="8.4" y1="13.0" x2="15.6" y2="17.5"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">관계망 변경 알림</div>
            <div class="menu-sub">인물·관계 업데이트 알림</div>
          </div>
          <div class="menu-right">
            <label class="toggle-wrap">
              <input type="checkbox" class="toggle-input" checked>
              <span class="toggle-slider"></span>
            </label>
          </div>
        </div>

        <div class="menu-row">
          <div class="menu-icon-wrap bg-gray">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" class="stroke-gray">
              <circle cx="12" cy="12" r="3"/><path d="M19.07 4.93A10 10 0 1 0 4.93 19.07"/>
              <path d="M12 2v2M12 20v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M2 12h2M20 12h2"/>
            </svg>
          </div>
          <div class="menu-text">
            <div class="menu-name">야간 방해금지</div>
            <div class="menu-sub">22:00 ~ 07:00 알림 차단</div>
          </div>
          <div class="menu-right">
            <label class="toggle-wrap">
              <input type="checkbox" class="toggle-input">
              <span class="toggle-slider"></span>
            </label>
          </div>
        </div>

      </div>
    </div>

    <!-- 앱 정보 -->
    <div class="section" style="margin-top:16px;">
      <div class="section-label">앱 정보</div>
      <div class="app-info-card">
        <div class="app-name">POL-MATE</div>
        <div class="app-ver">버전 1.0.0-beta · 2025.03</div>
        <div class="app-copy" style="margin-top:10px; color:var(--text-muted);">형사사법정보지원 시스템</div>
        <div style="margin-top:14px; padding-top:14px; border-top:1px solid var(--border); display:flex; justify-content:center; gap:24px;">
          <a href="#" style="font-size:11px; color:var(--accent); text-decoration:none;">이용약관</a>
          <a href="#" style="font-size:11px; color:var(--accent); text-decoration:none;">개인정보처리방침</a>
          <a href="#" style="font-size:11px; color:var(--accent); text-decoration:none;">오픈소스 라이선스</a>
        </div>
      </div>
    </div>

    <!-- 로그아웃 -->
    <div style="padding:16px 0 8px;">
      <button class="logout-btn" onclick="confirmLogout()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
          <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
          <polyline points="16 17 21 12 16 7"/>
          <line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
        로그아웃
      </button>
    </div>

  </div><!-- /content -->

  <!-- ── 하단 네비 ── -->
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
    <a href="board.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
      <span class="nav-label">커뮤니티</span>
    </a>
    <a href="mypage.jsp" class="nav-item active">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>

</div><!-- /screen -->


<!-- ════════════════════════════════════ -->
<!-- 드로어: 프로필 편집                   -->
<!-- ════════════════════════════════════ -->
<div class="overlay" id="profileDrawer" onclick="closeOnBg(event,'profileDrawer')">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-title">프로필 정보</div>
    <div class="drawer-body">
      <div class="d-field">
        <label class="d-label">이름</label>
        <input type="text" class="d-input" id="editName" value="<%= userName %>">
      </div>
      <div class="d-field">
        <label class="d-label">계급</label>
        <select class="d-input" id="editRank">
          <% String[] ranks = {"순경","경장","경사","경위","경감","경정","총경","경무관"}; %>
          <% for(String r : ranks) { %>
            <option <%= r.equals(userRank) ? "selected" : "" %>><%= r %></option>
          <% } %>
        </select>
      </div>
      <div class="d-field">
        <label class="d-label">소속 기관</label>
        <input type="text" class="d-input" id="editOrg" value="<%= userOrg %>">
      </div>
      <div class="d-field">
        <label class="d-label">연락처</label>
        <input type="tel" class="d-input" id="editPhone" value="<%= userPhone %>">
      </div>
      <div class="d-field">
        <label class="d-label">아이디 (변경 불가)</label>
        <input type="text" class="d-input" value="<%= userId %>" disabled>
      </div>
      <button class="d-btn" onclick="saveProfile()">저장</button>
      <button class="d-btn-cancel" onclick="closeDrawer('profileDrawer')">취소</button>
    </div>
  </div>
</div>


<!-- ════════════════════════════════════ -->
<!-- 드로어: 비밀번호 변경                 -->
<!-- ════════════════════════════════════ -->
<div class="overlay" id="pwDrawer" onclick="closeOnBg(event,'pwDrawer')">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-title">비밀번호 변경</div>
    <div class="drawer-body">
      <div class="d-field">
        <label class="d-label">현재 비밀번호</label>
        <input type="password" class="d-input" id="curPw" placeholder="현재 비밀번호 입력">
      </div>
      <div class="d-field">
        <label class="d-label">새 비밀번호</label>
        <input type="password" class="d-input" id="newPw" placeholder="8자 이상, 영문+숫자+특수문자">
      </div>
      <div class="d-field">
        <label class="d-label">새 비밀번호 확인</label>
        <input type="password" class="d-input" id="newPwCf" placeholder="새 비밀번호 재입력">
      </div>
      <p id="pwChangeMsg" style="font-size:11px; color:var(--danger); margin-bottom:10px; display:none;"></p>
      <button class="d-btn" onclick="changePw()">변경 완료</button>
      <button class="d-btn-cancel" onclick="closeDrawer('pwDrawer')">취소</button>
    </div>
  </div>
</div>


<!-- ════════════════════════════════════ -->
<!-- 드로어: 내 조서 이력                  -->
<!-- ════════════════════════════════════ -->
<div class="overlay" id="historyDrawer" onclick="closeOnBg(event,'historyDrawer')">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-title">내 조서 이력</div>
    <div class="history-list">
      <div class="history-item">
        <div>
          <div class="h-title">2024-0312 절도사건</div>
          <div class="h-meta">2025.03.24 · 진술 분석 완료</div>
        </div>
        <span class="h-badge h-badge-warn">검토필요</span>
      </div>
      <div class="history-item">
        <div>
          <div class="h-title">2024-0289 폭행사건</div>
          <div class="h-meta">2025.03.21 · 조서 작성 중</div>
        </div>
        <span class="h-badge h-badge-ok">진행중</span>
      </div>
      <div class="history-item">
        <div>
          <div class="h-title">2024-0271 사기사건</div>
          <div class="h-meta">2025.03.18 · 관계망 업데이트</div>
        </div>
        <span class="h-badge h-badge-done">완료</span>
      </div>
      <div class="history-item">
        <div>
          <div class="h-title">2024-0244 협박사건</div>
          <div class="h-meta">2025.03.10 · 조서 최종 제출</div>
        </div>
        <span class="h-badge h-badge-done">완료</span>
      </div>
      <div class="history-item">
        <div>
          <div class="h-title">2024-0201 강도사건</div>
          <div class="h-meta">2025.02.28 · 조서 최종 제출</div>
        </div>
        <span class="h-badge h-badge-done">완료</span>
      </div>
    </div>
    <div style="padding:16px 20px 0;">
      <button class="d-btn-cancel" onclick="closeDrawer('historyDrawer')">닫기</button>
    </div>
  </div>
</div>


<!-- ════════════════════════════════════ -->
<!-- 드로어: 활동 통계                    -->
<!-- ════════════════════════════════════ -->
<div class="overlay" id="statsDrawer" onclick="closeOnBg(event,'statsDrawer')">
  <div class="drawer">
    <div class="drawer-handle"></div>
    <div class="drawer-title">활동 통계</div>
    <div class="drawer-body">

      <!-- 기간 선택 -->
      <div style="display:flex; gap:8px; margin-bottom:18px;">
        <button class="period-btn active" onclick="setPeriod(this,'week')">이번 주</button>
        <button class="period-btn" onclick="setPeriod(this,'month')">이번 달</button>
        <button class="period-btn" onclick="setPeriod(this,'all')">전체</button>
      </div>

      <!-- 수치 그리드 -->
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:18px;" id="statsGrid">
        <!-- JS로 채움 -->
      </div>

      <!-- 막대 차트 (순수 CSS) -->
      <div style="font-size:11px; color:var(--text-muted); margin-bottom:8px;">월별 조서 처리 현황</div>
      <div id="barChart" style="display:flex; align-items:flex-end; gap:6px; height:80px; padding-bottom:4px;">
        <!-- JS로 채움 -->
      </div>
      <div id="barLabels" style="display:flex; gap:6px; margin-top:4px;">
        <!-- JS로 채움 -->
      </div>

      <button class="d-btn-cancel" style="margin-top:18px;" onclick="closeDrawer('statsDrawer')">닫기</button>
    </div>
  </div>
</div>

<style>
  .period-btn {
    flex: 1; padding: 8px 0; font-size: 12px; font-family: 'Noto Sans KR', sans-serif;
    background: var(--bg); border: 1px solid var(--border); border-radius: 8px; cursor: pointer;
    color: var(--text-secondary); transition: all 0.15s;
  }
  .period-btn.active { background: var(--navy); color: #fff; border-color: var(--navy); }

  .stat-tile {
    background: var(--bg); border-radius: 12px; padding: 14px;
    text-align: center; border: 1px solid var(--border);
  }
  .tile-num { font-size: 24px; font-weight: 700; color: var(--navy); }
  .tile-lbl { font-size: 11px; color: var(--text-muted); margin-top: 4px; }

  .bar-col { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; }
  .bar-fill { width: 100%; border-radius: 4px 4px 0 0; background: #c7d7f0; transition: height 0.4s; }
  .bar-fill.cur { background: var(--navy); }
  .bar-lbl { font-size: 9px; color: var(--text-muted); text-align: center; flex: 0 0 auto; width: 100%; }
</style>

<script>
// ── 드로어 열기/닫기 ──────────────────────────────────────────────
function openDrawer(id) {
  document.getElementById(id).classList.add('open');
  document.body.style.overflow = 'hidden';
  if (id === 'statsDrawer') renderStats('week');
}
function closeDrawer(id) {
  document.getElementById(id).classList.remove('open');
  document.body.style.overflow = '';
}
function closeOnBg(e, id) {
  if (e.target === document.getElementById(id)) closeDrawer(id);
}

// ── 프로필 저장 (임시: alert만 띄움) ──────────────────────────────
function saveProfile() {
  alert('저장되었습니다.\n(DB 미연동 상태 — 실제 반영은 DB 연동 후 가능합니다.)');
  closeDrawer('profileDrawer');
}

// ── 비밀번호 변경 ──────────────────────────────────────────────────
const TEMP_PW = '1234'; // 임시 현재 비밀번호
function changePw() {
  const cur  = document.getElementById('curPw').value;
  const nw   = document.getElementById('newPw').value;
  const nwcf = document.getElementById('newPwCf').value;
  const msg  = document.getElementById('pwChangeMsg');
  msg.style.display = 'none';

  if (!cur)           { showPwMsg('현재 비밀번호를 입력해 주세요.'); return; }
  if (cur !== TEMP_PW){ showPwMsg('현재 비밀번호가 올바르지 않습니다.'); return; }
  if (!nw || nw.length < 8) { showPwMsg('새 비밀번호를 8자 이상 입력해 주세요.'); return; }
  if (nw !== nwcf)    { showPwMsg('새 비밀번호가 일치하지 않습니다.'); return; }

  alert('비밀번호가 변경되었습니다.\n(DB 미연동 상태 — 실제 반영은 DB 연동 후 가능합니다.)');
  document.getElementById('curPw').value  = '';
  document.getElementById('newPw').value  = '';
  document.getElementById('newPwCf').value= '';
  closeDrawer('pwDrawer');
}
function showPwMsg(m) {
  const el = document.getElementById('pwChangeMsg');
  el.textContent = m;
  el.style.display = 'block';
}

// ── 로그아웃 ──────────────────────────────────────────────────────
function confirmLogout() {
  if (confirm('로그아웃 하시겠습니까?')) {
    // 세션 만료 처리는 LogoutServlet으로 (DB 연동 후)
    location.href = 'login.jsp';
  }
}

// ── 통계 렌더링 ───────────────────────────────────────────────────
const STATS = {
  week:  { cases:3,  docs:4,  contra:1, proc:2 },
  month: { cases:12, docs:18, contra:3, proc:7 },
  all:   { cases:43, docs:28, contra:9, proc:22 }
};
const BAR_DATA = {
  week:  [2,3,1,4,2,3,4],
  month: [5,8,12,7,10,14,18],
  all:   [15,22,18,25,30,28,35]
};
const BAR_LABELS = {
  week:  ['월','화','수','목','금','토','일'],
  month: ['10월','11월','12월','1월','2월','3월','이번달'],
  all:   ['2023','상반기','하반기','1Q','2Q','3Q','현재']
};

function renderStats(period) {
  const s = STATS[period];
  document.getElementById('statsGrid').innerHTML =
    '<div class="stat-tile"><div class="tile-num">' + s.cases  + '</div><div class="tile-lbl">담당 사건</div></div>' +
    '<div class="stat-tile"><div class="tile-num">' + s.docs   + '</div><div class="tile-lbl">조서 처리</div></div>' +
    '<div class="stat-tile"><div class="tile-num">' + s.contra + '</div><div class="tile-lbl">모순 탐지</div></div>' +
    '<div class="stat-tile"><div class="tile-num">' + s.proc   + '</div><div class="tile-lbl">관계망 등록</div></div>';
  const data   = BAR_DATA[period];
  const labels = BAR_LABELS[period];
  const mx     = Math.max(...data);
  document.getElementById('barChart').innerHTML = data.map(function(v,i) {
    var cls = (i===data.length-1) ? 'cur' : '';
    var h   = Math.round(v/mx*68);
    return '<div class="bar-col"><div class="bar-fill ' + cls + '" style="height:' + h + 'px;"></div></div>';
  }).join('');
  document.getElementById('barLabels').innerHTML = labels.map(function(l) {
    return '<div style="flex:1; font-size:9px; color:var(--text-muted); text-align:center;">' + l + '</div>';
  }).join('');
}

function setPeriod(btn, period) {
  document.querySelectorAll('.period-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  renderStats(period);
}
</script>

</body>
</html>
