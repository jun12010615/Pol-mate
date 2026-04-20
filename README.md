# POL-MATE 수사 보조 시스템

대한민국 경찰청 형사 수사관을 위한 AI 기반 수사 보조 플랫폼입니다.
진술 모순 탐지, 사건 관계망 시각화, CCTV 번호판 분석, AI 수사 챗봇 기능을 제공합니다.

---

## 목차

1. [시스템 구성](#1-시스템-구성)
2. [필수 설치 프로그램](#2-필수-설치-프로그램)
3. [필수 다운로드 파일 및 모델](#3-필수-다운로드-파일-및-모델)
4. [프로젝트 폴더 구조](#4-프로젝트-폴더-구조)
5. [데이터베이스 설정](#5-데이터베이스-설정)
6. [config.properties 설정](#6-configproperties-설정)
7. [Flask 파이썬 서버 실행](#7-flask-파이썬-서버-실행)
8. [Tomcat Java 서버 실행](#8-tomcat-java-서버-실행)
9. [Ollama LLM 실행](#9-ollama-llm-실행)
10. [접속 및 시작](#10-접속-및-시작)
11. [주요 기능 설명](#11-주요-기능-설명)
12. [문제 해결](#12-문제-해결)

---

## 1. 시스템 구성

POL-MATE는 세 개의 서버가 함께 동작합니다.

```
[사용자 브라우저 / 모바일]
        ↕
[Java Tomcat 서버]  ← JSP 페이지 렌더링, DB 처리
        ↕
[Python Flask 서버 :5001]  ← AI 분석, CCTV 번호판 탐지
        ↕
[Ollama LLM 서버 :11434]  ← 진술 분석 / AI 챗봇 LLM
```

| 서버 | 포트 | 역할 |
|------|------|------|
| Tomcat (Java) | 8080 | JSP 페이지, DB 연동, 세션 관리 |
| Flask (Python) | 5001 | 진술 분석, 관계망 추출, CCTV 번호판 분석 |
| Ollama | 11434 | LLM 추론 (exaone3.5:2.4b, gemma3:1b) |

---

## 2. 필수 설치 프로그램

### Java / Tomcat
- **JDK 17** 이상 — https://adoptium.net
- **Apache Tomcat 10.x** — https://tomcat.apache.org
- **Eclipse IDE for Enterprise Java** (배포용) — https://www.eclipse.org/downloads

### Python
- **Python 3.10 ~ 3.12** — https://www.python.org/downloads
  - 설치 시 **"Add Python to PATH"** 반드시 체크

### MySQL
- **MySQL 8.0** 이상 — https://dev.mysql.com/downloads/installer
- 또는 **MySQL Workbench** (GUI 관리 도구)

### Ollama
- **Ollama** — https://ollama.com/download
  - Windows / macOS / Linux 지원

---

## 3. 필수 다운로드 파일 및 모델

### Ollama LLM 모델 (Ollama 설치 후 CMD에서 실행)

```cmd
ollama pull exaone3.5:2.4b
ollama pull gemma3:1b
```

| 모델 | 용도 | 크기 |
|------|------|------|
| exaone3.5:2.4b | 진술 모순 분석, 관계망 추출 | 약 2GB |
| gemma3:1b | AI 수사 챗봇 | 약 1GB |

### YOLO 번호판 탐지 모델
- 파일명: `license_plate_detector.pt`
- 위치: `C:\JSP\Pol-mate\` (polmate_serv.py 와 같은 폴더)
- 팀 내 공유 파일 사용

### 한국 번호판 OCR 모델 (deep-text-recognition-benchmark 기반)
아래 파일들을 `C:\JSP\Pol-mate\ocr_engine\` 폴더에 배치합니다.

```
ocr_engine/
├── model.py
├── utils.py
├── modules/
└── saved_models/
    └── korean_plate/
        └── best_accuracy.pth   ← 약 194MB, 팀 내 공유 파일
```

### Python 패키지 설치

```cmd
python -m pip install flask flask-cors requests
python -m pip install opencv-python numpy
python -m pip install torch torchvision
python -m pip install ultralytics easyocr
```

---

## 4. 프로젝트 폴더 구조

```
C:\JSP\Pol-mate\
├── src\                        ← Java 소스 (Eclipse 프로젝트)
│   └── Servlet\
│       ├── AiChatServlet.java
│       ├── BoardServlet.java
│       ├── CaseServlet.java
│       ├── ContradictionServlet.java
│       ├── LoginServlet.java
│       ├── MypageServlet.java
│       ├── NotificationServlet.java
│       ├── RegisterServlet.java
│       ├── RelationBoardServlet.java
│       ├── SaveBoardServlet.java
│       └── SttServlet.java
├── build\                      ← 컴파일된 클래스 (자동 생성)
├── ocr_engine\                 ← OCR 모델 폴더
│   ├── model.py
│   ├── utils.py
│   ├── modules\
│   └── saved_models\
│       └── korean_plate\
│           └── best_accuracy.pth
├── license_plate_detector.pt   ← YOLO 번호판 탐지 모델
└── polmate_serv.py             ← Flask 통합 서버
```

Tomcat 배포 후 JSP 파일 위치:
```
[Tomcat 설치 경로]\webapps\[프로젝트명]\
├── WEB-INF\
│   ├── config.properties       ← API 키 및 서버 URL 설정
│   └── web.xml
├── login.jsp
├── main.jsp
├── myCase.jsp
├── cctvAnalysis.jsp
└── ... (기타 JSP 파일들)
```

---

## 5. 데이터베이스 설정

### DB 생성 및 테이블 초기화

MySQL Workbench 또는 CLI에서 아래 파일을 실행합니다.

```sql
SOURCE C:\JSP\Pol-mate\polmate.sql;
```

또는 MySQL Workbench에서:
1. Server → Data Import → Import from Self-Contained File
2. `polmate.sql` 선택 후 Start Import

### DBConnectionMgr 설정 확인

`src/Servlet/DBConnectionMgr.java` 에서 DB 접속 정보를 확인하고 필요 시 수정합니다.

```java
private String url      = "jdbc:mysql://localhost:3306/polmate?...";
private String user     = "root";
private String password = "본인 DB 비밀번호";
```

---

## 6. config.properties 설정

`[Tomcat]\webapps\[프로젝트명]\WEB-INF\config.properties` 파일을 수정합니다.

```properties
# Flask 파이썬 서버 URL (IP가 바뀌면 이 줄만 수정)
POL_MATE_SERV_BASE_URL=http://서버IP주소:5001

# CLOVA Speech-to-Text API (음성 조서 기능)
CLOVA_INVOKE_URL=https://clovaspeech-gw.ncloud.com/recog/v1/stt
CLOVA_SECRET_KEY=발급받은_시크릿_키

# 국가법령정보 API (AI 챗봇 법령 검색)
LAW_API_OC=발급받은_OC_ID

# 이메일 (비밀번호 찾기 기능)
MAIL_SMTP_HOST=smtp.gmail.com
MAIL_SMTP_PORT=587
MAIL_SMTP_USER=발신용_이메일@gmail.com
MAIL_SMTP_PASS=앱_비밀번호
MAIL_FROM_NAME=POLMATE
```

> 같은 PC에서 모든 서버를 실행하는 경우 `POL_MATE_SERV_BASE_URL=http://127.0.0.1:5001` 로 설정하면 안 됩니다.
> 브라우저가 직접 Flask 서버에 접근하므로 **반드시 실제 IP 주소**를 입력해야 합니다.

---

## 7. Flask 파이썬 서버 실행

`polmate_serv.py` 가 있는 폴더에서 CMD를 실행합니다.

```cmd
cd C:\JSP\Pol-mate
python polmate_serv.py
```

정상 실행 시 출력:
```
번호판 YOLO 모델 로드 중...
학습된 번호판 OCR 모델 로드 중...
학습된 OCR 모델 로드 완료!
모든 모델 로드 완료!
 * Running on http://0.0.0.0:5001
```

서버 상태 확인 (브라우저 또는 CMD):
```cmd
curl http://localhost:5001/health
```

### 제공 엔드포인트

| 엔드포인트 | 메서드 | 설명 |
|-----------|--------|------|
| /analyze | POST | 진술 모순 분석 (동기) |
| /analyze/start | POST | 진술 분석 작업 시작 (비동기) |
| /analyze/job/{id} | GET | 분석 작업 상태 조회 |
| /analyze/stream | POST | 진술 분석 SSE 스트리밍 |
| /summarize | POST | 진술 구조 요약 |
| /relation_map | POST | 사건 관계망 JSON 추출 |
| /cctv/analyze | POST | 영상 번호판 분석 시작 |
| /cctv/status/{id} | GET | 번호판 분석 상태 조회 |
| /health | GET | 서버 상태 확인 |

---

## 8. Tomcat Java 서버 실행

### Eclipse에서 실행

1. Eclipse → Project Explorer에서 프로젝트 우클릭
2. Run As → Run on Server
3. Tomcat 10.x 선택 후 Finish

### 독립 실행 (Tomcat 직접 실행)

```cmd
cd [Tomcat 설치 경로]\bin
startup.bat
```

---

## 9. Ollama LLM 실행

Ollama를 설치하면 백그라운드에서 자동 실행됩니다.
수동으로 모델을 활성화하려면:

```cmd
ollama run exaone3.5:2.4b
```

AI 챗봇용 모델:
```cmd
ollama run gemma3:1b
```

Ollama 서버 상태 확인:
```
http://localhost:11434
```

---

## 10. 접속 및 시작

세 서버(Tomcat, Flask, Ollama)가 모두 실행 중인 상태에서 브라우저로 접속합니다.

```
http://서버IP:8080/[프로젝트명]/login.jsp
```

### 최초 로그인

1. 회원가입 시 **공무원증 번호(4자리)** 가 필요합니다.
   - DB의 `officer_badges` 테이블에 등록된 번호만 가입 가능합니다.
   - 기본 등록된 번호: `0000`, `1111`, `2222`, `3333` ... `9999`
2. 회원가입 완료 후 로그인하면 `main.jsp` 메인 화면으로 이동합니다.

### 서버 실행 순서 권장

```
1. MySQL 실행 확인
2. Ollama 실행  →  ollama run exaone3.5:2.4b
3. Flask 서버   →  python polmate_serv.py
4. Tomcat 실행  →  Eclipse Run on Server 또는 startup.bat
5. 브라우저에서 login.jsp 접속
```

---

## 11. 주요 기능 설명

### 사건 관리 (myCase.jsp)
- 사건 등록/조회/삭제
- 조서(진술서) 등록 — 텍스트 직접 입력 또는 음성 녹음(STT)
- 진술 AI 분석 — Ollama LLM이 시간순 정리 및 모순 탐지
- 모순 탐지 결과 저장

### 관계망 시각화 (caseRelationMap.jsp)
- 조서에서 인물/관계 자동 추출
- D3.js 기반 인터랙티브 관계망 캔버스
- 피의자·피해자·목격자·참고인 역할 구분 시각화

### CCTV 영상 분석 (cctvAnalysis.jsp)
- MP4/MOV/AVI/MKV 영상 업로드 (최대 500MB)
- YOLO + 한국어 번호판 OCR 모델로 번호판 자동 탐지
- 번호판 일부 입력 후 검색 가능
- 탐지 시점(타임스탬프) 표시

### AI 수사 챗봇 (aiChat.jsp)
- 형사소송법, 경찰관직무집행법 등 법령 기반 답변
- 국가법령정보 API 연동 실시간 법령/판례 검색
- gemma3:1b 모델 사용

### 음성 조서 작성 (voiceTranscript.jsp / writeTranscript.jsp)
- CLOVA Speech API 연동 음성→텍스트 변환
- 변환된 텍스트 즉시 AI 분석 가능

---

## 12. 문제 해결

### Flask 서버 관련

| 증상 | 원인 | 해결 |
|------|------|------|
| `ModuleNotFoundError` | Python 패키지 미설치 | `python -m pip install 패키지명` |
| `license_plate_detector.pt` 파일 없음 | YOLO 모델 파일 누락 | 팀 공유 파일을 `C:\JSP\Pol-mate\` 에 복사 |
| OCR 인식 오류 | 신뢰도 임계값 문제 | `polmate_serv.py` 에서 `OCR_CONFIDENCE_THRESHOLD` 값을 낮춤 (기본 0.85) |
| 학습 OCR 모델 로드 실패 | `best_accuracy.pth` 경로 오류 | `ocr_engine/saved_models/korean_plate/` 경로 확인 |

### Ollama 관련

| 증상 | 원인 | 해결 |
|------|------|------|
| AI 챗봇 응답 없음 | Ollama 미실행 | `ollama run gemma3:1b` 실행 |
| 진술 분석 오류 | exaone 모델 미설치 | `ollama pull exaone3.5:2.4b` |

### CCTV 영상 분석 관련

| 증상 | 원인 | 해결 |
|------|------|------|
| 서버 연결 실패 | `config.properties` IP 오류 | `POL_MATE_SERV_BASE_URL` 값 확인 |
| 번호판 0건 탐지 | 영상 화질 또는 각도 문제 | `skip` 값 조정 — `polmate_serv.py`에서 `fps * 0.3` 으로 변경 |

### config.properties IP 변경 방법

서버 IP가 바뀐 경우 `WEB-INF/config.properties` 한 줄만 수정합니다.

```properties
POL_MATE_SERV_BASE_URL=http://새로운IP주소:5001
```

Tomcat 재시작 후 반영됩니다.

---

## 외부 API 키 발급 안내

| API | 발급처 | 용도 |
|-----|--------|------|
| CLOVA Speech | https://www.ncloud.com | 음성→텍스트 변환 |
| 국가법령정보 | https://www.law.go.kr/LSW/openapiInfo.do | 법령/판례 검색 |
| Gmail 앱 비밀번호 | Google 계정 → 보안 → 앱 비밀번호 | 비밀번호 찾기 이메일 발송 |
