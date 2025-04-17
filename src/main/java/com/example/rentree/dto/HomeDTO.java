package com.example.rentree.dto;

import com.example.rentree.domain.ItemRequest;
import com.example.rentree.domain.RentalItem;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.sql.Timestamp;
import java.time.LocalDateTime;

@Data
public class HomeDTO {

    private int id;
    private String studentNum;
    private String title;
    private String description;
    private Boolean isFaceToFace;
    private Timestamp createdAt;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;
    private String itemType;
    private String nickname;
    private int viewCount;

    @JsonInclude(JsonInclude.Include.NON_NULL) // null 값은 JSON에 포함되지 않음
    private Long categoryId;

    // HomeDTO 클래스에 ItemRequestDTO 생성자 추가 (클라이언트에서 받은 데이터를 HomeDTO로 변환)
    public HomeDTO(ItemRequestDTO itemRequestDTO) {
        this.id = itemRequestDTO.getId();
        this.studentNum = itemRequestDTO.getStudentNum();
        this.title = itemRequestDTO.getTitle();
        this.description = itemRequestDTO.getDescription();
        this.isFaceToFace = itemRequestDTO.isFaceToFace();
        this.createdAt = itemRequestDTO.getCreatedAt();
        this.rentalStartTime = itemRequestDTO.getRentalStartTime();
        this.rentalEndTime = itemRequestDTO.getRentalEndTime();
        this.itemType = "itemRequest";
        this.nickname = itemRequestDTO.getNickname();
        this.viewCount = itemRequestDTO.getViewCount();
    }

    // ItemRequestDTO 생성자 (엔티티 데이터를 HomeDTO로 변환해 클라이언트에 반환)
    public HomeDTO(ItemRequest itemRequest) {
        this.id = itemRequest.getId();
        this.title = itemRequest.getTitle();
        this.description = itemRequest.getDescription();
        this.studentNum = itemRequest.getStudent().getStudentNum();  // Student 객체에서 학번 가져오기
        this.nickname = itemRequest.getStudent().getNickname();      // Student 객체에서 닉네임 가져오기
        this.isFaceToFace = itemRequest.isFaceToFace();
        this.createdAt = itemRequest.getCreatedAt();
        this.rentalStartTime = itemRequest.getRentalStartTime();     // 필드명이 일치함
        this.rentalEndTime = itemRequest.getRentalEndTime();         // 필드명이 일치함
        this.viewCount = itemRequest.getViewCount();
        this.itemType = "REQUEST";
    }
    // RentalItemCreateRequest 생성자
    public HomeDTO(RentalItemCreateRequest rentalItemCreateRequest) {
        //this.id = rentalItemCreateRequest.getId();
        this.studentNum = rentalItemCreateRequest.getStudentNum();
        this.title = rentalItemCreateRequest.getTitle();
        this.description = rentalItemCreateRequest.getDescription();
        this.isFaceToFace = rentalItemCreateRequest.getIsFaceToFace();
        this.createdAt = rentalItemCreateRequest.getCreatedAt();
        this.rentalStartTime = rentalItemCreateRequest.getRentalStartTime();
        this.rentalEndTime = rentalItemCreateRequest.getRentalEndTime();
        this.itemType = "rentalItem";
        this.categoryId = rentalItemCreateRequest.getCategoryId();
    }

    // HomeDTO 클래스에 RentalItem 생성자 추가
    public HomeDTO(RentalItem rentalItem) {
        //this.id = rentalItem.getId();
        this.studentNum = rentalItem.getStudent().getStudentNum();  // Student 객체에서 학번 가져오기
        this.title = rentalItem.getTitle();
        this.description = rentalItem.getDescription();
        this.isFaceToFace = rentalItem.getIsFaceToFace();
        this.createdAt = rentalItem.getCreatedAt();
        this.rentalStartTime = rentalItem.getRentalStartTime();
        this.rentalEndTime = rentalItem.getRentalEndTime();
        this.itemType = "RENTAL";
        //this.categoryId = rentalItem.getCategoryId();
    }
}