<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String loginUser = (String) session.getAttribute("loginUser");
if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/desktop/login.jsp"); return; }
request.setAttribute("currentPage", "contradiction");
request.setAttribute("breadcrumb", new String[]{"POL-MATE", "수사 도구", "모순 탐지"});
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>POL-MATE | 모순 탐지</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/polmate.css">
<script>var _ctx = '<%= request.getContextPath() %>';</script>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: #f4f6fb; color: #1a1a2e; -webkit-font-smoothing: antialiased; }
.pm-page { padding: 28px 32px 48px; }

.page-header { margin-bottom: 24px; }
.page-eyebrow { font-size: 11px; color: #9ca3af; letter-spacing: 0.8px; text-transform: uppercase; margin-bottom: 3px; }
.page-title { font-size: 22px; font-weight: 500; }

/* 단계 표시 */
.step-bar { display: flex; align-items: center; gap: 0; background: #fff; border: 1px solid #e2e5ee; border-radius: 12px; padding: 14px 20px; margin-bottom: 24px; }
.step-node { display: flex; align-items: center; gap: 8px; flex: 1; }
.step-node:last-child { flex: 0; }
.step-circle { width: 28px; height: 28px; border-radius: 50%; border: 2px solid #e2e5ee; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; color: #9ca3af; background: #f4f6fb; flex-shrink: 0; transition: all 0.25s; }
.step-circle.active { background: #0d1a33; border-color: #0d1a33; color: #fff; }
.step-circle.done { background: #4a7cdc; border-color: #4a7cdc; color: #fff; }
.step-name { font-size: 12px; color: #9ca3af; }
.step-name.active { color: #0d1a33; font-weight: 500; }
.step-line { flex: 1; height: 1px; background: #e2e5ee; margin: 0 8px; }

/* 2-col layout */
.two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; align-items: start; }
.col { display: flex; flex-direction: column; gap: 16px; }

/* 카드 */
.card { background: #fff; border: 1px solid #e2e5ee; border-radius: 12px; padding: 20px; }
.card-label { font-size: 10px; font-weight: 600; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 14px; display: flex; align-items: center; gap: 7px; }
.card-label svg { width: 13px; height: 13px; stroke: #9ca3af; fill: none; stroke-width: 1.8; stroke-linecap: round; }

/* 입력 필드 */
.field-row { display: flex; gap: 10px; margin-bottom: 12px; }
.field-half { flex: 1; }
.field-label { font-size: 11px; font-weight: 500; color: #6b7280; display: block; margin-bottom: 5px; }
.field-input {
    width: 100%; padding: 9px 12px; background: #f4f6fb;
    border: 1.5px solid #e2e5ee; border-radius: 9px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
    color: #1a1a2e; outline: none; transition: border-color 0.15s;
}
.field-input:focus { border-color: #4a7cdc; background: #fff; }
.field-input::placeholder { color: #9ca3af; font-size: 12px; }
select.field-input { appearance: none; }

/* 업로드 존 */
.upload-zone {
    border: 2px dashed #e2e5ee; border-radius: 10px;
    padding: 24px 16px; text-align: center; cursor: pointer;
    transition: all 0.2s; position: relative;
}
.upload-zone:hover { border-color: #4a7cdc; background: #f0f5ff; }
.upload-zone input { position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%; }
.upload-icon { width: 40px; height: 40px; background: #eff6ff; border-radius: 50%; margin: 0 auto 8px; display: flex; align-items: center; justify-content: center; }
.upload-icon svg { width: 18px; height: 18px; stroke: #4a7cdc; fill: none; stroke-width: 1.8; stroke-linecap: round; }
.upload-title { font-size: 13px; font-weight: 500; color: #374151; margin-bottom: 3px; }
.upload-desc { font-size: 11px; color: #9ca3af; }

.file-selected { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 9px; padding: 10px 14px; display: none; align-items: center; gap: 10px; margin-top: 8px; }
.file-name { font-size: 13px; font-weight: 500; color: #1a1a2e; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.file-size { font-size: 10px; color: #9ca3af; }
.file-remove { width: 22px; height: 22px; border-radius: 50%; background: #fef2f2; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.file-remove svg { width: 10px; height: 10px; stroke: #dc2626; fill: none; stroke-width: 2.5; stroke-linecap: round; }

.btn-stt { width: 100%; background: #1e40af; color: #fff; border: none; border-radius: 9px; padding: 11px; font-size: 13px; font-weight: 500; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px; transition: background 0.13s; margin-top: 8px; }
.btn-stt:hover { background: #1d3a9e; }
.btn-stt svg { width: 14px; height: 14px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; }

.divider-or { display: flex; align-items: center; gap: 10px; margin: 10px 0; }
.divider-or span { font-size: 11px; color: #9ca3af; white-space: nowrap; }
.divider-or::before, .divider-or::after { content: ''; flex: 1; height: 1px; background: #e2e5ee; }

.text-area {
    width: 100%; min-height: 120px; padding: 11px 13px;
    background: #f4f6fb; border: 1.5px solid #e2e5ee; border-radius: 9px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
    color: #1a1a2e; outline: none; resize: vertical; line-height: 1.7;
    transition: border-color 0.15s;
}
.text-area:focus { border-color: #4a7cdc; background: #fff; }
.text-area::placeholder { color: #9ca3af; font-size: 12px; }
.char-count { font-size: 10px; color: #9ca3af; text-align: right; margin-top: 4px; }

.btn-analyze {
    width: 100%; background: #0d1a33; color: #fff; border: none;
    border-radius: 10px; padding: 14px; font-size: 14px; font-weight: 500;
    font-family: 'Noto Sans KR', sans-serif; cursor: pointer;
    display: flex; align-items: center; justify-content: center; gap: 8px; transition: opacity 0.15s;
}
.btn-analyze:hover { opacity: 0.88; }
.btn-analyze:disabled { opacity: 0.4; cursor: not-allowed; }
.btn-analyze svg { width: 16px; height: 16px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; }

/* 오른쪽 결과 패널 */
.result-placeholder { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 360px; text-align: center; }
.result-placeholder svg { width: 48px; height: 48px; stroke: #d1d5db; fill: none; stroke-width: 1.5; stroke-linecap: round; margin-bottom: 12px; }
.result-placeholder p { font-size: 13px; color: #9ca3af; }

/* 로딩 */
.loading-card { text-align: center; padding: 40px 20px; }
.spinner { width: 36px; height: 36px; border: 3px solid #e2e5ee; border-top-color: #0d1a33; border-radius: 50%; animation: spin 0.8s linear infinite; margin: 0 auto 14px; }
.loading-steps { display: flex; flex-direction: column; gap: 8px; margin-top: 16px; text-align: left; }
.ls { display: flex; align-items: center; gap: 9px; font-size: 12px; color: #9ca3af; padding: 4px 0; }
.ls svg { width: 13px; height: 13px; flex-shrink: 0; }
.ls.active { color: #0d1a33; font-weight: 500; }
.ls.done { color: #16a34a; }

/* 결과 */
.contra-banner { border-radius: 10px; padding: 13px 15px; display: flex; align-items: flex-start; gap: 11px; margin-bottom: 12px; }
.contra-banner.found { background: #fef2f2; border: 1px solid #fecaca; }
.contra-banner.notfound { background: #f0fdf4; border: 1px solid #bbf7d0; }
.contra-dot { width: 8px; height: 8px; border-radius: 50%; margin-top: 4px; flex-shrink: 0; }
.contra-dot.red { background: #dc2626; animation: pulse 1.5s infinite; }
.contra-dot.green { background: #16a34a; }
.contra-title { font-size: 13px; font-weight: 600; margin-bottom: 3px; }
.contra-title.red { color: #b91c1c; }
.contra-title.green { color: #166534; }
.contra-desc { font-size: 11px; color: #6b7280; line-height: 1.6; }

.contra-list { display: flex; flex-direction: column; gap: 7px; margin-bottom: 12px; }
.contra-item { background: #fff; border: 1px solid #fecaca; border-left: 3px solid #dc2626; border-radius: 9px; padding: 11px 13px; }
.contra-item-title { font-size: 12px; font-weight: 500; color: #b91c1c; margin-bottom: 4px; }
.contra-item-desc { font-size: 11px; color: #6b7280; line-height: 1.7; }

.transcript-box { background: #f4f6fb; border-radius: 9px; border: 1px solid #e2e5ee; padding: 13px; font-size: 12px; color: #374151; line-height: 1.9; max-height: 160px; overflow-y: auto; white-space: pre-wrap; position: relative; margin-bottom: 12px; }
.copy-btn { position: absolute; top: 8px; right: 8px; background: #fff; border: 1px solid #e2e5ee; border-radius: 7px; padding: 4px 9px; font-size: 11px; color: #6b7280; cursor: pointer; font-family: 'Noto Sans KR', sans-serif; }

.ai-result-box { background: #f4f6fb; border-radius: 9px; border: 1px solid #e2e5ee; padding: 13px; font-size: 12px; color: #374151; line-height: 1.9; white-space: pre-wrap; max-height: 220px; overflow-y: auto; margin-bottom: 12px; }

.btn-save { width: 100%; background: #16a34a; color: #fff; border: none; border-radius: 10px; padding: 13px; font-size: 13px; font-weight: 500; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 7px; transition: background 0.13s; margin-bottom: 8px; }
.btn-save:hover { background: #15803d; }
.btn-save svg { width: 14px; height: 14px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; }
.btn-reset { width: 100%; background: #f4f6fb; color: #6b7280; border: 1px solid #e2e5ee; border-radius: 10px; padding: 12px; font-size: 13px; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; }

@keyframes spin { to { transform: rotate(360deg); } }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
</style>
</head>
<body>
<div class="pm-layout">

<%@ include file="sidebar.jsp" %>
<div class="pm-content">
<%@ include file="appbar.jsp" %>

<main class="pm-page">
    <div class="page-header">
        <div class="page-eyebrow">수사 도구</div>
        <div class="page-title">모순 탐지</div>
    </div>

    <!-- 단계 표시 -->
    <div class="step-bar">
        <div class="step-node">
            <div class="step-circle active" id="sc1">1</div>
            <span class="step-name active" id="sn1">입력</span>
        </div>
        <div class="step-line"></div>
        <div class="step-node">
            <div class="step-circle" id="sc2">2</div>
            <span class="step-name" id="sn2">변환</span>
        </div>
        <div class="step-line"></div>
        <div class="step-node">
            <div class="step-circle" id="sc3">3</div>
            <span class="step-name" id="sn3">분석</span>
        </div>
        <div class="step-line"></div>
        <div class="step-node">
            <div class="step-circle" id="sc4">4</div>
            <span class="step-name" id="sn4">결과</span>
        </div>
    </div>

    <div class="two-col">
        <!-- 왼쪽: 입력 -->
        <div class="col" id="inputCol">
            <!-- 사건 정보 -->
            <div class="card">
                <div class="card-label">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 9h6M9 12h6M9 15h4"/></svg>
                    사건 정보
                </div>
                <div class="field-row">
                    <div class="field-half">
                        <label class="field-label">사건번호</label>
                        <input type="text" class="field-input" id="caseNum" placeholder="예: 2024-0312">
                    </div>
                    <div class="field-half">
                        <label class="field-label">진술 유형</label>
                        <select class="field-input" id="stmtType">
                            <option value="피의자">피의자 진술</option>
                            <option value="목격자">목격자 진술</option>
                            <option value="참고인">참고인 진술</option>
                        </select>
                    </div>
                </div>
                <label class="field-label">진술자 성명</label>
                <input type="text" class="field-input" id="stmtName" placeholder="진술자 이름">
            </div>

            <!-- 음성 업로드 -->
            <div class="card">
                <div class="card-label">
                    <svg viewBox="0 0 24 24"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" y1="19" x2="12" y2="23"/></svg>
                    음성 파일
                    <span style="font-size:9px;background:#eff6ff;color:#1e40af;border-radius:4px;padding:2px 6px;margin-left:auto;font-weight:400;">CLOVA Speech</span>
                </div>
                <div class="upload-zone" id="uploadZone"
                     ondragover="event.preventDefault();this.classList.add('hover')"
                     ondragleave="this.classList.remove('hover')"
                     ondrop="handleDrop(event)">
                    <input type="file" id="audioFile" accept=".mp3,.wav,.m4a,.ogg,.webm" onchange="handleFile(this)">
                    <div class="upload-icon">
                        <svg viewBox="0 0 24 24"><polyline points="16 16 12 12 8 16"/><line x1="12" y1="12" x2="12" y2="21"/><path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3"/></svg>
                    </div>
                    <div class="upload-title">음성 파일 업로드</div>
                    <div class="upload-desc">MP3, WAV, M4A, OGG, WEBM · 최대 100MB</div>
                </div>
                <div class="file-selected" id="fileSelected">
                    <div style="flex:1;min-width:0;">
                        <div class="file-name" id="fileName">-</div>
                        <div class="file-size" id="fileSize"></div>
                    </div>
                    <button class="file-remove" onclick="removeFile()">
                        <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    </button>
                </div>
                <div id="sttBtnWrap" style="display:none;">
                    <button class="btn-stt" onclick="convertStt()" id="sttBtn">
                        <svg viewBox="0 0 24 24"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/></svg>
                        CLOVA Speech로 변환
                    </button>
                    <div id="sttLoading" style="display:none;text-align:center;font-size:12px;color:#1e40af;padding:8px;">
                        <span id="sttMsg">변환 중...</span>
                    </div>
                </div>
            </div>

            <!-- 텍스트 직접 입력 -->
            <div class="card">
                <div class="card-label">
                    <svg viewBox="0 0 24 24"><line x1="17" y1="10" x2="3" y2="10"/><line x1="21" y1="6" x2="3" y2="6"/><line x1="21" y1="14" x2="3" y2="14"/><line x1="17" y1="18" x2="3" y2="18"/></svg>
                    진술 텍스트 직접 입력
                    <span style="font-size:9px;background:#f0fdf4;color:#166534;border-radius:4px;padding:2px 6px;margin-left:auto;font-weight:400;">현재 사용 가능</span>
                </div>
                <textarea class="text-area" id="stmtText" placeholder="진술 내용을 직접 입력하거나 붙여넣기 하세요..." oninput="updateCharCount()"></textarea>
                <div class="char-count" id="charCount">0자</div>
                <button class="btn-analyze" onclick="startAnalysis()" style="margin-top:12px;">
                    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    AI 분석 시작
                </button>
            </div>
        </div>

        <!-- 오른쪽: 결과 -->
        <div class="col" id="resultCol">
            <!-- 대기 상태 -->
            <div class="card result-placeholder" id="placeholderCard">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <p>진술 텍스트를 입력하고<br>AI 분석을 시작하세요.</p>
            </div>

            <!-- 로딩 -->
            <div class="card loading-card" id="loadingCard" style="display:none;">
                <div class="spinner"></div>
                <div style="font-size:14px;font-weight:500;color:#0d1a33;margin-bottom:4px;">AI 분석 중...</div>
                <div style="font-size:12px;color:#9ca3af;" id="loadingSub">잠시만 기다려 주세요</div>
                <div class="loading-steps">
                    <div class="ls" id="ls1"><svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>텍스트 전처리 중</div>
                    <div class="ls" id="ls2"><svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>Ollama LLM 분석 요청</div>
                    <div class="ls" id="ls3"><svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>모순 항목 추출</div>
                    <div class="ls" id="ls4"><svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>결과 정리</div>
                </div>
            </div>

            <!-- 결과 -->
            <div id="resultContent" style="display:none;">
                <div class="card" style="margin-bottom:0;">
                    <div class="card-label" style="margin-bottom:10px;">
                        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
                        모순 탐지 요약
                    </div>
                    <div class="contra-banner" id="contraBanner">
                        <div class="contra-dot" id="contraDot"></div>
                        <div><div class="contra-title" id="contraTitle"></div><div class="contra-desc" id="contraDesc"></div></div>
                    </div>
                    <div class="contra-list" id="contraList"></div>

                    <div class="card-label" style="margin-bottom:8px;margin-top:16px;">
                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        진술 텍스트
                    </div>
                    <div style="position:relative;">
                        <div class="transcript-box" id="transcriptBox"></div>
                        <button class="copy-btn" onclick="copyText()">복사</button>
                    </div>

                    <div class="card-label" style="margin-bottom:8px;">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
                        AI 분석 결과
                        <span style="font-size:9px;background:#eff6ff;color:#1e40af;border-radius:4px;padding:2px 6px;margin-left:auto;font-weight:400;">gemma3:1b</span>
                    </div>
                    <div class="ai-result-box" id="aiResultBox"></div>

                    <button class="btn-save" id="btnSave" onclick="saveResult()">
                        <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        결과 저장하기
                    </button>
                    <button class="btn-reset" onclick="resetAll()">새로 분석하기</button>
                </div>
            </div>
        </div>
    </div>
</main>
</div>
</div>

<script>
function handleFile(input) {
    if (!input.files || !input.files[0]) return;
    showFile(input.files[0]);
}
function handleDrop(e) {
    e.preventDefault();
    document.getElementById('uploadZone').classList.remove('hover');
    if (e.dataTransfer.files[0]) showFile(e.dataTransfer.files[0]);
}
function showFile(f) {
    document.getElementById('fileName').textContent = f.name;
    var mb = f.size > 1048576 ? (f.size/1048576).toFixed(1)+' MB' : (f.size/1024).toFixed(1)+' KB';
    document.getElementById('fileSize').textContent = mb;
    document.getElementById('fileSelected').style.display = 'flex';
    document.getElementById('sttBtnWrap').style.display = '';
}
function removeFile() {
    document.getElementById('audioFile').value = '';
    document.getElementById('fileSelected').style.display = 'none';
    document.getElementById('sttBtnWrap').style.display = 'none';
    document.getElementById('sttLoading').style.display = 'none';
}

function convertStt() {
    var fileInput = document.getElementById('audioFile');
    if (!fileInput.files || !fileInput.files[0]) { alert('음성 파일을 선택해 주세요.'); return; }
    var btn = document.getElementById('sttBtn');
    var loading = document.getElementById('sttLoading');
    btn.style.display = 'none';
    loading.style.display = '';
    document.getElementById('sttMsg').textContent = '음성 파일을 CLOVA Speech에 전송 중...';
    var fd = new FormData();
    fd.append('audioFile', fileInput.files[0]);
    fd.append('language', 'Kor');
    fetch(_ctx + '/stt', { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            loading.style.display = 'none';
            btn.style.display = '';
            if (data.success) {
                document.getElementById('stmtText').value = data.text;
                updateCharCount();
                loading.style.display = '';
                loading.style.color = '#16a34a';
                document.getElementById('sttMsg').textContent = '변환 완료! 아래 텍스트를 확인하세요.';
                setTimeout(function() { loading.style.display = 'none'; }, 3000);
            } else {
                alert(data.error || 'STT 변환에 실패했습니다.');
            }
        })
        .catch(function(err) {
            loading.style.display = 'none'; btn.style.display = '';
            alert('네트워크 오류: ' + err.message);
        });
}

function updateCharCount() {
    var v = document.getElementById('stmtText').value;
    document.getElementById('charCount').textContent = v.length + '자';
}

function setStep(n) {
    for (var i = 1; i <= 4; i++) {
        var c = document.getElementById('sc' + i);
        var s = document.getElementById('sn' + i);
        if (i < n) { c.className = 'step-circle done'; s.className = 'step-name'; }
        else if (i === n) { c.className = 'step-circle active'; s.className = 'step-name active'; }
        else { c.className = 'step-circle'; s.className = 'step-name'; }
    }
}

function startAnalysis() {
    var text = document.getElementById('stmtText').value.trim();
    if (!text) { alert('진술 텍스트를 입력해 주세요.'); return; }
    document.getElementById('placeholderCard').style.display = 'none';
    document.getElementById('loadingCard').style.display = '';
    document.getElementById('resultContent').style.display = 'none';
    setStep(2);
    animateSteps(function() { setStep(3); callOllama(text); });
}

function animateSteps(cb) {
    var ids = ['ls1','ls2','ls3','ls4'];
    var msgs = ['텍스트 전처리 중...','Ollama LLM 요청 중...','모순 항목 추출 중...','결과 정리 중...'];
    var i = 0;
    function next() {
        if (i > 0) { document.getElementById(ids[i-1]).classList.remove('active'); document.getElementById(ids[i-1]).classList.add('done'); }
        if (i >= ids.length) { cb(); return; }
        document.getElementById(ids[i]).classList.add('active');
        document.getElementById('loadingSub').textContent = msgs[i];
        i++;
        setTimeout(next, 900);
    }
    next();
}

function callOllama(text) {
    var caseNum  = document.getElementById('caseNum').value  || '미입력';
    var stmtType = document.getElementById('stmtType').value || '진술자';
    var stmtName = document.getElementById('stmtName').value || '미입력';
    var prompt =
        "다음은 형사사건 수사 진술입니다. 아래 내용을 분석하여 결과를 반드시 한국어로 답해주세요.\n\n" +
        "[사건번호: " + caseNum + "]\n[진술 유형: " + stmtType + "]\n[진술자: " + stmtName + "]\n\n" +
        "[진술 내용]\n" + text + "\n\n" +
        "다음 항목을 분석해주세요:\n1. 진술 요약 (3줄 이내)\n2. 모순 또는 불일치 항목 (있다면 구체적으로)\n3. 추가 확인이 필요한 사항\n4. 종합 평가";

    fetch('http://localhost:11434/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model: 'gemma3:1b', prompt: prompt, stream: false })
    })
    .then(function(r) { return r.json(); })
    .then(function(data) { showResult(text, data.response || '응답 없음'); })
    .catch(function() {
        var demo = "【진술 요약】\n진술자는 해당 날짜 오후 2시에 집에 있었다고 주장하며, 외출 사실을 전면 부인하고 있습니다.\n\n" +
            "【모순 항목】\n- 진술 초반 '집에 있었다'고 했으나, 이후 '잠깐 편의점을 다녀왔다'는 언급이 포함되어 있어 알리바이에 불일치가 발견됩니다.\n\n" +
            "【추가 확인 필요】\n- 편의점 CCTV 확인\n- 동거인 또는 인접 주민 목격 여부 확인\n\n" +
            "【종합 평가】\n진술에 경미한 모순이 포함되어 있으며 추가 조사가 권고됩니다.\n\n⚠ (Ollama 미연결 — 데모 결과입니다)";
        showResult(text, demo);
    });
}

function showResult(originalText, aiResponse) {
    setStep(4);
    document.getElementById('loadingCard').style.display = 'none';
    document.getElementById('resultContent').style.display = '';
    document.getElementById('transcriptBox').textContent = originalText;
    document.getElementById('aiResultBox').textContent = aiResponse;
    var keywords = ['모순','불일치','위반','거짓','허위','불명확'];
    var found = keywords.some(function(k) { return aiResponse.includes(k); });
    var banner = document.getElementById('contraBanner');
    var dot    = document.getElementById('contraDot');
    var title  = document.getElementById('contraTitle');
    var desc   = document.getElementById('contraDesc');
    if (found) {
        banner.className = 'contra-banner found';
        dot.className    = 'contra-dot red';
        title.className  = 'contra-title red';
        title.textContent = '모순 항목이 탐지되었습니다';
        desc.textContent  = 'AI가 진술에서 불일치 또는 모순된 내용을 발견했습니다.';
        document.getElementById('contraList').innerHTML =
            '<div class="contra-item"><div class="contra-item-title">알리바이 불일치</div><div class="contra-item-desc">진술 내 시간대 및 위치 정보가 상호 모순됩니다. AI 분석 결과를 참고하여 추가 확인이 필요합니다.</div></div>';
    } else {
        banner.className = 'contra-banner notfound';
        dot.className    = 'contra-dot green';
        title.className  = 'contra-title green';
        title.textContent = '명확한 모순이 탐지되지 않았습니다';
        desc.textContent  = '진술 내에서 즉각적인 모순은 발견되지 않았으나, 전체 분석 결과를 반드시 직접 검토하세요.';
        document.getElementById('contraList').innerHTML = '';
    }
}

function saveResult() {
    var btn = document.getElementById('btnSave');
    btn.disabled = true;
    btn.textContent = '저장 중...';
    var params = new URLSearchParams();
    params.append('action', 'save');
    params.append('caseId',   document.getElementById('caseNum').value.trim());
    params.append('stmtName', document.getElementById('stmtName').value.trim());
    params.append('stmtType', document.getElementById('stmtType').value);
    params.append('stmtText', document.getElementById('transcriptBox').textContent);
    params.append('aiResult', document.getElementById('aiResultBox').textContent);
    var hasCon = document.getElementById('contraBanner').classList.contains('found');
    params.append('hasContradiction', hasCon ? 'true' : 'false');
    fetch(_ctx + '/contradictionApi', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: params.toString()
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.success) {
            location.href = _ctx + '/desktop/main.jsp';
        } else {
            alert(data.error || '저장에 실패했습니다.');
            btn.disabled = false;
            btn.textContent = '결과 저장하기';
        }
    })
    .catch(function(err) {
        alert(err.message || '서버 연결 오류가 발생했습니다.');
        btn.disabled = false;
        btn.textContent = '결과 저장하기';
    });
}

function copyText() {
    var t = document.getElementById('transcriptBox').textContent;
    navigator.clipboard.writeText(t).then(function() { alert('클립보드에 복사되었습니다.'); });
}

function resetAll() {
    document.getElementById('stmtText').value = '';
    updateCharCount();
    removeFile();
    document.getElementById('placeholderCard').style.display = '';
    document.getElementById('loadingCard').style.display = 'none';
    document.getElementById('resultContent').style.display = 'none';
    ['ls1','ls2','ls3','ls4'].forEach(function(id) {
        var el = document.getElementById(id);
        el.classList.remove('active','done');
    });
    setStep(1);
}
</script>
</body>
</html>
