package com.example.rentree.domain;

import com.example.rentree.dto.ItemRequestDTO;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

import java.sql.Timestamp;
import java.time.LocalTime;

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
    @Column(nullable = false)
    private int id; // 요청 식별자

    @Column(name = "student_id", nullable = false) // student 테이블의 id를 참조
    private int studentId; // 학생 식별자 (외래키)

    @Column(nullable = false, length = 255)
    private String title; // 제목

    @Column(name = "description", nullable = false, columnDefinition = "TEXT") // TEXT 타입으로 지정
    private String description; // 설명

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime; // 요청 시간 From

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime; // 요청 시간 To

    @Column(name = "face_to_face", nullable = false)
    private boolean isPerson;

    @Column(name = "created_at", updatable = false, insertable = false)
    private Timestamp createdAt; // 요청 시간

    public static ItemRequest fromItemRequestDTO(ItemRequestDTO itemRequestDTO)
    {
        return ItemRequest.builder()
                .id(itemRequestDTO.getId())
                .studentId(itemRequestDTO.getStudentId())
                .title(itemRequestDTO.getTitle())
                .description(itemRequestDTO.getDescription())
                .startTime(itemRequestDTO.getStartTime())
                .endTime(itemRequestDTO.getEndTime())
                .isPerson(itemRequestDTO.isPerson())
                .createdAt(itemRequestDTO.getCreatedAt())
                .build();
    }
}
