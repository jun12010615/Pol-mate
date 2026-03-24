<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>AI 수사 보조 테스트</title>
<style>
    body { font-family: sans-serif; margin: 40px; line-height: 1.6; }
    .container { max-width: 600px; margin: auto; }
    textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; }
    button { background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-top: 10px; }
    button:hover { background-color: #0056b3; }
    .result-box { background: #f8f9fa; padding: 20px; border-left: 5px solid #007bff; margin-top: 20px; min-height: 50px; white-space: pre-wrap; }
</style>
</head>
<body>
    <div class="container">
        <h2>⚖KICS AI 수사 보조 시스템 (Test)</h2>
        <p>현장 진술이나 수사 질의를 입력해보세요.</p>
        
        <form action="askAI" method="post">
            <textarea name="userMsg" rows="5" placeholder="예: 피의자가 묵비권을 행사할 때 대처법은?"></textarea>
            <button type="submit">AI 분석 요청</button>
        </form>

        <hr>

        <h3>🔍 AI 분석 결과</h3>
        <div class="result-box">
            <%-- 서블릿에서 담아준 "result" 값을 출력합니다 --%>
            <%= (request.getAttribute("result") != null) ? request.getAttribute("result") : "질문을 입력하고 버튼을 눌러주세요." %>
        </div>
    </div>
</body>
</html>