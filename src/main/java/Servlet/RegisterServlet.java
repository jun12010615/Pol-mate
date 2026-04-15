package Servlet;

import java.io.*;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

/**
 * RegisterServlet
 * - URL: /register
 * - 아이디 중복확인(GET ?action=checkId)
 * - 부서 목록 조회(GET ?action=getDepts&org=기관명)
 * - 회원가입(POST) 처리
 * - USERS 테이블에 신규 수사관 계정 INSERT
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    /**
     * GET /register?action=checkId&userId=xxx
     * → JSON 응답: {"success": true/false, "message": "..."}
     *
     * GET /register?action=getDepts&org=서울지방경찰청
     * → JSON 응답: [{"dept_id": 1, "dept_name": "형사1팀"}, ...]
     *
     * GET /register (action 없음)
     * → register.jsp 포워드
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("checkId".equals(action)) {
            // ── 아이디 중복 확인 ─────────────────────────────────
            response.setContentType("application/json; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");

            String userId = request.getParameter("userId");
            if (userId == null || userId.trim().isEmpty()) {
                response.getWriter().print(jsonResult(false, "아이디를 입력해 주세요."));
                return;
            }

            userId = userId.trim();
            if (!userId.matches("^[a-z0-9]{4,16}$")) {
                response.getWriter().print(jsonResult(false, "영문 소문자+숫자 4~16자로 입력해 주세요."));
                return;
            }

            DBConnectionMgr mgr = DBConnectionMgr.getInstance();
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = mgr.getConnection();
                pstmt = conn.prepareStatement("SELECT 1 FROM users WHERE user_id = ?");
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    response.getWriter().print(jsonResult(false, "이미 사용 중인 아이디입니다."));
                } else {
                    response.getWriter().print(jsonResult(true, "사용 가능한 아이디입니다."));
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().print(jsonResult(false, "서버 오류: " + e.getMessage()));
            } finally {
                mgr.freeConnection(conn, pstmt, rs);
            }

        } else if ("verifyBadge".equals(action)) {
            // ── 공무원증 번호 인증 ───────────────────────────────
            response.setContentType("application/json; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");

            String badgeNum = request.getParameter("badgeNum");
            if (badgeNum == null || badgeNum.trim().isEmpty()) {
                response.getWriter().print(jsonResult(false, "수사관 번호를 입력해 주세요."));
                return;
            }
            badgeNum = badgeNum.trim();
            if (!badgeNum.matches("^[0-9]{4}$")) {
                response.getWriter().print(jsonResult(false, "수사관 번호는 숫자 4자리입니다."));
                return;
            }

            DBConnectionMgr mgr = DBConnectionMgr.getInstance();
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = mgr.getConnection();
                pstmt = conn.prepareStatement(
                    "SELECT is_used FROM officer_badges WHERE badge_num = ?"
                );
                pstmt.setString(1, badgeNum);
                rs = pstmt.executeQuery();
                if (!rs.next()) {
                    response.getWriter().print(jsonResult(false, "등록되지 않은 수사관 번호입니다."));
                } else if (rs.getInt("is_used") == 1) {
                    response.getWriter().print(jsonResult(false, "이미 사용된 수사관 번호입니다."));
                } else {
                    response.getWriter().print(jsonResult(true, "인증되었습니다."));
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().print(jsonResult(false, "서버 오류: " + e.getMessage()));
            } finally {
                mgr.freeConnection(conn, pstmt, rs);
            }

        } else if ("getDepts".equals(action)) {
            // ── 기관별 부서 목록 조회 ────────────────────────────
            response.setContentType("application/json; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");

            String org = request.getParameter("org");
            if (org == null || org.trim().isEmpty()) {
                response.getWriter().print("[]");
                return;
            }

            DBConnectionMgr mgr = DBConnectionMgr.getInstance();
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = mgr.getConnection();
                pstmt = conn.prepareStatement(
                    "SELECT dept_id, dept_name FROM departments WHERE org_name = ? ORDER BY dept_id"
                );
                pstmt.setString(1, org.trim());
                rs = pstmt.executeQuery();

                JsonArray arr = new JsonArray();
                while (rs.next()) {
                    JsonObject obj = new JsonObject();
                    obj.addProperty("dept_id",   rs.getInt("dept_id"));
                    obj.addProperty("dept_name", rs.getString("dept_name"));
                    arr.add(obj);
                }
                response.getWriter().print(arr.toString());
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().print("[]");
            } finally {
                mgr.freeConnection(conn, pstmt, rs);
            }

        } else {
            // ── register.jsp 포워드 ──────────────────────────────
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }

    /**
     * POST /register
     * 파라미터: userId, userPw, userName, userPhone, userOrg, userRank, deptId, badgeNum
     * → JSON 응답: {"success": true/false, "message": "..."}
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ── 파라미터 수집 ────────────────────────────────────────
        String userId   = nvl(request.getParameter("userId"));
        String userPw   = nvl(request.getParameter("userPw"));
        String userName = nvl(request.getParameter("userName"));
        String userPhone= nvl(request.getParameter("userPhone"));
        String userOrg  = nvl(request.getParameter("userOrg"));
        String userRank = nvl(request.getParameter("userRank"));
        String deptId   = nvl(request.getParameter("deptId"));   // 선택 (departments.dept_id)
        String badgeNum = nvl(request.getParameter("badgeNum"));
        String userEmail= nvl(request.getParameter("userEmail"));

        // ── 필수값 검증 ──────────────────────────────────────────
        if (userId.isEmpty())   { response.getWriter().print(jsonResult(false, "아이디를 입력해 주세요.")); return; }
        if (userPw.isEmpty())   { response.getWriter().print(jsonResult(false, "비밀번호를 입력해 주세요.")); return; }
        if (userName.isEmpty()) { response.getWriter().print(jsonResult(false, "이름을 입력해 주세요.")); return; }
        if (userOrg.isEmpty())  { response.getWriter().print(jsonResult(false, "소속 기관을 선택해 주세요.")); return; }
        if (userRank.isEmpty()) { response.getWriter().print(jsonResult(false, "계급을 선택해 주세요.")); return; }
        if (badgeNum.isEmpty()) { response.getWriter().print(jsonResult(false, "수사관 번호를 입력해 주세요.")); return; }
        if (userEmail.isEmpty()) { response.getWriter().print(jsonResult(false, "이메일을 입력해 주세요.")); return; }
        if (!userEmail.matches("^[\\w.+\\-]+@[\\w\\-]+\\.[\\w.]+$")) {
            response.getWriter().print(jsonResult(false, "이메일 형식이 올바르지 않습니다."));
            return;
        }

        // 아이디 형식 체크
        if (!userId.matches("^[a-z0-9]{4,16}$")) {
            response.getWriter().print(jsonResult(false, "아이디는 영문 소문자+숫자 4~16자로 입력해 주세요."));
            return;
        }
        // 비밀번호 복잡도 체크
        if (userPw.length() < 8) {
            response.getWriter().print(jsonResult(false, "비밀번호는 8자 이상 입력해 주세요."));
            return;
        }
        if (!userPw.matches(".*[a-zA-Z].*")) {
            response.getWriter().print(jsonResult(false, "비밀번호에 영문자를 포함해 주세요."));
            return;
        }
        if (!userPw.matches(".*[0-9].*")) {
            response.getWriter().print(jsonResult(false, "비밀번호에 숫자를 포함해 주세요."));
            return;
        }
        if (!userPw.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*")) {
            response.getWriter().print(jsonResult(false, "비밀번호에 특수문자를 포함해 주세요."));
            return;
        }

        // ── DB INSERT ────────────────────────────────────────────
        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = mgr.getConnection();

            // 아이디 중복 재확인 (POST 위조 방지)
            PreparedStatement chk = conn.prepareStatement("SELECT 1 FROM users WHERE user_id = ?");
            chk.setString(1, userId);
            ResultSet chkRs = chk.executeQuery();
            if (chkRs.next()) {
                chkRs.close(); chk.close();
                response.getWriter().print(jsonResult(false, "이미 사용 중인 아이디입니다."));
                return;
            }
            chkRs.close(); chk.close();

            // officer_badges 테이블에서 번호 유효성 확인
            PreparedStatement bChk = conn.prepareStatement(
                "SELECT is_used FROM officer_badges WHERE badge_num = ?"
            );
            bChk.setString(1, badgeNum);
            ResultSet bRs = bChk.executeQuery();
            if (!bRs.next()) {
                bRs.close(); bChk.close();
                response.getWriter().print(jsonResult(false, "등록되지 않은 수사관 번호입니다."));
                return;
            }
            if (bRs.getInt("is_used") == 1) {
                bRs.close(); bChk.close();
                response.getWriter().print(jsonResult(false, "이미 사용된 수사관 번호입니다."));
                return;
            }
            bRs.close(); bChk.close();

            // 이메일 중복 확인
            PreparedStatement eChk = conn.prepareStatement("SELECT 1 FROM users WHERE user_email = ?");
            eChk.setString(1, userEmail);
            ResultSet eRs = eChk.executeQuery();
            if (eRs.next()) {
                eRs.close(); eChk.close();
                response.getWriter().print(jsonResult(false, "이미 사용 중인 이메일입니다."));
                return;
            }
            eRs.close(); eChk.close();

            // INSERT (user_dept 대신 dept_id 사용)
            String sql = "INSERT INTO users (user_id, user_pw, user_name, user_phone, user_email, user_org, user_rank, dept_id, badge_num) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, userPw);   // ※ 운영 환경에서는 BCrypt 해시로 교체
            pstmt.setString(3, userName);
            pstmt.setString(4, userPhone.isEmpty() ? null : userPhone);
            pstmt.setString(5, userEmail);
            pstmt.setString(6, userOrg);
            pstmt.setString(7, userRank);
            // deptId가 비어있거나 숫자가 아니면 NULL 저장
            if (deptId.isEmpty()) {
                pstmt.setNull(8, Types.INTEGER);
            } else {
                try {
                    pstmt.setInt(8, Integer.parseInt(deptId));
                } catch (NumberFormatException e) {
                    pstmt.setNull(8, Types.INTEGER);
                }
            }
            pstmt.setString(9, badgeNum);
            pstmt.executeUpdate();

            // officer_badges 사용 처리
            PreparedStatement upd = conn.prepareStatement(
                "UPDATE officer_badges SET is_used = 1 WHERE badge_num = ?"
            );
            upd.setString(1, badgeNum);
            upd.executeUpdate();
            upd.close();

            response.getWriter().print(jsonResult(true, "회원가입이 완료되었습니다."));

        } catch (SQLIntegrityConstraintViolationException e) {
            // UNIQUE 제약 위반 (race condition 방어)
            response.getWriter().print(jsonResult(false, "이미 사용 중인 아이디 또는 수사관 번호입니다."));
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print(jsonResult(false, "가입 중 오류가 발생했습니다: " + e.getMessage()));
        } finally {
            mgr.freeConnection(conn, pstmt);
        }
    }

    // ── 헬퍼 ────────────────────────────────────────────────────
    private String nvl(String s) {
        return (s == null) ? "" : s.trim();
    }

    private String jsonResult(boolean success, String message) {
        JsonObject obj = new JsonObject();
        obj.addProperty("success", success);
        obj.addProperty("message", message);
        return obj.toString();
    }
}
