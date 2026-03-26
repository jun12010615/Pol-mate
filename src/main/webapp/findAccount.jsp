<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | ID / 비밀번호 찾기</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
  :root {
    --navy: #1a2744; --accent: #4a7cdc; --danger: #e74c3c;
    --text-primary: #1a1a2e; --text-secondary: #6b7280; --text-muted: #9ca3af;
    --bg: #f4f6fb; --card: #ffffff; --border: #e5e7eb; --success: #16a34a;
  }
  html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: var(--bg); }

  .screen { width: 100%; max-width: 420px; min-height: 100vh; margin: 0 auto; background: var(--bg); }

  .top-bar {
    background: var(--navy); padding: 52px 20px 0;
    position: sticky; top: 0; z-index: 10;
  }
  .top-row { display: flex; align-items: center; gap: 12px; padding-bottom: 16px; }
  .back-btn {
    width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.12);
    border: none; display: flex; align-items: center; justify-content: center; cursor: pointer;
  }
  .back-btn svg { width: 18px; height: 18px; stroke: #fff; }
  .top-title { font-size: 16px; font-weight: 500; color: #fff; }

  /* 탭 */
  .tab-row { display: flex; border-top: 1px solid rgba(255,255,255,0.1); }
  .tab-btn {
    flex: 1; padding: 13px 0; font-size: 13px; font-weight: 500;
    color: rgba(255,255,255,0.5); background: none; border: none;
    cursor: pointer; font-family: 'Noto Sans KR', sans-serif;
    border-bottom: 2px solid transparent; transition: all 0.2s;
  }
  .tab-btn.active { color: #fff; border-bottom-color: #fff; }

  .content { padding: 28px 20px 40px; }

  .tab-panel { display: none; animation: fadeUp 0.3s ease both; }
  .tab-panel.active { display: block; }

  .card { background: var(--card); border-radius: 16px; padding: 22px 20px; border: 1px solid var(--border); margin-bottom: 16px; }

  .field-group { margin-bottom: 14px; }
  .field-label { font-size: 11px; font-weight: 500; color: var(--text-secondary); display: block; margin-bottom: 6px; }
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

  .inline-row { display: flex; gap: 8px; }
  .inline-row .field-wrap { flex: 1; }
  .btn-send {
    background: var(--navy); color: #fff; border: none; border-radius: 10px;
    padding: 0 14px; font-size: 12px; font-family: 'Noto Sans KR', sans-serif;
    cursor: pointer; white-space: nowrap; font-weight: 500; height: 44px;
  }
  .btn-send:disabled { opacity: 0.5; cursor: not-allowed; }

  .timer { font-size: 12px; color: var(--danger); font-weight: 500; position: absolute; right: 12px; top: 50%; transform: translateY(-50%); }

  .btn-submit {
    width: 100%; background: var(--navy); color: #fff; border: none;
    border-radius: 12px; padding: 15px; font-size: 15px; font-weight: 500;
    font-family: 'Noto Sans KR', sans-serif; cursor: pointer;
    transition: background 0.2s, transform 0.1s;
  }
  .btn-submit:active { transform: scale(0.98); }

  /* 결과 카드 */
  .result-card {
    background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 14px; padding: 22px 20px;
    margin-bottom: 16px; text-align: center; display: none;
    animation: fadeUp 0.3s ease both;
  }
  .result-label { font-size: 11px; color: #1e40af; margin-bottom: 8px; }
  .result-value { font-size: 20px; font-weight: 700; color: var(--navy); letter-spacing: 1px; }
  .result-sub   { font-size: 11px; color: var(--text-muted); margin-top: 6px; }

  /* 새 비밀번호 설정 영역 */
  .new-pw-section { display: none; animation: fadeUp 0.3s ease both; }

  .hint-box {
    background: var(--bg); border-radius: 10px; padding: 12px 14px; margin-top: 12px;
    font-size: 11px; color: var(--text-muted); line-height: 1.8;
  }

  @keyframes fadeUp { from { opacity:0; transform: translateY(10px); } to { opacity:1; transform: translateY(0); } }
  @media (min-width: 421px) { .screen { box-shadow: 0 0 40px rgba(0,0,0,0.1); } }
</style>
</head>
<body>
<div class="screen">

  <div class="top-bar">
    <div class="top-row">
      <button class="back-btn" onclick="location.href='login.jsp'">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <span class="top-title">ID / 비밀번호 찾기</span>
    </div>
    <div class="tab-row">
      <button class="tab-btn active" id="tabId" onclick="switchTab('id')">아이디 찾기</button>
      <button class="tab-btn"        id="tabPw" onclick="switchTab('pw')">비밀번호 찾기</button>
    </div>
  </div>

  <div class="content">

    <!-- ═══ 아이디 찾기 패널 ═══ -->
    <div class="tab-panel active" id="panelId">

      <div class="card">
        <div class="field-group">
          <label class="field-label">이름</label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            <input type="text" id="findIdName" class="field-input" placeholder="가입 시 등록한 이름">
          </div>
        </div>

        <div class="field-group" style="margin-bottom:0">
          <label class="field-label">연락처</label>
          <div class="inline-row">
            <div class="field-wrap" style="flex:1; position:relative">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.45 19.45 0 0 1 5 12.4 19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
              <input type="tel" id="findIdPhone" class="field-input" placeholder="010-0000-0000">
            </div>
            <button class="btn-send" id="btnSendId" onclick="sendOtp('id')">인증번호 발송</button>
          </div>
        </div>
      </div>

      <div class="card" id="otpCardId" style="display:none">
        <div class="field-group" style="margin-bottom:0">
          <label class="field-label">인증번호 입력</label>
          <div class="field-wrap" style="position:relative">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            <input type="text" id="otpId" class="field-input" placeholder="6자리 숫자 입력" maxlength="6">
            <span class="timer" id="timerIdEl"></span>
          </div>
          <div class="hint-box">임시 인증번호: <strong>123456</strong> (DB 연동 전 테스트용)</div>
        </div>
      </div>

      <!-- 결과 -->
      <div class="result-card" id="idResult">
        <div class="result-label">회원님의 아이디는</div>
        <div class="result-value" id="foundId"></div>
        <div class="result-sub">가입일 기준으로 조회되었습니다</div>
      </div>

      <button class="btn-submit" onclick="findId()">아이디 찾기</button>
      <p style="text-align:center; margin-top:14px;">
        <a href="login.jsp" style="font-size:12px; color:var(--accent); text-decoration:none;">로그인 화면으로 돌아가기</a>
      </p>
    </div>

    <!-- ═══ 비밀번호 찾기 패널 ═══ -->
    <div class="tab-panel" id="panelPw">

      <div class="card">
        <div class="field-group">
          <label class="field-label">아이디</label>
          <div class="field-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            <input type="text" id="findPwId" class="field-input" placeholder="가입한 아이디">
          </div>
        </div>

        <div class="field-group" style="margin-bottom:0">
          <label class="field-label">연락처</label>
          <div class="inline-row">
            <div class="field-wrap" style="flex:1; position:relative">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.45 19.45 0 0 1 5 12.4 19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
              <input type="tel" id="findPwPhone" class="field-input" placeholder="010-0000-0000">
            </div>
            <button class="btn-send" id="btnSendPw" onclick="sendOtp('pw')">인증번호 발송</button>
          </div>
        </div>
      </div>

      <div class="card" id="otpCardPw" style="display:none">
        <div class="field-group" style="margin-bottom:0">
          <label class="field-label">인증번호 입력</label>
          <div class="field-wrap" style="position:relative">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            <input type="text" id="otpPw" class="field-input" placeholder="6자리 숫자 입력" maxlength="6">
            <span class="timer" id="timerPwEl"></span>
          </div>
          <div class="hint-box">임시 인증번호: <strong>123456</strong> (DB 연동 전 테스트용)</div>
        </div>
      </div>

      <!-- 새 비밀번호 설정 -->
      <div class="new-pw-section" id="newPwSection">
        <div class="card">
          <div class="field-group">
            <label class="field-label">새 비밀번호</label>
            <div class="field-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
              <input type="password" id="newPw" class="field-input" placeholder="8자 이상 영문+숫자+특수문자">
            </div>
          </div>
          <div class="field-group" style="margin-bottom:0">
            <label class="field-label">비밀번호 확인</label>
            <div class="field-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
              <input type="password" id="newPwCf" class="field-input" placeholder="비밀번호를 다시 입력하세요">
            </div>
          </div>
        </div>
        <button class="btn-submit" onclick="resetPw()">비밀번호 변경 완료</button>
      </div>

      <div id="verifyPwBtn">
        <button class="btn-submit" onclick="verifyOtpPw()">인증 확인</button>
      </div>

      <p style="text-align:center; margin-top:14px;">
        <a href="login.jsp" style="font-size:12px; color:var(--accent); text-decoration:none;">로그인 화면으로 돌아가기</a>
      </p>
    </div>

  </div>
</div>

<script>
// ── 임시 사용자 데이터 (DB 연동 전 테스트용) ──────────────────────
const TEMP_DB = [
  { id:'admin', name:'관리자', phone:'010-0000-0000' },
  { id:'test',  name:'김민준', phone:'010-1234-5678' },
  { id:'hong',  name:'홍길동', phone:'010-9876-5432' }
];
const TEMP_OTP = '123456';
// ──────────────────────────────────────────────────────────────────

let timerIdInterval = null;
let timerPwInterval = null;

function switchTab(tab) {
  document.getElementById('panelId').classList.toggle('active', tab==='id');
  document.getElementById('panelPw').classList.toggle('active', tab==='pw');
  document.getElementById('tabId').classList.toggle('active', tab==='id');
  document.getElementById('tabPw').classList.toggle('active', tab==='pw');
}

// ── OTP 발송 (임시: 콘솔 출력) ──
function sendOtp(type) {
  const phone = document.getElementById(type==='id' ? 'findIdPhone' : 'findPwPhone').value.trim();
  if (!phone) { alert('연락처를 입력해 주세요.'); return; }

  const cardId  = type==='id' ? 'otpCardId' : 'otpCardPw';
  const timerId = type==='id' ? 'timerIdEl' : 'timerPwEl';
  const btnId   = type==='id' ? 'btnSendId' : 'btnSendPw';
  const prevTimer = type==='id' ? timerIdInterval : timerPwInterval;

  document.getElementById(cardId).style.display = 'block';
  document.getElementById(btnId).textContent    = '재발송';
  if (prevTimer) clearInterval(prevTimer);

  let sec = 180;
  const el = document.getElementById(timerId);
  function tick() {
    const m = String(Math.floor(sec/60)).padStart(2,'0');
    const s = String(sec%60).padStart(2,'0');
    el.textContent = m+':'+s;
    if (sec-- <= 0) { clearInterval(iv); el.textContent='만료'; }
  }
  tick();
  const iv = setInterval(tick, 1000);
  if (type==='id') timerIdInterval = iv; else timerPwInterval = iv;

  console.log('[POL-MATE 테스트] OTP: ' + TEMP_OTP);
}

// ── 아이디 찾기 ──
function findId() {
  const name  = document.getElementById('findIdName').value.trim();
  const phone = document.getElementById('findIdPhone').value.trim();
  const otp   = document.getElementById('otpId') ? document.getElementById('otpId').value.trim() : '';

  if (!name || !phone) { alert('이름과 연락처를 입력해 주세요.'); return; }
  if (document.getElementById('otpCardId').style.display !== 'none' && otp !== TEMP_OTP) {
    alert('인증번호가 올바르지 않습니다.'); return;
  }

  const found = TEMP_DB.find(u => u.name === name && u.phone === phone);
  if (found) {
    const result = document.getElementById('idResult');
    document.getElementById('foundId').textContent = maskId(found.id);
    result.style.display = 'block';
  } else {
    alert('일치하는 회원 정보를 찾을 수 없습니다.');
  }
}

function maskId(id) {
  if (id.length <= 3) return id[0] + '*'.repeat(id.length-1);
  return id.slice(0, Math.ceil(id.length/2)) + '*'.repeat(Math.floor(id.length/2));
}

// ── 비밀번호 찾기 - OTP 인증 ──
function verifyOtpPw() {
  const userId= document.getElementById('findPwId').value.trim();
  const phone = document.getElementById('findPwPhone').value.trim();
  const otp   = document.getElementById('otpPw').value.trim();

  if (!userId || !phone) { alert('아이디와 연락처를 입력해 주세요.'); return; }
  if (!otp) { alert('인증번호를 입력해 주세요.'); return; }

  const found = TEMP_DB.find(u => u.id === userId && u.phone === phone);
  if (!found)             { alert('일치하는 회원 정보를 찾을 수 없습니다.'); return; }
  if (otp !== TEMP_OTP)   { alert('인증번호가 올바르지 않습니다.'); return; }

  document.getElementById('verifyPwBtn').style.display    = 'none';
  document.getElementById('otpCardPw').style.display      = 'none';
  document.getElementById('newPwSection').style.display   = 'block';
}

// ── 비밀번호 재설정 ──
function resetPw() {
  const pw   = document.getElementById('newPw').value;
  const pwcf = document.getElementById('newPwCf').value;
  if (!pw || pw.length < 8) { alert('비밀번호를 8자 이상 입력해 주세요.'); return; }
  if (pw !== pwcf)           { alert('비밀번호가 일치하지 않습니다.'); return; }

  alert('비밀번호가 변경되었습니다.\n(DB 미연동 상태 — 실제 반영은 DB 연동 후 가능합니다.)');
  location.href = 'login.jsp';
}
</script>
</body>
</html>
