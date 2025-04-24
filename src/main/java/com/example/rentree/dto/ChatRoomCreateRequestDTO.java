package com.example.rentree.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomCreateRequestDTO {
    private Long rentalItemId;         // 해당 채팅방이 어떤 물품에 대한 대화인지
    private String requesterStudentNum; // 채팅을 시작한 학생의 학번
}
