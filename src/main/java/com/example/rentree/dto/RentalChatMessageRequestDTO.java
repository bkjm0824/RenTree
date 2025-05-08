package com.example.rentree.dto;

import lombok.Data;

@Data
public class RentalChatMessageRequestDTO {
    private Long chatRoomId;
    private String senderStudentNum;
    private String receiverStudentNum;
    private String message;
}
