package com.example.rentree.dto;

import lombok.Data;

@Data
public class RentalChatRoomCreateRequestDTO {
    private Long rentalItemId;
    private String requesterStudentNum;
}
