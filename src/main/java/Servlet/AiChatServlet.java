package Servlet;

import java.io.*;
import java.net.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * AiChatServlet
 * - 기존 LLMTestServlet(test.jsp) 대체
 * - URL: /askAI (기존 매핑 유지 — aiChat.jsp form action과 일치)
 * - Ollama gemma3:1b 로컬 LLM 호출
 * - 수사 전문 시스템 프롬프트 내장
 */
@WebServlet("/askAI")
public class AiChatServlet extends HttpServlet {

    // ── 수사 보조 시스템 프롬프트 ─────────────────────────────────
    private static final String SYSTEM_PROMPT =
        "당신은 대한민국 경찰청 형사사법정보 AI 보조 시스템(POL-MATE)입니다.\n" +
        "현직 수사관의 질문에 다음 원칙으로 답변하세요:\n" +
        "1. 형사소송법, 경찰관직무집행법, 헌법 등 관련 법령을 인용하여 답변\n" +
        "2. 수사 실무에 즉시 적용 가능한 구체적인 내용 제공\n" +
        "3. 피의자 인권 보호 및 적법 절차 준수 강조\n" +
        "4. 반드시 한국어로 답변\n" +
        "5. 답변은 명확하고 간결하게 (200자 내외 권장)\n\n";
    // ─────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String userMsg  = request.getParameter("userMsg");
        String category = request.getParameter("category"); // 질문 카테고리 (선택)

        if (userMsg == null || userMsg.trim().isEmpty()) {
            request.setAttribute("result",    "질문을 입력해 주세요.");
            request.setAttribute("userMsg",   "");
            request.setAttribute("category",  "");
            request.getRequestDispatcher("aiChat.jsp").forward(request, response);
            return;
        }

        //dddd
        
        // 카테고리 프리픽스 추가
        String prompt = SYSTEM_PROMPT;
        if (category != null && !category.trim().isEmpty()) {
            prompt += "[질문 분류: " + category + "]\n\n";
        }
        prompt += "수사관 질문: " + userMsg.trim();

        String aiResponse = "";
        boolean ollamaOk  = false;

        try {
            URL url = new URL("http://localhost:11434/api/generate");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setConnectTimeout(5000);   // 5초 연결 타임아웃
            conn.setReadTimeout(60000);     // 60초 읽기 타임아웃
            conn.setDoOutput(true);

            JsonObject jsonInput = new JsonObject();
            jsonInput.addProperty("model",  "gemma3:1b");
            jsonInput.addProperty("prompt", prompt);
            jsonInput.addProperty("stream", false);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonInput.toString().getBytes("utf-8"));
            }

            if (conn.getResponseCode() == 200) {
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "utf-8"));
                String line = br.readLine();
                JsonObject jsonRes = JsonParser.parseString(line).getAsJsonObject();
                aiResponse = jsonRes.get("response").getAsString();
                ollamaOk   = true;
            } else {
                aiResponse = "[오류] Ollama 서버 응답 코드: " + conn.getResponseCode();
            }

        } catch (java.net.ConnectException ce) {
            aiResponse = "[OFFLINE] Ollama 서버에 연결할 수 없습니다.\n" +
                         "로컬에서 'ollama run gemma3:1b' 명령어로 서버를 시작해 주세요.";
        } catch (Exception e) {
            aiResponse = "[오류] " + e.getMessage();
        }

        request.setAttribute("result",    aiResponse);
        request.setAttribute("userMsg",   userMsg.trim());
        request.setAttribute("category",  category != null ? category : "");
        request.setAttribute("ollamaOk",  ollamaOk);
        request.getRequestDispatcher("aiChat.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("aiChat.jsp").forward(request, response);
    }
}
