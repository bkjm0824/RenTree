package com.example.rentree.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RentalChatMessageDeleteResponseDTO {
    private Long messageId;
    private String message;
}
