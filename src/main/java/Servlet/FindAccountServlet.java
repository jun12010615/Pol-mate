package Servlet;

import java.io.*;
import java.sql.*;
import java.util.Properties;
import java.util.Random;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.JsonObject;

/**
 * FindAccountServlet
 * POST /findAccount
 *   action=findId    : 이름+이메일 → 아이디 이메일 발송
 *   action=sendCode  : 아이디+이메일 확인 → 6자리 인증코드 이메일 발송 + 세션 저장
 *   action=verifyCode: 인증코드 검증 (세션 비교, 3분 유효)
 *   action=resetPw   : 새 비밀번호로 DB UPDATE
 */
@WebServlet("/findAccount")
public class FindAccountServlet extends HttpServlet {

    private static final String CFG_SMTP_HOST = "MAIL_SMTP_HOST";
    private static final String CFG_SMTP_PORT = "MAIL_SMTP_PORT";
    private static final String CFG_SMTP_USER = "MAIL_SMTP_USER";
    private static final String CFG_SMTP_PASS = "MAIL_SMTP_PASS";
    private static final String CFG_FROM_NAME = "MAIL_FROM_NAME";

    // 세션 키
    private static final String SESS_CODE    = "pw_code";
    private static final String SESS_USERID  = "pw_userId";
    private static final String SESS_EXPIRES = "pw_expires";
    private static final long   CODE_TTL_MS  = 3 * 60 * 1000L; // 3분

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("application/json; charset=UTF-8");
        res.setCharacterEncoding("UTF-8");

        String action = nvl(req.getParameter("action"));
        PrintWriter out = res.getWriter();

