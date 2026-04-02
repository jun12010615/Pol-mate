package Servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

@WebServlet("/saveBoardAction.do")
public class SaveBoardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;
        PreparedStatement pstmt = null;
        DBConnectionMgr pool = DBConnectionMgr.getInstance();

        try {
            // 1. JSON Body 읽기
            StringBuilder sb = new StringBuilder();
            String line;
            try (BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String jsonStr = sb.toString();

            if (jsonStr.isEmpty()) {
                throw new Exception("전송된 데이터가 비어 있습니다.");
            }

            // 2. JSON 파싱
            Gson gson = new Gson();
            JsonObject dataObj = gson.fromJson(jsonStr, JsonObject.class);

            String caseId = dataObj.get("caseId").getAsString();
            JsonArray personList = dataObj.getAsJsonArray("personList");
            // edgeList가 없으면 빈 배열로 처리
            JsonArray edgeList = dataObj.has("edgeList")
                ? dataObj.getAsJsonArray("edgeList")
                : new JsonArray();

            // 3. DB 연결 + 트랜잭션 시작
            conn = pool.getConnection();
            conn.setAutoCommit(false);

            // 4. 기존 데이터 삭제 (relation_edges 먼저, 그다음 relation_persons)
            String sqlDeleteEdges = "DELETE FROM relation_edges WHERE case_id = ?";
            pstmt = conn.prepareStatement(sqlDeleteEdges);
            pstmt.setString(1, caseId);
            pstmt.executeUpdate();
            pstmt.close();

            String sqlDeletePersons = "DELETE FROM relation_persons WHERE case_id = ?";
            pstmt = conn.prepareStatement(sqlDeletePersons);
            pstmt.setString(1, caseId);
            pstmt.executeUpdate();
            pstmt.close();

            // 5. relation_persons INSERT
            String sqlInsertPerson = "INSERT INTO relation_persons (case_id, person_name, role, memo) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sqlInsertPerson);
            for (JsonElement element : personList) {
                JsonObject p = element.getAsJsonObject();
                pstmt.setString(1, caseId);
                pstmt.setString(2, p.has("name") ? p.get("name").getAsString() : "이름없음");
                pstmt.setString(3, p.has("role") ? p.get("role").getAsString() : "");
                String memo = (p.has("memo") && !p.get("memo").isJsonNull())
                    ? p.get("memo").getAsString() : "";
                pstmt.setString(4, memo);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();

            // 6. relation_edges INSERT (src/dst에 이름 저장)
            if (edgeList.size() > 0) {
                String sqlInsertEdge = "INSERT INTO relation_edges (case_id, src_person_id, dst_person_id, rel_type, status, context) VALUES (?, ?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sqlInsertEdge);
                for (JsonElement element : edgeList) {
                    JsonObject e = element.getAsJsonObject();
                    pstmt.setString(1, caseId);
                    pstmt.setString(2, e.has("srcName") ? e.get("srcName").getAsString() : "");
                    pstmt.setString(3, e.has("dstName") ? e.get("dstName").getAsString() : "");
                    pstmt.setString(4, e.has("relType") ? e.get("relType").getAsString() : "");
                    pstmt.setString(5, e.has("status")  ? e.get("status").getAsString()  : "unknown");
                    String context = (e.has("context") && !e.get("context").isJsonNull())
                        ? e.get("context").getAsString() : "";
                    pstmt.setString(6, context);
                    pstmt.addBatch();
                }
                pstmt.executeBatch();
                pstmt.close();
            }

            conn.commit();
            out.print("{\"success\": true, \"message\": \"저장 성공\"}");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            out.print("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        } finally {
            pool.freeConnection(conn, pstmt);
        }
    }
}
