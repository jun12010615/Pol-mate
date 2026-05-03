<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String loginUser = (String) session.getAttribute("loginUser");
String userName  = (String) session.getAttribute("userName");
if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/desktop/login.jsp"); return; }
request.setAttribute("currentPage", "cases");
request.setAttribute("breadcrumb",  new String[]{"POL-MATE", "&#45236; &#49324;&#44148;"});
String initCaseId = request.getParameter("caseId") != null ? request.getParameter("caseId") : "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>POL-MATE | &#45236; &#49324;&#44148;</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/polmate.css">
<script>var _ctx = '<%= request.getContextPath() %>'; var _initCaseId = '<%= initCaseId %>';</script>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; font-family: 'Noto Sans KR', sans-serif; background: #f4f6fb; color: #1a1a2e; -webkit-font-smoothing: antialiased; }

.pm-page { padding: 28px 32px 48px; }


.toolbar {
    display: flex; align-items: center; gap: 12px; margin-bottom: 20px;
}
.search-box {
    flex: 1; max-width: 320px;
    display: flex; align-items: center; gap: 8px;
    background: #fff; border: 1.5px solid #e2e5ee; border-radius: 12px;
    padding: 9px 14px; transition: border-color 0.15s, box-shadow 0.15s;
}
.search-box:focus-within { border-color: #0d1a33; box-shadow: 0 0 0 3px rgba(13,26,51,0.07); }
.search-box input { border: none; background: transparent; outline: none; font-size: 13px; font-family: 'Noto Sans KR', sans-serif; color: #1a1a2e; width: 100%; }
.search-box input::placeholder { color: #9ca3af; }
.filter-chips { display: flex; gap: 6px; }
.chip {
    padding: 6px 14px; border-radius: 20px; font-size: 11px; font-family: 'Noto Sans KR', sans-serif;
    border: 1px solid #e2e5ee; background: #fff; color: #6b7280; cursor: pointer; transition: all 0.13s;
}
.chip.active { background: #0d1a33; color: #fff; border-color: #0d1a33; }
.chip:hover:not(.active) { border-color: #0d1a33; color: #0d1a33; }
.btn-new {
    display: flex; align-items: center; gap: 6px;
    background: #0d1a33; color: #fff; border: none; border-radius: 10px;
    padding: 9px 16px; font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
    font-weight: 500; cursor: pointer; transition: background 0.13s; margin-left: auto;
}
.btn-new:hover { background: #1a2744; }


.case-table { background: #fff; border: 1px solid #e2e5ee; border-radius: 16px; overflow: hidden; }
.case-table-head {
    display: grid; grid-template-columns: 130px 1fr 110px 80px 70px 70px 44px;
    padding: 10px 16px; border-bottom: 1px solid #e2e5ee; background: #f9fafb;
}
.th { font-size: 10px; font-weight: 500; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.6px; display: flex; align-items: center; }
.case-row {
    display: grid; grid-template-columns: 130px 1fr 110px 80px 70px 70px 44px;
    padding: 13px 16px; border-bottom: 1px solid #f0f2f8;
    align-items: center; cursor: pointer; transition: background 0.12s;
}
.case-row:last-child { border-bottom: none; }
.case-row:hover { background: #f4f6fb; }
.case-row.urgent { border-left: 3px solid #dc2626; padding-left: 13px; }
.case-row.selected { background: #eff6ff; }
.case-id { font-size: 11px; color: #9ca3af; font-family: 'Space Grotesk', sans-serif; }
.case-name { font-size: 13px; font-weight: 500; }
.case-suspect { font-size: 12px; color: #6b7280; }
.badge { display: inline-flex; align-items: center; font-size: 10px; font-weight: 500; padding: 3px 9px; border-radius: 20px; }
.b-jinhaeng { background: #f0fdf4; color: #16a34a; }
.b-wanryo   { background: #eff6ff; color: #1e40af; }
.b-moosun   { background: #fef2f2; color: #dc2626; }
.b-geomto   { background: #fffbeb; color: #92400e; }
.doc-count  { font-size: 12px; color: #6b7280; }
.contra-count { font-size: 12px; color: #dc2626; font-weight: 500; }
.action-btn {
    width: 30px; height: 30px; border-radius: 7px; border: none; background: transparent;
    cursor: pointer; display: flex; align-items: center; justify-content: center;
    color: #9ca3af; transition: background 0.13s, color 0.13s;
}
.action-btn:hover { background: #fee2e2; color: #dc2626; }
.empty-state { padding: 60px 20px; text-align: center; color: #9ca3af; font-size: 13px; }


.detail-overlay {
    display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.25); z-index: 200;
}
.detail-overlay.open { display: block; }
.detail-panel {
    position: fixed; top: 0; right: 0; bottom: 0; width: 520px;
    background: #fff; box-shadow: -4px 0 32px rgba(0,0,0,0.12);
    z-index: 201; display: flex; flex-direction: column;
    transform: translateX(100%); transition: transform 0.25s cubic-bezier(0.4,0,0.2,1);
    overflow: hidden;
}
.detail-panel.open { transform: translateX(0); }
.detail-header {
    padding: 20px 24px 16px; border-bottom: 1px solid #e2e5ee;
    display: flex; align-items: flex-start; gap: 12px; flex-shrink: 0;
}
.detail-close {
    width: 32px; height: 32px; border-radius: 8px; border: 1px solid #e2e5ee;
    background: transparent; cursor: pointer; display: flex; align-items: center;
    justify-content: center; color: #6b7280; transition: all 0.13s; flex-shrink: 0;
}
.detail-close:hover { background: #f4f6fb; }
.detail-title { font-size: 15px; font-weight: 500; flex: 1; margin-top: 4px; }
.detail-id { font-size: 11px; color: #9ca3af; font-family: 'Space Grotesk', sans-serif; margin-top: 2px; }
.detail-body { flex: 1; overflow-y: auto; padding: 20px 24px; }
.detail-tabs { display: flex; gap: 0; border-bottom: 1px solid #e2e5ee; margin-bottom: 20px; }
.dtab {
    padding: 8px 16px; font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
    border: none; background: transparent; cursor: pointer; color: #6b7280;
    border-bottom: 2px solid transparent; margin-bottom: -1px; transition: all 0.13s;
}
.dtab.active { color: #0d1a33; font-weight: 500; border-bottom-color: #0d1a33; }
.tab-pane { display: none; }
.tab-pane.active { display: block; }
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 20px; }
.info-item { }
.info-label { font-size: 10px; font-weight: 500; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.7px; margin-bottom: 4px; }
.info-value { font-size: 13px; color: #1a1a2e; }
.sec-label {
    font-size: 10px; font-weight: 500; color: #6b7280; text-transform: uppercase; letter-spacing: 0.8px;
    display: flex; align-items: center; gap: 8px; margin-bottom: 12px;
}
.sec-label::after { content: ''; flex: 1; height: 1px; background: #e2e5ee; }
.doc-item {
    display: flex; align-items: center; gap: 12px; padding: 10px 12px;
    border: 1px solid #e2e5ee; border-radius: 10px; margin-bottom: 8px;
    text-decoration: none; color: inherit; transition: border-color 0.13s, background 0.13s;
}
.doc-item:hover { border-color: #0d1a33; background: #f4f6fb; }
.doc-item.has-contra { border-left: 3px solid #dc2626; padding-left: 9px; }
.doc-icon { width: 32px; height: 32px; border-radius: 8px; background: #f0f2f8; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.doc-name { font-size: 13px; font-weight: 500; }
.doc-meta { font-size: 11px; color: #9ca3af; margin-top: 1px; }
.status-form { display: flex; gap: 8px; align-items: center; margin-bottom: 20px; }
.status-select {
    padding: 8px 12px; border: 1.5px solid #e2e5ee; border-radius: 10px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif; color: #1a1a2e;
    background: #fff; outline: none; cursor: pointer;
}
.btn-save {
    padding: 8px 16px; background: #0d1a33; color: #fff; border: none; border-radius: 10px;
    font-size: 12px; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; transition: background 0.13s;
}
.btn-save:hover { background: #1a2744; }
.btn-danger {
    padding: 8px 14px; background: transparent; color: #dc2626; border: 1px solid #fecaca;
    border-radius: 10px; font-size: 12px; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; transition: all 0.13s;
}
.btn-danger:hover { background: #fef2f2; }
.detail-footer {
    padding: 14px 24px; border-top: 1px solid #e2e5ee;
    display: flex; gap: 8px; flex-shrink: 0;
}


.modal-backdrop { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.35); z-index: 300; align-items: center; justify-content: center; }
.modal-backdrop.open { display: flex; }
.modal { background: #fff; border-radius: 16px; padding: 28px; width: 460px; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
.modal-title { font-size: 16px; font-weight: 500; margin-bottom: 20px; }
.form-field { margin-bottom: 14px; }
.form-label { display: block; font-size: 10px; font-weight: 500; color: #6b7280; text-transform: uppercase; letter-spacing: 0.7px; margin-bottom: 6px; }
.form-input, .form-select {
    width: 100%; padding: 11px 14px;
    border: 1.5px solid #e2e5ee; border-radius: 10px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif; color: #1a1a2e;
    background: #f4f6fb; outline: none; transition: border-color 0.15s, background 0.15s, box-shadow 0.15s;
}
.form-input:focus, .form-select:focus { border-color: #0d1a33; background: #fff; box-shadow: 0 0 0 3px rgba(13,26,51,0.07); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 20px; }
.btn-cancel { padding: 9px 18px; background: transparent; border: 1px solid #e2e5ee; border-radius: 10px; font-size: 13px; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; color: #6b7280; }
.btn-confirm { padding: 9px 18px; background: #0d1a33; color: #fff; border: none; border-radius: 10px; font-size: 13px; font-family: 'Noto Sans KR', sans-serif; cursor: pointer; }
.toast {
    position: fixed; bottom: 28px; left: 50%; transform: translateX(-50%) translateY(80px);
    background: #1a2744; color: #fff; padding: 10px 20px; border-radius: 10px;
    font-size: 13px; font-family: 'Noto Sans KR', sans-serif;
    opacity: 0; transition: all 0.25s; z-index: 500; white-space: nowrap;
}
.toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
</style>
</head>
<body>
<div class="pm-layout">

<%@ include file="sidebar.jsp" %>
<%@ include file="appbar.jsp" %>

<main class="pm-page">

    <div class="toolbar">
        <div class="search-box">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="1.8" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="searchInput" placeholder="&#49324;&#44148;&#48264;&#54840;, &#54588;&#51032;&#51088;, &#51333;&#47448; &#44160;&#49353;..." oninput="filterCases()">
        </div>
        <div class="filter-chips">
            <button class="chip active" data-status="all" onclick="setFilter(this)">&#51204;&#52404;</button>
            <button class="chip" data-status="&#51652;&#54665;&#51473;" onclick="setFilter(this)">&#51652;&#54665;&#51473;</button>
            <button class="chip" data-status="&#47784;&#49692;&#53460;&#51648;" onclick="setFilter(this)">&#47784;&#49692;&#53468;&#51648;</button>
            <button class="chip" data-status="&#44160;&#53664;&#54596;&#50836;" onclick="setFilter(this)">&#44160;&#53664;&#54596;&#50836;</button>
            <button class="chip" data-status="&#50756;&#47308;" onclick="setFilter(this)">&#50756;&#47308;</button>
        </div>
        <button class="btn-new" onclick="openNewModal()">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            &#49352; &#49324;&#44148;
        </button>
    </div>

    <div class="case-table">
        <div class="case-table-head">
            <span class="th">&#49324;&#44148;&#48264;&#54840;</span>
            <span class="th">&#49324;&#44148;&#47749;</span>
            <span class="th">&#54588;&#51032;&#51088;</span>
            <span class="th">&#49345;&#53468;</span>
            <span class="th">&#51109;&#49436;</span>
            <span class="th">&#47784;&#49692;</span>
            <span class="th"></span>
        </div>
        <div id="caseList">
            <div class="empty-state">&#47196;&#46377; &#51473;...</div>
        </div>
    </div>

</main>

</div>
</div>


<div class="detail-overlay" id="detailOverlay" onclick="closeDetail()"></div>
<div class="detail-panel" id="detailPanel">
    <div class="detail-header">
        <div style="flex:1">
            <div class="detail-id" id="dpId"></div>
            <div class="detail-title" id="dpName"></div>
        </div>
        <button class="detail-close" onclick="closeDetail()">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
    </div>
    <div class="detail-body">
        <div class="detail-tabs">
            <button class="dtab active" onclick="switchTab('info')">&#44592;&#48376; &#51221;&#48372;</button>
            <button class="dtab" onclick="switchTab('docs')">&#51109;&#49436; &#47785;&#47197;</button>
        </div>
        <div class="tab-pane active" id="tabInfo">
            <div class="info-grid" id="dpInfoGrid"></div>
            <div class="sec-label" style="margin-top:16px">&#49345;&#53468; &#48320;&#44221;</div>
            <div class="status-form">
                <select class="status-select" id="dpStatusSel">
                    <option>&#51652;&#54665;&#51473;</option>
                    <option>&#44160;&#53664;&#54596;&#50836;</option>
                    <option>&#50756;&#47308;</option>
                </select>
                <button class="btn-save" onclick="saveStatus()">&#51200;&#51109;</button>
            </div>
        </div>
        <div class="tab-pane" id="tabDocs">
            <div id="dpDocList"><div class="empty-state">&#51109;&#49436;&#44032; &#50630;&#49845;&#45768;&#45796;</div></div>
            <div style="margin-top:16px">
                <a id="btnNewDoc" href="#" class="btn-new" style="display:inline-flex;text-decoration:none;">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    &#51109;&#49436; &#51089;&#49457;
                </a>
            </div>
        </div>
    </div>
    <div class="detail-footer">
        <button class="btn-danger" onclick="deleteCase()">&#49324;&#44148; &#49325;&#51228;</button>
    </div>
</div>


<div class="modal-backdrop" id="newModal">
    <div class="modal" onclick="event.stopPropagation()">
        <div class="modal-title">&#49352; &#49324;&#44148; &#46321;&#47197;</div>
        <div class="form-field">
            <label class="form-label">&#49324;&#44148;&#47749; <span style="color:#dc2626">*</span></label>
            <input type="text" class="form-input" id="newCaseName" placeholder="&#49324;&#44148;&#47749; &#51077;&#47141;">
        </div>
        <div class="form-field">
            <label class="form-label">&#54588;&#51032;&#51088;</label>
            <input type="text" class="form-input" id="newSuspect" placeholder="&#54588;&#51032;&#51088; &#49457;&#47749;">
        </div>
        <div class="form-field">
            <label class="form-label">&#51333;&#47448;</label>
            <input type="text" class="form-input" id="newCharge" placeholder="&#51333;&#47448;&#47749; (&#50696;: &#51208;&#46020;&#51452;&#44144;&#51644;)">
        </div>
        <div class="modal-actions">
            <button class="btn-cancel" onclick="closeNewModal()">&#52712;&#49548;</button>
            <button class="btn-confirm" onclick="createCase()">&#46321;&#47197;</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script>
var _cases = [];
var _currentFilter = 'all';
var _currentCaseId = null;

function badgeClass(status) {
    if (status === '&#51652;&#54665;&#51473;') return 'b-jinhaeng';
    if (status === '&#47784;&#49692;&#53460;&#51648;') return 'b-moosun';
    if (status === '&#44160;&#53664;&#54596;&#50836;') return 'b-geomto';
    return 'b-wanryo';
}

function loadCases() {
    fetch(_ctx + '/caseApi?action=caseList', {credentials: 'same-origin'})
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (Array.isArray(data)) {
                _cases = data;
            } else if (data.cases) {
                _cases = data.cases;
            } else {
                _cases = [];
            }
            renderCases();
        })
        .catch(function() { showToast('&#49324;&#44148; &#47785;&#47197;&#47484; &#48266;&#47140;&#50625; &#49688; &#50630;&#49845;&#45768;&#45796;.'); });
}

function renderCases() {
    var kw = document.getElementById('searchInput').value.trim().toLowerCase();
    var list = _cases.filter(function(c) {
        var matchFilter = _currentFilter === 'all' || c.status === _currentFilter;
        var matchKw = !kw || (c.id||'').toLowerCase().includes(kw)
            || (c.name||'').toLowerCase().includes(kw)
            || (c.suspect||'').toLowerCase().includes(kw);
        return matchFilter && matchKw;
    });

    var el = document.getElementById('caseList');
    if (list.length === 0) {
        el.innerHTML = '<div class="empty-state">&#51312;&#44148;&#54616;&#45716; &#49324;&#44148;&#51060; &#50630;&#49845;&#45768;&#45796;</div>';
        return;
    }

    el.innerHTML = list.map(function(c) {
        var bc = badgeClass(c.status);
        var urgent = c.urgent ? 'urgent' : '';
        var sel = c.id === _currentCaseId ? 'selected' : '';
        return '<div class="case-row ' + urgent + ' ' + sel + '" onclick="openDetail(\'' + c.id + '\')">'
            + '<span class="case-id">' + (c.id||'') + '</span>'
            + '<span class="case-name">' + (c.name||'') + '</span>'
            + '<span class="case-suspect">' + (c.suspect||'') + '</span>'
            + '<span><span class="badge ' + bc + '">' + (c.status||'') + '</span></span>'
            + '<span class="doc-count">' + (c.docs||0) + '&#44148;</span>'
            + '<span class="contra-count">' + (c.contradictions > 0 ? c.contradictions + '&#44148;' : '-') + '</span>'
            + '<button class="action-btn" title="&#49325;&#51228;" onclick="event.stopPropagation();confirmDelete(\'' + c.id + '\')">'
            + '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>'
            + '</button>'
            + '</div>';
    }).join('');
}

function setFilter(btn) {
    document.querySelectorAll('.chip').forEach(function(c) { c.classList.remove('active'); });
    btn.classList.add('active');
    _currentFilter = btn.dataset.status;
    renderCases();
}

function filterCases() { renderCases(); }

function openDetail(caseId) {
    _currentCaseId = caseId;
    renderCases();
    document.getElementById('detailOverlay').classList.add('open');
    document.getElementById('detailPanel').classList.add('open');
    switchTab('info');

    fetch(_ctx + '/caseApi?action=caseDetail&caseId=' + encodeURIComponent(caseId), {credentials: 'same-origin'})
        .then(function(r) { return r.json(); })
        .then(function(d) {
            var c = d.case || d;
            document.getElementById('dpId').textContent = c.id || caseId;
            document.getElementById('dpName').textContent = c.name || '';
            document.getElementById('dpStatusSel').value = c.status || '&#51652;&#54665;&#51473;';

            var grid = document.getElementById('dpInfoGrid');
            grid.innerHTML = [
                ['&#54588;&#51032;&#51088;', c.suspect || '-'],
                ['&#51333;&#47448;', c.charge || '-'],
                ['&#45817;&#45813; &#49688;&#49324;&#44288;', (c.rank || '') + ' ' + (c.detective || '-')],
                ['&#54861;&#49345; &#48512;&#49436;', c.dept_name || '-'],
                ['&#46321;&#47197;&#51068;', c.date || '-'],
                ['&#51109;&#49436; &#49688;', (c.docs || 0) + '&#44148;']
            ].map(function(pair) {
                return '<div class="info-item"><div class="info-label">' + pair[0] + '</div><div class="info-value">' + pair[1] + '</div></div>';
            }).join('');

            var docs = d.documents || c.documents || [];
            var docEl = document.getElementById('dpDocList');
            if (docs.length === 0) {
                docEl.innerHTML = '<div class="empty-state">&#51109;&#49436;&#44032; &#50630;&#49845;&#45768;&#45796;</div>';
            } else {
                docEl.innerHTML = docs.map(function(doc) {
                    var contra = doc.has_contradiction ? 'has-contra' : '';
                    return '<a href="' + _ctx + '/desktop/writeTranscript.jsp?transcriptId=' + (doc.id||'') + '" class="doc-item ' + contra + '">'
                        + '<div class="doc-icon"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6b7280" stroke-width="1.8" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>'
                        + '<div style="flex:1"><div class="doc-name">' + (doc.subject || doc.title || '&#51109;&#49436; #' + doc.id) + '</div>'
                        + '<div class="doc-meta">' + (doc.created_at || '') + (doc.has_contradiction ? ' &nbsp;&#9656; &#47784;&#49692; &#53460;&#51648;' : '') + '</div></div>'
                        + '</a>';
                }).join('');
            }
            document.getElementById('btnNewDoc').href = _ctx + '/desktop/writeTranscript.jsp?caseId=' + encodeURIComponent(caseId);
        })
        .catch(function() { showToast('&#49324;&#44148; &#49345;&#49464;&#47484; &#48266;&#47140;&#50625; &#49688; &#50630;&#49845;&#45768;&#45796;.'); });
}

function closeDetail() {
    _currentCaseId = null;
    document.getElementById('detailOverlay').classList.remove('open');
    document.getElementById('detailPanel').classList.remove('open');
    renderCases();
}

function switchTab(name) {
    document.querySelectorAll('.dtab').forEach(function(t, i) {
        t.classList.toggle('active', (i === 0 && name === 'info') || (i === 1 && name === 'docs'));
    });
    document.getElementById('tabInfo').classList.toggle('active', name === 'info');
    document.getElementById('tabDocs').classList.toggle('active', name === 'docs');
}

function saveStatus() {
    if (!_currentCaseId) return;
    var status = document.getElementById('dpStatusSel').value;
    var fd = new FormData();
    fd.append('action', 'caseStatus');
    fd.append('caseId', _currentCaseId);
    fd.append('status', status);
    fetch(_ctx + '/caseApi', {method: 'POST', body: fd, credentials: 'same-origin'})
        .then(function(r) { return r.json(); })
        .then(function() {
            showToast('&#49345;&#53468;&#44032; &#50629;&#45936;&#51060;&#53944;&#46104;&#50632;&#49845;&#45768;&#45796;.');
            loadCases();
        });
}

function confirmDelete(caseId) {
    if (!confirm('&#49324;&#44148; ' + caseId + '&#47484; &#49325;&#51228;&#54616;&#49884;&#44192;&#49845;&#45768;&#44992;?')) return;
    doDelete(caseId);
}
function deleteCase() {
    if (!_currentCaseId) return;
    if (!confirm('&#49324;&#44148; ' + _currentCaseId + '&#47484; &#49325;&#51228;&#54616;&#49884;&#44192;&#49845;&#45768;&#44992;?')) return;
    doDelete(_currentCaseId);
    closeDetail();
}
function doDelete(caseId) {
    var fd = new FormData();
    fd.append('action', 'caseDelete');
    fd.append('caseId', caseId);
    fetch(_ctx + '/caseApi', {method: 'POST', body: fd, credentials: 'same-origin'})
        .then(function(r) { return r.json(); })
        .then(function() { showToast('&#49325;&#51228;&#46104;&#50632;&#49845;&#45768;&#45796;.'); loadCases(); });
}

function openNewModal() { document.getElementById('newModal').classList.add('open'); }
function closeNewModal() { document.getElementById('newModal').classList.remove('open'); }

function createCase() {
    var name = document.getElementById('newCaseName').value.trim();
    if (!name) { showToast('&#49324;&#44148;&#47749;&#51012; &#51077;&#47141;&#54644; &#51452;&#49464;&#50836;.'); return; }
    var fd = new FormData();
    fd.append('action', 'caseCreate');
    fd.append('caseName', name);
    fd.append('suspect', document.getElementById('newSuspect').value.trim());
    fd.append('charge',  document.getElementById('newCharge').value.trim());
    fetch(_ctx + '/caseApi', {method: 'POST', body: fd, credentials: 'same-origin'})
        .then(function(r) { return r.json(); })
        .then(function(d) {
            closeNewModal();
            document.getElementById('newCaseName').value = '';
            document.getElementById('newSuspect').value = '';
            document.getElementById('newCharge').value = '';
            showToast('&#49324;&#44148;&#51060; &#46321;&#47197;&#46104;&#50632;&#49845;&#45768;&#45796;.');
            loadCases();
            if (d.caseId) openDetail(d.caseId);
        })
        .catch(function() { showToast('&#46321;&#47197; &#51473; &#50724;&#47448;&#44032; &#48156;&#49373;&#54588;&#49845;&#45768;&#45796;.'); });
}

function showToast(msg) {
    var t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('show');
    setTimeout(function() { t.classList.remove('show'); }, 2500);
}

loadCases();


if (_initCaseId) { setTimeout(function() { openDetail(_initCaseId); }, 300); }
</script>
</body>
</html>
