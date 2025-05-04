package com.example.rentree.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomResponseDTO {
    private Long roomId;                // 채팅방 ID
    private Long rentalItemId;          // 물품 ID (채팅방이 연결된 물품)
    private String rentalItemTitle;     // 물품 제목
    private String requesterNickname;   // 요청자 닉네임 (학번 대신 닉네임 사용)
    private String responderNickname;   // 응답자 닉네임 (학번 대신 닉네임 사용)
    private String requesterStudentNum;
    private String responderStudentNum; // 응답자 학번
    private LocalDateTime createdAt;    // 채팅방 생성 시간
}
