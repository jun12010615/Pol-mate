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
  .field-input:disabled { opacity: 0.5; cursor: not-allowed; }

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

        <!-- 소속 기관 -->
        <div class="field-group">
          <label class="field-label">소속 기관 <span class="required">*</span></label>
          <select id="userOrg" class="field-input no-icon" onchange="loadDepts()">
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

        <!-- 부서명 (기관 선택 후 동적 로드) -->
        <div class="field-group">
          <label class="field-label">부서명</label>
          <select id="userDept" class="field-input no-icon" disabled>
            <option value="">소속 기관을 먼저 선택하세요</option>
          </select>
          <p class="field-hint" id="deptHint" style="display:none">소속 기관 선택 후 부서를 선택할 수 있습니다.</p>
        </div>

        <!-- 계급 -->
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

        <!-- 수사관 번호 -->
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
          <span class="agree-view" onclick="event.stopPropagation(); openTermsDrawer('terms')">보기</span>
        </div>
        <div class="agree-item" onclick="toggleChk('chk2')">
          <div class="chk" id="chk2"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
          <span class="agree-text"><strong>[필수]</strong> 개인정보 수집·이용 동의</span>
          <span class="agree-view" onclick="event.stopPropagation(); openTermsDrawer('privacy')">보기</span>
        </div>
        <div class="agree-item" onclick="toggleChk('chk3')">
          <div class="chk" id="chk3"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
          <span class="agree-text"><strong>[필수]</strong> 수사 정보 보안 서약 동의</span>
          <span class="agree-view" onclick="event.stopPropagation(); openTermsDrawer('security')">보기</span>
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


<!-- =====================================
     약관 드로어 (screen 바깥, body 안)
===================================== -->
<div id="termsOverlay" onclick="if(event.target===this)closeTermsDrawer()" style="position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:500;display:none;align-items:flex-end;justify-content:center;">
  <div style="background:#fff;border-radius:20px 20px 0 0;width:100%;max-width:420px;max-height:88vh;overflow-y:auto;padding:0 0 32px;animation:termsSlideUp 0.28s ease both;">
    <div style="width:36px;height:4px;background:#e5e7eb;border-radius:2px;margin:12px auto 0;"></div>
    <div style="display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid #e5e7eb;">
      <span id="termsDrawerTitle" style="font-size:15px;font-weight:500;color:#1a1a2e;"></span>
      <button onclick="closeTermsDrawer()" style="background:none;border:none;cursor:pointer;padding:4px;line-height:0;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
    <div id="termsDrawerBody" style="padding:20px;font-size:13px;color:#6b7280;line-height:1.85;"></div>
    <div style="padding:0 20px;">
      <button id="termsAgreeBtn" onclick="agreeAndCloseDrawer()" style="width:100%;background:#1a2744;color:#fff;border:none;border-radius:12px;padding:14px;font-size:14px;font-weight:500;font-family:'Noto Sans KR',sans-serif;cursor:pointer;">동의하고 닫기</button>
    </div>
  </div>
</div>

<style>
@keyframes termsSlideUp {
  from { transform: translateY(100%); opacity: 0; }
  to   { transform: translateY(0);    opacity: 1; }
}
</style>

