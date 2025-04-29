package com.example.rentree.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageRequestDTO {

    private Long chatRoomId;            // 채팅방 ID
    private String senderStudentNum;    // 발신자 학번
    private String message;             // 메시지 내용
}
