package com.example.rentree.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class RentalChatRoomResponseDTO {

    private Long roomId;
    private Long rentalItemId;
    private String rentalItemTitle;

    private String requesterStudentNum;
    private String requesterNickname;

    private String responderStudentNum;
    private String responderNickname;

    private LocalDateTime createdAt;
}
