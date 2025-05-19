package com.example.rentree.security;

import com.example.rentree.domain.Student;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Getter
public class StudentDetails implements UserDetails {

    private final Student student;

    public StudentDetails(Student student) {
        this.student = student;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // 권한 설정 (단일 권한 예시)
        return Collections.singleton(() -> "ROLE_USER");
    }

    @Override
    public String getPassword() {
        return student.getPassword();  // DB에 암호화된 비밀번호 저장되어야 함
    }

    @Override
    public String getUsername() {
        return student.getStudentNum();  // 학번으로 로그인
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // 계정 만료 여부 처리 안함
    }

    @Override
    public boolean isAccountNonLocked() {
        return true; // 계정 잠금 여부 처리 안함
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // 자격 증명 만료 여부 처리 안함
    }

    @Override
    public boolean isEnabled() {
        // 페널티 3점 이상이면 로그인 차단
        return !student.isBanned();
    }
}
