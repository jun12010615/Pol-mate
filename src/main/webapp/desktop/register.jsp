<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if (session.getAttribute("loginUser") != null) {
    response.sendRedirect(request.getContextPath() + "/desktop/main.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>POL-MATE | 수사관 계정 등록</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: #f0f2f8; -webkit-font-smoothing: antialiased; }
.page { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
.card {
    width: 980px; display: grid; grid-template-columns: 1.1fr 1.6fr;
    background: #fff; border-radius: 22px; overflow: hidden;
    box-shadow: 0 24px 80px rgba(13,26,51,0.18); min-height: 640px;
    animation: fadeUp 0.35s ease both;
}
@keyframes fadeUp { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
.brand {
    background: #0d1a33; color: #fff; padding: 48px 40px;
    display: flex; flex-direction: column; justify-content: space-between; position: relative; overflow: hidden;
}
.brand::before { content:''; position:absolute; top:-80px; right:-80px; width:240px; height:240px; border-radius:50%; border:1px solid rgba(240,192,64,0.12); }
.brand::after  { content:''; position:absolute; bottom:-60px; left:-60px; width:180px; height:180px; border-radius:50%; border:1px solid rgba(74,124,220,0.10); }
.brand-gold-line { position:absolute; bottom:0; left:40px; right:40px; height:2px; background:linear-gradient(90deg,transparent,#f0c040,transparent); opacity:0.4; }
.brand-top { position:relative; z-index:1; }
.shield { display:block; margin-bottom:18px; }
.wordmark { font-family:'Space Grotesk',sans-serif; font-weight:700; font-size:24px; letter-spacing:5px; color:#fff; margin-bottom:6px; }
.tagline { font-size:10px; color:rgba(255,255,255,0.5); letter-spacing:1px; text-transform:uppercase; margin-bottom:18px; }
.gov-badge { display:inline-flex; align-items:center; gap:6px; font-size:10px; font-weight:500; padding:5px 12px; border-radius:20px; background:rgba(240,192,64,0.18); color:#f0c040; border:1px solid rgba(240,192,64,0.35); }
.gov-dot { width:5px; height:5px; border-radius:50%; background:#f0c040; }
.brand-steps { position:relative; z-index:1; }
.brand-step { display:flex; align-items:center; gap:10px; margin-bottom:12px; }
.brand-step:last-child { margin-bottom:0; }
.bs-num { width:22px; height:22px; border-radius:50%; background:rgba(240,192,64,0.2); border:1px solid rgba(240,192,64,0.4); display:flex; align-items:center; justify-content:center; font-size:10px; font-weight:700; color:#f0c040; flex-shrink:0; }
.bs-text { font-size:11px; color:rgba(255,255,255,0.55); }
.brand-bottom { position:relative; z-index:1; font-size:11px; color:rgba(255,255,255,0.4); line-height:1.8; }

.form-side { padding: 36px 44px; overflow-y: auto; display: flex; flex-direction: column; }
.step-bar { display:flex; align-items:center; margin-bottom:24px; }
.step { display:flex; flex-direction:column; align-items:center; flex:1; }
.step-circle { width:28px; height:28px; border-radius:50%; font-size:12px; font-weight:500; display:flex; align-items:center; justify-content:center; border:2px solid #e2e5ee; color:#9ca3af; background:#fff; transition:all 0.3s; }
.step-circle.active { background:#0d1a33; border-color:#0d1a33; color:#fff; }
.step-circle.done   { background:#4a7cdc; border-color:#4a7cdc; color:#fff; }
.step-label { font-size:9px; color:#9ca3af; margin-top:4px; }
.step-label.active { color:#0d1a33; font-weight:500; }
.step-line { flex:1; height:1px; background:#e2e5ee; margin-bottom:16px; }

.form-eyebrow { font-size:10px; color:#9ca3af; letter-spacing:0.8px; text-transform:uppercase; margin-bottom:3px; }
.form-title { font-size:18px; font-weight:500; color:#1a1a2e; margin-bottom:4px; }
.form-sub { font-size:12px; color:#6b7280; margin-bottom:18px; }

.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:0 16px; }
.field { margin-bottom:12px; }
.field.full { grid-column:1/-1; }
.field-label { display:block; font-size:10px; font-weight:500; color:#6b7280; letter-spacing:0.7px; text-transform:uppercase; margin-bottom:5px; }
.required { color:#dc2626; margin-left:2px; }
.field-wrap { position:relative; }
.field-wrap svg { position:absolute; left:13px; top:50%; transform:translateY(-50%); width:14px; height:14px; stroke:#9ca3af; pointer-events:none; }
.field-input { width:100%; padding:10px 12px 10px 38px; background:#f4f6fb; border:1.5px solid #e2e5ee; border-radius:10px; font-size:13px; font-family:'Noto Sans KR',sans-serif; color:#1a1a2e; outline:none; transition:border-color 0.15s, background 0.15s, box-shadow 0.15s; }
.field-input:focus { border-color:#0d1a33; background:#fff; box-shadow:0 0 0 3px rgba(13,26,51,0.07); }
.field-input::placeholder { color:#9ca3af; font-size:12px; }
.field-input.no-icon { padding-left:12px; }
select.field-input { appearance:none; }
.field-hint { font-size:10px; color:#9ca3af; margin-top:4px; }
.field-ok   { font-size:10px; color:#16a34a; margin-top:4px; display:none; }
.field-err  { font-size:10px; color:#dc2626; margin-top:4px; display:none; }
.inline-row { display:flex; gap:8px; }
.inline-row .field-wrap { flex:1; }
.btn-check { background:#0d1a33; color:#fff; border:none; border-radius:10px; padding:0 14px; font-size:12px; font-family:'Noto Sans KR',sans-serif; cursor:pointer; white-space:nowrap; font-weight:500; }
.btn-check:hover { background:#1a2744; }

.agree-box { background:#f9fafb; border:1px solid #e2e5ee; border-radius:12px; padding:14px; margin-bottom:14px; }
.agree-all  { display:flex; align-items:center; gap:10px; padding-bottom:10px; border-bottom:1px solid #e2e5ee; margin-bottom:10px; cursor:pointer; }
.agree-item { display:flex; align-items:center; gap:10px; margin-bottom:8px; cursor:pointer; }
.agree-item:last-child { margin-bottom:0; }
.chk { width:18px; height:18px; border-radius:5px; border:1.5px solid #e2e5ee; flex-shrink:0; display:flex; align-items:center; justify-content:center; transition:all 0.15s; }
.chk.checked { background:#0d1a33; border-color:#0d1a33; }
.chk svg { width:10px; height:10px; stroke:#fff; display:none; }
.chk.checked svg { display:block; }
.agree-text { font-size:12px; color:#6b7280; flex:1; }
.agree-text strong { color:#1a1a2e; font-weight:500; }
.agree-view { font-size:11px; color:#4a7cdc; text-decoration:none; flex-shrink:0; }
.agree-view:hover { text-decoration:underline; }
.notice-box { background:#fffbeb; border:1px solid #f59e0b; border-radius:10px; padding:11px 14px; margin-bottom:14px; font-size:11px; color:#92400e; line-height:1.7; }

.step-actions { display:flex; gap:10px; margin-top:16px; }
.btn-back { padding:11px 20px; background:transparent; color:#6b7280; border:1.5px solid #e2e5ee; border-radius:12px; font-size:13px; font-family:'Noto Sans KR',sans-serif; cursor:pointer; }
.btn-back:hover { border-color:#0d1a33; color:#1a1a2e; }
.btn-next { flex:1; padding:11px; background:#0d1a33; color:#fff; border:none; border-radius:12px; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer; }
.btn-next:hover { background:#1a2744; }

.done-screen { display:none; text-align:center; padding:60px 20px; }
.done-icon { width:72px; height:72px; background:#f0fdf4; border-radius:50%; margin:0 auto 20px; display:flex; align-items:center; justify-content:center; }
.done-icon svg { width:36px; height:36px; stroke:#16a34a; fill:none; }
.done-title { font-size:20px; font-weight:700; color:#0d1a33; margin-bottom:8px; }
.done-desc  { font-size:13px; color:#6b7280; line-height:1.8; margin-bottom:28px; }

@media (max-width:900px) { .card { grid-template-columns:1fr; width:100%; max-width:540px; } .brand { padding:32px; } .form-side { padding:32px; } .form-grid { grid-template-columns:1fr; } }
</style>
</head>
<body>
<div class="page">
<div class="card">

    <div class="brand">
        <div class="brand-top">
            <svg class="shield" width="52" height="52" viewBox="0 0 86 86" fill="none">
                <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="#162240"/>
                <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="#f0c040" stroke-width="1.8"/>
                <circle cx="43" cy="40" r="15" fill="none" stroke="#4a7cdc" stroke-width="1.2" stroke-dasharray="4.5 2.5" opacity="0.65"/>
                <circle cx="43" cy="40" r="11" fill="#0d1a33"/>
                <circle cx="43" cy="40" r="6"  fill="#4a7cdc" opacity="0.85"/>
                <circle cx="43" cy="40" r="3"  fill="#fff"/>
                <circle cx="43" cy="22" r="2"  fill="#f0c040"/>
                <circle cx="43" cy="58" r="2"  fill="#f0c040"/>
                <circle cx="28" cy="40" r="2"  fill="#f0c040"/>
                <circle cx="58" cy="40" r="2"  fill="#f0c040"/>
                <polygon points="43,8 44.4,12 48.5,12 45.2,14.5 46.6,18.5 43,16 39.4,18.5 40.8,14.5 37.5,12 41.6,12" fill="#f0c040"/>
            </svg>
            <div class="wordmark">POL-MATE</div>
            <div class="tagline">Criminal Justice Information System</div>
            <div class="gov-badge"><span class="gov-dot"></span>대한민국 경찰청 공식 시스템</div>
        </div>
        <div class="brand-steps">
            <div class="brand-step"><div class="bs-num">1</div><div class="bs-text">계정 기본 정보 입력</div></div>
            <div class="brand-step"><div class="bs-num">2</div><div class="bs-text">소속 및 직급 정보</div></div>
            <div class="brand-step"><div class="bs-num">3</div><div class="bs-text">보안 약관 동의</div></div>
        </div>
        <div class="brand-bottom">
            본 시스템은 인가된 수사관만 접근 가능합니다.<br>
            무단 접속 및 수사 정보 유출 시 형사처벌을 받을 수 있습니다.
        </div>
        <div class="brand-gold-line"></div>
    </div>

    <div class="form-side">
        <div class="step-bar">
            <div class="step"><div class="step-circle active" id="s1">1</div><div class="step-label active" id="sl1">기본 정보</div></div>
            <div class="step-line"></div>
            <div class="step"><div class="step-circle" id="s2">2</div><div class="step-label" id="sl2">소속 정보</div></div>
            <div class="step-line"></div>
            <div class="step"><div class="step-circle" id="s3">3</div><div class="step-label" id="sl3">약관 동의</div></div>
        </div>

        <!-- STEP 1 -->
        <div id="step1">
            <div class="form-eyebrow">Step 1 / 3</div>
            <div class="form-title">계정 정보 입력</div>
            <div class="form-sub">로그인에 사용할 아이디와 비밀번호를 설정하세요.</div>
            <div class="form-grid">
                <div class="field full">
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
                <div class="field">
                    <label class="field-label">비밀번호 <span class="required">*</span></label>
                    <div class="field-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="userPw" class="field-input" placeholder="8자 이상, 영문+숫자+특수문자" oninput="checkPwStrength()">
                    </div>
                    <p class="field-hint" id="pwHint">8자 이상, 영문+숫자+특수문자 포함</p>
                </div>
                <div class="field">
                    <label class="field-label">비밀번호 확인 <span class="required">*</span></label>
                    <div class="field-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="userPwCf" class="field-input" placeholder="비밀번호를 다시 입력하세요" oninput="checkPwMatch()">
                    </div>
                    <p class="field-ok"  id="pwOk"  style="display:none">비밀번호가 일치합니다.</p>
                    <p class="field-err" id="pwErr" style="display:none">비밀번호가 일치하지 않습니다.</p>
                </div>
                <div class="field">
                    <label class="field-label">이름 <span class="required">*</span></label>
                    <div class="field-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        <input type="text" id="userName" class="field-input" placeholder="실명을 입력하세요">
                    </div>
                </div>
                <div class="field">
                    <label class="field-label">연락처 <span class="required">*</span></label>
                    <div class="field-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.45 19.45 0 0 1 5 12.4 19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        <input type="tel" id="userPhone" class="field-input" placeholder="010-0000-0000">
                    </div>
                </div>
                <div class="field full">
                    <label class="field-label">이메일 <span class="required">*</span></label>
                    <div class="field-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input type="email" id="userEmail" class="field-input" placeholder="example@email.com" oninput="checkEmailFormat()">
                    </div>
                    <div id="emailMsg" style="font-size:10px; margin-top:4px; display:none;"></div>
                </div>
            </div>
            <div class="step-actions">
                <button class="btn-back" onclick="location.href='<%= request.getContextPath() %>/desktop/login.jsp'">로그인으로</button>
                <button class="btn-next" onclick="goStep2()">다음 단계 →</button>
            </div>
        </div>

        <!-- STEP 2 -->
        <div id="step2" style="display:none">
            <div class="form-eyebrow">Step 2 / 3</div>
            <div class="form-title">소속 및 직급 정보</div>
            <div class="form-sub">근무 중인 기관 및 계급 정보를 입력하세요.</div>
            <div class="form-grid">
                <div class="field">
                    <label class="field-label">소속 기관 <span class="required">*</span></label>
                    <select id="userOrg" class="field-input no-icon" onchange="loadDepts()">
                        <option value="">선택하세요</option>
                        <option>서울경찰청</option><option>부산지방경찰청</option><option>인천지방경찰청</option>
                        <option>경기남부경찰청</option><option>경기북부경찰청</option><option>대구지방경찰청</option>
                        <option>광주지방경찰청</option><option>대전지방경찰청</option><option>울산지방경찰청</option>
                        <option>기타</option>
                    </select>
                </div>
                <div class="field">
                    <label class="field-label">부서명</label>
                    <select id="userDept" class="field-input no-icon" disabled>
                        <option value="">소속 기관을 먼저 선택하세요</option>
                    </select>
                </div>
                <div class="field">
                    <label class="field-label">계급 <span class="required">*</span></label>
                    <select id="userRank" class="field-input no-icon">
                        <option value="">선택하세요</option>
                        <option>순경</option><option>경장</option><option>경사</option><option>경위</option>
                        <option>경감</option><option>경정</option><option>총경</option><option>경무관</option>
                    </select>
                </div>
                <div class="field">
                    <label class="field-label">수사관 번호 <span class="required">*</span></label>
                    <div class="inline-row">
                        <div class="field-wrap" style="flex:1">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 9h6M9 12h6M9 15h4"/></svg>
                            <input type="text" id="badgeNum" class="field-input" placeholder="4자리 번호" maxlength="4" oninput="onBadgeInput()">
                        </div>
                        <button class="btn-check" id="badgeVerifyBtn" onclick="verifyBadge()">인증</button>
                    </div>
                    <p class="field-hint" id="badgeHint">공무원증에 기재된 4자리 번호</p>
                    <p class="field-ok"  id="badgeOk"  style="display:none">&#10003; 인증되었습니다.</p>
                    <p class="field-err" id="badgeErr" style="display:none"></p>
                </div>
            </div>
            <div class="step-actions">
                <button class="btn-back" onclick="setStep(1)">← 이전</button>
                <button class="btn-next" onclick="goStep3()">다음 단계 →</button>
            </div>
        </div>

        <!-- STEP 3 -->
        <div id="step3" style="display:none">
            <div class="form-eyebrow">Step 3 / 3</div>
            <div class="form-title">보안 서약 및 약관 동의</div>
            <div class="form-sub">아래 약관에 모두 동의하셔야 가입이 완료됩니다.</div>
            <div class="notice-box">
                본 시스템은 수사 목적으로만 사용되어야 합니다. 개인정보 및 수사 정보 무단 유출 시 형사처벌을 받을 수 있습니다.
            </div>
            <div class="agree-box">
                <div class="agree-all" onclick="toggleAll()">
                    <div class="chk" id="chkAll"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
                    <span class="agree-text"><strong>전체 동의</strong></span>
                </div>
                <div class="agree-item" onclick="toggleChk('chk1')">
                    <div class="chk" id="chk1"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
                    <span class="agree-text"><strong>[필수]</strong> 이용약관 동의</span>
                    <a class="agree-view" href="#" onclick="event.stopPropagation(); openTermsModal('terms')">보기</a>
                </div>
                <div class="agree-item" onclick="toggleChk('chk2')">
                    <div class="chk" id="chk2"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
                    <span class="agree-text"><strong>[필수]</strong> 개인정보 수집·이용 동의</span>
                    <a class="agree-view" href="#" onclick="event.stopPropagation(); openTermsModal('privacy')">보기</a>
                </div>
                <div class="agree-item" onclick="toggleChk('chk3')">
                    <div class="chk" id="chk3"><svg viewBox="0 0 12 12" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="2 6 5 9 10 3"/></svg></div>
                    <span class="agree-text"><strong>[필수]</strong> 수사 정보 보안 서약 동의</span>
                    <a class="agree-view" href="#" onclick="event.stopPropagation(); openTermsModal('security')">보기</a>
                </div>
            </div>
            <div class="step-actions">
                <button class="btn-back" onclick="setStep(2)">← 이전</button>
                <button class="btn-next" onclick="submitRegister()">가입 완료</button>
            </div>
        </div>

        <!-- 완료 화면 -->
        <div class="done-screen" id="doneScreen">
            <div class="done-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <div class="done-title">가입 완료!</div>
            <div class="done-desc">수사관 계정 등록이 완료되었습니다.<br><span id="doneId" style="font-weight:500; color:#0d1a33;"></span> 로 로그인하세요.</div>
            <button class="btn-next" style="max-width:240px; margin:0 auto;" onclick="location.href='<%= request.getContextPath() %>/desktop/login.jsp'">로그인 화면으로</button>
        </div>
    </div>
</div>
</div>

<!-- 약관 모달 -->
<div id="termsModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:500; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:18px; width:520px; max-height:80vh; overflow:hidden; display:flex; flex-direction:column; box-shadow:0 20px 60px rgba(0,0,0,0.2); animation:fadeUp 0.2s ease both;">
        <div style="display:flex; align-items:center; justify-content:space-between; padding:18px 24px; border-bottom:1px solid #e2e5ee;">
            <span id="termsModalTitle" style="font-size:15px; font-weight:500; color:#1a1a2e;"></span>
            <button onclick="closeTermsModal()" style="background:none; border:none; cursor:pointer; color:#6b7280; display:flex; align-items:center;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div id="termsModalBody" style="padding:20px 24px; font-size:13px; color:#6b7280; line-height:1.85; overflow-y:auto; flex:1;"></div>
        <div style="padding:16px 24px; border-top:1px solid #e2e5ee;">
            <button id="termsModalAgreeBtn" onclick="agreeAndCloseModal()" style="width:100%; background:#0d1a33; color:#fff; border:none; border-radius:12px; padding:12px; font-size:14px; font-weight:500; font-family:'Noto Sans KR',sans-serif; cursor:pointer;">동의하고 닫기</button>
        </div>
    </div>
</div>

<script>
var _TERMS = {
  terms:    { title:'이용약관', chk:'chk1', html:'<p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제1조 (목적)</p><p style="margin-bottom:14px;">본 약관은 POL-MATE 서비스의 이용에 관한 조건 및 절차를 규정함을 목적으로 합니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">제2조 (이용자의 의무)</p><p>이용자는 타인의 계정 도용, 수사 정보 무단 유출, 시스템 운영 방해 등의 행위를 하여서는 안 됩니다.</p>' },
  privacy:  { title:'개인정보 수집·이용 동의', chk:'chk2', html:'<p style="margin-bottom:14px;">POL-MATE는 개인정보 보호법에 따라 아래와 같이 개인정보를 수집·이용합니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">수집 항목</p><p style="margin-bottom:14px;">아이디, 비밀번호(암호화), 이름, 계급, 소속 기관, 수사관 번호</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">보유 기간</p><p>회원 탈퇴 시 즉시 파기합니다.</p>' },
  security: { title:'수사 정보 보안 서약', chk:'chk3', html:'<p style="margin-bottom:14px;">본 서약은 POL-MATE를 통해 접근하는 수사 정보의 보안 유지를 위한 것입니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">기밀 유지 의무</p><p style="margin-bottom:14px;">서비스를 통해 취득한 수사 정보를 수사 목적 이외에 외부에 유출하지 않겠습니다.</p><p style="font-weight:600;color:#1a1a2e;margin-bottom:6px;">위반 시 책임</p><p>본 서약 위반 시 형사소송법, 개인정보 보호법 등에 따라 민·형사상 책임을 질 수 있습니다.</p>' }
};
var _currentTermsKey = null;

function openTermsModal(key) {
    _currentTermsKey = key;
    var d = _TERMS[key];
    document.getElementById('termsModalTitle').textContent = d.title;
    document.getElementById('termsModalBody').innerHTML = d.html;
    var already = document.getElementById(d.chk).classList.contains('checked');
    document.getElementById('termsModalAgreeBtn').textContent = already ? '닫기' : '동의하고 닫기';
    document.getElementById('termsModal').style.display = 'flex';
}
function closeTermsModal() { document.getElementById('termsModal').style.display = 'none'; _currentTermsKey = null; }
function agreeAndCloseModal() {
    if (_currentTermsKey) {
        document.getElementById(_TERMS[_currentTermsKey].chk).classList.add('checked');
        var all = ['chk1','chk2','chk3'].every(function(i) { return document.getElementById(i).classList.contains('checked'); });
        document.getElementById('chkAll').classList.toggle('checked', all);
    }
    closeTermsModal();
}

var idChecked = false, badgeVerified = false;

function onBadgeInput() { badgeVerified = false; document.getElementById('badgeOk').style.display='none'; document.getElementById('badgeErr').style.display='none'; document.getElementById('badgeHint').style.display='block'; }

function verifyBadge() {
    var val = document.getElementById('badgeNum').value.trim();
    if (!val) { alert('수사관 번호를 입력하세요.'); return; }
    if (!/^[0-9]{4}$/.test(val)) { document.getElementById('badgeErr').textContent='수사관 번호는 숫자 4자리입니다.'; document.getElementById('badgeErr').style.display='block'; badgeVerified=false; return; }
    var btn = document.getElementById('badgeVerifyBtn'); btn.disabled=true; btn.textContent='확인 중...';
    fetch('<%= request.getContextPath() %>/register?action=verifyBadge&badgeNum='+encodeURIComponent(val))
        .then(function(r){return r.json();})
        .then(function(d){ btn.disabled=false; btn.textContent='인증'; document.getElementById('badgeHint').style.display='none';
            if(d.success){document.getElementById('badgeOk').style.display='block'; document.getElementById('badgeErr').style.display='none'; badgeVerified=true;}
            else{document.getElementById('badgeErr').textContent=d.message; document.getElementById('badgeErr').style.display='block'; badgeVerified=false;}
        }).catch(function(){btn.disabled=false; btn.textContent='인증'; document.getElementById('badgeErr').textContent='서버 통신 오류'; document.getElementById('badgeErr').style.display='block';});
}

function checkEmailFormat() {
    var email=document.getElementById('userEmail').value.trim(); var msg=document.getElementById('emailMsg');
    if(!email){msg.style.display='none';return;}
    var ok=/^[\w.+-]+@[\w-]+\.[\w.]+$/.test(email);
    msg.style.display='block'; msg.style.color=ok?'#16a34a':'#dc2626';
    msg.textContent=ok?'✓ 올바른 이메일 형식입니다.':'이메일 형식이 올바르지 않습니다.';
}

function checkId() {
    var v=document.getElementById('userId').value.trim();
    if(!v){alert('아이디를 입력하세요.');return;}
    if(!/^[a-z0-9]{4,16}$/.test(v)){document.getElementById('idErr').textContent='영문 소문자+숫자 4~16자로 입력하세요.'; document.getElementById('idErr').style.display='block'; idChecked=false; return;}
    fetch('<%= request.getContextPath() %>/register?action=checkId&userId='+encodeURIComponent(v))
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){document.getElementById('idErr').style.display='none'; document.getElementById('idHint').style.display='none'; document.getElementById('idOk').style.display='block'; idChecked=true;}
            else{document.getElementById('idOk').style.display='none'; document.getElementById('idHint').style.display='none'; document.getElementById('idErr').textContent=d.message; document.getElementById('idErr').style.display='block'; idChecked=false;}
        }).catch(function(){alert('서버 통신 오류가 발생했습니다.'); idChecked=false;});
}

function loadDepts() {
    var org=document.getElementById('userOrg').value; var sel=document.getElementById('userDept');
    if(!org){sel.innerHTML='<option value="">소속 기관을 먼저 선택하세요</option>'; sel.disabled=true; return;}
    sel.innerHTML='<option value="">불러오는 중...</option>'; sel.disabled=true;
    fetch('<%= request.getContextPath() %>/register?action=getDepts&org='+encodeURIComponent(org))
        .then(function(r){return r.json();})
        .then(function(depts){
            sel.innerHTML='<option value="">선택하세요 (선택)</option>';
            depts.forEach(function(d){var o=document.createElement('option'); o.value=d.dept_id; o.textContent=d.dept_name; sel.appendChild(o);});
            sel.disabled=false;
        }).catch(function(){sel.innerHTML='<option value="">불러오기 실패</option>';});
}

function checkPwStrength() {
    var pw=document.getElementById('userPw').value; var hint=document.getElementById('pwHint'); var missing=[];
    if(pw.length<8)missing.push('8자 이상'); if(!/[a-zA-Z]/.test(pw))missing.push('영문'); if(!/[0-9]/.test(pw))missing.push('숫자'); if(!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pw))missing.push('특수문자');
    hint.style.color=missing.length===0?'#16a34a':'#dc2626'; hint.textContent=missing.length===0?'사용 가능한 비밀번호입니다.':missing.join(', ')+' 필요'; hint.style.display='block';
}

function checkPwMatch() {
    var pw=document.getElementById('userPw').value; var pwcf=document.getElementById('userPwCf').value;
    if(!pwcf){document.getElementById('pwOk').style.display='none'; document.getElementById('pwErr').style.display='none'; return;}
    document.getElementById('pwOk').style.display=pw===pwcf?'block':'none'; document.getElementById('pwErr').style.display=pw!==pwcf?'block':'none';
}

function setStep(n) {
    [1,2,3].forEach(function(i){document.getElementById('step'+i).style.display=i===n?'block':'none';});
    [1,2,3].forEach(function(i){
        var c=document.getElementById('s'+i); var l=document.getElementById('sl'+i);
        if(i<n){c.className='step-circle done'; l.className='step-label';}
        else if(i===n){c.className='step-circle active'; l.className='step-label active';}
        else{c.className='step-circle'; l.className='step-label';}
    });
}

function goStep2() {
    if(!idChecked){alert('아이디 중복 확인을 완료해 주세요.'); return;}
    var pw=document.getElementById('userPw').value; var pwcf=document.getElementById('userPwCf').value;
    if(!pw||pw.length<8){alert('비밀번호를 8자 이상 입력해 주세요.'); return;}
    if(!/[a-zA-Z]/.test(pw)||!/[0-9]/.test(pw)||!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pw)){alert('비밀번호에 영문, 숫자, 특수문자를 포함해 주세요.'); return;}
    if(pw!==pwcf){document.getElementById('pwErr').style.display='block'; return;}
    if(!document.getElementById('userName').value.trim()){alert('이름을 입력해 주세요.'); return;}
    if(!document.getElementById('userPhone').value.trim()){alert('연락처를 입력해 주세요.'); return;}
    var email=document.getElementById('userEmail').value.trim();
    if(!email||!/^[\w.+-]+@[\w-]+\.[\w.]+$/.test(email)){alert('올바른 이메일을 입력해 주세요.'); return;}
    setStep(2);
}

function goStep3() {
    if(!document.getElementById('userOrg').value){alert('소속 기관을 선택해 주세요.'); return;}
    if(!document.getElementById('userRank').value){alert('계급을 선택해 주세요.'); return;}
    if(!badgeVerified){alert('수사관 번호 인증을 완료해 주세요.'); return;}
    setStep(3);
}

function toggleAll() {
    var allChecked=document.getElementById('chkAll').classList.contains('checked');
    ['chkAll','chk1','chk2','chk3'].forEach(function(id){var el=document.getElementById(id); if(allChecked)el.classList.remove('checked'); else el.classList.add('checked');});
}
function toggleChk(id) {
    document.getElementById(id).classList.toggle('checked');
    var all=['chk1','chk2','chk3'].every(function(i){return document.getElementById(i).classList.contains('checked');});
    document.getElementById('chkAll').classList.toggle('checked', all);
}

function submitRegister() {
    if(!['chk1','chk2','chk3'].every(function(i){return document.getElementById(i).classList.contains('checked');})){alert('필수 약관에 모두 동의해 주세요.'); return;}
    var params=new URLSearchParams();
    params.append('userId', document.getElementById('userId').value.trim());
    params.append('userPw', document.getElementById('userPw').value);
    params.append('userName', document.getElementById('userName').value.trim());
    params.append('userPhone', document.getElementById('userPhone').value.trim());
    params.append('userEmail', document.getElementById('userEmail').value.trim());
    params.append('userOrg', document.getElementById('userOrg').value);
    params.append('userRank', document.getElementById('userRank').value);
    params.append('deptId', document.getElementById('userDept').value);
    params.append('badgeNum', document.getElementById('badgeNum').value.trim());
    fetch('<%= request.getContextPath() %>/register', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:params.toString()})
        .then(function(r){return r.json();})
        .then(function(data){
            if(data.success){
                document.getElementById('doneId').textContent=params.get('userId');
                [1,2,3].forEach(function(i){document.getElementById('step'+i).style.display='none';});
                document.getElementById('doneScreen').style.display='block';
            } else { alert('가입 실패: '+data.message); }
        }).catch(function(){alert('서버 통신 오류가 발생했습니다.');});
}
</script>
</body>
</html>
