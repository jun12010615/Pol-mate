<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 회원가입</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
  :root {
    --navy: #1a2744; --accent: #4a7cdc; --danger: #e74c3c;
    --text-primary: #1a1a2e; --text-secondary: #6b7280; --text-muted: #9ca3af;
    --bg: #f4f6fb; --card: #ffffff; --border: #e5e7eb; --success: #16a34a;
  }
  html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: var(--bg); }

  .screen { width: 100%; max-width: 420px; min-height: 100vh; margin: 0 auto; background: var(--bg); display: flex; flex-direction: column; }

  .top-bar {
    background: var(--navy); padding: 52px 20px 18px;
    display: flex; align-items: center; gap: 12px; position: sticky; top: 0; z-index: 10;
  }
  .back-btn {
    width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.12);
    border: none; display: flex; align-items: center; justify-content: center; cursor: pointer;
  }
  .back-btn svg { width: 18px; height: 18px; stroke: #fff; }
  .top-title { font-size: 16px; font-weight: 500; color: #fff; }

  .content { flex: 1; padding: 24px 20px 40px; }

  .step-bar {
    display: flex; align-items: center; margin-bottom: 28px; gap: 0;
  }
  .step { display: flex; flex-direction: column; align-items: center; flex: 1; }
  .step-circle {
    width: 28px; height: 28px; border-radius: 50%; font-size: 12px; font-weight: 500;
    display: flex; align-items: center; justify-content: center;
    border: 2px solid var(--border); color: var(--text-muted); background: var(--card);
    transition: all 0.3s;
  }
  .step-circle.active { background: var(--navy); border-color: var(--navy); color: #fff; }
  .step-circle.done   { background: var(--accent); border-color: var(--accent); color: #fff; }
  .step-label { font-size: 9px; color: var(--text-muted); margin-top: 4px; }
  .step-label.active { color: var(--navy); font-weight: 500; }
  .step-line { flex: 1; height: 1px; background: var(--border); margin-bottom: 16px; }

  .card { background: var(--card); border-radius: 16px; padding: 20px; border: 1px solid var(--border); margin-bottom: 16px; }
  .card-title { font-size: 13px; font-weight: 500; color: var(--navy); margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid var(--border); }

  .field-group { margin-bottom: 14px; }
  .field-label { font-size: 11px; font-weight: 500; color: var(--text-secondary); display: block; margin-bottom: 6px; }
  .required { color: #ef4444; margin-left: 2px; }

  .field-wrap { position: relative; }
  .field-wrap svg { position: absolute; left: 13px; top: 50%; transform: translateY(-50%); width: 15px; height: 15px; color: var(--text-muted); pointer-events: none; }
  .field-input {
    width: 100%; padding: 12px 12px 12px 38px;
    background: var(--bg); border: 1px solid var(--border); border-radius: 10px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif; color: var(--text-primary); outline: none;
    transition: border-color 0.2s;
  }
  .field-input:focus { border-color: var(--accent); background: #fff; }
  .field-input::placeholder { color: var(--text-muted); font-size: 12px; }
  .field-input.no-icon { padding-left: 12px; }

  .inline-row { display: flex; gap: 8px; }
  .inline-row .field-input { flex: 1; }
  .btn-check {
    background: var(--navy); color: #fff; border: none; border-radius: 10px;
    padding: 0 14px; font-size: 12px; font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer; white-space: nowrap; font-weight: 500;
  }
  .btn-check:active { opacity: 0.8; }

  .field-hint { font-size: 10px; color: var(--text-muted); margin-top: 5px; }
  .field-ok   { font-size: 10px; color: var(--success); margin-top: 5px; display: none; }
  .field-err  { font-size: 10px; color: var(--danger);  margin-top: 5px; display: none; }

  select.field-input { padding-left: 12px; appearance: none; }

  .btn-submit {
    width: 100%; background: var(--navy); color: #fff; border: none;
    border-radius: 12px; padding: 15px; font-size: 15px; font-weight: 500;
    font-family: 'Noto Sans KR', sans-serif; cursor: pointer; letter-spacing: 0.5px;
    transition: background 0.2s, transform 0.1s;
  }
  .btn-submit:active { transform: scale(0.98); }

  .agree-box {
    background: var(--card); border-radius: 16px; padding: 18px 20px;
    border: 1px solid var(--border); margin-bottom: 20px;
  }
  .agree-all {
    display: flex; align-items: center; gap: 10px; padding-bottom: 12px;
    border-bottom: 1px solid var(--border); margin-bottom: 12px; cursor: pointer;
  }
  .agree-item { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; cursor: pointer; }
  .agree-item:last-child { margin-bottom: 0; }

  .chk { width: 18px; height: 18px; border-radius: 5px; border: 1.5px solid var(--border); flex-shrink: 0; display: flex; align-items: center; justify-content: center; transition: all 0.15s; }
  .chk.checked { background: var(--navy); border-color: var(--navy); }
  .chk svg { width: 10px; height: 10px; stroke: #fff; display: none; }
  .chk.checked svg { display: block; }

  .agree-text { font-size: 12px; color: var(--text-secondary); flex: 1; }
  .agree-text strong { color: var(--text-primary); font-weight: 500; }
  .agree-view { font-size: 11px; color: var(--accent); margin-left: auto; }

  .notice-box {
    background: #fffbeb; border: 1px solid #f59e0b; border-radius: 10px;
    padding: 12px 14px; margin-bottom: 20px; font-size: 11px; color: #92400e; line-height: 1.7;
  }

  /* 완료 화면 */
  .done-screen { display: none; text-align: center; padding: 60px 20px; }
  .done-icon {
    width: 72px; height: 72px; background: #f0fdf4; border-radius: 50%;
    margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;
  }
  .done-icon svg { width: 36px; height: 36px; stroke: var(--success); }
  .done-title { font-size: 20px; font-weight: 700; color: var(--navy); margin-bottom: 8px; }
  .done-desc  { font-size: 13px; color: var(--text-secondary); line-height: 1.8; margin-bottom: 32px; }

  @keyframes fadeUp { from { opacity:0; transform: translateY(12px); } to { opacity:1; transform: translateY(0); } }
  .card { animation: fadeUp 0.35s ease both; }

  @media (min-width: 421px) {
    .screen { box-shadow: 0 0 40px rgba(0,0,0,0.1); }
  }
</style>
</head>
<body>
<div class="screen">

  <div class="top-bar">
    <button class="back-btn" onclick="history.back()">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <span class="top-title">수사관 계정 등록</span>
  </div>

  <div class="content" id="formContent">

    <!-- 단계 표시 -->
    <div class="step-bar">
      <div class="step">
        <div class="step-circle active" id="s1">1</div>
        <div class="step-label active" id="sl1">기본 정보</div>
      </div>
      <div class="step-line"></div>
      <div class="step">
        <div class="step-circle" id="s2">2</div>
        <div class="step-label" id="sl2">소속 정보</div>
      </div>
      <div class="step-line"></div>
      <div class="step">
        <div class="step-circle" id="s3">3</div>
        <div class="step-label" id="sl3">약관 동의</div>
      </div>
    </div>

    <!-- STEP 1 -->
    <div id="step1">
      <div class="card">
        <div class="card-title">계정 정보 입력</div>

        <div class="field-group">
          <label class="field-label">아이디 <span class="required">*</span></label>
          <div class="inline-row">
            <div class="field-wrap" style="flex:1">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              <input type="text" id="userId" class="field-input" placeholder="영문, 숫자 4~16자">
            </div>
            <button class="btn-check" onclick="checkId()">중복확인</button>
          </div>
          <p class="field-hint" id="idHint">영문 소문자 + 숫자 조합, 4~16자</p>
          <p class="field-ok"  id="idOk">사용 가능한 아이디입니다.</p>
          <p class="field-err" id="idErr">이미 사용 중인 아이디입니다.</p>
        </div>

        <div class="field-group">
          <label class="field-label">비밀번호 <span class="required">*</span></label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            <input type="password" id="userPw" class="field-input" placeholder="8자 이상, 영문+숫자+특수문자" oninput="checkPwStrength()">
          </div>
          <p class="field-hint" id="pwHint">8자 이상, 영문+숫자+특수문자 포함</p>
        </div>

        <div class="field-group">
          <label class="field-label">비밀번호 확인 <span class="required">*</span></label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            <input type="password" id="userPwCf" class="field-input" placeholder="비밀번호를 다시 입력하세요" oninput="checkPwMatch()">
          </div>
          <p class="field-ok"  id="pwOk"  style="display:none">비밀번호가 일치합니다.</p>
          <p class="field-err" id="pwErr" style="display:none">비밀번호가 일치하지 않습니다.</p>
        </div>

        <div class="field-group">
          <label class="field-label">이름 <span class="required">*</span></label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            <input type="text" id="userName" class="field-input" placeholder="실명을 입력하세요">
          </div>
        </div>

        <div class="field-group" style="margin-bottom:0">
          <label class="field-label">연락처 <span class="required">*</span></label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2A19.79 19.79 0 0 1 11.6 19 19.45 19.45 0 0 1 5 12.4 19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            <input type="tel" id="userPhone" class="field-input" placeholder="010-0000-0000">
          </div>
        </div>
      </div>

      <button class="btn-submit" onclick="goStep2()">다음 단계</button>
    </div>

    <!-- STEP 2 -->
    <div id="step2" style="display:none">
      <div class="card">
        <div class="card-title">소속 및 직급 정보</div>

        <div class="field-group">
          <label class="field-label">소속 기관 <span class="required">*</span></label>
          <select id="userOrg" class="field-input no-icon">
            <option value="">선택하세요</option>
            <option>서울지방경찰청</option>
            <option>부산지방경찰청</option>
            <option>인천지방경찰청</option>
            <option>경기남부경찰청</option>
            <option>경기북부경찰청</option>
            <option>대구지방경찰청</option>
            <option>광주지방경찰청</option>
            <option>대전지방경찰청</option>
            <option>울산지방경찰청</option>
            <option>기타</option>
          </select>
        </div>

        <div class="field-group">
          <label class="field-label">부서명</label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/></svg>
            <input type="text" id="userDept" class="field-input" placeholder="예: 형사과 2팀">
          </div>
        </div>

        <div class="field-group">
          <label class="field-label">계급 <span class="required">*</span></label>
          <select id="userRank" class="field-input no-icon">
            <option value="">선택하세요</option>
            <option>순경</option>
            <option>경장</option>
            <option>경사</option>
            <option>경위</option>
            <option>경감</option>
            <option>경정</option>
            <option>총경</option>
            <option>경무관</option>
          </select>
        </div>

        <div class="field-group" style="margin-bottom:0">
          <label class="field-label">수사관 번호 <span class="required">*</span></label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 9h6M9 12h6M9 15h4"/></svg>
            <input type="text" id="badgeNum" class="field-input" placeholder="공무원증 번호 입력">
          </div>
          <p class="field-hint">공무원증에 기재된 고유번호를 입력하세요</p>
        </div>
      </div>

      <div style="display:flex; gap:10px;">
        <button class="btn-submit" style="background:var(--bg); color:var(--text-primary); border:1px solid var(--border); flex:0 0 80px;" onclick="goStep1()">이전</button>
        <button class="btn-submit" style="flex:1" onclick="goStep3()">다음 단계</button>
      </div>
    </div>

    <!-- STEP 3 -->
    <div id="step3" style="display:none">

      <div class="notice-box">
        본 시스템은 수사 목적으로만 사용되어야 합니다. 개인정보 및 수사 정보 무단 유출 시 형사처벌을 받을 수 있습니다.
      </div>

      <div class="agree-box">
        <div class="agree-all" onclick="toggleAll()">
          <div class="chk" id="chkAll">
            <svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg>
          </div>
          <span class="agree-text"><strong>전체 동의</strong></span>
        </div>
        <div class="agree-item" onclick="toggleChk('chk1')">
          <div class="chk" id="chk1"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
          <span class="agree-text"><strong>[필수]</strong> 이용약관 동의</span>
          <span class="agree-view">보기</span>
        </div>
        <div class="agree-item" onclick="toggleChk('chk2')">
          <div class="chk" id="chk2"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
          <span class="agree-text"><strong>[필수]</strong> 개인정보 수집·이용 동의</span>
          <span class="agree-view">보기</span>
        </div>
        <div class="agree-item" onclick="toggleChk('chk3')">
          <div class="chk" id="chk3"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
          <span class="agree-text"><strong>[필수]</strong> 수사 정보 보안 서약 동의</span>
          <span class="agree-view">보기</span>
        </div>
      </div>

      <div style="display:flex; gap:10px;">
        <button class="btn-submit" style="background:var(--bg); color:var(--text-primary); border:1px solid var(--border); flex:0 0 80px;" onclick="goStep2b()">이전</button>
        <button class="btn-submit" style="flex:1" onclick="submitRegister()">가입 완료</button>
      </div>
    </div>

  </div><!-- /content -->

  <!-- 완료 화면 -->
  <div class="done-screen" id="doneScreen">
    <div class="done-icon">
      <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
    </div>
    <div class="done-title">가입 완료!</div>
    <div class="done-desc">
      수사관 계정 등록이 완료되었습니다.<br>
      <span id="doneId" style="font-weight:500; color:var(--navy);"></span> 로 로그인하세요.
    </div>
    <button class="btn-submit" onclick="location.href='login.jsp'">로그인 화면으로</button>
  </div>

</div>

<script>
let idChecked = false;

// ── 아이디 중복 확인 ──
function checkId() {
  const v = document.getElementById('userId').value.trim();
  if (!v) { alert('아이디를 입력하세요.'); return; }
  if (!/^[a-z0-9]{4,16}$/.test(v)) { showErr('idErr', '영문 소문자+숫자 4~16자로 입력하세요.'); idChecked = false; return; }

  fetch('register?action=checkId&userId=' + encodeURIComponent(v))
    .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(data => {
      if (data.success) {
        document.getElementById('idErr').style.display  = 'none';
        document.getElementById('idHint').style.display = 'none';
        document.getElementById('idOk').style.display   = 'block';
        idChecked = true;
      } else {
        document.getElementById('idOk').style.display   = 'none';
        document.getElementById('idHint').style.display = 'none';
        document.getElementById('idErr').style.display  = 'block';
        document.getElementById('idErr').textContent    = data.message;
        idChecked = false;
      }
    })
    .catch(err => { alert('서버 통신 오류: ' + err.message + '\nRegisterServlet.java가 배포되었는지 확인하세요.'); idChecked = false; });
}

// ── 비밀번호 강도 체크 (실시간) ──
function checkPwStrength() {
  const pw = document.getElementById('userPw').value;
  const hint = document.getElementById('pwHint');
  const hasLen  = pw.length >= 8;
  const hasAlpha= /[a-zA-Z]/.test(pw);
  const hasNum  = /[0-9]/.test(pw);
  const hasSpc  = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pw);
  const missing = [];
  if (!hasLen)   missing.push('8자 이상');
  if (!hasAlpha) missing.push('영문');
  if (!hasNum)   missing.push('숫자');
  if (!hasSpc)   missing.push('특수문자');
  if (missing.length === 0) {
    hint.style.color = 'var(--success)';
    hint.textContent = '사용 가능한 비밀번호입니다.';
  } else {
    hint.style.color = 'var(--danger)';
    hint.textContent = missing.join(', ') + ' 필요';
  }
  hint.style.display = 'block';
}

// ── 비밀번호 확인 일치 체크 (실시간) ──
function checkPwMatch() {
  const pw   = document.getElementById('userPw').value;
  const pwcf = document.getElementById('userPwCf').value;
  if (!pwcf) {
    document.getElementById('pwOk').style.display  = 'none';
    document.getElementById('pwErr').style.display = 'none';
    return;
  }
  if (pw === pwcf) {
    document.getElementById('pwOk').style.display  = 'block';
    document.getElementById('pwErr').style.display = 'none';
  } else {
    document.getElementById('pwOk').style.display  = 'none';
    document.getElementById('pwErr').style.display = 'block';
  }
}

// ── 에러 메시지 표시 ──
function showErr(id, msg) {
  const el = document.getElementById(id);
  el.textContent = msg;
  el.style.display = 'block';
}

// ── 단계 이동 ──
function goStep2() {
  if (!idChecked) { alert('아이디 중복 확인을 완료해 주세요.'); return; }
  const pw   = document.getElementById('userPw').value;
  const pwcf = document.getElementById('userPwCf').value;
  const name = document.getElementById('userName').value.trim();
  const phone= document.getElementById('userPhone').value.trim();
  if (!pw || pw.length < 8)              { alert('비밀번호를 8자 이상 입력해 주세요.'); return; }
  if (!/[a-zA-Z]/.test(pw))             { alert('비밀번호에 영문자를 포함해 주세요.'); return; }
  if (!/[0-9]/.test(pw))                { alert('비밀번호에 숫자를 포함해 주세요.'); return; }
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pw)) { alert('비밀번호에 특수문자를 포함해 주세요.'); return; }
  if (pw !== pwcf)                       { document.getElementById('pwErr').style.display='block'; return; }
  else                         { document.getElementById('pwErr').style.display='none'; }
  if (!name)                   { alert('이름을 입력해 주세요.'); return; }
  if (!phone)                  { alert('연락처를 입력해 주세요.'); return; }
  setStep(2);
}

function goStep1()  { setStep(1); }

function goStep3() {
  if (!document.getElementById('userOrg').value)  { alert('소속 기관을 선택해 주세요.'); return; }
  if (!document.getElementById('userRank').value) { alert('계급을 선택해 주세요.'); return; }
  if (!document.getElementById('badgeNum').value.trim()) { alert('수사관 번호를 입력해 주세요.'); return; }
  setStep(3);
}

function goStep2b() { setStep(2); }

function setStep(n) {
  document.getElementById('step1').style.display = n===1 ? 'block' : 'none';
  document.getElementById('step2').style.display = n===2 ? 'block' : 'none';
  document.getElementById('step3').style.display = n===3 ? 'block' : 'none';
  [1,2,3].forEach(i => {
    const c = document.getElementById('s'+i);
    const l = document.getElementById('sl'+i);
    if (i < n)      { c.className='step-circle done';   l.className='step-label'; }
    else if (i===n) { c.className='step-circle active'; l.className='step-label active'; }
    else            { c.className='step-circle';        l.className='step-label'; }
  });
  window.scrollTo(0, 0);
}

// ── 전체 동의 토글 ──
function toggleAll() {
  const allChecked = document.getElementById('chkAll').classList.contains('checked');
  ['chkAll','chk1','chk2','chk3'].forEach(id => {
    const el = document.getElementById(id);
    if (allChecked) el.classList.remove('checked'); else el.classList.add('checked');
  });
}

function toggleChk(id) {
  document.getElementById(id).classList.toggle('checked');
  const all = ['chk1','chk2','chk3'].every(i => document.getElementById(i).classList.contains('checked'));
  if (all) document.getElementById('chkAll').classList.add('checked');
  else     document.getElementById('chkAll').classList.remove('checked');
}

// ── 가입 완료 (서버 POST) ──
function submitRegister() {
  if (!['chk1','chk2','chk3'].every(i => document.getElementById(i).classList.contains('checked'))) {
    alert('필수 약관에 모두 동의해 주세요.'); return;
  }

  const params = new URLSearchParams();
  params.append('userId',    document.getElementById('userId').value.trim());
  params.append('userPw',    document.getElementById('userPw').value);
  params.append('userName',  document.getElementById('userName').value.trim());
  params.append('userPhone', document.getElementById('userPhone').value.trim());
  params.append('userOrg',   document.getElementById('userOrg').value);
  params.append('userRank',  document.getElementById('userRank').value);
  params.append('userDept',  document.getElementById('userDept').value.trim());
  params.append('badgeNum',  document.getElementById('badgeNum').value.trim());

  fetch('register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
    body: params.toString()
  })
  .then(r => r.json())
  .then(data => {
    if (data.success) {
      document.getElementById('doneId').textContent = params.get('userId');
      document.getElementById('formContent').style.display = 'none';
      document.getElementById('doneScreen').style.display  = 'block';
      window.scrollTo(0, 0);
    } else {
      alert('가입 실패: ' + data.message);
    }
  })
  .catch(() => alert('서버 통신 오류가 발생했습니다.'));
}
</script>
</body>
</html>
