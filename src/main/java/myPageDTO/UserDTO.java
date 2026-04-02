package myPageDTO;

import java.sql.Timestamp;

/**
 * USERS 테이블 매핑 DTO
 * 수사관 계정 정보
 */
public class UserDTO {

    private String userId;      // 로그인 아이디 (PK)
    private String userPw;      // 비밀번호 (BCrypt 해시)
    private String userName;    // 수사관 실명
    private String userPhone;   // 연락처
    private String userOrg;     // 소속 기관
    private String userRank;    // 계급
    private String userDept;    // 부서명
    private String badgeNum;    // 공무원증 번호
    private Timestamp createdAt; // 가입 일시
    private Integer deptId;     // 부서 ID (FK)

    public UserDTO() {}

    public UserDTO(String userId, String userPw, String userName,
                   String userPhone, String userOrg, String userRank,
                   String userDept, String badgeNum, Timestamp createdAt) {
        this.userId    = userId;
        this.userPw    = userPw;
        this.userName  = userName;
        this.userPhone = userPhone;
        this.userOrg   = userOrg;
        this.userRank  = userRank;
        this.userDept  = userDept;
        this.badgeNum  = badgeNum;
        this.createdAt = createdAt;
    }

    // ── Getters ───────────────────────────────────────────
    public String getUserId()      { return userId; }
    public String getUserPw()      { return userPw; }
    public String getUserName()    { return userName; }
    public String getUserPhone()   { return userPhone; }
    public String getUserOrg()     { return userOrg; }
    public String getUserRank()    { return userRank; }
    public String getUserDept()    { return userDept; }
    public String getBadgeNum()    { return badgeNum; }
    public Timestamp getCreatedAt(){ return createdAt; }
    public Integer getDeptId()     { return deptId; }

    // ── Setters ───────────────────────────────────────────
    public void setUserId(String userId)           { this.userId    = userId; }
    public void setUserPw(String userPw)           { this.userPw    = userPw; }
    public void setUserName(String userName)       { this.userName  = userName; }
    public void setUserPhone(String userPhone)     { this.userPhone = userPhone; }
    public void setUserOrg(String userOrg)         { this.userOrg   = userOrg; }
    public void setUserRank(String userRank)       { this.userRank  = userRank; }
    public void setUserDept(String userDept)       { this.userDept  = userDept; }
    public void setBadgeNum(String badgeNum)       { this.badgeNum  = badgeNum; }
    public void setCreatedAt(Timestamp createdAt)  { this.createdAt = createdAt; }
    public void setDeptId(Integer deptId)          { this.deptId    = deptId; }

    @Override
    public String toString() {
        return "UserDTO{userId='" + userId + "', userName='" + userName +
               "', userRank='" + userRank + "', userOrg='" + userOrg + "'}";
    }
}
