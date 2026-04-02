package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

@WebServlet("/loadBoardAction.do")
public class LoadBoardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        String caseId = request.getParameter("caseId");
        JsonObject result = new JsonObject();
        Gson gson = new Gson();

        DBConnectionMgr pool = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = pool.getConnection();

            // 1. relation_persons 조회
            String sqlPerson = "SELECT person_name, role, memo FROM relation_persons WHERE case_id = ?";
            pstmt = conn.prepareStatement(sqlPerson);
            pstmt.setString(1, caseId);
            rs = pstmt.executeQuery();

            List<JsonObject> personList = new ArrayList<>();
            while (rs.next()) {
                JsonObject p = new JsonObject();
                p.addProperty("name", rs.getString("person_name"));
                p.addProperty("role", rs.getString("role"));
                p.addProperty("memo", rs.getString("memo") != null ? rs.getString("memo") : "");
                personList.add(p);
            }
            rs.close();
            pstmt.close();

            // 2. relation_edges 조회 (srcName/dstName으로 이름 저장)
            String sqlEdge = "SELECT src_person_id, dst_person_id, rel_type, status, context FROM relation_edges WHERE case_id = ?";
            pstmt = conn.prepareStatement(sqlEdge);
            pstmt.setString(1, caseId);
            rs = pstmt.executeQuery();

            List<JsonObject> edgeList = new ArrayList<>();
            while (rs.next()) {
                JsonObject e = new JsonObject();
                e.addProperty("srcName", rs.getString("src_person_id"));
                e.addProperty("dstName", rs.getString("dst_person_id"));
                e.addProperty("relType", rs.getString("rel_type"));
                e.addProperty("status",  rs.getString("status"));
                e.addProperty("context", rs.getString("context") != null ? rs.getString("context") : "");
                edgeList.add(e);
            }
            rs.close();
            pstmt.close();

            result.add("personList", gson.toJsonTree(personList));
            result.add("edgeList",   gson.toJsonTree(edgeList));
            result.addProperty("success", true);

        } catch (Exception e) {
            e.printStackTrace();
            result.addProperty("success", false);
            result.addProperty("message", e.getMessage());
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }

        out.print(gson.toJson(result));
    }
}
