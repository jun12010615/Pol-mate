package Servlet;

import java.io.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    // ── 임시 계정 (DB 연동 전 로컬 테스트용) ──────────────────
    // DB 연동 후 아래 Map 삭제하고 DB 조회 로직으로 교체하면 됩니다.
    private static final Map<String, String[]> TEMP_USERS = new HashMap<>();

    @Override
    public void init() {
        // { 아이디 : [비밀번호, 이름] }
        TEMP_USERS.put("admin", new String[]{"1234", "관리자"});
        TEMP_USERS.put("test",  new String[]{"1234", "김민준"});
        TEMP_USERS.put("hong",  new String[]{"abcd", "홍길동"});
    }
    // ──────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        String userPw = request.getParameter("userPw");

        // 빈값 체크
        if (userId == null || userId.trim().isEmpty()
         || userPw == null || userPw.trim().isEmpty()) {
            request.setAttribute("loginError", "아이디와 비밀번호를 입력해 주세요.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // 임시 인증 로직 (DB 연동 후 이 블록을 DB 조회로 교체)
        String[] userData = TEMP_USERS.get(userId.trim());
        if (userData != null && userData[0].equals(userPw)) {
            // 로그인 성공 → 세션 발급
            HttpSession session = request.getSession();
            session.setAttribute("loginUser", userId.trim());
            session.setAttribute("userName",  userData[1]);
            session.setMaxInactiveInterval(60 * 60); // 1시간
            response.sendRedirect("main.jsp");
        } else {
            // 로그인 실패
            request.setAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}
