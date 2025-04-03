package com.example.rentree.dto;

import com.example.rentree.domain.ItemRequest;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.sql.Timestamp;
import java.time.LocalTime;

/*
요청 정보를 담는 DTO 클래스
클라이언트와 서버 간 데이터 교환을 위해 사용
필요한 데이터만 담아 전송
 */

@Data // getter, setter, toString, equals, hashCode 메서드 자동 생성
public class ItemRequestDTO {

    private int id; // 요청 식별자
    private int studentId; // 학생 식별자
    private String title; // 제목
    private String description; // 설명

    @JsonFormat(pattern = "HH:mm:ss")  // 시간 포맷 지정
    private LocalTime startTime; // 요청 시간 From

    @JsonFormat(pattern = "HH:mm:ss")  // 시간 포맷 지정
    private LocalTime endTime; // 요청 시간 To

    private boolean isPerson; // 대면 여부

    private Timestamp createdAt; // 요청 시간

    /*
    ItemRequest 객체를 ItemRequestDTO 객체로 변환하는 메서드
    @param itemRequest : ItemRequest 객체
    @return : ItemRequestDTO 객체
     */

    public static ItemRequestDTO fromEntity(ItemRequest itemRequest) {
        ItemRequestDTO dto = new ItemRequestDTO();
        dto.setId(itemRequest.getId());
        dto.setStudentId(itemRequest.getStudentId());
        dto.setTitle(itemRequest.getTitle());
        dto.setDescription(itemRequest.getDescription());
        dto.setStartTime(itemRequest.getStartTime());
        dto.setEndTime(itemRequest.getEndTime());
        dto.setPerson(itemRequest.isPerson());
        dto.setCreatedAt(itemRequest.getCreatedAt());
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
