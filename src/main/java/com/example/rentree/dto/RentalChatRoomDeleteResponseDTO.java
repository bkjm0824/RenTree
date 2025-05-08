package com.example.rentree.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RentalChatRoomDeleteResponseDTO {
    private Long roomId;
    private String message;
}