<script>
var _TERMS = {
  terms: {
    title: '이용약관', chk: 'chk1',
    html: '<p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제1조 (목적)</p><p style="margin-bottom:16px;">본 약관은 POL-MATE(이하 &quot;서비스&quot;)의 이용에 관한 조건 및 절차, 기타 필요한 사하를 균정함을 목적으로 합니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제2조 (정의)</p><p style="margin-bottom:16px;">&quot;서비스&quot;란 형사사법정보 지원을 위해 제공되는 조서 작성·분석·관리 시스템을 의미합니다. &quot;이용자&quot;란 본 약관에 동의하고 서비스를 이용하는 수사 담당 공무원을 말합니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제3조 (서비스의 제공 및 중단)</p><p style="margin-bottom:16px;">서비스는 연중 24시간 제공을 원칙으로 하며, 시스템 점검 등으로 일시 중단될 수 있습니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제4조 (이용자의 의무)</p><p style="margin-bottom:16px;">이용자는 타인의 계정 도용, 수사 정보 무단 유출, 시스템 운영 방해 등의 행위를 하여서는 안 됩니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제5조 (준거법)</p><p style="margin-bottom:20px;">본 약관은 대한민국 법령에 따라 해석 및 적용됩니다.</p><p style="font-size:11px;color:#9ca3af;border-top:1px solid #e5e7eb;padding-top:12px;">시행일: 2025년 3월 1일</p>'
  },
  privacy: {
    title: '개인정보 수집·이용 동의', chk: 'chk2',
    html: '<p style="margin-bottom:16px;">POL-MATE는 À개인정보 보호법À에 따라 아래와 같이 개인정보를 수집·이용합니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">1. 수집 항목</p><p style="margin-bottom:16px;">· <b>필수:</b> 아이디, 비밀번호(암호화), 이름, 계급, 소속 기관, 수사관 번호<br>· <b>선택:</b> 부서, 연락처<br>· <b>자동 수집:</b> 접속 로그, 이용 기록</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">2. 수집 및 이용 목적</p><p style="margin-bottom:16px;">이용자 식별·자격 확인, 사건·조서 관리, 불법·부정 이용 방지, 서비스 개선</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">3. 보유 및 이용 기간</p><p style="margin-bottom:16px;">회원 탈퇴 시 즉시 파기합니다. 단, 법령에 의거한 경우 해당 기간 보관합니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">4. 동의 거부 권리</p><p style="margin-bottom:20px;">필수 항목 미동의 시 서비스 이용이 제한됩니다.</p><p style="font-size:11px;color:#9ca3af;border-top:1px solid #e5e7eb;padding-top:12px;">시행일: 2025년 3월 1일</p>'
  },
  security: {
    title: '수사 정보 보안 서약', chk: 'chk3',
    html: '<p style="margin-bottom:16px;">본 서약은 POL-MATE를 통해 접근하는 수사 정보의 보안 유지를 위한 것입니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">1. 기밀 유지 의무</p><p style="margin-bottom:16px;">서비스를 통해 취듹한 수사 정보, ���의자·������자·참고인 관련 정보, 조서 내용을 수사 목적 이외에 외부에 유출하지 않겠습니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">2. 계정 보안 책임</p><p style="margin-bottom:16px;">계정 정보를 타인과 공유하지 않으며, 비밀번호를 주기적으로 변경하고, 계정 도용이 의심될 경우 즉시 신고하겠습니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">3. 수사 목적 외 사용 길지</p><p style="margin-bottom:16px;">시스템 내 정보를 수사 목적 이외의 용도로 열람·복사·전송·활용하지 않겠습니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">4. 위반 시 책임</p><p style="margin-bottom:16px;">본 서약 위반 시 À형사소송법À, À개인정보 보호법À 등에 따라 민·형사상 책임을 질 수 있습니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">5. 퇴직 후 보안 유지</p><p style="margin-bottom:20px;">서비스 이용 종료 후에도 재직 중 취듹한 수사 정보에 대한 기밀 유지 의무는 계속됩니다.</p><p style="font-size:11px;color:#9ca3af;border-top:1px solid #e5e7eb;padding-top:12px;">시행일: 2025년 3월 1일</p>'
  }
};
var _currentTermsKey = null;

function openTermsDrawer(key) {
  _currentTermsKey = key;
  var d = _TERMS[key];
  document.getElementById('termsDrawerTitle').textContent = d.title;
  document.getElementById('termsDrawerBody').innerHTML = d.html;
  var already = document.getElementById(d.chk).classList.contains('checked');
  document.getElementById('termsAgreeBtn').textContent = already ? '닫기' : '동의하고 닫기';
  document.getElementById('termsOverlay').style.display = 'flex';
  document.body.style.overflow = 'hidden';
}
function closeTermsDrawer() {
  document.getElementById('termsOverlay').style.display = 'none';
  document.body.style.overflow = '';
  _currentTermsKey = null;
}
function agreeAndCloseDrawer() {
  if (_currentTermsKey) {
    document.getElementById(_TERMS[_currentTermsKey].chk).classList.add('checked');
    var all = ['chk1','chk2','chk3'].every(function(i){
      return document.getElementById(i).classList.contains('checked');
    });
    if (all) document.getElementById('chkAll').classList.add('checked');
    else     document.getElementById('chkAll').classList.remove('checked');
  }
  closeTermsDrawer();
}
</script>

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

// ── 기관 선택 시 부서 목록 동적 로드 ──
function loadDepts() {
  const org = document.getElementById('userOrg').value;
  const deptSel = document.getElementById('userDept');
  const deptHint = document.getElementById('deptHint');

  // 기관 미선택 시 부서 초기화
  if (!org) {
    deptSel.innerHTML = '<option value="">소속 기관을 먼저 선택하세요</option>';
    deptSel.disabled = true;
    deptHint.style.display = 'none';
    return;
  }

  deptSel.innerHTML = '<option value="">불러오는 중...</option>';
  deptSel.disabled = true;

  fetch('register?action=getDepts&org=' + encodeURIComponent(org))
    .then(r => r.json())
    .then(depts => {
      deptSel.innerHTML = '<option value="">선택하세요 (선택)</option>';
      if (depts.length === 0) {
        deptSel.innerHTML = '<option value="">등록된 부서가 없습니다</option>';
        deptHint.style.display = 'block';
        deptHint.textContent = '부서 정보가 없습니다. 관리자에게 문의하세요.';
      } else {
        depts.forEach(d => {
          const opt = document.createElement('option');
          opt.value = d.dept_id;
          opt.textContent = d.dept_name;
          deptSel.appendChild(opt);
        });
        deptSel.disabled = false;
        deptHint.style.display = 'none';
      }
    })
    .catch(() => {
      deptSel.innerHTML = '<option value="">불러오기 실패</option>';
      deptHint.style.display = 'block';
      deptHint.textContent = '부서 목록을 불러오지 못했습니다. 다시 시도해 주세요.';
    });
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
  else                                   { document.getElementById('pwErr').style.display='none'; }
  if (!name)                             { alert('이름을 입력해 주세요.'); return; }
  if (!phone)                            { alert('연락처를 입력해 주세요.'); return; }
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
  params.append('deptId',    document.getElementById('userDept').value);  // dept_id (숫자) 전송
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
