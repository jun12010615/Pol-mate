<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 대시보드</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<style>
  *{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
  :root{
    --deep:#0d1a33; --navy:#1a2744; --mid:#243358;
    --gold:#f0c040; --gold2:#e6b830;
    --blue:#4a7cdc; --danger:#dc2626;
    --tp:#1a1a2e; --ts:#6b7280; --tm:#9ca3af;
    --bg:#f0f2f8; --card:#ffffff; --bd:#e2e5ee;
    --success:#16a34a; --success-bg:#f0fdf4; --success-bd:#bbf7d0;
    --warn-bg:#fffbeb; --warn-text:#92400e;
    --danger-bg:#fef2f2; --danger-bd:#fecaca;
    --info-bg:#eff6ff; --info-text:#1e40af;
    --bnav:64px;
  }
  html,body{height:100%;font-family:'Noto Sans KR',sans-serif;background:var(--bg);overflow-x:hidden;}

  .screen{
    width:100%;max-width:420px;min-height:100vh;
    display:flex;flex-direction:column;margin:0 auto;background:var(--bg);
    position:relative;
  }

  /* ══ TOP HEADER ══ */
  .top-header{
    background:var(--deep);
    padding:52px 20px 0;
    position:sticky;top:0;z-index:10;
  }

  .header-main{
    display:flex;justify-content:space-between;align-items:center;
    padding-bottom:16px;
  }

  .greeting-sub{font-size:11px;color:rgba(255,255,255,0.45);margin-bottom:2px;}
  .greeting-name{
    font-family:'Space Grotesk','Noto Sans KR',sans-serif;
    font-size:18px;font-weight:700;color:#fff;letter-spacing:0.3px;
  }

  .header-icons{display:flex;gap:8px;align-items:center;}

  .icon-btn{
    width:36px;height:36px;border-radius:50%;
    background:rgba(255,255,255,0.08);
    border:1px solid rgba(255,255,255,0.12);
    display:flex;align-items:center;justify-content:center;cursor:pointer;
    position:relative;transition:background 0.15s;
  }
  .icon-btn:active{background:rgba(255,255,255,0.18);}
  .icon-btn svg{width:17px;height:17px;stroke:#fff;}

  .notif-dot{
    position:absolute;top:5px;right:5px;
    width:7px;height:7px;border-radius:50%;
    background:#ef4444;border:1.5px solid var(--deep);
  }

  /* 아바타에 마스코트 아이콘 사용 */
  .avatar-btn{
    width:36px;height:36px;border-radius:50%;cursor:pointer;
    overflow:hidden;border:1.5px solid rgba(255,255,255,0.25);
    background:var(--navy);
    display:flex;align-items:center;justify-content:center;
  }

  /* ══ 헤더 하단 골드라인 ══ */
  .header-gold-line{
    height:1.5px;
    background:linear-gradient(90deg,transparent,var(--gold) 30%,var(--gold) 70%,transparent);
    opacity:0.25;margin:0 -20px;
  }

  /* ══ 경고 배너 ══ */
  .alert-strip{
    background:var(--deep);padding:10px 20px 14px;
  }
  .alert-banner{
    background:rgba(240,192,64,0.1);
    border:1px solid rgba(240,192,64,0.25);
    border-radius:12px;padding:10px 14px;
    display:flex;gap:10px;align-items:flex-start;cursor:pointer;
    transition:background 0.15s;
  }
  .alert-banner:active{background:rgba(240,192,64,0.18);}
  .alert-pulse{
    width:7px;height:7px;border-radius:50%;
    background:var(--gold);margin-top:3px;flex-shrink:0;
    animation:pulse 2s infinite;
  }
  .alert-text{font-size:12px;color:rgba(255,255,255,0.85);line-height:1.6;}
  .alert-text strong{color:var(--gold);}

  /* ══ 스크롤 콘텐츠 ══ */
  .content{flex:1;overflow-y:auto;padding-bottom:calc(var(--bnav) + 16px);}

  /* ══ 화이트 카드 브릿지 ══ */
  .wave-bridge{background:var(--deep);padding:0;}
  .wave-card{
    background:var(--bg);border-radius:22px 22px 0 0;
    padding:22px 16px 0;
    border-top:1px solid var(--bd);
  }

  /* ══ 섹션 라벨 ══ */
  .sec-label{
    font-size:10px;font-weight:500;color:var(--tm);
    text-transform:uppercase;letter-spacing:0.8px;
    margin-bottom:10px;display:flex;align-items:center;gap:8px;
  }
  .sec-label::after{content:'';flex:1;height:1px;background:var(--bd);}

  /* ══ 메뉴 그리드 ══ */
  .menu-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:20px;}

  .menu-card{
    background:var(--card);border-radius:16px;padding:16px 14px;
    cursor:pointer;text-decoration:none;display:block;
    border:1px solid var(--bd);
    transition:transform 0.15s,border-color 0.15s;
    animation:fadeUp 0.35s ease both;
  }
  .menu-card:nth-child(1){animation-delay:0.04s;}
  .menu-card:nth-child(2){animation-delay:0.08s;}
  .menu-card:nth-child(3){animation-delay:0.12s;}
  .menu-card:nth-child(4){animation-delay:0.16s;}
  .menu-card:active{transform:scale(0.96);}
  .menu-card:hover{border-color:rgba(13,26,51,0.2);}

  .menu-icon-wrap{
    width:40px;height:40px;border-radius:12px;
    margin-bottom:10px;display:flex;align-items:center;justify-content:center;
  }
  .menu-icon-wrap svg{width:20px;height:20px;}

  /* 아이콘 컬러 테마 */
  .mi-navy  {background:#e8edf5;}
  .mi-green {background:var(--success-bg);}
  .mi-amber {background:#fffbeb;}
  .mi-purple{background:#f5f3ff;}

  .menu-name{font-size:13px;font-weight:500;margin-bottom:3px;line-height:1.3;}
  .menu-desc{font-size:10px;color:var(--tm);}
  .mn-navy  {color:var(--deep);}
  .mn-green {color:#166534;}
  .mn-amber {color:#92400e;}
  .mn-purple{color:#5b21b6;}

  /* ══ 통계 ══ */
  .stats-row{
    display:grid;grid-template-columns:repeat(3,1fr);
    gap:10px;margin-bottom:20px;padding:0 16px;
  }
  .stat-card{
    background:var(--card);border-radius:14px;
    padding:14px 10px;text-align:center;border:1px solid var(--bd);
  }
  .stat-val{
    font-family:'Space Grotesk','Noto Sans KR',sans-serif;
    font-size:24px;font-weight:700;color:var(--deep);
  }
  .stat-val.red{color:var(--danger);}
  .stat-lbl{font-size:10px;color:var(--tm);margin-top:3px;}

  /* ══ 최근 사건 ══ */
  .sec-pad{padding:0 16px;}

  .case-list{display:flex;flex-direction:column;gap:8px;margin-bottom:8px;}

  .case-item{
    background:var(--card);border-radius:14px;
    padding:13px 14px;display:flex;
    justify-content:space-between;align-items:center;
    border:1px solid var(--bd);cursor:pointer;text-decoration:none;
    transition:border-color 0.15s,background 0.15s;
    animation:fadeUp 0.35s ease both;
  }
  .case-item:hover{border-color:rgba(13,26,51,0.2);}
  .case-item:active{background:var(--bg);}
  .case-item.urgent{border-left:3px solid var(--danger);}

  .case-title{font-size:13px;font-weight:500;color:var(--tp);margin-bottom:3px;}
  .case-meta {font-size:10px;color:var(--tm);}

  .badge{font-size:10px;font-weight:500;padding:4px 10px;border-radius:20px;white-space:nowrap;flex-shrink:0;}
  .bw{background:var(--warn-bg);color:var(--warn-text);}
  .bo{background:var(--success-bg);color:var(--success);}
  .bi{background:var(--info-bg);color:var(--info-text);}
  .bd2{background:#f3f4f6;color:var(--tm);}
  .br{background:var(--danger-bg);color:var(--danger);}

  .view-all{
    display:block;text-align:center;
    font-size:12px;color:var(--deep);font-weight:500;
    padding:13px;text-decoration:none;
    border:1px solid var(--bd);border-radius:12px;
    margin:0 16px 8px;background:var(--card);
    transition:background 0.15s;
  }
  .view-all:active{background:var(--bg);}

  /* ══ BOTTOM NAV ══ */
  .bottom-nav{
    position:fixed;bottom:0;left:50%;transform:translateX(-50%);
    width:100%;max-width:420px;height:var(--bnav);
    background:var(--card);border-top:1px solid var(--bd);
    display:flex;justify-content:space-around;align-items:center;
    padding:0 8px;z-index:100;
  }
  .nav-item{
    display:flex;flex-direction:column;align-items:center;
    gap:3px;flex:1;cursor:pointer;text-decoration:none;padding:6px 0;
  }
  .nav-icon{width:24px;height:24px;display:flex;align-items:center;justify-content:center;}
  .nav-icon svg{width:22px;height:22px;}
  .nav-label{font-size:9px;}
  .nav-item.active .nav-icon svg{stroke:var(--deep);}
  .nav-item.active .nav-label{color:var(--deep);font-weight:500;}
  .nav-item:not(.active) .nav-icon svg{stroke:var(--tm);}
  .nav-item:not(.active) .nav-label{color:var(--tm);}

  /* 활성 탭 골드 인디케이터 */
  .nav-item.active{position:relative;}
  .nav-item.active::before{
    content:'';position:absolute;top:0;left:50%;transform:translateX(-50%);
    width:20px;height:2px;background:var(--gold);border-radius:0 0 2px 2px;
  }

  @keyframes fadeUp{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
  @keyframes pulse {0%,100%{opacity:1}50%{opacity:0.35}}

  @media(min-width:421px){.screen{box-shadow:0 0 48px rgba(0,0,0,0.12);}}
</style>
</head>
<body>

<%@ page import="java.sql.*, Servlet.DBConnectionMgr" %>
<%
  String loginUser = (String) session.getAttribute("loginUser");
  if (loginUser == null) { response.sendRedirect("login.jsp"); return; }
  String userName = (String) session.getAttribute("userName");
  if (userName == null) userName = loginUser;

  int cntActive = 0, cntContradiction = 0, cntTranscript = 0;
  String alertCaseId = null, alertCaseName = null;
  java.util.List<String[]> recentCases = new java.util.ArrayList<>();

  DBConnectionMgr mgr = DBConnectionMgr.getInstance();
  java.sql.Connection conn = null;
  try {
    conn = mgr.getConnection();

    java.sql.PreparedStatement ps1 = conn.prepareStatement(
      "SELECT COUNT(*) FROM CASES c JOIN TEAM_MEMBERS tm ON c.team_id=tm.team_id WHERE tm.user_id=? AND c.status!='완료'");
    ps1.setString(1, loginUser);
    java.sql.ResultSet rs1 = ps1.executeQuery();
    if (rs1.next()) cntActive = rs1.getInt(1);
    rs1.close(); ps1.close();

    java.sql.PreparedStatement ps2 = conn.prepareStatement(
      "SELECT COUNT(DISTINCT t.transcript_id) FROM TRANSCRIPTS t JOIN CASES c ON t.case_id=c.case_id JOIN TEAM_MEMBERS tm ON c.team_id=tm.team_id WHERE tm.user_id=? AND t.has_contradiction=1");
    ps2.setString(1, loginUser);
    java.sql.ResultSet rs2 = ps2.executeQuery();
    if (rs2.next()) cntContradiction = rs2.getInt(1);
    rs2.close(); ps2.close();

    java.sql.PreparedStatement ps3 = conn.prepareStatement("SELECT COUNT(*) FROM TRANSCRIPTS WHERE user_id=?");
    ps3.setString(1, loginUser);
    java.sql.ResultSet rs3 = ps3.executeQuery();
    if (rs3.next()) cntTranscript = rs3.getInt(1);
    rs3.close(); ps3.close();

    java.sql.PreparedStatement ps4 = conn.prepareStatement(
      "SELECT c.case_id,c.case_name FROM CASES c JOIN TEAM_MEMBERS tm ON c.team_id=tm.team_id WHERE tm.user_id=? AND c.status='모순탐지' ORDER BY c.updated_at DESC LIMIT 1");
    ps4.setString(1, loginUser);
    java.sql.ResultSet rs4 = ps4.executeQuery();
    if (rs4.next()) { alertCaseId=rs4.getString(1); alertCaseName=rs4.getString(2); }
    rs4.close(); ps4.close();

    java.sql.PreparedStatement ps5 = conn.prepareStatement(
      "SELECT c.case_id,c.case_name,c.status,c.updated_at FROM CASES c JOIN TEAM_MEMBERS tm ON c.team_id=tm.team_id WHERE tm.user_id=? ORDER BY c.updated_at DESC LIMIT 3");
    ps5.setString(1, loginUser);
    java.sql.ResultSet rs5 = ps5.executeQuery();
    while (rs5.next()) {
      String upd = rs5.getString("updated_at");
      recentCases.add(new String[]{ rs5.getString("case_id"), rs5.getString("case_name"), rs5.getString("status"), upd!=null?upd.substring(0,10):"" });
    }
    rs5.close(); ps5.close();

  } catch (Exception e) { e.printStackTrace(); }
  finally { mgr.freeConnection(conn); }
%>

<div class="screen">

  <!-- ══ HEADER ══ -->
  <div class="top-header">
    <div class="header-main">
      <div>
        <div class="greeting-sub">안녕하세요,</div>
        <div class="greeting-name"><%= userName %> 수사관</div>
      </div>
      <div class="header-icons">
        <button class="icon-btn" onclick="location.href='notifications.jsp'">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
          <span class="notif-dot"></span>
        </button>
        <!-- 마스코트 아이콘 아바타 -->
        <a href="mypage.jsp" class="avatar-btn">
          <svg width="28" height="28" viewBox="0 0 86 86" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="#162240"/>
            <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="#f0c040" stroke-width="2"/>
            <circle cx="43" cy="40" r="15" fill="none" stroke="#4a7cdc" stroke-width="1.3" stroke-dasharray="4 2.5" opacity="0.6"/>
            <circle cx="43" cy="40" r="11" fill="#0d1a33"/>
            <circle cx="43" cy="40" r="6" fill="#4a7cdc" opacity="0.85"/>
            <circle cx="43" cy="40" r="3" fill="#ffffff"/>
            <circle cx="43" cy="22" r="2" fill="#f0c040"/>
            <circle cx="43" cy="58" r="2" fill="#f0c040"/>
            <circle cx="28" cy="40" r="2" fill="#f0c040"/>
            <circle cx="58" cy="40" r="2" fill="#f0c040"/>
            <polygon points="43,8 44.4,12 48.5,12 45.2,14.5 46.6,18.5 43,16 39.4,18.5 40.8,14.5 37.5,12 41.6,12" fill="#f0c040"/>
          </svg>
        </a>
      </div>
    </div>
    <div class="header-gold-line"></div>
  </div>

  <!-- 경고 배너 -->
  <div class="alert-strip">
    <% if (alertCaseId != null) { %>
    <div class="alert-banner" onclick="location.href='caseList.jsp'">
      <div class="alert-pulse"></div>
      <div class="alert-text">
        <strong>사건 <%= alertCaseId %></strong> — 진술 모순이 탐지되었습니다. 검토가 필요합니다.
      </div>
    </div>
    <% } %>
  </div>

  <!-- ══ 콘텐츠 ══ -->
  <div class="content">
    <div class="wave-bridge">
      <div class="wave-card">

        <!-- 주요 기능 -->
        <div class="sec-label">주요 기능</div>
        <div class="menu-grid">
    
		<a href="writeTranscript.jsp" class="menu-card">
            <div class="menu-icon-wrap mi-navy">
              <svg viewBox="0 0 24 24" fill="none" stroke="#1a2744" stroke-width="1.8" stroke-linecap="round">
                <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                <line x1="12" y1="19" x2="12" y2="23"/>
                <line x1="8" y1="23" x2="16" y2="23"/>
              </svg>
            </div>
            <div class="menu-name mn-navy">조서 작성</div>
            <div class="menu-desc">STT + 모순 탐지</div>
          </a>

          <a href="caseRelationMap.jsp" class="menu-card">
            <div class="menu-icon-wrap mi-green">
              <svg viewBox="0 0 24 24" fill="none" stroke="#166534" stroke-width="1.8" stroke-linecap="round">
                <circle cx="6" cy="12" r="2.5"/>
                <circle cx="18" cy="5" r="2.5"/>
                <circle cx="18" cy="19" r="2.5"/>
                <line x1="8.4" y1="11.0" x2="15.6" y2="6.5"/>
                <line x1="8.4" y1="13.0" x2="15.6" y2="17.5"/>
              </svg>
            </div>
            <div class="menu-name mn-green">사건 관계망</div>
            <div class="menu-desc">인물 · 관계 시각화</div>
          </a>

          <a href="askAI" class="menu-card">
            <div class="menu-icon-wrap mi-amber">
              <!-- 마스코트 아이콘 미니 -->
              <svg width="20" height="20" viewBox="0 0 86 86" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="#92400e" opacity="0.15"/>
                <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="#92400e" stroke-width="4"/>
                <circle cx="43" cy="40" r="11" fill="#92400e" opacity="0.08"/>
                <circle cx="43" cy="40" r="6" fill="#b45309" opacity="0.7"/>
                <circle cx="43" cy="40" r="3" fill="#92400e"/>
                <circle cx="43" cy="22" r="3" fill="#b45309"/>
                <circle cx="43" cy="58" r="3" fill="#b45309"/>
                <circle cx="28" cy="40" r="3" fill="#b45309"/>
                <circle cx="58" cy="40" r="3" fill="#b45309"/>
              </svg>
            </div>
            <div class="menu-name mn-amber">AI 수사 보조</div>
            <div class="menu-desc">질의응답 · 법령 검색</div>
          </a>

          <a href="myCase.jsp" class="menu-card">
            <div class="menu-icon-wrap mi-purple">
              <svg viewBox="0 0 24 24" fill="none" stroke="#5b21b6" stroke-width="1.8" stroke-linecap="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
              </svg>
            </div>
            <div class="menu-name mn-purple">내 조서 관리</div>
            <div class="menu-desc">이력 · 수정 · 사건별</div>
          </a>

        </div>
      </div>
    </div>

    <!-- 통계 -->
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-val"><%= cntActive %></div>
        <div class="stat-lbl">진행 사건</div>
      </div>
      <div class="stat-card">
        <div class="stat-val red"><%= cntContradiction %></div>
        <div class="stat-lbl">모순 탐지</div>
      </div>
      <div class="stat-card">
        <div class="stat-val"><%= cntTranscript %></div>
        <div class="stat-lbl">작성 조서</div>
      </div>
    </div>

    <!-- 최근 사건 -->
    <div class="sec-pad">
      <div class="sec-label">최근 사건</div>
      <div class="case-list">
      <%
        String[] delays = {"0.05s","0.1s","0.15s"};
        for (int ci=0; ci<recentCases.size(); ci++) {
          String[] rc = recentCases.get(ci);
          String rcId=rc[0], rcName=rc[1], rcStatus=rc[2], rcDate=rc[3];
          boolean isUrgent = "모순탐지".equals(rcStatus);
          String badgeCls = "진행중".equals(rcStatus)?"bo":"완료".equals(rcStatus)?"bi":"모순탐지".equals(rcStatus)?"bw bd2":"bd2";
      %>
        <a href="caseList.jsp" class="case-item <%= isUrgent?"urgent":"" %>" style="animation-delay:<%= delays[ci] %>">
          <div>
            <div class="case-title"><%= rcId %> <%= rcName %></div>
            <div class="case-meta"><%= rcDate %></div>
          </div>
          <span class="badge <%= badgeCls %>"><%= rcStatus %></span>
        </a>
      <% } %>
      <% if (recentCases.isEmpty()) { %>
        <div style="text-align:center;padding:24px;color:var(--tm);font-size:13px;">배정된 사건이 없습니다.</div>
      <% } %>
      </div>
    </div>

    <a href="caseList.jsp" class="view-all">전체 사건 보기 →</a>

  </div><!-- /content -->

  <!-- ══ BOTTOM NAV ══ -->
  <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item active">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
      <span class="nav-label">홈</span>
    </a>
    <a href="myCase.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
      <span class="nav-label">조서</span>
    </a>
    <a href="askAI" class="nav-item">
      <div class="nav-icon">
        <!-- 하단 탭에도 마스코트 아이콘 미니 사용 -->
        <svg width="22" height="22" viewBox="0 0 86 86" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M43 7 L66 17 L66 41 C66 57 43 71 43 71 C43 71 20 57 20 41 L20 17 Z" fill="none" stroke="currentColor" stroke-width="5" stroke-linejoin="round"/>
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
</body>
</html>
