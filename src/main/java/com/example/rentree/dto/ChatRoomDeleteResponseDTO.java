package com.example.rentree.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomDeleteResponseDTO {
    private Long deletedRoomId;        // 삭제된 채팅방 ID
    private String message;            // 삭제 메시지
}
