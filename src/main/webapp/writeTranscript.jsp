<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Servlet.DBConnectionMgr, java.sql.*" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String userName  = (String) session.getAttribute("userName");
    if (loginUser == null) { response.sendRedirect("login.jsp"); return; }

    // 내 사건 + 같은 부서(dept_id) 팀원 사건 목록 조회 (드롭다운용)
    DBConnectionMgr _mgr = DBConnectionMgr.getInstance();
    Connection _conn = null;
    PreparedStatement _ps = null;
    ResultSet _rs = null;
    StringBuilder caseOptions = new StringBuilder();
    try {
        _conn = _mgr.getConnection();
        _ps = _conn.prepareStatement(
            "SELECT c.case_id, c.case_name FROM cases c " +
            "WHERE (c.user_id = ? " +
            "   OR c.user_id IN ( " +
            "       SELECT u2.user_id FROM users u2 " +
            "       JOIN users me ON me.user_id = ? " +
            "       WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL " +
            "   )) " +
            "ORDER BY c.updated_at DESC");
        _ps.setString(1, loginUser);
        _ps.setString(2, loginUser);
        _rs = _ps.executeQuery();
        while (_rs.next()) {
            caseOptions.append("<option value=\"")
                .append(_rs.getString("case_id")).append("\">")
                .append(_rs.getString("case_id")).append(" · ")
                .append(_rs.getString("case_name"))
                .append("</option>");
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally { _mgr.freeConnection(_conn, _ps, _rs); }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 조서 작성</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  :root {
    --navy:#1a2744; --accent:#4a7cdc; --danger:#e74c3c;
    --text-primary:#1a1a2e; --text-secondary:#6b7280; --text-muted:#9ca3af;
    --bg:#f4f6fb; --card:#ffffff; --border:#e5e7eb;
    --success:#16a34a; --success-bg:#f0fdf4; --success-border:#bbf7d0;
    --warn-bg:#fffbeb; --warn-border:#fde68a;
    --danger-bg:#fef2f2; --danger-border:#fecaca;
    --bottom-nav-h:64px;
  }
  html,body { height:100%; font-family:'Noto Sans KR',sans-serif; background:var(--bg); overflow-x:hidden; }
  .screen { width:100%; max-width:420px; min-height:100vh; margin:0 auto; background:var(--bg); display:flex; flex-direction:column; }

  /* ── 헤더 ── */
  .top-header {
    background:var(--navy); padding:52px 20px 20px;
    display:flex; align-items:center; gap:12px;
    position:sticky; top:0; z-index:10;
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

  /* ── 진행 단계 ── */
  .step-flow {
    display:flex; align-items:center;
    background:var(--card); border-radius:14px; border:1px solid var(--border);
    padding:14px 16px; margin-bottom:14px;
  }
  .step-node { display:flex; flex-direction:column; align-items:center; flex:1; gap:5px; }
  .step-circle {
    width:32px; height:32px; border-radius:50%; border:2px solid var(--border);
    display:flex; align-items:center; justify-content:center;
    font-size:12px; font-weight:500; color:var(--text-muted);
    background:var(--bg); transition:all 0.3s;
  }
  .step-circle.active { background:var(--navy); border-color:var(--navy); color:#fff; }
  .step-circle.done   { background:var(--accent); border-color:var(--accent); color:#fff; }
  .step-circle svg    { width:14px; height:14px; }
  .step-name          { font-size:9px; color:var(--text-muted); text-align:center; }
  .step-name.active   { color:var(--navy); font-weight:500; }
  .step-line          { flex:1; height:1px; background:var(--border); margin-bottom:14px; }

  /* ── 카드 ── */
  .content { flex:1; overflow-y:auto; padding:20px 16px calc(var(--bottom-nav-h)+20px); }
  .card {
    background:var(--card); border-radius:16px; border:1px solid var(--border);
    padding:20px; margin-bottom:14px; animation:fadeUp 0.35s ease both;
  }
  .card-title {
    font-size:12px; font-weight:500; color:var(--text-secondary);
    text-transform:uppercase; letter-spacing:0.6px;
    margin-bottom:14px; display:flex; align-items:center; gap:7px;
  }
  .card-title svg { width:14px; height:14px; stroke:var(--text-muted); }

  /* ── 폼 필드 ── */
  .field-row   { display:flex; gap:10px; margin-bottom:10px; }
  .field-half  { flex:1; }
  .field-label { font-size:11px; font-weight:500; color:var(--text-secondary); display:block; margin-bottom:5px; }
  .field-req   { color:var(--danger); }
  .field-input {
    width:100%; padding:10px 12px; background:var(--bg);
    border:1px solid var(--border); border-radius:10px;
    font-size:13px; font-family:'Noto Sans KR',sans-serif;
    color:var(--text-primary); outline:none; transition:border-color 0.2s;
  }
  .field-input:focus { border-color:var(--accent); background:#fff; }
  .field-input::placeholder { color:var(--text-muted); font-size:12px; }
  select.field-input { appearance:none; }

  /* ── 음성 업로드 ── */
  .upload-zone {
    border:2px dashed var(--border); border-radius:14px;
    padding:28px 20px; text-align:center; cursor:pointer;
    transition:border-color 0.2s,background 0.2s; position:relative;
  }
  .upload-zone:hover,.upload-zone.drag { border-color:var(--accent); background:#f0f5ff; }
  .upload-zone input { position:absolute; inset:0; opacity:0; cursor:pointer; width:100%; height:100%; }
  .upload-icon {
    width:48px; height:48px; background:#eff6ff; border-radius:50%;
    margin:0 auto 10px; display:flex; align-items:center; justify-content:center;
  }
  .upload-icon svg { width:22px; height:22px; stroke:var(--accent); }
  .upload-title { font-size:13px; font-weight:500; color:var(--text-primary); margin-bottom:3px; }
  .upload-desc  { font-size:11px; color:var(--text-muted); }
  .upload-hint  { font-size:10px; color:var(--text-muted); margin-top:8px; }

  .file-selected {
    background:var(--success-bg); border:1px solid var(--success-border);
    border-radius:12px; padding:13px 15px; display:none;
    align-items:center; gap:12px; margin-top:12px;
  }
  .file-icon { width:34px; height:34px; background:#dcfce7; border-radius:9px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  .file-icon svg { width:16px; height:16px; stroke:var(--success); }
  .file-meta { flex:1; min-width:0; }
  .file-name { font-size:13px; font-weight:500; color:var(--text-primary); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .file-size { font-size:10px; color:var(--text-muted); margin-top:2px; }
  .file-remove { width:24px; height:24px; border-radius:50%; background:#fef2f2; border:none; cursor:pointer; display:flex; align-items:center; justify-content:center; }
  .file-remove svg { width:12px; height:12px; stroke:var(--danger); }

  /* ── OR 구분선 ── */
  .divider { display:flex; align-items:center; gap:10px; margin:14px 0; }
  .divider span { font-size:11px; color:var(--text-muted); white-space:nowrap; }
  .divider::before,.divider::after { content:''; flex:1; height:1px; background:var(--border); }

  /* ── 텍스트 영역 ── */
  .text-area {
    width:100%; min-height:160px; padding:13px 14px;
    background:var(--bg); border:1px solid var(--border); border-radius:12px;
    font-size:13px; font-family:'Noto Sans KR',sans-serif;
    color:var(--text-primary); outline:none; resize:vertical; line-height:1.8;
    transition:border-color 0.2s;
  }
  .text-area:focus { border-color:var(--accent); background:#fff; }
  .text-area::placeholder { color:var(--text-muted); font-size:12px; }

  /* ── 저장 버튼 ── */
  .btn-save {
    width:100%; background:var(--navy); color:#fff; border:none;
    border-radius:14px; padding:16px; font-size:15px; font-weight:500;
    font-family:'Noto Sans KR',sans-serif; cursor:pointer;
    display:flex; align-items:center; justify-content:center; gap:9px;
    transition:transform 0.1s,background 0.2s; margin-bottom:10px;
  }
  .btn-save:active { transform:scale(0.98); }
  .btn-save svg { width:18px; height:18px; stroke:#fff; }

  .btn-reset {
    width:100%; background:var(--bg); color:var(--text-secondary);
    border:1px solid var(--border); border-radius:14px; padding:14px;
    font-size:14px; font-family:'Noto Sans KR',sans-serif; cursor:pointer;
  }

  /* ── 저장 완료 화면 ── */
  .save-done { display:none; }
  .save-done-icon {
    width:64px; height:64px; border-radius:50%; background:var(--success-bg);
    margin:0 auto 16px; display:flex; align-items:center; justify-content:center;
  }
  .save-done-icon svg { width:32px; height:32px; stroke:var(--success); }

  /* ── 토스트 ── */
  #toast {
    position:fixed; bottom:84px; left:50%; transform:translateX(-50%) translateY(20px);
    background:var(--navy); color:#fff; padding:10px 20px; border-radius:24px;
    font-size:13px; opacity:0; transition:all 0.3s; pointer-events:none; z-index:999;
    white-space:nowrap; font-family:'Noto Sans KR',sans-serif;
  }

  /* ── 하단 네비 ── */
  .bottom-nav {
    position:fixed; bottom:0; left:50%; transform:translateX(-50%);
    width:100%; max-width:420px; height:var(--bottom-nav-h);
    background:var(--card); border-top:1px solid var(--border);
    display:flex; justify-content:space-around; align-items:center;
    padding:0 8px; z-index:100;
  }
  .nav-item { display:flex; flex-direction:column; align-items:center; gap:3px; flex:1; cursor:pointer; text-decoration:none; padding:6px 0; }
  .nav-icon  { width:24px; height:24px; display:flex; align-items:center; justify-content:center; }
  .nav-icon svg { width:22px; height:22px; }
  .nav-label { font-size:9px; }
  .nav-item.active .nav-icon svg { stroke:var(--navy); }
  .nav-item.active .nav-label    { color:var(--navy); font-weight:500; }
  .nav-item:not(.active) .nav-icon svg { stroke:var(--text-muted); }
  .nav-item:not(.active) .nav-label    { color:var(--text-muted); }

  @keyframes fadeUp { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
  @keyframes spin   { to{transform:rotate(360deg)} }
  @media(min-width:421px){ .screen{box-shadow:0 0 40px rgba(0,0,0,0.1);} }

  .case-detail-box {
    margin-top:12px; padding:12px 14px; background:var(--bg); border-radius:10px;
    border:1px solid var(--border); font-size:12px; display:none;
  }
  .case-detail-box.show { display:block; }
  .case-detail-row { display:flex; justify-content:space-between; align-items:flex-start; gap:10px; margin-bottom:8px; }
  .case-detail-row:last-child { margin-bottom:0; }
  .case-detail-key { color:var(--text-muted); flex-shrink:0; font-size:11px; }
  .case-detail-val { color:var(--text-primary); text-align:right; word-break:break-word; flex:1; }
</style>
</head>
<body>
<div class="screen">

  <!-- 헤더 -->
  <div class="top-header">
    <button class="back-btn" onclick="history.back()">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <div class="header-text">
      <div class="header-title">조서 작성</div>
      <div class="header-sub">음성 변환 · 직접 입력 · DB 저장</div>
    </div>
  </div>

  <div class="content">

    <!-- 진행 단계 -->
    <div class="step-flow" id="stepFlow">
      <div class="step-node">
        <div class="step-circle active" id="sc1">1</div>
        <div class="step-name active"   id="sn1">사건 선택</div>
      </div>
      <div class="step-line"></div>
      <div class="step-node">
        <div class="step-circle" id="sc2">2</div>
        <div class="step-name"   id="sn2">내용 입력</div>
      </div>
      <div class="step-line"></div>
      <div class="step-node">
        <div class="step-circle" id="sc3">3</div>
        <div class="step-name"   id="sn3">저장 완료</div>
      </div>
    </div>

    <!-- ══════════════════ 입력 섹션 ══════════════════ -->
    <div id="inputSection">

      <!-- 사건 정보 -->
      <div class="card" style="animation-delay:0.05s">
        <div class="card-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 9h6M9 12h6M9 15h4"/></svg>
          사건 정보
        </div>

        <!-- 사건 선택 드롭다운 (내 사건 + 같은 부서 팀원 사건) -->
        <div style="margin-bottom:10px;">
          <label class="field-label">담당 사건 <span class="field-req">*</span></label>
          <select class="field-input" id="caseId">
            <option value="">— 사건을 선택하세요 —</option>
            <%= caseOptions.toString() %>
          </select>
        </div>
        <div id="caseDetailBox" class="case-detail-box" aria-live="polite"></div>

        <div class="field-row">
          <div class="field-half">
            <label class="field-label">진술 유형 <span class="field-req">*</span></label>
            <select class="field-input" id="stmtType">
              <option value="피의자">피의자 진술</option>
              <option value="피해자">피해자 진술</option>
              <option value="목격자">목격자 진술</option>
              <option value="참고인">참고인 진술</option>
            </select>
          </div>
          <div class="field-half">
            <label class="field-label">진술자 성명</label>
            <input type="text" class="field-input" id="stmtName" placeholder="이름">
          </div>
        </div>
      </div>

      <!-- 음성 파일 업로드 -->
      <div class="card" style="animation-delay:0.1s">
        <div class="card-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" y1="19" x2="12" y2="23"/><line x1="8" y1="23" x2="16" y2="23"/></svg>
          음성 파일 업로드
          <span style="font-size:9px;background:#eff6ff;color:#1e40af;border-radius:4px;padding:2px 6px;margin-left:auto;font-weight:400;">CLOVA Speech API</span>
        </div>

        <div class="upload-zone" id="uploadZone"
             ondragover="event.preventDefault();this.classList.add('drag')"
             ondragleave="this.classList.remove('drag')"
             ondrop="handleDrop(event)">
          <input type="file" id="audioFile" accept=".mp3,.wav,.m4a,.ogg,.webm" onchange="handleFile(this)">
          <div class="upload-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><polyline points="16 16 12 12 8 16"/><line x1="12" y1="12" x2="12" y2="21"/><path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3"/></svg>
          </div>
          <div class="upload-title">음성 파일을 업로드하세요</div>
          <div class="upload-desc">클릭하거나 파일을 드래그하세요</div>
          <div class="upload-hint">지원 형식: MP3, WAV, M4A, OGG, WEBM · 최대 100MB</div>
        </div>

        <div class="file-selected" id="fileSelected">
          <div class="file-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/></svg>
          </div>
          <div class="file-meta">
            <div class="file-name" id="fileName">-</div>
            <div class="file-size" id="fileSize">-</div>
          </div>
          <button class="file-remove" onclick="removeFile()">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <!-- STT 변환 버튼 -->
        <div id="sttBtnWrap" style="display:none;margin-top:10px;">
          <button onclick="convertStt()" id="sttBtn"
            style="width:100%;background:#1e40af;color:#fff;border:none;border-radius:12px;
                   padding:12px;font-size:13px;font-weight:500;font-family:'Noto Sans KR',sans-serif;
                   cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;">
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" style="width:16px;height:16px;"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/></svg>
            CLOVA Speech로 텍스트 변환
          </button>
          <div id="sttLoading" style="display:none;text-align:center;padding:10px;font-size:12px;color:#1e40af;">
            <span id="sttLoadingMsg">음성 파일을 CLOVA에 전송 중...</span>
          </div>
        </div>
      </div>

      <!-- 텍스트 직접 입력 -->
      <div class="card" style="animation-delay:0.15s">
        <div class="card-title">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><line x1="17" y1="10" x2="3" y2="10"/><line x1="21" y1="6" x2="3" y2="6"/><line x1="21" y1="14" x2="3" y2="14"/><line x1="17" y1="18" x2="3" y2="18"/></svg>
          진술 텍스트 입력 <span class="field-req">*</span>
          <span style="font-size:9px;background:#f0fdf4;color:#166534;border-radius:4px;padding:2px 6px;margin-left:auto;font-weight:400;">직접 입력 가능</span>
        </div>
        <textarea class="text-area" id="stmtText"
          placeholder="진술 내용을 입력하거나 위에서 음성 변환 후 자동으로 채워집니다.&#10;&#10;예) 저는 3월 15일 오후 2시에 집에 있었습니다..."></textarea>
        <div style="display:flex;justify-content:flex-end;margin-top:6px;">
          <span style="font-size:10px;color:var(--text-muted);" id="charCount">0자</span>
        </div>
      </div>

      <!-- 저장 버튼 -->
      <button class="btn-save" id="saveBtn" onclick="saveTranscript()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
        저장
      </button>
      <button class="btn-reset" onclick="resetAll()">초기화</button>

    </div><!-- /inputSection -->

    <!-- ══════════════════ 저장 완료 섹션 ══════════════════ -->
    <div id="doneSection" class="save-done">
      <div class="card" style="text-align:center;padding:36px 20px;">
        <div class="save-done-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <div style="font-size:16px;font-weight:600;color:var(--text-primary);margin-bottom:8px;">조서가 저장됐습니다</div>
        <div id="doneSummary" style="font-size:12px;color:var(--text-muted);line-height:1.8;margin-bottom:24px;"></div>

        <div style="display:flex;flex-direction:column;gap:10px;">
          <button onclick="location.href='myCase.jsp'" class="btn-save" style="margin-bottom:0;">
            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            내 조서 관리로 이동
          </button>
          <button onclick="resetAll()" class="btn-reset">새 조서 작성</button>
        </div>
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
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
      <span class="nav-label">커뮤니티</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>
</div>

<div id="toast"></div>

<script>
/* ══════════════════════════════════════════════════════
   담당 사건 상세 (caseApi caseDetail)
══════════════════════════════════════════════════════ */
var lastCaseDetail = null;

function clearCaseDetailSummary() {
  lastCaseDetail = null;
  var box = document.getElementById('caseDetailBox');
  box.classList.remove('show');
  box.innerHTML = '';
}

function renderCaseDetailSummary(c) {
  lastCaseDetail = c;
  var box = document.getElementById('caseDetailBox');
  var rows =
    '<div class="case-detail-row"><span class="case-detail-key">사건명</span><span class="case-detail-val">' + escHtml(c.name) + '</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">피의자</span><span class="case-detail-val">' + escHtml(c.suspect || '미입력') + '</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">적용 법조</span><span class="case-detail-val">' + escHtml(c.charge || '미입력') + '</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">상태</span><span class="case-detail-val">' + escHtml(c.status || '') + '</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">진행률</span><span class="case-detail-val">' + (c.progress != null ? c.progress : 0) + '%</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">등록 조서</span><span class="case-detail-val">' + (c.docCount != null ? c.docCount : 0) + '건</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">담당</span><span class="case-detail-val">' + escHtml((c.detective || '') + (c.rank ? ' (' + c.rank + ')' : '')) + '</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">부서</span><span class="case-detail-val">' + escHtml(c.deptName || '미배정') + '</span></div>' +
    '<div class="case-detail-row"><span class="case-detail-key">최종 수정</span><span class="case-detail-val">' + escHtml(c.date || '') + '</span></div>';
  box.innerHTML = rows;
  box.classList.add('show');
}

function loadCaseDetailForSelect() {
  var id = document.getElementById('caseId').value.trim();
  if (!id) {
    clearCaseDetailSummary();
    return;
  }
  var box = document.getElementById('caseDetailBox');
  box.classList.add('show');
  box.innerHTML = '<div style="color:var(--text-muted);font-size:11px;">사건 정보를 불러오는 중...</div>';
  fetch('caseApi?action=caseDetail&caseId=' + encodeURIComponent(id))
    .then(function(r) { return r.json(); })
    .then(function(c) {
      if (c.error) {
        clearCaseDetailSummary();
        showToast(c.error);
        return;
      }
      renderCaseDetailSummary(c);
    })
    .catch(function() {
      clearCaseDetailSummary();
      showToast('사건 정보 조회에 실패했습니다.');
    });
}

function initCaseFromUrl() {
  var pre = new URLSearchParams(window.location.search).get('caseId');
  if (!pre) return;
  var sel = document.getElementById('caseId');
  var hasOpt = Array.prototype.some.call(sel.options, function(o) { return o.value === pre; });
  if (hasOpt) {
    sel.value = pre;
    loadCaseDetailForSelect();
    return;
  }
  fetch('caseApi?action=caseDetail&caseId=' + encodeURIComponent(pre))
    .then(function(r) { return r.json(); })
    .then(function(c) {
      if (c.error) {
        showToast(c.error || '사건을 불러올 수 없습니다.');
        return;
      }
      var opt = document.createElement('option');
      opt.value = c.id;
      opt.textContent = c.id + ' · ' + (c.name || '');
      sel.appendChild(opt);
      sel.value = c.id;
      renderCaseDetailSummary(c);
    })
    .catch(function() {
      showToast('사건 정보를 불러오지 못했습니다.');
    });
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('caseId').addEventListener('change', loadCaseDetailForSelect);
  initCaseFromUrl();
});

/* ══════════════════════════════════════════════════════
   파일 처리
══════════════════════════════════════════════════════ */
function handleFile(input) {
  if (!input.files || !input.files[0]) return;
  showFile(input.files[0]);
}
function handleDrop(e) {
  e.preventDefault();
  document.getElementById('uploadZone').classList.remove('drag');
  var f = e.dataTransfer.files[0];
  if (f) showFile(f);
}
function showFile(f) {
  document.getElementById('fileName').textContent = f.name;
  document.getElementById('fileSize').textContent = formatSize(f.size);
  document.getElementById('fileSelected').style.display = 'flex';
  document.getElementById('sttBtnWrap').style.display   = 'block';
}
function removeFile() {
  document.getElementById('audioFile').value             = '';
  document.getElementById('fileSelected').style.display  = 'none';
  document.getElementById('sttBtnWrap').style.display    = 'none';
  document.getElementById('sttLoading').style.display    = 'none';
}
function formatSize(b) {
  if (b < 1024*1024) return (b/1024).toFixed(1) + ' KB';
  return (b/(1024*1024)).toFixed(1) + ' MB';
}

/* ══════════════════════════════════════════════════════
   CLOVA STT 변환 (SttServlet 호출)
══════════════════════════════════════════════════════ */
function convertStt() {
  var fileInput = document.getElementById('audioFile');
  if (!fileInput.files || !fileInput.files[0]) {
    showToast('음성 파일을 선택해 주세요.');
    return;
  }

  var sttBtn     = document.getElementById('sttBtn');
  var sttLoading = document.getElementById('sttLoading');
  var sttMsg     = document.getElementById('sttLoadingMsg');

  sttBtn.style.display     = 'none';
  sttLoading.style.display = 'block';
  sttLoading.style.color   = '#1e40af';
  sttMsg.textContent       = '음성 파일을 CLOVA Speech에 전송 중...';

  var formData = new FormData();
  formData.append('audioFile', fileInput.files[0]);
  formData.append('language',  'Kor');

  fetch('stt', { method:'POST', body:formData })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      sttLoading.style.display = 'none';
      sttBtn.style.display     = 'flex';
      if (data.success) {
        document.getElementById('stmtText').value = data.text;
        document.getElementById('charCount').textContent = data.text.length + '자';
        sttLoading.style.display = 'block';
        sttLoading.style.color   = '#16a34a';
        sttMsg.textContent       = '✓ 변환 완료! 아래 텍스트를 확인하고 저장하세요.';
        setTimeout(function() { sttLoading.style.display = 'none'; }, 3000);
        setStep(2);
      } else {
        showToast(data.error || 'STT 변환에 실패했습니다.');
      }
    })
    .catch(function(err) {
      sttLoading.style.display = 'none';
      sttBtn.style.display     = 'flex';
      showToast('네트워크 오류: SttServlet을 확인해 주세요.');
    });
}

/* ══════════════════════════════════════════════════════
   글자수 카운트
══════════════════════════════════════════════════════ */
document.getElementById('stmtText').addEventListener('input', function() {
  document.getElementById('charCount').textContent = this.value.length + '자';
  if (this.value.length > 0) setStep(2);
  else setStep(1);
});

/* ══════════════════════════════════════════════════════
   저장
══════════════════════════════════════════════════════ */
function saveTranscript() {
  var caseId       = document.getElementById('caseId').value.trim();
  var stmtType     = document.getElementById('stmtType').value;
  var stmtName     = document.getElementById('stmtName').value.trim();
  var originalText = document.getElementById('stmtText').value.trim();

  if (!caseId)       { showToast('담당 사건을 선택해 주세요.');    return; }
  if (!originalText) { showToast('진술 내용을 입력해 주세요.');    return; }

  var saveBtn = document.getElementById('saveBtn');
  saveBtn.disabled = true;
  saveBtn.textContent = '저장 중...';

  var params = new URLSearchParams();
  params.append('action',       'transcriptSave');
  params.append('caseId',       caseId);
  params.append('stmtType',     stmtType);
  params.append('stmtName',     stmtName);
  params.append('originalText', originalText);

  fetch('caseApi', {
    method:  'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    params.toString()
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      setStep(3);
      document.getElementById('inputSection').style.display = 'none';
      document.getElementById('doneSection').style.display  = 'block';
      var caseLine = '사건: <b>' + escHtml(caseId) + '</b>';
      if (lastCaseDetail && lastCaseDetail.name) {
        caseLine += ' · <b>' + escHtml(lastCaseDetail.name) + '</b>';
      }
      document.getElementById('doneSummary').innerHTML =
        caseLine + '<br>' +
        '진술 유형: <b>' + escHtml(stmtType) + '</b><br>' +
        '진술자: <b>' + (stmtName || '미입력') + '</b><br>' +
        '글자 수: <b>' + originalText.length.toLocaleString() + '자</b>';
      window.scrollTo(0, 0);
    } else {
      showToast(d.message || '저장 실패');
      saveBtn.disabled = false;
      saveBtn.innerHTML =
        '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" style="width:18px;height:18px;stroke:#fff"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>저장';
    }
  })
  .catch(function(e) {
    console.error(e);
    showToast('네트워크 오류가 발생했습니다.');
    saveBtn.disabled = false;
    saveBtn.textContent = '저장';
  });
}

/* ══════════════════════════════════════════════════════
   초기화
══════════════════════════════════════════════════════ */
function resetAll() {
  document.getElementById('inputSection').style.display = 'block';
  document.getElementById('doneSection').style.display  = 'none';
  clearCaseDetailSummary();
  document.getElementById('caseId').value               = '';
  document.getElementById('stmtName').value             = '';
  document.getElementById('stmtText').value             = '';
  document.getElementById('charCount').textContent      = '0자';
  document.getElementById('saveBtn').disabled           = false;
  document.getElementById('saveBtn').innerHTML =
    '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" style="width:18px;height:18px;stroke:#fff"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>저장';
  removeFile();
  setStep(1);
  window.scrollTo(0, 0);
}

/* ══════════════════════════════════════════════════════
   유틸
══════════════════════════════════════════════════════ */
function setStep(n) {
  for (var i = 1; i <= 3; i++) {
    var c = document.getElementById('sc'+i);
    var s = document.getElementById('sn'+i);
    if      (i < n)  { c.className = 'step-circle done';   s.className = 'step-name'; }
    else if (i === n){ c.className = 'step-circle active'; s.className = 'step-name active'; }
    else             { c.className = 'step-circle';        s.className = 'step-name'; }
  }
}

function escHtml(s) {
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.style.opacity   = '1';
  t.style.transform = 'translateX(-50%) translateY(0)';
  setTimeout(function() {
    t.style.opacity   = '0';
    t.style.transform = 'translateX(-50%) translateY(20px)';
  }, 2300);
}
</script>
</body>
</html>
