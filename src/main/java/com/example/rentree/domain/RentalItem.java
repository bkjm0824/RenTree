package com.example.rentree.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
public class RentalItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String studentId; // 학번 (외래키, 문자열로 가정)

    @Column(nullable = false, length = 255)
    private String title; // 제목

    @Column(columnDefinition = "TEXT")
    private String description; // 설명

    @Column(nullable = false)
    private Boolean isFaceToFace; // 대면 여부

    @Column(length = 255)
    private String photoUrl; // 사진 URL

    private LocalDate rentalDate; // 대여 일자

    @Column(nullable = false)
    private Integer viewCount = 0; // 조회수

    @Column(nullable = false)
    private Long categoryId; // 카테고리 ID (외래키)

    private LocalDateTime rentalStartTime; // 대여 시작 시간
    private LocalDateTime rentalEndTime;   // 대여 종료 시간

    protected RentalItem() {}

    public RentalItem(String studentId, String title, String description, Boolean isFaceToFace,
                      String photoUrl, LocalDate rentalDate, Long categoryId,
                      LocalDateTime rentalStartTime, LocalDateTime rentalEndTime) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("제목은 필수 입력 사항입니다.");
        }
        this.studentId = studentId;
        this.title = title;
        this.description = description;
        this.isFaceToFace = isFaceToFace;
        this.photoUrl = photoUrl;
        this.rentalDate = rentalDate;
        this.categoryId = categoryId;
        this.rentalStartTime = rentalStartTime;
        this.rentalEndTime = rentalEndTime;
    }

    public void incrementViewCount() {
        this.viewCount++;
    }
}




