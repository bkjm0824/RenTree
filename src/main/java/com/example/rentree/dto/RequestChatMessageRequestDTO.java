package com.example.rentree.dto;

import lombok.Data;

@Data
public class RequestChatMessageRequestDTO {
    private Long chatRoomId;
    private String senderStudentNum;
    private String receiverStudentNum;
    private String message;
}
