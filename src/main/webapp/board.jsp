<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>POL-MATE | 커뮤니티</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
:root{
  --deep:#0d1a33;--navy:#1a2744;--mid:#243358;
  --gold:#f0c040;--blue:#4a7cdc;--danger:#dc2626;
  --tp:#1a1a2e;--ts:#6b7280;--tm:#9ca3af;
  --bg:#f0f2f8;--card:#ffffff;--bd:#e2e5ee;
  --success:#16a34a;--success-bg:#f0fdf4;
  --bnav:64px;

  /* 카테고리 테마 */
  --tip-bg:#fff7ed;--tip-bd:#fed7aa;--tip-text:#c2410c;--tip-icon:#f97316;
  --gear-bg:#f0fdf4;--gear-bd:#bbf7d0;--gear-text:#166534;--gear-icon:#16a34a;
  --free-bg:#eff6ff;--free-bd:#bfdbfe;--free-text:#1e40af;--free-icon:#4a7cdc;
}
html,body{height:100%;font-family:'Noto Sans KR',sans-serif;background:var(--bg);overflow-x:hidden;}
.screen{width:100%;max-width:420px;min-height:100vh;margin:0 auto;background:var(--bg);display:flex;flex-direction:column;}

/* ── 헤더 ── */
.top-header{background:var(--deep);padding:52px 20px 0;position:sticky;top:0;z-index:20;}
.header-row{display:flex;align-items:center;justify-content:space-between;padding-bottom:14px;}
.header-left{}
.header-title{font-size:17px;font-weight:700;color:#fff;letter-spacing:-0.3px;}
.header-sub{font-size:10px;color:rgba(255,255,255,0.45);margin-top:2px;}
.write-btn{
  display:flex;align-items:center;gap:5px;
  background:var(--gold);border:none;border-radius:20px;
  padding:8px 14px;font-size:12px;font-weight:700;
  color:var(--deep);cursor:pointer;font-family:'Noto Sans KR',sans-serif;
  transition:transform 0.1s;flex-shrink:0;
}
.write-btn:active{transform:scale(0.95);}
.write-btn svg{width:13px;height:13px;stroke:var(--deep);stroke-width:2.5;}
.header-gold-line{height:1.5px;background:linear-gradient(90deg,transparent,var(--gold) 30%,var(--gold) 70%,transparent);opacity:0.25;margin:0 -20px;}

/* ── 카테고리 탭 ── */
.cat-tabs{display:flex;background:var(--deep);padding:0 16px 12px;}
.cat-tab{
  flex:1;padding:12px 6px;font-size:12px;font-weight:500;
  color:rgba(255,255,255,0.45);border:none;background:none;
  cursor:pointer;font-family:'Noto Sans KR',sans-serif;
  border-bottom:2px solid transparent;transition:all 0.2s;
  display:flex;align-items:center;justify-content:center;gap:5px;
  white-space:nowrap;
}
.cat-tab.active{color:#fff;border-bottom-color:var(--gold);}
.cat-tab .tab-dot{width:6px;height:6px;border-radius:50%;flex-shrink:0;}
.tip-dot{background:var(--tip-icon);}
.gear-dot{background:var(--gear-icon);}
.free-dot{background:var(--free-icon);}

/* ── 콘텐츠 ── */
.content{flex:1;overflow-y:auto;padding:22px 14px calc(var(--bnav)+20px);}

/* ── 검색 + 정렬 바 ── */
.filter-bar{display:flex;gap:8px;margin-bottom:14px;align-items:center;}
.search-wrap{flex:1;position:relative;}
.search-input{
  width:100%;padding:10px 14px 10px 36px;
  background:var(--card);border:1px solid var(--bd);border-radius:12px;
  font-size:13px;font-family:'Noto Sans KR',sans-serif;
  color:var(--tp);outline:none;transition:border-color 0.2s;
}
.search-input:focus{border-color:var(--blue);}
.search-icon{position:absolute;left:11px;top:50%;transform:translateY(-50%);width:15px;height:15px;stroke:var(--tm);pointer-events:none;}
.sort-btn{
  padding:10px 12px;background:var(--card);border:1px solid var(--bd);
  border-radius:12px;font-size:12px;color:var(--ts);
  cursor:pointer;font-family:'Noto Sans KR',sans-serif;
  white-space:nowrap;display:flex;align-items:center;gap:4px;
}
.sort-btn svg{width:13px;height:13px;stroke:var(--ts);}

/* ── 고정 공지 ── */
.notice-card{
  background:var(--navy);border-radius:14px;padding:13px 15px;
  margin-bottom:10px;display:flex;align-items:center;gap:10px;
  border:1px solid rgba(240,192,64,0.25);
}
.notice-badge{
  background:var(--gold);color:var(--deep);
  font-size:10px;font-weight:700;padding:3px 7px;border-radius:6px;flex-shrink:0;
}
.notice-text{font-size:12px;color:rgba(255,255,255,0.85);line-height:1.5;flex:1;}

/* ── 게시글 카드 ── */
.post-list{display:flex;flex-direction:column;gap:10px;}
.post-card{
  background:var(--card);border-radius:16px;border:1px solid var(--bd);
  padding:15px;cursor:pointer;transition:border-color 0.15s,transform 0.1s;
  animation:fadeUp 0.3s ease both;
}
.post-card:active{transform:scale(0.985);border-color:var(--blue);}
.post-header{display:flex;align-items:flex-start;gap:10px;margin-bottom:10px;}
.post-cat-badge{
  font-size:10px;font-weight:700;padding:3px 8px;border-radius:6px;
  flex-shrink:0;white-space:nowrap;margin-top:1px;
}
.badge-tip {background:var(--tip-bg);color:var(--tip-text);border:1px solid var(--tip-bd);}
.badge-gear{background:var(--gear-bg);color:var(--gear-text);border:1px solid var(--gear-bd);}
.badge-free{background:var(--free-bg);color:var(--free-text);border:1px solid var(--free-bd);}
.post-title{font-size:14px;font-weight:500;color:var(--tp);line-height:1.4;flex:1;}
.post-preview{font-size:12px;color:var(--ts);line-height:1.6;margin-bottom:11px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.post-footer{display:flex;align-items:center;justify-content:space-between;}
.post-author{display:flex;align-items:center;gap:7px;}
.author-avatar{
  width:24px;height:24px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;
  font-size:10px;font-weight:700;color:#fff;flex-shrink:0;
}
.author-name{font-size:11px;color:var(--ts);}
.author-date{font-size:10px;color:var(--tm);margin-left:2px;}
.post-stats{display:flex;align-items:center;gap:10px;}
.stat-item{display:flex;align-items:center;gap:3px;font-size:11px;color:var(--tm);}
.stat-item svg{width:12px;height:12px;stroke:var(--tm);}
.stat-item.hot{color:var(--danger);}
.stat-item.hot svg{stroke:var(--danger);}

/* 인기글 강조 */
.post-card.hot-post{border-left:3px solid var(--gold);}
.hot-label{
  font-size:10px;font-weight:700;color:var(--gold);
  background:rgba(240,192,64,0.12);padding:2px 7px;border-radius:6px;
  display:inline-flex;align-items:center;gap:3px;margin-bottom:6px;
}

/* ── 플로팅 글쓰기 버튼 ── */
.fab{
  position:fixed;bottom:calc(var(--bnav)+16px);right:calc(50% - 210px + 16px);
  width:50px;height:50px;border-radius:50%;
  background:var(--deep);border:2px solid var(--gold);
  display:flex;align-items:center;justify-content:center;
  cursor:pointer;z-index:15;box-shadow:0 4px 16px rgba(13,26,51,0.35);
  transition:transform 0.15s;
}
.fab:active{transform:scale(0.92);}
.fab svg{width:20px;height:20px;stroke:var(--gold);stroke-width:2;}
@media(max-width:420px){.fab{right:16px;}}

/* ── 상세 모달 ── */
.modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:100;display:none;overflow-y:auto;}
.modal-overlay.open{display:block;}
.modal-sheet{
  background:var(--bg);min-height:100vh;
  max-width:420px;margin:0 auto;
  animation:slideUp 0.28s ease;
}
@keyframes slideUp{from{transform:translateY(40px);opacity:0}to{transform:translateY(0);opacity:1}}

.modal-header{
  background:var(--deep);padding:52px 20px 18px;
  position:sticky;top:0;z-index:5;
}
.modal-back{display:flex;align-items:center;gap:10px;}
.modal-back-btn{
  width:34px;height:34px;border-radius:50%;
  background:rgba(255,255,255,0.12);border:none;
  display:flex;align-items:center;justify-content:center;cursor:pointer;flex-shrink:0;
}
.modal-back-btn svg{width:17px;height:17px;stroke:#fff;}
.modal-back-title{font-size:15px;font-weight:500;color:#fff;}

.modal-body{padding:18px 16px 40px;}
.detail-cat-badge{display:inline-block;margin-bottom:10px;}
.detail-title{font-size:18px;font-weight:700;color:var(--tp);line-height:1.4;margin-bottom:12px;}
.detail-meta{display:flex;align-items:center;gap:12px;padding-bottom:14px;border-bottom:1px solid var(--bd);margin-bottom:16px;}
.detail-author-row{display:flex;align-items:center;gap:8px;flex:1;}
.detail-avatar{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#fff;}
.detail-author-name{font-size:13px;font-weight:500;color:var(--tp);}
.detail-author-info{font-size:11px;color:var(--tm);}
.detail-stats{display:flex;gap:10px;}
.detail-stat{display:flex;align-items:center;gap:4px;font-size:12px;color:var(--tm);}
.detail-stat svg{width:13px;height:13px;stroke:var(--tm);}

.detail-content{font-size:14px;color:var(--tp);line-height:1.9;margin-bottom:20px;white-space:pre-wrap;}

/* 첨부 태그 */
.attach-row{display:flex;flex-wrap:wrap;gap:7px;margin-bottom:20px;}
.attach-tag{
  display:flex;align-items:center;gap:5px;
  background:var(--bg);border:1px solid var(--bd);border-radius:8px;
  padding:6px 10px;font-size:11px;color:var(--ts);cursor:pointer;
}
.attach-tag svg{width:13px;height:13px;stroke:var(--ts);}

/* 구매 링크 카드 (수사 장비 전용) */
.buy-links-section{margin-bottom:20px;}
.buy-links-title{font-size:12px;font-weight:700;color:var(--gear-text);display:flex;align-items:center;gap:5px;margin-bottom:8px;}
.buy-links-title svg{width:13px;height:13px;stroke:var(--gear-icon);}
.buy-link-card{
  display:flex;align-items:center;gap:12px;
  background:var(--gear-bg);border:1px solid var(--gear-bd);
  border-radius:12px;padding:12px 14px;margin-bottom:8px;
  text-decoration:none;transition:border-color 0.15s,transform 0.1s;
  cursor:pointer;
}
.buy-link-card:active{transform:scale(0.98);border-color:var(--gear-icon);}
.buy-link-icon{
  width:34px;height:34px;border-radius:10px;
  background:var(--gear-icon);display:flex;align-items:center;
  justify-content:center;flex-shrink:0;
}
.buy-link-icon svg{width:17px;height:17px;stroke:#fff;stroke-width:2;}
.buy-link-info{flex:1;min-width:0;}
.buy-link-name{font-size:13px;font-weight:600;color:var(--gear-text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.buy-link-url{font-size:10px;color:var(--tm);margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.buy-link-arrow{width:20px;height:20px;flex-shrink:0;stroke:var(--gear-icon);stroke-width:2;}

/* 글쓰기 - 링크 입력 필드 */
.link-input-group{display:flex;flex-direction:column;gap:8px;}
.link-input-row{display:flex;gap:6px;align-items:center;}
.link-input-row .write-input{flex:1;}
.link-del-btn{
  width:34px;height:38px;border-radius:10px;border:1px solid var(--bd);
  background:var(--bg);display:flex;align-items:center;justify-content:center;
  cursor:pointer;flex-shrink:0;
}
.link-del-btn svg{width:14px;height:14px;stroke:var(--danger);}
.link-add-btn{
  display:flex;align-items:center;gap:5px;
  background:var(--gear-bg);border:1px solid var(--gear-bd);
  border-radius:10px;padding:9px 13px;font-size:12px;
  font-weight:600;color:var(--gear-text);cursor:pointer;
  font-family:'Noto Sans KR',sans-serif;transition:background 0.15s;
  width:100%;justify-content:center;
}
.link-add-btn svg{width:13px;height:13px;stroke:var(--gear-icon);}
#gearLinkSection{display:none;margin-top:0;}

/* 좋아요 버튼 */
.like-wrap{display:flex;justify-content:center;margin-bottom:22px;}
.like-btn{
  display:flex;align-items:center;gap:7px;
  background:var(--card);border:1.5px solid var(--bd);border-radius:24px;
  padding:10px 22px;font-size:14px;font-weight:500;color:var(--ts);
  cursor:pointer;font-family:'Noto Sans KR',sans-serif;transition:all 0.15s;
}
.like-btn svg{width:18px;height:18px;stroke:var(--ts);transition:all 0.15s;}
.like-btn.liked{border-color:#ef4444;color:#ef4444;}
.like-btn.liked svg{stroke:#ef4444;fill:#ef4444;}

/* ── 댓글 ── */
.comment-section{border-top:1px solid var(--bd);padding-top:18px;}
.comment-title{font-size:13px;font-weight:700;color:var(--tp);margin-bottom:14px;display:flex;align-items:center;gap:6px;}
.comment-count-badge{
  background:var(--blue);color:#fff;font-size:10px;font-weight:700;
  padding:2px 7px;border-radius:10px;
}
.comment-item{display:flex;gap:10px;margin-bottom:16px;}
.comment-avatar{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;color:#fff;flex-shrink:0;margin-top:1px;}
.comment-body{flex:1;}
.comment-author-row{display:flex;align-items:center;gap:7px;margin-bottom:4px;}
.comment-author{font-size:12px;font-weight:600;color:var(--tp);}
.comment-time{font-size:10px;color:var(--tm);}
.comment-text{font-size:13px;color:var(--ts);line-height:1.7;}
.comment-actions{display:flex;gap:10px;margin-top:5px;}
.comment-action-btn{font-size:11px;color:var(--tm);background:none;border:none;cursor:pointer;font-family:'Noto Sans KR',sans-serif;padding:0;}

/* 댓글 입력 */
.comment-input-wrap{
  position:sticky;bottom:0;background:var(--card);
  border-top:1px solid var(--bd);padding:12px 16px;
  display:flex;gap:8px;align-items:flex-end;
}
.comment-textarea{
  flex:1;padding:10px 13px;background:var(--bg);
  border:1px solid var(--bd);border-radius:12px;
  font-size:13px;font-family:'Noto Sans KR',sans-serif;
  color:var(--tp);outline:none;resize:none;max-height:80px;
  line-height:1.5;
}
.comment-textarea:focus{border-color:var(--blue);}
.comment-submit{
  width:38px;height:38px;border-radius:12px;background:var(--deep);border:none;
  display:flex;align-items:center;justify-content:center;cursor:pointer;flex-shrink:0;
  transition:transform 0.1s;
}
.comment-submit:active{transform:scale(0.92);}
.comment-submit svg{width:16px;height:16px;stroke:#fff;stroke-width:2;}

/* ── 글쓰기 모달 ── */
.write-modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:200;display:none;overflow-y:auto;}
.write-modal-overlay.open{display:block;}
.write-modal{background:var(--bg);min-height:100vh;max-width:420px;margin:0 auto;}
.write-modal-header{background:var(--deep);padding:52px 20px 18px;position:sticky;top:0;z-index:5;}
.write-modal-title{display:flex;align-items:center;justify-content:space-between;}
.write-close-btn{width:34px;height:34px;border-radius:50%;background:rgba(255,255,255,0.12);border:none;display:flex;align-items:center;justify-content:center;cursor:pointer;}
.write-close-btn svg{width:17px;height:17px;stroke:#fff;}
.write-submit-btn{
  background:var(--gold);border:none;border-radius:20px;
  padding:8px 16px;font-size:13px;font-weight:700;
  color:var(--deep);cursor:pointer;font-family:'Noto Sans KR',sans-serif;
}
.write-body{padding:18px 16px 40px;}
.write-field{margin-bottom:14px;}
.write-label{font-size:11px;font-weight:600;color:var(--ts);display:block;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;}
.write-input{
  width:100%;padding:12px 14px;background:var(--card);
  border:1px solid var(--bd);border-radius:12px;
  font-size:14px;font-family:'Noto Sans KR',sans-serif;
  color:var(--tp);outline:none;transition:border-color 0.2s;
}
.write-input:focus{border-color:var(--blue);}
.write-textarea{
  width:100%;padding:12px 14px;background:var(--card);
  border:1px solid var(--bd);border-radius:12px;
  font-size:14px;font-family:'Noto Sans KR',sans-serif;
  color:var(--tp);outline:none;resize:none;line-height:1.7;
  min-height:200px;transition:border-color 0.2s;
}
.write-textarea:focus{border-color:var(--blue);}
.cat-selector{display:flex;gap:8px;}
.cat-sel-btn{
  flex:1;padding:11px 8px;border-radius:12px;border:2px solid var(--bd);
  background:var(--card);font-size:12px;font-weight:600;
  font-family:'Noto Sans KR',sans-serif;cursor:pointer;
  display:flex;flex-direction:column;align-items:center;gap:5px;
  transition:all 0.15s;color:var(--ts);
}
.cat-sel-btn .sel-icon{font-size:20px;}
.cat-sel-btn.sel-tip{border-color:var(--tip-icon);background:var(--tip-bg);color:var(--tip-text);}
.cat-sel-btn.sel-gear{border-color:var(--gear-icon);background:var(--gear-bg);color:var(--gear-text);}
.cat-sel-btn.sel-free{border-color:var(--free-icon);background:var(--free-bg);color:var(--free-text);}

/* ── 하단 네비 ── */
.bottom-nav{
  position:fixed;bottom:0;left:50%;transform:translateX(-50%);
  width:100%;max-width:420px;height:var(--bnav);
  background:var(--card);border-top:1px solid var(--bd);
  display:flex;z-index:10;
}
.nav-item{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;text-decoration:none;color:var(--tm);cursor:pointer;border:none;background:none;font-family:'Noto Sans KR',sans-serif;}
.nav-item.active{color:var(--deep);}
.nav-item.active .nav-label{font-weight:600;}
.nav-icon{width:22px;height:22px;display:flex;align-items:center;justify-content:center;}
.nav-icon svg{width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;}
.nav-label{font-size:10px;}

/* ── 유틸 ── */
@keyframes fadeUp{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
.empty-state{text-align:center;padding:50px 20px;}
.empty-icon{width:52px;height:52px;background:#e8edf5;border-radius:50%;margin:0 auto 14px;display:flex;align-items:center;justify-content:center;}
.empty-icon svg{width:24px;height:24px;stroke:var(--ts);}
.empty-title{font-size:14px;font-weight:500;color:var(--tp);margin-bottom:6px;}
.empty-desc{font-size:12px;color:var(--tm);line-height:1.7;}

/* 토스트 */
#toast{
  position:fixed;bottom:84px;left:50%;transform:translateX(-50%) translateY(20px);
  background:var(--deep);color:#fff;padding:10px 20px;border-radius:24px;
  font-size:13px;opacity:0;transition:all 0.3s;pointer-events:none;z-index:300;white-space:nowrap;
}
</style>
</head>
<body>
<div class="screen">

  <!-- ── 헤더 ── -->
  <div class="top-header">
    <div class="header-row">
      <div class="header-left">
        <div class="header-title">수사관 커뮤니티</div>
        <div class="header-sub">팁 · 장비 · 자유게시판</div>
      </div>
      <button class="write-btn" onclick="openWrite()">
        <svg viewBox="0 0 24 24" fill="none" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        글쓰기
      </button>
    </div>
    <div class="header-gold-line"></div>
    <!-- 카테고리 탭 -->
    <div class="cat-tabs">
      <button class="cat-tab active" onclick="switchCat('all',this)">
        <span class="tab-dot" style="background:var(--gold)"></span> 전체
      </button>
      <button class="cat-tab" onclick="switchCat('tip',this)">
        <span class="tab-dot tip-dot"></span> 수사 노하우
      </button>
      <button class="cat-tab" onclick="switchCat('gear',this)">
        <span class="tab-dot gear-dot"></span> 수사 장비
      </button>
      <button class="cat-tab" onclick="switchCat('free',this)">
        <span class="tab-dot free-dot"></span> 자유게시판
      </button>
      <button class="cat-tab" onclick="switchCat('mine',this)">
        <span class="tab-dot" style="background:#f0c040"></span> 내 글
      </button>
    </div>
  </div>

  <!-- ── 콘텐츠 ── -->
  <div class="content">
    <!-- 검색 + 정렬 -->
    <div class="filter-bar">
      <div class="search-wrap">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input class="search-input" id="searchInput" placeholder="게시글 검색..." oninput="renderList()">
      </div>
      <button class="sort-btn" onclick="toggleSort()">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="15" y2="12"/><line x1="3" y1="18" x2="10" y2="18"/></svg>
        <span id="sortLabel">최신순</span>
      </button>
    </div>

    <!-- 공지 -->
    <div class="notice-card">
      <span class="notice-badge">공지</span>
      <div class="notice-text">개인 식별 정보(피의자·피해자 성명 등)는 게시 금지입니다. 위반 시 게시물이 삭제될 수 있습니다.</div>
    </div>

    <!-- 게시글 목록 -->
    <div class="post-list" id="postList"></div>
  </div>

  <!-- 플로팅 버튼 -->
  <button class="fab" onclick="openWrite()" title="글쓰기">
    <svg viewBox="0 0 24 24" fill="none" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
  </button>

  <!-- ── 하단 네비 ── -->
  <nav class="bottom-nav">
    <a href="main.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
      <span class="nav-label">홈</span>
    </a>
    <a href="myCase.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
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
    <a href="board.jsp" class="nav-item active">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
      <span class="nav-label">커뮤니티</span>
    </a>
    <a href="mypage.jsp" class="nav-item">
      <div class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
      <span class="nav-label">마이페이지</span>
    </a>
  </nav>
</div>

<!-- ══════════════════════════════════════════════ -->
<!-- 게시글 상세 모달 -->
<!-- ══════════════════════════════════════════════ -->
<div class="modal-overlay" id="detailModal">
  <div class="modal-sheet">
    <div class="modal-header">
      <div class="modal-back">
        <button class="modal-back-btn" onclick="closeDetail()">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <span class="modal-back-title" id="detailCatLabel">수사 노하우</span>
      </div>
    </div>
    <div class="modal-body" id="detailBody"></div>
    <div class="comment-input-wrap">
      <textarea class="comment-textarea" id="commentInput" placeholder="댓글을 입력하세요..." rows="1"
        oninput="this.style.height='auto';this.style.height=Math.min(this.scrollHeight,80)+'px'"></textarea>
      <button class="comment-submit" onclick="submitComment()">
        <svg viewBox="0 0 24 24" fill="none" stroke-linecap="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
      </button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════ -->
<!-- 글쓰기 모달 -->
<!-- ══════════════════════════════════════════════ -->
<div class="write-modal-overlay" id="writeModal">
  <div class="write-modal">
    <div class="write-modal-header">
      <div class="write-modal-title">
        <button class="write-close-btn" onclick="closeWrite()">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
        <span style="font-size:16px;font-weight:600;color:#fff;">새 게시글</span>
        <button class="write-submit-btn" onclick="submitPost()">등록</button>
      </div>
    </div>
    <div class="write-body">
      <div class="write-field">
        <label class="write-label">카테고리</label>
        <div class="cat-selector">
          <button class="cat-sel-btn" onclick="selectCat('tip',this)" id="selTip">
            <span class="sel-icon">👮</span>수사 노하우
          </button>
          <button class="cat-sel-btn" onclick="selectCat('gear',this)" id="selGear">
            <span class="sel-icon">🧰</span>수사 장비
          </button>
          <button class="cat-sel-btn" onclick="selectCat('free',this)" id="selFree">
            <span class="sel-icon">💬</span>자유게시판
          </button>
        </div>
      </div>
      <div class="write-field">
        <label class="write-label">제목</label>
        <input class="write-input" id="wTitle" placeholder="제목을 입력하세요" maxlength="60">
      </div>
      <div class="write-field">
        <label class="write-label">내용</label>
        <textarea class="write-textarea" id="wContent" placeholder="현장에서 유용했던 팁이나 장비를 공유해보세요.&#10;&#10;개인정보(피의자·피해자 성명 등)는 반드시 제외해 주세요."></textarea>
      </div>
      <div class="write-field">
        <label class="write-label">첨부 태그 (선택)</label>
        <input class="write-input" id="wTags" placeholder="예) 엑셀서식, 바디캠, 조서템플릿 (쉼표 구분)">
      </div>
      <!-- 수사 장비 전용: 구매 링크 -->
      <div class="write-field" id="gearLinkSection">
        <label class="write-label" style="color:var(--gear-text);">
          🛒 구매 링크 (선택 · 최대 3개)
        </label>
        <div class="link-input-group" id="linkInputGroup">
          <div class="link-input-row" data-idx="0">
            <input class="write-input" placeholder="링크 이름 (예: 쿠팡, 네이버쇼핑)" style="flex:0.9" data-role="name">
            <input class="write-input" placeholder="https://..." data-role="url">
          </div>
        </div>
        <button class="link-add-btn" id="linkAddBtn" onclick="addLinkRow()" style="margin-top:8px;">
          <svg viewBox="0 0 24 24" fill="none" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          링크 추가
        </button>
      </div>
    </div>
  </div>
</div>

<div id="toast"></div>

<script>
/* ═══════════════════════════════════════════════════════
   샘플 데이터
═══════════════════════════════════════════════════════ */
var ME = { name:'김민준', rank:'경위', color:'#1a2744' };

var posts = [
  {
    id:1, cat:'tip', hot:true,
    title:'진술 모순 탐지할 때 쓰는 타임라인 엑셀 서식 공유합니다',
    preview:'피의자 진술과 목격자 진술을 시간축으로 나란히 정리하면 모순점이 바로 보여요. 셀 조건부 서식으로 불일치 구간을 빨간색으로 자동 표시되게 해뒀습니다.',
    content:`현장에서 3년 쓰면서 다듬은 진술 타임라인 비교 서식입니다.

【사용법】
1. A열에 피의자 진술 시각 입력
2. B열에 목격자 진술 시각 입력
3. C열이 자동으로 불일치 여부 표시 (빨강=불일치)
4. D열 메모란에 추가 확인 사항 기재

【팁】
- 진술이 여러 건일 때는 시트를 복사해서 사용하면 됩니다
- 날짜가 다를 경우 날짜+시각으로 같이 입력해야 정렬이 정확합니다
- 조서 작성 후 첨부 자료로 제출하면 검사실에서 반응 좋습니다 ㅎㅎ

파일은 댓글로 요청해주시면 Google Drive 링크 드릴게요.`,
    tags:['엑셀서식','진술분석','조서작성'],
    author:'박현우', authorRank:'경사', authorColor:'#0F6E56',
    date:'2025.03.28', views:312, likes:47,
    comments:[
      { id:1, author:'이수진', rank:'경위', color:'#185FA5', text:'완전 유용해요! 저도 비슷하게 만들었는데 이게 훨씬 낫네요. 링크 공유 부탁드립니다!', time:'1일 전', liked:false },
      { id:2, author:'최동혁', rank:'경사', color:'#533AB7', text:'조서 작성할 때 항상 이런 서식 필요하다고 생각했는데 감사합니다. 요청드려요~', time:'21시간 전', liked:false },
      { id:3, author:'박현우', authorRank:'경사', color:'#0F6E56', text:'@이수진, @최동혁 drive.google.com/... 링크 달아드렸어요. 잘 쓰세요!', time:'20시간 전', liked:false },
    ]
  },
  {
    id:2, cat:'gear', hot:true,
    title:'바디캠 직구 후기 — Insta360 GO 3S 실사용 6개월',
    preview:'지급품 바디캠이 화질이 너무 아쉬워서 직접 Insta360 GO 3S 구매했습니다. 마그네틱 클립 방식이라 착탈이 편하고 야간 화질이 압도적으로 좋아요.',
    content:`지급 바디캠은 야간에 거의 못 쓸 수준이라 사비로 구매해서 6개월 쓴 후기입니다.

【Insta360 GO 3S 장점】
- 마그네틱 클립: 제복 어디든 1초 착탈
- 야간 화질: 지급품 대비 압도적 (f/2.2 조리개)
- 방수: IPX8 (비·땀 걱정 없음)
- 배터리: 연속 70분 (현장 출동 1회 충분)
- 무게: 35g (거의 안 느껴짐)

【단점】
- 가격: 55만원대 (공식 직구 기준)
- 내장 스피커 없음 (영상 확인은 앱으로)
- 저장장치 최대 256GB (장시간 녹화 시 용량 관리 필요)

【추천 설정】
해상도: 2.7K 30fps / 야간모드: Auto / 안정화: FlowState ON

팀 전체가 다 구매할 정도로 만족도 높습니다. 질문 있으면 댓글 달아주세요.`,
    tags:['바디캠','Insta360','현장장비'],
    links:[
      { name:'쿠팡 공식 직구', url:'https://www.coupang.com' },
      { name:'Insta360 공식몰', url:'https://www.insta360.com' },
    ],
    author:'정태양', authorRank:'경위', authorColor:'#854F0B',
    date:'2025.03.25', views:521, likes:89,
    comments:[
      { id:1, author:'김민준', rank:'경위', color:'#1a2744', text:'저도 관심 있었는데 야간 화질 비교 사진 같은 거 있으면 올려주실 수 있나요?', time:'3일 전', liked:false },
      { id:2, author:'정태양', rank:'경위', color:'#854F0B', text:'@김민준 사진은 보안 때문에 올리기 애매한데, 직접 DM으로 보내드릴게요!', time:'3일 전', liked:false },
    ]
  },
  {
    id:3, cat:'tip',
    title:'참고인 조서 작성 템플릿 — 검사실 반려율 0% 버전',
    preview:'검사실에서 보완 요청 받으면서 계속 다듬은 참고인 조서 템플릿입니다. 필수 기재사항 체크리스트 포함.',
    content:`3년간 수십 번 보완 요청 받으면서 완성한 참고인 조서 템플릿입니다.

【핵심 체크리스트】
□ 진술인 인적사항 (주민등록번호 뒷자리 마스킹)
□ 진술 일시·장소 명기
□ 진술 거부권·위증죄 고지 여부 서명
□ 사건과의 관계 명확히 기재
□ 진술 내용 — 시간순 정리 (추정 표현 최소화)
□ 진술 후 열람·서명 확인

【자주 보완 요청받는 항목】
- "~인 것 같습니다" → "~으로 확인했습니다" 로 수정
- 장소 기재 시 지번 주소까지 확인
- 피해자와의 관계가 애매할 때 관계 증빙 별도 첨부

템플릿 파일 필요하신 분은 댓글로!`,
    tags:['조서템플릿','참고인','검사실'],
    author:'윤지혜', authorRank:'경감', authorColor:'#3B6D11',
    date:'2025.03.22', views:198, likes:31,
    comments:[
      { id:1, author:'장현우', rank:'경장', color:'#185FA5', text:'신임 때 이런 게 있었으면 얼마나 좋았을까요 ㅠ 파일 공유 부탁드립니다!', time:'5일 전', liked:false },
    ]
  },
  {
    id:4, cat:'gear',
    title:'현장 필수 글러브 비교 — 절개방지 vs 일반 수색장갑',
    preview:'압수수색 현장에서 날카로운 물건 때문에 손 다친 동료가 있어서 절개방지 장갑을 조사했습니다. EN388 등급 기준으로 정리.',
    content:`압수수색 현장에서 날카로운 물건에 손 베이는 사고가 꽤 있습니다. 몇 가지 비교해봤어요.

【EN388 절개방지 등급이란?】
- 4단계 (1~4): 숫자 높을수록 절개 저항성 강함
- 현장 권장: 최소 Level 3 이상

【비교한 제품】
1. Mechanix Wear CUT (Level 4) — 5만원대
   장점: 터치스크린 호환, 손가락 감각 유지
   단점: 여름엔 더움

2. Hatch Operator (Level 2) — 3만원대
   장점: 가격 대비 내구성, 그립감
   단점: 절개방지 등급 아쉬움

3. 국내 산업용 방검장갑 — 2만원대
   장점: 가성비 최고
   단점: 스마트폰 미호환, 투박함

【추천】
무난하게 Mechanix CUT Level 4. 특히 마약류 수색 시 주사기 찔림 예방에도 좋습니다.`,
    tags:['장갑','압수수색','안전장비'],
    links:[
      { name:'Mechanix CUT Level 4 — 네이버쇼핑', url:'https://shopping.naver.com' },
      { name:'Hatch Operator — 옥션', url:'https://www.auction.co.kr' },
    ],
    author:'최수진', authorRank:'경사', authorColor:'#A32D2D',
    date:'2025.03.20', views:143, likes:22,
    comments:[]
  },
  {
    id:5, cat:'free',
    title:'신임 경찰관들에게 — 첫 조서 작성 실수담',
    preview:'첫 조서에서 피의자 진술을 그대로 옮겨 쓰다가 검사실에서 전화 왔던 기억이 납니다. 신임분들 파이팅!',
    content:`경력 7년 차입니다. 신임 때 기억이 가끔 생각나서 적어봐요.

첫 피의자 조서를 쓸 때 진술 내용을 거의 그대로 옮겨 썼습니다. 구어체, "~이요", "~잖아요" 그대로요. 검사실에서 전화가 왔습니다.

"이거 조서가 아니라 녹취록이에요?"

그 이후로 배운 것들:
- 조서는 '객관적 사실'을 중심으로, 진술은 요약해서
- 감정 표현(억울하다, 화가 났다)은 직접 인용 형식으로만
- 날짜·시간·장소는 무조건 구체적으로
- 애매한 것은 차라리 "확인 필요"로 남겨두기

7년 지나도 어려운 게 조서입니다. 신임분들 너무 자책하지 마세요. 다들 그렇게 성장합니다 💪`,
    tags:['신임','조서작성','경험담'],
    author:'강민석', authorRank:'경감', authorColor:'#533AB7',
    date:'2025.03.18', views:287, likes:63,
    comments:[
      { id:1, author:'이준호', rank:'순경', color:'#185FA5', text:'신임인데 많은 도움이 됐습니다. 감사합니다 선배님!', time:'1주일 전', liked:false },
      { id:2, author:'김민준', rank:'경위', color:'#1a2744', text:'공감 100%입니다. 저도 비슷한 경험이 있어요 ㅋㅋ', time:'6일 전', liked:false },
    ]
  },
  {
    id:6, cat:'free',
    title:'POL-MATE 앱 쓰면서 좋았던 점 & 아쉬운 점',
    preview:'STT 기능 정말 편하더라고요. 조서 쓸 때 음성 녹음하면서 동시에 텍스트 변환되니까 시간이 많이 절약됩니다.',
    content:`팀 전체에 POL-MATE 도입한 지 2주 됐습니다.

【좋았던 점】
- STT 변환 정확도: 생각보다 훨씬 높음 (방언도 잘 잡음)
- 사건 관계망: 인물 정리할 때 시각적으로 정리되니까 팀원들과 공유하기 좋음
- AI 모순 탐지: 진술 길이가 길 때 특히 유용

【아쉬운 점】
- 오프라인에서 일부 기능 제한 (현장은 LTE도 안 터질 때 있음)
- 사건 관계망에 자동 저장이 됐으면 (수동 저장 깜빡하면 날아감)
- 다크모드 지원 있으면 좋겠음

개발팀 계시면 피드백 전달해주세요 😊`,
    tags:['앱피드백','POL-MATE'],
    author:'홍수정', authorRank:'경사', authorColor:'#0F6E56',
    date:'2025.03.15', views:176, likes:29,
    comments:[
      { id:1, author:'박현우', rank:'경사', color:'#0F6E56', text:'자동 저장 저도 필요하다고 느꼈어요. 공감합니다!', time:'1주일 전', liked:false },
    ]
  },
];

/* ═══════════════════════════════════════════════════════
   상태
═══════════════════════════════════════════════════════ */
var currentCat  = 'all';
var currentSort = 'latest'; // latest | popular | views
var openPostId  = null;
var writeCat    = '';

var CAT_LABEL = { tip:'수사 노하우', gear:'수사 장비', free:'자유게시판', all:'전체', mine:'내 글' };
var CAT_BADGE = { tip:'badge-tip', gear:'badge-gear', free:'badge-free' };
var CAT_SEL   = { tip:'sel-tip',   gear:'sel-gear',   free:'sel-free' };

/* ═══════════════════════════════════════════════════════
   목록 렌더
═══════════════════════════════════════════════════════ */
function switchCat(cat, btn) {
  currentCat = cat;
  document.querySelectorAll('.cat-tab').forEach(function(t){ t.classList.remove('active'); });
  btn.classList.add('active');
  renderList();
}

function toggleSort() {
  var order = ['latest','popular','views'];
  var labels = ['최신순','추천순','조회순'];
  var idx = order.indexOf(currentSort);
  currentSort = order[(idx+1) % 3];
  document.getElementById('sortLabel').textContent = labels[(idx+1)%3];
  renderList();
}

function renderList() {
  var q   = document.getElementById('searchInput').value.trim().toLowerCase();
  var list = posts.filter(function(p) {
    if (currentCat === 'mine') {
      if (p.author !== ME.name) return false;
      if (q && !p.title.toLowerCase().includes(q) && !p.preview.toLowerCase().includes(q)) return false;
      return true;
    }
    if (currentCat !== 'all' && p.cat !== currentCat) return false;
    if (q && !p.title.toLowerCase().includes(q) && !p.preview.toLowerCase().includes(q)) return false;
    return true;
  });

  if (currentSort === 'popular') list.sort(function(a,b){ return b.likes - a.likes; });
  else if (currentSort === 'views') list.sort(function(a,b){ return b.views - a.views; });
  else list.sort(function(a,b){ return b.id - a.id; });

  var el = document.getElementById('postList');
  if (!list.length) {
    var emptyMsg = currentCat === 'mine'
      ? '<div class="empty-title">아직 작성한 글이 없습니다</div><div class="empty-desc">첫 번째 글을 작성해보세요!</div>'
      : '<div class="empty-title">게시글이 없습니다</div><div class="empty-desc">첫 번째 글을 작성해보세요!</div>';
    el.innerHTML = '<div class="empty-state"><div class="empty-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>'+emptyMsg+'</div>';
    return;
  }

  el.innerHTML = list.map(function(p, i) {
    var hotLabel = p.hot ? '<div class="hot-label">🔥 인기글</div>' : '';
    var tagHtml  = p.tags.map(function(t){ return '<span style="font-size:11px;color:var(--ts);background:var(--bg);border:1px solid var(--bd);border-radius:6px;padding:2px 7px;">#'+escHtml(t)+'</span>'; }).join('');
    return '<div class="post-card'+(p.hot?' hot-post':'')+'" onclick="openDetail('+p.id+')" style="animation-delay:'+(i*0.04)+'s">'+
      hotLabel+
      '<div class="post-header">'+
        '<span class="post-cat-badge '+CAT_BADGE[p.cat]+'">'+CAT_LABEL[p.cat]+'</span>'+
        '<div class="post-title">'+escHtml(p.title)+'</div>'+
      '</div>'+
      '<div class="post-preview">'+escHtml(p.preview)+'</div>'+
      (tagHtml ? '<div style="display:flex;flex-wrap:wrap;gap:5px;margin-bottom:10px;">'+tagHtml+'</div>' : '')+
      '<div class="post-footer">'+
        '<div class="post-author">'+
          '<div class="author-avatar" style="background:'+p.authorColor+'">'+p.author.charAt(0)+'</div>'+
          '<span class="author-name">'+escHtml(p.author)+' '+escHtml(p.authorRank)+'</span>'+
          '<span class="author-date">· '+escHtml(p.date)+'</span>'+
        '</div>'+
        '<div class="post-stats">'+
          '<div class="stat-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>'+p.views+'</div>'+
          '<div class="stat-item'+(p.likes>=40?' hot':'')+'"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>'+p.likes+'</div>'+
          '<div class="stat-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>'+p.comments.length+'</div>'+
        '</div>'+
      '</div>'+
    '</div>';
  }).join('');
}

/* ═══════════════════════════════════════════════════════
   상세
═══════════════════════════════════════════════════════ */
function openDetail(id) {
  var p = posts.find(function(x){ return x.id===id; });
  if (!p) return;
  openPostId = id;
  p.views++;
  document.getElementById('detailCatLabel').textContent = CAT_LABEL[p.cat];

  var tagHtml = p.tags.map(function(t){
    return '<div class="attach-tag"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>#'+escHtml(t)+'</div>';
  }).join('');

  // 구매링크 (수사 장비 전용)
  var buyLinksHtml = '';
  if (p.cat === 'gear' && p.links && p.links.length) {
    var linkCards = p.links.map(function(lk) {
      var displayUrl = lk.url.replace(/^https?:\/\//, '').replace(/\/$/, '');
      return '<a class="buy-link-card" href="'+escHtml(lk.url)+'" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">'+
        '<div class="buy-link-icon"><svg viewBox="0 0 24 24" fill="none" stroke-linecap="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg></div>'+
        '<div class="buy-link-info">'+
          '<div class="buy-link-name">'+escHtml(lk.name)+'</div>'+
          '<div class="buy-link-url">'+escHtml(displayUrl)+'</div>'+
        '</div>'+
        '<svg class="buy-link-arrow" viewBox="0 0 24 24" fill="none" stroke-linecap="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>'+
      '</a>';
    }).join('');
    buyLinksHtml = '<div class="buy-links-section">'+
      '<div class="buy-links-title">'+
        '<svg viewBox="0 0 24 24" fill="none" stroke-linecap="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>'+
        '구매 링크'+
      '</div>'+
      linkCards+
    '</div>';
  }

  var commentHtml = p.comments.map(function(c){
    return '<div class="comment-item" id="ci-'+c.id+'">'+
      '<div class="comment-avatar" style="background:'+c.color+'">'+c.author.charAt(0)+'</div>'+
      '<div class="comment-body">'+
        '<div class="comment-author-row">'+
          '<span class="comment-author">'+escHtml(c.author)+'</span>'+
          '<span class="comment-time">'+escHtml(c.rank)+' · '+escHtml(c.time)+'</span>'+
        '</div>'+
        '<div class="comment-text">'+escHtml(c.text)+'</div>'+
        '<div class="comment-actions">'+
          '<button class="comment-action-btn" onclick="likeComment('+id+','+c.id+')">'+
            (c.liked?'❤️':'🤍')+' 좋아요'+
          '</button>'+
        '</div>'+
      '</div>'+
    '</div>';
  }).join('');

  document.getElementById('detailBody').innerHTML =
    '<span class="post-cat-badge '+CAT_BADGE[p.cat]+' detail-cat-badge">'+CAT_LABEL[p.cat]+'</span>'+
    '<div class="detail-title">'+escHtml(p.title)+'</div>'+
    '<div class="detail-meta">'+
      '<div class="detail-author-row">'+
        '<div class="detail-avatar" style="background:'+p.authorColor+'">'+p.author.charAt(0)+'</div>'+
        '<div>'+
          '<div class="detail-author-name">'+escHtml(p.author)+' '+escHtml(p.authorRank)+'</div>'+
          '<div class="detail-author-info">'+escHtml(p.date)+'</div>'+
        '</div>'+
      '</div>'+
      '<div class="detail-stats">'+
        '<div class="detail-stat"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>'+p.views+'</div>'+
        '<div class="detail-stat"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>'+p.comments.length+'</div>'+
      '</div>'+
    '</div>'+
    '<div class="detail-content">'+escHtml(p.content)+'</div>'+
    (tagHtml?'<div class="attach-row">'+tagHtml+'</div>':'')+
    buyLinksHtml+
    '<div class="like-wrap">'+
      '<button class="like-btn'+(p.liked?' liked':'')+'" id="likeBtn" onclick="likePost('+id+')">'+
        '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>'+
        '추천 <span id="likeCount">'+p.likes+'</span>'+
      '</button>'+
    '</div>'+
    '<div class="comment-section">'+
      '<div class="comment-title">댓글 <span class="comment-count-badge" id="cmtCount">'+p.comments.length+'</span></div>'+
      '<div id="cmtList">'+commentHtml+'</div>'+
    '</div>';

  document.getElementById('detailModal').classList.add('open');
  document.getElementById('detailModal').scrollTop = 0;
  renderList();
}

function closeDetail() {
  document.getElementById('detailModal').classList.remove('open');
  openPostId = null;
}

function likePost(id) {
  var p = posts.find(function(x){ return x.id===id; });
  if (!p) return;
  p.liked = !p.liked;
  p.likes += p.liked ? 1 : -1;
  var btn = document.getElementById('likeBtn');
  if (btn) {
    btn.className = 'like-btn'+(p.liked?' liked':'');
    document.getElementById('likeCount').textContent = p.likes;
  }
  renderList();
}

function likeComment(postId, cmtId) {
  var p = posts.find(function(x){ return x.id===postId; });
  if (!p) return;
  var c = p.comments.find(function(x){ return x.id===cmtId; });
  if (!c) return;
  c.liked = !c.liked;
  openDetail(postId);
}

/* ═══════════════════════════════════════════════════════
   댓글 제출
═══════════════════════════════════════════════════════ */
function submitComment() {
  var text = document.getElementById('commentInput').value.trim();
  if (!text) { showToast('댓글을 입력하세요.'); return; }
  if (!openPostId) return;
  var p = posts.find(function(x){ return x.id===openPostId; });
  if (!p) return;
  var newId = (p.comments.length ? p.comments[p.comments.length-1].id : 0) + 1;
  p.comments.push({
    id: newId, author: ME.name, rank: ME.rank, color: ME.color,
    text: text, time: '방금 전', liked: false
  });
  document.getElementById('commentInput').value = '';
  document.getElementById('commentInput').style.height = 'auto';
  openDetail(openPostId);
  showToast('✓ 댓글이 등록됐습니다');
}

/* ═══════════════════════════════════════════════════════
   글쓰기
═══════════════════════════════════════════════════════ */
function openWrite() {
  writeCat = '';
  document.getElementById('wTitle').value = '';
  document.getElementById('wContent').value = '';
  document.getElementById('wTags').value = '';
  // 링크 입력 초기화
  var grp = document.getElementById('linkInputGroup');
  grp.innerHTML = '<div class="link-input-row" data-idx="0"><input class="write-input" placeholder="링크 이름 (예: 쿠팡, 네이버쇼핑)" style="flex:0.9" data-role="name"><input class="write-input" placeholder="https://..." data-role="url"></div>';
  document.getElementById('gearLinkSection').style.display = 'none';
  ['tip','gear','free'].forEach(function(c){
    document.getElementById('sel'+c.charAt(0).toUpperCase()+c.slice(1)).className = 'cat-sel-btn';
  });
  document.getElementById('writeModal').classList.add('open');
  document.getElementById('writeModal').scrollTop = 0;
}

function closeWrite() { document.getElementById('writeModal').classList.remove('open'); }

function selectCat(cat, btn) {
  writeCat = cat;
  ['selTip','selGear','selFree'].forEach(function(id){ document.getElementById(id).className='cat-sel-btn'; });
  btn.className = 'cat-sel-btn '+CAT_SEL[cat];
  // 수사 장비일 때만 구매링크 섹션 표시
  document.getElementById('gearLinkSection').style.display = cat === 'gear' ? 'block' : 'none';
}

function submitPost() {
  var title   = document.getElementById('wTitle').value.trim();
  var content = document.getElementById('wContent').value.trim();
  var tagsRaw = document.getElementById('wTags').value.trim();
  if (!writeCat)  { showToast('카테고리를 선택하세요.'); return; }
  if (!title)     { showToast('제목을 입력하세요.'); return; }
  if (!content)   { showToast('내용을 입력하세요.'); return; }
  var tags = tagsRaw ? tagsRaw.split(',').map(function(t){ return t.trim(); }).filter(Boolean) : [];

  // 구매링크 수집 (수사 장비만)
  var links = [];
  if (writeCat === 'gear') {
    document.querySelectorAll('#linkInputGroup .link-input-row').forEach(function(row) {
      var name = row.querySelector('[data-role="name"]').value.trim();
      var url  = row.querySelector('[data-role="url"]').value.trim();
      if (name && url) links.push({ name: name, url: url });
    });
  }

  var newId = posts.length ? Math.max.apply(null, posts.map(function(p){ return p.id; })) + 1 : 1;
  posts.unshift({
    id: newId, cat: writeCat, hot: false,
    title: title, preview: content.substring(0,80)+(content.length>80?'...':''),
    content: content, tags: tags, links: links,
    author: ME.name, authorRank: ME.rank, authorColor: ME.color,
    date: new Date().toLocaleDateString('ko-KR',{year:'numeric',month:'2-digit',day:'2-digit'}).replace(/\. /g,'.').replace('.',''),
    views: 0, likes: 0, liked: false, comments: []
  });
  closeWrite();
  currentCat = writeCat;
  document.querySelectorAll('.cat-tab').forEach(function(t,i){ t.classList.toggle('active', i===['all','tip','gear','free'].indexOf(writeCat)); });
  renderList();
  showToast('✓ 게시글이 등록됐습니다');
}

/* ═══════════════════════════════════════════════════════
   구매링크 행 추가/삭제
═══════════════════════════════════════════════════════ */
function addLinkRow() {
  var grp = document.getElementById('linkInputGroup');
  var rows = grp.querySelectorAll('.link-input-row');
  if (rows.length >= 3) { showToast('링크는 최대 3개까지 추가할 수 있습니다.'); return; }
  var idx = rows.length;
  var div = document.createElement('div');
  div.className = 'link-input-row';
  div.setAttribute('data-idx', idx);
  div.innerHTML =
    '<input class="write-input" placeholder="링크 이름 (예: 쿠팡, 네이버쇼핑)" style="flex:0.9" data-role="name">'+
    '<input class="write-input" placeholder="https://..." data-role="url">'+
    '<button class="link-del-btn" onclick="removeLinkRow(this)" type="button">'+
      '<svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'+
    '</button>';
  grp.appendChild(div);
  if (grp.querySelectorAll('.link-input-row').length >= 3) {
    document.getElementById('linkAddBtn').style.display = 'none';
  }
}

function removeLinkRow(btn) {
  btn.closest('.link-input-row').remove();
  document.getElementById('linkAddBtn').style.display = 'flex';
}

/* ═══════════════════════════════════════════════════════
   유틸
═══════════════════════════════════════════════════════ */
function escHtml(s) {
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.style.opacity = '1';
  t.style.transform = 'translateX(-50%) translateY(0)';
  setTimeout(function(){
    t.style.opacity = '0';
    t.style.transform = 'translateX(-50%) translateY(20px)';
  }, 2200);
}

// 상세 모달 뒤로가기
document.getElementById('detailModal').addEventListener('click', function(e){
  if (e.target === this) closeDetail();
});

renderList();
</script>
</body>
</html>
