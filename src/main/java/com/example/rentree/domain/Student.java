package com.example.rentree.domain;

import com.example.rentree.dto.StudentDTO;
import jakarta.persistence.*;
import lombok.*;

@AllArgsConstructor // 모든 필드 값을 파라미터로 받는 생성자 생성
@NoArgsConstructor // 파라미터가 없는 기본 생성자 생성
@Getter // 모든 필드에 대한 getter 메서드 생성
@Setter // 모든 필드에 대한 setter 메서드 생성
@ToString // 모든 필드에 대한 toString 메서드 생성
@Builder // 빌더 패턴을 사용할 수 있게 해줌
@Entity // JPA 엔티티 클래스임을 명시 (데이터베이스의 테이블과 매핑)
@Table(name = "student") // 데이터베이스의 student 테이블과 매핑
public class Student {

    @Id // 기본 키임을 명시
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto_increment
    @Column(nullable = false) // null 값 허용하지 않음
    private int id; // 학생 식별자

    @Column(name = "student_num", nullable = false, length = 100, unique = true) // null 값 허용하지 않음, 길이 100
    private String studentNum; // 학번

    @Column(nullable = false, length = 255) // null 값 허용하지 않음, 길이 255
    private String password; // 비밀번호

    // 닉네임 컬럼
    @Column(name = "nickname", nullable = false, length = 255)
    private String nickname; // 닉네임

    // 프로필 이미지 난수 컬럼(1~4)
    @Column(name = "profile_image")
    private Integer profileImage; // 프로필 이미지 난수

    // 대여 횟수
    @Column(name = "rental_count", nullable = false, columnDefinition = "int default 0")
    private int rentalCount = 0; // 대여 횟수 초기값 0

    // 대여 포인트
    @Column(name = "rental_point", nullable = false, columnDefinition = "int default 0")
    private int rentalPoint = 0;

    public void incrementRentalCount() {
        this.rentalCount++; // 대여 횟수 증가
    }

    // 대여 횟수가 1증가하면 포인트는 10증가
    public void incrementRentalPoint() {
        this.rentalPoint += 10; // 대여 포인트 증가
    }

}
