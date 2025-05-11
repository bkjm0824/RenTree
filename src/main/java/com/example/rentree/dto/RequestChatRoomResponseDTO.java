package com.example.rentree.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class RequestChatRoomResponseDTO {

    private Long roomId;
    private Long itemRequestId;
    private String itemRequestTitle;

    private String requesterStudentNum;
    private String requesterNickname;
    private Integer requesterProfileImage;

    private String responderStudentNum;
    private String responderNickname;
    private Integer responderProfileImage;

    private boolean requesterExited;
    private boolean responderExited;

    private LocalDateTime createdAt;
}
