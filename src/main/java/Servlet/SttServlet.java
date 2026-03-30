package Servlet;

import java.io.*;
import java.net.*;
import java.util.Properties;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * SttServlet — CLOVA Speech Recognition API 연동 (신형: Invoke URL + Secret Key 방식)
 *
 * URL: /stt
 * Method: POST (multipart/form-data)
 * 파라미터:
 *   - audioFile : 업로드된 음성 파일 (mp3, wav, m4a, ogg, flac)
 *   - language  : 언어 코드 (기본값: Kor)
 *
 * CLOVA Speech API 스펙:
 *   POST https://clovaspeech-gw.ncloud.com/recog/v1/stt?lang=Kor
 *   Headers:
 *     Content-Type: application/octet-stream
 *     X-CLOVASPEECH-API-KEY: {secretKey}
 *   Body: 음성 파일 바이너리
 *
 * 응답 JSON: {"text": "인식된 텍스트"}
 */
@WebServlet("/stt")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1MB 이상이면 임시 파일로 저장
    maxFileSize       = 100 * 1024 * 1024, // 파일 최대 100MB
    maxRequestSize    = 105 * 1024 * 1024  // 요청 최대 105MB
)
public class SttServlet extends HttpServlet {

    private String invokeUrl;
    private String secretKey;

    @Override
    public void init() throws ServletException {
        // config.properties에서 API 키 로드
        try {
            Properties props = new Properties();
            InputStream is = getServletContext()
                .getResourceAsStream("/WEB-INF/config.properties");
            if (is != null) {
                props.load(is);
                invokeUrl = props.getProperty("CLOVA_INVOKE_URL", "").trim();
                secretKey = props.getProperty("CLOVA_SECRET_KEY", "").trim();
            }
        } catch (IOException e) {
            log("[SttServlet] config.properties 로드 실패: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        // ── API 키 미설정 체크 ──────────────────────────────────────
        if (secretKey == null || secretKey.isEmpty()
         || secretKey.equals("YOUR_CLOVA_SECRET_KEY")) {
            out.print(errorJson("CLOVA Secret Key가 설정되지 않았습니다. WEB-INF/config.properties를 확인해 주세요."));
            return;
        }
        if (invokeUrl == null || invokeUrl.isEmpty()
         || invokeUrl.equals("YOUR_CLOVA_INVOKE_URL")) {
            out.print(errorJson("CLOVA Invoke URL이 설정되지 않았습니다. WEB-INF/config.properties를 확인해 주세요."));
            return;
        }

        // ── 파일 파트 추출 ──────────────────────────────────────────
        Part filePart;
        try {
            filePart = request.getPart("audioFile");
        } catch (Exception e) {
            out.print(errorJson("파일 업로드 오류: " + e.getMessage()));
            return;
        }

        if (filePart == null || filePart.getSize() == 0) {
            out.print(errorJson("음성 파일이 없습니다."));
            return;
        }

        // ── 언어 코드 (기본: 한국어) ────────────────────────────────
        String language = request.getParameter("language");
        if (language == null || language.isEmpty()) language = "Kor";

        // ── CLOVA Speech API 호출 ───────────────────────────────────
        try {
            String apiUrl = invokeUrl + "?lang=" + language;
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setDoInput(true);
            conn.setUseCaches(false);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(60000);
            conn.setRequestProperty("Content-Type",          "application/octet-stream");
            conn.setRequestProperty("X-CLOVASPEECH-API-KEY", secretKey);

            // 음성 파일 바이너리 전송
            try (OutputStream os = conn.getOutputStream();
                 InputStream  is = filePart.getInputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = is.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
            }

            int statusCode = conn.getResponseCode();

            if (statusCode == 200) {
                // ── 성공 응답 파싱 ──────────────────────────────────
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) sb.append(line);

                // {"text": "인식된 텍스트"}
                JsonObject jsonRes = JsonParser.parseString(sb.toString()).getAsJsonObject();
                String recognizedText = jsonRes.has("text")
                    ? jsonRes.get("text").getAsString() : "";

                // Gson으로 안전하게 응답 JSON 구성 (특수문자 자동 이스케이프)
                JsonObject result = new JsonObject();
                result.addProperty("success",  true);
                result.addProperty("text",      recognizedText);
                result.addProperty("language",  language);
                result.addProperty("fileSize",  filePart.getSize());
                result.addProperty("fileName",  getFileName(filePart));
                out.print(result.toString());

            } else {
                // ── 오류 응답 읽기 ──────────────────────────────────
                String errBody = "";
                InputStream errStream = conn.getErrorStream();
                if (errStream != null) {
                    BufferedReader br = new BufferedReader(
                        new InputStreamReader(errStream, "UTF-8"));
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) sb.append(line);
                    errBody = sb.toString();
                }
                // Gson으로 안전하게 오류 JSON 구성 (한국어/특수문자 깨짐 방지)
                out.print(errorJson("CLOVA API 오류 (" + statusCode + "): " + errBody));
            }

        } catch (java.net.ConnectException ce) {
            out.print(errorJson("CLOVA API 서버에 연결할 수 없습니다. Invoke URL을 확인해 주세요."));
        } catch (Exception e) {
            out.print(errorJson("STT 처리 중 오류: " + e.getMessage()));
        }
    }

    /**
     * Gson을 사용해 에러 JSON을 안전하게 생성
     * 한국어, 따옴표, 특수문자 등이 포함되어도 JSON이 깨지지 않음
     */
    private String errorJson(String message) {
        JsonObject obj = new JsonObject();
        obj.addProperty("success", false);
        obj.addProperty("error",   message);
        return obj.toString();
    }

    // 업로드된 파일명 추출 헬퍼
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) return "unknown";
        for (String token : contentDisposition.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1)
                    .trim().replace("\"", "");
            }
        }
        return "unknown";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        boolean configured = secretKey != null
            && !secretKey.isEmpty()
            && !secretKey.equals("YOUR_CLOVA_SECRET_KEY");
        JsonObject obj = new JsonObject();
        obj.addProperty("configured", configured);
        response.getWriter().print(obj.toString());
    }
}