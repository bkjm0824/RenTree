package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/*
요청 정보를 담는 엔티티 클래스
데이터베이스의 Item_Request 테이블과 1:1 매핑
데이터베이스에서 데이터를 CRUD할 때 사용
 */

@AllArgsConstructor // 모든 필드 값을 파라미터로 받는 생성자 생성
@NoArgsConstructor // 파라미터가 없는 기본 생성자 생성
@Getter // 모든 필드에 대한 getter 메서드 생성
@Setter // 모든 필드에 대한 setter 메서드 생성
@ToString // 모든 필드에 대한 toString 메서드 생성
@Builder // 빌더 패턴을 사용할 수 있게 해줌
@Entity // JPA 엔티티 클래스임을 명시 (데이터베이스의 테이블과 매핑)
@Table(name = "Item_Request") // 데이터베이스의 Item_Request 테이블과 매핑
public class ItemRequest {

    @Id // 기본 키임을 명시
    @GeneratedValue(strategy = GenerationType.IDENTITY) // auto_increment
    @Column(nullable = false)
    private Long id; // 요청 식별자

    // studentNum을 외래키로 연결
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_num", referencedColumnName = "student_num", nullable = false)
    private Student student;

    @Column(nullable = false, length = 255)
    private String title; // 제목

    @Column(name = "description", nullable = false, columnDefinition = "TEXT") // TEXT 타입으로 지정
    private String description; // 설명

    @Column(name = "start_time", nullable = false)
    private LocalDateTime rentalStartTime; // 요청 시간 From

    @Column(name = "end_time", nullable = false)
    private LocalDateTime rentalEndTime; // 요청 시간 To

    @Column(name = "face_to_face", nullable = false)
    private Boolean isFaceToFace;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Timestamp createdAt;

    @Column(nullable = false)
    private Integer viewCount = 0;

    @Column(nullable = false)
    private Boolean isAvailable = true; // 요청 가능 여부

    // 비밀번호
    @Column(name = "password")
    private String password;

    @Column(name = "returned", nullable = false)
    private Boolean isReturned = false;

    @Column(name = "actual_return_time")
    private LocalDateTime actualReturnTime;


    public void incrementViewCount() {
        this.viewCount++;
    }

    public ItemRequest(Student student, String title, String description, Boolean isFaceToFace,
                       Timestamp createdAt, LocalDateTime rentalStartTime, LocalDateTime rentalEndTime, String password) {
        this.student = student;
        this.title = title;
        this.description = description;
        this.isFaceToFace = isFaceToFace;
        this.createdAt = createdAt;
        this.rentalStartTime = rentalStartTime;
        this.rentalEndTime = rentalEndTime;
        this.password = password;
    }

    public void markAsRequested() {this.isAvailable = false; } // 요청 처리 완료 시 호출되는 메서드

    public void markAsAvailable() {
        this.isAvailable = true;
    }
}
