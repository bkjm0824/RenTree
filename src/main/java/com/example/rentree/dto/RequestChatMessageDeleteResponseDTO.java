package com.example.rentree.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RequestChatMessageDeleteResponseDTO {
    private Long messageId;
    private String message;
}
