package myPageDAO;

import Servlet.DBConnectionMgr;
import myPageDTO.MypageStatsDTO;
import myPageDTO.TranscriptDTO;
import myPageDTO.UserDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public class MypageDAO {

    private DBConnectionMgr mgr;

    // ════════════════════════════════════════════════════════════════
    // 1. 프로필 조회
    // ════════════════════════════════════════════════════════════════
    public MypageDAO() {
		mgr = DBConnectionMgr.getInstance();
	}
    
    public UserDTO getUserById(String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        UserDTO dto = new UserDTO();
        try {
            conn = mgr.getConnection();
            String sql = "SELECT u.user_id, u.user_name, u.user_phone, u.user_org, u.user_rank, " +
                         "       d.dept_name AS user_dept, u.badge_num, u.created_at " +
                         "FROM users u " +
                         "LEFT JOIN departments d ON u.dept_id = d.dept_id " +
                         "WHERE u.user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                dto.setUserId(rs.getString("user_id"));
                dto.setUserName(rs.getString("user_name"));
                dto.setUserPhone(rs.getString("user_phone"));
                dto.setUserOrg(rs.getString("user_org"));
                dto.setUserRank(rs.getString("user_rank"));
                dto.setUserDept(rs.getString("user_dept"));
                dto.setBadgeNum(rs.getString("badge_num"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                return dto;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return dto;
    }

    // ════════════════════════════════════════════════════════════════
    // 2. 프로필 수정
    // ════════════════════════════════════════════════════════════════

    public boolean updateProfile(UserDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = mgr.getConnection();
            String sql = "UPDATE users SET user_name = ?, user_rank = ?, user_org = ?, user_phone = ? " +
                         "WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getUserName());
            pstmt.setString(2, dto.getUserRank());
            pstmt.setString(3, dto.getUserOrg());
            pstmt.setString(4, dto.getUserPhone());
            pstmt.setString(5, dto.getUserId());
            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt);
        }
        return false;
    }

    // ════════════════════════════════════════════════════════════════
    // 3. 비밀번호 확인 / 변경
    // ════════════════════════════════════════════════════════════════

    public boolean checkPassword(String userId, String plainPw) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement("SELECT user_pw FROM users WHERE user_id = ?");
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedPw = rs.getString("user_pw");
                // ※ BCrypt 적용 시: return BCrypt.checkpw(plainPw, storedPw);
                return storedPw.equals(plainPw);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return false;
    }

    public boolean changePassword(String userId, String newPw) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = mgr.getConnection();
            // ※ BCrypt 적용 시: newPw = BCrypt.hashpw(newPw, BCrypt.gensalt());
            pstmt = conn.prepareStatement("UPDATE users SET user_pw = ? WHERE user_id = ?");
            pstmt.setString(1, newPw);
            pstmt.setString(2, userId);
            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt);
        }
        return false;
    }

    // ════════════════════════════════════════════════════════════════
    // 4. 내 조서 이력
    // ════════════════════════════════════════════════════════════════

    public List<TranscriptDTO> getTranscriptHistory(String userId, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<TranscriptDTO> list = new ArrayList<>();

        try {
            conn = mgr.getConnection();
            String sql = "SELECT t.transcript_id, t.case_id, t.user_id, " +
                         "       t.stmt_name, t.stmt_type, t.has_contradiction, t.created_at, " +
                         "       c.case_name, c.status AS case_status " +
                         "FROM transcripts t " +
                         "JOIN cases c ON t.case_id = c.case_id " +
                         "WHERE t.user_id = ? " +
                         "ORDER BY t.created_at DESC " +
                         "LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                TranscriptDTO dto = new TranscriptDTO();
                dto.setTranscriptId(rs.getInt("transcript_id"));
                dto.setCaseId(rs.getString("case_id"));
                dto.setUserId(rs.getString("user_id"));
                dto.setStmtName(rs.getString("stmt_name"));
                dto.setStmtType(rs.getString("stmt_type"));
                dto.setHasContradiction(rs.getInt("has_contradiction"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setCaseName(rs.getString("case_name"));
                dto.setCaseStatus(rs.getString("case_status"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return list;
    }

    // ════════════════════════════════════════════════════════════════
    // 5. 활동 통계
    // ════════════════════════════════════════════════════════════════

    public MypageStatsDTO getStats(String userId) {
        MypageStatsDTO stats = new MypageStatsDTO();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // ① 조서 기준 통계 (transcripts JOIN cases)
        try {
            conn = mgr.getConnection();
            String sql =
                "SELECT COUNT(*) AS total_transcripts, " +
                "  SUM(t.has_contradiction) AS contradiction_count, " +
                "  SUM(CASE WHEN c.status = '완료' THEN 1 ELSE 0 END) AS completed_transcripts " +
                "FROM transcripts t " +
                "JOIN cases c ON t.case_id = c.case_id " +
                "WHERE t.user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stats.setTotalTranscripts(rs.getInt("total_transcripts"));
                stats.setContradictionCount(rs.getInt("contradiction_count"));
                stats.setCompletedTranscripts(rs.getInt("completed_transcripts"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }

        // ② 팀 사건 통계 (dept_id 기반 — main.jsp와 동일 로직)
        try {
            conn = mgr.getConnection();
            String sql =
                "SELECT COUNT(*) AS total_cases, " +
                "  SUM(CASE WHEN c.status != '완료' THEN 1 ELSE 0 END) AS active_cases " +
                "FROM cases c " +
                "WHERE (c.user_id = ? OR c.user_id IN (" +
                "  SELECT u2.user_id FROM users u2 " +
                "  JOIN users me ON me.user_id = ? " +
                "  WHERE u2.dept_id = me.dept_id AND me.dept_id IS NOT NULL" +
                "))";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stats.setTotalCases(rs.getInt("total_cases"));
                stats.setActiveCases(rs.getInt("active_cases"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }

        // ③ 관계망 편집 이력 수
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) AS relation_count FROM relation_history WHERE user_id = ?");
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stats.setRelationEdges(rs.getInt("relation_count"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }

        return stats;
    }

    // ════════════════════════════════════════════════════════════════
    // 6. 알림 설정 조회
    // ════════════════════════════════════════════════════════════════

    public java.util.Map<String, Boolean> getSettings(String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        java.util.Map<String, Boolean> map = new java.util.HashMap<>();
        map.put("notifContradiction", true);
        map.put("notifRelation",      true);
        map.put("nightMode",          false);

        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "SELECT notif_contradiction, notif_relation, night_mode " +
                "FROM users WHERE user_id = ?");
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                map.put("notifContradiction", rs.getInt("notif_contradiction") == 1);
                map.put("notifRelation",      rs.getInt("notif_relation")      == 1);
                map.put("nightMode",          rs.getInt("night_mode")          == 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return map;
    }

    // ════════════════════════════════════════════════════════════════
    // 7. 알림 설정 저장
    // ════════════════════════════════════════════════════════════════

    public boolean saveSettings(String userId, boolean notifContradiction,
                                boolean notifRelation, boolean nightMode) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "UPDATE users SET notif_contradiction = ?, notif_relation = ?, night_mode = ? " +
                "WHERE user_id = ?");
            pstmt.setInt(1, notifContradiction ? 1 : 0);
            pstmt.setInt(2, notifRelation      ? 1 : 0);
            pstmt.setInt(3, nightMode          ? 1 : 0);
            pstmt.setString(4, userId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt);
        }
        return false;
    }
}