        switch (action) {
            case "findId"     -> out.print(handleFindId(req));
            case "sendCode"   -> out.print(handleSendCode(req));
            case "verifyCode" -> out.print(handleVerifyCode(req));
            case "resetPw"    -> out.print(handleResetPw(req));
            default           -> out.print(fail("알 수 없는 요청입니다."));
        }
    }

    // ═══════════════════════════════════════════════════════════
    // 1. 아이디 찾기 (이름 + 이메일 → 이메일 발송)
    // ═══════════════════════════════════════════════════════════
    private String handleFindId(HttpServletRequest req) {
        String name  = nvl(req.getParameter("name"));
        String email = nvl(req.getParameter("email"));

        if (name.isEmpty())  return fail("이름을 입력해 주세요.");
        if (email.isEmpty()) return fail("이메일을 입력해 주세요.");
        if (!isValidEmail(email)) return fail("이메일 형식이 올바르지 않습니다.");

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "SELECT user_id FROM users WHERE user_name = ? AND user_email = ?");
            pstmt.setString(1, name); pstmt.setString(2, email);
            rs = pstmt.executeQuery();
            if (!rs.next()) return fail("입력하신 이름과 이메일이 일치하는 계정을 찾을 수 없습니다.");

            String maskedId = maskId(rs.getString("user_id"));
            sendEmail(email, "[POL-MATE] 아이디 찾기 안내", buildFindIdHtml(name, maskedId));

            JsonObject jo = new JsonObject();
            jo.addProperty("success", true);
            jo.addProperty("maskedEmail", maskEmail(email));
            return jo.toString();
        } catch (MailSendException me) {
            me.printStackTrace();
            return fail("이메일 발송 실패: " + me.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return fail("서버 오류가 발생했습니다.");
        } finally { closeAll(mgr, conn, pstmt, rs); }
    }

    // ═══════════════════════════════════════════════════════════
    // 2. 인증코드 발송 (아이디 + 이메일 확인 후 코드 이메일 전송)
    // ═══════════════════════════════════════════════════════════
    private String handleSendCode(HttpServletRequest req) {
        String userId = nvl(req.getParameter("userId"));
        String email  = nvl(req.getParameter("email"));

        if (userId.isEmpty()) return fail("아이디를 입력해 주세요.");
        if (email.isEmpty())  return fail("이메일을 입력해 주세요.");
        if (!isValidEmail(email)) return fail("이메일 형식이 올바르지 않습니다.");

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "SELECT user_id FROM users WHERE user_id = ? AND user_email = ?");
            pstmt.setString(1, userId); pstmt.setString(2, email);
            rs = pstmt.executeQuery();
            if (!rs.next()) return fail("아이디 또는 이메일이 일치하지 않습니다.");

            // 6자리 랜덤 인증코드 생성
            String code = String.format("%06d", new Random().nextInt(1_000_000));

            // 세션에 저장 (코드, userId, 만료시간)
            HttpSession sess = req.getSession();
            sess.setAttribute(SESS_CODE,    code);
            sess.setAttribute(SESS_USERID,  userId);
            sess.setAttribute(SESS_EXPIRES, System.currentTimeMillis() + CODE_TTL_MS);

            // 이메일 발송
            sendEmail(email, "[POL-MATE] 비밀번호 재설정 인증코드", buildCodeHtml(userId, code));

            return ok("인증코드가 발송되었습니다.");
        } catch (MailSendException me) {
            me.printStackTrace();
            return fail("이메일 발송 실패: " + me.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return fail("서버 오류가 발생했습니다.");
        } finally { closeAll(mgr, conn, pstmt, rs); }
    }

    // ═══════════════════════════════════════════════════════════
    // 3. 인증코드 검증
    // ═══════════════════════════════════════════════════════════
    private String handleVerifyCode(HttpServletRequest req) {
        String inputCode = nvl(req.getParameter("code"));
        if (inputCode.isEmpty()) return fail("인증코드를 입력해 주세요.");

        HttpSession sess = req.getSession(false);
        if (sess == null) return fail("세션이 만료되었습니다. 인증코드를 다시 발송해 주세요.");

        String savedCode = (String) sess.getAttribute(SESS_CODE);
        Long   expires   = (Long)   sess.getAttribute(SESS_EXPIRES);

        if (savedCode == null || expires == null)
            return fail("인증코드를 먼저 발송해 주세요.");
        if (System.currentTimeMillis() > expires)
            return fail("인증코드가 만료되었습니다. 재발송해 주세요.");
        if (!savedCode.equals(inputCode))
            return fail("인증코드가 올바르지 않습니다.");

        // 인증 성공 — 코드 무효화 (재사용 방지)
        sess.removeAttribute(SESS_CODE);
        sess.removeAttribute(SESS_EXPIRES);
        // userId는 resetPw에서 사용하므로 유지

        return ok("인증되었습니다.");
    }

    // ═══════════════════════════════════════════════════════════
    // 4. 비밀번호 재설정
    // ═══════════════════════════════════════════════════════════
    private String handleResetPw(HttpServletRequest req) {
        String newPw = nvl(req.getParameter("newPw"));

        HttpSession sess = req.getSession(false);
        if (sess == null) return fail("세션이 만료되었습니다. 처음부터 다시 시도해 주세요.");

        String userId = (String) sess.getAttribute(SESS_USERID);
        if (userId == null) return fail("인증 정보가 없습니다. 처음부터 다시 시도해 주세요.");

        // 비밀번호 유효성 검사
        if (newPw.length() < 8)               return fail("비밀번호는 8자 이상이어야 합니다.");
        if (!newPw.matches(".*[a-zA-Z].*"))   return fail("영문자를 포함해야 합니다.");
        if (!newPw.matches(".*[0-9].*"))      return fail("숫자를 포함해야 합니다.");
        if (!newPw.matches(".*[!@#$%^&*()_+\\-=].*")) return fail("특수문자를 포함해야 합니다.");

        DBConnectionMgr mgr = DBConnectionMgr.getInstance();
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "UPDATE users SET user_pw = ?, password_changed_at = NOW() WHERE user_id = ?");
            pstmt.setString(1, newPw);   // ※ 운영 환경에서는 BCrypt 해시 적용
            pstmt.setString(2, userId);
            int updated = pstmt.executeUpdate();
            if (updated == 0) return fail("계정을 찾을 수 없습니다.");

            // 세션 정리
            sess.removeAttribute(SESS_USERID);

            return ok("비밀번호가 변경되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            return fail("서버 오류가 발생했습니다.");
        } finally { closeAll(mgr, conn, pstmt, null); }
    }

    // ═══════════════════════════════════════════════════════════
    // 이메일 발송 공통 메서드
    // ═══════════════════════════════════════════════════════════
    private void sendEmail(String toEmail, String subject, String html)
            throws MailSendException, UnsupportedEncodingException {
        Properties cfg = loadConfig();
        String smtpHost = cfg.getProperty(CFG_SMTP_HOST, "smtp.gmail.com");
        String smtpPort = cfg.getProperty(CFG_SMTP_PORT, "587");
        String smtpUser = cfg.getProperty(CFG_SMTP_USER, "");
        String smtpPass = cfg.getProperty(CFG_SMTP_PASS, "");
        String fromName = cfg.getProperty(CFG_FROM_NAME, "POL-MATE");

        if (smtpUser.isEmpty() || smtpPass.isEmpty())
            throw new MailSendException("SMTP 계정이 설정되지 않았습니다. config.properties를 확인하세요.");

        Properties mailProps = new Properties();
        mailProps.put("mail.smtp.host",            smtpHost);
        mailProps.put("mail.smtp.port",            smtpPort);
        mailProps.put("mail.smtp.auth",            "true");
        mailProps.put("mail.smtp.starttls.enable", "true");
        mailProps.put("mail.smtp.ssl.protocols",   "TLSv1.2");

        final String user = smtpUser, pass = smtpPass;
        Session mailSession = Session.getInstance(mailProps, new Authenticator() {
            @Override protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });

        try {
            Message msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(smtpUser, fromName, "UTF-8"));
            msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            msg.setSubject(subject);
            msg.setContent(html, "text/html; charset=UTF-8");
            Transport.send(msg);
        } catch (MessagingException e) {
            throw new MailSendException("메일 전송 실패: " + e.getMessage());
        }
    }

    // ═══════════════════════════════════════════════════════════
    // 이메일 HTML 본문
    // ═══════════════════════════════════════════════════════════
    private String buildFindIdHtml(String userName, String maskedId) {
        return baseHtml("아이디 찾기 안내",
            "<p style='font-size:14px;color:#1a1a2e;margin:0 0 6px;'>"
            + "<strong>" + escHtml(userName) + "</strong> 수사관님,</p>"
            + "<p style='font-size:13px;color:#6b7280;margin:0 0 24px;line-height:1.7;'>"
            + "요청하신 아이디 찾기 결과를 안내드립니다.</p>"
            + "<div style='background:#f0f2f8;border-radius:12px;padding:24px;text-align:center;margin-bottom:24px;'>"
            + "<p style='font-size:11px;color:#6b7280;margin:0 0 8px;'>회원님의 아이디</p>"
            + "<p style='font-size:26px;font-weight:700;color:#0d1a33;letter-spacing:4px;margin:0;'>"
            + escHtml(maskedId) + "</p>"
            + "<p style='font-size:11px;color:#9ca3af;margin:8px 0 0;'>보안을 위해 일부 문자는 *로 표시됩니다</p>"
            + "</div>"
        );
    }

    private String buildCodeHtml(String userId, String code) {
        return baseHtml("비밀번호 재설정 인증코드",
            "<p style='font-size:14px;color:#1a1a2e;margin:0 0 6px;'>"
            + "<strong>" + escHtml(userId) + "</strong> 수사관님,</p>"
            + "<p style='font-size:13px;color:#6b7280;margin:0 0 24px;line-height:1.7;'>"
            + "비밀번호 재설정을 위한 인증코드를 안내드립니다.</p>"
            + "<div style='background:#f0f2f8;border-radius:12px;padding:24px;text-align:center;margin-bottom:16px;'>"
            + "<p style='font-size:11px;color:#6b7280;margin:0 0 8px;'>인증코드 (3분 이내 입력)</p>"
            + "<p style='font-size:36px;font-weight:700;color:#0d1a33;letter-spacing:8px;margin:0;'>"
            + escHtml(code) + "</p>"
            + "</div>"
            + "<p style='font-size:12px;color:#9ca3af;line-height:1.8;margin:0;'>"
            + "본인이 요청하지 않은 경우 이 메일을 무시하셔도 됩니다.</p>"
        );
    }

    private String baseHtml(String title, String body) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
            + "<body style='margin:0;padding:0;background:#f0f2f8;font-family:Arial,sans-serif;'>"
            + "<div style='max-width:480px;margin:40px auto;background:#fff;"
            + "border-radius:16px;overflow:hidden;border:1px solid #e2e5ee;'>"
            + "<div style='background:#0d1a33;padding:32px;text-align:center;'>"
            + "<p style='font-size:11px;color:rgba(255,255,255,0.45);letter-spacing:2px;margin:0 0 6px;'>POL-MATE</p>"
            + "<p style='font-size:20px;font-weight:700;color:#fff;margin:0;'>" + escHtml(title) + "</p>"
            + "</div>"
            + "<div style='padding:32px;'>" + body + "</div>"
            + "<div style='background:#f0f2f8;padding:16px 32px;text-align:center;"
            + "font-size:11px;color:#9ca3af;border-top:1px solid #e2e5ee;'>"
            + "© POL-MATE &nbsp;·&nbsp; 이 메일은 자동 발송되었습니다.</div>"
            + "</div></body></html>";
    }

    // ═══════════════════════════════════════════════════════════
    // 유틸
    // ═══════════════════════════════════════════════════════════
    private Properties loadConfig() {
        Properties p = new Properties();
        try (InputStream is = getServletContext().getResourceAsStream("/WEB-INF/config.properties")) {
            if (is != null) p.load(new InputStreamReader(is, "UTF-8"));
        } catch (Exception ignored) {}
        return p;
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[\\w.+\\-]+@[\\w\\-]+\\.[\\w.]+$");
    }

    private String maskId(String id) {
        if (id == null || id.length() <= 2) return id;
        int show = (int) Math.ceil(id.length() / 2.0);
        return id.substring(0, show) + "*".repeat(id.length() - show);
    }

    private String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 0) return email;
        String local = email.substring(0, at), domain = email.substring(at);
        int show = Math.min(2, local.length());
        return local.substring(0, show) + "*".repeat(local.length() - show) + domain;
    }

    private String escHtml(String s) {
        return s == null ? "" : s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
    }

    private String nvl(String s) { return s == null ? "" : s.trim(); }

    private String ok(String msg) {
        JsonObject jo = new JsonObject();
        jo.addProperty("success", true);
        jo.addProperty("message", msg);
        return jo.toString();
    }

    private String fail(String msg) {
        JsonObject jo = new JsonObject();
        jo.addProperty("success", false);
        jo.addProperty("message", msg);
        return jo.toString();
    }

    private void closeAll(DBConnectionMgr mgr, Connection c, PreparedStatement p, ResultSet r) {
        try { if (r != null) r.close(); } catch (Exception ignored) {}
        try { if (p != null) p.close(); } catch (Exception ignored) {}
        try { if (c != null) mgr.freeConnection(c); } catch (Exception ignored) {}
    }

    static class MailSendException extends RuntimeException {
        MailSendException(String msg) { super(msg); }
    }
}
