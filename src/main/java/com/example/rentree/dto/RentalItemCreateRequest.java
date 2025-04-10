package com.example.rentree.dto;

import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class RentalItemCreateRequest {

    private String studentId;
    private String title;
    private String description;
    private Boolean isFaceToFace;
    private LocalDate rentalDate;
    private Long categoryId;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;

    private List<String> photoUrls;

    public RentalItemCreateRequest() {}
}
