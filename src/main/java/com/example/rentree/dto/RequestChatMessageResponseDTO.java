package com.example.rentree.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class RequestChatMessageResponseDTO {
    private Long messageId;
    private Long chatRoomId;
    private String senderStudentNum;
    private String senderNickname;
    private String receiverStudentNum;
    private String receiverNickname;
    private String message;
    private LocalDateTime sentAt;
}
