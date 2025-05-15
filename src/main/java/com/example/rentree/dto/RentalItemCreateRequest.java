package com.example.rentree.dto;

import lombok.Getter;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class RentalItemCreateRequest {
    private Long id;
    private String studentNum;
    private String title;
    private String description;
    private Boolean isFaceToFace;
    private Timestamp createdAt;
    private Long categoryId;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;
    private String password;


    public RentalItemCreateRequest() {}

}
