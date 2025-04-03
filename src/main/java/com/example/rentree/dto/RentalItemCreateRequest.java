package com.example.rentree.dto;

import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
public class RentalItemCreateRequest {

    // Getter 메서드
    private String studentId;  // 학번
    private String title;  // 제목
    private String description;  // 설명
    private Boolean isFaceToFace;  // 대면 여부
    private String photoUrl;  // 사진 URL
    private LocalDate rentalDate;  // 대여 일자
    private Long categoryId;  // 카테고리 ID
    private LocalDateTime rentalStartTime;  // 대여 시작 시간
    private LocalDateTime rentalEndTime;  // 대여 종료 시간

    // 기본 생성자 (JSON 직렬화/역직렬화 시 필요)
    public RentalItemCreateRequest() {}

}
