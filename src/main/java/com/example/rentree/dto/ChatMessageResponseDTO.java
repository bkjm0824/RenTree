package com.example.rentree.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageResponseDTO {

    private Long messageId;             // 메시지 ID
    private Long chatRoomId;            // 채팅방 ID
    private String senderStudentNum;    // 발신자 학번
    private String senderNickname;      // 발신자 닉네임
    private String message;             // 메시지 내용
    private LocalDateTime sentAt;       // 보낸 시간
}
