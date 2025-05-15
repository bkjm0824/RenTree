package com.example.rentree.dto;

import com.example.rentree.domain.ItemRequest;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/*
요청 정보를 담는 DTO 클래스
클라이언트와 서버 간 데이터 교환을 위해 사용
필요한 데이터만 담아 전송
 */

@Data // getter, setter, toString, equals, hashCode 메서드 자동 생성
public class ItemRequestResponseDTO {

    private Long id; // 요청 식별자
    //private String studentNum; // 학번 (외래키 역할)
    private String nickname; // 닉네임
    private String title; // 제목
    private String description; // 설명

    //@JsonFormat(pattern = "HH:mm:ss")  // 시간 포맷 지정
    private LocalDateTime rentalStartTime; // 요청 시간 From

    //@JsonFormat(pattern = "HH:mm:ss")  // 시간 포맷 지정
    private LocalDateTime rentalEndTime; // 요청 시간 To

    private Boolean isFaceToFace; // 대면 여부

    private Timestamp createdAt; // 요청 시간

    private Integer profileImage;

    private String password;

    //private Integer viewCount = 0; // 조회수

    /*
    ItemRequest 객체를 ItemRequestDTO 객체로 변환하는 메서드
    @param itemRequest : ItemRequest 객체
    @return : ItemRequestDTO 객체
     */

    // ItemRequest 객체를 ItemRequestResponseDTO 객체로 변환하는 메서드
    public static ItemRequestResponseDTO fromEntity(ItemRequest itemRequest) {
        ItemRequestResponseDTO dto = new ItemRequestResponseDTO();
        dto.setId(itemRequest.getId());
        //dto.setStudentNum(itemRequest.getStudent().getStudentNum());
        dto.setNickname(itemRequest.getStudent().getNickname());
        dto.setTitle(itemRequest.getTitle());
        dto.setDescription(itemRequest.getDescription());
        dto.setRentalStartTime(itemRequest.getRentalStartTime());
        dto.setRentalEndTime(itemRequest.getRentalEndTime());
        dto.setIsFaceToFace(itemRequest.getIsFaceToFace());
        dto.setCreatedAt(itemRequest.getCreatedAt());
        dto.setProfileImage(itemRequest.getStudent().getProfileImage());
        dto.setPassword(itemRequest.getPassword());
        return dto;
    }

    /*
    CREATE TABLE Item_Request (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT, -- Foreign Key (참조 대상: student.id)
    title VARCHAR(255),
    `description` TEXT,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
    );
     */
}