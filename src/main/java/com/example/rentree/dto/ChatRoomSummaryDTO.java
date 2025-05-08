package com.example.rentree.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class ChatRoomSummaryDTO {
    private Long roomId;
    private String type; // "rental" or "request"

    private Long relatedItemId;
    private String relatedItemTitle;

    private String requesterStudentNum;
    private String responderStudentNum;

    private String requesterNickname;
    private String responderNickname;

    private LocalDateTime createdAt;
}
