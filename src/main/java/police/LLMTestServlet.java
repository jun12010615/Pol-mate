package police; // 본인 패키지명 확인

import java.io.*;
import java.net.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
@WebServlet("/askAI")
public class LLMTestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String userMsg = request.getParameter("userMsg"); // JSP에서 보낸 메시지 받기

        String aiResponse = "";
        try {
            // 1. Ollama 로컬 서버 연결 설정
            URL url = new URL("http://localhost:11434/api/generate");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setDoOutput(true);

            // 2. JSON 요청 데이터 구성 (gemma3:1b 모델 사용)
            JsonObject jsonInput = new JsonObject();
            jsonInput.addProperty("model", "gemma3:1b");
            jsonInput.addProperty("prompt", userMsg);
            jsonInput.addProperty("stream", false);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonInput.toString().getBytes("utf-8"));
            }

            // 3. 응답 결과 받기
            if (conn.getResponseCode() == 200) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
                String line = br.readLine();
                JsonObject jsonRes = JsonParser.parseString(line).getAsJsonObject();
                aiResponse = jsonRes.get("response").getAsString();
            } else {
                aiResponse = "AI 서버 연결 실패: " + conn.getResponseCode();
            }
        } catch (Exception e) {
            aiResponse = "에러: " + e.getMessage();
        }

        // 4. 결과를 다시 JSP로 전달
        request.setAttribute("result", aiResponse);
        request.getRequestDispatcher("test.jsp").forward(request, response);
    }
}