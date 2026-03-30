package Servlet;

import java.io.*;
import java.net.*;
import java.util.Properties;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * LawApiServlet — 국가법령정보 공동활용 API 연동
 *
 * URL: /lawApi
 * Method: GET
 * 파라미터:
 *   - query  : 검색 키워드 (필수)
 *   - target : 검색 대상 (기본값: law)
 *              law  = 현행법령
 *              prec = 판례
 *   - display: 결과 개수 (기본값: 10, 최대 100)
 *   - page   : 페이지 번호 (기본값: 1)
 *
 * 국가법령정보 API 스펙:
 *   GET http://www.law.go.kr/DRF/lawSearch.do
 *     ?OC={OC아이디}
 *     &target=law
 *     &type=JSON
 *     &query={검색어}
 *     &display=10
 *     &page=1
 *
 * 법령 본문 조회:
 *   GET http://www.law.go.kr/DRF/lawService.do
 *     ?OC={OC아이디}
 *     &target=law
 *     &type=JSON
 *     &MST={법령일련번호}
 */
@WebServlet("/lawApi")
public class LawApiServlet extends HttpServlet {

    private static final String LAW_BASE_URL    = "http://www.law.go.kr/DRF/lawSearch.do";
    private static final String LAW_CONTENT_URL = "http://www.law.go.kr/DRF/lawService.do";

    private String ocId; // 국가법령정보 공동활용 아이디

    @Override
    public void init() throws ServletException {
        try {
            Properties props = new Properties();
            InputStream is = getServletContext()
                .getResourceAsStream("/WEB-INF/config.properties");
            if (is != null) {
                props.load(is);
                ocId = props.getProperty("LAW_API_OC", "");
            }
        } catch (IOException e) {
            log("[LawApiServlet] config.properties 로드 실패: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        // API 키 미설정 체크
        if (ocId == null || ocId.isEmpty() || ocId.equals("YOUR_LAW_API_OC_ID")) {
            out.print("{\"success\":false,\"error\":\"법령 API OC 아이디가 설정되지 않았습니다.\","
                    + "\"fallback\":true}");
            return;
        }

        String query   = request.getParameter("query");
        String target  = request.getParameter("target");
        String display = request.getParameter("display");
        String page    = request.getParameter("page");
        String mst     = request.getParameter("mst"); // 법령 본문 조회용 일련번호

        if (query == null || query.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"검색어가 없습니다.\"}");
            return;
        }

        if (target  == null || target.isEmpty())  target  = "law";
        if (display == null || display.isEmpty()) display = "10";
        if (page    == null || page.isEmpty())    page    = "1";

        try {
            // ── 법령 본문 조회 (mst 파라미터 있을 때) ──────────────
            if (mst != null && !mst.isEmpty()) {
                String contentResult = fetchLawContent(mst);
                out.print(contentResult);
                return;
            }

            // ── 법령 목록 검색 ──────────────────────────────────────
            String encodedQuery = URLEncoder.encode(query.trim(), "UTF-8");
            String apiUrl = LAW_BASE_URL
                + "?OC="      + URLEncoder.encode(ocId, "UTF-8")
                + "&target="  + target
                + "&type=JSON"
                + "&query="   + encodedQuery
                + "&display=" + display
                + "&page="    + page;

            String rawJson = fetchUrl(apiUrl);

            // API 응답을 그대로 전달 (JSP에서 파싱)
            // 응답 구조: {"LawSearch": {"totalCnt": "N", "page": "1",
            //             "law": [{"법령명한글": "...", "법령일련번호": "...", ...}]}}
            out.print("{\"success\":true,\"data\":" + rawJson + ","
                    + "\"query\":\"" + escapeJson(query) + "\","
                    + "\"target\":\"" + target + "\"}");

        } catch (java.net.ConnectException ce) {
            out.print("{\"success\":false,"
                    + "\"error\":\"국가법령정보 API 서버에 연결할 수 없습니다.\","
                    + "\"fallback\":true}");
        } catch (Exception e) {
            out.print("{\"success\":false,"
                    + "\"error\":\"법령 검색 오류: " + escapeJson(e.getMessage()) + "\","
                    + "\"fallback\":true}");
        }
    }

    // 법령 본문 조회
    private String fetchLawContent(String mst) throws IOException {
        String apiUrl = LAW_CONTENT_URL
            + "?OC="     + URLEncoder.encode(ocId, "UTF-8")
            + "&target=law"
            + "&type=JSON"
            + "&MST="    + URLEncoder.encode(mst, "UTF-8");

        String rawJson = fetchUrl(apiUrl);
        return "{\"success\":true,\"contentData\":" + rawJson + "}";
    }

    // HTTP GET 요청 공통 헬퍼
    private String fetchUrl(String urlStr) throws IOException {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(10000);
        conn.setRequestProperty("Accept", "application/json");

        int statusCode = conn.getResponseCode();
        InputStream is = (statusCode == 200)
            ? conn.getInputStream() : conn.getErrorStream();

        BufferedReader br = new BufferedReader(
            new InputStreamReader(is, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();

        if (statusCode != 200) {
            throw new IOException("HTTP " + statusCode + ": " + sb.toString());
        }
        return sb.toString();
    }

    // JSON 문자열 이스케이프
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
