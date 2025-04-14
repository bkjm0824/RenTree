package com.example.rentree.dto;

import lombok.Getter;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class RentalItemUpdateRequest {

    private String title;
    private String description;
    private Boolean isFaceToFace;
    private Timestamp createdAt;
    private Long categoryId;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;

}
