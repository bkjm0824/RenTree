package com.example.rentree.dto;

import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
public class RentalItemUpdateRequest {

    private String title;
    private String description;
    private Boolean isFaceToFace;
    private String photoUrl;
    private LocalDate rentalDate;
    private Long categoryId;
    private LocalDateTime rentalStartTime;
    private LocalDateTime rentalEndTime;

    public RentalItemUpdateRequest() {
    }
}
