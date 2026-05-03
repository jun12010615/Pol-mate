package Servlet;

import java.io.*;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        String userPw = request.getParameter("userPw");

        // ── 빈값 체크 ───────────────────────────────────────────
        if (userId == null || userId.trim().isEmpty()
         || userPw == null || userPw.trim().isEmpty()) {
            request.setAttribute("loginError", "아이디와 비밀번호를 입력해 주세요.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // ── DB 조회 ─────────────────────────────────────────────
        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();

            String sql = "SELECT user_id, user_pw, user_name, user_rank, user_org, user_phone FROM USERS WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId.trim());
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String dbPw    = rs.getString("user_pw");
                String dbName  = rs.getString("user_name");
                
                // 2. DB에서 계급, 소속, 전화번호 추가로 읽어오기
                String dbRank  = rs.getString("user_rank");
                String dbOrg   = rs.getString("user_org");
                String dbPhone = rs.getString("user_phone");

                if (dbPw.equals(userPw)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("loginUser", userId.trim());
                    session.setAttribute("userName",  dbName);
                    session.setAttribute("userRank", dbRank);
                    session.setAttribute("userOrg", dbOrg);
                    session.setAttribute("userPhone", dbPhone);
                    
                    session.setMaxInactiveInterval(60 * 60); 
                    String redirectTo = request.getParameter("redirectTo");
                    if ("desktop".equals(redirectTo)) {
                        response.sendRedirect("desktop/main.jsp");
                    } else {
                        response.sendRedirect("main.jsp");
                    }
                } else {
                    // 비밀번호 불일치
                    request.setAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                // 아이디 없음
                request.setAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loginError", "로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}