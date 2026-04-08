package myPageDAO;

import Servlet.DBConnectionMgr;
import myPageDTO.MypageStatsDTO;
import myPageDTO.TranscriptDTO;
import myPageDTO.UserDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


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
                         "       d.dept_name AS user_dept, u.badge_num, u.created_at, u.dept_id " +
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
                int deptId = rs.getInt("dept_id");
                dto.setDeptId(rs.wasNull() ? null : deptId);
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
            String sql = "UPDATE users SET user_name = ?, user_rank = ?, user_org = ?, user_phone = ?, dept_id = ? " +
                         "WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getUserName());
            pstmt.setString(2, dto.getUserRank());
            pstmt.setString(3, dto.getUserOrg());
            pstmt.setString(4, dto.getUserPhone());
            // dept_id: 0 이하면 NULL (미배정)
            if (dto.getDeptId() != null && dto.getDeptId() > 0) {
                pstmt.setInt(5, dto.getDeptId());
            } else {
                pstmt.setNull(5, java.sql.Types.INTEGER);
            }
            pstmt.setString(6, dto.getUserId());
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
            pstmt = conn.prepareStatement(
                "UPDATE users SET user_pw = ?, password_changed_at = NOW() WHERE user_id = ?");
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
    // 5-b. 기간별 통계 (period: week / month / all)
    // ════════════════════════════════════════════════════════════════
    public MypageStatsDTO getStatsByPeriod(String userId, String period) {
        MypageStatsDTO stats = new MypageStatsDTO();
        String dateFilter = "";
        if ("week".equals(period)) {
            dateFilter = " AND t.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
        } else if ("month".equals(period)) {
            dateFilter = " AND t.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = mgr.getConnection();
            String sql =
                "SELECT COUNT(*) AS total_transcripts, " +
                "  SUM(t.has_contradiction) AS contradiction_count " +
                "FROM transcripts t " +
                "JOIN cases c ON t.case_id = c.case_id " +
                "WHERE t.user_id = ?" + dateFilter;
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stats.setTotalTranscripts(rs.getInt("total_transcripts"));
                stats.setContradictionCount(rs.getInt("contradiction_count"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }

        // 팀 사건 (기간 필터 없음 — 사건은 생성일 기준이 아닌 현재 상태 기반)
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

        // 관계망 (기간 필터 적용)
        try {
            conn = mgr.getConnection();
            String relFilter = "";
            if ("week".equals(period))  relFilter = " AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            else if ("month".equals(period)) relFilter = " AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) AS relation_count FROM relation_history WHERE user_id = ?" + relFilter);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) stats.setRelationEdges(rs.getInt("relation_count"));
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }

        return stats;
    }

    // ════════════════════════════════════════════════════════════════
    // 5-c. 월별 조서 처리 현황 (최근 6개월)
    // ════════════════════════════════════════════════════════════════
    public Map<String, Integer> getMonthlyTranscripts(String userId) {
        // 최근 6개월 라벨 미리 생성 (데이터 없는 달도 0으로 표시)
        Map<String, Integer> result = new LinkedHashMap<>();
        java.util.Calendar cal = java.util.Calendar.getInstance();
        for (int i = 5; i >= 0; i--) {
            java.util.Calendar c2 = (java.util.Calendar) cal.clone();
            c2.add(java.util.Calendar.MONTH, -i);
            String key = String.format("%d.%02d",
                c2.get(java.util.Calendar.YEAR),
                c2.get(java.util.Calendar.MONTH) + 1);
            result.put(key, 0);
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "SELECT DATE_FORMAT(created_at, '%Y.%m') AS ym, COUNT(*) AS cnt " +
                "FROM transcripts " +
                "WHERE user_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                "GROUP BY ym ORDER BY ym");
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String ym = rs.getString("ym");
                if (result.containsKey(ym)) result.put(ym, rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return result;
    }

    // ════════════════════════════════════════════════════════════════
    // 6. 회원탈퇴 (관련 데이터 연쇄 삭제 후 계정 삭제)
    // ════════════════════════════════════════════════════════════════

    public boolean withdrawUser(String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = mgr.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작

            // ① 알림 삭제 (수신·발신 모두)
            pstmt = conn.prepareStatement("DELETE FROM notifications WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ② 관계망 편집 이력 삭제
            pstmt = conn.prepareStatement("DELETE FROM relation_history WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ③ 내가 작성한 조서 전체 삭제 (내 사건 + 팀원 사건에 작성한 것 포함)
            pstmt = conn.prepareStatement("DELETE FROM transcripts WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ④ 내 사건에 팀원이 작성한 조서 삭제
            //    (cases 삭제 전에 FK 제약 해소)
            pstmt = conn.prepareStatement(
                "DELETE FROM transcripts " +
                "WHERE case_id IN (SELECT case_id FROM cases WHERE user_id = ?)");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑤ 내 사건 삭제
            pstmt = conn.prepareStatement("DELETE FROM cases WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑥ 게시판 — 내가 누른 게시글 좋아요의 like_count 캐시 재집계
            //    (board_likes 삭제 전에 먼저 실행해야 정확히 반영됨)
            pstmt = conn.prepareStatement(
                "UPDATE board_posts p " +
                "SET p.like_count = (" +
                "  SELECT COUNT(*) FROM board_likes l " +
                "  WHERE l.target_type = 'post' AND l.target_id = p.post_id" +
                ") - 1 " +
                "WHERE p.post_id IN (" +
                "  SELECT target_id FROM board_likes " +
                "  WHERE user_id = ? AND target_type = 'post'" +
                ")");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑥-b 내가 누른 좋아요 전체 삭제 (post + comment)
            pstmt = conn.prepareStatement(
                "DELETE FROM board_likes WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑦ 게시판 — 내 게시글의 댓글에 달린 좋아요 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_likes " +
                "WHERE target_type = 'comment' AND target_id IN (" +
                "  SELECT comment_id FROM board_comments " +
                "  WHERE post_id IN (SELECT post_id FROM board_posts WHERE user_id = ?)" +
                ")");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑧ 게시판 — 내 게시글에 달린 좋아요 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_likes " +
                "WHERE target_type = 'post' AND target_id IN (" +
                "  SELECT post_id FROM board_posts WHERE user_id = ?" +
                ")");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑨ 게시판 — 내 댓글 삭제 (다른 사람 게시글에 단 것 포함)
            pstmt = conn.prepareStatement(
                "DELETE FROM board_comments WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑩ 게시판 — 내 게시글의 남은 댓글 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_comments " +
                "WHERE post_id IN (SELECT post_id FROM board_posts WHERE user_id = ?)");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑪ 게시판 — 내 게시글의 태그·링크 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_tags " +
                "WHERE post_id IN (SELECT post_id FROM board_posts WHERE user_id = ?)");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            pstmt = conn.prepareStatement(
                "DELETE FROM board_links " +
                "WHERE post_id IN (SELECT post_id FROM board_posts WHERE user_id = ?)");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑫ 게시판 — 내 게시글 삭제
            pstmt = conn.prepareStatement(
                "DELETE FROM board_posts WHERE user_id = ?");
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // ⑬ 사용자 계정 삭제 (마지막)
            pstmt = conn.prepareStatement("DELETE FROM users WHERE user_id = ?");
            pstmt.setString(1, userId);
            int affected = pstmt.executeUpdate();

            if (affected > 0) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ignored) {}
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception ignored) {}
            mgr.freeConnection(conn, pstmt);
        }
    }

    // ════════════════════════════════════════════════════════════════
    // 7. 알림 설정 조회
    // ════════════════════════════════════════════════════════════════

    public java.util.Map<String, Object> getSettings(String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        java.util.Map<String, Object> settings = new java.util.HashMap<>();
        // 기본값 (DB 조회 실패 시 안전한 기본값 유지)
        settings.put("notifContradiction", true);
        settings.put("notifRelation",      true);
        settings.put("nightMode",          false);
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "SELECT notif_contradiction, notif_relation, night_mode FROM users WHERE user_id = ?");
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                settings.put("notifContradiction", rs.getInt("notif_contradiction") == 1);
                settings.put("notifRelation",      rs.getInt("notif_relation")      == 1);
                settings.put("nightMode",          rs.getInt("night_mode")          == 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return settings;
    }

    // ════════════════════════════════════════════════════════════════
    // 8. 알림 설정 저장
    // ════════════════════════════════════════════════════════════════

    public boolean saveSettings(String userId, boolean notifContradiction, boolean notifRelation, boolean nightMode) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = mgr.getConnection();
            pstmt = conn.prepareStatement(
                "UPDATE users SET notif_contradiction = ?, notif_relation = ?, night_mode = ? WHERE user_id = ?");
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
    
    // ════════════════════════════════════════════════════════════════
    // 9. 기관별 부서 목록 조회 (새로 분리됨)
    // ════════════════════════════════════════════════════════════════
    public List<Map<String, Object>> getDepartmentsByOrg(String org) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> list = new ArrayList<>();
        
        try {
            conn = mgr.getConnection();
            String sql = "SELECT dept_id, dept_name FROM departments WHERE org_name = ? ORDER BY dept_name";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, org.trim());
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> map = new java.util.HashMap<>();
                map.put("dept_id", rs.getInt("dept_id"));
                map.put("dept_name", rs.getString("dept_name"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return list;
    }

    // ════════════════════════════════════════════════════════════════
    // 10. 모순탐지 참 총 건수 조회 (새로 분리됨)
    // ════════════════════════════════════════════════════════════════
    public int getContradictionCount(String userId, String period) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = mgr.getConnection();
            String sql;
            if ("week".equals(period)) {
                sql = "SELECT COUNT(*) FROM contradiction_results WHERE user_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            } else if ("month".equals(period)) {
                sql = "SELECT COUNT(*) FROM contradiction_results WHERE user_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)";
            } else if ("year".equals(period)) {
                sql = "SELECT COUNT(*) FROM contradiction_results WHERE user_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)";
            } else {
                sql = "SELECT COUNT(*) FROM contradiction_results WHERE user_id = ?";
            }
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            mgr.freeConnection(conn, pstmt, rs);
        }
        return count;
    }
}
