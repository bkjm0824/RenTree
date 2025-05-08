package com.example.rentree.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RequestChatRoomDeleteResponseDTO {
    private Long roomId;
    private String message;
}
